
import '../models/interactive_lesson_model.dart';
import 'mblock_palette.dart';

/// mBlock 5 kursu — editörü ve blokları sıfırdan öğreten dersler.
///
/// NEDEN AYRI BİR KURS
/// -------------------
/// Arduino kursu doğrudan devre kurmakla başlıyordu: çocuk mBlock'u hiç
/// tanımadan "şu bloğu sürükle" deniyordu. Ama mBlock'ta bir bloğu
/// sürüklemeden önce bilinmesi gereken şeyler var — cihaz mı kukla mı
/// seçili, yükleme modunda mı canlı modda mı, blok hangi kategoride.
/// Bu bilinmediğinde en sık yaşanan üç şey şu: aranan blok bulunamıyor,
/// blok gri görünüyor, ya da program yükleniyor ama hiçbir şey olmuyor.
///
/// Bu kurs önce EDİTÖRÜ, sonra PALETİ, sonra ilk programı öğretiyor;
/// ardından küçükten büyüğe projelerle ilerliyor.
///
/// BLOKLARIN KAYNAĞI
/// -----------------
/// Buradaki bütün blok etiketleri, renkleri ve şekilleri mBlock'un kendi
/// Arduino Uno cihaz paketinden ve Türkçe dil dosyasından alındı
/// (bkz. `mblock_palette.dart`). Uydurulmadı, çevrilmedi. Çocuk mBlock'u
/// açtığında bloğu birebir aynı halde bulacak.
class MBlockLessonsData {
  // ==========================================
  // MODÜL 1 — mBLOCK NEDİR, NEREDE NE VAR
  // ==========================================

