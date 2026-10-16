// ARDUINO KURSU — MODUL 4: PWM VE POTANSIYOMETRE
//
// PWM pinleriyle LED'i yarim parlak yakmak, potansiyometreyi analog
// okumak, harita bloguyla okunan degeri LED parlakligina cevirmek.
import '../../devre/arduino_projeleri.dart';
import '../../devre/devre_modeli.dart';
import '../../models/interactive_lesson_model.dart';
import '../mblock_palette.dart';
import 'ders_yardimcisi.dart';

final _nefesDevre = DevreKurmaStep(
  id: 'a4_1_devre',
  talimat: 'Mavi LED\'i bu kez pin 9\'a bağla: pin 9 → direnç → LED → GND.',
  talimatEn: 'This time connect the blue LED to pin 9: pin 9 → resistor → LED → GND.',
  talimatDe: 'Schließ die blaue LED diesmal an Pin 9 an: Pin 9 → Widerstand → LED → GND.',
  talimatEs: 'Esta vez conecta el LED azul al pin 9: pin 9 → resistencia → LED → GND.',
  parcalar: DevreKalibi.led('L1', 14, renk: LedRengi.mavi),
  hazirKablolar: const [DevreKalibi.gndKablosu],
  hedefler: DevreKalibi.ledHedefleri(9, 14),
  xpReward: 25,
);

final _potDevre = DevreKurmaStep(
  id: 'a4_2_devre',
  talimat: 'Potansiyometreyi bağla: uçlar + ve − hatlarına, orta bacak A0\'a.',
  talimatEn: 'Wire up the potentiometer: the outer legs to the + and − rails, the middle leg to A0.',
  talimatDe: 'Schließ das Potentiometer an: die äußeren Beine an + und −, das mittlere Bein an A0.',
  talimatEs: 'Conecta el potenciómetro: las patas de los extremos a las líneas + y −, la del centro a A0.',
  parcalar: DevreKalibi.pot(),
  hazirKablolar: const [DevreKalibi.gndKablosu, DevreKalibi.vKablosu],
  hedefler: DevreKalibi.potHedefleri,
  xpReward: 25,
);

final _dugmeDevre = DevreKurmaStep(
  id: 'a4_3_devre',
  talimat: 'Potansiyometre hazır. Yanına mavi LED\'i pin 9 ile bağla.',
  talimatEn: 'The potentiometer is ready. Next to it, connect the blue LED to pin 9.',
  talimatDe: 'Das Potentiometer ist fertig. Schließ daneben die blaue LED an Pin 9 an.',
  talimatEs: 'El potenciómetro ya está listo. A su lado, conecta el LED azul al pin 9.',
  parcalar: [...DevreKalibi.pot(), ...DevreKalibi.led('L1', 14, renk: LedRengi.mavi)],
  hazirKablolar: const [DevreKalibi.gndKablosu, DevreKalibi.vKablosu, ...DevreKalibi.potKablolari],
  hedefler: DevreKalibi.ledHedefleri(9, 14),
  xpReward: 25,
);

