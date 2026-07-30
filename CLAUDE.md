# CLAUDE.md — AppSeed

UIKit seed project (UIKit + SnapKit, MVVM-R, Supabase) — the starting point for new apps, carrying CoupleOS-proven patterns so the next app has its first week already built. This file is the contract for how code is written here. **Do not deviate from these standards.** When in doubt, read the golden file.

**Golden files — two, one per shape:**
- `AppSeed/Scenes/Main/Items/` — a **feature**: Supabase-backed collection, realtime listener, optimistic writes, empty state, swipe delete, nested `AddItem` form sheet. Copy this for anything the user creates, edits or deletes.
- `AppSeed/Scenes/Main/Profile/` — a **settings screen**: section-driven table, nested EditProfile form sheet, language/theme switches, sign-out and delete-account.

## Architecture — MVVM-R + Builder

Every scene = 4 files: `{Scene}Builder`, `{Scene}Router`, `{Scene}ViewController`, `{Scene}ViewModel` (+ optional `Cells/`, `Views/`, `Localizable/`, nested `Scenes/`). Sheets use the `{X}Sheet` name suffix and are full scenes too — never inline.

- **Builder** — the only place concrete services are instantiated. Build order: router → viewModel (+ closure/property assignments) → viewController → return.
- **ViewModel** — protocol triple above the class: `{X}ViewModelDataSource` / `ClosureSource` / `FunctionSource` (Function optional), combined in `{X}ViewModelProtocol`. Holds `private let` service **protocols**, never concrete types.
- **Router** — a Route protocol + `extension {X}Route where Self: BaseRouter` holding the presentation logic; the Router class only adopts Route protocols (`final class ProfileRouter: BaseRouter, EditProfileRoute, PaywallRoute, ... { }`). No direct funcs in Router classes. VC only calls `router?.pushX()` — VCs never contain presentation logic.
- Route func prefix by presentation: `pushX()` = nav push, `presentX()` = modal, `showX()` = window root swap.
- Sheet bases: `BottomSheetViewController` (action sheets) / `FormBottomSheetViewController` (forms). Sheet routers derive from the matching sheet router base.

## MARK order

ViewController (in-class, top to bottom), then file-level extensions:

```
// MARK: - UI              ← always first (lazy vars)
// MARK: - Constants       ← optional, before Properties
// MARK: - Properties
// MARK: - Life Cycle      ← two words
// MARK: - Prepare
// MARK: - Bind
// MARK: - <domain blocks>  (Navigation / Actions / Session Observers / ... — free order)
// MARK: - Localization
--- extensions ---
// MARK: - UITableViewDataSource
// MARK: - UITableViewDelegate
// MARK: - Draw            ← always the last extension
```

ViewModel file: `// MARK: - Source` → `Closure` → `Function` → `Protocol` → `ViewModel`; inside the class: `Source` → `Services` → `Closure` → `Properties` → `Init` → `DataSource` → `Fetch` → domain blocks. Private helpers always live under `// MARK: - Private` (never `Factories`/`Helpers`; subgroup as `// MARK: - Private — Pins` if needed).

## UI components — lazy var rule

Static UI elements are **inline multi-line lazy closures** under `// MARK: - UI`:

```swift
private lazy var tableView: BaseTableView = {
    let view = BaseTableView(frame: .zero, style: .grouped)
    view.backgroundColor = .clear
    view.separatorStyle = .none
    return view
}()
```

