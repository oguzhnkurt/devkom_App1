import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/sound_service.dart';
import '../../theme.dart';
import 'devre_cizimi.dart';
import 'devre_metinleri.dart';
import 'devre_modeli.dart';
import 'devre_simulasyonu.dart';
import 'devre_yerlesim.dart';

/// Duzenleyicinin calisma bicimi.
enum DevreKipi {
  /// Serbest atolye: parca ekle/tasi/dondur/sil, kablo tak/sok.
  serbest,

  /// Rehberli kurulum: parcalar yerinde ve kilitli; cocuk hedef
  /// kablolari takiyor. Hedefe uymayan kablo kabul edilmiyor.
  rehberli,

  /// Yalnizca izle (ders kod adiminin sahnesi): yakinlastir, butona bas.
  izle,
}

/// SANAL DEVRE DUZENLEYICISI — Tinkercad'deki gibi breadboard'a parca
/// koyup kablo cekmek, telefonda.
///
/// TELEFONDA KABLOLAMA
/// -------------------
/// Eski Arduino simulatoru (2.400 satir) parmakla kablo SURUKLETIYORDU
/// ve 20x12 piksellik pinlere isabet ettirmek mumkun degildi. Burada:
///  * Kablo DOKUN-DOKUN takiliyor: once bir uca, sonra digerine. Arada
///    parmak surukleme yok; iki parmakla yakinlastirma serbest.
///  * Uzaktan bakarken (delik araligi ekranda 16 pikselden kucukken) bir
///    deliğe dokunmak once oraya YAKINLASTIRIYOR; ikinci dokunus seciyor.
///  * Secilen ucun adi ("c12 deliği", "pin 13") ust seritte yaziyor;
///    yanlis uca degdiyse ayni uca tekrar dokununca vazgeciliyor.
///  * Parca koymak: listeden sec, hayaleti gormek istedigin delige dokun
///    (ya da basili tutup surukle), "Yerleştir".
///  * Her degisiklik geri alinabiliyor.
class DevreDuzenleyici extends StatefulWidget {
  const DevreDuzenleyici({
    super.key,
    required this.sim,
    required this.lang,
    this.kip = DevreKipi.serbest,
    this.hedefler = const [],
    this.kilitli = false,
    this.yukseklik = 340,
    this.renk = const Color(0xFF00979D),
    this.onDegisti,
    this.onHedeflerTamam,
    this.onYanlis,
    this.onYardim,
  });

  final DevreSimulasyonu sim;
  final String lang;
  final DevreKipi kip;

  /// Rehberli kipte takilacak baglantilar (sirasiyla gosteriliyor ama
  /// herhangi bir sirayla takilabilir).
  final List<HedefBaglanti> hedefler;

  /// Program calisiyor: duzenleme kapali, butonlara basilabiliyor.
  final bool kilitli;

  /// Sahnenin yuksekligi.
  final double yukseklik;
  final Color renk;

  final ValueChanged<Devre>? onDegisti;
  final VoidCallback? onHedeflerTamam;

  /// Rehberli kipte kabul edilmeyen bir kablo denemesi.
  final VoidCallback? onYanlis;

  /// "Benim yerime tak" kullanildi.
  final VoidCallback? onYardim;

  /// Delik araligi ekranda bundan kucukse dokunus once yakinlastirir.
  static const double yakinlastirmaEsigi = 16;

  /// Yakinlastirinca hedeflenen delik araligi (piksel).
  static const double rahatAdim = 30;

  @override
  State<DevreDuzenleyici> createState() => DevreDuzenleyiciState();
}

