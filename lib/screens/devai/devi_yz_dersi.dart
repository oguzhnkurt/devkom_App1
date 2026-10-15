import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/sound_service.dart';
import '../../theme.dart';
import '../../ui/motion.dart';
import '../../utils/lang.dart';
import '../../widgets/devi_gokyuzu.dart';
import '../../widgets/mascot.dart';

/// Devi'nin yapay zeka dersi: DevAI'ye ilk girildiginde acilan, hikaye
/// (story) biciminde kisa bir ders. 6-13 yas icin.
///
/// NEDEN HIKAYE BICIMI: Cocuklar bu kaydirma dilini zaten taniyor; ustteki
/// cubuklar dersin ne kadar kisa oldugunu bastan gosteriyor ("dokuz kart,
/// bir dakika"). Ama yalnizca kaydirmali kart degil: dokuz karttan besi
/// oyun. Cocuk bilgisayara kedi-kopek ogretiyor, kartlari ceviriyor,
/// "antrenman" yaptirip dogrulugun artisini goruyor, guvenlik kurallarini
/// isaretliyor, sonda bir soru cevapliyor ve rozet aliyor.
///
/// DURUSTLUK: Devi'nin cevaplari cihazda, elle yazilmis ve gozden
/// gecirilmis bir bilgi tabanindan geliyor (bkz. devchat_screen.dart).
/// Ders Devi'yi "kendi kendine ogrenen" bir model gibi TANITMIYOR;
/// yapay zekayi genel olarak anlatiyor, Devi'nin ne yaptigini ise oldugu
/// gibi soyluyor: sorulari cevaplar, yazilanlar telefonda kalir.
///
/// Etkilesim: sag tarafa dokun = ileri, sol = geri, basili tut = dur.
class DeviYzDersi {
  DeviYzDersi._();

  static const _gorulduAnahtari = 'devi_yz_dersi_goruldu_v1';
  static const _bittiAnahtari = 'devi_yz_dersi_bitti_v1';

  static Future<bool> goruldu() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(_gorulduAnahtari) ?? false;
    } catch (_) {
      return true; // Okuyamiyorsak cocugu her acilista derse sokmayalim.
    }
  }

  static Future<bool> bitti() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(_bittiAnahtari) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _yaz(String k) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(k, true);
    } catch (_) {}
  }

  /// Dersi acar. Donus:
  /// * null: ders yarida kapatildi,
  /// * '': sona gelindi, sohbete gecilsin,
  /// * dolu metin: cocuk bu soruyu Devi'ye sormak istiyor.
  static Future<String?> ac(BuildContext context) async {
    await _yaz(_gorulduAnahtari);
    if (!context.mounted) return null;
    return Navigator.of(context).push<String>(PageRouteBuilder<String>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const DeviYzDersiScreen(),
      transitionsBuilder: (_, a, __, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: c,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(c),
            child: child,
          ),
        );
      },
    ));
  }
}

void _titret(Future<void> Function() f) {
  if (!SoundService.vibrationEnabled) return;
  f().catchError((_) {});
}

/// Her kartin zemin renkleri (gokyuzu kart degistikce renk degistiriyor).
const _zeminler = <List<Color>>[
  [Color(0xFF1B1446), Color(0xFF3A1F7A), Color(0xFF6A2FB0)],
  [Color(0xFF0C1E4A), Color(0xFF13407A), Color(0xFF1B6FA8)],
  [Color(0xFF1F1147), Color(0xFF4B1D7A), Color(0xFFB0306A)],
  [Color(0xFF082B3A), Color(0xFF0E5560), Color(0xFF14806E)],
  [Color(0xFF26104A), Color(0xFF52207E), Color(0xFF8E3BB8)],
  [Color(0xFF2A1240), Color(0xFF6B2A5E), Color(0xFFD0613A)],
  [Color(0xFF0D2340), Color(0xFF1D4F7C), Color(0xFF2E8BB8)],
  [Color(0xFF1A1250), Color(0xFF3D2A8F), Color(0xFF6C4BD1)],
  [Color(0xFF2B1446), Color(0xFF6A2FB0), Color(0xFFFF8A3D)],
];

class _Kart {
  const _Kart({required this.icerik, this.otomatik = false, this.sure = 9});

  final Widget Function(VoidCallback bitti) icerik;

  /// Etkilesimsiz kart: sure dolunca kendiliginden ilerler.
  final bool otomatik;

  /// Saniye.
  final int sure;
}

class DeviYzDersiScreen extends StatefulWidget {
  const DeviYzDersiScreen({super.key});

  @override
  State<DeviYzDersiScreen> createState() => _DeviYzDersiScreenState();
}

