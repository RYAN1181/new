# Decision log

## 2026-08-23 — Supabase-backed moderated Wishes Wall

**Decision:** Keep GitHub Pages for hosting and use Supabase PostgreSQL, Auth, and Row Level Security for shared wishes and moderation.

**Why:** The invitation is already a static site. This adds persistent shared state and authenticated review without operating a custom server.

**Consequences:** The repository contains public project configuration but no private key. Production setup requires a Supabase project, one authorized Auth user, and execution of `setup.sql`.

## 2026-08-23 — Database policies are the authorization boundary

**Decision:** Anonymous visitors may insert only pending rows and read only approved rows. Only allow-listed authenticated users can see or moderate every row.

**Why:** Browser code and an unlisted admin URL are inspectable and cannot safely enforce permissions.

## 2026-08-23 — Render wishes with DOM text APIs

**Decision:** Use `textContent` for guest names and messages in both public and admin pages.

**Why:** The original `innerHTML` approach allowed submitted markup to execute. Safe text rendering prevents that stored-XSS path.

## 2026-08-23 — Correct the reception weekday and timezone

**Decision:** Display Wednesday, 16 September 2026 and compute the countdown from `2026-09-16T18:00:00+05:30`.

**Why:** 16 September 2026 is Wednesday. An explicit India offset keeps the countdown consistent for visitors in other time zones.

## 2026-08-23 — Put venue directions on the invitation cover

**Decision:** Move the Google Maps Directions action from the lower event card to the cover, beside the Open Invitation action.

**Why:** Venue navigation is a high-priority guest action and should be available immediately without requiring guests to open and scroll through the invitation.

## 2026-08-23 — Repeat essential reception details near the invitation message

**Decision:** Add a compact date, venue, and Directions panel immediately below the opening invitation copy while retaining the cover action and complete event card.

**Why:** Guests reading the main invitation should see the essential logistics before reaching the countdown and later content, without losing the detailed event section farther down the page.

## 2026-08-23 — Make auto-approval an admin-controlled database setting

**Decision:** Store an `auto_approve` flag in a singleton `wish_settings` row. A security-definer insert trigger reads the flag and forces each new wish to `approved` or `pending`. Only allow-listed authenticated admins can read or update the setting.

**Why:** A browser-side toggle or client-supplied status could be bypassed. Keeping the choice in the database preserves the RLS security boundary while allowing the couple to change behavior without editing or redeploying the website.

**Consequences:** The default remains off. Enabling the setting affects only future submissions; existing pending wishes remain pending until an admin moderates them.
