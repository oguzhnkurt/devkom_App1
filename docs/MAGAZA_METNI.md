# App Store metinleri — dört dil

Sürüm 1.0.7 (11) · 9 Eylül 2026

Bu dosya App Store Connect'e **elle yapıştırılacak** metinleri tutar.
Uygulama adı, alt başlık ve açıklama App Store Connect'te dil dil
girilir; ikili (binary) içinde değildir. Ana ekrandaki ad
(`CFBundleDisplayName` / `android:label`) her ülkede **DevEducation**
olarak kalıyor — ana ekranda kısa isim daha iyi duruyor, uzun olan
mağazada arama için.

## Tek satış noktası

Bütün metinler ve bütün slaytlar **tek bir cümleyi** taşıyor:

> **Renkli bloklarla başlar, gerçek kod yazarak biter.**

Slayt başlıkları bu cümlenin parçaları, ayrı ayrı vaatler değil.
Açıklamanın ilk paragrafı da aynı cümleyle açılıyor. Bir kullanıcı
mağazada iki saniye harcıyor; o iki saniyede tek bir şey anlamalı.

### Beş slayt — birbirine bağlı

App Store Connect'e 9 Eylül 2026'da yüklenen sıra (tr ve en, 6.9 inç):

| # | Dosya | Başlık (tr) | Başlık (en) | Renk |
|---|---|---|---|---|
| 1 | `01_09_home` | **[Kodlama]** ve robotik öğren | Learn **[coding]** and robotics | Lavanta |
| 2 | `02_08_path` | **[Bloklardan]** gerçek koda | From **[blocks]** to real code | Gök mavisi |
| 3 | `03_07_matching` | **[Oyunla]** pekiştirir | Practises by **[playing]** | Nane |
| 4 | `04_02_lesson` | Scratch'i *adım adım* öğrenir | Learns Scratch *step by step* | Şeftali |
| 5 | `05_04_blocks` | Gerçek *Arduino*'yu programlar | Programs a real *Arduino* | Leylak |

Arka arkaya okunduğunda: *kodlama ve robotik öğrenir → bloklardan
gerçek koda geçer → oyunla pekiştirir → Scratch'i adım adım öğrenir →
gerçek Arduino'yu programlar.*

**Yükleme sırası önemli.** App Store Connect'e beş dosya birden
verilince sıra karışıyor (yükleme paralel bitiyor). Tek tek, aralarında
bekleyerek yüklenmeli — yoksa mağazada ilk görünen slayt yanlış oluyor.

### Görsel dil

Her slaytın kendi yumuşak zemini ve arkada büyük bulanık bir ışık
lekesi var. Beşi yan yana duracak; hepsi aynı zeminde olursa liste
tekdüze görünüyor.

**Başlığın bir kelimesi vurgulu.** `SLIDES` içinde `[köşeli parantez]`
o kelimeyi renkli kutuya alıp beyaz yazıyor, `*yıldız*` ise vurgu
renginde yazıyor. Düz tek renk başlık mağazada göze çarpmıyordu.

**Ekranın bir parçası telefonun dışına taşıyor.** Küçük ekranda gözden
kaçan detay — bir blok, renkli etiketler — büyütülmüş kart olarak
slaytın kenarından sarkıyor. Kart kaynağın tam üstüne oturmuyor;
dikeyde kaydırılıyor, yoksa telefonun içeriğini kapatıyor.

**Telefon eğik değil.** Bir denemede eğik ve perspektifliydi;
ekrandaki yazı da eğildiği için okunmuyordu. Mağazada ekran
görüntüsünün tek işi okunmak. Ekran görüntüsü de agresif
küçültülmüyor, yazılar net kalıyor.

**Başlık kimi slaytta üstte kimi altta** (`SLIDES` içindeki
`'ust'` / `'alt'`) — hepsi aynı kalıba oturursa liste tekdüze
görünüyor.

