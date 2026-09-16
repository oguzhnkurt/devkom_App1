import 'package:flutter/material.dart';
import '../../widgets/student_drawer.dart';
import '../auth/profile_screen.dart';
import '../unified_home_screen.dart';
import '../../courses/screens/course_catalog_screen.dart';
import '../devchat_screen.dart';
import '../../utils/app_localizations.dart';

/// Student home screen with age-appropriate content
/// Shows games and homework based on student's age group
/// Updated with new professional UI screens
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);


    // Sekmeler: Ana Sayfa, Kurslar, DevAiChat, Profil.
    // NOT: Sosyal akis 1.0.5'te kaldirildi (bkz. App Store yas anketi).
    final List<Widget> screens = [
      const UnifiedDashboard(),
      const CourseCatalogScreen(),
      const DevAiChatScreen(showBackButton: false),
      const ProfileScreen(),
    ];

    // Eskiden kayitli index sinir disina tasabilir.
    final safeIndex = _selectedIndex.clamp(0, screens.length - 1);

    return Scaffold(
      drawer: const StudentDrawer(),
      body: screens[safeIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.blue.shade400),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 20),
            ),
            label: loc.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined, color: Colors.green.shade400),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            label: loc.courses,
          ),
          NavigationDestination(
            icon: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ).createShader(bounds),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            label: loc.devAiChat,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.purple.shade400),
            selectedIcon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            label: loc.profile,
          ),
        ],
      ),
    );
  }
}
