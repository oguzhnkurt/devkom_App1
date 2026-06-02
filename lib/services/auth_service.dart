import 'package:flutter/foundation.dart';
import '../core/service_locator.dart';

/// Auth Service Stub - Redirects to Supabase Auth
/// This is a compatibility layer for old code
class AuthService {
  // Redirect all calls to Supabase auth service
  Future<void> signOut() async {
    debugPrint('🔄 AuthService: Redirecting to AuthServiceSupabase');
    await authService.signOut();
  }

  Future<dynamic> getCurrentUserData() async {
    debugPrint('🔄 AuthService: Redirecting to AuthServiceSupabase');
    return await authService.getCurrentUserData();
  }

  dynamic get currentUser {
    debugPrint('🔄 AuthService: Use AuthServiceSupabase instead');
    return null;
  }

  Stream<dynamic> authStateChanges() {
    debugPrint('🔄 AuthService: Use AuthServiceSupabase.authStateChanges instead');
    return Stream.empty();
  }

  Future<bool> isAppleSignInAvailable() async {
    debugPrint('⚠️ AuthService.isAppleSignInAvailable: Supabase migration pending');
    return false;
  }

  Future<dynamic> signInWithApple() async {
    debugPrint('⚠️ AuthService.signInWithApple: Supabase migration pending');
    return null;
  }
}
