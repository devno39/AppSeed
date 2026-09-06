# Base

The framework layer every scene and component builds on. All view controllers,
view models, routers, sheets, and UI primitives descend from here. Full standards
live in the root `CLAUDE.md`.

## Layout

```
Base/
├── MVVM-R/
│   ├── Scenes/          # BaseBuilder, BaseRouter, BaseViewController, BaseViewModel
│   └── BottomSheet/
│       ├── Sheet/       # BottomSheet bases (action sheets)
│       └── Form/        # FormBottomSheet bases (form sheets)
├── Controllers/         # BaseNavigationController, BaseTabbarController
├── Transitions/         # ZoomTransition
├── UI/                  # Base UI components + Form field library
│   └── Map/             # MapKit annotation kit
├── Constants/           # Typealias
└── Localizable/         # Localizable protocol + global Localizable.xcstrings
```

## MVVM-R

### BaseViewController
Generic over `ViewModel` and `Router` (init sets `router?.viewController = self`). Provides
an optional scroll+stack container (`isScrollable`), automatic keyboard handling (sheets
override `adjustsScrollForKeyboard = false`), and an init order of `bindViewModel()` → `draw()`.

```swift
final class MyViewController: BaseViewController<MyViewModel, MyRouter> {
    override func prepare() { super.prepare() /* UI */ }
    override func bindViewModel() { super.bindViewModel() /* closures */ }
    override func configureLocalization() { }
    override func configurePalette() { }
}
```

### BaseViewModel
The protocol triple each scene follows — `DataSource` / `ClosureSource` / `FunctionSource`
(Function optional), combined in `{X}ViewModelProtocol`. Services enter as `private let`
protocols; the concrete type is named only in the Builder.

### BaseRouter + Route protocol
A Route protocol declares *how* a scene opens; the implementation lives in an
`extension {X}Route where Self: BaseRouter`. Router classes only adopt Route protocols —
no direct funcs. Prefix by presentation: `showX()` (window root swap), `pushX()` (nav push),
`presentX()` (modal).

### BaseBuilder
The only place concrete services are instantiated. Build order: router → viewModel → viewController → return.

## BottomSheet bases (`MVVM-R/BottomSheet/`)

Two families; every sheet is a full MVVM-R scene (Builder/Router/VC/VM), never inline
except the generic action-sheet shortcut.

- **`Sheet/`** — `BottomSheetViewController<VM, Router>` + `BottomSheetViewModel/Router/Builder`: action sheets (option lists). `BottomSheetBuilder` is used directly for the inline language/theme pickers in Profile.
- **`Form/`** — `FormBottomSheetViewController<VM, Router>` + `FormBottomSheetViewModel/Router/Builder`: form sheets (inputs + save). Save is fire-and-forget — the service call completes even if the sheet dismisses.

Four knobs on the action sheet, all reaching the view model through `presentBottomSheet(…)`
and `BottomSheetBuilder`:

- `onDismiss` — fires once the sheet has left the screen, whichever way it left (button,
  action row, swipe, backdrop). This is what lets a queued caller take its turn; see
  `Helpers/README.md` → Launch prompts. The view model has always declared it and the view
  controller has always fired it; what was missing was a way in from the generic
  `presentBottomSheet(…)` path, so nothing ever set it.
- `dismissesOnActionTap` — off for sheets whose rows toggle state in place (the permission sheet).
- `dismissesOnBackdropTap` — off when a stray tap outside must not close the sheet. Swipe
  still works; only the accidental dismissal is gone.
- `BottomSheetAction.isPro` — puts a `ProBadgeView` in the trailing slot. A `.normal` row
  never shows a chevron, so the slot is free.

## Form field library (`UI/Form/`)

Building blocks for form sheets — all titled, pre-fill aware:

| Component | Role |
|---|---|
| `FormTextField` | Single-line text input |
| `FormTextView` | Multi-line text input |
| `FormDatePickerField` + `DatePickerViewController` | Date selection (UICalendarView, preselect, tap-outside dismiss) |
| `FormEmojiField` | Emoji grid + custom emoji |
| `FormPickerField` + `PickerSheetViewController` | Picker row (title above, icon-left + value + chevron-right, whole row tappable) — options and time modes share the wheels sheet |
| `FormSegmentField` | Equal-width segment selection |
| `FormImagePickerField` / `FormMultiImagePickerField` | PHPicker single/multi image |
| `FormActionsField` | Horizontal in-form action row (`FormAction` struct) |
| `KeyboardDoneAccessory` | Keyboard accessory bar with a Done button |

