import '../courses/data/mblock_palette.dart';
import '../courses/models/interactive_lesson_model.dart';

/// Arduino oyununun gorev turu.
///
/// Oyun tek bir oyun ama iki tur gorev iceriyor. Boylece ayni ekranda hem
/// "kodu kur, kart tepki versin" hem de "devrede ne eksik" calisiliyor;
/// cocuk icin iki ayri oyun degil, zorlasan tek bir yol.
enum ArduinoGorevTuru {
  /// Blok surukleyip kod kur; sanal kart calistirinca tepki veriyor.
  kod,

  /// Cizili devrede eksik parcayi sec.
  devre,
}

/// Bir blogun sanal kartta yaptigi sey.
///
/// Blok kimliginden turetiliyor; ekran bu enum'a bakarak animasyonu
/// oynatiyor. Blogun ETIKETI degil KIMLIGI kullaniliyor, cunku etiket
/// dort dilde degisiyor.
enum ArduinoEtki { ledYak, ledSondur, bekle, nota, servo, pwm, dongu, baslangic }

ArduinoEtki etkiOf(String blokId) {
  if (blokId == 'board_launch') return ArduinoEtki.baslangic;
  if (blokId == 'forever') return ArduinoEtki.dongu;
  if (blokId.startsWith('led_on')) return ArduinoEtki.ledYak;
  if (blokId.startsWith('led_off')) return ArduinoEtki.ledSondur;
  if (blokId.startsWith('wait')) return ArduinoEtki.bekle;
  if (blokId.startsWith('note')) return ArduinoEtki.nota;
  if (blokId.startsWith('servo')) return ArduinoEtki.servo;
  if (blokId.startsWith('pwm')) return ArduinoEtki.pwm;
  return ArduinoEtki.bekle;
}

/// Devre gorevindeki bir secenek.
class ArduinoSecenek {
  final String emoji;
  final String tr;
  final String en;
  final String de;
  final String es;

  const ArduinoSecenek(this.emoji, this.tr, this.en, this.de, this.es);
}

/// Tek bir seviye.
class ArduinoSeviye {
  final ArduinoGorevTuru tur;

  /// Ekranin ustundeki hedef cumlesi.
  final String hedefTr;
  final String hedefEn;
  final String hedefDe;
  final String hedefEs;

  /// Kod gorevi: paletteki bloklar (sirasi karistirilarak gosteriliyor).
  final List<ScratchBlock> havuz;

  /// Kod gorevi: dogru siradaki blok kimlikleri.
  final List<String> cozum;

  /// Devre gorevi: devrenin parcalari; '?' eksik olani gosteriyor.
  final List<String> devreParcalari;

  /// Devre gorevi: secenekler ve dogrusunun sirasi.
  final List<ArduinoSecenek> secenekler;
  final int dogruIndeks;

  /// Cevap sonrasi gosterilen kisa aciklama.
  final String ipucuTr;
  final String ipucuEn;
  final String ipucuDe;
  final String ipucuEs;

  const ArduinoSeviye.kodGorevi({
    required this.hedefTr,
    required this.hedefEn,
    required this.hedefDe,
    required this.hedefEs,
    required this.havuz,
    required this.cozum,
    required this.ipucuTr,
    required this.ipucuEn,
    required this.ipucuDe,
    required this.ipucuEs,
  })  : tur = ArduinoGorevTuru.kod,
        devreParcalari = const [],
        secenekler = const [],
        dogruIndeks = -1;

  const ArduinoSeviye.devreGorevi({
    required this.hedefTr,
    required this.hedefEn,
    required this.hedefDe,
    required this.hedefEs,
    required this.devreParcalari,
    required this.secenekler,
    required this.dogruIndeks,
    required this.ipucuTr,
    required this.ipucuEn,
    required this.ipucuDe,
    required this.ipucuEs,
  })  : tur = ArduinoGorevTuru.devre,
        havuz = const [],
        cozum = const [];

  String hedefFor(String lang) =>
      pickLang(hedefTr, hedefEn, lang, hedefDe, hedefEs);
  String ipucuFor(String lang) =>
      pickLang(ipucuTr, ipucuEn, lang, ipucuDe, ipucuEs);
}