class DevreDuzenleyiciState extends State<DevreDuzenleyici>
    with TickerProviderStateMixin {
  final TransformationController _tc = TransformationController();
  late final AnimationController _nabiz;
  late final AnimationController _zoom;
  Animation<Matrix4>? _zoomAnim;

  double _k0 = 10;
  Size _gorunum = Size.zero;

  String? _seciliParca;
  int? _seciliKablo;
  String? _kabloBasi;

  /// Yerlestirilen ya da tasinan parca (hayalet).
  Parca? _hayalet;
  bool _hayaletYeni = false;

  /// Uzun basip surukleyince parmak ile capa arasindaki fark (dunya).
  Offset _tutma = Offset.zero;

  final List<Devre> _geri = [];
  int _sabitKablo = 0;
  int _yanlis = 0;
  bool _tamamBildirildi = false;

  String? _not;
  bool _notHata = false;
  Timer? _notZamani;

  Devre get devre => widget.sim.devre;
  DevreDunyasi get _dunya => DevreDunyasi.icin(_hayalet?.tur == ParcaTuru.servo
      ? devre.parcaEkle(_hayalet!)
      : devre);

  /// Rehberli kipte kac yanlis deneme oldu (yardim dugmesi).
  int get yanlisSayisi => _yanlis;

  @visibleForTesting
  String? get kabloBasi => _kabloBasi;

  @visibleForTesting
  Parca? get hayalet => _hayalet;

  @visibleForTesting
  String? get seciliParca => _seciliParca;

  @override
  void initState() {
    super.initState();
    _nabiz = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _zoom = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260))
      ..addListener(() {
        final a = _zoomAnim;
        if (a != null) _tc.value = a.value;
      });
    _sabitKablo = widget.kip == DevreKipi.rehberli ? devre.kablolar.length : 0;
    _nabziAyarla();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hedefDenetle());
  }

  @override
  void didUpdateWidget(covariant DevreDuzenleyici oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.kilitli && !oldWidget.kilitli) _vazgec();
    _nabziAyarla();
  }

  @override
  void dispose() {
    _notZamani?.cancel();
    _nabiz.dispose();
    _zoom.dispose();
    _tc.dispose();
    super.dispose();
  }

  void _nabziAyarla() {
    final gerek = !widget.kilitli &&
        (_kabloBasi != null ||
            _hayalet != null ||
            (widget.kip == DevreKipi.rehberli && _siradakiHedef != null));
    if (gerek && !_nabiz.isAnimating) {
      _nabiz.repeat(reverse: true);
    } else if (!gerek && _nabiz.isAnimating) {
      _nabiz.stop();
    }
  }

  // ------------------------------------------------------------------
  // Devre degisikligi
  // ------------------------------------------------------------------

  void _degistir(Devre yeni, {bool geriye = true}) {
    if (geriye) {
      _geri.add(devre);
      if (_geri.length > 40) _geri.removeAt(0);
    }
    widget.sim.devre = yeni;
    widget.onDegisti?.call(yeni);
    setState(() {});
    _hedefDenetle();
  }

  void geriAl() {
    if (_geri.isEmpty) return;
    HapticFeedback.selectionClick();
    final d = _geri.removeLast();
    widget.sim.devre = d;
    widget.onDegisti?.call(d);
    setState(_secimiBirak);
  }

  /// Tahtayi bosaltir (geri alinabilir).
  void temizle() {
    if (devre.bosMu) return;
    _vazgec();
    _degistir(Devre.bos);
    _goster(devreT(widget.lang, 'Tahta boşaldı. "Geri al" ile geri getirebilirsin.',
        'Board cleared. Use "Undo" to bring it back.',
        'Brett geleert. Mit „Rückgängig“ holst du es zurück.',
        'Placa vacía. Con «Deshacer» la recuperas.'));
  }

  void _secimiBirak() {
    _seciliParca = null;
    _seciliKablo = null;
    _kabloBasi = null;
    _hayalet = null;
    _nabziAyarla();
  }

  void _vazgec() => setState(_secimiBirak);

  void _goster(String s, {bool hata = false}) {
    _notZamani?.cancel();
    setState(() {
      _not = s;
      _notHata = hata;
    });
    _notZamani = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) setState(() => _not = null);
    });
  }

  // ------------------------------------------------------------------
  // Rehberli hedefler
  // ------------------------------------------------------------------

  List<bool> get _hedefDurumu => hedefDurumu(devre, widget.hedefler);

  HedefBaglanti? get _siradakiHedef {
    if (widget.kip != DevreKipi.rehberli) return null;
    final d = _hedefDurumu;
    for (var i = 0; i < d.length; i++) {
      if (!d[i]) return widget.hedefler[i];
    }
    return null;
  }

  int get tamamlananHedef => _hedefDurumu.where((x) => x).length;

  void _hedefDenetle() {
    if (!mounted || widget.kip != DevreKipi.rehberli) return;
    if (_tamamBildirildi || widget.hedefler.isEmpty) return;
    if (devreTamamMi(devre, widget.hedefler)) {
      _tamamBildirildi = true;
      _nabziAyarla();
      widget.onHedeflerTamam?.call();
    }
  }

  /// Yardim: siradaki hedefi cocugun yerine takar.
  void hedefiTak() {
    final h = _siradakiHedef;
    if (h == null) return;
    String? bos(String uc) {
      if (devre.kabloTakilabilir(uc)) return uc;
      final d = delikCoz(uc);
      if (d == null) return null;
      // Ayni seritte bos bir delik.
      final yarim = d.$1 < 5 ? [0, 1, 2, 3, 4] : [5, 6, 7, 8, 9];
      for (final r in yarim.reversed) {
        final u = delik(devreSatirlari[r], d.$2);
        if (devre.kabloTakilabilir(u)) return u;
      }
      return null;
    }

    final a = bos(h.a), b = bos(h.b);
    if (a == null || b == null) return;
    widget.onYardim?.call();
    _kabloyuEkle(a, b, yardim: true);
  }

  // ------------------------------------------------------------------
  // Kablo
  // ------------------------------------------------------------------

  void _kabloyuEkle(String a, String b, {bool yardim = false}) {
    final k = Kablo(a, b);
    if (devre.kablolar.contains(k)) {
      setState(() => _kabloBasi = null);
      return;
    }
    final yeni = devre.kabloEkle(k);
    if (widget.kip == DevreKipi.rehberli && !yardim) {
      final once = _hedefDurumu;
      final sonra = hedefDurumu(yeni, widget.hedefler);
      var ilerledi = false;
      for (var i = 0; i < once.length; i++) {
        if (!once[i] && sonra[i]) ilerledi = true;
      }
      final kisa = devreyiCoz(yeni).kisaDevre;
      if (!ilerledi || kisa) {
        _yanlis++;
        widget.onYanlis?.call();
        SoundService.playWrong();
        HapticFeedback.mediumImpact();
        final h = _siradakiHedef;
        setState(() => _kabloBasi = null);
        _goster(
            kisa
                ? devreT(widget.lang, 'Bu kablo kısa devre yapar! 5V doğrudan GND\'ye gitmemeli.',
                    'This wire would cause a short circuit! 5V must not go straight to GND.',
                    'Dieses Kabel macht einen Kurzschluss! 5V darf nicht direkt an GND.',
                    '¡Este cable haría un cortocircuito! 5V no debe ir directo a GND.')
                : devreT(
                    widget.lang,
                    'Bu bağlantı devrede yok. ${h == null ? '' : 'Sıradaki: ${h.metin(widget.lang)}'}',
                    'That connection is not in the circuit. ${h == null ? '' : 'Next: ${h.metin(widget.lang)}'}',
                    'Diese Verbindung gehört nicht dazu. ${h == null ? '' : 'Als Nächstes: ${h.metin(widget.lang)}'}',
                    'Esa conexión no está en el circuito. ${h == null ? '' : 'Siguiente: ${h.metin(widget.lang)}'}'),
            hata: true);
        return;
      }
    }
    HapticFeedback.lightImpact();
    SoundService.playBlokTak();
    _kabloBasi = null;
    _degistir(yeni);
    _nabziAyarla();
  }

  // ------------------------------------------------------------------
  // Parca
  // ------------------------------------------------------------------

  static const Map<ParcaTuru, List<int>> _tercihSatirlari = {
    ParcaTuru.led: [2, 1, 7, 6],
    ParcaTuru.direnc: [1, 2, 6, 7],
    ParcaTuru.buton: [4],
    ParcaTuru.pot: [0, 5],
    ParcaTuru.buzzer: [2, 7],
    ParcaTuru.ldr: [1, 6],
    ParcaTuru.sicaklik: [0, 5],
    ParcaTuru.mesafe: [0, 5],
  };

  /// Yeni bir parcayi hayalet olarak getirir (kullanici yerini secer).
  void parcaEkle(ParcaTuru tur, {LedRengi renk = LedRengi.kirmizi, int ohm = 220}) {
    if (widget.kilitli || widget.kip != DevreKipi.serbest) return;
    final onek = switch (tur) {
      ParcaTuru.led => 'L',
      ParcaTuru.direnc => 'R',
      ParcaTuru.buton => 'B',
      ParcaTuru.pot => 'P',
      ParcaTuru.buzzer => 'Z',
      ParcaTuru.ldr => 'IS',
      ParcaTuru.sicaklik => 'T',
      ParcaTuru.mesafe => 'M',
      ParcaTuru.servo => 'S',
    };
    final id = devre.yeniKimlik(onek);
    if (tur == ParcaTuru.servo) {
      final dolu = {for (final p in devre.parcalar) if (p.tur == ParcaTuru.servo) p.sutun};
      final yer = [0, 1].where((y) => !dolu.contains(y)).firstOrNull;
      if (yer == null) {
        _goster(devreT(widget.lang, 'En fazla iki servo koyabilirsin.', 'You can add at most two servos.',
            'Höchstens zwei Servos.', 'Como máximo dos servos.'), hata: true);
        return;
      }
      _secimiBirak();
      _degistir(devre.parcaEkle(Parca.servo(id, yer: yer)));
      _seciliParca = id;
      return;
    }
    Parca? bulunan;
    for (final r in _tercihSatirlari[tur] ?? const [2]) {
      for (var c = 3; c <= devreSutunSayisi && bulunan == null; c++) {
        final p = Parca(id: id, tur: tur, sutun: c, satir: r, renk: renk, ohm: ohm);
        if (devre.yerlesebilir(p)) bulunan = p;
      }
      if (bulunan != null) break;
    }
    if (bulunan == null) {
      _goster(devreT(widget.lang, 'Breadboard\'da yer kalmadı.', 'No room left on the breadboard.',
          'Kein Platz mehr auf dem Steckbrett.', 'No queda sitio en la placa de pruebas.'), hata: true);
      return;
    }
    setState(() {
      _secimiBirak();
      _hayalet = bulunan;
      _hayaletYeni = true;
    });
    _nabziAyarla();
    _goster(devreT(widget.lang, 'Koymak istediğin deliğe dokun, sonra "Yerleştir".',
        'Tap the hole where you want it, then "Place".',
        'Tippe auf das gewünschte Loch, dann „Einsetzen“.',
        'Toca el agujero donde lo quieras y luego «Colocar».'));
    _gorunurYap(_dunya.parcaKutusu(bulunan));
  }

  bool get _hayaletGecerli {
    final h = _hayalet;
    if (h == null) return false;
    return devre.yerlesebilir(h);
  }

  void yerlestir() {
    final h = _hayalet;
    if (h == null || !_hayaletGecerli) return;
    HapticFeedback.lightImpact();
    SoundService.playBlokTak();
    final yeni = _hayaletYeni ? devre.parcaEkle(h) : devre.parcaDegistir(h);
    _hayalet = null;
    _seciliParca = h.id;
    _degistir(yeni);
    _nabziAyarla();
  }

  bool _dondurulebilir(Parca p) => switch (p.tur) {
        ParcaTuru.led ||
        ParcaTuru.direnc ||
        ParcaTuru.pot ||
        ParcaTuru.buzzer ||
        ParcaTuru.sicaklik =>
          true,
        _ => false,
      };

  Parca _dondur(Parca p) =>
      p.tur == ParcaTuru.direnc ? p.kopya(dikey: !p.dikey) : p.kopya(ters: !p.ters);

  void dondur() {
    final h = _hayalet;
    if (h != null) {
      setState(() => _hayalet = _dondur(h));
      return;
    }
    final p = _seciliParca == null ? null : devre.parca(_seciliParca!);
    if (p == null || !_dondurulebilir(p)) return;
    final yeni = _dondur(p);
    if (!devre.yerlesebilir(yeni)) {
      _goster(devreT(widget.lang, 'Burada döndürmeye yer yok; önce taşı.', 'No room to flip it here; move it first.',
          'Hier ist kein Platz zum Drehen; erst verschieben.', 'No cabe girado aquí; muévelo primero.'), hata: true);
      return;
    }
    HapticFeedback.selectionClick();
    _degistir(devre.parcaDegistir(yeni));
  }

  void _tasi() {
    final p = _seciliParca == null ? null : devre.parca(_seciliParca!);
    if (p == null || p.tur.kartDisi) return;
    setState(() {
      _hayalet = p;
      _hayaletYeni = false;
    });
    _nabziAyarla();
    _goster(devreT(widget.lang, 'Yeni yerine dokun, sonra "Yerleştir".', 'Tap its new spot, then "Place".',
        'Tippe auf die neue Stelle, dann „Einsetzen“.', 'Toca su nuevo sitio y luego «Colocar».'));
  }

  void _sil() {
    final p = _seciliParca;
    final k = _seciliKablo;
    if (p != null) {
      _secimiBirak();
      _degistir(devre.parcaSil(p));
    } else if (k != null) {
      if (k < _sabitKablo) return;
      _secimiBirak();
      _degistir(devre.kabloSil(k));
    }
    HapticFeedback.selectionClick();
  }

  void _ozellik() {
    final p = _seciliParca == null ? null : devre.parca(_seciliParca!);
    if (p == null) return;
    if (p.tur == ParcaTuru.led) {
      final r = LedRengi.values[(p.renk.index + 1) % LedRengi.values.length];
      _degistir(devre.parcaDegistir(p.kopya(renk: r)));
    } else if (p.tur == ParcaTuru.direnc) {
      const sira = [220, 1000, 10000];
      final i = sira.indexOf(p.ohm);
      _degistir(devre.parcaDegistir(p.kopya(ohm: sira[(i + 1) % sira.length])));
    }
    HapticFeedback.selectionClick();
  }

  void _kabloRengi() {
    final i = _seciliKablo;
    if (i == null) return;
    const renkler = [
      0xFFE53935, 0xFF2B2D31, 0xFFF9A825, 0xFF2E9E4F, 0xFFF57C00, 0xFF1E6FD9, 0xFF8E44AD, 0xFFECEFF1,
    ];
    final k = devre.kablolar[i];
    final simdiki = k.renk ?? kabloRengi(k, i);
    final j = renkler.indexOf(simdiki);
    _degistir(devre.kabloDegistir(i, Kablo(k.a, k.b, renk: renkler[(j + 1) % renkler.length])));
  }

  // ------------------------------------------------------------------
  // Dokunma
  // ------------------------------------------------------------------

  double get _olcek => _tc.value.getMaxScaleOnAxis();

  /// Ekranda bir delik araligi kac piksel.
  double get ekranAdimi => _k0 * _olcek;

  Offset _dunyaya(Offset yerel) => yerel / _k0;

  Parca? _parcaBul(Offset w) {
    // Ustte cizilen (sonra eklenen) once.
    for (final p in devre.parcalar.reversed) {
      if (_dunya.parcaKutusu(p).inflate(0.15).contains(w)) return p;
    }
    return null;
  }

  void _dokun(TapUpDetails d) {
    if (widget.kilitli) return;
    final w = _dunyaya(d.localPosition);
    final h = _hayalet;
    if (h != null) {
      final del = DevreDunyasi.enYakinDelik(w, yaricap: 2.5);
      if (del == null) return;
      final c = delikCoz(del)!;
      setState(() => _hayalet = h.kopya(sutun: c.$2, satir: c.$1));
      HapticFeedback.selectionClick();
      return;
    }
    final uc = _dunya.enYakinUc(w, devre);
    final bas = _kabloBasi;
    if (bas != null) {
      if (uc == null) {
        setState(() => _kabloBasi = null);
        _nabziAyarla();
        return;
      }
      if (uc == bas) {
        setState(() => _kabloBasi = null);
        _nabziAyarla();
        return;
      }
      if (ekranAdimi < DevreDuzenleyici.yakinlastirmaEsigi) {
        _yakinlas(d.localPosition);
        return;
      }
      if (!devre.kabloTakilabilir(uc)) {
        _doluUyarisi();
        return;
      }
      _kabloyuEkle(bas, uc);
      return;
    }
    if (widget.kip == DevreKipi.serbest) {
      final p = _parcaBul(w);
      if (p != null) {
        HapticFeedback.selectionClick();
        setState(() {
          _secimiBirak();
          _seciliParca = p.id;
        });
        return;
      }
    }
    if (widget.kip != DevreKipi.izle) {
      final ki = _dunya.enYakinKablo(w, devre);
      if (ki != null && (uc == null || ki >= _sabitKablo)) {
        HapticFeedback.selectionClick();
        setState(() {
          _secimiBirak();
          _seciliKablo = ki;
        });
        return;
      }
    }
    if (uc != null && widget.kip != DevreKipi.izle) {
      if (ekranAdimi < DevreDuzenleyici.yakinlastirmaEsigi) {
        _yakinlas(d.localPosition);
        return;
      }
      if (!devre.kabloTakilabilir(uc)) {
        _doluUyarisi();
        return;
      }
      HapticFeedback.selectionClick();
      setState(() {
        _secimiBirak();
        _kabloBasi = uc;
      });
      _nabziAyarla();
      return;
    }
    if (_seciliParca != null || _seciliKablo != null) _vazgec();
  }

  void _doluUyarisi() => _goster(
      devreT(widget.lang, 'Bu delik dolu. Aynı sıradaki boş bir deliği seç.',
          'That hole is taken. Pick an empty hole in the same row strip.',
          'Das Loch ist belegt. Nimm ein freies Loch im selben Streifen.',
          'Ese agujero está ocupado. Elige uno libre de la misma tira.'),
      hata: true);

  /// Test ve ekran goruntusu icin: bir uca dokunmanin karsiligi.
  @visibleForTesting
  void ucaDokun(String uc) {
    final k = _dunya.konum(uc, devre);
    if (k == null) return;
    // Yakinlastirma esigini atla: o uca yakinlasilmis gibi.
    _tc.value = _merkezle(k * _k0, DevreDuzenleyici.rahatAdim / _k0);
    _dokun(TapUpDetails(kind: PointerDeviceKind.touch, localPosition: k * _k0, globalPosition: Offset.zero));
  }

  void _uzunBasBasla(LongPressStartDetails d) {
    if (widget.kilitli || widget.kip != DevreKipi.serbest) return;
    final w = _dunyaya(d.localPosition);
    var h = _hayalet;
    if (h == null) {
      final p = _parcaBul(w);
      if (p == null || p.tur.kartDisi) return;
      h = p;
      _hayaletYeni = false;
    }
    final capa = Offset(DevreDunyasi.sutunX(h.sutun), DevreDunyasi.satirY(h.satir));
    HapticFeedback.mediumImpact();
    setState(() {
      _seciliParca = null;
      _seciliKablo = null;
      _kabloBasi = null;
      _hayalet = h;
      _tutma = w - capa;
    });
    _nabziAyarla();
  }

  void _uzunBasSurukle(LongPressMoveUpdateDetails d) {
    final h = _hayalet;
    if (h == null) return;
    final w = _dunyaya(d.localPosition) - _tutma;
    final del = DevreDunyasi.enYakinDelik(w, yaricap: 3);
    if (del == null) return;
    final c = delikCoz(del)!;
    if (c.$1 == h.satir && c.$2 == h.sutun) return;
    HapticFeedback.selectionClick();
    setState(() => _hayalet = h.kopya(sutun: c.$2, satir: c.$1));
  }

  void _uzunBasBitti(LongPressEndDetails d) {
    if (_hayalet == null) return;
    if (!_hayaletYeni && _hayaletGecerli) yerlestir();
  }

  // Calisirken butona basmak.
  final Map<int, String> _basanParmaklar = {};

  void _parmakBas(PointerDownEvent e) {
    if (!(widget.kilitli || widget.kip == DevreKipi.izle)) return;
    final w = _dunyaya(e.localPosition);
    for (final p in devre.parcalar) {
      if (p.tur == ParcaTuru.buton && _dunya.parcaKutusu(p).inflate(0.6).contains(w)) {
        _basanParmaklar[e.pointer] = p.id;
        widget.sim.butonBas(p.id, true);
        HapticFeedback.lightImpact();
        return;
      }
    }
  }

  void _parmakKalk(PointerEvent e) {
    final id = _basanParmaklar.remove(e.pointer);
    if (id != null) widget.sim.butonBas(id, false);
  }

  // ------------------------------------------------------------------
  // Yakinlastirma
  // ------------------------------------------------------------------

  Matrix4 _sigdir() {
    final h = _dunya.yukseklik * _k0;
    final s = math.min(1.0, _gorunum.height / h);
    final dx = (_gorunum.width - _gorunum.width * s) / 2;
    final dy = math.max(0.0, (_gorunum.height - h * s) / 2);
    return _matris(dx, dy, s);
  }

  /// Izleme kipinin ilk gorunumu: devrede parca varsa breadboard'a (ve
  /// servo seridine) odaklan, Uno'nun alt basligi da gorunsun; LED'ler,
  /// butonlar orada. Parca yoksa (karttaki L isigi) her sey.
  Matrix4 _ilkGorunum() {
    if (widget.kip != DevreKipi.izle) return _sigdir();
    // Bos devre: yalnizca karttaki L isigi var, karta odaklan.
    final bos = devre.bosMu;
    final ust = bos ? 0.0 : DevreDunyasi.bbY - 3.4;
    final alt = bos ? DevreDunyasi.bbY - 1.6 : _dunya.yukseklik;
    final odakH = (alt - ust) * _k0;
    final s = math.min(1.0, _gorunum.height / odakH);
    final dx = (_gorunum.width - _gorunum.width * s) / 2;
    final dy = -ust * _k0 * s + math.max(0.0, (_gorunum.height - odakH * s) / 2);
    return _matris(dx, dy, s);
  }

  /// Olcek + kaydirma matrisi (vector_math surumlerinden bagimsiz).
  static Matrix4 _matris(double tx, double ty, double s) =>
      Matrix4.diagonal3Values(s, s, 1)..setTranslationRaw(tx, ty, 0);

  double get _enAzOlcek => math.min(1.0, _gorunum.height / (_dunya.yukseklik * _k0));

  void _animasyon(Matrix4 hedef) {
    _zoomAnim = Matrix4Tween(begin: _tc.value, end: hedef)
        .animate(CurvedAnimation(parent: _zoom, curve: Curves.easeOutCubic));
    _zoom.forward(from: 0);
  }

  Matrix4 _merkezle(Offset yerel, double s) {
    final w = _gorunum.width, h = _gorunum.height;
    final icW = w * s, icH = _dunya.yukseklik * _k0 * s;
    var tx = w / 2 - yerel.dx * s;
    var ty = h / 2 - yerel.dy * s;
    tx = icW <= w ? (w - icW) / 2 : tx.clamp(w - icW, 0.0);
    ty = icH <= h ? (h - icH) / 2 : ty.clamp(h - icH, 0.0);
    return _matris(tx, ty, s);
  }

  void _yakinlas(Offset yerel) {
    HapticFeedback.selectionClick();
    _animasyon(_merkezle(yerel, DevreDuzenleyici.rahatAdim / _k0));
    _goster(devreT(widget.lang, 'Yakınlaştırdım. Şimdi tam deliğe dokun.', 'Zoomed in. Now tap the exact hole.',
        'Herangezoomt. Tippe jetzt genau aufs Loch.', 'Acerqué la vista. Ahora toca el agujero exacto.'));
  }

  void _olcekle(double carpan) {
    final s = (_olcek * carpan).clamp(_enAzOlcek, 5.0);
    final m = Matrix4.inverted(_tc.value);
    final orta = MatrixUtils.transformPoint(m, _gorunum.center(Offset.zero));
    _animasyon(_merkezle(orta, s));
  }

  void sigdir() => _animasyon(_sigdir());

  /// Bir dunya dikdortgeni gorunmuyorsa ona kay.
  void _gorunurYap(Rect r) {
    if (_gorunum == Size.zero) return;
    final s = math.max(_olcek, math.min(5.0, 20 / _k0));
    _animasyon(_merkezle(r.center * _k0, s));
  }

  // ------------------------------------------------------------------
  // Ekran
  // ------------------------------------------------------------------

  String _t(String tr, String en, String de, String es) => devreT(widget.lang, tr, en, de, es);

  @override
  Widget build(BuildContext context) {
    final dunya = _dunya;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const ValueKey('devre_sahnesi'),
          height: widget.yukseklik,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F6F6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDCE6E6)),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(builder: (context, c) {
            final yeniGorunum = Size(c.maxWidth, c.maxHeight);
            final k0 = c.maxWidth / dunya.genislik;
            if (yeniGorunum != _gorunum || (k0 - _k0).abs() > 0.01) {
              final ilk = _gorunum == Size.zero;
              _gorunum = yeniGorunum;
              _k0 = k0;
              if (ilk) {
                // InteractiveViewer henuz dinlemiyor: dogrudan.
                _tc.value = _ilkGorunum();
              } else {
                // Boyut degisti (dondurme): kurulum sirasinda
                // denetleyiciyi degistirmek dinleyeni insa sirasinda
                // kirletir; bir sonraki kareye.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _tc.value = _ilkGorunum();
                });
              }
            }
            return Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _tc,
                    constrained: false,
                    minScale: _enAzOlcek,
                    maxScale: 5,
                    boundaryMargin: const EdgeInsets.all(60),
                    child: Listener(
                      onPointerDown: _parmakBas,
                      onPointerUp: _parmakKalk,
                      onPointerCancel: _parmakKalk,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: _dokun,
                        onLongPressStart: _uzunBasBasla,
                        onLongPressMoveUpdate: _uzunBasSurukle,
                        onLongPressEnd: _uzunBasBitti,
                        child: SizedBox(
                          width: c.maxWidth,
                          height: dunya.yukseklik * _k0,
                          child: Stack(children: [
                            Positioned.fill(
                              child: RepaintBoundary(
                                child: CustomPaint(
                                  painter: DevreZeminBoyaci(
                                      devre: devre, dunya: dunya, secilenKablo: _seciliKablo),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: RepaintBoundary(
                                child: CustomPaint(
                                  key: const ValueKey('devre_parcalari'),
                                  painter: DevreParcaBoyaci(
                                    devre: devre,
                                    dunya: dunya,
                                    sim: widget.sim,
                                    gizli: _hayaletYeni ? null : _hayalet?.id,
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _UstBoyaci(
                                  nabiz: _nabiz,
                                  dunya: dunya,
                                  devre: devre,
                                  seciliParca: _seciliParca,
                                  kabloBasi: _kabloBasi,
                                  hayalet: _hayalet,
                                  hayaletGecerli: _hayaletGecerli,
                                  hedef: widget.kilitli ? null : _siradakiHedef,
                                  sim: widget.sim,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: _zoomDugmeleri(),
                ),
                if (_ustSerit() case final s?) Positioned(left: 8, top: 8, right: 52, child: s),
                if (_not case final n?)
                  Positioned(left: 8, right: 8, bottom: 8, child: _notKutusu(n, _notHata)),
              ],
            );
          }),
        ),
        if (widget.kip != DevreKipi.izle && !widget.kilitli) ...[
          const SizedBox(height: 8),
          _aracSeridi(),
          if (widget.kip == DevreKipi.serbest &&
              _hayalet == null &&
              _seciliParca == null &&
              _seciliKablo == null &&
              _kabloBasi == null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 2),
              child: Text(
                _t('Kablo: iki uca sırayla dokun. Parçayı taşımak: basılı tut ve sürükle.',
                    'Wire: tap two ends one after the other. Move a part: press, hold and drag.',
                    'Kabel: tippe nacheinander auf zwei Enden. Bauteil verschieben: gedrückt halten und ziehen.',
                    'Cable: toca dos extremos, uno tras otro. Mover una pieza: mantén pulsado y arrastra.'),
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey.shade400),
              ),
            ),
        ],
      ],
    );
  }

  Widget? _ustSerit() {
    final bas = _kabloBasi;
    if (bas != null) {
      return _cip(
        key: const ValueKey('devre_kablo_basi'),
        ikon: Icons.cable_rounded,
        renk: const Color(0xFF00897B),
        metin: _t('${ucAdi(bas, 'tr', devre)} seçildi · kablonun öbür ucuna dokun',
            '${ucAdi(bas, 'en', devre)} picked · tap the other end',
            '${ucAdi(bas, 'de', devre)} gewählt · tippe auf das andere Ende',
            '${ucAdi(bas, 'es', devre)} elegido · toca el otro extremo'),
      );
    }
    final p = _seciliParca == null ? null : devre.parca(_seciliParca!);
    if (p != null) {
      return _cip(ikon: Icons.touch_app_rounded, renk: widget.renk, metin: parcaAdi(p, widget.lang));
    }
    final h = _hayalet;
    if (h != null) {
      return _cip(
          ikon: _hayaletGecerli ? Icons.check_circle_rounded : Icons.block_rounded,
          renk: _hayaletGecerli ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          metin: _hayaletGecerli
              ? '${parcaAdi(h, widget.lang)} · ${devreSatirlari[h.satir]}${h.sutun}'
              : _t('Buraya sığmıyor', 'It doesn\'t fit here', 'Passt hier nicht', 'No cabe aquí'));
    }
    return null;
  }

  Widget _cip({Key? key, required IconData ikon, required Color renk, required String metin}) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        key: key,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(ikon, size: 16, color: renk),
          const SizedBox(width: 6),
          Flexible(
            child: Text(metin,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily, fontSize: 12.5, fontWeight: FontWeight.w800, color: renk)),
          ),
        ]),
      ),
    );
  }

  Widget _notKutusu(String n, bool hata) {
    return Container(
      key: const ValueKey('devre_notu'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hata ? const Color(0xFFFFEBEE) : const Color(0xFF263238).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(n,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12.5,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: hata ? const Color(0xFFC62828) : Colors.white)),
    );
  }

  Widget _zoomDugmeleri() {
    final kucuk = widget.kip == DevreKipi.izle;
    final boy = kucuk ? 32.0 : 38.0;
    Widget d(IconData i, String ad, VoidCallback f, Key k) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Tooltip(
            message: ad,
            child: GestureDetector(
              key: k,
              behavior: HitTestBehavior.opaque,
              onTap: f,
              child: Container(
                width: boy,
                height: boy,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD5DEE2)),
                ),
                child: Icon(i, size: kucuk ? 18 : 20, color: const Color(0xFF455A64)),
              ),
            ),
          ),
        );
    return Column(children: [
      d(Icons.add_rounded, _t('Yakınlaştır', 'Zoom in', 'Vergrößern', 'Acercar'), () => _olcekle(1.6),
          const ValueKey('devre_yakin')),
      d(Icons.remove_rounded, _t('Uzaklaştır', 'Zoom out', 'Verkleinern', 'Alejar'), () => _olcekle(1 / 1.6),
          const ValueKey('devre_uzak')),
      d(Icons.fit_screen_rounded, _t('Tamamını gör', 'Show all', 'Alles zeigen', 'Ver todo'), sigdir,
          const ValueKey('devre_sigdir')),
    ]);
  }

  Widget _arac(IconData i, String ad, VoidCallback? f, {Key? key, Color? renk, bool ana = false}) {
    final r = renk ?? const Color(0xFF37474F);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ana
          ? FilledButton.icon(
              key: key,
              onPressed: f,
              icon: Icon(i, size: 18),
              label: Text(ad, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800)),
              style: FilledButton.styleFrom(
                backgroundColor: r,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )
          : OutlinedButton.icon(
              key: key,
              onPressed: f,
              icon: Icon(i, size: 18, color: f == null ? null : r),
              label: Text(ad,
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800, color: f == null ? null : r)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
    );
  }

  Widget _aracSeridi() {
    final List<Widget> l;
    final h = _hayalet;
    final p = _seciliParca == null ? null : devre.parca(_seciliParca!);
    if (h != null) {
      l = [
        _arac(Icons.check_rounded, _t('Yerleştir', 'Place', 'Einsetzen', 'Colocar'),
            _hayaletGecerli ? yerlestir : null,
            key: const ValueKey('devre_yerlestir'), renk: const Color(0xFF2E7D32), ana: true),
        if (_dondurulebilir(h))
          _arac(Icons.rotate_right_rounded, _t('Döndür', 'Flip', 'Drehen', 'Girar'), dondur,
              key: const ValueKey('devre_dondur')),
        _arac(Icons.close_rounded, _t('Vazgeç', 'Cancel', 'Abbrechen', 'Cancelar'), _vazgec,
            key: const ValueKey('devre_vazgec')),
      ];
    } else if (p != null) {
      l = [
        if (!p.tur.kartDisi)
          _arac(Icons.open_with_rounded, _t('Taşı', 'Move', 'Verschieben', 'Mover'), _tasi,
              key: const ValueKey('devre_tasi')),
        if (_dondurulebilir(p))
          _arac(Icons.rotate_right_rounded, _t('Döndür', 'Flip', 'Drehen', 'Girar'), dondur,
              key: const ValueKey('devre_dondur')),
        if (p.tur == ParcaTuru.led)
          _arac(Icons.palette_rounded, _t('Renk', 'Colour', 'Farbe', 'Color'), _ozellik,
              key: const ValueKey('devre_renk'), renk: ledRengi(p.renk) == const Color(0xFFF4F7FF) ? null : ledRengi(p.renk)),
        if (p.tur == ParcaTuru.direnc)
          _arac(Icons.tune_rounded, ohmYazisi(p.ohm), _ozellik, key: const ValueKey('devre_ohm')),
        _arac(Icons.delete_outline_rounded, _t('Sil', 'Delete', 'Löschen', 'Borrar'), _sil,
            key: const ValueKey('devre_sil'), renk: const Color(0xFFC62828)),
        _arac(Icons.close_rounded, _t('Tamam', 'Done', 'Fertig', 'Listo'), _vazgec),
      ];
    } else if (_seciliKablo != null) {
      final sabit = _seciliKablo! < _sabitKablo;
      l = [
        if (!sabit)
          _arac(Icons.palette_rounded, _t('Renk', 'Colour', 'Farbe', 'Color'), _kabloRengi,
              key: const ValueKey('devre_kablo_renk')),
        if (!sabit)
          _arac(Icons.delete_outline_rounded, _t('Kabloyu sil', 'Delete wire', 'Kabel löschen', 'Borrar cable'), _sil,
              key: const ValueKey('devre_sil'), renk: const Color(0xFFC62828)),
        _arac(Icons.close_rounded, _t('Tamam', 'Done', 'Fertig', 'Listo'), _vazgec),
      ];
    } else if (widget.kip == DevreKipi.rehberli) {
      l = [
        _arac(Icons.undo_rounded, _t('Geri al', 'Undo', 'Rückgängig', 'Deshacer'), _geri.isEmpty ? null : geriAl,
            key: const ValueKey('devre_geri')),
        if (_yanlis >= 3 && _siradakiHedef != null)
          _arac(Icons.lightbulb_rounded, _t('Benim yerime tak', 'Plug it in for me', 'Steck es für mich ein', 'Conéctalo por mí'),
              hedefiTak,
              key: const ValueKey('devre_yardim'), renk: const Color(0xFFF57C00)),
      ];
    } else {
      l = [
        _arac(Icons.add_circle_rounded, _t('Parça ekle', 'Add part', 'Bauteil', 'Añadir pieza'), _parcaListesi,
            key: const ValueKey('devre_parca_ekle'), renk: widget.renk, ana: true),
        _arac(Icons.undo_rounded, _t('Geri al', 'Undo', 'Rückgängig', 'Deshacer'), _geri.isEmpty ? null : geriAl,
            key: const ValueKey('devre_geri')),
        _arac(Icons.layers_clear_rounded, _t('Temizle', 'Clear', 'Leeren', 'Limpiar'), devre.bosMu ? null : temizle,
            key: const ValueKey('devre_temizle')),
      ];
    }
    return SizedBox(
      height: 46,
      child: ListView(scrollDirection: Axis.horizontal, children: l),
    );
  }

  Future<void> _parcaListesi() async {
    final secim = await showModalBottomSheet<(ParcaTuru, LedRengi, int)>(
      context: context,
      showDragHandle: true,
      builder: (context) => ParcaListesi(lang: widget.lang),
    );
    if (secim == null || !mounted) return;
    parcaEkle(secim.$1, renk: secim.$2, ohm: secim.$3);
  }
}

