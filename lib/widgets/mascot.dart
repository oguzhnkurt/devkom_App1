import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ui/motion.dart';
import 'mascot_mood.dart';

export 'mascot_mood.dart';

/// Uygulamanın maskotu: **Devi**.
///
/// NEDEN TEK BİR KARAKTER
/// ----------------------
/// Uygulamada şimdiye kadar maskot diye bir şey yoktu: her ekran başka bir
/// emoji gösteriyordu (🤖 burada, 🧩 şurada, 🐱 öbür derste). Çocuk için
/// bu, uygulamanın bir "kimse"si olmaması demek. Devi, uygulamanın her
/// yerinde aynı: karşılamada, derste, sonuç ekranında, mağazada.
///
/// ÇİZİM DEĞİL, RENDER
/// --------------------
/// Devi önceden Dart'ta `CustomPainter` ile çiziliyordu ve beş ayrı tür
/// (Puf, Mia, Bit, Kâşif, Bug) vardı; çocuk açılışta birini seçiyordu.
/// O sistem kaldırıldı: artık tek bir karakter var ve o da satın alınmış
/// bir 3B render (ticari lisanslı).
///
/// Bunun bedeli dürüstçe şu: **render poz veremez.** Çizili karakterin
/// altı ruh hâli yüzünden okunuyordu; render'ın tek bir pozu var. Bu
/// yüzden ruh hâli artık YÜZDE değil HAREKETTE: sevinç daha yüksek bir
/// zıplama, düşünme daha yavaş bir nefes. [MascotMood.cheering] anında
/// —ders bitti, rozet geldi— altı saniyelik gerçek animasyon dönüyor.
///
/// SESSİZ VARSAYILAN
/// ------------------
/// Sürekli oynayan bir maskot içerikle dikkat için yarışıyor (Frontiers
/// 2025, n=112: sadece ajan koymak bilgi aktarımını DÜŞÜRÜYOR). Bu
/// yüzden normal hâlde tek kare PNG duruyor; animasyon yalnızca kutlama
/// anında açılıyor. Batarya ve dikkat, ikisi de aynı kararla korunuyor.
///
/// SUÇLULUK YOK
/// -------------
/// [MascotMood]'da üzgün ya da küsmüş bir hâl bilerek YOK ve render de
/// hep aynı neşeli ifadede. Duolingo'nun kendi A/B testi, koçun "gelişim
/// zihniyeti" diliyle konuşmasının standart övgüye göre D14 tutmayı
/// %7,2 artırdığını gösteriyor; suçluluk temelli maskot davranışının
/// öğrenmeye yaradığına dair yayımlanmış bir kanıt ise yok.
class Mascot extends StatefulWidget {
  const Mascot({
    super.key,
    this.mood = MascotMood.idle,
    this.size = 96,
    this.color,
    this.onTap,
    this.showShadow = true,
    this.blink = false,
  });

  final MascotMood mood;
  final double size;

  /// Gölgenin ve parıltının rengi. Verilmezse Devi'nin kendi turuncusu.
  final Color? color;

  /// Dokununca. Verilirse Devi dokunmaya küçük bir zıplamayla cevap
  /// veriyor — çocuk için "bu canlı" sinyali.
  final VoidCallback? onTap;

  final bool showShadow;

  /// Göz kırpma. Açıkken Devi ~3 saniyede bir gözlerini kırpıyor
  /// (arada bir çift kırpma). Render tek kare olduğu için kırpma,
  /// vizörün üstüne göz kapakları çizilerek yapılıyor: kalp gözler
  /// kapanıyor, yerlerinde mutlu bir "‿" parlıyor.
  ///
  /// Varsayılan KAPALI: her ekranda kırpan bir maskot içerikle dikkat
  /// için yarışır (bkz. sınıf açıklaması). Yalnızca Devi'nin kendini
  /// tanıttığı anda açık. "Hareketi azalt" açıksa kırpma yok.
  final bool blink;

  /// Ekran görüntüsü araçları için: verilirse gözler bu oranda kapalı
  /// çiziliyor (0 açık, 1 kapalı). Uygulamada hep null.
  @visibleForTesting
  static double? debugGozKapali;

  /// Karakterin adı. Metinlerde geçtiği için tek yerden okunuyor.
  static const String ad = 'Devi';

