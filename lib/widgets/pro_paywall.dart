import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../screens/robotics_games_screen.dart' show ProGames;
import '../screens/subscription_screen.dart';
import '../theme.dart';
import '../ui/press_button.dart';
import '../utils/lang.dart';

/// Bir Pro ozellige carpildiginda acilan alt sayfa.
///
/// ONEMLI DUZELTME: Bu widget daha once uygulamada karsiligi olmayan sozler
/// veriyordu — "Sinirsiz AI asistan kullanimi", "Offline icerik indirme",
/// "Oncelikli destek", "Sinirsiz paylasim" — ve butonun uzerinde magazadan
/// gelmeyen, elle yazilmis bir fiyat duruyordu: "Pro'ya Gec - Ilk 3 Ay
/// TL69.99". Ikisi de App Store Kural 3.1.2 acisindan riskli: fiyat her zaman
/// StoreKit'ten okunmali ve yalnizca gercekten sunulan ozellikler
/// listelenmeli. Liste artik abonelik ekranindakiyle ayni ve butonda fiyat
/// yok; fiyat, planlarin bulundugu ekranda magazadan geliyor.
class ProPaywall extends StatelessWidget {
  final String title;
  final String message;
  final String? featureDescription;
  final VoidCallback? onUpgrade;

  const ProPaywall({
    super.key,
    required this.title,
    required this.message,
    this.featureDescription,
    this.onUpgrade,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? featureDescription,
    VoidCallback? onUpgrade,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProPaywall(
        title: title,
        message: message,
        featureDescription: featureDescription,
        onUpgrade: onUpgrade,
      ),
    );
  }

  static const Color _ink = Color(0xFF14161A);
  static const Color _inkSoft = Color(0xFF5B616E);

  /// Yalnizca gercekten sunulanlar — ve DORT DILDE.
  ///
  /// Bu liste sabit ve tamamen Turkce idi: uygulamanin dili ne olursa
  /// olsun Pro sayfasi Turkce aciliyordu. Oyun sayisi da elle yazilmisti
  /// ("13 ek oyun"); gercek sayi [ProGames.lockedGameCount] ile
  /// katalogdan geliyor.
  List<(IconData, String)> _features(String lang) {
    String t(String tr, String en, String de, String es) =>
        AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
    final n = ProGames.lockedGameCount;
    return [
      (
        Icons.sports_esports_rounded,
        t('$n ek oyun', '$n more games', '$n weitere Spiele', '$n juegos más'),
      ),
      (
        Icons.school_rounded,
        t('İleri seviye kurslar: Arduino IDE, Java, C#',
            'Advanced courses: Arduino IDE, Java, C#',
            'Fortgeschrittene Kurse: Arduino IDE, Java, C#',
            'Cursos avanzados: Arduino IDE, Java, C#'),
      ),
      (
        Icons.insights_rounded,
        t('Kişisel ilerleme raporu', 'A personal progress report',
            'Ein persönlicher Fortschrittsbericht',
            'Un informe de progreso personal'),
      ),
      (
        Icons.workspace_premium_rounded,
        t('Kurs bitirme sertifikası', 'A certificate for each course',
            'Ein Zertifikat für jeden Kurs', 'Un certificado por cada curso'),
      ),
      (
        Icons.monetization_on_rounded,
        t('1000 jeton hediye, her ay 300 jeton',
            '1000 bonus tokens, 300 every month',
            '1000 Bonus-Münzen, jeden Monat 300',
            '1000 fichas de regalo, 300 cada mes'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lang = context.watch<SettingsProvider>().locale.languageCode;
    final features = _features(lang);
    String t(String tr, String en, String de, String es) =>
        AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE1E7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, Color(0xFF6D5AE8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    size: 36, color: Colors.white),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(color: _ink),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: _inkSoft),
              ),
              if (featureDescription != null) ...[
                const SizedBox(height: 6),
                Text(
                  featureDescription!,
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(color: _inkSoft),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < features.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(features[i].$1,
                              size: 19, color: AppTheme.primaryBlue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              features[i].$2,
                              style: text.bodyMedium?.copyWith(
                                color: _ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Uygulamanın her yerindeki ana düğmeyle AYNI his.
              //
              // Burada düz bir `ElevatedButton` vardı: dokununca yalnızca
              // soluk bir dalga çiziyordu. [PressButton] parmak değince
              // gerçekten çöküyor — çocuk dokunuşunun kaydedildiğini
              // görüyor ve iki kez basmıyor.
              PressButton(
                label: t('Pro seçeneklerine bak', 'See the Pro plans',
                    'Pro-Pläne ansehen', 'Ver los planes Pro'),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  (onUpgrade ?? () => _handleUpgrade(context))();
                },
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  t('Şimdi değil', 'Not now', 'Jetzt nicht', 'Ahora no'),
                  style: text.labelMedium?.copyWith(color: _inkSoft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleUpgrade(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }
}
