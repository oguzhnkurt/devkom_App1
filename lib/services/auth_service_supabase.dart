import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_auth_exception.dart';
import '../models/user_model.dart';
import '../models/homework_model.dart';
import '../main.dart';

/// Supabase Authentication Service
/// Handles all Supabase Authentication operations
class AuthServiceSupabase {
  final SupabaseClient _supabase = supabase;

  // Get current Supabase user
  User? get currentUser => _supabase.auth.currentUser;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Get user-friendly error message
  String _getErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Hatalı e-posta veya şifre.';
    } else if (message.contains('Email not confirmed')) {
      return 'E-posta adresinizi onaylamanız gerekiyor.';
    } else if (message.contains('User already registered')) {
      return 'Bu e-posta adresi zaten kullanımda.';
    } else if (message.contains('Password should be at least')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    } else if (message.contains('Invalid email')) {
      return 'Geçersiz e-posta adresi.';
    } else if (message.contains('Network request failed')) {
      return 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
    }
    return 'Bir hata oluştu: $message';
  }

  /// Register with email and password
  /// Creates both Supabase Auth user and users table record
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    AgeGroup? ageGroup,
    String? parentId,
  }) async {
    try {
      debugPrint('📝 Registering user: $email');

      // Sign up with Supabase Auth.
      // NOTE: all profile fields are also passed as user metadata so that
      // the `handle_new_user` DB trigger (see supabase/migrations/18_*.sql)
      // can create the public.users row server-side. This is required
      // because when "Confirm email" is enabled in Supabase Auth, signUp()
      // does not return an active session, so any client-side insert into
      // users would fail RLS (auth.uid() is null without a session).
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          'role': role.name,
          'age_group': ageGroup?.toSupabaseValue(),
          'parent_id': parentId,
        },
      );

      if (response.user == null) {
        throw Exception('Kullanıcı oluşturulamadı');
      }

      final user = response.user!;
      debugPrint('✅ Supabase Auth user created: ${user.id}');

      // The users table row is created automatically by the
      // `handle_new_user` trigger on auth.users (runs server-side,
      // bypasses RLS). If a session is already active at this point
      // (email confirmation disabled), also try to sync/complete the row
      // client-side. This is best-effort: failures here are not fatal
      // since the trigger has already created the row.
      final now = DateTime.now().toIso8601String();
      if (response.session != null) {
        try {
          await _supabase.from('users').upsert({
            'id': user.id,
            'email': email,
            'display_name': displayName,
            'role': role.name,
            'age_group': ageGroup?.toSupabaseValue(),
            'parent_id': parentId,
            'last_login_at': now,
          });
          debugPrint('✅ User record synced in Supabase');
        } catch (e) {
          debugPrint('⚠️ Could not sync user record (non-fatal, trigger already created it): $e');
        }
      } else {
        debugPrint('ℹ️ No active session yet (email confirmation pending) - profile created by DB trigger');
      }

      // Create UserModel
      final userModel = UserModel(
        uid: user.id,
        email: email,
        displayName: displayName,
        role: role,
        ageGroup: ageGroup,
        parentId: parentId,
        createdAt: DateTime.parse(now),
        lastLoginAt: DateTime.parse(now),
      );

      return userModel;
    } on AuthException catch (e) {
      debugPrint('❌ Supabase Auth Error: ${e.message}');
      throw Exception(_getErrorMessage(e.message));
    } catch (e) {
      debugPrint('❌ Registration Error: $e');
      throw Exception('Kayıt işlemi başarısız: $e');
    }
  }

  /// Sign in with email and password
  /// Returns UserModel from Supabase
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Signing in: $email');

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Giriş başarısız');
      }

      final user = response.user!;
      debugPrint('✅ Supabase Auth successful: ${user.id}');

      // Get user data from users table
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      // Update last login time
      await _supabase
          .from('users')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', user.id);

      debugPrint('✅ User data loaded from Supabase');

      return _userModelFromMap(userData, user.id);
    } on AuthException catch (e) {
      debugPrint('❌ Supabase Auth Error: ${e.message}');
      throw Exception(_getErrorMessage(e.message));
    } catch (e) {
      debugPrint('❌ Sign in Error: $e');
      throw Exception('Giriş başarısız: $e');
    }
  }

  // ==========================================================================
  // APPLE ILE GIRIS
  // ==========================================================================
  //
  // Neden Apple birincil yol: uygulamayi 7-12 yasindaki cocuklar kullaniyor.
  // Bir cocuga e-posta adresi ve sifre yazdirmak pratikte calismiyor - sifreyi
  // unutuyor, e-postasi yok, ya da annesininkini giriyor. Apple ile giris tek
  // dokunus, sifre yok ve "E-postami Gizle" secenegi sayesinde cocugun gercek
  // e-postasini hic saklamiyoruz; bu KVKK/COPPA tarafinda da yukumuzu azaltiyor.
  //
  // Ilerleme korumasi: cocuk zaten anonim bir oturumda XP, jeton ve rozet
  // biriktirmis oluyor. Apple girisi Supabase'de YENI bir kullanici acabilir;
  // onlem alinmazsa o ilerleme eski satirda kalir. Bu yuzden giristen HEMEN
  // ONCE, hala anonim kullaniciyken sunucudan bir "birlestirme anahtari"
  // aliyoruz ve giristen sonra onu ibraz edip ilerlemeyi tasitiyoruz
  // (bkz. supabase/migrations/30_account_merge_tokens.sql).

  /// Cihaz Apple ile girisi destekliyor mu?
  Future<bool> isAppleSignInAvailable() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS) return false;
      return await SignInWithApple.isAvailable();
    } catch (e) {
      debugPrint('⚠️ Apple Sign In kullanilabilirlik kontrolu basarisiz: $e');
      return false;
    }
  }

  /// Kriptografik rastgele nonce. Apple id_token'inin bu oturuma ait
  /// oldugunu dogrulamak icin gerekli (replay saldirisina karsi).
  String _generateNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  String _sha256(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  /// Apple ile giris yapar, gerekiyorsa anonim ilerlemeyi yeni hesaba tasir.
  ///
  /// Kullanici vazgecerse null doner (hata firlatmaz).
  Future<UserModel?> signInWithApple() async {
    final previousUser = _supabase.auth.currentUser;
    final wasAnonymous = previousUser?.isAnonymous ?? false;

    // 1) Hala anonimken birlestirme anahtarini al. Giristen sonra bunu
    //    isteyemeyiz: o an artik baska bir kullanici olmus oluruz ve
    //    "su kullanicinin ilerlemesi benim" demenin ispati kalmaz.
    String? mergeToken;
    if (wasAnonymous) {
      try {
        final result = await _supabase.rpc('create_account_merge_token');
        mergeToken = result as String?;
      } catch (e) {
        debugPrint('⚠️ Birlestirme anahtari alinamadi: $e');
      }
    }

    try {
      final rawNonce = _generateNonce();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: _sha256(rawNonce),
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Apple kimlik dogrulamasi eksik dondu.');
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Apple girisi tamamlanamadi.');

      // 2) Ilerlemeyi tasi. Ayni kullaniciya baglandiysa sunucu zaten
      //    "same_user" deyip hicbir sey yapmiyor.
      if (mergeToken != null) {
        try {
          final merge = await _supabase
              .rpc('claim_account_merge_token', params: {'p_token': mergeToken});
          debugPrint('🔀 Ilerleme tasima sonucu: $merge');
        } catch (e) {
          // Tasima basarisiz olsa bile giris gecerli; kullaniciyi kapida
          // birakmiyoruz. Anahtar 30 dakika gecerli, tekrar denenebilir.
          debugPrint('⚠️ Ilerleme tasinamadi: $e');
        }
      }

      // 3) Apple ilk giriste ad verir, sonrakilerde vermez. Elimizde ad varsa
      //    ve kullanicinin adi yoksa yaziyoruz.
      final givenName = credential.givenName?.trim();
      if (givenName != null && givenName.isNotEmpty) {
        final existing = await _supabase
            .from('users')
            .select('display_name')
            .eq('id', user.id)
            .maybeSingle();
        final current = (existing?['display_name'] as String?)?.trim() ?? '';
        if (current.isEmpty) {
          await _supabase
              .from('users')
              .update({'display_name': givenName}).eq('id', user.id);
        }
      }

      // Tetikleyicinin users satirini yazmasi bir an surebiliyor.
      Map<String, dynamic>? userData;
      for (var i = 0; i < 6; i++) {
        userData = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (userData != null) break;
        await Future.delayed(const Duration(milliseconds: 400));
      }
      if (userData == null) return null;

      debugPrint('✅ Apple ile giris: ${user.id}');
      return _userModelFromMap(userData, user.id);
    } on SignInWithAppleAuthorizationException catch (e) {
      // Kullanici vazgecti - hata degil, sessizce donuyoruz.
      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint('ℹ️ Apple girisinden vazgecildi');
        return null;
      }
      debugPrint('❌ Apple yetkilendirme hatasi: ${e.code} / ${e.message}');
      throw AppAuthException(_appleErrorMessage(e.code), debugDetail: '${e.code}: ${e.message}');
    } on AuthException catch (e) {
      debugPrint('❌ Supabase Apple giris hatasi: ${e.message}');
      throw AppAuthException(
        'Apple hesabın doğrulandı ama girişin tamamlanamadı. '
        'Birazdan tekrar dener misin?',
        debugDetail: e.message,
      );
    } on AppAuthException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Apple giris hatasi: $e');
      throw AppAuthException(
        'Şu an giriş yapılamadı. İnternet bağlantını kontrol edip '
        'tekrar dene.',
        debugDetail: e.toString(),
      );
    }
  }

  /// Apple'in hata kodunu cocugun anlayacagi bir cumleye cevirir.
  ///
  /// Ham metni asla ekrana basmiyoruz: "AuthorizationError hatasi 1000"
  /// kullaniciya hicbir sey anlatmiyor, uygulamayi da amator gosteriyor.
  ///
  /// Not: switch bilerek `default` ile bitiyor. sign_in_with_apple paketi
  /// yeni iOS surumleriyle bu enum'a deger ekleyebiliyor; tum degerleri tek
  /// tek yazmak paket guncellendiginde derlemeyi kirardi.
  String _appleErrorMessage(AuthorizationErrorCode code) {
    switch (code) {
      case AuthorizationErrorCode.notHandled:
      case AuthorizationErrorCode.notInteractive:
      case AuthorizationErrorCode.unknown:
        // En sik neden: cihazda Apple hesabiyla oturum acik degil.
        return 'Apple hesabına ulaşılamadı. Cihazının Ayarlar bölümünden '
            'Apple hesabınla giriş yaptığından emin olup tekrar dene.';
      case AuthorizationErrorCode.canceled:
        return 'Giriş yarıda kaldı.';
      default:
        return 'Apple ile giriş tamamlanamadı. Birazdan tekrar dener misin?';
    }
  }

  /// Anonim oturum acar.
  ///
  /// Uygulama ilk acilista kimlik sormuyor: Supabase anonim bir kullanici
  /// yaratiyor, `handle_new_user` tetikleyicisi de users tablosuna Turkce
  /// bir takma adla satir ekliyor. Kullanici isterse sonradan e-posta
  /// baglayip ilerlemesini kalici hale getiriyor ([linkEmailToAnonymous]).
  Future<UserModel?> signInAnonymously() async {
    try {
      debugPrint('👤 Anonim oturum aciliyor...');
      final response = await _supabase.auth.signInAnonymously();
      final user = response.user;
      if (user == null) {
        debugPrint('❌ Anonim oturum acilamadi');
        return null;
      }

      // Tetikleyicinin users satirini yazmasi bir an surebiliyor.
      Map<String, dynamic>? userData;
      for (var i = 0; i < 5; i++) {
        userData = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (userData != null) break;
        await Future.delayed(const Duration(milliseconds: 400));
      }

      if (userData == null) {
        debugPrint('❌ Anonim kullanici satiri olusmadi');
        return null;
      }

      debugPrint('✅ Anonim oturum acildi: ${user.id}');
      return _userModelFromMap(userData, user.id);
    } catch (e) {
      debugPrint('❌ Anonim oturum hatasi: $e');
      return null;
    }
  }

  /// Anonim hesabi e-posta + sifre ile kalici hale getirir.
  ///
  /// Supabase'de anonim kullaniciya e-posta eklemek yeni hesap acmak degil,
  /// mevcut kullaniciyi yukseltmek demek: `auth.uid()` degismedigi icin
  /// XP, jeton, rozetler ve satin alinan karakterler oldugu gibi kalir.
  Future<void> linkEmailToAnonymous({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final current = _supabase.auth.currentUser;
    if (current == null) {
      throw Exception('Once uygulamayi acmalisin.');
    }
    if (current.isAnonymous != true) {
      throw Exception('Bu hesap zaten bir e-postaya bagli.');
    }

    try {
      await _supabase.auth.updateUser(
        UserAttributes(email: email, password: password),
      );

      final updates = <String, dynamic>{'email': email};
      if (displayName != null && displayName.trim().isNotEmpty) {
        updates['display_name'] = displayName.trim();
      }
      await _supabase.from('users').update(updates).eq('id', current.id);

      debugPrint('✅ Anonim hesap e-postaya baglandi: $email');
    } on AuthException catch (e) {
      debugPrint('❌ Hesap baglama hatasi: ${e.message}');
      throw Exception(_getErrorMessage(e.message));
    }
  }

  /// Get current user data from Supabase
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('ℹ️ No current user');
        return null;
      }

      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return _userModelFromMap(userData, user.id);
    } catch (e) {
      debugPrint('❌ Error getting user data: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      debugPrint('👋 Signing out');
      await _supabase.auth.signOut();
      debugPrint('✅ Sign out successful');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      throw Exception('Çıkış yapılamadı: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      debugPrint('📧 Sending password reset email to: $email');
      await _supabase.auth.resetPasswordForEmail(email);
      debugPrint('✅ Password reset email sent');
    } on AuthException catch (e) {
      debugPrint('❌ Password reset error: ${e.message}');
      throw Exception(_getErrorMessage(e.message));
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw Exception('Şifre sıfırlama e-postası gönderilemedi: $e');
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Kullanıcı bulunamadı');

      final updates = <String, dynamic>{};

      if (displayName != null) {
        updates['display_name'] = displayName;
      }

      if (photoURL != null) {
        updates['profile_picture_url'] = photoURL;
      }

      if (updates.isNotEmpty) {
        await _supabase
            .from('users')
            .update(updates)
            .eq('id', user.id);
      }

      debugPrint('✅ Profile updated');
    } catch (e) {
      debugPrint('❌ Profile update error: $e');
      throw Exception('Profil güncellenemedi: $e');
    }
  }

  /// Update user role (admin only)
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _supabase
          .from('users')
          .update({'role': role.name})
          .eq('id', uid);
      debugPrint('✅ Role updated for user: $uid to ${role.name}');
    } catch (e) {
      debugPrint('❌ Role update error: $e');
      throw Exception('Rol güncellenemedi: $e');
    }
  }

  /// Add student to parent
  Future<void> addStudentToParent(String parentId, String studentId) async {
    try {
      // Get current parent data
      final parentData = await _supabase
          .from('users')
          .select('student_ids')
          .eq('id', parentId)
          .single();

      List<String> studentIds = [];
      if (parentData['student_ids'] != null) {
        studentIds = List<String>.from(parentData['student_ids']);
      }

      if (!studentIds.contains(studentId)) {
        studentIds.add(studentId);
      }

      // Update parent
      await _supabase
          .from('users')
          .update({'student_ids': studentIds})
          .eq('id', parentId);

      // Update student
      await _supabase
          .from('users')
          .update({'parent_id': parentId})
          .eq('id', studentId);

      debugPrint('✅ Student added to parent');
    } catch (e) {
      debugPrint('❌ Error adding student to parent: $e');
      throw Exception('Öğrenci eklenemedi: $e');
    }
  }

  /// Delete account
  /// Calls the `delete-account` Edge Function, which removes both the
  /// public.users row AND the actual Supabase Auth identity (email/password,
  /// OAuth links). Deleting only the DB row (the old behavior) leaves the
  /// login credential intact, which does not satisfy Apple/Google's account
  /// deletion requirement — the user could still sign back in afterward.
  Future<void> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      final response = await _supabase.functions.invoke('delete-account');

      final data = response.data;
      final success = data is Map && data['success'] == true;
      if (!success) {
        final serverError = data is Map ? data['error'] : null;
        throw Exception(serverError ?? 'Hesap silinemedi');
      }

      // Local session is now invalid since the auth user no longer exists.
      await _supabase.auth.signOut();

      debugPrint('✅ Account deleted (auth identity + data)');
    } on FunctionException catch (e) {
      debugPrint('❌ Delete account function error: ${e.details}');
      throw Exception('Hesap silinemedi: ${e.details ?? e.reasonPhrase}');
    } on AuthException catch (e) {
      debugPrint('❌ Delete account error: ${e.message}');
      throw Exception(_getErrorMessage(e.message));
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw Exception('Hesap silinemedi: $e');
    }
  }

  /// Check if user has specific role
  Future<bool> hasRole(UserRole role) async {
    try {
      UserModel? user = await getCurrentUserData();
      return user?.role == role;
    } catch (e) {
      return false;
    }
  }

  /// Check if user has live camera access
  Future<bool> hasLiveCameraAccess() async {
    try {
      UserModel? user = await getCurrentUserData();
      return user?.hasLiveCameraAccess ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Convert Supabase map to UserModel
  UserModel _userModelFromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      email: data['email'] ?? '',
      displayName: data['display_name'] ?? '',
      profilePictureUrl: data['profile_picture_url'],
      role: _parseRole(data['role']),
      ageGroup: _parseAgeGroup(data['age_group']),
      parentId: data['parent_id'],
      studentIds: data['student_ids'] != null
          ? List<String>.from(data['student_ids'])
          : null,
      classId: data['class_id'],
      description: data['description'],
      isRoboAkademi: data['is_roboakademi'] ?? false,
      createdAt: DateTime.parse(data['created_at']),
      lastLoginAt: data['last_login_at'] != null
          ? DateTime.parse(data['last_login_at'])
          : null,
      isPro: data['is_pro'] ?? false,
      proExpiryDate: data['pro_expiry_date'] != null
          ? DateTime.parse(data['pro_expiry_date'])
          : null,
      proTrialStartDate: data['pro_trial_start_date'] != null
          ? DateTime.parse(data['pro_trial_start_date'])
          : null,
      hasUsedTrial: data['has_used_trial'] ?? false,
      dailyPostCount: data['daily_post_count'] ?? 0,
      lastPostResetDate: data['last_post_reset_date'] != null
          ? DateTime.parse(data['last_post_reset_date'])
          : null,
      dailyAiMessageCount: data['daily_ai_message_count'] ?? 0,
      lastAiResetDate: data['last_ai_reset_date'] != null
          ? DateTime.parse(data['last_ai_reset_date'])
          : null,
      dailyQuestionCount: data['daily_question_count'] ?? 0,
      lastQuestionDate: data['last_question_date'] != null
          ? DateTime.parse(data['last_question_date'])
          : null,
      birthDate: data['birth_date'] != null
          ? DateTime.parse(data['birth_date'])
          : null,
      hasSelectedPurpose: data['has_selected_purpose'] ?? false,
    );
  }

  /// Parse role from string
  UserRole _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'parent':
        return UserRole.parent;
      case 'teacher':
        return UserRole.teacher;
      case 'visitor':
        return UserRole.visitor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  /// Parse age group from string
  AgeGroup? _parseAgeGroup(String? ageGroupString) {
    switch (ageGroupString?.toLowerCase()) {
      case 'age4to6':
        return AgeGroup.age4to6;
      case 'age7to9':
        return AgeGroup.age7to9;
      case 'age10to12':
        return AgeGroup.age10to12;
      case 'age13plus':
        return AgeGroup.age13plus;
      default:
        return null;
    }
  }
}
