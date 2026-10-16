import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../theme.dart';
import '../../ui/motion.dart';
import '../../utils/lang.dart';
import '../../widgets/mascot.dart';
import '../yurutme/blok_yorumlayici.dart';
import '../yurutme/degisken_adlari.dart';
import '../yurutme/scratch_blok_katalogu.dart';
import 'scratch_sahnesi.dart' show SahneBalonu;

/// PROJE SAHNESI — Proje Atolyesi'nin canli sahnesi.
///
/// [ProjeMotoru]'nu kare kare ilerletip (Scratch'in 30 kare/saniyesi)
/// motorun o anki halini ciziyor: kuklalar ve ikizleri, kalem cizgileri,
/// konusma balonlari, nota (♪), degisken gostergeleri. Sahne Scratch'in
/// kendi olcusunde (480 x 360, ortasi 0,0); altindaki yesil serit
/// "renge degiyor mu?"nun zemini ([ProjeMotoru.zeminY]).
///
/// Program tus kullaniyorsa sahnenin altinda SANAL TUSLAR var: basili
/// tutulan tus motorda basili ("sag ok basili mi?"), basmak tus
/// betiklerini baslatiyor. Sahneye dokunmak kuklaya tiklamak ve fare
/// imlecini oraya koymak demek. Cocuk hic dokunmazsa otomatik oyuncu
/// oynuyor; bunu sahnedeki kucuk etiket soyluyor.
///
/// HIZ: blok calistiran kareler [mesgulKare] kadar suruyor (cizim gibi
/// kisa projeler yavas cekimde izlensin), bekleme kareleri ve oyunlar
/// gercek hizda. Motorun kendisi zamandan bagimsiz: hiz yalnizca
/// gosterim.
///
/// BASLAMAMIS motor (bayrak oncesi) onizleme olarak ciziliyor: kuklalar
/// baslangic yerlerinde, tuslar pasif.
///
/// SURUKLEME ([surukle]): program calismiyorken cocuk bir kuklayi
/// parmagiyla tasiyabiliyor (Scratch'teki gibi). Kuklaya degen dokunus
/// HEMEN kuklanin (sayfa kaymiyor); kuklanin disindaki dokunus sayfayi
/// kaydirmaya devam ediyor. Yer sahne sinirlarinda tutuluyor (480 x 360);
/// birakinca [onKonum] — sahibi bunu bir sonraki calistirmanin
/// baslangic yeri yapiyor. Ilk hareket [onSurukleBasla]'yi cagiriyor
/// (biten bir yurutmenin son hali yerine onizlemeye donmek icin).
/// Birden cok kukla varsa dokunulan kukla SECILIYOR (ince halka).
///
/// KONUM GOSTERGESI: sol altta kucuk "x: 120  y: -40" (secili kuklanin;
/// suruklerken ve calisirken canli, tam sayi). Birden cok kukla varsa
/// basinda kuklanin adi.
class ProjeSahnesi extends StatefulWidget {
  const ProjeSahnesi({
    super.key,
    required this.motor,
    required this.lang,
    this.calisiyor = false,
    this.renk,
    this.mesgulKare = const Duration(milliseconds: 33),
    this.baslamaGecikmesi = Duration.zero,
    this.onAdim,
    this.onBitti,
    this.hedefTamam,
    this.dogru = false,
    this.ipucu,
    this.surukle = false,
    this.onSurukleBasla,
    this.onKonum,
  });

  final ProjeMotoru motor;
  final String lang;

  /// false: onizleme (motor ilerlemiyor).
  final bool calisiyor;
  final Color? renk;
  final Duration mesgulKare;
  final Duration baslamaGecikmesi;

  /// Cocugun kuklasinin calistirdigi son blogun kod alanindaki sirasi.
  final ValueChanged<int?>? onAdim;

  /// Yurutme bitti (kendiliginden, hedeflerle ya da dur ile).
  final VoidCallback? onBitti;

  /// Verilirse yarim saniyede bir soruluyor: true ise oyun bir saniye
  /// sonra "hedefler tamam" diye bitiyor (sonsuz donguyu beklemeden).
  final bool Function()? hedefTamam;

  /// Kod hedefe ulasti: Devi sonda mutlu.
  final bool dogru;

  /// Onizlemede ustte gosterilen yazi.
  final String? ipucu;

  /// Calismiyorken kuklalar surukleniyor.
  final bool surukle;

  /// Bir kukla ilk kez kipirdadi (kuklanin adi).
  final ValueChanged<String>? onSurukleBasla;

  /// Kukla birakildi: adi ve yeni yeri (Scratch koordinati, tam sayi).
  final void Function(String ad, Offset konum)? onKonum;

  /// Gercek hizda bir kare.
  static const Duration kareSuresi = Duration(milliseconds: 33);

  /// Sahnenin (480 x 360) altindaki tus seridinin yuksekligi.
  static const double tusSeridi = 54;

