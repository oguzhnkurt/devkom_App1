import '../yurutme/mblock_cozum.dart';
import 'devre_modeli.dart';

/// Arduino kursunun ve Arduino Atolyesinin HAZIR DEVRELERI.
///
/// Ayni yerlesim hem derslerde (rehberli devre kurma adimi) hem de
/// atolyenin rehberli projelerinde kullaniliyor: cocuk derste kurdugu
/// devreyi atolyede ayni yerde buluyor.
///
/// YERLESIM KURALLARI (butun devrelerde ayni)
///  * Uno'nun guc basligi breadboard'un tam ustunde: GND -> ustteki eksi
///    hat (`U-20`), 5V -> ustteki arti hat (`U+19`). Kablolar kisa.
///  * LED blogu sutun s'de: direnc `j(s-3)`..`j(s)` yatay, LED anodu
///    `h(s)`, katodu `h(s+1)`. Pin kablosu direncin sol seridine,
///    katot seridi eksi hatta.
///  * Sensorler ust yarinin en ust satirinda (`j`), govdeleri hatlarin
///    ustune tasiyor; kablolar ayni sutunun `f`-`i` deliklerinden.
abstract final class DevreKalibi {
  static const Kablo gndKablosu = Kablo('GND1', 'U-20');
  static const Kablo vKablosu = Kablo('5V', 'U+19');

  static const HedefBaglanti gndHedefi = HedefBaglanti(
    'GND1',
    'U-20',
    tr: 'Uno\'nun GND pinini üstteki − (mavi) hatta bağla.',
    en: 'Connect the Uno\'s GND pin to the top − (blue) rail.',
    de: 'Verbinde den GND-Pin des Uno mit der oberen − (blauen) Schiene.',
    es: 'Conecta el pin GND del Uno a la línea − (azul) superior.',
  );

  static const HedefBaglanti vHedefi = HedefBaglanti(
    '5V',
    'U+19',
    tr: 'Uno\'nun 5V pinini üstteki + (kırmızı) hatta bağla.',
    en: 'Connect the Uno\'s 5V pin to the top + (red) rail.',
    de: 'Verbinde den 5V-Pin des Uno mit der oberen + (roten) Schiene.',
    es: 'Conecta el pin 5V del Uno a la línea + (roja) superior.',
  );

  /// LED + 220 ohm, sutun [s] (s+1 altinin kati olmamali: orada hat
  /// deligi yok).
  static List<Parca> led(String id, int s, {LedRengi renk = LedRengi.kirmizi}) {
    assert(rayDeligiVar(s + 1));
    return [
      Parca.direnc('R$id', 'j${s - 3}'),
      Parca.led(id, 'h$s', renk: renk),
    ];
  }

  static List<Kablo> ledKablolari(int pin, int s) => [
        Kablo('D$pin', 'g${s - 3}'),
        Kablo('i${s + 1}', 'U-${s + 1}'),
      ];

  static List<HedefBaglanti> ledHedefleri(int pin, int s) => [
        HedefBaglanti('D$pin', 'g${s - 3}',
            tr: 'Pin $pin\'u direncin sol bacağının sırasına (sütun ${s - 3}) bağla.',
            en: 'Connect pin $pin to the resistor\'s left leg strip (column ${s - 3}).',
            de: 'Verbinde Pin $pin mit dem Streifen des linken Widerstandsbeins (Spalte ${s - 3}).',
            es: 'Conecta el pin $pin a la tira de la pata izquierda de la resistencia (columna ${s - 3}).'),
        HedefBaglanti('i${s + 1}', 'U-${s + 1}',
            tr: 'LED\'in kısa bacağının sırasını (sütun ${s + 1}) − hattına bağla.',
            en: 'Connect the LED\'s short leg strip (column ${s + 1}) to the − rail.',
            de: 'Verbinde den Streifen des kurzen LED-Beins (Spalte ${s + 1}) mit der −-Schiene.',
            es: 'Conecta la tira de la pata corta del LED (columna ${s + 1}) a la línea −.'),
      ];

