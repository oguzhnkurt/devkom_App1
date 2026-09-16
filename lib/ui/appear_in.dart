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
  });

  final Widget child;
  final Duration delay;

  /// Baslangicta ne kadar asagida duracagi (px).
  final double offset;

  final Duration duration;

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
      builder: (context, v, c) => Opacity(
        opacity: v,
        child:
            Transform.translate(offset: Offset(0, offset * (1 - v)), child: c),
      ),
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
