import 'dart:async';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/learner_profile.dart';
import '../models/user_model.dart';
import '../models/user_progress_model.dart';
import '../models/homework_model.dart';
import '../services/auth_service_supabase.dart';
import '../utils/nickname_generator.dart';
import '../services/app_auth_exception.dart';
import '../services/subscription_service.dart';
import '../services/user_progress_service.dart';
import '../services/local_notification_service.dart';
import '../main.dart';
import '../services/ads_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthServiceSupabase _authService = AuthServiceSupabase();
  final UserProgressService _progressService = UserProgressService();
  final LocalNotificationService _notificationService = LocalNotificationService();
  final SubscriptionService _subscriptionService = SubscriptionService();

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

  /// Anonim oturum mu? (e-posta baglanmamis hesap)
  ///
  /// Profil ekrani buna bakip "ilerlemeni kaydet" onerisini gosteriyor.
  bool get isAnonymous =>
      supabase.auth.currentUser?.isAnonymous ?? false;
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
    _bootstrap();
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

  /// Oturum dinleyicisi.
  ///
  /// BURADA CIDDI BIR HATA VARDI: `_loadCurrentUser()` yalnizca dinleyici
  /// DOLU bir oturumla tetiklendiginde cagriliyordu. Temiz kurulumda ise
  /// oturum yok, dinleyici `session == null` ile bir kez tetikleniyor ve
  /// kullaniciyi temizleyip birakiyordu — yani `signInAnonymously()` hicbir
  /// zaman calismiyordu.
  ///
  /// Sonuc: "uygulama acilista sessizce anonim oturum aciyor" ozelligi
  /// yalnizca CIHAZDA ESKI BIR OTURUM VARSA calisiyordu. Gercekten sifirdan
  /// kuran bir kullanicida hic kullanici olusmuyor, dolayisiyla profil
  /// "yuklenemedi" diyor, onboarding cevaplari kaydedilmiyor, XP ve jeton
  /// hicbir yere yazilmiyordu. Veritabaninda gun boyu tek bir yeni anonim
  /// kullanici gorunmemesinin sebebi buydu.
  ///
  /// Cozum: oturumu dinleyiciden bagimsiz olarak acilista bir kez kuruyoruz
  /// (bkz. [_bootstrap]) ve dinleyiciyi yalnizca gercek degisiklikler icin
  /// kullaniyoruz.
  void _initializeAuthListener() {
    _authService.authStateChanges.listen((AuthState authState) async {
      final supabaseUser = authState.session?.user;

      if (supabaseUser == null) {
        // Yalnizca GERCEK cikista temizliyoruz. Acilistaki "henuz oturum yok"
        // bildirimini cikis sayarsak bootstrap'i bosa dusururuz.
        if (authState.event == AuthChangeEvent.signedOut) {
          _currentUser = null;
          _userProgress = null;
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          // CIKISTAN SONRA UYGULAMA KULLANICISIZ KALIYORDU.
          //
          // Uygulamanin tasarimi "kimlik sorma, anonim calis". Ama
          // cikis bu kurali bozuyordu: oturum temizleniyor ve yerine
          // YENISI ACILMIYORDU. Cocuk cikis yapip "Hesapsiz devam et"e
          // basinca profil "Profilin yuklenemedi" diyordu — internet
          // sorunu yokken.
          unawaited(_ensureGuestSession());
        }
        return;
      }

      // Ayni kullanici zaten yuklu ise tekrar yuklemiyoruz: token yenileme
      // her seferinde tum profili bastan cekmesin.
      if (_currentUser?.uid == supabaseUser.id) return;
      await _loadCurrentUser();
    });
  }

  /// Oturum yoksa yenisini (anonim) acar.
  ///
  /// `_loadCurrentUser` zaten once mevcut oturumu soruyor, o yuzden
  /// birden fazla yerden cagrilmasi ikinci bir anonim kullanici
  /// olusturmuyor.
  Future<void> _ensureGuestSession() async {
    if (_currentUser != null) return;
    await _loadCurrentUser();
  }

  /// Acilis: oturumu kur (yoksa anonim ac) ve kullaniciyi yukle.
  bool _bootstrapped = false;
  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;
    await _loadCurrentUser();
  }

  /// Ayni anda iki kez calismasin: anonim giris dinleyiciyi tetikliyor ve
  /// dinleyici de buraya donuyordu.
  bool _loadingUser = false;

  // Load current user data
  Future<void> _loadCurrentUser() async {
    if (_loadingUser) return;
    _loadingUser = true;
    try {
      _isLoading = true;
      notifyListeners();

      _currentUser = await _authService.getCurrentUserData();

      // Hicbir oturum yoksa sessizce anonim oturum aciyoruz: uygulama
      // kimlik sormadan calissin, ilerleme ilk andan itibaren kaydedilsin.
      // Kullanici isterse sonradan e-posta baglayip hesabini kalici yapar.
      _currentUser ??= await _authService.signInAnonymously();

      _errorMessage = null;
    } catch (e) {
      // Yalnizca kullanicinin KENDISINI yukleyemedigimizde oturumu bosaltiyoruz.
      _errorMessage = e.toString();
      _currentUser = null;
      _userProgress = null;
    }

    // Kullanici yuklendikten sonraki isler ayri bir try icinde.
    //
    // Onceden hepsi ayni try blogundaydi ve catch `_currentUser = null`
    // yapiyordu: jeton talebi, bildirim izni ya da Adapty tarafinda olusan
    // herhangi bir hata, basariyla yuklenmis kullaniciyi siliyordu. Sonuc
    // kullanicinin gordugu sey "Profilin yuklenemedi" oluyordu - oysa
    // kullanici gayet yuklenmisti, sadece yan islerden biri patlamisti.
    if (_currentUser != null) {
      // Reklam servisi Pro bayragini buradan ogreniyor. Paywall'da
      // "Reklamsiz kullanim" yaziyor; bu bir vaat, o yuzden kullanici
      // her yuklendiginde tazeleniyor.
      AdsService.instance.setProMember(_currentUser!.isPro);
      try {
        await _ensureNickname();
        await _flushPendingProfileEdits();
        await _loadUserProgress();
        await _claimPendingProJeton();
        await _setupNotifications();
        _identifyAdapty(_currentUser!.uid);
      } catch (e) {
        debugPrint('⚠️ Oturum sonrasi hazirlik adimi basarisiz: $e');
      }
    }

    _isLoading = false;
    _loadingUser = false;
    notifyListeners();
  }

  // ==========================================================================
  // Oturum hazir olmadan yapilan degisiklikler
  // ==========================================================================
  // Onboarding, oturumun acilmasini beklemeden bitirilebiliyor: uygulama
  // acilirken splash 2.5 saniye sonra tanitimi gosteriyor, oturum ise
  // (ozellikle refresh_token ile) daha gec hazir oluyor. Kullanici sorulari
  // hizli cevaplayip bitirdiginde `_currentUser` henuz null oluyordu ve hem
  // takma ad hem de ogrenme profili sessizce kayboluyordu.
  //
  // Cozum: kullanici yoksa cevaplari cihazda bekletiyoruz ve oturum acilir
  // acilmaz yaziyoruz.
  static const _pendingNameKey = 'pending_display_name';
  static const _pendingAgeBandKey = 'pending_age_band';
  static const _pendingSkillLevelKey = 'pending_skill_level';
  static const _pendingGoalKey = 'pending_learning_goal';

  Future<void> _flushPendingProfileEdits() async {
    final prefs = await SharedPreferences.getInstance();

    final pendingName = prefs.getString(_pendingNameKey);
    if (pendingName != null && pendingName.trim().isNotEmpty) {
      final ok = await updateDisplayName(pendingName);
      if (ok) await prefs.remove(_pendingNameKey);
    }

    final profile = LearnerProfile(
      ageBand: LearnerAgeBandX.fromDb(prefs.getString(_pendingAgeBandKey)),
      skillLevel: SkillLevelX.fromDb(prefs.getString(_pendingSkillLevelKey)),
      goal: LearningGoalX.fromDb(prefs.getString(_pendingGoalKey)),
    );
    if (profile.isComplete) {
      final ok = await saveLearnerProfile(profile);
      if (ok) {
        await prefs.remove(_pendingAgeBandKey);
        await prefs.remove(_pendingSkillLevelKey);
        await prefs.remove(_pendingGoalKey);
      }
    }
  }

  Future<void> _stashProfile(LearnerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    if (profile.ageBand != null) {
      await prefs.setString(_pendingAgeBandKey, profile.ageBand!.dbValue);
    }
    if (profile.skillLevel != null) {
      await prefs.setString(_pendingSkillLevelKey, profile.skillLevel!.dbValue);
    }
    if (profile.goal != null) {
      await prefs.setString(_pendingGoalKey, profile.goal!.dbValue);
    }
  }

  /// Oturum hazir olana kadar bekler. Onboarding sonunda cagriliyor.
  /// Hazir olursa true, sure dolarsa false doner.
  Future<bool> waitForSession({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (_currentUser == null && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return _currentUser != null;
  }

  /// Görünen adı boşsa ya da e-postadan türetilmişse otomatik bir
  /// Türkçe takma ad atar. Kullanıcıya soru sormuyoruz; isterse
  /// profilden kendisi değiştiriyor.
  Future<void> _ensureNickname() async {
    final user = _currentUser;
    if (user == null) return;

    final current = user.displayName.trim();
    final looksLikeEmail = current.contains('@');
    if (current.isNotEmpty && !looksLikeEmail) return;

    final nickname = NicknameGenerator.generate();
    try {
      await supabase
          .from('users')
          .update({'display_name': nickname})
          .eq('id', user.uid);
      _currentUser = user.copyWith(displayName: nickname);
      debugPrint('🎲 Otomatik takma ad atandı: $nickname');
    } catch (e) {
      debugPrint('Takma ad atanamadı: $e');
    }
  }

  void _identifyAdapty(String userId) {
    Adapty().identify(userId).catchError((e) {
      debugPrint('⚠️ Adapty identify error: $e');
    });
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
        await _ensureNickname();
        await _loadUserProgress();
        await _setupNotifications();
        _identifyAdapty(_currentUser!.uid);
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
        await _ensureNickname();
        await _loadUserProgress();
        await _setupNotifications();
        _identifyAdapty(_currentUser!.uid);
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

      // Clear user data
      _currentUser = null;
      _userProgress = null;
      _errorMessage = null;
      _isLoading = false;

      notifyListeners();

      // Yeni misafir oturumu BURADA aciliyor, dinleyiciyi beklemeden.
      // Cikistan hemen sonra ana ekrana gidiliyor; oturum bir kare bile
      // bos kalirsa o ekranlar "kullanici yok" haliyle ciziliyor.
      await _ensureGuestSession();

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

  /// Pro kullanicinin bekleyen jetonlarini alir.
  ///
  /// Sunucu ayni donem icin ikinci kez jeton vermedigi icin her aciliste
  /// cagirmak guvenli; bu sayede abonelik yenilendiginde yeni ayin jetonu
  /// kullanici hicbir sey yapmadan hesabina duser.
  Future<void> _claimPendingProJeton() async {
    if (_currentUser?.isPro != true) return;
    final grant = await _subscriptionService.claimProJeton();
    if (grant != null && grant.hasReward) {
      await _loadUserProgress();
    }
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

  /// Jeton ekler ve ilerlemeyi tazeler.
  ///
  /// Market'teki ödüllü video buradan geçiyor. Ekran kendi
  /// `UserProgressService` örneğini kurmasın diye burada: iki örnek
  /// olursa biri jetonu ekliyor, diğeri eski bakiyeyi gösteriyor.
  Future<void> addJeton(int amount, {String? source}) async {
    final user = _currentUser;
    if (user == null || amount <= 0) return;
    try {
      await _progressService.addJeton(user.uid, amount, source: source);
      _userProgress = _progressService.currentProgress;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to add jeton: $e');
    }
  }

  /// Takma adı günceller. Kullanıcı profilden değiştirebiliyor;
  /// hesap açılışında otomatik atanan ada dokunmak zorunda değil.
  Future<bool> updateDisplayName(String newName) async {
    final user = _currentUser;
    if (user == null) {
      // Oturum henuz hazir degil: adi cihazda beklet, oturum acilinca yaz.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingNameKey, newName.trim());
      return false;
    }

    final trimmed = newName.trim();
    if (trimmed.isEmpty) return false;

    try {
      await supabase
          .from('users')
          .update({'display_name': trimmed})
          .eq('id', user.uid);

      _currentUser = user.copyWith(displayName: trimmed);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Takma ad güncellenemedi: $e');
      return false;
    }
  }

  /// Cihaz Apple ile girisi destekliyor mu? (iOS/macOS)
  Future<bool> isAppleSignInAvailable() =>
      _authService.isAppleSignInAvailable();

  /// Apple ile giris. Anonim ilerleme yeni hesaba tasinir.
  ///
  /// Kullanici vazgecerse false doner ve hata mesaji set edilmez - iptal bir
  /// hata degil.
  Future<bool> signInWithApple() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithApple();
      if (user == null) return false;

      _currentUser = user;
      await _ensureNickname();
      await _flushPendingProfileEdits();
      await _loadUserProgress();
      await _claimPendingProJeton();
      _identifyAdapty(user.uid);
      return true;
    } on AppAuthException catch (e) {
      // Servis katmani zaten kullaniciya gosterilebilir bir cumle uretti.
      debugPrint('Apple giris hatasi (teknik): ${e.debugDetail}');
      _errorMessage = e.message;
      return false;
    } catch (e) {
      // Beklenmeyen bir sey: teknik metni ASLA ekrana basmiyoruz, yalniz
      // loga yaziyoruz.
      debugPrint('Apple giris beklenmeyen hata: $e');
      _errorMessage = 'Şu an giriş yapılamadı. Birazdan tekrar dener misin?';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Onboarding'de verilen cevaplari kaydeder.
  ///
  /// Kisisel ogrenme yolu bu uc alandan uretiliyor (LearningPathService), o
  /// yuzden yerel kopyayi da hemen guncelleyip dinleyicileri uyariyoruz;
  /// aksi halde onboarding'den cikan kullanici bir sonraki acilisa kadar
  /// varsayilan yolu goruyordu.
  Future<bool> saveLearnerProfile(LearnerProfile profile) async {
    final user = _currentUser;
    if (user == null) {
      // Bkz. _flushPendingProfileEdits: cevaplari kaybetmiyoruz.
      await _stashProfile(profile);
      return false;
    }

    final completedAt = DateTime.now();
    try {
      await supabase.from('users').update({
        ...profile.toSupabase(),
        'onboarding_completed_at': completedAt.toIso8601String(),
      }).eq('id', user.uid);

      _currentUser = user.copyWith(
        ageBand: profile.ageBand,
        skillLevel: profile.skillLevel,
        learningGoal: profile.goal,
        onboardingCompletedAt: completedAt,
      );
      notifyListeners();
      return true;
    } catch (e) {
      // Kaydedilemese bile onboarding'i tikamiyoruz: cevaplar bellekte
      // duruyor, kullanici uygulamaya girebiliyor.
      debugPrint('Ogrenci profili kaydedilemedi: $e');
      await _stashProfile(profile);
      _currentUser = user.copyWith(
        ageBand: profile.ageBand,
        skillLevel: profile.skillLevel,
        learningGoal: profile.goal,
      );
      notifyListeners();
      return false;
    }
  }

  /// Anonim hesabi e-posta ile kalici hale getirir. Ilerleme korunur.
  Future<bool> linkAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.linkEmailToAnonymous(
        email: email,
        password: password,
        displayName: displayName,
      );

      _currentUser = await _authService.getCurrentUserData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user role
  Future<void> updateUserRole(UserRole role, {bool isRoboAkademi = false}) async {
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
            'is_roboakademi': isRoboAkademi,
          })
          .eq('id', _currentUser!.uid);

      // Update local user
      _currentUser = _currentUser!.copyWith(
        role: role,
        hasSelectedPurpose: true,
        isRoboAkademi: isRoboAkademi,
      );
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
