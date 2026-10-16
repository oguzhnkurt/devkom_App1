// ARDUINO KURSU — MODUL 5: SES, ISIK VE SICAKLIK
//
// Buzzer ile frekans ve gam, LDR + 10k gerilim bolucuyle gece lambasi,
// sicaklik sensoruyle termometre.
import '../../devre/arduino_projeleri.dart';
import '../../devre/devre_modeli.dart';
import '../../models/interactive_lesson_model.dart';
import '../../yurutme/mblock_cozum.dart';
import '../mblock_palette.dart';
import 'ders_yardimcisi.dart';

/// Buzzer: + bacak pin 8'e, − bacak GND'ye.
final _buzzerDevre = DevreKurmaStep(
  id: 'a5_1_devre',
  talimat: 'Buzzer\'ı bağla: + bacağı pin 8\'e, − bacağı − hattına.',
  talimatEn: 'Wire up the buzzer: its + leg to pin 8, its − leg to the − rail.',
  talimatDe: 'Schließ den Summer an: das +-Bein an Pin 8, das −-Bein an die −-Schiene.',
  talimatEs: 'Conecta el zumbador: la pata + al pin 8 y la pata − a la línea −.',
  parcalar: DevreKalibi.buzzer(20),
  hazirKablolar: [DevreKalibi.gndKablosu],
  hedefler: DevreKalibi.buzzerHedefleri(20),
  xpReward: 25,
);

/// LDR + 10k gerilim bolucu A0'a; sari LED pin 13'te hazir.
final _ldrDevre = DevreKurmaStep(
  id: 'a5_2_devre',
  talimat: 'Işık sensörünü ve 10k direnci bağla; ortadaki sırayı A0\'a götür. LED zaten pin 13\'te.',
  talimatEn: 'Wire the light sensor and the 10k resistor; take the middle strip to A0. The LED is already on pin 13.',
  talimatDe: 'Schließ Lichtsensor und 10k-Widerstand an; führe den mittleren Streifen zu A0. Die LED hängt schon an Pin 13.',
  talimatEs: 'Conecta el sensor de luz y la resistencia de 10k; lleva la tira del medio a A0. El LED ya está en el pin 13.',
  parcalar: [...DevreKalibi.ldr(), ...DevreKalibi.led('L1', 16, renk: LedRengi.sari)],
  hazirKablolar: [DevreKalibi.gndKablosu, DevreKalibi.vKablosu, ...DevreKalibi.ledKablolari(13, 16)],
  hedefler: DevreKalibi.ldrHedefleri,
  xpReward: 25,
);

/// Sicaklik sensoru A1'e, kirmizi LED pin 12'ye.
final _sicaklikDevre = DevreKurmaStep(
  id: 'a5_3_devre',
  talimat: 'Sıcaklık sensörünü (VCC, çıkış, GND) ve pin 12\'deki LED\'i bağla.',
  talimatEn: 'Wire the temperature sensor (VCC, output, GND) and the LED on pin 12.',
  talimatDe: 'Schließ den Temperatursensor (VCC, Ausgang, GND) und die LED an Pin 12 an.',
  talimatEs: 'Conecta el sensor de temperatura (VCC, salida, GND) y el LED del pin 12.',
  parcalar: [...DevreKalibi.sicaklik(), ...DevreKalibi.led('L1', 16)],
  hazirKablolar: [DevreKalibi.gndKablosu, DevreKalibi.vKablosu],
  hedefler: [...DevreKalibi.sicaklikHedefleri, ...DevreKalibi.ledHedefleri(12, 16)],
  xpReward: 25,
);