class _DeviYzDersiScreenState extends State<DeviYzDersiScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sure =
      AnimationController(vsync: this, duration: const Duration(seconds: 9))
        ..addStatusListener(_sureBitti);

  int _i = 0;
  int _yon = 1;
  final Set<int> _bitenler = {0};
  bool _durdu = false;

  String get _lang => Localizations.localeOf(context).languageCode;
  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  late List<_Kart> _kartlar;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _baslat());
  }

  @override
  void dispose() {
    _sure.dispose();
    super.dispose();
  }

  void _baslat() {
    if (!mounted) return;
    _sure
      ..duration = Duration(seconds: _kartlar[_i].sure)
      ..forward(from: 0);
  }

  void _sureBitti(AnimationStatus s) {
    if (s != AnimationStatus.completed || !mounted) return;
    if (_kartlar[_i].otomatik) _git(_i + 1);
  }

  void _git(int yeni) {
    if (yeni < 0) return;
    if (yeni >= _kartlar.length) {
      Navigator.of(context).pop('');
      return;
    }
    _titret(HapticFeedback.selectionClick);
    setState(() {
      _yon = yeni > _i ? 1 : -1;
      _i = yeni;
      if (_kartlar[yeni].otomatik) _bitenler.add(yeni);
    });
    _baslat();
  }

  void _bitti(int i) {
    if (_bitenler.contains(i)) return;
    setState(() => _bitenler.add(i));
  }

  void _dur(bool d) {
    setState(() => _durdu = d);
    if (d) {
      _sure.stop();
    } else if (_sure.value < 1) {
      _sure.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    _kartlar = _kartlariKur();
    final kart = _kartlar[_i];
    return Scaffold(
      backgroundColor: const Color(0xFF1B1446),
      body: DeviGokyuzu(
        renkler: _zeminler[_i % _zeminler.length],
        yogunluk: 1.2,
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) {
              final w = MediaQuery.sizeOf(context).width;
              if (d.localPosition.dx < w * 0.3) {
                _git(_i - 1);
              } else if (_bitenler.contains(_i)) {
                // Oyun kartinda bos bir yere dokunmak cocugu oyunun
                // ortasindan atmasin; oyun bitince ya da "Devam" ile.
                _git(_i + 1);
              }
            },
            onLongPressStart: (_) => _dur(true),
            onLongPressEnd: (_) => _dur(false),
            child: Column(
              children: [
                _ustCubuk(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, a) {
                      final gelen = child.key == ValueKey(_i);
                      final dx = (gelen ? 0.18 : -0.18) * _yon;
                      return FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                          position: Tween(
                            begin: Offset(dx, 0),
                            end: Offset.zero,
                          ).animate(a),
                          child: ScaleTransition(
                            scale: Tween(begin: 0.95, end: 1.0).animate(a),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_i),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                        child: kart.icerik(() => _bitti(_i)),
                      ),
                    ),
                  ),
                ),
                _altCubuk(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ustCubuk() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 0),
      child: Column(
        children: [
          Row(
            children: [
              for (var k = 0; k < _kartlar.length; k++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    alignment: Alignment.centerLeft,
                    child: k < _i
                        ? const _Dolgu(1)
                        : k == _i
                            ? AnimatedBuilder(
                                animation: _sure,
                                builder: (_, __) => _Dolgu(_sure.value),
                              )
                            : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 4),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Mascot(size: 30, showShadow: false)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    const TextSpan(
                        text: 'Devi  ',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    TextSpan(
                      text: _t('Yapay Zekâ Dersi', 'AI Lesson', 'KI-Lektion',
                          'Lección de IA'),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w700),
                    ),
                  ]),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              if (_durdu)
                const Icon(Icons.pause_rounded,
                    color: Colors.white70, size: 20),
              IconButton(
                key: const ValueKey('yz_kapat'),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _altCubuk() {
    final son = _i == _kartlar.length - 1;
    if (son) return const SizedBox(height: 12);
    final hazir = _bitenler.contains(_i);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 14),
      child: Row(
        children: [
          if (_i == 0)
            Expanded(
              child: Row(
                children: [
                  const _Nabiz(
                    child: Icon(Icons.touch_app_rounded,
                        color: Colors.white70, size: 20),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _t(
                          'Sağa dokun: ileri · Basılı tut: dur',
                          'Tap right: next · Hold: pause',
                          'Rechts tippen: weiter · Halten: Pause',
                          'Toca a la derecha: seguir · Mantén: pausa'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 8),
          _Nabiz(
            calis: hazir,
            child: GestureDetector(
              key: const ValueKey('yz_devam'),
              onTap: () => _git(_i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.fromLTRB(18, 11, 12, 11),
                decoration: BoxDecoration(
                  color: hazir
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _t('Devam', 'Next', 'Weiter', 'Seguir'),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: hazir ? const Color(0xFF4B2A9E) : Colors.white,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: hazir ? const Color(0xFF4B2A9E) : Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- kartlar

  List<_Kart> _kartlariKur() => [
        _Kart(icerik: (_) => _Merhaba(t: _t, ileri: () => _git(1))),
        _Kart(otomatik: true, sure: 11, icerik: (_) => _Nedir(t: _t)),
        _Kart(sure: 20, icerik: (b) => _OgretOyunu(t: _t, bitti: b)),
        _Kart(sure: 16, icerik: (b) => _Nerede(t: _t, bitti: b)),
        _Kart(sure: 14, icerik: (b) => _Antrenman(t: _t, bitti: b)),
        _Kart(otomatik: true, sure: 12, icerik: (_) => _Kod(t: _t)),
        _Kart(sure: 14, icerik: (b) => _Kurallar(t: _t, bitti: b)),
        _Kart(sure: 12, icerik: (b) => _Soru(t: _t, bitti: b)),
        _Kart(
          sure: 10,
          icerik: (_) => _Final(
            t: _t,
            lang: _lang,
            yeniden: () => _git(0),
          ),
        ),
      ];
}

typedef _Ceviri = String Function(String tr, String en, String de, String es);

// ============================================================ ortak parcalar

class _Dolgu extends StatelessWidget {
  const _Dolgu(this.oran);
  final double oran;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
        widthFactor: oran.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

/// Hafifce nefes alan (buyuyup kuculen) sarmalayici.
class _Nabiz extends StatefulWidget {
  const _Nabiz({required this.child, this.calis = true});
  final Widget child;
  final bool calis;

  @override
  State<_Nabiz> createState() => _NabizState();
}

class _NabizState extends State<_Nabiz> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ayarla();
  }

  @override
  void didUpdateWidget(_Nabiz old) {
    super.didUpdateWidget(old);
    _ayarla();
  }

  void _ayarla() {
    if (widget.calis && !Motion.reduced(context)) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.scale(
          scale: 1 + 0.06 * Curves.easeInOut.transform(_c.value),
          child: child,
        ),
        child: widget.child,
      );
}

const _baslikStili = TextStyle(
  fontFamily: AppTheme.fontFamily,
  color: Colors.white,
  fontSize: 30,
  height: 1.08,
  fontWeight: FontWeight.w900,
);

TextStyle _govde([double boy = 16.5]) => TextStyle(
      fontFamily: AppTheme.fontFamily,
      color: Colors.white.withValues(alpha: 0.92),
      fontSize: boy,
      height: 1.35,
      fontWeight: FontWeight.w700,
    );

Widget _baslik(String s) => Text(s, style: _baslikStili);

/// Kucuk "ipucu" hapi: "Kartlara dokun!" gibi.
Widget _ipucu(String s) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        s,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

/// Basinca biraz cokup geri gelen buyuk dugme.
class _Basmali extends StatefulWidget {
  const _Basmali({
    super.key,
    required this.child,
    required this.onTap,
    this.renk = Colors.white,
    this.golge = const Color(0xFFB9A8F0),
  });

  final Widget child;
  final VoidCallback onTap;
  final Color renk;
  final Color golge;

  @override
  State<_Basmali> createState() => _BasmaliState();
}

class _BasmaliState extends State<_Basmali> {
  bool _basili = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _basili = true),
      onTapCancel: () => setState(() => _basili = false),
      onTapUp: (_) {
        setState(() => _basili = false);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, _basili ? 4 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.renk,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: widget.golge,
              offset: Offset(0, _basili ? 1 : 5),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Sallanma (yanlis cevap).
class _Salla extends StatelessWidget {
  const _Salla({required this.tetik, required this.child});
  final int tetik;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        key: ValueKey(tetik),
        tween: Tween(begin: tetik == 0 ? 1 : 0, end: 1),
        duration: const Duration(milliseconds: 420),
        builder: (_, v, c) => Transform.translate(
          offset: Offset(math.sin(v * math.pi * 6) * 10 * (1 - v), 0),
          child: c,
        ),
        child: child,
      );
}

/// Patlayan parilti (dogru cevap, rozet).
class _Parilti extends StatefulWidget {
  const _Parilti({required this.tetik, this.adet = 22});
  final int tetik;
  final int adet;

  @override
  State<_Parilti> createState() => _PariltiState();
}

class _PariltiState extends State<_Parilti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300));

  @override
  void didUpdateWidget(_Parilti old) {
    super.didUpdateWidget(old);
    if (widget.tetik != old.tetik && widget.tetik > 0) _c.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    if (widget.tetik > 0) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => CustomPaint(
            size: Size.infinite,
            painter: _PariltiRessami(_c.value, widget.adet, widget.tetik),
          ),
        ),
      );
}

class _PariltiRessami extends CustomPainter {
  _PariltiRessami(this.v, this.adet, this.tohum);
  final double v;
  final int adet;
  final int tohum;

  static const _renkler = [
    Color(0xFFFFD54F),
    Color(0xFF4DD0E1),
    Color(0xFFFF80AB),
    Color(0xFFB2FF59),
    Colors.white,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (v == 0 || v == 1) return;
    final r = math.Random(tohum);
    final merkez = Offset(size.width / 2, size.height * 0.42);
    final e = Curves.easeOutCubic.transform(v);
    for (var i = 0; i < adet; i++) {
      final aci = r.nextDouble() * math.pi * 2;
      final hiz = 80 + r.nextDouble() * 140;
      final p = merkez +
          Offset(math.cos(aci), math.sin(aci)) * hiz * e +
          Offset(0, 90 * v * v);
      final paint = Paint()
        ..color = _renkler[i % _renkler.length].withValues(alpha: 1 - v);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(aci + v * 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-4, -2, 8, 4), const Radius.circular(1.5)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PariltiRessami o) => o.v != v || o.tohum != tohum;
}

// ================================================================== 1 Merhaba

class _Merhaba extends StatefulWidget {
  const _Merhaba({required this.t, required this.ileri});
  final _Ceviri t;
  final VoidCallback ileri;

  @override
  State<_Merhaba> createState() => _MerhabaState();
}

class _MerhabaState extends State<_Merhaba>
    with SingleTickerProviderStateMixin {
  late final AnimationController _yorunge =
      AnimationController(vsync: this, duration: const Duration(seconds: 9));
  int _dokunus = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!Motion.reduced(context) && !_yorunge.isAnimating) _yorunge.repeat();
  }

  @override
  void dispose() {
    _yorunge.dispose();
    super.dispose();
  }

  List<String> get _sozler => [
        widget.t('Merhaba! Ben Devi 👋', "Hi! I'm Devi 👋",
            'Hallo! Ich bin Devi 👋', '¡Hola! Soy Devi 👋'),
        widget.t('Hihi, gıdıklanıyorum! 😄', 'Hehe, that tickles! 😄',
            'Hihi, das kitzelt! 😄', '¡Jiji, me haces cosquillas! 😄'),
        widget.t('Bir dokunuş daha, uçuyorum! 🚀', 'One more tap and I fly! 🚀',
            'Noch einmal und ich fliege! 🚀', '¡Un toque más y vuelo! 🚀'),
        widget.t(
            'Tamam tamam, derse başlayalım! 🤓',
            'Okay okay, let’s start! 🤓',
            'Okay, okay, los geht’s! 🤓',
            '¡Vale, vale, empecemos! 🤓'),
      ];

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    const simgeler = ['💡', '🧠', '🤖', '⭐', '🎮', '🔍'];
    return Column(
      children: [
        const Spacer(),
        // Konusma balonu.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Container(
            key: ValueKey(_dokunus % _sozler.length),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              _sozler[_dokunus % _sozler.length],
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3A1F7A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 270,
          height: 250,
          child: AnimatedBuilder(
            animation: _yorunge,
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                for (var k = 0; k < simgeler.length; k++)
                  Transform.translate(
                    offset: Offset(
                      math.cos(_yorunge.value * math.pi * 2 + k * math.pi / 3) *
                          118,
                      math.sin(_yorunge.value * math.pi * 2 + k * math.pi / 3) *
                          92,
                    ),
                    child:
                        Text(simgeler[k], style: const TextStyle(fontSize: 26)),
                  ),
                Mascot(
                  size: 160,
                  onTap: () {
                    _titret(HapticFeedback.lightImpact);
                    setState(() => _dokunus++);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          t('Yapay Zekâ\nDersi', 'The AI\nLesson', 'Die KI-\nLektion',
              'La lección\nde IA'),
          textAlign: TextAlign.center,
          style: _baslikStili.copyWith(fontSize: 38),
        ),
        const SizedBox(height: 10),
        Text(
          t(
              'Bir dakikada yapay zekâyı birlikte keşfedelim. Hazır mısın?',
              'Let’s explore AI together in one minute. Ready?',
              'Lass uns KI in einer Minute entdecken. Bereit?',
              'Descubramos la IA juntos en un minuto. ¿Listo?'),
          textAlign: TextAlign.center,
          style: _govde(),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _ipucu(t('⏱ 1 dakika', '⏱ 1 minute', '⏱ 1 Minute', '⏱ 1 minuto')),
            _ipucu(t('🎮 5 mini oyun', '🎮 5 mini games', '🎮 5 Minispiele',
                '🎮 5 minijuegos')),
            _ipucu(t('🏅 Rozet', '🏅 Badge', '🏅 Abzeichen', '🏅 Insignia')),
          ],
        ),
        const Spacer(),
        _Basmali(
          key: const ValueKey('yz_hazirim'),
          onTap: widget.ileri,
          child: Center(
            child: Text(
              t('Hazırım! 🚀', 'I’m ready! 🚀', 'Bereit! 🚀',
                  '¡Estoy listo! 🚀'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4B2A9E),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

// ==================================================================== 2 Nedir

class _Nedir extends StatefulWidget {
  const _Nedir({required this.t});
  final _Ceviri t;

  @override
  State<_Nedir> createState() => _NedirState();
}

class _NedirState extends State<_Nedir> with TickerProviderStateMixin {
  late final AnimationController _akis = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400));
  late final AnimationController _patla = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
  int _tur = 0;

  static const _girdiler = ['🐱', '🍎', '🐶'];

  @override
  void initState() {
    super.initState();
    _akis.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _tur++);
        _akis.forward(from: 0);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!Motion.reduced(context) && !_akis.isAnimating) _akis.forward();
  }

  @override
  void dispose() {
    _akis.dispose();
    _patla.dispose();
    super.dispose();
  }

  String _cikti() {
    final t = widget.t;
    switch (_tur % 3) {
      case 0:
        return t('Kedi!', 'Cat!', 'Katze!', '¡Gato!');
      case 1:
        return t('Elma!', 'Apple!', 'Apfel!', '¡Manzana!');
      default:
        return t('Köpek!', 'Dog!', 'Hund!', '¡Perro!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _baslik(t('Yapay zekâ nedir?', 'What is AI?', 'Was ist KI?',
            '¿Qué es la IA?')),
        const SizedBox(height: 12),
        Text(
          t(
              'Bilgisayarın ÖRNEKLERDEN öğrenip TAHMİN yapmasına yapay zekâ denir.',
              'AI is when a computer learns from EXAMPLES and makes GUESSES.',
              'KI heißt: Ein Computer lernt aus BEISPIELEN und trifft VORHERSAGEN.',
              'La IA es cuando un ordenador aprende de EJEMPLOS y hace PREDICCIONES.'),
          style: _govde(19),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _titret(HapticFeedback.mediumImpact);
              _patla.forward(from: 0);
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([_akis, _patla]),
              builder: (_, __) => CustomPaint(
                painter: _AgRessami(_akis.value, _patla.value),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Center(
                        child: Text(_girdiler[_tur % 3],
                            style: const TextStyle(fontSize: 44)),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 86,
                      child: Opacity(
                        opacity: _akis.value > 0.72 ? 1 : 0.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _cikti(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF13407A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Text(
          t(
              'Tıpkı senin gibi: bir şeyi çok görünce hemen tanırsın! 👀',
              'Just like you: see something often and you recognise it! 👀',
              'Genau wie du: Was du oft siehst, erkennst du sofort! 👀',
              '¡Como tú: si ves algo muchas veces, lo reconoces! 👀'),
          style: _govde(),
        ),
        const SizedBox(height: 10),
        _ipucu(t('🧠 Beyne dokun!', '🧠 Tap the brain!', '🧠 Tipp aufs Gehirn!',
            '🧠 ¡Toca el cerebro!')),
        const SizedBox(height: 6),
      ],
    );
  }
}

/// Uc katmanli kucuk bir sinir agi; sinyal soldan saga akiyor.
class _AgRessami extends CustomPainter {
  _AgRessami(this.v, this.patla);
  final double v;
  final double patla;

  @override
  void paint(Canvas canvas, Size size) {
    final katmanlar = [3, 4, 4, 2];
    final x0 = 80.0, x1 = size.width - 100;
    final noktalar = <List<Offset>>[];
    for (var k = 0; k < katmanlar.length; k++) {
      final x = x0 + (x1 - x0) * k / (katmanlar.length - 1);
      final n = katmanlar[k];
      noktalar.add([
        for (var j = 0; j < n; j++)
          Offset(x, size.height / 2 + (j - (n - 1) / 2) * 52),
      ]);
    }
    final cizgi = Paint()..strokeWidth = 1.4;
    final sinyal = Paint()..color = const Color(0xFF7FF6FF);
    for (var k = 0; k < noktalar.length - 1; k++) {
      final bas = k / (noktalar.length - 1);
      final son = (k + 1) / (noktalar.length - 1);
      final yerel = ((v - bas) / (son - bas)).clamp(0.0, 1.0);
      for (final a in noktalar[k]) {
        for (final b in noktalar[k + 1]) {
          cizgi.color = Colors.white.withValues(alpha: 0.18 + 0.3 * patla);
          canvas.drawLine(a, b, cizgi);
          if (yerel > 0 && yerel < 1) {
            canvas.drawCircle(Offset.lerp(a, b, yerel)!, 2.6, sinyal);
          }
        }
      }
    }
    for (var k = 0; k < noktalar.length; k++) {
      final aktif = v >= k / (noktalar.length - 1);
      for (final p in noktalar[k]) {
        final r = 9 + 6 * math.sin(patla * math.pi);
        canvas.drawCircle(
          p,
          r + 6,
          Paint()
            ..color =
                const Color(0xFF7FF6FF).withValues(alpha: aktif ? 0.25 : 0.06),
        );
        canvas.drawCircle(
          p,
          r,
          Paint()
            ..color =
                aktif ? Colors.white : Colors.white.withValues(alpha: 0.4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AgRessami o) => o.v != v || o.patla != patla;
}

// ============================================================= 3 Ogret oyunu

class _OgretOyunu extends StatefulWidget {
  const _OgretOyunu({required this.t, required this.bitti});
  final _Ceviri t;
  final VoidCallback bitti;

  @override
  State<_OgretOyunu> createState() => _OgretOyunuState();
}

class _OgretOyunuState extends State<_OgretOyunu> {
  // (emoji, kedi mi)
  static const _ornekler = [
    ('🐱', true),
    ('🐶', false),
    ('😺', true),
    ('🐕', false)
  ];

  int _sira = 0;
  int _hata = 0;
  int _salla = 0;
  int _parilti = 0;
  String? _uyari;

  /// 0: ogretiliyor, 1: dusunuyor, 2: sonuc.
  int _evre = 0;
  Timer? _zaman;

  @override
  void dispose() {
    _zaman?.cancel();
    super.dispose();
  }

  int get _guven => (96 - _hata * 7).clamp(68, 96);

  void _cevap(bool kedi) {
    if (_evre != 0) return;
    final dogru = _ornekler[_sira].$2 == kedi;
    if (!dogru) {
      SoundService.playWrong();
      setState(() {
        _hata++;
        _salla++;
        _uyari = widget.t(
          'Hmm, emin misin? Yanlış örnek yapay zekâyı şaşırtır! 🤔',
          'Hmm, are you sure? Wrong examples confuse an AI! 🤔',
          'Hmm, sicher? Falsche Beispiele verwirren eine KI! 🤔',
          'Mmm, ¿seguro? ¡Los ejemplos erróneos confunden a la IA! 🤔',
        );
      });
      return;
    }
    _titret(HapticFeedback.lightImpact);
    setState(() {
      _uyari = null;
      _sira++;
    });
    if (_sira == _ornekler.length) {
      setState(() => _evre = 1);
      _zaman = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        SoundService.playCorrect();
        setState(() {
          _evre = 2;
          _parilti++;
        });
        widget.bitti();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            _baslik(t('Bilgisayara öğret!', 'Teach the computer!',
                'Bring es dem Computer bei!', '¡Enséñale al ordenador!')),
            const SizedBox(height: 8),
            Text(
              t(
                  'Her resim için doğru düğmeye bas. Sen örnek ver, o öğrensin.',
                  'Press the right button for each picture. You give examples, it learns.',
                  'Drück für jedes Bild den richtigen Knopf. Du gibst Beispiele, sie lernt.',
                  'Pulsa el botón correcto en cada foto. Tú das ejemplos, ella aprende.'),
              style: _govde(),
            ),
            const SizedBox(height: 14),
            // Hafiza: ogretilen ornekler.
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    t('Hafıza', 'Memory', 'Speicher', 'Memoria'),
                    style: _govde(14),
                  ),
                  const Spacer(),
                  for (var k = 0; k < _ornekler.length; k++)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: k < _sira ? 1 : 0.18,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.elasticOut,
                        scale: k < _sira ? 1 : 0.7,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(_ornekler[k].$1,
                              style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: Center(child: _orta())),
            if (_uyari != null && _evre == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_uyari!,
                    textAlign: TextAlign.center, style: _govde(14.5)),
              ),
            if (_evre == 0)
              Row(
                children: [
                  Expanded(
                    child: _Basmali(
                      key: const ValueKey('yz_kedi'),
                      onTap: () => _cevap(true),
                      child: Center(
                        child: Text(
                            t('🐱 Kedi', '🐱 Cat', '🐱 Katze', '🐱 Gato'),
                            style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB0306A))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Basmali(
                      key: const ValueKey('yz_kopek'),
                      onTap: () => _cevap(false),
                      child: Center(
                        child: Text(
                            t('🐶 Köpek', '🐶 Dog', '🐶 Hund', '🐶 Perro'),
                            style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4B1D7A))),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 6),
          ],
        ),
        Positioned.fill(child: _Parilti(tetik: _parilti, adet: 30)),
      ],
    );
  }

  Widget _orta() {
    final t = widget.t;
    if (_evre == 0) {
      final o = _ornekler[_sira];
      return _Salla(
        tetik: _salla,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) => ScaleTransition(
              scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
              child: c),
          child: Container(
            key: ValueKey(_sira),
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(o.$1, style: const TextStyle(fontSize: 84)),
                Text(
                  '${t('Örnek', 'Example', 'Beispiel', 'Ejemplo')} ${_sira + 1}/4',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8A85A0),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_evre == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🐈', style: TextStyle(fontSize: 90)),
          const SizedBox(height: 8),
          Text(
            t(
                'Yeni bir resim! Yapay zekâ düşünüyor…',
                'A new picture! The AI is thinking…',
                'Ein neues Bild! Die KI denkt nach…',
                '¡Una foto nueva! La IA está pensando…'),
            textAlign: TextAlign.center,
            style: _govde(17),
          ),
          const SizedBox(height: 12),
          const SizedBox(
            width: 34,
            height: 34,
            child:
                CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ),
        ],
      );
    }
    return Column(
      key: const ValueKey('yz_ogret_sonuc'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🐈', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            t(
                'Bu bir KEDİ! · %$_guven emin',
                'It’s a CAT! · $_guven% sure',
                'Das ist eine KATZE! · $_guven % sicher',
                '¡Es un GATO! · $_guven % segura'),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFFB0306A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t(
              'Sen öğrettin, o öğrendi! 🎉\nHiç "kedi kuralı" yazmadın; örnekler yetti.',
              'You taught, it learned! 🎉\nYou never wrote a “cat rule”; examples were enough.',
              'Du hast gelehrt, sie hat gelernt! 🎉\nKeine „Katzenregel“ nötig – Beispiele reichten.',
              '¡Tú enseñaste y ella aprendió! 🎉\nNo escribiste ninguna “regla de gato”; bastaron los ejemplos.'),
          textAlign: TextAlign.center,
          style: _govde(16),
        ),
      ],
    );
  }
}

// ================================================================== 4 Nerede

class _Nerede extends StatefulWidget {
  const _Nerede({required this.t, required this.bitti});
  final _Ceviri t;
  final VoidCallback bitti;

  @override
  State<_Nerede> createState() => _NeredeState();
}

class _NeredeState extends State<_Nerede> {
  final Set<int> _acik = {};

  List<(String, String, String)> get _kartlar {
    final t = widget.t;
    return [
      (
        '🗺️',
        t('Harita', 'Maps', 'Karten', 'Mapas'),
        t('En hızlı yolu tahmin eder.', 'Guesses the fastest route.',
            'Schätzt den schnellsten Weg.', 'Calcula la ruta más rápida.')
      ),
      (
        '🌍',
        t('Çeviri', 'Translation', 'Übersetzen', 'Traducción'),
        t('Bir dili başka dile çevirir.', 'Turns one language into another.',
            'Macht aus einer Sprache eine andere.', 'Pasa de un idioma a otro.')
      ),
      (
        '🎤',
        t('Sesli asistan', 'Voice assistant', 'Sprachassistent',
            'Asistente de voz'),
        t('Konuşmanı yazıya döker.', 'Turns your voice into text.',
            'Macht aus Sprache Text.', 'Convierte tu voz en texto.')
      ),
      (
        '🩺',
        t('Doktorlar', 'Doctors', 'Ärzte', 'Médicos'),
        t('Röntgenleri incelemeye yardım eder.', 'Helps look at X-rays.',
            'Hilft bei Röntgenbildern.', 'Ayuda a revisar radiografías.')
      ),
      (
        '🎬',
        t('Öneriler', 'Suggestions', 'Vorschläge', 'Sugerencias'),
        t(
            'Sevebileceğin videoları önerir.',
            'Suggests videos you may like.',
            'Schlägt Videos vor, die dir gefallen.',
            'Sugiere vídeos que te pueden gustar.')
      ),
      (
        '♟️',
        t('Satranç', 'Chess', 'Schach', 'Ajedrez'),
        t(
            'Uygulamamızdaki satranç rakibin de bir oyun yapay zekâsı!',
            'Your chess opponent in our app is a game AI too!',
            'Dein Schachgegner in unserer App ist auch eine Spiel-KI!',
            '¡Tu rival de ajedrez en nuestra app también es una IA!')
      ),
    ];
  }

  void _cevir(int k) {
    _titret(HapticFeedback.lightImpact);
    setState(() {
      if (!_acik.remove(k)) _acik.add(k);
    });
    if (_acik.length >= 3) widget.bitti();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final kartlar = _kartlar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _baslik(t('Yapay zekâ nerede?', 'Where is AI?', 'Wo steckt KI?',
            '¿Dónde está la IA?')),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                  t('Kartlara dokun, çevir!', 'Tap the cards to flip!',
                      'Tipp die Karten an!', '¡Toca las cartas!'),
                  style: _govde()),
            ),
            _ipucu('${_acik.length}/6 ✨'),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.08,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var k = 0; k < kartlar.length; k++)
                GestureDetector(
                  key: ValueKey('yz_nerede_$k'),
                  onTap: () => _cevir(k),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: _acik.contains(k) ? 1 : 0),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeInOutBack,
                    builder: (_, v, __) {
                      final arka = v > 0.5;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(v * math.pi),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(arka ? math.pi : 0),
                          child: _neredeKart(kartlar[k], arka),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _neredeKart((String, String, String) k, bool arka) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: arka ? Colors.white : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
      ),
      child: arka
          ? Center(
              child: Text(
                k.$3,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14.5,
                  height: 1.3,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0E5560),
                ),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(k.$1, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 6),
                Text(
                  k.$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}

// =============================================================== 5 Antrenman

class _Antrenman extends StatefulWidget {
  const _Antrenman({required this.t, required this.bitti});
  final _Ceviri t;
  final VoidCallback bitti;

  @override
  State<_Antrenman> createState() => _AntrenmanState();
}

class _AntrenmanState extends State<_Antrenman>
    with SingleTickerProviderStateMixin {
  static const _dogruluk = [35, 58, 76, 88, 95, 98];
  int _seviye = 0;
  int _parilti = 0;

  late final AnimationController _don = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!Motion.reduced(context) && !_don.isAnimating) _don.repeat();
  }

  @override
  void dispose() {
    _don.dispose();
    super.dispose();
  }

  void _antrenman() {
    if (_seviye >= _dogruluk.length - 1) return;
    _titret(HapticFeedback.mediumImpact);
    setState(() => _seviye++);
    // Antrenman arttikca dongu hizlaniyor.
    _don.duration = Duration(milliseconds: 3200 - _seviye * 450);
    if (!Motion.reduced(context)) _don.repeat();
    if (_seviye == _dogruluk.length - 1) {
      SoundService.playCorrect();
      setState(() => _parilti++);
      widget.bitti();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final adimlar = [
      t('📚 Örnek', '📚 Example', '📚 Beispiel', '📚 Ejemplo'),
      t('🤔 Tahmin', '🤔 Guess', '🤔 Raten', '🤔 Predicción'),
      t('✅ Kontrol', '✅ Check', '✅ Prüfen', '✅ Comprobar'),
      t('🔧 Düzelt', '🔧 Fix', '🔧 Verbessern', '🔧 Corregir'),
    ];
    final yuzde = _dogruluk[_seviye];
    final usta = _seviye == _dogruluk.length - 1;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            _baslik(t('Nasıl öğrenir?', 'How does it learn?', 'Wie lernt sie?',
                '¿Cómo aprende?')),
            const SizedBox(height: 8),
            Text(
              t(
                  'Bu döngü binlerce kez döner. Antrenman yaptır, doğruluğu izle!',
                  'This loop runs thousands of times. Train it and watch the accuracy!',
                  'Diese Schleife läuft tausende Male. Trainiere und sieh zu!',
                  'Este ciclo se repite miles de veces. ¡Entrénala y mira la precisión!'),
              style: _govde(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (_, k) {
                  final r = math.min(k.maxWidth / 2 - 58, k.maxHeight * 0.36);
                  return Center(
                    child: AnimatedBuilder(
                      animation: _don,
                      builder: (_, __) => Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          CustomPaint(
                            size: Size(r * 2, r * 2),
                            painter: _DonguRessami(_don.value),
                          ),
                          for (var a = 0; a < 4; a++)
                            Transform.translate(
                              offset: Offset(
                                math.cos(-math.pi / 2 + a * math.pi / 2) * r,
                                math.sin(-math.pi / 2 + a * math.pi / 2) * r,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  adimlar[a],
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF52207E),
                                  ),
                                ),
                              ),
                            ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(end: yuzde.toDouble()),
                                duration: const Duration(milliseconds: 600),
                                builder: (_, v, __) => Text(
                                  '%${v.round()}',
                                  key: const ValueKey('yz_dogruluk'),
                                  style: _baslikStili.copyWith(fontSize: 44),
                                ),
                              ),
                              Text(
                                t('doğruluk', 'accuracy', 'Genauigkeit',
                                    'precisión'),
                                style: _govde(13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Text(
              usta
                  ? t(
                      'Pratik = ustalık! Senin derslerde yaptığın da tam bu. 💡',
                      'Practice = mastery! That is exactly what you do in lessons. 💡',
                      'Übung macht den Meister! Genau das machst du in den Lektionen. 💡',
                      '¡Práctica = maestría! Es justo lo que haces en las lecciones. 💡')
                  : t(
                      'Her antrenman bir tur daha demek.',
                      'Each training is one more loop.',
                      'Jedes Training ist eine Runde mehr.',
                      'Cada entrenamiento es una vuelta más.'),
              style: _govde(15.5),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: usta ? 0.45 : 1,
              child: _Basmali(
                key: const ValueKey('yz_antrenman'),
                onTap: _antrenman,
                golge: const Color(0xFF6B2AA0),
                renk: const Color(0xFFFFD54F),
                child: Center(
                  child: Text(
                    t('💪 Antrenman yap', '💪 Train it', '💪 Trainieren',
                        '💪 Entrenar'),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4A2A00),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
        Positioned.fill(child: _Parilti(tetik: _parilti)),
      ],
    );
  }
}

class _DonguRessami extends CustomPainter {
  _DonguRessami(this.v);
  final double v;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = Colors.white.withValues(alpha: 0.18),
    );
    final aci = -math.pi / 2 + v * math.pi * 2;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      aci - 1.1,
      1.1,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: aci - 1.1,
          endAngle: aci,
          colors: const [Color(0x00FFD54F), Color(0xFFFFD54F)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(c + Offset(math.cos(aci), math.sin(aci)) * r, 8,
        Paint()..color = const Color(0xFFFFD54F));
  }

  @override
  bool shouldRepaint(_DonguRessami o) => o.v != v;
}

// ===================================================================== 6 Kod

class _Kod extends StatefulWidget {
  const _Kod({required this.t});
  final _Ceviri t;

  @override
  State<_Kod> createState() => _KodState();
}

class _KodState extends State<_Kod> {
  int _sallanan = -1;
  int _tetik = 0;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final bloklar = <(String, Color)>[
      (
        t('bayrağa tıklanınca', 'when flag clicked', 'Wenn Fahne angeklickt',
            'al hacer clic en la bandera'),
        const Color(0xFFFFBF00)
      ),
      (
        t(
            'eğer  ⟨ sivri kulak var ⟩  ise',
            'if  ⟨ pointy ears ⟩  then',
            'falls  ⟨ spitze Ohren ⟩  dann',
            'si  ⟨ orejas puntiagudas ⟩  entonces'),
        const Color(0xFFFFAB19)
      ),
      (
        t('   söyle  “Kedi!”', '   say  “Cat!”', '   sage  „Katze!“',
            '   decir  «¡Gato!»'),
        const Color(0xFF9966FF)
      ),
      (t('değilse', 'else', 'sonst', 'si no'), const Color(0xFFFFAB19)),
      (
        t('   söyle  “Köpek!”', '   say  “Dog!”', '   sage  „Hund!“',
            '   decir  «¡Perro!»'),
        const Color(0xFF9966FF)
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _baslik(t('Sihir değil, kod! ✨', 'Not magic, code! ✨',
            'Keine Magie, Code! ✨', '¡No es magia, es código! ✨')),
        const SizedBox(height: 10),
        Text(
          t(
              'Yapay zekâyı yapan mühendisler de kodlamaya tıpkı senin gibi küçük bloklarla başladı.',
              'The engineers who build AI started coding just like you, with small blocks.',
              'Die Leute, die KI bauen, haben genau wie du mit kleinen Blöcken angefangen.',
              'Los ingenieros que crean IA empezaron como tú, con bloques pequeños.'),
          style: _govde(17),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var k = 0; k < bloklar.length; k++)
                  TweenAnimationBuilder<double>(
                    key: ValueKey('blok_$k'),
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 500 + k * 260),
                    curve: Interval(k * 0.14, 1, curve: Curves.easeOutBack),
                    builder: (_, v, child) => Opacity(
                      opacity: v.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, -40 * (1 - v)),
                        child: child,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _titret(HapticFeedback.selectionClick);
                        setState(() {
                          _sallanan = k;
                          _tetik++;
                        });
                      },
                      child: _Salla(
                        tetik: _sallanan == k ? _tetik : 0,
                        child: Container(
                          margin: EdgeInsets.only(
                              left: (k == 2 || k == 4) ? 22 : 0, bottom: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: bloklar[k].$2,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color.lerp(
                                    bloklar[k].$2, Colors.black, 0.3)!,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            bloklar[k].$1.trim(),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            t(
                'DevEducation’da Scratch, mBlock, Arduino ve Python ile sen de aynı yoldasın! 🚀',
                'With Scratch, mBlock, Arduino and Python on DevEducation, you are on the same path! 🚀',
                'Mit Scratch, mBlock, Arduino und Python in DevEducation bist du auf demselben Weg! 🚀',
                '¡Con Scratch, mBlock, Arduino y Python en DevEducation vas por el mismo camino! 🚀'),
            style: _govde(15.5).copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

// ================================================================ 7 Kurallar

class _Kurallar extends StatefulWidget {
  const _Kurallar({required this.t, required this.bitti});
  final _Ceviri t;
  final VoidCallback bitti;

  @override
  State<_Kurallar> createState() => _KurallarState();
}

class _KurallarState extends State<_Kurallar> {
  final Set<int> _tamam = {};
  int _parilti = 0;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final kurallar = [
      (
        '🔒',
        t(
            'Adını soyadını, adresini, okulunu ve şifreni yazma.',
            'Never type your full name, address, school or passwords.',
            'Schreib nie vollen Namen, Adresse, Schule oder Passwörter.',
            'No escribas tu nombre completo, dirección, colegio ni contraseñas.')
      ),
      (
        '🤔',
        t(
            'Yapay zekâ da yanılabilir. Önemli bilgiyi kontrol et.',
            'AI can be wrong too. Check important facts.',
            'Auch KI kann irren. Prüfe Wichtiges nach.',
            'La IA también se equivoca. Comprueba lo importante.')
      ),
      (
        '🙋',
        t(
            'Emin değilsen bir büyüğüne sor.',
            'Not sure? Ask an adult.',
            'Unsicher? Frag einen Erwachsenen.',
            '¿Dudas? Pregunta a un adulto.')
      ),
    ];
    final hepsi = _tamam.length == kurallar.length;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            _baslik(t('Akıllı kullanıcı kuralları', 'Smart user rules',
                'Regeln für kluge Nutzer', 'Reglas del usuario listo')),
            const SizedBox(height: 8),
            Text(
                t(
                    'Her kurala dokun, söz ver! ✋',
                    'Tap each rule to promise! ✋',
                    'Tipp jede Regel an und versprich es! ✋',
                    '¡Toca cada regla y promételo! ✋'),
                style: _govde()),
            const SizedBox(height: 18),
            for (var k = 0; k < kurallar.length; k++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  key: ValueKey('yz_kural_$k'),
                  onTap: () {
                    if (_tamam.contains(k)) return;
                    _titret(HapticFeedback.mediumImpact);
                    setState(() => _tamam.add(k));
                    if (_tamam.length == kurallar.length) {
                      SoundService.playCorrect();
                      setState(() => _parilti++);
                      widget.bitti();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _tamam.contains(k)
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Text(kurallar[k].$1,
                            style: const TextStyle(fontSize: 30)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            kurallar[k].$2,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15.5,
                              height: 1.3,
                              fontWeight: FontWeight.w800,
                              color: _tamam.contains(k)
                                  ? const Color(0xFF1D4F7C)
                                  : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.elasticOut,
                          scale: _tamam.contains(k) ? 1 : 0,
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFF2EBD85),
                            child: Icon(Icons.check_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const Spacer(),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: hepsi ? 1 : 0,
              child: Center(
                child: Text(
                  t(
                      'Süpersin! Artık güvenli bir kâşifsin 🛡️',
                      'Super! You are a safe explorer now 🛡️',
                      'Super! Du bist jetzt ein sicherer Entdecker 🛡️',
                      '¡Genial! Ya eres un explorador seguro 🛡️'),
                  textAlign: TextAlign.center,
                  style: _govde(18).copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
        Positioned.fill(child: _Parilti(tetik: _parilti)),
      ],
    );
  }
}

// ==================================================================== 8 Soru

class _Soru extends StatefulWidget {
  const _Soru({required this.t, required this.bitti});
  final _Ceviri t;
  final VoidCallback bitti;

  @override
  State<_Soru> createState() => _SoruState();
}

class _SoruState extends State<_Soru> {
  int? _yanlis;
  bool _dogru = false;
  int _salla = 0;
  int _parilti = 0;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final secenekler = [
      (
        t('🪄 Sihirle', '🪄 By magic', '🪄 Durch Zauberei', '🪄 Con magia'),
        false
      ),
      (
        t('📚 Örneklerden', '📚 From examples', '📚 Aus Beispielen',
            '📚 Con ejemplos'),
        true
      ),
      (
        t('😴 Uyuyarak', '😴 By sleeping', '😴 Im Schlaf', '😴 Durmiendo'),
        false
      ),
    ];
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            _ipucu(t('⚡ Hızlı soru', '⚡ Quick quiz', '⚡ Schnelle Frage',
                '⚡ Pregunta rápida')),
            const SizedBox(height: 14),
            _baslik(t('Yapay zekâ nasıl öğrenir?', 'How does AI learn?',
                'Wie lernt eine KI?', '¿Cómo aprende una IA?')),
            const SizedBox(height: 24),
            for (var k = 0; k < secenekler.length; k++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _Salla(
                  tetik: _yanlis == k ? _salla : 0,
                  child: SizedBox(
                    width: double.infinity,
                    child: _Basmali(
                      key: ValueKey('yz_secenek_$k'),
                      renk: _dogru && secenekler[k].$2
                          ? const Color(0xFF2EBD85)
                          : _yanlis == k
                              ? const Color(0xFFFFCDD2)
                              : Colors.white,
                      golge: const Color(0xFF2B1A6B),
                      onTap: () {
                        if (_dogru) return;
                        if (secenekler[k].$2) {
                          SoundService.playCorrect();
                          setState(() {
                            _dogru = true;
                            _parilti++;
                          });
                          widget.bitti();
                        } else {
                          SoundService.playWrong();
                          setState(() {
                            _yanlis = k;
                            _salla++;
                          });
                        }
                      },
                      child: Text(
                        secenekler[k].$1,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: _dogru && secenekler[k].$2
                              ? Colors.white
                              : const Color(0xFF3D2A8F),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                _dogru
                    ? t(
                        'Doğru! Örnek → tahmin → düzelt. Artık biliyorsun! 🎉',
                        'Correct! Example → guess → fix. Now you know! 🎉',
                        'Richtig! Beispiel → raten → verbessern. Jetzt weißt du es! 🎉',
                        '¡Correcto! Ejemplo → predicción → corregir. ¡Ya lo sabes! 🎉')
                    : _yanlis != null
                        ? t(
                            'Neredeyse! Bir daha dene 💪',
                            'Almost! Try again 💪',
                            'Fast! Versuch es nochmal 💪',
                            '¡Casi! Inténtalo otra vez 💪')
                        : '',
                key: ValueKey('$_dogru$_yanlis'),
                style: _govde(17).copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        Positioned.fill(child: _Parilti(tetik: _parilti, adet: 34)),
      ],
    );
  }
}

// =================================================================== 9 Final

class _Final extends StatefulWidget {
  const _Final({required this.t, required this.lang, required this.yeniden});
  final _Ceviri t;
  final String lang;
  final VoidCallback yeniden;

  @override
  State<_Final> createState() => _FinalState();
}

class _FinalState extends State<_Final> with SingleTickerProviderStateMixin {
  late final AnimationController _rozet = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    _rozet.forward();
    DeviYzDersi._yaz(DeviYzDersi._bittiAnahtari);
    SoundService.playBuyukBasari();
    _titret(HapticFeedback.heavyImpact);
  }

  @override
  void dispose() {
    _rozet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final sorular = [
      t('Yapay zeka hata yapar mı?', 'Does AI make mistakes?',
          'Macht KI Fehler?', '¿La IA se equivoca?'),
      t('Yapay zeka nerelerde kullanılır?', 'Where is AI used?',
          'Wo wird KI benutzt?', '¿Dónde se usa la IA?'),
      t('Python\'a nasıl başlarım?', 'How do I start with Python?',
          'Wie fange ich mit Python an?', '¿Cómo empiezo con Python?'),
    ];
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _rozet,
              builder: (_, child) {
                final v = Curves.elasticOut.transform(_rozet.value);
                return Transform.rotate(
                  angle: (1 - _rozet.value) * -1.4,
                  child: Transform.scale(scale: v, child: child),
                );
              },
              child: Container(
                key: const ValueKey('yz_rozet'),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFFFFF59D),
                      Color(0xFFFFC107),
                      Color(0xFFFF8F00)
                    ],
                    stops: [0.1, 0.6, 1],
                  ),
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.6),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🧠', style: TextStyle(fontSize: 70)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t(
                  'Tebrikler!\nYapay Zekâ Kâşifi 🏅',
                  'Congrats!\nAI Explorer 🏅',
                  'Glückwunsch!\nKI-Entdecker 🏅',
                  '¡Enhorabuena!\nExplorador de IA 🏅'),
              textAlign: TextAlign.center,
              style: _baslikStili.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Mascot(size: 54, showShadow: false),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      t(
                          'Ben senin kodlama arkadaşınım. Kodlama sorularını cevaplarım, ana sayfada her gün bilmece sorarım. Bana yazdıkların bu telefonda kalır.',
                          'I am your coding buddy. I answer coding questions and ask you riddles every day on the home screen. What you write to me stays on this phone.',
                          'Ich bin dein Coding-Kumpel. Ich beantworte Fragen zum Programmieren und stelle dir jeden Tag Rätsel. Was du mir schreibst, bleibt auf diesem Handy.',
                          'Soy tu compañero de programación. Respondo tus preguntas y te pongo acertijos cada día en el inicio. Lo que me escribes se queda en este teléfono.'),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A1F7A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t('Hemen sor:', 'Ask now:', 'Frag gleich:', 'Pregunta ya:'),
                style: _govde(14),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in sorular)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            _Basmali(
              key: const ValueKey('yz_sohbete_basla'),
              onTap: () => Navigator.of(context).pop(''),
              golge: const Color(0xFFB34E12),
              renk: const Color(0xFFFF8A3D),
              child: Center(
                child: Text(
                  t('Devi ile sohbete başla 💬', 'Start chatting with Devi 💬',
                      'Mit Devi chatten 💬', 'Hablar con Devi 💬'),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: widget.yeniden,
              icon: const Icon(Icons.replay_rounded,
                  color: Colors.white70, size: 18),
              label: Text(
                t('Dersi baştan izle', 'Watch again', 'Nochmal ansehen',
                    'Ver de nuevo'),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: Colors.white70,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const Positioned.fill(child: _Parilti(tetik: 1, adet: 46)),
      ],
    );
  }
}
