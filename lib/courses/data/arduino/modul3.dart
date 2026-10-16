// ARDUINO KURSU — MODUL 3: BUTONLAR
//
// Pin 2 butonu OKUYOR (cekme direnciyle), "eger" ile LED; "olana kadar
// bekle" ile ac/kapa dugmesi; degisken + seri port ile basis sayaci.
import '../../devre/arduino_projeleri.dart';
import '../../models/interactive_lesson_model.dart';
import '../../yurutme/mblock_cozum.dart';
import '../mblock_palette.dart';
import 'ders_yardimcisi.dart';

/// Buton pin 2'de (10k cekme direnciyle), LED pin 13'te. Modul boyunca ayni devre.
final _butonDevre = DevreKurmaStep(
  id: 'a3_1_devre',
  talimat: 'LED hazır. Butonu bağla: bir bacağı + hattına, öbürü pin 2\'ye; 10k direnç pin 2\'yi − hattına çeksin.',
  talimatEn: 'The LED is ready. Wire the button: one leg to the + rail, the other to pin 2; the 10k resistor pulls pin 2 down to the − rail.',
  talimatDe: 'Die LED ist fertig. Schließe den Taster an: ein Bein an die +-Schiene, das andere an Pin 2; der 10k-Widerstand zieht Pin 2 zur −-Schiene.',
  talimatEs: 'El LED ya está. Conecta el pulsador: una pata a la línea +, la otra al pin 2; la resistencia de 10k lleva el pin 2 a la línea −.',
  parcalar: [...DevreKalibi.buton(), ...DevreKalibi.led('L1', 22)],
  hazirKablolar: [DevreKalibi.gndKablosu, ...DevreKalibi.ledKablolari(13, 22)],
  hedefler: [DevreKalibi.vHedefi, ...DevreKalibi.butonHedefleri],
  xpReward: 25,
);

