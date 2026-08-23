# Product intent

## Purpose

Celebrate the reception of Ranganathan Thetharappan and Megha Roy with a warm, mobile-friendly invitation that preserves the couple's current visual design, event details, photos, music, directions, calendar action, and contact links.

## Wishes Wall outcome

Guests can send blessings from the invitation. Every submission is private until an authorized member of the couple reviews it. Approved wishes persist online and are visible to every later visitor.

## Non-negotiable behaviour

- A guest submission starts as `pending` and is never public immediately.
- Public visitors can read only `approved` wishes.
- Only an authenticated account listed in `wish_admins` can view all wishes, change status, or delete.
- No admin password, database password, or service key is stored in browser files.
- Guest-controlled text is rendered as text, never HTML.
- The invitation remains deployable as a static GitHub Pages site.
- The event is Wednesday, 16 September 2026, from 6:00 PM India time.
- Guests can open venue directions directly from the invitation cover without scrolling.
- The opening invitation section repeats the reception date, venue, and Directions action for guests reading the main page.

## Definition of done

The public page can submit and display database-backed approved wishes, the private page can moderate them through authenticated RLS-protected operations, setup is reproducible from the repository, and the complete pending-to-approved workflow is verified before production launch.
