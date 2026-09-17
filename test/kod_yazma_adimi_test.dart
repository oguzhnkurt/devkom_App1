// KOD YAZMA ADIMI — yazınca "Kontrol Et" açılıyor.
//
// Tuşun `onPressed`'i metin kutusu boş mu diye bakıyor, ama bu ölçüm
// yalnızca widget yeniden çizilirken yapılıyor ve `TextEditingController`
// değiştiğinde kendiliğinden bir çizim olmuyordu. Çocuk kodu yazıyor,
// tuş GRİ kalıyor, adım hiç tamamlanamıyordu — klavye açılırken olan
// tek yeniden çizim metin daha boşken gerçekleşiyor.
//
// Hata mağaza ekran görüntüsü alınırken ortaya çıktı: kod kutusu doluydu
// ama "Kontrol Et" sönüktü.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/html_lessons_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/ui/press_button.dart';

Future<void> _ciz(WidgetTester tester, TypeCodeStep adim) async {
  SharedPreferences.setMockInitialValues({'language_code': 'tr'});
  final settings = SettingsProvider();
  await settings.setLocale(const Locale('tr'));

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: TypeCodeStepWidget(
              step: adim,
              course: CoursesData.byId('html')!,
              isDark: false,
              onComplete: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

/// Tusun basilabilir olup olmadigi.
bool _acikMi(WidgetTester tester) {
  final tus = tester.widget<PressButton>(
    find.widgetWithText(PressButton, 'Kontrol Et'),
  );
  return tus.onPressed != null;
}

void main() {
  final adim = HtmlLessonsData.module1
      .expand((l) => l.steps)
      .whereType<TypeCodeStep>()
      .firstWhere((s) => s.id == 'h1_2_type1');

  testWidgets('bos kutuda Kontrol Et kapali', (tester) async {
    await _ciz(tester, adim);
    expect(_acikMi(tester), isFalse,
        reason: 'Bos kod kutusunda kontrol tusu basilabilir olmamali.');
  });

  testWidgets('kod yazilinca Kontrol Et aciliyor', (tester) async {
    await _ciz(tester, adim);

    await tester.enterText(find.byType(TextField), '<h1>Merhaba</h1>');
    await tester.pump();

    expect(_acikMi(tester), isTrue,
        reason: 'Cocuk kodu yazdi ama tus hala gri: adim tamamlanamaz.');
  });

  testWidgets('kod silinince Kontrol Et yine kapaniyor', (tester) async {
    await _ciz(tester, adim);

    await tester.enterText(find.byType(TextField), '<h1>Merhaba</h1>');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();

    expect(_acikMi(tester), isFalse,
        reason: 'Yalnizca bosluk kalmis bir kutu dolu sayilmamali.');
  });
}
