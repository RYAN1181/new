# Wishes Wall setup

The HTML files are complete, but persistence will stay disabled until a Supabase project is connected. No private credential belongs in this repository.

## 1. Create the database

1. Create a Supabase project.
2. Open its SQL editor.
3. Paste and run the complete contents of `setup.sql`.

The script creates `wishes` and `wish_admins`, enables Row Level Security, and installs the policies used by the public and admin pages.

## 2. Create and authorize the admin

1. In Supabase Authentication, create the email/password user who will review wishes.
2. Replace the email below and run this in the SQL editor:

```sql
insert into public.wish_admins (user_id)
select id
from auth.users
where email = 'YOUR_ADMIN_EMAIL';
```

The statement should report one inserted row. If it inserts no row, confirm that the Authentication user exists and the email matches exactly.

For a private moderation page, disable public user sign-ups in the Supabase Auth settings. The admin page contains sign-in only; it never creates accounts.

## 3. Connect the website

In Supabase project settings, copy:

- the Project URL
- the publishable key, or the legacy `anon` public key

Put only those two public values into `supabase-config.js`:

```js
window.WEDDING_SUPABASE = Object.freeze({
  url: "https://your-project-ref.supabase.co",
  anonKey: "your-publishable-or-anon-key"
});
```

Never use the `service_role` key. It bypasses Row Level Security and must never be exposed by a static website.

## 4. Configure and publish GitHub Pages

In Supabase Auth URL configuration, use the GitHub Pages address as the Site URL:

```text
https://ryan1181.github.io/new/
```

Push these files to the repository's `main` branch and keep GitHub Pages configured to publish from that branch. The pages will be:

- Invitation: `https://ryan1181.github.io/new/`
- Private moderation: `https://ryan1181.github.io/new/admin.html`

The `noindex` directive keeps normal search engines from listing the admin page, but it is not the security boundary. Supabase Authentication and RLS are the security boundary.

## 5. Verify the complete workflow

Use a private/incognito window for the public checks.

1. Open the invitation and submit a test wish.
2. Refresh the invitation. The pending wish must not appear.
3. Open `admin.html` and confirm that invalid or non-admin accounts cannot enter.
4. Sign in with the authorized admin and approve the test wish.
5. Refresh the invitation in the private window. The approved wish must appear.
6. Reject or move the wish back to pending. It must disappear from the public page.
7. Submit `<img src=x onerror=alert(1)>` as a test message. After approval, it must appear as harmless text—not execute.
8. Confirm an anonymous browser cannot update or delete a row through the Supabase API.

## Moderation states

- `pending` — private, awaiting review
- `approved` — public on the invitation
- `rejected` — private and retained for review

Deleting is permanent. Moving an approved wish back to pending or rejected hides it without deleting it.

## Spam protection

The form includes a hidden honeypot and disables repeat clicks while submitting. These reduce accidental and basic bot submissions, but client-side controls cannot stop determined abuse. If spam becomes a problem, add server-side rate limiting or CAPTCHA through a Supabase Edge Function; do not weaken the RLS policies.