/// Oyunun seviyeleri.
///
/// NEDEN BOYLE BIR OYUN
/// --------------------
/// Onceki ekran gercek bir breadboard simulatoruydu: 2.400 satir elle
/// cizilmis kart, delikli devre tahtasi ve kablo cizimi. Telefonda pin
/// hedefleri 20x12 piksele dusuyordu (onerilen ~44), kablolama parmakla
/// neredeyse imkansizdi ve ekran kalabalik gorunuyordu. Tinkercad'in
/// masaustu etkilesimini 390 puntoluk ekrana sigdirmaya calismak yanlis
/// karardi.
///
/// Yerine iki tur gorev kondu:
///  * KOD: kablolama yok. Kart ve parcalar hazir bagli; cocuk mBlock
///    bloklariyla kodu kuruyor, calistirinca LED gercekten yanip
///    soniyor, buzzer otuyor, servo donuyor. Arduino'nun cocuk icin
///    asil odulu bu: "yazdigim sey bir seyi hareket ettirdi".
///  * DEVRE: kablolama yerine anlama. Cizili devrede bir parca eksik,
///    cocuk uc buyuk secenekten dogrusunu seciyor. Dokunma hedefleri
///    kart boyunda.
///
/// Bloklar `MBlockBlocks`'tan geliyor, yani cocugun mBlock'ta gorecegi
/// blogun birebir ayni yazisi ve rengi.
class ArduinoGorevleri {
  ArduinoGorevleri._();

