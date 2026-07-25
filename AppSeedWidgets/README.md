# AppSeedWidgets

WidgetKit extension. Widgets can't subscribe to realtime — every provider reads App Group snapshots the app wrote (`AppGroupStorage` + `*WidgetMetadata` structs in `AppSeed/Helpers/AppGroup/`), and the app reloads timelines via `WidgetCenter.reloadTimelines(ofKind:)` after each snapshot write (handlers in `AppSeed/Helpers/WidgetSync/`).

`AppGroupStorage.swift` and the `*WidgetMetadata` structs compile into **both** targets (app + widget) — they're referenced explicitly in the widget target's Sources phase (the app's `Helpers` folder is a synchronized group, so the shared files are pulled in per-file rather than by folder).

## Kinds

Bundle order in `AppSeedWidgetsBundle.swift` = Apple gallery order. New app appends its widgets there and adds a matching `WidgetSyncKind` + handler.

| Kind | Family | Gating | Snapshot |
|---|---|---|---|
| `DemoWidget` | small/medium home | free | demo |

## Rules

- **JSON-only providers go through `WidgetSnapshot.read<T>`** — scope guard (`currentScopeId`) + fresh-only + iso8601 decode. Image-carrying snapshots use `AppGroupStorage.read`/`readImages` directly.
- **Snapshot values freeze at sync time** — count widgets roll them forward with `SnapshotAge.days(since:)` so counts stay right between app opens.
- **No `LanguageManager` widget-side** (app-only) — widgets format through `WidgetDateFormat`/`WidgetLocale`/`WidgetNumberFormat`, which read the language mirrored into the App Group.
- **Lock screen (accessory) kinds render vibrant monochrome** — hierarchy from opacity/weight (`.primary`/`.secondary`), never `WidgetColors`. Premium accessory kinds show `LockedAccessoryWidgetView`; home kinds show `LockedHomeWidgetView` (gated on `AppGroupStorage.isPro`).
- **Colors/theme/palette** read from the App Group shared defaults (`WidgetColorKit`); keep `WidgetColors` and `WidgetPalettePreset` in sync with the app's `Colors.xcassets` / `PalettePreset`.
- Localization: `WidgetLocalizable` enum + per-language `<lang>.lproj/WidgetLocalizable.strings` (seed ships en + tr), resolved from the App Group language.
- `.widgetURL(appseed://<host>)` deep-links into the app (hosts allowlisted in `DeepLinkRouter`).
