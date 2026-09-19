import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/user_progress_model.dart';
import '../services/user_progress_service.dart';
// import 'messaging/conversations_screen.dart'; // Temporarily disabled

import 'devchat_screen.dart'; // DevAiChat Screen
import 'auth/profile_screen.dart';
import 'quests/quests_screen.dart';
import 'robotics_games_screen.dart';

import '../courses/screens/course_catalog_screen.dart';
import '../widgets/student_drawer.dart';
import '../widgets/cam_nav_bar.dart';
import 'market_screen.dart';
import 'activity_hub_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import '../widgets/mascot.dart';
import 'quiz/quiz_intro_screen.dart';
import '../courses/screens/interactive_lesson_screen.dart';
import '../models/learner_profile.dart';
import '../providers/settings_provider.dart';
import '../services/learning_path_service.dart';
import '../services/next_lesson_service.dart';
import '../ui/count_up.dart';
import '../ui/motion.dart';
import '../ui/press_button.dart';
import '../courses/models/interactive_lesson_model.dart';
import '../widgets/code_hero_background.dart';
import '../utils/lang.dart';
import '../utils/pro_gate.dart';
import 'subscription_screen.dart';
import '../ui/kod_akintisi.dart';

/// Unified Home Screen - Minimal, modern dashboard for all ages
class UnifiedHomeScreen extends StatefulWidget {
  const UnifiedHomeScreen({super.key});

  @override
  State<UnifiedHomeScreen> createState() => _UnifiedHomeScreenState();
}

class _UnifiedHomeScreenState extends State<UnifiedHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;

    final List<Widget> screens = [
      const UnifiedDashboard(),
      const RoboticsGamesScreen(), // Temporarily replaced ConversationsScreen
      const DevAiChatScreen(showBackButton: false),
      const ProfileScreen(),
    ];

    // NOT: Sosyal akis 1.0.5'te kaldirildi. Eskiden kayitli index
    // sinir disina tasabilecegi icin clamp duruyor.
    final safeIndex = _selectedIndex.clamp(0, screens.length - 1);

    return Scaffold(
      // Cam cubugun arkasindan icerik gorunsun diye. Scaffold bu
      // durumda govdenin MediaQuery alt bosluguna cubugun yuksekligini
      // kendisi ekliyor, yani govdedeki SafeArea'lar dogru kaliyor.
      extendBody: true,
      body: screens[safeIndex],
      bottomNavigationBar: CamNavBar(
        secili: safeIndex,
        onSec: (index) => setState(() => _selectedIndex = index),
        maddeler: [
          const CamNavMaddesi(
            icon: Icons.home_outlined,
            seciliIcon: Icons.home_rounded,
            etiket: 'Ana Sayfa',
            renk: AppTheme.primaryBlue,
          ),
          CamNavMaddesi(
            icon: isAuthenticated
                ? Icons.message_outlined
                : Icons.sports_esports_outlined,
            seciliIcon: isAuthenticated
                ? Icons.message_rounded
                : Icons.sports_esports_rounded,
            etiket: isAuthenticated ? 'Mesajlar' : 'Oyunlar',
            renk: const Color(0xFF2E9E5B),
          ),
          const CamNavMaddesi(
            icon: Icons.auto_awesome_outlined,
            seciliIcon: Icons.auto_awesome_rounded,
            etiket: 'DevAI',
            renk: Color(0xFF6C5CE7),
          ),
          const CamNavMaddesi(
            icon: Icons.person_outline_rounded,
            seciliIcon: Icons.person_rounded,
            etiket: 'Profil',
            renk: Color(0xFF8E44AD),
          ),
        ],
      ),
    );
  }
}

/// Unified Dashboard - Minimal, modern design for ages 6-99
class UnifiedDashboard extends StatefulWidget {
  const UnifiedDashboard({super.key});

  @override
  State<UnifiedDashboard> createState() => _UnifiedDashboardState();
}

