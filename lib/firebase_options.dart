// Firebase yapilandirmasi: DevEducation projesi (deveducation-c550b).
//
// 30 Ekim 2026'da acildi. Repodaki eski google-services.json ve
// GoogleService-Info.plist baska bir hesaptaki `devkom-dfdca` projesine
// ve eski paket adlarina (com.example...) aitti; yerlerine bu projenin
// dosyalari kondu. Degerler o dosyalardan alindi.
//
// iOS plist'i Xcode projesine kaynak olarak ekli DEGIL; bu yuzden
// baslatma yerel dosyaya degil buradaki seceneklere dayaniyor (iki
// platformda da ayni yol). Bunlar istemci yapilandirmasi, gizli anahtar
// degil; erisim Firebase guvenlik kurallariyla sinirlanir.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  /// Desteklenmeyen platformda (web, masaustu) null: Firebase baslatilmaz.
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return null;
    }
  }

  static const String projectId = 'deveducation-c550b';

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAFYK3FUrClmZw58mDxti3DcN_PxMZ0tUU',
    appId: '1:1035073444712:android:80ade43023f6610da2d4dd',
    messagingSenderId: '1035073444712',
    projectId: projectId,
    storageBucket: 'deveducation-c550b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD9AKwTeWjezGnddZQNORWzQI-gBGlMufA',
    appId: '1:1035073444712:ios:c68027ec5004a29fa2d4dd',
    messagingSenderId: '1035073444712',
    projectId: projectId,
    storageBucket: 'deveducation-c550b.firebasestorage.app',
    iosBundleId: 'com.devkom.app',
  );
}