final List<InteractiveLesson> arduinoModul5 = [
  // ---------------------------------------------------------------- 5.1
  InteractiveLesson(
    id: 'arduino_4_1',
    courseId: 'arduino',
    title: 'Buzzer ile Melodi',
    titleEn: 'A Tune With a Buzzer',
    titleDe: 'Eine Melodie mit dem Summer',
    titleEs: 'Una melodía con el zumbador',
    subtitle: 'Frekans, ton bloğu ve gam',
    subtitleEn: 'Frequency, the tone block and a scale',
    subtitleDe: 'Frequenz, der Tonblock und eine Tonleiter',
    subtitleEs: 'Frecuencia, el bloque de tono y una escala',
    order: 13,
    xpReward: 60,
    badge: 'sound_maker',
    steps: [
      const IntroStep(
        id: 'a5_1_intro',
        mascotEmoji: '🔊',
        mascotMessage: 'Şimdiye kadar kartımız hep sessizdi. Bugün ona bir buzzer takıp '
            'ses çıkaracağız: önce tek bir nota, sonra küçük bir gam.',
        mascotMessageEn: 'So far our board has been silent. Today we add a buzzer and make '
            'sounds: first a single note, then a little scale.',
        mascotMessageDe: 'Bisher war unsere Platine stumm. Heute stecken wir einen Summer an '
            'und machen Töne: erst eine einzelne Note, dann eine kleine Tonleiter.',
        mascotMessageEs: 'Hasta ahora nuestra placa estaba en silencio. Hoy le ponemos un '
            'zumbador y hacemos sonidos: primero una nota, luego una pequeña escala.',
        highlights: ['Buzzer', 'Frekans (Hz)', 'Gam çal'],
        highlightsEn: ['Buzzer', 'Frequency (Hz)', 'Play a scale'],
        highlightsDe: ['Summer', 'Frequenz (Hz)', 'Tonleiter spielen'],
        highlightsEs: ['Zumbador', 'Frecuencia (Hz)', 'Toca una escala'],
      ),
      const ExplanationStep(
        id: 'a5_1_ses',
        title: 'Buzzer ve Frekans',
        titleEn: 'Buzzer and Frequency',
        titleDe: 'Summer und Frequenz',
        titleEs: 'Zumbador y frecuencia',
        content: '• Buzzer\'ın + bacağı pine, − bacağı GND\'ye gider.\n'
            '• Ses, saniyede kaç kez titrediğiyle belirlenir: buna frekans denir, birimi Hz.\n'
            '• Sayı büyüdükçe ses incelir; küçüldükçe kalınlaşır.\n'
            '• 262 Hz, "do" notasıdır.',
        contentEn: '• The buzzer\'s + leg goes to a pin, the − leg to GND.\n'
            '• A sound depends on how many times per second it vibrates: that is the frequency, in Hz.\n'
            '• The bigger the number, the higher the sound; smaller means deeper.\n'
            '• 262 Hz is the note C ("do").',
        contentDe: '• Das +-Bein des Summers kommt an einen Pin, das −-Bein an GND.\n'
            '• Ein Ton hängt davon ab, wie oft er pro Sekunde schwingt: das ist die Frequenz, in Hz.\n'
            '• Je größer die Zahl, desto höher der Ton; kleiner heißt tiefer.\n'
            '• 262 Hz ist der Ton C.',
        contentEs: '• La pata + del zumbador va a un pin y la − a GND.\n'
            '• Un sonido depende de cuántas veces vibra por segundo: es la frecuencia, en Hz.\n'
            '• Cuanto mayor es el número, más agudo es el sonido; menor, más grave.\n'
            '• 262 Hz es la nota «do».',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'pin 8 ton çal frekans 262 süre 1 saniye',
            contentEn: 'play tone on pin 8 frequency 262 for 1 secs',
            contentDe: 'spiele Ton an Pin 8 Frequenz 262 für 1 Sek.',
            contentEs: 'tocar tono en pin 8 frecuencia 262 durante 1 s',
            color: MBlockPalette.pin,
            label: 'Pin',
            labelEn: 'Pin',
            labelDe: 'Pin',
            labelEs: 'Pin',
          ),
        ],
        tipEmoji: '🎧',
        tip: 'Sanal buzzer gerçekten ses çıkarıyor; telefonunun sesini aç.',
        tipEn: 'The virtual buzzer really makes sound, so turn your phone\'s volume up.',
        tipDe: 'Der virtuelle Summer macht wirklich Töne, also dreh den Ton am Handy auf.',
        tipEs: 'El zumbador virtual suena de verdad, así que sube el volumen del móvil.',
      ),
      _buzzerDevre,
      arduinoKodAdimi(
        id: 'a5_1_kod',
        talimat: 'Pin 8\'deki buzzer 1 saniye boyunca 262 Hz\'lik "do" notasını çalsın.',
        talimatEn: 'Make the buzzer on pin 8 play the note C (262 Hz) for 1 second.',
        talimatDe: 'Lass den Summer an Pin 8 eine Sekunde lang den Ton C (262 Hz) spielen.',
        talimatEs: 'Haz que el zumbador del pin 8 toque la nota do (262 Hz) durante 1 segundo.',
        hedef: 'Pin 8, frekans 262, süre 1 saniye',
        hedefEn: 'Pin 8, frequency 262, 1 second',
        hedefDe: 'Pin 8, Frequenz 262, 1 Sekunde',
        hedefEs: 'Pin 8, frecuencia 262, 1 segundo',
        bloklar: const ['dev_kart_acilis', 'dev_ton'],
        cozum: [kartAcilis, tonCal(8, 262, 1)],
        devre: _buzzerDevre.tamami,
        xp: 25,
      ),
      arduinoKodAdimi(
        id: 'a5_1_kod2',
        talimat: 'Gamı çal: 262, 294, 330, 349 Hz\'yi 0.4 saniye, son olarak 392 Hz\'yi 0.8 saniye.',
        talimatEn: 'Play the scale: 262, 294, 330 and 349 Hz for 0.4 seconds each, then 392 Hz for 0.8 seconds.',
        talimatDe: 'Spiel die Tonleiter: 262, 294, 330 und 349 Hz je 0.4 Sekunden, zum Schluss 392 Hz für 0.8 Sekunden.',
        talimatEs: 'Toca la escala: 262, 294, 330 y 349 Hz durante 0.4 segundos cada una y al final 392 Hz durante 0.8 segundos.',
        hedef: 'Do, re, mi, fa, sol',
        hedefEn: 'C, D, E, F, G',
        hedefDe: 'C, D, E, F, G',
        hedefEs: 'Do, re, mi, fa, sol',
        bloklar: const ['dev_kart_acilis', 'dev_ton', 'dev_bekle'],
        cozum: [
          kartAcilis,
          tonCal(8, 262, 0.4),
          tonCal(8, 294, 0.4),
          tonCal(8, 330, 0.4),
          tonCal(8, 349, 0.4),
          tonCal(8, 392, 0.8),
        ],
        devre: _buzzerDevre.tamami,
        xp: 35,
      ),
      const MultipleChoiceStep(
        id: 'a5_1_q1',
        question: 'Hangi frekans EN İNCE sesi çıkarır?',
        questionEn: 'Which frequency makes the HIGHEST sound?',
        questionDe: 'Welche Frequenz ergibt den HÖCHSTEN Ton?',
        questionEs: '¿Qué frecuencia da el sonido MÁS AGUDO?',
        options: [
          ChoiceOption(text: '262 Hz', textEn: '262 Hz', textDe: '262 Hz', textEs: '262 Hz'),
          ChoiceOption(text: '330 Hz', textEn: '330 Hz', textDe: '330 Hz', textEs: '330 Hz'),
          ChoiceOption(text: '523 Hz', textEn: '523 Hz', textDe: '523 Hz', textEs: '523 Hz'),
          ChoiceOption(text: '131 Hz', textEn: '131 Hz', textDe: '131 Hz', textEs: '131 Hz'),
        ],
        correctIndex: 2,
        explanation: 'Sayı büyüdükçe ses incelir. 523 Hz, 262 Hz\'deki "do"nun bir üst oktavıdır.',
        explanationEn: 'The bigger the number, the higher the sound. 523 Hz is the C one octave above 262 Hz.',
        explanationDe: 'Je größer die Zahl, desto höher der Ton. 523 Hz ist das C eine Oktave über 262 Hz.',
        explanationEs: 'Cuanto mayor es el número, más agudo. 523 Hz es el do una octava por encima de 262 Hz.',
      ),
      const ExplanationStep(
        id: 'a5_1_ozet',
        title: 'Kartın Sesi Var!',
        titleEn: 'Your Board Has a Voice!',
        titleDe: 'Deine Platine hat eine Stimme!',
        titleEs: '¡Tu placa tiene voz!',
        content: '✓ Buzzer\'ı pin 8 ve GND\'ye bağladın\n'
            '✓ Frekans büyüdükçe sesin inceldiğini öğrendin\n'
            '✓ Ton bloklarını sıralayıp bir gam çaldın\n\n'
            'Sıradaki derste kart ışığı ölçecek.',
        contentEn: '✓ You wired the buzzer to pin 8 and GND\n'
            '✓ You learned that a bigger frequency means a higher sound\n'
            '✓ You lined up tone blocks and played a scale\n\n'
            'Next lesson: the board measures light.',
        contentDe: '✓ Du hast den Summer an Pin 8 und GND angeschlossen\n'
            '✓ Höhere Frequenz heißt höherer Ton\n'
            '✓ Du hast Tonblöcke aneinandergereiht und eine Tonleiter gespielt\n\n'
            'Nächste Lektion: Die Platine misst Licht.',
        contentEs: '✓ Conectaste el zumbador al pin 8 y a GND\n'
            '✓ Aprendiste que más frecuencia es un sonido más agudo\n'
            '✓ Pusiste bloques de tono en fila y tocaste una escala\n\n'
            'Siguiente lección: la placa mide la luz.',
        tipEmoji: '🏆',
        tip: 'Ses Yapımcısı rozetini kazandın!',
        tipEn: 'You earned the Sound Maker badge!',
        tipDe: 'Du hast das Abzeichen „Tonmacher“ verdient!',
        tipEs: '¡Has ganado la insignia Creador de Sonidos!',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 5.2
  InteractiveLesson(
    id: 'arduino_4_2',
    courseId: 'arduino',
    title: 'Gece Lambası',
    titleEn: 'Night Light',
    titleDe: 'Nachtlicht',
    titleEs: 'Luz nocturna',
    subtitle: 'Işık sensörü, gerilim bölücü ve A0',
    subtitleEn: 'Light sensor, voltage divider and A0',
    subtitleDe: 'Lichtsensor, Spannungsteiler und A0',
    subtitleEs: 'Sensor de luz, divisor de tensión y A0',
    order: 14,
    xpReward: 60,
    steps: [
      const IntroStep(
        id: 'a5_2_intro',
        mascotEmoji: '🌙',
        mascotMessage: 'Oda kararınca kendiliğinden yanan bir lamba yapalım. '
            'Bunun için kartın ışığı "görmesi" gerekiyor: ışık sensörü takacağız.',
        mascotMessageEn: 'Let\'s make a lamp that switches on by itself when the room gets dark. '
            'For that the board has to "see" light: we add a light sensor.',
        mascotMessageDe: 'Bauen wir eine Lampe, die von selbst angeht, wenn es dunkel wird. '
            'Dafür muss die Platine Licht „sehen“: Wir stecken einen Lichtsensor an.',
        mascotMessageEs: 'Hagamos una lámpara que se encienda sola cuando oscurece. '
            'Para eso la placa tiene que «ver» la luz: pondremos un sensor de luz.',
        highlights: ['Işık sensörü (LDR)', 'Gerilim bölücü', 'Karanlıkta yan'],
        highlightsEn: ['Light sensor (LDR)', 'Voltage divider', 'Light up in the dark'],
        highlightsDe: ['Lichtsensor (LDR)', 'Spannungsteiler', 'Im Dunkeln leuchten'],
        highlightsEs: ['Sensor de luz (LDR)', 'Divisor de tensión', 'Encender en la oscuridad'],
      ),
      const ExplanationStep(
        id: 'a5_2_ldr',
        title: 'Işığı Ölçen Direnç',
        titleEn: 'A Resistor That Measures Light',
        titleDe: 'Ein Widerstand, der Licht misst',
        titleEs: 'Una resistencia que mide la luz',
        content: '• LDR bir ışık sensörüdür: ışık azaldıkça direnci artar.\n'
            '• Onu 10k dirençle art arda bağlarız. Buna gerilim bölücü denir.\n'
            '• İkisinin buluştuğu nokta A0\'a gider.\n'
            '• Aydınlıkta A0 büyük, karanlıkta küçük bir sayı okur.',
        contentEn: '• An LDR is a light sensor: the less light, the higher its resistance.\n'
            '• We connect it in a row with a 10k resistor. This is called a voltage divider.\n'
            '• The point where the two meet goes to A0.\n'
            '• In bright light A0 reads a big number, in the dark a small one.',
        contentDe: '• Ein LDR ist ein Lichtsensor: Je weniger Licht, desto größer sein Widerstand.\n'
            '• Wir schalten ihn mit einem 10k-Widerstand hintereinander. Das heißt Spannungsteiler.\n'
            '• Der Punkt, wo beide sich treffen, geht an A0.\n'
            '• Bei Helligkeit liest A0 eine große Zahl, im Dunkeln eine kleine.',
        contentEs: '• Un LDR es un sensor de luz: cuanta menos luz, más resistencia.\n'
            '• Lo conectamos en fila con una resistencia de 10k. Esto se llama divisor de tensión.\n'
            '• El punto donde se unen va a A0.\n'
            '• Con luz A0 lee un número grande; a oscuras, uno pequeño.',
        tipEmoji: '🔦',
        tip: 'Gerçek kartta sensörün üstünü elinle kapatarak deneyebilirsin.',
        tipEn: 'On a real board you can test it by covering the sensor with your hand.',
        tipDe: 'Auf einer echten Platine kannst du es testen, indem du den Sensor mit der Hand abdeckst.',
        tipEs: 'En una placa real puedes probarlo tapando el sensor con la mano.',
      ),
      _ldrDevre,
      arduinoKodAdimi(
        id: 'a5_2_kod',
        talimat: 'A0\'daki ışık değerini sürekli seri porta yaz, her seferinde 0.3 saniye bekle. '
            'Sonra sahnedeki "Ortam ışığı" sürgüsünü kaydır.',
        talimatEn: 'Keep writing the light value from A0 to the serial port, waiting 0.3 seconds each time. '
            'Then move the "Room light" slider on the stage.',
        talimatDe: 'Schreib den Lichtwert von A0 immer wieder auf den seriellen Port und warte jedes Mal 0.3 Sekunden. '
            'Dann schieb den Regler „Raumlicht“ auf der Bühne.',
        talimatEs: 'Escribe sin parar el valor de luz de A0 en el puerto serie y espera 0.3 segundos cada vez. '
            'Luego mueve el control «Luz ambiente» del escenario.',
        hedef: 'Sürekli: A0\'ı seri porta yaz, 0.3 bekle',
        hedefEn: 'Forever: write A0 to serial, wait 0.3',
        hedefDe: 'Fortlaufend: A0 seriell schreiben, 0.3 warten',
        hedefEs: 'Por siempre: escribe A0 en el puerto serie, espera 0.3',
        bloklar: const ['dev_kart_acilis', 'dev_surekli', 'dev_seri_yaz', 'dev_analog_oku', 'dev_bekle'],
        cozum: [
          kartAcilis,
          surekli([seriYaz(deger: analogOku(0)), bekle(0.3)]),
        ],
        devre: _ldrDevre.tamami,
        xp: 30,
      ),
      arduinoKodAdimi(
        id: 'a5_2_kod2',
        talimat: 'Gece lambası: A0 400\'den küçükse pin 13\'ü yak, 399\'dan büyükse söndür.',
        talimatEn: 'Night light: if A0 is less than 400 turn pin 13 on, if it is greater than 399 turn it off.',
        talimatDe: 'Nachtlicht: Ist A0 kleiner als 400, Pin 13 an; ist er größer als 399, aus.',
        talimatEs: 'Luz nocturna: si A0 es menor que 400 enciende el pin 13; si es mayor que 399, apágalo.',
        hedef: 'Karanlıkta yan, aydınlıkta sön',
        hedefEn: 'On in the dark, off in the light',
        hedefDe: 'Im Dunkeln an, im Hellen aus',
        hedefEs: 'Encendido a oscuras, apagado con luz',
        bloklar: const [
          'dev_kart_acilis',
          'dev_surekli',
          'dev_eger',
          'dev_kucuktur',
          'dev_buyuktur',
          'dev_analog_oku',
          'dev_dijital_yaz',
        ],
        cozum: [
          kartAcilis,
          MBlockBeklenen('dev_surekli', kardesKosullarSerbest: true, icerik: [
            eger(kucuktur(analogOku(0), 400), [dijitalYaz(13, true)]),
            eger(buyuktur(analogOku(0), 399), [dijitalYaz(13, false)]),
          ]),
        ],
        devre: _ldrDevre.tamami,
        xp: 40,
      ),
      const MultipleChoiceStep(
        id: 'a5_2_q1',
        question: 'Odanın ışığını kapattın. A0\'dan okunan sayıya ne olur?',
        questionEn: 'You switch off the room light. What happens to the number read from A0?',
        questionDe: 'Du machst das Licht im Zimmer aus. Was passiert mit der Zahl an A0?',
        questionEs: 'Apagas la luz de la habitación. ¿Qué pasa con el número que lee A0?',
        options: [
          ChoiceOption(text: 'Büyür', textEn: 'It gets bigger', textDe: 'Sie wird größer', textEs: 'Se hace más grande'),
          ChoiceOption(text: 'Küçülür', textEn: 'It gets smaller', textDe: 'Sie wird kleiner', textEs: 'Se hace más pequeño'),
          ChoiceOption(text: 'Hiç değişmez', textEn: 'It does not change', textDe: 'Sie ändert sich nicht', textEs: 'No cambia'),
          ChoiceOption(text: 'Hep 1023 olur', textEn: 'It is always 1023', textDe: 'Sie ist immer 1023', textEs: 'Siempre es 1023'),
        ],
        correctIndex: 1,
        explanation: 'Karanlıkta LDR\'nin direnci artar, A0\'daki gerilim düşer ve sayı küçülür.',
        explanationEn: 'In the dark the LDR\'s resistance rises, the voltage at A0 drops and the number gets smaller.',
        explanationDe: 'Im Dunkeln steigt der Widerstand des LDR, die Spannung an A0 sinkt und die Zahl wird kleiner.',
        explanationEs: 'A oscuras la resistencia del LDR sube, la tensión en A0 baja y el número se hace más pequeño.',
      ),
      const ExplanationStep(
        id: 'a5_2_ozet',
        title: 'Lamba Kendini Yakıyor!',
        titleEn: 'The Lamp Turns Itself On!',
        titleDe: 'Die Lampe schaltet sich selbst ein!',
        titleEs: '¡La lámpara se enciende sola!',
        content: '✓ LDR ve 10k dirençle gerilim bölücü kurdun\n'
            '✓ Işık değerini seri portta izledin\n'
            '✓ Karanlıkta yanan bir gece lambası yaptın\n\n'
            'Sıradaki derste kart sıcaklığı ölçecek.',
        contentEn: '✓ You built a voltage divider with an LDR and a 10k resistor\n'
            '✓ You watched the light value on the serial port\n'
            '✓ You made a night light that turns on in the dark\n\n'
            'Next lesson: the board measures temperature.',
        contentDe: '✓ Du hast mit LDR und 10k-Widerstand einen Spannungsteiler gebaut\n'
            '✓ Du hast den Lichtwert am seriellen Port beobachtet\n'
            '✓ Du hast ein Nachtlicht gebaut, das im Dunkeln angeht\n\n'
            'Nächste Lektion: Die Platine misst die Temperatur.',
        contentEs: '✓ Montaste un divisor de tensión con un LDR y una resistencia de 10k\n'
            '✓ Observaste el valor de luz en el puerto serie\n'
            '✓ Hiciste una luz nocturna que se enciende a oscuras\n\n'
            'Siguiente lección: la placa mide la temperatura.',
        tipEmoji: '💡',
        tip: '400 sınırını değiştirerek lambanın ne zaman yanacağını sen seçebilirsin.',
        tipEn: 'Change the 400 limit to choose when the lamp switches on.',
        tipDe: 'Ändere die Grenze 400, um selbst zu bestimmen, wann die Lampe angeht.',
        tipEs: 'Cambia el límite de 400 para elegir cuándo se enciende la lámpara.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- 5.3
  InteractiveLesson(
    id: 'arduino_r5_3',
    courseId: 'arduino',
    title: 'Termometre',
    titleEn: 'Thermometer',
    titleDe: 'Thermometer',
    titleEs: 'Termómetro',
    subtitle: 'Sıcaklık sensörü, °C ve uyarı ışığı',
    subtitleEn: 'Temperature sensor, °C and a warning light',
    subtitleDe: 'Temperatursensor, °C und ein Warnlicht',
    subtitleEs: 'Sensor de temperatura, °C y una luz de aviso',
    order: 15,
    xpReward: 60,
    steps: [
      const IntroStep(
        id: 'a5_3_intro',
        mascotEmoji: '🌡️',
        mascotMessage: 'Kartımız artık sıcaklığı da ölçecek. Dereceyi seri porta yazacak, '
            'hava 30 °C\'yi geçince de kırmızı LED\'le uyaracak.',
        mascotMessageEn: 'Now our board measures temperature too. It writes the degrees to the serial '
            'port and warns with a red LED when it gets above 30 °C.',
        mascotMessageDe: 'Jetzt misst unsere Platine auch die Temperatur. Sie schreibt die Grad auf den '
            'seriellen Port und warnt mit einer roten LED, wenn es über 30 °C wird.',
        mascotMessageEs: 'Ahora nuestra placa también mide la temperatura. Escribe los grados en el '
            'puerto serie y avisa con un LED rojo cuando pasa de 30 °C.',
        highlights: ['Sıcaklık sensörü', '°C bloğu', 'Sıcaklık uyarısı'],
        highlightsEn: ['Temperature sensor', 'The °C block', 'Heat warning'],
        highlightsDe: ['Temperatursensor', 'Der °C-Block', 'Hitzewarnung'],
        highlightsEs: ['Sensor de temperatura', 'El bloque °C', 'Aviso de calor'],
      ),
      const ExplanationStep(
        id: 'a5_3_sensor',
        title: 'Üç Bacaklı Sensör',
        titleEn: 'A Sensor With Three Legs',
        titleDe: 'Ein Sensor mit drei Beinen',
        titleEs: 'Un sensor de tres patas',
        content: 'Düz yüzü sana bakarken soldan sağa bacaklar:\n\n'
            '• VCC → + hattı (5V)\n'
            '• Çıkış → A1\n'
            '• GND → − hattı\n\n'
            '"sıcaklık sensörü pin (A) 1 °C" bloğu dereceyi doğrudan verir.',
        contentEn: 'With the flat side facing you, the legs from left to right are:\n\n'
            '• VCC → + rail (5V)\n'
            '• Output → A1\n'
            '• GND → − rail\n\n'
            'The "temperature sensor pin (A) 1 °C" block gives you the degrees directly.',
        contentDe: 'Wenn die flache Seite zu dir zeigt, sind die Beine von links nach rechts:\n\n'
            '• VCC → +-Schiene (5V)\n'
            '• Ausgang → A1\n'
            '• GND → −-Schiene\n\n'
            'Der Block „Temperatursensor Pin (A) 1 °C“ liefert direkt die Grad.',
        contentEs: 'Con la cara plana hacia ti, las patas de izquierda a derecha son:\n\n'
            '• VCC → línea + (5V)\n'
            '• Salida → A1\n'
            '• GND → línea −\n\n'
            'El bloque «sensor de temperatura pin (A) 1 °C» te da los grados directamente.',
        visuals: [
          VisualElement(
            type: VisualType.scratchBlock,
            content: 'sıcaklık sensörü pin (A) 1 °C',
            contentEn: 'temperature sensor pin (A) 1 °C',
            contentDe: 'Temperatursensor Pin (A) 1 °C',
            contentEs: 'sensor de temperatura pin (A) 1 °C',
            color: MBlockPalette.sensor,
            label: 'Sensör',
            labelEn: 'Sensor',
            labelDe: 'Sensor',
            labelEs: 'Sensor',
          ),
        ],
        tipEmoji: '⚠️',
        tip: 'Ters takılan sıcaklık sensörü çok ısınır. Düz yüzü hep sana baksın.',
        tipEn: 'A temperature sensor put in backwards gets very hot. Keep the flat side facing you.',
        tipDe: 'Ein verkehrt eingesteckter Temperatursensor wird sehr heiß. Die flache Seite zeigt immer zu dir.',
        tipEs: 'Un sensor de temperatura al revés se calienta mucho. La cara plana siempre hacia ti.',
      ),
      _sicaklikDevre,
      arduinoKodAdimi(
        id: 'a5_3_kod',
        talimat: 'Her saniye sıcaklığı seri porta yaz. 30\'dan büyükse pin 12\'yi yak, 31\'den küçükse söndür. '
            'Sahnedeki "Ortam sıcaklığı" sürgüsüyle dene.',
        talimatEn: 'Every second, write the temperature to the serial port. If it is greater than 30 turn pin 12 on, '
            'if it is less than 31 turn it off. Try it with the "Room temperature" slider on the stage.',
        talimatDe: 'Schreib jede Sekunde die Temperatur auf den seriellen Port. Ist sie größer als 30, Pin 12 an; '
            'ist sie kleiner als 31, aus. Probier es mit dem Regler „Raumtemperatur“ auf der Bühne.',
        talimatEs: 'Cada segundo, escribe la temperatura en el puerto serie. Si es mayor que 30 enciende el pin 12; '
            'si es menor que 31, apágalo. Pruébalo con el control «Temperatura ambiente» del escenario.',
        hedef: 'Yaz, 30\'u geçince yak, değilse söndür, 1 bekle',
        hedefEn: 'Write, on above 30, otherwise off, wait 1',
        hedefDe: 'Schreiben, über 30 an, sonst aus, 1 warten',
        hedefEs: 'Escribir, encender por encima de 30, si no apagar, esperar 1',
        bloklar: const [
          'dev_kart_acilis',
          'dev_surekli',
          'dev_seri_yaz',
          'dev_sicaklik',
          'dev_eger',
          'dev_buyuktur',
          'dev_kucuktur',
          'dev_dijital_yaz',
          'dev_bekle',
        ],
        cozum: [
          kartAcilis,
          MBlockBeklenen('dev_surekli', kardesKosullarSerbest: true, icerik: [
            seriYaz(deger: sicaklikOku(1)),
            eger(buyuktur(sicaklikOku(1), 30), [dijitalYaz(12, true)]),
            eger(kucuktur(sicaklikOku(1), 31), [dijitalYaz(12, false)]),
            bekle(1),
          ]),
        ],
        devre: _sicaklikDevre.tamami,
        xp: 40,
      ),
      const MultipleChoiceStep(
        id: 'a5_3_q1',
        question: 'Sensör 25 °C ölçüyor. Kodumuzda LED ne yapar?',
        questionEn: 'The sensor reads 25 °C. What does the LED do in our code?',
        questionDe: 'Der Sensor misst 25 °C. Was macht die LED in unserem Code?',
        questionEs: 'El sensor mide 25 °C. ¿Qué hace el LED en nuestro código?',
        options: [
          ChoiceOption(text: 'Yanar', textEn: 'It turns on', textDe: 'Sie geht an', textEs: 'Se enciende'),
          ChoiceOption(text: 'Yanıp söner', textEn: 'It blinks', textDe: 'Sie blinkt', textEs: 'Parpadea'),
          ChoiceOption(text: 'Yarı parlak yanar', textEn: 'It glows at half brightness', textDe: 'Sie leuchtet halb hell', textEs: 'Brilla a media luz'),
          ChoiceOption(text: 'Sönük kalır', textEn: 'It stays off', textDe: 'Sie bleibt aus', textEs: 'Se queda apagado'),
        ],
        correctIndex: 3,
        explanation: '25, 30\'dan büyük değil ama 31\'den küçük: ikinci "eğer" çalışır ve pin 12 düşük olur.',
        explanationEn: '25 is not greater than 30 but it is less than 31: the second "if" runs and pin 12 goes low.',
        explanationDe: '25 ist nicht größer als 30, aber kleiner als 31: Das zweite „falls“ läuft und Pin 12 wird niedrig.',
        explanationEs: '25 no es mayor que 30 pero sí menor que 31: se ejecuta el segundo «si» y el pin 12 queda en bajo.',
      ),
      const ExplanationStep(
        id: 'a5_3_ozet',
        title: 'Termometre Hazır!',
        titleEn: 'Thermometer Ready!',
        titleDe: 'Thermometer fertig!',
        titleEs: '¡Termómetro listo!',
        content: '✓ Üç bacaklı sıcaklık sensörünü doğru yönde bağladın\n'
            '✓ Dereceyi her saniye seri porta yazdın\n'
            '✓ 30 °C\'yi geçince yanan bir uyarı ışığı yaptın\n\n'
            'Sıradaki modülde yeni parçalar seni bekliyor.',
        contentEn: '✓ You wired the three-legged temperature sensor the right way round\n'
            '✓ You wrote the degrees to the serial port every second\n'
            '✓ You made a warning light that turns on above 30 °C\n\n'
            'Next module: new parts are waiting for you.',
        contentDe: '✓ Du hast den dreibeinigen Temperatursensor richtig herum angeschlossen\n'
            '✓ Du hast jede Sekunde die Grad auf den seriellen Port geschrieben\n'
            '✓ Du hast ein Warnlicht gebaut, das über 30 °C angeht\n\n'
            'Nächstes Modul: Neue Bauteile warten auf dich.',
        contentEs: '✓ Conectaste el sensor de temperatura de tres patas en el sentido correcto\n'
            '✓ Escribiste los grados en el puerto serie cada segundo\n'
            '✓ Hiciste una luz de aviso que se enciende por encima de 30 °C\n\n'
            'Siguiente módulo: te esperan piezas nuevas.',
        tipEmoji: '🌡️',
        tip: 'Sınırı 30 yerine 25 yaparsan uyarı daha erken gelir.',
        tipEn: 'Change the limit from 30 to 25 and the warning comes sooner.',
        tipDe: 'Setzt du die Grenze von 30 auf 25, kommt die Warnung früher.',
        tipEs: 'Si cambias el límite de 30 a 25, el aviso llega antes.',
      ),
    ],
  ),
];
