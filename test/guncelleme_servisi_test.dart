// "Yeni surum mevcut" uyarisi (Ekim 2026).
import 'dart:io';

import 'package:devkom_app/services/guncelleme_servisi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('surum karsilastirma', () {
    test('yeni surum algilaniyor', () {
      expect(GuncellemeServisi.dahaYeni('1.0.16', '1.0.15'), isTrue);
      expect(GuncellemeServisi.dahaYeni('1.1', '1.0.99'), isTrue);
      expect(GuncellemeServisi.dahaYeni('2.0.0', '1.9.9'), isTrue);
      expect(GuncellemeServisi.dahaYeni('1.0.10', '1.0.9'), isTrue);
    });
    test('ayni ya da eski surumde uyari yok', () {
      expect(GuncellemeServisi.dahaYeni('1.0.15', '1.0.15'), isFalse);
      expect(GuncellemeServisi.dahaYeni('1.0', '1.0.0'), isFalse);
      expect(GuncellemeServisi.dahaYeni('1.0.14', '1.0.15'), isFalse);
    });
    test('anlasilmayan deger uyari cikarmiyor', () {
      expect(GuncellemeServisi.dahaYeni('', '1.0.15'), isFalse);
      expect(GuncellemeServisi.dahaYeni('1.0.x', '1.0.15'), isFalse);
    });
  });

  test('Apple arama cevabindan surum okunuyor', () {
    expect(
        GuncellemeServisi.appStoreSurumu(
            '{"resultCount":1,"results":[{"version":"1.0.16"}]}'),
        '1.0.16');
    expect(GuncellemeServisi.appStoreSurumu('{"resultCount":0,"results":[]}'),
        isNull);
    expect(GuncellemeServisi.appStoreSurumu('<html>'), isNull);
  });

  for (final (lang, baslik, dugme) in [
    ('tr', 'Yeni sürüm mevcut', 'Güncelle'),
    ('en', 'A new version is available', 'Update'),
    ('de', 'Eine neue Version ist da', 'Aktualisieren'),
    ('es', 'Hay una nueva versión', 'Actualizar'),
  ]) {
    testWidgets('pencere ($lang)', (tester) async {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: GuncellemePenceresi(lang: lang))));
      expect(find.text(baslik), findsOneWidget);
      expect(find.text(dugme), findsOneWidget);
      expect(find.byKey(const ValueKey('guncelleme_sonra')), findsOneWidget);
    });
  }

  test('ana sayfa acilista bir kez kontrol ediyor', () {
    final src =
        File('lib/screens/unified_home_screen.dart').readAsStringSync();
    expect(src.contains('GuncellemeServisi.kontrolEt(context, lang: _lang)'),
        isTrue);
  });

  test('magaza adresleri dogru uygulamaya gidiyor', () {
    expect(GuncellemeServisi.bundleId, 'com.devkom.app');
    expect(GuncellemeServisi.appStoreId, '6775481665');
  });
}
