# 🚀 Quick Start: Sign in with Apple & StoreKit

## ⚡ 5 Dakikada Test Et (Sandbox)

### 1. Paketleri Yükle
```bash
cd /c/Users/Oguzhan/devkom_app
flutter pub get
```

### 2. iOS Simulator Başlat
```bash
open -a Simulator
# veya
# Windows'ta: "$LOCALAPPDATA/Android/Sdk/emulator/emulator.exe" -avd Pixel_6_Pro_API_36
```

### 3. Uygulamayı Çalıştır
```bash
flutter run
```

### 4. Test Senaryoları

#### A) Login Ekranında Apple Sign In Test
```
1. Login ekranını aç
2. En altta "🍎 Apple ile Giriş" butonunu gör
3. HENÜZ ÇALIŞMAZ - Çünkü:
   - Xcode'da capability eklenmedi
   - Firebase'de Apple provider aktif değil
```

#### B) Settings Ekranında Subscription Test
```
1. Giriş yap (email/password ile)
2. Settings'e git
3. En üstte "⭐ Devkom Pro" bölümünü gör
4. "Devkom Pro'ya Yükselt" tıkla
5. SubscriptionScreen açılır
6. HENÜZ ÜRÜN GÖSTERMEZ - Çünkü:
   - App Store Connect'te ürünler oluşturulmadı
```

---

## 📱 Manuel Adımlar (Sırayla Yapılmalı)

### Adım 1: Apple Developer Portal (30 dk)
```
1. https://developer.apple.com/account/ → Giriş yap

2. Certificates, Identifiers & Profiles → Identifiers
   → App IDs → "com.example.devkom_app" seç
   → Edit → "Sign in with Apple" işaretle → Save

3. Yeni Services ID oluştur:
   → Identifiers → "+" → Services IDs
   → Description: "Devkom Sign in with Apple"
   → Identifier: "com.example.devkom_app.signin"
   → Register

4. Services ID'yi yapılandır:
   → "com.example.devkom_app.signin" seç
   → Configure
   → Primary App ID: com.example.devkom_app
   → Domain: devkom.com.tr
   → Return URL: https://devkom-dfdca.firebaseapp.com/__/auth/handler
   → Save

5. Key oluştur (Firebase için):
   → Keys → "+" → Yeni Key
   → Key Name: "Devkom Apple Sign In Key"
   → "Sign in with Apple" işaretle
   → Configure → Primary App ID seç
   → Register
   → Download .p8 dosyasını (sadece 1 kez!)
   → Key ID'yi not al
```

### Adım 2: Firebase Console (10 dk)
```
1. https://console.firebase.google.com/project/devkom-dfdca
   → Authentication → Sign-in method

2. Apple provider'ı bul → Enable

3. Apple Developer'dan aldığın bilgileri gir:
   - Services ID: com.example.devkom_app.signin
   - Team ID: Apple Developer'da sağ üstte (XXXXXXXXXX)
   - Key ID: Keys bölümünden aldın
   - Private Key: .p8 dosyasının içeriği

4. Save
```

### Adım 3: Xcode Konfigürasyonu (5 dk)
```
1. Xcode'u aç:
   cd /c/Users/Oguzhan/devkom_app
   open ios/Runner.xcworkspace

2. Sol panelden "Runner" seç

3. "Signing & Capabilities" tab'ına git

4. "+ Capability" butonuna tıkla

5. "Sign in with Apple" seç

6. Team seçildiğinden emin ol

7. Provisioning Profile otomatik oluşacak

8. Cmd + B ile build et (hata olmamalı)
```

### Adım 4: App Store Connect (30 dk)
```
1. https://appstoreconnect.apple.com/ → Giriş yap

2. My Apps → Uygulamanı seç (yoksa oluştur)

3. Sol menüden "Subscriptions" seç

4. Yeni Subscription Group oluştur:
   → Reference Name: "Devkom Pro Subscriptions"
   → Create

5. İlk aboneliği ekle (Aylık):
   → "+ Create Subscription"
   → Product ID: devkom_pro_monthly (TAM OLARAK BU!)
   → Reference Name: Devkom Pro Aylık
   → Duration: 1 Month
   → Price: 49.99 TL
   → Localization (Türkçe):
     - Display Name: Devkom Pro Aylık
     - Description: Tüm özelliklere sınırsız erişim
   → Save

6. İkinci aboneliği ekle (Yıllık):
   → "+ Create Subscription"
   → Product ID: devkom_pro_yearly (TAM OLARAK BU!)
   → Reference Name: Devkom Pro Yıllık
   → Duration: 1 Year
   → Price: 399.99 TL
   → Localization (Türkçe):
     - Display Name: Devkom Pro Yıllık
     - Description: Tüm özelliklere sınırsız erişim
   → Save

7. Sandbox Tester oluştur:
   → Users and Access → Sandbox
   → "+" → Yeni tester
   → Email: test@devkom.com (gerçek olmasına gerek yok)
   → Password: Test1234!
   → First Name: Test
   → Last Name: User
   → Country: Turkey
   → Create
```

