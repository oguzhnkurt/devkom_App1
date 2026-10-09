import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/ad_config.dart';
import '../providers/auth_provider.dart';
import '../services/ads_service.dart';
import '../utils/lang.dart';

/// "Kısa bir video izle, jeton kazan" — tek yerde.
///
/// Market'teki şerit ve Etkinlikler'deki kart aynı akışı kullanıyor:
/// ödül yalnızca video sonuna kadar izlenirse veriliyor, jetonu
/// [AuthProvider.addJeton] ekliyor, sonuç kısa bir mesajla söyleniyor.
///
/// GÖNÜLLÜ: Pro üye de izleyebiliyor (bkz. `AdsService.canWatchRewarded`).
/// Kilit açan ya da araya giren reklamlar Pro'ya gösterilmiyor; bu
/// video ise çocuğun kendi seçtiği bir ödül.
class JetonVideosu {
  JetonVideosu._();

  static Future<bool> izlenebilir() =>
      AdsService.instance.canWatchRewarded(gonullu: true);

  /// Videoyu oynatır; jeton verildiyse true döner.
  static Future<bool> izle(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) return false;
    final lang = Localizations.localeOf(context).languageCode;
    String t(String tr, String en, String de, String es) =>
        AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
    final messenger = ScaffoldMessenger.of(context);
    void mesaj(String m, {bool iyi = false}) => messenger.showSnackBar(
          SnackBar(
            content: Text(m),
            behavior: SnackBarBehavior.floating,
            backgroundColor: iyi ? Colors.green.shade600 : null,
          ),
        );

    final sonuc = await AdsService.instance.showRewarded(gonullu: true);
    if (sonuc.earned) {
      await auth.addJeton(AdConfig.rewardedJeton, source: 'rewarded_ad');
      const j = AdConfig.rewardedJeton;
      mesaj(
          t('+$j jeton kazandın!', 'You earned $j coins!',
              '+$j Münzen verdient!', '¡Ganaste $j monedas!'),
          iyi: true);
      return true;
    }
    switch (sonuc.reason) {
      case RewardedAdFailure.dailyCapReached:
        mesaj(t('Bugünlük bu kadar. Yarın yeniden dene.',
            "That's it for today. Try again tomorrow.",
            'Für heute reicht es. Versuch es morgen wieder.',
            'Por hoy es suficiente. Inténtalo mañana.'));
        break;
      case RewardedAdFailure.dismissedEarly:
        mesaj(t('Video tamamlanmadı, jeton verilmedi.',
            'The video was not finished, so no coins this time.',
            'Das Video wurde nicht zu Ende geschaut, keine Münzen.',
            'El vídeo no terminó, esta vez no hay monedas.'));
        break;
      default:
        mesaj(t('Şu an gösterilecek video yok.', 'No video available right now.',
            'Gerade ist kein Video verfügbar.',
            'Ahora mismo no hay ningún vídeo.'));
    }
    return false;
  }
}
