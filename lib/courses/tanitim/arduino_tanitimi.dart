import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/sound_service.dart';
import '../../theme.dart';
import '../../ui/motion.dart';
import '../../widgets/mascot.dart';
import '../../widgets/scratch_blok.dart';
import '../data/course_modules.dart';
import '../devre/arduino_projeleri.dart';
import '../devre/devre_cizimi.dart';
import '../devre/devre_modeli.dart';
import '../devre/devre_simulasyonu.dart';
import '../devre/devre_yerlesim.dart';
import '../models/course_model.dart';
import '../sahne/uno_karti.dart' show UnoOlcu;
import '../screens/widgets/step_widgets.dart' show lessonLang;
import '../yurutme/mblock_uno.dart';
import 'kurs_tanitimi.dart';
import 'tanitim_parcalari.dart';

/// ARDUINO KURSUNUN ACILISI — Devi malzemeleri tek tek tanitiyor.
///
/// Scratch ve mBlock'un acilisi tek blokluk bir mini etkinlik; Arduino'da
/// cocuk once MALZEMEYI tanimali: Uno nedir, breadboard ne ise yarar,
/// LED/direnc/kablo, girisler (sensorler), cikislar (buzzer, servo),
/// kodun mBlock bloklariyla yazilmasi. Her slaytta Devi konusuyor,
/// ortada gercek devre cizimi (dersteki ve atolyedekiyle ayni) canli:
/// LED yanip sonuyor, breadboard'un bagli seritleri yaniyor, servo
/// donuyor. Son slayt modulleri sayiyor ve ilk derse goturuyor.
class ArduinoTanitimEkrani extends StatefulWidget {
  const ArduinoTanitimEkrani({super.key, required this.course, this.tekrar = false});

  final Course course;
  final bool tekrar;

  static const int slaytSayisi = 8;

  @override
  State<ArduinoTanitimEkrani> createState() => ArduinoTanitimEkraniState();
}

