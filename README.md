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
- **Backend (shelf, wire only if needed):** Firebase (RemoteConfig / Auth / Firestore) and the GPT / DALLE / Replicate / Fal.ai Alamofire services. Kept as optional infrastructure, never deleted.
- **Monetization:** RevenueCat (`IAPHelper` + Paywall scene, weekly→monthly→yearly funnel).
- **Images:** Kingfisher. **Animation:** Lottie.
- **Deployment target:** iOS 17.0.

## Targets

Three targets, one App Group, shared snapshot files:

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
supabase/                        # Edge functions + SQL templates + push pipeline rules  → supabase/README.md
```

`AppGroupStorage.swift` and the `*WidgetMetadata` structs (`AppSeed/Helpers/AppGroup/`)
compile into both the app and the widget target — the app writes snapshots, widgets read them.

## Quickstart

1. **Clone** the `develop` branch:
   ```bash
   git clone -b develop https://github.com/devno39/AppSeed.git
   ```

2. **Install the Xcode file templates** (New File → adds AppSeed Scene / Bottom Sheet / Form Sheet generators):
   ```bash
   cd Templates && swift install.swift
   ```

3. **Rename** to your project (renames folders, targets, entitlements, Info.plist, bundle IDs):
   ```bash
   cd Renamer && swift Renamer.swift AppSeed NewProjectName
   ```

4. **Fill the xcconfig keys** in `AppSeed/Configuration/Develop.xcconfig` and `Release.xcconfig`:
   - `PRODUCT_BUNDLE_IDENTIFIER`, `PRODUCT_APP_NAME`
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY`
   - Set your App Group + Sign in with Apple capability, and drop in your `GoogleService-Info` / RevenueCat key if you wire those shelves.

5. **Stand up the backend** — run the SQL templates under `supabase/templates/sql/` (users, RLS RPCs, device tokens + push outbox, `delete_my_account`) in your Supabase project's SQL editor, then deploy `supabase/functions/send-push/`. See [`supabase/README.md`](supabase/README.md) — the 4 push pipeline hard rules are mandatory reading before touching push.

6. **Build:**
   ```bash
   xcodebuild -project AppSeed.xcodeproj -scheme AppSeed-develop \
     -destination 'generic/platform=iOS Simulator' build
   ```

## Docs map

| Doc | Content |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | The engineering contract — architecture, MARK order, naming, invariants |
| [`AppSeed/Base/README.md`](AppSeed/Base/README.md) | Base classes, sheet bases, Form field library, base UI |
| [`AppSeed/Helpers/README.md`](AppSeed/Helpers/README.md) | Helpers, managers, App Group bridge, push, widget sync |
| [`AppSeed/Network/README.md`](AppSeed/Network/README.md) | Domain service layer + the HTTP shelf |
| [`AppSeed/Scenes/README.md`](AppSeed/Scenes/README.md) | Scene flow map: launch routing, tabs, sheets, deep-link hosts |
| [`AppSeed/Resources/README.md`](AppSeed/Resources/README.md) | Asset/color/localization conventions |
| [`AppSeedWidgets/README.md`](AppSeedWidgets/README.md) | Widget kinds, snapshot reads, lock-screen rules |
| [`supabase/README.md`](supabase/README.md) | Edge functions, push pipeline rules, SQL templates |
| `docs/templates/` | Process-doc skeletons (brainstorm / plan / release / review) |
| `docs/patterns/` | Reusable recipe write-ups |
| `docs/plans/` | Requirements and implementation plans (dated) |

## License

MIT.
