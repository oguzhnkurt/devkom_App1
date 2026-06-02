import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../splash_screen.dart';
import '../role_based_home_screen.dart';
import '../unified_home_screen.dart';
import 'purpose_selection_screen.dart';

/// AuthWrapper handles app navigation flow:
/// 1. Loading: Splash screen
/// 2. Authenticated + no purpose: Purpose selection
/// 3. Authenticated: Role-based home screen
/// 4. Unauthenticated: UnifiedHomeScreen (visitor mode - NO login forced)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        debugPrint('🟣 AuthWrapper: build() - isLoading: ${authProvider.isLoading}, isAuthenticated: ${authProvider.isAuthenticated}');

        // Show loading screen while checking auth state
        if (authProvider.isLoading) {
          debugPrint('🟣 AuthWrapper: Showing SplashScreen');
          return const SplashScreen();
        }

        // Get current user
        final user = authProvider.currentUser;

        // If authenticated but hasn't selected purpose, show purpose selection
        if (user != null && !(user.hasSelectedPurpose)) {
          debugPrint('🟣 AuthWrapper: Showing PurposeSelectionScreen (no purpose selected)');
          return const PurposeSelectionScreen();
        }

        // If user is authenticated, show role-based home screen
        if (authProvider.isAuthenticated) {
          debugPrint('🟣 AuthWrapper: Showing RoleBasedHomeScreen');
          return const RoleBasedHomeScreen();
        }

        // For unauthenticated users: Show home screen directly (visitor mode)
        // NO login screen forced - users can explore freely
        debugPrint('🟣 AuthWrapper: Showing UnifiedHomeScreen (visitor mode)');
        return const UnifiedHomeScreen();
      },
    );
  }
}
