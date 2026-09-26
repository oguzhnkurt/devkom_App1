# Tanıtım videosu — "Bloklardan gerçek koda" (Reels önce)

Üçüncü üretici. İlk ikisiyle aynı malzemeyi kullanıyor ama **kurgu
fikri farklı**: ürünün vaadini söylemek yerine **göstermek**.

    tool/promo3/run.sh
    # -> outputs/promo3/deveducation_blok_{tr,en}_{916,11}.mp4

**23,6 saniye / 30 fps**, sesli. TR/EN × 9:16 ve 1:1.

| | `tool/promo/` | `tool/promo2/` | `tool/promo3/` (bu) |
|---|---|---|---|
| açılış | marka bloğu | marka bloğu | **blok → kod dönüşümü** |
| kurgu | telefon turları | telefon + metin | dönüşüm → telefon → ritmik montaj |
| oyunlar | 1 sn çapraz geçiş | kayan şerit | **0,75 sn sert kesme, 80 BPM** |
| süre | 27,8 sn | 25,4 sn | **23,6 sn** |
| format | 9:16, 1:1 | 16:9, 9:16 | 9:16, 1:1 |

## Neden logo ile başlamıyor

Reels'te ilk saniye her şey; insanlar logo görünce kaydırıyor. Marka
sonda, ödülün olduğu yerde. Açılışta ürünün vaadi **gözle görünüyor**:
üç blok yerine oturuyor ve gerçek kod satırlarına dönüşüyor.

| sn | ne oluyor |
|---|---|
| 0–2,4 | Karanlıkta üç Scratch bloğu birbirine geçerek oturuyor. *"Bloklardan"* |
| 2,4–4,6 | Bloklar **tam durdukları yerde** HTML satırlarına dönüşüyor, arkalarında editör zemini beliriyor. *"gerçek koda."* |
| 4,6–7,6 | Kod telefonun ekranına giriyor — ekranda HTML dersi |
| 7,6–10,6 | Scratch dersi |
| 10,6–13,6 | Blok kurma |
| 13,6–19,6 | 8 oyun, ritmik montaj |
| 19,6–23,6 | Gökkuşağı + kod kapanışı |

Telefonun arkasında `tool/promo/` ile aynı hareketli 3B sahne var;
kapanış da aynı `#finale` katmanı.

## Bloklarda YAZI YOK — bilerek

Scratch/mBlock blok adları uydurulamaz; yalnızca resmî dil
dosyalarından gelir (`tool/bloklar/`). Bu yüzden açılıştaki bloklar
**şekil ve renk** olarak duruyor: üstte tırnak, altta çentik, içinde
soyut beyaz alan kutucukları. Tanınan siluet korunuyor, uydurma bir
etiket yazılmıyor.

Dönüştükleri kod uygulamanın **kendi HTML dersinin** satırları
(`<html>`, `<h1>Merhaba</h1>`, `</html>`) ve hemen ardından gelen
telefon ekranı aynı ders. Anlatı bu yüzden kapanıyor: az önce kurulan
şey, ekranda duran şey.

## Ritmik montaj

Oyun bölümünde uzun çapraz geçiş yok: kart başına **0,75 sn**, 0,12
sn'lik sert kesme, hafif punch-in (`scale 1.07 → 1.00`) ve küçük bir
eğim. Ses aynı ızgarada: her kesmede bir vuruş (80 BPM), araya kısık
bir hi-hat. Görüntüdeki kesme ile sesteki vuruş **aynı kareye**
düşüyor — `GAMES_DUR / 8` her iki dosyada da aynı.

## Ses

`sfx.py` numpy ile üretiyor. Açılışta her blok otururken tahta bir
"snap", dönüşümde aşağıdan yukarı tonal bir glide ve her kod satırında
yumuşak bir tuş, telefon sahnelerinde sahne başına tek malet notası,
oyunlarda vuruş ızgarası, kapanışta sıcak çınlama ve üç parıltı, altta
çok kısık bir akor.

**Geniş bantlı gürültü yok.** Önceki bir sürümde açılışta süzülmüş
gürültüden bir "bloom" vardı ve *"rüzgâr sesi gibi, itici"* bulundu.
Buradaki tek gürültü, oyun ızgarasındaki 50 ms'lik, çok kısık hi-hat.

Zamanlamalar `render.html`'deki `BLOK_DUR / MORPH_DUR / PHONE_DUR /
GAMES_DUR / OUTRO` sabitleriyle **aynı olmak zorunda**; `sfx.py` aynı
sayıları tekrar tanımlıyor.

> Sesi konteynerde dinleyemiyorum, yalnızca ölçebiliyorum. Bölümler
> arası denge eşitlendi (−16…−20 dB RMS). Yayına çıkmadan önce kulakla
> kontrol edilmeli.

## Hazırlık

Aynı malzeme: `tool/promo/README.md`'deki telefon modeli
(`outputs/promo/models/pro1.glb`) ve taze ekran görüntüleri
(`flutter test --run-skipped --tags shots test/appstore_shots_test.dart`).
Bağımlılıklar `tool/promo` ile ortak (`npm i playwright three`).

## ⚠️ App Store önizleme videosu DEĞİL

Apple ürün sayfasındaki app preview'larda yalnızca cihazdan kaydedilmiş
gerçek uygulama görüntüsü kabul ediyor; 3B maket reddedilir.

Kapanıştaki mağaza satırı `render.html` içindeki `STORES` sabitinden
geliyor. **Google Play listesi yayına girmeden `'both'` kullanılmamalı.**