## Controllers & Transitions

- `BaseNavigationController` / `BaseTabbarController` — nav and tab bar bases. On push, `NoMenuBarButtonItem` disables the back button's long-press history menu app-wide (overriding the `menu` setter is the only reliable route, since the system rebuilds it).
- `ZoomTransition` (`ZoomTransitionDelegate`) — zoom present/dismiss transition. `targetCornerRadius` is the radius the snapshot animates to (and `masksToBounds` is what makes it visible); `dismissSnapshot` supplies a view carrying its own shape, so shrinking a rounded card does not stretch baked pixels.

## Base UI components (`UI/`)

- **Button:** `BaseButton`, `FloatingActionButton` (FAB)
- **Label:** `BaseLabel` (font/weight/color at init), `CopyableLabel` (long-press copy)
- **TextField:** `BaseTextField` (palette-colored cursor), `EmojiTextField` (emoji-only input), `PillSearchField`
- **ImageView:** `BaseImageView`, `CircleImageView`, `CorneredImageView`, `CropImageView`
- **TableView:** `BaseTableView`, `BaseTableViewCell`, `BaseSectionHeaderView`, `EmptyTVCell`, `LargeTitleSectionHeader`
- **CollectionView:** `BaseCollectionView`, `BaseCollectionViewCell`, `PhotoViewerCell`, `PagedCarouselView` + `CarouselPageCell` (paged carousel with page control; pages come from a provider closure and are cached, so page state survives scrolling)
- **UIView:** `AvatarView` (placeholder + photo, tappable), `PalettePickerView` (horizontal accent picker), `ConfettiView`, `HudView` (LoadingHelper overlay), `RingProgressView` (parametric progress ring), `TooltipBubbleView`, `ExpandableAddField`, `LockedOverlay` (premium gate), `ProBadgeView` (rotated PRO stamp; `filled: true` puts a plate behind it for full-bleed hosts, `onTap` makes it a paywall entry point), `PaperBackgroundView`, `FloatingWidgetView`, `StatusBubbleView` (pill + tail pointing at any anchor view), `WhatsNewView` (emoji-bulleted release notes; drops into a BottomSheet as its `customView`)
- `ReusableView` protocol — reuse by `static identifier` (file `ReuseableView.swift`)

### Borders

Never assign `layer.borderColor` directly. It resolves the colour once and freezes it,
so a dynamic `UIColor` stops tracking light/dark and the previous mode's borders survive
the switch. Use `view.setBorderColor(_:)` (`Extensions/UIView+Extension.swift`) — it
re-resolves on every style change and cancels its previous registration, so repeated
calls from selection refreshes don't stack observers.

The exception is a border recomputed by a state update that already re-runs on
appearance changes (a selected/unselected ternary reapplied from
`registerForTraitChanges`) — there the direct assignment is the honest one.

### Map kit (`UI/Map/`)

Annotation types and their views, all domain-free: each annotation carries the
caller's own `id` plus what to draw.

| Annotation | View | Renders |
|---|---|---|
| `PhotoStackAnnotation` | `PhotoStackAnnotationView` | Up to 3 stacked photos, count badge, optional corner badge |
| `LabelPinAnnotation` | `LabelPinAnnotationView` | Text chip above a dot on the coordinate (`animateTap()`) |
| `AvatarAnnotation` | `AvatarAnnotationView` | Avatar with breathing glow + optional caption bubble |
| `MKClusterAnnotation` | `ClusterCountAnnotationView` | Member count badge |

Register by `reuseID`; `PhotoStackAnnotationView.clusteringIdentifier` opts pins
into MapKit clustering. Frames are set manually — MKAnnotationView is sized
before the map lays it out, so constraints resolve too late.

## Constants & Localizable

- `Typealias.swift` — closure aliases: `EmptyClosure`, `AnyClosure<T>`, `OptionalAnyClosure<T>`, `BoolClosure`, and the tuple/Codable/ResponseError variants (full list in the file).
- `Localizable.swift` — the per-scene `XxxLocalizable` enum pattern + the global `Localizable.xcstrings` for shared keys (`done`, etc.).

## Notes

1. New scene = derive from the base classes; reference scene is the golden file `Scenes/Main/Profile/`.
2. `bindViewModel()` always begins with `super`; closures bind `[weak self]`.
3. Navigation only through Route protocols.
4. Adding a base component or form field → update this README in the same commit.