final List<InteractiveLesson> arduinoModul4 = [
  // ---------------------------------------------------------------- 4.1
  InteractiveLesson(
    id: 'arduino_r4_1',
    courseId: 'arduino',
    title: 'Nefes Alan LED',
    titleEn: 'The Breathing LED',
    titleDe: 'Die atmende LED',
    titleEs: 'El LED que respira',
    subtitle: 'PWM ile yarım parlaklık',
    subtitleEn: 'Half brightness with PWM',
    subtitleDe: 'Halbe Helligkeit mit PWM',
    subtitleEs: 'Medio brillo con PWM',
    order: 10,
    xpReward: 60,
    badge: 'pwm_master',
    steps: [
      const IntroStep(
        id: 'a4_1_intro',
        mascotEmoji: '🌗',
        mascotMessage: 'Şimdiye kadar LED ya yandı ya söndü. Bu derste onu yarım parlaklıkta '
            'yakacağız, sonra da yavaşça nefes alır gibi parlatacağız.',
        mascotMessageEn: 'So far the LED was either on or off. In this lesson we light it at half '
            'brightness, then make it glow up slowly, as if it were breathing.',
        mascotMessageDe: 'Bisher war die LED entweder an oder aus. Jetzt lassen wir sie halb hell '
            'leuchten und dann langsam aufglühen, als würde sie atmen.',
        mascotMessageEs: 'Hasta ahora el LED estaba encendido o apagado. En esta lección lo '
            'encendemos a medias y luego lo hacemos brillar poco a poco, como si respirara.',
        highlights: ['PWM pinleri (~)', 'Güç: 0-255', 'Yavaşça parlayan LED'],
        highlightsEn: ['PWM pins (~)', 'Power: 0-255', 'An LED that glows up slowly'],
        highlightsDe: ['PWM-Pins (~)', 'Stärke: 0-255', 'Eine LED, die langsam aufglüht'],
        highlightsEs: ['Pines PWM (~)', 'Potencia: 0-255', 'Un LED que brilla poco a poco'],
      ),
      const ExplanationStep(
        id: 'a4_1_pwm',
        title: 'PWM: Çok Hızlı Aç-Kapa',
        titleEn: 'PWM: Super-Fast On and Off',
        titleDe: 'PWM: Superschnell an und aus',
        titleEs: 'PWM: encender y apagar muy rápido',
        content: '• Pin 3, 5, 6, 9, 10 ve 11 PWM yapabilir. Kartta yanlarında ~ işareti var.\n'
            '• Güç 0 ile 255 arasıdır: 0 kapalı, 255 tam parlak.\n'
            '• 128 verince pin saniyede yüzlerce kez açılıp kapanır. Gözümüz bunu '
            'yakalayamaz, LED\'i yarı parlak görürüz.',
        contentEn: '• Pins 3, 5, 6, 9, 10 and 11 can do PWM. On the board they have a ~ next to them.\n'
            '• Power goes from 0 to 255: 0 is off, 255 is full brightness.\n'
            '• With 128 the pin switches on and off hundreds of times a second. Our eyes '
            'can\'t keep up, so the LED looks half bright.',
        contentDe: '• Pins 3, 5, 6, 9, 10 und 11 können PWM. Auf der Platine steht ein ~ daneben.\n'
            '• Die Stärke geht von 0 bis 255: 0 ist aus, 255 ist ganz hell.\n'
            '• Bei 128 schaltet der Pin hunderte Male pro Sekunde an und aus. Unsere Augen '
            'kommen nicht mit, die LED wirkt halb hell.',
        contentEs: '• Los pines 3, 5, 6, 9, 10 y 11 pueden hacer PWM. En la placa llevan un ~ al lado.\n'
            '• La potencia va de 0 a 255: 0 es apagado, 255 es brillo máximo.\n'
            '• Con 128 el pin se enciende y se apaga cientos de veces por segundo. Nuestros '
            'ojos no lo notan y vemos el LED a medio brillo.',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'PWM ayarla pin9 çıkış 128',
            contentEn: 'set PWM 9 output as 128',
            contentDe: 'PWM-Ausgang 9 als 128 festlegen',
            contentEs: 'pon la salida PWM 9 a 128',
            color: MBlockPalette.pin,
            label: 'Pin',
            labelEn: 'Pin',
            labelDe: 'Pin',
            labelEs: 'Pin',
          ),
        ],
        tipEmoji: '〰️',
        tip: 'Pin 13\'te ~ yok: orada LED ya yanar ya söner.',
        tipEn: 'Pin 13 has no ~: there the LED is only on or off.',
        tipDe: 'Pin 13 hat kein ~: Dort ist die LED nur an oder aus.',
        tipEs: 'El pin 13 no tiene ~: ahí el LED solo se enciende o se apaga.',
      ),
      _nefesDevre,
      arduinoKodAdimi(
        id: 'a4_1_kod',
        talimat: 'LED\'i sönük yak: pin 9\'a 40 gücünü ver.',
        talimatEn: 'Light the LED dimly: give pin 9 a power of 40.',
        talimatDe: 'Lass die LED schwach leuchten: Gib Pin 9 die Stärke 40.',
        talimatEs: 'Enciende el LED flojito: dale al pin 9 una potencia de 40.',
        hedef: 'Başlangıç bloğu ve PWM pin 9, 40',
        hedefEn: 'The start block and PWM pin 9 at 40',
        hedefDe: 'Startblock und PWM an Pin 9 mit 40',
        hedefEs: 'El bloque de inicio y PWM en el pin 9 a 40',
        bloklar: const ['dev_kart_acilis', 'dev_pwm_yaz'],
        cozum: [kartAcilis, pwmYaz(9, guc: 40)],
        devre: _nefesDevre.tamami,
        xp: 25,
      ),
      arduinoKodAdimi(
        id: 'a4_1_kod2',
        talimat: 'Parlaklık değişkenini 0 yap. 51 defa tekrarla: pin 9\'a parlaklığı ver, '
            'parlaklığı 5 artır, 0.02 saniye bekle.',
        talimatEn: 'Set brightness to 0. Repeat 51 times: give pin 9 the brightness, '
            'change brightness by 5, wait 0.02 seconds.',
        talimatDe: 'Setze helligkeit auf 0. Wiederhole 51 mal: Gib Pin 9 die helligkeit, '
            'ändere helligkeit um 5, warte 0.02 Sekunden.',
        talimatEs: 'Da a brillo el valor 0. Repite 51 veces: dale al pin 9 el brillo, '
            'suma 5 a brillo y espera 0.02 segundos.',
        hedef: 'LED 0\'dan 255\'e yavaşça parlasın',
        hedefEn: 'The LED glows up slowly from 0 to 255',
        hedefDe: 'Die LED wird langsam von 0 bis 255 heller',
        hedefEs: 'El LED sube poco a poco de 0 a 255',
        bloklar: const [
          'dev_kart_acilis',
          'dev_degisken_yap',
          'dev_tekrarla',
          'dev_pwm_yaz',
          'dev_degisken_oku',
          'dev_degisken_degistir',
          'dev_bekle',
        ],
        cozum: [
          kartAcilis,
          degiskenYap('parlaklik', deger: 0),
          tekrarla(51, [
            pwmYaz(9, deger: degiskenOku('parlaklik')),
            degiskenDegistir('parlaklik', 5),
            bekle(0.02),
          ]),
        ],
        devre: _nefesDevre.tamami,
        xp: 35,
      ),
      const MultipleChoiceStep(
        id: 'a4_1_q1',
        question: 'LED\'i yarı parlak yakmak istiyorsun. Hangi pine bağlamalısın?',
        questionEn: 'You want the LED at half brightness. Which pin should you use?',
        questionDe: 'Die LED soll halb hell leuchten. An welchen Pin schließt du sie an?',
        questionEs: 'Quieres el LED a medio brillo. ¿A qué pin lo conectas?',
        options: [
          ChoiceOption(text: 'Pin 13', textEn: 'Pin 13', textDe: 'Pin 13', textEs: 'Pin 13'),
          ChoiceOption(text: 'Pin 6 (~)', textEn: 'Pin 6 (~)', textDe: 'Pin 6 (~)', textEs: 'Pin 6 (~)'),
          ChoiceOption(text: 'Pin 2', textEn: 'Pin 2', textDe: 'Pin 2', textEs: 'Pin 2'),
          ChoiceOption(text: 'GND', textEn: 'GND', textDe: 'GND', textEs: 'GND'),
        ],
        correctIndex: 1,
        explanation: 'Yalnızca ~ işaretli pinler PWM yapar. Pin 2 ve 13 sadece açık/kapalı bilir.',
        explanationEn: 'Only the pins marked ~ can do PWM. Pins 2 and 13 only know on and off.',
        explanationDe: 'Nur die Pins mit ~ können PWM. Pin 2 und 13 kennen nur an und aus.',
        explanationEs: 'Solo los pines con ~ hacen PWM. Los pines 2 y 13 solo saben encendido y apagado.',
      ),
      const ExplanationStep(
        id: 'a4_1_ozet',
        title: 'LED Nefes Aldı!',
        titleEn: 'The LED Breathed!',
        titleDe: 'Die LED hat geatmet!',
        titleEs: '¡El LED respiró!',
        content: '✓ ~ işaretli PWM pinlerini buldun\n'
            '✓ LED\'i 0-255 arası bir güçle yaktın\n'
            '✓ Değişkenle LED\'i yavaşça parlattın\n\n'
            'Sıradaki derste elle çevrilen bir düğmeyi okuyacağız.',
        contentEn: '✓ You found the PWM pins marked ~\n'
            '✓ You lit the LED with a power from 0 to 255\n'
            '✓ You made the LED glow up slowly with a variable\n\n'
            'Next lesson: we read a knob that you turn by hand.',
        contentDe: '✓ Du hast die PWM-Pins mit ~ gefunden\n'
            '✓ Du hast die LED mit einer Stärke von 0 bis 255 leuchten lassen\n'
            '✓ Mit einer Variablen wurde die LED langsam heller\n\n'
            'Nächste Lektion: Wir lesen einen Drehknopf, den du von Hand drehst.',
        contentEs: '✓ Encontraste los pines PWM marcados con ~\n'
            '✓ Encendiste el LED con una potencia de 0 a 255\n'
            '✓ Hiciste brillar el LED poco a poco con una variable\n\n'
            'Siguiente lección: leemos un mando que giras con la mano.',
        tipEmoji: '🏆',
        tip: 'PWM Ustası rozetini kazandın!',
        tipEn: 'You earned the PWM Master badge!',
        tipDe: 'Du hast das Abzeichen „PWM-Meister“ verdient!',
        tipEs: '¡Has ganado la insignia Maestro del PWM!',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 4.2
  InteractiveLesson(
    id: 'arduino_3_2',
    courseId: 'arduino',
    title: 'Potansiyometreyi Oku',
    titleEn: 'Read the Potentiometer',
    titleDe: 'Lies das Potentiometer',
    titleEs: 'Lee el potenciómetro',
    subtitle: 'Analog oku: 0-1023, seri porta yaz',
    subtitleEn: 'Read analog: 0-1023, write to the serial port',
    subtitleDe: 'Analog lesen: 0-1023, an den seriellen Port schreiben',
    subtitleEs: 'Lectura analógica: 0-1023, escribe en el puerto serie',
    order: 11,
    xpReward: 60,
    badge: 'analog_reader',
    steps: [
      const IntroStep(
        id: 'a4_2_intro',
        mascotEmoji: '🎚️',
        mascotMessage: 'Potansiyometre, çevirdikçe değeri değişen bir düğmedir. '
            'Uno onu okuyunca 0 ile 1023 arası bir sayı bulur. O sayıyı ekranda görelim!',
        mascotMessageEn: 'A potentiometer is a knob whose value changes as you turn it. '
            'When the Uno reads it, it gets a number from 0 to 1023. Let\'s see that number on screen!',
        mascotMessageDe: 'Ein Potentiometer ist ein Drehknopf, dessen Wert sich beim Drehen ändert. '
            'Der Uno liest dabei eine Zahl von 0 bis 1023. Schauen wir sie uns an!',
        mascotMessageEs: 'Un potenciómetro es un mando cuyo valor cambia al girarlo. '
            'Al leerlo, el Uno obtiene un número de 0 a 1023. ¡Veamos ese número en pantalla!',
        highlights: ['3 bacaklı düğme', 'Analog oku: 0-1023', 'Seri port'],
        highlightsEn: ['A knob with 3 legs', 'Read analog: 0-1023', 'The serial port'],
        highlightsDe: ['Ein Drehknopf mit 3 Beinen', 'Analog lesen: 0-1023', 'Der serielle Port'],
        highlightsEs: ['Un mando de 3 patas', 'Lectura analógica: 0-1023', 'El puerto serie'],
      ),
      const ExplanationStep(
        id: 'a4_2_pot',
        title: 'Üç Bacaklı Düğme',
        titleEn: 'A Knob With Three Legs',
        titleDe: 'Ein Drehknopf mit drei Beinen',
        titleEs: 'Un mando de tres patas',
        content: '• Uçtaki bacaklardan biri 5V\'a, öbürü GND\'ye gider.\n'
            '• Orta bacak A0\'a gider. Düğmeyi çevirdikçe orta bacağın gerilimi 0V ile 5V arasında değişir.\n'
            '• "analog oku pin (A) 0" bu gerilimi 0-1023 arası bir sayıya çevirir.\n'
            '• "seri port … yaz" sayıyı bilgisayar ekranına gönderir.',
        contentEn: '• One outer leg goes to 5V, the other to GND.\n'
            '• The middle leg goes to A0. As you turn the knob, its voltage moves between 0V and 5V.\n'
            '• "read analog pin (A) 0" turns that voltage into a number from 0 to 1023.\n'
            '• "serial write …" sends the number to the computer screen.',
        contentDe: '• Ein äußeres Bein kommt an 5V, das andere an GND.\n'
            '• Das mittlere Bein kommt an A0. Beim Drehen wandert seine Spannung zwischen 0V und 5V.\n'
            '• „analogen Pin (A) 0 lesen“ macht daraus eine Zahl von 0 bis 1023.\n'
            '• „serieller Port schreibt …“ schickt die Zahl auf den Computerbildschirm.',
        contentEs: '• Una pata de un extremo va a 5V y la otra a GND.\n'
            '• La pata central va a A0. Al girar el mando, su tensión cambia entre 0V y 5V.\n'
            '• «lee pin analógico 0» convierte esa tensión en un número de 0 a 1023.\n'
            '• «puerto serie escribe …» envía el número a la pantalla del ordenador.',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'analog oku pin (A) 0',
            contentEn: 'read analog pin (A) 0',
            contentDe: 'analogen Pin (A) 0 lesen',
            contentEs: 'lee pin analógico 0',
            color: MBlockPalette.pin,
            label: 'Pin · değer bloğu',
            labelEn: 'Pin · value block',
            labelDe: 'Pin · Werteblock',
            labelEs: 'Pin · bloque de valor',
          ),
        ],
      ),
      _potDevre,
      arduinoKodAdimi(
        id: 'a4_2_kod',
        talimat: 'Sürekli tekrarla içinde A0\'ı oku, seri porta yaz ve 0.2 saniye bekle. '
            'Sonra sahnenin altındaki "Potansiyometre" sürgüsünü çevir: seri porttaki sayı değişecek.',
        talimatEn: 'Inside forever, read A0, write it to the serial port and wait 0.2 seconds. '
            'Then move the "Potentiometer" slider under the stage: the number on the serial port changes.',
        talimatDe: 'In „wiederhole fortlaufend“ A0 lesen, an den seriellen Port schreiben und 0.2 Sekunden warten. '
            'Dann schieb den Regler „Potentiometer“ unter der Bühne: Die Zahl am seriellen Port ändert sich.',
        talimatEs: 'Dentro de por siempre, lee A0, escríbelo en el puerto serie y espera 0.2 segundos. '
            'Luego mueve el deslizador «Potenciómetro» bajo el escenario: el número del puerto serie cambia.',
        hedef: 'A0\'ı oku, seri porta yaz, 0.2 bekle; sonsuza kadar',
        hedefEn: 'Read A0, write to serial, wait 0.2; forever',
        hedefDe: 'A0 lesen, seriell schreiben, 0.2 warten; immer wieder',
        hedefEs: 'Leer A0, escribir en serie, esperar 0.2; para siempre',
        bloklar: const [
          'dev_kart_acilis',
          'dev_surekli',
          'dev_seri_yaz',
          'dev_analog_oku',
          'dev_bekle',
        ],
        cozum: [
          kartAcilis,
          surekli([seriYaz(deger: analogOku(0)), bekle(0.2)]),
        ],
        devre: _potDevre.tamami,
        xp: 35,
      ),
      const MultipleChoiceStep(
        id: 'a4_2_q1',
        question: 'Potansiyometrenin hangi bacağı A0\'a bağlanır?',
        questionEn: 'Which leg of the potentiometer goes to A0?',
        questionDe: 'Welches Bein des Potentiometers kommt an A0?',
        questionEs: '¿Qué pata del potenciómetro va a A0?',
        options: [
          ChoiceOption(text: 'Sol bacak', textEn: 'The left leg', textDe: 'Das linke Bein', textEs: 'La pata izquierda'),
          ChoiceOption(text: 'Sağ bacak', textEn: 'The right leg', textDe: 'Das rechte Bein', textEs: 'La pata derecha'),
          ChoiceOption(text: 'Orta bacak', textEn: 'The middle leg', textDe: 'Das mittlere Bein', textEs: 'La pata central'),
          ChoiceOption(text: 'Hiçbiri, A0 boş kalır', textEn: 'None, A0 stays empty', textDe: 'Keins, A0 bleibt frei', textEs: 'Ninguna, A0 queda libre'),
        ],
        correctIndex: 2,
        explanation: 'Uçlar 5V ve GND\'ye gider. Çevirdikçe değişen gerilim orta bacaktadır, A0 onu okur.',
        explanationEn: 'The outer legs go to 5V and GND. The voltage that changes as you turn is on the middle leg, and A0 reads it.',
        explanationDe: 'Die äußeren Beine kommen an 5V und GND. Die Spannung, die sich beim Drehen ändert, liegt am mittleren Bein. A0 liest sie.',
        explanationEs: 'Los extremos van a 5V y GND. La tensión que cambia al girar está en la pata central, y A0 la lee.',
      ),
      const MultipleChoiceStep(
        id: 'a4_2_q2',
        question: 'Düğmeyi sonuna kadar 5V tarafına çevirdin. Seri portta hangi sayıyı görürsün?',
        questionEn: 'You turned the knob all the way to the 5V side. Which number do you see on the serial port?',
        questionDe: 'Du drehst den Knopf ganz zur 5V-Seite. Welche Zahl siehst du am seriellen Port?',
        questionEs: 'Giraste el mando del todo hacia el lado de 5V. ¿Qué número ves en el puerto serie?',
        options: [
          ChoiceOption(text: '1023', textEn: '1023', textDe: '1023', textEs: '1023'),
          ChoiceOption(text: '255', textEn: '255', textDe: '255', textEs: '255'),
          ChoiceOption(text: '5', textEn: '5', textDe: '5', textEs: '5'),
          ChoiceOption(text: '0', textEn: '0', textDe: '0', textEs: '0'),
        ],
        correctIndex: 0,
        explanation: 'Analog okuma 0V\'ta 0, 5V\'ta 1023 verir. 255, PWM\'in en büyük gücüdür.',
        explanationEn: 'An analog reading gives 0 at 0V and 1023 at 5V. 255 is the highest PWM power.',
        explanationDe: 'Analog lesen ergibt 0 bei 0V und 1023 bei 5V. 255 ist die höchste PWM-Stärke.',
        explanationEs: 'La lectura analógica da 0 con 0V y 1023 con 5V. 255 es la potencia PWM máxima.',
      ),
      const ExplanationStep(
        id: 'a4_2_ozet',
        title: 'Düğmeyi Okudun!',
        titleEn: 'You Read the Knob!',
        titleDe: 'Du hast den Knopf gelesen!',
        titleEs: '¡Leíste el mando!',
        content: '✓ Potansiyometrenin üç bacağını doğru bağladın\n'
            '✓ A0\'dan 0-1023 arası bir sayı okudun\n'
            '✓ Sayıyı seri porta yazıp çevirdikçe değiştiğini gördün\n\n'
            'Sıradaki derste bu düğmeyle LED\'in parlaklığını ayarlayacağız.',
        contentEn: '✓ You wired the potentiometer\'s three legs correctly\n'
            '✓ You read a number from 0 to 1023 on A0\n'
            '✓ You wrote it to the serial port and watched it change as you turned\n\n'
            'Next lesson: we set the LED\'s brightness with this knob.',
        contentDe: '✓ Du hast die drei Beine des Potentiometers richtig angeschlossen\n'
            '✓ Du hast an A0 eine Zahl von 0 bis 1023 gelesen\n'
            '✓ Am seriellen Port hast du gesehen, wie sie sich beim Drehen ändert\n\n'
            'Nächste Lektion: Wir stellen mit diesem Knopf die Helligkeit der LED ein.',
        contentEs: '✓ Conectaste bien las tres patas del potenciómetro\n'
            '✓ Leíste en A0 un número de 0 a 1023\n'
            '✓ Lo escribiste en el puerto serie y viste cómo cambiaba al girar\n\n'
            'Siguiente lección: ajustamos el brillo del LED con este mando.',
        tipEmoji: '🏆',
        tip: 'Analog Okuyucu rozetini kazandın!',
        tipEn: 'You earned the Analog Reader badge!',
        tipDe: 'Du hast das Abzeichen „Analog-Leser“ verdient!',
        tipEs: '¡Has ganado la insignia Lector Analógico!',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 4.3
  InteractiveLesson(
    id: 'arduino_r4_3',
    courseId: 'arduino',
    title: 'Düğmeyle Parlaklık',
    titleEn: 'Brightness by Knob',
    titleDe: 'Helligkeit per Drehknopf',
    titleEs: 'Brillo con un mando',
    subtitle: 'Harita: 0-1023\'ten 0-255\'e',
    subtitleEn: 'Map: from 0-1023 to 0-255',
    subtitleDe: 'Ordnen: von 0-1023 zu 0-255',
    subtitleEs: 'Mapear: de 0-1023 a 0-255',
    order: 12,
    xpReward: 70,
    steps: [
      const IntroStep(
        id: 'a4_3_intro',
        mascotEmoji: '🎛️',
        mascotMessage: 'Potansiyometreyi okumayı ve LED\'i yarım yakmayı biliyorsun. '
            'Şimdi ikisini birleştirelim: düğmeyi çevirdikçe LED parlasın ya da sönükleşsin.',
        mascotMessageEn: 'You can read the potentiometer and light an LED at half power. '
            'Now let\'s combine them: turn the knob and the LED gets brighter or dimmer.',
        mascotMessageDe: 'Du kannst das Potentiometer lesen und eine LED halb hell leuchten lassen. '
            'Jetzt verbinden wir beides: Dreh am Knopf, und die LED wird heller oder dunkler.',
        mascotMessageEs: 'Ya sabes leer el potenciómetro y encender un LED a medias. '
            'Ahora juntamos las dos cosas: giras el mando y el LED brilla más o menos.',
        highlights: ['Harita bloğu', '0-1023 → 0-255', 'Dimmer lamba'],
        highlightsEn: ['The map block', '0-1023 → 0-255', 'A dimmer lamp'],
        highlightsDe: ['Der Ordnen-Block', '0-1023 → 0-255', 'Eine Dimmerlampe'],
        highlightsEs: ['El bloque mapea', '0-1023 → 0-255', 'Una lámpara regulable'],
      ),
      const ExplanationStep(
        id: 'a4_3_harita',
        title: 'İki Ölçek, Bir Köprü',
        titleEn: 'Two Scales, One Bridge',
        titleDe: 'Zwei Skalen, eine Brücke',
        titleEs: 'Dos escalas, un puente',
        content: '• Potansiyometre 0-1023 arası okunur.\n'
            '• PWM ise 0-255 arası güç ister.\n'
            '• Harita bloğu sayıyı bir ölçekten ötekine taşır: 0 → 0, 1023 → 255, '
            'ortadaki değerler de orantılı olarak ortaya düşer.',
        contentEn: '• The potentiometer reads from 0 to 1023.\n'
            '• PWM wants a power from 0 to 255.\n'
            '• The map block moves a number from one scale to the other: 0 → 0, 1023 → 255, '
            'and the values in between land in the middle in proportion.',
        contentDe: '• Das Potentiometer liefert 0 bis 1023.\n'
            '• PWM braucht eine Stärke von 0 bis 255.\n'
            '• Der Ordnen-Block bringt eine Zahl von einer Skala auf die andere: 0 → 0, 1023 → 255, '
            'und die Werte dazwischen landen anteilig in der Mitte.',
        contentEs: '• El potenciómetro lee de 0 a 1023.\n'
            '• El PWM pide una potencia de 0 a 255.\n'
            '• El bloque mapea lleva un número de una escala a la otra: 0 → 0, 1023 → 255, '
            'y los valores intermedios caen en medio, en proporción.',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'harita … den [0 , 1023] e [0 , 255]',
            contentEn: 'map … from [0 , 1023] to [0 , 255]',
            contentDe: 'ordne … von [0 , 1023] zu [0 , 255]',
            contentEs: 'mapea … de [0 , 1023] a [0 , 255]',
            color: MBlockPalette.data,
            label: 'Veri · değer bloğu',
            labelEn: 'Data · value block',
            labelDe: 'Daten · Werteblock',
            labelEs: 'Datos · bloque de valor',
          ),
        ],
      ),
      _dugmeDevre,
      arduinoKodAdimi(
        id: 'a4_3_kod',
        talimat: 'Sürekli tekrarla içinde pin 9\'a PWM ver. Gücün yerine harita bloğunu koy, '
            'içine de A0\'ı oku: 0-1023\'ten 0-255\'e. Sonra "Potansiyometre" sürgüsünü çevir.',
        talimatEn: 'Inside forever, set PWM on pin 9. Put the map block in the power slot '
            'and read A0 inside it: from 0-1023 to 0-255. Then move the "Potentiometer" slider.',
        talimatDe: 'In „wiederhole fortlaufend“ PWM an Pin 9 setzen. In das Stärke-Feld kommt der Ordnen-Block, '
            'darin A0 lesen: von 0-1023 zu 0-255. Dann den Regler „Potentiometer“ schieben.',
        talimatEs: 'Dentro de por siempre, pon PWM en el pin 9. En el hueco de potencia mete el bloque mapea '
            'y dentro lee A0: de 0-1023 a 0-255. Luego mueve el deslizador «Potenciómetro».',
        hedef: 'Pin 9 = harita(A0, 0-1023 → 0-255); sonsuza kadar',
        hedefEn: 'Pin 9 = map(A0, 0-1023 → 0-255); forever',
        hedefDe: 'Pin 9 = ordne(A0, 0-1023 → 0-255); immer wieder',
        hedefEs: 'Pin 9 = mapea(A0, 0-1023 → 0-255); para siempre',
        bloklar: const [
          'dev_kart_acilis',
          'dev_surekli',
          'dev_pwm_yaz',
          'dev_harita',
          'dev_analog_oku',
        ],
        cozum: [
          kartAcilis,
          surekli([pwmYaz(9, deger: harita(analogOku(0), 0, 1023, 0, 255))]),
        ],
        devre: _dugmeDevre.tamami,
        xp: 40,
      ),
      const MultipleChoiceStep(
        id: 'a4_3_q1',
        question: 'A0 512 okudu. Harita bloğu (0-1023\'ten 0-255\'e) yaklaşık kaç verir?',
        questionEn: 'A0 read 512. About what does the map block (0-1023 to 0-255) give?',
        questionDe: 'A0 hat 512 gelesen. Was liefert der Ordnen-Block (0-1023 zu 0-255) ungefähr?',
        questionEs: 'A0 leyó 512. ¿Qué da más o menos el bloque mapea (de 0-1023 a 0-255)?',
        options: [
          ChoiceOption(text: '512', textEn: '512', textDe: '512', textEs: '512'),
          ChoiceOption(text: '255', textEn: '255', textDe: '255', textEs: '255'),
          ChoiceOption(text: '0', textEn: '0', textDe: '0', textEs: '0'),
          ChoiceOption(text: '127', textEn: '127', textDe: '127', textEs: '127'),
        ],
        correctIndex: 3,
        explanation: '512, 1023\'ün yaklaşık yarısıdır. 255\'in yarısı da yaklaşık 127: LED yarı parlak yanar.',
        explanationEn: '512 is about half of 1023. Half of 255 is about 127, so the LED shines at half brightness.',
        explanationDe: '512 ist etwa die Hälfte von 1023. Die Hälfte von 255 ist etwa 127: Die LED leuchtet halb hell.',
        explanationEs: '512 es más o menos la mitad de 1023. La mitad de 255 es unos 127: el LED brilla a medias.',
      ),
      const ExplanationStep(
        id: 'a4_3_ozet',
        title: 'Kendi Dimmer Lamban!',
        titleEn: 'Your Own Dimmer Lamp!',
        titleDe: 'Deine eigene Dimmerlampe!',
        titleEs: '¡Tu propia lámpara regulable!',
        content: '✓ Potansiyometre ile LED\'i aynı devrede kullandın\n'
            '✓ Harita bloğuyla 0-1023\'ü 0-255\'e çevirdin\n'
            '✓ Düğmeyi çevirerek LED\'in parlaklığını ayarladın\n\n'
            'Sıradaki modülde yeni sensörlerle tanışacağız.',
        contentEn: '✓ You used a potentiometer and an LED in one circuit\n'
            '✓ You turned 0-1023 into 0-255 with the map block\n'
            '✓ You set the LED\'s brightness by turning the knob\n\n'
            'Next module: we meet new sensors.',
        contentDe: '✓ Potentiometer und LED in einer Schaltung\n'
            '✓ Mit dem Ordnen-Block wurde aus 0-1023 ein 0-255\n'
            '✓ Du hast die Helligkeit der LED mit dem Knopf eingestellt\n\n'
            'Nächstes Modul: Wir lernen neue Sensoren kennen.',
        contentEs: '✓ Usaste un potenciómetro y un LED en el mismo circuito\n'
            '✓ Pasaste de 0-1023 a 0-255 con el bloque mapea\n'
            '✓ Ajustaste el brillo del LED girando el mando\n\n'
            'Siguiente módulo: conocemos sensores nuevos.',
        tipEmoji: '💡',
        tip: 'Evdeki ayarlı lambalar da aynı fikirle çalışır: düğme okunur, ışık ona göre ayarlanır.',
        tipEn: 'Dimmable lamps at home work the same way: the knob is read and the light follows it.',
        tipDe: 'Dimmbare Lampen zu Hause funktionieren genauso: Der Knopf wird gelesen, das Licht folgt ihm.',
        tipEs: 'Las lámparas regulables de casa funcionan igual: se lee el mando y la luz lo sigue.',
      ),
    ],
  ),
];
