// ARDUINO KURSU — MODUL 1: UNO VE BREADBOARD
//
// Kartin kendisi (pinler, L isigi, baslangic blogu), breadboard'un
// baglantilari, LED + direnc, ilk pinle surulen devre.
import '../../devre/arduino_projeleri.dart';
import '../../devre/devre_modeli.dart';
import '../../models/interactive_lesson_model.dart';
import '../mblock_palette.dart';
import 'ders_yardimcisi.dart';

/// 5V -> + hatti -> direnc -> LED -> - hatti -> GND (kodsuz LED).
final List<HedefBaglanti> _pilsizHedefler = [
  DevreKalibi.vHedefi,
  DevreKalibi.gndHedefi,
  const HedefBaglanti('U+9', 'g9',
      tr: '+ hattını direncin sol bacağının sırasına (sütun 9) bağla.',
      en: 'Connect the + rail to the resistor\'s left leg strip (column 9).',
      de: 'Verbinde die +-Schiene mit dem Streifen des linken Widerstandsbeins (Spalte 9).',
      es: 'Conecta la línea + a la tira de la pata izquierda de la resistencia (columna 9).'),
  const HedefBaglanti('i13', 'U-13',
      tr: 'LED\'in kısa bacağının sırasını (sütun 13) − hattına bağla.',
      en: 'Connect the LED\'s short leg strip (column 13) to the − rail.',
      de: 'Verbinde den Streifen des kurzen LED-Beins (Spalte 13) mit der −-Schiene.',
      es: 'Conecta la tira de la pata corta del LED (columna 13) a la línea −.'),
];

/// Pin 13 -> direnc -> LED -> GND, takili.
final Devre ilkLedDevresi = Devre(
  parcalar: DevreKalibi.led('L1', 12),
  kablolar: [DevreKalibi.gndKablosu, ...DevreKalibi.ledKablolari(13, 12)],
);

