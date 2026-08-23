# Low-level architecture

## Public invitation

`index.html` creates a Supabase client only when `supabase-config.js` contains a valid project URL and publishable/anon key.

- `submitWish()` trims and validates the form, sends only `name` and `message`, and reloads the approved feed after success so an automatically approved wish appears immediately.
- `loadApprovedWishes()` asks for rows with `status = approved`, newest first, capped at 100.
- `makeWishCard()` uses `textContent`, preventing stored HTML/script execution.
- A honeypot handles basic bots without changing the visible form.
- The calendar action uses explicit UTC timestamps plus `Asia/Kolkata`, so guests outside India receive the correct 6:00 PM IST event.

## Moderation page

`admin.html` uses Supabase email/password authentication and queries the signed-in user's own RLS-protected `wish_admins` row before showing the dashboard or loading wishes.

- Tabs query one state at a time: pending, approved, or rejected.
- The Auto-approve switch reads and updates the singleton `wish_settings` row. RLS permits this only for a user present in `wish_admins`.
- Updates send only the new `status`.
- Deletes require a browser confirmation.
- All guest values and error messages are inserted with `textContent`.

## Database

`setup.sql` defines:

- `wishes`: bounded, trimmed name/message; constrained status; server timestamps; reviewer metadata.
- `wish_admins`: an allow-list linked to `auth.users`.
- `wish_settings`: a singleton row containing the protected `auto_approve` flag and update audit metadata.
- partial/public and moderation indexes.
- an authenticated-user policy that exposes only the caller's own `wish_admins` membership row.
- `private.stamp_wish_review()`: a non-API trigger function with an empty search path that forces each insert to pending or approved from `wish_settings`, preserves wish content during moderation, and sets or clears review metadata.
- `private.stamp_wish_settings()`: records the authenticated admin and time whenever the approval mode changes.
- RLS policies for public approved reads, server-decided inserts, admin-only moderation, and admin-only settings access.
- table grants that expose only the operations needed by each browser role; guest inserts are column-limited to `name` and `message`, moderation updates to `status`, and settings updates to `auto_approve`.

## Failure behaviour

- With placeholder configuration, the invitation remains usable and explains that wishes are not ready.
- Network/query failures show a non-sensitive message and do not expose credentials or raw public error details.
- Admin errors can show database messages after authentication to aid operation.
- If the new settings table has not been installed, moderation remains visible and the switch explains that the latest `setup.sql` must be run.
