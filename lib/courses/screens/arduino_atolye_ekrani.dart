import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/sound_service.dart';
import '../../theme.dart';
import '../devre/arduino_projeleri.dart';
import '../devre/devre_duzenleyici.dart';
import '../devre/devre_metinleri.dart';
import '../devre/devre_modeli.dart';
import '../devre/devre_paneli.dart';
import '../devre/devre_simulasyonu.dart';
import '../models/course_model.dart';
import '../yurutme/mblock_blok_adlari.dart';
import '../yurutme/mblock_cozum.dart';
import '../yurutme/mblock_uno.dart';
import 'widgets/mblock_atolye_tezgahi.dart';
import 'widgets/step_widgets.dart' show lessonLang, lessonLangRead;

/// ARDUINO ATOLYESI — Uno, breadboard, parcalar ve mBlock bloklari.
///
/// Iki yol (girisde secilir, ust cubuktan degistirilir):
///  * SERBEST: bos breadboard. Parca ekle, kablo tak, kodla, calistir.
///    Devre ve kod cihazda saklanir; geri gelince kaldigin yerde.
///  * REHBERLI PROJE: parcalar yerinde, cocuk kablolari adim adim takar
///    (her adimda iki uc yanip soner). Devre tamamlaninca kod sekmesi;
///    istenirse ornek kod yuklenir. Tamamlanan projeler isaretlenir.
///
/// Iki sekme: DEVRE (buyuk duzenleyici) ve KOD (kucuk canli sahne +
/// mBlock tezgahi). Program iki sekmede de calisiyor; calisirken devre
/// kilitli, butonlara basilabiliyor.
class ArduinoAtolyeEkrani extends StatefulWidget {
  const ArduinoAtolyeEkrani({super.key, required this.course});

  final Course course;

  /// Arduino kodlamasinin bloklari (kukla bloklari yok).
  static const List<String> bloklar = [
    'dev_kart_acilis',
    'dev_surekli',
    'dev_tekrarla',
    'dev_bekle',
    'dev_eger',
    'dev_bekle_kadar',
    'dev_dijital_yaz',
    'dev_pwm_yaz',
    'dev_dijital_oku',
    'dev_analog_oku',
    'dev_servo',
    'dev_ton',
    'dev_seri_yaz',
    'dev_mesafe',
    'dev_sicaklik',
    'dev_harita',
    'dev_degil',
    'dev_kucuktur',
    'dev_buyuktur',
    'dev_degisken_yap',
    'dev_degisken_degistir',
    'dev_degisken_oku',
    'dev_sayac_oku',
    'dev_aci_oku',
  ];

  static const String devreAnahtari = 'arduino_atolye_devre_v1';
  static const String kodAnahtari = 'arduino_atolye_kod_v1';
  static const String bitenlerAnahtari = 'arduino_atolye_bitenler_v1';

  @override
  State<ArduinoAtolyeEkrani> createState() => ArduinoAtolyeEkraniState();
}

class ArduinoAtolyeEkraniState extends State<ArduinoAtolyeEkrani> {
  final UnoKarti _kart = UnoKarti();
  late final DevreSimulasyonu _sim = DevreSimulasyonu(kart: _kart);
  final GlobalKey<MBlockAtolyeTezgahiState> _tezgah = GlobalKey();

  /// null: secim ekrani; 'serbest' ya da proje kimligi.
  String? _kip;
  ArduinoProjesi? _proje;
  bool _devreTamam = false;
  int _sekme = 0;
  int _surum = 0;

  List<List<MBlockBlok>> _kod = const [];
  bool _calisiyor = false;
  UnoYorumlayici? _uno;
  UnoBitis? _bitis;
  MBlockBlok? _calisanBlok;
  Timer? _blokYazisi;

  Set<String> _bitenler = {};
  bool _kayitliVar = false;
  Timer? _kayit;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void dispose() {
    _uno?.durdur();
    _blokYazisi?.cancel();
    _kayit?.cancel();
    _sim.dispose();
    _kart.dispose();
    super.dispose();
  }

