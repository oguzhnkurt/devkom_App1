import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IZIN YUZEYI TESTI
///
/// NEDEN VAR
/// ---------
/// Android izinleri manifestte elle yazilmiyor; paketlerin kendi
/// manifestlerinden BIRLESEREK geliyor. Yani kullanilmayan bir paket
/// depoda durdugu surece uygulama, hic kullanmadigi bir izni istiyor
/// gorunuyor.
///
/// `flutter_sound` tam olarak bunu yapiyordu: Dart tarafinda hicbir yerde
/// import edilmiyordu (tum ses `audioplayers` uzerinden gidiyor) ama
/// birlesik manifeste su iki satiri koyuyordu:
///
///   <uses-permission android:name="android.permission.RECORD_AUDIO" />
///   <uses-permission android:name="Manifest.permission.CAPTURE_AUDIO_OUTPUT" />
///
/// Ikincisi ayrica bozuk bir izin adi (Java sabiti XML'e yazilmis).
/// Cocuk kitlesi olan bir uygulamada gereksiz mikrofon izni hem Play'in
/// Veri Guvenligi formunda aciklama gerektiriyor hem de veliye kotu
/// gorunuyor. Paket kaldirildi; bu test geri gelmesini engelliyor.
///
/// Yeni bir ses/mikrofon ozelligi GERCEKTEN eklenirse bu testi silmek
/// degil, listeyi bilerek guncellemek gerekiyor — o zaman Veri Guvenligi
/// beyani da guncellenmeli.
void main() {
  test('pubspec kullanilmayan ses paketlerini geri almiyor', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      pubspec.contains('flutter_sound'),
      isFalse,
      reason: 'flutter_sound hicbir yerde kullanilmiyor ve RECORD_AUDIO '
          'iznini geri getiriyor. Ses icin audioplayers var.',
    );
  });

  test('Android manifestinde mikrofon izni yok', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    for (final izin in const [
      'RECORD_AUDIO',
      'CAPTURE_AUDIO_OUTPUT',
    ]) {
      expect(
        manifest.contains(izin),
        isFalse,
        reason: '$izin manifeste elle eklenmis. Uygulama ses KAYDETMIYOR.',
      );
    }
  });

  test('ses servisi audioplayers kullaniyor', () {
    final servis = File('lib/services/sound_service.dart').readAsStringSync();
    expect(servis.contains("package:audioplayers/audioplayers.dart"), isTrue);
    expect(servis.contains('flutter_sound'), isFalse);
  });
}
