import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/services/certificate_service.dart';
import 'package:devkom_app/utils/app_localizations.dart';
import 'package:devkom_app/utils/lang.dart';

/// Dort dilin gercekten calistigi.
///
/// Ceviri hatalari en sessiz hata turu: uygulama calisir, hicbir sey
/// kirilmaz, sadece ekranda yanlis dil durur. Bir anahtarin Almancasi
/// unutulursa kimse fark etmez — kullanici disinda.
void main() {
  group('AppLang', () {
    test('dort dil destekleniyor', () {
      expect(AppLang.supported, ['tr', 'en', 'de', 'es']);
      for (final code in AppLang.supported) {
        expect(AppLang.isSupported(code), isTrue);
        expect(AppLang.nativeName[code], isNotNull);
        expect(AppLang.flag[code], isNotNull);
      }
    });

    test('her dil KENDI adiyla yaziliyor', () {
      // Bir dili secerken kullanici o dili henuz okumuyor olabilir ama
      // kendi dilinin adini tanir.
      expect(AppLang.nativeName['de'], 'Deutsch');
      expect(AppLang.nativeName['es'], 'Español');
      expect(AppLang.nativeName['tr'], 'Türkçe');
    });

    test('desteklenmeyen cihaz dili INGILIZCE ye duser, Turkce ye degil', () {
      // Fransizca bir cihazda uygulamanin Turkce acilmasi, kullaniciya
      // "bu uygulama sana gore degil" demek olur.
      expect(AppLang.resolve('fr'), 'en');
      expect(AppLang.resolve(null), 'en');
      expect(AppLang.resolve('de'), 'de');
      expect(AppLang.resolve('tr'), 'tr');
    });

    test('de/es verilmemisse Ingilizce kullanilir, Turkce degil', () {
      const args = {'tr': 'Merhaba', 'en': 'Hello'};
      expect(
        AppLang.pick('de', tr: args['tr']!, en: args['en']!),
        'Hello',
        reason: 'Almanca yoksa Ingilizce gosterilmeli',
      );
      expect(AppLang.pick('es', tr: args['tr']!, en: args['en']!), 'Hello');
      expect(
        AppLang.pick('de', tr: 'Merhaba', en: 'Hello', de: 'Hallo'),
        'Hallo',
      );
      expect(
        AppLang.pick('es', tr: 'Merhaba', en: 'Hello', es: 'Hola'),
        'Hola',
      );
      expect(AppLang.pick('tr', tr: 'Merhaba', en: 'Hello'), 'Merhaba');
      // Taninmayan bir kod da Ingilizce.
      expect(AppLang.pick('fr', tr: 'Merhaba', en: 'Hello'), 'Hello');
    });
  });

  group('AppLocalizations', () {
    /// Bir dildeki bir anahtar eksikse `?? 'Turkce varsayilan'` devreye
    /// giriyor ve Alman kullanici ekranda TURKCE bir cumle goruyor.
    /// Bu test tam olarak bunu ariyor.
    test('dort dilde de ayni anahtar kumesi var', () {
      final tr = AppLocalizations.debugValues['tr']!;
      for (final code in ['en', 'de', 'es']) {
        final map = AppLocalizations.debugValues[code];
        expect(map, isNotNull, reason: '$code hic tanimli degil');
        final missing = tr.keys.where((k) => !map!.containsKey(k)).toList();
        expect(missing, isEmpty, reason: '$code dilinde eksik: $missing');
      }
    });

    test('hicbir ceviri bos degil', () {
      for (final entry in AppLocalizations.debugValues.entries) {
        for (final kv in entry.value.entries) {
          expect(kv.value.trim(), isNotEmpty,
              reason: '${entry.key}/${kv.key} bos');
        }
      }
    });

    test('Almanca ve Ispanyolca metinler Ingilizceden farkli', () {
      // Kopyala-yapistir ile Ingilizce birakilmis anahtarlari yakalar.
      // Bazi kelimeler dogal olarak ayni ("PDF", "OK", "Version"), o
      // yuzden hepsinin degil, buyuk cogunlugunun farkli olmasini
      // bekliyoruz.
      final en = AppLocalizations.debugValues['en']!;
      for (final code in ['de', 'es']) {
        final other = AppLocalizations.debugValues[code]!;
        final same = en.keys.where((k) => en[k] == other[k]).length;
        expect(same / en.length, lessThan(0.2),
            reason: '$code cevirilerinin cogu Ingilizce ile ayni');
      }
    });

    testWidgets('ayni ekran dile gore farkli metin veriyor', (tester) async {
      for (final entry in {
        'tr': 'Ayarlar',
        'en': 'Settings',
        'de': 'Einstellungen',
        'es': 'Ajustes',
      }.entries) {
        String? seen;
        await tester.pumpWidget(MaterialApp(
          locale: Locale(entry.key),
          // Uygulamadaki ile ayni delege listesi. Global delegeler
          // olmadan Almanca/Ispanyolca tarih ve dugme metinleri
          // (Material'in kendi yazilari) cevrilmez.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLang.supported.map(Locale.new).toList(),
          home: Builder(builder: (context) {
            seen = AppLocalizations.of(context).settings;
            return const SizedBox();
          }),
        ));
        // Delegeler asenkron yukleniyor; ilk kare Builder'i calistirmiyor.
        await tester.pumpAndSettle();
        expect(seen, entry.value, reason: '${entry.key} yanlis');
      }
    });
  });

  group('Sertifikalar', () {
    test('baslik ve kosul dort dilde de var', () {
      final certs = CertificateService.build(null, null);
      expect(certs, isNotEmpty);
      for (final c in certs) {
        for (final lang in AppLang.supported) {
          expect(c.titleFor(lang).trim(), isNotEmpty);
          expect(c.requirementFor(lang).trim(), isNotEmpty);
        }
        // Almanca baslik Turkceden farkli olmali.
        expect(c.titleFor('de'), isNot(c.titleFor('tr')));
        expect(c.requirementFor('es'), isNot(c.requirementFor('tr')));
      }
    });
  });
}
