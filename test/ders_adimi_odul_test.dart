import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/interactive_lesson_screen.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';

/// Ders ici odul ve tamamlama kilitleri (Ekim 2026 denetimi).
///
///  * Bir adimi yeniden tamamlamak (geri gelip yeniden cevaplamak, blok
///    kurma adiminin ic DEVAM tusu, "Yaptim"a ikinci basis) her seferinde
///    yeniden XP ekliyordu.
///  * "Tamamla"ya iki kez basmak dersi iki kez kaydediyordu.
///  * Rozet hic kaydedilmiyor, tekrarda da "YENI ROZET!" cikiyordu.
///  * Coktan secmeli adim tamamlanmayi 500 ms sonra "su anki adima"
///    bildiriyordu; o arada adim degistiyse yanlis adim tamamlaniyordu.
final _ders = InteractiveLesson(
  id: 'odul_denemesi',
  courseId: 'scratch',
  title: 'Ödül denemesi',
  subtitle: 'Deneme',
  order: 1,
  xpReward: 10,
  badge: 'loop_master',
  steps: const [
    ExplanationStep(id: 'a1', title: 'Bir', content: 'Tek paragraf.'),
    MultipleChoiceStep(
      id: 'a2',
      question: 'Hangisi doğru?',
      options: [
        ChoiceOption(text: 'Doğru seçenek'),
        ChoiceOption(text: 'Yanlış seçenek'),
      ],
      correctIndex: 0,
      explanation: 'Çünkü.',
    ),
    ExplanationStep(id: 'a3', title: 'Son', content: 'Bitti.'),
  ],
);

Future<SettingsProvider> _ayarlar() async {
  SharedPreferences.setMockInitialValues({'language_code': 'tr'});
  final s = SettingsProvider();
  await s.setLocale(const Locale('tr'));
  return s;
}

Widget _kabuk(SettingsProvider s, AuthProvider a, Widget child) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: s),
        ChangeNotifierProvider<AuthProvider>.value(value: a),
      ],
      child: MaterialApp(home: child),
    );

final _scratch = CoursesData.allCourses.firstWhere((c) => c.id == 'scratch');