  // ---------------------------------------------------------------- buton

  /// Buton (kanalin iki yaninda, sutun 8 ve 10) + 10k cekme direnci
  /// (`j10`..`j13`).
  static List<Parca> buton() => [
        Parca.buton('B1', 'e8'),
        Parca.direnc('R10K', 'j10', ohm: 10000),
      ];

  static const List<Kablo> butonKablolari = [
    Kablo('j8', 'U+8'),
    Kablo('i10', 'D2'),
    Kablo('i13', 'U-13'),
  ];

  static const List<HedefBaglanti> butonHedefleri = [
    HedefBaglanti('j8', 'U+8',
        tr: 'Butonun sol bacağının sırasını (sütun 8) + hattına bağla.',
        en: 'Connect the button\'s left leg strip (column 8) to the + rail.',
        de: 'Verbinde den Streifen des linken Tasterbeins (Spalte 8) mit der +-Schiene.',
        es: 'Conecta la tira de la pata izquierda del pulsador (columna 8) a la línea +.'),
    HedefBaglanti('i10', 'D2',
        tr: 'Butonun sağ bacağının sırasını (sütun 10) pin 2\'ye bağla.',
        en: 'Connect the button\'s right leg strip (column 10) to pin 2.',
        de: 'Verbinde den Streifen des rechten Tasterbeins (Spalte 10) mit Pin 2.',
        es: 'Conecta la tira de la pata derecha del pulsador (columna 10) al pin 2.'),
    HedefBaglanti('i13', 'U-13',
        tr: '10k direncin öbür ucunu (sütun 13) − hattına bağla. Buton basılı değilken pin 2 böylece 0 okur.',
        en: 'Connect the other end of the 10k resistor (column 13) to the − rail. Then pin 2 reads 0 while the button is up.',
        de: 'Verbinde das andere Ende des 10k-Widerstands (Spalte 13) mit der −-Schiene. So liest Pin 2 eine 0, solange der Taster oben ist.',
        es: 'Conecta el otro extremo de la resistencia de 10k (columna 13) a la línea −. Así el pin 2 lee 0 mientras el pulsador está suelto.'),
  ];

  // ------------------------------------------------------------ pot (A0)

  static List<Parca> pot() => [Parca.pot('P1', 'j3')];

  static const List<Kablo> potKablolari = [
    Kablo('i3', 'U+3'),
    Kablo('i5', 'U-5'),
    Kablo('i4', 'A0'),
  ];

  static const List<HedefBaglanti> potHedefleri = [
    HedefBaglanti('i3', 'U+3',
        tr: 'Potansiyometrenin sol bacağını (sütun 3) + hattına bağla.',
        en: 'Connect the potentiometer\'s left leg (column 3) to the + rail.',
        de: 'Verbinde das linke Bein des Potentiometers (Spalte 3) mit der +-Schiene.',
        es: 'Conecta la pata izquierda del potenciómetro (columna 3) a la línea +.'),
    HedefBaglanti('i5', 'U-5',
        tr: 'Sağ bacağını (sütun 5) − hattına bağla.',
        en: 'Connect its right leg (column 5) to the − rail.',
        de: 'Verbinde sein rechtes Bein (Spalte 5) mit der −-Schiene.',
        es: 'Conecta su pata derecha (columna 5) a la línea −.'),
    HedefBaglanti('i4', 'A0',
        tr: 'Orta bacağı (sütun 4) analog pin A0\'a bağla.',
        en: 'Connect the middle leg (column 4) to analog pin A0.',
        de: 'Verbinde das mittlere Bein (Spalte 4) mit dem Analogpin A0.',
        es: 'Conecta la pata central (columna 4) al pin analógico A0.'),
  ];

  // ------------------------------------------------------- LDR (A0) + 10k