  static final List<ArduinoSeviye> seviyeler = [
    // 1 — tek blok: LED yak
    ArduinoSeviye.kodGorevi(
      hedefTr: 'Kartın 13 numaralı LED\'ini yak.',
      hedefEn: 'Turn on the LED on pin 13.',
      hedefDe: 'Schalte die LED an Pin 13 ein.',
      hedefEs: 'Enciende el LED del pin 13.',
      havuz: [_baslat, _ledYak, _ledSondur],
      cozum: ['board_launch', 'led_on'],
      ipucuTr: 'Her Arduino programı "Arduino açılınca" bloğuyla başlar.',
      ipucuEn: 'Every Arduino program starts with the "when Arduino starts up" block.',
      ipucuDe: 'Jedes Arduino-Programm beginnt mit dem Startblock.',
      ipucuEs: 'Todo programa de Arduino empieza con el bloque de inicio.',
    ),

    // 2 — devre: direnç
    ArduinoSeviye.devreGorevi(
      hedefTr: 'LED\'i yakmak için devrede bir parça eksik. Hangisi?',
      hedefEn: 'One part is missing from this LED circuit. Which one?',
      hedefDe: 'In diesem LED-Stromkreis fehlt ein Teil. Welches?',
      hedefEs: 'Falta una pieza en este circuito de LED. ¿Cuál?',
      devreParcalari: ['🔌', '?', '💡'],
      secenekler: [
        ArduinoSecenek('🟫', '220Ω direnç', '220Ω resistor', '220Ω Widerstand',
            'resistencia de 220Ω'),
        ArduinoSecenek('🔋', 'İkinci pil', 'A second battery', 'Zweite Batterie',
            'Otra pila'),
        ArduinoSecenek('🔊', 'Buzzer', 'A buzzer', 'Ein Summer', 'Un zumbador'),
      ],
      dogruIndeks: 0,
      ipucuTr: 'Direnç akımı sınırlar. Doğrudan bağlanan LED aşırı akımdan yanar.',
      ipucuEn: 'A resistor limits the current. Wired directly, an LED burns out.',
      ipucuDe: 'Ein Widerstand begrenzt den Strom. Direkt angeschlossen brennt die LED durch.',
      ipucuEs: 'La resistencia limita la corriente. Conectado directo, el LED se quema.',
    ),

    // 3 — yak, bekle, söndür
    ArduinoSeviye.kodGorevi(
      hedefTr: 'LED\'i yak, 1 saniye bekle, sonra söndür.',
      hedefEn: 'Turn the LED on, wait 1 second, then turn it off.',
      hedefDe: 'Schalte die LED ein, warte 1 Sekunde, schalte sie aus.',
      hedefEs: 'Enciende el LED, espera 1 segundo y apágalo.',
      havuz: [_baslat, _ledYak, _bekle, _ledSondur],
      cozum: ['board_launch', 'led_on', 'wait_1', 'led_off'],
      ipucuTr: 'Beklemeden söndürürsen göz yanışı göremez: bilgisayar çok hızlı.',
      ipucuEn: 'Without the wait you would not see it: the board is far too fast.',
      ipucuDe: 'Ohne das Warten sähest du nichts: die Platine ist viel zu schnell.',
      ipucuEs: 'Sin la espera no lo verías: la placa es demasiado rápida.',
    ),

    // 4 — sürekli yanıp sönme
    ArduinoSeviye.kodGorevi(
      hedefTr: 'LED sürekli yanıp sönsün. (Klasik "Blink")',
      hedefEn: 'Make the LED blink forever. (The classic "Blink")',
      hedefDe: 'Lass die LED dauerhaft blinken. (Der Klassiker "Blink")',
      hedefEs: 'Haz que el LED parpadee sin parar. (El clásico "Blink")',
      havuz: [_baslat, _surekli, _ledYak, _bekle, _ledSondur, _bekle2],
      cozum: ['board_launch', 'forever', 'led_on', 'wait_1', 'led_off', 'wait_1b'],
      ipucuTr: 'Sürekli tekrarla bloğunun içine dört blok giriyor: yak, bekle, söndür, bekle.',
      ipucuEn: 'Four blocks go inside the forever block: on, wait, off, wait.',
      ipucuDe: 'Vier Blöcke gehören in den Wiederhol-Block: an, warten, aus, warten.',
      ipucuEs: 'Dentro del bloque "por siempre" van cuatro: enciende, espera, apaga, espera.',
    ),

    // 5 — devre: hangi pin
    ArduinoSeviye.devreGorevi(
      hedefTr: 'Bir LED\'i açıp kapatmak için hangi pin türü gerekir?',
      hedefEn: 'Which kind of pin do you need to switch an LED on and off?',
      hedefDe: 'Welche Pin-Art brauchst du, um eine LED an- und auszuschalten?',
      hedefEs: '¿Qué tipo de pin necesitas para encender y apagar un LED?',
      devreParcalari: ['🧠', '?', '💡'],
      secenekler: [
        ArduinoSecenek('1️⃣', 'Dijital pin (0-13)', 'Digital pin (0-13)',
            'Digitaler Pin (0-13)', 'Pin digital (0-13)'),
        ArduinoSecenek('📈', 'Analog pin (A0-A5)', 'Analog pin (A0-A5)',
            'Analoger Pin (A0-A5)', 'Pin analógico (A0-A5)'),
        ArduinoSecenek('⚡', 'GND pini', 'GND pin', 'GND-Pin', 'Pin GND'),
      ],
      dogruIndeks: 0,
      ipucuTr: 'Dijital pin yalnızca iki şey yapar: açık (HIGH) ya da kapalı (LOW). LED için tam gerekeni.',
      ipucuEn: 'A digital pin does only two things: on (HIGH) or off (LOW). Exactly what an LED needs.',
      ipucuDe: 'Ein digitaler Pin kann nur zwei Dinge: an (HIGH) oder aus (LOW). Genau richtig für eine LED.',
      ipucuEs: 'Un pin digital solo hace dos cosas: encendido (HIGH) o apagado (LOW). Justo lo que necesita un LED.',
    ),

    // 6 — buzzer
    ArduinoSeviye.kodGorevi(
      hedefTr: 'Buzzer\'dan bir nota çal.',
      hedefEn: 'Play a note on the buzzer.',
      hedefDe: 'Spiel einen Ton auf dem Summer.',
      hedefEs: 'Toca una nota en el zumbador.',
      havuz: [_baslat, _nota, _ledYak, _bekle],
      cozum: ['board_launch', 'note_C4'],
      ipucuTr: 'Buzzer da bir çıkıştır; LED gibi pine bağlanır, farkı sesi olmasıdır.',
      ipucuEn: 'A buzzer is an output too; it connects to a pin like an LED, it just makes sound.',
      ipucuDe: 'Ein Summer ist auch ein Ausgang; er hängt wie eine LED an einem Pin, macht nur Geräusch.',
      ipucuEs: 'El zumbador también es una salida; se conecta a un pin como el LED, solo que suena.',
    ),

    // 7 — devre: buton
    ArduinoSeviye.devreGorevi(
      hedefTr: 'Butona basılıp basılmadığını öğrenmek için ne yaparsın?',
      hedefEn: 'How do you find out whether a button is pressed?',
      hedefDe: 'Wie findest du heraus, ob ein Taster gedrückt ist?',
      hedefEs: '¿Cómo sabes si un botón está pulsado?',
      devreParcalari: ['🔘', '?', '🧠'],
      secenekler: [
        ArduinoSecenek('👁️', 'Pini okurum', 'I read the pin', 'Ich lese den Pin',
            'Leo el pin'),
        ArduinoSecenek('✍️', 'Pine yazarım', 'I write to the pin',
            'Ich schreibe auf den Pin', 'Escribo en el pin'),
        ArduinoSecenek('⏳', 'Beklerim', 'I wait', 'Ich warte', 'Espero'),
      ],
      dogruIndeks: 0,
      ipucuTr: 'Çıkışa yazarsın, girişi okursun. Buton bir giriştir: "dijital oku" bloğu.',
      ipucuEn: 'You write to outputs and read from inputs. A button is an input: the "read digital pin" block.',
      ipucuDe: 'Auf Ausgänge schreibst du, Eingänge liest du. Ein Taster ist ein Eingang: der Block "Digitalpin lesen".',
      ipucuEs: 'A las salidas se escribe, las entradas se leen. El botón es una entrada: el bloque "lee pin digital".',
    ),

    // 8 — servo
    ArduinoSeviye.kodGorevi(
      hedefTr: 'Servo motoru 90 dereceye çevir.',
      hedefEn: 'Turn the servo motor to 90 degrees.',
      hedefDe: 'Dreh den Servomotor auf 90 Grad.',
      hedefEs: 'Gira el servomotor a 90 grados.',
      havuz: [_baslat, _servo, _ledYak, _nota],
      cozum: ['board_launch', 'servo_90'],
      ipucuTr: 'Servo, DC motorun aksine belirli bir açıya gider ve orada durur.',
      ipucuEn: 'Unlike a DC motor, a servo turns to a set angle and stays there.',
      ipucuDe: 'Anders als ein DC-Motor dreht ein Servo auf einen festen Winkel und bleibt dort.',
      ipucuEs: 'A diferencia de un motor DC, el servo gira a un ángulo fijo y se queda ahí.',
    ),
  ];