  @override
  State<ProjeSahnesi> createState() => ProjeSahnesiState();
}

class ProjeSahnesiState extends State<ProjeSahnesi>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  /// Her karede bir artiyor; boyaci ve kuklalar bunu dinliyor.
  final ValueNotifier<int> _surum = ValueNotifier(0);

  Duration _sonraki = Duration.zero;
  int? _sonSira;
  bool _bildirildi = false;
  bool _hedefleBitti = false;
  int? _hedefKaresi;

  /// Secili kuklanin adi (null: cocugun kuklasi).
  String? _secili;
  _Tutus? _tutus;

  /// Son cizimin olcegi (surukleme parmagi Scratch koordinatina
  /// bununla ceviriyor).
  _Harita? _harita;

  @visibleForTesting
  String? get seciliKukla => _seciliKukla()?.tanim.ad;

  ProjeMotoru get _m => widget.motor;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    // Ticker burada kuruluyor: tembel kurulursa ilk kez dispose'ta
    // olusturulup "deactivated widget" hatasi veriyor (Flutter 3.44).
    _ticker = createTicker(_tik);
    if (widget.calisiyor) _basla();
  }

  @override
  void didUpdateWidget(covariant ProjeSahnesi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motor != widget.motor) {
      _ticker.stop();
      _bildirildi = false;
      _hedefleBitti = false;
      _hedefKaresi = null;
      _sonSira = null;
      if (widget.calisiyor) _basla();
    } else if (!oldWidget.calisiyor && widget.calisiyor) {
      _basla();
    }
  }

  void _basla() {
    _sonraki = widget.baslamaGecikmesi;
    if (!_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _surum.dispose();
    super.dispose();
  }

  /// Kirmizi dur.
  void durdur() {
    if (_m.bitti) return;
    _m.durdur();
    _bitti();
  }

  void _tik(Duration gecen) {
    if (_m.bitti) {
      _bitti();
      return;
    }
    var n = 0;
    while (gecen >= _sonraki && !_m.bitti) {
      _m.kare();
      _sonraki +=
          _m.sonKareMesgul ? widget.mesgulKare : ProjeSahnesi.kareSuresi;
      _hedefleriSor();
      // Uygulama takilirsa kareler birikmesin: en fazla 4 kare yetis.
      if (++n >= 4) {
        if (gecen > _sonraki) _sonraki = gecen;
        break;
      }
    }
    if (n == 0) return;
    _surum.value++;
    final sira = _m.calisanSira;
    if (sira != _sonSira) {
      _sonSira = sira;
      widget.onAdim?.call(sira);
    }
    if (_m.bitti) _bitti();
  }

  void _hedefleriSor() {
    final soru = widget.hedefTamam;
    if (soru == null || _m.bitti) return;
    final k = _m.kareNo;
    if (_hedefKaresi != null) {
      // Hedefler tamam: bir saniye daha izlensin, sonra bitsin.
      if (k - _hedefKaresi! >= ProjeMotoru.kareHizi) {
        _hedefleBitti = true;
        _m.tamamla();
      }
      return;
    }
    if (k % 15 == 0 && soru()) _hedefKaresi = k;
  }

  void _bitti() {
    _ticker.stop();
    if (_bildirildi) return;
    _bildirildi = true;
    _surum.value++;
    widget.onAdim?.call(null);
    if (mounted) setState(() {});
    widget.onBitti?.call();
  }

  // ---------------------------------------------------------------
  // Cizim
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tuslar = _siraliTuslar();
    return RepaintBoundary(
      child: Column(
        children: [
          Expanded(child: _tuval()),
          if (tuslar.isNotEmpty)
            SizedBox(
              height: ProjeSahnesi.tusSeridi,
              child: _TusSeridi(
                tuslar: tuslar,
                motor: _m,
                surum: _surum,
                lang: widget.lang,
                aktif: widget.calisiyor && !_m.bitti,
              ),
            ),
        ],
      ),
    );
  }

  List<String> _siraliTuslar() {
    const sira = ['left', 'up', 'down', 'right', 'space'];
    return [
      for (final t in sira)
        if (_m.tuslar.contains(t)) t,
    ];
  }

  Widget _tuval() {
    return LayoutBuilder(builder: (context, kutu) {
      final w = kutu.maxWidth, h = kutu.maxHeight;
      final o = math.min(w / 480, h / 360);
      final harita = _Harita(o, (w - 480 * o) / 2, (h - 360 * o) / 2);
      _harita = harita;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.calisiyor
            ? (d) {
                final p = harita.sahneye(d.localPosition);
                _m.tikla(p.dx, p.dy);
              }
            : null,
        child: RawGestureDetector(
          behavior: HitTestBehavior.translucent,
          gestures: {
            _KuklaTutucu: GestureRecognizerFactoryWithHandlers<_KuklaTutucu>(
              () => _KuklaTutucu(debugOwner: this),
              (r) => r
                ..tutabilir = ((p) => _tutus == null && _kuklaBul(p) != null)
                ..onBasla = _tutBasla
                ..onSurukle = _tutSurukle
                ..onBirak = _tutBirak,
            ),
          },
          child: _tuvalIcerigi(harita, w, h),
        ),
      );
    });
  }

  // ---------------------------------------------------------------
  // Surukleme ve secim
  // ---------------------------------------------------------------

  bool get _suruklenir => widget.surukle && !widget.calisiyor;

  /// Asil (ikiz olmayan) kuklalar.
  Iterable<SahneKuklasi> get _asillar =>
      _m.kuklalar.where((k) => !k.klon && !k.silindi);

  SahneKuklasi? _kuklaAdla(String? ad) {
    if (ad == null) return null;
    for (final k in _asillar) {
      if (k.tanim.ad == ad) return k;
    }
    return null;
  }

  SahneKuklasi? _seciliKukla() {
    final s = _kuklaAdla(_secili);
    if (s != null) return s;
    for (final k in _asillar) {
      if (k.ana) return k;
    }
    return _asillar.isEmpty ? null : _asillar.first;
  }

  /// Dokunulan yerdeki en ustteki kukla (dokunma alani en az 48 pt).
  SahneKuklasi? _kuklaBul(Offset yerel) {
    final harita = _harita;
    if (!_suruklenir || harita == null) return null;
    for (final k in _asillar.toList().reversed) {
      if (!k.sahne.gorunur) continue;
      final p = harita.ekrana(k.sahne.x, k.sahne.y);
      final r = math.max(k.yaricap * 1.3 * harita.olcek, 24.0);
      if ((p - yerel).distanceSquared <= r * r) return k;
    }
    return null;
  }

  void _tutBasla(Offset yerel) {
    final k = _kuklaBul(yerel);
    if (k == null) return;
    _tutus = _Tutus(k.tanim.ad, Offset(k.sahne.x, k.sahne.y), yerel);
    HapticFeedback.selectionClick();
    setState(() => _secili = k.tanim.ad);
  }

  void _tutSurukle(Offset yerel) {
    final t = _tutus;
    final harita = _harita;
    if (t == null || harita == null || !_suruklenir) return;
    final d = yerel - t.parmak;
    if (!t.kipirdadi) {
      if (d.distance < 2) return;
      t.kipirdadi = true;
      widget.onSurukleBasla?.call(t.ad);
    }
    final x = (t.bas.dx + d.dx / harita.olcek).clamp(-240.0, 240.0);
    final y = (t.bas.dy - d.dy / harita.olcek).clamp(-180.0, 180.0);
    t.son = Offset(x.roundToDouble(), y.roundToDouble());
    _yereKoy(t);
    _surum.value++;
  }

  void _yereKoy(_Tutus t) {
    final k = _kuklaAdla(t.ad);
    if (k == null) return;
    k.sahne
      ..x = t.son.dx
      ..y = t.son.dy;
  }

  void _tutBirak() {
    final t = _tutus;
    _tutus = null;
    if (t == null) return;
    if (t.kipirdadi) {
      // Yeni motor gelmis olabilir (bitmis yurutmeden onizlemeye):
      // kukla onda da birakilan yerde.
      _yereKoy(t);
      widget.onKonum?.call(t.ad, t.son);
    }
    if (mounted) setState(() {});
  }

  Widget _tuvalIcerigi(_Harita harita, double w, double h) {
    return ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ProjeBoyaci(
                    motor: _m,
                    harita: harita,
                    surum: _surum,
                    kalemRengi: widget.renk ?? const Color(0xFF4C97FF),
                  ),
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder<int>(
                  valueListenable: _surum,
                  builder: (context, _, __) => _ustKatman(harita, w, h),
                ),
              ),
            ],
          ),
    );
  }

  Widget _ustKatman(_Harita harita, double w, double h) {
    final zaman = _m.zaman;
    final cocuklar = <Widget>[];
    final secili = _seciliKukla();
    final cokKukla = _asillar.length > 1;
    final vurgu = widget.renk ?? const Color(0xFF4C97FF);
    // Secim halkasi (kuklanin altinda): birden cok kukla varken.
    if (secili != null &&
        cokKukla &&
        !widget.calisiyor &&
        secili.sahne.gorunur) {
      final p = harita.ekrana(secili.sahne.x, secili.sahne.y);
      final r = secili.yaricap * 1.25 * harita.olcek;
      cocuklar.add(Positioned(
        key: const ValueKey('kukla_secim_halkasi'),
        left: p.dx - r,
        top: p.dy - r,
        width: r * 2,
        height: r * 2,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: vurgu.withValues(alpha: 0.10),
              border:
                  Border.all(color: vurgu.withValues(alpha: 0.85), width: 2),
            ),
          ),
        ),
      ));
    }
    // Devi kuklalari (maskot gorseli).
    for (final k in _m.kuklalar) {
      final s = k.sahne;
      if (!s.gorunur || k.tanim.gorunum != KuklaGorunumu.devi) continue;
      final p = harita.ekrana(s.x, s.y);
      final boy = k.yaricap * 2.8 * harita.olcek;
      cocuklar.add(Positioned(
        key: ValueKey('kukla_${k.no}'),
        left: p.dx - boy / 2,
        top: p.dy - boy / 2,
        width: boy,
        height: boy,
        child: IgnorePointer(
          child: Transform.rotate(
            angle: _egim(k),
            child: Transform.flip(
              flipX: _solaBakiyor(k),
              child: Mascot(
                size: boy,
                showShadow: false,
                mood: _m.bitti && widget.dogru
                    ? MascotMood.happy
                    : MascotMood.idle,
              ),
            ),
          ),
        ),
      ));
    }
    // Konusma balonlari ve notalar.
    for (final k in _m.kuklalar) {
      final s = k.sahne;
      if (!s.gorunur) continue;
      final p = harita.ekrana(s.x, s.y);
      final ust = p.dy - k.yaricap * harita.olcek * 1.05;
      if (s.soyledigi != null) {
        cocuklar.add(Positioned(
          key: ValueKey('balon_${k.no}'),
          left: 4,
          right: 4,
          bottom: h - ust,
          child: IgnorePointer(
            child: Align(
              alignment: Alignment(
                  ((p.dx / math.max(w, 1)) * 2 - 1).clamp(-1.0, 1.0), 1),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: w * 0.6),
                child: SahneBalonu(
                  key: k.ana && !k.klon ? const ValueKey('sahne_balonu') : null,
                  metin: s.soyledigi!,
                  kenar: (widget.renk ?? const Color(0xFF4C97FF))
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ));
      }
      if (k.notaCaliyor(zaman)) {
        cocuklar.add(Positioned(
          left: p.dx + k.yaricap * harita.olcek * 0.7,
          top: ust - 20,
          child: const IgnorePointer(child: _NotaBalonu()),
        ));
      }
    }
    // Degisken gostergeleri (Scratch'teki gibi sol ustte).
    if (_m.degiskenler.isNotEmpty) {
      cocuklar.add(Positioned(
        left: 6,
        top: 6,
        child: IgnorePointer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in _m.degiskenler.entries.take(3))
                _Gosterge(
                    ad: yorumlayiciAdi(e.key, widget.lang), deger: e.value),
            ],
          ),
        ),
      ));
    }
    // Ust serit: onizlemede ipucu, otomatik oyuncu, sonuc.
    final serit = _serit();
    // Oyun surerken etiket altta (zeminde): ustten gelen kuklalari
    // (dusen elmalar) kapatmasin. Konum gostergesi hep sol altta.
    final altta = widget.calisiyor && !_m.bitti;
    if (serit != null && !altta) {
      cocuklar.add(Positioned(
        right: 6,
        left: _m.degiskenler.isNotEmpty ? 96 : 6,
        top: 6,
        child: IgnorePointer(
          child: Align(alignment: Alignment.topRight, child: serit),
        ),
      ));
    }
    cocuklar.add(Positioned(
      left: 6,
      right: 6,
      bottom: 4,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (serit != null && altta) ...[serit, const SizedBox(height: 4)],
            if (secili != null)
              _KonumGostergesi(
                ad: cokKukla ? secili.tanim.adFor(widget.lang) : null,
                x: secili.sahne.x,
                y: secili.sahne.y,
                lang: widget.lang,
                vurgu: _tutus != null,
              ),
          ],
        ),
      ),
    ));
    return Stack(clipBehavior: Clip.none, children: cocuklar);
  }

  bool _solaBakiyor(SahneKuklasi k) =>
      k.tanim.donusStili == DonusStili.solSag &&
      math.sin(k.sahne.yon * math.pi / 180) < -1e-6;

  /// Her yone donen kukla baktigi yone egiliyor; "sonraki kostum"
  /// kuklayi saga sola sallıyor (kostum degisti mi gorulsun).
  double _egim(SahneKuklasi k) {
    final kostum = k.sahne.kostum;
    final sallanma = kostum == 1 ? 0.0 : (kostum.isEven ? 0.16 : -0.16);
    if (k.tanim.donusStili == DonusStili.solSag) return sallanma;
    return (k.sahne.yon - 90) * math.pi / 180 + sallanma;
  }

  Widget? _serit() {
    if (!widget.calisiyor && !_m.bitti) {
      final ipucu = widget.ipucu;
      return ipucu == null ? null : _Etiket(metin: ipucu);
    }
    if (_m.bitti) return _sonucEtiketi();
    if (_m.etkilesimli && !_m.elleOynandi) {
      return _Etiket(
        key: const ValueKey('otomatik_oyuncu'),
        ikon: Icons.smart_toy_rounded,
        renk: const Color(0xFF6D4AFF),
        metin: _m.otomatikOynuyor
            ? _t(
                'Otomatik oyuncu · tuşlara bas, sen oyna!',
                'Autoplay · press the keys to play!',
                'Autopilot · drück die Tasten und spiel!',
                'Piloto automático · ¡pulsa las teclas y juega!')
            : _t(
                'Tuşlara bas ya da kuklaya dokun!',
                'Press the keys or tap a sprite!',
                'Drück die Tasten oder tippe eine Figur an!',
                '¡Pulsa las teclas o toca un objeto!'),
      );
    }
    return null;
  }

  Widget _sonucEtiketi() {
    final String metin;
    final IconData ikon;
    final Color renk;
    if (_m.elleDurdu) {
      metin = _t('Kodu durdurdun.', 'You stopped the code.',
          'Du hast den Code gestoppt.', 'Detuviste el código.');
      ikon = Icons.stop_circle_rounded;
      renk = const Color(0xFFB84848);
    } else if (_hedefleBitti) {
      metin = _t(
          'Hedefler tamam! Oyun durdu.',
          'Goals done! The game stopped.',
          'Ziele erreicht! Das Spiel stoppt.',
          '¡Objetivos cumplidos! El juego se detuvo.');
      ikon = Icons.emoji_events_rounded;
      renk = Colors.green.shade700;
    } else if (_m.butceBitti) {
      final sn = _m.zaman.round();
      metin = _t(
          'Bu kod hiç durmuyor; $sn saniye sonra biz durdurduk.',
          'This code never stops; we paused it after $sn seconds.',
          'Dieser Code hört nie auf; wir haben nach $sn Sekunden gestoppt.',
          'Este código no para nunca; lo pausamos tras $sn segundos.');
      ikon = Icons.all_inclusive_rounded;
      renk = const Color(0xFFB26A00);
    } else if (_m.durduruldu) {
      metin = _t(
          '"Tümünü durdur" oyunu bitirdi.',
          '"Stop all" ended the game.',
          '„Stoppe alles“ hat das Spiel beendet.',
          '"Detener todos" terminó el juego.');
      ikon = Icons.sports_score_rounded;
      renk = const Color(0xFF3D5A80);
    } else {
      metin = _t('Kodun sonuna geldi.', 'Your code reached the end.',
          'Dein Code ist durchgelaufen.', 'Tu código llegó al final.');
      ikon = Icons.flag_circle_rounded;
      renk = const Color(0xFF3D5A80);
    }
    return _Etiket(
        key: const ValueKey('proje_sonuc'),
        metin: metin,
        ikon: ikon,
        renk: renk);
  }
}