class _UnifiedDashboardState extends State<UnifiedDashboard>
    with TickerProviderStateMixin {
  late AnimationController _streakController;
  late AnimationController _orbController;
  late Animation<double> _orbAnimation;

  // Progress service for visitor mode
  final UserProgressService _progressService = UserProgressService();

  @override
  void initState() {
    super.initState();
    _streakController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _orbController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _orbAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _streakController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  /// Metin secici.
  ///
  /// [de] ve [es] verilmemisse Ingilizcesi gosteriliyor. Boylece bir
  /// cumlenin Almancasi henuz yazilmamis olsa bile ekran dogru
  /// calisiyor ve ceviri sonradan tek bir arguman eklenerek
  /// tamamlanabiliyor — 500'den fazla cagri yerini bir anda cevirmek
  /// zorunda kalmadan.
  String _t(String tr, String en, [String? de, String? es]) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  /// Ana sayfa.
  ///
  /// ESKI HALI BIR DURUM PANOSUYDU ve yeni bir cocukta ekrandaki her sayi
  /// sifirdi: "Seviye 1 · 0 XP" ve bos bir ilerleme cubugu, "Gunluk Hedef
  /// 0/3 · %0 tamamlandi", altinda birbirinin ayni alti soluk kart. En buyuk
  /// gorsel oge ise bir tanitim kartiydi (DevAI). Sonuc: cocuk ekrani tarayip
  /// "simdi ne yapayim" sorusunun cevabini bulamiyordu.
  ///
  /// Rakip uygulamalarin degerlendirmelerinde tekrar eden iki sey var:
  /// (1) sikayet — kalabalik ana ekran, anlamsiz sayilar, deger gormeden
  /// gosterilen tanitim kartlari, sucluluk yaratan gunluk hedefler;
  /// (2) ovgu — "aciyorum ve ne yapacagimi hemen biliyorum".
  ///
  /// Bu yuzden ekran artik bir PANO degil bir BASLATICI:
  ///  * Tek bir baskin eylem var: siradaki ders.
  ///  * Ilerleme bir sayi degil, uzerinde yurunen bir yol.
  ///  * Hic ders bitirmemis cocuga sifirlarla dolu bir tablo gosterilmiyor;
  ///    onun ekrani ayri kuruluyor.
  ///  * Gunluk hedef, rozetler ve tanitim ilk dersten SONRA, ikincil alanda.
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userProgress =
        authProvider.userProgress ?? _progressService.getVisitorProgress();
    final completedIds = userProgress.completedLessonIds.toSet();

    final profile = user?.learnerProfile ?? const LearnerProfile();
    final next = NextLessonService.resolve(profile, completedIds);
    final nodes = NextLessonService.strip(profile, completedIds);

    // "Yeni kullanici" = hic ders bitirmemis. Giris yapmis olmasi onemli
    // degil; sifirlarla dolu bir pano her iki durumda da moral bozuyor.
    final isNewUser = completedIds.isEmpty;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      drawer: const StudentDrawer(),
      // SAFEAREA UST KENARDA YOK: hero bandi durum cubugunun altina
      // kadar uzaniyor. Selamlama satiri kendi ust boslugunu aliyor.
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(user, userProgress, isDark, isNewUser),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                if (!isNewUser) ...[
                  _buildGenelBakis(userProgress, isDark),
                  const SizedBox(height: 18),
                  _buildGununGorevi(userProgress, isDark),
                  const SizedBox(height: 18),
                ],
                if (next == null)
                  _buildPathFinished(isDark)
                else if (isNewUser)
                  _buildFirstRun(next, isDark)
                else
                  _buildContinueCard(next, isDark),
                if (nodes.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildPathStrip(nodes, isDark),
                ],
                // ETKINLIK KARTI — dersin hemen altinda ve HERKESE
                // gorunur.
                //
                // Karakter, market, quiz ve yarisma tablosu uygulamada
                // vardi ama ulasilamiyordu: kartlar sayfanin en
                // dibindeydi ve asagidaki `!isNewUser` kosulunun
                // arkasindaydi. Uygulamayi yeni kuran cocuk hicbirini
                // GORMUYORDU — maskotunu secebildigini de, jetonunu
                // nerede harcayacagini da bilmiyordu.
                const SizedBox(height: 20),
                _FadeInUp(delay: 40, child: _buildActivityCard(isDark)),
                const SizedBox(height: 20),
                _buildSecondaryRow(isDark),
                // Ekranin alt yarisi bostu. Doldururken kurala sadik
                // kaliyoruz: buraya sayi/istatistik degil, cocugun BIR
                // SONRAKI ADIMI hakkinda gercek bilgi giriyor.
                if (next != null) ...[
                  const SizedBox(height: 22),
                  _FadeInUp(
                      delay: 60, child: _buildLessonPreview(next, isDark)),
                ],
                if (isNewUser) ...[
                  const SizedBox(height: 16),
                  _FadeInUp(delay: 140, child: _buildCodeTicker(isDark)),
                  const SizedBox(height: 16),
                  _FadeInUp(delay: 220, child: _buildRoadmap(profile, isDark)),
                ],
                // Ikincil bolum yalnizca ilk ders bitince aciliyor: yeni
                // cocuga XP ve rozet gostermenin tek etkisi "hepsi bos" hissi.
                if (!isNewUser) ...[
                  const SizedBox(height: 28),
                  _buildMoreSection(isDark, userProgress),
                ],
                // Pro karti EN ALTTA.
                //
                // Ustte olsaydi uygulamayi acan cocugun gordugu ilk sey
                // satis olurdu; asagida olunca once ders, sonra yol,
                // sonra oyun/gorev geliyor ve teklif akisi kesmiyor.
                // Pro kullaniciya hic cizilmiyor.
                if (!ProGate.watchIsPro(context)) ...[
                  const SizedBox(height: 26),
                  _FadeInUp(delay: 80, child: _buildProCard(isDark)),
                ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ------------------------------------------------------------------- pro

  /// Ana sayfadaki Pro karti.
  ///
  /// FIYAT YAZMIYOR — bilerek. Karta "$1.99 / hafta" yazmak iki sekilde
  /// yanlis olurdu: fiyat App Store'da ulkeye gore degisiyor (ayni
  /// abonelik 175 ulkede farkli tutar ve para birimi) ve Apple gercek
  /// yerel fiyatin gosterilmesini istiyor. Fiyatin tek dogru kaynagi
  /// StoreKit; onu da paywall ekrani `product.price.localizedString`
  /// ile gosteriyor. Kart yalnizca NE kazandigini soyluyor.
  Widget _buildProCard(bool isDark) {
    final perks = [
      (
        Icons.workspace_premium_rounded,
        _t('Tüm kurslar açık', 'Every course unlocked', 'Alle Kurse frei',
            'Todos los cursos'),
      ),
      (
        Icons.insights_rounded,
        _t('İlerleme raporu ve sertifikalar', 'Progress report and certificates',
            'Fortschrittsbericht und Zertifikate',
            'Informe de progreso y certificados'),
      ),
      (
        Icons.videogame_asset_rounded,
        _t('Bütün oyunlar ve görevler', 'All games and quests',
            'Alle Spiele und Aufgaben', 'Todos los juegos y misiones'),
      ),
    ];

    return GestureDetector(
      onTap: _openPaywall,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5A34E8), Color(0xFF00C4E0)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A34E8).withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white.withValues(alpha: 0.85), size: 20),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _t('Kilitli olan her şey açılsın',
                  'Unlock everything that is locked',
                  'Alles freischalten, was gesperrt ist',
                  'Desbloquea todo lo que está cerrado'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: Colors.white,
                fontSize: 19,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            for (final perk in perks)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    Icon(perk.$1,
                        size: 17,
                        color: Colors.white.withValues(alpha: 0.92)),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        perk.$2,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white.withValues(alpha: 0.94),
                          fontSize: 13.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _openPaywall,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5A34E8),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _t('Planları gör', 'See the plans', 'Pläne ansehen',
                      'Ver los planes'),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  // ------------------------------------------------------------------ baslik

  // ------------------------------------------------------------------ hero

  /// Ana sayfanin ust bandi: selamlama + DEV bir sayi + Devi.
  ///
  /// NEDEN BOYLE
  ///
  /// Ekranin ilk ekrani bir satir selamlama ve hemen altinda bir kartti;
  /// uygulamayi acan cocuk "buranin bir yuzu" oldugunu hissetmiyordu.
  /// Simdi ust band tek bir seyi soyluyor: KACINCI GUNUNDESIN. Arkadaki
  /// buyuk yazi, onunde duran maskot ve altindaki ozet, ekranin geri
  /// kalanini bir panoya cevirmeden bir kimlik veriyor.
  ///
  /// SAYI UYDURULMUYOR: seri varsa gun sayisi, yoksa seviye yaziyor.
  /// Hicbiri yoksa (ilk acilis) bant yalnizca selamliyor — sifirlarla
  /// dolu bir pano yeni cocugun moralini bozuyor.
  Widget _buildHero(
      UserModel? user, UserProgress progress, bool isDark, bool isNewUser) {
    final ad = (user?.displayName ?? '').trim();
    final seri = progress.streakDays;

    final (String buyukYazi, String altYazi) = switch (0) {
      _ when seri > 0 => (
          _isEn ? 'Day $seri' : '$seri. Gün',
          _t('Üst üste çalışıyorsun', 'You are on a roll',
              'Du bist im Lauf', 'Llevas una racha'),
        ),
      _ when !isNewUser => (
          _t('Seviye ${progress.level}', 'Level ${progress.level}',
              'Level ${progress.level}', 'Nivel ${progress.level}'),
          _t('Bugün bir ders daha?', 'One more lesson today?',
              'Heute noch eine Lektion?', '¿Una lección más hoy?'),
        ),
      _ => (
          _t('Hoş geldin', 'Welcome', 'Willkommen', 'Bienvenido'),
          _t('Hadi ilk dersini yapalım', "Let's do your first lesson",
              'Machen wir deine erste Lektion', 'Vamos con tu primera lección'),
        ),
    };

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6D5AE8), Color(0xFF4FC3F7)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: KodAkintisi(
        kose: 34,
        opaklik: 0.09,
        yogunluk: 10,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 16, 18),
            child: Column(
              children: [
                // Selamlama satiri: menu, ad, profil.
                Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu_rounded,
                            color: Colors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        tooltip: _t('Menü', 'Menu', 'Menü', 'Menú'),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ad.isEmpty
                            ? _t('Merhaba!', 'Hi there!', 'Hallo!', '¡Hola!')
                            : _t('Merhaba, $ad', 'Hi, $ad', 'Hallo, $ad',
                                'Hola, $ad'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Seri rozeti yalnizca gercek bir seri varsa: "0 gün"
                    // yazan bir alev motive etmiyor, eksigi hatirlatiyor.
                    if (seri > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              _isEn ? '$seri d' : '$seri gün',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      ),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 21),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // BUYUK YAZI + MASKOT: yazi arkada, Devi onunde.
                SizedBox(
                  height: 186,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 4,
                        child: FittedBox(
                          child: Text(
                            buyukYazi,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              // Yari saydam: maskotu ezmeden arkada durur.
                              color: Colors.white.withValues(alpha: 0.42),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        child: Mascot(
                          size: 150,
                          mood: MascotMood.happy,
                          showShadow: false,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  altYazi,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ genel bakis

  /// Dort kutuluk ozet: XP, jeton, seri, bitirilen ders.
  ///
  /// Hepsi GERCEK sayi. Yeni cocuga hic cizilmiyor (bkz. build): sifirlarla
  /// dolu bir tablo, yapilacak isin degil eksigin listesi gibi duruyor.
  Widget _buildGenelBakis(UserProgress p, bool isDark) {
    final kutular = <(String, String, String, Color)>[
      (
        '⚡',
        _t('XP', 'XP', 'XP', 'XP'),
        '${p.totalXP}',
        const Color(0xFF6D5AE8),
      ),
      (
        '🪙',
        _t('Jeton', 'Coins', 'Münzen', 'Monedas'),
        '${p.jetonBalance}',
        const Color(0xFFF2A33C),
      ),
      (
        '🔥',
        _t('Seri', 'Streak', 'Serie', 'Racha'),
        _isEn ? '${p.streakDays} d' : '${p.streakDays} gün',
        const Color(0xFFEF5350),
      ),
      (
        '📘',
        _t('Ders', 'Lessons', 'Lektionen', 'Lecciones'),
        '${p.completedLessonIds.length}',
        const Color(0xFF3BA55C),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('Genel bakış', 'Overview', 'Überblick', 'Resumen'),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF14161A),
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: [
            for (final k in kutular)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      k.$2,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(k.$1, style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              k.$3,
                              style: AppTheme.number(
                                  fontSize: 19, color: k.$4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------ gunun gorevi

  /// "Bugün bir ders bitir" — gunluk sayactan okunuyor.
  ///
  /// Hedef BIR ders: ulasilabilir olsun diye. Uygulamanin asil olcusu
  /// haftalik hedef (bkz. WeeklyGoalService); bu kart gunu baslatmak
  /// icin kucuk bir davet, ceza degil — bitmediyse kirmizi bir sey yok.
  Widget _buildGununGorevi(UserProgress p, bool isDark) {
    const hedef = 1;
    final yapilan = p.dailyLessonsCompleted.clamp(0, hedef);
    final bitti = yapilan >= hedef;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _t('Günün görevi', 'Daily mission', 'Tagesaufgabe',
                      'Misión del día'),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF14161A),
                  ),
                ),
              ),
              Text(bitti ? '✅' : '🔥', style: const TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bitti
                ? _t('Bugünkü dersini bitirdin. İstersen devam et!',
                    'You finished today\'s lesson. Keep going if you like!',
                    'Du hast deine Lektion für heute geschafft. Mach ruhig weiter!',
                    '¡Has terminado la lección de hoy! Sigue si quieres.')
                : _t('Bugün bir ders bitir', 'Finish one lesson today',
                    'Beende heute eine Lektion', 'Termina una lección hoy'),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              height: 1.35,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: yapilan / hedef),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                    bitti ? const Color(0xFF3BA55C) : AppTheme.warningOrange),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$yapilan / $hedef',
            style: AppTheme.number(
                fontSize: 12,
                color: bitti
                    ? const Color(0xFF3BA55C)
                    : AppTheme.warningOrange),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------- birincil eylem

  /// Hic ders bitirmemis cocugun ekrani.
  ///
  /// Tek bir sey var: baslama tusu. Istatistik yok, tanitim yok, kart
  /// izgarasi yok. Bos durum "eksiklerin listesi" degil, bir davet.
  Widget _buildFirstRun(NextStep next, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [next.course.primaryColor, next.course.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: next.course.primaryColor.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // Duz turuncu bir dikdortgen ucuz duruyordu: gozun tutunacagi
      // hicbir sey yok. Arkada cok soluk kod simgeleri suzuluyor —
      // kart artik bir YUZEY, boyali bir kutu degil.
      child: KodAkintisi(
        kose: 24,
        child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(next.course.icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            _t('Bugün ilk kodunu yazıyorsun.',
                'Today you write your first code.', 'Heute schreibst du deinen ersten Code.', 'Hoy escribes tu primer código.'),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${next.course.nameFor(_lang)} · ${next.lesson.titleFor(_lang)}',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
          const SizedBox(height: 18),
          PressButton(
            label: _t('İlk Dersine Başla', 'Start Your First Lesson', 'Erste Lektion starten', 'Empieza tu primera lección'),
            icon: Icons.play_arrow_rounded,
            color: Colors.white,
            foreground: next.course.primaryColor,
            height: 56,
            onPressed: () => _openLesson(next),
          ),
        ],
        ),
        ),
      ),
    );
  }

  /// Devam eden cocugun birincil karti.
  Widget _buildContinueCard(NextStep next, bool isDark) {
    final color = next.course.primaryColor;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Beyaz kartta simgeler dersin kendi renginde ve daha da soluk:
      // beyaz uzerine beyaz gorunmez, ve acik zeminde ayni opaklik
      // koyu zemindekinden daha baskin durur.
      child: KodAkintisi(
        kose: 22,
        renk: color,
        opaklik: 0.055,
        child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(next.course.icon,
                    style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${next.course.nameFor(_lang)} · ${_t('Ders', 'Lesson', 'Lektion', 'Lección')} ${next.indexInCourse}/${next.courseLessonCount}',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      next.lesson.titleFor(_lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 17,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF14161A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ProgressTrack(value: next.courseProgress, color: color),
          const SizedBox(height: 14),
          PressButton(
            label: _t('Devam Et', 'Continue', 'Weiter', 'Continuar'),
            icon: Icons.play_arrow_rounded,
            color: color,
            height: 52,
            onPressed: () => _openLesson(next),
          ),
        ],
        ),
        ),
      ),
    );
  }

  Widget _buildPathFinished(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏁', style: TextStyle(fontSize: 34)),
          const SizedBox(height: 10),
          Text(
            _t('Yolundaki tüm dersleri bitirdin!',
                'You finished every lesson on your path!', 'Du hast alle Lektionen auf deinem Weg geschafft!', '¡Terminaste todas las lecciones de tu ruta!'),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF14161A),
            ),
          ),
          const SizedBox(height: 14),
          PressButton(
            label: _t('Tüm Kurslara Bak', 'Browse All Courses', 'Alle Kurse ansehen', 'Ver todos los cursos'),
            color: AppTheme.successGreen,
            height: 52,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CourseCatalogScreen()),
            ),
          ),
        ],
      ),
    );
  }

  void _openLesson(NextStep next) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InteractiveLessonScreen(
          course: next.course,
          lesson: next.lesson,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- yol seridi

  /// Ilerlemeyi bir sayi yerine bir patika olarak gosteren serit.
  ///
  /// Bitmis dersler yesil ve isaretli, siradaki ders buyuk ve renkli,
  /// ilerideki dersler soluk. Soluk olanlar KILITLI degil: "yapamazsin"
  /// degil "buraya geleceksin" demek istiyoruz.
  Widget _buildPathStrip(List<PathNode> nodes, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('Yolun', 'Your path', 'Dein Weg', 'Tu ruta'),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < nodes.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: nodes[i].done || nodes[i].current
                            ? AppTheme.successGreen.withValues(alpha: 0.55)
                            : (isDark
                                ? Colors.grey.shade800
                                : const Color(0xFFE3E6EB)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                _buildPathNode(nodes[i], isDark),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPathNode(PathNode node, bool isDark) {
    final double size = node.current ? 52 : 38;
    late final Color bg;
    late final Widget child;
    if (node.done) {
      bg = AppTheme.successGreen;
      child = const Icon(Icons.check_rounded, color: Colors.white, size: 20);
    } else if (node.current) {
      bg = AppTheme.primaryBlue;
      child =
          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26);
    } else {
      bg = isDark ? Colors.grey.shade800 : const Color(0xFFE3E6EB);
      child = Icon(Icons.lock_open_rounded,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
          size: 17);
    }

    // NOKTALAR ARTIK TIKLANABILIR.
    //
    // Serit bir OYNAT isareti tasiyordu ama hicbir seye goturmuyordu:
    // cocuk basiyor, hicbir sey olmuyordu. Ekranda oynat ucgeni gorup
    // dokunan cocuk icin bu bir kusur — isaret bir soz veriyor.
    // Ileri dersler de aciliyor; serit KILIT degil, onizleme.
    return Tooltip(
      message: node.lesson.titleFor(_lang),
      child: Semantics(
        button: true,
        label: node.lesson.titleFor(_lang),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InteractiveLessonScreen(
                  course: node.course,
                  lesson: node.lesson,
                ),
              ),
            );
          },
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
        duration: Motion.medium2,
        curve: Motion.emphasized,
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: node.current
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ ikincil satir

  /// Ana ekranda ucten fazla esit agirlikta secenek olmasin: alti ayni
  /// boyutta soluk kart, alti esit secenek demek ve cocuk hangisine
  /// dokunacagini bilemiyor. Gerisi ikincil bolume tasindi.
  Widget _buildSecondaryRow(bool isDark) {
    final items = <(IconData, String, Color, VoidCallback)>[
      (
        Icons.sports_esports_rounded,
        _t('Oyun', 'Games', 'Spiele', 'Juegos'),
        const Color(0xFF7E57C2),
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoboticsGamesScreen()),
            ),
      ),
      (
        Icons.flag_rounded,
        _t('Görevler', 'Quests', 'Aufgaben', 'Misiones'),
        AppTheme.successGreen,
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuestsScreen()),
            ),
      ),
      (
        Icons.menu_book_rounded,
        _t('Tüm Dersler', 'All lessons', 'Alle Lektionen', 'Todas las lecciones'),
        AppTheme.primaryBlue,
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CourseCatalogScreen()),
            ),
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: items[i].$4,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isDark ? Colors.grey.shade800 : const Color(0xFFE8EAEE),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(items[i].$1, color: items[i].$3, size: 24),
                    const SizedBox(height: 7),
                    Text(
                      items[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF14161A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------ ders onizlemesi

  /// "Bu derste ne ogreneceksin" — dersin KENDI tanitim adimindaki maddeler.
  ///
  /// Alt yariyi doldururken uydurma bir sey yazmiyoruz: maddeler dersin
  /// icindeki `IntroStep.highlights` alanindan geliyor, sure ve XP de dersin
  /// gercek degerleri. Cocuk butona basmadan once ne kazanacagini goruyor;
  /// bu, bos bir alani istatistikle doldurmaktan farkli olarak karari
  /// kolaylastiriyor.
  Widget _buildLessonPreview(NextStep next, bool isDark) {
    final intro = next.lesson.steps.whereType<IntroStep>().firstOrNull;
    final highlights = (intro?.highlightsFor(_lang) ?? const <String>[])
        .where((h) => h.trim().isNotEmpty)
        .take(3)
        .toList();

    // Maddesi olmayan bir ders varsa kartin tamamini gizliyoruz; yarim
    // dolu bir kart bostan daha kotu.
    if (highlights.isEmpty) return const SizedBox.shrink();

    final color = next.course.primaryColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : const Color(0xFFE8EAEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _t('Bu derste ne öğreneceksin?',
                      "What you'll learn in this lesson", 'Was du in dieser Lektion lernst', 'Lo que aprenderás en esta lección'),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF14161A),
                  ),
                ),
              ),
              _miniChip(
                  Icons.schedule_rounded,
                  _isEn
                      ? '${next.lesson.estimatedMinutes} min'
                      : '${next.lesson.estimatedMinutes} dk',
                  color,
                  isDark),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < highlights.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, size: 14, color: color),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    highlights[i],
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.grey.shade300
                          : const Color(0xFF4A505C),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniChip(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- kod seridi

  /// Kendini yazan kucuk terminal.
  ///
  /// Acilis ekraninda ayni widget var; ana sayfanin alt yarisinda da onu
  /// kullanmak iki ekrani ayni marka diline baglayan tek hareketli oge.
  /// Suslu bir bosluk doldurucu degil: cocuk "kod" denen seyin neye
  /// benzedigini butona basmadan goruyor.
  Widget _buildCodeTicker(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF10151F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                _dot(const Color(0xFFFF5F57)),
                const SizedBox(width: 6),
                _dot(const Color(0xFFFFBD2E)),
                const SizedBox(width: 6),
                _dot(const Color(0xFF28C840)),
                const SizedBox(width: 10),
                Text(
                  _t('ilk_dersim.py', 'my_first_lesson.py', 'meine_erste_lektion.py', 'mi_primera_leccion.py'),
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
            child: TypingCodeLine(
              lines: _isEn
                  ? const [
                      'print("Hello DevEducation")',
                      'for i in range(4): robot.forward()',
                      'if distance < 10: stop()',
                      'led.on()  # your first robot is ready',
                    ]
                  : const [
                      'print("Merhaba DevEducation")',
                      'for i in range(4): robot.ileri()',
                      'if mesafe < 10: dur()',
                      'led.yak()  # ilk robotun hazır',
                    ],
              textStyle: const TextStyle(
                color: Color(0xFF7CE7B0),
                fontFamily: 'monospace',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: const Color(0xFF7CE7B0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  // -------------------------------------------------------------- yol haritasi

  /// Yolun nereye gittigi.
  ///
  /// Yeni cocuk yalnizca ilk dersi degil, bu isin onunu de gormeli:
  /// Scratch'ten Arduino'ya, oradan Python'a. Onboarding'de verdigi
  /// cevaplara gore siralanmis gercek kurslar — sabit bir liste degil.
  Widget _buildRoadmap(LearnerProfile profile, bool isDark) {
    final path = LearningPathService.buildPath(profile).take(4).toList();
    if (path.length < 2) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : const Color(0xFFE8EAEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('Yolun nereye gidiyor?', 'Where your path leads', 'Wohin dein Weg führt', 'A dónde lleva tu ruta'),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF14161A),
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < path.length; i++) ...[
            if (i > 0)
              Container(
                width: 2,
                height: 14,
                margin: const EdgeInsets.only(left: 17),
                color: isDark ? Colors.grey.shade800 : const Color(0xFFE3E6EB),
              ),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: path[i].primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child:
                      Text(path[i].icon, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    path[i].nameFor(_lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w600,
                      color: i == 0
                          ? (isDark ? Colors.white : const Color(0xFF14161A))
                          : (isDark
                              ? Colors.grey.shade400
                              : const Color(0xFF6B7280)),
                    ),
                  ),
                ),
                if (i == 0)
                  _miniChip(Icons.play_arrow_rounded, _t('Şimdi', 'Now', 'Jetzt', 'Ahora'),
                      path[i].primaryColor, isDark),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------- daha fazlasi

  Widget _buildMoreSection(bool isDark, UserProgress progress) {
    final earnedBadges = _progressService
        .getUserBadges()
        .where((b) => b.isEarned)
        .map((b) => b.emoji)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTodayChip(isDark, progress),
        const SizedBox(height: 18),
        // Tanitim karti artik ekranin en buyuk ogesi degil: cocuk once dersini
        // goruyor, yardimci asistan altta duruyor.
        _buildDevAIQueryBar(isDark),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildThemedCard(
                context: context,
                icon: Icons.emoji_events_rounded,
                title: _t('Yarışma', 'Leaderboard', 'Bestenliste', 'Clasificación'),
                subtitle: _t('Sıralamayı gör', 'See the ranking', 'Rangliste ansehen', 'Ver el ranking'),
                accent: const Color(0xFF6C3CE0),
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildThemedCard(
                context: context,
                icon: Icons.storefront_rounded,
                title: _t('Market', 'Store', 'Shop', 'Tienda'),
                subtitle: _t('Jeton harca', 'Spend coins', 'Münzen ausgeben', 'Gasta monedas'),
                accent: AppTheme.warningOrange,
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildThemedCard(
                context: context,
                icon: Icons.quiz_rounded,
                title: _t('Quiz', 'Quiz', 'Quiz', 'Quiz'),
                subtitle: _t('Bilgini sına', 'Test yourself', 'Teste dein Wissen', 'Pon a prueba lo que sabes'),
                accent: AppTheme.accentTeal,
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizIntroScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 24),
        _buildBadgeShowcase(isDark, earnedBadges),
      ],
    );
  }

  /// Gunun ozeti — tek satir, sucluluk uretmeyen bir bicimde.
  ///
  /// Eskiden buyuk bir halka "%0 tamamlandi" yaziyordu; henuz bir sey
  /// yapmamis cocuga borcunu hatirlatan bir gostergeydi. Simdi ilerleme
  /// KAZANILAN olarak yaziliyor ve hedefe ulasilinca kutlaniyor;
  /// ulasilamayinca hicbir sey olmuyor.
  Widget _buildTodayChip(bool isDark, UserProgress progress) {
    final done = progress.dailyGoalsCompleted;
    final target = progress.totalDailyGoals;
    final reached = done >= target;
    final color = reached ? AppTheme.successGreen : AppTheme.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            reached ? Icons.emoji_events_rounded : Icons.today_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reached
                  ? _t('Bugünkü hedefini tamamladın!', "You hit today's goal!", 'Du hast dein Tagesziel geschafft!', '¡Cumpliste tu meta de hoy!')
                  : _t('Bugün $done ders bitirdin',
                      'You finished $done lesson(s) today', 'Du hast heute $done Lektion(en) geschafft', 'Hoy terminaste $done lección(es)'),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF14161A),
              ),
            ),
          ),
          Text(
            '$done/$target',
            style: AppTheme.number(fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDevAIQueryBar(bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DevAiChatScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Breathing AI Orb with DevAI branding
            ScaleTransition(
              scale: _orbAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      const Color(0xFFB8B5FF).withValues(alpha: 0.7),
                      const Color(0xFF667eea).withValues(alpha: 0.4),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(0xFF667eea).withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow circle
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                const Color(0xFF667eea).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // DevAI text logo
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              'Dev',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF764ba2), Color(0xFF667eea)],
                            ).createShader(bounds),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Sparkle effect
                      Positioned(
                        top: 8,
                        right: 12,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: const Color(0xFF667eea).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // DevAI Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DevAI Chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kodlama ve robotik sorularını yanıtlar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Daily Goal - Circular progress ring
  /// Etkinlik alanina goturen buyuk kart.
  ///
  /// Ders karti kadar buyuk cizilmiyor ama ikincil kartlardan belirgin
  /// olarak buyuk: cocugun kacirmasi zor olmali. Ustunde secili maskot
  /// duruyor — "burada senin arkadasin var" sinyali, soguk bir menu
  /// baslığından cok daha guclu.
  Widget _buildActivityCard(bool isDark) {
    int jeton = 0;
    try {
      jeton = context.watch<AuthProvider>().userProgress?.jetonBalance ?? 0;
    } on ProviderNotFoundException {
      jeton = 0;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ActivityHubScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7A5CF0), Color(0xFF4E32C4)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E32C4).withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Mascot(size: 64, mood: MascotMood.happy, showShadow: false),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _t('Etkinlikler', 'Activities', 'Aktivitäten', 'Actividades'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // GIYDIRME SOZU KALDIRILDI.
                    //
                    // Tek maskota gecince giyilebilir urunler silindi ve
                    // jetonlar iade edildi; markette artik cerceve, afis,
                    // isim rozeti ve seri kalkani var. Ana sayfanin bu
                    // satiri hala "karakterini giydir" diyordu: tutulmayacak
                    // bir soz.
                    _t('Çerçeveni seç, jeton harca, yarış',
                        'Pick a frame, spend coins, compete',
                        'Wähl einen Rahmen, gib Münzen aus, tritt an',
                        'Elige un marco, gasta monedas, compite'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🪙 $jeton',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildThemedCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E8E8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Baslik her zaman tek satirda kalmali; "Karakterim" gibi
                  // uzun basliklar dar kartta iki satira boluniyordu.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        color: AppTheme.darkGray,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.mediumGray,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Streak Counter - Prominent streak display
  Widget _buildBadgeShowcase(bool isDark, List<String> earnedBadges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rozetlerim (${earnedBadges.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            Text(
              'Tumunu Gör →',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (earnedBadges.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'İlk rozetine çok yakınsın! Bir ders tamamla 🎯',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: earnedBadges.length + 1, // +1 for next badge to unlock
              itemBuilder: (context, index) {
                final isLocked = index == earnedBadges.length;
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isLocked
                          ? (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLocked
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 32,
                                color: isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sonraki',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            earnedBadges[index],
                            style: const TextStyle(fontSize: 48),
                          ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Icerigi asagidan yukari, gecikmeli olarak getiren kucuk sarmalayici.
///
/// Ana sayfanin alt yarisi bir anda belirmesin: kartlar sirayla gelince
/// ekran canli hissettiriyor ve goz asagi dogru yonleniyor. Hareketi
/// azaltma ayari acikken animasyon devreye girmiyor.
class _FadeInUp extends StatelessWidget {
  const _FadeInUp({required this.child, this.delay = 0});

  final Widget child;

  /// Milisaniye cinsinden gecikme.
  final int delay;

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.long2 + Duration(milliseconds: delay),
      curve: Interval(
        // Gecikme, egrinin baslangicini kaydirarak veriliyor; her kart icin
        // ayri bir denetleyici acmaya gerek kalmiyor.
        (delay / (Motion.long2.inMilliseconds + delay)).clamp(0.0, 0.9),
        1.0,
        curve: Motion.emphasizedDecelerate,
      ),
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}