  static List<Parca> ldr() => [
        Parca.ldr('IS1', 'j3'),
        Parca.direnc('R10K', 'h5', ohm: 10000),
      ];

  static const List<Kablo> ldrKablolari = [
    Kablo('i3', 'U+3'),
    Kablo('i8', 'U-8'),
    Kablo('g5', 'A0'),
  ];

  static const List<HedefBaglanti> ldrHedefleri = [
    HedefBaglanti('i3', 'U+3',
        tr: 'Işık sensörünün sol bacağını (sütun 3) + hattına bağla.',
        en: 'Connect the light sensor\'s left leg (column 3) to the + rail.',
        de: 'Verbinde das linke Bein des Lichtsensors (Spalte 3) mit der +-Schiene.',
        es: 'Conecta la pata izquierda del sensor de luz (columna 3) a la línea +.'),
    HedefBaglanti('i8', 'U-8',
        tr: '10k direncin sağ ucunu (sütun 8) − hattına bağla.',
        en: 'Connect the right end of the 10k resistor (column 8) to the − rail.',
        de: 'Verbinde das rechte Ende des 10k-Widerstands (Spalte 8) mit der −-Schiene.',
        es: 'Conecta el extremo derecho de la resistencia de 10k (columna 8) a la línea −.'),
    HedefBaglanti('g5', 'A0',
        tr: 'Sensörle direncin buluştuğu sırayı (sütun 5) A0\'a bağla.',
        en: 'Connect the strip where the sensor meets the resistor (column 5) to A0.',
        de: 'Verbinde den Streifen, wo Sensor und Widerstand sich treffen (Spalte 5), mit A0.',
        es: 'Conecta la tira donde se unen el sensor y la resistencia (columna 5) a A0.'),
  ];

  // ---------------------------------------------------- sicaklik (A1)

  static List<Parca> sicaklik() => [Parca.sicaklik('T1', 'j3')];

  static const List<Kablo> sicaklikKablolari = [
    Kablo('i3', 'U+3'),
    Kablo('i5', 'U-5'),
    Kablo('i4', 'A1'),
  ];

  static const List<HedefBaglanti> sicaklikHedefleri = [
    HedefBaglanti('i3', 'U+3',
        tr: 'Sıcaklık sensörünün sol bacağını (VCC, sütun 3) + hattına bağla.',
        en: 'Connect the temperature sensor\'s left leg (VCC, column 3) to the + rail.',
        de: 'Verbinde das linke Bein des Temperatursensors (VCC, Spalte 3) mit der +-Schiene.',
        es: 'Conecta la pata izquierda del sensor de temperatura (VCC, columna 3) a la línea +.'),
    HedefBaglanti('i5', 'U-5',
        tr: 'Sağ bacağını (GND, sütun 5) − hattına bağla.',
        en: 'Connect its right leg (GND, column 5) to the − rail.',
        de: 'Verbinde sein rechtes Bein (GND, Spalte 5) mit der −-Schiene.',
        es: 'Conecta su pata derecha (GND, columna 5) a la línea −.'),
    HedefBaglanti('i4', 'A1',
        tr: 'Orta bacağı (çıkış, sütun 4) A1\'e bağla.',
        en: 'Connect the middle leg (output, column 4) to A1.',
        de: 'Verbinde das mittlere Bein (Ausgang, Spalte 4) mit A1.',
        es: 'Conecta la pata central (salida, columna 4) a A1.'),
  ];

  // ------------------------------------------ mesafe (trig 12, echo 11)

  static List<Parca> mesafe() => [Parca.mesafe('M1', 'j3')];

  static const List<Kablo> mesafeKablolari = [
    Kablo('i3', 'U+3'),
    Kablo('i4', 'D12'),
    Kablo('i5', 'D11'),
    Kablo('i6', 'U-7'),
  ];

