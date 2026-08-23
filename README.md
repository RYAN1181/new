# Ranganathan & Megha — Reception Invitation

A static GitHub Pages wedding invitation with a persistent Wishes Wall and admin-controlled approval mode.

## How wishes work

1. A guest submits a name and message on `index.html`.
2. Supabase checks the protected `wish_settings` row. New wishes become `approved` immediately when auto-approval is on, or `pending` when it is off.
3. An authorized account signs in at `admin.html` to change the auto-approval setting and moderate any wish.
4. Only approved wishes are returned to visitors and shown on the invitation.

The site remains static. Supabase provides the database, authentication, and Row Level Security that separates public access from moderation access.

## Set up

Follow [SETUP.md](SETUP.md). It covers the database script, admin account, browser-safe key, deployment, and verification.

Never commit a Supabase `service_role` key, database password, or admin password. Only the project URL and publishable/anon browser key belong in `supabase-config.js`.

## Main files

- `index.html` — invitation, public wish submission, and approved wishes
- `admin.html` — authenticated moderation dashboard
- `supabase-config.js` — public Supabase project configuration
- `setup.sql` — schema, indexes, trigger, grants, and RLS policies
- `SETUP.md` — deployment instructions and test checklist
- `docs/project/` — product intent, architecture, and decision record
