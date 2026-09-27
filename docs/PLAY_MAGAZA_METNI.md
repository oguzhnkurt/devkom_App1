# Google Play mağaza metinleri — dört dil

26 Eylül 2026. Bu dosya Play Console'a **elle yapıştırılacak** metinleri
tutar. App Store metinleri ayrı: `docs/MAGAZA_METNI.md`.

## App Store metninden farkları

Play sayfası Ağustos 2026'dan kalmıştı ve artık doğru olmayan şeyler
anlatıyordu. Değişenler:

- **Giydirilebilir ürünler ve beş karakter çıkarıldı.** Maskot tek bir 3B
  render (*Devi*) olunca şapka/gözlük/kolye/ayakkabı ve "karakterler"
  katalogdan kalktı, jetonlar iade edildi
  (`supabase/migrations/32_tek_maskot_ve_jeton_iadesi.sql`). Market'te
  artık **avatar çerçeveleri** satılıyor ve çerçeve profilde gerçekten
  görünüyor.
  > App Store açıklamasında bu paragraf **hâlâ eski hâliyle duruyor**
  > ("Beş karakterden biri seçiliyor… şapka, gözlük, ayakkabı alınıyor").
  > 1.0.9'da düzeltilmeli.
- **Reklam bölümü eklendi.** Ücretsiz sürümde reklam var; Play'de de
  söylenmesi gerekiyor.
- **Dil sayısı ikiden dörde çıktı** (eski metin "TÜRKÇE VE İNGİLİZCE"
  diyordu).
- **Abonelik koşulları Google Play diyor**, App Store değil.
- **Yaş aralığı yok.** Eski kısa açıklama "4-12 yaş çocuklar için…"
  diyordu. Hedef kitle beyanı olarak **karma kitle** seçildi
  (bkz. `claude/play-families-reklam-denetimi.md`); Play mağaza metniyle
  beyanın uyumlu olmasını bekliyor, o yüzden ürün yaşla değil seviyeyle
  anlatılıyor — App Store'daki çizginin aynısı.

## Doğrulanan sayılar

| İddia | Değer | Kaynak |
|---|---|---|
| Kurs | 9 | `lib/courses/data/courses_data.dart` → `allCourses` |
| Mini oyun | 16 | `EmbeddedGamesService.getAllEmbeddedGames()` |
| Quiz sorusu | 52 | `lib/courses/data/quizzes_data.dart` |
| Pro'nun açtığı oyun | 9 | `ProGames.lockedGameCount` |
| Arayüz dili | 4 | tr, en, de, es |

Puan, yıldız, yorum sayısı, ödül ya da kullanıcı sayısı iddiası **yok** —
App Store metinlerindeki kuralın aynısı burada da geçerli.

## Çıkıştan önce düzeltilmesi gereken kod hatası

`lib/screens/subscription_screen.dart` platform ayrımı yapmıyor.
Android'de ödeme ekranı şu an:

- *"ödeme **App Store** hesabından tahsil edilir"* diyor
- Kullanım Koşulları bağlantısı **Apple'ın standart EULA'sına** gidiyor

İkisi de Play'de yanlış. `Platform.isAndroid` dallanması ve Android için
ayrı koşul metni gerekiyor. **Play'e yüklemeden önce düzeltilmeli.**


## Türkçe (tr-TR)

**Uygulama adı** (27/30)

```
DevEducation: Kodlama Öğren
```

**Kısa açıklama** (76/80)

```
Renkli bloklarla başla, gerçek kod yaz. Scratch, Python, Arduino ve robotik.
```

**Tam açıklama** (2135/4000)

