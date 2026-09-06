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

## Later syncs

The harvest closed on 2026-07-31, but CoupleOS keeps shipping, so the seed gets a sweep
now and then. Each one is listed here with what came over and why.

**2026-08-14** — a line-by-line diff of both trees plus every CoupleOS commit since the
close. What came over:

| Taken | Why |
|---|---|
| `UIView.setBorderColor(_:)` + 27 call sites | The seed had 33 frozen `layer.borderColor` assignments across its own Base library — every one of them wrong after a light/dark switch. |
| `PaperBackgroundView` trait observation | The seed's copy never redrew its pattern/grain/vignette on a mode change. |
| Storage content versioning (`?v=` stamp) | Re-uploading to the same path served the cached bytes forever. |
| IAP premium state machine | The seed had no `Purchases.logIn`, no `isPro` mirror, and no guard against the false downgrade RevenueCat's empty cache causes. |
| `CameraCapture/` scene | The seed had no camera capture at all; the scene is domain-free. |
| `ProBadgeView` + `ProStampView` | The locked widget placeholder had no counterpart inside the app. |
| `appseed://paywall` + notification-response capture | The locked widget deep-linked nowhere, and a cold-launch banner tap could route nowhere. |
| `Scripts/supabase_query.sh` | Read-only SQL against the linked project, with a statement guard. |

**2026-09-06** — a second full sweep: the 107 files both trees share, diffed one by one,
plus the CoupleOS envelope since 1.1.3. What came over:

| Taken | Why |
|---|---|
| The launch-prompt queue (`LaunchPromptManager` + `PermissionPromptManager` / `PaywallPromptManager` / `WhatsNewManager` / `WhatsNewView`) | The seed had a lone `ReviewPromptManager` and no rule for what happens when two prompts want the screen at once. The ordering, the session-gap schedules and the `isSettled`-not-`shown` invariant are the expensive part. |
| `String.postgresDate` | Postgres sends microsecond fractions, `ISO8601DateFormatter` reads three digits. The seed is Supabase-first and had no decoder for its own timestamps. |
| `UIImage.carriesAlpha` + `StoragePath.imageFormat(for:)` | The seed forced every profile image through PNG: a cut-out avatar needs it, a camera photo pays ~950kB against ~50kB for it. |
| Storage upload retry + `deleteFiles(relativePaths:)` + `relativePath(fromSignedURL:)` | A dropped connection mid-body read as a rejection. The SDK wraps the URL error, so detection has to walk the `NSUnderlyingErrorKey` chain. |
| `trimmingTransparentPixels` / `opaquePixelBounds` / `stickerOutlined` / `jpegData(fitting:)` / `String.isEmojiOnly` / `EmojiRenderer` | Font metrics describe the line box, not the glyph, and colour emoji carry no path to measure. Every one of these was re-derived the hard way. |
| `BottomSheet` `onDismiss` / `dismissesOnBackdropTap` / `isPro`, and the missing `actionButton.applyStyle()` | `onDismiss` was declared on the view model and fired by the view controller, but the generic `presentBottomSheet(…)` path had no way to pass one — so across the whole seed nothing ever set it. The sheet's action button was assigned a `style` after init and `applyStyle()` only runs in `prepare()`, so the font, title colour and background never landed. |
| `ZoomTransition` `targetCornerRadius` + `masksToBounds` + `dismissSnapshot` | The corner radius was assigned but never clipped, so it did nothing. |
| `ToastView` multi-line title | Clamped to one line; a long toast was silently truncated. |

Considered and left behind: the campaign timezone work (`075`) — the idea is right, but
the seed has no campaign SQL at all (`065`/`066` were rejected in the sweep below) and it
is welded to CoupleOS's `upsert_device_token` design, which the seed deliberately did not
adopt; the orphan-sweep extensions (`074`/`079`) — the seed's `005_storage_purge` is
already the generic form and these only add CoupleOS's own prefixes to it.

**Where the seed is now ahead of CoupleOS**, and porting back would be a regression:
`PermissionManager` (holds its `CLLocationManager` instead of creating one per query, and
is free of the location-domain welding), `ReviewPromptManager` (`milestone`, not `pair`),
`SupabaseAppConfigHelper` (`select("key,value")`, which survives the table growing a
non-text column), `AvatarView` (`placeholder`, not `egg`), `WidgetSyncService`,
`DateHelper`, `KeychainHelper`, `PushNotificationManager`, `HudView`. The de-domaining
done during the harvest is the reason — do not sync these back.

Considered and left behind: the background-location stack (`067`, cheap/expensive write
split) — unproven in the field, CoupleOS's own significant-location monitoring went silent
on a 500km drive; the push campaign SQL (`065`/`066`) — welded to CoupleOS's solo/pair
model; the `push_outbox_enabled` kill switch and HMAC collapse-id — the switch lives in a
pg_cron drain function the seed's template does not have, and the collapse-id belongs to
the HMAC design the seed deliberately dropped. Porting half of either repeats the mistake
this page already warns about.

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

Both later syncs build (Develop, generic iOS Simulator), sit at zero SwiftLint violations,
and pass the 28-test suite — the 2026-09-06 build pass covered the 2026-08-14 work too,
since the two were still sitting in the same working tree and landed in one commit. They
had to: separating them was tried and abandoned, because the 2026-08-14 state does not
compile on its own once the 2026-09-06 hunks are pulled out of `IAPHelper` (its
`refreshFromForeground`, which `SceneDelegate` calls, belongs to the earlier sync while the
premium gates around it belong to the later one).

What neither has had is a **run**. The 2026-08-14 camera scene still needs a look on a
device (the simulator falls back to the photo library). The 2026-09-06 launch-prompt queue
is ordering logic behind the login screen, so its ordering — and the permission sheet's
three rounds — are argued for, not observed.

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
APNs environment variables, `REVENUECAT_AUTH_HEADER`, `IAPHelper.apiKey`,
`SUPABASE_PROJECT_REF` (`Scripts/supabase_query.sh`), and
`TELEGRAM_BOT_TOKEN` / `TELEGRAM_CHANNEL_ID`.

`IAPHelper.apiKey` used to hold a real-looking RevenueCat key carried in from another
project. It is a placeholder now: a live key belonging to someone else's app silently
attributes purchases to the wrong project.
