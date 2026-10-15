import 'package:flutter/material.dart';
import '../widgets/siralama_karti.dart';
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
import '../widgets/ana_sekmeler.dart';
import 'market_screen.dart';
import 'activity_hub_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import '../widgets/mascot.dart';
import 'quiz/quiz_intro_screen.dart';
import '../courses/screens/interactive_lesson_screen.dart';
import '../models/learner_profile.dart';
import '../providers/settings_provider.dart';
import '../services/next_lesson_service.dart';
import '../ui/count_up.dart';
import '../ui/motion.dart';
import '../ui/press_button.dart';
import '../courses/models/interactive_lesson_model.dart';
import '../utils/lang.dart';
import '../ui/kod_akintisi.dart';
import '../models/game_model.dart';
import '../services/embedded_games_service.dart';
import '../widgets/oyun_kimligi.dart';
import '../widgets/oyun_sahnesi.dart';
import '../utils/pro_gate.dart';
import '../widgets/surpriz_sandik.dart';
import '../widgets/devi_bilmece_karti.dart';
import '../bilmece/devi_bilmeceleri_api.dart';
import '../data/dev_assistant_knowledge.dart' show kSuggestedQuestionsFor;

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
    final screens = AnaSekmeler.ekranlar();
    final lang = Localizations.localeOf(context).languageCode;

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
        maddeler: AnaSekmeler.maddeler(lang),
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
    // Sunucu listesi + cihazdaki kalici kayit (bkz. tamamlananDersler).
    // Yalnizca sunucu listesi okundugunda, ag yokken ertesi gun ilerleme
    // sifir gorunuyor ve kart "Ilk Dersine Basla" diyordu.
    final completedIds = {
      ...userProgress.completedLessonIds,
      ...authProvider.tamamlananDersler,
    };

    final profile = user?.learnerProfile ?? const LearnerProfile();
    // Once cocugun en son ders actigi kurs: katalogdan Scratch'e basladiysa
    // kart yolun ilk kursuna degil Scratch'in siradaki dersine goturuyor.
    final next = NextLessonService.resolve(profile, completedIds,
        oncelikliKurs: authProvider.sonKurs);
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
              // ALT BOSLUK CAM CUBUGU HESABA KATIYOR.
              //
              // Disdaki Scaffold `extendBody: true` veriyor: govde cam
              // gezinme cubugunun ARKASINA kadar uzaniyor. Sabit 24
              // piksel birakildiginda sayfanin son ~60 pikseli cubugun
              // altinda kaliyordu ve oraya kaydirmak mumkun degildi --
              // Pro kartinin "Planlari gor" dugmesi tam oraya denk
              // geliyordu, yani satin alma cagrisi hic gorunmuyordu.
              //
              // Flutter, `extendBody` acikken govdenin
              // MediaQuery.padding.bottom degerine cubugun yuksekligini
              // kendisi ekliyor. Dogru alt bosluk bu yuzden sabit degil,
              // o degerin uzerine konan paydir.
              padding: EdgeInsets.fromLTRB(
                  20, 18, 20, 24 + MediaQuery.paddingOf(context).bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // ILK ACILIS (hic ders bitirmemis cocuk): tek bir ders
                // karti, surpriz oyun sandigi ve kaydirmali "Kesfet" kartlari.
                //
                // Eskiden ayni ekranda alti ayri blok vardi: ders karti,
                // kilitli daireler seridi, Etkinlikler karti, uc kisayol,
                // "bu derste ne ogreneceksin", kendini yazan Python
                // terminali (Scratch dersinden once!) ve ayni yolu bir kez
                // daha anlatan bir liste. Hepsi ayni agirlikta oldugu icin
                // cocuk neye basacagini bilmiyordu (Ekim 2026 geri
                // bildirimi). Simdi her seyin bir sirasi var.
                if (isNewUser && next != null) ...[
                  _FadeInUp(child: _buildIlkGorev(next, isDark)),
                  const SizedBox(height: 24),
                  // Surpriz sandik: "bugun ne oynasam?" (Ekim 2026,
                  // "Ogrenecegin kurslar" seridinin yerine).
                  _FadeInUp(
                    delay: 60,
                    // Sandik reklamli Pro oyunlari da cikarabiliyor;
                    // `oyunuAc` onlari Oyunlar ekranindaki ayni Pro/reklam
                    // kapisindan geciriyor.
                    child: SurprizSandik(
                      lang: _lang,
                      pro: ProGate.watchIsPro(context),
                      onOyna: (g) => oyunuAc(context, g, lang: _lang),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FadeInUp(delay: 120, child: _buildKesfet(next, isDark)),
                  const SizedBox(height: 24),
                  // Devi'nin bilmecesi: her gun 3 soru (Scratch, mBlock,
                  // Arduino/Tinkercad/donanim), ana sayfada cozulur.
                  _FadeInUp(delay: 160, child: DeviBilmeceKarti(lang: _lang)),
                ] else ...[
                  if (!isNewUser) ...[
                    _buildGenelBakis(userProgress, isDark),
                    const SizedBox(height: 18),
                    _buildGununGorevi(userProgress, isDark),
                    const SizedBox(height: 18),
                  ],
                  if (next == null)
                    _buildPathFinished(isDark)
                  else
                    _buildContinueCard(next, isDark),
                  if (nodes.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _buildPathStrip(nodes, isDark),
                  ],
                  // ETKINLIK KARTI — ilk acilista "Baslarken" listesinin
                  // ucuncu adimi; sonrasinda dersin hemen altinda.
                  const SizedBox(height: 20),
                  _FadeInUp(delay: 40, child: _buildActivityCard(isDark)),
                  const SizedBox(height: 20),
                  _buildSecondaryRow(isDark),
                  if (next != null) ...[
                    const SizedBox(height: 22),
                    _FadeInUp(
                        delay: 60, child: _buildLessonPreview(next, isDark)),
                  ],
                  // Ikincil bolum yalnizca ilk ders bitince aciliyor.
                  if (!isNewUser) ...[
                    const SizedBox(height: 28),
                    _buildMoreSection(isDark, userProgress),
                  ],
                ],
                // SIRALAMA — ana sayfanin en altinda (Ekim 2026): genel XP
                // ve satrancta cocugun kendi yeri; dokununca tablo aciliyor.
                const SizedBox(height: 26),
                SiralamaKarti(lang: _lang),
                // PRO KARTI ANA SAYFADAN KALKTI (Ekim 2026).
                //
                // Ana sayfa cocugun her gun actigi yer; orada "Kilitli olan
                // her sey acilsin · Planlari gor" diye bir satis karti
                // durmasi, cocuga ebeveynine satin aldirmasi icin yapilan
                // bir cagri gibi isliyordu. Cocuklara yonelik bir urunde
                // bu dogru degil (Apple 1.3, Google Families: satin alma
                // cagrilari cocuga degil ebeveyne). Pro bilgisi artik
                // Profil > Hesap Islemleri'nde
                // duruyor; kilitli bir icerige dokunuldugunda
                // cikan bilgi sayfasi da yerinde.
                ],
              ),
            ),
          ],
        ),
      ),
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
            label: _t('Kaldığın yerden devam et', 'Continue where you left off',
                'Weiter, wo du aufgehört hast', 'Continúa donde lo dejaste'),
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

  // ------------------------------------------------------------ ilk acilis

  String _sayi(int n) => _t('$n dk', '$n min', '$n Min.', '$n min');

  /// Ilk gorev karti: dersin adi, suresi, XP'si ve "ne ogreneceksin"
  /// maddeleri TEK kartta, altinda tek buyuk dugme.
  ///
  /// Sure, XP ve maddeler dersin kendi verisinden (`IntroStep`), uydurma
  /// degil.
  Widget _buildIlkGorev(NextStep next, bool isDark) {
    final renk = next.course.primaryColor;
    final intro = next.lesson.steps.whereType<IntroStep>().firstOrNull;
    final maddeler = (intro?.highlightsFor(_lang) ?? const <String>[])
        .where((h) => h.trim().isNotEmpty)
        .take(3)
        .toList();

    Widget cip(IconData simge, String yazi) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(simge, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(yazi,
                  style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ],
          ),
        );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [next.course.primaryColor, next.course.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: renk.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: KodAkintisi(
        kose: 28,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(next.course.icon,
                        style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('İLK GÖREVİN', 'YOUR FIRST MISSION',
                              'DEINE ERSTE MISSION', 'TU PRIMERA MISIÓN'),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11.5,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Text(
                          next.course.nameFor(_lang),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                next.lesson.titleFor(_lang),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 25,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  cip(Icons.schedule_rounded, _sayi(next.lesson.estimatedMinutes)),
                  cip(Icons.bolt_rounded, '+${next.lesson.xpReward} XP'),
                  cip(Icons.format_list_numbered_rounded,
                      _t('1 / ${next.courseLessonCount} ders',
                          'Lesson 1 of ${next.courseLessonCount}',
                          'Lektion 1 von ${next.courseLessonCount}',
                          'Lección 1 de ${next.courseLessonCount}')),
                ],
              ),
              if (maddeler.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < maddeler.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check_rounded, size: 15, color: renk),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                maddeler[i],
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              PressButton(
                // Ders hic bitmemis ama acilmis olabilir (cocuk ilk derse
                // girip cikti): o zaman "basla" degil "devam et".
                // (build zaten AuthProvider'i dinliyor; burada listen: false.)
                label: Provider.of<AuthProvider>(context, listen: false)
                        .baslananKurslar
                        .contains(next.course.id)
                    ? _t('Kaldığın yerden devam et',
                        'Continue where you left off',
                        'Weiter, wo du aufgehört hast',
                        'Continúa donde lo dejaste')
                    : _t('İlk Dersine Başla', 'Start Your First Lesson',
                        'Erste Lektion starten', 'Empieza tu primera lección'),
                icon: Icons.play_arrow_rounded,
                color: Colors.white,
                foreground: renk,
                height: 58,
                onPressed: () => _openLesson(next),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ilk acilista isinma oyunu: kursa uyan UCRETSIZ bir oyun.
  GameModel? _isinmaOyunu(String kursId) {
    final tur = switch (kursId) {
      'scratch' => GameType.sequencing,
      'mblock' => GameType.blockCoding,
      'arduino' || 'arduino_ide' => GameType.blockCoding,
      'html' || 'css' => GameType.wordMatch,
      'python' || 'java' || 'csharp' => GameType.quiz,
      _ => GameType.sequencing,
    };
    for (final g in EmbeddedGamesService.getAllEmbeddedGames()) {
      if (g.type == tur) return g;
    }
    return null;
  }

  Widget _bolumBasligi(String baslik, bool isDark, {String? sag, VoidCallback? onSag}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            baslik,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF14161A),
            ),
          ),
        ),
        if (sag != null)
          GestureDetector(
            onTap: onSag,
            child: Text(
              sag,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7C4DFF),
              ),
            ),
          ),
      ],
    );
  }

  /// "Kesfet": yana kaydirilan buyuk kartlar — gunun bilgisi,
  /// etkinlikler, Devi'ye sor ve oyun onerisi (bu sirayla). Liste
  /// satirlari ve kilitli daireler yerine (Ekim 2026 geri bildirimi: "Baslarken ve Yolculugun'u
  /// begenmedim").
  Widget _buildKesfet(NextStep next, bool isDark) {
    // KESFET CESITLI (Ekim 2026): her kart baska bir sey — bir oyun
    // onerisi, Devi'ye bir soru, gunun bilgisi, etkinlikler. Eskiden uc
    // kartin ikisi oyundu.
    final oyun = _isinmaOyunu(next.course.id);
    final bugun = DateTime.now();
    final gun = DeviBilmeceleri.gunIndeksi(bugun);
    final sorular = kSuggestedQuestionsFor(_lang);
    final soru = sorular.isEmpty ? null : sorular[gun % sorular.length];
    int jeton;
    try {
      jeton = context.watch<AuthProvider>().userProgress?.jetonBalance ?? 0;
    } catch (_) {
      jeton = 0;
    }

    final kartlar = <Widget>[
      // SIRA (Ekim 2026, uygulama sahibinin istegi): gunun bilgisi,
      // etkinlikler, Devi'ye sor, oyun onerisi. Ustte sandik zaten bir oyun
      // veriyor; Kesfet'in ilk karti oyun olunca ikisi ayni seyi
      // soyluyordu.
      _kesfetKarti(
        renk: const Color(0xFFF9A825),
        ust: _t('BİLİYOR MUYDUN?', 'DID YOU KNOW?', 'WUSSTEST DU?', '¿SABÍAS QUE...?'),
        baslik: _t('Günün bilgisi', 'Fact of the day', 'Fakt des Tages', 'Dato del día'),
        gorsel: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -14,
                top: -10,
                child: Icon(Icons.lightbulb_rounded,
                    size: 96, color: Colors.white.withValues(alpha: 0.35)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 22, 8),
                child: Text(
                  DeviBilmeceleri.gununBilgisi(bugun, _lang),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {},
      ),
      _kesfetKarti(
        renk: const Color(0xFF7C4DFF),
        ust: _t('ETKİNLİKLER', 'ACTIVITIES', 'AKTIVITÄTEN', 'ACTIVIDADES'),
        baslik: _t('Çerçeveni seç', 'Pick your frame', 'Wähl deinen Rahmen', 'Elige tu marco'),
        dugme: _t('$jeton jeton', '$jeton coins', '$jeton Münzen', '$jeton monedas'),
        dugmeSimge: Icons.toll_rounded,
        gorsel: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB39DDB), Color(0xFF7C4DFF)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 6,
                bottom: -6,
                child: Image.asset('assets/images/ui/hediye.png',
                    width: 92,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
              Positioned(
                left: 16,
                top: 6,
                child: Image.asset(Mascot.durgunGorsel,
                    width: 104,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.smart_toy_rounded,
                        size: 80,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ActivityHubScreen())),
      ),
      if (soru != null)
        _kesfetKarti(
          renk: const Color(0xFF5E35B1),
          ust: _t("DEVİ'YE SOR", 'ASK DEVI', 'FRAG DEVI', 'PREGUNTA A DEVI'),
          baslik: _t('Kodlama asistanın', 'Your coding helper', 'Dein Coding-Helfer', 'Tu ayudante de código'),
          dugme: _t('Sor', 'Ask', 'Fragen', 'Preguntar'),
          dugmeSimge: Icons.auto_awesome_rounded,
          gorsel: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9575CD), Color(0xFF5E35B1)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(Mascot.durgunGorsel,
                      width: 84,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.smart_toy_rounded,
                          size: 64,
                          color: Colors.white)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          soru,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13.5,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4527A0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DevAiChatScreen(ilkSoru: soru))),
        ),
      if (oyun != null)
        _kesfetKarti(
          renk: OyunKimligi.renk(oyun.type),
          ust: _t('OYUN ÖNERİSİ', 'GAME PICK', 'SPIELTIPP', 'JUEGO RECOMENDADO'),
          baslik: oyun.titleFor(_lang),
          dugme: _t('Oyna', 'Play', 'Spielen', 'Jugar'),
          gorsel: OyunSahnesi(tur: oyun.type, lang: _lang),
          // Oyunlar ekraniyla ayni kapi: oneri ileride Pro bir oyun
          // olursa Pro/reklam kilidi atlanmasin.
          onTap: () => oyunuAc(context, oyun, lang: _lang),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bolumBasligi(_t('Keşfet', 'Explore', 'Entdecken', 'Explora'), isDark),
        const SizedBox(height: 12),
        // Sayfanin kenar boslugundan tasiyor: kartlar ekranin sagindan
        // tasarak "kaydir, daha var" diyor.
        SizedBox(
          height: 236,
          child: OverflowBox(
            maxWidth: MediaQuery.sizeOf(context).width,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: kartlar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.72,
                child: kartlar[i],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _kesfetKarti({
    required Color renk,
    required String ust,
    required String baslik,
    String? dugme,
    IconData dugmeSimge = Icons.play_arrow_rounded,
    required Widget gorsel,
    required VoidCallback onTap,
  }) {
    final koyu = Color.lerp(renk, const Color(0xFF14102B), 0.3)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: renk,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: koyu, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SizedBox(width: double.infinity, child: gorsel)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ust,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 10.5,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        Text(
                          baslik,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (dugme != null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(dugmeSimge, size: 18, color: koyu),
                        const SizedBox(width: 3),
                        Text(
                          dugme,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: koyu,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          // SABIT YUKSEKLIK DEGIL, EN AZ YUKSEKLIK. 120 pt sabitken ic alan
          // 86 pt kaliyordu (16 dolgu + 1 kenarlik, iki yandan); simge
          // (44) + baslik + alt yazi bunu 1 pt asiyordu ve iPhone 17 Pro
          // Max'te "RenderFlex overflowed by 1.00 pixels" uyarisi
          // dusuyordu. Buyuk yazi boyutunda tasma daha da buyuyordu.
          constraints: const BoxConstraints(minHeight: 120),
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
                padding: const EdgeInsets.all(8),
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
