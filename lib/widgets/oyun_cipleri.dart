import 'package:flutter/material.dart';

import '../theme.dart';
import '../ui/motion.dart';

/// Oyun ekraninin ust kismindaki bilgi cipi (seviye, puan, hamle, sure).
///
/// Boru Bulmacasi, Koordinat Macerasi ve Bilgi Yarismasi seviye/puan
/// bilgisini her biri kendi bicimde yaziyordu: biri tuvalin ustune duz
/// metin, biri buyuk mavi baslik, biri hic. Komut Dizilimi ve Kod
/// Bloklari'ndaki yuvarlak, golgeli kartlarla ayni aileden gorunsunler
/// diye ortak bir cip var: renkli daire icinde simge, ustte kucuk etiket,
/// altta kalin deger.
class OyunCipi extends StatelessWidget {
  const OyunCipi({
    super.key,
    required this.simge,
    required this.etiket,
    required this.deger,
    required this.renk,
    this.vurgu = false,
  });

  final IconData simge;

  /// Kucuk ust yazi ("Seviye", "Puan"). Tek satir; sigmazsa kuculur.
  final String etiket;

  /// Asil bilgi. Sayac animasyonu icin `CountUpText` de verilebilir.
  final Widget deger;
  final Color renk;

  /// Sure azalinca gibi dikkat istenen anlarda kenarlik renklenir.
  final bool vurgu;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Motion.adapt(context, Motion.medium2),
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: vurgu ? renk : renk.withValues(alpha: 0.18),
          width: vurgu ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: renk.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(renk, Colors.white, 0.25)!, renk],
              ),
            ),
            child: Icon(simge, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etiket,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkGray.withValues(alpha: 0.65),
                      height: 1.1,
                    ),
                  ),
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color.lerp(renk, Colors.black, 0.25),
                      height: 1.15,
                    ),
                    child: deger,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bir seviye bitince tahtanin ALTINDA beliren kutlama karti.
///
/// Eskiden Boru Bulmacasi tuvalin ortasina yesil bir "Tebrikler" yazip iki
/// saniye sonra hicbir sey sormadan sonraki seviyeye geciyordu; cocuk
/// basardigi tahtaya bakamadan tahta degisiyordu. Kart tahtanin ustune
/// degil altina geliyor (cocuk sulanan cicegi, buldugu hazineyi gormeye
/// devam ediyor) ve verilmisse dugmeyle ilerleniyor.
class SeviyeKutlamaKarti extends StatelessWidget {
  const SeviyeKutlamaKarti({
    super.key,
    required this.simge,
    required this.renk,
    required this.baslik,
    required this.altYazi,
    this.eylem,
  });

  final IconData simge;
  final Color renk;
  final String baslik;
  final String altYazi;

  /// Alttaki dugme (Sonraki seviye). Kendiliginden gecen oyunlarda bos.
  final Widget? eylem;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1),
      duration: Motion.adapt(context, Motion.long2),
      curve: Motion.overshoot,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: renk.withValues(alpha: 0.35), width: 2),
          boxShadow: [
            BoxShadow(
              color: renk.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color.lerp(renk, Colors.white, 0.35)!, renk],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: renk.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(simge, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baslik,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color.lerp(renk, Colors.black, 0.3),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        altYazi,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkGray,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (eylem != null) ...[
              const SizedBox(height: 12),
              eylem!,
            ],
          ],
        ),
      ),
    );
  }
}
