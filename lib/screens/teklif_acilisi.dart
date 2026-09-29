import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../ui/motion.dart';
import '../ui/press_button.dart';
import '../utils/lang.dart';

/// Cikis teklifinin acilis gosterisi: hediye kutusu -> konfeti -> indirim
/// rozeti -> fiyat karsilastirmasi.
///
/// ORNEK: kullanicinin gonderdigi ekran kaydi (baska bir uygulamanin
/// yillik teklif ekrani). Oradaki AKIS alindi — bulanik paywall uzerinde
/// ziplayan bir hediye kutusu, kutu acilinca konfeti, egik ve kabarik
/// bir indirim rozeti, altinda "bugun ne kazaniyorsun" ve iki kartli
/// karsilastirma.
///
/// ORADAKI IDDIALAR ALINMADI:
///
///  * "80% OFF" — orada yuzde bir tasarim karariydi. Burada yuzde
///    HESAPLANIYOR: magazanin (StoreKit / Play) gonderdigi iki gercek
///    fiyattan. Ekranda yazan sayi baska bir yerden gelemez; bu widget'a
///    fiyat degil yalnizca hazir hesaplanmis degerler geliyor.
///  * "FOREVER" — fiyatin sonsuza kadar sabit kalacagini soz veremeyiz;
///    magaza fiyatlari degisebiliyor.
///  * "One-time offer" / "Limited" — teklif her cikista aciliyor ve bir
///    sure siniri yok. Oyleyse "tek seferlik" ya da "sinirli" demek
///    yalan olurdu.
///  * "You save $240 TODAY" — yillik bir abonelikte fark bugun degil yil
///    boyunca olusuyor. Metin "yilda ... daha az" diyor.
///
/// Cocuk uygulamasi: ekran veliye konusuyor; "Hayir, tesekkurler" acikca
/// duruyor ve kapatmak zor degil (App Store karanlik desen kurali).
class TeklifAcilisi extends StatefulWidget {
  const TeklifAcilisi({
    super.key,
    required this.lang,
    required this.yuzde,
    required this.indirimMi,
    required this.teklifFiyati,
    required this.aylikKarsilik,
    this.normalFiyat,
    this.normalEtiket,
    this.fark,
    this.denemeGun,
  });

  final String lang;

  /// Gercek fiyatlardan hesaplanmis yuzde (bkz. SubscriptionScreen).
  final int yuzde;

  /// true: indirimli ayri bir yillik urun var (standart yilliga gore
  /// indirim). false: indirim yok; yillik plan secili plana gore ucuz
  /// ("tasarruf").
  final bool indirimMi;

  /// Magazanin bicimledigi fiyat metni: "₺599,99".
  final String teklifFiyati;
  final String aylikKarsilik;

  /// Karsilastirma fiyati ve etiketi ("Normal yillik", "Aylik x 12").
  final String? normalFiyat;
  final String? normalEtiket;

  /// Yillik fark tutari, bicimlenmis: "₺200,00".
  final String? fark;

  /// Teklif urununde ucretsiz deneme varsa gun sayisi.
  final int? denemeGun;

  /// Ekrani acar; "al" derse true doner.
  static Future<bool> goster(BuildContext context, TeklifAcilisi ekran) async {
    final sonuc = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => ekran,
      transitionBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: child),
    );
    return sonuc == true;
  }

  @override
  State<TeklifAcilisi> createState() => _TeklifAcilisiState();
}

