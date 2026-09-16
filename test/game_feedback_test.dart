import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/learning/how_to_play_demo.dart';
import 'package:devkom_app/widgets/learning/success_burst.dart';

/// Oyunlardaki geri bildirim parcalari.
///
/// Burada olculen sey "guzel gorunuyor mu" degil — o goze bakar. Olculen
/// sey su: gosterim CIZILEBILIYOR mu, bir kere gosterildikten sonra
/// TEKRAR ACILMIYOR mu, ve ses ayari kapaliyken servis gercekten susuyor
/// mu. Ucu de sessizce bozulabilecek seyler.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.configure(sound: true, vibration: true);
  });

  HowToPlayDemo demo() => const HowToPlayDemo(
        title: 'Nasil oynanir',
        hint: 'Soldakine dokun, sonra sagdaki dogru karsiligina dokun.',
        sourceLabel: 'Robot',
        targetLabel: 'Robot',
        decoyLabel: 'Sensor',
        startLabel: 'Basla',
      );

  group('HowToPlayDemo', () {
    testWidgets('cizilir ve baslat tusu gosterir', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: demo())));
      await tester.pump();
      expect(find.text('Nasil oynanir'), findsOneWidget);
      expect(find.text('Basla'), findsOneWidget);
      // Kaynak, hedef ve yanlis secenek birlikte duruyor: cocuk "dogru
      // olani sec" mesajini ancak yanlis secenek de ekrandaysa alir.
      expect(find.text('Robot'), findsNWidgets(2));
      expect(find.text('Sensor'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('bir tur boyunca coker mi', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: demo())));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    test('gorulme kaydi yazilir ve okunur', () async {
      expect(await HowToPlayDemo.seen('word_match'), isFalse);
      await HowToPlayDemo.markSeen('word_match');
      expect(await HowToPlayDemo.seen('word_match'), isTrue);
      // Oyunlar birbirinin kaydini paylasmiyor.
      expect(await HowToPlayDemo.seen('sequencing'), isFalse);
    });

    testWidgets('ikinci acilista gosterim cikmaz, force ile cikar',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (c) {
          ctx = c;
          return const Scaffold();
        }),
      ));

      // DIKKAT: maybeShow'u `await` ETMIYORUZ. Donen future, gosterim
      // kapanana kadar tamamlanmiyor; testte beklersek kilitleniyoruz.
      unawaited(HowToPlayDemo.maybeShow(ctx, gameKey: 'g1', demo: demo()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Basla'), findsOneWidget);

      await tester.tap(find.text('Basla'));
      await tester.pumpAndSettle();
      expect(find.text('Basla'), findsNothing);
      // Kapanis, "izlendi" kaydinin yazilmasini bekliyor.
      await tester.idle();
      await tester.pump();

      // Ikinci kez: kayit var, hic acilmamali.
      unawaited(HowToPlayDemo.maybeShow(ctx, gameKey: 'g1', demo: demo()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Basla'), findsNothing);

      // "?" tusu (force) kaydi yok sayar.
      unawaited(HowToPlayDemo.maybeShow(ctx,
          gameKey: 'g1', demo: demo(), force: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Basla'), findsOneWidget);

      await tester.tap(find.text('Basla'));
      await tester.pumpAndSettle();
    });
  });

  group('SuccessBurst', () {
    testWidgets('kendini oynatir ve bitince haber verir', (tester) async {
      var done = false;
      await tester.pumpWidget(MaterialApp(
        home: Stack(children: [
          SuccessBurst(
            center: const Offset(100, 100),
            onDone: () => done = true,
          ),
        ]),
      ));
      await tester.pumpAndSettle();
      expect(done, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('SoundService ayarlari', () {
    test('ses ve titresim ayri ayri kapanir', () {
      SoundService.configure(sound: false);
      expect(SoundService.soundEnabled, isFalse);
      expect(SoundService.vibrationEnabled, isTrue);

      SoundService.configure(vibration: false);
      expect(SoundService.vibrationEnabled, isFalse);

      SoundService.configure(sound: true, vibration: true);
      expect(SoundService.soundEnabled, isTrue);
      expect(SoundService.vibrationEnabled, isTrue);
    });

    test('ses kapaliyken calma cagrisi sessizce doner', () async {
      SoundService.configure(sound: false, vibration: false);
      // Test ortaminda ses eklentisi yok; kapaliyken hic dokunmadigi icin
      // bu cagri hatasiz tamamlanmali.
      await SoundService.playCorrect();
      await SoundService.playWrong();
      await SoundService.playDrop();
    });
  });
}
