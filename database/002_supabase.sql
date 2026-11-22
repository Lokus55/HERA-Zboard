begin;

create schema zboard_private;
revoke all on schema zboard_private from public;
grant usage on schema zboard_private to authenticated;

alter table public.profiles add foreign key (id) references auth.users(id) on delete cascade;

create function zboard_private.sync_profile() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.email is not null then
    insert into public.profiles (id, email, full_name)
    values (new.id, new.email, new.raw_user_meta_data ->> 'full_name')
    on conflict (id) do update set email = excluded.email, full_name = excluded.full_name;
  end if;
  return new;
end;
$$;

create trigger zboard_sync_profile after insert or update of email, raw_user_meta_data
on auth.users for each row execute function zboard_private.sync_profile();

insert into public.profiles (id, email, full_name)
select id, email, raw_user_meta_data ->> 'full_name' from auth.users where email is not null;

create function zboard_private.can_access_workspace(target uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.workspaces where id = target and owner_id = (select auth.uid())
  ) or exists (
    select 1 from public.workspace_members where workspace_id = target and user_id = (select auth.uid())
  );
$$;

create function zboard_private.can_access_project(target uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.projects where id = target and zboard_private.can_access_workspace(workspace_id)
  );
$$;

create function zboard_private.can_access_task(target uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.tasks where id = target and zboard_private.can_access_project(project_id)
  );
$$;

