# Helpers

Cross-cutting utilities and integrations: Supabase backend, the App Group bridge to
widgets, push, IAP, theming, localization, and general helpers. Full standards live in
the root `CLAUDE.md`.

## Layout

```
Helpers/
├── Supabase/                # Primary backend
│   ├── SupabaseManager.swift        # configured SupabaseClient
│   ├── Auth/                        # Apple Sign-In → Supabase token exchange
│   │   ├── SupabaseAppleSignInService.swift
│   │   ├── SupabaseAppleAuthorizationDelegate.swift
│   │   ├── SupabaseAppleSignInError.swift
│   │   └── NonceGenerator.swift
│   ├── Database/                    # SupabaseDatabaseHelper, SupabaseAppConfigHelper (min-version gate), SupabaseDatabaseErrorMapper
│   └── Storage/                     # SupabaseStorageHelper (avatars bucket, per-image PNG/JPEG, upload retry)
├── Firebase/                # Shelf — kept, wire only if needed
│   ├── Firestore/                   # FirestoreHelper
│   └── RemoteConfig/                # RemoteConfigHelper, RemoteConfigCacher, RemoteConfigKeys
├── AppGroup/                # Widget ↔ app shared state
│   ├── AppGroupStorage.swift        # atomic vintage-UUID writes, freshness/session guards, wipe
│   ├── DemoWidgetMetadata.swift     # example snapshot struct
│   └── PendingSharedItem.swift      # share-extension → app handoff (compiled into both targets)
├── WidgetSync/             # App → widget snapshot pipeline
│   ├── WidgetSyncService.swift, WidgetSyncHandler.swift, WidgetSyncKind.swift, WidgetSyncContext.swift
│   └── Handlers/DemoWidgetSyncHandler.swift
├── Push/                   # PushNotificationManager (APNs token registration)
├── IAP/                    # IAPHelper (RevenueCat), UserPlan, StoreKitConfig.storekit
├── Language/              # LanguageHelper + LanguageManager
├── Toast/                # ToastHelper + ToastView (global, palette-aware)
├── UserSessionManager.swift    # Supabase user listener, sign-out, Apple credential state
├── PaletteManager.swift        # accent selection + .paletteDidChange
├── ThemeManager.swift          # light/dark + .themeDidChange
├── PermissionManager.swift     # notification / location / photos permission flows
├── LaunchPromptManager.swift   # the launch-prompt queue — one owner for everything that wants the screen
├── PermissionPromptManager.swift  # when the permission sheet is due
├── PaywallPromptManager.swift     # when the scheduled paywall is due
├── WhatsNewManager.swift          # per-version release notes gate
├── ReviewPromptManager.swift   # App Store review-prompt eligibility
├── DeepLinkRouter.swift        # scheme guard + host allowlist + cold-launch drain
├── PushNotificationManager  (under Push/)
├── NotificationHelper.swift    # notification authorization
├── LocalReminderHelper.swift   # prefix-scoped local reminder scheduling
├── FeedbackHelper.swift        # support-channel handoff (generic)
├── AlertHelper.swift, LoadingHelper.swift, KeychainHelper.swift
├── UserDefaultsWrapper.swift   # type-safe UserDefaults (tutorials_seen, has_completed_setup, …)
├── EmojiHelper.swift           # emoji catalog + keyword search (warmup on splash)
├── EmojiRenderer.swift         # emoji → outlined UIImage (cached); font metrics cannot size one
├── QRHelper.swift, DateHelper.swift, FormatHelper.swift, HapticHelper.swift
├── JsonCleaner.swift, TrackingHelper.swift
└── Logger.swift                # log(_:_:_:) categorized logs
```

## UserSessionManager

Singleton owning the current user's Supabase row listener. `startListening()` (Splash +
post-auth) / `stopListening()` (logout + delete). Publishes `.userDidChange`. All view
models read the current user from `UserSessionManager.shared` rather than fetching directly.
Callbacks are guarded by a session generation counter — a stale listener callback after
sign-out is dropped (see `docs/patterns/listener-generation-guard.md`).

### Sign-out and revoked credentials

`signOut()` is the one sign-out sequence — device tokens go first (the RLS delete-own
policy needs `auth.uid()`, which `signOut` clears), the server call must succeed before
anything local is wiped, then the listener stops and review tracking resets. Scenes call
it and handle their own UI.

