# goldie — App Store görselleri

[goldie](https://github.com/kacperkapusciak/goldie) uygulamayı bir iOS
simülatöründe gezip ekran görüntülerini ve önizleme videosunu üretiyor.
Görünen her şey iki yerde tanımlı ve ikisi de commit'leniyor:

- `goldie/goldie.config.ts` — hangi ekran, hangi sırada, hangi başlık,
  hangi zemin, mağaza metinleri
- `.argent/flows/store-*.yaml` — o ekranlara giden yol

`goldie/out/` üretilen çıktı; `.gitignore`'da.

## Çalıştırma

macOS + iOS simülatörü + `ffmpeg` gerekiyor.

```bash
cd ~/devkom_build

# 1) Simülatör build'i
flutter build ios --simulator

# 2) Her komut config yolunu ortam değişkeninden okuyor
export GOLDIE_CONFIG=$PWD/goldie/goldie.config.ts

npx -y goldie@0 doctor      # araçlar, simülatör, akışlar
npx -y goldie@0 capture     # akışları oynat, ham görüntüleri al
npx -y goldie@0 frame       # çerçeve + zemin + başlık
npx -y goldie@0 preview     # önizleme videosu
npx -y goldie@0 studio      # http://localhost:4321
```

Tek bir dili denemek için: `capture --locale tr-TR`.

## Simülatörde Release build yok

Bu deponun eski notu `flutter build ios --release --simulator` diyordu;
öyle bir şey yok. Flutter simülatör için AOT derlemiyor, hem
`--release` hem `--profile` *"not supported for simulators"* deyip
çıkıyor. Simülatörde tek seçenek debug build.

Sorun değil: endişe edilecek şey debug banner'ı olurdu, iki
`MaterialApp` da `debugShowCheckedModeBanner: false` veriyor
(`lib/main.dart:114` ve `:157`), ekranda banner yok. `goldie doctor`
bu build'i yine de "release build" diye etiketliyor — etiket
yanıltıcı, çıktı temiz.

## Akışlarda neden metin seçici yok

goldie aynı akışı dört yerel için ayrı ayrı oynatıyor ve boş kurulumda
cihaz dili uygulamaya geçiyor (`settings_provider.dart:92`). Yani
`text: Hesabım` seçicisi tr koşusunda bulunur, en/de/es koşusunda
bulunmaz. Arayüz düzeni dört dilde aynı olduğu için akışlar
**koordinat** kullanıyor; her koordinatın üstünde neyi hedeflediğini
söyleyen bir `echo` var, düzen değişirse yeniden çözmek için gereken
bilgi orada.

Klavyeyle yazı yazan adım da yok. Türkçe klavye `print` yerine `prınt`
yazıyor, argent'in `paste` aracı ise iOS'un "yapıştırmaya izin ver"
sistem uyarısını açıyor. Bu yüzden 4. slayt Python quiz'i yerine HTML
quiz'ini kullanıyor: HTML setinin ilk iki sorusu çoktan seçmeli ve
doğru/yanlış, kod sorusuna sadece dokunarak varılıyor.

## Her akış en baştan başlıyor

goldie her akıştan önce uygulamayı verisi silinmiş halde yeniden
kuruyor, yani her akış splash + 8 adımlık onboarding'i baştan geçiyor.
Ortak baş `.argent/flows/store-00-sablon.yaml` içinde belgeli. İlk
onboarding adımı **sürükleme** istiyor (iki bloğu birleştir); ileri ok
o adımda pasif, bloklar birleşince ekran kendiliğinden ilerliyor.

## Bilerek yapılmayanlar

- **Ödül rozeti yok.** goldie `theme.decorations` ile "Editors' Choice"
  gibi rozetler koyabiliyor. Bize öyle bir ödül verilmedi; uydurma
  rozet App Store Kural 2.3.1'e giriyor.
- **Puan yok.** `store.rating` yalnızca studio önizlemesinde görünüyor,
  mağazaya gitmiyor — yine de 0 bırakıldı: uygulama henüz yayında
  değil, gerçek bir puanı yok.
- **"Her sorudan sonra açıklama" iddiası kaldırıldı.** Quiz'de açıklama
  kendiliğinden çıkmıyor; "İpucu"na basılınca açılıyor
  (`quiz_screen.dart:149`) ve sonuç ekranında yalnızca yanlış cevaplar
  açıklanıyor (`:986`). Slayt metni buna göre düzeltildi.

## store_slides.py ile ilişkisi

`tool/store_slides.py` aynı işi Flutter test motorunda çizilen
ekranlarla yapıyordu. goldie gerçek simülatörden çektiği için artık
asıl kaynak bu; `store_slides.py` bırakılabilir.