/// Suruklenen kukla: adi, tutuldugu andaki yeri ve parmagin yeri.
class _Tutus {
  _Tutus(this.ad, this.bas, this.parmak) : son = bas;
  final String ad;
  final Offset bas;
  final Offset parmak;
  Offset son;
  bool kipirdadi = false;
}

/// Kuklaya degen dokunusu HEMEN kazanan tanimayici: sayfanin kaydirmasi
/// (dikey surukleme) kuklayi tutan parmagi elinden almasin. Kuklaya
/// degmeyen dokunusa ([tutabilir] yanlis) hic katilmiyor.
class _KuklaTutucu extends OneSequenceGestureRecognizer {
  _KuklaTutucu({super.debugOwner});

  bool Function(Offset yerel)? tutabilir;
  ValueChanged<Offset>? onBasla;
  ValueChanged<Offset>? onSurukle;
  VoidCallback? onBirak;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      super.isPointerAllowed(event) &&
      (tutabilir?.call(event.localPosition) ?? false);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
    onBasla?.call(event.localPosition);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      onSurukle?.call(event.localPosition);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      onBirak?.call();
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void acceptGesture(int pointer) {}

  @override
  void rejectGesture(int pointer) {
    onBirak?.call();
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => 'kukla tutucu';
}

/// Sol alttaki kucuk konum gostergesi: "Devi  x: 120  y: -40".
class _KonumGostergesi extends StatelessWidget {
  const _KonumGostergesi({
    required this.x,
    required this.y,
    required this.lang,
    this.ad,
    this.vurgu = false,
  });