  /// Render'daki gövde turuncusu. Balon kenarlığı, gölge ve parıltı
  /// bunu kullanıyor ki maskot içinde durduğu kutuya ait gibi olsun.
  static const Color tone = Color(0xFFF2A33C);

  /// Duran hâl. Her ekranda bu görünüyor.
  static const String durgunGorsel = 'assets/maskot/devi.png';

  /// Kutlama animasyonu (saydam, döngülü WebP). Yalnızca
  /// [MascotMood.cheering] anında.
  static const String kutlamaGorseli = 'assets/maskot/devi_kutlama.webp';

  /// Döngünün o anındaki göz kapanıklığı (0 açık, 1 kapalı).
  ///
  /// 7 saniyelik döngüde üç kırpma: 2,9 sn'de tek, 6,4 sn'de çift
  /// (6,4 ve 6,75). Düzenli bir metronom gibi değil, canlı gibi.
  static double gozKapanikligi(double t) {
    double tepe(double bas, double sure) {
      if (t < bas || t > bas + sure) return 0;
      return math.sin((t - bas) / sure * math.pi);
    }

    return math.max(tepe(0.42, 0.026),
        math.max(tepe(0.915, 0.026), tepe(0.962, 0.024)));
  }

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with TickerProviderStateMixin {
  /// Nefes alma / zıplama.
  late final AnimationController _idle;

  /// Dokunma tepkisi.
  late final AnimationController _poke;

  /// Göz kırpma döngüsü (yalnızca [Mascot.blink] açıkken döner).
  late final AnimationController _kirp;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(vsync: this, duration: _idleDuration);
    _poke = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _kirp = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
  }

  Duration get _idleDuration => switch (widget.mood) {
        MascotMood.cheering => const Duration(milliseconds: 520),
        MascotMood.happy => const Duration(milliseconds: 900),
        MascotMood.thinking => const Duration(milliseconds: 3200),
        _ => const Duration(milliseconds: 2400),
      };

