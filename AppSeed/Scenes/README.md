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
| `Main/Home/` | App-level surface: review gate, shared-item drain | Tab 0 |
| `Main/Items/` | Per-user collection — **feature golden file** | Tab 1 |
| `Main/Profile/` | Section-driven settings — **settings golden file** | Tab 2 |
| `Setup/` | Name + birth-date form flow | TabBar, when setup incomplete |
| `Paywall/` | Premium sales screen (fullscreen modal) | Profile (premium-gated actions) |
| `QRScanner/` | Camera QR reader, returns the raw string | Ready to use — no call site yet |
| `PhotoViewer/` | Full-screen zoomable photo pager | Ready to use — no call site yet |
| `ReviewPrompt/` | "Enjoying the app?" sheet before `SKStoreReviewController` | Home, when `ReviewPromptManager.shouldShow()` |

## Main tabs (order = tab order)

| # | Tab | Folder | Tab item |
|---|---|---|---|
| 0 | Home | `Main/Home/` | `house` |
| 1 | Items | `Main/Items/` | `checkmark_circle_fill` |
| 2 | Profile | `Main/Profile/` | `person_crop_circle` |

Both tabs are wrapped in a `BaseNavigationController`. Extend `setupViewControllers()` in
`TabBarViewController` to add tabs.

## Sheets

Every sheet is a full MVVM-R scene (never inline, except the generic action-sheet shortcut).

| Sheet | Base | Nested under | Trigger |
|---|---|---|---|
| `AddItem` | FormBottomSheet | `Items/Scenes/AddItem/` | Items → FAB / empty-state button |
| `EditProfile` | FormBottomSheet | `Profile/Scenes/EditProfile/` | Profile → edit header |
| `Feedback` | BottomSheet scene | `Profile/Scenes/Feedback/` | Profile → send feedback |
| `PermissionSheet` | BottomSheet scene | `Setup/Scenes/PermissionSheet/` | Profile → permissions row |
| `ReviewPromptSheet` | BottomSheet scene | `ReviewPrompt/` | Home, on the review gate |
| Language picker | `BottomSheetBuilder` (inline action sheet) | — | Profile → language row |
| Theme picker | `BottomSheetBuilder` (inline action sheet) | — | Profile → theme row |

`ProfileRouter` adopts `LoginRoute, BottomSheetRoute, FormBottomSheetRoute, PaywallRoute,
FeedbackSheetRoute, PermissionSheetRoute`; sign-out routes back through `showLogin()`.

`PermissionSheet` refreshes itself on `.permissionsDidChange` and on
`didBecomeActiveNotification` — iOS posts nothing when the user comes back from
Settings, so without the second observer the rows stay stale.

## Items — the feature golden file

Copy this folder for any per-user collection. It is the shortest complete path through
the stack: `007_items.sql` → `SupabaseItemService` → `ItemsViewModel` → table + empty
state + swipe delete + FAB → `AddItemSheet` on the Form library.

Two things in it are worth keeping when you rename it:

- **The listener is the only fetch.** `listenItems` delivers the first page and every
  change after it, so there is no separate load call and no refresh control — realtime
  is the refresh. A collection listener refetches on each event rather than merging the
  row delta; decode the record instead once a table outgrows that.
- **Writes land locally first, and roll back on failure.** The optimistic mutation is
  what makes the UI instant; the listener's refetch reconciles it. A failed write is
  undone in the completion because the server never saw it — no echo will correct it.

## Ready-to-use scenes

`QRScanner/` and `PhotoViewer/` ship wired but uncalled. They are seed inventory,
not dead code: delete them only if the app will never scan a code or show a photo
full-screen.

- `QRScannerRoute.presentQRScanner(onCodeScanned:)` — handles the camera permission
  round-trip and hands back the raw scanned string; validation belongs to the caller.
- `PhotoViewerRoute.presentPhotoViewer(imageURLs:startIndex:info:actions:sourceFrame:sourceImage:)`
  — paging, counter, tap-to-hide chrome, pan-to-dismiss. Pass `sourceFrame`/`sourceImage`
  for the zoom transition, `actions` to get an options button, `info` for the caption bar.

## Review prompt

`ReviewPromptManager` counts sessions (`incrementSession()` in `AppDelegate`) and waits
for a milestone the app defines — the seed records it when the Setup flow completes.
Two sessions later Home offers the sheet once; "yes" goes to `SKStoreReviewController`,
"not now" opens the feedback sheet instead. Sign-out clears the milestone but never the
shown flag, so nobody is asked twice.

## Deep links (`appseed://<host>`)

Handled by `DeepLinkRouter` (`Helpers/DeepLinkRouter.swift`) — guards the scheme, maps an
allowlisted host to a tab index, and survives the cold-launch race (capture on connect,
drain once the tab bar is root; unknown hosts are logged and dropped). Keep the scheme in
sync with Info.plist's `CFBundleURLTypes` and the widget `.widgetURL`s.

| Host | Destination |
|---|---|
| `home` | Home tab (index 0) |
| `items` | Items tab (index 1) |

Extend `DeepLinkHost` per app as widgets and features add link targets.
