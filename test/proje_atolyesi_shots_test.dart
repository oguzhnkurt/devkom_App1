@Tags(['shots'])
library;

// Proje Atolyesi ve ic ice tezgah icin onizleme kareleri: ic ice C
// blogu, sayi tus takimi, hedefleri yanan atolye (kalem cizimi),
// Projelerim, 8. modul projesi, sanal Uno'da Hata Avcisi, mBlock
// atolyesi, ilerleyen ipucu.
//
//     flutter test --run-skipped --tags shots test/proje_atolyesi_shots_test.dart
//
// Cikti: /mnt/user-data/outputs/proje_atolyesi/*.png
// (PROJE_ATOLYESI_DIR ile degistirilebilir).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/scratch_atolyeleri.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/mblock_atolye_ekrani.dart';
import 'package:devkom_app/courses/screens/projelerim_ekrani.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_blok_adimi.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_tezgahi.dart';
import 'package:devkom_app/courses/screens/widgets/proje_atolyesi.dart';
import 'package:devkom_app/courses/screens/widgets/scratch_tezgahi.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/courses/sahne/mblock_sahnesi.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/proje_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/mascot.dart';
import 'package:devkom_app/widgets/scratch_blok.dart';

final _dizin = Platform.environment['PROJE_ATOLYESI_DIR'] ??
    '/mnt/user-data/outputs/proje_atolyesi';
final _key = GlobalKey();

final _scratch = CoursesData.byId('scratch')!;
final _mblock = CoursesData.byId('mblock')!;

Future<void> _fontlar() async {
  final n = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    n.addFont(Future.value(
        File('assets/fonts/Nunito-$w.ttf').readAsBytesSync().buffer.asByteData()));
  }
  await n.load();
  final root = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.path;
  final ikon =
      File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (ikon.existsSync()) {
    await (FontLoader('MaterialIcons')
          ..addFont(Future.value(ikon.readAsBytesSync().buffer.asByteData())))
        .load();
  }
}

Future<void> _kur(WidgetTester tester, Widget home,
    {Size boy = const Size(390, 844), AuthProvider? auth}) async {
  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final ayar = SettingsProvider();
  await ayar.setLocale(const Locale('tr'));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: ayar),
      if (auth != null) ChangeNotifierProvider<AuthProvider>.value(value: auth),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr'),
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('es')
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(useMaterial3: true, fontFamily: 'Nunito'),
      builder: (context, child) => RepaintBoundary(key: _key, child: child),
      home: home,
    ),
  ));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.runAsync(() async {
    try {
      await precacheImage(
              const AssetImage(Mascot.durgunGorsel), _key.currentContext!)
          .timeout(const Duration(seconds: 20));
    } catch (_) {}
  });
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _bekle(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _cek(WidgetTester tester, String ad, {double oran = 2}) async {
  await tester.runAsync(() async {
    final b = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: oran);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_dizin).createSync(recursive: true);
    File('$_dizin/$ad.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}

Widget _adimSayfasi(Widget adim) => Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: adim,
        ),
      ),
    );



T _adim<T extends LessonStep>(String kurs, String id) => CourseModules
    .allLessons(kurs)
    .expand((l) => l.steps)
    .firstWhere((s) => s.id == id) as T;

Future<void> _dokun(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 80));
}