final List<InteractiveLesson> arduinoModul1 = [
  // ---------------------------------------------------------------- 1.1
  InteractiveLesson(
    id: 'arduino_1_1',
    courseId: 'arduino',
    title: 'Arduino Uno\'yu Tanı',
    titleEn: 'Meet the Arduino Uno',
    titleDe: 'Lerne den Arduino Uno kennen',
    titleEs: 'Conoce el Arduino Uno',
    subtitle: 'Pinler, L ışığı ve ilk blok',
    subtitleEn: 'Pins, the L light and your first block',
    subtitleDe: 'Pins, das L-Licht und dein erster Block',
    subtitleEs: 'Pines, la luz L y tu primer bloque',
    order: 1,
    xpReward: 50,
    badge: 'arduino_starter',
    steps: [
      const IntroStep(
        id: 'a1_1_intro',
        mascotEmoji: '🤖',
        mascotMessage: 'Bu kursta gerçek bir Arduino Uno ile çalışacağız: LED yakacak, '
            'buton okuyacak, sensörlerle konuşacak ve motor döndüreceğiz. '
            'Kodu mBlock bloklarıyla yazacağız, devreyi breadboard\'da kuracağız.',
        mascotMessageEn: 'In this course we work with a real Arduino Uno: we light LEDs, read '
            'buttons, talk to sensors and turn motors. We write the code with '
            'mBlock blocks and build the circuits on a breadboard.',
        mascotMessageDe: 'In diesem Kurs arbeiten wir mit einem echten Arduino Uno: LEDs '
            'leuchten lassen, Taster lesen, mit Sensoren reden und Motoren drehen. '
            'Den Code bauen wir mit mBlock-Blöcken, die Schaltungen auf einem Steckbrett.',
        mascotMessageEs: 'En este curso trabajamos con un Arduino Uno de verdad: encendemos '
            'LED, leemos botones, hablamos con sensores y movemos motores. El código '
            'lo hacemos con bloques de mBlock y los circuitos en una placa de pruebas.',
        highlights: ['Uno\'nun pinleri', 'Başlangıç bloğu', 'Karttaki L ışığı'],
        highlightsEn: ['The Uno\'s pins', 'The start block', 'The L light on the board'],
        highlightsDe: ['Die Pins des Uno', 'Der Startblock', 'Das L-Licht auf der Platine'],
        highlightsEs: ['Los pines del Uno', 'El bloque de inicio', 'La luz L de la placa'],
      ),
      const ExplanationStep(
        id: 'a1_1_kart',
        title: 'Uno: Küçük Bir Bilgisayar',
        titleEn: 'The Uno: a Tiny Computer',
        titleDe: 'Der Uno: ein winziger Computer',
        titleEs: 'El Uno: un ordenador diminuto',
        content: 'Arduino Uno, yazdığın programı çalıştıran küçük bir bilgisayardır.\n\n'
            '• Üstteki 0-13 DİJİTAL pinler: açık ya da kapalı.\n'
            '• Alttaki A0-A5 ANALOG pinler: 0 ile 1023 arası değer okur.\n'
            '• 5V ve GND: devreye elektrik verir. GND eksi uçtur.\n'
            '• Kartın üstündeki küçük L ışığı pin 13\'e bağlıdır.',
        contentEn: 'The Arduino Uno is a tiny computer that runs your program.\n\n'
            '• The DIGITAL pins 0-13 on top: on or off.\n'
            '• The ANALOG pins A0-A5 at the bottom: they read a value from 0 to 1023.\n'
            '• 5V and GND power the circuit. GND is the minus side.\n'
            '• The small L light on the board is connected to pin 13.',
        contentDe: 'Der Arduino Uno ist ein winziger Computer, der dein Programm ausführt.\n\n'
            '• Oben die DIGITALEN Pins 0-13: an oder aus.\n'
            '• Unten die ANALOGEN Pins A0-A5: Sie lesen einen Wert von 0 bis 1023.\n'
            '• 5V und GND versorgen die Schaltung mit Strom. GND ist der Minuspol.\n'
            '• Das kleine L-Licht auf der Platine hängt an Pin 13.',
        contentEs: 'El Arduino Uno es un ordenador diminuto que ejecuta tu programa.\n\n'
            '• Arriba, los pines DIGITALES 0-13: encendido o apagado.\n'
            '• Abajo, los pines ANALÓGICOS A0-A5: leen un valor de 0 a 1023.\n'
            '• 5V y GND dan electricidad al circuito. GND es el lado negativo.\n'
            '• La lucecita L de la placa está conectada al pin 13.',
        tipEmoji: '🔌',
        tip: 'USB kablosu hem elektriği hem de programı karta taşır.',
        tipEn: 'The USB cable carries both the power and your program to the board.',
        tipDe: 'Das USB-Kabel bringt Strom und Programm zur Platine.',
        tipEs: 'El cable USB lleva a la placa tanto la electricidad como tu programa.',
      ),
      const MultipleChoiceStep(
        id: 'a1_1_q1',
        question: 'Bir düğmenin ne kadar çevrildiğini (0-1023) okumak için hangi pinleri kullanırsın?',
        questionEn: 'Which pins do you use to read how far a knob is turned (0-1023)?',
        questionDe: 'Mit welchen Pins liest du, wie weit ein Drehknopf gedreht ist (0-1023)?',
        questionEs: '¿Qué pines usas para leer cuánto se ha girado un mando (0-1023)?',
        options: [
          ChoiceOption(text: 'A0-A5 analog pinler', textEn: 'The analog pins A0-A5', textDe: 'Die Analogpins A0-A5', textEs: 'Los pines analógicos A0-A5'),
          ChoiceOption(text: '0-13 dijital pinler', textEn: 'The digital pins 0-13', textDe: 'Die Digitalpins 0-13', textEs: 'Los pines digitales 0-13'),
          ChoiceOption(text: 'Yalnızca GND', textEn: 'Only GND', textDe: 'Nur GND', textEs: 'Solo GND'),
          ChoiceOption(text: 'USB girişi', textEn: 'The USB port', textDe: 'Der USB-Anschluss', textEs: 'El puerto USB'),
        ],
        correctIndex: 0,
        explanation: 'Dijital pinler yalnızca açık/kapalı bilir. Aradaki değerleri analog pinler okur.',
        explanationEn: 'Digital pins only know on and off. The analog pins read the values in between.',
        explanationDe: 'Digitalpins kennen nur an und aus. Die Werte dazwischen lesen die Analogpins.',
        explanationEs: 'Los pines digitales solo saben encendido y apagado. Los valores intermedios los leen los analógicos.',
      ),
      ExplanationStep(
        id: 'a1_1_bas',
        title: 'Her Program Bu Blokla Başlar',
        titleEn: 'Every Program Starts With This Block',
        titleDe: 'Jedes Programm beginnt mit diesem Block',
        titleEs: 'Todo programa empieza con este bloque',
        content: 'Karta gidecek her program "when Arduino Uno starts up" bloğuyla başlar. '
            'Bu bloğun Türkçesi yok; mBlock\'ta da İngilizce görünür.\n\n'
            'Kart elektrik alır almaz bu bloğun altındakileri sırayla çalıştırır.',
        contentEn: 'Every program for the board starts with the "when Arduino Uno starts up" block.\n\n'
            'As soon as the board gets power, it runs the blocks below it, one after another.',
        contentDe: 'Jedes Programm für die Platine beginnt mit dem Block „wenn Arduino Uno startet“.\n\n'
            'Sobald die Platine Strom bekommt, führt sie die Blöcke darunter nacheinander aus.',
        contentEs: 'Todo programa para la placa empieza con el bloque «cuando Arduino Uno se inicia».\n\n'
            'En cuanto la placa recibe electricidad, ejecuta los bloques de debajo, uno tras otro.',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'when Arduino Uno starts up',
            contentEn: 'when Arduino Uno starts up',
            contentDe: 'wenn Arduino Uno startet',
            contentEs: 'cuando Arduino Uno se inicia',
            color: MBlockPalette.events,
            label: 'Olaylar · şapka bloğu',
            labelEn: 'Events · hat block',
            labelDe: 'Ereignisse · Hutblock',
            labelEs: 'Eventos · bloque sombrero',
          ),
        ],
      ),
      arduinoKodAdimi(
        id: 'a1_1_kod',
        talimat: 'Karttaki L ışığını yak: o, pin 13\'e bağlı.',
        talimatEn: 'Turn on the L light on the board: it is connected to pin 13.',
        talimatDe: 'Schalte das L-Licht auf der Platine ein: Es hängt an Pin 13.',
        talimatEs: 'Enciende la luz L de la placa: está conectada al pin 13.',
        hedef: 'Başlangıç bloğu ve pin 13 yüksek',
        hedefEn: 'The start block and pin 13 high',
        hedefDe: 'Startblock und Pin 13 auf hoch',
        hedefEs: 'El bloque de inicio y el pin 13 en alto',
        bloklar: const ['dev_kart_acilis', 'dev_dijital_yaz'],
        cozum: [kartAcilis, dijitalYaz(13, true)],
        devre: Devre.bos,
        xp: 25,
      ),
      arduinoKodAdimi(
        id: 'a1_1_kod2',
        talimat: 'L ışığı yanıp sönsün: sürekli tekrarla içinde yak, 1 saniye bekle, söndür, 1 saniye bekle.',
        talimatEn: 'Make the L light blink: inside forever, turn it on, wait 1 second, turn it off, wait 1 second.',
        talimatDe: 'Lass das L-Licht blinken: In „wiederhole fortlaufend“ an, 1 Sekunde warten, aus, 1 Sekunde warten.',
        talimatEs: 'Haz parpadear la luz L: dentro de por siempre, enciende, espera 1 segundo, apaga, espera 1 segundo.',
        hedef: 'Yan, bekle, sön, bekle; sonsuza kadar',
        hedefEn: 'On, wait, off, wait; forever',
        hedefDe: 'An, warten, aus, warten; immer wieder',
        hedefEs: 'Encender, esperar, apagar, esperar; para siempre',
        bloklar: const ['dev_kart_acilis', 'dev_surekli', 'dev_dijital_yaz', 'dev_bekle'],
        cozum: [
          kartAcilis,
          surekli([dijitalYaz(13, true), bekle(1), dijitalYaz(13, false), bekle(1)]),
        ],
        devre: Devre.bos,
      ),
      const ExplanationStep(
        id: 'a1_1_ozet',
        title: 'Uno\'yu Tanıdın!',
        titleEn: 'You Know the Uno!',
        titleDe: 'Du kennst den Uno!',
        titleEs: '¡Ya conoces el Uno!',
        content: '✓ Dijital ve analog pinlerin farkını öğrendin\n'
            '✓ Programın başlangıç bloğunu buldun\n'
            '✓ Karttaki L ışığını kodla yakıp söndürdün\n\n'
            'Sıradaki derste kartın yanına breadboard koyuyoruz.',
        contentEn: '✓ You learned the difference between digital and analog pins\n'
            '✓ You found the program\'s start block\n'
            '✓ You blinked the L light with code\n\n'
            'Next lesson: we put a breadboard next to the board.',
        contentDe: '✓ Du kennst den Unterschied zwischen digitalen und analogen Pins\n'
            '✓ Du hast den Startblock gefunden\n'
            '✓ Du hast das L-Licht mit Code blinken lassen\n\n'
            'Nächste Lektion: Wir legen ein Steckbrett neben die Platine.',
        contentEs: '✓ Aprendiste la diferencia entre pines digitales y analógicos\n'
            '✓ Encontraste el bloque de inicio del programa\n'
            '✓ Hiciste parpadear la luz L con código\n\n'
            'Siguiente lección: ponemos una placa de pruebas junto a la placa.',
        tipEmoji: '🏆',
        tip: 'Arduino Başlangıç rozetini kazandın!',
        tipEn: 'You earned the Arduino Starter badge!',
        tipDe: 'Du hast das Abzeichen „Arduino-Einsteiger“ verdient!',
        tipEs: '¡Has ganado la insignia Principiante de Arduino!',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 1.2
  InteractiveLesson(
    id: 'arduino_r1_2',
    courseId: 'arduino',
    title: 'Breadboard: Kabloların Yolu',
    titleEn: 'The Breadboard: Where Wires Go',
    titleDe: 'Das Steckbrett: Wege für Kabel',
    titleEs: 'La placa de pruebas: el camino de los cables',
    subtitle: 'Bağlı delikler, + ve − hatları, LED ve direnç',
    subtitleEn: 'Connected holes, + and − rails, LED and resistor',
    subtitleDe: 'Verbundene Löcher, + und − Schienen, LED und Widerstand',
    subtitleEs: 'Agujeros conectados, líneas + y −, LED y resistencia',
    order: 2,
    xpReward: 50,
    steps: [
      const IntroStep(
        id: 'a1_2_intro',
        mascotEmoji: '🧩',
        mascotMessage: 'Parçaları lehim yapmadan birleştirmek için breadboard kullanırız. '
            'Delikleri içeriden birbirine bağlıdır. Hangi deliğin hangisine bağlı '
            'olduğunu bilirsen her devreyi kurabilirsin.',
        mascotMessageEn: 'We use a breadboard to join parts without soldering. Its holes are '
            'connected inside. Once you know which holes are joined, you can build any circuit.',
        mascotMessageDe: 'Mit einem Steckbrett verbinden wir Bauteile ohne Löten. Seine Löcher '
            'sind innen verbunden. Wenn du weißt, welche Löcher zusammengehören, kannst du jede Schaltung bauen.',
        mascotMessageEs: 'Usamos una placa de pruebas para unir piezas sin soldar. Sus agujeros '
            'están conectados por dentro. Si sabes cuáles van juntos, puedes montar cualquier circuito.',
        highlights: ['Bağlı delikler', '+ ve − hatları', 'LED + direnç'],
        highlightsEn: ['Connected holes', 'The + and − rails', 'LED + resistor'],
        highlightsDe: ['Verbundene Löcher', 'Die + und − Schienen', 'LED + Widerstand'],
        highlightsEs: ['Agujeros conectados', 'Las líneas + y −', 'LED + resistencia'],
      ),
      const ExplanationStep(
        id: 'a1_2_bb',
        title: 'Hangi Delikler Bağlı?',
        titleEn: 'Which Holes Are Connected?',
        titleDe: 'Welche Löcher sind verbunden?',
        titleEs: '¿Qué agujeros están conectados?',
        content: '• Bir sütundaki a-e delikleri birbirine bağlıdır; f-j delikleri de.\n'
            '• Ortadaki kanal bu iki yarıyı ayırır.\n'
            '• Kenardaki + (kırmızı) ve − (mavi) hatlar boydan boya bağlıdır.\n\n'
            'Uno\'nun 5V\'unu + hatta, GND\'sini − hatta veririz. Böylece her parça elektriğe yakın olur.',
        contentEn: '• The holes a-e in one column are connected; so are f-j.\n'
            '• The channel in the middle separates the two halves.\n'
            '• The + (red) and − (blue) rails along the edge are connected end to end.\n\n'
            'We feed the Uno\'s 5V to the + rail and GND to the − rail, so power is close to every part.',
        contentDe: '• Die Löcher a-e einer Spalte sind verbunden, ebenso f-j.\n'
            '• Der Kanal in der Mitte trennt die beiden Hälften.\n'
            '• Die + (rote) und − (blaue) Schiene am Rand sind durchgehend verbunden.\n\n'
            '5V vom Uno kommt an die +-Schiene, GND an die −-Schiene. So ist Strom nah an jedem Bauteil.',
        contentEs: '• Los agujeros a-e de una columna están conectados; los f-j también.\n'
            '• El canal del centro separa las dos mitades.\n'
            '• Las líneas + (roja) y − (azul) del borde están conectadas de punta a punta.\n\n'
            'Llevamos el 5V del Uno a la línea + y GND a la línea −. Así la electricidad queda cerca de cada pieza.',
        tipEmoji: '🔎',
        tip: 'Atölyede bir deliğe dokunduğunda ona bağlı 5 delik hafifçe boyanır.',
        tipEn: 'In the workshop, when you tap a hole, the 5 holes joined to it light up.',
        tipDe: 'Tippst du in der Werkstatt auf ein Loch, leuchten die 5 verbundenen Löcher auf.',
        tipEs: 'En el taller, al tocar un agujero se iluminan los 5 agujeros unidos a él.',
      ),
      const MultipleChoiceStep(
        id: 'a1_2_q1',
        question: 'c12 deliğine bir kablo taktın. Hangi delik onunla BAĞLIDIR?',
        questionEn: 'You plugged a wire into hole c12. Which hole is CONNECTED to it?',
        questionDe: 'Du steckst ein Kabel in Loch c12. Welches Loch ist damit VERBUNDEN?',
        questionEs: 'Conectaste un cable en el agujero c12. ¿Qué agujero está CONECTADO con él?',
        options: [
          ChoiceOption(text: 'a12', textEn: 'a12', textDe: 'a12', textEs: 'a12'),
          ChoiceOption(text: 'c13', textEn: 'c13', textDe: 'c13', textEs: 'c13'),
          ChoiceOption(text: 'h12', textEn: 'h12', textDe: 'h12', textEs: 'h12'),
          ChoiceOption(text: 'c11', textEn: 'c11', textDe: 'c11', textEs: 'c11'),
        ],
        correctIndex: 0,
        explanation: 'Aynı sütunun a-e delikleri bağlıdır: a12 ile c12 aynı şeritte. h12 kanalın öbür yanında.',
        explanationEn: 'The a-e holes of one column are joined: a12 and c12 share a strip. h12 is across the channel.',
        explanationDe: 'Die Löcher a-e einer Spalte sind verbunden: a12 und c12 teilen einen Streifen. h12 liegt jenseits des Kanals.',
        explanationEs: 'Los agujeros a-e de una columna están unidos: a12 y c12 comparten tira. h12 está al otro lado del canal.',
      ),
      const ExplanationStep(
        id: 'a1_2_led',
        title: 'LED ve Direnç',
        titleEn: 'LED and Resistor',
        titleDe: 'LED und Widerstand',
        titleEs: 'LED y resistencia',
        content: 'LED\'in uzun bacağı artı (+), kısa bacağı eksi (−) tarafa gider. Ters takılırsa yanmaz.\n\n'
            'Direnç, LED\'e giden akımı sınırlar. Dirençsiz LED fazla akım çeker ve bozulur. '
            'Bu kursta 220Ω kullanıyoruz: kırmızı-kırmızı-kahverengi bantlı olan.',
        contentEn: 'The LED\'s long leg goes to plus (+), the short leg to minus (−). Put in backwards, it stays dark.\n\n'
            'A resistor limits the current to the LED. Without one, the LED draws too much and breaks. '
            'In this course we use 220Ω: the one with red-red-brown bands.',
        contentDe: 'Das lange Bein der LED kommt an Plus (+), das kurze an Minus (−). Verkehrt herum bleibt sie dunkel.\n\n'
            'Ein Widerstand begrenzt den Strom zur LED. Ohne ihn zieht die LED zu viel und geht kaputt. '
            'In diesem Kurs nehmen wir 220Ω: den mit den Ringen rot-rot-braun.',
        contentEs: 'La pata larga del LED va al positivo (+) y la corta al negativo (−). Si lo pones al revés, no se enciende.\n\n'
            'La resistencia limita la corriente del LED. Sin ella, el LED consume demasiado y se rompe. '
            'En este curso usamos 220Ω: la de bandas rojo-rojo-marrón.',
        tipEmoji: '💡',
        tip: 'Sanal LED\'de uzun bacak bükük çizilir ve yanında küçük bir + vardır.',
        tipEn: 'On the virtual LED the long leg is drawn bent, with a small + next to it.',
        tipDe: 'Bei der virtuellen LED ist das lange Bein geknickt gezeichnet, daneben ein kleines +.',
        tipEs: 'En el LED virtual la pata larga está doblada y tiene un pequeño + al lado.',
      ),
      DevreKurmaStep(
        id: 'a1_2_devre',
        talimat: 'LED\'i koddan önce doğrudan 5V ile yakalım: 5V → direnç → LED → GND.',
        talimatEn: 'Before any code, light the LED straight from 5V: 5V → resistor → LED → GND.',
        talimatDe: 'Noch ohne Code bringen wir die LED direkt mit 5V zum Leuchten: 5V → Widerstand → LED → GND.',
        talimatEs: 'Antes de programar, enciende el LED directamente con 5V: 5V → resistencia → LED → GND.',
        parcalar: DevreKalibi.led('L1', 12),
        hedefler: _pilsizHedefler,
        xpReward: 25,
      ),
      const MultipleChoiceStep(
        id: 'a1_2_q2',
        question: 'LED yanmadı ve uzun bacağı GND tarafında. Ne yapmalısın?',
        questionEn: 'The LED does not light and its long leg is on the GND side. What should you do?',
        questionDe: 'Die LED leuchtet nicht und ihr langes Bein ist auf der GND-Seite. Was tust du?',
        questionEs: 'El LED no se enciende y su pata larga está del lado de GND. ¿Qué haces?',
        options: [
          ChoiceOption(text: 'LED\'i ters çeviririm', textEn: 'Turn the LED around', textDe: 'Ich drehe die LED um', textEs: 'Doy la vuelta al LED'),
          ChoiceOption(text: 'İkinci bir direnç eklerim', textEn: 'Add a second resistor', textDe: 'Ich füge einen zweiten Widerstand hinzu', textEs: 'Añado otra resistencia'),
          ChoiceOption(text: 'Kabloyu A0\'a takarım', textEn: 'Plug the wire into A0', textDe: 'Ich stecke das Kabel in A0', textEs: 'Conecto el cable a A0'),
          ChoiceOption(text: 'Hiçbir şey; LED bozuk', textEn: 'Nothing; the LED is broken', textDe: 'Nichts; die LED ist kaputt', textEs: 'Nada; el LED está roto'),
        ],
        correctIndex: 0,
        explanation: 'LED tek yönlü çalışır: uzun bacak + tarafa. Atölyede LED\'i seçip "Döndür"e basman yeter.',
        explanationEn: 'An LED works in one direction only: long leg to +. In the workshop just select it and tap "Flip".',
        explanationDe: 'Eine LED funktioniert nur in eine Richtung: langes Bein zu +. In der Werkstatt auswählen und „Drehen“ tippen.',
        explanationEs: 'Un LED solo funciona en un sentido: pata larga al +. En el taller selecciónalo y pulsa «Girar».',
      ),
      const ExplanationStep(
        id: 'a1_2_ozet',
        title: 'Devre Kapandı, LED Yandı!',
        titleEn: 'The Circuit Closed, the LED Lit!',
        titleDe: 'Stromkreis zu, LED an!',
        titleEs: '¡Circuito cerrado, LED encendido!',
        content: '✓ Breadboard\'da hangi deliklerin bağlı olduğunu öğrendin\n'
            '✓ 5V\'u + hatta, GND\'yi − hatta verdin\n'
            '✓ LED\'i direnç ve doğru yönle yaktın\n\n'
            'Ama bu LED hep yanık. Sıradaki derste onu kodla yöneteceğiz.',
        contentEn: '✓ You learned which breadboard holes are connected\n'
            '✓ You fed 5V to the + rail and GND to the − rail\n'
            '✓ You lit the LED with a resistor, the right way round\n\n'
            'But this LED is always on. Next lesson we control it with code.',
        contentDe: '✓ Du weißt, welche Löcher im Steckbrett verbunden sind\n'
            '✓ 5V an die +-Schiene, GND an die −-Schiene\n'
            '✓ Die LED leuchtet mit Widerstand und richtig herum\n\n'
            'Aber diese LED ist immer an. In der nächsten Lektion steuern wir sie mit Code.',
        contentEs: '✓ Aprendiste qué agujeros de la placa están conectados\n'
            '✓ Llevaste 5V a la línea + y GND a la línea −\n'
            '✓ Encendiste el LED con resistencia y en el sentido correcto\n\n'
            'Pero este LED está siempre encendido. En la siguiente lección lo controlamos con código.',
        tipEmoji: '⚡',
        tip: 'Elektrik bir döngüde akar: 5V\'tan çıkar, parçalardan geçer, GND\'ye döner.',
        tipEn: 'Electricity flows in a loop: out of 5V, through the parts, back to GND.',
        tipDe: 'Strom fließt im Kreis: aus 5V heraus, durch die Bauteile, zurück zu GND.',
        tipEs: 'La electricidad fluye en un circuito: sale de 5V, pasa por las piezas y vuelve a GND.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 1.3
  InteractiveLesson(
    id: 'arduino_1_2',
    courseId: 'arduino',
    title: 'İlk LED Devren',
    titleEn: 'Your First LED Circuit',
    titleDe: 'Deine erste LED-Schaltung',
    titleEs: 'Tu primer circuito con LED',
    subtitle: 'Pin 13 → direnç → LED → GND, kodla',
    subtitleEn: 'Pin 13 → resistor → LED → GND, with code',
    subtitleDe: 'Pin 13 → Widerstand → LED → GND, mit Code',
    subtitleEs: 'Pin 13 → resistencia → LED → GND, con código',
    order: 3,
    xpReward: 60,
    badge: 'led_master',
    steps: [
      const IntroStep(
        id: 'a1_3_intro',
        mascotEmoji: '💡',
        mascotMessage: 'Şimdi LED\'e elektriği 5V\'tan değil bir PİNDEN vereceğiz. '
            'Pin, kodla açılıp kapanan bir anahtar gibidir.',
        mascotMessageEn: 'Now the LED gets its power from a PIN instead of 5V. '
            'A pin is like a switch you flip with code.',
        mascotMessageDe: 'Jetzt bekommt die LED ihren Strom von einem PIN statt von 5V. '
            'Ein Pin ist wie ein Schalter, den du mit Code umlegst.',
        mascotMessageEs: 'Ahora el LED recibe la electricidad de un PIN en vez de 5V. '
            'Un pin es como un interruptor que mueves con código.',
        highlights: ['Pin = anahtar', 'Devreyi kur', 'LED\'i yakıp söndür'],
        highlightsEn: ['Pin = switch', 'Build the circuit', 'Blink the LED'],
        highlightsDe: ['Pin = Schalter', 'Schaltung bauen', 'LED blinken lassen'],
        highlightsEs: ['Pin = interruptor', 'Monta el circuito', 'Haz parpadear el LED'],
      ),
      const ExplanationStep(
        id: 'a1_3_pin',
        title: 'Pin: Kodla Çalışan Anahtar',
        titleEn: 'A Pin: a Switch Run by Code',
        titleDe: 'Ein Pin: ein Schalter für Code',
        titleEs: 'Un pin: un interruptor con código',
        content: '"dijital ayarla pin 13 çıkış yüksek" → pin 13\'ten 5V çıkar, LED yanar.\n'
            '"… düşük" → 0V çıkar, LED söner.\n\n'
            'Devre aynı kalır, yalnızca + hattının yerini pin 13 alır: pin → direnç → LED → GND.',
        contentEn: '"set digital pin 13 output as high" → pin 13 gives 5V, the LED lights.\n'
            '"… low" → 0V, the LED goes off.\n\n'
            'The circuit stays the same; pin 13 just takes the place of the + rail: pin → resistor → LED → GND.',
        contentDe: '„digitalen Pin von Ausgang 13 als hoch setzen“ → Pin 13 liefert 5V, die LED leuchtet.\n'
            '„… niedrig“ → 0V, die LED geht aus.\n\n'
            'Die Schaltung bleibt gleich; Pin 13 ersetzt nur die +-Schiene: Pin → Widerstand → LED → GND.',
        contentEs: '«pon el pin digital 13 a alto» → el pin 13 da 5V y el LED se enciende.\n'
            '«… bajo» → 0V y el LED se apaga.\n\n'
            'El circuito es el mismo; el pin 13 ocupa el lugar de la línea +: pin → resistencia → LED → GND.',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'dijital ayarla pin 13 çıkış yüksek',
            contentEn: 'set digital pin 13 output as high',
            contentDe: 'digitalen Pin von Ausgang 13 als hoch setzen',
            contentEs: 'pon el pin digital 13 a alto',
            color: MBlockPalette.pin,
            label: 'Pin',
            labelEn: 'Pin',
            labelDe: 'Pin',
            labelEs: 'Pin',
          ),
        ],
      ),
      DevreKurmaStep(
        id: 'a1_3_devre',
        talimat: 'Pin 13\'ten LED\'e giden devreyi kur.',
        talimatEn: 'Build the circuit from pin 13 to the LED.',
        talimatDe: 'Baue die Schaltung von Pin 13 zur LED.',
        talimatEs: 'Monta el circuito del pin 13 al LED.',
        parcalar: DevreKalibi.led('L1', 12),
        hedefler: [DevreKalibi.gndHedefi, ...DevreKalibi.ledHedefleri(13, 12)],
        xpReward: 25,
      ),
      arduinoKodAdimi(
        id: 'a1_3_kod',
        talimat: 'LED\'i yarım saniyede bir yakıp söndür.',
        talimatEn: 'Blink the LED every half second.',
        talimatDe: 'Lass die LED jede halbe Sekunde blinken.',
        talimatEs: 'Haz parpadear el LED cada medio segundo.',
        hedef: 'Yan, 0.5 bekle, sön, 0.5 bekle; sonsuza kadar',
        hedefEn: 'On, wait 0.5, off, wait 0.5; forever',
        hedefDe: 'An, 0.5 warten, aus, 0.5 warten; immer wieder',
        hedefEs: 'Encender, esperar 0.5, apagar, esperar 0.5; para siempre',
        bloklar: const ['dev_kart_acilis', 'dev_surekli', 'dev_dijital_yaz', 'dev_bekle'],
        cozum: [
          kartAcilis,
          surekli([dijitalYaz(13, true), bekle(0.5), dijitalYaz(13, false), bekle(0.5)]),
        ],
        devre: ilkLedDevresi,
        xp: 35,
      ),
      const MultipleChoiceStep(
        id: 'a1_3_q1',
        question: 'Kodda "pin 12" yazdın ama kablo pin 13\'e takılı. Ne olur?',
        questionEn: 'Your code says "pin 12" but the wire is in pin 13. What happens?',
        questionDe: 'Im Code steht „Pin 12“, das Kabel steckt aber in Pin 13. Was passiert?',
        questionEs: 'Tu código dice «pin 12» pero el cable está en el pin 13. ¿Qué pasa?',
        options: [
          ChoiceOption(text: 'LED yanmaz: kod ile kablo aynı pini göstermeli', textEn: 'The LED stays dark: code and wire must use the same pin', textDe: 'Die LED bleibt dunkel: Code und Kabel brauchen denselben Pin', textEs: 'El LED no se enciende: código y cable deben usar el mismo pin'),
          ChoiceOption(text: 'LED yine yanar, pin fark etmez', textEn: 'The LED lights anyway, the pin does not matter', textDe: 'Die LED leuchtet trotzdem, der Pin ist egal', textEs: 'El LED se enciende igual, el pin da igual'),
          ChoiceOption(text: 'Kart bozulur', textEn: 'The board breaks', textDe: 'Die Platine geht kaputt', textEs: 'La placa se rompe'),
          ChoiceOption(text: 'LED iki kat parlak yanar', textEn: 'The LED shines twice as bright', textDe: 'Die LED leuchtet doppelt so hell', textEs: 'El LED brilla el doble'),
        ],
        correctIndex: 0,
        explanation: 'Kod pin 12\'ye elektrik verir; LED ise pin 13\'ü bekler. İkisi aynı pini göstermeli.',
        explanationEn: 'The code powers pin 12 while the LED waits on pin 13. Both must point to the same pin.',
        explanationDe: 'Der Code schaltet Pin 12, die LED wartet an Pin 13. Beide müssen denselben Pin meinen.',
        explanationEs: 'El código activa el pin 12 y el LED espera en el 13. Los dos deben indicar el mismo pin.',
      ),
      const ExplanationStep(
        id: 'a1_3_ozet',
        title: 'LED Ustası!',
        titleEn: 'LED Master!',
        titleDe: 'LED-Meister!',
        titleEs: '¡Maestro del LED!',
        content: '✓ Pin → direnç → LED → GND devresini kurdun\n'
            '✓ LED\'i kodla yakıp söndürdün\n'
            '✓ Kodla kablonun aynı pini göstermesi gerektiğini öğrendin\n\n'
            'Sıradaki modülde birden çok LED\'le oynayacağız.',
        contentEn: '✓ You built the pin → resistor → LED → GND circuit\n'
            '✓ You blinked the LED with code\n'
            '✓ You learned that code and wire must use the same pin\n\n'
            'Next module: we play with several LEDs.',
        contentDe: '✓ Du hast Pin → Widerstand → LED → GND gebaut\n'
            '✓ Du hast die LED mit Code blinken lassen\n'
            '✓ Code und Kabel brauchen denselben Pin\n\n'
            'Nächstes Modul: Wir spielen mit mehreren LEDs.',
        contentEs: '✓ Montaste el circuito pin → resistencia → LED → GND\n'
            '✓ Hiciste parpadear el LED con código\n'
            '✓ Aprendiste que código y cable deben usar el mismo pin\n\n'
            'Siguiente módulo: jugamos con varios LED.',
        tipEmoji: '🏆',
        tip: 'LED Ustası rozetini kazandın!',
        tipEn: 'You earned the LED Master badge!',
        tipDe: 'Du hast das Abzeichen „LED-Meister“ verdient!',
        tipEs: '¡Has ganado la insignia Maestro del LED!',
      ),
    ],
  ),
];