  static final List<InteractiveLesson> module1 = [
    // ---------------------------------------------------------- Ders 1.1
    InteractiveLesson(
      id: 'mblock_1_1',
      courseId: 'mblock',
      title: 'mBlock Nedir?',
      subtitle: 'Blokları gerçek bir karta gönderen editör',
      titleEn: 'What Is mBlock?',
      titleDe: 'Was ist mBlock?',
      titleEs: '¿Qué es mBlock?',
      subtitleEn: 'The editor that sends blocks to a real board',
      subtitleDe: 'Der Editor, der Blöcke auf eine echte Platine schickt',
      subtitleEs: 'El editor que envía bloques a una placa real',
      order: 1,
      xpReward: 40,
      badge: 'mblock_starter',
      steps: [
        IntroStep(
          id: 'm1_1_intro',
          mascotEmoji: '🧩',
          mascotMessage:
              'mBlock, Scratch\'e çok benzeyen bir program. Ama bir farkı '
              'var: burada kurduğun bloklar ekrandaki bir kediyi değil, '
              'masandaki gerçek bir kartı çalıştırıyor. LED yanıyor, '
              'buzzer ötüyor, motor dönüyor.',
          mascotMessageEn:
              'mBlock looks a lot like Scratch. With one difference: the '
              'blocks you snap together do not move a cat on the screen — '
              'they run a real board on your desk. An LED lights up, a '
              'buzzer sounds, a motor turns.',
          mascotMessageDe: 'mBlock sieht Scratch sehr ähnlich. Mit einem Unterschied: Die Blöcke, die du zusammensteckst, bewegen keine Katze auf dem Bildschirm – sie lassen eine echte Platine auf deinem Tisch laufen. Eine LED leuchtet, ein Summer piept, ein Motor dreht sich.',
          mascotMessageEs: 'mBlock se parece mucho a Scratch. Con una diferencia: los bloques que encajas no mueven un gato en la pantalla, hacen funcionar una placa real sobre tu mesa. Se enciende un LED, suena un zumbador, gira un motor.',
          highlights: [
            'Scratch gibi sürükle-bırak',
            'Gerçek karta yükleniyor',
            'Tek satır kod yazmadan',
          ],
          highlightsEn: [
            'Drag and drop, just like Scratch',
            'Uploads to a real board',
            'Without typing a single line of code',
          ],
          highlightsDe: [
            'Ziehen und ablegen, genau wie in Scratch',
            'Wird auf eine echte Platine geladen',
            'Ohne eine einzige Zeile Code zu tippen',
          ],
          highlightsEs: [
            'Arrastrar y soltar, igual que en Scratch',
            'Se sube a una placa real',
            'Sin escribir ni una línea de código',
          ],
        ),

        ExplanationStep(
          id: 'm1_1_exp1',
          title: 'mBlock ile Scratch\'in Farkı',
          titleEn: 'How mBlock Differs from Scratch',
          titleDe: 'Worin sich mBlock von Scratch unterscheidet',
          titleEs: 'En qué se diferencia mBlock de Scratch',
          content:
              'Scratch\'te program ekrandaki kuklayı hareket ettirir. '
              'mBlock\'ta program bir KARTA yüklenir ve kart bilgisayardan '
              'ayrılsa bile çalışmaya devam eder.\n\n'
              'Yani Scratch\'te yaptığın şey bilgisayarın içinde kalır; '
              'mBlock\'ta yaptığın şey elinde tuttuğun bir cihaz olur. '
              'Pili tak, masaya koy, çalışır.',
          contentEn:
              'In Scratch, your program moves a sprite on the screen. In '
              'mBlock, your program is uploaded to a BOARD, and the board '
              'keeps running even when you unplug it from the computer.\n\n'
              'What you make in Scratch stays inside the computer. What you '
              'make in mBlock becomes a device you can hold.',
          contentDe: 'In Scratch bewegt dein Programm eine Figur auf dem Bildschirm. In mBlock wird dein Programm auf eine PLATINE hochgeladen, und die Platine läuft weiter, auch wenn du sie vom Computer trennst.\n\nWas du in Scratch machst, bleibt im Computer. Was du in mBlock machst, wird zu einem Gerät, das du in die Hand nehmen kannst.',
          contentEs: 'En Scratch tu programa mueve un objeto en la pantalla. En mBlock tu programa se sube a una PLACA, y la placa sigue funcionando aunque la desconectes del ordenador.\n\nLo que haces en Scratch se queda dentro del ordenador. Lo que haces en mBlock se convierte en un aparato que puedes sostener.',
          tipEmoji: '💡',
          tip: 'mBlock 5, Scratch 3.0\'ın üzerine kurulmuş. Bu yüzden '
              'bloklar tanıdık geliyor.',
          tipEn: 'mBlock 5 is built on top of Scratch 3.0. That is why the '
              'blocks look familiar.',
          tipDe: 'mBlock 5 baut auf Scratch 3.0 auf. Deshalb kommen dir die Blöcke bekannt vor.',
          tipEs: 'mBlock 5 está construido sobre Scratch 3.0. Por eso los bloques te resultan familiares.',
        ),

        ExplanationStep(
          id: 'm1_1_exp2',
          title: 'Cihaz mı, Kukla mı?',
          titleEn: 'Device or Sprite?',
          titleDe: 'Gerät oder Figur?',
          titleEs: '¿Dispositivo u objeto?',
          content:
              'mBlock ekranının solunda iki sekme var: CİHAZ ve KUKLA.\n\n'
              'Cihaz sekmesi → Arduino kartın. Buradaki bloklar pinleri, '
              'sensörleri kontrol eder.\n'
              'Kukla sekmesi → ekrandaki karakter. Buradaki bloklar '
              'Scratch\'teki gibi çizim ve animasyon yapar.\n\n'
              'Aradığın bloğu bulamıyorsan sebep neredeyse her zaman '
              'budur: yanlış sekmedesin. Pin bloklarını kukla sekmesinde '
              'arayamazsın, orada yoklar.',
          contentEn:
              'On the left of the mBlock window there are two tabs: DEVICE '
              'and SPRITE.\n\n'
              'Device tab → your Arduino board. These blocks control pins '
              'and sensors.\n'
              'Sprite tab → the character on the screen. These are the '
              'Scratch blocks for drawing and animation.\n\n'
              'If you cannot find a block, this is almost always why: you '
              'are on the wrong tab.',
          contentDe: 'Links im mBlock-Fenster gibt es zwei Reiter: GERÄT und FIGUR.\n\nReiter Gerät → deine Arduino-Platine. Diese Blöcke steuern Pins und Sensoren.\nReiter Figur → die Figur auf dem Bildschirm. Das sind die Scratch-Blöcke zum Zeichnen und Animieren.\n\nWenn du einen Block nicht findest, liegt es fast immer daran: Du bist im falschen Reiter.',
          contentEs: 'A la izquierda de la ventana de mBlock hay dos pestañas: DISPOSITIVO y OBJETO.\n\nPestaña Dispositivo → tu placa Arduino. Estos bloques controlan pines y sensores.\nPestaña Objeto → el personaje de la pantalla. Son los bloques de Scratch para dibujar y animar.\n\nSi no encuentras un bloque, casi siempre es por esto: estás en la pestaña equivocada.',
          tipEmoji: '🔍',
          tip: 'Arduino kartını seçtiğinde Hareket, Görünüm, Ses ve '
              'Algılama kategorileri KAYBOLUR. Onlar kuklaya ait.',
          tipEn: 'When you select the Arduino board, the Motion, Looks, '
              'Sound and Sensing categories disappear. They belong to the '
              'sprite.',
          tipDe: 'Wenn du die Arduino-Platine auswählst, verschwinden die Kategorien Bewegung, Aussehen, Klang und Fühlen. Sie gehören zur Figur.',
          tipEs: 'Cuando seleccionas la placa Arduino, desaparecen las categorías Movimiento, Apariencia, Sonido y Sensores. Pertenecen al objeto.',
        ),

        MultipleChoiceStep(
          id: 'm1_1_q1',
          question: 'LED yakmak için gereken blok hangi sekmede?',
          questionEn: 'Which tab has the block for lighting an LED?',
          questionDe: 'In welchem Reiter liegt der Block, mit dem eine LED leuchtet?',
          questionEs: '¿En qué pestaña está el bloque para encender un LED?',
          options: [
            ChoiceOption(text: 'Cihaz sekmesi', textEn: 'The Device tab', textDe: 'Der Reiter Gerät', textEs: 'La pestaña Dispositivo'),
            ChoiceOption(text: 'Kukla sekmesi', textEn: 'The Sprite tab', textDe: 'Der Reiter Figur', textEs: 'La pestaña Objeto'),
            ChoiceOption(text: 'İkisinde de var', textEn: 'Both of them', textDe: 'Beide', textEs: 'Los dos'),
            ChoiceOption(text: 'Sahne sekmesi', textEn: 'The Stage tab', textDe: 'Der Reiter Bühne', textEs: 'La pestaña Escenario'),
          ],
          correctIndex: 0,
          explanation:
              'Pin blokları yalnızca cihaz sekmesinde. Kukla sekmesinde '
              'Arduino\'yla ilgili hiçbir blok yok.',
          explanationEn:
              'Pin blocks live only on the Device tab. The Sprite tab has '
              'no Arduino blocks at all.',
          explanationDe: 'Pin-Blöcke gibt es nur im Reiter Gerät. Im Reiter Figur gibt es überhaupt keine Arduino-Blöcke.',
          explanationEs: 'Los bloques de Pin solo están en la pestaña Dispositivo. La pestaña Objeto no tiene ningún bloque de Arduino.',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'm1_1_exp3',
          title: 'Yükleme Modu ve Canlı Mod',
          titleEn: 'Upload Mode and Live Mode',
          titleDe: 'Upload-Modus und Live-Modus',
          titleEs: 'Modo de subida y modo en vivo',
          content:
              'mBlock\'un iki çalışma modu var ve hangi blokların '
              'kullanılabildiğini bu belirliyor.\n\n'
              'YÜKLEME MODU (Yükleme modu): Program karta yazılır. Kabloyu '
              'çıkarsan bile çalışır. Bizim kullanacağımız mod bu.\n\n'
              'CANLI MOD (Canlı mod): Kart bilgisayara bağlı kalır, '
              'komutlar anında gider. Kablo çıkınca her şey durur.\n\n'
              'Bu ayrım önemli çünkü bazı bloklar sadece bir modda '
              'çalışıyor. Buzzer, mesafe sensörü ve seri port blokları '
              'canlı modda GRİ görünür — çalışmazlar. Yeşil bayrak ve '
              'mesaj yayınlama blokları ise yükleme modunda gri olur.',
          contentEn:
              'mBlock has two modes, and they decide which blocks you can '
              'use.\n\n'
              'UPLOAD MODE: the program is written into the board. It runs '
              'even when you unplug the cable. This is the mode we use.\n\n'
              'LIVE MODE: the board stays connected and commands go across '
              'instantly. Unplug the cable and everything stops.\n\n'
              'This matters because some blocks only work in one mode. The '
              'buzzer, distance sensor and serial blocks are GREYED OUT in '
              'live mode. The green flag and broadcast blocks are greyed '
              'out in upload mode.',
          contentDe: 'mBlock hat zwei Modi, und sie entscheiden, welche Blöcke du benutzen kannst.\n\nUPLOAD-MODUS: Das Programm wird in die Platine geschrieben. Es läuft auch, wenn du das Kabel abziehst. Diesen Modus benutzen wir.\n\nLIVE-MODUS: Die Platine bleibt verbunden und die Befehle gehen sofort hinüber. Ziehst du das Kabel ab, hört alles auf.\n\nDas ist wichtig, weil manche Blöcke nur in einem Modus funktionieren. Summer, Abstandssensor und die seriellen Blöcke sind im Live-Modus AUSGEGRAUT. Die grüne Flagge und die Nachrichten-Blöcke sind im Upload-Modus ausgegraut.',
          contentEs: 'mBlock tiene dos modos, y deciden qué bloques puedes usar.\n\nMODO DE SUBIDA: el programa se escribe en la placa. Funciona incluso si desconectas el cable. Es el modo que usamos.\n\nMODO EN VIVO: la placa sigue conectada y las órdenes pasan al instante. Si desconectas el cable, todo se detiene.\n\nEsto importa porque algunos bloques solo funcionan en un modo. El zumbador, el sensor de distancia y los bloques de puerto serie están EN GRIS en modo en vivo. La bandera verde y los bloques de mensajes están en gris en modo de subida.',
          tipEmoji: '⚠️',
          tip: 'Bir blok gri görünüyorsa bozuk değil — yanlış moddasın.',
          tipEn: 'A greyed-out block is not broken. You are in the wrong '
              'mode.',
          tipDe: 'Ein ausgegrauter Block ist nicht kaputt. Du bist im falschen Modus.',
          tipEs: 'Un bloque en gris no está roto. Estás en el modo equivocado.',
        ),

        MultipleChoiceStep(
          id: 'm1_1_q2',
          question:
              'Kartı bilgisayardan ayırdığında programın çalışmaya devam '
              'etmesini istiyorsun. Hangi mod?',
          questionEn:
              'You want the program to keep running after you unplug the '
              'board. Which mode?',
          questionDe: 'Das Programm soll weiterlaufen, nachdem du die Platine abgezogen hast. Welcher Modus?',
          questionEs: 'Quieres que el programa siga funcionando después de desconectar la placa. ¿Qué modo?',
          options: [
            ChoiceOption(text: 'Yükleme modu', textEn: 'Upload mode', textDe: 'Upload-Modus', textEs: 'Modo de subida'),
            ChoiceOption(text: 'Canlı mod', textEn: 'Live mode', textDe: 'Live-Modus', textEs: 'Modo en vivo'),
            ChoiceOption(text: 'Fark etmez, ikisi de olur', textEn: 'Either one works', textDe: 'Beides geht', textEs: 'Cualquiera de las dos'),
            ChoiceOption(text: 'Hiçbiri, kart hep bağlı kalmalı', textEn: 'Neither, the board must stay connected', textDe: 'Keiner von beiden, die Platine muss verbunden bleiben', textEs: 'Ninguno, la placa tiene que seguir conectada'),
          ],
          correctIndex: 0,
          explanation:
              'Yükleme modunda program kartın hafızasına yazılıyor. Canlı '
              'modda komutlar bilgisayardan geldiği için kablo çıkınca '
              'her şey duruyor.',
          explanationEn:
              'In upload mode the program is written into the board\'s own '
              'memory. In live mode the commands come from the computer, so '
              'unplugging stops everything.',
          explanationDe: 'Im Upload-Modus wird das Programm in den eigenen Speicher der Platine geschrieben. Im Live-Modus kommen die Befehle vom Computer, also hört beim Abziehen alles auf.',
          explanationEs: 'En el modo de subida el programa se escribe en la memoria de la propia placa. En el modo en vivo las órdenes vienen del ordenador, así que al desconectar se detiene todo.',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'm1_1_summary',
          title: 'mBlock\'u Tanıdın!',
          titleEn: 'You Know mBlock Now!',
          titleDe: 'Jetzt kennst du mBlock!',
          titleEs: '¡Ya conoces mBlock!',
          content: '🧩 Artık ekranda ne olduğunu biliyorsun.\n\n'
              '✓ mBlock, Scratch gibi ama gerçek kartı çalıştırıyor\n'
              '✓ Cihaz sekmesi donanım, kukla sekmesi ekran\n'
              '✓ Yükleme modu kalıcı, canlı mod bağlıyken\n\n'
              'Sıradaki ders: blok paletinde ne nerede?',
          contentEn: '🧩 You know what is on the screen now.\n\n'
              '✓ mBlock is like Scratch but runs a real board\n'
              '✓ Device tab is hardware, Sprite tab is the screen\n'
              '✓ Upload mode is permanent, live mode needs the cable\n\n'
              'Next lesson: what is where in the block palette?',
          contentDe: '🧩 Jetzt weißt du, was auf dem Bildschirm ist.\n\n✓ mBlock ist wie Scratch, steuert aber eine echte Platine\n✓ Reiter Gerät ist die Hardware, Reiter Figur der Bildschirm\n✓ Upload-Modus ist dauerhaft, Live-Modus braucht das Kabel\n\nNächste Lektion: Was liegt wo in der Blockpalette?',
          contentEs: '🧩 Ya sabes qué hay en la pantalla.\n\n✓ mBlock es como Scratch pero maneja una placa real\n✓ La pestaña Dispositivo es el hardware, la pestaña Objeto es la pantalla\n✓ El modo de subida es permanente, el modo en vivo necesita el cable\n\nSiguiente lección: ¿dónde está cada cosa en la paleta de bloques?',
          tipEmoji: '🏆',
          tip: 'mBlock\'a Merhaba rozetini kazandın!',
          tipEn: 'You earned the Hello mBlock badge!',
          tipDe: 'Du hast das Abzeichen «Hallo mBlock» verdient!',
          tipEs: '¡Has ganado la insignia Hola mBlock!',
        ),
      ],
    ),

    // ---------------------------------------------------------- Ders 1.2
    InteractiveLesson(
      id: 'mblock_1_2',
      courseId: 'mblock',
      title: 'Blok Paleti: Ne Nerede?',
      subtitle: 'Dokuz kategori, dokuz renk',
      titleEn: 'The Block Palette: What Is Where?',
      titleDe: 'Die Blockpalette: Was liegt wo?',
      titleEs: 'La paleta de bloques: ¿dónde está cada cosa?',
      subtitleEn: 'Nine categories, nine colours',
      subtitleDe: 'Neun Kategorien, neun Farben',
      subtitleEs: 'Nueve categorías, nueve colores',
      order: 2,
      xpReward: 45,
      steps: [
        IntroStep(
          id: 'm1_2_intro',
          mascotEmoji: '🎨',
          mascotMessage:
              'mBlock\'ta blokları RENGİNDEN tanırsın. Her kategorinin '
              'kendi rengi var ve bu renk hiç değişmez. Bir bloğun ne işe '
              'yaradığını çoğu zaman okumadan, rengine bakarak '
              'anlayabilirsin.',
          mascotMessageEn:
              'In mBlock you recognise blocks by their COLOUR. Every '
              'category has its own colour and it never changes. Most of '
              'the time you can tell what a block does from its colour, '
              'before you even read it.',
          mascotMessageDe: 'In mBlock erkennst du Blöcke an ihrer FARBE. Jede Kategorie hat ihre eigene Farbe, und die ändert sich nie. Meistens siehst du schon an der Farbe, was ein Block tut, bevor du ihn überhaupt liest.',
          mascotMessageEs: 'En mBlock reconoces los bloques por su COLOR. Cada categoría tiene su propio color y nunca cambia. Casi siempre sabes qué hace un bloque por su color, antes incluso de leerlo.',
          highlights: [
            'Dokuz kategori, dokuz renk',
            'Renk = ne işe yaradığı',
            'Şekil = nereye takıldığı',
          ],
          highlightsEn: [
            'Nine categories, nine colours',
            'Colour tells you what it does',
            'Shape tells you where it fits',
          ],
          highlightsDe: [
            'Neun Kategorien, neun Farben',
            'Die Farbe sagt, was er tut',
            'Die Form sagt, wohin er passt',
          ],
          highlightsEs: [
            'Nueve categorías, nueve colores',
            'El color dice qué hace',
            'La forma dice dónde encaja',
          ],
        ),

        ExplanationStep(
          id: 'm1_2_exp1',
          title: 'Donanım Kategorileri',
          titleEn: 'The Hardware Categories',
          titleDe: 'Die Hardware-Kategorien',
          titleEs: 'Las categorías de hardware',
          content:
              'Arduino kartını seçtiğinde paletin ÜSTÜNDE dört yeni '
              'kategori beliriyor. Bunlar Scratch\'te yok — karta özel:\n\n'
              'Pin (mavi) → LED yak, buton oku, servo döndür. En çok '
              'kullanacağın kategori.\n\n'
              'seri port (yeşil) → karttan bilgisayara yazı gönder. Hata '
              'ararken çok işe yarar.\n\n'
              'Veri (mor) → sayı dönüştürme, harita (map), sınırlama.\n\n'
              'Sensör (açık mavi) → mesafe algılayıcı, zamanlayıcı.',
          contentEn:
              'When you select the Arduino board, four new categories '
              'appear at the TOP of the palette. They do not exist in '
              'Scratch — they belong to the board:\n\n'
              'Pin (blue) → light an LED, read a button, turn a servo. The '
              'one you will use most.\n\n'
              'serial port (green) → send text from the board to the '
              'computer. Very useful when hunting bugs.\n\n'
              'Data (purple) → number conversion, map, constrain.\n\n'
              'Sensor (light blue) → distance sensor, timer.',
          contentDe: 'Wenn du die Arduino-Platine auswählst, erscheinen OBEN in der Palette vier neue Kategorien. In Scratch gibt es sie nicht – sie gehören zur Platine:\n\nPin (blau) → eine LED leuchten lassen, einen Taster lesen, einen Servo drehen. Die brauchst du am meisten.\n\nserielle Schnittstelle (grün) → Text von der Platine an den Computer schicken. Sehr nützlich bei der Fehlersuche.\n\nDaten (lila) → Zahlen umrechnen, Karte, Begrenzung.\n\nsensor (hellblau) → Abstandssensor, Timer.',
          contentEs: 'Cuando seleccionas la placa Arduino, aparecen cuatro categorías nuevas ARRIBA de la paleta. En Scratch no existen: pertenecen a la placa:\n\nPin (azul) → encender un LED, leer un botón, girar un servo. La que más usarás.\n\npuerto serie (verde) → enviar texto de la placa al ordenador. Muy útil para cazar errores.\n\nDatos (morado) → conversión de números, mapear, limitar.\n\nSensor (azul claro) → sensor de distancia, cronómetro.',
          tipEmoji: '🟣',
          tip: 'Dikkat: "Veri" (mor) ile "Değişkenler" (turuncu) AYRI '
              'kategoriler. Veri donanım matematiği, Değişkenler ise '
              'Scratch\'teki bildiğin değişkenler.',
          tipEn: 'Careful: "Data" (purple) and "Variables" (orange) are '
              'different categories. Data is hardware maths; Variables are '
              'the Scratch variables you already know.',
          tipDe: 'Achtung: «Daten» (lila) und «Variablen» (orange) sind verschiedene Kategorien. Daten ist Hardware-Rechnerei; Variablen sind die Scratch-Variablen, die du schon kennst.',
          tipEs: 'Cuidado: «Datos» (morado) y «Variables» (naranja) son categorías distintas. Datos son las matemáticas del hardware; Variables son las variables de Scratch que ya conoces.',
        ),

        ExplanationStep(
          id: 'm1_2_exp2',
          title: 'Scratch\'ten Gelen Kategoriler',
          titleEn: 'The Categories from Scratch',
          titleDe: 'Die Kategorien aus Scratch',
          titleEs: 'Las categorías que vienen de Scratch',
          content:
              'Donanım kategorilerinin altında tanıdık olanlar var:\n\n'
              'Olaylar (sarı) → program ne zaman başlasın?\n'
              'Kontrol (turuncu) → tekrarla, bekle, eğer/ise\n'
              'İşlemler (yeşil) → toplama, karşılaştırma, ve/veya\n'
              'Değişkenler (turuncu) → sayı sakla\n'
              'Bloklarım (pembe) → kendi bloğunu yap\n\n'
              'AMA Hareket, Görünüm, Ses ve Algılama YOK. Onlar kuklaya '
              'ait; Arduino kartı seçiliyken palette görünmezler.',
          contentEn:
              'Below the hardware categories are the familiar ones:\n\n'
              'Events (yellow) → when should the program start?\n'
              'Control (orange) → repeat, wait, if/then\n'
              'Operators (green) → add, compare, and/or\n'
              'Variables (orange) → store a number\n'
              'My Blocks (pink) → make your own block\n\n'
              'BUT there is no Motion, Looks, Sound or Sensing. Those '
              'belong to the sprite and are not in the palette while the '
              'Arduino board is selected.',
          contentDe: 'Unter den Hardware-Kategorien stehen die bekannten:\n\nEreignisse (gelb) → wann soll das Programm starten?\nSteuerung (orange) → wiederhole, warte, falls/dann\nOperatoren (grün) → addieren, vergleichen, und/oder\nVariablen (orange) → eine Zahl speichern\nMeine Blöcke (rosa) → einen eigenen Block bauen\n\nABER es gibt kein Bewegung, Aussehen, Klang oder Fühlen. Die gehören zur Figur und sind nicht in der Palette, solange die Arduino-Platine ausgewählt ist.',
          contentEs: 'Debajo de las categorías de hardware están las de siempre:\n\nEventos (amarillo) → ¿cuándo debe empezar el programa?\nControl (naranja) → repetir, esperar, si/entonces\nOperadores (verde) → sumar, comparar, y/o\nVariables (naranja) → guardar un número\nMis bloques (rosa) → crear tu propio bloque\n\nPERO no hay Movimiento, Apariencia, Sonido ni Sensores. Esos pertenecen al objeto y no están en la paleta mientras la placa Arduino esté seleccionada.',
          tipEmoji: '🧭',
          tip: 'Toplam dokuz kategori: dört donanım + beş Scratch.',
          tipEn: 'Nine categories in total: four hardware plus five from '
              'Scratch.',
          tipDe: 'Neun Kategorien insgesamt: vier Hardware plus fünf aus Scratch.',
          tipEs: 'Nueve categorías en total: cuatro de hardware más cinco de Scratch.',
        ),

        MatchingStep(
          id: 'm1_2_match1',
          instruction: 'Kategoriyi rengiyle eşleştir.',
          instructionEn: 'Match each category with its colour.',
          instructionDe: 'Ordne jeder Kategorie ihre Farbe zu.',
          instructionEs: 'Relaciona cada categoría con su color.',
          pairs: [
            MatchPair(id: 'p1', left: 'Pin', right: 'Mavi',
                leftEn: 'Pin',
                leftDe: 'Pin',
                leftEs: 'Pin', rightEn: 'Blue', rightDe: 'Blue', rightEs: 'Blue'),
            MatchPair(id: 'p2', left: 'seri port', right: 'Yeşil',
                leftEn: 'serial port',
                leftDe: 'serielle Schnittstelle',
                leftEs: 'puerto serie', rightEn: 'Green', rightDe: 'Green', rightEs: 'Green'),
            MatchPair(id: 'p3', left: 'Veri', right: 'Mor',
                leftEn: 'Data',
                leftDe: 'Daten',
                leftEs: 'Datos', rightEn: 'Purple', rightDe: 'Purple', rightEs: 'Purple'),
            MatchPair(id: 'p4', left: 'Olaylar', right: 'Sarı',
                leftEn: 'Events',
                leftDe: 'Ereignisse',
                leftEs: 'Eventos', rightEn: 'Yellow', rightDe: 'Yellow', rightEs: 'Yellow'),
            MatchPair(id: 'p5', left: 'Kontrol', right: 'Turuncu',
                leftEn: 'Control',
                leftDe: 'Steuerung',
                leftEs: 'Control', rightEn: 'Orange', rightDe: 'Orange', rightEs: 'Orange'),
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'm1_2_exp3',
          title: 'Şekil Neyi Söyler?',
          titleEn: 'What Does the Shape Tell You?',
          titleDe: 'Was verrät dir die Form?',
          titleEs: '¿Qué te dice la forma?',
          content:
              'Bir bloğun ŞEKLİ, nereye takılabileceğini söyler:\n\n'
              'Şapka (üstü yuvarlak) → en üste gelir, üstüne bir şey '
              'takılmaz. Program buradan başlar.\n\n'
              'Düz blok (üstü çentikli, altı çıkıntılı) → alt alta '
              'dizilir. İşin çoğu bunlarla yapılır.\n\n'
              'C bloğu → İÇİNE başka bloklar alır. "sürekli tekrarla" ve '
              '"eğer ise" böyledir.\n\n'
              'Oval → bir SAYI ya da yazı verir. Tek başına durmaz, başka '
              'bir bloğun kutusuna konur.\n\n'
              'Altıgen → EVET/HAYIR verir. Sadece altıgen yuvalara girer, '
              'yani "eğer ise" bloğunun koşul yerine.',
          contentEn:
              'A block\'s SHAPE tells you where it can go:\n\n'
              'Hat (rounded top) → goes on top, nothing attaches above it. '
              'The program starts here.\n\n'
              'Stack block (notch on top, bump below) → snaps in a column. '
              'Most of the work happens with these.\n\n'
              'C block → holds other blocks INSIDE it. "forever" and "if '
              'then" are like this.\n\n'
              'Oval → gives back a NUMBER or text. It never stands alone; '
              'it goes into another block\'s slot.\n\n'
              'Hexagon → gives back YES/NO. It only fits hexagon slots, '
              'like the condition of an "if then".',
          contentDe: 'Die FORM eines Blocks sagt dir, wohin er passt:\n\nHut (runde Oberseite) → kommt nach oben, darüber passt nichts. Hier startet das Programm.\n\nStapelblock (Kerbe oben, Nase unten) → rastet in einer Spalte ein. Damit passiert die meiste Arbeit.\n\nC-Block → hält andere Blöcke IN sich. «wiederhole fortlaufend» und «falls, dann» sind so.\n\nOval → gibt eine ZAHL oder Text zurück. Es steht nie allein; es kommt in den Schlitz eines anderen Blocks.\n\nSechseck → gibt JA/NEIN zurück. Es passt nur in Sechseck-Schlitze, zum Beispiel in die Bedingung von «falls, dann».',
          contentEs: 'La FORMA de un bloque te dice dónde puede ir:\n\nSombrero (parte superior redondeada) → va arriba del todo, nada se engancha encima. Ahí empieza el programa.\n\nBloque de pila (muesca arriba, saliente abajo) → encaja en una columna. Con estos se hace casi todo el trabajo.\n\nBloque en C → guarda otros bloques DENTRO. «por siempre» y «si entonces» son así.\n\nÓvalo → devuelve un NÚMERO o un texto. Nunca va solo; entra en la ranura de otro bloque.\n\nHexágono → devuelve SÍ/NO. Solo encaja en ranuras hexagonales, como la condición de un «si entonces».',
          tipEmoji: '🧩',
          tip: 'Oval bir bloğu altıgen yuvaya sokamazsın; mBlock zaten '
              'yerleştirmene izin vermez.',
          tipEn: 'You cannot put an oval block into a hexagon slot; mBlock '
              'will not let it snap in.',
          tipDe: 'Ein ovaler Block passt nicht in einen Sechseck-Schlitz; mBlock lässt ihn dort nicht einrasten.',
          tipEs: 'No puedes meter un bloque ovalado en una ranura hexagonal; mBlock no deja que encaje.',
        ),

        MultipleChoiceStep(
          id: 'm1_2_q1',
          question:
              '"dijital oku pin 2" bloğu ALTIGEN şeklinde. Bu ne demek?',
          questionEn:
              'The "read digital pin 2" block is a HEXAGON. What does that '
              'mean?',
          questionDe: 'Der Block «Digitalpin lesen 2» ist ein SECHSECK. Was heißt das?',
          questionEs: 'El bloque «lee pin digital 2» es un HEXÁGONO. ¿Qué significa eso?',
          options: [
            ChoiceOption(text: 'Evet/hayır verir, koşul yerine konur', textEn: 'It gives yes/no and goes in a condition', textDe: 'Es gibt ja/nein und kommt in eine Bedingung', textEs: 'Da sí/no y va en una condición'),
            ChoiceOption(text: 'Bir sayı verir, matematik kutusuna konur', textEn: 'It gives a number for a maths slot', textDe: 'Es gibt eine Zahl für einen Rechen-Schlitz', textEs: 'Da un número para una ranura de cálculo'),
            ChoiceOption(text: 'İçine başka blok alır', textEn: 'It holds other blocks inside', textDe: 'Er hält andere Blöcke in sich', textEs: 'Contiene otros bloques dentro'),
            ChoiceOption(text: 'Programı başlatır', textEn: 'It starts the program', textDe: 'Es startet das Programm', textEs: 'Inicia el programa'),
          ],
          correctIndex: 0,
          explanation:
              'Altıgen bloklar EVET/HAYIR döndürür. "dijital oku" bloğu da '
              'butona basılı mı diye sorar; cevabı evet ya da hayırdır. '
              'Bu yüzden "eğer ise" bloğunun altıgen yuvasına girer.',
          explanationEn:
              'Hexagon blocks return YES/NO. "read digital pin" asks '
              'whether the button is pressed — the answer is yes or no. '
              'That is why it fits the hexagon slot of an "if then".',
          explanationDe: 'Sechseck-Blöcke geben JA/NEIN zurück. «Digitalpin lesen» fragt, ob der Taster gedrückt ist – die Antwort ist ja oder nein. Deshalb passt er in den Sechseck-Schlitz von «falls, dann».',
          explanationEs: 'Los bloques hexagonales devuelven SÍ/NO. «lee pin digital» pregunta si el botón está pulsado, y la respuesta es sí o no. Por eso encaja en la ranura hexagonal de un «si entonces».',
          xpReward: 15,
        ),

        MultipleChoiceStep(
          id: 'm1_2_q2',
          question:
              '"analog oku pin (A) 0" bloğu OVAL. Nereye konur?',
          questionEn:
              'The "read analog pin (A) 0" block is OVAL. Where does it go?',
          questionDe: 'Der Block «analogen Pin（A）0 lesen» ist OVAL. Wohin kommt er?',
          questionEs: 'El bloque «lee pin analógico 0» es OVALADO. ¿Dónde va?',
          options: [
            ChoiceOption(text: 'Başka bir bloğun sayı kutusuna', textEn: 'Into another block\'s number slot', textDe: 'In den Zahlen-Schlitz eines anderen Blocks', textEs: 'En la ranura numérica de otro bloque'),
            ChoiceOption(text: '"eğer ise" bloğunun koşul yerine', textEn: 'Into the condition of an "if then"', textDe: 'In die Bedingung von «falls, dann»', textEs: 'En la condición de un «si entonces»'),
            ChoiceOption(text: 'En üste, program başlangıcı olarak', textEn: 'On top, as the start of the program', textDe: 'Ganz oben, als Anfang des Programms', textEs: 'Arriba del todo, como inicio del programa'),
            ChoiceOption(text: 'Tek başına, alt alta dizilerek', textEn: 'On its own, stacked in a column', textDe: 'Allein, in einer Spalte gestapelt', textEs: 'Solo, apilado en una columna'),
          ],
          correctIndex: 0,
          explanation:
              'Oval bloklar bir DEĞER verir — burada 0 ile 1023 arasında '
              'bir sayı. Tek başına durmazlar; bir kutunun içine konurlar.',
          explanationEn:
              'Oval blocks return a VALUE — here a number between 0 and '
              '1023. They never stand alone; they go inside a slot.',
          explanationDe: 'Ovale Blöcke geben einen WERT zurück – hier eine Zahl zwischen 0 und 1023. Sie stehen nie allein; sie kommen in einen Schlitz.',
          explanationEs: 'Los bloques ovalados devuelven un VALOR: aquí un número entre 0 y 1023. Nunca van solos; entran en una ranura.',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'm1_2_summary',
          title: 'Paleti Okuyabiliyorsun!',
          titleEn: 'You Can Read the Palette!',
          titleDe: 'Du kannst die Palette lesen!',
          titleEs: '¡Ya sabes leer la paleta!',
          content: '🎨 Artık bir bloğa bakınca ne olduğunu anlıyorsun.\n\n'
              '✓ Renk → hangi kategoriden\n'
              '✓ Şekil → nereye takılır\n'
              '✓ Dört donanım + beş Scratch kategorisi\n\n'
              'Sıradaki ders: ilk programını yazıyorsun.',
          contentEn: '🎨 Now you can read a block at a glance.\n\n'
              '✓ Colour → which category\n'
              '✓ Shape → where it fits\n'
              '✓ Four hardware plus five Scratch categories\n\n'
              'Next lesson: you write your first program.',
          contentDe: '🎨 Jetzt liest du einen Block auf einen Blick.\n\n✓ Farbe → welche Kategorie\n✓ Form → wohin er passt\n✓ Vier Hardware- plus fünf Scratch-Kategorien\n\nNächste Lektion: Du schreibst dein erstes Programm.',
          contentEs: '🎨 Ahora lees un bloque de un vistazo.\n\n✓ Color → qué categoría\n✓ Forma → dónde encaja\n✓ Cuatro categorías de hardware más cinco de Scratch\n\nSiguiente lección: escribes tu primer programa.',
          tipEmoji: '🏆',
          tip: 'Palet Ustası rozetini kazandın!',
          tipEn: 'You earned the Palette Reader badge!',
          tipDe: 'Du hast das Abzeichen «Palettenleser» verdient!',
          tipEs: '¡Has ganado la insignia Lector de Paleta!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODÜL 2 — İLK PROGRAMLAR (KÜÇÜK)
  // ==========================================

  static final List<InteractiveLesson> module2 = [
    // ---------------------------------------------------------- Ders 2.1
    InteractiveLesson(
      id: 'mblock_2_1',
      courseId: 'mblock',
      title: 'İlk Program: LED Yak',
      subtitle: 'Başlangıç bloğu ve dijital çıkış',
      titleEn: 'First Program: Light an LED',
      titleDe: 'Erstes Programm: eine LED leuchten lassen',
      titleEs: 'Primer programa: encender un LED',
      subtitleEn: 'The start block and digital output',
      subtitleDe: 'Der Startblock und der Digitalausgang',
      subtitleEs: 'El bloque de inicio y la salida digital',
      order: 3,
      xpReward: 50,
      steps: [
        IntroStep(
          id: 'm2_1_intro',
          mascotEmoji: '💡',
          mascotMessage:
              'İki blokla başlıyoruz: programı başlatan blok ve pini açan '
              'blok. Bu ikisi, mBlock\'taki her programın temeli.',
          mascotMessageEn:
              'We start with two blocks: the one that starts the program '
              'and the one that turns a pin on. These two are the basis of '
              'every mBlock program.',
          mascotMessageDe: 'Wir fangen mit zwei Blöcken an: dem, der das Programm startet, und dem, der einen Pin einschaltet. Diese beiden sind die Grundlage jedes mBlock-Programms.',
          mascotMessageEs: 'Empezamos con dos bloques: el que arranca el programa y el que enciende un pin. Estos dos son la base de todo programa de mBlock.',
          highlights: [
            'Başlangıç bloğunu tanı',
            'Pin kategorisini kullan',
            'İlk programı yükle',
          ],
          highlightsEn: [
            'Meet the start block',
            'Use the Pin category',
            'Upload your first program',
          ],
          highlightsDe: [
            'Den Startblock kennenlernen',
            'Die Kategorie Pin benutzen',
            'Dein erstes Programm hochladen',
          ],
          highlightsEs: [
            'Conocer el bloque de inicio',
            'Usar la categoría Pin',
            'Subir tu primer programa',
          ],
        ),

        ExplanationStep(
          id: 'm2_1_exp1',
          title: 'Yeşil Bayrak Nerede?',
          titleEn: 'Where Is the Green Flag?',
          titleDe: 'Wo ist die grüne Flagge?',
          titleEs: '¿Dónde está la bandera verde?',
          content:
              'Scratch\'te program yeşil bayrakla başlıyordu. Yükleme '
              'modunda yeşil bayrak YOK — gri görünür, çünkü kartın üstünde '
              'tıklayacağın bir bayrak yok.\n\n'
              'Onun yerine Olaylar kategorisindeki şu şapka bloğu var:\n\n'
              '   when Arduino Uno starts up\n\n'
              'Bu blok "kart elektrik alınca" demek. Pili taktığın anda '
              'altındaki her şey çalışmaya başlar.',
          contentEn:
              'In Scratch the program starts with the green flag. In upload '
              'mode there is NO green flag — it is greyed out, because '
              'there is no flag to click on a board.\n\n'
              'Instead, the Events category has this hat block:\n\n'
              '   when Arduino Uno starts up\n\n'
              'It means "when the board gets power". The moment you plug '
              'in the battery, everything below it runs.',
          contentDe: 'In Scratch startet das Programm mit der grünen Flagge. Im Upload-Modus gibt es KEINE grüne Flagge – sie ist ausgegraut, denn auf einer Platine gibt es keine Flagge zum Anklicken.\n\nStattdessen hat die Kategorie Ereignisse diesen Hutblock:\n\n   wenn Arduino Uno startet\n\nEr bedeutet «wenn die Platine Strom bekommt». In dem Moment, in dem du die Batterie ansteckst, läuft alles darunter.',
          contentEs: 'En Scratch el programa empieza con la bandera verde. En el modo de subida NO hay bandera verde: está en gris, porque en una placa no hay ninguna bandera que pulsar.\n\nEn su lugar, la categoría Eventos tiene este bloque de sombrero:\n\n   cuando Arduino Uno se inicia\n\nSignifica «cuando la placa recibe corriente». En el momento en que enchufas la pila, todo lo que hay debajo se ejecuta.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'when Arduino Uno starts up',
              contentEn: 'when Arduino Uno starts up',
              contentDe: 'wenn Arduino Uno startet',
              contentEs: 'cuando Arduino Uno se inicia',
              color: MBlockPalette.events,
              label: 'Olaylar · şapka blok',
              labelEn: 'Events · hat block',
              labelDe: 'Ereignisse · Hutblock',
              labelEs: 'Eventos · bloque de sombrero',
            ),
          ],
          tipEmoji: '🇬🇧',
          tip: 'Bu bloğun Türkçesi yok — mBlock\'un Türkçe arayüzünde bile '
              'İngilizce yazıyor. Bloğu ararken bu haliyle ara.',
          tipEn: 'This block has no Turkish name — it stays in English even '
              'in the Turkish interface.',
          tipDe: 'Auf Deutsch heißt dieser Block «wenn Arduino Uno startet» – genau so siehst du ihn im deutschen mBlock. Im türkischen mBlock bleibt er dagegen englisch.',
          tipEs: 'En español este bloque se llama «cuando Arduino Uno se inicia» y así lo verás en mBlock en español. En cambio, en el mBlock en turco sigue apareciendo en inglés.',
        ),

        ExplanationStep(
          id: 'm2_1_exp2',
          title: 'Pini Açan Blok',
          titleEn: 'The Block That Turns a Pin On',
          titleDe: 'Der Block, der einen Pin einschaltet',
          titleEs: 'El bloque que enciende un pin',
          content:
              'Pin kategorisindeki (mavi) ilk blok bu:\n\n'
              '   dijital ayarla pin [9] çıkış [yüksek]\n\n'
              'İki kutusu var:\n'
              '• pin → hangi bacak? (0-13 arası)\n'
              '• çıkış → yüksek mi düşük mü?\n\n'
              'yüksek = pine 5 volt verilir → LED yanar\n'
              'düşük = pin 0 volta iner → LED söner\n\n'
              'Dikkat: mBlock\'ta bu iki seçenek küçük harfle yazıyor, '
              '"yüksek" ve "düşük".',
          contentEn:
              'This is the first block in the Pin category (blue):\n\n'
              '   set digital pin [9] output as [high]\n\n'
              'It has two slots:\n'
              '• pin → which leg? (0-13)\n'
              '• output → high or low?\n\n'
              'high = 5 volts on the pin → the LED lights\n'
              'low = 0 volts → the LED goes off',
          contentDe: 'Das ist der erste Block in der Kategorie Pin (blau):\n\n   digitalen Pin von Ausgang [9] als [hoch] setzen\n\nEr hat zwei Schlitze:\n• Pin → welches Bein? (0-13)\n• Ausgang → hoch oder niedrig?\n\nhoch = 5 Volt am Pin → die LED leuchtet\nniedrig = 0 Volt → die LED geht aus',
          contentEs: 'Este es el primer bloque de la categoría Pin (azul):\n\n   pon el pin digital [9] a [alto]\n\nTiene dos ranuras:\n• pin → ¿qué pata? (0-13)\n• salida → ¿alto o bajo?\n\nalto = 5 voltios en el pin → el LED se enciende\nbajo = 0 voltios → el LED se apaga',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'dijital ayarla pin 9 çıkış yüksek',
              contentEn: 'set digital pin 9 output as high',
              contentDe: 'digitalen Pin von Ausgang 9 als hoch setzen',
              contentEs: 'pon el pin digital 9 a alto',
              color: MBlockPalette.pin,
              label: 'Pin · düz blok',
              labelEn: 'Pin · stack block',
              labelDe: 'Pin · Stapelblock',
              labelEs: 'Pin · bloque de pila',
            ),
          ],
          tipEmoji: '🔌',
          tip: 'LED\'in uzun bacağı 9 numaralı pine, kısa bacağı 220 ohm '
              'direnç üzerinden GND\'ye gider.',
          tipEn: 'The LED\'s long leg goes to pin 9, the short leg to GND '
              'through a 220 ohm resistor.',
          tipDe: 'Das lange Bein der LED kommt an Pin 9, das kurze über einen 220-Ohm-Widerstand an GND.',
          tipEs: 'La pata larga del LED va al pin 9 y la corta a GND a través de una resistencia de 220 ohmios.',
        ),

        BlockBuilderStep(
          id: 'm2_1_build1',
          instruction: 'LED\'i yakan en kısa programı kur.',
          instructionEn: 'Build the shortest program that lights the LED.',
          instructionDe: 'Baue das kürzeste Programm, das die LED leuchten lässt.',
          instructionEs: 'Construye el programa más corto que encienda el LED.',
          goal: 'Kart açılınca 9. pindeki LED yansın',
          goalEn: 'When the board starts, the LED on pin 9 turns on',
          goalDe: 'Wenn die Platine startet, geht die LED an Pin 9 an',
          goalEs: 'Cuando la placa arranca, el LED del pin 9 se enciende',
          availableBlocks: [
            MBlockBlocks.boardLaunch(),
            MBlockBlocks.digitalWrite('9', 'yüksek', id: 'led_on'),
            MBlockBlocks.digitalWrite('9', 'düşük', id: 'led_off'),
            MBlockBlocks.wait('1'),
          ],
          correctSequence: ['board_launch', 'led_on'],
          xpReward: 30,
        ),

        MultipleChoiceStep(
          id: 'm2_1_q1',
          question:
              'LED\'i söndürmek için "çıkış" kutusuna ne yazarsın?',
          questionEn:
              'What do you put in the "output" slot to turn the LED off?',
          questionDe: 'Was schreibst du in den Schlitz «Ausgang», um die LED auszuschalten?',
          questionEs: '¿Qué pones en la ranura de salida para apagar el LED?',
          options: [
            ChoiceOption(text: 'düşük', textEn: 'low', textDe: 'low', textEs: 'low'),
            ChoiceOption(text: 'yüksek', textEn: 'high', textDe: 'high', textEs: 'high'),
            ChoiceOption(text: 'kapalı', textEn: 'off', textDe: 'off', textEs: 'off'),
            ChoiceOption(text: '0 volt', textEn: '0 volt', textDe: '0 Volt', textEs: '0 voltios'),
          ],
          correctIndex: 0,
          explanation:
              'Kutu bir açılır liste ve içinde yalnızca iki seçenek var: '
              'yüksek ve düşük. "kapalı" diye bir seçenek yok.',
          explanationEn:
              'The slot is a dropdown with exactly two options: high and '
              'low. There is no "off".',
          explanationDe: 'Der Schlitz ist ein Ausklappmenü mit genau zwei Möglichkeiten: hoch und niedrig. Ein «aus» gibt es nicht.',
          explanationEs: 'La ranura es un desplegable con exactamente dos opciones: alto y bajo. No existe un «apagado».',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'm2_1_summary',
          title: 'İlk Programın Hazır!',
          titleEn: 'Your First Program Is Ready!',
          titleDe: 'Dein erstes Programm ist fertig!',
          titleEs: '¡Tu primer programa está listo!',
          content: '💡 İki blokla gerçek bir LED yaktın.\n\n'
              '✓ Başlangıç bloğunu öğrendin\n'
              '✓ dijital ayarla bloğunu kullandın\n'
              '✓ yüksek/düşük ne demek biliyorsun\n\n'
              'Sıradaki ders: LED\'i yanıp söndürmek.',
          contentEn: '💡 Two blocks and a real LED lights up.\n\n'
              '✓ You learned the start block\n'
              '✓ You used the digital output block\n'
              '✓ You know what high and low mean\n\n'
              'Next lesson: making it blink.',
          contentDe: '💡 Zwei Blöcke, und eine echte LED leuchtet.\n\n✓ Du hast den Startblock kennengelernt\n✓ Du hast den Digitalausgang benutzt\n✓ Du weißt, was hoch und niedrig bedeuten\n\nNächste Lektion: Sie soll blinken.',
          contentEs: '💡 Dos bloques y se enciende un LED de verdad.\n\n✓ Aprendiste el bloque de inicio\n✓ Usaste el bloque de salida digital\n✓ Sabes qué significan alto y bajo\n\nSiguiente lección: hacer que parpadee.',
          tipEmoji: '🏆',
          tip: 'İlk Işık rozetini kazandın!',
          tipEn: 'You earned the First Light badge!',
          tipDe: 'Du hast das Abzeichen «Erstes Licht» verdient!',
          tipEs: '¡Has ganado la insignia Primera Luz!',
        ),
      ],
    ),

    // ---------------------------------------------------------- Ders 2.2
    InteractiveLesson(
      id: 'mblock_2_2',
      courseId: 'mblock',
      title: 'Yanıp Sönme: Sürekli Tekrarla',
      subtitle: 'C bloğu ve bekleme',
      titleEn: 'Blinking: The Forever Loop',
      titleDe: 'Blinken: die Endlosschleife',
      titleEs: 'Parpadeo: el bucle por siempre',
      subtitleEn: 'C blocks and waiting',
      subtitleDe: 'C-Blöcke und das Warten',
      subtitleEs: 'Bloques en C y la espera',
      order: 4,
      xpReward: 50,
      steps: [
        IntroStep(
          id: 'm2_2_intro',
          mascotEmoji: '✨',
          mascotMessage:
              'LED yandı ama hep yanık kaldı. Şimdi onu yanıp söndüreceğiz. '
              'Bunun için iki şey lazım: tekrar eden bir kutu ve arada '
              'bekleme.',
          mascotMessageEn:
              'The LED lit up but stayed on. Now we will make it blink. We '
              'need two things: a box that repeats, and a pause in between.',
          mascotMessageDe: 'Die LED ging an, blieb aber an. Jetzt bringen wir sie zum Blinken. Dafür brauchen wir zwei Dinge: eine Box, die wiederholt, und eine Pause dazwischen.',
          mascotMessageEs: 'El LED se encendió pero se quedó encendido. Ahora vamos a hacerlo parpadear. Necesitamos dos cosas: una caja que repita y una pausa en medio.',
          highlights: [
            'C bloğu içine blok almak',
            'Bekleme neden şart',
            'Sürekli tekrarla',
          ],
          highlightsEn: [
            'Putting blocks inside a C block',
            'Why waiting is necessary',
            'The forever loop',
          ],
          highlightsDe: [
            'Blöcke in einen C-Block legen',
            'Warum das Warten nötig ist',
            'Die Endlosschleife',
          ],
          highlightsEs: [
            'Poner bloques dentro de un bloque en C',
            'Por qué hace falta esperar',
            'El bucle por siempre',
          ],
        ),

        ExplanationStep(
          id: 'm2_2_exp1',
          title: 'Sürekli Tekrarla',
          titleEn: 'Forever',
          titleDe: 'Wiederhole fortlaufend',
          titleEs: 'Por siempre',
          content:
              'Kontrol kategorisindeki (turuncu) "sürekli tekrarla" bloğu '
              'bir C şeklindedir: içine koyduğun bloklar durmadan, baştan '
              'sona, tekrar tekrar çalışır.\n\n'
              'Altında hiçbir şey olmaz — çünkü asla bitmez. Bloğun altında '
              'çentik bile yoktur.',
          contentEn:
              'The "forever" block in the Control category (orange) is a C '
              'shape: the blocks you put inside run over and over, without '
              'stopping.\n\n'
              'Nothing goes below it — it never ends, so it has no notch at '
              'the bottom.',
          contentDe: 'Der Block «wiederhole fortlaufend» in der Kategorie Steuerung (orange) hat eine C-Form: Die Blöcke, die du hineinlegst, laufen immer wieder, ohne aufzuhören.\n\nDarunter kommt nichts – die Schleife endet nie, deshalb hat sie unten keine Nase.',
          contentEs: 'El bloque «por siempre» de la categoría Control (naranja) tiene forma de C: los bloques que pones dentro se ejecutan una y otra vez, sin parar.\n\nDebajo no va nada: nunca termina, así que no tiene saliente abajo.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'sürekli tekrarla',
              contentEn: 'forever',
              contentDe: 'wiederhole fortlaufend',
              contentEs: 'por siempre',
              color: MBlockPalette.control,
              label: 'Kontrol · C bloğu',
              labelEn: 'Control · C block',
              labelDe: 'Steuerung · C-Block',
              labelEs: 'Control · bloque en C',
            ),
          ],
          tipEmoji: '♾️',
          tip: 'Arduino\'da program bittiğinde durmaz — "sürekli tekrarla" '
              'olmadan LED bir kez yanar ve öyle kalır.',
          tipEn: 'Without a forever loop the LED just turns on once and '
              'stays that way.',
          tipDe: 'Ohne Endlosschleife geht die LED nur einmal an und bleibt so.',
          tipEs: 'Sin un bucle por siempre, el LED solo se enciende una vez y se queda así.',
        ),

        ExplanationStep(
          id: 'm2_2_exp2',
          title: 'Beklemeyi Unutursan',
          titleEn: 'If You Forget the Wait',
          titleDe: 'Wenn du das Warten vergisst',
          titleEs: 'Si te olvidas de la espera',
          content:
              'Bu programı düşün:\n\n'
              'sürekli tekrarla\n'
              '  dijital ayarla pin 9 çıkış yüksek\n'
              '  dijital ayarla pin 9 çıkış düşük\n\n'
              'LED yanıp sönüyor mu? Teknik olarak evet — ama saniyede '
              'binlerce kez. Gözün bunu göremez; LED sana sürekli yanıyor '
              'gibi görünür (biraz sönük).\n\n'
              'Bu yüzden aralara "1 saniye bekle" koymak şart. Bekleme, '
              'yanıp sönmeyi görünür yapan şeydir.',
          contentEn:
              'Think about this program:\n\n'
              'forever\n'
              '  set digital pin 9 output as high\n'
              '  set digital pin 9 output as low\n\n'
              'Does the LED blink? Technically yes — thousands of times a '
              'second. Your eye cannot see that; the LED just looks dimly '
              'on all the time.\n\n'
              'That is why you need a wait in between.',
          contentDe: 'Denk an dieses Programm:\n\nwiederhole fortlaufend\n  digitalen Pin von Ausgang 9 als hoch setzen\n  digitalen Pin von Ausgang 9 als niedrig setzen\n\nBlinkt die LED? Streng genommen ja – tausende Male pro Sekunde. Dein Auge sieht das nicht; die LED wirkt einfach dauernd schwach an.\n\nDeshalb brauchst du ein Warten dazwischen.',
          contentEs: 'Piensa en este programa:\n\npor siempre\n  pon el pin digital 9 a alto\n  pon el pin digital 9 a bajo\n\n¿Parpadea el LED? Técnicamente sí, miles de veces por segundo. Tu ojo no lo ve; el LED parece encendido flojito todo el rato.\n\nPor eso hace falta una espera en medio.',
          tipEmoji: '⏱️',
          tip: 'Beklemesiz döngü en sık yapılan hata. LED "çalışmıyor" '
              'sanılır ama aslında çok hızlı çalışıyordur.',
          tipEn: 'A loop with no wait is the most common mistake. People '
              'think the LED is broken; it is just too fast to see.',
          tipDe: 'Eine Schleife ohne Warten ist der häufigste Fehler. Man hält die LED für kaputt; sie ist nur zu schnell, um sie zu sehen.',
          tipEs: 'Un bucle sin espera es el error más común. La gente cree que el LED está roto; solo va demasiado rápido para verlo.',
        ),

        BlockBuilderStep(
          id: 'm2_2_build1',
          instruction: 'LED\'i saniyede bir yanıp söndüren programı kur.',
          instructionEn: 'Build a program that blinks the LED once a second.',
          instructionDe: 'Baue ein Programm, das die LED einmal pro Sekunde blinken lässt.',
          instructionEs: 'Construye un programa que haga parpadear el LED una vez por segundo.',
          goal: 'Yan, 1 saniye bekle, sön, 1 saniye bekle — sürekli',
          goalEn: 'On, wait 1s, off, wait 1s — forever',
          goalDe: 'An, 1 s warten, aus, 1 s warten – fortlaufend',
          goalEs: 'Encendido, esperar 1 s, apagado, esperar 1 s, por siempre',
          availableBlocks: [
            MBlockBlocks.boardLaunch(),
            MBlockBlocks.forever(),
            MBlockBlocks.digitalWrite('9', 'yüksek', id: 'led_on'),
            MBlockBlocks.wait('1', id: 'wait_on'),
            MBlockBlocks.digitalWrite('9', 'düşük', id: 'led_off'),
            MBlockBlocks.wait('1', id: 'wait_off'),
          ],
          correctSequence: [
            'board_launch',
            'forever',
            'led_on',
            'wait_on',
            'led_off',
            'wait_off',
          ],
          xpReward: 35,
        ),

        MultipleChoiceStep(
          id: 'm2_2_q1',
          question:
              '"sürekli tekrarla" bloğunun ALTINA neden blok takılamaz?',
          questionEn: 'Why can nothing be attached BELOW a forever block?',
          questionDe: 'Warum kann UNTER einem «wiederhole fortlaufend» nichts angesteckt werden?',
          questionEs: '¿Por qué no se puede enganchar nada DEBAJO de un bloque por siempre?',
          options: [
            ChoiceOption(text: 'Döngü hiç bitmediği için sıra oraya gelmez', textEn: 'The loop never ends, so the turn never comes', textDe: 'Die Schleife endet nie, also kommt die Reihe nie', textEs: 'El bucle no termina nunca, así que nunca le toca'),
            ChoiceOption(text: 'mBlock\'ta bir hata var', textEn: 'It is a bug in mBlock', textDe: 'Das ist ein Fehler in mBlock', textEs: 'Es un fallo de mBlock'),
            ChoiceOption(text: 'Takılabilir, ama yavaşlatır', textEn: 'You can, but it slows things down', textDe: 'Man kann, aber es wird langsamer', textEs: 'Se puede, pero va más lento'),
            ChoiceOption(text: 'Yalnızca Pin blokları takılabilir', textEn: 'Only Pin blocks can attach', textDe: 'Nur Pin-Blöcke können andocken', textEs: 'Solo pueden encajar bloques de Pin'),
          ],
          correctIndex: 0,
          explanation:
              '"sürekli tekrarla" asla bitmez, bu yüzden altındaki bir blok '
              'hiçbir zaman çalışmazdı. mBlock da bunu bildiği için bloğun '
              'altına çentik koymuyor.',
          explanationEn:
              'A forever loop never finishes, so a block below it would '
              'never run. mBlock knows this and gives the block no bottom '
              'notch.',
          explanationDe: 'Eine Endlosschleife hört nie auf, also würde ein Block darunter nie laufen. mBlock weiß das und gibt dem Block unten keine Nase.',
          explanationEs: 'Un bucle por siempre nunca termina, así que un bloque debajo no se ejecutaría nunca. mBlock lo sabe y no le pone saliente inferior.',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'm2_2_summary',
          title: 'Döngüyü Öğrendin!',
          titleEn: 'You Learned the Loop!',
          titleDe: 'Du hast die Schleife gelernt!',
          titleEs: '¡Aprendiste el bucle!',
          content: '✨ İlk canlı projen çalışıyor.\n\n'
              '✓ C bloğunun içine blok koydun\n'
              '✓ Beklemenin neden şart olduğunu anladın\n'
              '✓ Sonsuz döngü kurdun\n\n'
              'Sıradaki modül: kart artık seni DİNLEYECEK.',
          contentEn: '✨ Your first live project works.\n\n'
              '✓ You put blocks inside a C block\n'
              '✓ You understand why the wait is necessary\n'
              '✓ You built an endless loop\n\n'
              'Next module: the board starts LISTENING to you.',
          contentDe: '✨ Dein erstes richtiges Projekt läuft.\n\n✓ Du hast Blöcke in einen C-Block gelegt\n✓ Du verstehst, warum das Warten nötig ist\n✓ Du hast eine Endlosschleife gebaut\n\nNächstes Modul: Die Platine HÖRT dir zu.',
          contentEs: '✨ Tu primer proyecto de verdad funciona.\n\n✓ Pusiste bloques dentro de un bloque en C\n✓ Entiendes por qué hace falta la espera\n✓ Construiste un bucle sin fin\n\nSiguiente módulo: la placa empieza a ESCUCHARTE.',
          tipEmoji: '🏆',
          tip: 'Yanıp Sönen Işık rozetini kazandın!',
          tipEn: 'You earned the Blinking Light badge!',
          tipDe: 'Du hast das Abzeichen «Blinkendes Licht» verdient!',
          tipEs: '¡Has ganado la insignia Luz Parpadeante!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODÜL 3 — KART SENİ DİNLİYOR (ORTA)
  // ==========================================

  static final List<InteractiveLesson> module3 = [
    // ---------------------------------------------------------- Ders 3.1
    InteractiveLesson(
      id: 'mblock_3_1',
      courseId: 'mblock',
      title: 'Buton: Altıgen Blok',
      subtitle: 'dijital oku ve eğer/ise',
      titleEn: 'Button: The Hexagon Block',
      titleDe: 'Taster: der Sechseck-Block',
      titleEs: 'Botón: el bloque hexagonal',
      subtitleEn: 'read digital pin and if/then',
      subtitleDe: 'Digitalpin lesen und falls/dann',
      subtitleEs: 'lee pin digital y si/entonces',
      order: 5,
      xpReward: 55,
      steps: [
        IntroStep(
          id: 'm3_1_intro',
          mascotEmoji: '🔘',
          mascotMessage:
              'Şimdiye kadar kart hep aynı şeyi yaptı. Şimdi bir buton '
              'ekliyoruz: kart artık dışarıdan gelen bir şeye bakıp KARAR '
              'verecek.',
          mascotMessageEn:
              'Until now the board always did the same thing. Now we add a '
              'button: the board will look at something outside and make a '
              'DECISION.',
          mascotMessageDe: 'Bisher hat die Platine immer dasselbe gemacht. Jetzt kommt ein Taster dazu: Die Platine schaut auf etwas von außen und trifft eine ENTSCHEIDUNG.',
          mascotMessageEs: 'Hasta ahora la placa hacía siempre lo mismo. Ahora añadimos un botón: la placa mirará algo de fuera y tomará una DECISIÓN.',
          highlights: [
            'Altıgen bloğu kullan',
            'Koşul yuvasına yerleştir',
            'Karar veren program',
          ],
          highlightsEn: [
            'Use a hexagon block',
            'Drop it into a condition slot',
            'A program that decides',
          ],
          highlightsDe: [
            'Einen Sechseck-Block benutzen',
            'Ihn in einen Bedingungs-Schlitz ziehen',
            'Ein Programm, das entscheidet',
          ],
          highlightsEs: [
            'Usar un bloque hexagonal',
            'Soltarlo en una ranura de condición',
            'Un programa que decide',
          ],
        ),

        ExplanationStep(
          id: 'm3_1_exp1',
          title: 'dijital oku — Altıgen',
          titleEn: 'read digital pin — a Hexagon',
          titleDe: 'Digitalpin lesen – ein Sechseck',
          titleEs: 'lee pin digital: un hexágono',
          content:
              'Pin kategorisindeki bu blok bir ALTIGEN:\n\n'
              '   dijital oku pin [2]\n\n'
              'Şekli neden önemli? Çünkü altıgen bloklar sadece EVET/HAYIR '
              'verir ve sadece altıgen yuvalara girer. Bu bloğu tek başına '
              'alt alta dizemezsin.\n\n'
              'Onu "eğer ise" bloğunun koşul yerine sürüklersin. Böylece '
              '"eğer buton basılıysa..." demiş olursun.',
          contentEn:
              'This block in the Pin category is a HEXAGON:\n\n'
              '   read digital pin [2]\n\n'
              'Why does the shape matter? Because hexagon blocks return '
              'only YES/NO and only fit hexagon slots. You cannot stack '
              'this block on its own.\n\n'
              'You drag it into the condition of an "if then".',
          contentDe: 'Dieser Block in der Kategorie Pin ist ein SECHSECK:\n\n   Digitalpin lesen [2]\n\nWarum ist die Form wichtig? Weil Sechseck-Blöcke nur JA/NEIN zurückgeben und nur in Sechseck-Schlitze passen. Du kannst diesen Block nicht allein stapeln.\n\nDu ziehst ihn in die Bedingung von «falls, dann».',
          contentEs: 'Este bloque de la categoría Pin es un HEXÁGONO:\n\n   lee pin digital [2]\n\n¿Por qué importa la forma? Porque los bloques hexagonales solo devuelven SÍ/NO y solo encajan en ranuras hexagonales. Este bloque no se puede apilar solo.\n\nLo arrastras a la condición de un «si entonces».',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'dijital oku pin 2',
              contentEn: 'read digital pin 2',
              contentDe: 'Digitalpin lesen 2',
              contentEs: 'lee pin digital 2',
              color: MBlockPalette.pin,
              label: 'Pin · altıgen',
              labelEn: 'Pin · hexagon',
              labelDe: 'Pin · Sechseck',
              labelEs: 'Pin · hexágono',
            ),
          ],
          tipEmoji: '⬡',
          tip: 'Şekli hatırla: oval = sayı, altıgen = evet/hayır.',
          tipEn: 'Remember the shapes: oval = number, hexagon = yes/no.',
          tipDe: 'Merke dir die Formen: oval = Zahl, Sechseck = ja/nein.',
          tipEs: 'Recuerda las formas: óvalo = número, hexágono = sí/no.',
        ),

        ExplanationStep(
          id: 'm3_1_exp2',
          title: 'Eğer / İse',
          titleEn: 'If / Then',
          titleDe: 'Falls / dann',
          titleEs: 'Si / entonces',
          content:
              'Kontrol kategorisindeki "eğer <> ise" bloğu bir C bloğudur '
              've ortasında altıgen bir boşluk vardır.\n\n'
              'eğer <dijital oku pin 2> ise\n'
              '   dijital ayarla pin 9 çıkış yüksek\n\n'
              'Bu program şunu diyor: butona bakıyorum; basılıysa LED\'i '
              'yak, değilse hiçbir şey yapma.\n\n'
              'Ama dikkat: LED\'i SÖNDÜREN bir şey yok. Bir kez yandığında '
              'yanık kalır. Söndürmek için ikinci bir "eğer" ya da bir '
              '"değilse" dalı gerekir.',
          contentEn:
              'The "if <> then" block in Control is a C block with a '
              'hexagon gap in the middle.\n\n'
              'if <read digital pin 2> then\n'
              '   set digital pin 9 output as high\n\n'
              'This says: look at the button; if it is pressed, light the '
              'LED, otherwise do nothing.\n\n'
              'But careful: nothing turns the LED OFF. Once lit it stays '
              'lit. You need a second "if" or an "else" branch.',
          contentDe: 'Der Block «falls <>, dann» in Steuerung ist ein C-Block mit einer Sechseck-Lücke in der Mitte.\n\nfalls <Digitalpin lesen 2>, dann\n   digitalen Pin von Ausgang 9 als hoch setzen\n\nDas heißt: Schau auf den Taster; wenn er gedrückt ist, lass die LED leuchten, sonst tu nichts.\n\nAber Achtung: Nichts schaltet die LED AUS. Einmal an, bleibt sie an. Du brauchst ein zweites «falls» oder einen «sonst»-Zweig.',
          contentEs: 'El bloque «si <> entonces» de Control es un bloque en C con un hueco hexagonal en medio.\n\nsi <lee pin digital 2> entonces\n   pon el pin digital 9 a alto\n\nDice: mira el botón; si está pulsado, enciende el LED; si no, no hagas nada.\n\nPero cuidado: nada APAGA el LED. Una vez encendido, se queda encendido. Necesitas un segundo «si» o una rama «si no».',
          tipEmoji: '🤔',
          tip: 'Bir şeyi açan her programda, onu kapatan bir şey de '
              'olmalı. Yoksa geri dönüşü olmaz.',
          tipEn: 'Every program that turns something on needs something '
              'that turns it off.',
          tipDe: 'Jedes Programm, das etwas einschaltet, braucht auch etwas, das es ausschaltet.',
          tipEs: 'Todo programa que enciende algo necesita algo que lo apague.',
        ),

        BlockBuilderStep(
          id: 'm3_1_build1',
          instruction:
              'Butona basılıyken LED yansın, bırakılınca sönsün.',
          instructionEn:
              'Light the LED while the button is held, turn it off when '
              'released.',
          instructionDe: 'Lass die LED leuchten, solange der Taster gedrückt ist, und schalte sie beim Loslassen aus.',
          instructionEs: 'Enciende el LED mientras el botón esté pulsado y apágalo al soltarlo.',
          goal: 'İki koşul: basılıysa yak, basılı değilse söndür',
          goalEn: 'Two conditions: pressed → on, not pressed → off',
          goalDe: 'Zwei Bedingungen: gedrückt → an, nicht gedrückt → aus',
          goalEs: 'Dos condiciones: pulsado → encendido, sin pulsar → apagado',
          availableBlocks: [
            MBlockBlocks.boardLaunch(),
            MBlockBlocks.forever(),
            MBlockBlocks.ifThen('dijital oku pin 2',
                conditionEn: 'read digital pin 2',
                conditionDe: 'Digitalpin lesen 2',
                conditionEs: 'lee pin digital 2', id: 'if_pressed'),
            MBlockBlocks.digitalWrite('9', 'yüksek', id: 'led_on'),
            MBlockBlocks.ifThen('dijital oku pin 2 = hayır',
                conditionEn: 'read digital pin 2 = no',
                conditionDe: 'Digitalpin lesen 2 = nein',
                conditionEs: 'lee pin digital 2 = no',
                id: 'if_released'),
            MBlockBlocks.digitalWrite('9', 'düşük', id: 'led_off'),
          ],
          correctSequence: [
            'board_launch',
            'forever',
            'if_pressed',
            'led_on',
            'if_released',
            'led_off',
          ],
          xpReward: 40,
        ),

        MultipleChoiceStep(
          id: 'm3_1_q1',
          question:
              '"dijital oku pin 2" bloğunu neden alt alta dizemezsin?',
          questionEn:
              'Why can you not stack the "read digital pin 2" block?',
          questionDe: 'Warum kannst du den Block «Digitalpin lesen 2» nicht stapeln?',
          questionEs: '¿Por qué no puedes apilar el bloque «lee pin digital 2»?',
          options: [
            ChoiceOption(text: 'Altıgen; üstünde çentik, altında çıkıntı yok', textEn: 'It is a hexagon: no notch on top, no bump below', textDe: 'Es ist ein Sechseck: oben keine Kerbe, unten keine Nase', textEs: 'Es un hexágono: sin muesca arriba ni saliente abajo'),
            ChoiceOption(text: 'Yalnızca canlı modda çalışıyor', textEn: 'It only works in live mode', textDe: 'Er funktioniert nur im Live-Modus', textEs: 'Solo funciona en modo en vivo'),
            ChoiceOption(text: 'Önce bir değişken tanımlamak gerekiyor', textEn: 'You must define a variable first', textDe: 'Du musst zuerst eine Variable definieren', textEs: 'Primero tienes que definir una variable'),
            ChoiceOption(text: 'Dizilebilir, sadece yavaş çalışır', textEn: 'You can, it is just slow', textDe: 'Man kann, es ist nur langsam', textEs: 'Se puede, solo que es lento'),
          ],
          correctIndex: 0,
          explanation:
              'Şekil kuralı koyar. Altıgenin takılacak çentiği yok, sadece '
              'altıgen bir boşluğa oturur.',
          explanationEn:
              'The shape sets the rule. A hexagon has no notch to stack '
              'with; it only sits in a hexagon gap.',
          explanationDe: 'Die Form bestimmt die Regel. Ein Sechseck hat keine Kerbe zum Stapeln; es sitzt nur in einer Sechseck-Lücke.',
          explanationEs: 'La forma marca la regla. Un hexágono no tiene muesca para apilarse; solo se mete en un hueco hexagonal.',
          xpReward: 15,
        ),
      ],
    ),

    // ---------------------------------------------------------- Ders 3.2
    InteractiveLesson(
      id: 'mblock_3_2',
      courseId: 'mblock',
      title: 'Potansiyometre ve Harita',
      subtitle: 'analog oku, 0-1023, PWM',
      titleEn: 'Potentiometer and Map',
      titleDe: 'Potentiometer und Karte',
      titleEs: 'Potenciómetro y mapear',
      subtitleEn: 'analog read, 0-1023, PWM',
      subtitleDe: 'analogen Pin lesen, 0-1023, PWM',
      subtitleEs: 'lee pin analógico, 0-1023, PWM',
      order: 6,
      xpReward: 60,
      steps: [
        IntroStep(
          id: 'm3_2_intro',
          mascotEmoji: '🎛️',
          mascotMessage:
              'Buton iki şey söyleyebiliyordu: basılı ya da değil. '
              'Potansiyometre ise ARADAKİ her değeri söyleyebilir. Şimdi '
              'LED\'i yakıp söndürmeyi değil, parlaklığını ayarlamayı '
              'öğreneceksin.',
          mascotMessageEn:
              'A button can say two things: pressed or not. A potentiometer '
              'can say everything in between. Now you will not just switch '
              'the LED — you will dim it.',
          mascotMessageDe: 'Ein Taster kann zwei Dinge sagen: gedrückt oder nicht. Ein Potentiometer kann alles dazwischen sagen. Jetzt schaltest du die LED nicht nur ein – du dimmst sie.',
          mascotMessageEs: 'Un botón puede decir dos cosas: pulsado o no. Un potenciómetro puede decir todo lo que hay en medio. Ahora no solo encenderás el LED: lo atenuarás.',
          highlights: [
            'analog oku: 0-1023',
            'PWM: 0-255',
            'Harita bloğuyla çevirme',
          ],
          highlightsEn: [
            'analog read: 0-1023',
            'PWM: 0-255',
            'Converting with the map block',
          ],
          highlightsDe: [
            'analogen Pin lesen: 0-1023',
            'PWM: 0-255',
            'Umrechnen mit dem Block «Karte»',
          ],
          highlightsEs: [
            'lee pin analógico: 0-1023',
            'PWM: 0-255',
            'Convertir con el bloque mapear',
          ],
        ),

        ExplanationStep(
          id: 'm3_2_exp1',
          title: 'analog oku — Oval',
          titleEn: 'read analog pin — an Oval',
          titleDe: 'analogen Pin lesen – ein Oval',
          titleEs: 'lee pin analógico: un óvalo',
          content:
              'Bu blok OVAL, yani bir SAYI verir:\n\n'
              '   analog oku pin (A) [0]\n\n'
              'Verdiği sayı 0 ile 1023 arasındadır. 0 volt → 0, 5 volt → '
              '1023. Aradaki her voltaj aradaki bir sayıya denk gelir.\n\n'
              'Neden 1023? Kartın ölçüm devresi 10 bitlik; 2 üzeri 10 = '
              '1024 farklı kademe, 0\'dan sayınca en büyüğü 1023.\n\n'
              'Analog pinler A0-A5 arası. Blokta yalnızca RAKAMI '
              'yazıyorsun: A0 için 0.',
          contentEn:
              'This block is OVAL, so it gives a NUMBER:\n\n'
              '   read analog pin (A) [0]\n\n'
              'The number is between 0 and 1023. 0 volts → 0, 5 volts → '
              '1023.\n\n'
              'Why 1023? The measuring circuit is 10-bit: 2^10 = 1024 '
              'steps, and counting from 0 the largest is 1023.\n\n'
              'Analog pins are A0-A5. In the block you type only the '
              'number: 0 for A0.',
          contentDe: 'Dieser Block ist OVAL, er gibt also eine ZAHL:\n\n   analogen Pin（A）[0] lesen\n\nDie Zahl liegt zwischen 0 und 1023. 0 Volt → 0, 5 Volt → 1023.\n\nWarum 1023? Die Messschaltung ist 10-Bit: 2^10 = 1024 Stufen, und von 0 an gezählt ist die größte 1023.\n\nDie Analogpins sind A0-A5. In den Block schreibst du nur die Zahl: 0 für A0.',
          contentEs: 'Este bloque es OVALADO, así que da un NÚMERO:\n\n   lee pin analógico [0]\n\nEl número está entre 0 y 1023. 0 voltios → 0, 5 voltios → 1023.\n\n¿Por qué 1023? El circuito de medida es de 10 bits: 2^10 = 1024 pasos, y contando desde 0 el mayor es 1023.\n\nLos pines analógicos son A0-A5. En el bloque escribes solo el número: 0 para A0.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'analog oku pin (A) 0',
              contentEn: 'read analog pin (A) 0',
              contentDe: 'analogen Pin（A）0 lesen',
              contentEs: 'lee pin analógico 0',
              color: MBlockPalette.pin,
              label: 'Pin · oval',
              labelEn: 'Pin · oval',
              labelDe: 'Pin · oval',
              labelEs: 'Pin · óvalo',
            ),
          ],
          tipEmoji: '📏',
          tip: 'Analog = "arada her değer olabilir". Dijital = "ya var ya '
              'yok".',
          tipEn: 'Analog means "anything in between". Digital means "on or '
              'off".',
          tipDe: 'Analog heißt «alles dazwischen». Digital heißt «an oder aus».',
          tipEs: 'Analógico significa «todo lo que hay en medio». Digital significa «encendido o apagado».',
        ),

        ExplanationStep(
          id: 'm3_2_exp2',
          title: 'PWM: Yarım Yanan LED',
          titleEn: 'PWM: a Half-Lit LED',
          titleDe: 'PWM: eine halb leuchtende LED',
          titleEs: 'PWM: un LED a media luz',
          content:
              'LED\'i yarı parlak yakmak için pini çok hızlı açıp '
              'kapatıyoruz. Zamanın yarısında açıksa, göz onu yarı parlak '
              'görüyor. Buna PWM deniyor.\n\n'
              '   PWM ayarla pin[5] çıkış [128]\n\n'
              'Değer 0 ile 255 arasında: 0 sönük, 255 tam parlak.\n\n'
              'ÇOK ÖNEMLİ: PWM her pinde çalışmaz. Uno\'da yalnızca '
              '3, 5, 6, 9, 10, 11 numaralı pinler PWM yapabilir. Kartta bu '
              'pinlerin yanında küçük bir ~ işareti vardır.',
          contentEn:
              'To make an LED half bright we switch the pin on and off very '
              'fast. If it is on half the time, your eye sees half '
              'brightness. This is called PWM.\n\n'
              '   set PWM [5] output as [128]\n\n'
              'The value is 0 to 255: 0 is off, 255 is full.\n\n'
              'IMPORTANT: PWM does not work on every pin. On the Uno only '
              'pins 3, 5, 6, 9, 10 and 11 can do PWM. They are marked with '
              'a small ~ on the board.',
          contentDe: 'Damit eine LED halb hell leuchtet, schalten wir den Pin sehr schnell an und aus. Ist er die halbe Zeit an, sieht dein Auge halbe Helligkeit. Das heißt PWM.\n\n   PWM-Ausgang [5] als [128] festlegen\n\nDer Wert geht von 0 bis 255: 0 ist aus, 255 ist voll.\n\nWICHTIG: PWM geht nicht an jedem Pin. Beim Uno können nur die Pins 3, 5, 6, 9, 10 und 11 PWM. Sie sind auf der Platine mit einem kleinen ~ markiert.',
          contentEs: 'Para que un LED brille a la mitad, encendemos y apagamos el pin muy deprisa. Si está encendido la mitad del tiempo, tu ojo ve la mitad de brillo. Esto se llama PWM.\n\n   pon la salida PWM [5] a [128]\n\nEl valor va de 0 a 255: 0 es apagado, 255 es al máximo.\n\nIMPORTANTE: el PWM no funciona en todos los pines. En el Uno solo pueden hacer PWM los pines 3, 5, 6, 9, 10 y 11. Están marcados con una pequeña ~ en la placa.',
          tipEmoji: '〰️',
          tip: 'Karttaki ~ işareti "bu pin PWM yapabilir" demek. mBlock '
              'seni uyarmaz — yanlış pin seçersen program yüklenir ama LED '
              'sadece açık/kapalı olur.',
          tipEn: 'The ~ on the board means the pin can do PWM. mBlock will '
              'not warn you.',
          tipDe: 'Das ~ auf der Platine heißt, dass der Pin PWM kann. mBlock warnt dich nicht.',
          tipEs: 'La ~ de la placa significa que el pin puede hacer PWM. mBlock no te avisará.',
        ),

        MultipleChoiceStep(
          id: 'm3_2_q1',
          question: 'Hangi pin PWM yapabilir?',
          questionEn: 'Which pin can do PWM?',
          questionDe: 'Welcher Pin kann PWM?',
          questionEs: '¿Qué pin puede hacer PWM?',
          options: [
            ChoiceOption(text: '6', textEn: '6', textDe: '6', textEs: '6'),
            ChoiceOption(text: '4', textEn: '4', textDe: '4', textEs: '4'),
            ChoiceOption(text: '7', textEn: '7', textDe: '7', textEs: '7'),
            ChoiceOption(text: '12', textEn: '12', textDe: '12', textEs: '12'),
          ],
          correctIndex: 0,
          explanation:
              'Uno\'da PWM pinleri 3, 5, 6, 9, 10 ve 11. Diğerleri sadece '
              'açık/kapalı yapabilir.',
          explanationEn:
              'The Uno\'s PWM pins are 3, 5, 6, 9, 10 and 11. The others '
              'can only do on/off.',
          explanationDe: 'Die PWM-Pins des Uno sind 3, 5, 6, 9, 10 und 11. Die anderen können nur an/aus.',
          explanationEs: 'Los pines PWM del Uno son 3, 5, 6, 9, 10 y 11. Los demás solo pueden encender/apagar.',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'm3_2_exp3',
          title: 'İki Aralığı Birbirine Çevirmek',
          titleEn: 'Converting One Range into Another',
          titleDe: 'Einen Bereich in einen anderen umrechnen',
          titleEs: 'Convertir un rango en otro',
          content:
              'Bir sorun var: potansiyometre 0-1023 veriyor, PWM ise '
              '0-255 istiyor. Doğrudan bağlarsan 255\'ten sonrası '
              'anlamsızlaşır.\n\n'
              'Veri kategorisindeki (mor) Harita bloğu tam bunun için:\n\n'
              '   Harita [analog oku pin (A) 0] konumundan (0, 1023) '
              'için (0, 255)\n\n'
              'Bu blok "bu sayı 0-1023 aralığındaydı, onu 0-255 aralığına '
              'taşı" diyor. 1023 → 255, 512 → yaklaşık 128 olur.',
          contentEn:
              'There is a problem: the potentiometer gives 0-1023 but PWM '
              'wants 0-255.\n\n'
              'The map block in the Data category (purple) is exactly for '
              'this:\n\n'
              '   map [read analog pin (A) 0] from (0, 1023) to (0, 255)\n\n'
              'It says "this number was in the range 0-1023, move it into '
              'the range 0-255".',
          contentDe: 'Es gibt ein Problem: Das Potentiometer gibt 0-1023, PWM will aber 0-255.\n\nGenau dafür ist der Block «Karte» in der Kategorie Daten (lila):\n\n   Karte [analogen Pin（A）0 lesen] Von ( 0 , 1023 ) zu ( 0 , 255 ）\n\nEr sagt: «Diese Zahl war im Bereich 0-1023, bring sie in den Bereich 0-255».',
          contentEs: 'Hay un problema: el potenciómetro da 0-1023 pero el PWM quiere 0-255.\n\nEl bloque «mapear» de la categoría Datos (morado) es justo para esto:\n\n   mapear [lee pin analógico 0] de (0, 1023) a (0, 255）\n\nDice «este número estaba en el rango 0-1023, llévalo al rango 0-255».',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Harita [x] konumundan (0, 1023) için (0, 255)',
              contentEn: 'map [x] from (0, 1023) to (0, 255)',
              contentDe: 'Karte [x] Von ( 0 , 1023 ) zu ( 0 , 255 ）',
              contentEs: 'mapear [x] de (0, 1023) a (0, 255）',
              color: MBlockPalette.data,
              label: 'Veri · oval',
              labelEn: 'Data · oval',
              labelDe: 'Daten · oval',
              labelEs: 'Datos · óvalo',
            ),
          ],
          tipEmoji: '🗺️',
          tip: 'Harita bloğu Veri kategorisinde (mor), Değişkenler '
              'kategorisinde (turuncu) DEĞİL.',
          tipEn: 'The map block is in Data (purple), not Variables '
              '(orange).',
          tipDe: 'Der Block «Karte» ist in Daten (lila), nicht in Variablen (orange).',
          tipEs: 'El bloque mapear está en Datos (morado), no en Variables (naranja).',
        ),

