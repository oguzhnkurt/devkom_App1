import 'package:flutter/material.dart';

import 'motion.dart';

/// Icerigi asagidan yukari, gecikmeli olarak getiren kucuk sarmalayici.
///
/// Bir listenin tamami ayni anda belirdiginde ekran "yuklendi" degil
/// "zipladi" hissi veriyor. Kartlar 40-60 ms arayla girince goz sirayla
/// takip ediyor ve ayni icerik daha duzenli algilaniyor.
///
/// Hareketi azaltma ayari acikken animasyon hic calismiyor: hareket
/// duyarliligi olan cocuklar icin bu bir erisilebilirlik gerekliligi.
class AppearIn extends StatelessWidget {
  const AppearIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 18,
    this.duration = Motion.long2,
    this.renk,
  });

  final Widget child;
  final Duration delay;

  /// Baslangicta ne kadar asagida duracagi (px).
  final double offset;

  final Duration duration;

  /// Belirirken icerigin uzerine vurulan renk.
  ///
  /// Verildiginde icerik once bu renkte gelir, yerine otururken kendi
  /// rengine doner — yazi icin "renkli girdi, sonra siyahlasti" etkisi.
  /// Renk yalnizca gorunusu boyar: metnin kendi rengi, ikonlar, kenarlik
  /// hepsi alfa korunarak kaplanir, yani seffaf bolgeler seffaf kalir.
  ///
  /// Hareket azaltilmisken bu da calismaz — renk sicramasi da harekettir.
  final Color? renk;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;

    final total = duration + delay;
    // Gecikmeyi ayri bir denetleyici acmadan, egrinin baslangicini kaydirarak
    // veriyoruz. Uzun listelerde onlarca AnimationController acmak pahali.
    final start =
        (delay.inMilliseconds / total.inMilliseconds).clamp(0.0, 0.85);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1.0, curve: Motion.emphasizedDecelerate),
      builder: (context, v, c) {
        Widget icerik = Transform.translate(
          offset: Offset(0, offset * (1 - v)),
          child: c,
        );
        final vurgu = renk;
        if (vurgu != null) {
          // Renk, hareketten SONRA cozulsun: ilk yarida tam renkli durur,
          // ikinci yarida kendi rengine doner. Ayni egriyle sonseydi renk
          // daha kart yerine oturmadan kaybolur, etki gorulmezdi.
          final cozulme = ((v - 0.35) / 0.65).clamp(0.0, 1.0);
          icerik = ColorFiltered(
            // srcATop: cocugun gordugu sekil aynen kalir, uzerine yari
            // saydam renk surulur. Alfa korundugu icin yazinin kenarlari
            // ve ikonlarin bosluklari bozulmaz.
            colorFilter: ColorFilter.mode(
              vurgu.withValues(alpha: 1 - cozulme),
              BlendMode.srcATop,
            ),
            child: icerik,
          );
        }
        return Opacity(opacity: v, child: icerik);
      },
      child: child,
    );
  }

  /// Izgara/liste icin sirali gecikme.
  ///
  /// [index] buyudukce gecikme artiyor ama bir tavana vuruyor: 30. kartin
  /// 1.5 saniye beklemesi animasyon degil gecikme olur.
  static Duration stagger(int index, {int stepMs = 45, int maxMs = 360}) =>
      Duration(milliseconds: (index * stepMs).clamp(0, maxMs));
}