  @override
  void didUpdateWidget(covariant Mascot old) {
    super.didUpdateWidget(old);
    if (old.blink != widget.blink) _applyMotion();
    if (old.mood != widget.mood) {
      _idle.duration = _idleDuration;
      _applyMotion();
      // Yeni bir duruma geçmek küçük bir zıplama: geçiş fark edilsin.
      if (!Motion.reduced(context)) _poke.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyMotion();
    _kutlamayiHazirla();
  }

  /// Uygulama açılışında bir kez hazırlanan kutlama görseli.
  static bool _kutlamaHazirlandi = false;

  /// Kutlama görseli büyük (1,4 MB) ve **hareketli** bir WebP —
  /// 90 kare. Ders biterken ilk kez yüklenmesin diye önceden ön
  /// belleğe alınıyor, ama iki koşulla:
  ///
  /// **Bir kez.** `didChangeDependencies` her bağımlılık değişiminde
  /// çalışıyor — klavye açılınca, yön dönünce, tema değişince. Her
  /// seferinde yeniden ön belleğe almak boşuna iş.
  ///
  /// **Testte hiç.** Widget testlerinin sahte zamanlı (fake-async)
  /// motoru hareketli bir görselin karelerini çözmüyor.
  /// `precacheImage` ya hiç dönmüyor — test 10 dakika sonra zaman
  /// aşımına uğruyor — ya da bir sonraki `pump`,
  /// `MultiFrameImageStreamCompleter._handleAppFrame` içindeki
  /// `_nextFrame != null` savını düşürüyor. Mağaza görsellerini üreten
  /// araç (`test/appstore_shots_test.dart`) tam bu yüzden maskotlu ilk
  /// ekranında donuyor, ardından gelen testler de "Reentrant call to
  /// runAsync()" ile düşüyordu.
  ///
  /// `TestWidgetsFlutterBinding` bir [WidgetsFlutterBinding] DEĞİL;
  /// ayrım buradan yapılıyor, `dart:io` gerekmiyor (web derlemesi de
  /// bozulmuyor).
  void _kutlamayiHazirla() {
    if (_kutlamaHazirlandi) return;
    if (WidgetsBinding.instance is! WidgetsFlutterBinding) return;
    _kutlamaHazirlandi = true;
    precacheImage(const AssetImage(Mascot.kutlamaGorseli), context);
  }

  void _applyMotion() {
    // Klavye açıkken nefes alma DURUYOR.
    //
    // Kullanıcı yazarken her tuşta metin alanı yeniden çiziliyor;
    // arkada saniyede 60 kez dönen bir animasyon varken bu, yazmanın
    // takılması olarak hissediliyor.
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (Motion.reduced(context) || typing) {
      _idle.stop();
      _kirp.stop();
      _kirp.value = 0;
      return;
    }
    if (!_idle.isAnimating) _idle.repeat(reverse: true);
    if (widget.blink) {
      if (!_kirp.isAnimating) _kirp.repeat();
    } else if (_kirp.isAnimating) {
      _kirp.stop();
      _kirp.value = 0;
    }
  }


  @override
  void dispose() {
    _idle.dispose();
    _poke.dispose();
    _kirp.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    if (!Motion.reduced(context)) _poke.forward(from: 0);
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    final tone = widget.color ?? Mascot.tone;

    return Semantics(
      label: '${Mascot.ad} — ${_moodLabel(widget.mood)}',
      button: widget.onTap != null,
      image: true,
      child: GestureDetector(
        onTap: widget.onTap == null ? null : _handleTap,
        behavior: HitTestBehavior.opaque,
        // KENDİ KATMANINDA ÇİZİLİYOR.
        //
        // Devi hiç durmadan nefes alıyor. Sınır konmadığında bu, Devi'nin
        // BULUNDUĞU KATMANIN TAMAMININ her karede yeniden çizilmesi
        // demek — arkadaki kartlar, başlıklar, bloklar dahil.
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_idle, _poke]),
            builder: (context, child) {
              final breath =
                  reduced ? 0.0 : Curves.easeInOut.transform(_idle.value);
              final poke = reduced ? 0.0 : Curves.easeOut.transform(_poke.value);
              final pokeBump = math.sin(poke * math.pi);

              final lift = switch (widget.mood) {
                MascotMood.cheering => -breath * widget.size * 0.10,
                MascotMood.happy => -breath * widget.size * 0.04,
                _ => -breath * widget.size * 0.018,
              };
              final squash = switch (widget.mood) {
                MascotMood.cheering => 1 + breath * 0.05,
                _ => 1 + breath * 0.015,
              };

              return Transform.translate(
                offset: Offset(0, lift - pokeBump * widget.size * 0.08),
                child: Transform.scale(
                  scaleX: 1 / squash,
                  scaleY: squash * (1 + pokeBump * 0.06),
                  child: child,
                ),
              );
            },
            child: _figur(tone),
          ),
        ),
      ),
    );
  }

  /// Gövde: kutlamada animasyon, diğer hâllerde tek kare.
  Widget _figur(Color tone) {
    final kutlama =
        widget.mood == MascotMood.cheering && !Motion.reduced(context);
    final gorsel = Image.asset(
      kutlama ? Mascot.kutlamaGorseli : Mascot.durgunGorsel,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      // Filtre kalitesi: maskot 40 px'e kadar küçülüyor ve varsayılan
      // düşük kaliteli ölçekleme metal kenarlarda testere dişi yapıyor.
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      errorBuilder: (context, _, __) => Icon(
        Icons.smart_toy_rounded,
        size: widget.size * 0.7,
        color: tone,
      ),
    );

    // Kutlama animasyonunun kendi karesi var; kapaklar yalnızca duran
    // render'ın gözlerine oturuyor.
    final govde = (widget.blink || Mascot.debugGozKapali != null) && !kutlama
        ? Stack(
            children: [
              gorsel,
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _kirp,
                    builder: (context, _) => CustomPaint(
                      painter: _GozKapagi(Mascot.debugGozKapali ??
                          Mascot.gozKapanikligi(_kirp.value)),
                    ),
                  ),
                ),
              ),
            ],
          )
        : gorsel;

    if (!widget.showShadow) return govde;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Zemin gölgesi: figür havada duruyor, gölge onu bir yere
          // oturtuyor. Render'ın kendi gölgesi yok (saydam arka plan).
          Positioned(
            bottom: widget.size * 0.06,
            child: Container(
              width: widget.size * 0.42,
              height: widget.size * 0.07,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(widget.size),
              ),
            ),
          ),
          govde,
        ],
      ),
    );
  }

  String _moodLabel(MascotMood m) => switch (m) {
        MascotMood.idle => 'bekliyor',
        MascotMood.thinking => 'düşünüyor',
        MascotMood.happy => 'mutlu',
        MascotMood.cheering => 'seviniyor',
        MascotMood.encouraging => 'cesaret veriyor',
        MascotMood.curious => 'merak ediyor',
      };
}

