# 🍎 Sign in with Apple & StoreKit Entegrasyon Rehberi

## 📋 İçindekiler
1. [Genel Bakış](#genel-bakış)
2. [Sign in with Apple Kurulumu](#sign-in-with-apple-kurulumu)
3. [StoreKit/In-App Purchase Kurulumu](#storekit-kurulumu)
4. [Kullanım Örnekleri](#kullanım-örnekleri)
5. [Test Etme](#test-etme)
6. [Sık Sorulan Sorular](#sss)

---

## 🎯 Genel Bakış

Bu proje artık şu özellikleri destekliyor:
- ✅ **Sign in with Apple** (iOS/macOS için tek tıkla giriş)
- ✅ **StoreKit** (iOS için uygulama içi satın alma)
- ✅ **Google Play Billing** (Android için hazır)
- ✅ **Firebase Auth** (tüm platformlar için backend)

### 🏗️ Mimari

```
┌─────────────────┐
│   iOS Cihaz     │
└────────┬────────┘
         │
    ┌────▼─────────────┐
    │  Sign in with    │──────┐
    │     Apple        │      │
    └──────────────────┘      │
                              ▼
                      ┌────────────────┐
                      │ Firebase Auth  │
                      └───────┬────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
    ┌────▼─────┐    ┌────────▼────────┐    ┌─────▼──────┐
    │ StoreKit │    │   Firestore     │    │  Android   │
    │  (iOS)   │    │   (Database)    │    │   Auth     │
    └──────────┘    └─────────────────┘    └────────────┘
```

---

## 🍏 Sign in with Apple Kurulumu

### 1. Apple Developer Console Ayarları

#### a) App ID Yapılandırması
1. [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list) → **Identifiers** → **App IDs**
2. Uygulamanızı seçin: `com.example.devkom_app`
3. **Sign in with Apple** capability'sini etkinleştirin
4. **Save** ve **Done**

#### b) Services ID Oluşturma
1. **Identifiers** → **+** → **Services IDs**
2. Description: `Devkom Sign in with Apple`
3. Identifier: `com.example.devkom_app.signin`
4. **Continue** → **Register**
5. Services ID'yi seçin → **Configure**
6. **Website URLs** altına şunları ekleyin:
   - Primary App ID: `com.example.devkom_app`
   - Domain: `devkom.com.tr` (veya sizin domain'iniz)
   - Return URL: `https://<YOUR-PROJECT-ID>.firebaseapp.com/__/auth/handler`
7. **Save** → **Continue** → **Done**

#### c) Firebase Console Ayarları
1. [Firebase Console](https://console.firebase.google.com/) → Projeniz
2. **Authentication** → **Sign-in method** → **Apple**
3. **Enable** → **Save**
4. Apple Developer'dan aldığınız:
   - **Services ID**: `com.example.devkom_app.signin`
   - **Team ID**: Apple Developer hesabınızdan bulun
   - **Key ID** ve **Private Key**: [Keys](https://developer.apple.com/account/resources/authkeys/list) bölümünden oluşturun

### 2. iOS/Xcode Ayarları

#### a) Xcode'da Capability Ekleme
1. `ios/Runner.xcworkspace` dosyasını Xcode'da açın
2. **Runner** → **Signing & Capabilities**
3. **+ Capability** → **Sign in with Apple**

#### b) Info.plist Güncellemesi (Otomatik)
```xml
<!-- Xcode otomatik ekler -->
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

### 3. Kod Kullanımı

#### Login Ekranında Kullanım
```dart
import 'package:devkom_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Email/Password Login
            ElevatedButton(
              onPressed: () => _emailLogin(),
              child: Text('Email ile Giriş'),
            ),

            // Apple Sign In (iOS only)
            FutureBuilder<bool>(
              future: authService.isAppleSignInAvailable(),
              builder: (context, snapshot) {
                if (snapshot.data != true) return SizedBox.shrink();

                return SignInWithAppleButton(
                  onPressed: () async {
                    try {
                      final user = await authService.signInWithApple();
                      print('Giriş başarılı: ${user.displayName}');
                      // Navigate to home
                    } catch (e) {
                      // Show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Giriş hatası: $e')),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 💳 StoreKit Kurulumu

### 1. App Store Connect Ayarları

#### a) Abonelik Oluşturma
1. [App Store Connect](https://appstoreconnect.apple.com/) → **My Apps**
2. Uygulamanızı seçin
3. **Subscriptions** → **+** → **Create Subscription Group**
   - Reference Name: `Devkom Pro Subscriptions`
4. **Create Subscription** → İki abonelik ekleyin:

**Aylık Abonelik:**
- Product ID: `devkom_pro_monthly`
- Reference Name: `Devkom Pro Aylık`
- Duration: 1 Month
- Price: ₺49.99 (örnek)

**Yıllık Abonelik:**
- Product ID: `devkom_pro_yearly`
- Reference Name: `Devkom Pro Yıllık`
- Duration: 1 Year
- Price: ₺399.99 (örnek)
- **Discount**: İlk ay %20 indirim ekleyebilirsiniz

#### b) Sandbox Tester Hesabı Oluşturma
1. [App Store Connect](https://appstoreconnect.apple.com/) → **Users and Access**
2. **Sandbox** → **+** (Yeni tester)
3. Email: `test@devkom.com` (gerçek olmayan email)
4. Password: Test için şifre
5. Region: Turkey

### 2. Kod Kullanımı

#### Main.dart'ta Servis Başlatma
```dart
import 'package:devkom_app/services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp();

  // Subscription servisini başlat
  final subscriptionService = SubscriptionService();
  await subscriptionService.initialize();

  runApp(MyApp());
}
```

#### Abonelik Satın Alma Ekranı
```dart
import 'package:devkom_app/services/subscription_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<ProductDetails> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _subscriptionService.getAvailableProducts();
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      print('Ürünler yüklenemedi: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('Devkom Pro')),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];

          return Card(
            child: ListTile(
              title: Text(product.title),
              subtitle: Text(product.description),
              trailing: Text(product.price),
              onTap: () => _purchaseProduct(product),
            ),
          );
        },
      ),
    );
  }

  Future<void> _purchaseProduct(ProductDetails product) async {
    try {
      final success = await _subscriptionService.purchaseSubscription(product);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Satın alma başlatıldı...')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }
}
```

#### Abonelik Durumu Kontrol Etme
```dart
// Herhangi bir yerde abonelik kontrolü
final subscriptionService = SubscriptionService();
final hasSubscription = await subscriptionService.hasActiveSubscription();

if (hasSubscription) {
  // Pro özellikleri göster
  showProFeatures();
} else {
  // Abonelik satın alma ekranını göster
  showSubscriptionScreen();
}

// Abonelik bilgilerini göster
final info = await subscriptionService.getSubscriptionInfo();
if (info != null) {
  print('Pro aktif: ${info['isActive']}');
  print('Bitiş tarihi: ${info['expiryDate']}');
}
```

#### iOS'ta "Restore Purchases" Butonu (ZORUNLU)
```dart
// Settings ekranında olmalı
ElevatedButton(
  onPressed: () async {
    try {
      await _subscriptionService.restorePurchases();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Satın almalar geri yüklendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  },
  child: Text('Satın Almaları Geri Yükle'),
)
```

---

## 🧪 Test Etme

### Sign in with Apple Testi

#### iOS Simulator'da Test
```bash
# Simulator başlat
open -a Simulator

# Settings → Sign in to your Apple ID
# Test hesabınızla giriş yapın

# Uygulamayı çalıştır
flutter run
```

**Önemli**: Sandbox hesabı ile giriş yapın, production hesabı değil!

### StoreKit Testi

#### 1. Sandbox Hesabıyla Test
1. iOS cihazda **Settings** → **App Store** → **Sandbox Account**
2. Sandbox tester hesabınızı ekleyin
3. Uygulamayı çalıştırın
4. Satın alma yapmayı deneyin
5. Apple ID şifrenizi girdiğinizde **[Environment: Sandbox]** yazmalı

#### 2. StoreKit Configuration File (Xcode 12+)
```bash
# Xcode'da
File → New → File → StoreKit Configuration File
```

**StoreKit.storekit** dosyası oluşturun:
```json
{
  "identifier" : "devkom_pro_monthly",
  "type" : "auto-renewable",
  "reference_name" : "Devkom Pro Monthly",
  "products" : [
    {
      "displayPrice" : "49,99",
      "familyShareable" : false,
      "groupNumber" : 1,
      "internalID" : "1234567890",
      "localizations" : [
        {
          "description" : "Aylık Pro abonelik",
          "displayName" : "Devkom Pro Aylık",
          "locale" : "tr"
        }
      ],
      "productID" : "devkom_pro_monthly",
      "referenceName" : "Monthly",
      "subscriptionGroupName" : "Devkom Pro",
      "type" : "auto-renewable"
    }
  ]
}
```

---

## ❓ SSS (Sık Sorulan Sorular)

### Q: Android'de Sign in with Apple çalışır mı?
**A**: Hayır, ancak Firebase Auth sayesinde:
- iOS kullanıcı Apple ile giriş yapar
- Android kullanıcı Email/Password veya Google ile giriş yapar
- Her iki platform da aynı Firebase Firestore'u kullanır

### Q: Kullanıcı hem iOS hem Android kullanıyorsa?
**A**: Firebase Auth'un aynı email için farklı provider'ları birleştirir:
```dart
// iOS'ta Apple ile giriş: apple.user@example.com
// Android'de Email ile giriş: apple.user@example.com (aynı email)
// → Aynı Firebase UID, aynı Firestore verileri!
```

### Q: StoreKit abonelikler otomatik yenilenir mi?
**A**: Evet, ancak:
- Production'da: Otomatik yenilenir
- Sandbox'ta: Hızlandırılmış (1 günde 5-6 kez yenilenir test için)

### Q: Abonelik süresi dolunca ne olur?
**A**:
1. `proExpiryDate` Firestore'da geçer
2. `hasActiveSubscription()` false döner
3. Uygulama otomatik olarak free özelliklere döner

### Q: Kullanıcı iptali nasıl yapar?
**A**:
- iOS: Settings → [İsim] → Subscriptions → Devkom → Cancel
- Kod tarafından iptal **YAPAMAYIZ** (Apple kuralı)

### Q: Firebase maliyetleri?
**A**:
- Auth: Ücretsiz (sınırsız kullanıcı)
- Firestore: İlk 50k okuma/gün ücretsiz
- **Önemli**: StoreKit %30 komisyon alır (Apple'a gider)

---

## 📱 Sonraki Adımlar

### 1. App Store'a Gönderme Öncesi
- [ ] TestFlight'ta beta test yapın
- [ ] Abonelikleri test edin (en az 1 hafta)
- [ ] Screenshot'larda abonelik özelliklerini gösterin
- [ ] Privacy Policy ekleyin

### 2. Üretim Ayarları
```dart
// .env dosyasına ekleyin
APPLE_SIGNIN_ENABLED=true
SUBSCRIPTION_ENABLED=true
```

### 3. Analytics Ekleme
```dart
// Satın alma başarılı olduğunda
FirebaseAnalytics.instance.logPurchase(
  value: product.price,
  currency: 'TRY',
  items: [{'id': product.id}],
);
```

---

## 🆘 Destek

Sorun mu yaşıyorsunuz?

1. **Logları kontrol edin**:
   ```bash
   flutter logs | grep "🍎\|💳\|✅\|❌"
   ```

2. **Firebase Console** → Authentication → Users (giriş yapan kullanıcıları görün)

3. **App Store Connect** → Sales and Trends (satın almaları görün)

---

## 📚 Faydalı Linkler

- [Sign in with Apple Documentation](https://developer.apple.com/sign-in-with-apple/)
- [StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- [Flutter in_app_purchase Package](https://pub.dev/packages/in_app_purchase)
- [Firebase Auth iOS Setup](https://firebase.google.com/docs/auth/ios/apple)

---

**Son Güncelleme**: 2025-11-21
**Versiyon**: 1.0.0
