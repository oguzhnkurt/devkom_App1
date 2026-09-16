// Maskot secici: cocuk bes karakterden birini secebiliyor mu, secim
// kaydediliyor mu, acilista dogru karakter geliyor mu.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/character_screen.dart';
import 'package:devkom_app/widgets/character_stage.dart';
import 'package:devkom_app/widgets/mascot.dart';

/// SettingsProvider kurucusunda SharedPreferences okuyor. Bu okuma
/// gercek bir olay dongusu istiyor; sahte zamanin icinde beklenirse
/// test asili kaliyor. Bu yuzden runAsync icinde kuruluyor.
Future<SettingsProvider> _settings(
    WidgetTester tester, Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  late SettingsProvider s;
  await tester.runAsync(() async {
    s = SettingsProvider();
    await Future<void>.delayed(const Duration(milliseconds: 30));
  });
  return s;
}

Future<void> _pump(WidgetTester tester, SettingsProvider settings) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: MascotPicker())),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('beş karakterin hepsi seçilebiliyor', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = await _settings(tester, {});
    await _pump(tester, settings);

    for (final species in MascotSpecies.values) {
      expect(find.text(specOf(species).name), findsOneWidget,
          reason: '${specOf(species).name} seçicide yok');
    }
  });

  testWidgets('dokununca seçim değişiyor ve KAYDEDİLİYOR', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = await _settings(tester, {});
    expect(settings.mascot, MascotSpecies.puf,
        reason: 'açılıştaki karakter Puf olmalı');

    await _pump(tester, settings);
    await tester.tap(find.text('Mia'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(settings.mascot, MascotSpecies.mia);

    // Kalicilik: yeni bir provider ayni tercihi okumali. Bu unutulursa
    // cocuk her acilista Puf'a geri doner ve secimi kaybolur.
    late SettingsProvider reloaded;
    await tester.runAsync(() async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mascot_species'), 'mia');
      reloaded = SettingsProvider();
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    expect(reloaded.mascot, MascotSpecies.mia);
  });

  test('bozuk kayıt açılıştaki karaktere düşüyor', () async {
    SharedPreferences.setMockInitialValues({'mascot_species': 'yok-boyle-bir-sey'});
    final s = SettingsProvider();
    await Future<void>.delayed(Duration.zero);
    expect(s.mascot, MascotSpecies.puf);
  });

  // BU HATA GERCEKTEN OLDU: CharacterStage'in kendi `species` alani
  // Puf'a varsayiliydi ve turu Mascot'a HER ZAMAN elle geciriyordu.
  // Cocuk Mia'yi secse bile profil ekranindaki sahne Puf gosteriyordu.
  testWidgets('CharacterStage çocuğun seçimini eziyor mu', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = await _settings(tester, {'mascot_species': 'kasif'});
    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settings,
        child: const MaterialApp(
          home: Scaffold(
            body: Center(child: CharacterStage(size: 160, interactive: false)),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final mascot = tester.widget<Mascot>(find.byType(Mascot));
    expect(mascot.species, MascotSpecies.kasif,
        reason: 'sahne, çocuğun seçtiği karakteri göstermeli');
  });

  testWidgets('seçili karakter mutlu, diğerleri sakin duruyor', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final settings = await _settings(tester, {'mascot_species': 'bit'});
    await _pump(tester, settings);

    final mascots = tester.widgetList<Mascot>(find.byType(Mascot)).toList();
    expect(mascots.length, MascotSpecies.values.length);
    for (final m in mascots) {
      if (m.species == MascotSpecies.bit) {
        expect(m.mood, MascotMood.happy);
      } else {
        expect(m.mood, MascotMood.idle);
      }
    }
  });
}