/// Devi'nin göz kapakları.
///
/// Render'daki kalp gözlerin yeri `devi.png` (512×512) üzerinde
/// ölçüldü; görsel kare ve `BoxFit.contain` ile çizildiği için konumlar
/// boyutla orantılı. Kapanırken vizör renginde iki kapak (üstten ve
/// alttan) kalbi örtüyor; yarıdan sonra yerinde turkuaz, hafif parlayan
/// mutlu bir "‿" beliriyor — robotun gözleri kapanınca sönen bir ekran
/// değil, gülümseyen bir yüz.
class _GozKapagi extends CustomPainter {
  _GozKapagi(this.kapali);

  /// 0 açık, 1 tamamen kapalı.
  final double kapali;

  /// (merkez x, merkez y, genişlik, yükseklik, üst renk, alt renk)
  static const _gozler = [
    (156.0, 263.0, 44.0, 44.0, Color(0xFF55552A), Color(0xFF34381A)),
    (240.5, 253.5, 40.0, 42.0, Color(0xFF4E4422), Color(0xFF2E2E0A)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (kapali <= 0.001) return;
    final k = size.shortestSide / 512;
    final ox = (size.width - 512 * k) / 2;
    final oy = (size.height - 512 * k) / 2;
    for (final (cx, cy, w, h, ust, alt) in _gozler) {
      final merkez = Offset(ox + cx * k, oy + cy * k);
      final rect = Rect.fromCenter(center: merkez, width: w * k, height: h * k);
      final yari = rect.height / 2 * kapali;
      final kapak = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ust, alt],
        ).createShader(rect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.6 * k + 0.4);
      canvas.save();
      canvas.clipRRect(RRect.fromRectAndRadius(
          rect.inflate(1.5 * k), Radius.circular(10 * k)));
      canvas.drawRect(
          Rect.fromLTRB(rect.left - 4, rect.top - 4, rect.right + 4,
              rect.top + yari + 0.5),
          kapak);
      canvas.drawRect(
          Rect.fromLTRB(rect.left - 4, rect.bottom - yari - 0.5,
              rect.right + 4, rect.bottom + 4),
          kapak);
      canvas.restore();

      // Kapalı göz: mutlu bir kavis.
      final gor = ((kapali - 0.55) / 0.45).clamp(0.0, 1.0);
      if (gor > 0) {
        final yol = Path()
          ..moveTo(merkez.dx - w * 0.34 * k, merkez.dy - 1.5 * k)
          ..quadraticBezierTo(merkez.dx, merkez.dy + h * 0.30 * k,
              merkez.dx + w * 0.34 * k, merkez.dy - 1.5 * k);
        canvas.drawPath(
          yol,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 7 * k
            ..color = const Color(0xFF7FF6F0).withValues(alpha: 0.45 * gor)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * k + 0.5),
        );
        canvas.drawPath(
          yol,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 4.2 * k
            ..color = const Color(0xFFD8FFFC).withValues(alpha: gor),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GozKapagi old) => old.kapali != kapali;
}

/// Devi + konuşma balonu.
///
/// Maskotun tek başına durması "süs" demek; bir şey söylediğinde
/// karakter oluyor. Balon, çocuğun O AN yaptığı şeye bağlı bir cümle
/// taşımalı — genel bir teşvik değil (bkz. Calvert 2020: çocuğun kendi
/// eylemine karşılık veren karakter, öğrenmeyi ölçülebilir biçimde
/// artırıyor; sadece duran ve alkışlayan karakter artırmıyor).
class MascotSays extends StatelessWidget {
  const MascotSays({
    super.key,
    required this.text,
    this.mood = MascotMood.idle,
    this.size = 72,
    this.color,
    this.action,
  });

  final String text;
  final MascotMood mood;
  final double size;
  final Color? color;

  /// Balonun altındaki isteğe bağlı düğme.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? Mascot.tone;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Mascot(mood: mood, size: size, color: color),
        SizedBox(width: size * 0.16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: tone.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: tone.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2430),
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 12),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