```
DevEducation renkli bloklarla başlar, gerçek kod yazarak biter.

Okuyarak değil, yaparak öğretiyor. Dokuz kurs sıfırdan başlayanı ilk renkli bloktan ilk gerçek kod satırına götürüyor. Her ders küçük adımlardan oluşuyor — bir bloğu sürükle, bir satırı düzelt, kodun ne yazdıracağını tahmin et — böylece uzun metin okumadan da ilerlenebiliyor.

📚 DERSLER
Dokuz kurs adım adım ilerleyen tek bir yol olarak dizili: Scratch ile sürükle-bırak bloklardan başlanıyor, mBlock ve Arduino ile gerçek karta geçiliyor, HTML, CSS, Python, Java ve C# ile gerçek kod yazılıyor.

🎮 OYUNLAR
On altı mini oyun aynı fikirleri başka bir yoldan çalıştırıyor: komutları sıraya dizmek, örüntü yakalamak, terim eşleştirmek, bir karakteri labirentten geçirmek, sanal bir Arduino devresi kurmak.

❓ QUİZLER
Derslerin ardından gelen 52 soru neyin akılda kaldığını ölçüyor ve her sorunun ardından açıklaması geliyor. Yanlış cevap puan kaybettirmiyor.

🪙 JETONLAR
Ders ve oyun tamamlandıkça jeton kazanılıyor, Market'te avatar çerçevelerine harcanıyor. Kazanılan çerçeve profil resminin etrafında gerçekten görünüyor.

👨‍👩‍👧 EBEVEYN KAPISI
Kapının arkasında ilerleme, haftalık hedef ve sertifikalar var. Uygulamanın kendi satın almaları ve dış bağlantıları bu kapıdan geçmeden açılmıyor.

📢 REKLAMLAR
Ücretsiz sürümde reklam gösteriliyor. Reklamlar kişiselleştirilmiyor: hedefleme yapılmıyor ve reklam kimliği kullanılmıyor. Ders ve oyun aralarında ara sıra tam ekran reklam çıkıyor; ilk derslerde hiç çıkmıyor, arka arkaya gelmiyor ve günlük bir sınırı var. Market'te istersen kısa bir video izleyip jeton kazanabilirsin.

🌍 DİLLER
Arayüz Türkçe, İngilizce, Almanca ve İspanyolca.

⭐ DEVEDUCATION PRO
Pro reklamları tamamen kaldırıyor, dokuz ek oyunu ve bütün kursları açıyor. Fiyatlar satın alma öncesinde uygulama içinde, kendi para biriminizde gösteriliyor. Abonelik otomatik yenilenir; dönem bitmeden en az 24 saat önce iptal edilmezse yenilenir ve ücret Google Play hesabınızdan tahsil edilir. Aboneliğinizi Google Play hesap ayarlarından yönetebilir veya iptal edebilirsiniz.

Gizlilik Politikası: https://oguzhnkurt.github.io/devkom_App1/privacy-policy.html
```


## İngilizce (en-US)

**Uygulama adı** (24/30)

```
DevEducation: Learn Code
```

**Kısa açıklama** (73/80)

```
Start with coloured blocks, end with real code. Scratch, Python, Arduino.
```

**Tam açıklama** (2101/4000)

```
DevEducation starts with coloured blocks and ends with real code.

It teaches by doing, not by reading. Nine courses take a complete beginner from the first coloured block to the first line of real code. Every lesson is made of small steps — drag a block, fix a line, predict what the code will print — so progress does not depend on reading long paragraphs.

📚 COURSES
Nine courses form a single path, step by step: start with drag-and-drop blocks in Scratch, move to a real board with mBlock and Arduino, then write real code in HTML, CSS, Python, Java and C#.

🎮 GAMES
Sixteen mini games practise the same ideas a different way: sequencing commands, spotting patterns, matching terms, steering a character through a maze, wiring a virtual Arduino circuit.

❓ QUIZZES
Fifty-two questions after the lessons check what stuck, with an explanation after every question. A wrong answer never costs points.

🪙 COINS
Finishing lessons and games earns coins, spent in the Store on avatar frames. The frame you buy really does appear around your profile picture.

👨‍👩‍👧 PARENT GATE
Behind the gate: progress, the weekly goal and certificates. The app's own purchases and external links are not reachable without passing it.

📢 ADS
The free version shows ads. They are never personalised: no targeting and no advertising identifier is used. A full-screen ad appears occasionally between lessons and games; never during the first lessons, never twice in a row, and with a daily limit. In the Store you can watch a short video for coins if you want to.

🌍 LANGUAGES
The interface is available in Turkish, English, German and Spanish.

⭐ DEVEDUCATION PRO
Pro removes the ads and unlocks nine further games and all courses. Prices are shown in the app, in your own currency, before you buy anything. The subscription renews automatically; unless it is cancelled at least 24 hours before the period ends, it renews and your Google Play account is charged. You can manage or cancel your subscription in your Google Play account settings.

Privacy Policy: https://oguzhnkurt.github.io/devkom_App1/privacy-policy.html
```


## Almanca (de-DE)

**Uygulama adı** (25/30)

```
DevEducation: Code lernen
```

**Kısa açıklama** (75/80)

```
Beginne mit bunten Blöcken, schreibe echten Code. Scratch, Python, Arduino.
```

**Tam açıklama** (2236/4000)

