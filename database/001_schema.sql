begin;

create table public.profiles (
  id uuid primary key,
  email text not null,
  full_name text
);

create table public.workspaces (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id),
  name text not null check (btrim(name) <> ''),
  slug text not null,
  color text not null default '#06b6d4',
  created_at timestamptz not null default now()
);

create table public.workspace_members (
  workspace_id uuid references public.workspaces(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  role text not null check (role in ('owner', 'member')),
  primary key (workspace_id, user_id)
);

create table public.projects (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  created_by uuid references public.profiles(id) on delete set null,
  name text not null check (btrim(name) <> ''),
  description text not null default '',
  color text not null default '#06b6d4',
  created_at timestamptz not null default now()
);

create table public.task_statuses (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  name text not null check (btrim(name) <> ''),
  color text not null default '#06b6d4',
  position integer not null default 0,
  unique (project_id, id)
);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  status_id uuid not null,
  title text not null check (btrim(title) <> ''),
  description text not null default '',
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high')),
  position integer not null default 0,
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (project_id, status_id) references public.task_statuses(project_id, id)
);

create table public.labels (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  name text not null check (btrim(name) <> ''),
  color text not null default '#06b6d4',
  created_at timestamptz not null default now()
);

create table public.task_labels (
  task_id uuid references public.tasks(id) on delete cascade,
  label_id uuid references public.labels(id) on delete cascade,
  primary key (task_id, label_id)
);

create table public.task_assignees (
  task_id uuid references public.tasks(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  assigned_by uuid references public.profiles(id) on delete set null,
  primary key (task_id, user_id)
);

create table public.project_documents (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  created_by uuid references public.profiles(id) on delete set null,
  title text not null check (btrim(title) <> ''),
  slug text not null check (slug ~ '^[A-Za-z0-9_-]+$'),
  content text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.task_activities (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  task_id uuid references public.tasks(id) on delete set null,
  task_title text,
  user_id uuid references public.profiles(id) on delete set null,
  action text not null,
  field_name text,
  old_value text,
  new_value text,
  created_at timestamptz not null default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type text not null,
  title text not null,
  message text not null,
  link text,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index on public.workspace_members (user_id);
create index on public.projects (workspace_id, created_at);
create index on public.tasks (project_id, position);
create index on public.tasks (project_id, status_id);
create index on public.labels (project_id);
create index on public.task_labels (label_id);
create index on public.task_assignees (user_id);
create unique index on public.project_documents (project_id, lower(slug));
create index on public.task_activities (project_id, created_at desc);
create index on public.task_activities (task_id, created_at desc);
create index on public.notifications (user_id, created_at desc);

-- Supabase supplies the policies and grants in the next script.
alter table public.profiles enable row level security;
alter table public.workspaces enable row level security;
alter table public.workspace_members enable row level security;
alter table public.projects enable row level security;
alter table public.task_statuses enable row level security;
alter table public.tasks enable row level security;
alter table public.labels enable row level security;
alter table public.task_labels enable row level security;
alter table public.task_assignees enable row level security;
alter table public.project_documents enable row level security;
alter table public.task_activities enable row level security;
alter table public.notifications enable row level security;

commit;
