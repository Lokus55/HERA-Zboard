# Zboard

Zboard is a Kanban board for teams. Organize projects in workspaces, move tasks through custom columns, and use labels, assignees, and project documents to keep track of the work.

The frontend is built with Nuxt and can be deployed as a static site. The included Supabase setup provides PostgreSQL, authentication, and the data API. Each deployment uses its own database and user accounts.

## Quick start

**Requirements** — Node.js 22, pnpm 10, and a new Supabase project with email sign-in enabled.

1. In the Supabase SQL Editor, run [`001_schema.sql`](database/001_schema.sql) and then [`002_supabase.sql`](database/002_supabase.sql). Run each script once, in order, on a fresh database.
2. Copy [`.env.example`](.env.example) to `.env`. Set `NUXT_PUBLIC_SUPABASE_URL` to your project URL and `NUXT_PUBLIC_SUPABASE_KEY` to your publishable key. A legacy `anon` key also works. Keep database passwords and Supabase secret or `service_role` keys server-side.
3. In Supabase **Authentication → URL Configuration**, set the **Site URL** to your app's origin and add `http://localhost:3000/auth/login` to the allowed redirect URLs for local development.
4. From the repository root, install dependencies and start the development server.

```bash
pnpm install --frozen-lockfile
pnpm dev
```

Open `http://localhost:3000`, create an account, and confirm your email if required. Create a workspace and a project to open a board with four starter columns. Workspace owners can add other users by email after those users have registered and confirmed their accounts.

[Nuxt Supabase configuration](https://supabase.nuxtjs.org/getting-started/introduction) · [Supabase Auth redirect URLs](https://supabase.com/docs/guides/auth/redirect-urls)

## Database setup

| File | Purpose |
| --- | --- |
| [`database/001_schema.sql`](database/001_schema.sql) | Creates the application tables, relationships, constraints, and indexes, and enables row-level security. |
| [`database/002_supabase.sql`](database/002_supabase.sql) | Connects the schema to Supabase Auth and adds access policies, database functions, and triggers. |
| [`database/tests/smoke_supabase.sql`](database/tests/smoke_supabase.sql) | Checks setup and access with temporary users. Run it in a test project after both setup scripts. It rolls back its test data. |

| Tables | Purpose |
| --- | --- |
| `profiles`, `workspaces`, `workspace_members` | User profiles, workspace ownership, and membership. |
| `projects`, `task_statuses`, `tasks` | Projects, board columns, and task cards. |
| `labels`, `task_labels`, `task_assignees` | Task labels and assignees. |
| `project_documents` | Project documents that can be referenced from tasks. |
| `task_activities`, `notifications` | Task history and private notifications. |

`add_workspace_member` lets a workspace owner add a confirmed account by email. `save_board_task` validates labels and assignees and saves the task and its assignments in a single transaction. Database triggers create workspace owner memberships and starter columns, keep profiles in sync, record task activity, and send assignment notifications.

[Supabase row-level security](https://supabase.com/docs/guides/database/postgres/row-level-security)

### Using another PostgreSQL provider

Apply `001_schema.sql` to a fresh PostgreSQL 14 or later database. It provides the application schema with row-level security enabled. The second script depends on Supabase Auth and its database roles.

To run Zboard against a different provider, connect the frontend to a compatible API or build a backend that manages authentication, maps identities to `profiles.id`, and enforces workspace access. The backend must also provide the board's data operations and equivalents for the two database functions. Store `DATABASE_URL` on the server.

### Upgrading an existing database

The setup scripts initialize a fresh database. For an existing deployment, compare its schema, functions, and access policies with the templates and test an incremental migration on a copy. The frontend expects both database functions and the triggers for workspace ownership, starter columns, and notifications.

## Deployment

Set the two public Supabase environment variables on your hosting service and build the site.

```bash
pnpm generate
```

Publish `.output/public` and configure the host to serve `index.html` for app routes that do not resolve to a file. [`netlify.toml`](netlify.toml) includes this setup for Netlify. Set the production origin as the Supabase **Site URL** and allow `https://your-domain.example/auth/login` as a redirect. Rebuild the site when switching Supabase projects.
