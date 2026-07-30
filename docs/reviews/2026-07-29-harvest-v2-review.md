# Harvest v2 Review — CoupleOS → AppSeed (2026-07-29)

Kapsam: `docs/plans/2026-07-28-harvest-v2.md` F1–F5 + doküman turu. F6 (agentic katman)
Tunay'ın kararıyla ayrı işe bırakıldı.

Yürütme: plan → taşı → review → build, faz başına. CoupleOS'a sıfır dokunuş (salt-okunur).

## Kapı sonuçları

| Kapı | Sonuç | Bulgular |
|---|---|---|
| Baseline | ✅ | 2026-07-28 build exit 0, own-code warning yok |
| F1 — Drift | ✅ | ReviewPromptManager tek-sor mantığı; `shown` bayrağı reset'ten muaf tutuldu |
| F2 — Base UI | ✅ | Map kit + PagedCarousel + StatusBubble; domain sızıntısı sıfır |
| F3 — Helper | ✅ | LocalReminderHelper; NotificationHelper'ın demo scheduler'ı ve legacy "id_1" kalıntısı temizlendi |
| F4 — Scene | ✅ | 4 scene derlendi; l10n key/xcstrings paritesi script'le doğrulandı |
| F5 — Extension + backend | ✅ | ShareExtension target'ı elle pbxproj'a eklendi, appex app bundle'ında; secret-scan temiz |
| Final | ✅ | Clean build exit 0, sıfır own-code warning; Renamer smoke AppSeed→TestSeed + build exit 0 |

## Taşınanlar