```
DevEducation beginnt mit bunten Blöcken und endet mit echtem Code.

Es lehrt durch Tun, nicht durch Lesen. Neun Kurse führen Anfängerinnen und Anfänger vom ersten bunten Block bis zur ersten Zeile echten Codes. Jede Lektion besteht aus kleinen Schritten — einen Block ziehen, eine Zeile korrigieren, vorhersagen, was der Code ausgibt — so hängt der Fortschritt nicht vom Lesen langer Texte ab.

📚 KURSE
Neun Kurse bilden einen einzigen Weg, Schritt für Schritt: Beginne mit Drag-and-drop-Blöcken in Scratch, wechsle mit mBlock und Arduino auf eine echte Platine und schreibe dann echten Code in HTML, CSS, Python, Java und C#.

🎮 SPIELE
Sechzehn Minispiele üben dieselben Ideen auf andere Weise: Befehle ordnen, Muster erkennen, Begriffe zuordnen, eine Figur durch ein Labyrinth steuern, eine virtuelle Arduino-Schaltung aufbauen.

❓ QUIZ
Zweiundfünfzig Fragen nach den Lektionen prüfen, was hängen geblieben ist, mit einer Erklärung nach jeder Frage. Eine falsche Antwort kostet nie Punkte.

🪙 MÜNZEN
Abgeschlossene Lektionen und Spiele bringen Münzen, die im Laden für Avatar-Rahmen ausgegeben werden. Der gekaufte Rahmen erscheint wirklich um das Profilbild.

👨‍👩‍👧 ELTERNSPERRE
Hinter der Sperre: Fortschritt, Wochenziel und Zertifikate. Die Käufe der App und externe Links sind ohne diese Sperre nicht erreichbar.

📢 WERBUNG
Die kostenlose Version zeigt Werbung. Sie wird nie personalisiert: kein Targeting, keine Werbe-ID. Zwischen Lektionen und Spielen erscheint gelegentlich eine Vollbildanzeige; nie in den ersten Lektionen, nie zweimal hintereinander und mit einem Tageslimit. Im Laden kannst du freiwillig ein kurzes Video für Münzen ansehen.

🌍 SPRACHEN
Die Oberfläche gibt es auf Türkisch, Englisch, Deutsch und Spanisch.

⭐ DEVEDUCATION PRO
Pro entfernt die Werbung und schaltet neun weitere Spiele sowie alle Kurse frei. Die Preise werden vor dem Kauf in der App in deiner eigenen Währung angezeigt. Das Abo verlängert sich automatisch; wird es nicht spätestens 24 Stunden vor Ablauf gekündigt, verlängert es sich und dein Google-Play-Konto wird belastet. Du kannst dein Abo in den Google-Play-Kontoeinstellungen verwalten oder kündigen.

Datenschutzerklärung: https://oguzhnkurt.github.io/devkom_App1/privacy-policy.html
```


## İspanyolca (es-ES)

**Uygulama adı** (28/30)

```
DevEducation: Aprende código
```

**Kısa açıklama** (63/80)

```
Empieza con bloques de colores y acaba escribiendo código real.
```

**Tam açıklama** (2311/4000)

```
DevEducation empieza con bloques de colores y termina escribiendo código real.

Enseña haciendo, no leyendo. Nueve cursos llevan a quien empieza desde cero desde el primer bloque de colores hasta la primera línea de código real. Cada lección está hecha de pasos pequeños — arrastra un bloque, corrige una línea, adivina qué imprimirá el código — para que avanzar no dependa de leer textos largos.

📚 CURSOS
Nueve cursos forman un único camino, paso a paso: empieza con bloques de arrastrar y soltar en Scratch, pasa a una placa real con mBlock y Arduino, y luego escribe código real en HTML, CSS, Python, Java y C#.

🎮 JUEGOS
Dieciséis minijuegos practican las mismas ideas de otra manera: ordenar comandos, detectar patrones, emparejar términos, guiar a un personaje por un laberinto, montar un circuito Arduino virtual.

❓ CUESTIONARIOS
Cincuenta y dos preguntas después de las lecciones comprueban qué se ha quedado, con una explicación tras cada pregunta. Una respuesta incorrecta nunca resta puntos.

🪙 MONEDAS
Terminar lecciones y juegos da monedas, que se gastan en la Tienda en marcos de avatar. El marco que compras aparece de verdad alrededor de tu foto de perfil.

👨‍👩‍👧 CONTROL PARENTAL
Detrás del control: el progreso, el objetivo semanal y los certificados. Las compras de la aplicación y los enlaces externos no se abren sin pasar por él.

📢 ANUNCIOS
La versión gratuita muestra anuncios. Nunca se personalizan: no hay segmentación ni se usa el identificador de publicidad. Entre lecciones y juegos aparece de vez en cuando un anuncio a pantalla completa; nunca en las primeras lecciones, nunca dos veces seguidas y con un límite diario. En la Tienda puedes ver un vídeo corto para ganar monedas si quieres.

🌍 IDIOMAS
La interfaz está disponible en turco, inglés, alemán y español.

⭐ DEVEDUCATION PRO
Pro elimina los anuncios y desbloquea nueve juegos más y todos los cursos. Los precios se muestran en la aplicación, en tu propia moneda, antes de comprar nada. La suscripción se renueva automáticamente; si no se cancela al menos 24 horas antes de que acabe el periodo, se renueva y se cobra en tu cuenta de Google Play. Puedes gestionar o cancelar tu suscripción en los ajustes de tu cuenta de Google Play.

Política de privacidad: https://oguzhnkurt.github.io/devkom_App1/privacy-policy.html
```
