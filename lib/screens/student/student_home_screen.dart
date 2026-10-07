import 'package:flutter/material.dart';
import '../../widgets/student_drawer.dart';
import '../../widgets/ana_sekmeler.dart';
import '../../widgets/cam_nav_bar.dart';

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
    // Sekmeler tek yerde: Ana Sayfa, Oyunlar, Kurslar, DevAI, Profil.
    final screens = AnaSekmeler.ekranlar();
    final lang = Localizations.localeOf(context).languageCode;

    // Eskiden kayitli index sinir disina tasabilir.
    final safeIndex = _selectedIndex.clamp(0, screens.length - 1);

    return Scaffold(
      drawer: const StudentDrawer(),
      body: screens[safeIndex],
      extendBody: true,
      bottomNavigationBar: CamNavBar(
        secili: safeIndex,
        onSec: (index) => setState(() => _selectedIndex = index),
        maddeler: AnaSekmeler.maddeler(lang),
      ),
    );
  }
}
