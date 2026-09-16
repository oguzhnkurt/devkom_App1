@Tags(['shots'])
library;

// Bes maskotu BUTUN ruh halleriyle ve ekipmanlariyla cizer — ARAC.
//
//     flutter test --run-skipped --tags shots test/mascot_species_shots_test.dart
//
// Cikti: outputs/mascot/turler.png     (tur x ruh hali izgarasi)
//        outputs/mascot/ekipman.png    (sapka/gozluk/ayakkabi oturuyor mu)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/character_screen.dart';
import 'package:devkom_app/widgets/mascot.dart';

Future<void> _loadFonts() async {
  for (final w in ['400', '600', '700', '800']) {
    final f = File('assets/fonts/Nunito-$w.ttf');
    if (f.existsSync()) {
      await (FontLoader('Nunito')
            ..addFont(Future.value(f.readAsBytesSync().buffer.asByteData())))
          .load();
    }
  }
  // Emoji: ekipmanlar emoji olarak ciziliyor. Yuklenmezse tofu kutusu
  // cikiyor ve cipa denetimi yapilamiyor.
  for (final path in const [
    '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
    '/System/Library/Fonts/Apple Color Emoji.ttc',
  ]) {
    final f = File(path);
    if (f.existsSync()) {
      await (FontLoader('EmojiFallback')
            ..addFont(Future.value(f.readAsBytesSync().buffer.asByteData())))
          .load();
      break;
    }
  }
}

const _moodLabels = {
  MascotMood.idle: 'bekliyor',
  MascotMood.happy: 'mutlu',
  MascotMood.cheering: 'seviniyor',
  MascotMood.curious: 'merak',
  MascotMood.thinking: 'düşünüyor',
  MascotMood.encouraging: 'cesaret',
};

Future<void> _shoot(WidgetTester tester, String name, Widget sheet,
    Size size) async {
  SharedPreferences.setMockInitialValues({'language_code': 'tr'});
  final settings = SettingsProvider();
  await settings.setLocale(const Locale('tr'));

  tester.view.physicalSize = Size(size.width * 2, size.height * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MediaQuery(
        data: MediaQueryData(size: size),
        child: DefaultTextStyle(
          style: const TextStyle(
              fontFamily: 'Nunito',
              fontFamilyFallback: ['EmojiFallback'],
              color: Color(0xFF303648)),
          child: Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: size.width,
              height: size.height,
              color: const Color(0xFFF3F5FA),
              child: sheet,
            ),
          ),
        ),
      ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));

  await tester.runAsync(() async {
    final b = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory('outputs/mascot').createSync(recursive: true);
    File('outputs/mascot/$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

TextStyle get _label => const TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: Color(0xFF303648));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  testWidgets('tur x ruh hali izgarasi', (tester) async {
    const cell = 140.0;
    final species = MascotSpecies.values;
    final moods = _moodLabels.keys.toList();
    final size = Size(
      cell * moods.length + 130,
      (cell * 1.12 + 26) * species.length + 50,
    );

    await _shoot(
      tester,
      'turler',
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const SizedBox(width: 96),
              for (final m in moods)
                SizedBox(
                    width: cell,
                    child: Text(_moodLabels[m]!,
                        textAlign: TextAlign.center, style: _label)),
            ]),
            for (final s in species)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 96,
                      child: Text('${specOf(s).name}\n${specOf(s).tagline}',
                          style: _label)),
                  for (final m in moods)
                    SizedBox(
                      width: cell,
                      child: Center(
                        child: Mascot(species: s, mood: m, size: cell * 0.80),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      size,
    );
  });

  testWidgets('secici seridi', (tester) async {
    await _shoot(
      tester,
      'secici',
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Arkadaşın — beşinden birini seç', style: _label),
            const SizedBox(height: 12),
            const MascotPicker(),
          ],
        ),
      ),
      const Size(620, 230),
    );
  });

  testWidgets('ekipman cipalari', (tester) async {
    const cell = 190.0;
    final species = MascotSpecies.values;
    final size = Size(cell * species.length + 60, cell * 1.12 + 140);

    await _shoot(
      tester,
      'ekipman',
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Şapka · gözlük · kolye · ayakkabı — hepsinde aynı çıpalar',
                style: _label),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final s in species)
                  SizedBox(
                    width: cell,
                    child: Column(
                      children: [
                        Mascot(
                          species: s,
                          size: cell * 0.82,
                          mood: MascotMood.happy,
                          hat: '🎩',
                          glasses: '🕶️',
                          necklace: '🎽',
                          shoes: '👟',
                        ),
                        const SizedBox(height: 6),
                        Text(specOf(s).name, style: _label),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      size,
    );
  });
}

