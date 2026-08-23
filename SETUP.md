# Wishes Wall setup

The HTML files are complete, but persistence will stay disabled until a Supabase project is connected. No private credential belongs in this repository.

## 1. Create the database

1. Create a Supabase project.
2. Open its SQL editor.
3. Paste and run the complete contents of `setup.sql`.

The script creates `wishes`, `wish_admins`, and the singleton `wish_settings` row, enables Row Level Security, and installs the policies and triggers used by the public and admin pages. It is safe to run the complete script again when upgrading an existing project.

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

## 5. Choose the approval mode

1. Open `admin.html` and sign in with the authorized admin account.
2. Use **Auto-approve new wishes** at the top of the dashboard.
3. Leave it off when every wish should wait in Pending. Turn it on when new wishes should appear publicly immediately.

Changing the switch affects only wishes submitted afterward. Existing pending wishes are not automatically published.

## 6. Verify the complete workflow

Use a private/incognito window for the public checks.

1. Sign in to `admin.html`, turn auto-approval off, and submit a test wish from the invitation.
2. Refresh the invitation. The pending wish must not appear.
3. Confirm that invalid or non-admin accounts cannot enter the dashboard or change `wish_settings`.
4. Approve the pending test wish. Refresh the invitation and confirm it appears.
5. Turn auto-approval on and submit a second test wish. It must appear on the invitation immediately and in the Approved admin tab.
6. Turn auto-approval off and confirm the earlier pending/approved rows do not change state automatically.
7. Reject or move an approved wish back to pending. It must disappear from the public page.
8. Submit `<img src=x onerror=alert(1)>` as a test message. After approval, it must appear as harmless text—not execute.
9. Confirm an anonymous browser cannot update or delete a wish or change `wish_settings` through the Supabase API.

## Moderation states

- `pending` — private, awaiting review
- `approved` — public on the invitation
- `rejected` — private and retained for review

Deleting is permanent. Moving an approved wish back to pending or rejected hides it without deleting it.

## Spam protection

The form includes a hidden honeypot and disables repeat clicks while submitting. These reduce accidental and basic bot submissions, but client-side controls cannot stop determined abuse. If spam becomes a problem, add server-side rate limiting or CAPTCHA through a Supabase Edge Function; do not weaken the RLS policies.
