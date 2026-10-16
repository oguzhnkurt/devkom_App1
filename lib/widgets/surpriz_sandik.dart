import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_model.dart';
import '../screens/robotics_games_screen.dart' show ProGames;
import '../services/ads_service.dart';
import '../services/embedded_games_service.dart';
import '../services/gunluk_sandik_deposu.dart';
import '../theme.dart';
import '../ui/motion.dart';
import '../utils/lang.dart';
import 'oyun_kimligi.dart';
import 'oyun_sahnesi.dart';

/// GUNLUK SANDIK (ana sayfa): "Gunluk odulunu al, surpriz oyununu gor."
///
/// Her takvim gununde (cihazin yerel tarihi) sandik bir kez HAZIR:
/// parliyor, ara ara hafifce sallaniyor. Dokununca aciliyor; once jeton
/// odulu ucuyor, sonra oyunlarin canli kapaklari slot makinesi gibi donup
/// gunun oyununda duruyor. Acildiktan sonra o gun ayni oyun kaliyor
/// ("Oyna" her zaman calisiyor), altta "Bugunku odulunu aldin · Yarin
/// yeni sandik" yaziyor. Yeniden karistirma yok.
///
/// ODUL (bkz. [GunlukSandikDeposu]): jeton RASTGELE DEGIL, ust uste
/// kacinci gun oldugu belli: 5, 6, 7 ... en cok 10; bir gun kacarsa 5'e
/// doner. Yalnizca oyun rastgele. Sandik ucretsiz: acmak icin reklam ya
/// da satin alma yok.
///
/// HAVUZ (Ekim 2026): ucretsiz oyunlar + odullu reklamla bir tur
/// oynanabilen Pro oyunlar. Reklamli oyun cikarsa "Oyna" onu Oyunlar
/// ekranindaki ayni kapidan (`oyunuAc` -> bilgi sayfasi -> reklam)
/// geciriyor; sandik kilidi atlamiyor. Kapakta "Reklamla" rozeti var ki
/// cocuk videoyu surpriz diye karsilamasin. Reklam hakki yoksa ya da oyun
/// yalnizca Pro ise Pro olmayan cocuga o oyun cikmiyor.
///
/// Hareketi azalt aciksa bekleme sallantisi, acilis ve karistirma yok;
/// odul ve oyun dogrudan gorunur.
class SurprizSandik extends StatefulWidget {
  const SurprizSandik({
    super.key,
    required this.lang,
    required this.onOyna,
    this.onOdul,
    this.pro = false,
    this.reklamSorgusu,
    this.saat,
  });

  final String lang;
  final ValueChanged<GameModel> onOyna;

  /// Jetonu sunucuya yazar; yazildiysa `true`. Verilmezse ya da `false`
  /// donerse odul cihazda bekler ve sonraki acilista yeniden denenir.
  final Future<bool> Function(int jeton)? onOdul;

  /// Cocuk Pro mu? Pro ise butun oyunlar havuzda ve reklam yok.
  final bool pro;

  /// "Odullu reklam su an izlenebilir mi?" sorusu. Verilmezse
  /// `AdsService`'e soruluyor; testler reklam servisini baslatmadan
  /// reklamli havuzu deneyebilsin diye disaridan verilebiliyor.
  final Future<bool> Function()? reklamSorgusu;

  /// Simdiki zaman (testler gun degistirebilsin diye).
  final DateTime Function()? saat;

  /// Sandigin cikarabilecegi oyunlar.
  ///
  /// [reklamVar]: odullu reklam su an izlenebilir mi. Degilse kilitli
  /// oyun cikarmak cocugu acilamayan bir kapiya goturmek olur.
  static List<GameModel> havuz({required bool pro, required bool reklamVar}) =>
      EmbeddedGamesService.getAllEmbeddedGames().where((g) {
        if (pro || !ProGames.isProGame(g.type)) return true;
        return reklamVar && ProGames.reklamlaAcilabilir(g.type);
      }).toList();

  @override
  State<SurprizSandik> createState() => _SurprizSandikState();
}

enum _Durum { yukleniyor, hazir, aciliyor, karisiyor, acik }

