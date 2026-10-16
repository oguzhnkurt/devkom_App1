// ARDUINO KURSU — MODUL 2: LED'LER
//
// Bekleme suresiyle hiz, "… defa tekrarla", hata avcisi (eksik bekleme),
// uc LED'li trafik isigi ve kayan isik.
import '../../devre/arduino_projeleri.dart';
import '../../devre/devre_modeli.dart';
import '../../models/interactive_lesson_model.dart';
import '../mblock_palette.dart';
import 'ders_yardimcisi.dart';
import 'modul1.dart' show ilkLedDevresi;

/// Kirmizi (pin 12), sari (pin 11), yesil (pin 10) LED'ler.
final _trafikDevre = DevreKurmaStep(
  id: 'a2_2_devre',
  talimat: 'Üç LED\'i bağla: kırmızı pin 12\'ye, sarı pin 11\'e, yeşil pin 10\'a. GND kablosu hazır.',
  talimatEn: 'Wire up three LEDs: red to pin 12, yellow to pin 11, green to pin 10. The GND wire is ready.',
  talimatDe: 'Schließe drei LEDs an: Rot an Pin 12, Gelb an Pin 11, Grün an Pin 10. Das GND-Kabel steckt schon.',
  talimatEs: 'Conecta tres LED: el rojo al pin 12, el amarillo al 11 y el verde al 10. El cable GND ya está puesto.',
  parcalar: [
    ...DevreKalibi.led('L1', 10, renk: LedRengi.kirmizi),
    ...DevreKalibi.led('L2', 16, renk: LedRengi.sari),
    ...DevreKalibi.led('L3', 22, renk: LedRengi.yesil),
  ],
  hazirKablolar: [DevreKalibi.gndKablosu],
  hedefler: [
    ...DevreKalibi.ledHedefleri(12, 10),
    ...DevreKalibi.ledHedefleri(11, 16),
    ...DevreKalibi.ledHedefleri(10, 22),
  ],
  xpReward: 30,
);