  static const List<HedefBaglanti> mesafeHedefleri = [
    HedefBaglanti('i3', 'U+3',
        tr: 'Sensörün VCC bacağını (sütun 3) + hattına bağla.',
        en: 'Connect the sensor\'s VCC leg (column 3) to the + rail.',
        de: 'Verbinde das VCC-Bein des Sensors (Spalte 3) mit der +-Schiene.',
        es: 'Conecta la pata VCC del sensor (columna 3) a la línea +.'),
    HedefBaglanti('i4', 'D12',
        tr: 'TRIG bacağını (sütun 4) pin 12\'ye bağla.',
        en: 'Connect the TRIG leg (column 4) to pin 12.',
        de: 'Verbinde das TRIG-Bein (Spalte 4) mit Pin 12.',
        es: 'Conecta la pata TRIG (columna 4) al pin 12.'),
    HedefBaglanti('i5', 'D11',
        tr: 'ECHO bacağını (sütun 5) pin 11\'e bağla.',
        en: 'Connect the ECHO leg (column 5) to pin 11.',
        de: 'Verbinde das ECHO-Bein (Spalte 5) mit Pin 11.',
        es: 'Conecta la pata ECHO (columna 5) al pin 11.'),
    HedefBaglanti('i6', 'U-7',
        tr: 'GND bacağını (sütun 6) − hattına bağla.',
        en: 'Connect the GND leg (column 6) to the − rail.',
        de: 'Verbinde das GND-Bein (Spalte 6) mit der −-Schiene.',
        es: 'Conecta la pata GND (columna 6) a la línea −.'),
  ];

  // ------------------------------------------------------ buzzer (pin 8)

  /// Buzzer: arti `h(s)`, eksi `h(s+3)`.
  static List<Parca> buzzer(int s) => [Parca.buzzer('Z1', 'h$s')];

  static List<Kablo> buzzerKablolari(int s) => [
        Kablo('D8', 'g$s'),
        Kablo('i${s + 3}', 'U-${s + 3}'),
      ];

  static List<HedefBaglanti> buzzerHedefleri(int s) => [
        HedefBaglanti('D8', 'g$s',
            tr: 'Buzzer\'ın + bacağının sırasını (sütun $s) pin 8\'e bağla.',
            en: 'Connect the buzzer\'s + leg strip (column $s) to pin 8.',
            de: 'Verbinde den Streifen des +-Beins vom Summer (Spalte $s) mit Pin 8.',
            es: 'Conecta la tira de la pata + del zumbador (columna $s) al pin 8.'),
        HedefBaglanti('i${s + 3}', 'U-${s + 3}',
            tr: '− bacağının sırasını (sütun ${s + 3}) − hattına bağla.',
            en: 'Connect the − leg strip (column ${s + 3}) to the − rail.',
            de: 'Verbinde den Streifen des −-Beins (Spalte ${s + 3}) mit der −-Schiene.',
            es: 'Conecta la tira de la pata − (columna ${s + 3}) a la línea −.'),
      ];

  // -------------------------------------------------------- servo (pin 9)

  static List<Parca> servo() => [Parca.servo('S1')];

  static const List<Kablo> servoKablolari = [
    Kablo('S1.gnd', 'GND'),
    Kablo('S1.vcc', 'U+1'),
    Kablo('S1.sinyal', 'D9'),
  ];

  static const List<HedefBaglanti> servoHedefleri = [
    HedefBaglanti('S1.gnd', 'GND',
        tr: 'Servonun kahverengi kablosunu GND\'ye bağla.',
        en: 'Connect the servo\'s brown wire to GND.',
        de: 'Verbinde das braune Servokabel mit GND.',
        es: 'Conecta el cable marrón del servo a GND.'),
    HedefBaglanti('S1.vcc', 'U+1',
        tr: 'Kırmızı kablosunu + hattına (5V) bağla.',
        en: 'Connect its red wire to the + rail (5V).',
        de: 'Verbinde das rote Kabel mit der +-Schiene (5V).',
        es: 'Conecta su cable rojo a la línea + (5V).'),
    HedefBaglanti('S1.sinyal', 'D9',
        tr: 'Turuncu sinyal kablosunu pin 9\'a bağla.',
        en: 'Connect the orange signal wire to pin 9.',
        de: 'Verbinde das orange Signalkabel mit Pin 9.',
        es: 'Conecta el cable naranja de señal al pin 9.'),
  ];
}