/// [f] ekranin ust kismina gelsin.
Future<void> _goster(WidgetTester tester, Finder f, {double ust = 90}) async {
  await tester.ensureVisible(f);
  await tester.pump();
  final y = tester.getTopLeft(f).dy;
  await tester.drag(find.byType(Scrollable).first, Offset(0, ust - y));
  await _bekle(tester, 300);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await _fontlar();
    SoundService.configure(sound: false);
    for (final kanal in const [
      'com.llfbandit.app_links/events',
      'com.llfbandit.app_links/messages',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(kanal), (_) async => null);
    }
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', publishableKey: 'test', debug: false);
  });

  testWidgets('1 ic ice C blogu', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final adim = _adim<BlockBuilderStep>('scratch', 's3_2_build1');
    await _kur(
        tester,
        _adimSayfasi(BlockBuilderStepWidget(
            step: adim, course: _scratch, isDark: false, onComplete: (_) {})),
        boy: const Size(390, 900));
    Future<void> p(String id) =>
        _dokun(tester, find.byKey(ValueKey('palet_$id')));
    await p('green_flag');
    await p('set_time_5');
    await p('repeat_5');
    await p('wait_1s');
    await p('change_time_down');
    await _dokun(tester, find.byKey(const ValueKey('ic_ice_ayak_2')));
    await p('if_time_0');
    await p('say_time_up');
    final st = tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));
    st.calistir();
    await _bekle(tester, 9000);
    await _goster(tester, find.byType(ScratchTezgahi), ust: 40);
    await _bekle(tester, 400);
    await _cek(tester, '1_ic_ice_c_blogu');
    await _kapat(tester);
  });

  testWidgets('2 sayi tus takimi', (tester) async {
    final adim = _adim<BlockBuilderStep>('scratch', 's8_2_ucgen');
    await _kur(
        tester,
        _adimSayfasi(BlockBuilderStepWidget(
            step: adim, course: _scratch, isDark: false, onComplete: (_) {})),
        boy: const Size(390, 844));
    Future<void> p(String id) =>
        _dokun(tester, find.byKey(ValueKey('palet_$id')));
    for (final id in ['green_flag', 'pen_down', 'repeat_4', 'move_100',
      'turn_90']) {
      await p(id);
    }
    final halka = find.byKey(const ValueKey('ic_ice_sayi_4'));
    await _goster(tester, find.byType(ScratchTezgahi), ust: -160);
    await tester.tapAt(tester.getCenter(halka));
    await _bekle(tester, 600);
    await tester.tap(find.byKey(const ValueKey('sayi_tus_1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('sayi_tus_2')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('sayi_tus_0')));
    await _bekle(tester, 300);
    await _cek(tester, '2_sayi_tus_takimi');
    await _kapat(tester);
  });

  Future<void> atolye(WidgetTester tester, ProjeAtolyesiStep a, String ad,
      {double ust = 40, String? kayitAdi}) async {
    await _kur(
        tester,
        _adimSayfasi(ProjeAtolyesiWidget(
          step: a,
          course: _scratch,
          isDark: false,
          lang: 'tr',
          onComplete: (_) {},
          kayitli: KayitliProje(
            id: 'k',
            ad: kayitAdi ?? a.titleFor('tr'),
            kursId: 'scratch',
            adimId: a.id,
            kod: KodYapisi.coz(a.ornekCozum),
            tarih: DateTime(2026, 10, 14),
          ),
        )),
        boy: const Size(390, 1100));
    final st = tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));
    st.calistir();
    await _bekle(tester, 60000);
    await tester.drag(find.byType(Scrollable).first, Offset(0, ust));
    await _bekle(tester, 600);
    await _cek(tester, ad);
    await _kapat(tester);
  }

  testWidgets('3 atolye: hedefler yandi (kalem cizimi)', (tester) async {
    await atolye(tester, ScratchAtolyeleri.cokgenCicegi,
        '3_atolye_hedefler_cicek', kayitAdi: 'Çiçeğim');
  });

  testWidgets('5 modul 8 projesi: yildiz', (tester) async {
    await atolye(tester, ScratchAtolyeleri.yildizCiz, '5_modul8_yildiz',
        kayitAdi: 'Yıldızım');
  });

  testWidgets('4 Projelerim', (tester) async {
    String p(String id, String ad, String adim, int gun, String kod) =>
        '{"id":"$id","ad":"$ad","kurs":"scratch","adim":"$adim",'
        '"kod":${'[${KodYapisi.coz(kod).map((o) => '{"id":"${o.id}"${o.deger == null ? '' : ',"d":${o.deger}'}}').join(',')}]'},'
        '"t":${DateTime(2026, 10, gun).millisecondsSinceEpoch}}';
    SharedPreferences.setMockInitialValues({
      'language_code': 'tr',
      ProjeDeposu.anahtar: '[${[
        p('a', 'Yıldızım', 's8_2_atolye', 14, ScratchAtolyeleri.yildizCiz.ornekCozum),
        p('b', 'Zar oyunum', 's9_2_atolye', 13, ScratchAtolyeleri.zarOyunu.ornekCozum),
        p('c', 'Çiçeğim', 's11_2_atolye', 12, ScratchAtolyeleri.cokgenCicegi.ornekCozum),
        p('d', 'Dans partisi', 's6_1_atolye', 9, ScratchAtolyeleri.dansPartisi.ornekCozum),
      ].join(',')}]',
    });
    await _kur(tester, ProjelerimEkrani(course: _scratch));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await _bekle(tester, 600);
    await _cek(tester, '4_projelerim');
    await _kapat(tester);
  });

  group('mBlock (tezgah onizlemede)', () {
    setUp(() => MBlockTezgahi.webviewsiz = true);
    tearDown(() => MBlockTezgahi.webviewsiz = false);

    testWidgets('6 hata avcisi: sanal Uno', (tester) async {
      final adim = _adim<BlockBuilderStep>('mblock', 'm2_2_hata');
      await _kur(
          tester,
          _adimSayfasi(MBlockBlokAdimi(
            step: adim,
            ayar: adim.mblock!,
            course: _mblock,
            isDark: false,
            onComplete: (_) {},
          )),
          boy: const Size(390, 1250));
      final s =
          tester.state<MBlockBlokAdimiState>(find.byType(MBlockBlokAdimi));
      s.yalnizCalistir();
      await _bekle(tester, 2500);
      await _cek(tester, '6_hata_avcisi_uno');
      await _kapat(tester);
    });

    testWidgets('7 mBlock atolyesi', (tester) async {
      await _kur(tester, MBlockAtolyeEkrani(course: _mblock),
          boy: const Size(390, 1100));
      final s = tester
          .state<MBlockAtolyeEkraniState>(find.byType(MBlockAtolyeEkrani));
      final bariyer = _adim<BlockBuilderStep>('mblock', 'm4_2_build1');
      s.durumVer([mblockCozumProgrami(bariyer.mblock!.cozum, 'tr')]);
      await tester.pump();
      final sahne =
          tester.state<MBlockSahnesiState>(find.byType(MBlockSahnesi));
      sahne.unoKarti.mesafe = 12;
      s.calistir();
      await _bekle(tester, 2500);
      await _cek(tester, '7_mblock_atolyesi');
      sahne.durdur();
      await _kapat(tester);
    });
  });

  testWidgets('8 ilerleyen ipucu', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    final adim = _adim<BlockBuilderStep>('scratch', 's9_2_build1');
    await _kur(
        tester,
        _adimSayfasi(BlockBuilderStepWidget(
            step: adim, course: _scratch, isDark: false, onComplete: (_) {})),
        boy: const Size(390, 1300));
    Finder blok(String id) =>
        find.byWidgetPredicate((w) => w is ScratchBlok && w.kimlik == id);
    await _dokun(tester, blok('green_flag').first);
    for (var i = 0; i < 4; i++) {
      await _dokun(tester, blok('say_keep_going').first);
      await _dokun(tester, blok('if_score_low').first);
      await _bekle(tester, 300);
      if (i < 3) {
        await _dokun(tester, blok('if_score_low').last);
        await _dokun(tester, blok('say_keep_going').last);
      }
    }
    await _goster(tester, find.byType(IlerleyenIpucu), ust: 250);
    await _bekle(tester, 800);
    await _cek(tester, '8_ilerleyen_ipucu');
    await _kapat(tester);
  });
}
