import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/roboakademi/roboakademi_agenda_screen.dart';
import '../screens/roboakademi/roboakademi_curriculum_screen.dart';
import '../screens/roboakademi/roboakademi_parent_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/videos/video_series_screen.dart';
import '../theme.dart';
import '../utils/app_localizations.dart';
import 'mascot.dart';

/// Yan menü.
///
/// ESKİ HÂLİ NEDEN DEĞİŞTİ
/// -----------------------
/// Menü, uygulamanın geri kalanıyla aynı dili konuşmuyordu: doygun mavi
/// bir `DrawerHeader` gradyanı, altında beyaza giden ikinci bir gradyan,
/// ve ortada **genel bir insan simgesi**. Oysa uygulamanın beş çizilmiş
/// maskotu var ve çocuk kurulumda birini seçip ona ad veriyor; menüyü
/// açınca onu değil, gri bir avatar görüyordu.
///
/// Yeni hâli ayarlar ve ebeveyn alanıyla aynı kalıpta: yumuşak zemin,
/// beyaz kartlar, renk tonlu ikon kutuları, 20'lik köşeler.
class StudentDrawer extends StatelessWidget {
  const StudentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final ilerleme = auth.userProgress;

    return Drawer(
      backgroundColor: const Color(0xFFF2F5F9),
      child: SafeArea(
        child: Column(
          children: [
            _profilKarti(context, loc, auth, ilerleme),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                children: [
                  _madde(
                    context,
                    ikon: Icons.play_circle_fill_rounded,
                    baslik: loc.videoLessons,
                    renk: const Color(0xFF6C3CE0),
                    git: () => const VideoSeriesScreen(),
                  ),
                  _madde(
                    context,
                    ikon: Icons.settings_rounded,
                    baslik: loc.settings,
                    renk: const Color(0xFF546E7A),
                    git: () => const SettingsScreen(),
                  ),

                  // RoboAkademi — yalnızca atölyeye kayıtlı ailelere.
                  if (user?.isRoboAkademi == true) ...[
                    const SizedBox(height: 4),
                    _ayrac(),
                    _madde(
                      context,
                      ikon: Icons.precision_manufacturing_rounded,
                      baslik: 'RoboAkademi Takip',
                      renk: const Color(0xFF00979D),
                      git: () => const RoboAkademiParentScreen(),
                    ),
                    _madde(
                      context,
                      ikon: Icons.calendar_today_rounded,
                      baslik: loc.schedule,
                      renk: const Color(0xFF00979D),
                      git: () => const RoboAkademiAgendaScreen(),
                    ),
                    _madde(
                      context,
                      ikon: Icons.menu_book_rounded,
                      baslik: loc.curriculum,
                      renk: const Color(0xFF00979D),
                      git: () => const RoboAkademiCurriculumScreen(),
                    ),
                  ],

                  // ÇIKIŞ YAP — yalnızca GERÇEK hesabı olana.
                  //
                  // Uygulama anonim bir oturumla başlıyor. Anonim bir
                  // kullanıcı "çıkış" yaparsa geri dönüş yolu YOK: o
                  // oturum kaybolur, yerine yeni bir anonim kullanıcı
                  // gelir ve XP, jeton, açılan dersler o eski satırda
                  // öksüz kalır. Karşılığında hiçbir şey kazanmaz —
                  // giriş yapacağı bir hesabı zaten yoktur.
                  //
                  // Bu yüzden düğme yalnızca Apple ile giriş yapmış
                  // kullanıcıya gösteriliyor.
                  if (!auth.isAnonymous) ...[
                    const SizedBox(height: 4),
                    _ayrac(),
                    _cikisMaddesi(context, loc, auth),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Üstteki profil kartı: maskot, takma ad, seviye ve iki rozet.
  Widget _profilKarti(
    BuildContext context,
    AppLocalizations loc,
    AuthProvider auth,
    dynamic ilerleme,
  ) {
    final user = auth.currentUser;
    final maskotAdi = context.watch<SettingsProvider>().mascotName;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Çocuğun SEÇTİĞİ karakter. Tür verilmiyor: Mascot
              // ayarlardan okuyor, böylece her ekranda aynı karakter.
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Mascot(size: 54, showShadow: false),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? loc.student,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${loc.level} ${ilerleme?.level ?? 1}  ·  $maskotAdi',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12.5,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Jeton daha önce 🪙 emojisiyle çiziliyordu ve bazı
              // cihazlarda emoji yedeği bulunamayıp boş bir kare ya da
              // alakasız bir glif çıkıyordu. Artık ikon.
              _rozet(
                Icons.monetization_on_rounded,
                '${ilerleme?.jetonBalance ?? 0}',
                AppTheme.accentYellow,
              ),
              const SizedBox(width: 8),
              _rozet(
                Icons.star_rounded,
                '${ilerleme?.totalXP ?? 0} XP',
                AppTheme.warningOrange,
              ),
              if ((ilerleme?.streakDays ?? 0) > 0) ...[
                const SizedBox(width: 8),
                _rozet(
                  Icons.local_fire_department_rounded,
                  '${ilerleme?.streakDays}',
                  const Color(0xFFEF5350),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _rozet(IconData ikon, String metin, Color renk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 15, color: renk),
          const SizedBox(width: 5),
          Text(
            metin,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: renk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ayrac() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
      );

  Widget _madde(
    BuildContext context, {
    required IconData ikon,
    required String baslik,
    required Color renk,
    required Widget Function() git,
  }) {
    return _kart(
      context,
      ikon: ikon,
      baslik: baslik,
      renk: renk,
      basinca: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => git()));
      },
    );
  }

  Widget _kart(
    BuildContext context, {
    required IconData ikon,
    required String baslik,
    required Color renk,
    required VoidCallback basinca,
    Color? yaziRengi,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: basinca,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: renk.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(ikon, color: renk, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    baslik,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: yaziRengi ?? AppTheme.darkGray,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cikisMaddesi(
    BuildContext context,
    AppLocalizations loc,
    AuthProvider auth,
  ) {
    return _kart(
      context,
      ikon: Icons.logout_rounded,
      baslik: loc.logout,
      renk: AppTheme.errorRed,
      yaziRengi: AppTheme.errorRed,
      basinca: () async {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 200));
        if (!navigator.context.mounted) return;

        final yerel = AppLocalizations.of(navigator.context);
        final onay = await showDialog<bool>(
          context: navigator.context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(yerel.logout),
            content: Text(yerel.logoutConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(yerel.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                ),
                child: Text(yerel.logout),
              ),
            ],
          ),
        );
        if (onay != true) return;

        try {
          await auth.signOut();
          if (!navigator.context.mounted) return;
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } catch (e) {
          debugPrint('Çıkış yapılamadı: $e');
          messenger.showSnackBar(
            SnackBar(
              content: Text(yerel.logoutError),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      },
    );
  }
}
