import 'package:flutter/material.dart';

import '../theme.dart';
import 'motion.dart';

/// Bir sayiyi eski degerinden yenisine sayarak gecen metin.
///
/// Skorun bir anda "0"dan "120"ye siciramasi kazanci gorunmez kiliyor;
/// sayarak gecmesi ise kazanci bir OLAY haline getiriyor — egitim
/// uygulamalarinda XP/skor animasyonunun tek isi bu.
///
/// [AppTheme.number] kullaniyoruz: tabular rakamlar sayesinde 9 -> 10
/// gecisinde metnin genisligi degismiyor, sayac titremiyor.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.fontSize = 28,
    this.color,
    this.prefix = '',
    this.suffix = '',
    this.duration = Motion.long4,
  });

  final int value;
  final double fontSize;
  final Color? color;
  final String prefix;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: Motion.adapt(context, duration),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        '$prefix${v.round()}$suffix',
        style: AppTheme.number(fontSize: fontSize, color: color),
      ),
    );
  }
}

/// Dolarken animasyonlu ilerleme cubugu.
///
/// Ders/quiz ilerlemesi icin. Yukseklik 12, tamamen yuvarlak: ince gri bir
/// cizgi yerine ilerlemenin kendisi bir odul gibi gorunsun.
class ProgressTrack extends StatelessWidget {
  const ProgressTrack({
    super.key,
    required this.value,
    this.color = AppTheme.successGreen,
    this.background = const Color(0xFFE3E6EB),
    this.height = 12,
  });

  /// 0..1
  final double value;
  final Color color;
  final Color background;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: background,
        child: Align(
          alignment: Alignment.centerLeft,
          child: LayoutBuilder(
            builder: (context, c) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
              duration: Motion.adapt(context, Motion.medium2),
              curve: Curves.easeOut,
              builder: (context, v, _) => Container(
                width: c.maxWidth * v,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
