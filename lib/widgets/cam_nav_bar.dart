import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../ui/motion.dart';

/// Alt gezinme cubugundaki tek bir sekme.
class CamNavMaddesi {
  const CamNavMaddesi({
    required this.icon,
    required this.seciliIcon,
    required this.etiket,
    required this.renk,
  });

  /// Secili degilken gosterilen ince ikon.
  final IconData icon;

  /// Secildiginde gosterilen dolu ikon.
  final IconData seciliIcon;

  final String etiket;

  /// Sekmenin kimligi olan renk. Ana sayfa mavi, kurslar yesil ...
  final Color renk;
}

/// Buzlu cam alt gezinme cubugu.
///
/// ONCEDEN: Material'in kendi [NavigationBar]'i, dort sekmenin her
/// birinde ayri bir LinearGradient'li kare ile. Uc sorunu vardi.
///
///  1. Gradyanli haplar uygulamanin geri kalaniyla ayni dili
///     konusmuyordu; yan menu ve oyun ekranlari duz renge gecmisti,
///     alt cubuk hala 2019 gorunuyordu.
///  2. Ayni 80 satir hem [UnifiedHomeScreen] hem [StudentHomeScreen]
///     icinde kopyalanmisti; birinde yapilan duzeltme otekine hic
///     gelmiyordu.
///  3. Cubuk opak bir blok oldugu icin ekranin alt kenari kesiliyordu:
///     kaydirilan icerik cubugun altinda bitmiyor, ona carpiyordu.
///
/// SIMDI: iceriden gecen her sey bulaniklasarak gorunuyor. Cubuk
/// ekranin uzerinde duran yari saydam bir cam levha; altinda kaydirilan
/// kartlarin rengi cama vuruyor. Secili sekme kendi renginde yumusak
/// bir hapin icinde duruyor, otekiler notr gri.
///
/// Kullanan ekran [Scaffold.extendBody] = true vermeli; yoksa camin
/// arkasinda bulaniklastiracak bir sey olmaz. Scaffold bu durumda
/// govdenin MediaQuery alt bosluguna cubugun yuksekligini kendisi
/// ekliyor, yani govdedeki [SafeArea]'lar dogru calismaya devam ediyor.
class CamNavBar extends StatelessWidget {
  const CamNavBar({
    super.key,
    required this.secili,
    required this.onSec,
    required this.maddeler,
  });

  final int secili;
  final ValueChanged<int> onSec;
  final List<CamNavMaddesi> maddeler;

  /// Cam levhanin kendi yuksekligi (alt guvenli alan haric).
  static const double yukseklik = 62;

  @override
  Widget build(BuildContext context) {
    final koyu = Theme.of(context).brightness == Brightness.dark;
    final altBosluk = MediaQuery.paddingOf(context).bottom;

    // Camin rengi: neredeyse saydam ama okunurlugu koruyacak kadar
    // dolu. Tam saydam birakilirsa alttan gecen renkli bir kart
    // ikonlari yutuyor.
    final camRengi = koyu
        ? const Color(0xFF141922).withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.72);

    return Padding(
      // Kenarlardan bosluk: cubuk ekrana yapismiyor, uzerinde duruyor.
      padding: EdgeInsets.fromLTRB(14, 0, 14, 8 + altBosluk * 0.45),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: koyu ? 0.38 : 0.10),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: yukseklik,
              decoration: BoxDecoration(
                color: camRengi,
                borderRadius: BorderRadius.circular(24),
                // Ince ust kenarlik camin kalinligini veren sey; onsuz
                // cubuk bulanik bir leke gibi duruyor.
                border: Border.all(
                  color: koyu
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.65),
                  width: 1,
                ),
              ),
              // Material SART: Scaffold'un bottomNavigationBar yuvasi bir
              // Material icinde DEGIL, dolayisiyla icerideki InkWell
              // "No Material widget found" ile patlar. Saydam tip,
              // camin altina opak bir katman koymadan dalga efektini
              // mumkun kiliyor.
              child: Material(
                type: MaterialType.transparency,
                child: Row(
                  children: [
                    for (var i = 0; i < maddeler.length; i++)
                      Expanded(
                        child: _Sekme(
                          madde: maddeler[i],
                          secili: i == secili,
                          koyu: koyu,
                          onTap: () => onSec(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Sekme extends StatelessWidget {
  const _Sekme({
    required this.madde,
    required this.secili,
    required this.koyu,
    required this.onTap,
  });

  final CamNavMaddesi madde;
  final bool secili;
  final bool koyu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sure = Motion.reduced(context) ? Duration.zero : Motion.short4;
    final notr =
        koyu ? const Color(0xFF8A94A6) : const Color(0xFF98A2B3);
    final renk = secili ? madde.renk : notr;

    return Semantics(
      button: true,
      selected: secili,
      label: madde.etiket,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        // Cam uzerinde gri bir dalga cirkin duruyor; sekmenin kendi
        // rengiyle vuruyoruz.
        splashColor: madde.renk.withValues(alpha: 0.10),
        highlightColor: madde.renk.withValues(alpha: 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: sure,
              curve: Motion.emphasized,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: secili
                    ? madde.renk.withValues(alpha: koyu ? 0.22 : 0.13)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                secili ? madde.seciliIcon : madde.icon,
                size: 21,
                color: renk,
              ),
            ),
            const SizedBox(height: 3),
            // Etiket her zaman gorunuyor. Yalnizca secili sekmede
            // gostermek yer kazandiriyor ama 6 yasindaki bir cocuga
            // ikonu tek basina cozmek dusuyor.
            Text(
              madde.etiket,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 10.5,
                height: 1.1,
                fontWeight: secili ? FontWeight.w800 : FontWeight.w600,
                color: renk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
