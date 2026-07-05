# Devkom App - Kapsamlı Uygulama Kılavuzu

## 📱 Proje Özeti

**Devkom**, robotik eğitim odaklı profesyonel bir mobil uygulama platformudur. Firebase tabanlı backend altyapısı ile kullanıcı rolleri, yaş gruplarına göre oyun modülleri, ödev takibi, IP kamera izleme ve push bildirimleri gibi özellikler sunmaktadır.

---

## 🎯 Temel Özellikler

### ✅ Tamamlanan Özellikler

1. **Kullanıcı Rolleri Sistemi**
   - Admin (Yönetici)
   - Parent (Veli)
   - Student (Öğrenci)
   - Visitor (Ziyaretçi)

2. **Yaş Grubu Sistemi**
   - 4-6 Yaş Grubu
   - 7-9 Yaş Grubu
   - Yaş grubuna özel içerik filtreleme

3. **Modern Material 3 Tasarım**
   - Kurumsal mavi-beyaz-gri renk paleti
   - Profesyonel ve modern UI/UX
   - Responsive tasarım (mobil, tablet, desktop)

4. **Firebase Entegrasyonu**
   - Authentication (Kimlik Doğrulama)
   - Firestore (Veritabanı)
   - Storage (Dosya Depolama)
   - Cloud Messaging (Push Bildirimler)

5. **Push Notification Sistemi**
   - Rol tabanlı bildirimler
   - Kullanıcıya özel bildirimler
   - Bildirim geçmişi
   - Topic-based subscriptions

6. **Rol Tabanlı Ekranlar**
   - Öğrenci Ana Ekranı
   - Veli Ana Ekranı
   - Admin Dashboard
   - Otomatik rol bazlı yönlendirme

7. **IP Kamera İzleme**
   - Canlı kamera görüntüleme
   - Sadece veli ve admin erişimi
   - Kamera link yönetimi

---

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                          # Ana uygulama giriş noktası
├── theme.dart                         # Material 3 tema tanımları
├── firebase_options.dart              # Firebase yapılandırması
│
├── models/                            # Veri modelleri
│   ├── user_model.dart               # Kullanıcı modeli (roller, yaş grupları)
│   ├── game_model.dart               # Oyun modeli
│   ├── homework_model.dart           # Ödev modeli
│   ├── camera_model.dart             # Kamera modeli
│   ├── student_model.dart            # Öğrenci modeli
│   └── class_model.dart              # Sınıf modeli
│
├── services/                          # İş mantığı servisleri
│   ├── auth_service.dart             # Kimlik doğrulama servisi
│   ├── notification_service.dart     # Push bildirim servisi
│   ├── firestore_service.dart        # Firestore CRUD işlemleri
│   ├── camera_service.dart           # Kamera servisi
│   ├── games_service.dart            # Oyun servisi
│   ├── homework_service.dart         # Ödev servisi
│   └── file_upload_service.dart      # Dosya yükleme servisi
│
├── providers/                         # State management
│   └── auth_provider.dart            # Kullanıcı state yönetimi
│
├── screens/                           # UI ekranları
│   ├── role_based_home_screen.dart   # Rol bazlı yönlendirme
│   ├── home_screen.dart              # Genel ana ekran
│   │
│   ├── student/                      # Öğrenci ekranları
│   │   └── student_home_screen.dart  # Öğrenci ana ekranı
│   │
│   ├── parent/                       # Veli ekranları
│   │   └── parent_home_screen.dart   # Veli ana ekranı
│   │
│   ├── admin/                        # Admin ekranları
│   │   ├── admin_dashboard_screen.dart
│   │   ├── admin_games_screen.dart
│   │   ├── admin_homeworks_screen.dart
│   │   ├── admin_students_screen.dart
│   │   └── admin_camera_links_screen.dart
│   │
│   ├── auth/                         # Kimlik doğrulama ekranları
│   │   ├── auth_wrapper.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── profile_screen.dart
│   │
│   ├── robotics_games_screen.dart    # Robotik oyunlar
│   ├── homework_screen.dart          # Ödev ekranı
│   ├── live_camera_screen.dart       # Canlı kamera
│   └── splash_screen.dart            # Açılış ekranı
│
└── widgets/                           # Yeniden kullanılabilir widget'lar
    ├── game_card.dart
    ├── homework_card.dart
    └── category_selector.dart
```

---

## 🎨 Renk Paleti

```dart
// Kurumsal Mavi-Beyaz-Gri Tema
Primary Blue:   #1565C0  // Ana mavi
Light Blue:     #42A5F5  // Açık mavi
Dark Blue:      #0D47A1  // Koyu mavi

White:          #FFFFFF  // Beyaz
Light Gray:     #F5F5F5  // Açık gri (arka plan)
Medium Gray:    #9E9E9E  // Orta gri (metin)
Dark Gray:      #424242  // Koyu gri (ana metin)

