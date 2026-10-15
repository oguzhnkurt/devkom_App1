import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme.dart';
import '../../ui/motion.dart';
import '../../utils/lang.dart';
import '../../widgets/mascot.dart';

/// Ilk acilista Devi'nin kendini tanittigi ekran.
///
/// NEDEN
/// -----
/// Kullanici: "Ilk girildiginde Devi kendini tanitmali: adim Devi,
/// kodlama ve yapay zeka ogrenirken sana yardim edecegim... guzel bir
/// konusma balonuyla, gozlerini kirparak." Onceden akis dogrudan
/// "ona ne ad koyalim?" sorusuyla basliyordu; cocuk karakteri tanimadan
/// ona ad vermeye zorlaniyordu. Simdi once Devi kendini tanitiyor, sonra
/// ilk gorev geliyor (ad degistirmek Ayarlar'a tasindi).
///
/// NASIL
/// -----
/// * Devi asagidan ziplayarak geliyor, sonra hafifce saga sola
///   sallanarak "merhaba" diyor; yaninda el sallayan bir 👋.
/// * Gozlerini ~3 saniyede bir kirpiyor ([Mascot.blink]).
/// * Konusma balonunda uc kisa sayfa, daktilo gibi yaziliyor. Balonun
///   olcusu yazi bitmeden de sabit (gorunmez kalan metin yer tutuyor):
///   yazarken satirlar ziplamiyor.
/// * Ekrana dokunmak: yazi bitmediyse bitirir, bittiyse sonraki sayfa.
/// * "Atla" her zaman sag ustte.
///
/// "Hareketi azalt" aciksa giris, sallanma, kirpma ve daktilo yok; metin
/// hemen tam gorunuyor.
class DeviTanisma extends StatefulWidget {
  const DeviTanisma({
    super.key,
    required this.lang,
    required this.onDone,
    this.leading,
    this.ad = Mascot.ad,
  });

  /// Maskotun adi. Kurulumda sorulmuyor, yani hemen her zaman Devi;
  /// ama Ayarlar'dan degistirilip kurulum yeniden gosterilirse o ad.
  final String ad;

  final String lang;

  /// Tanisma bitti ya da atlandi.
  final VoidCallback onDone;

  /// Sol ustte (dil secici).
  final Widget? leading;

  /// Balondaki sayfalar.
  static List<String> sayfalar(String lang, [String ad = Mascot.ad]) {
    String t(String tr, String en, String de, String es) =>
        AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
    return [
      t('Merhaba! Benim adım $ad 👋', 'Hi there! My name is $ad 👋',
          'Hallo! Ich heiße $ad 👋', '¡Hola! Me llamo $ad 👋'),
      t(
        'Kodlamayı ve yapay zekâyı öğrenirken hep yanında olacağım.',
        "I'll be right by your side while you learn coding and AI.",
        'Ich bin immer an deiner Seite, wenn du Programmieren und KI lernst.',
        'Estaré a tu lado mientras aprendes programación e IA.',
      ),
      t(
        'Hazırsan ilk kodumuzu birlikte yazalım!',
        "Ready? Let's write our first code together!",
        'Bereit? Dann schreiben wir zusammen unseren ersten Code!',
        '¿Listo? ¡Escribamos juntos nuestro primer código!',
      ),
    ];
  }

  @override
  State<DeviTanisma> createState() => DeviTanismaState();
}

