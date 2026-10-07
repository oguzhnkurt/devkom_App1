import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/acilis_sahnesi.dart';
import 'auth_wrapper.dart';
import 'onboarding_flow_screen.dart';

/// Acilis ekrani: [AcilisSahnesi]'ni oynatir, sonra tanitima ya da
/// AuthWrapper'a gecer.
class ModernSplashScreen extends StatefulWidget {
  const ModernSplashScreen({super.key});

  @override
  State<ModernSplashScreen> createState() => _ModernSplashScreenState();
}

class _ModernSplashScreenState extends State<ModernSplashScreen> {
  Timer? _zaman;

  @override
  void initState() {
    super.initState();
    // Sahnenin giris animasyonu ~2.1 sn; bloklar kenetlendikten kisa bir
    // sure sonra geciliyor.
    _zaman = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final hasSeenOnboarding = settingsProvider.hasSeenOnboarding;
    final targetScreen =
        hasSeenOnboarding ? const AuthWrapper() : const OnboardingFlowScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _zaman?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AcilisSahnesi.zemin,
      body: AcilisSahnesi(),
    );
  }
}
