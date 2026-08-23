# Low-level architecture

## Public invitation

`index.html` creates a Supabase client only when `supabase-config.js` contains a valid project URL and publishable/anon key.

- `submitWish()` trims and validates the form, sends only `name` and `message`, and relies on the database default plus RLS for `pending` status.
- `loadApprovedWishes()` asks for rows with `status = approved`, newest first, capped at 100.
- `makeWishCard()` uses `textContent`, preventing stored HTML/script execution.
- A honeypot handles basic bots without changing the visible form.
- The calendar action uses explicit UTC timestamps plus `Asia/Kolkata`, so guests outside India receive the correct 6:00 PM IST event.

## Moderation page

`admin.html` uses Supabase email/password authentication and queries the signed-in user's own RLS-protected `wish_admins` row before showing the dashboard or loading wishes.

- Tabs query one state at a time: pending, approved, or rejected.
- Updates send only the new `status`.
- Deletes require a browser confirmation.
- All guest values and error messages are inserted with `textContent`.

## Database

`setup.sql` defines:

- `wishes`: bounded, trimmed name/message; constrained status; server timestamps; reviewer metadata.
- `wish_admins`: an allow-list linked to `auth.users`.
- partial/public and moderation indexes.
- an authenticated-user policy that exposes only the caller's own `wish_admins` membership row.
- `private.stamp_wish_review()`: a non-API trigger function with an empty search path that preserves wish content during moderation and sets or clears review metadata.
- RLS policies for public approved reads, pending inserts, and admin-only moderation.
- table grants that expose only the operations needed by each browser role; authenticated updates are column-limited to `status`.

## Failure behaviour

- With placeholder configuration, the invitation remains usable and explains that wishes are not ready.
- Network/query failures show a non-sensitive message and do not expose credentials or raw public error details.
- Admin errors can show database messages after authentication to aid operation.
