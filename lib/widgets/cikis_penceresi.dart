import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../ui/motion.dart';
import '../ui/press_button.dart';
import '../utils/lang.dart';

/// "Çıkmak üzeresin, ilerlemeni kaybedeceksin" penceresi.
///
/// NEDEN AYRI BIR DOSYA
///
/// Ayni pencere iki yerde — ders ve quiz — birbirinden bagimsiz iki
/// `AlertDialog` olarak yazilmisti. Ikisi de Flutter'in KUTUDAN CIKAN
/// gorunumundeydi: kare kose, gri baslik, altta yan yana iki kucuk yazi
/// tusu ve bir kirmizi dugme. Uygulamanin geri kalani (yuvarlak kartlar,
/// Nunito, renkli rozetler, `PressButton`) yaninda bu pencere baska bir
/// uygulamadan yapistirilmis gibi duruyordu. Ustelik ders penceresi
/// yalnizca IKI dilde yaziliydi: Almanca ve Ispanyolca oynayan cocuk
/// Ingilizce bir uyari goruyordu.
///
/// TASARIM KARARLARI
///
/// - **Kalmak birincil eylem.** Buyuk, renkli `PressButton` "Devam et"
///   diyor; cikis onun altinda soluk bir yazi tusu. Cocuk yanlislikla
///   dokundugunda kaybetmesi zor olmali, kolay degil.
/// - **Kirmizi yok.** Dersten cikmak bir hata ya da tehlike degil.
///   Kirmizi bir "ÇIK" dugmesi cocuga yanlis bir sey yaptigini
///   soyluyordu. Uyari rengi yalnizca ustteki kucuk rozette, o da amber.
/// - Pencere asagidan hafifce yukselerek ve bulaniklastirilmis bir
///   perdenin uzerinde aciliyor; hareketi azaltma ayari aciksa
///   yukselme yok.
class CikisPenceresi extends StatelessWidget {
  const CikisPenceresi({
    super.key,
    required this.lang,
    required this.baslik,
    required this.govde,
    required this.kalYazisi,
    required this.cikYazisi,
    this.renk = AppTheme.primaryBlue,
  });

  final String lang;
  final String baslik;
  final String govde;
  final String kalYazisi;
  final String cikYazisi;
  final Color renk;

  /// Dersten cikis penceresi. `true` donerse cocuk cikmak istiyor.
  static Future<bool> dersten(BuildContext context, String lang,
      {Color renk = AppTheme.primaryBlue}) {
    return _goster(
      context,
      CikisPenceresi(
        lang: lang,
        renk: renk,
        baslik: AppLang.pick(lang,
            tr: 'Dersten çıkmak üzeresin',
            en: 'You are about to leave the lesson',
            de: 'Du verlässt gleich die Lektion',
            es: 'Estás a punto de salir de la lección'),
        govde: AppLang.pick(lang,
            tr: 'Bu derste yaptıkların kaydedilmeyecek. Birazdan yine '
                'buradan başlaman gerekir.',
            en: "What you did in this lesson won't be saved. You would have "
                'to start here again.',
            de: 'Was du in dieser Lektion gemacht hast, wird nicht '
                'gespeichert. Du müsstest hier neu anfangen.',
            es: 'Lo que hiciste en esta lección no se guardará. Tendrías '
                'que empezar de nuevo aquí.'),
        kalYazisi: AppLang.pick(lang,
            tr: 'Derse devam et',
            en: 'Keep going',
            de: 'Weitermachen',
            es: 'Seguir aquí'),
        cikYazisi: AppLang.pick(lang,
            tr: 'Yine de çık',
            en: 'Leave anyway',
            de: 'Trotzdem verlassen',
            es: 'Salir de todos modos'),
      ),
    );
  }

  /// Quizden cikis penceresi.
  static Future<bool> quizden(BuildContext context, String lang,
      {Color renk = AppTheme.primaryBlue}) {
    return _goster(
      context,
      CikisPenceresi(
        lang: lang,
        renk: renk,
        baslik: AppLang.pick(lang,
            tr: 'Quizden çıkmak üzeresin',
            en: 'You are about to leave the quiz',
            de: 'Du verlässt gleich das Quiz',
            es: 'Estás a punto de salir del cuestionario'),
        govde: AppLang.pick(lang,
            tr: 'Verdiğin cevaplar kaydedilmeyecek. Quiz baştan başlar.',
            en: "Your answers won't be saved. The quiz starts over.",
            de: 'Deine Antworten werden nicht gespeichert. Das Quiz '
                'beginnt von vorne.',
            es: 'Tus respuestas no se guardarán. El cuestionario empieza '
                'de nuevo.'),
        kalYazisi: AppLang.pick(lang,
            tr: 'Quize devam et',
            en: 'Keep going',
            de: 'Weitermachen',
            es: 'Seguir aquí'),
        cikYazisi: AppLang.pick(lang,
            tr: 'Yine de çık',
            en: 'Leave anyway',
            de: 'Trotzdem verlassen',
            es: 'Salir de todos modos'),
      ),
    );
  }

  static Future<bool> _goster(
      BuildContext context, CikisPenceresi pencere) async {
    final azalt = Motion.reduced(context);
    final sonuc = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: pencere.baslik,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: azalt ? Motion.short2 : Motion.medium2,
      pageBuilder: (_, __, ___) => pencere,
      transitionBuilder: (context, anim, _, child) {
        final egri =
            CurvedAnimation(parent: anim, curve: Motion.emphasizedDecelerate);
        return FadeTransition(
          opacity: egri,
          child: azalt
              ? child
              : SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(egri),
                  child: child,
                ),
        );
      },
    );
    return sonuc ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final karanlik = Theme.of(context).brightness == Brightness.dark;
    final zemin = karanlik ? const Color(0xFF1E1E2E) : Colors.white;
    final yazi = karanlik ? Colors.white : const Color(0xFF1A1A1A);

    return Dialog(
      backgroundColor: zemin,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.warningOrange.withValues(alpha: 0.14),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.pause_rounded,
                  size: 32, color: AppTheme.warningOrange),
            ),
            const SizedBox(height: 16),
            Text(
              baslik,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.25,
                color: yazi,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              govde,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14.5,
                height: 1.45,
                color: karanlik ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 22),
            PressButton(
              label: kalYazisi,
              color: renk,
              height: 52,
              onPressed: () => Navigator.pop(context, false),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor:
                    karanlik ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              child: Text(
                cikYazisi,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
