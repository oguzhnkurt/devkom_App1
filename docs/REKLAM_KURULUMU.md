# Reklam kurulumu (AdMob)

Kod tarafı bitti. Uygulama **şu anda reklamsız çalışıyor**: gerçek
reklam birimi kimlikleri girilene kadar `AdsService` sessizce kapalı
kalıyor. Aşağıdaki adımlar tamamlanınca reklamlar açılıyor.

## Ne eklendi

| Dosya | İş |
|---|---|
| `lib/config/ad_config.dart` | Kimlikler ve sınırlar — tek kaynak |
| `lib/services/ads_service.dart` | Bütün reklamların tek kapısı |
| `lib/services/ad_navigator_observer.dart` | Geçiş reklamını ekran değişiminde gösteriyor |
| `lib/screens/market_screen.dart` | "Video izle, jeton kazan" şeridi |
| `lib/services/user_progress_service.dart` | Ders/oyun bitince reklamı *işaretliyor* |
| `lib/providers/auth_provider.dart` | Pro bayrağını servise veriyor |

## Kurallar (koda gömülü)

- **Pro üyeye hiç reklam yok.** Paywall'da "Reklamsız kullanım" yazıyor;
  bu bir vaat. Üç giriş noktası da önce Pro bayrağına bakıyor,
  `test/ads_service_test.dart` bunu kilitliyor.
- **Kişiselleştirme kapalı.** `tagForChildDirectedTreatment` +
  `tagForUnderAgeOfConsent` + `maxAdContentRating: G` ve her istekte
  `nonPersonalizedAds: true`. Reklam kimliği kullanılmadığı için **ATT
  izin ekranı gerekmiyor** ve App Privacy'de "takip" beyan edilmiyor.
- **Ödül dersten az.** Bir ders 8 jeton, reklam 5. Reklam izlemek ders
  yapmaktan kârlı olsaydı uygulamanın amacı tersine dönerdi.
- **Sıklık sınırı.** Günde en fazla 5 ödüllü video; geçiş reklamları
  arasında en az 4 dakika, günde en fazla 6 tane, ve yeni kullanıcı ilk
  3 ders/oyununda hiç reklam görmüyor.
- **Reklam kutlamanın üstüne binmiyor.** Ders/oyun bitişinde yalnızca
  işaret konuyor; reklam kullanıcı o ekrandan **çıkarken** açılıyor.
  Böylece çocuk "devam" düğmesine basarken reklama denk gelmiyor.

## Yapılacaklar (panel tarafı — benim yapamayacağım kısım)

1. **AdMob hesabı**: https://admob.google.com → uygulamayı ekle
   (iOS: `com.devkom.app`, Android ayrı kayıt).
2. Her platform için **iki reklam birimi** oluştur:
   - Ödüllü (Rewarded)
   - Geçiş (Interstitial)
3. AdMob > Uygulama ayarları'nda uygulamayı **"Çocuklara yönelik"**
   olarak işaretle.
4. **Uygulama kimliğini** (`ca-app-pub-...~...`) iki yere yaz:
   - `ios/Runner/Info.plist` → `GADApplicationIdentifier`
   - `android/app/src/main/AndroidManifest.xml` →
     `com.google.android.gms.ads.APPLICATION_ID`

   Şu an ikisinde de **Google'ın test kimliği** duruyor. Yayına
   çıkmadan değiştirilmezse gelir oluşmaz.
5. **Birim kimliklerini `.env`'e** yaz (depoya girmiyor):

   ```
   ADMOB_IOS_REWARDED=ca-app-pub-XXXX/YYYY
   ADMOB_IOS_INTERSTITIAL=ca-app-pub-XXXX/YYYY
   ADMOB_ANDROID_REWARDED=ca-app-pub-XXXX/YYYY
   ADMOB_ANDROID_INTERSTITIAL=ca-app-pub-XXXX/YYYY
   ```

   Bu değerler yalnızca **release** derlemesinde kullanılıyor; geliştirme
   ve testte her zaman Google'ın test reklamları geliyor. Gerçek
   reklamlara kendi cihazından tıklamak AdMob'da hesap kapatma sebebi.
6. `cd ios && pod install` (yeni bir yerel eklenti geldi).

## App Store Connect tarafı

- **App Privacy** bölümü güncellenmeli: üçüncü taraf reklam SDK'sı
  eklendi. Kişiselleştirme kapalı olduğu için **"Takip" (Tracking)
  işaretlenmiyor**; "Üçüncü Taraf Reklamcılık" verisi ise beyan
  edilmeli. Değişikliği yaparken AdMob'un kendi beyan tablosuna bak.
- Mağaza açıklaması güncellendi (`docs/MAGAZA_METNI.md`): ücretsiz
  sürümün reklamlı olduğu ve reklamların kişiselleştirilmediği yazıyor.
  Ayrıca "hiçbir dış bağlantı açılmıyor" cümlesi daraltıldı — reklama
  dokunan çocuk ebeveyn kapısından geçmeden dışarı çıkabiliyor.
  `test/ads_store_text_test.dart` bu iki şeyi kilitliyor.
- **1.0.7 şu anda incelemede.** Reklamlar 1.0.8'e kalıyor; sürüm
  numarası `pubspec.yaml` ve `lib/app_version.dart` içinde birlikte
  yükseltilmeli (`test/app_version_test.dart` ikisini karşılaştırıyor).

## Silinen ekran: Daily Maze

`lib/screens/games/maze_planet_game_screen.dart` **silindi**. Kataloğa
bağlı değildi — hiçbir yerden gidilmiyordu — ama içinde üç sorun vardı:

1. `onNavigationRequest` koşulsuz izin veriyordu: WebView içindeki
   herhangi bir bağlantıya (reklamın açılış sayfası, App Store, `tel:`)
   gidilebiliyordu. Ebeveyn kapısı yalnızca uygulamanın *kendi*
   bağlantılarını koruyor.
2. Sayfa 20 saniye boyunca her saniye `[class*="play"]` gibi çok geniş
   seçicilerle otomatik tıklanıyordu; bir reklam bağlantısına denk
   gelirse çocuk hiçbir şey yapmadan dışarı çıkabiliyordu.
3. Üçüncü tarafın (HTMLGames) reklamları JavaScript ile siliniyordu —
   kullanım şartlarına aykırı ve kendi AdMob reklamımızı gösterirken
   tutarsız.

Ayrıca `button:contains("Skip")` geçerli bir CSS seçici değil (jQuery
sözdizimi); o satır hiç çalışmamıştı, try/catch yutuyordu. Ekrandaki
"Reklam atlanıyor... 20" sayacı da reklam olsun olmasın her açılışta
gösteriliyordu.

`test/embedded_webview_safety_test.dart` artık dosyayı değil **kuralı**
koruyor: ileride gömülü bir web sayfası eklenirse gezinme denetimi ve
JavaScript enjeksiyonu yasağı zorunlu.

`webview_flutter` doğrudan bağımlılıktan çıkarıldı (tek kullanıcısı bu
ekrandı); paket yine de `google_mobile_ads` üzerinden geliyor.
