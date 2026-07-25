# Scenes

Scene flow map — where each scene lives and what routes into it. Per-scene detail belongs
in the code (every scene is the same MVVM-R shape; see `CLAUDE.md` and the golden file
`Main/Profile/`).

## Launch routing

`Splash` is the root scene (SceneDelegate). It defers the flow until the app is actually
foregrounded (`startWhenForeground()` — a silent push can cold-launch in the background),
checks the remote minimum version, then routes:

```
Splash
├─ app version < remote minimum   → force-update alert → App Store (re-checked on each return to foreground)
├─ !tutorials_seen                → Tutorial → Login
├─ logged in                      → Main (TabBar)
└─ else                           → Login → (Apple Sign-In) → Main (TabBar)
```

Setup is **not** a Splash decision — TabBar presents it on first appear / `.userDidChange`
once `currentUser` is loaded and `has_completed_setup` is false:

```
TabBar
└─ !has_completed_setup (name or birth date missing)  → SetupFlow (form sheet)
```

## Scene table

| Scene | Purpose | Opened from |
|---|---|---|
| `Splash/` | Launch, version gate, initial routing | App root |
| `Tutorial/` | Onboarding slides (generic) | Splash (first run) |
| `Login/` | Apple Sign-In → Supabase | Splash, Tutorial end |
| `Main/TabBar/` | TabBar shell + tabs | Splash / Login success |
| `Main/Home/` | Placeholder home tab | Tab 0 |
| `Main/Profile/` | Section-driven profile (golden file) | Tab 1 |
| `Setup/` | Name + birth-date form flow | TabBar, when setup incomplete |
| `Paywall/` | Premium sales screen (fullscreen modal) | Profile (premium-gated actions) |

## Main tabs (order = tab order)

| # | Tab | Folder | Tab item |
|---|---|---|---|
| 0 | Home | `Main/Home/` | `house` |
| 1 | Profile | `Main/Profile/` | `person_crop_circle` |

Both tabs are wrapped in a `BaseNavigationController`. Extend `setupViewControllers()` in
`TabBarViewController` to add tabs.

## Sheets

Every sheet is a full MVVM-R scene (never inline, except the generic action-sheet shortcut).

| Sheet | Base | Nested under | Trigger |
|---|---|---|---|
| `EditProfile` | FormBottomSheet | `Profile/Scenes/EditProfile/` | Profile → edit header |
| `Feedback` | BottomSheet scene | `Profile/Scenes/Feedback/` | Profile → send feedback |
| Language picker | `BottomSheetBuilder` (inline action sheet) | — | Profile → language row |
| Theme picker | `BottomSheetBuilder` (inline action sheet) | — | Profile → theme row |

`ProfileRouter` adopts `LoginRoute, BottomSheetRoute, FormBottomSheetRoute, PaywallRoute,
FeedbackSheetRoute`; sign-out routes back through `showLogin()`.

## Deep links (`appseed://<host>`)

Handled by `DeepLinkRouter` (`Helpers/DeepLinkRouter.swift`) — guards the scheme, maps an
allowlisted host to a tab index, and survives the cold-launch race (capture on connect,
drain once the tab bar is root; unknown hosts are logged and dropped). Keep the scheme in
sync with Info.plist's `CFBundleURLTypes` and the widget `.widgetURL`s.

| Host | Destination |
|---|---|
| `home` | Home tab (index 0) |

Extend `DeepLinkHost` per app as widgets and features add link targets.
