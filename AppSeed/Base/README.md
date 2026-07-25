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
- `ZoomTransition` (`ZoomTransitionDelegate`) — zoom present/dismiss transition.

## Base UI components (`UI/`)

- **Button:** `BaseButton`, `FloatingActionButton` (FAB)
- **Label:** `BaseLabel` (font/weight/color at init), `CopyableLabel` (long-press copy)
- **TextField:** `BaseTextField` (palette-colored cursor), `EmojiTextField` (emoji-only input), `PillSearchField`
- **ImageView:** `BaseImageView`, `CircleImageView`, `CorneredImageView`, `CropImageView`
- **TableView:** `BaseTableView`, `BaseTableViewCell`, `BaseSectionHeaderView`, `EmptyTVCell`, `LargeTitleSectionHeader`
- **CollectionView:** `BaseCollectionView`, `BaseCollectionViewCell`, `PhotoViewerCell`
- **UIView:** `AvatarView` (placeholder + photo, tappable), `PalettePickerView` (horizontal accent picker), `ConfettiView`, `HudView` (LoadingHelper overlay), `RingProgressView` (parametric progress ring), `TooltipBubbleView`, `ExpandableAddField`, `LockedOverlay` (premium gate), `PaperBackgroundView`, `FloatingWidgetView`
- `ReusableView` protocol — reuse by `static identifier` (file `ReuseableView.swift`)

## Constants & Localizable

- `Typealias.swift` — closure aliases: `EmptyClosure`, `AnyClosure<T>`, `OptionalAnyClosure<T>`, `BoolClosure`, and the tuple/Codable/ResponseError variants (full list in the file).
- `Localizable.swift` — the per-scene `XxxLocalizable` enum pattern + the global `Localizable.xcstrings` for shared keys (`done`, etc.).

## Notes

1. New scene = derive from the base classes; reference scene is the golden file `Scenes/Main/Profile/`.
2. `bindViewModel()` always begins with `super`; closures bind `[weak self]`.
3. Navigation only through Route protocols.
4. Adding a base component or form field → update this README in the same commit.