### Adım 5: iOS Cihazda Sandbox Ayarı (2 dk)
```
Fiziksel iPhone veya Simulator'da:

1. Settings → App Store
2. Sandbox Account → Sign Out (varsa)
3. Uygulama açıldığında otomatik Sandbox prompt gelecek
4. test@devkom.com ile giriş yap
```

---

## ✅ Test Zamanı

### Test 1: Apple Sign In
```bash
# iOS simulator'da çalıştır
flutter run

# Login ekranında:
1. "🍎 Apple ile Giriş" butonuna tıkla
2. Apple ID prompt gelecek
3. Face ID/Touch ID simülatöründe Features → Face ID → Matched Face
4. Başarılı giriş → Home ekranı
5. Firebase Console → Authentication → Users → Yeni kullanıcı görünmeli
```

### Test 2: Subscription Satın Alma
```bash
# Giriş yaptıktan sonra:
1. Settings → "Devkom Pro'ya Yükselt"
2. Aylık veya Yıllık seç
3. "Devam Et"
4. Sandbox ödeme ekranı gelecek
5. "[Environment: Sandbox]" yazmalı (üstte)
6. Sandbox tester şifresi: Test1234!
7. Purchase/Confirm
8. 2-3 saniye bekle
9. Settings'e dön → "Devkom Pro Aktif ✓" görünmeli
10. Firebase Console → Firestore → users → isPro: true olmalı
```

### Test 3: Restore Purchases
```bash
# Uygulamayı sil ve yeniden kur veya:
1. Firebase Console → users → Manuel isPro: false yap
2. Uygulama Settings → "Satın Almaları Geri Yükle"
3. İşlem tamamlanır
4. isPro tekrar true olmalı
```

---

## 🐛 Sorun Giderme

### Problem: Apple Sign In Butonu Görünmüyor
```
Çözüm:
- iOS simulator/cihazda çalıştığından emin ol
- Android'de bu buton görünmez (normal)
```

### Problem: "Sign in with Apple is not available"
```
Çözüm:
1. Xcode'da capability eklendi mi kontrol et
2. iOS 13+ olmalı
3. Simulator Settings → iCloud → Sign in (herhangi bir Apple ID)
```

### Problem: Ürünler Listelenmedi
```
Çözüm:
1. App Store Connect'te ürünler "Ready to Submit" durumunda mı?
2. Product ID'ler kod ile birebir aynı mı?
   - devkom_pro_monthly
   - devkom_pro_yearly
3. 1-2 saat bekle (Apple cache)
4. Uygulamayı yeniden başlat
```

### Problem: Sandbox Ödeme Çalışmıyor
```
Çözüm:
1. Sandbox tester oluşturdun mu?
2. iOS Settings → App Store → Sandbox Account doğru mu?
3. Gerçek Apple ID ile giriş yapma, sadece Sandbox!
4. Ödeme ekranında "[Environment: Sandbox]" yazıyor mu?
```

### Problem: Firebase isPro Güncellenmiyor
```
Çözüm:
1. Firestore Rules deploy edildi mi?
   firebase deploy --only firestore:rules
2. purchases koleksiyonuna kayıt düşüyor mu?
3. Logları kontrol et:
   flutter logs | grep "💳\|✅"
```

---

## 📊 Debug Komutları

```bash
# Tüm logları göster
flutter logs

# Sadece subscription logları
flutter logs | grep "💳"

# Sadece Apple Sign In logları
flutter logs | grep "🍎"

# Firebase işlemleri
flutter logs | grep "Firebase\|Firestore"

# Hata logları
flutter logs | grep "❌\|Error"

# Clean build (sorun olursa)
flutter clean && flutter pub get && flutter run
```

---

## 📝 Checklist

### Kod Tarafı (✅ Tamamlandı)
- [x] Paketler eklendi
- [x] AuthService güncellendi
- [x] SubscriptionService oluşturuldu
- [x] UI componentleri eklendi
- [x] Login/Settings ekranları güncellendi
- [x] Firebase rules deploy edildi

### Manuel Adımlar (❌ Yapılacak)
- [ ] Apple Developer Portal ayarları
- [ ] Firebase Console Apple provider
- [ ] Xcode capability ekleme
- [ ] App Store Connect ürünler
- [ ] Sandbox tester oluşturma
- [ ] iOS cihazda test

---

## 🎓 Öğrenme Kaynakları

- [Apple Developer Docs](https://developer.apple.com/sign-in-with-apple/)
- [Firebase Apple Auth](https://firebase.google.com/docs/auth/ios/apple)
- [StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- [Flutter in_app_purchase](https://pub.dev/packages/in_app_purchase)

---

**Hazırlayan**: Claude Code
**Tarih**: 2025-11-21
**Versiyon**: 1.0
**Durum**: Kod %100 Hazır, Manuel Adımlar Bekliyor
