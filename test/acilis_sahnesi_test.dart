// Acilis sahnesi: gece uzayi, tek renk yazi, mBlock tarzi bloklar.
import 'dart:io';

import 'package:devkom_app/widgets/acilis_sahnesi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('son halinde yazi ve uc blok var', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('tr'),
      supportedLocales: [Locale('tr'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: AcilisSahnesi(giris: false)),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.bySemanticsLabel('DevEducation'), findsOneWidget);
    for (final k in ['Kodla', 'Oyna', 'Keşfet', 'Scratch', 'Robot', 'YZ']) {
      expect(find.text(k), findsOneWidget, reason: k);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  test('DevEducation tek renk ve yerel acilis rengi ayni', () {
    expect(AcilisTema.uzay.dev, AcilisTema.uzay.yazi);
    expect(AcilisSahnesi.zemin, const Color(0xFF111833));
    final ios = File('ios/Runner/Base.lproj/LaunchScreen.storyboard').readAsStringSync();
    expect(ios.contains('red="0.066666666666666666" green="0.094117647058823528"'), isTrue);
    final android = File('android/app/src/main/res/values/colors.xml').readAsStringSync();
    expect(android.contains('<color name="acilis_zemin">#111833</color>'), isTrue);
  });
}
