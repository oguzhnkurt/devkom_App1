# 🚀 DEVKOM APP - Firebase'den Supabase'e Tam Geçiş Kılavuzu

## 📋 İçindekiler
1. [Supabase Proje Kurulumu](#1-supabase-proje-kurulumu)
2. [Database Migration](#2-database-migration)
3. [Flutter SDK Kurulumu](#3-flutter-sdk-kurulumu)
4. [Authentication Migration](#4-authentication-migration)
5. [Storage Migration](#5-storage-migration)
6. [Realtime Migration](#6-realtime-migration)
7. [Service Layer Migration](#7-service-layer-migration)
8. [Testing](#8-testing)
9. [Production Deployment](#9-production-deployment)

---

## 1. SUPABASE PROJE KURULUMU

### Adım 1.1: Supabase Projesi Oluştur

1. **https://supabase.com/dashboard** adresine git
2. **"New Project"** butonuna tıkla
3. Proje ayarları:
   ```
   Name: devkom-app
   Database Password: [GÜÇLÜ ŞİFRE OLUŞTUR - KAYDET!]
   Region: Europe West (London) VEYA Europe Central (Frankfurt)
   Pricing Plan: Free (başlangıç) → Pro ($25/ay) (production)
   ```

### Adım 1.2: Bağlantı Bilgilerini Al

1. Dashboard'da **Settings → API** kısmına git
2. Şu bilgileri kaydet:
   ```
   Project URL: https://xxxxx.supabase.co
   anon public key: eyJhbG...
   service_role key: eyJhbG... (admin işlemleri için)
   ```

### Adım 1.3: Database Migration Scriptlerini Çalıştır

1. Supabase Dashboard → **SQL Editor** kısmına git
2. Sırayla şu dosyaları çalıştır:
   - `supabase/migrations/00_initial_schema.sql`
   - `supabase/migrations/01_rls_policies.sql`
   - `supabase/migrations/02_storage_setup.sql`

**Alternatif: Supabase CLI ile (Önerilir)**
```bash
# Supabase CLI kur
npm install -g supabase

# Projeye login ol
supabase login

# Projeyi link et
supabase link --project-ref YOUR_PROJECT_REF

# Migration'ları çalıştır
supabase db push
```

---

## 2. DATABASE MIGRATION

### Adım 2.1: Firestore Data Export

Firebase Console'dan verileri export et:

```bash
# Firebase CLI ile export
firebase firestore:export gs://YOUR_BUCKET_NAME/firestore-backup

# Veya Node.js script ile
node scripts/export_firestore.js
```

### Adım 2.2: Data Transformation

Firestore JSON → PostgreSQL SQL dönüşümü için transform script:

```javascript
// scripts/transform_firestore_to_sql.js
const fs = require('fs');

// Firestore exports oku
const users = JSON.parse(fs.readFileSync('./firestore-backup/users.json'));

// PostgreSQL INSERT statements oluştur
const sqlInserts = users.map(user => `
  INSERT INTO users (id, email, display_name, role, created_at, ...)
  VALUES ('${user.id}', '${user.email}', '${user.displayName}', '${user.role}', ...);
`).join('\n');

fs.writeFileSync('./migrations/03_data_import.sql', sqlInserts);
```

### Adım 2.3: Data Import

```bash
# SQL dosyasını Supabase'e import et
psql $DATABASE_URL < migrations/03_data_import.sql

# Veya Supabase Dashboard → SQL Editor'de çalıştır
```

---

## 3. FLUTTER SDK KURULUMU

### Adım 3.1: Dependencies Güncelle

`pubspec.yaml` dosyasını güncelle:

```yaml
dependencies:
  # ❌ Kaldırılacaklar
  # firebase_core: ^3.15.2
  # firebase_auth: ^5.7.0
  # cloud_firestore: ^5.6.12
  # firebase_storage: ^12.4.10
  # firebase_analytics: ^11.3.5
  # firebase_messaging: ^15.2.10

  # ✅ Eklenecekler
  supabase_flutter: ^2.5.6

  # Analytics alternatifi (opsiyonel)
  posthog_flutter: ^4.0.0

  # Push notification alternatifi
  onesignal_flutter: ^5.0.0

  # Mevcut dependencies (KALACAK)
  flutter:
    sdk: flutter
  provider: ^6.1.2
  rxdart: ^0.28.0
  image_picker: ^1.1.2
  file_picker: ^8.1.4
  cached_network_image: ^3.4.1
  flutter_image_compress: ^2.3.0
  path_provider: ^2.1.4
  shared_preferences: ^2.3.3
  sign_in_with_apple: ^6.1.2
  http: ^1.2.1
  intl: ^0.19.0
  # ... diğerleri
```

```bash
flutter pub get
```

### Adım 3.2: Supabase Initialization

`lib/main.dart` dosyasını güncelle:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ❌ Firebase init kaldır
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // ✅ Supabase init ekle
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
      persistSession: true,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    storageOptions: const StorageClientOptions(
      retryAttempts: 3,
    ),
  );

  runApp(const MyApp());
}

// Global accessor
final supabase = Supabase.instance.client;
```

### Adım 3.3: Environment Variables

`.env` dosyası oluştur:

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbG...
SUPABASE_SERVICE_ROLE_KEY=eyJhbG... # Sadece backend/admin işlemleri için
```

`.gitignore`'a ekle:
```
.env
```

---

## 4. AUTHENTICATION MIGRATION

### Adım 4.1: Auth Service Yeniden Yaz

`lib/services/auth_service.dart` → `lib/services/supabase_auth_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Current user
  User? get currentUser => _supabase.auth.currentUser;

  // Email/Password Sign Up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': displayName,
        'role': role.name,
      },
    );

    if (response.user != null) {
      // Create user profile in public.users table
      await _supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'display_name': displayName,
        'role': role.name,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  // Email/Password Sign In
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      // Update last login
      await _supabase.from('users').update({
        'last_login_at': DateTime.now().toIso8601String(),
      }).eq('id', response.user!.id);
    }

    return response;
  }

  // Apple Sign In
  Future<AuthResponse> signInWithApple() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'YOUR_DEEP_LINK',
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Get User Profile
  Future<UserModel?> getUserProfile(String userId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromMap(response);
  }

  // Update Profile
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    await _supabase.from('users').update({
      if (displayName != null) 'display_name': displayName,
      if (photoUrl != null) 'photo_url': photoUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // Delete Account
  Future<void> deleteAccount() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // Supabase CASCADE delete handles related data
    await _supabase.from('users').delete().eq('id', userId);
    await _supabase.auth.signOut();
  }
}
```

### Adım 4.2: Auth Provider Güncelle

`lib/providers/auth_provider.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/supabase_auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();

  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth changes
    _authService.authStateChanges.listen((event) async {
      if (event.session != null) {
        await _loadUserProfile(event.session!.user.id);
      } else {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getUserProfile(userId);
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign In
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
```

---

## 5. STORAGE MIGRATION

### Adım 5.1: Storage Service Yeniden Yaz

`lib/services/supabase_storage_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload file
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
    String? contentType,
  }) async {
    final bytes = await file.readAsBytes();

    final response = await _supabase.storage.from(bucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: false,
      ),
    );

    // Get public URL
    final url = _supabase.storage.from(bucket).getPublicUrl(path);
    return url;
  }

  // Upload chat image
  Future<String> uploadChatImage({
    required String userId,
    required File imageFile,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$fileName';

    return await uploadFile(
      bucket: 'chat-images',
      path: path,
      file: imageFile,
      contentType: 'image/jpeg',
    );
  }

  // Upload homework submission
  Future<String> uploadHomeworkFile({
    required String userId,
    required String homeworkId,
    required File file,
    required String fileName,
  }) async {
    final path = '$userId/$homeworkId/$fileName';

    return await uploadFile(
      bucket: 'homework-submissions',
      path: path,
      file: file,
    );
  }

  // Upload post media
  Future<String> uploadPostMedia({
    required String userId,
    required String postId,
    required File file,
    required String mediaType,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    final fileName = '${timestamp}_${postId}.$extension';
    final path = '$userId/$fileName';

    return await uploadFile(
      bucket: 'post-media',
      path: path,
      file: file,
      contentType: mediaType,
    );
  }

  // Upload profile picture
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    final fileName = 'profile.jpg';
    final path = '$userId/$fileName';

    return await uploadFile(
      bucket: 'profile-pictures',
      path: path,
      file: imageFile,
      contentType: 'image/jpeg',
    );
  }

  // Delete file
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _supabase.storage.from(bucket).remove([path]);
  }

  // List files
  Future<List<FileObject>> listFiles({
    required String bucket,
    String? path,
  }) async {
    return await _supabase.storage.from(bucket).list(path: path);
  }
}
```

---

## 6. REALTIME MIGRATION

### Adım 6.1: Messaging Service (Realtime Örneği)

`lib/services/supabase_messaging_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class SupabaseMessagingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Send message
  Future<void> sendMessage(MessageModel message) async {
    await _supabase.from('messages').insert(message.toMap());
  }

  // Get conversation (realtime)
  Stream<List<MessageModel>> getConversation(String userId1, String userId2) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .or('sender_id.eq.$userId1,receiver_id.eq.$userId1')
        .or('sender_id.eq.$userId2,receiver_id.eq.$userId2')
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => MessageModel.fromMap(json)).toList());
  }

  // Alternative: Combine two queries with RxDart
  Stream<List<MessageModel>> getConversationCombined(String userId1, String userId2) {
    final stream1 = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('sender_id', userId1)
        .eq('receiver_id', userId2)
        .order('created_at', ascending: true);

    final stream2 = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('sender_id', userId2)
        .eq('receiver_id', userId1)
        .order('created_at', ascending: true);

    return Rx.combineLatest2(
      stream1,
      stream2,
      (List<Map<String, dynamic>> data1, List<Map<String, dynamic>> data2) {
        final messages = <MessageModel>[];
        messages.addAll(data1.map((json) => MessageModel.fromMap(json)));
        messages.addAll(data2.map((json) => MessageModel.fromMap(json)));
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return messages;
      },
    );
  }

  // Mark as read
  Future<void> markAsRead(String messageId) async {
    await _supabase.from('messages').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('id', messageId);
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    await _supabase.from('messages').delete().eq('id', messageId);
  }
}
```

### Adım 6.2: Realtime Subscriptions

Supabase Realtime kullanımı:

```dart
// Subscribe to new messages
final channel = supabase.channel('messages')
  .onPostgresChanges(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'messages',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'receiver_id',
      value: currentUserId,
    ),
    callback: (payload) {
      print('New message: ${payload.newRecord}');
      // Handle new message
    },
  )
  .subscribe();

// Unsubscribe
await channel.unsubscribe();
```

---

## 7. SERVICE LAYER MIGRATION

### Tüm servisler için genel migration pattern:

```dart
// BEFORE (Firebase)
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Item>> getItems() {
    return _firestore
        .collection('items')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList());
  }
}

// AFTER (Supabase)
class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Item>> getItems() {
    return _supabase
        .from('items')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .map((data) => data.map((json) => Item.fromMap(json)).toList());
  }
}
```

### Key Differences:

| Firebase | Supabase |
|----------|----------|
| `collection('items')` | `from('items')` |
| `.where('field', isEqualTo: value)` | `.eq('field', value)` |
| `.orderBy('field', descending: true)` | `.order('field', ascending: false)` |
| `.limit(10)` | `.limit(10)` |
| `.snapshots()` | `.stream(primaryKey: ['id'])` |
| `doc.data()` | `row` (Map<String, dynamic>) |
| `FieldValue.serverTimestamp()` | `DateTime.now().toIso8601String()` |
| `FieldValue.increment(1)` | SQL: `UPDATE ... SET count = count + 1` |
| `FieldValue.arrayUnion([item])` | PostgreSQL array operations |

---

## 8. TESTING

### Adım 8.1: Unit Tests

```dart
// test/services/supabase_auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseAuthService', () {
    late SupabaseAuthService authService;

    setUp(() {
      authService = SupabaseAuthService();
    });

    test('Sign up creates user profile', () async {
      // Test implementation
    });

    test('Sign in returns auth response', () async {
      // Test implementation
    });
  });
}
```

### Adım 8.2: Integration Tests

```bash
flutter test integration_test/
```

### Adım 8.3: Manual Testing Checklist

- [ ] User registration
- [ ] User login
- [ ] Password reset
- [ ] Profile update
- [ ] Post creation
- [ ] Post likes/comments
- [ ] Messaging (send/receive)
- [ ] Real-time updates
- [ ] File uploads
- [ ] Homework submission
- [ ] Leaderboard updates

---

## 9. PRODUCTION DEPLOYMENT

### Adım 9.1: Environment Setup

```dart
// lib/config/env.dart
class Environment {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_PROD_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_PROD_KEY',
  );
}
```

### Adım 9.2: Build Commands

```bash
# Android
flutter build apk --release --dart-define=SUPABASE_URL=https://prod.supabase.co --dart-define=SUPABASE_ANON_KEY=your_key

# iOS
flutter build ios --release --dart-define=SUPABASE_URL=https://prod.supabase.co --dart-define=SUPABASE_ANON_KEY=your_key
```

### Adım 9.3: Database Backup

```bash
# Supabase CLI ile backup
supabase db dump -f backup.sql

# Restore
psql $DATABASE_URL < backup.sql
```

---

## 10. POST-MIGRATION CLEANUP

### Adım 10.1: Firebase Cleanup

```yaml
# pubspec.yaml'dan kaldır
# firebase_core
# firebase_auth
# cloud_firestore
# firebase_storage
# firebase_analytics
# firebase_messaging
```

### Adım 10.2: Dosya Cleanup

```bash
# Sil
rm -rf lib/firebase_options.dart
rm -rf android/app/google-services.json
rm -rf ios/Runner/GoogleService-Info.plist
rm -rf .firebaserc
rm -rf firebase.json
rm -rf firestore.rules
rm -rf firestore.indexes.json
rm -rf storage.rules
```

---

## 📞 YARDIM VE DESTEK

- **Supabase Docs:** https://supabase.com/docs
- **Flutter SDK:** https://supabase.com/docs/reference/dart
- **Community Discord:** https://discord.supabase.com

---

## ✅ MIGRATION CHECKLIST

### Database
- [ ] PostgreSQL şema oluşturuldu
- [ ] RLS politikaları ayarlandı
- [ ] Storage buckets yapılandırıldı
- [ ] Firestore data export edildi
- [ ] Data transform edildi
- [ ] Data import edildi

### Flutter App
- [ ] Supabase SDK eklendi
- [ ] Environment variables ayarlandı
- [ ] Auth service taşındı
- [ ] Storage service taşındı
- [ ] Tüm servisler migrate edildi
- [ ] Models güncellendi
- [ ] Providers güncellendi

### Testing
- [ ] Unit tests yazıldı
- [ ] Integration tests çalıştırıldı
- [ ] Manual testing tamamlandı
- [ ] Performance test edildi

### Deployment
- [ ] Production Supabase projesi oluşturuldu
- [ ] Environment variables ayarlandı
- [ ] Build oluşturuldu
- [ ] App store'a yüklendi

### Cleanup
- [ ] Firebase dependencies kaldırıldı
- [ ] Firebase config dosyaları silindi
- [ ] Eski kod temizlendi
- [ ] Documentation güncellendi

---

**🎉 Migration tamamlandı!**