/// Atolyenin rehberli projesi.
class ArduinoProjesi {
  const ArduinoProjesi({
    required this.id,
    required this.ad,
    required this.hedef,
    required this.zorluk,
    required this.parcalar,
    this.hazirKablolar = const [],
    required this.hedefler,
    required this.kod,
  });

  final String id;

  /// tr, en, de, es.
  final List<String> ad;

  /// Devre kurulunca ne yapilacak (dort dil).
  final List<String> hedef;

  /// 1-3 yildiz.
  final int zorluk;
  final List<Parca> parcalar;

  /// Bastan takili kablolar (onceki adimlardan kalan).
  final List<Kablo> hazirKablolar;
  final List<HedefBaglanti> hedefler;

  /// Ornek cozum programi.
  final List<MBlockBeklenen> kod;

  String adFor(String lang) => ad[_i(lang)];
  String hedefFor(String lang) => hedef[_i(lang)];

  static int _i(String lang) => switch (lang) {
        'tr' => 0,
        'de' => 2,
        'es' => 3,
        _ => 1,
      };

  Devre get baslangic => Devre(parcalar: parcalar, kablolar: hazirKablolar);

  /// Devrenin tamami (hedeflerin hepsi takili): kod adimlari icin.
  Devre get tamami => Devre(parcalar: parcalar, kablolar: [
        ...hazirKablolar,
        for (final h in hedefler) Kablo(h.a, h.b),
      ]);
}

// ---------------------------------------------------------------------
// Ornek programlar (cozum dilinde)
// ---------------------------------------------------------------------

const MBlockBeklenen _bas = MBlockBeklenen('dev_kart_acilis');

MBlockBeklenen _yaz(int pin, bool yuksek) => MBlockBeklenen('dev_dijital_yaz',
    alanlar: {'PIN': '$pin', 'SEVIYE': yuksek ? 'HIGH' : 'LOW'});

MBlockBeklenen _bekle(String sn) =>
    MBlockBeklenen('dev_bekle', alanlar: {'SANIYE': sn});

MBlockBeklenen _surekli(List<MBlockBeklenen> ic) =>
    MBlockBeklenen('dev_surekli', icerik: ic);

