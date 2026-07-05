# Firebase Authentication - Devkom App

## 🔐 Authentication Sistemi Özellikleri

### ✅ Tamamlanan Özellikler

1. **Firebase Authentication Entegrasyonu**
   - E-posta/Şifre ile kayıt ve giriş
   - Kullanıcı dostu hata mesajları (Türkçe)
   - Auto-login (oturum sürekliliği)
   - Token yönetimi

2. **Rol Tabanlı Erişim Kontrolü**
   - 3 Rol Tipi:
     - `admin` - Tam yetki + yönetim
     - `parent` (Veli) - Canlı kamera erişimi dahil
     - `visitor` (Ziyaretçi) - Genel içerik erişimi

3. **Provider Pattern ile State Management**
   - `AuthProvider` - Tüm uygulamada kullanıcı durumu
   - Real-time auth state dinleme
   - Otomatik kullanıcı verisi güncelleme

4. **Güvenlik**
   - Firestore güvenlik kuralları (`firestore.rules`)
   - Rol tabanlı veri erişimi
   - Şifre validasyonu (min 6 karakter)
   - E-posta formatı kontrolü

---

## 📁 Dosya Yapısı

```
lib/
├── models/
│   └── user_model.dart              # UserModel + UserRole enum
├── services/
│   └── auth_service.dart            # Firebase Auth işlemleri
├── providers/
│   └── auth_provider.dart           # State management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart        # Giriş ekranı
│   │   ├── register_screen.dart     # Kayıt ekranı (rol seçimi)
│   │   ├── profile_screen.dart      # Profil + çıkış butonu
│   │   └── auth_wrapper.dart        # Auto-login wrapper
│   ├── live_camera_screen.dart      # Veli erişimi (kısıtlı)
│   └── access_denied_screen.dart    # Yetkisiz erişim ekranı
└── firestore.rules                  # Güvenlik kuralları
```

---

## 👤 Demo Hesaplar

### Kullanım için Mock Hesaplar

Uygulamayı test etmek için Firebase Console'da şu hesapları oluşturun:

| E-posta | Şifre | Rol | Erişim |
|---------|-------|-----|--------|
| admin@devkom.com | 123456 | admin | Tam yetki + yönetim |
| veli@devkom.com | 123456 | parent | Canlı kamera erişimi |
| ziyaretci@devkom.com | 123456 | visitor | Genel içerik |

**Not:** Firebase Console'da manuel olarak oluşturun ve Firestore'da `users` koleksiyonuna ekleyin:

```json
{
  "uid": "firebase-user-id",
  "email": "admin@devkom.com",
  "displayName": "Admin User",
  "role": "admin",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp"
}
```

---

## 🔧 Firebase Kurulumu

### 1. Firebase Projesi Oluştur

```bash
# Firebase CLI Kurulumu
npm install -g firebase-tools

# Firebase'e giriş
firebase login

# Proje dizininde Firebase başlat
cd devkom_app
firebase init
```

### 2. FlutterFire CLI ile Yapılandırma

```bash
# FlutterFire CLI kur
dart pub global activate flutterfire_cli

# Firebase yapılandırması oluştur
flutterfire configure
```

Bu komut `lib/firebase_options.dart` dosyasını otomatik oluşturur.

### 3. Main.dart'ı Güncelle

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DevkomApp());
}
```

### 4. Firestore Rules Deploy Et

```bash
firebase deploy --only firestore:rules
```

---

## 🎯 Kullanım Örnekleri

### 1. Kullanıcı Kayıt

```dart
final authProvider = context.read<AuthProvider>();

await authProvider.register(
  email: 'user@example.com',
  password: 'password123',
  displayName: 'John Doe',
  role: UserRole.parent,
);
```

### 2. Kullanıcı Giriş

```dart
final authProvider = context.read<AuthProvider>();

await authProvider.signIn(
  email: 'user@example.com',
  password: 'password123',
);
```

### 3. Rol Kontrolü

```dart
// Provider ile
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.hasLiveCameraAccess) {
      return LiveCameraButton();
    }
    return SizedBox.shrink();
  },
);

