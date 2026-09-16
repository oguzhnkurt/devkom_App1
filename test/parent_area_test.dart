import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/services/progress_report_service.dart';
import 'package:devkom_app/services/weekly_goal_service.dart';
import 'package:devkom_app/widgets/parent_gate.dart';

/// Ebeveyn alaninin mantigi.
///
/// Buradaki uc sey de sessizce yanlis olabilecek seyler: kapi acilir
/// ama korumaz, haftalik sayim gecen haftanin derslerini de sayar,
/// hedef kaydedilmez. Ucu de ekranda hicbir sey kirmaz.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('ParentGate', () {
    Future<void> pump(WidgetTester tester, ValueChanged<bool> onResult) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async =>
                    onResult(await ParentGate.verify(context)),
                child: const Text('aç'),
              ),
            ),
          ),
        ),
      ));
    }

    testWidgets('makul bir ebeveyn dogum yili kapiyi acar', (tester) async {
      bool? result;
      await pump(tester, (r) => result = r);
      await tester.tap(find.text('aç'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '1985');
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('cocugun kendi dogum yili kapiyi ACMAZ', (tester) async {
      // Kapinin butun anlami bu. Hedef kitlemiz 7-14 yas; bir cocuk
      // panige kapilinca once kendi dogum yilini dener.
      final childYear = DateTime.now().year - 11;
      bool? result;
      await pump(tester, (r) => result = r);
      await tester.tap(find.text('aç'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '$childYear');
      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();

      expect(result, isNull, reason: 'kapi acilmamali');
      expect(find.textContaining('doğum yılı gibi görünmüyor'), findsOneWidget);
    });

    testWidgets('sacma degerler kapiyi acmaz', (tester) async {
      for (final input in ['0', '9999', '2030', '1']) {
        bool? result;
        await pump(tester, (r) => result = r);
        await tester.tap(find.text('aç'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), input);
        await tester.tap(find.text('Devam'));
        await tester.pumpAndSettle();
        expect(result, isNull, reason: '$input kapiyi acmamali');
        await tester.tap(find.text('Vazgeç'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('girilen yilin saklanmadigi ekranda yaziyor', (tester) async {
      // Ebeveynden dogum yili istemek aciklama gerektiriyor; bu cumle
      // urunun bir parcasi, susleme degil.
      await pump(tester, (_) {});
      await tester.tap(find.text('aç'));
      await tester.pumpAndSettle();
      expect(find.textContaining('kaydedilmiyor'), findsOneWidget);
    });
  });

  group('WeeklyGoalService', () {
    test('hedef kaydedilir ve okunur', () async {
      expect(await WeeklyGoalService.target(), WeeklyGoalService.defaultTarget);
      await WeeklyGoalService.setTarget(3);
      expect(await WeeklyGoalService.target(), 3);
    });

    test('hafta pazartesi baslar', () {
      // 2026-09-08 bir sali. Haftanin basi 7 Eylul pazartesi olmali.
      final start = WeeklyGoalService.weekStart(DateTime(2026, 9, 8, 15, 30));
      expect(start, DateTime(2026, 9, 7));
      expect(start.weekday, DateTime.monday);

      // Pazar gunu hala AYNI haftaya ait olmali.
      final sunday = WeeklyGoalService.weekStart(DateTime(2026, 9, 13, 23, 59));
      expect(sunday, DateTime(2026, 9, 7));
    });

    test('sadece bu haftanin dersleri sayilir', () {
      final now = DateTime(2026, 9, 10); // persembe
      DayActivity day(int d, int lessons) => DayActivity(
            day: DateTime(2026, 9, d),
            xp: lessons * 10,
            lessons: lessons,
            quizzes: 0,
            videos: 0,
          );

      final state = WeeklyGoalService.stateFrom(
        [
          day(4, 5), // gecen hafta cuma — sayilmamali
          day(6, 3), // gecen hafta pazar — sayilmamali
          day(7, 2), // bu hafta pazartesi
          day(9, 1), // bu hafta carsamba
        ],
        4,
        now: now,
      );

      expect(state.done, 3, reason: 'gecen haftanin dersleri sayilmamali');
      expect(state.activeDays, 2);
      expect(state.remaining, 1);
      expect(state.reached, isFalse);
    });

    test('hedefe ulasinca ulasildi der ve kalan sifirlanir', () {
      final state = WeeklyGoalService.stateFrom(
        [
          DayActivity(
            day: DateTime(2026, 9, 8),
            xp: 60,
            lessons: 6,
            quizzes: 0,
            videos: 0,
          ),
        ],
        4,
        now: DateTime(2026, 9, 10),
      );
      expect(state.reached, isTrue);
      expect(state.remaining, 0);
      // Oran 1'i asmamali; ilerleme cubugu tasar.
      expect(state.ratio, 1.0);
    });

    test('bos hafta cokmez', () {
      final state = WeeklyGoalService.stateFrom(const [], 4);
      expect(state.done, 0);
      expect(state.ratio, 0);
      expect(state.reached, isFalse);
    });
  });
}
