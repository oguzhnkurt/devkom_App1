# Mac'teki Claude için devir notu

Bu dosyayı Mac'te Claude'a olduğu gibi yapıştır. Bağlam bu kadar.

---

## Görev

DevKom Flutter uygulamasının iOS sürümünü derleyip TestFlight'a göndermek.

## Proje

- Repo: https://github.com/oguzhnkurt/devkom_App1
- Bundle ID: `com.devkom.app`
- Apple Team ID: `YUXT7SYQ2K` (Individual üyelik, aktif)
- Sürüm: `1.0.1+5` (pubspec.yaml — App Store aynı build numarasını iki kez kabul etmez)

## Yapılacak

```bash
git clone https://github.com/oguzhnkurt/devkom_App1.git devkom_app   # veya: git pull
cd devkom_app
# >>> .env dosyasını buraya kopyala (aşağıya bak) <<<
bash scripts/ios_release.sh
```

`scripts/ios_release.sh` her şeyi sırayla yapar ve hata olursa durur:
ön kontroller → clean → pub get → pod install → **flutter analyze** → test → `flutter build ipa`.

Script bittiğinde arşiv `build/ios/archive/Runner.xcarchive` içinde olur.
Xcode → Window → Organizer → Distribute App → App Store Connect ile yüklenir.

## KRİTİK: .env dosyası

`.env` güvenlik nedeniyle git'e **dahil değil**, ama `pubspec.yaml` onu zorunlu
asset olarak listeliyor. Dosya yoksa build asset hatasıyla patlar.

Kullanıcının Windows makinesinde `C:\Users\Oguzhan\devkom_app\.env` mevcut.
Proje köküne `.env` adıyla kopyalanmalı. İçindeki anahtarlar:

```
GEMINI_API_KEY=...
ADAPTY_PUBLIC_KEY=...
MIXPANEL_TOKEN=...
```

Script bu dosyayı ilk adımda kontrol ediyor, yoksa açıklamayla duruyor.

## Bu sürümde ne değişti

- İki dilli (TR/EN) ders altyapısı: `interactive_lesson_model.dart` içindeki tüm
  adım tiplerine opsiyonel `...En` alanları eklendi. Hepsi nullable + TR'ye
  fallback — mevcut 66 dersin hiçbiri değişmedi.
- Ders ekranları dile duyarlı hale getirildi (`lessonLang(context)` helper'ı
  `step_widgets.dart` içinde).
- HTML kursu 3 → 10 ders, 2 → 6 modül, baştan sona TR+EN.
- Bilgi Yarışması soru bankası 72 → 108 soru (her seviyeye +3, TR+EN).
- `access_denied_screen.dart`: "Destek ile iletişim" butonu artık gerçekten
  `mailto:info@devkom.com.tr` açıyor (önceden "yakında" snackbar'ıydı).
- `ios/Podfile`: `platform :ios, '13.0'` satırı yorumdaydı, açıldı
  (Adapty ve flutter_sound iOS 13+ istiyor).

## Bilinmesi gerekenler

- **Bu kod hiç derlenmedi.** Windows tarafında Flutter SDK yoktu. Tüm doğrulama
  statik yapıldı (parantez dengesi, alan/metot isim eşleşmesi, içerik
  bütünlüğü). `flutter analyze` çıktısı ilk gerçek testtir — hata çıkarsa
  büyük ihtimalle bugün dokunulan şu dosyalardadır:
  - `lib/courses/models/interactive_lesson_model.dart`
  - `lib/courses/screens/widgets/step_widgets.dart`
  - `lib/courses/screens/interactive_course_screen.dart`
  - `lib/courses/screens/interactive_lesson_screen.dart`
  - `lib/courses/screens/scratch_course_screen.dart`
  - `lib/courses/data/html_lessons_data.dart`
  - `lib/services/millionaire_questions_service.dart`
  - `lib/screens/access_denied_screen.dart`
- `sign_in_with_apple` paketi kurulu ve `apple_sign_in_button.dart` widget'ı var
  ama **hiçbir ekranda gösterilmiyor** (ölü kod). Bu yüzden Sign in with Apple
  entitlement'ı eksik olması bu sürüm için sorun değil. İleride buton ekranlara
  eklenirse Xcode → Signing & Capabilities → + Sign in with Apple şart olacak.
- Firebase tamamen kaldırıldı, backend Supabase. `ios/Runner/GoogleService-Info.plist`
  hâlâ repoda duruyor ama kullanılmıyor (zararsız).
- Google Play tarafı ayrı: geliştirici hesabı (DevKom, ID 5407250162311337063)
  oluşturuldu ama Google kimlik doğrulamasını hâlâ inceliyor. Android yayını
  o onay gelene kadar bekliyor. Bu görev sadece iOS.

## Test edilecekler (build sonrası, cihazda)

1. Ayarlar → dili İngilizce yap → Dersler → HTML kursunu aç.
   Modül başlıkları, ders başlıkları ve soru metinleri İngilizce olmalı.
2. Dili Türkçe'ye geri al, aynı ekranlar Türkçe'ye dönmeli (yeniden başlatmadan).
3. Diğer kurslar (Python, Scratch, CSS, Java, C#, Arduino) İngilizce modda da
   **Türkçe** görünmeli — bu beklenen davranış, henüz çevrilmediler, fallback
   çalışıyor demektir.
4. HTML kursu son ders: "Final Proje: Kişisel Sayfa" adımı açılıyor mu.
5. Bilgi Yarışması birkaç kez oynanıp soruların tekrar etmediği görülmeli.
