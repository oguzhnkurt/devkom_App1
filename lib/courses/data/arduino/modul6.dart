// ARDUINO KURSU — MODUL 6: MESAFE, SERVO VE FINAL
//
// Ultrasonik mesafe sensoru (park sensoru), servo motor (aci ve tarama),
// final projesi: mesafe + servo + LED ile akilli otopark bariyeri.
import '../../devre/arduino_projeleri.dart';
import '../../devre/devre_modeli.dart';
import '../../models/interactive_lesson_model.dart';
import '../mblock_palette.dart';
import 'ders_yardimcisi.dart';

/// Mesafe sensoru (trig 12, echo 11) + buzzer (pin 8).
final _parkDevre = DevreKurmaStep(
  id: 'a6_1_devre',
  talimat: 'Mesafe sensörünü ve buzzer\'ı bağla: TRIG pin 12\'ye, ECHO pin 11\'e, buzzer pin 8\'e.',
  talimatEn: 'Wire up the distance sensor and the buzzer: TRIG to pin 12, ECHO to pin 11, buzzer to pin 8.',
  talimatDe: 'Schließe Abstandssensor und Summer an: TRIG an Pin 12, ECHO an Pin 11, Summer an Pin 8.',
  talimatEs: 'Conecta el sensor de distancia y el zumbador: TRIG al pin 12, ECHO al pin 11 y el zumbador al pin 8.',
  parcalar: [...DevreKalibi.mesafe(), ...DevreKalibi.buzzer(20)],
  hazirKablolar: [DevreKalibi.gndKablosu, DevreKalibi.vKablosu],
  hedefler: [...DevreKalibi.mesafeHedefleri, ...DevreKalibi.buzzerHedefleri(20)],
  xpReward: 25,
);

/// Servo: GND, 5V (+ hatti), sinyal pin 9.
final _servoDevre = DevreKurmaStep(
  id: 'a6_2_devre',
  talimat: 'Servonun üç kablosunu bağla: kahverengi GND\'ye, kırmızı + hattına, turuncu pin 9\'a.',
  talimatEn: 'Connect the servo\'s three wires: brown to GND, red to the + rail, orange to pin 9.',
  talimatDe: 'Schließe die drei Servokabel an: braun an GND, rot an die +-Schiene, orange an Pin 9.',
  talimatEs: 'Conecta los tres cables del servo: marrón a GND, rojo a la línea + y naranja al pin 9.',
  parcalar: DevreKalibi.servo(),
  hazirKablolar: [DevreKalibi.gndKablosu, DevreKalibi.vKablosu],
  hedefler: DevreKalibi.servoHedefleri,
  xpReward: 25,
);

/// Final: mesafe sensoru (hazir bagli) + servo + yesil LED (pin 13).
final _bariyerDevre = DevreKurmaStep(
  id: 'a6_3_devre',
  talimat: 'Mesafe sensörü hazır bağlı. Sen bariyeri (servo, pin 9) ve yeşil LED\'i (pin 13) ekle.',
  talimatEn: 'The distance sensor is already wired. You add the barrier (servo, pin 9) and the green LED (pin 13).',
  talimatDe: 'Der Abstandssensor ist schon angeschlossen. Du ergänzt die Schranke (Servo, Pin 9) und die grüne LED (Pin 13).',
  talimatEs: 'El sensor de distancia ya está conectado. Tú añades la barrera (servo, pin 9) y el LED verde (pin 13).',
  parcalar: [
    ...DevreKalibi.mesafe(),
    ...DevreKalibi.servo(),
    ...DevreKalibi.led('L1', 22, renk: LedRengi.yesil),
  ],
  hazirKablolar: [
    DevreKalibi.gndKablosu,
    DevreKalibi.vKablosu,
    ...DevreKalibi.mesafeKablolari,
  ],
  hedefler: [...DevreKalibi.servoHedefleri, ...DevreKalibi.ledHedefleri(13, 22)],
  xpReward: 30,
);

