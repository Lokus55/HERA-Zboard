-- Run in a disposable Supabase project after 001 and 002, as database administrator.
begin;

insert into auth.users (id, email, email_confirmed_at, raw_user_meta_data)
values ('10000000-0000-4000-8000-000000000001', 'zboard-owner@example.test', now(), '{"full_name":"Owner"}'),
       ('10000000-0000-4000-8000-000000000002', 'zboard-member@example.test', now(), '{"full_name":"Member"}'),
       ('10000000-0000-4000-8000-000000000003', 'zboard-outsider@example.test', now(), '{"full_name":"Outsider"}');

set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);

do $$
declare
  workspace uuid;
  board uuid;
  status uuid;
  saved uuid;
  recipient uuid := '10000000-0000-4000-8000-000000000002';
begin
  insert into public.workspaces (owner_id, name, slug)
  values (auth.uid(), 'Smoke Test', 'smoke-test') returning id into workspace;
  if not exists (select 1 from public.workspace_members where workspace_id = workspace and user_id = auth.uid() and role = 'owner') then
    raise exception 'Missing owner membership';
  end if;

  perform public.add_workspace_member(workspace, ' ZBOARD-MEMBER@example.test ');
  insert into public.projects (workspace_id, created_by, name)
  values (workspace, auth.uid(), 'Smoke Project') returning id into board;
  if (select count(*) from public.task_statuses where project_id = board) <> 4 then
    raise exception 'Missing default statuses';
  end if;

  select id into status from public.task_statuses where project_id = board order by position limit 1;
  saved := public.save_board_task(board, null, 'Smoke Task', '', status, 'medium', array[recipient], '{}');
  perform public.save_board_task(board, saved, 'Updated Smoke Task', '', status, 'high', array[recipient], '{}');

  if (select count(*) from public.task_assignees where task_id = saved and user_id = recipient) <> 1 then
    raise exception 'Assignment is missing';
  end if;
  if not exists (select 1 from public.task_activities where task_id = saved and action = 'assigned') then
    raise exception 'Missing assignment activity';
  end if;

  perform set_config('zboard.smoke_board', board::text, true);
  perform set_config('zboard.smoke_workspace', workspace::text, true);
  perform set_config('zboard.smoke_task', saved::text, true);
  perform set_config('zboard.smoke_status', status::text, true);
end;
$$;

select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000002', true);
do $$
declare
  board uuid := current_setting('zboard.smoke_board')::uuid;
  workspace uuid := current_setting('zboard.smoke_workspace')::uuid;
begin
  if not exists (select 1 from public.projects where id = board) then
    raise exception 'Member cannot read shared project';
  end if;
  if (select count(*) from public.notifications where link = '/project/' || board) <> 1 then
    raise exception 'Expected one assignment notification';
  end if;
  update public.notifications set is_read = true where link = '/project/' || board;
  begin
    perform public.add_workspace_member(workspace, 'zboard-outsider@example.test');
    raise exception 'Non-owner could add members';
  exception when insufficient_privilege then null;
  end;
end;
$$;

select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000003', true);
do $$
declare
  board uuid := current_setting('zboard.smoke_board')::uuid;
  status uuid := current_setting('zboard.smoke_status')::uuid;
begin
  if exists (select 1 from public.projects where id = board)
    or exists (select 1 from public.tasks where project_id = board)
    or exists (select 1 from public.notifications where link = '/project/' || board)
    or exists (select 1 from public.profiles where id = '10000000-0000-4000-8000-000000000002') then
    raise exception 'Outsider can read private records';
  end if;
  begin
    perform public.save_board_task(board, null, 'Undesired write', '', status, 'medium', '{}', '{}');
    raise exception 'Outsider could write a task';
  exception when insufficient_privilege then null;
  end;
end;
$$;

select set_config('request.jwt.claim.sub', '10000000-0000-4000-8000-000000000001', true);
do $$
declare
  board uuid := current_setting('zboard.smoke_board')::uuid;
  saved uuid := current_setting('zboard.smoke_task')::uuid;
begin
  delete from public.tasks where id = saved;
  if not exists (select 1 from public.task_activities
                 where project_id = board and action = 'deleted' and task_title = 'Updated Smoke Task') then
    raise exception 'Task deletion was not recorded';
  end if;
  delete from public.workspaces where id = current_setting('zboard.smoke_workspace')::uuid;
  if exists (select 1 from public.projects where id = board) then
    raise exception 'Workspace deletion did not cascade';
  end if;
end;
$$;

reset role;
rollback;