class DeviTanismaState extends State<DeviTanisma>
    with TickerProviderStateMixin {
  int _sayfa = 0;

  /// Devi'nin girisi (zipla + sallan).
  late final AnimationController _giris;

  /// Daktilo.
  late final AnimationController _yazi;

  /// El sallayan 👋.
  late final AnimationController _el;

  bool _hazir = false;

  /// Balonun yazmaya baslamasi icin bekleme (dispose'ta iptal).
  Timer? _baslat;

  int get sayfa => _sayfa;

  @override
  void initState() {
    super.initState();
    _giris = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _yazi = AnimationController(vsync: this);
    _el = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hazir) return;
    _hazir = true;
    if (Motion.reduced(context)) {
      _giris.value = 1;
      _yazi.value = 1;
      return;
    }
    _giris.forward();
    _el.repeat();
    // Balon, Devi yerine oturunca yazmaya basliyor.
    _baslat = Timer(const Duration(milliseconds: 520), () {
      if (mounted && _yazi.value == 0) _yaz();
    });
  }

  @override
  void dispose() {
    _baslat?.cancel();
    _giris.dispose();
    _yazi.dispose();
    _el.dispose();
    super.dispose();
  }

  List<String> get _metinler => DeviTanisma.sayfalar(widget.lang, widget.ad);

  void _yaz() {
    if (Motion.reduced(context)) {
      _yazi.value = 1;
      return;
    }
    final n = _metinler[_sayfa].characters.length;
    _yazi.duration = Duration(milliseconds: 260 + n * 34);
    _yazi.forward(from: 0);
  }

  /// Dokunus: yazi bitmediyse tamamla, bittiyse ilerle.
  void ileri() {
    if (_yazi.value < 1) {
      _yazi.value = 1;
      return;
    }
    HapticFeedback.selectionClick();
    if (_sayfa >= _metinler.length - 1) {
      widget.onDone();
      return;
    }
    setState(() => _sayfa++);
    // Her yeni cumlede Devi kucuk bir "hm-hm" sallanmasi yapiyor.
    if (!Motion.reduced(context)) _giris.forward(from: 0.55);
    _yaz();
  }

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  @override
  Widget build(BuildContext context) {
    final son = _sayfa == _metinler.length - 1;
    return Scaffold(
      key: const ValueKey('devi_tanisma'),
      backgroundColor: const Color(0xFF2F3FB5),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: ileri,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2B37A8), Color(0xFF4A63E0), Color(0xFF7FA2FF)],
              stops: [0.0, 0.62, 1.0],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: _Yildizlar())),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (widget.leading != null) widget.leading!,
                          const Spacer(),
                          TextButton(
                            key: const ValueKey('devi_tanisma_atla'),
                            onPressed: widget.onDone,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            child: Text(_t('Atla', 'Skip', 'Überspringen',
                                'Saltar')),
                          ),
                        ],
                      ),
                      Expanded(
                        child: LayoutBuilder(builder: (context, c) {
                          // Kucuk ekranda (SE, buyuk yazi) Devi kuculuyor,
                          // balon hep tam okunuyor.
                          final deviBoy =
                              (c.maxHeight * 0.52).clamp(120.0, 320.0);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: _Balon(
                                  metin: _metinler[_sayfa],
                                  yazi: _yazi,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _devi(deviBoy),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      _noktalar(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          key: const ValueKey('devi_tanisma_devam'),
                          onPressed: ileri,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2B37A8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            textStyle: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          child: Text(son
                              ? _t('Hadi başlayalım!', "Let's start!",
                                  'Los geht\'s!', '¡Empecemos!')
                              : _t('Devam', 'Continue', 'Weiter',
                                  'Continuar')),
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

  Widget _noktalar() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _metinler.length; i++)
            AnimatedContainer(
              duration: Motion.medium2,
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == _sayfa ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: i == _sayfa ? 1 : 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      );

  Widget _devi(double boy) {
    return AnimatedBuilder(
      animation: Listenable.merge([_giris, _el]),
      builder: (context, child) {
        final g = _giris.value;
        // 0..0.4: asagidan ziplayarak gelis; 0.4..1: sonen bir sallanma.
        final gelis = Curves.elasticOut.transform((g / 0.4).clamp(0.0, 1.0));
        final sallan = g < 0.4
            ? 0.0
            : math.sin((g - 0.4) / 0.6 * math.pi * 3) * (1 - (g - 0.4) / 0.6);
        final el = math.sin(_el.value * math.pi * 2);
        return SizedBox(
          width: boy * 1.25,
          height: boy,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Arkadaki yumusak hale.
              Container(
                width: boy * 0.95,
                height: boy * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    Colors.white.withValues(alpha: 0.30),
                    Colors.white.withValues(alpha: 0.0),
                  ]),
                ),
              ),
              Opacity(
                opacity: (g / 0.12).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - gelis) * boy * 0.6),
                  child: Transform.rotate(
                    angle: sallan * 0.09,
                    child: Transform.scale(
                      scale: 0.6 + 0.4 * gelis,
                      child: child,
                    ),
                  ),
                ),
              ),
              if (_sayfa == 0)
                Positioned(
                  left: boy * 0.02,
                  top: boy * 0.02,
                  child: Opacity(
                    opacity: ((g - 0.3) / 0.2).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: el * 0.35,
                      alignment: Alignment.bottomRight,
                      child: Text('👋',
                          style: TextStyle(fontSize: boy * 0.16)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      child: Mascot(
        mood: _sayfa == _metinler.length - 1
            ? MascotMood.happy
            : MascotMood.idle,
        size: boy,
        blink: true,
        showShadow: false,
      ),
    );
  }
}

/// Daktilo ile yazilan konusma balonu, kuyrugu asagida (Devi'ye dogru).
class _Balon extends StatelessWidget {
  const _Balon({required this.metin, required this.yazi});

  final String metin;
  final Animation<double> yazi;

  @override
  Widget build(BuildContext context) {
    const stil = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: 21,
      height: 1.38,
      fontWeight: FontWeight.w800,
      color: Color(0xFF1E2A55),
    );
    final harfler = metin.characters;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: CustomPaint(
        painter: const _BalonKuyrugu(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF101A5C).withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: AnimatedBuilder(
              animation: yazi,
              builder: (context, _) {
                final n = (harfler.length * yazi.value).round();
                final gorunen = harfler.take(n).toString();
                final kalan = harfler.skip(n).toString();
                // Gorunmez kalan metin yer tutuyor: balon yazarken
                // buyumuyor, satirlar ziplamiyor.
                return Semantics(
                  label: metin,
                  excludeSemantics: true,
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: gorunen),
                      TextSpan(
                        text: kalan,
                        style: const TextStyle(color: Colors.transparent),
                      ),
                    ]),
                    key: const ValueKey('devi_tanisma_metin'),
                    textAlign: TextAlign.center,
                    style: stil,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BalonKuyrugu extends CustomPainter {
  const _BalonKuyrugu();

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final y = size.height - 15;
    final yol = Path()
      ..moveTo(x - 16, y)
      ..quadraticBezierTo(x - 2, y + 4, x + 2, y + 15)
      ..quadraticBezierTo(x + 6, y + 4, x + 18, y)
      ..close();
    canvas.drawPath(yol, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_BalonKuyrugu old) => false;
}

/// Arka plandaki soluk yildizlar ve noktalar (sabit, rastgele degil).
class _Yildizlar extends CustomPainter {
  const _Yildizlar();

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(11);
    final p = Paint();
    for (var i = 0; i < 46; i++) {
      final o = Offset(r.nextDouble() * size.width,
          r.nextDouble() * size.height * 0.85);
      final b = 0.8 + r.nextDouble() * 2.0;
      p.color = Colors.white.withValues(alpha: 0.10 + r.nextDouble() * 0.35);
      canvas.drawCircle(o, b, p);
    }
    // Iki buyuk, cok soluk daire: derinlik.
    p.color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.18),
        size.width * 0.32, p);
    canvas.drawCircle(Offset(size.width * 0.95, size.height * 0.62),
        size.width * 0.42, p);
  }

  @override
  bool shouldRepaint(_Yildizlar old) => false;
}