  final String? ad;
  final double x, y;
  final String lang;
  final bool vurgu;

  @override
  Widget build(BuildContext context) {
    final xs = x.round(), ys = y.round();
    final konum = AppLang.pick(lang,
        tr: 'konumu', en: 'position', de: 'Position', es: 'posición');
    final yazi = 'x: $xs  y: $ys';
    return Semantics(
      label: ad == null ? '$konum x $xs, y $ys' : '$ad $konum x $xs, y $ys',
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('kukla_konumu'),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: vurgu ? 0.95 : 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
                  vurgu ? const Color(0xFF4C97FF) : const Color(0x1F000000)),
        ),
        child: Text(
          ad == null ? yazi : '$ad  $yazi',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 11,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: Color(0xFF575E75),
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Scratch koordinati (480 x 360, y yukari) <-> ekran.
class _Harita {
  const _Harita(this.olcek, this.ox, this.oy);
  final double olcek, ox, oy;

  Offset ekrana(double x, double y) =>
      Offset(ox + (x + 240) * olcek, oy + (180 - y) * olcek);

  Offset sahneye(Offset p) =>
      Offset((p.dx - ox) / olcek - 240, 180 - (p.dy - oy) / olcek);

  @override
  bool operator ==(Object o) =>
      o is _Harita && o.olcek == olcek && o.ox == ox && o.oy == oy;

  @override
  int get hashCode => Object.hash(olcek, ox, oy);
}

class _ProjeBoyaci extends CustomPainter {
  _ProjeBoyaci({
    required this.motor,
    required this.harita,
    required ValueNotifier<int> surum,
    required this.kalemRengi,
  }) : super(repaint: surum);

  final ProjeMotoru motor;
  final _Harita harita;
  final Color kalemRengi;

  static final Paint _bulut = Paint()
    ..color = Colors.white.withValues(alpha: 0.95);
  static final Paint _zemin = Paint()..color = ScratchBlokKatalogu.zeminRengi;
  static final Paint _zeminCizgi = Paint()
    ..color = const Color(0xFF5DAE4F)
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final o = harita.olcek;
    // Gokyuzu (sahnenin disi da ayni renk: kenarlarda bosluk kalmasin).
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDDEEFF), Color(0xFFF4F9FF)],
        ).createShader(Offset.zero & size),
    );
    void bulut(double x, double y, double r) {
      final c = harita.ekrana(x, y);
      final rr = r * o;
      canvas.drawCircle(c, rr, _bulut);
      canvas.drawCircle(c + Offset(rr * 0.9, rr * 0.15), rr * 0.8, _bulut);
      canvas.drawCircle(c + Offset(-rr * 0.9, rr * 0.2), rr * 0.7, _bulut);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(c.dx - rr * 1.5, c.dy, rr * 3.1, rr * 0.9),
              Radius.circular(rr * 0.45)),
          _bulut);
    }

    bulut(-130, 120, 22);
    bulut(120, 90, 17);

    // Zemin seridi: "yesil rengine degiyor mu?"nun rengi.
    final zeminY = harita.ekrana(0, ProjeMotoru.zeminY).dy;
    canvas.drawRect(Rect.fromLTRB(0, zeminY, size.width, size.height), _zemin);
    canvas.drawLine(Offset(0, zeminY), Offset(size.width, zeminY), _zeminCizgi);

    // Kalem cizgileri.
    final kalem = Paint()
      ..color = kalemRengi
      ..strokeWidth = math.max(2.0, 3 * o)
      ..strokeCap = StrokeCap.round;
    for (final c in motor.cizgiler) {
      canvas.drawLine(
          harita.ekrana(c.x1, c.y1), harita.ekrana(c.x2, c.y2), kalem);
    }

    // Devi disindaki kuklalar.
    for (final k in motor.kuklalar) {
      final s = k.sahne;
      if (!s.gorunur || k.tanim.gorunum == KuklaGorunumu.devi) continue;
      final c = harita.ekrana(s.x, s.y);
      final r = k.yaricap * o;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      final sola = k.tanim.donusStili == DonusStili.solSag &&
          math.sin(s.yon * math.pi / 180) < -1e-6;
      if (k.tanim.donusStili == DonusStili.herYone &&
          k.tanim.gorunum == KuklaGorunumu.fare) {
        canvas.rotate((s.yon - 90) * math.pi / 180);
      }
      if (sola) canvas.scale(-1, 1);
      switch (k.tanim.gorunum) {
        case KuklaGorunumu.fare:
          _fare(canvas, r);
        case KuklaGorunumu.elma:
          _elma(canvas, r);
        case KuklaGorunumu.kase:
          _kase(canvas, r);
        case KuklaGorunumu.devi:
          break;
      }
      canvas.restore();
    }
  }

  static void _fare(Canvas c, double r) {
    final gri = Paint()..color = const Color(0xFF9AA3AE);
    final koyu = Paint()..color = const Color(0xFF6B7480);
    final pembe = Paint()..color = const Color(0xFFF4A7B9);
    // Kuyruk.
    c.drawPath(
      Path()
        ..moveTo(-r * 0.7, r * 0.25)
        ..quadraticBezierTo(-r * 1.35, r * 0.35, -r * 1.25, -r * 0.35),
      Paint()
        ..color = const Color(0xFFE38FA4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12
        ..strokeCap = StrokeCap.round,
    );
    // Govde ve bas.
    c.drawOval(
        Rect.fromCenter(
            center: Offset(-r * 0.1, r * 0.15),
            width: r * 1.6,
            height: r * 1.1),
        gri);
    c.drawCircle(Offset(r * 0.55, -r * 0.05), r * 0.5, gri);
    // Kulak.
    c.drawCircle(Offset(r * 0.35, -r * 0.55), r * 0.3, koyu);
    c.drawCircle(Offset(r * 0.35, -r * 0.55), r * 0.18, pembe);
    // Goz ve burun.
    c.drawCircle(Offset(r * 0.7, -r * 0.15), r * 0.09,
        Paint()..color = const Color(0xFF1F2430));
    c.drawCircle(Offset(r * 1.03, r * 0.02), r * 0.1, pembe);
    // Ayaklar.
    c.drawCircle(Offset(-r * 0.45, r * 0.68), r * 0.13, koyu);
    c.drawCircle(Offset(r * 0.25, r * 0.68), r * 0.13, koyu);
  }

  static void _elma(Canvas c, double r) {
    // Sap ve yaprak.
    c.drawLine(
        Offset(0, -r * 0.75),
        Offset(r * 0.12, -r * 1.25),
        Paint()
          ..color = const Color(0xFF7A4A21)
          ..strokeWidth = r * 0.18
          ..strokeCap = StrokeCap.round);
    c.save();
    c.translate(r * 0.42, -r * 1.05);
    c.rotate(-0.5);
    c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 0.7, height: r * 0.34),
        Paint()..color = const Color(0xFF43A047));
    c.restore();
    // Govde: iki daire, ustte hafif cukur.
    final kirmizi = Paint()..color = const Color(0xFFE53935);
    c.drawCircle(Offset(-r * 0.32, -r * 0.05), r * 0.72, kirmizi);
    c.drawCircle(Offset(r * 0.32, -r * 0.05), r * 0.72, kirmizi);
    c.drawCircle(Offset(0, r * 0.18), r * 0.78, kirmizi);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(-r * 0.45, -r * 0.25),
            width: r * 0.35,
            height: r * 0.5),
        Paint()..color = Colors.white.withValues(alpha: 0.45));
  }

  static void _kase(Canvas c, double r) {
    final dis = Paint()..color = const Color(0xFFC46A2B);
    final ic = Paint()..color = const Color(0xFF8E4A1C);
    final kenar = Paint()..color = const Color(0xFFE59A5A);
    final govde = Path()
      ..moveTo(-r * 1.1, -r * 0.2)
      ..quadraticBezierTo(-r * 1.0, r * 0.75, 0, r * 0.75)
      ..quadraticBezierTo(r * 1.0, r * 0.75, r * 1.1, -r * 0.2)
      ..close();
    c.drawPath(govde, dis);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(0, -r * 0.2), width: r * 2.2, height: r * 0.55),
        kenar);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(0, -r * 0.17), width: r * 1.85, height: r * 0.36),
        ic);
    // Ayak.
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(0, r * 0.8), width: r * 0.8, height: r * 0.18),
            Radius.circular(r * 0.09)),
        dis);
  }

  @override
  bool shouldRepaint(covariant _ProjeBoyaci old) =>
      old.motor != motor ||
      old.harita != harita ||
      old.kalemRengi != kalemRengi;
}