class _SurprizSandikState extends State<SurprizSandik>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _r = math.Random();

  /// Reklam hakki ogrenilene kadar yalnizca ucretsizler (ve Pro ise hepsi).
  late List<GameModel> _oyunlar;
  bool _reklamVar = false;

  /// Acilistaki sarsinti.
  late final AnimationController _salla;

  /// Hazirken: ara ara kucuk bir sallanti ve nabiz gibi parilti.
  late final AnimationController _bekleme;

  /// "+N jeton" yukari ucuyor, sandiktan bir isik patliyor.
  late final AnimationController _ucus;

  _Durum _durum = _Durum.yukleniyor;
  GunlukSandikDurumu? _gunluk;
  int _gosterilen = 0;
  GameModel? _secilen;
  Timer? _zamanlayici;
  Timer? _geceYarisi;

  /// Acma suruyor: ikinci dokunus ikinci bir talep baslatmasin.
  bool _aliyor = false;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  DateTime _simdi() => (widget.saat ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _oyunlar = SurprizSandik.havuz(pro: widget.pro, reklamVar: false);
    _salla = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 620));
    _bekleme = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600));
    _ucus = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    WidgetsBinding.instance.addObserver(this);
    _basla();
  }

  Future<void> _basla() async {
    await _reklamSor();
    await _yukle();
  }

  @override
  void didUpdateWidget(covariant SurprizSandik eski) {
    super.didUpdateWidget(eski);
    if (eski.pro != widget.pro) {
      _havuzuYenile();
      if (_durum == _Durum.acik) _yukle();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama gece arkadayken gun degismis olabilir.
    if (state == AppLifecycleState.resumed) _yukle();
  }

  /// Odullu reklam su an izlenebilir mi? Reklam servisi hic baslamamissa
  /// (test, masaustu) false doner; sandik yalnizca ucretsizlerle calisir.
  Future<void> _reklamSor() async {
    bool izlenebilir;
    try {
      izlenebilir = await (widget.reklamSorgusu ??
          AdsService.instance.canWatchRewarded)();
    } catch (_) {
      izlenebilir = false;
    }
    if (!mounted || izlenebilir == _reklamVar) return;
    _reklamVar = izlenebilir;
    _havuzuYenile();
  }

  /// Havuz karisirken degismiyor: indeksler eski listeye bakiyor.
  void _havuzuYenile() {
    if (_durum == _Durum.aciliyor || _durum == _Durum.karisiyor) return;
    setState(() {
      _oyunlar = SurprizSandik.havuz(pro: widget.pro, reklamVar: _reklamVar);
      _gosterilen = 0;
    });
  }

  /// Kalici durumu okur, bekleyen jetonu gondermeyi dener ve gece
  /// yarisinda kendini yeniden okuyacak zamanlayiciyi kurar.
  Future<void> _yukle() async {
    if (_aliyor || _durum == _Durum.aciliyor || _durum == _Durum.karisiyor) {
      return;
    }
    final d = await GunlukSandikDeposu.oku(_simdi());
    if (!mounted || _aliyor) return;
    _geceYarisinaKur();
    if (d.bekleyen > 0) _gonder();
    if (d.hazir) {
      _ucus.value = 0;
      setState(() {
        _gunluk = d;
        _secilen = null;
        _durum = _Durum.hazir;
      });
      _beklemeyiBaslat();
      return;
    }
    // Bugun acilmis: gunun oyunu. Havuzdan cikmissa (Pro bitti, reklam
    // hakki yok) acilabilen bir oyunla degistiriliyor; kilitli bir kapi
    // gostermektense.
    var g = _oyunlar.where((o) => o.id == d.oyunId).firstOrNull;
    if (g == null && _oyunlar.isNotEmpty) {
      g = _oyunlar[_r.nextInt(_oyunlar.length)];
      await GunlukSandikDeposu.oyunuDegistir(g.id);
      if (!mounted) return;
    }
    _bekleme.stop();
    setState(() {
      _gunluk = d;
      _secilen = g;
      _gosterilen = g == null ? 0 : math.max(0, _oyunlar.indexOf(g));
      _durum = g == null ? _Durum.hazir : _Durum.acik;
    });
    // Durumu okundu, sandik acik: ucan jeton bitmis gorunsun.
    _ucus.value = 1;
  }

  void _beklemeyiBaslat() {
    if (!mounted) return;
    if (Motion.reduced(context)) {
      _bekleme.value = 0.5;
    } else if (!_bekleme.isAnimating) {
      _bekleme.repeat();
    }
  }

  void _geceYarisinaKur() {
    _geceYarisi?.cancel();
    final s = _simdi();
    final yarin = DateTime(s.year, s.month, s.day + 1);
    // Bir saniye pay: tam sinirda eski gunu okumasin.
    _geceYarisi = Timer(yarin.difference(s) + const Duration(seconds: 1), () {
      if (mounted) _yukle();
    });
  }

  Future<void> _gonder() async {
    final f = widget.onOdul;
    if (f == null) return;
    await GunlukSandikDeposu.bekleyeniGonder(f);
  }

  /// Bu oyun icin reklam izlenecek mi (rozet ve dugme simgesi icin)?
  bool _reklamli(GameModel g) => !widget.pro && ProGames.isProGame(g.type);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _zamanlayici?.cancel();
    _geceYarisi?.cancel();
    _salla.dispose();
    _bekleme.dispose();
    _ucus.dispose();
    super.dispose();
  }

  Future<void> _ac() async {
    if (_durum != _Durum.hazir || _aliyor || _oyunlar.isEmpty) return;
    _aliyor = true;
    try {
      final hedef = _r.nextInt(_oyunlar.length);
      final oyun = _oyunlar[hedef];
      final d = await GunlukSandikDeposu.talepEt(_simdi(), oyunId: oyun.id);
      if (!mounted) return;
      if (d == null) {
        // Baska bir yerde (ikinci sekme, gece yarisi oncesi) acilmis.
        _aliyor = false;
        await _yukle();
        return;
      }
      _gunluk = d;
      // Odul hemen kayitli (bekleyen); sunucuya gonderim arkada.
      unawaited(_gonder());
      _bekleme.stop();
      if (Motion.reduced(context)) {
        _ucus.value = 1;
        setState(() {
          _secilen = oyun;
          _gosterilen = hedef;
          _durum = _Durum.acik;
        });
        return;
      }
      HapticFeedback.mediumImpact();
      setState(() => _durum = _Durum.aciliyor);
      await _salla.forward(from: 0);
      if (!mounted) return;
      HapticFeedback.lightImpact();
      _ucus.forward(from: 0);
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      setState(() => _durum = _Durum.karisiyor);
      // Slot makinesi: aralik her adimda biraz uzuyor; son adim hedefte.
      final adimSayisi = 12 + _r.nextInt(4);
      var adim = 0;
      var bekle = 70;
      final bitti = Completer<void>();
      void sonraki() {
        if (!mounted) {
          bitti.complete();
          return;
        }
        adim++;
        setState(() {
          _gosterilen = adim >= adimSayisi || _oyunlar.length < 2
              ? hedef
              : (_gosterilen + 1 + _r.nextInt(_oyunlar.length - 1)) %
                  _oyunlar.length;
        });
        HapticFeedback.selectionClick();
        if (adim >= adimSayisi) {
          HapticFeedback.mediumImpact();
          setState(() {
            _secilen = oyun;
            _durum = _Durum.acik;
          });
          bitti.complete();
          return;
        }
        bekle = (bekle * 1.14).round();
        _zamanlayici = Timer(Duration(milliseconds: bekle), sonraki);
      }

      sonraki();
      await bitti.future;
    } finally {
      _aliyor = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final acik = _durum == _Durum.acik && _secilen != null;
    final hazir = _durum == _Durum.hazir;
    final renk =
        acik ? OyunKimligi.renk(_secilen!.type) : const Color(0xFFFF8F00);
    final koyuTema = Theme.of(context).brightness == Brightness.dark;
    final d = _gunluk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _t('Günlük sandık', 'Daily chest', 'Tägliche Truhe',
                    'Cofre diario'),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: koyuTema ? Colors.white : const Color(0xFF14161A),
                ),
              ),
            ),
            if (d != null) _gunCipi(d.gun, koyuTema),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          button: hazir,
          label: hazir
              ? _t('Günlük sandığı aç', 'Open the daily chest',
                  'Tägliche Truhe öffnen', 'Abrir el cofre diario')
              : null,
          child: GestureDetector(
            key: const ValueKey('gunluk_sandik'),
            onTap: hazir ? _ac : null,
            child: AnimatedBuilder(
              animation: _bekleme,
              builder: (context, child) {
                final nabiz = hazir
                    ? 0.5 + 0.5 * math.sin(_bekleme.value * math.pi * 2)
                    : 0.0;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  constraints: const BoxConstraints(minHeight: 168),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: RadialGradient(
                      center: const Alignment(-0.5, -0.3),
                      radius: 1.3,
                      colors: acik
                          ? [Color.lerp(renk, Colors.white, 0.35)!, renk]
                          : const [Color(0xFFFFE082), Color(0xFFFF8F00)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.lerp(renk, Colors.black, 0.3)!,
                        offset: const Offset(0, 6),
                      ),
                      if (hazir)
                        BoxShadow(
                          color: const Color(0xFFFFC107)
                              .withValues(alpha: 0.30 + 0.30 * nabiz),
                          blurRadius: 14 + 10 * nabiz,
                          spreadRadius: 1 + 2 * nabiz,
                        ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                // Dar ekranda (360 pt, buyuk yazi) sandik biraz kuculuyor:
                // sag sutun Almanca uzun kelimeleri bolmeden sigsin.
                child: LayoutBuilder(builder: (context, c) {
                  final sol = math.min(140.0, c.maxWidth * 0.38);
                  return Row(
                    children: [
                      SizedBox(width: sol, height: math.max(sol, 120), child: _sol()),
                      const SizedBox(width: 12),
                      Expanded(child: _sag()),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        if (d != null) ...[
          const SizedBox(height: 12),
          _altSatir(d, koyuTema),
        ],
      ],
    );
  }

  Widget _gunCipi(int gun, bool koyuTema) {
    return Container(
      key: const ValueKey('gunluk_sandik_gun'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8F00).withValues(alpha: koyuTema ? 0.25 : 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '🔥 ${_t('$gun. gün', 'Day $gun', 'Tag $gun', 'Día $gun')}',
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: koyuTema ? const Color(0xFFFFCC80) : const Color(0xFFE65100),
        ),
      ),
    );
  }

  /// Kartin alti: hazirken bugunku ve artan odul (oranlar acik), acildiysa
  /// "yarin yeni sandik".
  Widget _altSatir(GunlukSandikDurumu d, bool koyuTema) {
    final hazir = _durum == _Durum.hazir;
    final yarin = GunlukSandikDeposu.odul(d.gun + 1);
    final yazi = hazir
        ? _t(
            'Bugün +${d.odul} jeton · her gün açarsan artar (en çok 10)',
            'Today +${d.odul} coins · grows every day in a row (up to 10)',
            'Heute +${d.odul} Münzen · wächst jeden Tag (bis 10)',
            'Hoy +${d.odul} monedas · crece cada día seguido (hasta 10)')
        : _t(
            'Bugünkü ödülünü aldın · Yarın yeni sandık (+$yarin)',
            "You got today's reward · New chest tomorrow (+$yarin)",
            'Heute schon abgeholt · Morgen neue Truhe (+$yarin)',
            'Premio de hoy recogido · Mañana, cofre nuevo (+$yarin)');
    final renk = koyuTema ? Colors.white70 : const Color(0xFF5F6670);
    return Row(
      key: const ValueKey('gunluk_sandik_alt'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
              hazir ? Icons.info_outline_rounded : Icons.check_circle_rounded,
              size: 16,
              color: hazir ? renk : const Color(0xFF3BA55C)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            yazi,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: renk,
            ),
          ),
        ),
      ],
    );
  }

  /// Sol: hazirken parlayan sandik, acilirken sarsilip isik sacan sandik,
  /// sonra oyunlarin donen kapagi.
  Widget _sol() {
    final sandikGorunur = _durum == _Durum.yukleniyor ||
        _durum == _Durum.hazir ||
        _durum == _Durum.aciliyor;
    final govde = sandikGorunur ? _sandik() : _kapak();
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        govde,
        // Ucan "+N" ve isik patlamasi (acilista; sonra gorunmez).
        AnimatedBuilder(
          animation: _ucus,
          builder: (_, __) {
            final v = _ucus.value;
            if (v <= 0 || v >= 1 || _gunluk == null) {
              return const SizedBox.shrink();
            }
            final patla = (v / 0.35).clamp(0.0, 1.0);
            final yuksel = Curves.easeOutCubic.transform(v);
            final saydam = v < 0.7 ? 1.0 : (1 - (v - 0.7) / 0.3);
            return IgnorePointer(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: (1 - patla).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.3 + 1.4 * patla,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            Colors.white,
                            Color(0x00FFFFFF),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, 10 - 64 * yuksel),
                    child: Opacity(
                      opacity: saydam.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: Motion.overshoot.transform(patla),
                        child: _jetonHapi(_gunluk!.odul, buyuk: true),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _sandik() {
    final hazir = _durum == _Durum.hazir;
    final resim = Image.asset(
      'assets/images/ui/sandik.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.card_giftcard_rounded, size: 90, color: Colors.white),
    );
    return AnimatedBuilder(
      animation: Listenable.merge([_salla, _bekleme]),
      builder: (_, child) {
        double aci = -0.08;
        double olcek = 1;
        if (_durum == _Durum.aciliyor) {
          final s = _salla.value;
          aci += math.sin(s * math.pi * 8) * 0.14 * (1 - s);
          olcek = 1 + 0.12 * math.sin(s * math.pi);
        } else if (hazir) {
          // Her turun ilk ~%30'unda kisa bir kipirti, sonra durgun.
          final b = _bekleme.value;
          if (b < 0.3) {
            final k = b / 0.3;
            aci += math.sin(k * math.pi * 4) * 0.07 * (1 - k);
          }
          olcek = 1 + 0.03 * math.sin(b * math.pi * 2);
        }
        final nabiz = hazir ? 0.5 + 0.5 * math.sin(_bekleme.value * math.pi * 2) : 0.0;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (hazir)
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    Colors.white.withValues(alpha: 0.35 + 0.25 * nabiz),
                    Colors.white.withValues(alpha: 0),
                  ]),
                ),
              ),
            Transform.rotate(
              angle: aci,
              child: Transform.scale(scale: olcek, child: child),
            ),
            if (hazir) ...[
              Positioned(
                top: 6,
                right: 10,
                child: Opacity(
                  opacity: 0.4 + 0.6 * nabiz,
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 20, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 18,
                left: 4,
                child: Opacity(
                  opacity: 1 - 0.6 * nabiz,
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 14, color: Colors.white),
                ),
              ),
            ],
          ],
        );
      },
      child: resim,
    );
  }

  Widget _kapak() {
    if (_oyunlar.isEmpty) return const SizedBox.shrink();
    final g = _oyunlar[_gosterilen.clamp(0, _oyunlar.length - 1)];
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 90),
        transitionBuilder: (c, a) => SlideTransition(
          position:
              Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(a),
          child: c,
        ),
        child: SizedBox.expand(
          key: ValueKey(_gosterilen),
          child: Stack(
            fit: StackFit.expand,
            children: [
              OyunSahnesi(tur: g.type, lang: widget.lang),
              // Oyunlar ekranindaki kartla ayni rozet: bu oyun bir
              // videoyla aciliyor.
              if (_reklamli(g))
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(4, 2, 7, 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded,
                            size: 13, color: Colors.white),
                        Text(
                          _t('Reklamla', 'With ad', 'Mit Werbung',
                              'Con anuncio'),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// "🪙 +5 jeton" hapi.
  Widget _jetonHapi(int n, {bool buyuk = false}) {
    return Container(
      key: buyuk ? const ValueKey('gunluk_sandik_ucan_jeton') : null,
      padding: EdgeInsets.symmetric(
          horizontal: buyuk ? 12 : 9, vertical: buyuk ? 6 : 3),
      decoration: BoxDecoration(
        color: buyuk ? Colors.white : Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        boxShadow: buyuk
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ]
            : null,
      ),
      child: Text(
        '🪙 ${_t('+$n jeton', '+$n coins', '+$n Münzen', '+$n monedas')}',
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: buyuk ? 16 : 12.5,
          fontWeight: FontWeight.w900,
          color: buyuk ? const Color(0xFFE65100) : Colors.white,
        ),
      ),
    );
  }

  Widget _sag() {
    const beyaz = TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white);
    const golge = [Shadow(color: Color(0x33000000), offset: Offset(0, 2))];
    switch (_durum) {
      case _Durum.yukleniyor:
        return const SizedBox.shrink();
      case _Durum.hazir:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _t('Günlük ödülün hazır!', 'Your daily reward is ready!',
                  'Deine Belohnung ist da!', '¡Tu premio diario está listo!'),
              style: beyaz.copyWith(
                  fontSize: 19,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  shadows: golge),
            ),
            const SizedBox(height: 6),
            Text(
              _t('Ödülünü al ve sürpriz oyununu gör',
                  'Claim it and see your surprise game',
                  'Hol sie dir und sieh dein Überraschungsspiel',
                  'Recógelo y mira tu juego sorpresa'),
              style: beyaz.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _hap(Icons.card_giftcard_rounded, _t('Aç', 'Open', 'Öffnen', 'Abrir'),
                const Color(0xFFE65100), _ac,
                anahtar: const ValueKey('gunluk_sandik_ac')),
          ],
        );
      case _Durum.aciliyor:
      case _Durum.karisiyor:
        final g = _oyunlar[_gosterilen.clamp(0, _oyunlar.length - 1)];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Acilirken jeton sandiktan ucuyor; hap karisma basinda gelir.
            if (_gunluk != null && _durum == _Durum.karisiyor) ...[
              _jetonHapi(_gunluk!.odul),
              const SizedBox(height: 8),
            ],
            Text(
                _durum == _Durum.aciliyor
                    ? _t('Sandık açılıyor...', 'Opening...', 'Öffnet sich...',
                        'Abriendo...')
                    : _t('Sürpriz oyun...', 'Surprise game...',
                        'Überraschungsspiel...', 'Juego sorpresa...'),
                style: beyaz.copyWith(fontSize: 12.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            if (_durum == _Durum.karisiyor)
              Text(g.titleFor(widget.lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: beyaz.copyWith(
                      fontSize: 19, height: 1.1, fontWeight: FontWeight.w900)),
          ],
        );
      case _Durum.acik:
        final g = _secilen!;
        final koyu = Color.lerp(OyunKimligi.renk(g.type), Colors.black, 0.3)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_gunluk != null) _jetonHapi(_gunluk!.odul),
            const SizedBox(height: 6),
            Text(
                _t('Bugünün oyunu:', "Today's game:", 'Spiel des Tages:',
                    'Juego de hoy:'),
                style: beyaz.copyWith(fontSize: 12, fontWeight: FontWeight.w800)),
            Text(g.titleFor(widget.lang),
                key: const ValueKey('gunluk_sandik_oyun'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: beyaz.copyWith(
                    fontSize: 19, height: 1.1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            _hap(
                _reklamli(g)
                    ? Icons.smart_display_rounded
                    : Icons.play_arrow_rounded,
                _t('Oyna', 'Play', 'Spielen', 'Jugar'),
                koyu,
                () => widget.onOyna(g),
                anahtar: const ValueKey('gunluk_sandik_oyna')),
          ],
        );
    }
  }

  Widget _hap(IconData simge, String yazi, Color renk, VoidCallback onTap,
      {Key? anahtar}) {
    return GestureDetector(
      key: anahtar,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(simge, size: 18, color: renk),
            const SizedBox(width: 3),
            Flexible(
              child: Text(yazi,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: renk)),
            ),
          ],
        ),
      ),
    );
  }
}