final List<InteractiveLesson> arduinoModul2 = [
  // ---------------------------------------------------------------- 2.1
  InteractiveLesson(
    id: 'arduino_r2_1',
    courseId: 'arduino',
    title: 'Yanıp Sönme Hızı',
    titleEn: 'Blink Speed',
    titleDe: 'Blinktempo',
    titleEs: 'Velocidad del parpadeo',
    subtitle: 'Bekleme süresi ve "… defa tekrarla"',
    subtitleEn: 'Wait time and "repeat …"',
    subtitleDe: 'Wartezeit und „wiederhole … mal“',
    subtitleEs: 'Tiempo de espera y «repetir …»',
    order: 4,
    xpReward: 50,
    steps: [
      const IntroStep(
        id: 'a2_1_intro',
        mascotEmoji: '⏱️',
        mascotMessage: 'LED\'in ne kadar hızlı yanıp söneceğine sen karar verirsin. '
            'Sırrı bekleme bloğunda! Bir de LED\'i tam istediğin sayıda yakıp söndüreceğiz.',
        mascotMessageEn: 'You decide how fast the LED blinks. The secret is in the wait block! '
            'We will also blink the LED exactly as many times as you want.',
        mascotMessageDe: 'Du bestimmst, wie schnell die LED blinkt. Das Geheimnis steckt im Warteblock! '
            'Außerdem lassen wir die LED genau so oft blinken, wie du willst.',
        mascotMessageEs: 'Tú decides lo rápido que parpadea el LED. ¡El secreto está en el bloque de esperar! '
            'Además, lo haremos parpadear justo las veces que quieras.',
        highlights: ['Kısa bekleme = hızlı', '… defa tekrarla', 'Hata avcısı'],
        highlightsEn: ['Short wait = fast', 'repeat …', 'Bug hunter'],
        highlightsDe: ['Kurz warten = schnell', 'wiederhole … mal', 'Fehlerjagd'],
        highlightsEs: ['Espera corta = rápido', 'repetir …', 'Cazador de errores'],
      ),
      const ExplanationStep(
        id: 'a2_1_hiz',
        title: 'Bekleme Hızı Belirler',
        titleEn: 'The Wait Sets the Speed',
        titleDe: 'Die Wartezeit bestimmt das Tempo',
        titleEs: 'La espera marca la velocidad',
        content: '1. modülde kurduğun devre hazır: pin 13 → direnç → LED → GND.\n\n'
            '• "1 saniye bekle" → yavaş, sakin yanıp sönme.\n'
            '• "0.2 saniye bekle" → hızlı, telaşlı yanıp sönme.\n'
            '• Bekleme küçüldükçe LED hızlanır.',
        contentEn: 'The circuit you built in module 1 is ready: pin 13 → resistor → LED → GND.\n\n'
            '• "wait 1 seconds" → slow, calm blinking.\n'
            '• "wait 0.2 seconds" → fast, busy blinking.\n'
            '• The shorter the wait, the faster the LED.',
        contentDe: 'Die Schaltung aus Modul 1 steht schon: Pin 13 → Widerstand → LED → GND.\n\n'
            '• „warte 1 Sekunden“ → langsames, ruhiges Blinken.\n'
            '• „warte 0.2 Sekunden“ → schnelles, hektisches Blinken.\n'
            '• Je kürzer die Wartezeit, desto schneller die LED.',
        contentEs: 'El circuito que montaste en el módulo 1 ya está listo: pin 13 → resistencia → LED → GND.\n\n'
            '• «esperar 1 segundos» → parpadeo lento y tranquilo.\n'
            '• «esperar 0.2 segundos» → parpadeo rápido y nervioso.\n'
            '• Cuanto más corta la espera, más rápido el LED.',
        tipEmoji: '🐢',
        tip: '0.5 saniye, 1 saniyenin yarısıdır.',
        tipEn: '0.5 seconds is half of 1 second.',
        tipDe: '0.5 Sekunden sind die Hälfte von 1 Sekunde.',
        tipEs: '0.5 segundos es la mitad de 1 segundo.',
      ),
      ExplanationStep(
        id: 'a2_1_tekrar',
        title: 'Belli Sayıda Tekrar',
        titleEn: 'Repeat a Set Number of Times',
        titleDe: 'Eine bestimmte Anzahl wiederholen',
        titleEs: 'Repetir unas veces concretas',
        content: '"sürekli tekrarla" hiç durmaz. "10 defa tekrarla" ise içindekileri '
            'tam 10 kez yapar, sonra durur.\n\n'
            'Sayıyı değiştirerek LED\'in kaç kez yanıp söneceğini seçersin.',
        contentEn: '"forever" never stops. "repeat 10" runs the blocks inside exactly '
            '10 times, then stops.\n\n'
            'Change the number to choose how many times the LED blinks.',
        contentDe: '„wiederhole fortlaufend“ hört nie auf. „wiederhole 10 mal“ führt die Blöcke '
            'darin genau 10-mal aus und hört dann auf.\n\n'
            'Mit der Zahl wählst du, wie oft die LED blinkt.',
        contentEs: '«por siempre» nunca se detiene. «repetir 10» hace los bloques de dentro '
            'exactamente 10 veces y luego para.\n\n'
            'Cambia el número para elegir cuántas veces parpadea el LED.',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: '10 defa tekrarla',
            contentEn: 'repeat 10',
            contentDe: 'wiederhole 10 mal',
            contentEs: 'repetir 10',
            color: MBlockPalette.control,
            label: 'Kontrol',
            labelEn: 'Control',
            labelDe: 'Steuerung',
            labelEs: 'Control',
          ),
        ],
      ),
      arduinoKodAdimi(
        id: 'a2_1_kod',
        talimat: 'LED 5 kez hızlıca yanıp sönsün: 5 defa tekrarla içinde yak, 0.2 saniye bekle, söndür, 0.2 saniye bekle.',
        talimatEn: 'Make the LED blink fast 5 times: inside repeat 5, turn it on, wait 0.2 seconds, turn it off, wait 0.2 seconds.',
        talimatDe: 'Lass die LED 5-mal schnell blinken: In „wiederhole 5 mal“ an, 0.2 Sekunden warten, aus, 0.2 Sekunden warten.',
        talimatEs: 'Haz que el LED parpadee rápido 5 veces: dentro de repetir 5, enciende, espera 0.2 segundos, apaga, espera 0.2 segundos.',
        hedef: '5 kez: yan, 0.2 bekle, sön, 0.2 bekle',
        hedefEn: '5 times: on, wait 0.2, off, wait 0.2',
        hedefDe: '5-mal: an, 0.2 warten, aus, 0.2 warten',
        hedefEs: '5 veces: encender, esperar 0.2, apagar, esperar 0.2',
        bloklar: const ['dev_kart_acilis', 'dev_tekrarla', 'dev_surekli', 'dev_dijital_yaz', 'dev_bekle'],
        cozum: [
          kartAcilis,
          tekrarla(5, [dijitalYaz(13, true), bekle(0.2), dijitalYaz(13, false), bekle(0.2)]),
        ],
        devre: ilkLedDevresi,
      ),
      arduinoKodAdimi(
        id: 'a2_1_hata',
        talimat: 'Hata avcısı! Bu programda LED hep yanık görünüyor. Söndükten hemen sonra yeniden yanıyor. Eksik bloğu ekle.',
        talimatEn: 'Bug hunter! In this program the LED looks always on. It turns back on right after turning off. Add the missing block.',
        talimatDe: 'Fehlerjagd! In diesem Programm scheint die LED immer an zu sein. Sie geht gleich nach dem Ausschalten wieder an. Füge den fehlenden Block ein.',
        talimatEs: '¡Cazador de errores! En este programa el LED parece siempre encendido. Se vuelve a encender justo después de apagarse. Añade el bloque que falta.',
        hedef: 'Söndükten sonra da 1 saniye bekle',
        hedefEn: 'Also wait 1 second after turning it off',
        hedefDe: 'Auch nach dem Ausschalten 1 Sekunde warten',
        hedefEs: 'Espera 1 segundo también después de apagarlo',
        bloklar: const ['dev_kart_acilis', 'dev_surekli', 'dev_dijital_yaz', 'dev_bekle'],
        baslangic: [
          kartAcilis,
          surekli([dijitalYaz(13, true), bekle(1), dijitalYaz(13, false)]),
        ],
        hataAvcisi: true,
        cozum: [
          kartAcilis,
          surekli([dijitalYaz(13, true), bekle(1), dijitalYaz(13, false), bekle(1)]),
        ],
        devre: ilkLedDevresi,
        xp: 35,
      ),
      const MultipleChoiceStep(
        id: 'a2_1_q1',
        question: 'LED\'in DAHA YAVAŞ yanıp sönmesi için ne yaparsın?',
        questionEn: 'What do you do to make the LED blink MORE SLOWLY?',
        questionDe: 'Was tust du, damit die LED LANGSAMER blinkt?',
        questionEs: '¿Qué haces para que el LED parpadee MÁS DESPACIO?',
        options: [
          ChoiceOption(text: 'Bekleme süresini küçültürüm', textEn: 'Make the wait shorter', textDe: 'Ich mache die Wartezeit kürzer', textEs: 'Hago la espera más corta'),
          ChoiceOption(text: 'Pin numarasını büyütürüm', textEn: 'Use a bigger pin number', textDe: 'Ich nehme eine größere Pinnummer', textEs: 'Uso un número de pin más alto'),
          ChoiceOption(text: 'Bekleme süresini büyütürüm', textEn: 'Make the wait longer', textDe: 'Ich mache die Wartezeit länger', textEs: 'Hago la espera más larga'),
          ChoiceOption(text: 'Tekrar sayısını artırırım', textEn: 'Raise the repeat count', textDe: 'Ich erhöhe die Wiederholungen', textEs: 'Subo el número de repeticiones'),
        ],
        correctIndex: 2,
        explanation: 'Uzun bekleme = LED her durumda daha uzun kalır, yani daha yavaş yanıp söner.',
        explanationEn: 'A longer wait keeps the LED in each state longer, so it blinks more slowly.',
        explanationDe: 'Längeres Warten hält die LED länger an und aus, also blinkt sie langsamer.',
        explanationEs: 'Una espera más larga mantiene el LED más tiempo en cada estado, así parpadea más despacio.',
      ),
      const ExplanationStep(
        id: 'a2_1_ozet',
        title: 'Hızı Sen Belirliyorsun!',
        titleEn: 'You Set the Speed!',
        titleDe: 'Du bestimmst das Tempo!',
        titleEs: '¡Tú marcas la velocidad!',
        content: '✓ Bekleme süresiyle yanıp sönme hızını değiştirdin\n'
            '✓ "… defa tekrarla" ile LED\'i tam 5 kez yaktın\n'
            '✓ Eksik beklemeyi bulup düzelttin\n\n'
            'Sıradaki derste üç LED\'le trafik ışığı yapıyoruz.',
        contentEn: '✓ You changed the blink speed with the wait time\n'
            '✓ You blinked the LED exactly 5 times with "repeat …"\n'
            '✓ You found and fixed the missing wait\n\n'
            'Next lesson: a traffic light with three LEDs.',
        contentDe: '✓ Du hast das Blinktempo mit der Wartezeit geändert\n'
            '✓ Mit „wiederhole … mal“ hat die LED genau 5-mal geblinkt\n'
            '✓ Du hast das fehlende Warten gefunden und repariert\n\n'
            'Nächste Lektion: eine Ampel mit drei LEDs.',
        contentEs: '✓ Cambiaste la velocidad del parpadeo con el tiempo de espera\n'
            '✓ Hiciste parpadear el LED justo 5 veces con «repetir …»\n'
            '✓ Encontraste y arreglaste la espera que faltaba\n\n'
            'Siguiente lección: un semáforo con tres LED.',
        tipEmoji: '⚡',
        tip: 'Kart çok hızlıdır: beklemeden söndürüp yakarsan gözün farkı göremez.',
        tipEn: 'The board is very fast: if it turns the LED off and on without waiting, your eyes cannot see it.',
        tipDe: 'Die Platine ist sehr schnell: Schaltet sie ohne Warten aus und an, sieht dein Auge das nicht.',
        tipEs: 'La placa es muy rápida: si apaga y enciende sin esperar, tus ojos no lo notan.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 2.2
  InteractiveLesson(
    id: 'arduino_3_1',
    courseId: 'arduino',
    title: 'Trafik Işığı',
    titleEn: 'Traffic Light',
    titleDe: 'Ampel',
    titleEs: 'Semáforo',
    subtitle: 'Üç LED, üç pin, doğru sıra',
    subtitleEn: 'Three LEDs, three pins, the right order',
    subtitleDe: 'Drei LEDs, drei Pins, die richtige Reihenfolge',
    subtitleEs: 'Tres LED, tres pines, el orden correcto',
    order: 5,
    xpReward: 70,
    badge: 'traffic_light_master',
    steps: [
      const IntroStep(
        id: 'a2_2_intro',
        mascotEmoji: '🚦',
        mascotMessage: 'Şimdi her LED kendi pinine bağlanacak. '
            'Kırmızı, sarı ve yeşili sırayla yakarak gerçek bir trafik ışığı yapacağız.',
        mascotMessageEn: 'Now each LED gets its own pin. '
            'By lighting red, yellow and green in turn, we build a real traffic light.',
        mascotMessageDe: 'Jetzt bekommt jede LED ihren eigenen Pin. '
            'Wir lassen Rot, Gelb und Grün nacheinander leuchten und bauen eine echte Ampel.',
        mascotMessageEs: 'Ahora cada LED tiene su propio pin. '
            'Encendiendo rojo, amarillo y verde por turnos, haremos un semáforo de verdad.',
        highlights: ['Her LED\'e bir pin', 'Üç LED\'li devre', 'Işık sırası'],
        highlightsEn: ['One pin per LED', 'A three-LED circuit', 'The light order'],
        highlightsDe: ['Ein Pin pro LED', 'Schaltung mit drei LEDs', 'Die Lichtreihenfolge'],
        highlightsEs: ['Un pin por LED', 'Circuito de tres LED', 'El orden de las luces'],
      ),
      const ExplanationStep(
        id: 'a2_2_pin',
        title: 'Her LED\'in Kendi Pini',
        titleEn: 'Each LED Has Its Own Pin',
        titleDe: 'Jede LED hat ihren eigenen Pin',
        titleEs: 'Cada LED tiene su pin',
        content: '• Kırmızı → pin 12, sarı → pin 11, yeşil → pin 10.\n'
            '• Üç LED\'in kısa bacakları aynı − hattına gider; tek GND kablosu yeter.\n'
            '• Kodda hangi pini "yüksek" yaparsan o LED yanar.',
        contentEn: '• Red → pin 12, yellow → pin 11, green → pin 10.\n'
            '• All three short legs go to the same − rail; one GND wire is enough.\n'
            '• Whichever pin you set "high" in the code, that LED lights.',
        contentDe: '• Rot → Pin 12, Gelb → Pin 11, Grün → Pin 10.\n'
            '• Die drei kurzen Beine gehen an dieselbe −-Schiene; ein GND-Kabel reicht.\n'
            '• Welchen Pin du im Code auf „hoch“ setzt, diese LED leuchtet.',
        contentEs: '• Rojo → pin 12, amarillo → pin 11, verde → pin 10.\n'
            '• Las tres patas cortas van a la misma línea −; basta un cable GND.\n'
            '• El pin que pongas en «alto» en el código es el LED que se enciende.',
        tipEmoji: '🎨',
        tip: 'Pinleri karıştırmamak için kablo renklerini LED renkleriyle eşleştirebilirsin.',
        tipEn: 'To keep pins apart, you can match wire colors to the LED colors.',
        tipDe: 'Damit du die Pins nicht verwechselst, nimm Kabelfarben passend zu den LEDs.',
        tipEs: 'Para no confundir pines, puedes usar cables del mismo color que los LED.',
      ),
      _trafikDevre,
      arduinoKodAdimi(
        id: 'a2_2_kod',
        talimat: 'Trafik ışığı: kırmızı 3 saniye, yeşil 3 saniye, sarı 1 saniye yansın. Her ışık sırası gelince yansın, sonra sönsün.',
        talimatEn: 'Traffic light: red for 3 seconds, green for 3 seconds, yellow for 1 second. Each light turns on in its turn, then off.',
        talimatDe: 'Ampel: Rot 3 Sekunden, Grün 3 Sekunden, Gelb 1 Sekunde. Jedes Licht geht an, wenn es dran ist, und dann wieder aus.',
        talimatEs: 'Semáforo: rojo 3 segundos, verde 3 segundos, amarillo 1 segundo. Cada luz se enciende en su turno y luego se apaga.',
        hedef: 'Kırmızı 3 sn → yeşil 3 sn → sarı 1 sn; sonsuza kadar',
        hedefEn: 'Red 3 s → green 3 s → yellow 1 s; forever',
        hedefDe: 'Rot 3 s → Grün 3 s → Gelb 1 s; immer wieder',
        hedefEs: 'Rojo 3 s → verde 3 s → amarillo 1 s; para siempre',
        bloklar: const ['dev_kart_acilis', 'dev_surekli', 'dev_dijital_yaz', 'dev_bekle'],
        cozum: [
          kartAcilis,
          surekli([
            dijitalYaz(12, true), bekle(3), dijitalYaz(12, false),
            dijitalYaz(10, true), bekle(3), dijitalYaz(10, false),
            dijitalYaz(11, true), bekle(1), dijitalYaz(11, false),
          ]),
        ],
        devre: _trafikDevre.tamami,
        xp: 40,
      ),
      const MultipleChoiceStep(
        id: 'a2_2_q1',
        question: 'Trafik ışığında yeşil LED yanmıyor, kırmızı ve sarı çalışıyor. Önce neye bakarsın?',
        questionEn: 'On the traffic light the green LED stays dark, red and yellow work. What do you check first?',
        questionDe: 'Bei der Ampel bleibt die grüne LED dunkel, Rot und Gelb gehen. Was prüfst du zuerst?',
        questionEs: 'En el semáforo el LED verde no se enciende, el rojo y el amarillo sí. ¿Qué revisas primero?',
        options: [
          ChoiceOption(text: 'GND kablosunu söküp atarım', textEn: 'I pull out the GND wire', textDe: 'Ich ziehe das GND-Kabel ab', textEs: 'Quito el cable GND'),
          ChoiceOption(text: 'Pin 10 kablosuna ve kodda pin 10 yazıyor mu', textEn: 'The pin 10 wire, and whether the code says pin 10', textDe: 'Das Kabel an Pin 10 und ob im Code Pin 10 steht', textEs: 'El cable del pin 10 y si el código dice pin 10'),
          ChoiceOption(text: 'Kırmızı LED\'i değiştiririm', textEn: 'I replace the red LED', textDe: 'Ich tausche die rote LED aus', textEs: 'Cambio el LED rojo'),
          ChoiceOption(text: 'Bekleme sürelerini sıfır yaparım', textEn: 'I set all waits to zero', textDe: 'Ich setze alle Wartezeiten auf null', textEs: 'Pongo todas las esperas a cero'),
        ],
        correctIndex: 1,
        explanation: 'Öbür LED\'ler yanıyorsa GND sağlam. Sorun yeşilin kendi yolunda: pin 10 kablosu, kodu ya da LED\'in yönü.',
        explanationEn: 'If the others light, GND is fine. The problem is on green\'s own path: the pin 10 wire, the code, or the LED\'s direction.',
        explanationDe: 'Leuchten die anderen, ist GND in Ordnung. Der Fehler liegt im Weg der grünen LED: Kabel an Pin 10, Code oder LED-Richtung.',
        explanationEs: 'Si los otros se encienden, GND está bien. El problema está en el camino del verde: el cable del pin 10, el código o el sentido del LED.',
      ),
      const ExplanationStep(
        id: 'a2_2_ozet',
        title: 'Trafik Işığı Ustası!',
        titleEn: 'Traffic Light Master!',
        titleDe: 'Ampel-Meister!',
        titleEs: '¡Maestro del semáforo!',
        content: '✓ Üç LED\'i üç ayrı pine bağladın\n'
            '✓ Tek GND kablosunu üç LED\'e paylaştırdın\n'
            '✓ Işıkları doğru sırayla ve sürelerle yaktın\n\n'
            'Sıradaki derste ışık LED\'den LED\'e kayacak.',
        contentEn: '✓ You wired three LEDs to three different pins\n'
            '✓ One GND wire serves all three LEDs\n'
            '✓ You lit the lights in the right order and timing\n\n'
            'Next lesson: the light slides from LED to LED.',
        contentDe: '✓ Drei LEDs an drei verschiedenen Pins\n'
            '✓ Ein GND-Kabel für alle drei LEDs\n'
            '✓ Die Lichter in der richtigen Reihenfolge und Zeit\n\n'
            'Nächste Lektion: Das Licht wandert von LED zu LED.',
        contentEs: '✓ Conectaste tres LED a tres pines distintos\n'
            '✓ Un solo cable GND sirve para los tres LED\n'
            '✓ Encendiste las luces en el orden y el tiempo correctos\n\n'
            'Siguiente lección: la luz corre de LED en LED.',
        tipEmoji: '🏆',
        tip: 'Trafik Işığı Ustası rozetini kazandın!',
        tipEn: 'You earned the Traffic Light Master badge!',
        tipDe: 'Du hast das Abzeichen „Ampel-Meister“ verdient!',
        tipEs: '¡Has ganado la insignia Maestro del Semáforo!',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 2.3
  InteractiveLesson(
    id: 'arduino_r2_3',
    courseId: 'arduino',
    title: 'Kayan Işık',
    titleEn: 'Running Light',
    titleDe: 'Lauflicht',
    titleEs: 'Luz que corre',
    subtitle: 'Işık LED\'den LED\'e koşuyor',
    subtitleEn: 'The light runs from LED to LED',
    subtitleDe: 'Das Licht läuft von LED zu LED',
    subtitleEs: 'La luz corre de LED en LED',
    order: 6,
    xpReward: 60,
    steps: [
      const IntroStep(
        id: 'a2_3_intro',
        mascotEmoji: '🏃',
        mascotMessage: 'Trafik ışığı devren duruyor. Bu kez LED\'leri kısa kısa, '
            'art arda yakıp ışığı bir uçtan öbürüne koşturacağız.',
        mascotMessageEn: 'Your traffic light circuit is still there. This time we light the LEDs '
            'quickly, one after another, so the light runs from one end to the other.',
        mascotMessageDe: 'Deine Ampelschaltung steht noch. Diesmal schalten wir die LEDs kurz '
            'nacheinander, damit das Licht von einem Ende zum anderen läuft.',
        mascotMessageEs: 'Tu circuito del semáforo sigue ahí. Esta vez encendemos los LED rápido, '
            'uno tras otro, para que la luz corra de un extremo al otro.',
        highlights: ['Art arda yakma', 'Kısa bekleme', 'Gidip gelen ışık'],
        highlightsEn: ['One after another', 'Short waits', 'Back-and-forth light'],
        highlightsDe: ['Nacheinander schalten', 'Kurze Wartezeiten', 'Hin und her'],
        highlightsEs: ['Uno tras otro', 'Esperas cortas', 'Luz de ida y vuelta'],
      ),
      const ExplanationStep(
        id: 'a2_3_kayma',
        title: 'Işık Nasıl Kayar?',
        titleEn: 'How Does the Light Move?',
        titleDe: 'Wie wandert das Licht?',
        titleEs: '¿Cómo se mueve la luz?',
        content: 'Aynı anda yalnız bir LED yanar:\n\n'
            '• Pin 12\'yi yak, biraz bekle, söndür.\n'
            '• Hemen pin 11\'i yak, bekle, söndür.\n'
            '• Sonra pin 10.\n\n'
            'Bekleme kısa olunca göz bunu kayan bir ışık gibi görür.',
        contentEn: 'Only one LED is on at a time:\n\n'
            '• Turn on pin 12, wait a bit, turn it off.\n'
            '• Right away turn on pin 11, wait, turn it off.\n'
            '• Then pin 10.\n\n'
            'With short waits, your eyes see a light that runs.',
        contentDe: 'Es leuchtet immer nur eine LED:\n\n'
            '• Pin 12 an, kurz warten, aus.\n'
            '• Sofort Pin 11 an, warten, aus.\n'
            '• Dann Pin 10.\n\n'
            'Bei kurzen Wartezeiten sieht dein Auge ein wanderndes Licht.',
        contentEs: 'Solo hay un LED encendido a la vez:\n\n'
            '• Enciende el pin 12, espera un poco, apágalo.\n'
            '• Enseguida enciende el 11, espera, apágalo.\n'
            '• Luego el pin 10.\n\n'
            'Con esperas cortas, tus ojos ven una luz que corre.',
        tipEmoji: '👀',
        tip: 'Kayan ışığın devresi trafik ışığınınkiyle aynı; yalnızca kod değişiyor.',
        tipEn: 'The running light uses the same circuit as the traffic light; only the code changes.',
        tipDe: 'Das Lauflicht nutzt dieselbe Schaltung wie die Ampel; nur der Code ändert sich.',
        tipEs: 'La luz que corre usa el mismo circuito que el semáforo; solo cambia el código.',
      ),
      arduinoKodAdimi(
        id: 'a2_3_kod',
        talimat: 'Işık kırmızıdan yeşile kaysın: her LED\'i sırayla yak, 0.2 saniye bekle, söndür.',
        talimatEn: 'Make the light run from red to green: light each LED in turn, wait 0.2 seconds, turn it off.',
        talimatDe: 'Lass das Licht von Rot nach Grün laufen: Jede LED der Reihe nach an, 0.2 Sekunden warten, aus.',
        talimatEs: 'Haz que la luz corra del rojo al verde: enciende cada LED por turno, espera 0.2 segundos y apágalo.',
        hedef: '12 → 11 → 10, her biri 0.2 sn; sonsuza kadar',
        hedefEn: '12 → 11 → 10, 0.2 s each; forever',
        hedefDe: '12 → 11 → 10, je 0.2 s; immer wieder',
        hedefEs: '12 → 11 → 10, 0.2 s cada uno; para siempre',
        bloklar: const ['dev_kart_acilis', 'dev_surekli', 'dev_dijital_yaz', 'dev_bekle'],
        cozum: [
          kartAcilis,
          surekli([
            dijitalYaz(12, true), bekle(0.2), dijitalYaz(12, false),
            dijitalYaz(11, true), bekle(0.2), dijitalYaz(11, false),
            dijitalYaz(10, true), bekle(0.2), dijitalYaz(10, false),
          ]),
        ],
        devre: _trafikDevre.tamami,
        xp: 35,
      ),
      arduinoKodAdimi(
        id: 'a2_3_kod2',
        talimat: 'Şimdi ışık gidip gelsin: 12, 11, 10 ve geri 11. Her LED 0.2 saniye yansın.',
        talimatEn: 'Now make the light go back and forth: 12, 11, 10 and back to 11. Each LED stays on for 0.2 seconds.',
        talimatDe: 'Jetzt soll das Licht hin und her laufen: 12, 11, 10 und zurück zu 11. Jede LED leuchtet 0.2 Sekunden.',
        talimatEs: 'Ahora la luz va y vuelve: 12, 11, 10 y otra vez 11. Cada LED se enciende 0.2 segundos.',
        hedef: '12 → 11 → 10 → 11; sonsuza kadar',
        hedefEn: '12 → 11 → 10 → 11; forever',
        hedefDe: '12 → 11 → 10 → 11; immer wieder',
        hedefEs: '12 → 11 → 10 → 11; para siempre',
        bloklar: const ['dev_kart_acilis', 'dev_surekli', 'dev_dijital_yaz', 'dev_bekle'],
        cozum: [
          kartAcilis,
          surekli([
            dijitalYaz(12, true), bekle(0.2), dijitalYaz(12, false),
            dijitalYaz(11, true), bekle(0.2), dijitalYaz(11, false),
            dijitalYaz(10, true), bekle(0.2), dijitalYaz(10, false),
            dijitalYaz(11, true), bekle(0.2), dijitalYaz(11, false),
          ]),
        ],
        devre: _trafikDevre.tamami,
        xp: 40,
      ),
      const MultipleChoiceStep(
        id: 'a2_3_q1',
        question: 'Kayan ışığın DAHA HIZLI koşması için beklemeleri kaç saniye yaparsın?',
        questionEn: 'To make the running light go FASTER, what do you set the waits to?',
        questionDe: 'Damit das Lauflicht SCHNELLER läuft, auf wie viele Sekunden stellst du die Wartezeiten?',
        questionEs: 'Para que la luz corra MÁS RÁPIDO, ¿a cuántos segundos pones las esperas?',
        options: [
          ChoiceOption(text: '0.5 saniye', textEn: '0.5 seconds', textDe: '0.5 Sekunden', textEs: '0.5 segundos'),
          ChoiceOption(text: '1 saniye', textEn: '1 second', textDe: '1 Sekunde', textEs: '1 segundo'),
          ChoiceOption(text: '2 saniye', textEn: '2 seconds', textDe: '2 Sekunden', textEs: '2 segundos'),
          ChoiceOption(text: '0.1 saniye', textEn: '0.1 seconds', textDe: '0.1 Sekunden', textEs: '0.1 segundos'),
        ],
        correctIndex: 3,
        explanation: 'Şu an 0.2 saniye. Daha kısa bekleme (0.1) ışığı hızlandırır; daha uzunlar yavaşlatır.',
        explanationEn: 'Right now it is 0.2 seconds. A shorter wait (0.1) speeds the light up; longer ones slow it down.',
        explanationDe: 'Gerade sind es 0.2 Sekunden. Kürzer (0.1) macht das Licht schneller, länger macht es langsamer.',
        explanationEs: 'Ahora son 0.2 segundos. Una espera más corta (0.1) acelera la luz; las más largas la frenan.',
      ),
      const ExplanationStep(
        id: 'a2_3_ozet',
        title: 'Işık Koşuyor!',
        titleEn: 'The Light Is Running!',
        titleDe: 'Das Licht läuft!',
        titleEs: '¡La luz corre!',
        content: '✓ LED\'leri art arda yakıp kayan ışık yaptın\n'
            '✓ Işığı gidip gelir hale getirdin\n'
            '✓ Bekleme süresinin hızı belirlediğini pekiştirdin\n\n'
            'Sıradaki modülde karta yeni parçalar ekliyoruz.',
        contentEn: '✓ You made a running light by lighting LEDs one after another\n'
            '✓ You made the light go back and forth\n'
            '✓ You practiced how the wait time sets the speed\n\n'
            'Next module: we add new parts to the board.',
        contentDe: '✓ Du hast ein Lauflicht gebaut, LED für LED\n'
            '✓ Das Licht läuft hin und her\n'
            '✓ Die Wartezeit bestimmt das Tempo – das sitzt jetzt\n\n'
            'Nächstes Modul: Wir schließen neue Bauteile an.',
        contentEs: '✓ Hiciste una luz que corre encendiendo los LED uno tras otro\n'
            '✓ Hiciste que la luz fuera y volviera\n'
            '✓ Repasaste que la espera marca la velocidad\n\n'
            'Siguiente módulo: añadimos piezas nuevas a la placa.',
        tipEmoji: '🌟',
        tip: 'Daha çok LED eklersen ışık daha uzun bir yolda koşar.',
        tipEn: 'Add more LEDs and the light runs along a longer track.',
        tipDe: 'Mit mehr LEDs läuft das Licht eine längere Strecke.',
        tipEs: 'Si añades más LED, la luz recorre un camino más largo.',
      ),
    ],
  ),
];