// Direkt kontrol
if (context.read<AuthProvider>().hasRole(UserRole.admin)) {
  // Admin işlemleri
}
```

### 4. Çıkış Yap

```dart
await context.read<AuthProvider>().signOut();
```

---

## 🛡️ Güvenlik Kuralları

### Firestore Rules Özeti

- **Users Collection**: Kullanıcılar sadece kendi verilerini okuyabilir/düzenleyebilir
- **Role Updates**: Sadece admin rol değiştirebilir
- **Projects**: Herkes okur, sahipler düzenler
- **Courses**: Herkes okur, admin düzenler
- **Camera Logs**: Sadece Veli ve Admin erişebilir

### Örnek Kural

```javascript
// Sadece parent ve admin canlı kamera loglarına erişebilir
match /camera_access_logs/{logId} {
  allow read: if isParent() || isAdmin();
  allow create: if isAuthenticated();
  allow update, delete: if isAdmin();
}
```

---

## 🎨 Ekranlar

### 1. Login Screen (`login_screen.dart`)
- E-posta ve şifre alanları
- Şifre göster/gizle özelliği
- "Kayıt Ol" linki
- Demo hesap bilgileri gösterilir
- Gradient arkaplan

### 2. Register Screen (`register_screen.dart`)
- Ad Soyad, E-posta, Şifre alanları
- Şifre tekrar doğrulama
- **Rol Seçimi** (Veli / Ziyaretçi)
- Form validasyonu
- Kullanıcı dostu tasarım

### 3. Profile Screen (`profile_screen.dart`)
- Kullanıcı bilgileri (Ad, E-posta, Rol)
- Rol badge (renkli)
- Üyelik tarihi
- Son giriş zamanı
- Canlı kamera erişim durumu
- **Çıkış Butonu** (onay dialogu ile)

### 4. Live Camera Screen (`live_camera_screen.dart`)
- **Veli erişimi kontrolü**
- Yetkisiz kullanıcılar → Access Denied
- Placeholder kamera görünümü
- "CANLI" göstergesi
- Kontrol butonları

### 5. Access Denied Screen (`access_denied_screen.dart`)
- Kullanıcı dostu mesaj
- Erişim açıklaması
- "Ana Sayfaya Dön" butonu
- Destek iletişim seçeneği

---

## ⚠️ Hata Mesajları

AuthService kullanıcı dostu Türkçe hata mesajları sunar:

| Firebase Hatası | Türkçe Mesaj |
|----------------|--------------|
| `weak-password` | Şifre çok zayıf. En az 6 karakter olmalıdır. |
| `email-already-in-use` | Bu e-posta adresi zaten kullanımda. |
| `user-not-found` | Bu e-posta ile kayıtlı kullanıcı bulunamadı. |
| `wrong-password` | Hatalı şifre. |
| `network-request-failed` | Bağlantı hatası. İnternet bağlantınızı kontrol edin. |

---

## 🚀 Özellikler

✅ E-posta/Şifre ile kayıt ve giriş
✅ Otomatik giriş (session persistence)
✅ Rol tabanlı erişim kontrolü (admin, parent, visitor)
✅ Provider pattern ile global state
✅ Kullanıcı dostu Türkçe hata mesajları
✅ Form validasyonu
✅ Şifre göster/gizle
✅ Profil ekranı
✅ Canlı kamera erişimi (sadece Veli)
✅ Access denied ekranı
✅ Firestore güvenlik kuralları
✅ Responsive tasarım
✅ Material 3 design

---

## 📝 Notlar

1. **Firebase Setup Gerekli**: Auth özellikleri çalışması için Firebase Console'da proje kurulumu gereklidir.

2. **Web Kurulumu**: Web platformunda çalıştırmak için `web/index.html` dosyasına Firebase SDK eklenmeli.

3. **Rol Atama**: Yeni kullanıcılar kayıt sırasında kendi rollerini seçer. Admin rolü sadece backend tarafından atanmalıdır (güvenlik).

4. **Test Hesapları**: Uygulamayı test etmek için yukarıdaki demo hesapları Firebase Console'da manuel oluşturun.

---

## 🔗 İlgili Dosyalar

- `lib/models/user_model.dart` - User ve Role tanımları
- `lib/services/auth_service.dart` - Firebase Auth CRUD
- `lib/providers/auth_provider.dart` - State management
- `firestore.rules` - Güvenlik kuralları

---

**Oluşturulma Tarihi**: 18 Ekim 2025
**Versiyon**: 1.0
**Geliştirici**: Claude Code
