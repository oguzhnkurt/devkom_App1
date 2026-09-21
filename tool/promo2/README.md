# Tanıtım videosu — "App Promo" sürümü (koyu, 2B maket)

İkinci bir tanıtım videosu üreticisi. `tool/promo/` ile **aynı işi
farklı bir dille** yapıyor:

| | `tool/promo/` | `tool/promo2/` (bu) |
|---|---|---|
| kaynak şablon | *Phone Mockup Opener* | *App Promo* |
| telefon | **3B model** (three.js, GLB) | **2B maket PNG'leri**, perspektif |
| arka plan | mor/lacivert, üstten ışık | siyaha yakın lacivert, **alttan mavi ışık** |
| kurgu | telefon dönüyor, oyunlar çerçevesiz | telefon yanda, metin diğer yanda; oyunlar şerit hâlinde kayıyor |
| süre | 26,8 sn | **25,4 sn** |
| format | 9:16, 1:1 | **16:9**, 9:16 |
| ses | klavye tıkı, whoosh | pad, swish, hafif tık, sıcak çınlama |

16:9 olduğu için YouTube reklamı, web sitesi başlığı ve sunum için
uygun; ötekisi Reels/TikTok için.

    tool/promo2/run.sh
    # -> outputs/promo2/deveducation_promo_{tr,en}_{169,916}.mp4

## ⚠️ App Store önizleme videosu DEĞİL

Apple ürün sayfasındaki app preview'larda yalnızca cihazdan kaydedilmiş
gerçek uygulama görüntüsü kabul ediyor; maket reddedilir. Bu dosyalar
sosyal medya, reklam ve web için.

## Kurgu

| sn | ne |
|---|---|
| 0–3,0 | simge + **DevEducation** + "Bloklardan gerçek koda" |
| 3,0–6,4 | ana sayfa — *Kodlama ve robotik öğren* |
| 6,4–9,8 | Scratch dersi — *Scratch'i adım adım öğrenir* |
| 9,8–13,2 | blok kurma — *Blokları sürükleyip kodu kurar* |
| 13,2–16,6 | HTML kodu — *Sonra gerçek kodu kendi yazar* |
| 16,6–22,0 | **8 oyun ekranı** yan yana kayıyor — *Oyunla pekiştirir* |
| 22,0–25,4 | simge + **App Store ve Google Play'de** |

Metinler `tool/store_slides.py` içindeki onaylı mağaza metinleriyle
aynı. App Store Kural 2.3.1: uydurma sayı, oran ya da ödül yok.

Kapanıştaki mağaza satırı `render.html` içindeki `COPY.*.brand`
dizisinde. **Google Play listesi yayına girmeden "Google Play" yazmayın**
— yayındaki bir reklamda olmayan bir mağazayı söylemek yanlış beyan
olur (bkz. `tool/promo/README.md`).

## Ekranın maketin içine oturması

Şablon After Effects'te şunu yapıyor: `Phone Mockup Placeholder N.png`
ekranın **tam dörtgeni** (düz yeşil), `Phone Mockup N.png` ise çerçeve +
camın üstündeki parıltı. Biz aynı işi `mockup.py` ile yapıp **hazır PNG**
üretiyoruz; tarayıcıdaki sahne sadece o düz katmanı hareket ettiriyor —
AE'nin yaptığı da bu.

1. Placeholder'daki yeşil bölgeden ekranın dört köşesi bulunuyor
   (`cv2.approxPolyDP`, perspektifli).
2. Ekran görüntüsü o dörtgene perspektif dönüşümle seriliyor.
3. Placeholder'ın **kendi maskesi** uygulanıyor — köşeler yuvarlak.
4. Maketin yeşil bölgesi saydamlaştırılıp çerçeve üstte birleşiyor;
   yeşilin parlaklık değişimi cam parıltısı olarak toplamalı ekleniyor.

`uret.py` bunu her (maket, ekran, dil) üçlüsü için bir kez çalıştırıyor:
2 dil × (5 ekran + 8 oyun) = 26 PNG, ~40 saniye.

### Ekran görüntüsü önce düzeltiliyor (`hazirla`)

* **Üst bant.** Widget testinden gelen görüntüde güvenli alan boşluğu
  yok, içerik y=0'dan başlıyor; maketin Dynamic Island'ı üstü örtüyor.
  Görüntünün kendi ilk satırının rengiyle 150 piksellik bir bant
  ekleniyor.
* **Alt kırpma.** Yüzen sekme çubuğunun **altında** yarım kalmış metin
  kalıyor ("Bu derste ne öğreneceksin?" gibi). Küçültülünce çizgi çizgi
  bir şeride dönüşüyordu — 100 piksel kırpılıp arka plan rengiyle
  dolduruluyor.
* **Oran.** Kalan görüntü, maketin ekran dörtgeninin en/boy oranına
  **yanlardan dolguyla** getiriliyor; hiçbir yer kırpılmıyor, yazılar
  ezilmiyor.

## Hazırlık

### 1. Maket görselleri

`outputs/promo2/maket/` içine şablonun `(Footage)/Stuff [Don't Edit]/
Assets/Base Mockup/` klasöründen on dosya:

    Phone Mockup 1..5.png
    Phone Mockup Placeholder 1..5.png

Lisanslı stok varlık; **depoya konmadı** (`outputs/` zaten
`.gitignore`'da). Açılar: 1 = 3/4 sol, 2 = yatık, 3 = düz, 4 ve 5 =
hafif. Hangi sahnenin hangi maketi kullandığı `uret.py` içindeki
`SAHNE` listesinde.

### 2. Ekran görüntüleri — TAZE olmalı

    flutter test --run-skipped --tags shots test/appstore_shots_test.dart

### 3. Bağımlılıklar

    cd tool/promo2 && npm i playwright
    npx playwright install chromium
    # python3 + numpy, scipy, opencv-python, Pillow; ffmpeg

## Ses

`sfx.py` numpy ile üretiyor: altta sürekli koyu bir pad, her sahne
geçişinde yumuşak bir swish, oyun şeridinde sekiz hafif tık, kapanışta
sıcak bir çınlama. Klavye tıkı **yok** — bu sürümde yazı yazılmıyor.
Zamanlamalar `render.html`'deki `INTRO/SCENE/GAMES/OUTRO` ile aynı
olmalı; `sfx.py` aynı sayıları tekrar tanımlıyor.

Şablonun kendi müziği (varsa) ayrı lisanslı olabilir; sökülüp
kullanılmaz.

## Tuzak: mutlak konumlu flex şerit

Oyun şeridi `position:absolute` + `display:flex`. Genişlik verilmezse
kutu kapsayıcıya sığmaya çalışıyor ve sekiz telefonu eziyor — ilk
denemede şeritte 8 yerine 12 ince telefon görünüyordu. `width:max-content`
ve `flex:0 0 auto` şart.

## Hız

WebGL yok, her şey DOM: kare başına ~0,09 sn, dört video toplam
~4 dakika.