class ArduinoTanitimEkraniState extends State<ArduinoTanitimEkrani>
    with SingleTickerProviderStateMixin {
  final PageController _sayfa = PageController();
  late final AnimationController _zaman =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  final UnoKarti _kart = UnoKarti();
  late final DevreSimulasyonu _sim = DevreSimulasyonu(kart: _kart, ses: false);
  final _yazi = GlobalKey<DaktiloYaziState>();
  int _i = 0;
  bool _bitti = false;

  int get slayt => _i;

  Color get _renk => widget.course.primaryColor;
  Color get _renk2 => widget.course.secondaryColor;

  @override
  void initState() {
    super.initState();
    _zaman.addListener(_canlandir);
    _slaytaHazirla(0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _zaman.stop();
      _zaman.value = 0.25;
    } else if (!_zaman.isAnimating) {
      _zaman.repeat();
    }
  }

  @override
  void dispose() {
    _zaman.dispose();
    _sayfa.dispose();
    _sim.dispose();
    _kart.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Devreler
  // ------------------------------------------------------------------

  static final Devre _ledDevresi = Devre(
    parcalar: DevreKalibi.led('L1', 12),
    kablolar: [DevreKalibi.gndKablosu, ...DevreKalibi.ledKablolari(13, 12)],
  );

  static final Devre _girisler = Devre(parcalar: [
    Parca.mesafe('M1', 'j3'),
    Parca.pot('P1', 'j9'),
    Parca.ldr('IS1', 'j14'),
    Parca.sicaklik('T1', 'j19'),
    Parca.buton('B1', 'e25'),
  ]);

  static final Devre _cikislar = Devre(parcalar: [
    ...DevreKalibi.led('L1', 12),
    ...DevreKalibi.buzzer(20),
    ...DevreKalibi.servo(),
  ], kablolar: [
    DevreKalibi.gndKablosu,
    ...DevreKalibi.ledKablolari(13, 12),
    ...DevreKalibi.buzzerKablolari(20),
    DevreKalibi.vKablosu,
    ...DevreKalibi.servoKablolari,
  ]);

  void _slaytaHazirla(int i) {
    _kart.sifirla();
    _sim.devre = switch (i) {
      0 || 3 => _ledDevresi,
      4 => _girisler,
      5 => _cikislar,
      _ => Devre.bos,
    };
    if (i == 3 || i == 6) _kart.dijitalYaz(13, true);
  }

  /// Slayta gore canli kisimlar: yanip sonen LED, donen servo, bip.
  void _canlandir() {
    final t = _zaman.value;
    switch (_i) {
      case 0:
        _kart.dijitalYaz(13, t < 0.5);
      case 5:
        _kart.dijitalYaz(13, t < 0.5);
        _kart.servoYaz(9, (90 + 80 * math.sin(t * 2 * math.pi)).round());
        _kart.tonYaz(8, t > 0.5 && t < 0.62 ? 880 : 0);
    }
  }

  // ------------------------------------------------------------------
  // Akis
  // ------------------------------------------------------------------

  void ileri() {
    if (_i >= ArduinoTanitimEkrani.slaytSayisi - 1) {
      _kapat(dersAc: true);
      return;
    }
    HapticFeedback.selectionClick();
    _sayfa.nextPage(duration: Motion.medium4, curve: Motion.emphasized);
  }

  void _degisti(int i) {
    setState(() => _i = i);
    _slaytaHazirla(i);
    if (i == ArduinoTanitimEkrani.slaytSayisi - 1) SoundService.playOdul();
  }

  Future<void> _kapat({required bool dersAc}) async {
    if (_bitti) return;
    _bitti = true;
    if (!widget.tekrar) await KursTanitimDeposu.acilisIsaretle(widget.course.id);
    if (!mounted) return;
    Navigator.of(context).pop(dersAc && !widget.tekrar);
  }

  String _t(String lang, String tr, String en, String de, String es) => tanitimMetni(lang, tr, en, de, es);

  String _balon(String lang) => switch (_i) {
        0 => _t(lang,
            'Merhaba, ben Devi! Bu kursta gerçek bir Arduino ile ışık yakacak, sensör okuyacak ve motor döndüreceğiz. Önce malzemeleri tanıyalım!',
            "Hi, I'm Devi! In this course we'll light LEDs, read sensors and turn motors with a real Arduino. First, let's meet the parts!",
            'Hallo, ich bin Devi! In diesem Kurs lassen wir mit einem echten Arduino LEDs leuchten, lesen Sensoren und drehen Motoren. Lernen wir zuerst die Teile kennen!',
            '¡Hola, soy Devi! En este curso encenderemos luces, leeremos sensores y moveremos motores con un Arduino de verdad. ¡Primero conozcamos las piezas!'),
        1 => _t(lang,
            'Bu Arduino Uno: küçük bir bilgisayar. Yazdığın programı çalıştırır, pinleriyle parçalara bağlanır.',
            'This is the Arduino Uno, a tiny computer. It runs your program and connects to parts through its pins.',
            'Das ist der Arduino Uno, ein winziger Computer. Er führt dein Programm aus und verbindet sich über seine Pins mit Bauteilen.',
            'Este es el Arduino Uno, un ordenador diminuto. Ejecuta tu programa y se conecta a las piezas con sus pines.'),
        2 => _t(lang,
            'Breadboard parçaları lehimsiz birleştirir. Aynı sütundaki 5 delik birbirine bağlıdır; + ve − hatları boydan boya.',
            'A breadboard joins parts without soldering. The 5 holes in a column are connected; the + and − rails run end to end.',
            'Ein Steckbrett verbindet Bauteile ohne Löten. Die 5 Löcher einer Spalte sind verbunden; die + und − Schienen laufen durch.',
            'La placa de pruebas une piezas sin soldar. Los 5 agujeros de una columna están conectados; las líneas + y − van de punta a punta.'),
        3 => _t(lang,
            'LED ışık verir, direnç onu korur, kablolar parçaları Uno\'ya bağlar. Elektrik pinden çıkar, GND\'ye döner.',
            'The LED gives light, the resistor protects it and wires connect the parts to the Uno. Power leaves the pin and returns to GND.',
            'Die LED leuchtet, der Widerstand schützt sie, Kabel verbinden die Teile mit dem Uno. Strom fließt vom Pin zurück zu GND.',
            'El LED da luz, la resistencia lo protege y los cables unen las piezas al Uno. La corriente sale del pin y vuelve a GND.'),
        4 => _t(lang,
            'Sensörler kartın gözü kulağıdır: düğmeye basıldı mı, ortam ne kadar aydınlık, ne kadar sıcak, engel ne kadar uzak?',
            'Sensors are the board\'s eyes and ears: is the button pressed, how bright or warm is it, how far is that obstacle?',
            'Sensoren sind Augen und Ohren der Platine: Ist der Taster gedrückt, wie hell oder warm ist es, wie weit ist das Hindernis?',
            'Los sensores son los ojos y oídos de la placa: ¿está pulsado el botón, cuánta luz o calor hay, a qué distancia está el obstáculo?'),
        5 => _t(lang,
            'LED, buzzer ve servo motor kartın sesi ve kollarıdır: ışık yakar, ses çıkarır, döner.',
            'The LED, buzzer and servo motor are the board\'s voice and arms: they light up, beep and turn.',
            'LED, Summer und Servomotor sind Stimme und Arme der Platine: Sie leuchten, piepen und drehen sich.',
            'El LED, el zumbador y el servomotor son la voz y los brazos de la placa: iluminan, pitan y giran.'),
        6 => _t(lang,
            'Kodu mBlock bloklarıyla yazacağız. Her program sarı başlangıç bloğuyla başlar; mavi blok pin 13\'ü yakar.',
            'We\'ll write the code with mBlock blocks. Every program starts with the yellow start block; the blue block turns on pin 13.',
            'Den Code bauen wir mit mBlock-Blöcken. Jedes Programm beginnt mit dem gelben Startblock; der blaue Block schaltet Pin 13 ein.',
            'Programaremos con bloques de mBlock. Todo programa empieza con el bloque amarillo de inicio; el azul enciende el pin 13.'),
        _ => _t(lang,
            'Her derste önce devreyi breadboard\'da kurar, sonra kodlar ve çalıştırırsın. Hazırsan ilk derse geçelim!',
            'In every lesson you first build the circuit on the breadboard, then code it and run it. Ready? Let\'s start the first lesson!',
            'In jeder Lektion baust du zuerst die Schaltung, dann programmierst und startest du sie. Bereit? Auf zur ersten Lektion!',
            'En cada lección primero montas el circuito y luego lo programas y lo ejecutas. ¿Listo? ¡Vamos a la primera lección!'),
      };

  // ------------------------------------------------------------------
  // Ekran
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final kisa = MediaQuery.sizeOf(context).height < 680;
    final son = _i == ArduinoTanitimEkrani.slaytSayisi - 1;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _renk,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.alphaBlend(Colors.black.withValues(alpha: 0.06), _renk), _renk2],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                const SizedBox(height: 8),
                _ustCubuk(lang),
                SizedBox(height: kisa ? 6 : 12),
                SizedBox(
                  height: kisa ? 96 : 112,
                  child: Row(children: [
                    Mascot(size: kisa ? 70 : 86, mood: son ? MascotMood.happy : MascotMood.idle, showShadow: false),
                    const SizedBox(width: 6),
                    Expanded(
                      child: DeviBalonu(
                        key: const ValueKey('arduino_tanitim_balon'),
                        metin: _balon(lang),
                        vurgu: _renk,
                        yaziAnahtari: _yazi,
                        onTap: () => _yazi.currentState?.tamamla(),
                      ),
                    ),
                  ]),
                ),
                SizedBox(height: kisa ? 8 : 14),
                Expanded(
                  child: PageView.builder(
                    key: const ValueKey('arduino_tanitim_sayfalar'),
                    controller: _sayfa,
                    itemCount: ArduinoTanitimEkrani.slaytSayisi,
                    onPageChanged: _degisti,
                    itemBuilder: (context, i) => _slaytKarti(i, lang),
                  ),
                ),
                SizedBox(height: kisa ? 10 : 14),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('arduino_tanitim_ileri'),
                    onPressed: ileri,
                    icon: Icon(son ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded),
                    label: Text(
                      son
                          ? _t(lang, 'İlk derse başla', 'Start the first lesson', 'Erste Lektion starten', 'Empezar la primera lección')
                          : _t(lang, 'Devam', 'Next', 'Weiter', 'Siguiente'),
                      style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _renk,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
                SizedBox(height: kisa ? 10 : 14),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ustCubuk(String lang) {
    return SizedBox(
      height: 40,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < ArduinoTanitimEkrani.slaytSayisi; i++)
                AnimatedContainer(
                  duration: Motion.medium2,
                  margin: const EdgeInsets.only(right: 6),
                  width: i == _i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: i <= _i ? 0.95 : 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ]),
          ),
        ),
        const SizedBox(width: 12),
        AtlaDugmesi(
          etiket: _t(lang, 'Atla', 'Skip', 'Überspringen', 'Saltar'),
          onTap: () => _kapat(dersAc: true),
        ),
      ]),
    );
  }

  /// Slaytin ortadaki karti.
  Widget _slaytKarti(int i, String lang) {
    final Widget icerik = switch (i) {
      0 => _resim(Rect.fromLTWH(0, 0, DevreDunyasi.bbW, DevreDunyasi.bbY + DevreDunyasi.bbH + 0.4)),
      1 => _unoSlayti(lang),
      2 => _maddeli(
          _resim(const Rect.fromLTWH(-0.3, DevreDunyasi.bbY - 0.4, DevreDunyasi.bbW + 0.6, DevreDunyasi.bbH + 0.8),
              ust: (d) => _BreadboardVurgusu(_zaman)),
          [
            (Icons.view_column_rounded, _t(lang, 'Bir sütundaki 5 delik bağlı', 'The 5 holes of a column are joined', 'Die 5 Löcher einer Spalte sind verbunden', 'Los 5 agujeros de una columna están unidos')),
            (Icons.horizontal_rule_rounded, _t(lang, 'Ortadaki kanal iki yarıyı ayırır', 'The middle channel splits the halves', 'Der Mittelkanal trennt die Hälften', 'El canal central separa las mitades')),
            (Icons.power_rounded, _t(lang, '+ ve − hatları boydan boya bağlı', 'The + and − rails run end to end', 'Die + und − Schienen laufen durch', 'Las líneas + y − van de punta a punta')),
          ]),
      3 => _maddeli(_resim(const Rect.fromLTWH(3, DevreDunyasi.bbY - 6.5, 22, 17),
          ust: (d) => _Etiketler(_zaman, [
                (_t(lang, 'kablo', 'wire', 'Kabel', 'cable'), const Offset(7.6, DevreDunyasi.bbY - 2.2)),
                (_t(lang, 'direnç', 'resistor', 'Widerstand', 'resistencia'), const Offset(11.6, DevreDunyasi.bbY + 2.3)),
                ('LED', const Offset(13.6, DevreDunyasi.bbY + 7.6)),
                ('GND', const Offset(21.0, DevreDunyasi.bbY - 1.6)),
              ])),
          [
            (Icons.lightbulb_rounded, _t(lang, 'LED: uzun bacak +, kısa bacak −', 'LED: long leg +, short leg −', 'LED: langes Bein +, kurzes Bein −', 'LED: pata larga +, pata corta −')),
            (Icons.shield_rounded, _t(lang, 'Direnç: fazla akımı durdurur (220Ω)', 'Resistor: stops too much current (220Ω)', 'Widerstand: bremst zu viel Strom (220Ω)', 'Resistencia: frena el exceso de corriente (220Ω)')),
            (Icons.cable_rounded, _t(lang, 'Kablo: pini parçaya bağlar', 'Wire: joins a pin to a part', 'Kabel: verbindet Pin und Bauteil', 'Cable: une un pin con una pieza')),
          ]),
      4 => _maddeli(_resim(const Rect.fromLTWH(0, DevreDunyasi.bbY - 5.4, DevreDunyasi.bbW, 18.4),
          ust: (d) => _Etiketler(_zaman, [
                (_t(lang, 'mesafe', 'distance', 'Abstand', 'distancia'), const Offset(5.6, DevreDunyasi.bbY + 9.6)),
                (_t(lang, 'düğme', 'knob', 'Drehknopf', 'mando'), const Offset(11.1, DevreDunyasi.bbY + 6.6)),
                (_t(lang, 'ışık', 'light', 'Licht', 'luz'), const Offset(16.1, DevreDunyasi.bbY + 9.6)),
                (_t(lang, 'sıcaklık', 'heat', 'Wärme', 'calor'), const Offset(21.1, DevreDunyasi.bbY + 6.6)),
                (_t(lang, 'buton', 'button', 'Taster', 'botón'), const Offset(27.1, DevreDunyasi.bbY + 12.2)),
              ])),
          [
            (Icons.radio_button_checked_rounded, _t(lang, 'Buton: basıldı mı?', 'Button: is it pressed?', 'Taster: gedrückt?', 'Botón: ¿pulsado?')),
            (Icons.tune_rounded, _t(lang, 'Potansiyometre: ne kadar çevrildi?', 'Potentiometer: how far is it turned?', 'Potentiometer: wie weit gedreht?', 'Potenciómetro: ¿cuánto se giró?')),
            (Icons.wb_sunny_rounded, _t(lang, 'Işık ve sıcaklık sensörü: ortam nasıl?', 'Light and heat sensors: what is the room like?', 'Licht- und Temperatursensor: Wie ist es im Raum?', 'Sensores de luz y calor: ¿cómo está el ambiente?')),
            (Icons.sensors_rounded, _t(lang, 'Mesafe sensörü: engel kaç cm uzakta?', 'Distance sensor: how many cm away?', 'Abstandssensor: wie viele cm entfernt?', 'Sensor de distancia: ¿a cuántos cm?')),
          ]),
      5 => _maddeli(_resim(Rect.fromLTWH(0, DevreDunyasi.bbY - 4, DevreDunyasi.bbW, DevreDunyasi.bbH + 11.5),
          ust: (d) => _Etiketler(_zaman, [
                ('LED', const Offset(13.6, DevreDunyasi.bbY + 7.6)),
                ('buzzer', const Offset(22.6, DevreDunyasi.bbY + 10.6)),
                ('servo', Offset(d.servoKutusu(0).center.dx, d.servoKutusu(0).top - 0.9)),
              ])),
          [
            (Icons.lightbulb_rounded, _t(lang, 'LED: ışık', 'LED: light', 'LED: Licht', 'LED: luz')),
            (Icons.volume_up_rounded, _t(lang, 'Buzzer: ses ve melodi', 'Buzzer: beeps and tunes', 'Summer: Töne und Melodien', 'Zumbador: pitidos y melodías')),
            (Icons.rotate_right_rounded, _t(lang, 'Servo: 0-180 derece döner', 'Servo: turns 0-180 degrees', 'Servo: dreht 0-180 Grad', 'Servo: gira de 0 a 180 grados')),
          ]),
      6 => _mblockSlayti(lang),
      _ => _yolSlayti(lang),
    };
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(12),
      child: icerik,
    );
  }

  /// Resim ustte, altinda kisa maddeler (bos kalan alani dolduruyor).
  Widget _maddeli(Widget resim, List<(IconData, String)> maddeler) {
    final kisa = MediaQuery.sizeOf(context).height < 680;
    return Column(children: [
      Expanded(child: resim),
      const SizedBox(height: 8),
      for (final m in maddeler)
        Padding(
          padding: EdgeInsets.only(top: kisa ? 3 : 6),
          child: Row(children: [
            Container(
              width: kisa ? 26 : 30,
              height: kisa ? 26 : 30,
              decoration: BoxDecoration(color: _renk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
              child: Icon(m.$1, size: kisa ? 16 : 18, color: _renk),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(m.$2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: kisa ? 13 : 14.5,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF37474F))),
            ),
          ]),
        ),
    ]);
  }

  Widget _resim(Rect kirp, {CustomPainter Function(DevreDunyasi)? ust}) => Center(
        child: AnimatedBuilder(
          animation: _sim,
          builder: (context, _) => DevreResmi(sim: _sim, kirp: kirp, ust: ust),
        ),
      );

  Widget _unoSlayti(String lang) {
    final etiketler = [
      _t(lang, 'Dijital pinler 0-13: aç ya da kapat', 'Digital pins 0-13: on or off', 'Digitalpins 0-13: an oder aus', 'Pines digitales 0-13: encender o apagar'),
      _t(lang, 'Analog pinler A0-A5: 0 ile 1023 arası okur', 'Analog pins A0-A5: read 0 to 1023', 'Analogpins A0-A5: lesen 0 bis 1023', 'Pines analógicos A0-A5: leen de 0 a 1023'),
      _t(lang, '5V ve GND: devreye elektrik verir', '5V and GND: power for the circuit', '5V und GND: Strom für die Schaltung', '5V y GND: electricidad para el circuito'),
      _t(lang, 'USB: program ve elektrik buradan gelir', 'USB: program and power come in here', 'USB: Hier kommen Programm und Strom an', 'USB: por aquí llegan el programa y la electricidad'),
      _t(lang, 'L ışığı: pin 13\'e bağlı küçük LED', 'L light: a small LED on pin 13', 'L-Licht: kleine LED an Pin 13', 'Luz L: un pequeño LED en el pin 13'),
    ];
    return Column(children: [
      Expanded(
        child: _resim(const Rect.fromLTWH(1.5, 0, 31.4, DevreDunyasi.unoH + 1.4), ust: (d) => _UnoVurgusu(_zaman)),
      ),
      const SizedBox(height: 8),
      AnimatedBuilder(
        animation: _zaman,
        builder: (context, _) {
          final k = _UnoVurgusu.sira(_zaman.value);
          return Container(
            key: const ValueKey('arduino_tanitim_uno_etiket'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFFFF3D6), borderRadius: BorderRadius.circular(14)),
            child: Text(etiketler[k],
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: AppTheme.fontFamily, fontSize: 14.5, fontWeight: FontWeight.w900, color: Color(0xFF6D4C00))),
          );
        },
      ),
    ]);
  }

  Widget _mblockSlayti(String lang) {
    final t = KursTanitimi(
      courseId: 'arduino',
      sapkaBlokId: 'dev_kart_acilis',
      yerlesecekBlokId: 'dev_dijital_yaz',
      sahne: TanitimSahnesi.kart,
    );
    return Column(children: [
      const SizedBox(height: 6),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ScratchBlok(tanim: t.sapka(lang), sigdir: false),
          ScratchBlok(tanim: t.blok(lang), sigdir: false),
        ]),
      ),
      const SizedBox(height: 10),
      Expanded(child: _resim(const Rect.fromLTWH(1.5, 0, 31.4, DevreDunyasi.unoH + 1.4))),
    ]);
  }

  Widget _yolSlayti(String lang) {
    final moduller = CourseModules.forCourse('arduino');
    return LayoutBuilder(builder: (context, c) {
      final satir = (c.maxHeight / (moduller.length + 0.6)).clamp(34.0, 56.0);
      return Column(children: [
        for (var i = 0; i < moduller.length; i++)
          SizedBox(
            height: satir,
            child: Row(children: [
              Container(
                width: satir * 0.72,
                height: satir * 0.72,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _renk.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Text('${i + 1}',
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w900, color: _renk, fontSize: 15)),
              ),
              const SizedBox(width: 10),
              Text(moduller[i].emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(moduller[i].titleFor(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: AppTheme.fontFamily, fontSize: 15.5, fontWeight: FontWeight.w900, color: Color(0xFF263238))),
              ),
            ]),
          ),
      ]);
    });
  }
}