  // --- Seviyelerde kullanilan bloklar -------------------------------------
  //
  // Kimlikler SABIT tutuluyor: cozum listesi ve kartin animasyonu bu
  // kimliklere bakiyor, etiketlere degil (etiket dort dilde degisiyor).

  static final ScratchBlock _baslat = MBlockBlocks.boardLaunch();

  static final ScratchBlock _surekli = MBlockBlocks.forever();

  static final ScratchBlock _ledYak = MBlockBlocks.digitalWrite(
      '13', 'yüksek',
      levelEn: 'high', levelDe: 'hoch', levelEs: 'alto', id: 'led_on');

  static final ScratchBlock _ledSondur = MBlockBlocks.digitalWrite(
      '13', 'düşük',
      levelEn: 'low', levelDe: 'niedrig', levelEs: 'bajo', id: 'led_off');

  static final ScratchBlock _bekle = MBlockBlocks.wait('1', id: 'wait_1');

  /// Blink'te iki ayri bekleme var; kimlikleri farkli olmali yoksa cozum
  /// listesinde hangisinin nereye gittigi ayirt edilemiyor.
  static final ScratchBlock _bekle2 = MBlockBlocks.wait('1', id: 'wait_1b');

  static final ScratchBlock _nota =
      MBlockBlocks.playNote('8', 'C4', '0.5', id: 'note_C4');

  static final ScratchBlock _servo =
      MBlockBlocks.servo('9', '90', id: 'servo_90');
}
