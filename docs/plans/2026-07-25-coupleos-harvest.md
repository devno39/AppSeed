# CoupleOS → AppSeed Hasat Planı (2026-07-25)

**Amaç:** CoupleOS'un kanıtlanmış mimari birikimini AppSeed'e taşıyıp seed'i agentic app-fabrikasının çekirdeği haline getirmek — bir sonraki app'in ilk haftasında lazım olacak her şey seed'de hazır.

**Karar seti:**
- Apple Sign-In + Supabase = seed'in birinci sınıf auth/backend yolu; Firebase legacy raf.
- CoupleOS her yerde kanonik kaynak; CoupleOS'a SIFIR dokunuş (salt-okunur). Hasatta bulunan CoupleOS bulguları `docs/plans/coupleos-findings.md`'ye not edilir, fix edilmez.
- Palette sistemi bütün olarak taşınır; Symbols mekanizması `Imageable`/`Symbolable`/`Colorable` protokolleriyle komple gelir.
- Yürütme: plan/karar/review ana oturum (Fable), port işleri Opus subagent; faz sonlarında review kapısı.
- Deployment target 17.0; IQKeyboardManager kaldırıldı (CoupleOS BaseViewController kendi keyboard altyapısını getiriyor).
- Localization: 6 dile hazır xcstrings şablonu, seed içeriği en+tr.
- Kapsam dışı bırakılanlar bilinçli: Weather üçlüsü (domain + WeatherKit entitlement), LocationHelper (domain; izin tarafını PermissionManager karşılıyor), pair/premium domain'i, domain scene'ler, SQL geçmişi.

