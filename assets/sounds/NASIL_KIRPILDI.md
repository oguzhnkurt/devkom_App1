# Sesler nereden geldi, nasıl kırpıldı

Klasörde iki ayrı kaynak var ve ikisi bilerek bir arada:

## 1. Sentezlenmiş aile — yalnızca `wrong_*`

Uygulama için üretilen yumuşak sinüs tonları (Do majör). Dört ton rengi:
`bright`, `warm`, `soft`, `deep`; her oyun kendi rengini alıyor
(`SfxVoice`).

`correct_*` ve `complete_*` de bu aileydi, **silindiler**. Gerekçe
kullanıcının ifadesiyle: "Sabah Rutini görevini başarıyla tamamlayınca
gelen ses çok itici… çok basit." Haklı bir itiraz — sentezlenmiş üçlü
sekiz bitlik bir oyuncak sesi gibi duruyordu ve bir turda onlarca kez
duyulduğu için kısa sürede yıpratıyordu. Yerlerini satın alınan
paketten kırpılmış gerçek kayıtlar aldı.

**Yanlış sesi neden hâlâ sentezlenmiş?** Paketteki başarısızlık
sesleri (Failure, Cartoon Failure) çizgi film tarzında ve
cezalandırıcı. 6-12 yaş için yumuşak, alçak bir "olmadı" tonu daha
doğru: yanlış denemek öğrenmenin parçası.

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
| `oyun_dogru.wav` | Application Confirm | 0,55 sn | Oyunda doğru cevap |
| `bolum_bitti.wav` | App Success | 1,40 sn | Oyunda seviye/bölüm bitti |
| `kilit_acildi.wav` | Dings | 0,55 sn | Reklam izlendi, ders açıldı |

Paketin kalan dört sesi (Application Error, Cartoon Drama,
Donation Received, Failure) **alınmadı**:
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

Ses seviyesi: RMS **-18…-22 dB**, tepe **-1,5 dB** sınırında. En
sık duyulan ses (`oyun_dogru`) en sessizi: -22 dB ve üstüne kodda
0,85 kısma. Bir tur boyunca onlarca kez çalan bir sesin yüksek
olması gerekmiyor, tersine. Bu
aralık keyfî değil — sentezlenmiş ailenin RMS'i -12…-16 dB, gerçek
kayıtlar transient taşıdığı için aynı RMS'te kulağa daha yüksek
geliyor. İkisi yan yana çaldığında birinin diğerini bastırmaması
için kayıtlar bir tık altta tutuldu. `sound_assets_test.dart` bu
aralığı da denetliyor.