  Future<void> _yukle() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _bitenler = (p.getStringList(ArduinoAtolyeEkrani.bitenlerAnahtari) ?? const []).toSet();
        _kayitliVar = (p.getString(ArduinoAtolyeEkrani.devreAnahtari) ?? '').length > 30;
      });
    } catch (_) {}
  }

  /// Olay isleyicilerinde de kullaniliyor: dinlemeden oku (build
  /// [lessonLang] ile bagimlilik kuruyor).
  String get _lang => lessonLangRead(context);
  String _t(String tr, String en, String de, String es) => devreT(_lang, tr, en, de, es);

  // ------------------------------------------------------------------
  // Kip secimi
  // ------------------------------------------------------------------

  Future<void> serbestAc() async {
    _durdur();
    var devre = Devre.bos;
    var kod = const <List<MBlockBlok>>[];
    try {
      final p = await SharedPreferences.getInstance();
      devre = Devre.coz(p.getString(ArduinoAtolyeEkrani.devreAnahtari) ?? '');
      kod = MBlockBlok.yiginlarCoz(p.getString(ArduinoAtolyeEkrani.kodAnahtari) ?? '');
    } catch (_) {}
    if (!mounted) return;
    _kart.sifirla();
    _sim.devre = devre;
    setState(() {
      _kip = 'serbest';
      _proje = null;
      _sekme = 0;
      _kod = kod;
      _bitis = null;
      _surum++;
    });
    _tezgahaYukle(kod);
  }

  void projeAc(ArduinoProjesi p) {
    _durdur();
    _kart.sifirla();
    _sim.devre = p.baslangic;
    setState(() {
      _kip = p.id;
      _proje = p;
      _devreTamam = false;
      _sekme = 0;
      _kod = const [];
      _bitis = null;
      _surum++;
    });
    _tezgahaYukle(const []);
  }

  void _tezgahaYukle(List<List<MBlockBlok>> kod) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final t = _tezgah.currentState;
      if (t == null) return;
      if (kod.isEmpty) {
        t.temizle();
      } else {
        t.yukle(kod);
      }
    });
  }

  void _secimeDon() {
    _durdur();
    _kaydetHemen();
    setState(() {
      _kip = null;
      _proje = null;
    });
    _yukle();
  }

  // ------------------------------------------------------------------
  // Kayit
  // ------------------------------------------------------------------

  void _kaydet() {
    if (_kip != 'serbest') return;
    _kayit?.cancel();
    _kayit = Timer(const Duration(milliseconds: 600), _kaydetHemen);
  }

  Future<void> _kaydetHemen() async {
    _kayit?.cancel();
    if (_kip != 'serbest') return;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(ArduinoAtolyeEkrani.devreAnahtari, _sim.devre.kodla());
      await p.setString(ArduinoAtolyeEkrani.kodAnahtari, MBlockBlok.yiginlarKodla(_kod));
    } catch (_) {}
  }

  Future<void> _projeBitti() async {
    final p = _proje;
    if (p == null) return;
    _bitenler.add(p.id);
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setStringList(ArduinoAtolyeEkrani.bitenlerAnahtari, _bitenler.toList());
    } catch (_) {}
  }

  // ------------------------------------------------------------------
  // Calistirma
  // ------------------------------------------------------------------

  bool get _kodVar => _kod.any((y) => y.isNotEmpty);

  bool get _seriVar {
    bool ara(MBlockBlok b) =>
        b.tip == 'dev_seri_yaz' || b.icerik.any(ara) || b.girdiler.values.any(ara);
    return _kod.any((y) => y.any(ara));
  }

  bool get calisiyor => _calisiyor;

  Future<void> calistir() async {
    if (!_kodVar) return;
    HapticFeedback.lightImpact();
    _uno?.durdur();
    final y = UnoYorumlayici(
      kart: _kart,
      butce: 8000,
      onBlok: (b) => _calisanBlok = b,
    );
    _uno = y;
    _calismaDurumu(true);
    setState(() => _bitis = null);
    _blokYazisi?.cancel();
    _blokYazisi = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && _calisiyor) setState(() {});
    });
    final bitis = await y.calistir(_kod);
    if (!mounted || !identical(_uno, y)) return;
    _blokYazisi?.cancel();
    if (bitis == UnoBitis.durduruldu || bitis == UnoBitis.butceBitti) _kart.sifirla();
    _sim.sustur();
    _calismaDurumu(false);
    setState(() {
      _bitis = bitis;
      _calisanBlok = null;
    });
  }

  void _durdur() {
    _uno?.durdur();
  }

  void _calismaDurumu(bool c) {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _calismaDurumu(c));
      return;
    }
    setState(() => _calisiyor = c);
  }

  // ------------------------------------------------------------------
  // Ekran
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    lessonLang(context);
    final renk = widget.course.primaryColor;
    final koyu = Theme.of(context).brightness == Brightness.dark;
    final p = _proje;
    return Scaffold(
      backgroundColor: koyu ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: renk,
        foregroundColor: Colors.white,
        title: Text(
          _kip == null
              ? _t('Arduino Atölyesi', 'Arduino Workshop', 'Arduino-Werkstatt', 'Taller de Arduino')
              : (p?.adFor(_lang) ?? _t('Serbest çalışma', 'Free build', 'Freies Bauen', 'Construcción libre')),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_kip != null)
            IconButton(
              key: const ValueKey('arduino_atolye_projeler'),
              tooltip: _t('Projeler', 'Projects', 'Projekte', 'Proyectos'),
              icon: const Icon(Icons.apps_rounded),
              onPressed: _secimeDon,
            ),
        ],
      ),
      body: _kip == null ? _secimEkrani(renk, koyu) : _calismaAlani(renk, koyu),
    );
  }

  // ---------------------------------------------------------- secim

  Widget _secimEkrani(Color renk, bool koyu) {
    final kart = koyu ? const Color(0xFF1E1E2E) : Colors.white;
    final yazi = koyu ? Colors.white : const Color(0xFF263238);
    return ListView(
      key: const ValueKey('arduino_atolye_secim'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Material(
          color: renk,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            key: const ValueKey('arduino_atolye_serbest'),
            borderRadius: BorderRadius.circular(22),
            onTap: serbestAc,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.developer_board_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_t('Serbest çalış', 'Free build', 'Frei bauen', 'Construcción libre'),
                        style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                        _kayitliVar
                            ? _t('Kaldığın yerden devam et: devren ve kodun kayıtlı.',
                                'Pick up where you left off: your circuit and code are saved.',
                                'Mach weiter, wo du warst: Schaltung und Code sind gespeichert.',
                                'Sigue donde lo dejaste: tu circuito y tu código están guardados.')
                            : _t('Boş breadboard: parçalarını koy, kablolarını tak, kodunu yaz.',
                                'An empty breadboard: place parts, plug in wires, write your code.',
                                'Leeres Steckbrett: Bauteile setzen, Kabel stecken, Code schreiben.',
                                'Placa vacía: coloca piezas, conecta cables y escribe tu código.'),
                        style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13.5,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.92))),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(_t('Rehberli projeler', 'Guided projects', 'Geführte Projekte', 'Proyectos guiados'),
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w900, color: yazi)),
        const SizedBox(height: 4),
        Text(
            _t('Parçalar hazır; kabloları adım adım takarsın, sonra kodlarsın.',
                'The parts are ready; you plug in the wires step by step, then code it.',
                'Die Bauteile stehen bereit; du steckst die Kabel Schritt für Schritt und programmierst dann.',
                'Las piezas ya están; conectas los cables paso a paso y luego programas.'),
            style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: yazi.withValues(alpha: 0.7))),
        const SizedBox(height: 10),
        for (final p in arduinoProjeleri)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: kart,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                key: ValueKey('arduino_proje_${p.id}'),
                borderRadius: BorderRadius.circular(18),
                onTap: () => projeAc(p),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: renk.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_projeSimgesi(p.id), color: renk),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Flexible(
                            child: Text(p.adFor(_lang),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w900,
                                    color: yazi)),
                          ),
                          const SizedBox(width: 6),
                          for (var i = 0; i < 3; i++)
                            Icon(Icons.star_rounded,
                                size: 15,
                                color: i < p.zorluk ? const Color(0xFFFFB300) : yazi.withValues(alpha: 0.15)),
                        ]),
                        const SizedBox(height: 3),
                        Text(p.hedefFor(_lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12.5,
                                height: 1.25,
                                fontWeight: FontWeight.w600,
                                color: yazi.withValues(alpha: 0.7))),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    _bitenler.contains(p.id)
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32))
                        : Icon(Icons.chevron_right_rounded, color: yazi.withValues(alpha: 0.4)),
                  ]),
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _projeSimgesi(String id) => switch (id) {
        'led_yak' => Icons.lightbulb_rounded,
        'trafik' => Icons.traffic_rounded,
        'buton_led' => Icons.radio_button_checked_rounded,
        'pot_parlaklik' => Icons.tune_rounded,
        'gece_lambasi' => Icons.nightlight_round,
        'termometre' => Icons.thermostat_rounded,
        'park_sensoru' => Icons.sensors_rounded,
        'bariyer' => Icons.toll_rounded,
        _ => Icons.memory_rounded,
      };

  // ---------------------------------------------------------- calisma

  Widget _calismaAlani(Color renk, bool koyu) {
    final mq = MediaQuery.sizeOf(context);
    final kisa = mq.height < 700;
    final p = _proje;
    final rehberli = p != null && !_devreTamam;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        child: Row(children: [
          Expanded(child: _sekmeler(renk)),
          const SizedBox(width: 10),
          _calistirDugmesi(),
        ]),
      ),
      Expanded(
        child: SingleChildScrollView(
          key: const ValueKey('arduino_atolye_sayfasi'),
          padding: EdgeInsets.fromLTRB(kisa ? 10 : 14, 4, kisa ? 10 : 14, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (p != null) _projeKarti(p, renk),
            if (_sekme == 0)
              DevreDuzenleyici(
                key: ValueKey('devre_${_kip}_${_surum}_${rehberli ? 'r' : 's'}'),
                sim: _sim,
                lang: _lang,
                renk: renk,
                kip: rehberli ? DevreKipi.rehberli : DevreKipi.serbest,
                hedefler: rehberli ? p.hedefler : const [],
                kilitli: _calisiyor,
                yukseklik: (mq.height * 0.5).clamp(280.0, 470.0),
                onDegisti: (_) {
                  setState(() {});
                  _kaydet();
                },
                onHedeflerTamam: _devreKuruldu,
              )
            else
              DevreDuzenleyici(
                key: ValueKey('devre_izle_${_kip}_$_surum'),
                sim: _sim,
                lang: _lang,
                renk: renk,
                kip: DevreKipi.izle,
                kilitli: _calisiyor,
                yukseklik: kisa ? 200 : 240,
              ),
            if (_calisiyor || _bitis != null) _durumSeridi(),
            DevreUyariSeridi(sim: _sim, lang: _lang),
            DevreGirdiPaneli(sim: _sim, lang: _lang, seriGoster: _seriVar),
            Offstage(
              offstage: _sekme != 1,
              child: TickerMode(
                enabled: _sekme == 1,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const SizedBox(height: 12),
                  MBlockAtolyeTezgahi(
                    key: _tezgah,
                    lang: _lang,
                    bloklar: ArduinoAtolyeEkrani.bloklar,
                    renk: renk,
                    calisiyor: _calisiyor,
                    ustunde: (kisa ? 200 : 240) + 130,
                    onDegisti: (y) {
                      setState(() => _kod = y);
                      _kaydet();
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const ValueKey('arduino_kod_temizle'),
                        onPressed: !_kodVar
                            ? null
                            : () {
                                _durdur();
                                _tezgah.currentState?.temizle();
                              },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(_t('Kodu temizle', 'Clear code', 'Code leeren', 'Borrar código'),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    if (p != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('arduino_ornek_kod'),
                          onPressed: () => _ornekKod(p),
                          icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                          label: Text(_t('Örnek kod', 'Sample code', 'Beispielcode', 'Código de ejemplo'),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _sekmeler(Color renk) {
    Widget sekme(int i, IconData ikon, String ad) {
      final secili = _sekme == i;
      return Expanded(
        child: GestureDetector(
          key: ValueKey('arduino_sekme_$i'),
          onTap: () {
            if (_sekme == i) return;
            HapticFeedback.selectionClick();
            setState(() => _sekme = i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 44,
            decoration: BoxDecoration(
              color: secili ? renk : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(ikon, size: 18, color: secili ? Colors.white : const Color(0xFF546E7A)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(ad,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: secili ? Colors.white : const Color(0xFF546E7A))),
              ),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        sekme(0, Icons.cable_rounded, _t('Devre', 'Circuit', 'Schaltung', 'Circuito')),
        sekme(1, Icons.extension_rounded, _t('Kod', 'Code', 'Code', 'Código')),
      ]),
    );
  }

  Widget _calistirDugmesi() {
    final c = _calisiyor;
    return SizedBox(
      height: 50,
      child: FilledButton.icon(
        key: const ValueKey('arduino_calistir'),
        onPressed: c ? _durdur : (_kodVar ? calistir : () => _kodYokUyarisi()),
        icon: Icon(c ? Icons.stop_rounded : Icons.flag_rounded),
        label: Text(c ? _t('Durdur', 'Stop', 'Stopp', 'Detener') : _t('Çalıştır', 'Run', 'Starten', 'Ejecutar'),
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w900)),
        style: FilledButton.styleFrom(
          backgroundColor: c ? const Color(0xFFEC5959) : const Color(0xFF4CBF56),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _kodYokUyarisi() {
    HapticFeedback.selectionClick();
    setState(() => _sekme = 1);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(_t(
            'Önce kod yaz: "${mblockBlokAdi('dev_kart_acilis', 'tr')}" bloğuyla başla.',
            'Write some code first: start with "${mblockBlokAdi('dev_kart_acilis', 'en')}".',
            'Schreib zuerst Code: fang mit „${mblockBlokAdi('dev_kart_acilis', 'de')}“ an.',
            'Primero escribe código: empieza con «${mblockBlokAdi('dev_kart_acilis', 'es')}».')),
        duration: const Duration(seconds: 3),
      ));
  }

  Widget _projeKarti(ArduinoProjesi p, Color renk) {
    final hedefler = p.hedefler;
    final tamam = hedefDurumu(_sim.devre, hedefler).where((x) => x).length;
    final String baslik;
    final String metin;
    if (!_devreTamam) {
      final sirada = hedefler.where((h) => !h.tamamMi(DevreDugumleri.kur(_sim.devre))).firstOrNull;
      baslik = _t('Devreyi kur · $tamam/${hedefler.length}', 'Build the circuit · $tamam/${hedefler.length}',
          'Schaltung bauen · $tamam/${hedefler.length}', 'Monta el circuito · $tamam/${hedefler.length}');
      metin = sirada?.metin(_lang) ?? '';
    } else {
      baslik = _t('Şimdi kodla', 'Now code it', 'Jetzt programmieren', 'Ahora prográmalo');
      metin = p.hedefFor(_lang);
    }
    return Container(
      key: const ValueKey('arduino_proje_karti'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _devreTamam ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _devreTamam ? const Color(0xFFA5D6A7) : const Color(0xFFFFE082)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(_devreTamam ? Icons.check_circle_rounded : Icons.cable_rounded,
              size: 18, color: _devreTamam ? const Color(0xFF2E7D32) : const Color(0xFFB26A00)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(baslik,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _devreTamam ? const Color(0xFF1B5E20) : const Color(0xFF6D4C00))),
          ),
          if (!_devreTamam)
            SizedBox(
              width: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: hedefler.isEmpty ? 0 : tamam / hedefler.length,
                  minHeight: 6,
                  backgroundColor: Colors.white,
                  color: const Color(0xFFFFB300),
                ),
              ),
            ),
        ]),
        if (metin.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(metin,
              style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF37474F))),
        ],
      ]),
    );
  }

  void _devreKuruldu() {
    SoundService.playLevelComplete();
    HapticFeedback.mediumImpact();
    _projeBitti();
    setState(() {
      _devreTamam = true;
      _sekme = 1;
      _surum++;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(_t('Devre tamam! Şimdi kodunu yaz ve çalıştır.', 'Circuit done! Now write your code and run it.',
            'Schaltung fertig! Jetzt Code schreiben und starten.', '¡Circuito listo! Ahora escribe tu código y ejecútalo.')),
        duration: const Duration(seconds: 3),
      ));
    // Sekme degisince tezgah ayni kaliyor (Offstage); kodu koru.
    _tezgahaYukle(_kod);
  }

  Future<void> _ornekKod(ArduinoProjesi p) async {
    if (_kodVar) {
      final evet = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(_t('Örnek kod yüklensin mi?', 'Load the sample code?', 'Beispielcode laden?', '¿Cargar el código de ejemplo?')),
          content: Text(_t('Tezgahtaki kodun yerine geçecek.', 'It will replace the code on your workbench.',
              'Er ersetzt deinen Code.', 'Reemplazará tu código.')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(_t('Vazgeç', 'Cancel', 'Abbrechen', 'Cancelar'))),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(_t('Yükle', 'Load', 'Laden', 'Cargar'))),
          ],
        ),
      );
      if (evet != true || !mounted) return;
    }
    _tezgah.currentState?.yukle([mblockCozumProgrami(p.kod, _lang)]);
  }

  Widget _durumSeridi() {
    final String metin;
    final Color renk;
    final IconData ikon;
    if (_calisiyor) {
      final b = _calisanBlok;
      metin = b == null ? _t('Çalışıyor…', 'Running…', 'Läuft…', 'Ejecutando…') : mblockBlokYazisi(b, _lang);
      renk = const Color(0xFF00878F);
      ikon = Icons.play_circle_fill_rounded;
    } else {
      switch (_bitis) {
        case UnoBitis.baslangicYok:
          metin = _t('Kart, "${mblockBlokAdi('dev_kart_acilis', 'tr')}" bloğuyla başlar.',
              'The board starts with "${mblockBlokAdi('dev_kart_acilis', 'en')}".',
              'Die Platine startet mit „${mblockBlokAdi('dev_kart_acilis', 'de')}“.',
              'La placa empieza con «${mblockBlokAdi('dev_kart_acilis', 'es')}».');
          renk = const Color(0xFF3D5A80);
          ikon = Icons.info_rounded;
        case UnoBitis.butceBitti:
          metin = _t('Bu kod hiç durmuyor; bir süre sonra biz durdurduk.',
              'This code never stops; we paused it after a while.',
              'Dieser Code hört nie auf; wir haben ihn angehalten.',
              'Este código no para nunca; lo pausamos tras un rato.');
          renk = const Color(0xFFB26A00);
          ikon = Icons.all_inclusive_rounded;
        case UnoBitis.durduruldu:
          metin = _t('Kodu durdurdun.', 'You stopped the code.', 'Du hast den Code gestoppt.', 'Detuviste el código.');
          renk = const Color(0xFFB84848);
          ikon = Icons.stop_circle_rounded;
        default:
          metin = _t('Program bitti. Kart son hâlinde kaldı.', 'The program finished. The board keeps its last state.',
              'Das Programm ist fertig. Die Platine bleibt so.', 'El programa terminó. La placa se queda así.');
          renk = const Color(0xFF2E7D32);
          ikon = Icons.check_circle_rounded;
      }
    }
    return Container(
      key: const ValueKey('arduino_durum'),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(ikon, size: 17, color: renk),
        const SizedBox(width: 6),
        Expanded(
          child: Text(metin,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12.5, fontWeight: FontWeight.w800, color: renk)),
        ),
      ]),
    );
  }
}
