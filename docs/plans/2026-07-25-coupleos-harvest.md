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

## Faz 1 — Library yüzeyi (TAMAM — commit'ler `ceaf65a..6b11710`)
- [x] Extensions: 7 drifted overwrite + 4 yeni; `UIImageView+Extension` Kingfisher-saf (Supabase varyantları Faz 2 notlu).
- [x] Helpers: temiz set + tam UserDefaultsWrapper (`@SharedUserDefault` Faz 5'e) + ThemeManager + FeedbackHelper (Telegram'dan generic) + RemoteConfig key-refactor + slim NotificationHelper + EmojiHelper (+JSON'lar pbxproj kayıtlı, generator Scripts/'te).
- [x] Base: MVVM-R core (klasör `Scenes/`'e hizalandı), controllers (+NoMenuBarButtonItem), UI core, UIView bileşenleri (Hud uzlaştırması: Lottie HudView silindi, UIComponents kaldırıldı), PalettePickerView premium'suz.
- [x] Form kütüphanesi (12) + BottomSheet stack (8) — L10n global `Localizable`'a rewire (`done` key'i eklendi).
- [x] 🔎 Review kapısı 1 GEÇİLDİ: port sadakati birebir (BVC/BaseButton diff temiz), domain sızıntısı sıfır, hayalet UIComponents sync-group referansı yakalandı+temizlendi (`6b11710`), final build exit 0.