        BlockBuilderStep(
          id: 'm3_2_build1',
          instruction:
              'Potansiyometreyi çevirdikçe LED\'in parlaklığı değişsin.',
          instructionEn:
              'Make the LED brightness follow the potentiometer.',
          instructionDe: 'Sorge dafür, dass die Helligkeit der LED dem Potentiometer folgt.',
          instructionEs: 'Haz que el brillo del LED siga al potenciómetro.',
          goal: 'A0\'ı oku, 0-255\'e çevir, 5. pine PWM olarak ver',
          goalEn: 'Read A0, map to 0-255, send as PWM to pin 5',
          goalDe: 'A0 lesen, auf 0-255 umrechnen, als PWM an Pin 5 geben',
          goalEs: 'Leer A0, mapear a 0-255, enviar como PWM al pin 5',
          availableBlocks: [
            MBlockBlocks.boardLaunch(),
            MBlockBlocks.forever(),
            MBlockBlocks.setVariable(
                'parlaklik', 'Harita [analog oku pin (A) 0] (0,1023) → (0,255)',
                valueEn:
                    'map [read analog pin (A) 0] from (0,1023) to (0,255)',
                valueDe: 'Karte [analogen Pin（A）0 lesen] Von ( 0 , 1023 ) zu ( 0 , 255 ）',
                valueEs: 'mapear [lee pin analógico 0] de (0,1023) a (0,255）',
                id: 'set_brightness'),
            MBlockBlocks.pwmWrite('5', 'parlaklik', id: 'pwm_out'),
          ],
          correctSequence: [
            'board_launch',
            'forever',
            'set_brightness',
            'pwm_out',
          ],
          xpReward: 40,
        ),