Apple can revoke a Sign in with Apple credential from iOS Settings while the app is
closed; the Supabase session stays valid on its own, so nothing else notices. Two paths
cover it: `ASAuthorizationAppleIDProvider.credentialRevokedNotification` while running,
and `verifyAppleCredential()` on every activation (`SceneDelegate`) for the closed case —
which needs Apple's own user identifier, stored in the Keychain at sign-in
(`KeychainKeys.appleUserId`). Either path signs out and posts `.sessionRevoked`;
`SceneDelegate` routes back to Login.

## Supabase

`SupabaseManager` exposes the configured `SupabaseClient` (auth + database + storage +
realtime), built from the `SUPABASE_URL` / `SUPABASE_ANON_KEY` xcconfig keys. Auth is
Apple Sign-In → Supabase token exchange (`Auth/`). Feature services live under
`Network/Services/Supabase/` and consume protocols.

`SupabaseStorageHelper` uploads, deletes, and re-signs images. Two traps are handled
inside it, and `UIImageView.setImage(with:)` depends on both:

- **Stored URLs expire.** Rows keep a 365-day signed URL with no refresh path, so reads
  re-sign the embedded storage path with a fresh 24-hour token (memoised per path).
- **Re-uploading to the same path keeps the same URL.** A path-shaped cache key would
  then serve the old bytes forever. Uploads return a URL stamped with `?v=<ms>`; the
  stamp goes into both the request URL and the Kingfisher cache key — a key-only stamp
  still gets the stale body off the network, since the memoised signed URL repeats. The
  upload also seeds the cache with the bytes it just sent. Rows written before the stamp
  existed stay on the bare path until their next save.
- **The format is chosen per image, not per path.** `StoragePath.imageFormat(for:)` asks
  the *original* image whether it `carriesAlpha`: a cut-out avatar flattens to white as
  JPEG, while a camera photo forced through PNG at 512px costs ~950kB against ~50kB. Asked
  of the original because the resize renderer adds an alpha channel whenever told to — and
  because the caller cannot know which extension was written, `deleteImage` removes every
  `ImageFormat` case's path.
- **A dropped connection is not a rejection.** `-1005` and friends arrive wrapped by the
  SDK, so `isTransient` walks the `NSUnderlyingErrorKey` chain rather than casting; both
  upload entry points funnel through one retrying `performUpload`. Without it a large
  upload fails on a perfectly working network.

`deleteFiles(relativePaths:)` is the other delete shape — files that carry their own name
rather than one file per owner. `relativePath(fromSignedURL:)` recovers the bucket-relative
path from a stored URL to feed it.

## Firebase (shelf)

Kept as optional infrastructure, never deleted. `RemoteConfig` (feature flags / version
gates) and `Firestore` (helper only) compile in; wire them only if an app needs them.

## AppGroup + WidgetSync (widget bridge)

Widgets can't subscribe to realtime — they read snapshots the app writes.

- `AppGroupStorage` — the shared-container `UserDefaults(suiteName:)` wrapper: atomic
  vintage-UUID writes, freshness + session validation, and a wipe on session change.
- One `*WidgetMetadata` Codable struct per widget kind (the demo ships `DemoWidgetMetadata`).
- `WidgetSyncService` runs per-kind `WidgetSyncHandler`s with a `WidgetSyncContext`; each
  handler builds its widget's snapshot and reloads its timeline. New widget = new
  `WidgetSyncKind` + handler. See `AppSeedWidgets/README.md`.

## Push

`PushNotificationManager` — APNs token registration + device-token upsert. Silent-push
handling must guard cold launches (see the push rules in `supabase/README.md`).
`NotificationHelper` only asks for authorization.

`LocalReminderHelper` schedules the app's own reminders. `sync(prefix:reminders:)`
drops every pending notification whose identifier starts with `prefix` and rebuilds
the set from the given `[LocalReminder]` — so a change anywhere in the model list
needs no per-item bookkeeping between launches. `ReminderRepeatRule` covers
none/daily/weekly/monthly/yearly, and `minutesIntoDay` sets the fire time.

## Share extension handoff

`PendingSharedItem` compiles into both the app and `AppSeedShareExtension`. The
extension writes the shared URL/text into the App Group and exits; `SceneDelegate`
posts `.sharedItemReceived` on the next activation and the observing scene calls
`PendingSharedItem.consume()`. The App Group suite name is repeated in the struct
because the extension target cannot see app-target code — keep it in sync with
`AppGroupStorage.groupIdentifier`.

## IAP (RevenueCat)

