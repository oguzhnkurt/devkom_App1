// SCRATCH BLOKLARININ ONIZLEME GORSELLERI.
//
// Normal kosuda yalnizca cizimin hatasiz oldugunu denetler. Gorsel
// dosyalari yazdirmak icin bir klasor verin:
//
//   SCRATCH_ONIZLEME=/mnt/user-data/outputs/scratch_bloklar_onizleme \
//     flutter test test/scratch_blok_onizleme_test.dart
//
// Yazi tipi (Nunito) yukleniyor; yuklenmezse test motoru her harfi kutu
// olarak cizer.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/models/course_model.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/courses/yurutme/scratch_blok_katalogu.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/scratch_block_widget.dart';
import 'package:devkom_app/widgets/scratch_blok.dart';
import 'package:devkom_app/widgets/scratch_blok_ikonlari.dart';

final String? _klasor = Platform.environment['SCRATCH_ONIZLEME'];

Future<void> _yaziTipleri() async {
  final nunito = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    nunito.addFont(Future.value(File('assets/fonts/Nunito-$w.ttf')
        .readAsBytesSync()
        .buffer
        .asByteData()));
  }
  await nunito.load();
  final root = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.path;
  final ikon = File(
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (ikon.existsSync()) {
    await (FontLoader('MaterialIcons')
          ..addFont(Future.value(ikon.readAsBytesSync().buffer.asByteData())))
        .load();
  }
  final mono = File('tool/fonts/DejaVuSansMono.ttf');
  if (mono.existsSync()) {
    await (FontLoader('monospace')
          ..addFont(Future.value(mono.readAsBytesSync().buffer.asByteData())))
        .load();
  }
  for (final yol in [
    '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
  ]) {
    final f = File(yol);
    if (!f.existsSync()) continue;
    await (FontLoader('EmojiFallback')
          ..addFont(Future.value(f.readAsBytesSync().buffer.asByteData())))
        .load();
  }
}

Future<void> _yaz(WidgetTester tester, GlobalKey anahtar, String ad,
    {double oran = 2}) async {
  final k = _klasor;
  if (k == null) return;
  await tester.runAsync(() async {
    final b =
        anahtar.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await b.toImage(pixelRatio: oran);
    final d = await img.toByteData(format: ui.ImageByteFormat.png);
    Directory(k).createSync(recursive: true);
    File('$k/$ad.png').writeAsBytesSync(d!.buffer.asUint8List());
  });
}

Future<SettingsProvider> _ayar(String dil) async {
  SharedPreferences.setMockInitialValues({'language_code': dil});
  final s = SettingsProvider();
  await s.setLocale(Locale(dil));
  return s;
}

ScratchBlokTanimi _t(String id, String dil) =>
    ScratchBlokKatalogu.tanim(id, dil)!;