## Faz 0 — Zemin
**Mekanik (TAMAM — commit'ler `d1c5543..d580e13`):**
- [x] Askıdaki pbxproj dedup → ilk commit; `harvest/coupleos-v1` branch'i.
- [x] Splash duplicate `SplashLocalizable` + legacy lproj temizliği (disk orphan'larıydı).
- [x] `Base/Helpers/Network/Scenes/UIComponents` → `PBXFileSystemSynchronizedRootGroup` (46 grup + 77 fileRef + 77 buildFile girişi temizlendi). Bonus: Network'te 2 byte-identical duplicate silindi, orphan `RequestArrayProtocol` derlemeye alındı.
- [x] Deployment target 17.0.
- [x] IQKeyboardManager söküldü (SPM + AppDelegate).
- [x] Supabase SPM (umbrella `Supabase`, 2.53.0) + xcconfig/Info.plist placeholder'ları.

**İçerik (TAMAM — commit'ler `b89199f..653987e`):**
- [x] `Imageable`/`Symbolable` + `Symbols` mekanizması (8 case'lik starter set — Base/Form grep kuralıyla kırpıldı).
- [x] Palette sistemi (WidgetKit/L10n bağları söküldü; sıfır call-site kırığı) + Colors.xcassets semantik yapı.
- [x] `Typealias` union + `PrivacyInfo.xcprivacy` (Resources phase'e kayıtlı).
- [x] `CLAUDE.md` taslağı (golden file: Splash→Profile geçişli).

## Faz 1 — Library yüzeyi
- [ ] Extensions: CoupleOS-ileride 8 merge + yeni `CGFloat`/`TimeInterval`/`UIImage`/`UIViewAnimation`; `UIImageView+Extension` iyileştirilerek (Kingfisher kalır, SupabaseStorage bağı parametrize).
- [ ] Helpers: AlertHelper, KeychainHelper, EmojiHelper + `emoji_keywords_{en,tr}.json` + CLDR generator script'i, FormatHelper, DateHelper, PermissionManager, ReviewPromptManager, QRHelper, ToastHelper+ToastView, Language ailesi, Logger, UserDefaultsWrapper (seed key seti), **ThemeManager** (AppGroup bağı sökülmüş), **TelegramHelper → FeedbackHelper** (placeholder bot config); RemoteConfig key-refactor uyarlanır, NotificationHelper yalın gövde + tek demo zamanlayıcı.
- [ ] Base: BaseViewController (keyboard+toast+palette), BaseButton (style enum + loading), BaseTextField, BaseNavigationController (+`NoMenuBarButtonItem`), BaseTabbarController, BaseRouter ilaveleri, cell'lere PaletteUpdatable, BaseSectionHeaderView, EmptyTVCell, ZoomTransition, FloatingActionButton, CropImageView, HudView, AvatarView, ConfettiView, PalettePickerView.
- [ ] Form kütüphanesi (12) + BottomSheet MVVM-R stack (8) + DatePickerViewController + PickerSheetViewController — Symbols/L10n parametrize.
- [ ] 🔎 Review kapısı 1: build yeşil + ana oturumda review.

## Faz 2 — Supabase çekirdeği + Auth
- [ ] Çekirdek: SupabaseManager (timestamp decoder), SupabaseDatabaseHelper (Table: users + örnek), ListenerHandle, ErrorMapper, AppConfigHelper (min-version gate), StorageHelper.
- [ ] Auth: NonceGenerator, SupabaseAppleSignInService, AuthorizationDelegate, SignInError + Sign in with Apple capability/entitlement (dev/release entitlement çifti kalıbıyla).
- [ ] UserServiceProtocol → SupabaseUserService (kırpılmış User) + minimal UserSessionManager (generation-counter guard, .userDidChange, wipeCache reset hook).
- [ ] Login scene (sade seed görseli; Terms/Privacy attributed-text kalıbı kalır).
- [ ] 🔎 Review kapısı 2. Not: gerçek e2e auth bir dev Supabase projesi ister; seed'de akış auth çağrısına kadar doğrulanır.

## Faz 3 — İskelet scene'ler
- [ ] Splash: startWhenForeground + update-gate grace; routing tutorial_seen → login → tabbar.
- [ ] Tutorial: generic slide'lar; FloatingWidgetView Base'e terfi.
- [ ] TabBar: 2 placeholder tab.
- [ ] Profile: section-driven tablo — EditProfile form sheet, dil, tema, sign-out, delete-account. → CLAUDE.md golden file.
- [ ] Setup: Form kütüphanesi canlı örneği.
- [ ] **Paywall scene** (RevenueCat + PaywallPlanCard/FeatureRow; weekly→monthly→yearly funnel şablonu) + **Feedback sheet** (FeedbackHelper'a bağlı).
- [ ] **DeepLinkRouter şablonu** (scheme-guard + host-allowlist + pending-drain, SceneDelegate'ten çıkarılıp tip olarak).
- [ ] ScrollTest scene silinir.
- [ ] 🔎 Review kapısı 3: tam akış — splash → tutorial → login → tabbar → profile → paywall → logout.

## Faz 4 — Terfi bileşenleri (iyileştirerek taşı)
- [ ] `RingProgressView` — 3 copy-paste ring'ten tek parametrik bileşen.
- [ ] A-sınıfı: `EmojiTextField`, `PhotoViewerCell`, `PaperBackgroundView` (+`UIColor.isLight`).
- [ ] B-sınıfı: `TooltipBubbleView`, `ExpandableAddField`, `LockedOverlay`, `PillSearchField`, `LargeTitleSectionHeader`.
- [ ] Yeni küçük ekleme: `HapticHelper` (CoupleOS'ta inline dağınık haptik'lerin dersi).
- [ ] 🔎 Review kapısı 4.

## Faz 5 — İleri altyapı şablonları (widget + push + extension'lar)
- [ ] **Widget starter kit:** widget extension target'ı + `AppGroupStorage` (generic motor: vintage-UUID atomik yazım, freshness/session doğrulama, wipe) + `WidgetSyncService`/`WidgetSyncHandler` (registry, cheap/expensive ayrımı) + `WidgetHelpers` (timeline politikaları, App-Group locale/format köprüleri, kilit view'ları) + `WidgetColorKit` şablonu + `WidgetLocalizable` kalıbı + tek demo widget (+ `StatusBubbleShape`) + widget README iskeleti.
- [ ] **NSE iskeleti:** `NotificationService.swift` (version gate → reloadAllTimelines → pass-through, 25s emniyet) + Info.plist/entitlements şablonu.
- [ ] **Share-extension handoff şablonu** (App-Group üzerinden ana app'e devir) — opsiyonel, yalın haliyle.
- [ ] **supabase/ tohumları:** README (jenerikleştirilmiş 4 kanun playbook'u), starter SQL şablonları (users + RLS SECURITY DEFINER RPC örneği + outbox + `delete_my_account`), push edge-function şablonu, `PushNotificationManager` generic çekirdeği (device token kaydı). Şablon seviyesi — canlı test bir sonraki app'in Supabase projesinde.
- [ ] **ci_scripts:** branch-adından-versiyon script'i (`ci_post_clone.sh`) + dSYM hook şablonu; `.gitignore` CoupleOS versiyonuyla güncellenir.
- [ ] 🔎 Review kapısı 5.

## Faz 6 — Agentic kapanış
- [ ] CLAUDE.md finalize (golden file: Profile) + Base/Helpers/Network/Scenes README'leri (docs-maintenance kuralı seed'e gelir).
- [ ] **docs/ şablonları:** dört doküman tipinin format iskeletleri (brainstorm/plan/release/review) + `docs/patterns/` reçeteleri: pendingSaves (optimistic-base + echo-kuyruğu + 3-yönlü merge), generation-counter stale-callback guard, startWhenForeground cold-launch kalıbı.
- [ ] Xcode scene template'i güncel formata yenilenir (protokol üçlüsü, MARK sırası) + sheet template'leri eklenir; Renamer smoke test.
- [ ] Localizable seed seti (en+tr içerik, 6 dil şablonu).
- [ ] Final build + tam akış + `main`'e merge kararı Tunay'da.

## Taşınmayanlar (bilinçli)
Pair/premium domain'i, Places/Paper/Calendar/Today/Together domain scene'leri, domain widget'ları (yapıları şablon olarak öğretici, içerikleri değil), Weather üçlüsü, LocationHelper, PlaceLabelHelper, Nudge/DateReminders/MissionReminders, SQL migration geçmişi (52 dosya), GoogleService-Info değerleri. AppSeed'in mevcut GPT/DALLE/Replicate/Falai servisleri ve RevenueCat IAP dokunulmadan kalır. Network HTTP katmanı zaten AppSeed'de yaşıyor (CoupleOS 1.0.8'de silmişti — teyitli).
