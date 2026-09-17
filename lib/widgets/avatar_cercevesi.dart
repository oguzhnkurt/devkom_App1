import 'package:flutter/material.dart';

import '../models/store_item_model.dart';

/// Profil avatarının etrafındaki çerçeve.
///
/// NEDEN VAR
///
/// Market, jetonla "avatar çerçevesi" satıyordu ama çerçeve HİÇBİR YERDE
/// görünmüyordu: çocuk jetonunu veriyor, ekranda hiçbir şey değişmiyordu.
/// Karşılığı olmayan bir vaat, mağazanın kendisini anlamsız kılar.
///
/// Artık satın alınan çerçeve profil avatarının etrafında ve marketin
/// önizlemesinde aynı şekilde çiziliyor — yani market, satın almadan
/// önce ne alacağını gerçekten gösteriyor.
///
/// Çerçeve yoksa sade beyaz bir halka var; "boş" bir görünüm değil,
/// varsayılan görünüm.
class AvatarCercevesi extends StatelessWidget {
  const AvatarCercevesi({
    super.key,
    required this.boyut,
    required this.child,
    this.cerceve,
  });

  final double boyut;

  /// Halkanın içindeki şey (maskot, baş harf...).
  final Widget child;

  /// Kuşanılmış çerçeve. null ise sade beyaz halka.
  final StoreItem? cerceve;

  static Color renk(String hex) {
    final t = hex.replaceFirst('#', '');
    final v = int.tryParse(t.length == 6 ? '0xFF$t' : '0x$t');
    return v == null ? const Color(0xFF6C3CE0) : Color(v);
  }

  @override
  Widget build(BuildContext context) {
    final c = cerceve;
    final kalinlik = boyut * 0.045;

    if (c == null) {
      return Container(
        width: boyut,
        height: boyut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.85), width: 3),
        ),
        child: Center(child: child),
      );
    }

    final ana = renk(c.colorHex);
    return SizedBox(
      width: boyut,
      height: boyut,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: boyut,
            height: boyut,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Iki renkli halka: duz bir cizgi "cerceve" gibi
              // durmuyordu, bir kenarlik gibi duruyordu.
              gradient: SweepGradient(
                colors: [
                  ana,
                  Color.lerp(ana, Colors.white, 0.55)!,
                  ana,
                  Color.lerp(ana, Colors.black, 0.25)!,
                  ana,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: ana.withValues(alpha: 0.35),
                  blurRadius: boyut * 0.12,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Container(
            width: boyut - kalinlik * 2,
            height: boyut - kalinlik * 2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(child: child),
          ),
          // Cercevenin kendi simgesi: hangi cerceveyi taktigi tek
          // bakista anlasilsin.
          if (c.iconEmoji.isNotEmpty)
            Positioned(
              bottom: 0,
              right: boyut * 0.04,
              child: Container(
                padding: EdgeInsets.all(boyut * 0.03),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(c.iconEmoji,
                    style: TextStyle(fontSize: boyut * 0.13)),
              ),
            ),
        ],
      ),
    );
  }
}