final List<InteractiveLesson> arduinoModul3 = [
  // ---------------------------------------------------------------- 3.1
  InteractiveLesson(
    id: 'arduino_2_1',
    courseId: 'arduino',
    title: 'Butonla LED',
    titleEn: 'Button and LED',
    titleDe: 'Taster und LED',
    titleEs: 'Pulsador y LED',
    subtitle: 'Pin 2 butonu okur, pin 13 LED\'i yakar',
    subtitleEn: 'Pin 2 reads the button, pin 13 lights the LED',
    subtitleDe: 'Pin 2 liest den Taster, Pin 13 schaltet die LED',
    subtitleEs: 'El pin 2 lee el pulsador y el pin 13 enciende el LED',
    order: 7,
    xpReward: 60,
    badge: 'button_reader',
    steps: [
      const IntroStep(
        id: 'a3_1_intro',
        mascotEmoji: '🔘',
        mascotMessage: 'Şimdiye kadar pinler hep bir şey YAPTI. Bu derste bir pin dinleyecek: '
            'butona basıldı mı, basılmadı mı? Cevaba göre LED\'i yakacağız.',
        mascotMessageEn: 'So far our pins always DID something. In this lesson a pin listens: '
            'is the button pressed or not? We light the LED based on the answer.',
        mascotMessageDe: 'Bisher haben unsere Pins immer etwas GETAN. Jetzt hört ein Pin zu: '
            'Ist der Taster gedrückt oder nicht? Je nach Antwort schalten wir die LED.',
        mascotMessageEs: 'Hasta ahora los pines siempre HACÍAN algo. En esta lección un pin escucha: '
            '¿está pulsado el botón o no? Según la respuesta, encendemos el LED.',
        highlights: ['Pin okuma', 'Çekme direnci', 'eğer … ise'],
        highlightsEn: ['Reading a pin', 'Pull-down resistor', 'if … then'],
        highlightsDe: ['Einen Pin lesen', 'Pull-down-Widerstand', 'falls … dann'],
        highlightsEs: ['Leer un pin', 'Resistencia de bajada', 'si … entonces'],
      ),
      const ExplanationStep(
        id: 'a3_1_buton',
        title: 'Buton ve Çekme Direnci',
        titleEn: 'Button and Pull-down Resistor',
        titleDe: 'Taster und Pull-down-Widerstand',
        titleEs: 'Pulsador y resistencia de bajada',
        content: '• Butona basınca iki yanını birleştirir: + hattı pin 2\'ye ulaşır.\n'
            '• Pin 2 bu kez yazmaz, OKUR: basılıysa 1, değilse 0.\n'
            '• 10k direnç, basılı değilken pin 2\'yi GND\'ye çeker. '
            'Direnç olmasa pin "havada" kalır ve rastgele okur.',
        contentEn: '• When pressed, the button joins its two sides: the + rail reaches pin 2.\n'
            '• This time pin 2 does not write, it READS: 1 if pressed, 0 if not.\n'
            '• The 10k resistor pulls pin 2 down to GND while the button is up. '
            'Without it the pin "floats" and reads random values.',
        contentDe: '• Gedrückt verbindet der Taster seine beiden Seiten: Die +-Schiene erreicht Pin 2.\n'
            '• Diesmal schreibt Pin 2 nicht, er LIEST: 1 bei gedrückt, sonst 0.\n'
            '• Der 10k-Widerstand zieht Pin 2 auf GND, solange der Taster oben ist. '
            'Ohne ihn „schwebt“ der Pin und liest zufällige Werte.',
        contentEs: '• Al pulsarlo, el botón une sus dos lados: la línea + llega al pin 2.\n'
            '• Esta vez el pin 2 no escribe, LEE: 1 si está pulsado, 0 si no.\n'
            '• La resistencia de 10k lleva el pin 2 a GND mientras el botón está suelto. '
            'Sin ella, el pin queda «al aire» y lee valores al azar.',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'dijital oku pin 2',
            contentEn: 'read digital pin 2',
            contentDe: 'Digitalpin lesen 2',
            contentEs: 'lee pin digital 2',
            color: MBlockPalette.pin,
            label: 'Pin · altıgen blok (1 ya da 0)',
            labelEn: 'Pin · hexagon block (1 or 0)',
            labelDe: 'Pin · Sechseckblock (1 oder 0)',
            labelEs: 'Pin · bloque hexagonal (1 o 0)',
          ),
        ],
      ),
      _butonDevre,
      arduinoKodAdimi(
        id: 'a3_1_kod',
        talimat: 'Sürekli tekrarla içinde: eğer pin 2 okunuyorsa pin 13 yüksek; eğer okunmuyorsa ("değil") düşük. '
            'Sonra sahnenin altındaki "B1 · basılı tut" düğmesine basılı tut: LED yanmalı.',
        talimatEn: 'Inside forever: if pin 2 reads 1, set pin 13 high; if not ("not"), set it low. '
            'Then press and hold "B1 · hold" under the stage: the LED should light.',
        talimatDe: 'In „wiederhole fortlaufend“: falls Pin 2 eine 1 liest, Pin 13 hoch; falls nicht („nicht“), niedrig. '
            'Halte dann unter der Bühne „B1 · gedrückt halten“: Die LED sollte leuchten.',
        talimatEs: 'Dentro de por siempre: si el pin 2 lee 1, pin 13 a alto; si no («no»), a bajo. '
            'Luego mantén pulsado «B1 · mantener» bajo el escenario: el LED debe encenderse.',
        hedef: 'Basılıyken yanık, bırakınca sönük',
        hedefEn: 'On while pressed, off when released',
        hedefDe: 'An, solange gedrückt; aus beim Loslassen',
        hedefEs: 'Encendido mientras pulsas, apagado al soltar',
        bloklar: const [
          'dev_kart_acilis',
          'dev_surekli',
          'dev_eger',
          'dev_dijital_oku',
          'dev_degil',
          'dev_dijital_yaz',
        ],
        cozum: [
          kartAcilis,
          MBlockBeklenen('dev_surekli', kardesKosullarSerbest: true, icerik: [
            eger(dijitalOku(2), [dijitalYaz(13, true)]),
            eger(degil(dijitalOku(2)), [dijitalYaz(13, false)]),
          ]),
        ],
        devre: _butonDevre.tamami,
        xp: 35,
      ),
      const MultipleChoiceStep(
        id: 'a3_1_q1',
        question: '10k direnci çıkardın. Butona dokunmadığın hâlde LED bazen yanıp sönüyor. Neden?',
        questionEn: 'You removed the 10k resistor. The LED sometimes flickers even though nobody touches the button. Why?',
        questionDe: 'Du hast den 10k-Widerstand entfernt. Die LED flackert manchmal, obwohl niemand den Taster berührt. Warum?',
        questionEs: 'Quitaste la resistencia de 10k. El LED a veces parpadea aunque nadie toca el botón. ¿Por qué?',
        options: [
          ChoiceOption(text: 'Buton bozuldu', textEn: 'The button is broken', textDe: 'Der Taster ist kaputt', textEs: 'El botón está roto'),
          ChoiceOption(text: 'Pin 2 havada kaldı ve rastgele okuyor', textEn: 'Pin 2 is floating and reads random values', textDe: 'Pin 2 schwebt und liest Zufallswerte', textEs: 'El pin 2 está al aire y lee valores al azar'),
          ChoiceOption(text: 'LED ters takıldı', textEn: 'The LED is in backwards', textDe: 'Die LED steckt verkehrt herum', textEs: 'El LED está al revés'),
          ChoiceOption(text: 'Kodda bekle bloğu eksik', textEn: 'The code is missing a wait block', textDe: 'Im Code fehlt ein Warteblock', textEs: 'Al código le falta un bloque de espera'),
        ],
        correctIndex: 1,
        explanation: 'Çekme direnci olmadan pin 2 ne 5V\'a ne GND\'ye bağlıdır; bazen 1, bazen 0 okur.',
        explanationEn: 'Without the pull-down resistor, pin 2 is tied to neither 5V nor GND, so it reads 1 one moment and 0 the next.',
        explanationDe: 'Ohne Pull-down-Widerstand hängt Pin 2 weder an 5V noch an GND und liest mal 1, mal 0.',
        explanationEs: 'Sin la resistencia de bajada, el pin 2 no está unido ni a 5V ni a GND, así que unas veces lee 1 y otras 0.',
      ),
      const ExplanationStep(
        id: 'a3_1_ozet',
        title: 'Buton Okuyucu!',
        titleEn: 'Button Reader!',
        titleDe: 'Taster-Leser!',
        titleEs: '¡Lector de botones!',
        content: '✓ Butonu pin 2\'ye ve çekme direncine bağladın\n'
            '✓ "dijital oku" ile pinin 1 mi 0 mı olduğunu okudun\n'
            '✓ "eğer" ile LED\'i butona bağladın\n\n'
            'Sıradaki derste tek basışla açılıp kapanan bir düğme yapacağız.',
        contentEn: '✓ You wired the button to pin 2 with a pull-down resistor\n'
            '✓ You used "read digital" to see if the pin is 1 or 0\n'
            '✓ You linked the LED to the button with "if"\n\n'
            'Next lesson: a switch that turns on and off with one press each.',
        contentDe: '✓ Taster an Pin 2 mit Pull-down-Widerstand angeschlossen\n'
            '✓ Mit „Digitalpin lesen“ geprüft, ob der Pin 1 oder 0 ist\n'
            '✓ Mit „falls“ die LED an den Taster gekoppelt\n\n'
            'Nächste Lektion: ein Schalter, der mit einem Druck an- und mit dem nächsten ausgeht.',
        contentEs: '✓ Conectaste el pulsador al pin 2 con una resistencia de bajada\n'
            '✓ Con «lee pin digital» viste si el pin es 1 o 0\n'
            '✓ Con «si» uniste el LED al botón\n\n'
            'Siguiente lección: un interruptor que se enciende con una pulsación y se apaga con la siguiente.',
        tipEmoji: '🏆',
        tip: 'Buton Okuyucu rozetini kazandın!',
        tipEn: 'You earned the Button Reader badge!',
        tipDe: 'Du hast das Abzeichen „Taster-Leser“ verdient!',
        tipEs: '¡Has ganado la insignia Lector de botones!',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 3.2
  InteractiveLesson(
    id: 'arduino_2_2',
    courseId: 'arduino',
    title: 'Aç/Kapa Düğmesi',
    titleEn: 'On/Off Switch',
    titleDe: 'An/Aus-Schalter',
    titleEs: 'Interruptor de encendido',
    subtitle: 'Bir basış açar, sonraki kapatır',
    subtitleEn: 'One press turns it on, the next turns it off',
    subtitleDe: 'Ein Druck schaltet an, der nächste aus',
    subtitleEs: 'Una pulsación enciende, la siguiente apaga',
    order: 8,
    xpReward: 60,
    steps: [
      const IntroStep(
        id: 'a3_2_intro',
        mascotEmoji: '💡',
        mascotMessage: 'Odadaki lamba düğmesi gibi bir şey yapalım: bas ve bırak, ışık açılsın; '
            'bir daha bas, kapansın. Parmağını tutman gerekmesin.',
        mascotMessageEn: 'Let\'s make something like a room light switch: press and release, the light comes on; '
            'press again, it goes off. No need to keep your finger on it.',
        mascotMessageDe: 'Bauen wir so etwas wie einen Lichtschalter: drücken und loslassen, das Licht geht an; '
            'noch einmal drücken, es geht aus. Du musst nicht gedrückt halten.',
        mascotMessageEs: 'Hagamos algo como el interruptor de la luz: pulsa y suelta, la luz se enciende; '
            'pulsa otra vez, se apaga. No hace falta mantener el dedo.',
        highlights: ['… olana kadar bekle', 'Basış ve bırakış', 'Aç/kapa'],
        highlightsEn: ['wait until …', 'Press and release', 'On/off'],
        highlightsDe: ['warte bis …', 'Drücken und loslassen', 'An/Aus'],
        highlightsEs: ['esperar hasta que …', 'Pulsar y soltar', 'Encender/apagar'],
      ),
      const ExplanationStep(
        id: 'a3_2_bekle',
        title: 'Olana Kadar Bekle',
        titleEn: 'Wait Until',
        titleDe: 'Warte bis',
        titleEs: 'Esperar hasta que',
        content: '"… olana kadar bekle" program akışını durdurur; içindeki koşul doğru olunca devam eder.\n\n'
            '• Basılana kadar bekle → LED\'i yak\n'
            '• Bırakılana kadar bekle\n'
            '• Yine basılana kadar bekle → LED\'i söndür\n'
            '• Bırakılana kadar bekle',
        contentEn: '"wait until …" pauses the program; it carries on once the condition inside is true.\n\n'
            '• Wait until pressed → LED on\n'
            '• Wait until released\n'
            '• Wait until pressed again → LED off\n'
            '• Wait until released',
        contentDe: '„warte bis …“ hält das Programm an; es läuft weiter, sobald die Bedingung darin wahr ist.\n\n'
            '• Warten, bis gedrückt → LED an\n'
            '• Warten, bis losgelassen\n'
            '• Warten, bis wieder gedrückt → LED aus\n'
            '• Warten, bis losgelassen',
        contentEs: '«esperar hasta que …» detiene el programa; sigue cuando la condición de dentro es verdadera.\n\n'
            '• Esperar a que se pulse → LED encendido\n'
            '• Esperar a que se suelte\n'
            '• Esperar a que se pulse otra vez → LED apagado\n'
            '• Esperar a que se suelte',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'dijital oku pin 2 olana kadar bekle',
            contentEn: 'wait until read digital pin 2',
            contentDe: 'warte bis Digitalpin lesen 2',
            contentEs: 'esperar hasta que lee pin digital 2',
            color: MBlockPalette.control,
            label: 'Kontrol',
            labelEn: 'Control',
            labelDe: 'Steuerung',
            labelEs: 'Control',
          ),
        ],
      ),
      arduinoKodAdimi(
        id: 'a3_2_kod',
        talimat: 'Devre hazır. Sürekli tekrarla içinde: basılana kadar bekle, yak, bırakılana kadar bekle; '
            'basılana kadar bekle, söndür, bırakılana kadar bekle. Sonra "B1 · basılı tut"a bas ve bırak.',
        talimatEn: 'The circuit is ready. Inside forever: wait until pressed, LED on, wait until released; '
            'wait until pressed, LED off, wait until released. Then press and release "B1 · hold".',
        talimatDe: 'Die Schaltung steht. In „wiederhole fortlaufend“: warten bis gedrückt, an, warten bis losgelassen; '
            'warten bis gedrückt, aus, warten bis losgelassen. Dann „B1 · gedrückt halten“ drücken und loslassen.',
        talimatEs: 'El circuito está listo. Dentro de por siempre: espera a que se pulse, enciende, espera a que se suelte; '
            'espera a que se pulse, apaga, espera a que se suelte. Luego pulsa y suelta «B1 · mantener».',
        hedef: 'Bir basış açar, bir basış kapatır',
        hedefEn: 'One press on, one press off',
        hedefDe: 'Ein Druck an, ein Druck aus',
        hedefEs: 'Una pulsación enciende, otra apaga',
        bloklar: const [
          'dev_kart_acilis',
          'dev_surekli',
          'dev_bekle_kadar',
          'dev_dijital_oku',
          'dev_degil',
          'dev_dijital_yaz',
        ],
        cozum: [
          kartAcilis,
          surekli([
            olanaKadarBekle(dijitalOku(2)),
            dijitalYaz(13, true),
            olanaKadarBekle(degil(dijitalOku(2))),
            olanaKadarBekle(dijitalOku(2)),
            dijitalYaz(13, false),
            olanaKadarBekle(degil(dijitalOku(2))),
          ]),
        ],
        devre: _butonDevre.tamami,
        xp: 40,
      ),
      const MultipleChoiceStep(
        id: 'a3_2_q1',
        question: '"Bırakılana kadar bekle" bloklarını silersen ne olur?',
        questionEn: 'What happens if you delete the "wait until released" blocks?',
        questionDe: 'Was passiert, wenn du die Blöcke „warten bis losgelassen“ löschst?',
        questionEs: '¿Qué pasa si borras los bloques «esperar a que se suelte»?',
        options: [
          ChoiceOption(text: 'Hiçbir şey değişmez', textEn: 'Nothing changes', textDe: 'Nichts ändert sich', textEs: 'No cambia nada'),
          ChoiceOption(text: 'LED hiç yanmaz', textEn: 'The LED never lights', textDe: 'Die LED leuchtet nie', textEs: 'El LED nunca se enciende'),
          ChoiceOption(text: 'Parmak basılıyken LED defalarca açılıp kapanır', textEn: 'While your finger is down, the LED flips on and off again and again', textDe: 'Solange der Finger drückt, geht die LED immer wieder an und aus', textEs: 'Mientras el dedo pulsa, el LED se enciende y apaga una y otra vez'),
          ChoiceOption(text: 'Kart yeniden başlar', textEn: 'The board restarts', textDe: 'Die Platine startet neu', textEs: 'La placa se reinicia'),
        ],
        correctIndex: 2,
        explanation: 'Kart çok hızlıdır: parmak hâlâ basılıyken "basıldı" koşulu hemen yine doğru olur ve LED art arda açılıp kapanır.',
        explanationEn: 'The board is very fast: with your finger still down, "pressed" is true again at once, so the LED flips back and forth.',
        explanationDe: 'Die Platine ist sehr schnell: Der Finger drückt noch, also ist „gedrückt“ sofort wieder wahr und die LED schaltet hin und her.',
        explanationEs: 'La placa es muy rápida: con el dedo aún abajo, «pulsado» vuelve a ser verdad enseguida y el LED cambia sin parar.',
      ),
      const ExplanationStep(
        id: 'a3_2_ozet',
        title: 'Işık Düğmen Hazır!',
        titleEn: 'Your Light Switch Works!',
        titleDe: 'Dein Lichtschalter funktioniert!',
        titleEs: '¡Tu interruptor funciona!',
        content: '✓ "… olana kadar bekle" ile programı bir koşula beklettin\n'
            '✓ Basışı ve bırakışı ayrı ayrı bekledin\n'
            '✓ Tek butonla aç/kapa düğmesi yaptın\n\n'
            'Sıradaki derste basışları sayacağız.',
        contentEn: '✓ You made the program wait for a condition with "wait until …"\n'
            '✓ You waited for the press and the release separately\n'
            '✓ You built an on/off switch with one button\n\n'
            'Next lesson: we count presses.',
        contentDe: '✓ Mit „warte bis …“ wartet das Programm auf eine Bedingung\n'
            '✓ Drücken und Loslassen getrennt abgewartet\n'
            '✓ Einen An/Aus-Schalter mit einem Taster gebaut\n\n'
            'Nächste Lektion: Wir zählen Tastendrücke.',
        contentEs: '✓ Con «esperar hasta que …» el programa espera una condición\n'
            '✓ Esperaste la pulsación y la suelta por separado\n'
            '✓ Hiciste un interruptor con un solo botón\n\n'
            'Siguiente lección: contamos pulsaciones.',
        tipEmoji: '👆',
        tip: 'Basış + bırakış = bir tam "tık". İkisini de beklemek gerekir.',
        tipEn: 'Press + release = one full "click". You need to wait for both.',
        tipDe: 'Drücken + Loslassen = ein ganzer „Klick“. Beides musst du abwarten.',
        tipEs: 'Pulsar + soltar = un «clic» completo. Hay que esperar los dos.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 3.3
  InteractiveLesson(
    id: 'arduino_r3_3',
    courseId: 'arduino',
    title: 'Basış Sayacı',
    titleEn: 'Press Counter',
    titleDe: 'Tastendruck-Zähler',
    titleEs: 'Contador de pulsaciones',
    subtitle: 'Değişken ve seri port',
    subtitleEn: 'Variables and the serial port',
    subtitleDe: 'Variablen und der serielle Port',
    subtitleEs: 'Variables y el puerto serie',
    order: 9,
    xpReward: 60,
    steps: [
      const IntroStep(
        id: 'a3_3_intro',
        mascotEmoji: '🔢',
        mascotMessage: 'Butona kaç kez bastın? Kart bunu bir DEĞİŞKENDE aklında tutabilir '
            've seri porttan bilgisayara yazabilir.',
        mascotMessageEn: 'How many times did you press the button? The board can remember it in a VARIABLE '
            'and write it to the computer through the serial port.',
        mascotMessageDe: 'Wie oft hast du den Taster gedrückt? Die Platine merkt es sich in einer VARIABLE '
            'und schreibt es über den seriellen Port an den Computer.',
        mascotMessageEs: '¿Cuántas veces pulsaste el botón? La placa puede recordarlo en una VARIABLE '
            'y escribirlo al ordenador por el puerto serie.',
        highlights: ['Değişken', 'Sayaç', 'Seri port'],
        highlightsEn: ['Variable', 'Counter', 'Serial port'],
        highlightsDe: ['Variable', 'Zähler', 'Serieller Port'],
        highlightsEs: ['Variable', 'Contador', 'Puerto serie'],
      ),
      const ExplanationStep(
        id: 'a3_3_degisken',
        title: 'Değişken: Kartın Not Defteri',
        titleEn: 'A Variable: the Board\'s Notepad',
        titleDe: 'Eine Variable: der Notizblock der Platine',
        titleEs: 'Una variable: la libreta de la placa',
        content: '• Değişken, içinde bir sayı tutan kutudur. Bizimkinin adı "sayaç".\n'
            '• "sayaç değişkenini 0 yap" → kutuyu sıfırlar.\n'
            '• "sayaç i 1 kadar değiştir" → sayıyı 1 artırır.\n'
            '• "seri port … yaz" → değeri bilgisayara gönderir. Sahnedeki "Seri port" kutusunda görürsün.',
        contentEn: '• A variable is a box that holds a number. Ours is called "counter".\n'
            '• "set counter to 0" → empties the box.\n'
            '• "change counter by 1" → adds 1.\n'
            '• "serial write …" → sends the value to the computer. You see it in the "Serial port" box on the stage.',
        contentDe: '• Eine Variable ist eine Kiste, die eine Zahl hält. Unsere heißt „zähler“.\n'
            '• „setze zähler auf 0“ → leert die Kiste.\n'
            '• „ändere zähler um 1“ → zählt 1 dazu.\n'
            '• „serieller Port schreibt …“ → schickt den Wert an den Computer. Du siehst ihn im Feld „Serieller Port“ auf der Bühne.',
        contentEs: '• Una variable es una caja que guarda un número. La nuestra se llama «contador».\n'
            '• «dar a contador el valor 0» → vacía la caja.\n'
            '• «sumar a contador 1» → le suma 1.\n'
            '• «puerto serie escribe …» → envía el valor al ordenador. Lo ves en la caja «Puerto serie» del escenario.',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'sayaç i 1 kadar değiştir',
            contentEn: 'change counter by 1',
            contentDe: 'ändere zähler um 1',
            contentEs: 'sumar a contador 1',
            color: MBlockPalette.variables,
            label: 'Değişkenler',
            labelEn: 'Variables',
            labelDe: 'Variablen',
            labelEs: 'Variables',
          ),
        ],
      ),
      const MultipleChoiceStep(
        id: 'a3_3_q1',
        question: 'Sayaç 4. Üç kez daha "sayaç i 1 kadar değiştir" çalışırsa sayaç kaç olur?',
        questionEn: 'The counter is 4. If "change counter by 1" runs three more times, what is the counter?',
        questionDe: 'Der Zähler steht auf 4. Wenn „ändere zähler um 1“ noch dreimal läuft, wie viel zeigt er?',
        questionEs: 'El contador vale 4. Si «sumar a contador 1» se ejecuta tres veces más, ¿cuánto vale?',
        options: [
          ChoiceOption(text: '3', textEn: '3', textDe: '3', textEs: '3'),
          ChoiceOption(text: '5', textEn: '5', textDe: '5', textEs: '5'),
          ChoiceOption(text: '1', textEn: '1', textDe: '1', textEs: '1'),
          ChoiceOption(text: '7', textEn: '7', textDe: '7', textEs: '7'),
        ],
        correctIndex: 3,
        explanation: 'Her çalışmada 1 eklenir: 4 + 1 + 1 + 1 = 7.',
        explanationEn: 'Each run adds 1: 4 + 1 + 1 + 1 = 7.',
        explanationDe: 'Jeder Durchlauf zählt 1 dazu: 4 + 1 + 1 + 1 = 7.',
        explanationEs: 'Cada vez se suma 1: 4 + 1 + 1 + 1 = 7.',
      ),
      arduinoKodAdimi(
        id: 'a3_3_kod',
        talimat: 'Önce sayacı 0 yap. Sürekli tekrarla içinde: basılana kadar bekle, sayacı 1 artır, '
            'sayacı seri porta yaz, bırakılana kadar bekle. "B1 · basılı tut"a birkaç kez bas, Seri port kutusuna bak.',
        talimatEn: 'First set the counter to 0. Inside forever: wait until pressed, add 1 to the counter, '
            'write the counter to the serial port, wait until released. Press "B1 · hold" a few times and watch the Serial port box.',
        talimatDe: 'Setze zuerst den Zähler auf 0. In „wiederhole fortlaufend“: warten bis gedrückt, Zähler um 1 erhöhen, '
            'Zähler an den seriellen Port schreiben, warten bis losgelassen. Drücke ein paar Mal „B1 · gedrückt halten“ und schau ins Feld „Serieller Port“.',
        talimatEs: 'Primero pon el contador a 0. Dentro de por siempre: espera a que se pulse, suma 1 al contador, '
            'escribe el contador en el puerto serie, espera a que se suelte. Pulsa varias veces «B1 · mantener» y mira la caja Puerto serie.',
        hedef: 'Her basışta sayı 1 artsın ve seri porta yazılsın',
        hedefEn: 'Each press adds 1 and writes it to the serial port',
        hedefDe: 'Jeder Druck zählt 1 dazu und schreibt die Zahl an den seriellen Port',
        hedefEs: 'Cada pulsación suma 1 y lo escribe en el puerto serie',
        bloklar: const [
          'dev_kart_acilis',
          'dev_degisken_yap',
          'dev_surekli',
          'dev_bekle_kadar',
          'dev_dijital_oku',
          'dev_degil',
          'dev_degisken_degistir',
          'dev_seri_yaz',
          'dev_sayac_oku',
        ],
        cozum: [
          kartAcilis,
          degiskenYap('sayac', deger: 0),
          surekli([
            olanaKadarBekle(dijitalOku(2)),
            degiskenDegistir('sayac', 1),
            seriYaz(deger: degiskenOku('sayac')),
            olanaKadarBekle(degil(dijitalOku(2))),
          ]),
        ],
        devre: _butonDevre.tamami,
        xp: 40,
      ),
      const MultipleChoiceStep(
        id: 'a3_3_q2',
        question: '"sayaç değişkenini 0 yap" bloğunu sürekli tekrarla İÇİNE koyarsan ne olur?',
        questionEn: 'What happens if you put "set counter to 0" INSIDE forever?',
        questionDe: 'Was passiert, wenn du „setze zähler auf 0“ IN „wiederhole fortlaufend“ legst?',
        questionEs: '¿Qué pasa si pones «dar a contador el valor 0» DENTRO de por siempre?',
        options: [
          ChoiceOption(text: 'Sayaç her turda sıfırlanır, hep 1 yazar', textEn: 'The counter resets every round and always shows 1', textDe: 'Der Zähler wird jede Runde zurückgesetzt und zeigt immer 1', textEs: 'El contador se reinicia en cada vuelta y siempre muestra 1'),
          ChoiceOption(text: 'Sayaç iki kat hızlı artar', textEn: 'The counter goes up twice as fast', textDe: 'Der Zähler steigt doppelt so schnell', textEs: 'El contador sube el doble de rápido'),
          ChoiceOption(text: 'Seri port kapanır', textEn: 'The serial port closes', textDe: 'Der serielle Port schließt sich', textEs: 'El puerto serie se cierra'),
          ChoiceOption(text: 'Fark etmez, aynı çalışır', textEn: 'No difference, it works the same', textDe: 'Kein Unterschied, es läuft gleich', textEs: 'Da igual, funciona igual'),
        ],
        correctIndex: 0,
        explanation: 'Sıfırlama yalnızca bir kez, başta yapılmalı. Döngünün içinde olursa her basıştan önce sayaç yine 0 olur.',
        explanationEn: 'Resetting should happen only once, at the start. Inside the loop, the counter goes back to 0 before every press.',
        explanationDe: 'Zurücksetzen gehört nur einmal an den Anfang. In der Schleife springt der Zähler vor jedem Druck wieder auf 0.',
        explanationEs: 'El reinicio debe hacerse una sola vez, al principio. Dentro del bucle, el contador vuelve a 0 antes de cada pulsación.',
      ),
      const ExplanationStep(
        id: 'a3_3_ozet',
        title: 'Sayaç Çalışıyor!',
        titleEn: 'The Counter Works!',
        titleDe: 'Der Zähler läuft!',
        titleEs: '¡El contador funciona!',
        content: '✓ Bir değişkende sayı tuttun\n'
            '✓ Her basışta sayacı 1 artırdın\n'
            '✓ Değeri seri porttan bilgisayara yazdın\n\n'
            'Butonlar modülünü bitirdin!',
        contentEn: '✓ You kept a number in a variable\n'
            '✓ You added 1 to the counter on every press\n'
            '✓ You wrote the value to the computer through the serial port\n\n'
            'You finished the Buttons module!',
        contentDe: '✓ Du hast eine Zahl in einer Variable gespeichert\n'
            '✓ Bei jedem Druck zählt der Zähler 1 hoch\n'
            '✓ Den Wert über den seriellen Port an den Computer geschickt\n\n'
            'Du hast das Modul Taster geschafft!',
        contentEs: '✓ Guardaste un número en una variable\n'
            '✓ Sumaste 1 al contador en cada pulsación\n'
            '✓ Enviaste el valor al ordenador por el puerto serie\n\n'
            '¡Terminaste el módulo de botones!',
        tipEmoji: '🖥️',
        tip: 'Seri port, kodunda ne olduğunu görmenin en kolay yoludur.',
        tipEn: 'The serial port is the easiest way to see what is happening in your code.',
        tipDe: 'Der serielle Port ist der einfachste Weg zu sehen, was in deinem Code passiert.',
        tipEs: 'El puerto serie es la forma más fácil de ver qué pasa en tu código.',
      ),
    ],
  ),
];
