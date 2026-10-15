// IC ICE TEZGAH, SAYI TUS TAKIMI, PROJE ATOLYESI, PROJELERIM, HATA
// AVCISI ve mBLOCK ATOLYESI — ekranda.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/scratch_atolyeleri.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/mblock_atolye_ekrani.dart';
import 'package:devkom_app/courses/screens/projelerim_ekrani.dart';
import 'package:devkom_app/courses/screens/widgets/ic_ice_blok_adimi.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_blok_adimi.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_tezgahi.dart';
import 'package:devkom_app/courses/screens/widgets/proje_atolyesi.dart';
import 'package:devkom_app/courses/screens/widgets/scratch_tezgahi.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/courses/sahne/mblock_sahnesi.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/proje_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';

final _scratch = CoursesData.byId('scratch')!;
final _mblock = CoursesData.byId('mblock')!;

T _adim<T extends LessonStep>(String kurs, String id) => CourseModules
    .allLessons(kurs)
    .expand((l) => l.steps)
    .firstWhere((s) => s.id == id) as T;

late SettingsProvider _ayar;

Future<void> _ac(WidgetTester tester, Widget w,
    {double yukseklik = 2600, bool sayfa = true}) async {
  tester.view.physicalSize = Size(390 * 3, yukseklik * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: _ayar,
    child: MaterialApp(
      home: sayfa
          ? Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: w,
              ),
            )
          : w,
    ),
  ));
  await tester.pump();
}

