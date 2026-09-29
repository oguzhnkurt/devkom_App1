# Arayüz ikonları nereden geldi

Kaynak: satın alınan **DaCon Game Icon Generator v01** paketi
(İndirilenler klasöründeki zip). Paketten üç ikon alındı, 512 pikselden
kullanılacakları boyuta indirildi ve saydam kenarları kırpıldı.

| Dosya | Kaynak | Boyut | Nerede |
|---|---|---|---|
| `jeton.png` | `icn_coin1_512.png` (düzeltildi) | 184×192 | Oyunlar başlığındaki sayaç |
| `sandik.png` | `icn_chest_512.png` | 256×213 | Günün Görevi kartı |
| `tac.png` | `icn_crown_512.png` | 192×188 | Kilitli oyun kartındaki Pro rozeti |

## Jetonun üstündeki dolar işareti kaldırıldı

Paketteki madeni paranın yüzünde büyük bir **$** vardı. Uygulamadaki
jeton para değil, oyun içi puan; üstelik hedef kitle çocuk ve mağaza
kuralları çocuk uygulamalarında gerçek parayı çağrıştıran görsellerde
hassas. Bu yüzden yazı silinip yerine yıldız konuldu.

Nasıl: paranın yüzü halka halka taranıp her yarıçapta piksellerin
**açısal medyanı** alındı. Dolar işareti her halkanın yalnızca bir
bölümünü kapladığı için medyanda kayboluyor, altındaki altın gradyanı
kalıyor. Bu yeniden kurulan yüz sadece iç diskte kullanıldı (dışarıya
doğru yumuşak geçişle); paranın kenarı, kalınlığı ve parlaması
orijinalinden geliyor — yani 3B görünüş bozulmadı. Üstüne kabartma
hissi veren bir yıldız çizildi: altta koyu bir kopya, üstte açık altın,
en üstte hafif bir ışık.

## Neden sadece üç ikon

Pakette 16 ikon var (bomba, sohbet, hediye, mücevher, el...). Geri
kalanının bu ekranda bağlanacağı bir an yok; kullanılmayan görsel
uygulama paketine boşuna ağırlık katıyor. Yeni bir an çıkarsa paket
İndirilenler'de duruyor.

## Kullanılmayan diğer paket: OI 57

`game-assets-illustration` zip'i 16 tane RPG madalyası/arması içeriyor
(kılıçlı, boynuzlu, kristalli fantezi rozetleri). Oyun kartlarına
uymuyor — 6-12 yaş kodlama uygulamasının dili değil. Ama **rozet
koleksiyonu** ya da **avatar çerçevesi** için uygun olabilir; o iş
gündeme gelirse oradan bakılmalı.