## Faz 2 — Supabase çekirdeği + Auth (TAMAM — commit'ler `afe72ee..473beab`)
- [x] Çekirdek: SupabaseManager + DatabaseHelper (Table→users) + ErrorMapper + AppConfigHelper (min-version; magic-code/telegram key'leri kırpıldı) + StorageHelper (`avatars` bucket) + UIImageView Supabase varyantları geri takıldı.
- [x] Auth dörtlüsü `Helpers/Supabase/Auth/`'ta (NonceGenerator temiz evine taşındı) + dev/release entitlement çifti (`applesignin`) — sim build kabul etti.
- [x] Kırpılmış User (`avatarURL` rename'iyle) + SupabaseUserService + minimal UserSessionManager (generation guard doğrulandı) — klasör adı temiz `Network/Services/Supabase/`.
- [x] Login scene sade görselle + en/tr LoginLocalizable; Splash bağlantısı Faz 3'te (onaylı geçici istisna).
- [x] 🔎 Review kapısı 2 GEÇİLDİ: auth zinciri birebir (header-only diff), domain sızıntısı sıfır, build exit 0.

## Faz 3 — İskelet scene'ler (TAMAM — commit'ler `92b5fee..ae93976`; kapı 3 sim'de görsel akış testiyle geçildi: splash→tutorial→login rotaları doğrulandı. Polish notu: splash başlığı koyu temada düşük kontrast)
- [x] Splash: startWhenForeground + update-gate grace; routing tutorial_seen → login → tabbar.
- [x] Tutorial: generic slide'lar; FloatingWidgetView Base'e terfi.
- [x] TabBar: 2 placeholder tab.
- [x] Profile: section-driven tablo — EditProfile form sheet, dil, tema, sign-out, delete-account. → CLAUDE.md golden file.
- [x] Setup: Form kütüphanesi canlı örneği.
- [x] **Paywall scene** (RevenueCat + PaywallPlanCard/FeatureRow; weekly→monthly→yearly funnel şablonu) + **Feedback sheet** (FeedbackHelper'a bağlı).
- [x] **DeepLinkRouter şablonu** (scheme-guard + host-allowlist + pending-drain, SceneDelegate'ten çıkarılıp tip olarak).
- [x] ScrollTest scene silinir.
- [x] 🔎 Review kapısı 3 GEÇİLDİ (sim görsel test).

## Faz 4 — Terfi bileşenleri (iyileştirerek taşı)
- [x] `RingProgressView` — 3 copy-paste ring'ten tek parametrik bileşen.
- [x] A-sınıfı: `EmojiTextField`, `PhotoViewerCell`, `PaperBackgroundView` (+`UIColor.isLight`).
- [x] B-sınıfı: `TooltipBubbleView`, `ExpandableAddField`, `LockedOverlay`, `PillSearchField`, `LargeTitleSectionHeader`.
- [x] Yeni küçük ekleme: `HapticHelper` (CoupleOS'ta inline dağınık haptik'lerin dersi).
- [x] 🔎 Review kapısı 4 GEÇİLDİ (RingProgressView ana oturumda okundu, leak sıfır).

## Faz 5 — İleri altyapı şablonları (widget + push + extension'lar)
- [x] **Widget starter kit:** widget extension target'ı + `AppGroupStorage` (generic motor: vintage-UUID atomik yazım, freshness/session doğrulama, wipe) + `WidgetSyncService`/`WidgetSyncHandler` (registry, cheap/expensive ayrımı) + `WidgetHelpers` (timeline politikaları, App-Group locale/format köprüleri, kilit view'ları) + `WidgetColorKit` şablonu + `WidgetLocalizable` kalıbı + tek demo widget (+ `StatusBubbleShape`) + widget README iskeleti.
- [x] **NSE iskeleti:** `NotificationService.swift` (version gate → reloadAllTimelines → pass-through, 25s emniyet) + Info.plist/entitlements şablonu.
- [x] **Share-extension handoff şablonu** (App-Group üzerinden ana app'e devir) — opsiyonel, yalın haliyle.
- [x] **supabase/ tohumları:** README (jenerikleştirilmiş 4 kanun playbook'u), starter SQL şablonları (users + RLS SECURITY DEFINER RPC örneği + outbox + `delete_my_account`), push edge-function şablonu, `PushNotificationManager` generic çekirdeği (device token kaydı). Şablon seviyesi — canlı test bir sonraki app'in Supabase projesinde.
- [x] **ci_scripts:** branch-adından-versiyon script'i (`ci_post_clone.sh`) + dSYM hook şablonu; `.gitignore` CoupleOS versiyonuyla güncellenir.
- [x] 🔎 Review kapısı 5 GEÇİLDİ (secret-scan temiz, 3 target build exit 0; device_tokens token-PK iyileştirmesi onaylandı).

## Faz 6 — Agentic kapanış
- [ ] CLAUDE.md finalize (golden file: Profile) + Base/Helpers/Network/Scenes README'leri (docs-maintenance kuralı seed'e gelir).
- [ ] **docs/ şablonları:** dört doküman tipinin format iskeletleri (brainstorm/plan/release/review) + `docs/patterns/` reçeteleri: pendingSaves (optimistic-base + echo-kuyruğu + 3-yönlü merge), generation-counter stale-callback guard, startWhenForeground cold-launch kalıbı.
- [ ] Xcode scene template'i güncel formata yenilenir (protokol üçlüsü, MARK sırası) + sheet template'leri eklenir; Renamer smoke test.
- [ ] Localizable seed seti (en+tr içerik, 6 dil şablonu).
- [ ] Final build + tam akış + `main`'e merge kararı Tunay'da.

## Taşınmayanlar (bilinçli)
Pair/premium domain'i, Places/Paper/Calendar/Today/Together domain scene'leri, domain widget'ları (yapıları şablon olarak öğretici, içerikleri değil), Weather üçlüsü, LocationHelper, PlaceLabelHelper, Nudge/DateReminders/MissionReminders, SQL migration geçmişi (52 dosya), GoogleService-Info değerleri. AppSeed'in mevcut GPT/DALLE/Replicate/Falai servisleri ve RevenueCat IAP dokunulmadan kalır. Network HTTP katmanı zaten AppSeed'de yaşıyor (CoupleOS 1.0.8'de silmişti — teyitli).
