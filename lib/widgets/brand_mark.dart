import 'package:flutter/material.dart';

/// Uygulamanın kendi simgesi + adı.
///
/// NEREDE KULLANILIR
/// -----------------
/// Seyrek. Uygulama simgesi zaten açılış, giriş ve profil ekranlarında
/// var; her sayfaya bir imza koymak markayı görünür yapmıyor, sadece
/// arayüzü kalabalıklaştırıyor.
///
/// Ders ekranının altına konmuştu ve KALDIRILDI: içeriğin tam ortasında,
/// iki düğmenin arasında duruyordu ve oraya ait değildi.
///
/// ŞİRKET LOGOSU DEĞİL, UYGULAMA SİMGESİ. `logo.png` (DEVKOM YAZILIM)
/// kurumsal bir arma; çocuk için anlamı yok ve armanın altındaki yazı
/// küçük boyutta okunmuyor. `app_icon.png` uygulamanın kendi markası —
/// çocuğun ana ekranda dokunduğu simgenin aynısı.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 26,
    this.showName = true,
    this.opacity = 0.85,
  });

  /// Simgenin kenar uzunluğu.
  final double size;

  /// Simgenin yanında "DevEducation" yazsın mı.
  final bool showName;

  final double opacity;

  static const String appName = 'DevEducation';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = ClipRRect(
      // Uygulama simgesi kare; iOS'taki gibi yuvarlatılmadan konunca
      // arayüzde yamalı duruyor.
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        'assets/images/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        // Görsel yüklenemezse ekran kırmızı hata kutusuyla dolmasın.
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );

    return Opacity(
      opacity: opacity,
      child: showName
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                SizedBox(width: size * 0.32),
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: size * 0.52,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: isDark ? Colors.white70 : const Color(0xFF5B616E),
                  ),
                ),
              ],
            )
          : icon,
    );
  }
}
