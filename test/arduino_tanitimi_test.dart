// Arduino kursunun acilisi: Devi malzemeleri tanitiyor, sonda ilk derse.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/tanitim/arduino_tanitimi.dart';
import 'package:devkom_app/courses/tanitim/kurs_acilis_ekrani.dart';
import 'package:devkom_app/courses/tanitim/kurs_tanitimi.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';

void main() {
  setUpAll(() => SoundService.configure(sound: false));

  for (final lang in const ['tr', 'en', 'de', 'es']) {
    testWidgets('arduino acilisi bastan sona ($lang), ilk derse gonderir', (tester) async {
      tester.view.physicalSize = const Size(375 * 3, 667 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({'language_code': lang});
      final ayar = SettingsProvider();
      await ayar.setLocale(Locale(lang));
      bool? sonuc;
      await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
        value: ayar,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async =>
                    sonuc = await KursAcilisEkrani.ac(context, CoursesData.byId('arduino')!),
                child: const Text('ac'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('ac'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(ArduinoTanitimEkrani), findsOneWidget);
      final st = tester.state<ArduinoTanitimEkraniState>(find.byType(ArduinoTanitimEkrani));
      for (var i = 0; i < ArduinoTanitimEkrani.slaytSayisi; i++) {
        expect(st.slayt, i);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('arduino_tanitim_ileri')));
        for (var j = 0; j < 12; j++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      expect(find.byType(ArduinoTanitimEkrani), findsNothing);
      expect(sonuc, isTrue);
      expect(await KursTanitimDeposu.acilisGoruldu('arduino'), isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
