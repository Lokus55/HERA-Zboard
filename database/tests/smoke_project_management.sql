-- Run after 001, 002 and 003 as the SQL Editor role in a test project.
begin;

insert into auth.users (id, email, email_confirmed_at, raw_user_meta_data)
values ('20000000-0000-4000-8000-000000000001', 'management-owner@example.test', now(), '{"full_name":"Owner"}'),
       ('20000000-0000-4000-8000-000000000003', 'management-outsider@example.test', now(), '{"full_name":"Outsider"}');

set local role authenticated;
select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000001', true);
do $$
declare
  workspace uuid;
  board uuid;
  token text;
begin
  insert into public.workspaces (owner_id, name, slug)
  values (auth.uid(), 'Management Smoke', 'management-smoke') returning id into workspace;
  insert into public.projects (workspace_id, created_by, name)
  values (workspace, auth.uid(), 'Original title') returning id into board;
  update public.projects set name = 'Edited title', archived_at = now() where id = board;
  if not exists (select 1 from public.projects where id = board and name = 'Edited title' and archived_at is not null) then
    raise exception 'Owner should be able to edit and archive a project';
  end if;
  update public.projects set archived_at = null where id = board;
  if not exists (select 1 from public.projects where id = board and archived_at is null) then
    raise exception 'Owner should be able to restore a project';
  end if;

  token := public.create_workspace_invite(workspace, 'management-invitee@example.test');
  perform set_config('zboard.test_management_previous_token', token, true);
  token := public.create_workspace_invite(workspace, ' MANAGEMENT-INVITEE@example.test ');
  if token !~ '^[a-f0-9]{64}$' then raise exception 'Invalid invitation token'; end if;
  perform set_config('zboard.test_management_token', token, true);
  perform set_config('zboard.test_management_workspace', workspace::text, true);
  perform set_config('zboard.test_management_project', board::text, true);
end;
$$;

select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000003', true);
do $$
begin
  begin
    perform public.accept_workspace_invite(current_setting('zboard.test_management_token'));
    raise exception 'Wrong account was able to accept the invitation';
  exception when insufficient_privilege then null;
  end;

  begin
    perform public.create_workspace_invite(current_setting('zboard.test_management_workspace')::uuid, 'outsider-invite@example.test');
    raise exception 'Outsider was able to create an invitation';
  exception when insufficient_privilege then null;
  end;
end;
$$;

reset role;
insert into auth.users (id, email, raw_user_meta_data)
values ('20000000-0000-4000-8000-000000000002', 'management-invitee@example.test', '{"full_name":"Invitee"}');

set local role authenticated;
select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000002', true);
do $$
begin
  begin
    perform public.accept_workspace_invite(current_setting('zboard.test_management_token'));
    raise exception 'Unconfirmed account was able to accept the invitation';
  exception when insufficient_privilege then null;
  end;
end;
$$;

reset role;
update auth.users set email_confirmed_at = now() where id = '20000000-0000-4000-8000-000000000002';

set local role authenticated;
select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000002', true);
do $$
declare
  workspace uuid := current_setting('zboard.test_management_workspace')::uuid;
  board uuid := current_setting('zboard.test_management_project')::uuid;
  token text := current_setting('zboard.test_management_token');
  status uuid;
  task uuid;
begin
  begin
    perform public.accept_workspace_invite(current_setting('zboard.test_management_previous_token'));
    raise exception 'Old invitation was accepted after rotation';
  exception when no_data_found then null;
  end;
  if public.accept_workspace_invite(token) is distinct from workspace then
    raise exception 'Invitation returned the wrong workspace';
  end if;
  begin
    perform public.accept_workspace_invite(token);
    raise exception 'Consumed invitation was accepted again';
  exception when no_data_found then null;
  end;

  update public.projects set name = 'Unauthorized edit' where id = board;
  if found then raise exception 'A member could edit the project'; end if;
  begin
    perform public.remove_workspace_member(workspace, auth.uid());
    raise exception 'A member could remove workspace members';
  exception when insufficient_privilege then null;
  end;

  select id into status from public.task_statuses where project_id = board order by position limit 1;
  task := public.save_board_task_with_due_date(board, null, 'Management task', '', status, 'medium',
    array[auth.uid()], '{}', date '2027-01-08');
  if (select due_date from public.tasks where id = task) is distinct from date '2027-01-08' then
    raise exception 'Due date was not saved';
  end if;
  perform public.save_board_task_with_due_date(board, task, 'Management task', '', status, 'medium',
    array[auth.uid()], '{}', null);
  if exists (select 1 from public.tasks where id = task and due_date is not null) then
    raise exception 'Due date was not cleared';
  end if;
  if (select count(*) from public.task_activities where task_id = task and field_name = 'due_date') <> 2 then
    raise exception 'Due date changes are missing from task history';
  end if;
  perform set_config('zboard.test_management_task', task::text, true);
end;
$$;

select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000001', true);
do $$
declare
  workspace uuid := current_setting('zboard.test_management_workspace')::uuid;
  task uuid := current_setting('zboard.test_management_task')::uuid;
  invitee uuid := '20000000-0000-4000-8000-000000000002';
begin
  begin
    perform public.remove_workspace_member(workspace, auth.uid());
    raise exception 'The owner could remove their own membership';
  exception when invalid_parameter_value then null;
  end;
  perform public.remove_workspace_member(workspace, invitee);
  if exists (select 1 from public.workspace_members where workspace_id = workspace and user_id = invitee)
    or exists (select 1 from public.task_assignees where task_id = task and user_id = invitee) then
    raise exception 'Removing the member left membership or assignments behind';
  end if;
end;
$$;

select set_config('request.jwt.claim.sub', '20000000-0000-4000-8000-000000000002', true);
do $$
begin
  if exists (select 1 from public.projects where id = current_setting('zboard.test_management_project')::uuid) then
    raise exception 'Former member retained access to the project';
  end if;
end;
$$;

reset role;
rollback;
