import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../screens/student/schedule_screen.dart';
import '../screens/student/attendance_screen.dart';
import '../screens/student/curriculum_screen.dart';
import '../screens/student/agenda_screen.dart';
import '../screens/student/achievement_analysis_screen.dart';
import '../screens/student/surveys_screen.dart';
import '../screens/auth/login_screen.dart';
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
              Theme.of(context).primaryColor.withOpacity(0.1),
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
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? loc.student,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            _buildDrawerItem(
              context,
              icon: Icons.calendar_today,
              title: loc.schedule,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduleScreen(),
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
                    builder: (context) => const AttendanceScreen(),
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
                    builder: (context) => const CurriculumScreen(),
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
                    builder: (context) => const AgendaScreen(),
                  ),
                );
              },
            ),

            _buildDrawerItem(
              context,
              icon: Icons.analytics,
              title: loc.achievementAnalysis,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AchievementAnalysisScreen(),
                  ),
                );
              },
            ),

            _buildDrawerItem(
              context,
              icon: Icons.poll,
              title: loc.surveys,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SurveysScreen(),
                  ),
                );
              },
            ),

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
          color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
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
      hoverColor: Theme.of(context).primaryColor.withOpacity(0.05),
    );
  }
}