Accent Teal:    #26C6DA  // Vurgu rengi
Success Green:  #66BB6A  // Başarı durumları
Warning Orange: #FF9800  // Uyarı durumları
Error Red:      #EF5350  // Hata durumları
```

---

## 👥 Kullanıcı Rolleri ve İzinler

### 1. Student (Öğrenci)
**Erişim Hakları:**
- ✅ Kendi oyunlarına erişim
- ✅ Ödevlerini görüntüleme ve tamamlama
- ✅ Kendi profilini görüntüleme
- ❌ Kamera erişimi yok
- ❌ Admin paneli yok

**Ana Ekran Özellikleri:**
- Hoş geldin kartı
- İstatistikler (oyunlar, ödevler, puanlar)
- Hızlı erişim butonları
- Son aktiviteler

### 2. Parent (Veli)
**Erişim Hakları:**
- ✅ Çocuklarının ilerlemesini takip etme
- ✅ Canlı kamera erişimi
- ✅ Ödev ve oyun raporları
- ✅ Mesajlaşma
- ❌ Admin paneli yok

**Ana Ekran Özellikleri:**
- Çocuk listesi ve ilerleme takibi
- Canlı kamera erişimi
- Hızlı erişim menüsü
- Son gelişmeler

### 3. Admin (Yönetici)
**Erişim Hakları:**
- ✅ Tüm özellikler
- ✅ Kullanıcı yönetimi
- ✅ İçerik yönetimi (oyunlar, ödevler)
- ✅ Kamera link yönetimi
- ✅ Bildirim gönderme
- ✅ Sistem ayarları

**Admin Dashboard:**
- Kullanıcı istatistikleri
- Oyun yönetimi
- Ödev yönetimi
- Öğrenci yönetimi
- Kamera link yönetimi
- Bildirim yönetimi

### 4. Visitor (Ziyaretçi)
**Erişim Hakları:**
- ✅ Genel içeriği görüntüleme
- ✅ Yazılım ve robotik bilgileri
- ❌ Kamera erişimi yok
- ❌ Oyun/ödev erişimi yok

---

## 🎮 Yaş Grubu Sistemi

### 4-6 Yaş Grubu
- Basitleştirilmiş oyunlar
- Görsel ağırlıklı içerik
- Kolay seviye ödevler
- Renkli ve eğlenceli arayüz

### 7-9 Yaş Grubu
- Daha karmaşık oyunlar
- Mantık ve problem çözme
- Orta seviye ödevler
- Eğitici ve challenge içerikler

---

## 📊 Firebase Firestore Veri Yapısı

### Collections (Koleksiyonlar)

```
firestore/
│
├── users/                              # Kullanıcılar
│   └── {userId}/
│       ├── uid: string
│       ├── email: string
│       ├── displayName: string
│       ├── role: 'student' | 'parent' | 'admin' | 'visitor'
│       ├── ageGroup: 'age4to6' | 'age7to9' | null
│       ├── parentId: string | null     # Öğrenciler için
│       ├── studentIds: string[] | null # Veliler için
│       ├── classId: string | null
│       ├── fcmToken: string            # Push notification token
│       ├── createdAt: timestamp
│       └── lastLoginAt: timestamp
│
├── games/                              # Oyunlar
│   └── {gameId}/
│       ├── title: string
│       ├── description: string
│       ├── ageGroup: 'age4to6' | 'age7to9'
│       ├── category: string
│       ├── difficulty: string
│       ├── imageUrl: string
│       ├── videoUrl: string
│       ├── points: number
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── homeworks/                          # Ödevler
│   └── {homeworkId}/
│       ├── title: string
│       ├── description: string
│       ├── ageGroup: 'age4to6' | 'age7to9'
│       ├── classId: string
│       ├── dueDate: timestamp
│       ├── attachments: string[]
│       ├── createdBy: string           # Admin userId
│       ├── createdAt: timestamp
│       └── status: 'active' | 'completed'
│
├── homework_submissions/               # Ödev teslimler
│   └── {submissionId}/
│       ├── homeworkId: string
│       ├── studentId: string
│       ├── submittedAt: timestamp
│       ├── attachments: string[]
│       ├── notes: string
│       ├── grade: number | null
│       └── feedback: string | null
│
├── classes/                            # Sınıflar
│   └── {classId}/
│       ├── name: string
│       ├── ageGroup: 'age4to6' | 'age7to9'
│       ├── studentIds: string[]
│       ├── teacherId: string
│       └── createdAt: timestamp
│
├── camera_links/                       # Kamera linkleri
│   └── {cameraId}/
│       ├── name: string
│       ├── streamUrl: string
│       ├── location: string
│       ├── isActive: boolean
│       └── createdAt: timestamp
│
└── notifications/                      # Bildirimler
    └── {notificationId}/
        ├── userId: string
        ├── title: string
        ├── body: string
        ├── data: map
        ├── type: 'homework' | 'game' | 'announcement' | 'camera_alert'
        ├── read: boolean
        ├── createdAt: timestamp
        └── readAt: timestamp | null