final List<InteractiveLesson> arduinoModul6 = [
  // ---------------------------------------------------------------- 6.1
  InteractiveLesson(
    id: 'arduino_5_1',
    courseId: 'arduino',
    title: 'Park Sensörü',
    titleEn: 'Parking Sensor',
    titleDe: 'Einparkhilfe',
    titleEs: 'Sensor de aparcamiento',
    subtitle: 'Ultrasonik sensörle uzaklık ölç, yaklaşınca bip',
    subtitleEn: 'Measure distance with sound, beep when close',
    subtitleDe: 'Abstand mit Ultraschall messen, piepen wenn nah',
    subtitleEs: 'Mide la distancia con ultrasonidos y pita si está cerca',
    order: 16,
    xpReward: 70,
    badge: 'ultrasonic_master',
    steps: [
      const IntroStep(
        id: 'a6_1_intro',
        mascotEmoji: '🦇',
        mascotMessage: 'Yarasalar karanlıkta ses gönderir ve yankıyı dinleyerek yol bulur. '
            'Arabaların park sensörü de aynısını yapar. Bugün biz de bir park sensörü yapıyoruz!',
        mascotMessageEn: 'Bats send out sounds in the dark and find their way by listening to the echo. '
            'A car\'s parking sensor does the same. Today we build one too!',
        mascotMessageDe: 'Fledermäuse rufen im Dunkeln und finden ihren Weg über das Echo. '
            'Die Einparkhilfe im Auto macht es genauso. Heute bauen wir selbst eine!',
        mascotMessageEs: 'Los murciélagos emiten sonidos en la oscuridad y se orientan con el eco. '
            'El sensor de aparcamiento de un coche hace lo mismo. ¡Hoy construimos uno!',
        highlights: ['Ses ve yankı', 'Uzaklığı cm ile oku', 'Yaklaşınca bip'],
        highlightsEn: ['Sound and echo', 'Read the distance in cm', 'Beep when close'],
        highlightsDe: ['Schall und Echo', 'Abstand in cm lesen', 'Piepen, wenn es nah ist'],
        highlightsEs: ['Sonido y eco', 'Lee la distancia en cm', 'Pita al acercarse'],
      ),
      const ExplanationStep(
        id: 'a6_1_sensor',
        title: 'Yarasa Gibi Ölçen Sensör',
        titleEn: 'A Sensor That Measures Like a Bat',
        titleDe: 'Ein Sensor, der misst wie eine Fledermaus',
        titleEs: 'Un sensor que mide como un murciélago',
        content: 'Ultrasonik sensörün iki "gözü" var: biri duyamadığımız bir ses gönderir, '
            'öbürü yankıyı dinler. Yankı ne kadar geç dönerse engel o kadar uzaktır.\n\n'
            '• VCC → + hattı, GND → − hattı\n'
            '• TRIG → pin 12 (sesi gönder)\n'
            '• ECHO → pin 11 (yankıyı dinle)',
        contentEn: 'The ultrasonic sensor has two "eyes": one sends a sound we cannot hear, '
            'the other listens for the echo. The later the echo returns, the farther away the obstacle is.\n\n'
            '• VCC → + rail, GND → − rail\n'
            '• TRIG → pin 12 (send the sound)\n'
            '• ECHO → pin 11 (listen for the echo)',
        contentDe: 'Der Ultraschallsensor hat zwei „Augen“: Eines sendet einen Ton, den wir nicht hören, '
            'das andere lauscht auf das Echo. Je später das Echo zurückkommt, desto weiter weg ist das Hindernis.\n\n'
            '• VCC → +-Schiene, GND → −-Schiene\n'
            '• TRIG → Pin 12 (Ton senden)\n'
            '• ECHO → Pin 11 (Echo hören)',
        contentEs: 'El sensor ultrasónico tiene dos «ojos»: uno emite un sonido que no oímos '
            'y el otro escucha el eco. Cuanto más tarda el eco en volver, más lejos está el obstáculo.\n\n'
            '• VCC → línea +, GND → línea −\n'
            '• TRIG → pin 12 (envía el sonido)\n'
            '• ECHO → pin 11 (escucha el eco)',
        tipEmoji: '🔊',
        tip: 'Bu ses o kadar ince ki insan kulağı duyamaz, ama yarasalar duyar.',
        tipEn: 'This sound is so high that human ears cannot hear it, but bats can.',
        tipDe: 'Der Ton ist so hoch, dass Menschen ihn nicht hören, Fledermäuse aber schon.',
        tipEs: 'Este sonido es tan agudo que el oído humano no lo oye, pero los murciélagos sí.',
      ),
      ExplanationStep(
        id: 'a6_1_blok',
        title: 'Uzaklığı Okuyan Blok',
        titleEn: 'The Block That Reads Distance',
        titleDe: 'Der Block, der den Abstand liest',
        titleEs: 'El bloque que lee la distancia',
        content: '"mesafe algılayıcı 12 trig pin 11 echo pin" bloğu engelin uzaklığını santimetre (cm) olarak verir.\n\n'
            'Bu oval bir bloktur: tek başına durmaz, başka bir bloğun içine takılır. '
            'Örneğin "seri port … yaz" ya da "eğer … ise" bloğunun içine.',
        contentEn: 'The "read ultrasonic sensor trig pin 12 echo pin 11" block gives the obstacle\'s distance in centimetres (cm).\n\n'
            'It is a round block: it does not stand alone but plugs into another block, '
            'such as "serial write …" or "if … then".',
        contentDe: 'Der Block „Ultraschallsensor Trig-Pin 12 Echo-Pin 11 lesen“ liefert den Abstand zum Hindernis in Zentimetern (cm).\n\n'
            'Es ist ein runder Block: Er steht nicht allein, sondern steckt in einem anderen Block, '
            'zum Beispiel in „serieller Port schreibt …“ oder „falls … dann“.',
        contentEs: 'El bloque «lee el sensor de distancia pin trig 12 pin echo 11» da la distancia al obstáculo en centímetros (cm).\n\n'
            'Es un bloque redondo: no va solo, se encaja dentro de otro bloque, '
            'como «puerto serie escribe …» o «si … entonces».',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'mesafe algılayıcı 12 trig pin 11 echo pin',
            contentEn: 'read ultrasonic sensor trig pin 12 echo pin 11',
            contentDe: 'Ultraschallsensor Trig-Pin 12 Echo-Pin 11 lesen',
            contentEs: 'lee el sensor de distancia pin trig 12 pin echo 11',
            color: MBlockPalette.sensor,
            label: 'Sensör · oval blok',
            labelEn: 'Sensor · round block',
            labelDe: 'Sensor · runder Block',
            labelEs: 'Sensor · bloque redondo',
          ),
        ],
      ),
      _parkDevre,
      arduinoKodAdimi(
        id: 'a6_1_kod',
        talimat: 'Uzaklığı seri porta yaz: sürekli tekrarla içinde mesafeyi yaz, 0.3 saniye bekle. '
            'Sonra "Engelin uzaklığı" sürgüsünü kaydır.',
        talimatEn: 'Write the distance to the serial port: inside forever, write the distance, wait 0.3 seconds. '
            'Then move the "Obstacle distance" slider.',
        talimatDe: 'Schreibe den Abstand auf den seriellen Port: In „wiederhole fortlaufend“ den Abstand schreiben, 0.3 Sekunden warten. '
            'Dann schiebe den Regler „Abstand zum Hindernis“.',
        talimatEs: 'Escribe la distancia en el puerto serie: dentro de por siempre, escribe la distancia y espera 0.3 segundos. '
            'Luego mueve el deslizador «Distancia al obstáculo».',
        hedef: 'Mesafeyi yaz, 0.3 bekle; sonsuza kadar',
        hedefEn: 'Write the distance, wait 0.3; forever',
        hedefDe: 'Abstand schreiben, 0.3 warten; immer wieder',
        hedefEs: 'Escribir la distancia, esperar 0.3; para siempre',
        bloklar: const ['dev_kart_acilis', 'dev_surekli', 'dev_seri_yaz', 'dev_mesafe', 'dev_bekle'],
        cozum: [
          kartAcilis,
          surekli([seriYaz(deger: mesafeOku(12, 11)), bekle(0.3)]),
        ],
        devre: _parkDevre.tamami,
      ),
      arduinoKodAdimi(
        id: 'a6_1_kod2',
        talimat: 'Park sensörü: engel 20 cm\'den yakınsa buzzer pin 8\'de 880 frekansla 0.1 saniye çalsın, sonra 0.1 saniye beklesin.',
        talimatEn: 'Parking sensor: if the obstacle is closer than 20 cm, play pin 8 at frequency 880 for 0.1 seconds, then wait 0.1 seconds.',
        talimatDe: 'Einparkhilfe: Ist das Hindernis näher als 20 cm, spielt Pin 8 einen Ton mit Frequenz 880 für 0.1 Sekunden, dann 0.1 Sekunden warten.',
        talimatEs: 'Sensor de aparcamiento: si el obstáculo está a menos de 20 cm, toca en el pin 8 la frecuencia 880 durante 0.1 segundos y espera 0.1 segundos.',
        hedef: 'Eğer mesafe < 20 ise bip; sonsuza kadar',
        hedefEn: 'If distance < 20, beep; forever',
        hedefDe: 'Falls Abstand < 20, piepen; immer wieder',
        hedefEs: 'Si distancia < 20, pitar; para siempre',
        bloklar: const [
          'dev_kart_acilis',
          'dev_surekli',
          'dev_eger',
          'dev_kucuktur',
          'dev_mesafe',
          'dev_ton',
          'dev_bekle',
        ],
        cozum: [
          kartAcilis,
          surekli([
            eger(kucuktur(mesafeOku(12, 11), 20), [tonCal(8, 880, 0.1), bekle(0.1)]),
          ]),
        ],
        devre: _parkDevre.tamami,
        xp: 35,
      ),
      const MultipleChoiceStep(
        id: 'a6_1_q1',
        question: 'Sensörün yankısı çok GEÇ döndü. Bu ne demek?',
        questionEn: 'The sensor\'s echo came back very LATE. What does that mean?',
        questionDe: 'Das Echo des Sensors kam sehr SPÄT zurück. Was bedeutet das?',
        questionEs: 'El eco del sensor volvió muy TARDE. ¿Qué significa?',
        options: [
          ChoiceOption(text: 'Engel çok yakın', textEn: 'The obstacle is very close', textDe: 'Das Hindernis ist sehr nah', textEs: 'El obstáculo está muy cerca'),
          ChoiceOption(text: 'Sensör bozuk', textEn: 'The sensor is broken', textDe: 'Der Sensor ist kaputt', textEs: 'El sensor está roto'),
          ChoiceOption(text: 'Engel uzakta', textEn: 'The obstacle is far away', textDe: 'Das Hindernis ist weit weg', textEs: 'El obstáculo está lejos'),
          ChoiceOption(text: 'Oda çok karanlık', textEn: 'The room is too dark', textDe: 'Der Raum ist zu dunkel', textEs: 'La habitación está muy oscura'),
        ],
        correctIndex: 2,
        explanation: 'Ses uzaktaki engele gidip dönerken daha uzun yol alır, bu yüzden yankı geç gelir. Işık önemli değil: sensör sesle ölçer.',
        explanationEn: 'Sound travels farther to a distant obstacle and back, so the echo arrives late. Light does not matter: the sensor measures with sound.',
        explanationDe: 'Bis zu einem fernen Hindernis und zurück ist der Weg länger, darum kommt das Echo spät. Licht spielt keine Rolle: Der Sensor misst mit Schall.',
        explanationEs: 'El sonido recorre más camino hasta un obstáculo lejano y de vuelta, por eso el eco llega tarde. La luz da igual: el sensor mide con sonido.',
      ),
      const ExplanationStep(
        id: 'a6_1_ozet',
        title: 'Park Sensörün Hazır!',
        titleEn: 'Your Parking Sensor Is Ready!',
        titleDe: 'Deine Einparkhilfe ist fertig!',
        titleEs: '¡Tu sensor de aparcamiento está listo!',
        content: '✓ Ultrasonik sensörün yankıyla ölçtüğünü öğrendin\n'
            '✓ VCC, TRIG, ECHO ve GND bacaklarını bağladın\n'
            '✓ Uzaklığı cm olarak seri porta yazdın\n'
            '✓ Engel yaklaşınca buzzer\'ı öttürdün\n\n'
            'Sıradaki derste bir motoru istediğin açıya döndüreceğiz.',
        contentEn: '✓ You learned that the ultrasonic sensor measures with an echo\n'
            '✓ You wired the VCC, TRIG, ECHO and GND legs\n'
            '✓ You wrote the distance in cm to the serial port\n'
            '✓ You made the buzzer beep when an obstacle got close\n\n'
            'Next lesson: we turn a motor to any angle we like.',
        contentDe: '✓ Der Ultraschallsensor misst mit einem Echo\n'
            '✓ Du hast VCC, TRIG, ECHO und GND angeschlossen\n'
            '✓ Du hast den Abstand in cm auf den seriellen Port geschrieben\n'
            '✓ Der Summer piept, wenn ein Hindernis nah kommt\n\n'
            'Nächste Lektion: Wir drehen einen Motor auf jeden Winkel, den wir wollen.',
        contentEs: '✓ Aprendiste que el sensor ultrasónico mide con un eco\n'
            '✓ Conectaste las patas VCC, TRIG, ECHO y GND\n'
            '✓ Escribiste la distancia en cm en el puerto serie\n'
            '✓ Hiciste pitar el zumbador al acercarse un obstáculo\n\n'
            'Siguiente lección: giramos un motor al ángulo que queramos.',
        tipEmoji: '🏆',
        tip: 'Ultrasonik Ustası rozetini kazandın!',
        tipEn: 'You earned the Ultrasonic Master badge!',
        tipDe: 'Du hast das Abzeichen „Ultraschall-Meister“ verdient!',
        tipEs: '¡Has ganado la insignia Maestro del Ultrasonido!',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 6.2
  InteractiveLesson(
    id: 'arduino_5_2',
    courseId: 'arduino',
    title: 'Servo Motor',
    titleEn: 'Servo Motor',
    titleDe: 'Servomotor',
    titleEs: 'Servomotor',
    subtitle: '0-180 derece, istediğin açıya dön',
    subtitleEn: '0-180 degrees, turn to any angle',
    subtitleDe: '0-180 Grad, auf jeden Winkel drehen',
    subtitleEs: '0-180 grados, gira al ángulo que quieras',
    order: 17,
    xpReward: 70,
    badge: 'servo_master',
    steps: [
      const IntroStep(
        id: 'a6_2_intro',
        mascotEmoji: '⚙️',
        mascotMessage: 'Robot kolları, oyuncak kapıları ve bariyerler hep aynı motorla döner: servo. '
            'Servoya bir açı söylersin, o da tam oraya döner ve orada durur.',
        mascotMessageEn: 'Robot arms, toy doors and barriers all turn with the same motor: the servo. '
            'You tell the servo an angle, and it turns exactly there and stays.',
        mascotMessageDe: 'Roboterarme, Spielzeugtüren und Schranken drehen sich alle mit demselben Motor: dem Servo. '
            'Du sagst ihm einen Winkel, und er dreht genau dorthin und bleibt stehen.',
        mascotMessageEs: 'Brazos robot, puertas de juguete y barreras giran con el mismo motor: el servo. '
            'Le dices un ángulo y gira justo hasta ahí y se queda quieto.',
        highlights: ['0-180 derece', 'Üç kablo', 'Açı değişkeniyle tarama'],
        highlightsEn: ['0-180 degrees', 'Three wires', 'Sweeping with an angle variable'],
        highlightsDe: ['0-180 Grad', 'Drei Kabel', 'Schwenken mit einer Winkel-Variable'],
        highlightsEs: ['0-180 grados', 'Tres cables', 'Barrido con una variable de ángulo'],
      ),
      ExplanationStep(
        id: 'a6_2_servo',
        title: 'Servo: Açıyı Bilen Motor',
        titleEn: 'The Servo: a Motor That Knows Angles',
        titleDe: 'Der Servo: ein Motor, der Winkel kennt',
        titleEs: 'El servo: un motor que conoce los ángulos',
        content: 'Servo 0 ile 180 derece arasında döner. 90 tam ortadır.\n\n'
            '• Kahverengi kablo → GND\n'
            '• Kırmızı kablo → 5V (+ hattı)\n'
            '• Turuncu kablo → sinyal, pin 9\n\n'
            '"servo pin 9 açı 90" bloğu kolu 90 dereceye çevirir.',
        contentEn: 'A servo turns between 0 and 180 degrees. 90 is right in the middle.\n\n'
            '• Brown wire → GND\n'
            '• Red wire → 5V (+ rail)\n'
            '• Orange wire → signal, pin 9\n\n'
            'The "set servo pin 9 angle as 90" block turns the arm to 90 degrees.',
        contentDe: 'Ein Servo dreht sich zwischen 0 und 180 Grad. 90 ist genau die Mitte.\n\n'
            '• Braunes Kabel → GND\n'
            '• Rotes Kabel → 5V (+-Schiene)\n'
            '• Oranges Kabel → Signal, Pin 9\n\n'
            'Der Block „setze Servo an Anschluss 9 auf Winkel 90“ dreht den Arm auf 90 Grad.',
        contentEs: 'Un servo gira entre 0 y 180 grados. 90 es justo el centro.\n\n'
            '• Cable marrón → GND\n'
            '• Cable rojo → 5V (línea +)\n'
            '• Cable naranja → señal, pin 9\n\n'
            'El bloque «mueve el servo en pin 9 al ángulo 90» gira el brazo a 90 grados.',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'servo pin 9 açı 90',
            contentEn: 'set servo pin 9 angle as 90',
            contentDe: 'setze Servo an Anschluss 9 auf Winkel 90',
            contentEs: 'mueve el servo en pin 9 al ángulo 90',
            color: MBlockPalette.pin,
            label: 'Pin',
            labelEn: 'Pin',
            labelDe: 'Pin',
            labelEs: 'Pin',
          ),
        ],
      ),
      _servoDevre,
      arduinoKodAdimi(
        id: 'a6_2_kod',
        talimat: 'Servoyu üç açıya götür: 0 derece, 1 saniye bekle, 90 derece, 1 saniye bekle, 180 derece.',
        talimatEn: 'Move the servo to three angles: 0 degrees, wait 1 second, 90 degrees, wait 1 second, 180 degrees.',
        talimatDe: 'Bringe den Servo auf drei Winkel: 0 Grad, 1 Sekunde warten, 90 Grad, 1 Sekunde warten, 180 Grad.',
        talimatEs: 'Lleva el servo a tres ángulos: 0 grados, espera 1 segundo, 90 grados, espera 1 segundo, 180 grados.',
        hedef: '0 → 90 → 180 derece, arada 1 saniye',
        hedefEn: '0 → 90 → 180 degrees, 1 second apart',
        hedefDe: '0 → 90 → 180 Grad, je 1 Sekunde dazwischen',
        hedefEs: '0 → 90 → 180 grados, con 1 segundo entre medias',
        bloklar: const ['dev_kart_acilis', 'dev_servo', 'dev_bekle'],
        cozum: [
          kartAcilis,
          servoYaz(9, aci: 0),
          bekle(1),
          servoYaz(9, aci: 90),
          bekle(1),
          servoYaz(9, aci: 180),
        ],
        devre: _servoDevre.tamami,
      ),
      const ExplanationStep(
        id: 'a6_2_degisken',
        title: 'Açı Değişkeniyle Tarama',
        titleEn: 'Sweeping With an Angle Variable',
        titleDe: 'Schwenken mit einer Winkel-Variable',
        titleEs: 'Barrido con una variable de ángulo',
        content: 'Servoyu yavaşça döndürmek için her seferinde açıyı biraz büyütürüz.\n\n'
            '• "açı değişkenini 0 yap" → başlangıç\n'
            '• servo bloğunun içine "açı" ovalini tak\n'
            '• "açı i 10 kadar değiştir" → her turda 10 derece daha\n\n'
            '18 tur × 10 derece = 180 derece!',
        contentEn: 'To turn the servo slowly, we make the angle a little bigger each time.\n\n'
            '• "set angle to 0" → the start\n'
            '• put the "angle" oval into the servo block\n'
            '• "change angle by 10" → 10 more degrees each round\n\n'
            '18 rounds × 10 degrees = 180 degrees!',
        contentDe: 'Damit der Servo langsam dreht, machen wir den Winkel jedes Mal etwas größer.\n\n'
            '• „setze winkel auf 0“ → der Start\n'
            '• steck das Oval „winkel“ in den Servo-Block\n'
            '• „ändere winkel um 10“ → jede Runde 10 Grad mehr\n\n'
            '18 Runden × 10 Grad = 180 Grad!',
        contentEs: 'Para girar el servo despacio, hacemos el ángulo un poco más grande cada vez.\n\n'
            '• «dar a ángulo el valor 0» → el inicio\n'
            '• mete el óvalo «ángulo» en el bloque del servo\n'
            '• «sumar a ángulo 10» → 10 grados más en cada vuelta\n\n'
            '¡18 vueltas × 10 grados = 180 grados!',
        tipEmoji: '📦',
        tip: 'Değişken, içine sayı koyduğun bir kutudur. mBlock\'ta bu kutunun adı "açı".',
        tipEn: 'A variable is a box you put a number in. In mBlock this box is called "angle".',
        tipDe: 'Eine Variable ist eine Kiste für eine Zahl. In mBlock heißt diese Kiste „winkel“.',
        tipEs: 'Una variable es una caja donde guardas un número. En mBlock esta caja se llama «ángulo».',
      ),
      arduinoKodAdimi(
        id: 'a6_2_kod2',
        talimat: 'Servoyu yavaşça tara: açıyı 0 yap; 18 defa tekrarla içinde servoyu "açı"ya çevir, açıyı 10 artır, 0.1 saniye bekle.',
        talimatEn: 'Sweep the servo slowly: set angle to 0; repeat 18 times: turn the servo to "angle", change angle by 10, wait 0.1 seconds.',
        talimatDe: 'Schwenke den Servo langsam: setze winkel auf 0; 18-mal: Servo auf „winkel“ drehen, winkel um 10 ändern, 0.1 Sekunden warten.',
        talimatEs: 'Haz un barrido lento: da a ángulo el valor 0; repite 18 veces: gira el servo a «ángulo», suma 10 a ángulo y espera 0.1 segundos.',
        hedef: 'Açı 0\'dan 10\'ar 10\'ar büyüsün, servo takip etsin',
        hedefEn: 'The angle grows from 0 in steps of 10, the servo follows',
        hedefDe: 'Der Winkel wächst ab 0 in 10er-Schritten, der Servo folgt',
        hedefEs: 'El ángulo crece desde 0 de 10 en 10 y el servo lo sigue',
        bloklar: const [
          'dev_kart_acilis',
          'dev_degisken_yap',
          'dev_tekrarla',
          'dev_servo',
          'dev_aci_oku',
          'dev_degisken_degistir',
          'dev_bekle',
        ],
        cozum: [
          kartAcilis,
          degiskenYap('aci', deger: 0),
          tekrarla(18, [
            servoYaz(9, deger: degiskenOku('aci')),
            degiskenDegistir('aci', 10),
            bekle(0.1),
          ]),
        ],
        devre: _servoDevre.tamami,
        xp: 35,
      ),
      const MultipleChoiceStep(
        id: 'a6_2_q1',
        question: 'Servonun turuncu kablosu hangi pine gider?',
        questionEn: 'Which pin does the servo\'s orange wire go to?',
        questionDe: 'An welchen Pin kommt das orange Kabel des Servos?',
        questionEs: '¿A qué pin va el cable naranja del servo?',
        options: [
          ChoiceOption(text: 'GND', textEn: 'GND', textDe: 'GND', textEs: 'GND'),
          ChoiceOption(text: 'Pin 9 (sinyal)', textEn: 'Pin 9 (signal)', textDe: 'Pin 9 (Signal)', textEs: 'Pin 9 (señal)'),
          ChoiceOption(text: '5V', textEn: '5V', textDe: '5V', textEs: '5V'),
          ChoiceOption(text: 'A0', textEn: 'A0', textDe: 'A0', textEs: 'A0'),
        ],
        correctIndex: 1,
        explanation: 'Kahverengi GND\'ye, kırmızı 5V\'a gider. Turuncu kablo açı bilgisini taşır: pin 9.',
        explanationEn: 'Brown goes to GND, red to 5V. The orange wire carries the angle: pin 9.',
        explanationDe: 'Braun kommt an GND, rot an 5V. Das orange Kabel trägt den Winkel: Pin 9.',
        explanationEs: 'El marrón va a GND y el rojo a 5V. El cable naranja lleva el ángulo: pin 9.',
      ),
      const MultipleChoiceStep(
        id: 'a6_2_q2',
        question: 'Açı 0\'dan başlıyor ve her turda 10 artıyor. 9 tur sonra servo nerede olur?',
        questionEn: 'The angle starts at 0 and grows by 10 each round. Where is the servo after 9 rounds?',
        questionDe: 'Der Winkel startet bei 0 und wächst jede Runde um 10. Wo steht der Servo nach 9 Runden?',
        questionEs: 'El ángulo empieza en 0 y sube 10 en cada vuelta. ¿Dónde está el servo tras 9 vueltas?',
        options: [
          ChoiceOption(text: '9 derece', textEn: '9 degrees', textDe: '9 Grad', textEs: '9 grados'),
          ChoiceOption(text: '180 derece', textEn: '180 degrees', textDe: '180 Grad', textEs: '180 grados'),
          ChoiceOption(text: '19 derece', textEn: '19 degrees', textDe: '19 Grad', textEs: '19 grados'),
          ChoiceOption(text: '90 derece, tam ortada', textEn: '90 degrees, right in the middle', textDe: '90 Grad, genau in der Mitte', textEs: '90 grados, justo en el centro'),
        ],
        correctIndex: 3,
        explanation: '9 tur × 10 derece = 90 derece. Servo yolun yarısındadır.',
        explanationEn: '9 rounds × 10 degrees = 90 degrees. The servo is halfway.',
        explanationDe: '9 Runden × 10 Grad = 90 Grad. Der Servo ist auf halbem Weg.',
        explanationEs: '9 vueltas × 10 grados = 90 grados. El servo está a medio camino.',
      ),
      const ExplanationStep(
        id: 'a6_2_ozet',
        title: 'Servo Ustası!',
        titleEn: 'Servo Master!',
        titleDe: 'Servo-Meister!',
        titleEs: '¡Maestro del servo!',
        content: '✓ Servonun 0-180 derece döndüğünü öğrendin\n'
            '✓ Üç kabloyu doğru yere bağladın\n'
            '✓ Servoyu istediğin açıya çevirdin\n'
            '✓ Açı değişkeniyle yavaş bir tarama yaptın\n\n'
            'Sıradaki ders FİNAL: sensör ve servoyu birleştiriyoruz!',
        contentEn: '✓ You learned that a servo turns from 0 to 180 degrees\n'
            '✓ You connected its three wires correctly\n'
            '✓ You turned the servo to the angle you wanted\n'
            '✓ You made a slow sweep with an angle variable\n\n'
            'Next lesson is the FINAL: we combine the sensor and the servo!',
        contentDe: '✓ Ein Servo dreht sich von 0 bis 180 Grad\n'
            '✓ Du hast die drei Kabel richtig angeschlossen\n'
            '✓ Du hast den Servo auf deinen Wunschwinkel gedreht\n'
            '✓ Du hast mit einer Winkel-Variable langsam geschwenkt\n\n'
            'Die nächste Lektion ist das FINALE: Sensor und Servo kommen zusammen!',
        contentEs: '✓ Aprendiste que un servo gira de 0 a 180 grados\n'
            '✓ Conectaste bien sus tres cables\n'
            '✓ Giraste el servo al ángulo que querías\n'
            '✓ Hiciste un barrido lento con una variable de ángulo\n\n'
            'La siguiente lección es la FINAL: ¡unimos el sensor y el servo!',
        tipEmoji: '🏆',
        tip: 'Servo Ustası rozetini kazandın!',
        tipEn: 'You earned the Servo Master badge!',
        tipDe: 'Du hast das Abzeichen „Servo-Meister“ verdient!',
        tipEs: '¡Has ganado la insignia Maestro del Servo!',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 6.3
  InteractiveLesson(
    id: 'arduino_r6_3',
    courseId: 'arduino',
    title: 'Final: Akıllı Bariyer',
    titleEn: 'Final: Smart Barrier',
    titleDe: 'Finale: Intelligente Schranke',
    titleEs: 'Final: Barrera inteligente',
    subtitle: 'Mesafe sensörü + servo + LED ile otopark bariyeri',
    subtitleEn: 'A car park barrier with distance sensor, servo and LED',
    subtitleDe: 'Eine Parkhausschranke mit Abstandssensor, Servo und LED',
    subtitleEs: 'Una barrera de parking con sensor de distancia, servo y LED',
    order: 18,
    xpReward: 100,
    badge: 'robotics_engineer',
    steps: [
      const IntroStep(
        id: 'a6_3_intro',
        mascotEmoji: '🚗',
        mascotMessage: 'Final zamanı! Bir otopark bariyeri yapıyoruz: araba yaklaşınca yeşil ışık yanar, '
            'bariyer kalkar, araba geçince iner. Öğrendiğin her şeyi birlikte kullanacaksın.',
        mascotMessageEn: 'Final time! We build a car park barrier: when a car comes close, a green light '
            'turns on, the barrier lifts, and it goes down after the car passes. You will use everything you learned.',
        mascotMessageDe: 'Zeit fürs Finale! Wir bauen eine Parkhausschranke: Kommt ein Auto näher, geht ein '
            'grünes Licht an, die Schranke hebt sich und senkt sich wieder. Du nutzt alles, was du gelernt hast.',
        mascotMessageEs: '¡Hora de la final! Construimos una barrera de parking: cuando se acerca un coche, '
            'se enciende una luz verde, la barrera sube y luego baja. Usarás todo lo que has aprendido.',
        highlights: ['Sensör + servo + LED', 'Eğer … ise', 'Kursun finali'],
        highlightsEn: ['Sensor + servo + LED', 'If … then', 'The course final'],
        highlightsDe: ['Sensor + Servo + LED', 'Falls … dann', 'Das Kursfinale'],
        highlightsEs: ['Sensor + servo + LED', 'Si … entonces', 'La final del curso'],
      ),
      const ExplanationStep(
        id: 'a6_3_plan',
        title: 'Bariyerin Planı',
        titleEn: 'The Barrier\'s Plan',
        titleDe: 'Der Plan für die Schranke',
        titleEs: 'El plan de la barrera',
        content: 'Önce bariyeri 0 dereceye indir. Sonra sürekli:\n\n'
            '• Eğer araba 15 cm\'den yakınsa:\n'
            '  – yeşil LED yanar (pin 13)\n'
            '  – bariyer 90 dereceye kalkar (pin 9)\n'
            '  – 2 saniye bekler\n'
            '  – bariyer 0\'a iner, LED söner',
        contentEn: 'First lower the barrier to 0 degrees. Then, forever:\n\n'
            '• If a car is closer than 15 cm:\n'
            '  – the green LED turns on (pin 13)\n'
            '  – the barrier lifts to 90 degrees (pin 9)\n'
            '  – wait 2 seconds\n'
            '  – the barrier goes back to 0, the LED turns off',
        contentDe: 'Senke die Schranke zuerst auf 0 Grad. Dann immer wieder:\n\n'
            '• Falls ein Auto näher als 15 cm ist:\n'
            '  – die grüne LED geht an (Pin 13)\n'
            '  – die Schranke hebt sich auf 90 Grad (Pin 9)\n'
            '  – 2 Sekunden warten\n'
            '  – die Schranke geht zurück auf 0, die LED aus',
        contentEs: 'Primero baja la barrera a 0 grados. Luego, por siempre:\n\n'
            '• Si un coche está a menos de 15 cm:\n'
            '  – se enciende el LED verde (pin 13)\n'
            '  – la barrera sube a 90 grados (pin 9)\n'
            '  – espera 2 segundos\n'
            '  – la barrera vuelve a 0 y el LED se apaga',
        tipEmoji: '🧠',
        tip: 'Büyük bir projeyi küçük adımlara bölmek, mühendislerin en önemli hilesidir.',
        tipEn: 'Splitting a big project into small steps is an engineer\'s most important trick.',
        tipDe: 'Ein großes Projekt in kleine Schritte zu teilen ist der wichtigste Trick von Ingenieuren.',
        tipEs: 'Dividir un gran proyecto en pasos pequeños es el truco más importante de los ingenieros.',
      ),
      _bariyerDevre,
      arduinoKodAdimi(
        id: 'a6_3_kod',
        talimat: 'Akıllı bariyeri programla: önce servo 0 derece. Sürekli: mesafe < 15 ise LED\'i yak, servo 90, '
            '2 saniye bekle, servo 0, LED\'i söndür. Sonra "Engelin uzaklığı" sürgüsüyle bir araba yaklaştır.',
        talimatEn: 'Program the smart barrier: first servo to 0 degrees. Forever: if distance < 15, LED on, servo 90, '
            'wait 2 seconds, servo 0, LED off. Then bring a car closer with the "Obstacle distance" slider.',
        talimatDe: 'Programmiere die Schranke: zuerst Servo auf 0 Grad. Immer wieder: falls Abstand < 15, LED an, Servo 90, '
            '2 Sekunden warten, Servo 0, LED aus. Dann fahre mit dem Regler „Abstand zum Hindernis“ ein Auto heran.',
        talimatEs: 'Programa la barrera: primero el servo a 0 grados. Por siempre: si distancia < 15, LED encendido, servo 90, '
            'espera 2 segundos, servo 0, LED apagado. Luego acerca un coche con el deslizador «Distancia al obstáculo».',
        hedef: 'Araba yaklaşınca LED yanar, bariyer kalkar ve 2 saniye sonra iner',
        hedefEn: 'When a car comes close the LED lights, the barrier lifts and lowers after 2 seconds',
        hedefDe: 'Kommt ein Auto nah, leuchtet die LED, die Schranke hebt sich und senkt sich nach 2 Sekunden',
        hedefEs: 'Cuando se acerca un coche, el LED se enciende, la barrera sube y baja a los 2 segundos',
        bloklar: const [
          'dev_kart_acilis',
          'dev_servo',
          'dev_surekli',
          'dev_eger',
          'dev_kucuktur',
          'dev_mesafe',
          'dev_dijital_yaz',
          'dev_bekle',
        ],
        cozum: [
          kartAcilis,
          servoYaz(9, aci: 0),
          surekli([
            eger(kucuktur(mesafeOku(12, 11), 15), [
              dijitalYaz(13, true),
              servoYaz(9, aci: 90),
              bekle(2),
              servoYaz(9, aci: 0),
              dijitalYaz(13, false),
            ]),
          ]),
        ],
        devre: _bariyerDevre.tamami,
        xp: 50,
      ),
      const MultipleChoiceStep(
        id: 'a6_3_q1',
        question: '"2 saniye bekle" bloğunu silseydin ne olurdu?',
        questionEn: 'What would happen if you deleted the "wait 2 seconds" block?',
        questionDe: 'Was würde passieren, wenn du den Block „warte 2 Sekunden“ löschst?',
        questionEs: '¿Qué pasaría si borraras el bloque «espera 2 segundos»?',
        options: [
          ChoiceOption(text: 'Bariyer hiç kalkmazdı', textEn: 'The barrier would never lift', textDe: 'Die Schranke würde sich nie heben', textEs: 'La barrera nunca subiría'),
          ChoiceOption(text: 'Bariyer hep açık kalırdı', textEn: 'The barrier would stay open', textDe: 'Die Schranke bliebe immer offen', textEs: 'La barrera se quedaría abierta'),
          ChoiceOption(text: 'Bariyer kalkıp hemen inerdi; araba geçemezdi', textEn: 'It would lift and drop at once; the car could not pass', textDe: 'Sie würde hoch- und sofort runtergehen; das Auto käme nicht durch', textEs: 'Subiría y bajaría al instante; el coche no podría pasar'),
          ChoiceOption(text: 'LED kırmızı yanardı', textEn: 'The LED would turn red', textDe: 'Die LED würde rot leuchten', textEs: 'El LED se pondría rojo'),
        ],
        correctIndex: 2,
        explanation: 'Bekleme olmadan servo 90\'a gider gitmez 0\'a döner. Arabaya geçmesi için zaman vermek gerekir.',
        explanationEn: 'Without the wait, the servo goes back to 0 right after reaching 90. The car needs time to pass.',
        explanationDe: 'Ohne Warten geht der Servo gleich nach 90 wieder auf 0. Das Auto braucht Zeit zum Durchfahren.',
        explanationEs: 'Sin la espera, el servo vuelve a 0 nada más llegar a 90. El coche necesita tiempo para pasar.',
      ),
      const ExplanationStep(
        id: 'a6_3_ozet',
        title: 'Kursu Bitirdin!',
        titleEn: 'You Finished the Course!',
        titleDe: 'Du hast den Kurs geschafft!',
        titleEs: '¡Has terminado el curso!',
        content: '✓ LED yaktın, buton okudun\n'
            '✓ Potansiyometre, ışık ve sıcaklık sensörüyle çalıştın\n'
            '✓ Buzzer çaldın, mesafe ölçtün, servo döndürdün\n'
            '✓ Hepsini birleştirip akıllı bir bariyer yaptın\n\n'
            '"Arduino Atölyesi"nde serbest devre kurabilir ve rehberli projelerle devam edebilirsin.',
        contentEn: '✓ You lit LEDs and read buttons\n'
            '✓ You worked with a potentiometer, a light sensor and a temperature sensor\n'
            '✓ You played a buzzer, measured distance and turned a servo\n'
            '✓ You combined it all into a smart barrier\n\n'
            'In the "Arduino Workshop" you can build free circuits and keep going with guided projects.',
        contentDe: '✓ Du hast LEDs leuchten lassen und Taster gelesen\n'
            '✓ Du hast mit Potentiometer, Licht- und Temperatursensor gearbeitet\n'
            '✓ Du hast den Summer gespielt, Abstände gemessen und einen Servo gedreht\n'
            '✓ Alles zusammen ergibt deine intelligente Schranke\n\n'
            'In der „Arduino-Werkstatt“ kannst du frei Schaltungen bauen und mit geführten Projekten weitermachen.',
        contentEs: '✓ Encendiste LED y leíste botones\n'
            '✓ Trabajaste con un potenciómetro y sensores de luz y temperatura\n'
            '✓ Tocaste un zumbador, mediste distancias y giraste un servo\n'
            '✓ Lo uniste todo en una barrera inteligente\n\n'
            'En el «Taller de Arduino» puedes montar circuitos libres y seguir con proyectos guiados.',
        tipEmoji: '🏆',
        tip: 'Robotik Mühendisi rozetini kazandın!',
        tipEn: 'You earned the Robotics Engineer badge!',
        tipDe: 'Du hast das Abzeichen „Robotik-Ingenieur“ verdient!',
        tipEs: '¡Has ganado la insignia Ingeniero de Robótica!',
      ),
    ],
  ),
];
