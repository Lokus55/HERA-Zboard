# Zboard

Tablero Kanban para equipos. Cada instalación utiliza su propia base de datos y sus propias cuentas.

## Instalación con Supabase

1. Instala Node.js 22 LTS y pnpm 10. Crea un proyecto vacío en Supabase.
2. Abre **SQL Editor** y ejecuta [001_schema.sql](database/001_schema.sql). Después ejecuta [002_supabase.sql](database/002_supabase.sql). Cada archivo se ejecuta como una transacción y se aplica una sola vez.
3. Copia `.env.example` a `.env` y coloca la **Project URL** y la **Publishable key** del proyecto. Una clave pública `anon` de un proyecto que use claves antiguas también sirve. El navegador recibe estos valores. Mantén fuera del frontend la contraseña de PostgreSQL y las claves `service_role` o `secret`.
4. En **Authentication → URL Configuration**, configura **Site URL** con el origen de tu aplicación. Agrega `http://localhost:3000/auth/login` en **Redirect URLs** durante el desarrollo y `https://tu-dominio/auth/login` al desplegar. Habilita el proveedor de correo si está desactivado.
5. Instala dependencias e inicia Nuxt.

```bash
pnpm install --frozen-lockfile
pnpm dev
```

Abre `http://localhost:3000`, registra una cuenta y confirma su correo si tu proyecto lo requiere. Crea un espacio y un proyecto. El proyecto debe abrir con cuatro columnas. Para compartir el espacio, registra y confirma una segunda cuenta. Desde el proyecto, el propietario puede agregarla por correo. La función agrega cuentas existentes.

[Configuración oficial del módulo Nuxt](https://supabase.nuxtjs.org/getting-started/introduction) · [URLs de redirección de Supabase Auth](https://supabase.com/docs/guides/auth/redirect-urls)

## Despliegue estático

Ejecuta `pnpm generate` con las variables de entorno del proyecto y publica `.output/public`. Si cambias de instancia de Supabase, vuelve a generar el sitio. En Netlify el comando, el directorio y la redirección de la SPA se configuran en `netlify.toml`. En otro hosting configura las rutas de la aplicación para que sirvan `index.html` cuando la ruta no corresponda a un archivo.

## Plantilla de base de datos

| Archivo | Contenido |
| --- | --- |
| [001_schema.sql](database/001_schema.sql) | 12 tablas, llaves foráneas, restricciones, índices y activación de RLS. |
| [002_supabase.sql](database/002_supabase.sql) | Integración con Supabase Auth, grants, políticas RLS, funciones RPC, columnas iniciales, historial y notificaciones. |
| [smoke_supabase.sql](database/tests/smoke_supabase.sql) | Prueba de instalación y permisos con tres cuentas temporales. Ejecutar en un proyecto de pruebas. Los datos se revierten al final. |

| Tablas | Datos |
| --- | --- |
| `profiles`, `workspaces`, `workspace_members` | Identidad, propiedad y acceso por espacio. |
| `projects`, `task_statuses`, `tasks` | Proyectos, columnas y tarjetas del tablero. |
| `labels`, `task_labels`, `task_assignees` | Etiquetas y responsables por tarea. |
| `project_documents` | Documentos y sus referencias desde tareas. |
| `task_activities`, `notifications` | Historial y avisos privados al destinatario. |

- `add_workspace_member(workspace, member_email)` exige que el usuario sea propietario y agrega una cuenta confirmada. Los perfiles se consultan por pertenencia a un espacio compartido.
- `save_board_task(board, task, task_title, task_description, task_status, task_priority, assignees, task_label_ids)` crea si `task` es nulo o edita si recibe un ID. Valida responsables y etiquetas y aplica los cambios en una sola transacción.
- Los disparadores sincronizan perfiles, agregan al propietario al crear un espacio, siembran columnas, registran cambios y generan avisos de asignación. El historial conserva el título de las tareas eliminadas mientras exista el proyecto.

[Políticas RLS de Supabase](https://supabase.com/docs/guides/database/postgres/row-level-security)

## PostgreSQL con otro proveedor

Puedes aplicar `001_schema.sql` a PostgreSQL 14 o posterior en una base vacía. El esquema está en `public`, con RLS habilitado. Tu backend debe vincular `profiles.id` a su propio sistema de identidad y usar un rol de aplicación y políticas de acceso adecuados. `002_supabase.sql` depende de `auth.users`, `auth.uid()`, los roles y la API de Supabase.

El frontend actual usa Supabase Auth y la API de datos de Supabase. Una conexión PostgreSQL de Neon, Railway o un servidor propio necesita una API o un servicio compatible. La adaptación debe exponer autenticación, las lecturas y escrituras del tablero y las operaciones equivalentes a las dos RPC. Reutiliza las reglas de acceso y automatizaciones del segundo script con la identidad validada por tu backend. La cadena `DATABASE_URL` pertenece únicamente al servidor. El uso directo de un proveedor PostgreSQL genérico desde este frontend requiere desarrollar esa integración.

## Instalaciones existentes

Los scripts inicializan una base vacía. Para actualizar una instalación anterior, exporta y compara su esquema, funciones y políticas. Prepara una migración incremental en una copia con datos de prueba antes de desplegar esta versión. El frontend usa las dos RPC nuevas y espera asignación de propietario, columnas iniciales y avisos a cargo de la base.