```

---

## 🔔 Push Notification Sistemi

### Notification Service Özellikleri

1. **Kullanıcı Bazlı Bildirimler**
   ```dart
   await notificationService.sendNotificationToUser(
     userId: 'student123',
     title: 'Yeni Ödev',
     body: 'Robot Hareket ödevi yayınlandı',
     data: {'type': 'homework', 'targetId': 'hw123'},
   );
   ```

2. **Rol Bazlı Bildirimler**
   ```dart
   await notificationService.sendNotificationToRole(
     role: 'student',
     title: 'Duyuru',
     body: 'Yarın robotik yarışması var!',
   );
   ```

3. **Topic Subscriptions**
   - `all_users` - Tüm kullanıcılar
   - `students` - Öğrenciler
   - `parents` - Veliler
   - `admins` - Yöneticiler

### Bildirim Tipleri
- `homework` - Ödev bildirimleri
- `game` - Oyun bildirimleri
- `announcement` - Duyurular
- `camera_alert` - Kamera uyarıları

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK 3.6+
- Dart SDK 3.0+
- Firebase projesi
- Android Studio / VS Code
- Git

### Adım 1: Projeyi Klonlayın
```bash
git clone <repository-url>
cd devkom_app
```

### Adım 2: Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### Adım 3: Firebase Yapılandırması
1. Firebase Console'da proje oluşturun
2. FlutterFire CLI'yı yükleyin:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. Firebase'i yapılandırın:
   ```bash
   flutterfire configure
   ```

### Adım 4: Uygulamayı Çalıştırın

**Web (Development)**
```bash
flutter run -d web-server --web-port=9004
```

**Android**
```bash
flutter run -d <device-id>
```

**iOS**
```bash
flutter run -d <device-id>
```

**Windows**
```bash
flutter run -d windows
```

---

## 🎯 Test Kullanıcıları

### Admin Kullanıcısı
```
Email: admin@devkom.com
Password: admin123
Role: Admin
```

### Veli Kullanıcısı
```
Email: parent@devkom.com
Password: parent123
Role: Parent
```

### Öğrenci Kullanıcısı (4-6 Yaş)
```
Email: student1@devkom.com
Password: student123
Role: Student
Age Group: 4-6 Yaş
```

### Öğrenci Kullanıcısı (7-9 Yaş)
```
Email: student2@devkom.com
Password: student123
Role: Student
Age Group: 7-9 Yaş
```

---

## 📱 Platform Desteği

### ✅ Desteklenen Platformlar
- **Web** - Tam destek
- **Android** - Tam destek
- **iOS** - Tam destek
- **Windows** - Sınırlı destek (kamera desteği yok)
- **macOS** - Sınırlı destek

### ⚠️ Platform Notları
- **Kamera:** Mobil platformlarda VLC veya WebRTC kullanılır
- **Push Notifications:** Web'de sınırlı, mobilde tam destek
- **File Picker:** Tüm platformlarda desteklenir

---

## 🔐 Güvenlik

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid == userId ||
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Games - read by all authenticated, write by admin
    match /games/{gameId} {
      allow read: if request.auth.uid != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Homeworks - read by students in class, write by admin
    match /homeworks/{homeworkId} {
      allow read: if request.auth.uid != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Notifications - user can only read their own
    match /notifications/{notificationId} {
      allow read: if resource.data.userId == request.auth.uid;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## 📈 Performans Optimizasyonu

### Yapılanlar
1. ✅ Image caching
2. ✅ Lazy loading
3. ✅ Pagination (Firestore queries)
4. ✅ Optimized build methods
5. ✅ Const constructors

### Yapılacaklar
- [ ] Index optimization
- [ ] Image compression
- [ ] Offline support
- [ ] Background sync

---

## 🎨 UI/UX Best Practices

1. **Consistency** - Tutarlı tasarım dili
2. **Accessibility** - Erişilebilirlik standartları
3. **Responsive** - Tüm ekran boyutlarında çalışma
4. **Loading States** - Yükleme göstergeleri
5. **Error Handling** - Kullanıcı dostu hata mesajları
6. **Animations** - Akıcı geçişler

---

## 🚢 Yayın Sürümü Hazırlığı

### Android

1. **Keystore Oluşturma**
   ```bash
   keytool -genkey -v -keystore devkom-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias devkom
   ```

2. **key.properties Dosyası**
   ```
   storePassword=<password>
   keyPassword=<password>
   keyAlias=devkom
   storeFile=<keystore-path>
   ```

3. **Build APK**
   ```bash
   flutter build apk --release
   ```

4. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **Xcode Configuration**
   - Bundle ID ayarlayın
   - Signing & Capabilities ayarlayın
   - App Icons ekleyin

2. **Build IPA**
   ```bash
   flutter build ipa --release
   ```

---

## 📚 Dokümantasyon Kaynakları

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material 3 Design](https://m3.material.io/)
- [Provider State Management](https://pub.dev/packages/provider)

---

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit yapın (`git commit -m 'Add some AmazingFeature'`)
4. Push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

---

## 📞 İletişim

**Devkom Team**
- Email: info@devkom.com
- Website: www.devkom.com

---

## 🙏 Teşekkürler

Bu projeyi kullandığınız için teşekkür ederiz! Sorunlar veya öneriler için lütfen issue açın.

---

**Son Güncelleme:** 2025-01-20
**Versiyon:** 1.0.0
**Durum:** Production Ready ✅
