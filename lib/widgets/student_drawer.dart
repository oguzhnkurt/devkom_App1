import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/roboakademi/roboakademi_parent_screen.dart';
import '../screens/roboakademi/roboakademi_curriculum_screen.dart';
import '../screens/roboakademi/roboakademi_agenda_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/videos/video_series_screen.dart';
import '../utils/app_localizations.dart';

class StudentDrawer extends StatelessWidget {
  const StudentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user?.displayName ?? loc.student,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // NOT: Burada daha once e-posta adresi gosteriliyordu.
                        // Uygulama tek kullanicili ve cocuklara yonelik oldugu
                        // icin kisisel veriyi ekranda tutmuyoruz; yerine
                        // seviye bilgisi var. Takma ad profilden degistirilebilir.
                        Text(
                          '${loc.level} '
                          '${authProvider.userProgress?.level ?? 1}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        if (user != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🪙', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  '${authProvider.userProgress?.jetonBalance ?? 0}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Video Dersler — konu konu izlenen seriler. Icerik Supabase'den
            // (video_series / video_episodes) geldigi icin yeni seri eklemek
            // uygulama guncellemesi gerektirmiyor.
            //
            // Not: Quiz ve Market bu menuden kaldirildi; ikisi de ana ekrandaki
            // hizli erisim kartlarindan zaten ulasilabiliyor, menuyu tekrar
            // ediyorlardi.
            _buildDrawerItem(
              context,
              icon: Icons.play_circle_fill_rounded,
              title: loc.videoLessons,
              iconColor: const Color(0xFF6C3CE0),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VideoSeriesScreen()),
                );
              },
            ),
            // Ayarlar — dil secimi, bildirimler, tanitimi tekrar gosterme.
            // Ekran uzun suredir vardi ama uygulamada hicbir yerden
            // acilamiyordu; menude olmadigi icin olu ekran gibi duruyordu.
            _buildDrawerItem(
              context,
              icon: Icons.settings_rounded,
              title: loc.settings,
              iconColor: const Color(0xFF546E7A),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            const Divider(height: 24),

            // RoboAkademi shortcut — only shown to workshop-enrolled parents
            if (user?.isRoboAkademi == true) ...[
              _buildDrawerItem(
                context,
                icon: Icons.precision_manufacturing_rounded,
                title: 'RoboAkademi Takip',
                iconColor: const Color(0xFF00979D),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoboAkademiParentScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 24),
            ],

            // Menu items — Ders Programı / Devamsızlık / Müfredat / Ajanda
            // are RoboAkademi-backed screens now, so they're only shown to
            // RoboAkademi-enrolled parents (no more empty placeholder pages
            // for everyone else).
            if (user?.isRoboAkademi == true) ...[
              _buildDrawerItem(
                context,
                icon: Icons.calendar_today,
                title: loc.schedule,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoboAkademiAgendaScreen(),
                    ),
                  );
                },
              ),

              _buildDrawerItem(
                context,
                icon: Icons.event_available,
                title: loc.attendance,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoboAkademiAgendaScreen(),
                    ),
                  );
                },
              ),

              _buildDrawerItem(
                context,
                icon: Icons.menu_book,
                title: loc.curriculum,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoboAkademiCurriculumScreen(),
                    ),
                  );
                },
              ),

              _buildDrawerItem(
                context,
                icon: Icons.event_note,
                title: loc.agenda,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoboAkademiAgendaScreen(),
                    ),
                  );
                },
              ),
            ],

            const Divider(height: 32),

            // Logout Button for authenticated users
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: loc.logout,
              iconColor: Colors.red,
              titleColor: Colors.red,
              onTap: () async {
                // Save the navigator state before closing drawer
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                  Navigator.pop(context); // Close drawer first

                  // Wait for drawer to close
                  await Future.delayed(const Duration(milliseconds: 200));
                  if (!navigator.context.mounted) return;

                  // Show confirmation dialog
                  final loc = AppLocalizations.of(navigator.context);
                  final confirmed = await showDialog<bool>(
                    context: navigator.context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: Text(loc.logout),
                      content: Text(loc.logoutConfirmation),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(loc.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(loc.logout),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      debugPrint('🔴 Çıkış Yap: signOut çağrılıyor...');
                      await authProvider.signOut();
                      if (!navigator.context.mounted) return;

                      debugPrint('🔴 Çıkış Yap: Navigation yapılıyor...');
                      // Navigate directly to LoginScreen and clear all routes
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false, // Remove all previous routes
                      );
                      debugPrint('🔴 Çıkış Yap: TAMAMLANDI');
                    } catch (e) {
                      // Show error if needed
                      debugPrint('🔴 Çıkış Yap: HATA - $e');
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('${loc.logoutError}: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.grey[800],
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
    );
  }
}
