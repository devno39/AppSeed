# CLAUDE.md — AppSeed

UIKit seed project (UIKit + SnapKit, MVVM-R, Supabase) — the starting point for new apps, carrying CoupleOS-proven patterns so the next app has its first week already built. This file is the contract for how code is written here. **Do not deviate from these standards.** When in doubt, read the golden file.

**Golden file:** `AppSeed/Scenes/Main/Profile/` — lands in Phase 3 of the harvest; until then `Scenes/Splash/` is the reference shape. New scenes copy its shape.

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
- No dead code in APP code: unused scenes, routes, view models, and helpers are removed, not kept "just in case" (exception: Firebase helpers and the GPT/DALLE/Replicate/Falai shelf modules, kept as optional infrastructure). **`Extensions/` and `Base/UI` are library surface** — unused members stay; they exist to be reached for. Only remove a library member when it is actively harmful (e.g. shadowing a system API).
- No over-engineering: no speculative abstractions, no generic frameworks for one call site. Solve today's problem.
- Reusable behavior lives in its natural home, never inline in scenes: system-type behavior as extensions (`Extensions/`), domain utilities as helpers (`Helpers/`), UI building blocks in `Base/UI`. This is a seed — write generic pieces clean enough to carry into the next app.
- Localization: per-scene `XxxLocalizable` enum + `.xcstrings` (6-language template: en, tr, es, de, fr, it; seed content en+tr). Every user-facing string goes through it.

## Cross-cutting invariants

Placeholder — the seed's widget and push invariants (App-Group snapshot mirroring, silent-push cold-launch races, one-event-one-outbox-row) arrive with the Phase 5 widget/push templates. Until those land, no cross-cutting push/widget rules apply.

## Docs map + maintenance

| Doc | Content |
|---|---|
| `README.md` | Project overview |
| `docs/plans/` | Requirements and implementation plans (dated) |

Per-area READMEs (`Base/`, `Helpers/`, `Network/`, `Scenes/`, `Resources/`) and the `docs/` process templates land in Phase 6 of the harvest.

**Maintenance rule:** docs update in the same commit as the change that invalidates them — new service → the Network README; new base component or form field → the Base README; new scene or navigation change → the Scenes README; new helper → the Helpers README. A doc that lists code the repo doesn't have (or misses code it does) is a bug.

## Working agreements

- Plan before code: analyze → present plan → approval → then implement.
- Commit and build only on explicit request.
- Push back on requests that conflict with these standards — don't silently comply.