create function zboard_private.can_read_profile(target uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select target = (select auth.uid()) or exists (
    select 1 from public.workspace_members
    where user_id = target and zboard_private.can_access_workspace(workspace_id)
  );
$$;

create function zboard_private.add_workspace_owner() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.workspace_members (workspace_id, user_id, role)
  values (new.id, new.owner_id, 'owner');
  return new;
end;
$$;

create trigger zboard_workspace_owner after insert on public.workspaces
for each row execute function zboard_private.add_workspace_owner();

create function zboard_private.add_default_statuses() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.task_statuses (project_id, name, color, position)
  values (new.id, 'Por hacer', '#64748b', 0),
         (new.id, 'En progreso', '#f59e0b', 1),
         (new.id, 'En revisión', '#8b5cf6', 2),
         (new.id, 'Completado', '#10b981', 3);
  return new;
end;
$$;

create trigger zboard_default_statuses after insert on public.projects
for each row execute function zboard_private.add_default_statuses();

create function public.add_workspace_member(workspace uuid, member_email text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  member_id uuid;
begin
  if not exists (
    select 1 from public.workspaces where id = workspace and owner_id = auth.uid()
  ) then
    raise exception 'Solo el propietario puede agregar miembros' using errcode = '42501';
  end if;

  select p.id into member_id
  from public.profiles p join auth.users u on u.id = p.id
  where lower(u.email) = lower(btrim(member_email)) and u.email_confirmed_at is not null
  limit 1;

  if member_id is null then
    raise exception 'No se encontró una cuenta confirmada con ese correo';
  end if;

  insert into public.workspace_members (workspace_id, user_id, role)
  values (workspace, member_id, 'member') on conflict do nothing;
end;
$$;

create function zboard_private.stamp_task_update() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  new.updated_by := coalesce(auth.uid(), new.updated_by);
  return new;
end;
$$;

create trigger zboard_stamp_task before update on public.tasks
for each row execute function zboard_private.stamp_task_update();

create function zboard_private.log_task_activity() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  old_status text;
  new_status text;
begin
  if tg_op = 'DELETE' then
    if exists (select 1 from public.projects where id = old.project_id) then
      insert into public.task_activities (project_id, task_title, user_id, action)
      values (old.project_id, old.title, auth.uid(), 'deleted');
    end if;
    return old;
  end if;

  if tg_op = 'INSERT' then
    insert into public.task_activities (project_id, task_id, task_title, user_id, action)
    values (new.project_id, new.id, new.title, auth.uid(), 'created');
    return new;
  end if;

  if old.status_id is distinct from new.status_id then
    select name into old_status from public.task_statuses where id = old.status_id;
    select name into new_status from public.task_statuses where id = new.status_id;
    insert into public.task_activities
      (project_id, task_id, task_title, user_id, action, field_name, old_value, new_value)
    values (new.project_id, new.id, new.title, auth.uid(), 'status_changed', 'status_id', old_status, new_status);
  end if;

  insert into public.task_activities
    (project_id, task_id, task_title, user_id, action, field_name, old_value, new_value)
  select new.project_id, new.id, new.title, auth.uid(), 'updated', change.field, change.old_text, change.new_text
  from (values ('title', old.title, new.title),
               ('description', old.description, new.description),
               ('priority', old.priority, new.priority)) as change(field, old_text, new_text)
  where change.old_text is distinct from change.new_text;
  return new;
end;
$$;

create trigger zboard_task_activity after insert or update or delete on public.tasks
for each row execute function zboard_private.log_task_activity();

create function zboard_private.log_task_relation() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  task_row public.tasks;
  relation jsonb;
  display_name text;
  event_name text;
begin
  relation := case when tg_op = 'INSERT' then to_jsonb(new) else to_jsonb(old) end;
  select * into task_row from public.tasks where id = (relation ->> 'task_id')::uuid;
  if not found then
    return null;
  end if;

  if tg_table_name = 'task_assignees' then
    select coalesce(nullif(full_name, ''), email) into display_name
    from public.profiles where id = (relation ->> 'user_id')::uuid;
    event_name := case when tg_op = 'INSERT' then 'assigned' else 'unassigned' end;

    if tg_op = 'INSERT' and (relation ->> 'user_id')::uuid <> auth.uid() then
      insert into public.notifications (user_id, type, title, message, link)
      values ((relation ->> 'user_id')::uuid, 'task_assigned', 'Nueva tarea asignada',
              'Te han asignado "' || task_row.title || '"', '/project/' || task_row.project_id);
    end if;
  else
    select name into display_name from public.labels where id = (relation ->> 'label_id')::uuid;
    event_name := case when tg_op = 'INSERT' then 'label_added' else 'label_removed' end;
  end if;

  insert into public.task_activities
    (project_id, task_id, task_title, user_id, action, old_value, new_value)
  values (task_row.project_id, task_row.id, task_row.title, auth.uid(), event_name,
          case when tg_op = 'DELETE' then coalesce(display_name, '—') end,
          case when tg_op = 'INSERT' then coalesce(display_name, '—') end);
  return null;
end;
$$;

create trigger zboard_assignee_activity after insert or delete on public.task_assignees
for each row execute function zboard_private.log_task_relation();

create trigger zboard_label_activity after insert or delete on public.task_labels
for each row execute function zboard_private.log_task_relation();

create function public.save_board_task(
  board uuid, task uuid, task_title text, task_description text,
  task_status uuid, task_priority text, assignees uuid[], task_label_ids uuid[]
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  account uuid := auth.uid();
  workspace uuid;
  saved_id uuid;
begin
  select workspace_id into workspace from public.projects where id = board;
  if account is null or workspace is null or not zboard_private.can_access_workspace(workspace) then
    raise exception 'Proyecto no accesible' using errcode = '42501';
  end if;

  assignees := coalesce(assignees, '{}'::uuid[]);
  task_label_ids := coalesce(task_label_ids, '{}'::uuid[]);
  if exists (
    select 1 from unnest(assignees) as requested(id)
    where not exists (
      select 1 from public.workspace_members where workspace_id = workspace and user_id = requested.id
    )
  ) or exists (
    select 1 from unnest(task_label_ids) as requested(id)
    where not exists (select 1 from public.labels where project_id = board and id = requested.id)
  ) then
    raise exception 'Una asignación o etiqueta no pertenece al proyecto';
  end if;

  if task is null then
    -- Serialize position allocation for saves on this board.
    perform 1 from public.projects where id = board for no key update;
    insert into public.tasks (project_id, title, description, status_id, priority, created_by, position)
    values (board, btrim(task_title), task_description, task_status, task_priority, account,
            (select coalesce(max(position) + 1, 0) from public.tasks where project_id = board))
    returning id into saved_id;
  else
    update public.tasks
    set title = btrim(task_title), description = task_description, status_id = task_status, priority = task_priority
    where id = task and project_id = board
    returning id into saved_id;
    if saved_id is null then
      raise exception 'Tarea no accesible' using errcode = '42501';
    end if;
  end if;

  delete from public.task_assignees where task_id = saved_id and user_id <> all(assignees);
  insert into public.task_assignees (task_id, user_id, assigned_by)
  select saved_id, requested.id, account from unnest(assignees) as requested(id)
  on conflict do nothing;

  delete from public.task_labels where task_id = saved_id and label_id <> all(task_label_ids);
  insert into public.task_labels (task_id, label_id)
  select saved_id, requested.id from unnest(task_label_ids) as requested(id)
  on conflict do nothing;
  return saved_id;
end;
$$;

revoke all on all functions in schema zboard_private from public, anon, authenticated;
grant execute on function zboard_private.can_access_workspace(uuid),
  zboard_private.can_access_project(uuid), zboard_private.can_access_task(uuid),
  zboard_private.can_read_profile(uuid) to authenticated;

revoke all on function public.add_workspace_member(uuid, text),
  public.save_board_task(uuid, uuid, text, text, uuid, text, uuid[], uuid[]) from public, anon, authenticated;
grant execute on function public.add_workspace_member(uuid, text),
  public.save_board_task(uuid, uuid, text, text, uuid, text, uuid[], uuid[]) to authenticated;

revoke all on
  public.profiles,
  public.workspaces,
  public.workspace_members,
  public.projects,
  public.task_statuses,
  public.tasks,
  public.labels,
  public.task_labels,
  public.task_assignees,
  public.project_documents,
  public.task_activities,
  public.notifications
from public, anon, authenticated;

grant select on public.profiles to authenticated;
create policy profiles_read on public.profiles for select to authenticated
using (zboard_private.can_read_profile(id));

grant select on public.workspaces to authenticated;
create policy workspaces_read on public.workspaces for select to authenticated
using (owner_id = (select auth.uid()) or zboard_private.can_access_workspace(id));

grant select on public.workspace_members to authenticated;
create policy workspace_members_read on public.workspace_members for select to authenticated
using (zboard_private.can_access_workspace(workspace_id));

grant select on public.projects to authenticated;
create policy projects_read on public.projects for select to authenticated
using (zboard_private.can_access_workspace(workspace_id));

grant select on public.task_statuses to authenticated;
create policy task_statuses_read on public.task_statuses for select to authenticated
using (zboard_private.can_access_project(project_id));

grant select on public.tasks to authenticated;
create policy tasks_read on public.tasks for select to authenticated
using (zboard_private.can_access_project(project_id));

grant select on public.labels to authenticated;
create policy labels_read on public.labels for select to authenticated
using (zboard_private.can_access_project(project_id));

grant select on public.task_labels to authenticated;
create policy task_labels_read on public.task_labels for select to authenticated
using (zboard_private.can_access_task(task_id));

grant select on public.task_assignees to authenticated;
create policy task_assignees_read on public.task_assignees for select to authenticated
using (zboard_private.can_access_task(task_id));

grant select on public.project_documents to authenticated;
create policy project_documents_read on public.project_documents for select to authenticated
using (zboard_private.can_access_project(project_id));

grant select on public.task_activities to authenticated;
create policy task_activities_read on public.task_activities for select to authenticated
using (zboard_private.can_access_project(project_id));

grant select on public.notifications to authenticated;
create policy notifications_read on public.notifications for select to authenticated
using (user_id = (select auth.uid()));

grant insert (owner_id, name, slug, color), update (name, color), delete on public.workspaces to authenticated;
create policy workspaces_create on public.workspaces for insert to authenticated
with check (owner_id = (select auth.uid()));
create policy workspaces_edit on public.workspaces for update to authenticated
using (owner_id = (select auth.uid()));
create policy workspaces_delete on public.workspaces for delete to authenticated
using (owner_id = (select auth.uid()));

grant insert (workspace_id, created_by, name, description, color) on public.projects to authenticated;
create policy projects_create on public.projects for insert to authenticated
with check (zboard_private.can_access_workspace(workspace_id) and created_by = (select auth.uid()));

grant insert (project_id, name, color, position), update (name, color, position), delete on public.task_statuses to authenticated;
create policy task_statuses_create on public.task_statuses for insert to authenticated
with check (zboard_private.can_access_project(project_id));
create policy task_statuses_edit on public.task_statuses for update to authenticated
using (zboard_private.can_access_project(project_id));
create policy task_statuses_delete on public.task_statuses for delete to authenticated
using (zboard_private.can_access_project(project_id));

grant insert (project_id, name, color), update (name, color), delete on public.labels to authenticated;
create policy labels_create on public.labels for insert to authenticated
with check (zboard_private.can_access_project(project_id));
create policy labels_edit on public.labels for update to authenticated
using (zboard_private.can_access_project(project_id));
create policy labels_delete on public.labels for delete to authenticated
using (zboard_private.can_access_project(project_id));

grant insert (project_id, created_by, title, slug, content), update (title, slug, content, updated_at), delete on public.project_documents to authenticated;
create policy project_documents_create on public.project_documents for insert to authenticated
with check (zboard_private.can_access_project(project_id) and created_by = (select auth.uid()));
create policy project_documents_edit on public.project_documents for update to authenticated
using (zboard_private.can_access_project(project_id));
create policy project_documents_delete on public.project_documents for delete to authenticated
using (zboard_private.can_access_project(project_id));

grant update (status_id, position), delete on public.tasks to authenticated;
create policy tasks_move on public.tasks for update to authenticated
using (zboard_private.can_access_project(project_id));
create policy tasks_delete on public.tasks for delete to authenticated
using (zboard_private.can_access_project(project_id));

grant update (is_read) on public.notifications to authenticated;
create policy notifications_mark_read on public.notifications for update to authenticated
using (user_id = (select auth.uid()));

notify pgrst, 'reload schema';
commit;
