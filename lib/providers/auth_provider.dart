import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/user_progress_model.dart';
import '../models/homework_model.dart';
import '../services/analytics_service.dart';
import '../services/auth_service_supabase.dart';
import '../services/user_progress_service.dart';
import '../services/local_notification_service.dart';
import '../main.dart';

class AuthProvider extends ChangeNotifier {
  final AuthServiceSupabase _authService = AuthServiceSupabase();
  final UserProgressService _progressService = UserProgressService();
  final LocalNotificationService _notificationService = LocalNotificationService();
  final AnalyticsService _analytics = AnalyticsService();

  UserModel? _currentUser;
  UserProgress? _userProgress;
  bool _isLoading = true;
  String? _errorMessage;
  bool _onboardingCompleted = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  UserProgress? get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isOnboardingCompleted => _onboardingCompleted;

  // Check if user has specific role
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  // Check if user has live camera access
  bool get hasLiveCameraAccess {
    return _currentUser?.hasLiveCameraAccess ?? false;
  }

  AuthProvider() {
    _initializeAuthListener();
    _loadOnboardingState();
  }

  // Load onboarding state from shared preferences
  Future<void> _loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    notifyListeners();
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _onboardingCompleted = true;
    notifyListeners();
  }

  // Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', false);
    _onboardingCompleted = false;
    notifyListeners();
  }

  // Initialize auth state listener
  void _initializeAuthListener() {
    _authService.authStateChanges.listen((AuthState authState) async {
      final supabaseUser = authState.session?.user;

      if (supabaseUser == null) {
        // User signed out, clear data immediately
        _currentUser = null;
        _userProgress = null;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      } else {
        // User signed in, load user data
        await _loadCurrentUser();
      }
    });

    // For demo mode, immediately set loading to false
    // Demo mode doesn't have session persistence
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_currentUser == null) {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // Load current user data
  Future<void> _loadCurrentUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentUser = await _authService.getCurrentUserData();
      _errorMessage = null;

      if (_currentUser != null) {
        await _loadUserProgress();
        await _setupNotifications();
        _identifyAdapty(_currentUser!.uid);
        _identifyAnalytics(_currentUser!);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
      _userProgress = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _identifyAdapty(String userId) {
    Adapty().identify(userId).catchError((e) {
      debugPrint('⚠️ Adapty identify error: $e');
    });
  }

  void _identifyAnalytics(UserModel user) {
    _analytics.identify(user.uid);
    _analytics.setUserProperties(
      role: user.role.name,
      isPro: user.isPro,
      displayName: user.displayName,
    );
  }

  // Load user progress from Supabase
  Future<void> _loadUserProgress() async {
    if (_currentUser == null) return;

    try {
      _userProgress = await _progressService.loadUserProgress(_currentUser!.uid);
      debugPrint('User progress loaded: Level ${_userProgress?.level}, XP ${_userProgress?.totalXP}');
    } catch (e) {
      debugPrint('Failed to load user progress: $e');
      // Create initial progress if doesn't exist
      _userProgress = UserProgress.empty(_currentUser!.uid);
    }
  }

  // Setup notifications for authenticated user
  Future<void> _setupNotifications() async {
    try {
      await _notificationService.initialize();
      await _notificationService.requestPermissions();
      await _notificationService.scheduleDailyGoalReminders();
      debugPrint('Daily goal notifications scheduled');
    } catch (e) {
      debugPrint('Failed to setup notifications: $e');
    }
  }

  // Helper to calculate age group from birth date
  AgeGroup? _calculateAgeGroup(DateTime? birthDate) {
    if (birthDate == null) return null;

    final now = DateTime.now();
    final age = now.year - birthDate.year -
        (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day) ? 1 : 0);

    if (age >= 4 && age <= 6) return AgeGroup.age4to6;
    if (age >= 7 && age <= 9) return AgeGroup.age7to9;
    if (age >= 10 && age <= 12) return AgeGroup.age10to12;
    if (age >= 13) return AgeGroup.age13plus;

    return null; // Outside defined age ranges
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    DateTime? birthDate,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Calculate age group from birth date
      final ageGroup = _calculateAgeGroup(birthDate);

      _currentUser = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        ageGroup: ageGroup,
      );

      if (_currentUser != null) {
        await _loadUserProgress();
        await _setupNotifications();
        _identifyAdapty(_currentUser!.uid);
        _identifyAnalytics(_currentUser!);
        _analytics.logSignUp('email');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_currentUser != null) {
        await _loadUserProgress();
        await _setupNotifications();
        _identifyAdapty(_currentUser!.uid);
        _identifyAnalytics(_currentUser!);
        _analytics.logLogin('email');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
      _currentUser = null;
      _userProgress = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('signOut: START');

      // Cancel daily goal notifications
      await _notificationService.cancelDailyGoalReminders();
      debugPrint('Daily goal notifications cancelled');

      await _authService.signOut();
      await Adapty().logout().catchError((e) => debugPrint('⚠️ Adapty logout error: $e'));
      _analytics.reset();

      // Clear user data
      _currentUser = null;
      _userProgress = null;
      _errorMessage = null;
      _isLoading = false;

      notifyListeners();
      debugPrint('signOut: COMPLETE');
    } catch (e) {
      debugPrint('signOut: ERROR - $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _currentUser = null;
      _userProgress = null;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  // Refresh user progress only
  Future<void> refreshProgress() async {
    await _loadUserProgress();
    notifyListeners();
  }

  // Add XP to user
  Future<void> addXP(int xp) async {
    if (_currentUser == null || _userProgress == null) return;

    try {
      await _progressService.addXP(_currentUser!.uid, xp);
      // Refresh progress after XP update
      _userProgress = _progressService.currentProgress;
      notifyListeners();
      debugPrint('Added $xp XP. New total: ${_userProgress?.totalXP}');
    } catch (e) {
      debugPrint('Failed to add XP: $e');
    }
  }

  // Update user role
  Future<void> updateUserRole(UserRole role) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Update role and hasSelectedPurpose in Supabase
      await supabase
          .from('users')
          .update({
            'role': role.name,
            'has_selected_purpose': true,
          })
          .eq('id', _currentUser!.uid);

      // Update local user
      _currentUser = _currentUser!.copyWith(role: role, hasSelectedPurpose: true);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
