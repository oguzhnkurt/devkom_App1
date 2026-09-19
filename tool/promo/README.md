# Tanıtım videosu üreticisi

Dört MP4 üretir — Türkçe ve İngilizce × 9:16 (1080×1920) ve 1:1 (1080×1080),
her biri **23,6 saniye / 30 fps**, sesli. Instagram Reels, TikTok ve kare
reklam yerleşimleri için.

    tool/promo/run.sh
    # -> outputs/promo/deveducation_{tr,en}_{916,11}.mp4

## ⚠️ App Store önizleme videosu DEĞİL

Apple, ürün sayfasındaki app preview videolarında yalnızca **cihazdan
kaydedilmiş gerçek uygulama görüntüsü** kabul ediyor. Buradaki 3B telefon
maketi reddedilir. Bu dosyalar sosyal medya ve reklam içindir.

## Kurgu — iki ayrı anlatım dili, harmanlanmış

Uygulama ekranları 3B telefon maketinin içinde, **oyun ekranları
çerçevesiz tam tasarım** olarak geçiyor. Telefon oyun bölümünde küçülüp
siliniyor, kapanışta geri geliyor.

| sn | ekran | çerçeve | ne oluyor |
|---|---|---|---|
| 0–2,8 | — | — | başlık klavyeden yazılıyormuş gibi harf harf beliriyor |
| 2,8–6,0 | ana sayfa | telefon | telefon dönerek geliyor |
| 6,0–9,2 | Scratch dersi | telefon | |
| 9,2–12,4 | blok kurma | telefon | |
| 12,4–15,6 | HTML kodu | telefon | |
| 15,6–20,4 | 4 oyun ekranı | **çerçevesiz** | telefon çekiliyor, ekranlar tam tasarım çapraz geçiyor |
| 20,4–23,6 | öğrenme yolu | telefon | telefon geri geliyor, sonda logo |

Telefon her geçişte tam tur dönüyor; ekran dokusu turun ortasında, arka
yüz kameraya bakarken değişiyor. Oyun bölümündeki dört kart 0,35 sn'lik
çapraz geçişle birbirine karışıyor — geçiş penceresi kart süresinden
kısa olduğu için aralarda **boş kare kalmıyor** (ilk sürümde kalıyordu).

Zamanlamalar `render.html` başındaki `PHONE_DUR`, `GAMES_DUR`, `INTRO`,
`SPIN` sabitlerinde. `sfx.py` aynı sayıları tekrar tanımlıyor — **birini
değiştirirken diğerini de değiştirin**, yoksa ses kurguyla kayar.

Metinler `render.html` içindeki `COPY` sabitinde ve
`tool/store_slides.py` içindeki **mağaza slaytlarıyla aynı** — orada bir
kez denetlenmiş ifadeler. Yeni bir vaat eklenecekse önce slaytlara,
sonra buraya. App Store Kural 2.3.1: uydurma sayı, oran ya da ödül
yazılmaz.

## Ses — sıfırdan sentez, telifsiz

`sfx.py` sesi numpy ile üretiyor: yazının her harfinde klavye tıkı,
telefon gelirken ve her turda whoosh, oyun bölümüne geçişte bir whoosh
ve her oyun kartında blip, logoda çınlama, altta çok kısık bir bas
dokusu.

Şablonun `Read Me!.txt` dosyasındaki AudioJungle parçası (`abstract
glitch tech`) **ayrı lisanslı**; eğitim videosundan sökülüp
kullanılamaz. Lisans alınırsa sentez sesin yerine konabilir:

    ffmpeg -i video.mp4 -i muzik.mp3 -c:v copy -c:a aac -b:a 192k \
           -shortest muzikli.mp4

## Nasıl çalışıyor

After Effects yok. Sahne tarayıcıda kuruluyor:

1. `render.html` — three.js ile 3B telefon, arka plan, metin katmanları,
   üstte çerçevesiz oyun ekranları için ayrı bir DOM katmanı. Tek bir
   `__renderFrame(t)` fonksiyonu var; `t` saniye cinsinden.
2. `shoot.js` — headless Chromium'u sürer, her kare için `__renderFrame`
   çağırıp ekran görüntüsü alır.
3. `run.sh` — sahneyi kurar, sesi üretir, dört varyantı render eder,
   `ffmpeg` ile H.264 + AAC MP4'e çevirir.

GPU yoksa WebGL yazılımla (SwiftShader) koşar: kare başına ~0,5 sn, dört
video toplam ~25 dakika. GPU'lu bir makinede dakikalar sürer.

## Hazırlık

### 1. Telefon modeli

`outputs/promo/models/pro1.glb` gerekiyor. Satın alınan
*"Phone Mockup Opener — Clean 3D Mobile App UI/UX"* şablonunun içinden:

    Project folder/(Footage)/e74ada8c1538f44e/iphone_17_pro (1).glb

Model **depoya konmadı** — lisanslı stok varlık. `outputs/` zaten
`.gitignore`'da.

