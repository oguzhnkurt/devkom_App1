# 🚀 SUPABASE QUICK START GUIDE

Bu döküman Supabase'e hızlıca başlamanız için adım adım rehberdir.

## ⚡ 5 DAKIKADA BAŞLA

### 1️⃣ Supabase Projesi Oluştur (2 dk)

1. https://supabase.com/dashboard → "New Project"
2. Bilgileri gir:
   ```
   Name: devkom-app
   Password: [güçlü şifre - KAYDET!]
   Region: Europe West (London)
   ```
3. 2 dakika bekle (database hazırlanıyor)

### 2️⃣ Migration Scriptlerini Çalıştır (2 dk)

**Seçenek A: Dashboard ile (Kolay)**
1. Dashboard → SQL Editor
2. `supabase/migrations/00_initial_schema.sql` dosyasını aç
3. İçeriği kopyala → SQL Editor'e yapıştır → Run
4. Aynısını `01_rls_policies.sql` ve `02_storage_setup.sql` için yap

**Seçenek B: CLI ile (Hızlı)**
```bash
npm install -g supabase
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

### 3️⃣ Bağlantı Bilgilerini Al (30 sn)

1. Dashboard → Settings → API
2. Şu bilgileri kopyala ve `lib/config/supabase_config.dart` dosyasını oluştur:

```dart
class SupabaseConfig {
  static const String url = 'https://xxxxx.supabase.co'; // YOUR_PROJECT_URL
  static const String anonKey = 'eyJhbG...'; // YOUR_ANON_KEY
}
```

### 4️⃣ Flutter Dependencies Ekle (30 sn)

```bash
flutter pub add supabase_flutter
flutter pub get
```

### 5️⃣ Initialize Et (30 sn)

`lib/main.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

// Global accessor
final supabase = Supabase.instance.client;
```

### ✅ HAZIR!

Artık Supabase'i kullanabilirsiniz:

```dart
// Auth
await supabase.auth.signInWithPassword(email: 'test@test.com', password: '123456');

// Database
final data = await supabase.from('users').select();

// Storage
await supabase.storage.from('chat-images').upload('path', file);

// Realtime
supabase.from('messages').stream(primaryKey: ['id']).listen((data) {
  print('New message: $data');
});
```

---

## 🎯 SIRA SENIN!

Şimdi bu adımları takip et:

1. ✅ Supabase projesi oluştur
2. ✅ Migration scriptlerini çalıştır
3. ✅ Bağlantı bilgilerini yapılandır
4. ✅ Flutter SDK'yı ekle
5. ✅ İlk sorguyu çalıştır

**Sorun mu yaşıyorsun?**
- `SUPABASE_MIGRATION_GUIDE.md` dosyasına bak
- Bana sor! 😊