/// Uno slaytinda sirayla yanan bolgeler: dijital pinler, analog pinler,
/// guc pinleri, USB, L isigi.
class _UnoVurgusu extends CustomPainter {
  _UnoVurgusu(this.zaman) : super(repaint: zaman);
  final Animation<double> zaman;

  /// Bes bolge, her biri 1.8 saniye (saatten: animasyon dongusu
  /// sifirlansa da sira ilerliyor).
  static int sira(double _) => (DateTime.now().millisecondsSinceEpoch ~/ 1800) % 5;

  @override
  void paint(Canvas c, Size size) {
    final k = size.width / DevreDunyasi.bbW;
    c.save();
    c.scale(k);
    const o = DevreDunyasi.unoO;
    const s = DevreDunyasi.unoS;
    Rect uno(double x, double y, double w, double h) => Rect.fromLTWH(o.dx + x * s, o.dy + y * s, w * s, h * s);
    final bolgeler = [
      uno(UnoOlcu.dijital1X - 6, UnoOlcu.ustY - 6, UnoOlcu.dijital2X + 8 * UnoOlcu.adim - UnoOlcu.dijital1X + 12, UnoOlcu.baslikH + 12),
      uno(UnoOlcu.analogX - 6, UnoOlcu.altY - 6, 6 * UnoOlcu.adim + 12, UnoOlcu.baslikH + 12),
      uno(UnoOlcu.gucX + 3 * UnoOlcu.adim - 6, UnoOlcu.altY - 6, 4 * UnoOlcu.adim + 12, UnoOlcu.baslikH + 12),
      uno(-260, 100, 370, 140),
      uno(UnoOlcu.lLedi.dx - 30, UnoOlcu.lLedi.dy - 24, 60, 48),
    ];
    final r = bolgeler[sira(zaman.value)];
    final n = 0.5 + 0.5 * math.sin(zaman.value * 5 * math.pi);
    c.drawRRect(RRect.fromRectAndRadius(r.inflate(0.25), const Radius.circular(0.5)),
        Paint()..color = const Color(0xFFFFC107).withValues(alpha: 0.22 + 0.12 * n));
    c.drawRRect(
        RRect.fromRectAndRadius(r.inflate(0.25), const Radius.circular(0.5)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.22
          ..color = const Color(0xFFFF8F00));
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _UnoVurgusu old) => false;
}

/// Breadboard slaytinda soldan saga kayan bagli serit ve nabiz atan
/// guc hatlari.
class _BreadboardVurgusu extends CustomPainter {
  _BreadboardVurgusu(this.zaman) : super(repaint: zaman);
  final Animation<double> zaman;

