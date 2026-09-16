import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/services/ad_unlock_service.dart';

/// Odullu reklamla kilit acma kurallari.
///
/// Urun karari soyleydi: Pro bir kursun ILK IKI dersi reklamla acilabilir
/// ve acik kalir; ucuncu ders ve sonrasi yalnizca Pro. Kilitli oyunlar
/// ise reklamla KALICI acilmaz, yalnizca tek tur oynanir.
///
/// Bu sinir urunun kendisi: kaldirilirsa hem Pro'nun satacagi bir sey
/// kalmaz hem de cocuk ilerlemek icin reklam izlemek zorunda kalir.
/// O yuzden testle kilitliyoruz.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final servis = AdUnlockService.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await servis.temizle();
  });

  group('ders sinirlari', () {
    test('ilk iki ders reklamla acilabilir', () {
      expect(servis.reklamlaAcilabilir(0), isTrue);
      expect(servis.reklamlaAcilabilir(1), isTrue);
    });

    test('ucuncu ders ve sonrasi reklamla acilamaz', () {
      expect(servis.reklamlaAcilabilir(2), isFalse);
      expect(servis.reklamlaAcilabilir(3), isFalse);
      expect(servis.reklamlaAcilabilir(50), isFalse);
    });

    test('sinir ikiden buyuk olmamali', () {
      // Bu sayiyi yukseltmek urun kararini degistirir: kurs reklamla
      // bitirilebilir hale gelir. Degistirmek isteyen once bu testi ve
      // ustundeki gerekceyi okusun.
      expect(AdUnlockService.reklamlaAcilabilirDers, 2);
    });

    test('gecersiz sira reddediliyor', () {
      expect(servis.reklamlaAcilabilir(-1), isFalse);
    });
  });

  group('kalicilik', () {
    test('acilan ders acik kaliyor', () async {
      expect(await servis.acikMi('java', 'java_1'), isFalse);
      expect(await servis.ac('java', 'java_1', 0), isTrue);
      expect(await servis.acikMi('java', 'java_1'), isTrue);
    });

    test('sinirin disindaki ders acilmiyor', () async {
      expect(await servis.ac('java', 'java_3', 2), isFalse);
      expect(await servis.acikMi('java', 'java_3'), isFalse);
    });

    test('kurslar birbirine karismiyor', () async {
      await servis.ac('java', 'ders_1', 0);
      expect(await servis.acikMi('csharp', 'ders_1'), isFalse);
      expect(await servis.acilanSayisi('java'), 1);
      expect(await servis.acilanSayisi('csharp'), 0);
    });

    test('ayni ders iki kez acilinca sayac artmiyor', () async {
      await servis.ac('java', 'java_1', 0);
      await servis.ac('java', 'java_1', 0);
      expect(await servis.acilanSayisi('java'), 1);
    });

    test('bir kursta en fazla iki ders acilabiliyor', () async {
      await servis.ac('java', 'java_1', 0);
      await servis.ac('java', 'java_2', 1);
      await servis.ac('java', 'java_3', 2);
      await servis.ac('java', 'java_4', 3);
      expect(await servis.acilanSayisi('java'),
          AdUnlockService.reklamlaAcilabilirDers);
    });
  });

  group('kaynak kodu kurallari', () {
    final proGate = File('lib/utils/pro_gate.dart').readAsStringSync();

    test('reklam dugmesi yalnizca hak varken ciziliyor', () {
      // Gunluk sinir dolmussa ya da platform reklam desteklemiyorsa
      // dugmeyi gostermek, basildiginda hicbir sey olmayan bir dugme
      // demek. ensureOrAd bunu onceden soruyor.
      expect(proGate.contains('await AdsService.instance.canWatchRewarded()'),
          isTrue);
      expect(proGate.contains('reklamEtiketi: reklamVar ? reklamEtiketi : null'),
          isTrue);
    });

    test('Pro uyeye reklam secenegi hic sorulmuyor', () {
      final i = proGate.indexOf('static Future<ProUnlock> ensureOrAd');
      expect(i, isNot(-1));
      final govde = proGate.substring(i, i + 400);
      expect(govde.indexOf('if (isPro(context)) return ProUnlock.pro;'),
          lessThan(govde.indexOf('canWatchRewarded')),
          reason: 'Pro kontrolu reklam kontrolunden ONCE gelmeli.');
    });

    test('odul kazanilmadan kilit acilmiyor', () {
      expect(proGate.contains('if (sonuc.earned) return ProUnlock.reklam;'),
          isTrue);
    });

    test('kilitli oyun kalici olarak acilmiyor', () {
      // Oyun tarafi AdUnlockService'e hic yazmiyor: reklam tek tur veriyor.
      final oyunlar =
          File('lib/screens/robotics_games_screen.dart').readAsStringSync();
      expect(oyunlar.contains('AdUnlockService'), isFalse,
          reason: 'Oyun kilidi kalici acilirsa "tek tur" sozu bozulur.');
      expect(oyunlar.contains('ProGate.ensureOrAd'), isTrue);
    });

    test('kurs kapisi artik kilitli degil', () {
      // Kilit ders basina tasindi; katalogda kurs acilisini engelleyen
      // bir ProGate.ensure kalmamali.
      final katalog = File('lib/courses/screens/course_catalog_screen.dart')
          .readAsStringSync();
      expect(katalog.contains('ProGate.ensure('), isFalse);
    });

    test('ucuncu ders icin reklam secenegi sunulmuyor', () {
      final kurs = File('lib/courses/screens/interactive_course_screen.dart')
          .readAsStringSync();
      final i = kurs.indexOf('if (!_reklamlaAcilir(lesson)) {');
      expect(i, isNot(-1));
      // O dalda ensure (yalnizca Pro) cagriliyor, ensureOrAd degil.
      final dal = kurs.substring(i, kurs.indexOf('} else {', i));
      expect(dal.contains('ProGate.ensure('), isTrue);
      expect(dal.contains('ensureOrAd'), isFalse);
    });
  });
}
