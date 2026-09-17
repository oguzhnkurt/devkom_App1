import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

/// Kartların arkasında çok soluk, yavaşça sağdan sola süzülen kod
/// simgeleri: `{ }`, `</>`, yıldız ve yapboz parçası.
///
/// NEDEN
/// -----
/// Ana karttaki turuncu düz bir renkti. Düz renk ucuz durur; gözün
/// tutunacağı hiçbir şey yok ve kart, arkasındaki sayfadan kopmuyor.
/// Bu akıntı yüzeye **derinlik** veriyor: arkada, yavaşça akan bir
/// katman olduğu için kart bir yüzey gibi duruyor, boyalı bir dikdörtgen
/// gibi değil.
///
/// KURALLAR (keyfi değil)
/// ----------------------
/// * **Okunurluk önce.** Simgeler %10 opaklıkta. Metnin kontrastını
///   ölçülebilir biçimde bozmayacak kadar soluk; WCAG kontrast hesabı
///   zemin rengiyle yapıldığı için %10'luk beyaz bir doku, 4.5:1
///   sınırını geçmiş bir başlığı sınırın altına düşürmüyor.
/// * **Yavaş.** Tam tur 40 saniye. Hareket fark edilsin ama göz onu
///   TAKİP ETMESİN; hızlı bir arka plan, üstündeki yazıyı okunamaz
///   yapmasa bile okumayı zorlaştırıyor.
/// * **Hareket azaltma.** Sistem ayarında hareket azaltılmışsa akıntı
///   durur — desen kalır, hareket gider. Bu bir tercih değil,
///   erişilebilirlik gereği (vestibüler rahatsızlık).
/// * **Tek katman.** [RepaintBoundary] içinde çiziliyor; yoksa kartın
///   içindeki her şey (başlık, düğme) saniyede 60 kez yeniden
///   çizilirdi.
class KodAkintisi extends StatefulWidget {
  const KodAkintisi({
    super.key,
    required this.child,
    this.renk = Colors.white,
    this.opaklik = 0.10,
    this.kose = 24,
    this.sure = const Duration(seconds: 40),
    this.yogunluk = 12,
  });

  final Widget child;

  /// Simgelerin rengi. Koyu/renkli zeminde beyaz, açık zeminde koyu.
  final Color renk;

  final double opaklik;

  /// Kartın köşe yarıçapı — akıntı bunun dışına taşmasın.
  final double kose;

  /// Bir simgenin baştan sona geçiş süresi.
  final Duration sure;

  /// Kaç simge çizilecek.
  final int yogunluk;

  @override
  State<KodAkintisi> createState() => _KodAkintisiState();
}

class _KodAkintisiState extends State<KodAkintisi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.sure);

  late final List<_Simge> _simgeler;

  @override
  void initState() {
    super.initState();
    // SABİT TOHUM: uygulama her açıldığında desen aynı yerde başlasın.
    // Rastgele yerleşim her açılışta farklı olsaydı kart "oynak"
    // hissettirirdi — aynı ekranı iki kez açan çocuk aynı şeyi görmeli.
    final rnd = math.Random(41);
    const glifler = ['{ }', '</>', '★', '🧩', '( )', ';', '[ ]', '✦'];
    _simgeler = List.generate(widget.yogunluk, (i) {
      return _Simge(
        glif: glifler[i % glifler.length],
        // Başlangıç faz kaydırması: hepsi aynı anda girmesin.
        faz: rnd.nextDouble(),
        y: 0.06 + rnd.nextDouble() * 0.88,
        olcek: 0.7 + rnd.nextDouble() * 0.9,
        // Farklı hızlar = paralaks. Derinlik hissinin asıl kaynağı bu:
        // uzaktaki yavaş, yakındaki hızlı akıyor.
        hiz: 0.6 + rnd.nextDouble() * 0.8,
        egim: (rnd.nextDouble() - 0.5) * 0.5,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.kose),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) => CustomPaint(
                  painter: _AkintiBoyaci(
                    simgeler: _simgeler,
                    t: _c.value,
                    renk: widget.renk.withValues(alpha: widget.opaklik),
                  ),
                  // Boyacı kartın tamamını kaplasın.
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Simge {
  const _Simge({
    required this.glif,
    required this.faz,
    required this.y,
    required this.olcek,
    required this.hiz,
    required this.egim,
  });

  final String glif;
  final double faz;
  final double y;
  final double olcek;
  final double hiz;
  final double egim;
}

class _AkintiBoyaci extends CustomPainter {
  _AkintiBoyaci({
    required this.simgeler,
    required this.t,
    required this.renk,
  });

  final List<_Simge> simgeler;
  final double t;
  final Color renk;

  /// Ölçülen metin yeniden kullanılıyor: her karede on iki
  /// `TextPainter` kurmak, kartı çizmekten pahalıya geliyordu.
  static final Map<String, TextPainter> _onbellek = {};

  TextPainter _yazi(String glif, double boy, Color renk) {
    final anahtar = '$glif|${boy.toStringAsFixed(1)}|${renk.toARGB32()}';
    return _onbellek.putIfAbsent(anahtar, () {
      final tp = TextPainter(
        text: TextSpan(
          text: glif,
          style: TextStyle(
            fontSize: boy,
            fontWeight: FontWeight.w800,
            color: renk,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return tp;
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    for (final s in simgeler) {
      final boy = size.height * 0.22 * s.olcek;
      final tp = _yazi(s.glif, boy, renk);

      // SAĞDAN SOLA. Tur uzunluğu genişlik + simge genişliği: simge
      // tamamen çıkmadan başa dönmüyor, yani kenarda "zıplama" yok.
      final tur = size.width + tp.width;
      final ilerleme = (s.faz + t * s.hiz) % 1.0;
      final dx = size.width - ilerleme * tur;
      final dy = size.height * s.y - tp.height / 2;

      canvas.save();
      canvas.translate(dx + tp.width / 2, dy + tp.height / 2);
      canvas.rotate(s.egim);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_AkintiBoyaci old) => old.t != t || old.renk != renk;
}
