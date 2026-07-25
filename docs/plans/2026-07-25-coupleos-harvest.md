# CoupleOS → AppSeed Hasat Planı (2026-07-25)

**Amaç:** CoupleOS'un kanıtlanmış mimari birikimini (Base, Extensions, Helpers, Form kütüphanesi, auth, iskelet scene'ler) AppSeed'e taşıyıp seed'i agentic app-fabrikasının çekirdeği haline getirmek.

**Karar seti:**
- Apple Sign-In + Supabase = seed'in birinci sınıf auth/backend yolu; Firebase legacy raf olarak kalır.
- CoupleOS her yerde kanonik kaynak (AppSeed'in "ileride" görünen dosyaları budanmamış eski orijinaller — diff'le doğrulandı).
- CoupleOS'a SIFIR dokunuş — salt-okunur kaynak. Hasat sırasında bulunan CoupleOS bug/dupe'ları sadece `docs/plans/coupleos-findings.md`'ye not edilir, fix edilmez.
- Palette sistemi (PaletteManager + PaletteUpdatable) bütün olarak taşınır — stub değil.
- Yürütme: plan/karar/review ana oturumda (Fable), port işleri Opus subagent'larda; her fazın sonunda tek review kapısı.
- Deployment target 17.0'a çekilir (CoupleOS ile hizalı). IQKeyboardManager kaldırılır (CoupleOS BaseViewController kendi keyboard-adjust altyapısını getiriyor; ikisi çakışır).
- Localization: 6 dile hazır xcstrings şablonu, seed içeriği en+tr.

## Faz 0 — Zemin
- [x] Askıdaki pbxproj dedup değişikliği incelendi → hasat branch'inin ilk commit'i (`harvest/coupleos-v1`).
- [ ] Splash'taki duplicate `SplashLocalizable.swift` (scene kökü) + legacy `en.lproj`/`tr.lproj` sil (sync dönüşümü öncesi ZORUNLU — duplicate symbol önlemi).
- [ ] `Base/`, `Helpers/`, `Network/`, `Scenes/`, `UIComponents/` klasörlerini `PBXFileSystemSynchronizedRootGroup`'a çevir (Extensions zaten öyle). Eski PBXGroup/FileReference/BuildFile girişleri temizlenir. `Application/`, `Configuration/`, `Resources/` şimdilik klasik kalır. Build yeşili şart.
- [ ] Deployment target 17.0; IQKeyboardManager SPM + AppDelegate çağrıları kaldır.
- [ ] Supabase SPM paketi ekle; `SUPABASE_URL`/`SUPABASE_ANON_KEY` xcconfig placeholder'ları.
- [ ] Önkoşul enum'lar: `Symbols` (kırpılmış), Palette sistemi (PaletteManager + Palette/Colorable + Colors.xcassets girişleri), `Typealias` merge (ResponseError* GPT alias'ları korunur).
- [ ] AppSeed `CLAUDE.md` taslağı (CoupleOS kontratının seed versiyonu; golden file = Faz 3'te Profile scene'i olacak).

