import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/lang.dart';
import '../widgets/brand_mark.dart';
import '../widgets/mascot.dart';
import 'character_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'market_screen.dart';
import 'quiz/quiz_intro_screen.dart';

/// Etkinlik alanı — dersin dışındaki her şeyin tek kapısı.
///
/// NEDEN VAR
/// ---------
/// Karakter, market, quiz ve yarışma tablosu uygulamada VARDI ama
/// bulunamıyordu:
///
/// * Karakterim/Market/Quiz kartları ana sayfanın en dibindeydi ve
///   `isNewUser` koşulunun arkasındaydı — uygulamayı yeni kuran çocuk
///   (henüz ders bitirmemiş olduğu için) bu kartların hiçbirini
///   GÖRMÜYORDU.
/// * Yarışma tablosu yalnızca TEK bir oyunun sonuç ekranından
///   açılıyordu; menülerin hiçbirinde yoktu.
///
/// Bu ekran hepsini bir araya getiriyor ve ana sayfadan tek dokunuşla
/// açılıyor. Jeton biriktiren ama harcayacak yeri bulamayan çocuk,
/// biriktirmeyi de bırakır.
class ActivityHubScreen extends StatelessWidget {
  const ActivityHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final lang = settings.locale.languageCode;
    final spec = specOf(settings.mascot);
    // Jeton bakiyesi: AuthProvider olmayan bir agacta (ekran goruntusu
    // araclari, bazi widget testleri) ekran cokmemeli — bakiye 0
    // gosterilir, kapilar yine acilir.
    int jeton = 0;
    try {
      jeton = context.watch<AuthProvider>().userProgress?.jetonBalance ?? 0;
    } on ProviderNotFoundException {
      jeton = 0;
    }

    String t(String tr, String en, String de, String es) =>
        AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(t('Etkinlikler', 'Activities', 'Aktivitäten',
            'Actividades')),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF1F1D36),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
        children: [
          _MascotHeader(spec: spec, jeton: jeton, lang: lang),
          const SizedBox(height: 22),
          _Tile(
            emoji: '🎨',
            color: const Color(0xFFEC407A),
            title: t('Arkadaşını seç ve giydir', 'Pick and dress your buddy',
                'Kumpel wählen und anziehen', 'Elige y viste a tu amigo'),
            subtitle: t(
                'Beş karakter, şapkalar, gözlükler',
                'Five characters, hats and glasses',
                'Fünf Figuren, Hüte und Brillen',
                'Cinco personajes, gorros y gafas'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CharacterScreen())),
          ),
          _Tile(
            emoji: '🛍️',
            color: const Color(0xFFF57C00),
            title: t('Market', 'Store', 'Laden', 'Tienda'),
            subtitle: t('Jetonlarını harca', 'Spend your coins',
                'Gib deine Münzen aus', 'Gasta tus monedas'),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const MarketScreen())),
          ),
          _Tile(
            emoji: '🏆',
            color: const Color(0xFF6C3CE0),
            title: t('Yarışma tablosu', 'Leaderboard', 'Bestenliste',
                'Clasificación'),
            subtitle: t(
                'Arkadaşlarınla sıralamada yarış',
                'Race your friends up the ranking',
                'Miss dich mit deinen Freunden',
                'Compite con tus amigos'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
          ),
          _Tile(
            emoji: '🎯',
            color: const Color(0xFF00897B),
            title: t('Bilgi yarışması', 'Knowledge quiz', 'Wissensquiz',
                'Concurso'),
            subtitle: t('Bildiklerini sına', 'Test what you know',
                'Teste dein Wissen', 'Pon a prueba lo que sabes'),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const QuizIntroScreen())),
          ),
          const SizedBox(height: 26),
          // Tek imza YERI. Uygulama simgesi zaten acilis, giris ve
          // profil ekranlarinda var; her sayfaya bir tane koymak
          // markayi gorunur yapmiyor, arayuzu kalabaliklastiriyor.
          const Center(child: BrandMark(opacity: 0.55)),
        ],
      ),
    );
  }
}

/// Üstteki tanıtım: çocuğun seçtiği karakter, adı ve jeton bakiyesi.
class _MascotHeader extends StatelessWidget {
  const _MascotHeader(
      {required this.spec, required this.jeton, required this.lang});

  final MascotSpec spec;
  final int jeton;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            spec.defaultColor,
            Color.lerp(spec.defaultColor, Colors.black, 0.35)!,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Mascot(size: 84, mood: MascotMood.happy, showShadow: false),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  spec.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900),
                ),
                Text(
                  spec.taglineFor(lang),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🪙 $jeton',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.emoji,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15.5, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 12.5, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