**Rozet ve puan yok — bilerek.** Örnek alınan tasarımlarda
"1M+ Learner", "JOIN 150,000+ PEOPLES", "#1 THERAPY EXPERIENCE" ve
yıldızlar var. Bizde yok ve konulmayacak: hiçbiri doğrulanabilir
değil. Puanlar gerçek deneyimden birikir; slaytta uydurulmaz
(Kural 2.3.1). Gerçek bir sayı ya da ödül olunca eklenir.

**Hap etiketler gerçek kurslar:** Scratch, Python, mBlock, Arduino,
HTML, C# — altısının da katalogda karşılığı var.
`test/appstore_slides_test.dart` bunu kontrol ediyor.

## Kural: uydurma yok

Ne metinlerde ne slaytlarda **puan, yıldız, yorum sayısı, ödül,
"1 numara" ya da "milyonlarca kullanıcı" iddiası var**. Puanlar ve
yorumlar gerçek deneyimden birikir; laf kalabalığıyla paketlenmez. Bu
tür hiçbir iddia — hiçbiri doğrulanabilir değil ve
App Store Kural 2.3.1 buna bakıyor. Sayılar koddan ve canlı veritabanından
doğrulandı (bkz. tablo).

| İddia | Değer | Kaynak |
|---|---|---|
| Kurs | 9 | `CoursesData.allCourses` |
| Mini oyun | 16 | oyun kataloğu |
| Pro'nun açtığı oyun | 9 | `ProGames.lockedGameCount` |
| Video serisi | 15 | Supabase `video_series` (aktif) |
| Quiz sorusu | 52 | `QuizzesData` |
| Arayüz dili | 4 | tr, en, de, es |

## KURAL: yaş ve "çocuklar için" yok

