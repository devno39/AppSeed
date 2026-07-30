# Harvest Review — CoupleOS → AppSeed (2026-07-26)

Kapsam: `docs/harvest/2026-07-25-coupleos-harvest.md` planının tamamı (Faz 0-6) + 3 kalite pass'i. Yürütme: Opus subagent portları, Fable ana-oturum review kapıları. Tüm commit'ler build-yeşili; tarama yöntemleri: gerçek diff (satır-sayısı yön tayini YASAK — bir kez yanılttı), domain-leak grep, secret-scan, sim görsel test, scratch-copy smoke.

## Kapı sonuçları

| Kapı | Sonuç | Bulgular |
|---|---|---|
| 1 — Library | ✅ | Port sadakati birebir; hayalet UIComponents sync-group referansı yakalandı → `6b11710` |
| 2 — Supabase+Auth | ✅ | Auth zinciri header-only diff; domain sızıntısı sıfır |
| 3 — İskelet akış | ✅ | Sim görsel test: splash→tutorial→login rotaları doğru; splash koyu-tema kontrast notu → Faz 6'da fix |
| 4 — Terfi bileşenleri | ✅ | RingProgressView ana-oturumda satır satır okundu |
| 5 — Widget/Push | ✅ | Secret-scan temiz; 3 target birlikte yeşil; device_tokens token-PK iyileştirmesi onaylandı |
| 6 — Kapanış | ✅ | Renamer smoke: AppSeed→TestSeed tam rename + build exit 0, fix gerekmedi |

## Kalite pass'leri

1. **Warning + doküman gerçekliği** (`85e1348`, `43dfe6f`): tek own-code warning (`UIMenuController` → `UIEditMenuInteraction` gerçek migrasyonu); xcstrings 121 key × en+tr eksiksiz, sıfır orphan; kök README'de 2 yol hatası düzeltildi.
2. **Modifiye-port adversarial review** (`13055f9`): 7 riskli dosyadan 6'sı CLEAN. **1 gerçek bug:** sign-out'ta device-token silme `auth.signOut()` sonrasına düşüyordu → RLS anon reddi → çıkan cihaz eski kullanıcının push'larını almaya devam ederdi. Sıralama düzeltildi (`ProfileViewModel.logout` + `UserSessionManager.stopListening`). 5 yanlış-alarm gerekçeli reddedildi (parite barı).
3. **Template smoke** (`652c326`): 3 template'ten üretilen 12 dosya derlendi + kontrat kontrolü; tek ihlal — FormSheet router'ı `FormBottomSheetRouter`'dan türetilmeliydi, düzeltildi.

## Bilinen placeholder'lar (yeni projede doldurulacak)

`SUPABASE_URL`/`SUPABASE_ANON_KEY` (xcconfig), Terms/Privacy URL'leri (`Configuration`), App Group id (`group.com.devno39.appseed`), FeedbackHelper endpoint/token, APNs env değişkenleri (`supabase/functions/send-push`). RevenueCat: weekly plan yok (monthly/annual); paywall boş offering'de zarif düşer.

## Açık karar

`harvest/coupleos-v1` → `main` merge — Tunay'da.