final List<ArduinoProjesi> arduinoProjeleri = [
  ArduinoProjesi(
    id: 'led_yak',
    ad: const ['LED Yak', 'Light an LED', 'LED leuchten lassen', 'Enciende un LED'],
    hedef: const [
      'Pin 13\'teki LED bir saniye yansın, bir saniye sönsün.',
      'Make the LED on pin 13 blink: one second on, one second off.',
      'Lass die LED an Pin 13 blinken: eine Sekunde an, eine aus.',
      'Haz parpadear el LED del pin 13: un segundo encendido, uno apagado.',
    ],
    zorluk: 1,
    parcalar: DevreKalibi.led('L1', 12),
    hedefler: [DevreKalibi.gndHedefi, ...DevreKalibi.ledHedefleri(13, 12)],
    kod: [
      _bas,
      _surekli([_yaz(13, true), _bekle('1'), _yaz(13, false), _bekle('1')]),
    ],
  ),
  ArduinoProjesi(
    id: 'trafik',
    ad: const ['Trafik Işığı', 'Traffic Light', 'Ampel', 'Semáforo'],
    hedef: const [
      'Kırmızı 3 saniye, yeşil 3 saniye, sarı 1 saniye yansın; sonsuza kadar.',
      'Red for 3 seconds, green for 3, yellow for 1, forever.',
      'Rot 3 Sekunden, Grün 3, Gelb 1, immer wieder.',
      'Rojo 3 segundos, verde 3 y amarillo 1, para siempre.',
    ],
    zorluk: 2,
    parcalar: [
      ...DevreKalibi.led('L1', 10, renk: LedRengi.kirmizi),
      ...DevreKalibi.led('L2', 16, renk: LedRengi.sari),
      ...DevreKalibi.led('L3', 22, renk: LedRengi.yesil),
    ],
    hedefler: [
      DevreKalibi.gndHedefi,
      ...DevreKalibi.ledHedefleri(12, 10),
      ...DevreKalibi.ledHedefleri(11, 16),
      ...DevreKalibi.ledHedefleri(10, 22),
    ],
    kod: [
      _bas,
      _surekli([
        _yaz(12, true), _bekle('3'), _yaz(12, false),
        _yaz(10, true), _bekle('3'), _yaz(10, false),
        _yaz(11, true), _bekle('1'), _yaz(11, false),
      ]),
    ],
  ),
  ArduinoProjesi(
    id: 'buton_led',
    ad: const ['Butonla LED', 'Button and LED', 'Taster und LED', 'Pulsador y LED'],
    hedef: const [
      'Butona basınca LED yansın, bırakınca sönsün.',
      'The LED lights while you press the button and goes off when you let go.',
      'Die LED leuchtet, solange du den Taster drückst.',
      'El LED se enciende mientras pulsas el botón y se apaga al soltarlo.',
    ],
    zorluk: 2,
    parcalar: [...DevreKalibi.buton(), ...DevreKalibi.led('L1', 22)],
    hazirKablolar: [DevreKalibi.gndKablosu, ...DevreKalibi.ledKablolari(13, 22)],
    hedefler: [DevreKalibi.vHedefi, ...DevreKalibi.butonHedefleri],
    kod: [
      _bas,
      _surekli([
        const MBlockBeklenen('dev_eger',
            girdiler: {'KOSUL': MBlockBeklenen('dev_dijital_oku', alanlar: {'PIN': '2'})},
            icerik: [MBlockBeklenen('dev_dijital_yaz', alanlar: {'PIN': '13', 'SEVIYE': 'HIGH'})]),
        const MBlockBeklenen('dev_eger', girdiler: {
          'KOSUL': MBlockBeklenen('dev_degil',
              girdiler: {'KOSUL': MBlockBeklenen('dev_dijital_oku', alanlar: {'PIN': '2'})})
        }, icerik: [
          MBlockBeklenen('dev_dijital_yaz', alanlar: {'PIN': '13', 'SEVIYE': 'LOW'})
        ]),
      ]),
    ],
  ),
  ArduinoProjesi(
    id: 'pot_parlaklik',
    ad: const ['Düğmeyle Parlaklık', 'Dimmer Knob', 'Dimmer-Drehknopf', 'Regulador de brillo'],
    hedef: const [
      'Potansiyometreyi çevirdikçe pin 9\'daki LED parlasın ya da sönükleşsin.',
      'Turn the potentiometer to make the LED on pin 9 brighter or dimmer.',
      'Dreh am Potentiometer: Die LED an Pin 9 wird heller oder dunkler.',
      'Gira el potenciómetro para que el LED del pin 9 brille más o menos.',
    ],
    zorluk: 2,
    parcalar: [...DevreKalibi.pot(), ...DevreKalibi.led('L1', 14, renk: LedRengi.mavi)],
    hazirKablolar: [DevreKalibi.gndKablosu, DevreKalibi.vKablosu],
    hedefler: [...DevreKalibi.potHedefleri, ...DevreKalibi.ledHedefleri(9, 14)],
    kod: [
      _bas,
      _surekli([
        const MBlockBeklenen('dev_pwm_yaz', alanlar: {'PIN': '9'}, girdiler: {
          'GUC': MBlockBeklenen('dev_harita',
              alanlar: {'A': '0', 'B': '1023', 'C': '0', 'D': '255'},
              girdiler: {'DEGER': MBlockBeklenen('dev_analog_oku', alanlar: {'PIN': '0'})})
        }),
      ]),
    ],
  ),
  ArduinoProjesi(
    id: 'gece_lambasi',
    ad: const ['Gece Lambası', 'Night Light', 'Nachtlicht', 'Luz nocturna'],
    hedef: const [
      'Oda kararınca (A0 400\'den küçükken) LED kendiliğinden yansın.',
      'When the room gets dark (A0 below 400) the LED switches on by itself.',
      'Wird es dunkel (A0 unter 400), geht die LED von selbst an.',
      'Cuando oscurece (A0 menor que 400) el LED se enciende solo.',
    ],
    zorluk: 2,
    parcalar: [...DevreKalibi.ldr(), ...DevreKalibi.led('L1', 16, renk: LedRengi.sari)],
    hazirKablolar: [DevreKalibi.gndKablosu, DevreKalibi.vKablosu, ...DevreKalibi.ledKablolari(13, 16)],
    hedefler: DevreKalibi.ldrHedefleri,
    kod: [
      _bas,
      _surekli([
        const MBlockBeklenen('dev_eger', girdiler: {
          'KOSUL': MBlockBeklenen('dev_kucuktur',
              alanlar: {'B': '400'}, girdiler: {'A': MBlockBeklenen('dev_analog_oku', alanlar: {'PIN': '0'})})
        }, icerik: [
          MBlockBeklenen('dev_dijital_yaz', alanlar: {'PIN': '13', 'SEVIYE': 'HIGH'})
        ]),
        const MBlockBeklenen('dev_eger', girdiler: {
          'KOSUL': MBlockBeklenen('dev_buyuktur',
              alanlar: {'B': '399'}, girdiler: {'A': MBlockBeklenen('dev_analog_oku', alanlar: {'PIN': '0'})})
        }, icerik: [
          MBlockBeklenen('dev_dijital_yaz', alanlar: {'PIN': '13', 'SEVIYE': 'LOW'})
        ]),
      ]),
    ],
  ),
  ArduinoProjesi(
    id: 'termometre',
    ad: const ['Termometre', 'Thermometer', 'Thermometer', 'Termómetro'],
    hedef: const [
      'Sıcaklığı her saniye seri porta yaz; 30 °C\'yi geçince kırmızı LED yansın.',
      'Write the temperature to the serial port every second; above 30 °C the red LED lights up.',
      'Schreib jede Sekunde die Temperatur auf den seriellen Port; über 30 °C leuchtet die rote LED.',
      'Escribe la temperatura en el puerto serie cada segundo; por encima de 30 °C se enciende el LED rojo.',
    ],
    zorluk: 3,
    parcalar: [...DevreKalibi.sicaklik(), ...DevreKalibi.led('L1', 16)],
    hazirKablolar: [DevreKalibi.gndKablosu, DevreKalibi.vKablosu],
    hedefler: [...DevreKalibi.sicaklikHedefleri, ...DevreKalibi.ledHedefleri(12, 16)],
    kod: [
      _bas,
      _surekli([
        const MBlockBeklenen('dev_seri_yaz',
            girdiler: {'METIN': MBlockBeklenen('dev_sicaklik', alanlar: {'PIN': '1'})}),
        const MBlockBeklenen('dev_eger', girdiler: {
          'KOSUL': MBlockBeklenen('dev_buyuktur',
              alanlar: {'B': '30'}, girdiler: {'A': MBlockBeklenen('dev_sicaklik', alanlar: {'PIN': '1'})})
        }, icerik: [
          MBlockBeklenen('dev_dijital_yaz', alanlar: {'PIN': '12', 'SEVIYE': 'HIGH'})
        ]),
        const MBlockBeklenen('dev_eger', girdiler: {
          'KOSUL': MBlockBeklenen('dev_kucuktur',
              alanlar: {'B': '31'}, girdiler: {'A': MBlockBeklenen('dev_sicaklik', alanlar: {'PIN': '1'})})
        }, icerik: [
          MBlockBeklenen('dev_dijital_yaz', alanlar: {'PIN': '12', 'SEVIYE': 'LOW'})
        ]),
        _bekle('1'),
      ]),
    ],
  ),
  ArduinoProjesi(
    id: 'park_sensoru',
    ad: const ['Park Sensörü', 'Parking Sensor', 'Einparkhilfe', 'Sensor de aparcamiento'],
    hedef: const [
      'Engel 20 cm\'den yakınsa buzzer bip bip ötsün.',
      'When something is closer than 20 cm, the buzzer beeps.',
      'Ist etwas näher als 20 cm, piept der Summer.',
      'Si algo está a menos de 20 cm, el zumbador pita.',
    ],
    zorluk: 3,
    parcalar: [...DevreKalibi.mesafe(), ...DevreKalibi.buzzer(20)],
    hazirKablolar: [DevreKalibi.gndKablosu, DevreKalibi.vKablosu],
    hedefler: [...DevreKalibi.mesafeHedefleri, ...DevreKalibi.buzzerHedefleri(20)],
    kod: [
      _bas,
      _surekli([
        const MBlockBeklenen('dev_eger', girdiler: {
          'KOSUL': MBlockBeklenen('dev_kucuktur', alanlar: {
            'B': '20'
          }, girdiler: {
            'A': MBlockBeklenen('dev_mesafe', alanlar: {'TRIG': '12', 'ECHO': '11'})
          })
        }, icerik: [
          MBlockBeklenen('dev_ton', alanlar: {'PIN': '8', 'FREKANS': '880', 'SANIYE': '0.1'}),
          MBlockBeklenen('dev_bekle', alanlar: {'SANIYE': '0.1'}),
        ]),
      ]),
    ],
  ),
  ArduinoProjesi(
    id: 'bariyer',
    ad: const ['Akıllı Bariyer', 'Smart Barrier', 'Schlaue Schranke', 'Barrera inteligente'],
    hedef: const [
      'Araba (engel) 15 cm\'den yakına gelince servo bariyeri 90 dereceye kaldırsın, sonra indirsin.',
      'When a car (obstacle) comes closer than 15 cm, the servo lifts the barrier to 90 degrees, then lowers it.',
      'Kommt ein Auto (Hindernis) näher als 15 cm, hebt der Servo die Schranke auf 90 Grad und senkt sie wieder.',
      'Cuando un coche (obstáculo) está a menos de 15 cm, el servo sube la barrera a 90 grados y luego la baja.',
    ],
    zorluk: 3,
    parcalar: [...DevreKalibi.mesafe(), ...DevreKalibi.servo()],
    hazirKablolar: [DevreKalibi.gndKablosu, DevreKalibi.vKablosu, ...DevreKalibi.mesafeKablolari],
    hedefler: DevreKalibi.servoHedefleri,
    kod: [
      _bas,
      const MBlockBeklenen('dev_servo', alanlar: {'PIN': '9', 'ACI': '0'}),
      _surekli([
        const MBlockBeklenen('dev_eger', girdiler: {
          'KOSUL': MBlockBeklenen('dev_kucuktur', alanlar: {
            'B': '15'
          }, girdiler: {
            'A': MBlockBeklenen('dev_mesafe', alanlar: {'TRIG': '12', 'ECHO': '11'})
          })
        }, icerik: [
          MBlockBeklenen('dev_servo', alanlar: {'PIN': '9', 'ACI': '90'}),
          MBlockBeklenen('dev_bekle', alanlar: {'SANIYE': '2'}),
          MBlockBeklenen('dev_servo', alanlar: {'PIN': '9', 'ACI': '0'}),
        ]),
      ]),
    ],
  ),
];
