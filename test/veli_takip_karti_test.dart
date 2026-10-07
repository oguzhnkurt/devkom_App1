import 'dart:io';

import 'package:devkom_app/models/user_progress_model.dart';
import 'package:devkom_app/screens/parent/cocuk_raporu_screen.dart';
import 'package:devkom_app/services/child_link_service.dart';
import 'package:devkom_app/services/cocuk_raporu.dart';
import 'package:devkom_app/services/progress_report_service.dart';
import 'package:devkom_app/widgets/veli_takip_karti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Profildeki veli karti: kodu yaz, bitti.

List<DayActivity> _gunler() {
  final bugun = DateTime.now();
  final b = DateTime(bugun.year, bugun.month, bugun.day);
  return [
    for (var i = 0; i < 14; i++)
      DayActivity(
        day: b.subtract(Duration(days: 13 - i)),
        xp: i >= 10 ? 20 : 0,
        lessons: i == 13 ? 1 : 0,
        quizzes: 0,
        videos: 0,
      ),
  ];
}

Future<CocukRaporu> _sahteRapor(ChildLink c) async => CocukRaporu(
      ad: c.childName,
      ilerleme: UserProgress.empty(c.childId)
          .copyWith(completedLessonIds: ['scratch_1_1'], totalXP: 80, level: 2),
      gunler: _gunler(),
    );

