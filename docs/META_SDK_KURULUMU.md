# Meta (Facebook) SDK — 1.0.10 (16)

4 Ekim 2026. Karar: DevEducation **13+ / veli odaklı** konumlanıyor ve
Meta uygulama yükleme reklamları için Facebook SDK ekleniyor.
Ayrıntılı gerekçe: `faith_pulse_ai/docs/21_...md` §7.5–7.6.

## Kodda yapılanlar

| Dosya | Değişiklik |
|---|---|
| `pubspec.yaml` | `facebook_app_events: ^0.30.5`, sürüm **1.0.10+16** |
| `lib/app_version.dart` | 1.0.10 / 16 |
| `lib/services/meta_install_service.dart` | Yeni. Yalnız iOS'ta çalışır. IDFA kapalı, izleme kapalı, otomatik olay kaydı açık, `activateApp()` |
| `lib/main.dart` | Servis, reklam servisinden sonra kendi try'ında başlatılıyor |
| `ios/Runner/Info.plist` | `CFBundleURLTypes` (fb1644718090391447), `FacebookAppID`, `FacebookClientToken` (**yer tutucu**), `FacebookDisplayName`, `FacebookAutoLogAppEventsEnabled=true`, `FacebookAdvertiserIDCollectionEnabled=false` |
| `test/meta_sdk_test.dart` | Yeni. App ID, URL şeması, IDFA kapalı, ATT yok; **client token yer tutucu kalırsa kırmızı** |
| `docs/privacy-policy.html` | Paylaşım tablosuna Google AdMob ve Meta eklendi; "hiçbiri pazarlama için kullanmaz" cümlesi düzeltildi |

Değişmeyenler, **bilerek**:

* ATT izni (`NSUserTrackingUsageDescription`) eklenmedi.
* AdMob'un çocuk güvenli ayarları (`tagForChildDirectedTreatment`,
  `maxAdContentRating: G`) yerinde. Temkinli taraf, dokunulmadı.
* Meta'nın SKAdNetwork kimlikleri (`v9wttpbfk9`, `n38lu8286q`) zaten
  listede vardı.

## Derlemeden önce senin yapacakların

1. **Client token.** developers.facebook.com → DevEducation → Uygulama
   ayarları → Gelişmiş → "İstemci tokeni". Değeri kopyala;
   `ios/Runner/Info.plist` içinde `META_CLIENT_TOKEN_BURAYA` yerine yapıştır.
2. Paketi kur ve testleri çalıştır:

       flutter pub get
       cd ios && pod install && cd ..
       flutter test

   `meta_sdk_test` ve `app_version_test` yeşil olmalı.
3. Her zamanki gibi derle ve yükle (Xcode Archive ya da `flutter build ipa`).

## App Store Connect (1.0.10 ile birlikte)

**Yaş derecelendirmesi.** App Information → Age Ratings. "Made for
Kids" / Kids kategorisi **seçili olmamalı**; şu an da değil, birincil
kategori Education. Anketi 13+ çıkacak şekilde güncelle.

**App Privacy.** Yeni veri türleri:

| Veri türü | Kullanım amacı | Kullanıcıya bağlı mı | İzleme için mi |
|---|---|---|---|
| Ürün etkileşimi (uygulama açılışı) | Üçüncü taraf reklamcılık, Analitik | Hayır | **Hayır** |
| Satın alma geçmişi | Üçüncü taraf reklamcılık, Analitik | Hayır | **Hayır** |
| Cihaz kimliği | Toplanmıyor (IDFA kapalı) | — | — |

"İzleme için mi" HAYIR olmalı. IDFA toplanmıyor, ATT yok; Meta ölçümü
SKAdNetwork / Toplu Olay Ölçümü ile yapıyor. Evet işaretlenirse Apple
ATT izni ister, o da bu sürümde yok ve geri çevrilir.

**Gizlilik politikası.** Güncellenen `docs/privacy-policy.html` dosyası,
GitHub Pages'teki `oguzhnkurt.github.io/devkom_App1/privacy-policy.html`
adresine yayınlanmalı. Mağazadaki link bu.

**Mağaza metni** (isteğe bağlı): "veliler ve 13 yaş üstü öğrenciler"
vurgusu.

## Meta tarafı

* Uygulama: DevEducation, App ID **1644718090391447**, portföy
  RoboAkademi. iOS platformu ve reklam hesabı bağlı.
* Uygulama Development modunda. Reklam için Live moda almak gerekebilir.
  Live mod gizlilik politikası URL'si ister; aynı link kullanılır.
* 1.0.10 yayına girip ilk açılışlar geldikten sonra, Ads Manager'da
  "DE - TR - Meta - Lansman Reel - App Install" taslağında
  "iOS 14+ kampanyası" açılabilecek. Reklama çıkma kararı ayrı.

## Gizlilik politikası — yayın (4 Ekim 2026)

* **Asıl adres:** https://www.devkom.com.tr/deveducation-privacy.html
  (devkom-website `public/`, commit a0e1c43, Vercel).
  "Hesabımı sil" bağlantısı GitHub Pages'teki delete-account.html'e
  mutlak adresle gidiyor.
* **Eski adres:** oguzhnkurt.github.io/devkom_App1/privacy-policy.html
  aynı içerikle güncellendi (commit f7a16e8). Bırakılabilir.
* **Uygulama içi link:** settings_screen.dart ve subscription_screen.dart
  yeni adrese çevrildi (1.0.10 ile çıkar).
* **App Store Connect:** Privacy Policy URL (Türkçe) yeni adrese
  çevrildi. Diğer diller (EN/DE/ES) ayrı ayrı kontrol edilmeli.
* Not: Yerel klasör `devkom_build` = GitHub'daki `devkom_App1` deposu
  (remote origin). `~/devkom_App1` klasörü boş, kullanılmıyor.
* App Store Connect Privacy Policy URL: TR/EN/DE/ES dördü de devkom.com.tr adresine çevrildi (1.0.10 ile çıkar).