/// Kuklanin yanindaki ♪ (ses ve nota bloklari).
class _NotaBalonu extends StatelessWidget {
  const _NotaBalonu();

  @override
  Widget build(BuildContext context) => Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCF63CF), width: 2),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.music_note_rounded,
            size: 16, color: Color(0xFFCF63CF)),
      );
}

/// Scratch'in degisken gostergesi: gri kutu, turuncu deger.
class _Gosterge extends StatelessWidget {
  const _Gosterge({required this.ad, required this.deger});
  final String ad;
  final num deger;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.fromLTRB(7, 3, 3, 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0FF).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFC4CFDF)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(ad,
              style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  color: Color(0xFF575E75))),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C1A),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              deger == deger.roundToDouble() ? '${deger.toInt()}' : '$deger',
              key: ValueKey('gosterge_$ad'),
              style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Colors.white),
            ),
          ),
        ]),
      );
}

class _Etiket extends StatelessWidget {
  const _Etiket({super.key, required this.metin, this.ikon, this.renk});
  final String metin;
  final IconData? ikon;
  final Color? renk;

  @override
  Widget build(BuildContext context) {
    final r = renk ?? const Color(0xFF4A4F5C);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (ikon != null) ...[
          Icon(ikon, size: 16, color: r),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            metin,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11.5,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: r,
            ),
          ),
        ),
      ]),
    );
  }
}

