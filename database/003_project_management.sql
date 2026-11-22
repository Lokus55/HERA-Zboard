begin;

alter table public.projects add column archived_at timestamptz;
alter table public.tasks add column due_date date;

grant update (name, description, color, archived_at) on public.projects to authenticated;
create policy projects_update_owner on public.projects for update to authenticated
using (exists (
  select 1 from public.workspaces w
  where w.id = projects.workspace_id and w.owner_id = (select auth.uid())
))
with check (exists (
  select 1 from public.workspaces w
  where w.id = projects.workspace_id and w.owner_id = (select auth.uid())
));

create table zboard_private.workspace_invitations (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  email text not null,
  token_hash bytea not null unique,
  expires_at timestamptz not null,
  primary key (workspace_id, email)
);
alter table zboard_private.workspace_invitations enable row level security;
revoke all on zboard_private.workspace_invitations from public, anon, authenticated;

create function public.create_workspace_invite(workspace uuid, invite_email text) returns text
language plpgsql security definer set search_path = '' as $$
declare
  normalized_email text := lower(btrim(invite_email));
  token text;
begin
  perform 1 from public.workspaces
  where id = workspace and owner_id = auth.uid() for no key update;
  if not found then
    raise exception 'Only the workspace owner can create invitations' using errcode = '42501';
  end if;

  if normalized_email is null or length(normalized_email) > 254
    or normalized_email !~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$' then
    raise exception 'Invalid invitation email' using errcode = '22023';
  end if;

  if exists (
    select 1 from public.workspace_members m join auth.users u on u.id = m.user_id
    where m.workspace_id = workspace and lower(u.email) = normalized_email
  ) then
    raise exception 'This account already belongs to the workspace' using errcode = '23505';
  end if;

  token := replace(gen_random_uuid()::text || gen_random_uuid()::text, '-', '');
  insert into zboard_private.workspace_invitations (workspace_id, email, token_hash, expires_at)
  values (workspace, normalized_email, sha256(convert_to(token, 'UTF8')), now() + interval '7 days')
  on conflict (workspace_id, email) do update
  set token_hash = excluded.token_hash, expires_at = excluded.expires_at;
  return token;
end;
$$;

create function public.accept_workspace_invite(invite_token text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  account uuid := auth.uid();
  account_email text;
  invite_hash bytea;
  target_workspace uuid;
  invited_email text;
begin
  if account is null then
    raise exception 'Sign in to accept the invitation' using errcode = '42501';
  end if;
  if invite_token is null or invite_token !~ '^[a-f0-9]{64}$' then
    raise exception 'This invitation is invalid, expired, or already used' using errcode = 'P0002';
  end if;

  select lower(email) into account_email from auth.users
  where id = account and email_confirmed_at is not null;
  invite_hash := sha256(convert_to(invite_token, 'UTF8'));

  select workspace_id into target_workspace from zboard_private.workspace_invitations
  where token_hash = invite_hash and expires_at > now();
  if not found then
    raise exception 'This invitation is invalid, expired, or already used' using errcode = 'P0002';
  end if;

  -- Use the same workspace lock as invitation rotation and membership removal.
  perform 1 from public.workspaces where id = target_workspace for no key update;
  select email into invited_email from zboard_private.workspace_invitations
  where workspace_id = target_workspace and token_hash = invite_hash and expires_at > now()
  for update;
  if not found then
    raise exception 'This invitation is invalid, expired, or already used' using errcode = 'P0002';
  end if;
  if account_email is distinct from invited_email then
    raise exception 'Use the confirmed email address that was invited' using errcode = '42501';
  end if;

  insert into public.workspace_members (workspace_id, user_id, role)
  values (target_workspace, account, 'member') on conflict do nothing;
  delete from zboard_private.workspace_invitations where token_hash = invite_hash;
  return target_workspace;
end;
$$;

create function public.remove_workspace_member(workspace uuid, member_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform 1 from public.workspaces
  where id = workspace and owner_id = auth.uid() for no key update;
  if not found then
    raise exception 'Only the workspace owner can remove members' using errcode = '42501';
  end if;

  if member_id = auth.uid() then
    raise exception 'The workspace owner cannot be removed' using errcode = '22023';
  end if;

  delete from public.workspace_members
  where workspace_id = workspace and user_id = member_id and role = 'member';

  delete from zboard_private.workspace_invitations invitation
  using auth.users account
  where invitation.workspace_id = workspace and account.id = member_id
    and invitation.email = lower(account.email);

  delete from public.task_assignees assignment using public.tasks task, public.projects project
  where assignment.user_id = member_id and assignment.task_id = task.id
    and task.project_id = project.id and project.workspace_id = workspace;
end;
$$;

create function zboard_private.log_task_due_date() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.task_activities
    (project_id, task_id, task_title, user_id, action, field_name, old_value, new_value)
  values
    (new.project_id, new.id, new.title, auth.uid(), 'updated', 'due_date',
     to_char(old.due_date, 'YYYY-MM-DD'), to_char(new.due_date, 'YYYY-MM-DD'));
  return new;
end;
$$;

create trigger zboard_due_date_activity after update of due_date on public.tasks
for each row when (old.due_date is distinct from new.due_date)
execute function zboard_private.log_task_due_date();

create function public.save_board_task_with_due_date(
  board uuid, task uuid, task_title text, task_description text,
  task_status uuid, task_priority text, assignees uuid[], task_label_ids uuid[], task_due_date date
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  target_workspace uuid;
  saved_id uuid;
begin
  if not zboard_private.can_access_project(board) then
    raise exception 'Project is not accessible' using errcode = '42501';
  end if;
  if task_due_date is not null and task_due_date not between date '0001-01-01' and date '9999-12-31' then
    raise exception 'Invalid due date' using errcode = '22023';
  end if;

  select workspace_id into target_workspace from public.projects where id = board;
  -- Keep memberships in place until the task and its assignments are saved.
  perform 1 from public.workspace_members
  where workspace_id = target_workspace
    and (user_id = auth.uid() or user_id = any(coalesce(assignees, '{}'::uuid[])))
  order by user_id for key share;

  saved_id := public.save_board_task(
    board, task, task_title, task_description, task_status, task_priority, assignees, task_label_ids
  );
  update public.tasks set due_date = task_due_date
  where id = saved_id and due_date is distinct from task_due_date;
  return saved_id;
end;
$$;

revoke all on function zboard_private.log_task_due_date() from public, anon, authenticated;

revoke all on function public.create_workspace_invite(uuid, text),
  public.accept_workspace_invite(text), public.remove_workspace_member(uuid, uuid),
  public.save_board_task_with_due_date(uuid, uuid, text, text, uuid, text, uuid[], uuid[], date)
from public, anon, authenticated;

grant execute on function public.create_workspace_invite(uuid, text),
  public.accept_workspace_invite(text), public.remove_workspace_member(uuid, uuid),
  public.save_board_task_with_due_date(uuid, uuid, text, text, uuid, text, uuid[], uuid[], date)
to authenticated;

notify pgrst, 'reload schema';
commit;