void main() {
  setUpAll(_yaziTipleri);
  // Testte ses calmasin: audioplayers eklentisi yok.
  setUpAll(() => SoundService.configure(sound: false, vibration: false));

  for (final dil in const ['tr', 'en', 'de', 'es']) {
    testWidgets('katalog galerisi ($dil)', (tester) async {
      tester.view.physicalSize = const Size(1500, 1900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final anahtar = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: anahtar,
              child: Container(
                color: const Color(0xFFF9F9F9),
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 18,
                  runSpacing: 14,
                  children: [
                    for (final id in ScratchBlokKatalogu.kimlikler)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ScratchBlok(
                            tanim: _t(id, dil), olcek: 0.9, sigdir: false),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await _yaz(tester, anahtar, 'galeri_$dil', oran: 1.5);
    });
  }

  testWidgets('eklenti bloklari: simge ve dikey ayrac (Kalem, Muzik)',
      (tester) async {
    tester.view.physicalSize = const Size(900, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const s = 1.2;
    final anahtar = GlobalKey();
    const kimlikler = [
      'pen_down',
      'pen_up',
      'pen_clear',
      'play_note_60',
      'play_drum'
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RepaintBoundary(
          key: anahtar,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScratchBlok(tanim: _t('green_flag', 'tr'), olcek: s),
                for (final id in kimlikler)
                  ScratchBlok(tanim: _t(id, 'tr'), olcek: s, sigdir: false),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await _yaz(tester, anahtar, 'eklenti_bloklari', oran: 2);

    // Scratch 3: eklenti blogu 40x40 simgeyle basliyor, blok bu yuzden
    // normal yigin bloktan (48) uzun: simge + 2x8 dolgu.
    for (final id in kimlikler) {
      expect(ScratchBlokOlcer.yukseklik(_t(id, 'tr'), s), 56 * s, reason: id);
    }
    // Simge ve ayrac satiri genisletiyor; duz metin degismiyor.
    final kalem = _t('pen_down', 'tr');
    final simgesiz = ScratchBlokTanimi(
        kategori: ScratchKategori.hareket,
        sekil: kalem.sekil,
        satir: kalem.satir);
    expect(
        ScratchBlokOlcer.genislik(kalem, s) -
            ScratchBlokOlcer.genislik(simgesiz, s),
        closeTo((40 + 8 + 1 + 8) * s, 0.5));
    expect(kalem.duzMetin, isNot(contains('✎')));
    expect(scratchIkonBoyutu(ScratchIkon.kalem), const Size(40, 40));
    expect(scratchIkonBoyutu(ScratchIkon.muzik), const Size(40, 40));
  });

  testWidgets('sekiller ve kategori daireleri', (tester) async {
    tester.view.physicalSize = const Size(1000, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final anahtar = GlobalKey();
    const s = 1.3;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RepaintBoundary(
          key: anahtar,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scratch editorunun sol sutunu.
                Column(
                  children: [
                    for (final k in const [
                      ScratchKategori.hareket,
                      ScratchKategori.gorunum,
                      ScratchKategori.ses,
                      ScratchKategori.olaylar,
                      ScratchKategori.kontrol,
                      ScratchKategori.algilama,
                      ScratchKategori.islemler,
                      ScratchKategori.degiskenler,
                      ScratchKategori.bloklarim,
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ScratchKategoriDairesi(kategori: k, lang: 'en'),
                      ),
                  ],
                ),
                const SizedBox(width: 36),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScratchBlok(tanim: _t('green_flag', 'en'), olcek: s),
                    ScratchBlok(
                        tanim: _t('forever', 'en'),
                        olcek: s,
                        parca: ScratchCParcasi.ust),
                    ScratchCSirti(
                      kategori: ScratchKategori.kontrol,
                      olcek: s,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScratchBlok(tanim: _t('move_10', 'en'), olcek: s),
                          ScratchBlok(
                              tanim: _t('if_space', 'en'),
                              olcek: s,
                              parca: ScratchCParcasi.ust),
                          ScratchCSirti(
                            kategori: ScratchKategori.kontrol,
                            olcek: s,
                            child: ScratchBlok(
                                tanim: _t('say_hello', 'en'), olcek: s),
                          ),
                          ScratchBlok(
                              tanim: _t('if_space', 'en'),
                              olcek: s,
                              parca: ScratchCParcasi.alt,
                              icDolu: true),
                          ScratchBlok(tanim: _t('turn_90', 'en'), olcek: s),
                        ],
                      ),
                    ),
                    ScratchBlok(
                        tanim: _t('forever', 'en'),
                        olcek: s,
                        parca: ScratchCParcasi.alt,
                        icDolu: true),
                    const SizedBox(height: 28),
                    Wrap(spacing: 16, runSpacing: 16, children: [
                      ScratchBlok(tanim: _t('random_1_10', 'en'), olcek: s),
                      ScratchBlok(tanim: _t('touching_edge', 'en'), olcek: s),
                      ScratchBlok(tanim: _t('delete_clone', 'en'), olcek: s),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await _yaz(tester, anahtar, 'sekiller_ve_kategoriler');
  });

  /// Gercek bir blok kurma adimi, telefon boyunda, cozum dizilmis.
  Future<void> adim(WidgetTester tester, String dil, Course kurs,
      BlockBuilderStep step, String ad,
      {bool calistir = false}) async {
    final s = await _ayar(dil);
    tester.view.physicalSize = const Size(390 * 2, 1300 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final anahtar = GlobalKey();
    await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
      value: s,
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'Nunito'),
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: anahtar,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: BlockBuilderStepWidget(
                  step: step,
                  course: kurs,
                  isDark: false,
                  onComplete: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    // Cozumu dokunarak diz (paletteki blok = son eslesen).
    for (final id in step.correctSequence) {
      final hedef = kurs.id == 'scratch'
          ? find.byWidgetPredicate((w) => w is ScratchBlok && w.kimlik == id)
          : find.byWidgetPredicate(
              (w) => w is ScratchBlockWidget && w.block.id == id);
      await tester.ensureVisible(hedef.last);
      await tester.pump();
      await tester.tap(hedef.last, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
    }
    if (calistir) {
      final tus = find.byType(ElevatedButton).first;
      await tester.ensureVisible(tus);
      await tester.tap(tus);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1500));
    }
    expect(tester.takeException(), isNull);
    await _yaz(tester, anahtar, ad);
    // Sahnenin zamanlayicilari bitsin.
    await tester.pump(const Duration(seconds: 30));
  }

  BlockBuilderStep adimBul(String id) => CourseModules.allLessons('scratch')
      .expand((l) => l.steps)
      .whereType<BlockBuilderStep>()
      .firstWhere((s) => s.id == id);

  final scratch = CoursesData.allCourses.firstWhere((c) => c.id == 'scratch');

  testWidgets('blok kurma adimi: ONCE (eski cizim)', (tester) async {
    // Eski cizim Scratch disi kurslarda hala duruyor; ayni adimi baska
    // bir kursun icinde cizmek "once"yi gosteriyor.
    final baska = CoursesData.allCourses.firstWhere((c) => c.id == 'mblock');
    await adim(tester, 'tr', baska, adimBul('s2_1_build1'), 'adim_once_tr');
  });

  for (final dil in const ['tr', 'en']) {
    testWidgets('blok kurma adimi: SONRA ($dil)', (tester) async {
      await adim(
          tester, dil, scratch, adimBul('s2_1_build1'), 'adim_sonra_$dil');
    });
  }

  testWidgets('blok kurma adimi: calisirken (tr)', (tester) async {
    await adim(
        tester, 'tr', scratch, adimBul('s2_1_build1'), 'adim_calisirken_tr',
        calistir: true);
  });

  testWidgets('anlatim ve siralama adimlari (en)', (tester) async {
    final s = await _ayar('en');
    tester.view.physicalSize = const Size(390 * 2, 2600 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final adimlar =
        CourseModules.allLessons('scratch').expand((l) => l.steps).toList();
    final anlatimlar = adimlar
        .whereType<ExplanationStep>()
        .where((e) => e.visuals.any((v) => v.type == VisualType.scratchBlock))
        .where((e) => const ['s1_2_exp1', 's1_2_exp2', 's2_1_exp1', 's2_1_exp3']
            .contains(e.id))
        .toList();
    final siralama = adimlar.whereType<OrderingStep>().first;
    final anahtar = GlobalKey();
    await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
      value: s,
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'Nunito'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: anahtar,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final a in anlatimlar) ...[
                      ExplanationStepWidget(
                          tumunuGoster: true,
                          step: a,
                          course: scratch,
                          isDark: false,
                          onComplete: () {}),
                      const Divider(height: 32),
                    ],
                    OrderingStepWidget(
                        step: siralama,
                        course: scratch,
                        isDark: false,
                        onComplete: (_) {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    await _yaz(tester, anahtar, 'anlatim_ve_siralama_en', oran: 1.5);
  });
}
