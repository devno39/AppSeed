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
│   └── Storage/                     # SupabaseStorageHelper (avatars bucket)
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
├── ReviewPromptManager.swift   # App Store review-prompt eligibility
├── DeepLinkRouter.swift        # scheme guard + host allowlist + cold-launch drain
├── PushNotificationManager  (under Push/)
├── NotificationHelper.swift    # notification authorization
├── LocalReminderHelper.swift   # prefix-scoped local reminder scheduling
├── FeedbackHelper.swift        # support-channel handoff (generic)
├── AlertHelper.swift, LoadingHelper.swift, KeychainHelper.swift
├── UserDefaultsWrapper.swift   # type-safe UserDefaults (tutorials_seen, has_completed_setup, …)
├── EmojiHelper.swift           # emoji catalog + keyword search (warmup on splash)
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

`IAPHelper.shared` — configure at launch, then `getOfferings()`, `purchase(package:)`,
`restorePurchases()`, `isPremium()` → `UserPlan`. `StoreKitConfig.storekit` is the local
simulator config.

## Theming & language

- `PaletteManager` (accent, `.paletteDidChange`), `ThemeManager` (light/dark, `.themeDidChange`).
- Views outside the BaseViewController hierarchy (e.g. `ToastView` on the key window) self-observe both via `PaletteUpdatable`.
- `LanguageManager` / `LanguageHelper` — in-app language switch (`.languageDidChange`).

## Notes

Adding a helper or manager → update this README in the same commit.