        MultipleChoiceStep(
          id: 'm3_2_q2',
          question:
              'Potansiyometreyi sonuna kadar çevirdin. analog oku ne verir?',
          questionEn:
              'You turned the potentiometer all the way. What does analog '
              'read give?',
          questionDe: 'Du hast das Potentiometer ganz aufgedreht. Was gibt «analogen Pin lesen»?',
          questionEs: 'Has girado el potenciómetro del todo. ¿Qué da «lee pin analógico»?',
          options: [
            ChoiceOption(text: '1023', textEn: '1023', textDe: '1023', textEs: '1023'),
            ChoiceOption(text: '255', textEn: '255', textDe: '255', textEs: '255'),
            ChoiceOption(text: '100', textEn: '100', textDe: '100', textEs: '100'),
            ChoiceOption(text: '5', textEn: '5', textDe: '5', textEs: '5'),
          ],
          correctIndex: 0,
          explanation:
              'analog oku 0-1023 arası verir. 255 PWM\'in üst sınırı, '
              'analog okumanın değil — ikisini karıştırmamak lazım.',
          explanationEn:
              'analog read gives 0-1023. 255 is the top of PWM, not of the '
              'analog reading.',
          explanationDe: '«analogen Pin lesen» gibt 0-1023. 255 ist die Obergrenze von PWM, nicht die des Analogwerts.',
          explanationEs: '«lee pin analógico» da 0-1023. 255 es el máximo del PWM, no el de la lectura analógica.',
          xpReward: 15,
        ),
      ],
    ),
  ];

  // ==========================================
  // MODÜL 4 — BÜYÜK PROJELER
  // ==========================================

  static final List<InteractiveLesson> module4 = [
    // ---------------------------------------------------------- Ders 4.1
    InteractiveLesson(
      id: 'mblock_4_1',
      courseId: 'mblock',
      title: 'Mesafe Sensörü ve Park Alarmı',
      subtitle: 'Sensör kategorisi ve seri port',
      titleEn: 'Distance Sensor and Parking Alarm',
      titleDe: 'Abstandssensor und Einparkhilfe',
      titleEs: 'Sensor de distancia y alarma de aparcamiento',
      subtitleEn: 'The Sensor category and serial port',
      subtitleDe: 'Die Kategorie sensor und die serielle Schnittstelle',
      subtitleEs: 'La categoría Sensor y el puerto serie',
      order: 7,
      xpReward: 65,
      steps: [
        IntroStep(
          id: 'm4_1_intro',
          mascotEmoji: '📡',
          mascotMessage:
              'Şimdi kartın "görmesini" sağlayacağız. Mesafe sensörü ses '
              'dalgası gönderip geri dönmesini bekliyor — tıpkı yarasalar '
              'gibi. Arabaların park sensörü de aynı şeyi yapıyor.',
          mascotMessageEn:
              'Now we will let the board "see". The distance sensor sends '
              'a sound pulse and waits for it to come back — like a bat. '
              'Car parking sensors work the same way.',
          mascotMessageDe: 'Jetzt lassen wir die Platine «sehen». Der Abstandssensor schickt einen Schallimpuls und wartet, bis er zurückkommt – wie eine Fledermaus. Einparkhilfen im Auto arbeiten genauso.',
          mascotMessageEs: 'Ahora vamos a hacer que la placa «vea». El sensor de distancia envía un pulso de sonido y espera a que vuelva, como un murciélago. Los sensores de aparcamiento de los coches funcionan igual.',
          highlights: [
            'Sensör kategorisi',
            'Mesafeye göre karar',
            'Seri portla hata bulma',
          ],
          highlightsEn: [
            'The Sensor category',
            'Deciding by distance',
            'Debugging with the serial port',
          ],
          highlightsDe: [
            'Die Kategorie sensor',
            'Nach Abstand entscheiden',
            'Fehlersuche mit der seriellen Schnittstelle',
          ],
          highlightsEs: [
            'La categoría Sensor',
            'Decidir según la distancia',
            'Depurar con el puerto serie',
          ],
        ),

        ExplanationStep(
          id: 'm4_1_exp1',
          title: 'Mesafe Bloğu',
          titleEn: 'The Distance Block',
          titleDe: 'Der Abstandsblock',
          titleEs: 'El bloque de distancia',
          content:
              'Sensör kategorisindeki (açık mavi) blok bu:\n\n'
              '   mesafe algılayıcı [13] trig pin [12] echo pin\n\n'
              'Türkçesi biraz garip görünüyor: kutular yazılardan ÖNCE '
              'geliyor. Birinci kutu trig, ikinci kutu echo pini.\n\n'
              'Blok OVAL, yani bir sayı verir — santimetre cinsinden '
              'mesafe.\n\n'
              'trig = sensörün ses gönderdiği bacak\n'
              'echo = sesin döndüğünü duyduğu bacak',
          contentEn:
              'This is the block in the Sensor category (light blue):\n\n'
              '   read ultrasonic sensor trig pin [13] echo pin [12]\n\n'
              'The block is OVAL, so it gives a number — the distance in '
              'centimetres.\n\n'
              'trig = the leg that sends the sound\n'
              'echo = the leg that hears it come back',
          contentDe: 'Das ist der Block in der Kategorie sensor (hellblau):\n\n   read ultrasonic sensor trig pin [13] echo pin [12]\n\nDer Block ist OVAL, er gibt also eine Zahl – den Abstand in Zentimetern.\n\ntrig = das Bein, das den Schall sendet\necho = das Bein, das ihn zurückkommen hört',
          contentEs: 'Este es el bloque de la categoría Sensor (azul claro):\n\n   lee sensor de ultrasonidos, pin de activación [13], pin de eco [12]\n\nEl bloque es OVALADO, así que da un número: la distancia en centímetros.\n\nactivación (trig) = la pata que envía el sonido\neco = la pata que lo oye volver',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'mesafe algılayıcı 13 trig pin 12 echo pin',
              contentEn: 'read ultrasonic sensor trig pin 13 echo pin 12',
              contentDe: 'read ultrasonic sensor trig pin 13 echo pin 12',
              contentEs: 'lee sensor de ultrasonidos, pin de activación 13, pin de eco 12',
              color: MBlockPalette.sensor,
              label: 'Sensör · oval',
              labelEn: 'Sensor · oval',
              labelDe: 'sensor · oval',
              labelEs: 'Sensor · óvalo',
            ),
          ],
          tipEmoji: '⚠️',
          tip: 'Bu blok CANLI MODDA GRİ görünür. Mesafe sensörü sadece '
              'yükleme modunda çalışır.',
          tipEn: 'This block is GREYED OUT in live mode. The distance '
              'sensor only works in upload mode.',
          tipDe: 'Dieser Block ist im Live-Modus AUSGEGRAUT. Der Abstandssensor läuft nur im Upload-Modus.',
          tipEs: 'Este bloque está EN GRIS en modo en vivo. El sensor de distancia solo funciona en modo de subida.',
        ),

        ExplanationStep(
          id: 'm4_1_exp2',
          title: 'Seri Port: Kartın Konuşması',
          titleEn: 'The Serial Port: the Board Speaks',
          titleDe: 'Die serielle Schnittstelle: die Platine spricht',
          titleEs: 'El puerto serie: la placa habla',
          content:
              'Sensör bir şey ölçüyor ama sen göremiyorsun. Seri port '
              'blokları tam bunun için:\n\n'
              '   seri porta [mesafe algılayıcı ...] yaz\n\n'
              'Bu blok, ölçtüğü sayıyı bilgisayara gönderir; mBlock\'ta '
              'seri port ekranını açıp okursun.\n\n'
              'Bir şey çalışmadığında ilk yapılacak iş budur: sensörün '
              'gerçekten ne okuduğuna bak. Çoğu zaman sorun kodda değil, '
              'kabloda çıkar.',
          contentEn:
              'The sensor measures something but you cannot see it. That is '
              'what the serial blocks are for:\n\n'
              '   write [read ultrasonic sensor ...] to serial port\n\n'
              'This sends the number to the computer; you open the serial '
              'monitor in mBlock to read it.\n\n'
              'When something does not work, this is the first thing to do.',
          contentDe: 'Der Sensor misst etwas, aber du kannst es nicht sehen. Dafür sind die seriellen Blöcke da:\n\n   [read ultrasonic sensor ...] an serielle Schnittstelle schreiben\n\nDas schickt die Zahl an den Computer; du öffnest in mBlock den seriellen Monitor, um sie zu lesen.\n\nWenn etwas nicht funktioniert, ist das das Erste, was du tust.',
          contentEs: 'El sensor mide algo pero tú no lo ves. Para eso están los bloques de puerto serie:\n\n   escribe [lee sensor de ultrasonidos ...] al puerto serie\n\nEsto envía el número al ordenador; abres el monitor serie en mBlock para leerlo.\n\nCuando algo no funciona, esto es lo primero que hay que hacer.',
          tipEmoji: '🐞',
          tip: 'Seri port blokları da canlı modda gri. Ayrıca 0 ve 1 '
              'numaralı pinler seri port için kullanılır — onları başka '
              'bir şeye bağlama.',
          tipEn: 'Serial blocks are greyed out in live mode too. Pins 0 and '
              '1 are used by the serial port — do not wire anything else '
              'to them.',
          tipDe: 'Serielle Blöcke sind im Live-Modus ebenfalls ausgegraut. Die Pins 0 und 1 gehören der seriellen Schnittstelle – schließe dort nichts anderes an.',
          tipEs: 'Los bloques de puerto serie también están en gris en modo en vivo. Los pines 0 y 1 los usa el puerto serie: no conectes nada más ahí.',
        ),

        MultipleChoiceStep(
          id: 'm4_1_q1',
          question:
              'Mesafe sensörü bloğu canlı modda gri görünüyor. Neden?',
          questionEn:
              'The distance sensor block is greyed out in live mode. Why?',
          questionDe: 'Der Abstandssensor-Block ist im Live-Modus ausgegraut. Warum?',
          questionEs: 'El bloque del sensor de distancia está en gris en modo en vivo. ¿Por qué?',
          options: [
            ChoiceOption(text: 'Bu blok yalnızca yükleme modunda çalışır', textEn: 'The block only works in upload mode', textDe: 'Der Block funktioniert nur im Upload-Modus', textEs: 'El bloque solo funciona en modo de subida'),
            ChoiceOption(text: 'Sensör bozuk', textEn: 'The sensor is broken', textDe: 'Der Sensor ist kaputt', textEs: 'El sensor está roto'),
            ChoiceOption(text: 'Kablolar yanlış takılmış', textEn: 'The wiring is wrong', textDe: 'Die Verkabelung ist falsch', textEs: 'El cableado está mal'),
            ChoiceOption(text: 'Önce bir değişken tanımlamak gerekiyor', textEn: 'You must define a variable first', textDe: 'Du musst zuerst eine Variable definieren', textEs: 'Primero tienes que definir una variable'),
          ],
          correctIndex: 0,
          explanation:
              'mBlock bazı blokları modun dışında kapatıyor. Mesafe '
              'sensörü, buzzer ve seri port blokları yalnızca yükleme '
              'modunda kullanılabiliyor.',
          explanationEn:
              'mBlock disables some blocks outside their mode. The distance '
              'sensor, the buzzer and the serial blocks only work in upload '
              'mode.',
          explanationDe: 'mBlock schaltet manche Blöcke außerhalb ihres Modus ab. Der Abstandssensor, der Summer und die seriellen Blöcke laufen nur im Upload-Modus.',
          explanationEs: 'mBlock desactiva algunos bloques fuera de su modo. El sensor de distancia, el zumbador y los bloques de puerto serie solo funcionan en modo de subida.',
          xpReward: 15,
        ),

        ProjectStep(
          id: 'm4_1_project',
          title: 'Proje: Park Sensörü',
          titleEn: 'Project: Parking Sensor',
          titleDe: 'Projekt: Einparkhilfe',
          titleEs: 'Proyecto: sensor de aparcamiento',
          description:
              'Engel yaklaştıkça daha hızlı öten bir park sensörü yap.',
          descriptionEn:
              'Build a parking sensor that beeps faster as the obstacle '
              'gets closer.',
          descriptionDe: 'Baue eine Einparkhilfe, die schneller piept, je näher das Hindernis kommt.',
          descriptionEs: 'Construye un sensor de aparcamiento que pite más rápido cuanto más cerca esté el obstáculo.',
          requirements: [
            'Mesafeyi bir değişkene oku',
            'Mesafeyi seri porta yaz (kontrol için)',
            '30 cm\'den yakınsa buzzer ötsün',
            '10 cm\'den yakınsa aralık kısalsın',
          ],
          requirementsEn: [
            'Read the distance into a variable',
            'Write the distance to the serial port (to check)',
            'Beep when closer than 30 cm',
            'Beep faster when closer than 10 cm',
          ],
          requirementsDe: [
            'Den Abstand in eine Variable lesen',
            'Den Abstand an die serielle Schnittstelle schreiben (zum Prüfen)',
            'Piepen, wenn es näher als 30 cm ist',
            'Schneller piepen, wenn es näher als 10 cm ist',
          ],
          requirementsEs: [
            'Leer la distancia en una variable',
            'Escribir la distancia al puerto serie (para comprobar)',
            'Pitar cuando esté a menos de 30 cm',
            'Pitar más rápido cuando esté a menos de 10 cm',
          ],
          hints: [
            'mesafe değişkenini <mesafe algılayıcı 13 trig 12 echo> yap',
            'eğer <mesafe < 30> ise → pinde çal 8 nota C4 ile 0.25 vuruş',
            'eğer <mesafe < 10> ise → bekleme süresini kısalt',
          ],
          hintsEn: [
            'set distance to <read ultrasonic sensor trig 13 echo 12>',
            'if <distance < 30> then → play pin 8 with note C4 for 0.25 beats',
            'if <distance < 10> then → shorten the wait',
          ],
          hintsDe: [
            'setze abstand auf <read ultrasonic sensor trig pin 13 echo pin 12>',
            'falls <abstand < 30>, dann → Pin8 spielt Note C4 tür 0.25 Schläge',
            'falls <abstand < 10>, dann → das Warten verkürzen',
          ],
          hintsEs: [
            'dar a distancia el valor <lee sensor de ultrasonidos, pin de activación 13, pin de eco 12>',
            'si <distancia < 30> entonces → toca nota C4 en pin 8 durante 0.25 tiempos',
            'si <distancia < 10> entonces → acortar la espera',
          ],
          starterCode: '',
          language: 'mblock',
          // NOT: mustContain hicbir ekranda okunmuyor (bkz. ders icerigi
          // denetimi). Buraya gercekci belirtecler yaziyoruz ki dogrulama
          // bir gun baglandiginda anlamli olsun.
          validation: ProjectValidation(
            mustContain: ['mesafe algılayıcı', 'eğer', 'pinde çal'],
          ),
          xpReward: 60,
        ),
      ],
    ),

    // ---------------------------------------------------------- Ders 4.2
    InteractiveLesson(
      id: 'mblock_4_2',
      courseId: 'mblock',
      title: 'Final Proje: Otomatik Bariyer',
      subtitle: 'Sensör + servo + buzzer bir arada',
      titleEn: 'Final Project: Automatic Barrier',
      titleDe: 'Abschlussprojekt: automatische Schranke',
      titleEs: 'Proyecto final: barrera automática',
      subtitleEn: 'Sensor, servo and buzzer together',
      subtitleDe: 'Sensor, Servo und Summer zusammen',
      subtitleEs: 'Sensor, servo y zumbador juntos',
      order: 8,
      xpReward: 80,
      steps: [
        IntroStep(
          id: 'm4_2_intro',
          mascotEmoji: '🚧',
          mascotMessage:
              'Son proje: otoparkların girişindeki bariyer. Araba '
              'yaklaşınca kolu kaldıracak, geçtikten sonra indirecek. '
              'Öğrendiğin her şey burada bir arada.',
          mascotMessageEn:
              'The final project: the barrier at a car park entrance. It '
              'lifts when a car comes close and lowers after it passes. '
              'Everything you learned, together.',
          mascotMessageDe: 'Das Abschlussprojekt: die Schranke an der Einfahrt eines Parkplatzes. Sie hebt sich, wenn ein Auto näher kommt, und senkt sich, wenn es durch ist. Alles, was du gelernt hast, zusammen.',
          mascotMessageEs: 'El proyecto final: la barrera de la entrada de un aparcamiento. Se levanta cuando se acerca un coche y baja cuando ha pasado. Todo lo que has aprendido, junto.',
          highlights: [
            'Servo motoru kontrol et',
            'Sensörle karar ver',
            'Üç parçayı birleştir',
          ],
          highlightsEn: [
            'Control a servo motor',
            'Decide with a sensor',
            'Combine three parts',
          ],
          highlightsDe: [
            'Einen Servomotor steuern',
            'Mit einem Sensor entscheiden',
            'Drei Teile kombinieren',
          ],
          highlightsEs: [
            'Controlar un servomotor',
            'Decidir con un sensor',
            'Combinar tres partes',
          ],
        ),

        ExplanationStep(
          id: 'm4_2_exp1',
          title: 'Servo Motor',
          titleEn: 'The Servo Motor',
          titleDe: 'Der Servomotor',
          titleEs: 'El servomotor',
          content:
              'Servo, istediğin AÇIYA dönen bir motordur. Normal motor gibi '
              'sürekli dönmez; 0 ile 180 derece arasında bir yere gider ve '
              'orada durur.\n\n'
              '   servo pin [9] açı [90]\n\n'
              'Bariyer için: 0 derece kapalı, 90 derece açık.\n\n'
              'Servo bunu nasıl yapıyor? İçinde, mile bağlı küçük bir '
              'potansiyometre var. Motor dönerken kendi açısını ölçüyor ve '
              'istenen açıya gelince duruyor.',
          contentEn:
              'A servo turns to the ANGLE you ask for. Unlike a normal '
              'motor it does not spin continuously; it goes somewhere '
              'between 0 and 180 degrees and stays there.\n\n'
              '   set servo pin [9] angle as [90]\n\n'
              'For the barrier: 0 degrees closed, 90 degrees open.\n\n'
              'How does it know? Inside, a small potentiometer is attached '
              'to the shaft. The motor measures its own angle as it turns '
              'and stops when it reaches the target.',
          contentDe: 'Ein Servo dreht sich auf den WINKEL, den du verlangst. Anders als ein normaler Motor dreht er sich nicht durch; er geht irgendwohin zwischen 0 und 180 Grad und bleibt dort.\n\n   setze Servo an Anschluss [9] auf Winkel [90]\n\nFür die Schranke: 0 Grad zu, 90 Grad offen.\n\nWoher weiß er das? Innen sitzt ein kleines Potentiometer an der Achse. Der Motor misst beim Drehen seinen eigenen Winkel und hält an, wenn er das Ziel erreicht.',
          contentEs: 'Un servo gira hasta el ÁNGULO que le pides. A diferencia de un motor normal no da vueltas sin parar; va a algún punto entre 0 y 180 grados y se queda ahí.\n\n   mueve el servo en pin [9] al ángulo [90]\n\nPara la barrera: 0 grados cerrada, 90 grados abierta.\n\n¿Cómo lo sabe? Dentro tiene un potenciómetro pequeño unido al eje. El motor mide su propio ángulo mientras gira y se para al llegar al objetivo.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'servo pin 9 açı 90',
              contentEn: 'set servo pin 9 angle as 90',
              contentDe: 'setze Servo an Anschluss 9 auf Winkel 90',
              contentEs: 'mueve el servo en pin 9 al ángulo 90',
              color: MBlockPalette.pin,
              label: 'Pin · düz blok',
              labelEn: 'Pin · stack block',
              labelDe: 'Pin · Stapelblock',
              labelEs: 'Pin · bloque de pila',
            ),
          ],
          tipEmoji: '⚙️',
          tip: 'Servonun üç kablosu var: kırmızı (+5V), kahverengi/siyah '
              '(GND) ve turuncu/sarı (sinyal). Sinyal kablosu blokta '
              'yazdığın pine gider.',
          tipEn: 'A servo has three wires: red (+5V), brown/black (GND) and '
              'orange/yellow (signal). The signal wire goes to the pin you '
              'type in the block.',
          tipDe: 'Ein Servo hat drei Kabel: rot (+5V), braun/schwarz (GND) und orange/gelb (Signal). Das Signalkabel kommt an den Pin, den du in den Block schreibst.',
          tipEs: 'Un servo tiene tres cables: rojo (+5V), marrón/negro (GND) y naranja/amarillo (señal). El cable de señal va al pin que escribes en el bloque.',
        ),

        MultipleChoiceStep(
          id: 'm4_2_q1',
          question: 'Servoya "açı 200" dersen ne olur?',
          questionEn: 'What happens if you tell the servo "angle 200"?',
          questionDe: 'Was passiert, wenn du dem Servo «Winkel 200» sagst?',
          questionEs: '¿Qué pasa si le dices al servo «ángulo 200»?',
          options: [
            ChoiceOption(text: 'Gidebildiği kadar gider; 180 derece sınırını aşamaz', textEn: 'It goes as far as it can; it cannot pass 180 degrees', textDe: 'Er geht so weit er kann; über 180 Grad kommt er nicht', textEs: 'Llega hasta donde puede; no puede pasar de 180 grados'),
            ChoiceOption(text: 'İki tam tur atar', textEn: 'It makes two full turns', textDe: 'Er macht zwei volle Drehungen', textEs: 'Da dos vueltas completas'),
            ChoiceOption(text: 'mBlock hata verip programı yüklemez', textEn: 'mBlock refuses to upload the program', textDe: 'mBlock weigert sich, das Programm hochzuladen', textEs: 'mBlock se niega a subir el programa'),
            ChoiceOption(text: 'Servo bozulur ve bir daha çalışmaz', textEn: 'The servo breaks permanently', textDe: 'Der Servo geht dauerhaft kaputt', textEs: 'El servo se rompe para siempre'),
          ],
          correctIndex: 0,
          explanation:
              'Standart bir servo 0-180 derece arasında çalışır. mBlock '
              'yazdığın sayıyı kontrol etmez — programı yükler, servo da '
              'gidebildiği yere kadar gider.',
          explanationEn:
              'A standard servo works between 0 and 180 degrees. mBlock '
              'does not check the number you type; it uploads the program '
              'and the servo goes as far as it can.',
          explanationDe: 'Ein normaler Servo arbeitet zwischen 0 und 180 Grad. mBlock prüft die Zahl nicht, die du schreibst; es lädt das Programm hoch und der Servo geht so weit er kann.',
          explanationEs: 'Un servo normal trabaja entre 0 y 180 grados. mBlock no comprueba el número que escribes; sube el programa y el servo llega hasta donde puede.',
          xpReward: 15,
        ),

        ProjectStep(
          id: 'm4_2_project',
          title: 'Proje: Otomatik Bariyer',
          titleEn: 'Project: Automatic Barrier',
          titleDe: 'Projekt: automatische Schranke',
          titleEs: 'Proyecto: barrera automática',
          description:
              'Araba yaklaşınca açılan, geçince kapanan bir bariyer yap.',
          descriptionEn:
              'Build a barrier that opens when a car approaches and closes '
              'after it passes.',
          descriptionDe: 'Baue eine Schranke, die sich öffnet, wenn ein Auto kommt, und schließt, wenn es durch ist.',
          descriptionEs: 'Construye una barrera que se abra cuando se acerque un coche y se cierre cuando haya pasado.',
          requirements: [
            'Mesafeyi sürekli oku',
            '20 cm\'den yakınsa servo 90 dereceye gitsin',
            'Uzaklaşınca servo 0 dereceye dönsün',
            'Açılırken buzzer bir kez ötsün',
            'Mesafeyi seri porta yaz',
          ],
          requirementsEn: [
            'Read the distance continuously',
            'Closer than 20 cm → servo goes to 90 degrees',
            'Further away → servo returns to 0 degrees',
            'Beep once while opening',
            'Write the distance to the serial port',
          ],
          requirementsDe: [
            'Den Abstand laufend lesen',
            'Näher als 20 cm → Servo geht auf 90 Grad',
            'Weiter weg → Servo geht zurück auf 0 Grad',
            'Beim Öffnen einmal piepen',
            'Den Abstand an die serielle Schnittstelle schreiben',
          ],
          requirementsEs: [
            'Leer la distancia continuamente',
            'A menos de 20 cm → el servo va a 90 grados',
            'Más lejos → el servo vuelve a 0 grados',
            'Pitar una vez al abrir',
            'Escribir la distancia al puerto serie',
          ],
          hints: [
            'Sürekli tekrarla içinde: mesafe değişkenini oku',
            'eğer <mesafe < 20> ise → nota çal, servo açı 90, 3 saniye bekle',
            'eğer <mesafe > 20> ise → servo açı 0',
            'Servo sinyalini 9, buzzer\'ı 8, sensörü 13/12 pinlerine bağla',
          ],
          hintsEn: [
            'Inside forever: read the distance into a variable',
            'if <distance < 20> then → play a note, servo 90, wait 3 seconds',
            'if <distance > 20> then → servo 0',
            'Servo signal on 9, buzzer on 8, sensor on 13/12',
          ],
          hintsDe: [
            'In «wiederhole fortlaufend»: den Abstand in eine Variable lesen',
            'falls <abstand < 20>, dann → eine Note spielen, Servo 90, 3 Sekunden warten',
            'falls <abstand > 20>, dann → Servo 0',
            'Servo-Signal an 9, Summer an 8, Sensor an 13/12',
          ],
          hintsEs: [
            'Dentro de «por siempre»: leer la distancia en una variable',
            'si <distancia < 20> entonces → tocar una nota, servo 90, esperar 3 segundos',
            'si <distancia > 20> entonces → servo 0',
            'Señal del servo en 9, zumbador en 8, sensor en 13/12',
          ],
          starterCode: '',
          language: 'mblock',
          validation: ProjectValidation(
            mustContain: ['mesafe algılayıcı', 'servo pin', 'eğer'],
          ),
          xpReward: 80,
        ),

        ExplanationStep(
          id: 'm4_2_summary',
          title: 'mBlock Kursunu Bitirdin!',
          titleEn: 'You Finished the mBlock Course!',
          titleDe: 'Du hast den mBlock-Kurs geschafft!',
          titleEs: '¡Has terminado el curso de mBlock!',
          content: '🚧 Gerçek bir cihaz yaptın.\n\n'
              '✓ mBlock editörünü ve iki modunu tanıyorsun\n'
              '✓ Dokuz kategoriyi ve renklerini biliyorsun\n'
              '✓ Şekillerden bloğun nereye takılacağını anlıyorsun\n'
              '✓ Dijital, analog, PWM, servo ve sensör kullandın\n'
              '✓ Seri portla hata aramayı öğrendin\n\n'
              'Bundan sonrası senin fikirlerine kalmış.',
          contentEn: '🚧 You built a real device.\n\n'
              '✓ You know the mBlock editor and its two modes\n'
              '✓ You know the nine categories and their colours\n'
              '✓ You can tell from a shape where a block fits\n'
              '✓ You used digital, analog, PWM, servo and a sensor\n'
              '✓ You learned to debug with the serial port\n\n'
              'What comes next is up to your ideas.',
          contentDe: '🚧 Du hast ein echtes Gerät gebaut.\n\n✓ Du kennst den mBlock-Editor und seine zwei Modi\n✓ Du kennst die neun Kategorien und ihre Farben\n✓ Du siehst an der Form, wohin ein Block passt\n✓ Du hast digital, analog, PWM, Servo und einen Sensor benutzt\n✓ Du hast gelernt, mit der seriellen Schnittstelle Fehler zu suchen\n\nWas als Nächstes kommt, entscheiden deine Ideen.',
          contentEs: '🚧 Has construido un aparato de verdad.\n\n✓ Conoces el editor de mBlock y sus dos modos\n✓ Conoces las nueve categorías y sus colores\n✓ Sabes por la forma dónde encaja un bloque\n✓ Has usado digital, analógico, PWM, servo y un sensor\n✓ Has aprendido a depurar con el puerto serie\n\nLo que venga ahora depende de tus ideas.',
          tipEmoji: '🏆',
          tip: 'mBlock Ustası rozetini kazandın!',
          tipEn: 'You earned the mBlock Maker badge!',
          tipDe: 'Du hast das Abzeichen «mBlock-Macher» verdient!',
          tipEs: '¡Has ganado la insignia Creador mBlock!',
        ),
      ],
    ),
  ];

  static List<InteractiveLesson> get allLessons => [
        ...module1,
        ...module2,
        ...module3,
        ...module4,
      ];

  static InteractiveLesson? byId(String id) {
    for (final lesson in allLessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }
}
