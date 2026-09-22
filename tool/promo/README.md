# Tanıtım videosu üreticisi

Dört MP4 üretir — Türkçe ve İngilizce × 9:16 (1080×1920) ve 1:1 (1080×1080),
her biri **27,8 saniye / 30 fps**, sesli. Instagram Reels, TikTok ve kare
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
| 0–3,0 | — | — | **açılış**: koyu lacivert zemin, ortada simge + DevEducation + slogan |
| 3,0–6,2 | ana sayfa | telefon | mor zemine geçiliyor, telefon dönerek geliyor |
| 6,2–9,4 | Scratch dersi | telefon | |
| 9,4–12,6 | blok kurma | telefon | |
| 12,6–15,8 | HTML kodu | telefon | |
| 15,8–23,8 | **8 oyun ekranı** | **çerçevesiz** | telefon çekiliyor, ekranlar tam tasarım çapraz geçiyor — kart başına 1 sn |
| 23,8–27,8 | — | — | **kapanış**: gökkuşağı + kod ekranı |

**Açılış** `tool/promo2/` ile aynı dili konuşuyor: siyaha yakın
lacivert, alttan mavi ışık, ortada simge + ad + slogan. Aradaki telefon
sahneleri kendi mor zeminini koruyor; geçiş 0,7 sn'lik bir çapraz geçiş
(`#appbg` opaklığı).

**Kapanış ayrı bir ekran** (`#finale`): dönen konik gökkuşağı, kod
yağmuru, aşağıdan yukarı süzülen renkli kod kartları, ortada gökkuşağı
degradeli **DevEducation** ve mağaza satırı. Oyun şeridinin son kartı
(Arduino Atölyesi) **biter bitmez** buraya geçiliyor; şerit sonda
sönmüyor, kapanışa çapraz geçiyor — eskiden arada telefon maketi bir an
geri geliyordu ve bu istenmiyordu.

Kapanıştaki kod kartlarında **Scratch blok adı yazılmıyor**: onlar
yalnızca resmî dil dosyalarından gelir (`tool/bloklar/`). Kartlar gerçek
kod satırları (`int x = 10;`, `digitalWrite(13, HIGH);`).

Kapanışın her şeyi `t`'nin saf fonksiyonu — rastgelelik sabit tohumlu
bir üreteçten (`rastgele()`), böylece aynı kare her koşuda aynı çıkıyor.

Eski daktilo açılışı ve sondaki "öğrenme yolu" telefon sahnesi
kaldırıldı.

Telefon her geçişte tam tur dönüyor; ekran dokusu turun ortasında, arka
yüz kameraya bakarken değişiyor. Oyun bölümündeki sekiz kart çapraz
geçişle birbirine karışıyor — geçiş penceresi kart süresinin **%30'unu
geçmiyor** (`XF = min(0.26, step * 0.3)`), böylece aralarda **boş kare
kalmıyor** (ilk sürümde kalıyordu) ve ghost'lanma da uzamıyor.

Zamanlamalar `render.html` başındaki `PHONE_DUR`, `GAMES_DUR`, `INTRO`,
`SPIN` sabitlerinde. `sfx.py` aynı sayıları tekrar tanımlıyor — **birini
değiştirirken diğerini de değiştirin**, yoksa ses kurguyla kayar.

Metinler `render.html` içindeki `COPY` sabitinde ve
`tool/store_slides.py` içindeki **mağaza slaytlarıyla aynı** — orada bir
kez denetlenmiş ifadeler. Yeni bir vaat eklenecekse önce slaytlara,
sonra buraya. App Store Kural 2.3.1: uydurma sayı, oran ya da ödül
yazılmaz.

## Ses — sıfırdan sentez, telifsiz

`sfx.py` sesi numpy ile üretiyor: açılışta yükselen yumuşak bir doku,
telefon gelirken ve her turda whoosh, oyun bölümüne geçişte bir whoosh
ve her oyun kartında blip, kapanışta çınlama, altta çok kısık bir bas
dokusu. **Klavye tıkı yok** — açılışta artık yazı yazılmıyor. Kapanışta
çınlamanın ardından üç ince parıltı, ad yerine otururken. **`GAME_COUNT` kart sayısıyla aynı olmalı**, yoksa blipler
kartlarla tutmaz.

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
video toplam ~40 dakika. GPU'lu bir makinede dakikalar sürer.

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
söylüyor (`g1_chess` ← `12_chess.png` gibi). Sekiz kart:

    g1_chess       g2_millionaire  g3_word_match  g4_matching
    g5_bug_hunter  g6_coordinates  g7_robot       g8_arduino

Hepsi widget testinin çıktısından geliyor ve **dile göre ayrışıyor**
(`ekranlar_tr/` ile `ekranlar/`). Bir tur bu atlandı: İngilizce videoya
Türkçe cihaz kayıtları konmuştu, videoda "Satranç Oyunu", "Bilgi
Yarışması", "Soru 1" yazıyordu.

Bir kart için

    outputs/promo/oyun/{tr,en}/g1_chess.png

varsa o kullanılıyor. Bu kapı cihazdan alınmış gerçek ekran kayıtları
için; ama **ya hepsine koyun ya hiçbirine**: cihaz kaydında iOS durum
çubuğu var, widget çıktısında yok, karışınca kartlar farklı yerden
gelmiş gibi duruyor. Görsel hiç yoksa kart atlanıyor, uyarı basılıyor
ve çapraz geçiş kalan kartlara bölünüyor.

### 4. Bağımlılıklar

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
