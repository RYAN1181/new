# High-level architecture

```text
Guest browser                          Admin browser
     |                                     |
     | index.html                          | admin.html + Supabase Auth
     | submit pending / read approved      | read all / change status / delete
     +------------------+------------------+
                        |
                 Supabase browser API
                        |
              PostgreSQL + Row Level Security
                        |
                 wishes / wish_admins
```

GitHub Pages serves the static HTML, images, music, and public configuration. Supabase is the only shared-state component. Its database policies—not hidden URLs or JavaScript checks—enforce the public/admin boundary.

## Trust boundaries

- Everything shipped by GitHub Pages is public and inspectable.
- The Supabase publishable/anon key identifies the project but grants only what RLS policies allow.
- Supabase Auth establishes an admin user's identity.
- A signed-in user can read only their own `wish_admins` membership row; the same membership check is repeated by the moderation policies.
- The Supabase dashboard and SQL editor are operational control surfaces and are not part of the public application.
