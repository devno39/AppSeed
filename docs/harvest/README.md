# Where the seed came from

AppSeed was harvested out of CoupleOS, a shipped iOS app, in two rounds
(2026-07-25 and 2026-07-28/29). This page is everything from that work still worth
knowing.

The session-by-session plans and reviews are not kept in the tree — they were notes
about *building* the seed, not about using it, and everything durable in them is on
this page. They remain in git if you ever want them:

```bash
git show 2e750bb --stat -- docs/harvest/    # what was there
git show 2e750bb:docs/harvest/2026-07-29-harvest-v2-review.md
```

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

## Considered and not taken

These came up during the harvest and were decided against. The reasoning is the
useful part — if one of them turns out to be needed, you are picking up an argument
rather than starting one.

| Candidate | Decision |
|---|---|
| `LocationHelper` | Out. CoupleOS's version is welded to significant-location monitoring and partner sharing; write a generic one when an app needs location. |
| Reachability / offline handling | Out. The Supabase SDK reconnects its own socket; anything beyond that is app-specific. |
| Analytics event layer | Out. Firebase Analytics is linked but there is no typed event wrapper — event names are app-specific, so a template would have been speculative. |
| Debug / QA menu | Out. Useful, but not part of a seed's core. |
| `PaperView` / `DrawingToolbar` | Out. A drawing engine is a product decision on its own. |
| `CalendarMonthCell` | Out. The month grid was welded to domain rules. |
| Generic `OptimisticSync` | Out — see above. |

One decision worth knowing when you compare against CoupleOS: **the push manager's
hardening was deliberately not carried over** (device-install-id signature short-circuit,
30s failure backoff). Those are tied to CoupleOS's `upsert_device_token` RPC, while the
seed chose the simpler token-as-primary-key design. Porting half of it would have been
worse than porting none.

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
