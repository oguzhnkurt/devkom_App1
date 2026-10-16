@Tags(['shots'])
library;

// Gunluk sandik (ana sayfa) ve el emojisiz Devi tanismasi icin onizleme
// kareleri — TEST DEGIL, ARAC.
//
//     flutter test --run-skipped --tags shots test/gunluk_sandik_shots_test.dart
//
// Cikti: /mnt/user-data/outputs/gunluk_sandik/*.png
// (GUNLUK_SANDIK_DIR ile degistirilebilir).
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

import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/auth/devi_tanisma.dart';
import 'package:devkom_app/screens/unified_home_screen.dart';
import 'package:devkom_app/services/gunluk_sandik_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/theme.dart';
import 'package:devkom_app/utils/app_localizations.dart';
import 'package:devkom_app/widgets/mascot.dart';

final _dizin = Platform.environment['GUNLUK_SANDIK_DIR'] ??
    '/mnt/user-data/outputs/gunluk_sandik';
final _key = GlobalKey();

Future<void> _fontlar() async {
  final n = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    n.addFont(Future.value(File('assets/fonts/Nunito-$w.ttf')
        .readAsBytesSync()
        .buffer
        .asByteData()));
  }
  await n.load();
  final b = FontLoader('Baloo2')
    ..addFont(Future.value(File('assets/fonts/Baloo2-ExtraBold.ttf')
        .readAsBytesSync()
        .buffer
        .asByteData()));
  await b.load();
  final emoji = File('/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf');
  if (emoji.existsSync()) {
    await (FontLoader('EmojiFallback')
          ..addFont(Future.value(emoji.readAsBytesSync().buffer.asByteData())))
        .load();
  }
  final root = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.path;
  final ikon = File(
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (ikon.existsSync()) {
    await (FontLoader('MaterialIcons')
          ..addFont(Future.value(ikon.readAsBytesSync().buffer.asByteData())))
        .load();
  }
}

Future<void> _kur(WidgetTester tester, Widget home,
    {String lang = 'tr',
    Size boy = const Size(430, 932),
    double yazi = 1.0}) async {
  tester.view.physicalSize = Size(boy.width * 3, boy.height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  debugDisableShadows = false;
  final ayar = SettingsProvider();
  await ayar.setLocale(Locale(lang));
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: ayar),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(lang),
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('es')
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme().copyWith(
        textTheme: AppTheme.lightTheme().textTheme.apply(
            fontFamily: 'Nunito', fontFamilyFallback: const ['EmojiFallback']),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(yazi)),
        child: RepaintBoundary(key: _key, child: child),
      ),
      home: home,
    ),
  ));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.runAsync(() async {
    for (final yol in [Mascot.durgunGorsel, 'assets/images/ui/sandik.png']) {
      try {
        await precacheImage(AssetImage(yol), _key.currentContext!)
            .timeout(const Duration(seconds: 20));
      } catch (_) {}
    }
  });
  await _bekle(tester, 1200);
}

Future<void> _bekle(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _cek(WidgetTester tester, String ad) async {
  await tester.runAsync(() async {
    final b = _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: 2.5);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(_dizin).createSync(recursive: true);
    File('$_dizin/$ad.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 8));
  debugDisableShadows = true;
}

/// Sandik ekranin ortasina gelsin.
Future<void> _sandigaKaydir(WidgetTester tester) async {
  final ctx = tester.element(find.byKey(const ValueKey('gunluk_sandik')));
  await tester.runAsync(() async {});
  Scrollable.ensureVisible(ctx, alignment: 0.45);
  await _bekle(tester, 600);
}

/// Dun acilmis, seri 2: bugun "3. gun".
Map<String, Object> _dunkuSeri() {
  final dun = DateTime.now().subtract(const Duration(days: 1));
  return {
    GunlukSandikDeposu.anahtarGun: GunlukSandikDeposu.gunAnahtari(dun),
    GunlukSandikDeposu.anahtarSeri: 2,
    GunlukSandikDeposu.anahtarOdul: 6,
    GunlukSandikDeposu.anahtarOyun: 'x',
  };
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

  for (final lang in ['tr', 'en']) {
    testWidgets('ana sayfa sandik $lang', (tester) async {
      SharedPreferences.setMockInitialValues(
          {'language_code': lang, ..._dunkuSeri()});
      await _kur(tester, const UnifiedHomeScreen(), lang: lang);
      await _sandigaKaydir(tester);
      await _cek(tester, '01_ana_sayfa_sandik_hazir_$lang');

      await tester.tap(find.byKey(const ValueKey('gunluk_sandik')));
      await _bekle(tester, 900);
      await _cek(tester, '02_sandik_aciliyor_jeton_$lang');
      await _bekle(tester, 6000);
      await _cek(tester, '03_sandik_acildi_oyun_$lang');

      // Uygulama yeniden acildi: ayni gun, odul alinmis.
      await _kapat(tester);
      await _kur(tester, const UnifiedHomeScreen(), lang: lang);
      await _sandigaKaydir(tester);
      await _cek(tester, '04_sandik_alindi_yarin_$lang');
      await _kapat(tester);
    });
  }

  testWidgets('kucuk ekran buyuk yazi', (tester) async {
    SharedPreferences.setMockInitialValues({'language_code': 'de'});
    await _kur(tester, const UnifiedHomeScreen(),
        lang: 'de', boy: const Size(360, 640), yazi: 1.3);
    await _sandigaKaydir(tester);
    await _cek(tester, '05_kucuk_ekran_hazir_de_130');
    await tester.tap(find.byKey(const ValueKey('gunluk_sandik')));
    await _bekle(tester, 7000);
    expect(tester.takeException(), isNull);
    await _cek(tester, '06_kucuk_ekran_acildi_de_130');
    await _kapat(tester);
  });

  for (final lang in ['tr', 'en']) {
    testWidgets('devi tanisma el yok $lang', (tester) async {
      SharedPreferences.setMockInitialValues({'language_code': lang});
      await _kur(tester, DeviTanisma(lang: lang, onDone: () {}), lang: lang);
      await _bekle(tester, 3200);
      await _cek(tester, '07_devi_tanisma_el_yok_$lang');
      await _kapat(tester);
    });
  }
}
