# Sesler nereden geldi, nasıl kırpıldı

Klasörde iki ayrı kaynak var ve ikisi bilerek bir arada:

## 1. Sentezlenmiş aile — `correct_*`, `wrong_*`, `complete_*`

Uygulama için üretilen yumuşak sinüs tonları (Do majör). Dört ton rengi:
`bright`, `warm`, `soft`, `deep`. Her oyun kendi rengini alıyor
(`SfxVoice`), böylece bütün oyunlar aynı sesi çalmıyor ama "bu
uygulamanın sesi" hissi bozulmuyor.

**Bu aile satın alınan kayıtlarla değiştirilemez:** pakette dört ayrı
"doğru" sesi yok, tek bir onay sesi var. Dördünü tek sesle
değiştirmek oyunları sesten ayırt edilemez hâle getirirdi.

## 2. Satın alınan paketten kırpılan gerçek kayıtlar

Kaynak: `mobile-game-app-pack` (kullanıcı tarafından satın alındı,
30 dosya = 15 ses × mp3 + wav). Kullanılan dokuzu:

| Uygulamadaki dosya | Paketteki kaynak | Süre | Nerede çalıyor |
|---|---|---|---|
| `tap.wav` | Application Button | 0,25 sn | Buton / kart dokunuşu |
| `drop.wav` | App Pop Up | 0,35 sn | Parça yerine oturunca |
| `dogru_cevap.wav` | App Confirm | 0,85 sn | Ders sorusu doğru |
| `odul.wav` | App Win | 1,80 sn | Ders bitti |
| `buyuk_basari.wav` | Big Band Achievement | 2,90 sn | Modül sınavı bitti |
| `ilk_basari.wav` | Big Band Celebration | 2,85 sn | Açılıştaki ilk görev |
| `jeton.wav` | Collect Gold | 1,30 sn | Görev ödülü, oyunda puan |
| `oyun_bitti.wav` | Cartoon Failure | 1,60 sn | Oyun bitti |
| `kilit_acildi.wav` | Dings | 0,55 sn | Reklam izlendi, ders açıldı |

Paketin kalan altı sesi (Application Confirm, Application Error,
App Success, Cartoon Drama, Donation Received, Failure) **alınmadı**:
ya elimizdekinin neredeyse aynısı (Application Confirm ile App Pop Up
aynı dosya boyutunda), ya da bağlanacak bir an yok. Kullanılmayan ses
pakete ağırlık katıyor; `sound_assets_test.dart` içindeki "her ses
dosyası servis tarafından çalınıyor" denetimi bunu kilitliyor.

## Kırpma ölçüleri

Her dosya tek kanal, 44.100 Hz, 16 bit PCM. Süre sesin **kaç kere
duyulduğuna** göre seçildi: her soruda çalan ses 1 saniyenin altında,
bir kere duyulan 3 saniyeye kadar. Kırpma noktası kulakla değil
zarfla belirlendi — 100 ms'lik pencerelerde RMS ölçülüp sesin
gövdesinin bittiği yer bulundu, sonuna kareli bir fade kondu (5 ms
giriş fade'i de var: örneğin ortasından başlayan bir dalga "tık"
sesi yapıyor).

Ses seviyesi: RMS **-18…-20 dB**, tepe **-1,5 dB** sınırında. Bu
aralık keyfî değil — sentezlenmiş ailenin RMS'i -12…-16 dB, gerçek
kayıtlar transient taşıdığı için aynı RMS'te kulağa daha yüksek
geliyor. İkisi yan yana çaldığında birinin diğerini bastırmaması
için kayıtlar bir tık altta tutuldu. `sound_assets_test.dart` bu
aralığı da denetliyor.
