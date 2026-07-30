# Where the seed came from

AppSeed was harvested out of CoupleOS, a shipped iOS app, in two rounds
(2026-07-25 and 2026-07-28/29). The dated plans and reviews next to this file are
the full record; this page is the part worth knowing without reading them.

Everything here is provenance. It explains why pieces look the way they do and
where the known holes are — it is not a to-do list for your app.

## The rule that decided what came over

Judge a piece by whether it carries knowledge that is painful to re-derive —
platform traps, layout maths, ordering rules — not by whether it looks like the
app it came from. A component with an opinionated visual style over a generic
capability is worth taking; the styling is a handful of constants you will change
anyway.

That rule was arrived at the hard way: the first cut list was drawn on "this looks
like CoupleOS" and did not survive scrutiny.

## Deliberately left behind

Domain scenes and their widgets, the pair/premium domain, Weather, `LocationHelper`
(CoupleOS's version is welded to significant-location monitoring and partner
sharing — write a generic one when an app needs location), `PlaceLabelHelper`,
`UpcomingDatesHelper`, and the 60-file SQL migration history. Firebase's
Apple-Sign-In / Database / Storage helpers stayed behind too: Supabase is the
first-class path and those are superseded.

Also considered and rejected: a generic `OptimisticSync` component. CoupleOS's
three-way merge solves a *document-shaped* row — one row holding a collection that
two people co-edit. Forcing it onto ordinary independent rows would have taught the
wrong default. The row-shaped case is demonstrated in `Scenes/Main/Items/`; the
document-shaped one stays written up in `../patterns/optimistic-realtime-sync.md`.

## What is verified, and what is not

Verified: five targets build in Develop and Release, SwiftLint is at zero
violations, the test suite passes, the Renamer round-trips the whole project
including App Group ids, and the app launches to the login screen.

**Not verified:** the SQL templates and edge functions under `../../supabase/` have
never been executed. They were adapted from migrations running in CoupleOS
production, but they were rewritten — renamed tables, merged files, and
`007_items.sql` written from scratch. Run them once on a throwaway Supabase project
and follow with `supabase/tests/000_rls_baseline_test.sql` before trusting them.

Everything behind the login screen is compile-verified only; the simulator cannot
complete Sign in with Apple.

## Known placeholders

`SUPABASE_URL` / `SUPABASE_ANON_KEY` (xcconfig), Terms and Privacy URLs
(`Configuration`), the App Group id, `FeedbackHelper`'s endpoint and token, the
APNs environment variables, `REVENUECAT_AUTH_HEADER`, and
`TELEGRAM_BOT_TOKEN` / `TELEGRAM_CHANNEL_ID`.