/// Parca listesi (alt sayfa).
class ParcaListesi extends StatelessWidget {
  const ParcaListesi({super.key, required this.lang});
  final String lang;

  static const List<(ParcaTuru, LedRengi, int)> ogeler = [
    (ParcaTuru.led, LedRengi.kirmizi, 220),
    (ParcaTuru.led, LedRengi.sari, 220),
    (ParcaTuru.led, LedRengi.yesil, 220),
    (ParcaTuru.led, LedRengi.mavi, 220),
    (ParcaTuru.direnc, LedRengi.kirmizi, 220),
    (ParcaTuru.direnc, LedRengi.kirmizi, 10000),
    (ParcaTuru.buton, LedRengi.kirmizi, 220),
    (ParcaTuru.pot, LedRengi.kirmizi, 220),
    (ParcaTuru.buzzer, LedRengi.kirmizi, 220),
    (ParcaTuru.ldr, LedRengi.kirmizi, 220),
    (ParcaTuru.sicaklik, LedRengi.kirmizi, 220),
    (ParcaTuru.mesafe, LedRengi.kirmizi, 220),
    (ParcaTuru.servo, LedRengi.kirmizi, 220),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.82,
          children: [
            for (final o in ogeler)
              InkWell(
                key: ValueKey('parca_${o.$1.name}_${o.$2.name}_${o.$3}'),
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(context, o),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Column(children: [
                    Expanded(child: CustomPaint(painter: _ParcaSimgesi(o), size: Size.infinite)),
                    const SizedBox(height: 4),
                    Text(
                      parcaAdi(Parca(id: '', tur: o.$1, renk: o.$2, ohm: o.$3), lang),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF37474F)),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Listedeki parca resmi: parca kendi cizimiyle, kutuya sigdirilmis.
class _ParcaSimgesi extends CustomPainter {
  _ParcaSimgesi(this.o);
  final (ParcaTuru, LedRengi, int) o;

  @override
  void paint(Canvas c, Size size) {
    const dunya = DevreDunyasi(servoSayisi: 1);
    final p = o.$1 == ParcaTuru.servo
        ? Parca.servo('S')
        : Parca(id: 'x', tur: o.$1, sutun: 10, satir: o.$1 == ParcaTuru.buton ? 4 : 2, renk: o.$2, ohm: o.$3);
    var r = dunya.parcaKutusu(p);
    if (o.$1 == ParcaTuru.direnc) r = r.inflate(0.3);
    final s = math.min(size.width / r.width, size.height / r.height) * 0.9;
    c.save();
    c.translate(size.width / 2, size.height / 2);
    c.scale(s);
    c.translate(-r.center.dx, -r.center.dy);
    if (p.tur == ParcaTuru.servo) servoZemini(c, p, dunya);
    devreParcasiCiz(c, p, dunya,
        sonuc: null, girdiler: const DevreGirdileri());
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _ParcaSimgesi old) => old.o != o;
}

/// Ust katman: secim cercevesi, kablo baslangici, hedefler, hayalet.
class _UstBoyaci extends CustomPainter {
  _UstBoyaci({
    required this.nabiz,
    required this.dunya,
    required this.devre,
    required this.seciliParca,
    required this.kabloBasi,
    required this.hayalet,
    required this.hayaletGecerli,
    required this.hedef,
    required this.sim,
  }) : super(repaint: nabiz);

  final Animation<double> nabiz;
  final DevreDunyasi dunya;
  final Devre devre;
  final String? seciliParca;
  final String? kabloBasi;
  final Parca? hayalet;
  final bool hayaletGecerli;
  final HedefBaglanti? hedef;
  final DevreSimulasyonu sim;

  @override
  void paint(Canvas c, Size size) {
    final k = size.width / dunya.genislik;
    final n = nabiz.value;
    c.save();
    c.scale(k);

    final h = hedef;
    if (h != null) {
      for (final u in [h.a, h.b]) {
        _serit(c, u, const Color(0xFFFFB300));
        final m = dunya.konum(u, devre);
        if (m == null) continue;
        c.drawCircle(m, 0.55 + 0.35 * n,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.16
              ..color = const Color(0xFFFF8F00).withValues(alpha: 0.95 - 0.4 * n));
      }
    }

    final p = seciliParca == null ? null : devre.parca(seciliParca!);
    if (p != null) {
      c.drawRRect(
          RRect.fromRectAndRadius(dunya.parcaKutusu(p).inflate(0.25), const Radius.circular(0.4)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.14
            ..color = const Color(0xFF00ACC1));
    }

    final bas = kabloBasi;
    if (bas != null) {
      _serit(c, bas, const Color(0xFF26A69A));
      final m = dunya.konum(bas, devre);
      if (m != null) {
        c.drawCircle(m, 0.5 + 0.3 * n, Paint()..color = const Color(0xFF26A69A).withValues(alpha: 0.35));
        c.drawCircle(m, 0.42,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.14
              ..color = const Color(0xFF00897B));
      }
    }

    final g = hayalet;
    if (g != null) {
      final r = dunya.parcaKutusu(g).inflate(0.2);
      c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(0.4)),
          Paint()
            ..color = (hayaletGecerli ? const Color(0xFF43A047) : const Color(0xFFE53935))
                .withValues(alpha: 0.14 + 0.08 * n));
      devreParcasiCiz(c, g, dunya, girdiler: sim.girdiler, saydamlik: 0.8);
      for (final u in g.bacakUclari.values) {
        if (u == null) continue;
        final m = dunya.konum(u)!;
        c.drawCircle(m, 0.3,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.1
              ..color = hayaletGecerli ? const Color(0xFF2E7D32) : const Color(0xFFC62828));
      }
    }
    c.restore();
  }

  /// Bir delik ucunun bagli oldugu 5'li serit (ya da ray) hafifce
  /// boyaniyor: "ayni siradaki delikler birbirine bagli".
  void _serit(Canvas c, String uc, Color renk) {
    final d = delikCoz(uc);
    final boya = Paint()..color = renk.withValues(alpha: 0.18);
    if (d != null) {
      final ust = d.$1 >= 5;
      final y1 = DevreDunyasi.satirY(ust ? 9 : 4), y2 = DevreDunyasi.satirY(ust ? 5 : 0);
      final x = DevreDunyasi.sutunX(d.$2);
      c.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTRB(x - 0.45, y1 - 0.45, x + 0.45, y2 + 0.45), const Radius.circular(0.3)),
          boya);
      return;
    }
    final r = rayCoz(uc);
    if (r != null) {
      final y = DevreDunyasi.rayY(r.$1, r.$2);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTRB(DevreDunyasi.sutunX(1) - 0.45, y - 0.4, DevreDunyasi.sutunX(30) + 0.45, y + 0.4),
              const Radius.circular(0.3)),
          boya);
    }
  }

  @override
  bool shouldRepaint(covariant _UstBoyaci old) => true;
}
