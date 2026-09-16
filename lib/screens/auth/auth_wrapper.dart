import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../splash_screen.dart';
import '../role_based_home_screen.dart';
import '../unified_home_screen.dart';

/// Uygulamanin acilis yonlendirmesi:
/// 1. Yukleniyor: SplashScreen
/// 2. Oturum var (anonim ya da kayitli): RoleBasedHomeScreen
/// 3. Oturum yok (cevrimdisi): UnifiedHomeScreen - giris zorunlu degil
///
/// Not: Eskiden burada "Ne icin kullanmak istiyorsunuz?" (PurposeSelectionScreen)
/// adimi vardi. Uygulama tek kullanici tipine gectigi icin bu soru kaldirildi;
/// ilk acilista tanitim akisi bitince kullanici dogrudan ana ekrana giriyor.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        final user = authProvider.currentUser;

        if (user != null || authProvider.isAuthenticated) {
          return const RoleBasedHomeScreen();
        }

        // Oturum acilamadiysa (ornegin internet yoksa) yine de uygulamayi
        // kullanabilsin.
        return const UnifiedHomeScreen();
      },
    );
  }
}