Future<void> _bekle(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _dokun(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  setUpAll(() async {
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    _ayar = SettingsProvider();
    await _ayar.setLocale(const Locale('tr'));
  });

  group('ic ice blok adimi', () {
    testWidgets('3.2 geri sayim: dongunun ICI ve SONRASI dokunarak kuruluyor',
        (tester) async {
      final adim = _adim<BlockBuilderStep>('scratch', 's3_2_build1');
      bool? tamam;
      await _ac(
          tester,
          BlockBuilderStepWidget(
              step: adim,
              course: _scratch,
              isDark: false,
              onComplete: (c) => tamam = c));
      expect(find.byType(IcIceBlokAdimi), findsOneWidget,
          reason: 'yapi verilen adim ic ice tezgahla aciliyor');

      Future<void> palet(String id) =>
          _dokun(tester, find.byKey(ValueKey('palet_$id')));

      await palet('green_flag');
      await palet('set_time_5');
      await palet('repeat_5'); // imlec agzin icine geciyor
      await palet('wait_1s');
      await palet('change_time_down');
      // Ayaga dokun: imlec donguden SONRAYA.
      await _dokun(tester, find.byKey(const ValueKey('ic_ice_ayak_2')));
      await palet('if_time_0');
      await palet('say_time_up');
      await tester.pump(const Duration(milliseconds: 300));
      expect(tamam, isTrue);
      expect(find.textContaining('Her blok doğru yerde'), findsOneWidget);

      // Calistir: sure sifira iniyor, "Sure bitti!" BIR kez.
      final st = tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));
      expect(KodYapisi.imza(st.kod),
          KodYapisi.duzle(adim.yapi!));
      await _kapat(tester);
    });

    testWidgets('yanlis yapi: iki yanlista ipucu, dortte cozum', (tester) async {
      final adim = _adim<BlockBuilderStep>('scratch', 's3_2_build1');
      await _ac(
          tester,
          BlockBuilderStepWidget(
              step: adim, course: _scratch, isDark: false, onComplete: (_) {}));
      Future<void> palet(String id) =>
          _dokun(tester, find.byKey(ValueKey('palet_$id')));
      // Her sey dongunun icinde (ayaga dokunmadan): yanlis.
      for (final id in [
        'green_flag',
        'set_time_5',
        'repeat_5',
        'wait_1s',
        'change_time_down',
        'if_time_0',
        'say_time_up',
      ]) {
        await palet(id);
      }
      expect(find.byKey(const ValueKey('ic_ice_yanlis')), findsOneWidget);
      expect(find.byType(IlerleyenIpucu), findsOneWidget);
      expect(find.byKey(const ValueKey('ipucu_1')), findsNothing);
      // Son blogu cikarip yeniden ekle: ikinci yanlis.
      final st = tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));
      Future<void> yenidenDene() async {
        final son = st.kod.lastIndexWhere((o) => o.id == 'say_time_up');
        // Sil: blogun sag ucundaki "x".
        final f = find.byKey(ValueKey('ic_ice_blok_$son'));
        await tester.ensureVisible(f);
        final r = tester.getRect(f);
        await tester.tapAt(Offset(r.right - 6, r.center.dy));
        await tester.pump(const Duration(milliseconds: 50));
        await palet('say_time_up');
      }

      await yenidenDene();
      expect(find.byKey(const ValueKey('ipucu_1')), findsOneWidget);
      expect(find.textContaining('döngünün ayağının ALTINDA'), findsOneWidget);
      await yenidenDene();
      await yenidenDene();
      expect(find.byKey(const ValueKey('ipucu_cozum')), findsOneWidget);
      expect(find.byKey(const ValueKey('ipucu_cozum_satirlari')), findsOneWidget);
      await _kapat(tester);
    });

    testWidgets('ucgen: sayi tus takimiyla 4 -> 3, 90 -> 120; sonuc denetimi',
        (tester) async {
      final adim = _adim<BlockBuilderStep>('scratch', 's8_2_ucgen');
      bool? tamam;
      await _ac(
          tester,
          BlockBuilderStepWidget(
              step: adim,
              course: _scratch,
              isDark: false,
              onComplete: (c) => tamam = c));
      Future<void> palet(String id) =>
          _dokun(tester, find.byKey(ValueKey('palet_$id')));
      await palet('green_flag');
      await palet('pen_down');
      await palet('repeat_4');
      await palet('move_100');
      await palet('turn_90');

      Future<void> sayiYaz(int sira, String sayi) async {
        final halka = find.byKey(ValueKey('ic_ice_sayi_$sira'));
        expect(halka, findsOneWidget);
        await tester.ensureVisible(halka);
        await tester.tapAt(tester.getCenter(halka));
        await _bekle(tester, 700);
        expect(find.byKey(const ValueKey('sayi_gostergesi')), findsOneWidget);
        for (final r in sayi.split('')) {
          await tester.tap(find.byKey(ValueKey('sayi_tus_$r')));
          await tester.pump();
        }
        await tester.tap(find.byKey(const ValueKey('sayi_tamam')));
        await _bekle(tester, 700);
      }

      await sayiYaz(2, '3');
      await sayiYaz(4, '120');
      final st = tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));
      expect(st.kod[2].deger, 3);
      expect(st.kod[4].deger, 120);
      expect(find.text('3 defa tekrarla'), findsNothing,
          reason: 'blok metni kod alaninda cizimle; duz metin degil');

      // Calistir; sahne bitince hedef tutuyor.
      st.calistir();
      await _bekle(tester, 12000);
      expect(tamam, isTrue);
      await _kapat(tester);
    });
  });

  group('proje atolyesi', () {
    testWidgets('kayitli projeyle acilip calisinca hedefler yaniyor; XP bir '
        'kez; kaydet Projelerim\'e yaziyor', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': 'tr'});
      final atolye = ScratchAtolyeleri.yildizCiz;
      final sonuclar = <bool>[];
      await _ac(
        tester,
        ProjeAtolyesiWidget(
          step: atolye,
          course: _scratch,
          isDark: false,
          lang: 'tr',
          onComplete: sonuclar.add,
          kayitli: KayitliProje(
            id: 'x',
            ad: 'Yıldızım',
            kursId: 'scratch',
            adimId: atolye.id,
            kod: KodYapisi.coz(atolye.ornekCozum),
            tarih: DateTime(2026, 10, 1),
          ),
        ),
      );
      expect(find.text('0/3'), findsOneWidget);
      final st = tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));
      st.calistir();
      await _bekle(tester, 400);
      expect(find.text('0/3'), findsOneWidget,
          reason: 'tikler oynatma bitince yaniyor');
      await _bekle(tester, 20000);
      expect(find.text('3/3'), findsOneWidget);
      expect(find.byKey(const ValueKey('atolye_basari')), findsOneWidget);
      expect(sonuclar, [true]);

      // Yeniden calistirmak yeniden XP vermiyor.
      st.calistir();
      await _bekle(tester, 20000);
      expect(sonuclar, [true]);

      // Kaydet.
      await _dokun(tester, find.byKey(const ValueKey('atolye_kaydet')));
      await _bekle(tester, 700);
      await tester.tap(find.byKey(const ValueKey('proje_kaydet_onay')));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await _bekle(tester, 700);
      final kayitlar = await tester.runAsync(ProjeDeposu.tumu);
      expect(kayitlar!.single.ad, 'Yıldızım');
      expect(kayitlar.single.kod[3].deger, 5);
      await _kapat(tester);
    });

    testWidgets('yanlis kod: hedefler yanmiyor, iki denemede ipucu',
        (tester) async {
      final atolye = ScratchAtolyeleri.yildizToplayici;
      final sonuclar = <bool>[];
      await _ac(
        tester,
        ProjeAtolyesiWidget(
          step: atolye,
          course: _scratch,
          isDark: false,
          lang: 'tr',
          onComplete: sonuclar.add,
          kayitli: KayitliProje(
            id: 'y',
            ad: 'Yanlış',
            kursId: 'scratch',
            adimId: atolye.id,
            kod: KodYapisi.coz('green_flag set_score_0 repeat_5 change_score }'),
            tarih: DateTime(2026, 10, 1),
          ),
        ),
      );
      final st = tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));
      for (var i = 0; i < 2; i++) {
        st.calistir();
        await _bekle(tester, 12000);
      }
      expect(find.text('1/3'), findsOneWidget);
      expect(sonuclar, isEmpty);
      expect(find.byKey(const ValueKey('ipucu_1')), findsOneWidget);
      await _kapat(tester);
    });

    testWidgets('Projelerim listeliyor, aciyor, siliyor', (tester) async {
      SharedPreferences.setMockInitialValues({
        'language_code': 'tr',
        ProjeDeposu.anahtar:
            '[{"id":"a","ad":"Yıldızım","kurs":"scratch","adim":"s8_2_atolye",'
                '"kod":[{"id":"green_flag"}],"t":1760000000000},'
                '{"id":"b","ad":"Zar oyunum","kurs":"scratch","adim":"s9_2_atolye",'
                '"kod":[{"id":"green_flag"}],"t":1760100000000}]'
      });
      await _ac(tester, ProjelerimEkrani(course: _scratch), sayfa: false);
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      expect(find.text('Yıldızım'), findsOneWidget);
      expect(find.text('Zar oyunum'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('proje_a')));
      await _bekle(tester, 700);
      expect(find.byType(ProjeAtolyesiWidget), findsOneWidget);
      expect(find.textContaining('Yıldız Çiz'), findsWidgets);
      await tester.pageBack();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await _bekle(tester, 700);

      await tester.tap(find.byKey(const ValueKey('proje_sil_b')));
      await _bekle(tester, 700);
      await tester.tap(find.byKey(const ValueKey('proje_sil_onay')));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await _bekle(tester, 700);
      expect(find.text('Zar oyunum'), findsNothing);
      await _kapat(tester);
    });
  });

  group('mBlock', () {
    setUp(() => MBlockTezgahi.webviewsiz = true);
    tearDown(() => MBlockTezgahi.webviewsiz = false);

    testWidgets('Hata Avcisi: hazir program calisiyor (LED hep yanik), '
        'duzeltilince dogru', (tester) async {
      final adim = _adim<BlockBuilderStep>('mblock', 'm2_2_hata');
      final sonuclar = <bool>[];
      await _ac(
          tester,
          MBlockBlokAdimi(
            step: adim,
            ayar: adim.mblock!,
            course: _mblock,
            isDark: false,
            onComplete: sonuclar.add,
          ));
      expect(find.byKey(const ValueKey('mblock_hata_avcisi')), findsOneWidget);
      await _dokun(
          tester, find.byKey(const ValueKey('mblock_hatali_calistir')));
      await tester.pump(const Duration(milliseconds: 100));
      final sahne =
          tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
      // Hata: sondurdukten sonra beklemiyor; LED neredeyse hep yanik.
      var yanik = 0;
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (sahne.unoKarti.parlaklik(9) == 1) yanik++;
      }
      expect(yanik, greaterThanOrEqualTo(18));
      expect(sonuclar, isEmpty, reason: 'calistirmak denetim degil');

      final s =
          tester.state<MBlockBlokAdimiState>(find.byType(MBlockBlokAdimi));
      s.durumVer([mblockCozumProgrami(adim.mblock!.cozum, 'tr')]);
      await tester.pump();
      s.kontrolEt();
      await tester.pump(const Duration(milliseconds: 700));
      expect(sonuclar, [true]);
      await _kapat(tester);
    });

    testWidgets('mBlock atolyesi: Uno programi sanal Uno\'da calisiyor',
        (tester) async {
      await _ac(tester, MBlockAtolyeEkrani(course: _mblock), sayfa: false);
      final s = tester
          .state<MBlockAtolyeEkraniState>(find.byType(MBlockAtolyeEkrani));
      final park = _adim<BlockBuilderStep>('mblock', 'm4_1_build1');
      s.durumVer([mblockCozumProgrami(park.mblock!.cozum, 'tr')]);
      await tester.pump();
      expect(find.byKey(const ValueKey('mblock_kart_sahnesi')), findsOneWidget);
      final sahne =
          tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
      sahne.unoKarti.mesafe = 10;
      s.calistir();
      var calan = false;
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (sahne.unoKarti.dijital[8] == true) calan = true;
      }
      expect(calan, isTrue, reason: 'yakin engel: buzzer otuyor');
      sahne.durdur();
      await _kapat(tester);
    });
  });
}
