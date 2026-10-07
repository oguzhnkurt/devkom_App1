import 'package:flutter/material.dart';

import '../courses/screens/course_catalog_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/devchat_screen.dart';
import '../screens/robotics_games_screen.dart';
import '../screens/unified_home_screen.dart';
import '../theme.dart';
import '../utils/lang.dart';
import 'cam_nav_bar.dart';

/// Alt cubugun bes sekmesi: Ana Sayfa, Oyunlar, Kurslar, DevAI, Profil.
///
/// Iki ana ekran (misafir icin UnifiedHomeScreen, ogrenci icin
/// StudentHomeScreen) cubugu AYRI AYRI tanimliyordu ve birbirinden
/// sapmisti: birinde Kurslar yoktu, oburunde Oyunlar; misafir ekraninda
/// giris yapilinca etiket "Mesajlar" oluyor ama sekme yine Oyunlar'i
/// aciyordu. Etiketler de yalnizca Turkceydi. Artik tek yer (Ekim 2026).
class AnaSekmeler {
  AnaSekmeler._();

  static List<Widget> ekranlar() => const [
        UnifiedDashboard(),
        RoboticsGamesScreen(),
        CourseCatalogScreen(),
        DevAiChatScreen(showBackButton: false, dersiOtomatikAc: true),
        ProfileScreen(),
      ];

  static List<CamNavMaddesi> maddeler(String lang) {
    String t(String tr, String en, String de, String es) =>
        AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
    return [
      CamNavMaddesi(
        icon: Icons.home_outlined,
        seciliIcon: Icons.home_rounded,
        etiket: t('Ana Sayfa', 'Home', 'Start', 'Inicio'),
        renk: AppTheme.primaryBlue,
      ),
      CamNavMaddesi(
        icon: Icons.sports_esports_outlined,
        seciliIcon: Icons.sports_esports_rounded,
        etiket: t('Oyunlar', 'Games', 'Spiele', 'Juegos'),
        renk: const Color(0xFFE65100),
      ),
      CamNavMaddesi(
        icon: Icons.school_outlined,
        seciliIcon: Icons.school_rounded,
        etiket: t('Kurslar', 'Courses', 'Kurse', 'Cursos'),
        renk: const Color(0xFF2E9E5B),
      ),
      const CamNavMaddesi(
        icon: Icons.auto_awesome_outlined,
        seciliIcon: Icons.auto_awesome_rounded,
        etiket: 'DevAI',
        renk: Color(0xFF6C5CE7),
      ),
      CamNavMaddesi(
        icon: Icons.person_outline_rounded,
        seciliIcon: Icons.person_rounded,
        etiket: t('Profil', 'Profile', 'Profil', 'Perfil'),
        renk: const Color(0xFF8E44AD),
      ),
    ];
  }
}