Uygulama App Store'da **Education** kategorisinde, **Kids Category'de
değil** (App Store Connect > App Information > Category: Education,
9 Eylül 2026'da doğrulandı).

1.0.5 sürümünde açıklamadaki *"4-12 yaş arası çocuklar için"* ifadesi
**Kural 5.1.4(b)** gerekçesiyle çıkarılmıştı. Apple, hedefi çocuklar
olan uygulamaların Kids Category'de olmasını istiyor; kategoride
değilken metinde çocuk hedefi belirtmek aynı gerekçeyle geri dönüyor.

Bu yüzden ad, alt başlık, açıklama, anahtar kelimeler **ve ekran
görüntüleri** (onlar da meta veri sayılıyor) yaş aralığı ya da
"çocuklar için" demiyor. Ürünü seviyeyle anlatıyoruz: *sıfırdan
başla*, *yeni başlayanlar için*, *yazmadan önce bloklarla*.

`test/appstore_slides_test.dart` slayt metnini bu kelimelere karşı
tarıyor — biri geri eklenirse testler düşüyor.

Kids Category'ye geçilirse bu bölüm ve altındaki metinler yeniden
yazılabilir; o kategorinin kendi kuralları var (üçüncü taraf içerik,
analitik, dış bağlantılar).

## KURAL: reklam anlatılırken ne söyleniyor

Uygulamada AdMob reklamları var (ödüllü video + ders/oyun sonu geçiş
reklamı). Bu üç şeyi mağaza metninde değiştiriyor:

1. **Açıklama reklamdan bahsetmek zorunda.** Ücretsiz sürümde reklam
   varken bunu söylememek App Store 2.3.1'e giriyor ve kullanıcı
   yorumlarında geri dönüyor. `test/ads_store_text_test.dart` bunu
   kilitliyor.
2. **"Hiçbir dış bağlantı açılmıyor" denemez.** Ebeveyn kapısı
   uygulamanın *kendi* satın almalarını ve bağlantılarını koruyor;
   bir reklama dokunan çocuk yine dışarı çıkabiliyor. Cümle
   "uygulamanın kendi satın almaları ve dış bağlantıları" diye
   daraltıldı.
3. **Pro'nun ilk vaadi artık reklamsızlık.** Paywall'da zaten
   "Reklamsız kullanım" yazıyordu ama uygulamada reklam yoktu; söz
   boştaydı. Şimdi karşılığı var.

Reklamlar `tagForChildDirectedTreatment` ve `maxAdContentRating: G`
ile kişiselleştirmesiz gidiyor. Bu yüzden App
Privacy'de "takip" (tracking) beyan **edilmiyor** ve `Info.plist`'e ATT
izin metni (`NSUserTrackingUsageDescription`) bilerek eklenmedi —
kullanılmayan bir izni istemek tek başına ret sebebi olabiliyor.

## Uygulama adı (en fazla 30 karakter)

Türkçe ad **değişmiyor** — 1.0.5'te onaylanan hâli kalıyor.

| Dil | Ad | Karakter |
|---|---|---|
| tr | `DevEducation: Kodlama Öğren` | 27 |
| en | `DevEducation: Learn Code` | 24 |

## Alt başlık (en fazla 30 karakter)

Türkçe alt başlık da **değişmiyor**.

| Dil | Alt başlık | Karakter |
|---|---|---|
| tr | `Sıfırdan kodlama ve robotik` | 27 |
| en | `Coding and robotics basics` | 26 |

## Açıklama

### tr

DevEducation renkli bloklarla başlar, gerçek kod yazarak biter.

Okuyarak değil, yaparak öğretiyor. Dokuz kurs sıfırdan başlayanı ilk
renkli bloktan ilk gerçek kod satırına götürüyor: Scratch, mBlock,
HTML, CSS, Python, Java, C#, Arduino ve robotik. Her ders küçük
adımlardan oluşuyor — bir bloğu sürükle, bir satırı düzelt, kodun ne
yazdıracağını tahmin et — böylece uzun metin okumadan da ilerlenebiliyor.

On altı mini oyun aynı fikirleri başka bir yoldan çalıştırıyor:
komutları sıraya dizmek, örüntü yakalamak, terim eşleştirmek, bir
karakteri labirentten geçirmek.

Derslerin ardından gelen quizler neyin akılda kaldığını ölçüyor; her
sorunun ardından açıklaması var. Yanlış cevap puan kaybettirmiyor.

Uygulamanın maskotu Devi yol boyunca eşlik ediyor. Öğrendikçe jeton
kazanılıyor; jetonlar avatar çerçevesi, profil afişi ve isim rozetine
harcanıyor.

Ebeveyn kapısının arkasında ilerleme, haftalık hedef ve sertifikalar
var. Uygulamanın kendi satın almaları ve dış bağlantıları bu kapıdan
geçmeden açılmıyor.

Ücretsiz sürümde reklam var. Reklamlar kişiselleştirilmiyor: hedefleme
yapılmıyor ve reklam kimliği kullanılmıyor.

Arayüz Türkçe, İngilizce, Almanca ve İspanyolca.

DevEducation Pro reklamları kaldırıyor, dokuz oyunu ve bütün kursları
açıyor. Fiyatlar satın alma öncesinde uygulama içinde, kendi para
biriminizde gösteriliyor.

### en

DevEducation starts with coloured blocks and ends with real code.

It teaches by doing, not by reading. Nine courses take a complete
beginner from the first coloured block to the first line of real code:
Scratch, mBlock, HTML, CSS, Python, Java, C#, Arduino and robotics.
Every lesson is made of small steps — drag a block, fix a line, predict
what the code will print — so progress does not depend on reading long
paragraphs.

Sixteen mini games practise the same ideas a different way: sequencing
commands, spotting patterns, matching terms, steering a character
through a maze.

Quizzes after the lessons check what stuck, with an explanation after
every question. A wrong answer never costs points.

Devi, the app's mascot, comes along for the ride. Learning earns coins,
and coins are spent on avatar frames, profile banners and name badges.

Behind a parent gate: progress, the weekly goal and certificates. The
app's own purchases and external links are not reachable without
passing that gate.

The free version shows ads. They are never personalised: no targeting
and no advertising identifier is used.

The interface is available in Turkish, English, German and Spanish.

DevEducation Pro removes the ads and unlocks nine further games and all
courses. Prices are shown in the app, in your own currency, before you
buy anything.

## Anahtar kelimeler (en fazla 100 karakter, virgülle)

| Dil | Anahtar kelimeler |
|---|---|
| tr | `kodlama,scratch,python,arduino,robotik,mblock,kod öğren,programlama` |
| en | `coding,scratch,python,arduino,robotics,mblock,learn to code,programming` |

`çocuklar için kodlama` ve `coding for kids` çıkarıldı — yukarıdaki
kurala giriyor.

## "What's New in This Version" — 1.0.9

1.0.8 (build 14) 27 Eylül 2026'da incelemeye gönderildi. Aşağıdaki metin
1.0.9 (build 15) içindir. 1.0.8'in notları git geçmişinde
(`a7a9b6c` ve sonrası).

**Pro'su biten kullanıcı söyleniyor.** Önceden aboneliği biten hesap
reklamsız kalıyordu (hata). Artık ücretsiz sürümün kuralları geçerli;
bunu sessizce değiştirmek sürprize ve düşük puana yol açar.

### tr

• mBlock kursuna Projeler modülü: Akvaryum Dünyası, Dans Partisi ve Elma
Toplama Oyunu. Her proje adım adım, bilgisayarındaki mBlock 5 ile
kuruluyor.

• mBlock derslerinde gerçek blok editörü: blokları sürükleyip kodu kendin
kuruyorsun. Kod uzayınca blok listesi kenara çekiliyor.

• Scratch kursuna dört yeni modül: kalemle çizim, işlemler, listeler ve
kendi bloğunu yapmak.

• Oyunlar ekranı yenilendi: günün görevi, raflar ve jeton/seri sayacın.

• Quiz ekranı renklendi: soruyu Devi soruyor, şıklar renkli kartlar.

• Doğru cevap, bölüm sonu ve ödül sesleri yenilendi.

• Market'teki "video izle, jeton kazan" seçeneği bazen görünmüyordu;
düzeltildi. Pro aboneliği sona eren hesaplarda ücretsiz sürüm (reklamlı)
artık doğru şekilde devreye giriyor.

• Hesap oluşturduktan sonra bazen çıkan hata ekranı giderildi.

• DevAI'de hazır bir soruya dokununca klavye kapanıyor, alt menü
kaybolmuyor.

• Almanca ve İspanyolca'da kalan Türkçe yazılar çevrildi.

• Performans iyileştirmeleri ve hata düzeltmeleri.

### en

• New Projects module in the mBlock course: Aquarium World, Dance Party and
Apple Catcher. Each project is built step by step in mBlock 5 on your
computer.

• A real block editor in the mBlock lessons: drag the blocks and build the
code yourself. When the code gets long, the block list slides aside.

• Four new modules in the Scratch course: drawing with the pen, operators,
lists and making your own blocks.

• The Games screen is new: today's mission, shelves and your coin/streak
counter.

• The quiz screen is more colourful: Devi asks the question and the
answers are colourful cards.

• New sounds for correct answers, finished chapters and rewards.

• The "watch a video, earn coins" option in the shop sometimes didn't
appear; fixed. Accounts whose Pro subscription has ended now correctly
get the free version (with ads).

• Fixed an error screen that sometimes appeared right after creating an
account.

• In DevAI, tapping a suggested question now closes the keyboard, so the
bottom menu stays visible.

• Remaining Turkish texts in German and Spanish have been translated.

• Performance improvements and bug fixes.

### de

• Neues Modul „Projekte“ im mBlock-Kurs: Aquarium-Welt, Tanzparty und
Äpfel fangen. Jedes Projekt entsteht Schritt für Schritt in mBlock 5 auf
deinem Computer.

• Ein echter Block-Editor in den mBlock-Lektionen: Blöcke ziehen und den
Code selbst bauen. Wird der Code lang, schiebt sich die Blockliste zur
Seite.

• Vier neue Module im Scratch-Kurs: Zeichnen mit dem Malstift,
Operatoren, Listen und eigene Blöcke.

• Der Spiele-Bildschirm ist neu: Tagesaufgabe, Regale und dein
Münz-/Serienzähler.

• Das Quiz ist bunter: Devi stellt die Frage, die Antworten sind farbige
Karten.

• Neue Klänge für richtige Antworten, beendete Kapitel und Belohnungen.

• Die Option „Video ansehen, Münzen verdienen“ im Shop fehlte manchmal;
behoben. Konten mit abgelaufenem Pro-Abo erhalten jetzt korrekt die
kostenlose Version (mit Werbung).

• Ein Fehlerbildschirm direkt nach dem Anlegen eines Kontos wurde
behoben.

• In DevAI schließt ein Tipp auf eine vorgeschlagene Frage jetzt die
Tastatur, das Menü unten bleibt sichtbar.

• Restliche türkische Texte auf Deutsch und Spanisch wurden übersetzt.

• Leistungsverbesserungen und Fehlerbehebungen.

### es

• Nuevo módulo Proyectos en el curso de mBlock: Mundo acuario, Fiesta de
baile y Atrapa manzanas. Cada proyecto se construye paso a paso en
mBlock 5 en tu ordenador.

• Un editor de bloques real en las lecciones de mBlock: arrastra los
bloques y arma el código tú mismo. Cuando el código crece, la lista de
bloques se aparta.

• Cuatro módulos nuevos en el curso de Scratch: dibujar con el lápiz,
operadores, listas y crear tus propios bloques.

• La pantalla de juegos es nueva: misión del día, estantes y tu contador
de monedas y racha.

• El cuestionario tiene más color: Devi hace la pregunta y las respuestas
son tarjetas de colores.

• Nuevos sonidos para respuestas correctas, capítulos terminados y
premios.

• La opción «ver un vídeo y ganar monedas» de la tienda a veces no
aparecía; corregido. Las cuentas cuya suscripción Pro ha terminado
reciben ahora correctamente la versión gratuita (con anuncios).

• Se corrigió una pantalla de error que a veces aparecía justo después
de crear una cuenta.

• En DevAI, al tocar una pregunta sugerida se cierra el teclado y el menú
inferior sigue visible.

• Se tradujeron los textos en turco que quedaban en alemán y español.

• Mejoras de rendimiento y corrección de errores.

## Ekran görüntüleri — iki adım

**1. Ham ekranlar** (gerçek Flutter motoru, 1290×2796 — Apple'ın 6.9 inç
boyutu):

```
flutter test --run-skipped --tags shots test/appstore_shots_test.dart
```

`outputs/appstore/ekranlar{,_tr,_de,_es}/`

**2. Başlıklı slaytlar:**

```
python3 tool/store_slides.py
```

`outputs/appstore/slaytlar_{tr,en,de,es}/` — App Store Connect'e
yüklenecek dosyalar bunlar.

Başlıklar `tool/store_slides.py` içindeki `SLIDES` listesinde; slayt
sırasını ya da metnini değiştirmek için tek düzenlenecek yer orası.
Araç her koşuşta çıktı klasörünü temizliyor — eski bir slaytın
mağazaya sızmaması için.

Ekran görüntüleri gerçek Flutter motoruyla çiziliyor, elde yapılmış
taklit değil: ekranda ne varsa slaytta o var. Quiz slaytı bir sık
seçilip ipucu açılarak çekiliyor, yani boş bir ekran değil çocuğun
içinde olduğu an gösteriliyor.

### Bu turda düzeltilen iki şey

1. **Maskotun repliği Almanca/İspanyolca slaytlarda Türkçe çıkıyordu.**
   Araçta `lang == 'en' ? İngilizce : Türkçe` ikilisi vardı; dört dile
   çıkınca Alman App Store'una Türkçe yazılı bir slayt gidecekti.
2. **Karakter slaytı hâlâ "Devi" gösteriyordu.** Uygulama çoktan beş
   karaktere (Puf/Mia/Bit/Kaşif/Bug) geçmiş, açılış karakteri Puf
   olmuştu. Ad ve alt yazı artık `MascotSpec`'ten okunuyor, elle
   yazılmıyor — karakter değişirse slayt kendiliğinden düzeliyor.