## Faz 1 — Library yüzeyi
- [ ] Extensions: CoupleOS-ileride 8 dosya merge (`UIApplication`, `Date`, `String`, `UIColor`, `UITableView`, `URL`, `UIView`, +) + yeni `CGFloat`, `TimeInterval`, `UIImage` (Palette'li), `UIViewAnimation`; `UIImageView+Extension` iyileştirilerek (Kingfisher kalır, SupabaseStorage bağı parametrize).
- [ ] Helpers: AlertHelper (CoupleOS ver.), KeychainHelper, EmojiHelper, FormatHelper, DateHelper, PermissionManager, ReviewPromptManager, QRHelper, Toast çifti (ToastHelper+ToastView), Language ailesi, Logger, UserDefaultsWrapper (seed key seti: tutorials_seen, has_completed_setup, has_shown_permission_sheet); RemoteConfig key-refactor uyarlanır (GPT key'leri AppSeed servisleriyle uyumlu kalır), NotificationHelper yalın gövde + tek demo zamanlayıcı.
- [ ] Base: BaseViewController (keyboard+toast+palette), BaseButton (style enum + loading), BaseTextField, BaseNavigationController, BaseTabbarController, BaseRouter (dismissPresented+ShareRoute), cell'lere PaletteUpdatable, BaseSectionHeaderView, EmptyTVCell, ZoomTransition, FloatingActionButton, CropImageView, HudView, AvatarView, ConfettiView, PalettePickerView.
- [ ] Form kütüphanesi (12 dosya) + BottomSheet MVVM-R stack'i (8 dosya) + DatePickerViewController + PickerSheetViewController — Symbols/L10n parametrize edilerek.
- [ ] 🔎 Review kapısı 1: build yeşil + ana oturumda dosya review.

## Faz 2 — Supabase çekirdeği + Auth
- [ ] Çekirdek: SupabaseManager (timestamp decoder), SupabaseDatabaseHelper (Table: users + örnek), ListenerHandle, SupabaseDatabaseErrorMapper, SupabaseAppConfigHelper (min-version gate), SupabaseStorageHelper.
- [ ] Auth: NonceGenerator, SupabaseAppleSignInService, SupabaseAppleAuthorizationDelegate, SupabaseAppleSignInError + Sign in with Apple capability/entitlement.
- [ ] UserServiceProtocol → SupabaseUserService (kırpılmış User modeli) + minimal UserSessionManager (generation-counter stale-callback guard, .userDidChange, wipeCache reset hook).
- [ ] Login scene (yapı aynen; orbit/social-proof süsü sade seed görseline iner; Terms/Privacy attributed-text kalıbı kalır).
- [ ] 🔎 Review kapısı 2: build + akış review'u. Not: gerçek e2e auth testi bir dev Supabase projesi + provisioning ister; seed'de akış "auth çağrısına kadar" simülatörde doğrulanır.

## Faz 3 — İskelet scene'ler
- [ ] Splash: startWhenForeground + update-gate grace pattern; routing tutorial_seen → login → tabbar.
- [ ] Tutorial: generic slide'lar; FloatingWidgetView Base'e terfi, demo içerik.
- [ ] TabBar: 2 placeholder tab'lı container (BaseTabbarController nihayet kullanılır).
- [ ] Profile: section-driven tablo — EditProfile form sheet, dil, tema, sign-out, delete-account. → CLAUDE.md golden file.
- [ ] Setup: Form kütüphanesinin canlı örneği (FormTextField + FormDatePickerField).
- [ ] ScrollTest scene silinir (playground artığı, seed'de yeri yok).
- [ ] 🔎 Review kapısı 3: tam akış — splash → tutorial → login → tabbar → profile → logout → login.

## Faz 4 — Terfi bileşenleri (iyileştirerek taşı)
- [ ] `RingProgressView` — CoupleOS'ta 3 yerde copy-paste olan ring'ten tek parametrik bileşen (radius/lineWidth/renk).
- [ ] A-sınıfı: `EmojiTextField` (CoupleEmojiTextField rename), `PhotoViewerCell` (zoom/pan image cell), `PaperBackgroundView` (+`UIColor.isLight`).
- [ ] B-sınıfı: `TooltipBubbleView` (StatusBubbleView'dan), `ExpandableAddField` (QuickAddTaskView'dan), `LockedOverlay`, `PillSearchField` (MapSearchField'dan), `PaywallPlanCard`+`PaywallFeatureRow` (generic pricing seti), `LargeTitleSectionHeader` (TodaySectionHeader'dan).
- [ ] 🔎 Review kapısı 4.

## Faz 5 — Agentic kapanış
- [ ] CLAUDE.md finalize + Base/Helpers/Network/Scenes README'leri (docs-maintenance kuralı seed'e gelir).
- [ ] Renamer smoke test (yeni dosya seti ile), Xcode scene template uyum kontrolü.
- [ ] Localizable seed seti (en+tr içerik, 6 dil şablonu).
- [ ] Final build + tam akış + anlamlı commit hikâyesi; `main`'e merge kararı Tunay'da.

## Taşınmayanlar (bilinçli)
Widget pipeline'ı + AppGroup katmanı, push/outbox sistemi, pair/premium domain'i, SQL migration'lar, Places/Paper/Calendar/Today/Together domain scene'leri, LocationHelper, TelegramHelper, WidgetSync. Bunlar CoupleOS'un ürünü, seed'in değil. AppSeed'in mevcut GPT/DALLE/Replicate/Falai servisleri ve RevenueCat IAP dokunulmadan kalır.