**Base UI** — `Base/UI/Map/` (PhotoStack / LabelPin / Avatar annotation + view'ları,
ClusterCount view'ı), `PagedCarouselView` + `CarouselPageCell`, `StatusBubbleView`.

**Helpers** — `LocalReminderHelper` (prefix-scoped sync + ReminderRepeatRule),
`PendingSharedItem` (App Group devri), `DateHelper` yinelenen tarih hesapları
(`RecurrencePeriod`, `daysRemaining`, `nextOccurrence`, `occurrenceDays`).

**Extensions** — `Collection[safe:]`, `String.height(withConstrainedWidth:font:)`.

**Scene** — `ReviewPrompt/` (Home'a bağlı, tam akış canlı), `Setup/Scenes/PermissionSheet/`
(Profile'a bağlı), `QRScanner/`, `PhotoViewer/` (ikisi hazır envanter, çağrı yeri yok).

**Target** — `AppSeedShareExtension` (gerçek target; Sources/Frameworks/Resources fazları,
sync group, embed + dependency, iki build config).

**Backend** — `003_app_config` (remote config + admins + is_admin), `004_storage`
(owner-scoped RLS), `005_storage_purge` (kuyruk + yetim taraması + cron), `006_premium`
(guard trigger); `feedback`, `purge-storage`, `revenuecat-webhook` edge fonksiyonları;
`tests/000_rls_baseline_test.sql` regresyon kalıbı.

## İkinci review turu (aynı gün, satır satır okuma)

İlk tur "derleniyor + sızıntı yok" seviyesindeydi. İkinci turda her yeni dosya
davranış düzeyinde okundu; 8 gerçek kusur daha çıktı.

**Yeni kodda bulunanlar**

1. **`PagedCarouselView.layoutSubviews` her geçişte sayfaya geri sıçratıyordu.**
   CoupleOS'tan gelen yorum "yalnız bounds değişince çalışır" diyordu ama kod bunu
   garanti etmiyordu — sürükleme sırasında tetiklenen herhangi bir layout, kullanıcının
   hareketini iptal ederdi. `lastLaidOutSize` karşılaştırması eklendi (+ `invalidateLayout`,
   flow layout item boyutu bounds'a bağlı olduğu için).
2. **`CarouselPageCell.detachPageView` başka hücrenin constraint'lerini silebiliyordu.**
   `snp.removeConstraints()` view'a bağlıdır, hücreye değil. Artık yalnız kendi
   `contentView`'ındaki view'ı söküyor.
3. **`PhotoViewerInfoView` taşma kontrolü `DispatchQueue.main.async` ile yapılıyordu;**
   label'ın genişliği o an hâlâ 0 olabildiği için chevron hiç görünmeyebilirdi.
   `layoutSubviews`'a taşındı — deterministik.
4. **Home'da paylaşılan içerik uyarısı ile review sheet'i üst üste biniyordu.**
   `AlertHelper` asenkron sunuyor, dolayısıyla review kapısının `presentedViewController`
   kontrolü onu göremiyordu. Paylaşım varsa review o tur atlanıyor.
5. **`delete_my_account` 001'de tanımlıyken 005'in fonksiyonunu çağırıyordu** — ileri
   yönlü bağımlılık. 001 tekrar kendi başına çalışır hâle getirildi; enqueue'lu sürüm
   005'te `create or replace` ile veriliyor (repo'nun "en yeni tanım kaynaktır" kuralı).
6. **RLS test takımında 5. case yanlışlıkla geçiyordu** — `reset role` sonrası jwt
   claim'leri transaction'da kaldığı için. Artık kullanıcı C'yi açıkça taklit ediyor.

**Seed'de zaten var olan, bu turda yakalanan kusurlar**

7. **`Configuration.isRelease` / `isDevelop` her zaman `false` dönüyordu.** `#if Release`
   / `#if Develop` yazılmıştı ama konfigürasyon *adları* derleme koşulu değil; bu projede
   yalnız `DEBUG` tanımlı. `appVersionAndBuild()` bu yüzden release'te de build numarası
   gösterirdi. `DEBUG` üzerinden yeniden yazıldı.
8. **`AppDelegate.firebase()` var olmayan bir Info.plist anahtarını `"Debug"` ile
   karşılaştırıyordu** — develop build'i de release plist'ini seçerdi. `Configuration.isDevelop`'a
   bağlandı; ayrıca plist bundle ID uyuşmazlığı için uyarı eklendi (uyuşmazlıkta Firebase
   sorunsuz configure olur, olaylar sunucuda sessizce düşer).

**Bu turda kapatılan eksik**

9. **Sign in with Apple iptali hiçbir yerde ele alınmıyordu.** Kullanıcı iOS Ayarlar'dan
   erişimi kaldırdığında Supabase oturumu geçerli kalmaya devam ederdi. İki yol da
   kuruldu: uygulama açıkken `credentialRevokedNotification`, kapalıyken her aktivasyonda
   `verifyAppleCredential()`. Apple'ın kendi kullanıcı kimliği Keychain'e yazılıyor
   (`getCredentialState` başka anahtar kabul etmiyor). Bu iş sırasında oturum kapatma
   sırası `UserSessionManager.signOut()`'ta tek yere toplandı — ProfileViewModel'deki
   kopya kalktı.

**Ek doğrulamalar**

- Release konfigürasyonu ilk kez derlendi: exit 0. Share extension bundle id'leri iki
  konfigürasyonda da doğru (`…develop.share` / `…release.share`).
- `knownRegions` en/tr → en/tr/es/de/fr/it genişletildi; dokümanların "6 dil şablonu"
  iddiası artık gerçek.
- Standart taraması (MARK sırası, `make*` yasağı, header, tek satır lazy var,
  force-unwrap, `[weak self]`) 33 yeni dosyada temiz.
- CoupleOS'ta kalan tüm dosyalar tek tek sınıflandırıldı; hepsi ya Firebase legacy ya
  domain. Tek tartışmalı: `LocationHelper` — dışarıda bırakıldı, çünkü CoupleOS sürümü
  SLC + partner paylaşımına gömülü. Map kit pin çizer, konum üretmez; konum gerektiren
  ilk uygulamada yazılacak.

## İlk turda düzeltilen gerçek kusurlar

1. **Info.plist'te izin açıklaması yoktu.** `PermissionManager` konum/fotoğraf isteyebiliyordu
   ama `NSLocationWhenInUseUsageDescription` / `NSPhotoLibraryUsageDescription` tanımlı
   değildi — ilk izin isteğinde crash. Üçü (kamera dahil) iki config'e de eklendi.
2. **`SupabaseAppConfigHelper.fetchAll` `select()` ile tüm kolonları çekiyordu.**
   `[[String: String]]` decode'u, tablo `value_type`/`updated_at` kazanır kazanmaz
   kırılırdı. `select("key,value")` yapıldı.
3. **`ReviewPromptManager` eski iki-sor mantığındaydı** ve hiçbir yerden çağrılmıyordu.
   Mantık sadeleşti + AppDelegate/Setup/Home/Profile zincirine bağlandı.
4. **`AvatarView(egg:)` ve `startEggGlowAnimation`** seed API'sinde domain adı taşıyordu →
   `placeholder:` / `startPulseGlowAnimation`.

## Bilinçli kararlar

- **QRScanner ve PhotoViewer çağrı yeri olmadan duruyor.** CLAUDE.md'nin "ölü kod" maddesi
  bu yüzden netleştirildi: seed envanteri ölü kod değildir. Aksi halde bir sonraki ajan
  bunları temizlik sanıp silerdi.
- **PushNotificationManager'ın CoupleOS'taki sertleştirmeleri alınmadı** (device-install-id
  imza kısa devresi, 30 sn failure backoff). Bunlar `upsert_device_token` RPC tasarımına
  bağlı; seed v1'de bilinçli olarak token-PK'lı sade tasarım seçilmişti. Yarım taşımak
  yerine hiç taşınmadı.
- **`PaperView`/`DrawingToolbar` ve `CalendarMonthCell` elendi** — biri tek başına ürün
  kararı, diğeri domain kurallarına gömülü.

## Bilinen placeholder'lar

`SUPABASE_URL` / `SUPABASE_ANON_KEY` (xcconfig), Terms/Privacy URL'leri, App Group id
(`group.com.devno39.appseed` — `AppGroupStorage`, `PendingSharedItem`, `ShareLocalizable`
ve iki entitlements dosyasında; Renamer bunu değiştirmez, elle güncellenir),
FeedbackHelper endpoint/token, APNs env değişkenleri, `REVENUECAT_AUTH_HEADER`,
`TELEGRAM_BOT_TOKEN` / `TELEGRAM_CHANNEL_ID`.

## Üçüncü tur — yorum ve stil geçişi

Yeni ve değişen tüm dosyalardaki yorumlar tek tek okunup CLAUDE.md kuralına
("yalnız koddan görünmeyen tuzak, tek satır") göre yargılandı.

- 14 yorum iki-üç satırdan tek satıra indirildi; 3 tanesi tamamen kaldırıldı
  (`LabelPinAnnotationView` tip yorumu kodu tekrar ediyordu, `SceneDelegate`'teki
  iptal açıklaması tanım yerindekini tekrar ediyordu, Apple kimliği kaydı zaten
  Keychain anahtarının yorumunda anlatılıyordu).
- **Bayat yorum yakalandı:** `stopListening` içindeki "device-token temizliği çağıranda
  yapılır" notu, temizliği `signOut()`'a taşıdığım için artık yanlıştı — düzeltildi.
- `layoutSubviews` MARK'ı seed genelinde 7 dosyada `Life Cycle`, 1 dosyada `Layout`
  idi; `AvatarView` çoğunluğa hizalandı.
- Mekanik tarama (MARK sırası, `Draw` son extension, `make*` yasağı, dosya başlığı,
  TODO/FIXME, yorum satırına alınmış kod, 2 satırı aşan yorum) temiz. Tek istisna:
  `DateHelper` formatter cache ve `UserSessionManager` generation guard — ikisi de
  v1'den gelen, üç satırı hak eden yoğun tuzak notları, dokunulmadı.
- SQL/TS yorum yoğunluğu (%30-39) CoupleOS migration'ları (%21-52) ve v1 şablonları
  (%23-51) ile aynı aralıkta — ev stili korunuyor.

## Dördüncü tur — lock screen widget + SwiftLint

**Lock screen widget (mekanizma, örnek değil).** `DemoWidget` accessoryCircular +
accessoryRectangular ailelerini de karşılıyor: aynı provider, aynı snapshot, ayrı
`accessoryView`. Kritik olan üç şey kodda: vibrant render herhangi bir dolguyu gri
bloğa çevirdiği için container background accessory'de `Color.clear`, circular ailede
`AccessoryWidgetBackground()`, ve tint yok sayıldığı için görsel hiyerarşi yalnız
şekil + ağırlıkla kuruluyor. `LockedAccessoryWidgetView` böylece ilk kez ulaşılabilir
hâle geldi. Ayrı bir widget kind'ı açılmadı — lock screen farklı veri ya da farklı
yenileme temposu istemedikçe gereksiz.

**SwiftLint (0.65) kuruldu ve depo sıfır ihlale çekildi.** `.swiftlint.yml` sözleşmenin
makineyle denetlenebilir yarısını kodluyor; dört custom rule CLAUDE.md'den geliyor:
`make*` view fabrikası, yasak MARK adları (`Helpers`/`Factories`), `print(` yerine
`log(`, sabit kullanıcı metni. `Scripts/lint.sh` (+ `--fix`).

İlk koşuda 200+ ihlal çıktı; ayıklaması:

- **Gerçek sözleşme ihlalleri (3):** `AppGroupStorage`, `LargeTitleSectionHeader` ve
  `ExpandableAddField` içinde `// MARK: - Helpers` — CLAUDE.md bunu açıkça yasaklıyor.
  Linter olmasa görülmezdi.
- **Bayat TODO (2):** `BaseViewModel`'in boş `deinit`'inde "create a custom logger"
  yazıyordu; seed'in `log()`'u zaten var — `BaseViewController` ile aynı deinit log'una
  çevrildi. Falai şablonundaki TODO düz açıklamaya döndü.
- **Sahipsiz `swiftlint:enable`** — `UIDevice+Extension`'da eşleşen disable'ı olmayan
  bir satır duruyordu; seed'in bir zamanlar SwiftLint gördüğünün kalıntısı.
- **~150 mekanik ihlal** `--fix` ile temizlendi (trailing whitespace, virgül/parantez
  boşlukları, kullanılmayan closure parametreleri).
- **3 aşırı uzun satır** sarıldı (`BottomSheetAction.init` 229 karakterdi).
- **Yanlış alarmlar config'te kapatıldı:** `make*` kuralı yalnız `Scenes|Base/UI` yolunda
  çalışıyor (network request builder'larının `makeBody`'si meşru); sabit-metin kuralı
  string interpolation'ı dışlıyor; `function_parameter_count` 7'ye çekildi (router'ların
  altı sunum parametresi meşru); `line_length` ev stiline göre 180.
- **Meşru istisna:** `PaperBackgroundView`'daki `srand48(42)`/`drand48()` — tanenin
  yeniden çizimde titrememesi için tohumlanmış; `.random(in:)` tohumlanamıyor. Kural
  global kalıp o blokta gerekçesiyle kapatıldı.

## Beşinci tur — seed'in omurgası (Items + test target)

**Tespit:** seed'de bir ayarlar ekranı vardı ama Supabase'den koleksiyon çekip listeleyen,
ekleyen, silen, realtime dinleyen **tek bir feature örneği yoktu** — yani her app'in
çekirdek döngüsü. Golden file bir ayar ekranıydı.

**`Items` feature'ı** yığının en kısa tam yolu olarak eklendi: `007_items.sql` (owner RLS,
sunucu damgalı `updated_at`, realtime publication) → `SupabaseItemService` → `ItemsViewModel`
→ tablo + boş durum + swipe-delete + FAB → Form kütüphanesi üstünde `AddItemSheet`.
TabBar'da ikinci sekme, `appseed://items` deep-link host'u ile. CLAUDE.md artık iki golden
file tanımlıyor: Items (feature) ve Profile (ayar ekranı).

İki karar kodda kalıcı:
- **Dinleyici tek fetch yolu** — ilk sayfayı da o getiriyor, dolayısıyla ayrı yükleme çağrısı
  ve pull-to-refresh yok; realtime zaten refresh. Koleksiyon dinleyicisi her olayda yeniden
  çekiyor, satır deltası birleştirmiyor (insert/update/delete için ayrı merge gerekirdi).
- **Yazma önce yerelde, hatada geri alınır** — anlık UI'ı optimistic mutasyon veriyor,
  uzlaşmayı dinleyicinin refetch'i yapıyor; başarısız yazma completion'da geri alınıyor
  çünkü sunucu onu hiç görmedi, düzeltecek bir echo gelmeyecek.

**`OptimisticSync` bileşeni bilinçli olarak yapılmadı.** CoupleOS'taki 3-yönlü merge, tek
satırın içinde koleksiyon taşıyan bir modelin problemi; bağımsız satırlı normal bir tabloda
doğru çözüm çok daha basit. Onu Items'a zorlamak standartların yasakladığı spekülatif
soyutlama olur, üstelik yanlış dersi öğretirdi. Doküman-şekilli satır vakası
`docs/patterns/optimistic-realtime-sync.md`'de yazı olarak kalıyor.

**Tekrar kaldırıldı:** realtime tarih çözücü `SupabaseUserService` içinde gömülüydü; ikinci
servis onu kopyalamak zorunda kalacaktı. `SupabaseRealtimeDecoder` olarak ortaklaştırıldı
(Postgres mikrosaniye kesirleri `ISO8601DateFormatter`'ın okuyamadığı formatta — bu sınıfın
tek varlık sebebi).

**`AppSeedTests` target'ı** eklendi (unit-test bundle + TEST_HOST + iki paylaşımlı scheme'in
TestAction'ı) ve 28 saf mantık testi yazıldı: DateHelper tekrar hesapları (artık gün dahil),
review kapısı, LocalReminder trigger üretimi, ItemModel kolon eşlemesi, `Collection[safe:]`.
`Scripts/test.sh` ile koşuyor. Target'ın kendisi asıl kazanç — sonradan eklemek pbxproj
cerrahisi gerektiriyor.

**İlk koşuda gerçek bir hata çıktı:** `Optional.isNotEmpty` nil için `true` dönüyordu
(`!(self?.isEmpty ?? false)`). Canlı etkisi vardı — `RequestDALLE`/`RequestReplicate`
içinde `elements == nil` iken elements dalına giriyor ve çağıranın `prompt`'unu tamamen
yok sayıyordu. Düzeltildi, test kilitledi.

## Eklenmesi değerlendirilen, şimdilik eklenmeyenler

| Aday | Karar |
|---|---|
| **Test target** | Ne CoupleOS'ta ne AppSeed'de var. Agentic hedef için en değerli eksik: bir ajanın kendi işini doğrulayabilmesi için koşulabilir bir test hedefi gerekiyor. F6'ya bağlanmalı. |
| **SwiftLint** | Yok. CLAUDE.md'deki standartların bir kısmı (MARK sırası, `make*` yasağı) makine ile denetlenebilir; bu turda script'le elle yapıldı. F6 adayı. |
| **`LocationHelper`** | Dışarıda. CoupleOS sürümü SLC + partner paylaşımına gömülü; generic hâli konum gerektiren ilk uygulamada yazılmalı. |
| **Reachability / offline** | Yok. Supabase SDK socket'i kendi yeniden bağlıyor; ötesi uygulamaya özgü. |
| **Analytics olay katmanı** | Firebase Analytics linkli ama tipli bir olay sarmalayıcı yok. Olay isimleri uygulamaya özgü — şablon yazmak spekülatif olurdu. |
| **Debug/QA menüsü** | Yok. Faydalı ama seed'in çekirdeği değil. |

## Açık işler

- F6 — agentic katman (`.claude/skills`, CLI scene/service üretici, CLAUDE.md agent bölümü).
- `harvest/coupleos-v1` → `main` merge kararı hâlâ Tunay'da.
- SQL şablonları ve edge fonksiyonları **canlıda çalıştırılmadı** — ilk gerçek doğrulama
  bir sonraki uygulamanın Supabase projesinde olacak.
