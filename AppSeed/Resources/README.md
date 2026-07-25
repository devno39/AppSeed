# Resources

Assets, colors, animations, localization keywords, and the type-safe accessors over them.
This file documents **conventions** — the asset inventory is the catalogs themselves (don't
list names here; they go stale).

## Layout

```
Resources/
├── Assets.xcassets/       # Images: AppIcon, AccentColor, Logo/, Background/, Tutorial/, readme/
├── Colors.xcassets/       # Semantic colorsets: Background/, Text/, Action/, Shadow/ (light+dark)
├── Colors/                # Color enums + Palette + Colorable protocol
├── Images/                # Asset-access enums + Imageable/Symbolable protocols
├── Animations/            # Lottie JSON (lottie-loading)
├── EmojiKeywords/         # emoji_keywords_{en,tr}.json (emoji search)
├── Info.plist
└── PrivacyInfo.xcprivacy
```

## Image access — `Imageable`

Rule: **enum case name == asset catalog name.** The `.image` accessor derives the name via
`String(describing:)` — no rawValue mapping.

```swift
protocol Imageable {
    var image: UIImage { get }   // UIImage(named: String(describing: self)) ?? UIImage()
}

imageView.image = Logo.logo_1024.image
```

Adding an image: put the asset in the catalog → add a same-named case to the matching enum.
Enums: `Logo`, `BackgroundImages`, `TutorialImage` (all in `Images/`).

## SF Symbols — `Symbolable`

The `Symbols` enum is `String`-raw-valued; `symbolName = rawValue` (with `_` → `.`). The
`Symbolable` protocol provides sizing helpers: `symbol(size:weight:)`,
`symbolSmall/Medium/Large()`, and a tinted variant.

```swift
button.setImage(Symbols.chevron_right.symbolMedium(), for: .normal)
```

Never call a symbol with a string literal — add a case to `Symbols`.

## Colors — `Colorable`

Semantic color enums live in `Colors/`, colorsets (light+dark variants) in `Colors.xcassets`:

```swift
view.backgroundColor = ColorBackground.backgroundPrimary.color
label.textColor = ColorText.textSecondary.color
```

- Families: `ColorBackground` (primary / secondary / tertiary / border / shadowPrimary),
  `ColorText` (primary / secondary), `ColorAction` (destructive).
- `.color` resolves `UIColor(named:) ?? UIColor(rgb: hex)` — the **colorset carries the
  light/dark adaptation; the enum `hex` is only a fallback.** A color used on a *fixed*
  (non-adapting) background needs a fixed literal, not an adaptive semantic color — an
  adaptive color will fail contrast in one of the two modes (see `SplashViewController`).
- **Palette (accent) colors are NOT colorsets** — they're code-defined in `Colors/Palette.swift`
  (`palette1/2/3`); selection via `PaletteManager`, live updates via `PaletteUpdatable`.
- The widget target mirrors these as `WidgetColorKit` hex values — if a colorset changes,
  update both.

## Animations

Lottie JSON under `Animations/`, loaded with `LottieAnimationView(name:)`.

## Rules

1. Asset name = enum case name — break this contract and the image silently returns empty.
2. Colors are never hardcoded in scenes — always enum + `.color` (fixed on-image text excepted).
3. SF Symbols never via string literal — add a `Symbols` case.
4. New enum/protocol pattern → update this README in the same commit.
