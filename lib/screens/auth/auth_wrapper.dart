import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../splash_screen.dart';
import '../role_based_home_screen.dart';
import '../unified_home_screen.dart';
import 'abonelik_kapisi.dart';

/// Uygulamanin acilis yonlendirmesi:
/// 1. Yukleniyor: SplashScreen
/// 2. Oturum var (anonim ya da kayitli): RoleBasedHomeScreen
/// 3. Oturum yok (cevrimdisi): UnifiedHomeScreen - giris zorunlu degil
///
/// Not: Eskiden burada "Ne icin kullanmak istiyorsunuz?" (PurposeSelectionScreen)
/// adimi vardi. Uygulama tek kullanici tipine gectigi icin bu soru kaldirildi;
/// ilk acilista tanitim akisi bitince kullanici dogrudan ana ekrana giriyor.
///
/// 1.0.18'den itibaren ana ekran [AbonelikKapisi]'nin arkasinda: ucretsiz
/// kullanim yok, tanitimdan sonra (ve her acilista abone degilse) satin
/// alma ekrani geliyor.
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
          return const AbonelikKapisi(child: RoleBasedHomeScreen());
        }

        // Oturum acilamadiysa (ornegin internet yoksa) ana ekran yine
        // aciliyor, ama abonelik kapisindan geciyor.
        return const AbonelikKapisi(child: UnifiedHomeScreen());
      },
    );
  }
}