class _TeklifAcilisiState extends State<TeklifAcilisi>
    with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  late final AnimationController _isin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );
  final ConfettiController _konfeti =
      ConfettiController(duration: const Duration(milliseconds: 700));
  bool _konfetiAtildi = false;

  static const _mavi = Color(0xFF2F6BFF);
  static const _koyu = Color(0xFF14161A);
  static const _gri = Color(0xFF5B616E);

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (Motion.reduced(context)) {
        // Hareket azaltilmissa gosteri yok: dogrudan son hal.
        _c.value = 1;
        return;
      }
      _c.addListener(_konfetiZamani);
      _c.forward();
      _isin.repeat();
    });
  }

  void _konfetiZamani() {
    if (!_konfetiAtildi && _c.value >= 0.47) {
      _konfetiAtildi = true;
      _konfeti.play();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _isin.dispose();
    _konfeti.dispose();
    super.dispose();
  }

  /// [a]..[b] araligini 0..1'e cevirir.
  double _aralik(double a, double b, [Curve egri = Curves.easeOut]) {
    final v = ((_c.value - a) / (b - a)).clamp(0.0, 1.0);
    return egri.transform(v);
  }

  String get _rozetUst => widget.indirimMi
      ? _t('%${widget.yuzde}', '${widget.yuzde}% OFF',
          '${widget.yuzde} %', '${widget.yuzde} %')
      : _t('%${widget.yuzde}', 'SAVE ${widget.yuzde}%',
          '${widget.yuzde} %', '${widget.yuzde} %');

  String get _rozetAlt => widget.indirimMi
      ? _t('İNDİRİM', 'YEARLY PLAN', 'RABATT', 'DESCUENTO')
      : _t('TASARRUF', 'YEARLY PLAN', 'GESPART', 'DE AHORRO');

  @override
  Widget build(BuildContext context) {
    final ekran = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final zemin = _aralik(0.42, 0.62);
          return Stack(
            children: [
              // Beyaz zemin, hediye acilinca geliyor.
              Positioned.fill(
                child: Opacity(
                  opacity: zemin,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFEFF3FF), Colors.white],
                      ),
                    ),
                  ),
                ),
              ),
              if (_c.value < 0.62) _hediye(ekran),
              if (zemin > 0) _icerik(zemin),
              Align(
                alignment: const Alignment(0, -0.35),
                child: ConfettiWidget(
                  confettiController: _konfeti,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 40,
                  maxBlastForce: 32,
                  minBlastForce: 12,
                  gravity: 0.18,
                  emissionFrequency: 0,
                  colors: const [
                    Color(0xFF2F6BFF),
                    Color(0xFFFFC400),
                    Color(0xFFFF4081),
                    Color(0xFF00BFA5),
                    Color(0xFF7C4DFF),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Ziplayan, sallanan, sonra buyuyup kaybolan hediye kutusu.
  Widget _hediye(Size ekran) {
    final gelis = _aralik(0.0, 0.28, Curves.elasticOut);
    final salla = _aralik(0.28, 0.44);
    final acil = _aralik(0.44, 0.58, Curves.easeIn);
    final aci = math.sin(salla * math.pi * 5) * 0.12 * (1 - salla);
    final olcek = gelis * (1 + acil * 0.5);
    return Align(
      alignment: const Alignment(0, -0.2),
      child: Opacity(
        opacity: 1 - acil,
        child: Transform.rotate(
          angle: aci,
          child: Transform.scale(
            scale: olcek,
            child: Image.asset(
              'assets/images/ui/hediye.png',
              width: math.min(ekran.width * 0.42, 180),
              errorBuilder: (_, __, ___) =>
                  const Text('🎁', style: TextStyle(fontSize: 110)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _icerik(double zemin) {
    final rozet = _aralik(0.5, 0.74, Curves.elasticOut);
    Widget sirayla(double bas, Widget cocuk) {
      final v = _aralik(bas, bas + 0.16);
      return Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: cocuk),
      );
    }

    return SafeArea(
      child: LayoutBuilder(builder: (context, kutu) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: kutu.maxHeight - 20),
            child: Column(
              children: [
                sirayla(
                  0.58,
                  Text(
                    widget.indirimMi
                        ? _t('Sana özel yıllık teklif',
                            'A special yearly price for you',
                            'Ein besonderer Jahrespreis für dich',
                            'Un precio anual especial para ti')
                        : _t('Yıllık plan daha uygun',
                            'The yearly plan costs less',
                            'Der Jahresplan kostet weniger',
                            'El plan anual cuesta menos'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 26,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: _mavi,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 190,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rozetin arkasindaki yavas donen isik.
                      Opacity(
                        opacity: rozet.clamp(0.0, 1.0) * 0.9,
                        child: RotationTransition(
                          turns: _isin,
                          child: const CustomPaint(
                            size: Size(260, 260),
                            painter: _IsinBoyaci(),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.3 + 0.7 * rozet,
                        child: Transform.rotate(
                          angle: -0.12,
                          child: _Rozet(ust: _rozetUst, alt: _rozetAlt),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.fark != null)
                  sirayla(
                    0.66,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3DC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text.rich(
                        TextSpan(children: [
                          const TextSpan(text: '✨ '),
                          TextSpan(
                              text: _t('Yılda ', 'You pay ', 'Du zahlst ',
                                  'Pagas ')),
                          TextSpan(
                            text: widget.fark,
                            style: const TextStyle(color: _mavi),
                          ),
                          TextSpan(
                              text: _t(' daha az ödersin', ' less a year',
                                  ' weniger im Jahr', ' menos al año')),
                        ]),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _koyu,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                sirayla(0.72, _kartlar()),
                const SizedBox(height: 14),
                if (widget.denemeGun != null)
                  sirayla(
                    0.78,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _t(
                            '${widget.denemeGun} gün ücretsiz · sonra ${widget.teklifFiyati}/yıl',
                            '${widget.denemeGun}-day free trial · then ${widget.teklifFiyati}/year',
                            '${widget.denemeGun} Tage gratis · dann ${widget.teklifFiyati}/Jahr',
                            '${widget.denemeGun} días gratis · luego ${widget.teklifFiyati}/año'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                sirayla(
                  0.82,
                  PressButton(
                    label: widget.denemeGun != null
                        ? _t('${widget.denemeGun} gün ücretsiz başla',
                            'Start ${widget.denemeGun}-day free trial',
                            '${widget.denemeGun} Tage gratis starten',
                            'Empezar ${widget.denemeGun} días gratis')
                        : _t('Bu fiyattan başla', 'Get this price',
                            'Zu diesem Preis starten', 'Empezar con este precio'),
                    color: _mavi,
                    height: 56,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
                const SizedBox(height: 8),
                sirayla(
                  0.86,
                  Text(
                    _t('İstediğin zaman iptal edebilirsin · Güvenli ödeme',
                        'Cancel anytime · Secure payment',
                        'Jederzeit kündbar · Sichere Zahlung',
                        'Cancela cuando quieras · Pago seguro'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _gri,
                    ),
                  ),
                ),
                // Vazgecmek kolay ve gorunur: karanlik desen degil.
                sirayla(
                  0.86,
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      _t('Hayır, teşekkürler', 'No thanks', 'Nein, danke',
                          'No, gracias'),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _gri,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _kartlar() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.normalFiyat != null) ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.normalEtiket ?? '',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _gri,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.normalFiyat!,
                        style: AppTheme.number(fontSize: 22, color: _gri)
                            .copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t('yıllık', 'per year', 'pro Jahr', 'al año'),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: _gri,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _mavi, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: _mavi.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _t('Yıllık', 'Yearly', 'Jährlich', 'Anual'),
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _mavi,
                              ),
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded,
                              color: _mavi, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.teklifFiyati,
                          style: AppTheme.number(fontSize: 26, color: _koyu),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _t('ayda ${widget.aylikKarsilik}',
                            '${widget.aylikKarsilik} / month',
                            '${widget.aylikKarsilik} / Monat',
                            '${widget.aylikKarsilik} / mes'),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _gri,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -11,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: _mavi,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _t('%${widget.yuzde}', '-${widget.yuzde}%',
                          '-${widget.yuzde} %', '-${widget.yuzde} %'),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Egik, kabarik indirim rozeti: jole buton gibi alt kenari koyu.
class _Rozet extends StatelessWidget {
  const _Rozet({required this.ust, required this.alt});

  final String ust;
  final String alt;

  @override
  Widget build(BuildContext context) {
    const koyu = Color(0xFF1C47C4);
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5B8CFF), Color(0xFF2F6BFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 2),
        boxShadow: const [
          BoxShadow(color: koyu, offset: Offset(0, 8)),
          BoxShadow(
              color: Color(0x552F6BFF), blurRadius: 24, offset: Offset(0, 14)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ust,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 52,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [Shadow(color: koyu, offset: Offset(0, 3))],
            ),
          ),
          Text(
            alt,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 22,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rozetin arkasindaki gunes isinlari.
class _IsinBoyaci extends CustomPainter {
  const _IsinBoyaci();

  @override
  void paint(Canvas canvas, Size size) {
    final merkez = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final boya = Paint()
      ..shader = RadialGradient(colors: [
        const Color(0xFFFFD27A).withValues(alpha: 0.55),
        const Color(0xFFFFD27A).withValues(alpha: 0.0),
      ]).createShader(Rect.fromCircle(center: merkez, radius: r));
    const adet = 14;
    for (var i = 0; i < adet; i++) {
      final a = i * 2 * math.pi / adet;
      final yol = Path()
        ..moveTo(merkez.dx, merkez.dy)
        ..lineTo(merkez.dx + r * math.cos(a - 0.09),
            merkez.dy + r * math.sin(a - 0.09))
        ..lineTo(merkez.dx + r * math.cos(a + 0.09),
            merkez.dy + r * math.sin(a + 0.09))
        ..close();
      canvas.drawPath(yol, boya);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
