import 'package:flutter/material.dart';
import '../../widgets/student_drawer.dart';
import '../../widgets/cam_nav_bar.dart';
import '../../theme.dart';
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
      extendBody: true,
      bottomNavigationBar: CamNavBar(
        secili: safeIndex,
        onSec: (index) => setState(() => _selectedIndex = index),
        maddeler: [
          CamNavMaddesi(
            icon: Icons.home_outlined,
            seciliIcon: Icons.home_rounded,
            etiket: loc.home,
            renk: AppTheme.primaryBlue,
          ),
          CamNavMaddesi(
            icon: Icons.school_outlined,
            seciliIcon: Icons.school_rounded,
            etiket: loc.courses,
            renk: const Color(0xFF2E9E5B),
          ),
          CamNavMaddesi(
            icon: Icons.auto_awesome_outlined,
            seciliIcon: Icons.auto_awesome_rounded,
            etiket: loc.devAiChat,
            renk: const Color(0xFF6C5CE7),
          ),
          CamNavMaddesi(
            icon: Icons.person_outline_rounded,
            seciliIcon: Icons.person_rounded,
            etiket: loc.profile,
            renk: const Color(0xFF8E44AD),
          ),
        ],
      ),
    );
  }
}
