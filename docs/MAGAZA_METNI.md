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
kazanılıyor; jetonlar avatar çerçevesi, profil afişi, rozet ve etikete
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
and coins are spent on avatar frames, profile banners, badges and labels.

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

## "What's New in This Version" — 1.0.11

1.0.10 (build 16) 4 Ekim 2026'da incelemeye gitti (Meta SDK, gizlilik
bağlantısı). Aşağıdaki metin **1.0.11 (build 17)** içindir. 1.0.9'un notları
git geçmişinde.

İçerik: oyun çevirileri (`bad3b6e`), oyun ekranlarının ortak başlık ve
zemini, açık zeminli ekranlarda görünmeyen başlık/geri tuşu düzeltmesi,
herkesin Scratch'ten başlaması, kurs sayfalarının dört dile çevrilmesi.

### tr

• Oyun ekranları yenilendi: her oyunun kendi renginde başlık, yumuşak zemin
ve renkli cevap kartları. Oyunlar sekmesi de renkli kartlarla yenilendi.

• Etkinlikler ve Kurslar ekranında görünmeyen geri tuşu ve başlık
düzeltildi.

• Öğrenme yolu artık herkes için Scratch ile başlıyor.

• Satranç: taşa dokununca gidebileceği kareler gösteriliyor. Oyun bitince tahta açık kalıyor, nasıl mat olduğunu görebiliyorsun. Kolay seviye artık gerçekten kolay, orta seviye daha dengeli.

• Bilgi Yarışması'nın soruları artık Almanca ve İspanyolca.

• Boru Bulmacası'nın skor satırı dört dilde.

• Arduino Atölyesi'nde başlangıç bloğu Türkçe: "Arduino Uno açılınca".

• Hata düzeltmeleri ve iyileştirmeler.

### en

• Refreshed game screens: each game has its own colorful header, a softer
background and colorful answer cards. The Games tab has new colorful cards too.

• Fixed the back button and title that were hard to see on the
Activities and Courses screens.

• The learning path now starts with Scratch for everyone.

• Chess: tap a piece to see where it can move. When the game ends the board stays visible, so you can see how the checkmate happened. Easy is now truly easy, and Medium is more balanced.

• Course pages (modules and lessons) are now fully in English.

• Knowledge Quiz questions are now in German and Spanish too.

• The Pipes Puzzle score bar now speaks all four languages.

• Fixes and improvements.

### de

• Neue Spielbildschirme: bunte Kopfzeile in der Farbe des Spiels, ein
sanfter Hintergrund und farbige Antwortkarten. Auch der Spiele-Tab zeigt neue bunte Karten.

• Zurück-Taste und Titel auf den Seiten Aktivitäten und Kurse sind wieder
gut sichtbar.

• Der Lernpfad beginnt jetzt für alle mit Scratch.

• Schach: Tippe auf eine Figur, um ihre möglichen Züge zu sehen. Nach der Partie bleibt das Brett sichtbar, so siehst du, wie das Matt entstand. Die leichte Stufe ist jetzt wirklich leicht, die mittlere ausgewogener.

• Kursseiten (Module und Lektionen) sind jetzt auf Deutsch.

• Die Fragen im Wissensquiz gibt es jetzt auf Deutsch.

• Die Anzeige im Rohr-Rätsel (Level, Punkte, Züge) ist jetzt auf Deutsch.

• Fehlerbehebungen und Verbesserungen.

### es

• Pantallas de juego renovadas: cada juego tiene su propia cabecera de
color, un fondo suave y tarjetas de respuesta de colores. La pestaña Juegos también estrena tarjetas de colores.

• Se corrigieron el botón de volver y el título que casi no se veían en
Actividades y Cursos.

• La ruta de aprendizaje ahora empieza con Scratch para todos.

• Ajedrez: toca una pieza para ver adónde puede moverse. Al terminar la partida el tablero sigue visible y puedes ver cómo fue el jaque mate. El nivel fácil ahora es fácil de verdad y el intermedio, más equilibrado.

• Las páginas de los cursos (módulos y lecciones) ya están en español.

• Las preguntas del concurso de conocimiento ya están en español.

• El marcador del rompecabezas de tuberías (nivel, puntos, movimientos)
ya está en español.

• Corrección de errores y mejoras.

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
