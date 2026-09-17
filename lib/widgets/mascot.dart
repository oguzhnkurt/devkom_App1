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
  });

  final MascotMood mood;
  final double size;

  /// Gölgenin ve parıltının rengi. Verilmezse Devi'nin kendi turuncusu.
  final Color? color;

  /// Dokununca. Verilirse Devi dokunmaya küçük bir zıplamayla cevap
  /// veriyor — çocuk için "bu canlı" sinyali.
  final VoidCallback? onTap;

  final bool showShadow;

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

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with TickerProviderStateMixin {
  /// Nefes alma / zıplama.
  late final AnimationController _idle;

  /// Dokunma tepkisi.
  late final AnimationController _poke;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(vsync: this, duration: _idleDuration);
    _poke = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
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
    // Kutlama görseli büyük; ders biterken ilk kez yüklenmesin diye
    // önceden hazırlanıyor.
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
      return;
    }
    if (!_idle.isAnimating) _idle.repeat(reverse: true);
  }

  @override
  void dispose() {
    _idle.dispose();
    _poke.dispose();
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

    if (!widget.showShadow) return gorsel;

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
          gorsel,
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