/// Sahnenin altindaki sanal tuslar. Basili tutulan tus motorda basili;
/// otomatik oyuncunun bastigi tus da basili gorunuyor.
class _TusSeridi extends StatelessWidget {
  const _TusSeridi({
    required this.tuslar,
    required this.motor,
    required this.surum,
    required this.lang,
    required this.aktif,
  });

  final List<String> tuslar;
  final ProjeMotoru motor;
  final ValueNotifier<int> surum;
  final String lang;
  final bool aktif;

  String _ad(String tus) => switch (tus) {
        'left' => AppLang.pick(lang,
            tr: 'Sol ok',
            en: 'Left arrow',
            de: 'Pfeil nach links',
            es: 'Flecha izquierda'),
        'right' => AppLang.pick(lang,
            tr: 'Sağ ok',
            en: 'Right arrow',
            de: 'Pfeil nach rechts',
            es: 'Flecha derecha'),
        'up' => AppLang.pick(lang,
            tr: 'Yukarı ok',
            en: 'Up arrow',
            de: 'Pfeil nach oben',
            es: 'Flecha arriba'),
        'down' => AppLang.pick(lang,
            tr: 'Aşağı ok',
            en: 'Down arrow',
            de: 'Pfeil nach unten',
            es: 'Flecha abajo'),
        _ => AppLang.pick(lang,
            tr: 'boşluk', en: 'space', de: 'Leertaste', es: 'espacio'),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F5FA),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: LayoutBuilder(builder: (context, kutu) {
        // Dar sahnede tuslar daralir ama dokunma alani 44 pt'nin
        // altina inmez (bosluk tusu kisalir, aralar daralir).
        final bosluk = tuslar.contains('space');
        final oklar = tuslar.length - (bosluk ? 1 : 0);
        var ara = 8.0, ok = 50.0, genis = 108.0;
        double toplam() =>
            oklar * ok + (bosluk ? genis : 0) + tuslar.length * ara;
        if (toplam() > kutu.maxWidth) {
          ara = 6;
          ok = 46;
          genis = 76;
        }
        if (toplam() > kutu.maxWidth) {
          ok = 44;
          ara = 4;
          genis = math.max(56.0, kutu.maxWidth - oklar * (ok + ara) - ara);
        }
        return ValueListenableBuilder<int>(
          valueListenable: surum,
          builder: (context, _, __) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final t in tuslar)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: ara / 2),
                  child: _Tus(
                    genislik: t == 'space' ? genis : ok,
                    key: ValueKey('tus_$t'),
                    ad: _ad(t),
                    ikon: switch (t) {
                      'left' => Icons.arrow_back_rounded,
                      'right' => Icons.arrow_forward_rounded,
                      'up' => Icons.arrow_upward_rounded,
                      'down' => Icons.arrow_downward_rounded,
                      _ => null,
                    },
                    genis: t == 'space',
                    basili: aktif && motor.basili.contains(t),
                    onBas: aktif ? () => motor.tusBas(t) : null,
                    onBirak: aktif ? () => motor.tusBirak(t) : null,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _Tus extends StatelessWidget {
  const _Tus({
    super.key,
    required this.ad,
    required this.ikon,
    required this.genis,
    required this.basili,
    this.genislik,
    this.onBas,
    this.onBirak,
  });

  final double? genislik;
  final String ad;
  final IconData? ikon;
  final bool genis;
  final bool basili;
  final VoidCallback? onBas;
  final VoidCallback? onBirak;

  @override
  Widget build(BuildContext context) {
    final aktif = onBas != null;
    final renk = basili ? const Color(0xFF4C97FF) : Colors.white;
    final yazi = basili
        ? Colors.white
        : aktif
            ? const Color(0xFF3D4A66)
            : const Color(0xFFAAB3C2);
    return Semantics(
      button: true,
      enabled: aktif,
      label: ad,
      child: Listener(
        onPointerDown: aktif ? (_) => onBas!() : null,
        onPointerUp: aktif ? (_) => onBirak!() : null,
        onPointerCancel: aktif ? (_) => onBirak!() : null,
        child: AnimatedContainer(
          duration: Motion.reduced(context)
              ? Duration.zero
              : const Duration(milliseconds: 80),
          width: genislik ?? (genis ? 108 : 50),
          height: 44,
          decoration: BoxDecoration(
            color: renk,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color:
                    basili ? const Color(0xFF3373CC) : const Color(0xFFD3DBE8),
                width: 1.5),
            boxShadow: basili
                ? null
                : [
                    const BoxShadow(
                        color: Color(0xFFD3DBE8), offset: Offset(0, 3)),
                  ],
          ),
          transform: Matrix4.translationValues(0, basili ? 2 : 0, 0),
          alignment: Alignment.center,
          child: ikon != null
              ? Icon(ikon, color: yazi, size: 24)
              : Text(
                  ad,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: yazi,
                  ),
                ),
        ),
      ),
    );
  }
}