/// Bekle ve bir kare daha: anlatim adimi tamamlanmayi kareden SONRA
/// bildiriyor; alt cubuk ancak bir sonraki karede aciliyor.
Future<void> _bekle(WidgetTester t, [int ms = 700]) async {
  await t.pump(Duration(milliseconds: ms));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthProvider auth;
  setUpAll(() async {
    SoundService.configure(sound: false);
    // Supabase oturum dinleyicisi app_links akisini aciyor; testte eklenti
    // yok. Kanal sessizce cevaplasin (yoksa hata zamanlamaya bagli olarak
    // bu teste dusuyor).
    for (final kanal in const [
      'com.llfbandit.app_links/events',
      'com.llfbandit.app_links/messages',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(kanal), (_) async => null);
    }
    // AuthProvider Supabase istemcisini kuruyor; gercek sunucuya
    // baglanmiyoruz (bkz. kaldigin_yerden_devam_test.dart).
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
    auth = AuthProvider();
  });

  testWidgets('adim XP yalnizca ilk tamamlanista; Tamamla bir kez; rozet',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final s = await _ayarlar();

    await tester.pumpWidget(_kabuk(s, auth,
        InteractiveLessonScreen(lesson: _ders, course: _scratch)));
    await _bekle(tester);
    expect(find.text('+5'), findsOneWidget, reason: 'Anlatim adimi 5 XP');

    await tester.tap(find.text('Devam'));
    await _bekle(tester);
    await tester.tap(find.text('Doğru seçenek'));
    await _bekle(tester);
    expect(find.text('+15'), findsOneWidget);

    // Geri gel, yeniden ilerle, yeniden cevapla: XP degismiyor.
    await tester.tap(find.text('Önceki'));
    await _bekle(tester);
    expect(find.text('+15'), findsOneWidget);
    await tester.tap(find.text('Devam'));
    await _bekle(tester);
    await tester.tap(find.text('Doğru seçenek'));
    await _bekle(tester);
    expect(find.text('+15'), findsOneWidget,
        reason: 'Ayni adim ikinci kez XP vermemeli.');

    await tester.tap(find.text('Devam'));
    await _bekle(tester);
    final tamamla = find.text('Tamamla');
    expect(tamamla, findsOneWidget);
    // Cift dokunus: ders bir kez kaydediliyor, tek pencere.
    await tester.tap(tamamla);
    await tester.tap(tamamla, warnIfMissed: false);
    // Kayit gercek zamanuyumsuz isler iceriyor (yerel depo).
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await _bekle(tester, 1500);
    expect(find.text('TEBRİKLER!'), findsOneWidget);
    expect(find.text('YENİ ROZET!'), findsOneWidget);
    expect(find.text('Döngü Ustası'), findsOneWidget,
        reason: 'Rozet adi katalogdan gelmeli.');
    expect(auth.tamamlananDersler, contains('odul_denemesi'));

    // TEKRAR: ayni ders yeniden bitirilince "YENI ROZET" yok.
    await tester.pumpWidget(const SizedBox());
    await _bekle(tester, 2000);
    await tester.pumpWidget(_kabuk(s, auth,
        InteractiveLessonScreen(lesson: _ders, course: _scratch)));
    await _bekle(tester);
    await tester.tap(find.text('Devam'));
    await _bekle(tester);
    await tester.tap(find.text('Doğru seçenek'));
    await _bekle(tester);
    await tester.tap(find.text('Devam'));
    await _bekle(tester);
    await tester.tap(find.text('Tamamla'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await _bekle(tester, 1500);
    expect(find.text('TEBRİKLER!'), findsOneWidget);
    expect(find.text('YENİ ROZET!'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await _bekle(tester, 3000);
  });

  testWidgets('coktan secmeli: adim kalkinca gecikmeli bildirim gitmiyor',
      (tester) async {
    final s = await _ayarlar();
    var cagri = 0;
    await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
      value: s,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MultipleChoiceStepWidget(
              step: _ders.steps[1] as MultipleChoiceStep,
              course: _scratch,
              isDark: false,
              onComplete: (_) => cagri++,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.tap(find.text('Doğru seçenek'));
    await tester.pump(const Duration(milliseconds: 100));
    // Cocuk "Onceki"ye basti: adim agactan kalkti.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(cagri, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('blok kurma: dogru dizide bir kez tamamlaniyor, DEVAM ilerletiyor',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final s = await _ayarlar();
    final adim = BlockBuilderStep(
      id: 'kur_denemesi',
      instruction: 'Kur',
      goal: 'Bayrak, git',
      availableBlocks: const [
        ScratchBlock(
            id: 'green_flag',
            blockType: ScratchBlockType.events,
            shape: ScratchBlockShape.cap,
            label: 'bayrak',
            color: Color(0xFFFFBF00)),
        ScratchBlock(
            id: 'move_10',
            blockType: ScratchBlockType.motion,
            shape: ScratchBlockShape.stack,
            label: '10 adım git',
            color: Color(0xFF4C97FF)),
      ],
      correctSequence: const ['green_flag', 'move_10'],
    );
    var tamam = 0;
    var devam = 0;
    final arduino =
        CoursesData.allCourses.firstWhere((c) => c.id == 'arduino');
    await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
      value: s,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BlockBuilderStepWidget(
              step: adim,
              course: arduino,
              isDark: false,
              onComplete: (_) => tamam++,
              onDevam: () => devam++,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    // Palette dokun: once bayrak, sonra git.
    await tester.tap(find.text('bayrak').last);
    await tester.pump();
    await tester.tap(find.text('10 adım git').last);
    await tester.pump();
    expect(tamam, 1, reason: 'Dogru dizi bulununca adim tamamlanmali.');

    await tester.tap(find.text('DEVAM'));
    await tester.pump();
    expect(devam, 1, reason: 'Ic DEVAM dersi ilerletmeli.');
    expect(tamam, 1, reason: 'Ic DEVAM yeniden XP istememeli.');
    await tester.pump(const Duration(seconds: 1));
  });
}