- **`make*` view factories are FORBIDDEN.** Even for twin elements, repeat the closure body — this is a deliberate style decision; reviewers flagging it as duplication get WONT-FIX.
- The only legitimate builder func: views produced in a loop from a model at runtime (can't be lazy vars) — those go under `// MARK: - Private`.
- Layout with SnapKit (no manual frames), images via Kingfisher `setImage(with:)`, reuse via `ReusableView` + `static identifier`, palette via `PaletteUpdatable.updatePaletteColors()`.

## Callbacks

- ViewModel → VC: closures named `xxxDidChange` (state) or `onXxx` / `xxxClosure` (action), typed with `EmptyClosure` / `AnyClosure<T>` (see `Base/Constants/Typealias.swift`), declared `var` in `ClosureSource`.
- Bound in `bindViewModel()`, always starting with `super.bindViewModel()`, always `[weak self]`.
- Cell → VC → VM chains use the same `onXxx` convention.

## Services

- Supabase is the first-class backend path: ViewModels consume `XServiceProtocol` only; Builders inject `SupabaseXService()`. Firebase helpers and the GPT/DALLE/Replicate/Falai Alamofire services are optional shelf modules — wire only what the app needs, and never delete the shelf.
- Async SDK bridging (`Task` + do/catch) stays **inside** the service; closures come out. VM/VC never see async.
- RPCs live in their owning service — no generic rpc helper.
- Realtime listeners return `ListenerHandle`; owner stores and cancels on teardown. Service calls must not be tied to UI lifecycle (a dismissed sheet's save still completes).
- `LoadingHelper`: show/hide in the same method (show before request, hide in callback), driven from the ViewModel; orphan `hideLoading` crashes in DEBUG.

## Naming

`XxxViewController` / `XxxViewModel` / `XxxRouter` / `XxxBuilder` / `XxxRoute` / `XxxCell` / `XxxHelper` (static) / `XxxManager` (singleton `.shared` + NotificationCenter) / `XxxServiceProtocol` → `SupabaseXxxService`.

## Clean code

- Comments: minimal — a single line only for traps not visible in the code itself. No "what the next line does" comments, no history notes. Names carry the meaning.
- No dead code in APP code: scenes, routes, view models, and helpers you wrote for this app and no longer call are removed, not kept "just in case".
- **Seed inventory is not dead code.** This is a base: uncalled members are stock, not rot. That covers `Extensions/`, `Helpers/`, `Base/UI` (including `UI/Map/`, `PagedCarouselView`, `StatusBubbleView`), the ready-to-use scenes (`QRScanner/`, `PhotoViewer/`), the `AppSeedShareExtension` target, and the optional infrastructure shelves (Firebase helpers, the GPT/DALLE/Replicate/Falai modules). Judge a piece by whether it carries knowledge that is painful to re-derive — platform traps, layout maths, ordering rules — not by whether it looks like the app it came from. Delete only when the app will provably never want the capability, or when the member is actively harmful (e.g. shadowing a system API).
- No over-engineering: no speculative abstractions, no generic frameworks for one call site. Solve today's problem.
- Reusable behavior lives in its natural home, never inline in scenes: system-type behavior as extensions (`Extensions/`), domain utilities as helpers (`Helpers/`), UI building blocks in `Base/UI`. This is a seed — write generic pieces clean enough to carry into the next app.
- **SwiftLint enforces the machine-checkable half of this file** (`.swiftlint.yml`): `make*` view factories, forbidden MARK names, `print(` instead of `log(`, hardcoded user-facing strings. The repo is kept at zero violations — run `Scripts/lint.sh` (or `Scripts/lint.sh --fix`) before finishing a change, so anything reported is yours.
- Localization: per-scene `XxxLocalizable` enum + `.xcstrings` (6-language template: en, tr, es, de, fr, it; seed content en+tr). Every user-facing string goes through it.

## Cross-cutting invariants

- **Widgets can't do realtime.** The app writes App-Group snapshots (`AppGroupStorage` + `*WidgetMetadata` Codable structs), then calls `WidgetCenter.shared.reloadTimelines(ofKind:)`. Feature writes route through the `WidgetSync` registry: new widget = new `WidgetSyncKind` + a `WidgetSyncHandler`. Widgets read snapshots — they never fetch. See `AppSeedWidgets/README.md`.
- **Push pipeline has 4 hard rules** (no hybrid `alert`+`content-available` payloads, one event = one `push_outbox` row, loc-key deploy order, silent-push cold-launch race) — read `supabase/README.md` before touching anything push-related.
- **Storage RLS policies OR together.** A single bucket-wide `authenticated` policy cancels every narrow policy beside it — audit `pg_policy` before trusting one. Object paths carry the owner id from day one (`profile_images/{user_id}.ext`, `user_files/{user_id}/…`); retrofitting that later means moving every file. Deleting a row that names a file? Queue the path *before* the delete — afterwards nobody can ask whose file it was. See `supabase/README.md`.
- **Silent-push cold-launch race.** A silent push can launch the app in the background and race the splash. The defense is `SplashViewController.startWhenForeground()` (hold the flow until foregrounded) plus a SceneDelegate fallback; `handleSilentPush` must guard `currentUser == nil` and do no heavy work on background launches.

## Docs map + maintenance

| Doc | Content |
|---|---|
| `README.md` | Shop-window overview: stack, target layout, quickstart, docs map |
| `AppSeed/Base/README.md` | Base classes, sheet bases, Form field library, base UI |
| `AppSeed/Helpers/README.md` | Helpers, managers, App Group bridge, push, widget sync |
| `AppSeed/Network/README.md` | Domain service layer + the GPT/DALLE/Replicate/Falai HTTP shelf |
| `AppSeed/Scenes/README.md` | Scene flow map (Splash routing, tabs, sheets, deep-link hosts) |
| `AppSeed/Resources/README.md` | Asset/color/localization conventions |
| `AppSeedWidgets/README.md` | Widget extension: kind table, snapshot reads, lock-screen rules |
| `supabase/README.md` | Edge functions + push pipeline 4 hard rules + SQL templates |
| `docs/templates/` | Process-doc skeletons (brainstorm, plan, release, review) |
| `docs/patterns/` | Reusable recipe write-ups (optimistic sync, listener guards, cold-launch defer) |
| `docs/brainstorms/` | Your app's requirements docs (empty on a fresh clone) |
| `docs/plans/` | Your app's implementation plans (empty on a fresh clone) |
| `docs/reviews/` | Your app's review reports (empty on a fresh clone) |
| `docs/releases/` | Your app's shipped notes, one per version (empty on a fresh clone) |
| `docs/harvest/` | Where the seed came from: what was left behind, what is unverified |
| `AppSeedTests/` | Pure-logic suite — `Scripts/test.sh` |

**Maintenance rule:** docs update in the same commit as the change that invalidates them — new service → the Network README; new base component or form field → the Base README; new scene or navigation change → the Scenes README; new helper → the Helpers README; new widget kind → the AppSeedWidgets README; push/edge-function change → the supabase README; a trap that cost you an afternoon → a new `docs/patterns/` write-up, so the next app pays for it once. A doc that lists code the repo doesn't have (or misses code it does) is a bug.

## Working agreements

- Plan before code: analyze → present plan → approval → then implement.
- Commit and build only on explicit request.
- Push back on requests that conflict with these standards — don't silently comply.