Widget _uygulama(Widget child) => MaterialApp(
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void _uzunEkran(WidgetTester tester) {
  tester.view.physicalSize = const Size(430 * 2, 2600 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('cocuk yokken kod alani var; 6 karakter yazilinca kendiliginden baglaniyor',
      (tester) async {
    _uzunEkran(tester);
    final kullanilan = <String>[];
    var bagli = <ChildLink>[];
    await tester.pumpWidget(_uygulama(VeliTakipKarti(
      cocuklariGetir: () async => bagli,
      kodKullan: (k) async {
        kullanilan.add(k);
        bagli = [const ChildLink(childId: 'c1', childName: 'Ada')];
        return 'c1';
      },
      raporYukle: _sahteRapor,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Çocuğumu takip et'), findsOneWidget);
    expect(find.byKey(const ValueKey('veli_kod_alani')), findsOneWidget);
    // Dogum yili ya da baska bir soru yok.
    expect(find.textContaining('doğum'), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('veli_kod_alani')), 'abc12');
    await tester.pump();
    expect(find.text('ABC-12'), findsOneWidget, reason: 'tire kendiliginden');
    expect(kullanilan, isEmpty, reason: 'eksik kodla denenmemeli');

    await tester.enterText(find.byKey(const ValueKey('veli_kod_alani')), 'abc-123');
    await tester.pumpAndSettle();

    expect(kullanilan, ['ABC123']);
    // Rapor dogrudan acildi.
    expect(find.byType(CocukRaporuScreen), findsOneWidget);
    expect(find.text('Ada'), findsWidgets);
    expect(find.text('Güzel haberler'), findsOneWidget);
  });

  testWidgets('yanlis kod nazik bir hata gosteriyor ve ekranda kaliyor', (tester) async {
    await tester.pumpWidget(_uygulama(VeliTakipKarti(
      cocuklariGetir: () async => const [],
      kodKullan: (_) async => null,
      raporYukle: _sahteRapor,
    )));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('veli_kod_alani')), 'ZZZ999');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('veli_kod_hata')), findsOneWidget);
    expect(find.textContaining('24 saat'), findsOneWidget);
    expect(find.byType(CocukRaporuScreen), findsNothing);
  });

  testWidgets('birden fazla cocuk listeleniyor; yenisi eklenebiliyor', (tester) async {
    var bagli = const [
      ChildLink(childId: 'c1', childName: 'Ada'),
      ChildLink(childId: 'c2', childName: 'Can'),
    ];
    await tester.pumpWidget(_uygulama(VeliTakipKarti(
      cocuklariGetir: () async => bagli,
      kodKullan: (k) async {
        bagli = [...bagli, const ChildLink(childId: 'c3', childName: 'Ece')];
        return 'c3';
      },
      raporYukle: _sahteRapor,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Can'), findsOneWidget);
    // Cocuk varken kod alani gizli, "Baska bir cocuk ekle" var.
    expect(find.byKey(const ValueKey('veli_kod_alani')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('baska_cocuk_ekle')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('veli_kod_alani')), 'QWE234');
    await tester.pumpAndSettle();

    // Ece'nin raporu acildi; geri donunce uc cocuk listede.
    expect(find.byType(CocukRaporuScreen), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('Ece'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Can'), findsOneWidget);

    // Bir cocuga dokununca ONUN raporu.
    await tester.tap(find.byKey(const ValueKey('cocuk_c2')));
    await tester.pumpAndSettle();
    expect(find.descendant(
            of: find.byKey(const ValueKey('rapor_ust')), matching: find.text('Can')),
        findsOneWidget);
  });

  testWidgets('rapor ekrani: bolumler ve listeden kaldirma', (tester) async {
    _uzunEkran(tester);
    String? kaldirilan;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Builder(
        builder: (c) => TextButton(
          onPressed: () => Navigator.push(
            c,
            MaterialPageRoute(
              builder: (_) => CocukRaporuScreen(
                cocuk: const ChildLink(childId: 'c1', childName: 'Ada'),
                yukleyici: _sahteRapor,
                bagiKaldir: (id) async => kaldirilan = id,
              ),
            ),
          ),
          child: const Text('ac'),
        ),
      ),
    ));
    await tester.tap(find.text('ac'));
    await tester.pumpAndSettle();

    for (final k in ['rapor_ust', 'rapor_son7', 'rapor_gunler', 'rapor_haberler']) {
      expect(find.byKey(ValueKey(k)), findsOneWidget, reason: k);
    }
    // Son 7 gun: 4 gun calisti (indeks 10-13).
    expect(find.text('4/7'), findsOneWidget);
    expect(find.text('Ada son 7 günde 4 gün çalıştı.'), findsOneWidget);

    final liste = find.byKey(const ValueKey('cocuk_raporu_liste'));
    await tester.scrollUntilVisible(find.byKey(const ValueKey('rapor_kaldir')), 300,
        scrollable: find.descendant(of: liste, matching: find.byType(Scrollable)).first);
    expect(find.byKey(const ValueKey('rapor_kurslar')), findsOneWidget);
    expect(find.byKey(const ValueKey('rapor_sohbet')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rapor_kaldir')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaldır'));
    await tester.pumpAndSettle();
    expect(kaldirilan, 'c1');
    expect(find.byType(CocukRaporuScreen), findsNothing);
  });

  testWidgets('ilerleme okunamazsa durust not, bos kurs karti yok', (tester) async {
    await tester.pumpWidget(_uygulama(SizedBox(
      height: 2000,
      child: CocukRaporuScreen(
        cocuk: const ChildLink(childId: 'c1'),
        yukleyici: (c) async =>
            CocukRaporu(ad: null, ilerleme: null, gunler: _gunler()),
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Çocuğunuz'), findsOneWidget);
    expect(find.byKey(const ValueKey('rapor_kurslar')), findsNothing);
    final liste = find.byKey(const ValueKey('cocuk_raporu_liste'));
    await tester.scrollUntilVisible(find.byKey(const ValueKey('rapor_not')), 300,
        scrollable: find.descendant(of: liste, matching: find.byType(Scrollable)).first);
    expect(find.byKey(const ValueKey('rapor_not')), findsOneWidget);
  });

  group('kaynak', () {
    test('profilde, ilerlemeni kaydet kartinin USTUNDE', () {
      final s = File('lib/screens/auth/profile_screen.dart').readAsStringSync();
      final kart = s.indexOf('const VeliTakipKarti()');
      final kaydet = s.indexOf('_buildSaveProgressCard(context),');
      expect(kart, isNot(-1));
      expect(kart, lessThan(kaydet));
    });

    test('kartta ebeveyn kapisi (dogum yili) yok', () {
      final s = File('lib/widgets/veli_takip_karti.dart').readAsStringSync();
      expect(s.contains('ParentGate'), isFalse);
    });

    test('veli raporu cocugun verisine YAZMIYOR', () {
      for (final f in [
        'lib/screens/parent/cocuk_raporu_screen.dart',
        'lib/services/cocuk_raporu_kaynagi.dart',
        'lib/screens/parent/parent_area_screen.dart',
      ]) {
        // Yorum satirlari haric (yorumlar eski hatayi anlatiyor).
        final s = File(f)
            .readAsLinesSync()
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        expect(s.contains('loadUserProgress'), isFalse, reason: f);
        expect(s.contains('.update('), isFalse, reason: f);
        expect(s.contains('.insert('), isFalse, reason: f);
      }
    });

    test('ders bitince dersin kimligi kaydediliyor', () {
      // Eskiden ders ekranlari yalnizca XP veriyordu; completed_lesson_ids
      // hic yazilmiyordu ve veli raporunda dersler hep sifirdi.
      for (final f in [
        'lib/courses/screens/interactive_lesson_screen.dart',
        'lib/courses/screens/lesson_screen.dart',
      ]) {
        final s = File(f).readAsStringSync();
        expect(s.contains('dersTamamlandi(widget.lesson.id'), isTrue, reason: f);
      }
      final servis =
          File('lib/services/user_progress_service.dart').readAsStringSync();
      expect(servis.contains("source: yeni ? 'lesson' : 'lesson_tekrar'"), isTrue);
    });

    test('quizler gunluk kirilimda quiz olarak sayiliyor', () {
      for (final f in [
        'lib/courses/screens/quiz_screen.dart',
        'lib/courses/screens/module_quiz_screen.dart',
      ]) {
        expect(File(f).readAsStringSync().contains("source: 'quiz'"), isTrue,
            reason: f);
      }
    });

    test('ebeveyn okuma politikasi once kontrol ederek kuruluyor', () {
      final sql =
          File('supabase/migrations/35_veli_ilerleme_okuma.sql').readAsStringSync();
      expect(sql.contains('is_linked_parent(user_id)'), isTrue);
      expect(sql.contains('if not exists'), isTrue);
      expect(sql.contains('for select'), isTrue);
      expect(RegExp(r'for (update|insert|delete|all)').hasMatch(sql), isFalse);
    });
  });
}
