# AppSeed

A production-grade iOS seed project — the starting point for a new app, carrying
CoupleOS-proven architecture so the first week is already built. Clone, rename, fill in
your keys, and start shipping features instead of scaffolding.

The full engineering contract lives in [`CLAUDE.md`](CLAUDE.md). This file is the shop
window: what's in the box and how to boot it.

## Stack

- **UI:** UIKit + SnapKit (no storyboards beyond the launch screen), programmatic lazy-var views.
- **Architecture:** MVVM-R + Builder — every scene is `Builder` / `Router` / `ViewController` / `ViewModel`. Sheets are full scenes on `BottomSheet` / `FormBottomSheet` bases.
- **Backend (first-class):** Supabase — Apple Sign-In → Supabase auth, Postgres (RLS + SECURITY DEFINER RPCs), Realtime, Storage.
- **Backend (shelf, wire only if needed):** Firebase (RemoteConfig, Firestore) and the GPT / DALLE / Replicate / Fal.ai Alamofire services. Kept as optional infrastructure, never deleted.
- **Monetization:** RevenueCat (`IAPHelper` + Paywall scene, weekly→monthly→yearly funnel).
- **Images:** Kingfisher. **Animation:** Lottie.
- **Deployment target:** iOS 17.0.

## Targets

Five targets, one App Group, shared snapshot files:

```
AppSeed/                         # Main app
├── Application/                 # AppDelegate, SceneDelegate, LaunchScreen
├── Base/                        # MVVM-R core, sheet bases, Form library, base UI      → Base/README.md
├── Helpers/                     # Managers, App Group bridge, push, widget sync, IAP    → Helpers/README.md
├── Network/                     # Domain service layer + GPT/DALLE/… HTTP shelf         → Network/README.md
├── Scenes/                      # Splash, Tutorial, Login, TabBar, Profile, Paywall…    → Scenes/README.md
├── Extensions/                  # Foundation/UIKit conveniences (library surface)
├── Resources/                   # Assets, Colors.xcassets, Images/Colors enums, L10n    → Resources/README.md
└── Configuration/               # Develop/Release .xcconfig + Configuration.swift

AppSeedWidgets/                  # WidgetKit extension — reads App Group snapshots        → AppSeedWidgets/README.md
AppSeedNotificationService/      # NSE — version-gate → reload widget timelines → passthrough
AppSeedShareExtension/           # Share sheet — writes the shared URL/text to the App Group
AppSeedTests/                    # Pure-logic unit tests (no network, no UI)                → Scripts/test.sh
supabase/                        # Edge functions + SQL templates + push pipeline rules  → supabase/README.md
```

`AppGroupStorage.swift` and the `*WidgetMetadata` structs (`AppSeed/Helpers/AppGroup/`)
compile into both the app and the widget target — the app writes snapshots, widgets read them.
`PendingSharedItem.swift` does the same for the share extension.

## Quickstart

Each step does one thing. Steps 1–3 take minutes; step 6 is the only one that needs an
account somewhere else.

1. **Clone** — `main` is the branch to start from:
   ```bash
   git clone https://github.com/devno39/AppSeed.git
   ```

2. **Rename** to your project — folders, targets, entitlements, Info.plist, bundle ids,
   and the App Group id:
   ```bash
   cd Renamer && swift Renamer.swift AppSeed NewProjectName
   ```

3. **Install the Xcode file templates** (New File → scene / bottom-sheet / form-sheet
   generators). Do this *after* renaming: the installer copies into your home directory,
   so templates installed first would keep the old name forever.
   ```bash
   cd Templates && swift install.swift
   ```

4. **Fill the xcconfig keys** in `AppSeed/Configuration/Develop.xcconfig` and
   `Release.xcconfig`: `PRODUCT_BUNDLE_IDENTIFIER`, `PRODUCT_APP_NAME`, `SUPABASE_URL`,
   `SUPABASE_ANON_KEY`.

   Optional shelves: drop in `GoogleService-Info-develop/release.plist` and your RevenueCat
   key only if you wire them. Without the plist, Firebase and Crashlytics stay off by
   design — the launch log says so.

5. **Turn on the capabilities** — App Group and Sign in with Apple, on every target that
   has an entitlements file (app, widgets, NSE, share extension). The Renamer already
   rewrote the group id to `group.<prefix>.<yourapp>` in the four entitlements files and
   the three Swift literals that duplicate it; create that exact group in your developer
   account. **A mismatch here fails silently** — widgets and the share extension read an
   empty container instead of crashing.

6. **Stand up the backend** — run the SQL templates under `supabase/templates/sql/` in
   numeric order (users + `delete_my_account`, device tokens + push outbox, remote config +
   admin, storage RLS, storage purge, premium guard, items), then deploy the edge functions
   you need from `supabase/functions/`. Verify with `supabase/tests/000_rls_baseline_test.sql`.
   See [`supabase/README.md`](supabase/README.md) — the push pipeline's four hard rules and
   the silent-failure rules the templates encode are mandatory reading.

7. **Build and verify:**
   ```bash
   xcodebuild -project AppSeed.xcodeproj -scheme AppSeed-develop \
     -destination 'generic/platform=iOS Simulator' build
   Scripts/lint.sh     # the repo is kept at zero violations
   Scripts/test.sh     # 28 pure-logic tests, no network
   ```

8. **Make it yours.** `Scenes/Main/Items/` is a working feature wired to the `items` table —
   it is the shape to copy, not something to keep. Rename it to your domain (scene, service,
   model, `007_items.sql`, the tab and the deep-link host) or drop the tab. Everything
   uncalled elsewhere is seed inventory: keep what you might reach for, delete a capability
   only when the app will provably never want it.

## Docs map

Each area documents itself next to its code — open the one you're working in:

| Doc | Content |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | The engineering contract — architecture, MARK order, naming, invariants, **and the full docs map** |
| [`AppSeed/Base/README.md`](AppSeed/Base/README.md) | Base classes, sheet bases, Form field library, base UI |
| [`AppSeed/Helpers/README.md`](AppSeed/Helpers/README.md) | Helpers, managers, App Group bridge, push, widget sync |
| [`AppSeed/Network/README.md`](AppSeed/Network/README.md) | Domain service layer + the HTTP shelf |
| [`AppSeed/Scenes/README.md`](AppSeed/Scenes/README.md) | Scene flow map: launch routing, tabs, sheets, deep-link hosts |
| [`AppSeed/Resources/README.md`](AppSeed/Resources/README.md) | Asset/color/localization conventions |
| [`AppSeedWidgets/README.md`](AppSeedWidgets/README.md) | Widget kinds, snapshot reads, lock-screen rules |
| [`supabase/README.md`](supabase/README.md) | Edge functions, push rules, storage rules, SQL templates |

Process docs live under `docs/` — templates to copy, patterns worth re-reading, and the
folders your app fills as it grows. `docs/harvest/` records where the seed came from and,
more usefully, what is still unverified. CLAUDE.md lists all of it.

## License

MIT.