### 2. Ekran görüntüleri — TAZE olmalı

    flutter test --run-skipped --tags shots test/appstore_shots_test.dart

Bayat ekran görüntüsü sessizce yanlış bir video üretir. İlk denemede
ana sayfa hâlâ *"Karakterini giydir, jeton harca, yarış"* diyordu —
o vaat koddan kaldırılalı günler olmuştu (bkz. `market_vaatleri_test`).
Videoyu çekmeden önce görüntüleri yenileyin.

### 3. Oyun ekranları

`run.sh` içindeki `oyun` çağrıları hangi görselin hangi karta gittiğini
söylüyor (`g1_chess` ← `12_chess.png` gibi). Her kart için önce

    outputs/promo/oyun/{tr,en}/g1_chess.png

varsa o kullanılıyor — **cihazdan alınmış gerçek ekran görüntüsü tercih
edilir**, çünkü iOS durum çubuğu üstte duruyor ve çerçevesiz gösterimde
telefondan kaydedilmiş gibi görünüyor. Yoksa widget testinin çıktısına
düşüyor; o da yoksa kart atlanıyor ve uyarı basılıyor.

İngilizce tarafta **bilgi yarışmasının İngilizce ekran görüntüsü
henüz yok** (o ekran `appstore_shots_test.dart`'a eklendi ama test
çalıştırılmadı), o yüzden EN videosunda üç kart dönüyor: satranç,
kelime eşleştirme, eşleştirme. TR'de dört kart var. Kart sayısı
otomatik: yüklenemeyen görsel atlanıyor, çapraz geçiş kalanlara
bölünüyor.

### 4. Kapanıştaki mağaza satırı

`render.html` başında:

    const STORES = 'both';   // 'apple' | 'both'

`'both'` → *App Store ve Google Play'de* / *Available on the App Store
and Google Play*. `'apple'` → *App Store'da* / *On the App Store*.

**Google Play listesi yayına girmeden `'both'` kullanılmamalı.**
Yayındaki bir reklamda olmayan bir mağazayı söylemek yanlış beyan olur.
19 Eylül 2026 itibarıyla `play.google.com/store/apps/details?id=com.devkom.app`
404 dönüyordu.

### 5. Bağımlılıklar

    cd tool/promo && npm i playwright three
    npx playwright install chromium     # kendi Chromium'u yoksa
    # ffmpeg, python3, numpy, scipy PATH'te olmalı

## Ekranın 3B modele oturması — üç ayrı tuzak

### a) UV atlasın içinde ve 90° dönük

`render.html` şu ölçülen değerleri kullanıyor (`Object_33 / Screen_BG`):

    u 0.1849 .. 0.5240  ->  ekranın ALT .. ÜST kenarı
    v 0.4389 .. 0.6013  ->  ekranın SAĞ .. SOL kenarı

`texture.repeat/offset` bunu ifade edemiyor (dönme + ters yön), bu
yüzden dokunun `matrix`'i elle kuruluyor.

### b) Mesh çerçevenin altına uzanıyor

`Screen_BG` mesh'i, üstünü örten çerçevenin **altına** kadar gidiyor.
Görüntüyü mesh'in tamamına serince kenarlar çerçevenin altında kalıyor
ve ekran "taşmış" görünüyordu. Görünür açıklık, kenarlardan **0,096
dünya birimi** içeride. Bu sayı `BEZEL` sabiti.

Yeniden ölçmek için: `render.html?calib=1` — ekrana %0/2/4/6/8 içeride
renkli bantlar basan bir doku koyar ve telefonu düz tutar. Kırmızı
(en dıştaki) bant tam görünüyorsa `BEZEL` doğrudur.

### c) Dynamic Island yazıların üstüne biniyordu

Ekran görüntüleri widget testinden geliyor; güvenli alan boşluğu yok,
içerik y=0'dan başlıyor. Modelin Dynamic Island'ı ise ekranın üst
%5'ini örtüyor. Çözüm `padded()`: görüntü üstten 160 piksel
paylanıyor, bant görüntünün kendi ilk satırının rengiyle doluyor —
uygulamanın arka planının devamı gibi duruyor. Yanlardan da açıklık
oranını tutturacak kadar dolgu ekleniyor, böylece **hiçbir yerden
kırpma olmuyor**.

Başka bir `.glb` kullanılacaksa (a) ve (b) yeniden ölçülmeli.

## Renk — telefonun içi neden `MeshBasicMaterial`

İlk sürümde ekran PBR malzemeydi ve sahnede ACES tone mapping vardı;
uygulamanın renkleri "cansız" çıkıyordu. Ekran kendi ışığını veren bir
yüzey, ışık alan bir yüzey değil: `MeshBasicMaterial` +
`toneMapped: false` ile uygulamanın rengi birebir geçiyor. Cam parlaması
ayrı, toplanır (additive) bir dörtgenle ekleniyor.