  @override
  void paint(Canvas c, Size size) {
    final k = size.width / DevreDunyasi.bbW;
    final t = zaman.value;
    c.save();
    c.scale(k);
    final sutun = 2 + (t * 26).floor();
    final ust = (t * 2).floor().isEven;
    final x = DevreDunyasi.sutunX(sutun);
    final y1 = DevreDunyasi.satirY(ust ? 9 : 4), y2 = DevreDunyasi.satirY(ust ? 5 : 0);
    final serit = RRect.fromRectAndRadius(Rect.fromLTRB(x - 0.45, y1 - 0.45, x + 0.45, y2 + 0.45), const Radius.circular(0.3));
    c.drawRRect(serit, Paint()..color = const Color(0xFF26A69A).withValues(alpha: 0.35));
    c.drawRRect(
        serit,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.14
          ..color = const Color(0xFF00897B));
    final n = 0.5 + 0.5 * math.sin(t * 4 * math.pi);
    for (final (u, a, renk) in [
      (true, true, const Color(0xFFE53935)),
      (true, false, const Color(0xFF1E6FD9)),
    ]) {
      final y = DevreDunyasi.rayY(u, a);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTRB(DevreDunyasi.sutunX(1) - 0.45, y - 0.38, DevreDunyasi.sutunX(30) + 0.45, y + 0.38),
              const Radius.circular(0.3)),
          Paint()..color = renk.withValues(alpha: 0.10 + 0.14 * n));
    }
    devreEtiketi(c, '5', Offset(x, ust ? y2 + 1.25 : y1 - 1.25), boy: 0.8, renk: const Color(0xFF00796B));
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _BreadboardVurgusu old) => false;
}

/// Parcalarin uzerinde ad etiketleri (hafifce nefes alarak).
class _Etiketler extends CustomPainter {
  _Etiketler(this.zaman, this.etiketler) : super(repaint: zaman);
  final Animation<double> zaman;
  final List<(String, Offset)> etiketler;

  @override
  void paint(Canvas c, Size size) {
    final k = size.width / DevreDunyasi.bbW;
    c.save();
    c.scale(k);
    for (var i = 0; i < etiketler.length; i++) {
      final d = math.sin((zaman.value + i * 0.17) * 2 * math.pi) * 0.12;
      devreEtiketi(c, etiketler[i].$1, etiketler[i].$2 + Offset(0, d), boy: 0.95);
    }
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _Etiketler old) => false;
}