`IAPHelper.shared` — `configure()` at launch, then `getOfferings()`, `purchase(package:)`,
`restorePurchases()`, `isPremium` → `UserPlan`. `StoreKitConfig.storekit` is the local
simulator config. `apiKey` is a placeholder; fill it before shipping.

The premium state is a small state machine, and each part of it exists because of a
failure mode:

- **`logIn(userId:)` / `logOut()`** — `UserSessionManager` calls these on sign-in and
  sign-out. Without them RevenueCat stays on its per-device anonymous id and a purchase
  does not follow the account to a second device.
- **Cached bootstrap in `configure()`** — widgets render before RevenueCat's first
  network answer; an unset flag reads as free.
- **The `AppGroupStorage.isPro` mirror**, rewritten on every plan change, is how the
  widget extension gates itself without linking the SDK. It is skipped while
  RevenueCat's cache is still empty — otherwise every cold launch briefly downgrades a
  paying user and strips their palette. On upgrade it re-runs the widget sync, because
  gated handlers wrote nothing while the user was free and a bare reload would render
  empty widgets.
- **`refreshFromForeground()`** (SceneDelegate) invalidates the cache, so a subscription
  bought or lapsed elsewhere shows up on return.
- **`entitlementsKnown` / `premiumIncludingLastKnown`** — `isPremium` reads false until
  RevenueCat's first response lands. A gate that treats that window as "free" shows the
  paywall to a paying user on every cold launch, so `PaywallPromptManager` asks these two
  instead: has RevenueCat answered at all, and what was the last state we knew.
- Sign-out clears `AppGroupStorage.isPro` in the session wipe — RevenueCat clears its own
  cache asynchronously, and until it does the widgets would keep rendering unlocked.

A plan change posts `.premiumStatusDidChange` and reloads all timelines.
`.openPaywallRequested` is the other half: the `appseed://paywall` deep link posts it and
Home presents the paywall.

## Launch prompts

Everything that wants the screen at launch goes through `LaunchPromptManager.shared` —
permissions, What's New, the onboarding paywall, the review ask, the scheduled paywall, in
that order. Without one owner these race: two sheets present in the same runloop and one
closes the other, or a prompt that never lands blocks the ones behind it forever.

The rules split in two on purpose:

- **The manager owns the order and the retries.** It re-runs on `didBecomeActive`,
  `.setupFlowDidComplete` and `.premiumStatusDidChange`, so calling
  `presentNextIfPossible()` more than once is free.
- **Each prompt owns "am I due?"** — `PermissionPromptManager`, `WhatsNewManager`,
  `PaywallPromptManager`, `ReviewPromptManager`. The two scheduled ones count in
  *sessions* (`review_session_count`, bumped once per launch), not days: `[0, 3, 6]` for
  permissions, `[3, 5, 8]` for the paywall.

Scenes register how to present, they do not decide when — `HomeViewController.registerLaunchPrompts()`
is the seed's example. A scene that lands somewhere other than the first tab registers there
instead. Three rules the registrations encode:

- **Count on presentation, not before it** — a dropped `present` would otherwise spend a
  turn the user never saw. Hence `presentPermissionSheet(onDismiss:onPresented:)`.
- **Report the dismissal** — the presenter's `onDismiss` argument is what lets the next
  prompt take its turn. The paywall is the exception: it is a full screen of its own and
  reports nothing, so the next foreground picks the queue back up.
- **`isSettled`, not "has it been shown"** — `PermissionPromptManager.isSettled` is defined
  as `!shouldShow()`, so a presentation that never lands cannot leave What's New and the
  paywall queued behind it.

**Trim `PermissionType` to what your app actually asks for.** `allGranted` requires every
case, so leaving `.location` in an app that never wants location means the sheet is never
satisfied — it shows its full three rounds before settling.

`WhatsNewManager.items` is rewritten every release alongside the version bump; the strings
live in `Localizable` (`whats_new_*`). A first install stamps the current version through
`markCurrentVersionSeenIfNeeded()` — called from the setup flow and from the TabBar's
already-set-up path — so the sheet waits for a real update instead of greeting a user who
has seen nothing yet.

## Theming & language

- `PaletteManager` (accent, `.paletteDidChange`), `ThemeManager` (light/dark, `.themeDidChange`).
- Views outside the BaseViewController hierarchy (e.g. `ToastView` on the key window) self-observe both via `PaletteUpdatable`.
- `LanguageManager` / `LanguageHelper` — in-app language switch (`.languageDidChange`).

## Notes

Adding a helper or manager → update this README in the same commit.
