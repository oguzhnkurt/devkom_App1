// mBLOCK KURSUNUN ACILISI VE KAPANISI
//
// Scratch'inkiyle ayni ekranlar, kurs ayariyla (KursTanitimi):
//  * Acilis: Devi + tek blokluk etkinlik — "when Arduino Uno starts up"
//    altina "dijital ayarla pin 13 cikis yuksek"; bayrakla sanal Uno'nun
//    13. pinindeki LED yaniyor.
//  * Kapanis: ozet (mBlock bloklari tezgah cozumlerinden), sertifika,
//    siradaki kurs Arduino.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/tanitim/kurs_acilis_ekrani.dart';
import 'package:devkom_app/courses/tanitim/kurs_kapanis_ekrani.dart';
import 'package:devkom_app/courses/tanitim/kurs_tanitimi.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/scratch_blok.dart';

final mblock = CoursesData.byId('mblock')!;
final hepsi = CourseModules.allLessons('mblock').map((l) => l.id).toSet();

Future<Widget> _uygulama(Widget home, {String lang = 'tr'}) async {
  final s = SettingsProvider();
  await s.setLocale(Locale(lang));
  return ChangeNotifierProvider<SettingsProvider>.value(
    value: s,
    child: MaterialApp(locale: Locale(lang), home: home),
  );
}

void main() {
  setUpAll(() {
    SoundService.configure(sound: false);
  });

  test('ayar: kart sahnesi, iki gercek mBlock blogu, siradaki kurs Arduino',
      () {
    final t = KursTanitimi.forCourse('mblock')!;
    expect(t.kart, isTrue);
    expect(t.sapka('tr').duzMetin, 'when Arduino Uno starts up');
    expect(t.sapka('tr').sekil, ScratchSekil.sapka);
    expect(t.blok('tr').duzMetin, 'dijital ayarla pin 13 çıkış yüksek');
    expect(t.blok('en').duzMetin, 'set digital pin 13 output as high');
    expect(t.blok('de').duzMetin, 'digitalen Pin von Ausgang 13 als hoch setzen');
    expect(t.blok('es').duzMetin, 'pon el pin digital 13 a alto');
    expect(t.blok('tr').kategori, ScratchKategori.mblockPin);
    expect(KursTanitimi.sonrakiKurs('mblock')?.id, 'arduino');
  });

  test('kapanis ozeti: mBlock bloklari tezgah cozumlerinden', () {
    final o = KursOzeti.hesapla('mblock', hepsi);
    expect(o.kursBitti, isTrue);
    expect(o.farkliBlok, greaterThan(15));
  });

  for (final lang in ['tr', 'en', 'de', 'es']) {
    testWidgets('acilis ($lang): blok yerlesir, bayrak LED 13u yakar',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(await _uygulama(
          KursAcilisEkrani(
              course: mblock, tanitim: KursTanitimi.forCourse('mblock')!),
          lang: lang));
      await tester.pump(const Duration(milliseconds: 300));
      final durum =
          tester.state<KursAcilisEkraniState>(find.byType(KursAcilisEkrani));

      await tester.tap(find.byKey(const ValueKey('acilis_basla')));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byKey(const ValueKey('acilis_palet_blogu')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(durum.evre, AcilisEvresi.calistir);
      expect(durum.unoKarti.parlaklik(13), 0);

      await tester.tap(find.byKey(const ValueKey('acilis_bayrak')));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(durum.unoKarti.parlaklik(13), 1, reason: 'LED yandi');
      expect(durum.evre, AcilisEvresi.kutlama);
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      expect(durum.evre, AcilisEvresi.hazir);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }

  testWidgets('kapanis: sertifika ve siradaki kurs Arduino', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await _uygulama(KursKapanisEkrani(
        course: mblock,
        tamamlanan: hepsi,
        ad: 'Elif',
        tarih: DateTime(2026, 10, 15))));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Kursu bitirdin!'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('kapanis_paylas')), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const ValueKey('kapanis_paylas')), findsOneWidget);
    final arduino = CoursesData.byId('arduino')!;
    await tester.scrollUntilVisible(
        find.textContaining(arduino.nameFor('tr')).last, 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining(arduino.nameFor('tr')), findsWidgets);
    expect(await KursKapanisEkrani.gosterilmeli('mblock', hepsi), isFalse,
        reason: 'Gosterildi: isaret yazildi.');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
