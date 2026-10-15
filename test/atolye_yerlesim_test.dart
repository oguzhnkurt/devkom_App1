// PROJE ATOLYESI ve BLOK KURMA ADIMI YERLESIMI
//
// Kilitlenenler:
//  * 360x640, 375x667, 390x844, 430x932 — yazi olcegi 1.0 ve 1.3 —
//    5.1 (Elma Yagmuru), 3.1 (Yakala!), uzun duz blok adimi (9.2) ve ic
//    ice adim (3.2): tasma yok.
//  * Tezgah sinirli yukseklikte: sayfa 430x932'de ekranin 1.6 katindan
//    kisa; palet ve kod alani kendi iclerinde kayiyor.
//  * Kategori sekmesine dokununca palet o bolume kayiyor ve sekme
//    vurgulaniyor; kaydirinca vurgu degisiyor.
//  * Paletteki bloklar kod alaniyla ayni olcekte (kocaman degil) ve
//    palet sutununa sigiyor.
//  * Dokunarak ve surukleyerek ekleme calisiyor.
//  * Kucuk ekranda hedefler ozete iniyor; cok dar tezgahta "Bloklar |
//    Kod" secici.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/scratch_atolyeleri.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/sahne/blok_tezgahi_karti.dart';
import 'package:devkom_app/courses/screens/widgets/proje_atolyesi.dart';
import 'package:devkom_app/courses/screens/widgets/scratch_tezgahi.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/services/proje_deposu.dart';
import 'package:devkom_app/services/sound_service.dart';
import 'package:devkom_app/widgets/scratch_blok.dart';

final _scratch = CoursesData.byId('scratch')!;

T _adim<T extends LessonStep>(String id) => CourseModules.allLessons('scratch')
    .expand((l) => l.steps)
    .firstWhere((s) => s.id == id) as T;

late SettingsProvider _ayar;

/// Uygulamanin yazi tipi (test yazi tipi cok genis; sayfa boyu olcumu
/// gercekci olsun).
Future<void> _nunito() async {
  final n = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    n.addFont(Future.value(File('assets/fonts/Nunito-$w.ttf')
        .readAsBytesSync()
        .buffer
        .asByteData()));
  }
  await n.load();
}

/// Uygulamadaki gibi: ust cubuk + kayan sayfa (Projelerim'deki atolye).
Future<void> _ac(WidgetTester tester, Widget w,
    {required Size boy, double yazi = 1.0}) async {
  tester.view.physicalSize = boy * 3;
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = yazi;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final dolgu = boy.height < 700 ? 12.0 : 16.0;
  await tester.pumpWidget(ChangeNotifierProvider<SettingsProvider>.value(
    value: _ayar,
    child: MaterialApp(
      theme: ThemeData(fontFamily: 'Nunito'),
      home: Scaffold(
        appBar: AppBar(title: const Text('Atölye')),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(dolgu, dolgu, dolgu, 32),
          child: w,
        ),
      ),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 100));
}

Widget _atolye(ProjeAtolyesiStep a, {bool hazir = true}) => ProjeAtolyesiWidget(
      step: a,
      course: _scratch,
      isDark: false,
      lang: 'tr',
      onComplete: (_) {},
      kayitli: hazir
          ? KayitliProje(
              id: 'k',
              ad: 'Deneme',
              kursId: 'scratch',
              adimId: a.id,
              kod: KodYapisi.coz(a.ornekCozum),
              tarih: DateTime(2026, 10, 15),
            )
          : null,
    );

Widget _ders(String id) => BlockBuilderStepWidget(
    step: _adim<BlockBuilderStep>(id),
    course: _scratch,
    isDark: false,
    onComplete: (_) {});

Future<void> _kapat(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
}

KategoriliTezgahState _tezgah(WidgetTester tester) =>
    tester.state<KategoriliTezgahState>(find.byType(KategoriliTezgah));

ScrollPosition _sayfa(WidgetTester tester) => tester
    .state<ScrollableState>(find
        .descendant(
            of: find.byType(SingleChildScrollView).first,
            matching: find.byType(Scrollable))
        .first)
    .position;

void main() {
  setUpAll(() async {
    SoundService.configure(sound: false);
    SharedPreferences.setMockInitialValues({'language_code': 'tr'});
    _ayar = SettingsProvider();
    await _ayar.setLocale(const Locale('tr'));
  });

  group('tasma yok', () {
    const boylar = [
      Size(360, 640),
      Size(375, 667),
      Size(390, 844),
      Size(430, 932),
    ];
    final ekranlar = <String, Widget Function()>{
      '5.1 elma yagmuru': () => _atolye(ScratchAtolyeleri.elmaYagmuru),
      '3.1 yakala (bos)': () =>
          _atolye(ScratchAtolyeleri.yakalaOyunu, hazir: false),
      '9.2 uzun blok adimi': () => _ders('s9_2_build1'),
      '3.2 ic ice adim': () => _ders('s3_2_build1'),
    };
    for (final boy in boylar) {
      for (final yazi in const [1.0, 1.3]) {
        for (final e in ekranlar.entries) {
          testWidgets(
              '${e.key} ${boy.width.toInt()}x${boy.height.toInt()} x$yazi',
              (tester) async {
            await _ac(tester, e.value(), boy: boy, yazi: yazi);
            expect(tester.takeException(), isNull);
            expect(find.byType(KategoriliTezgah), findsOneWidget);

            // Tezgah sinirli: 320..560 ve ekrandan uzun degil.
            final kart = tester.getRect(find.byType(KategoriliTezgah));
            expect(kart.height, inInclusiveRange(319.5, 560.5));
            expect(kart.right, lessThanOrEqualTo(boy.width));

            // Paletteki bloklar palet sutununa sigiyor.
            final palet =
                tester.getRect(find.byKey(const ValueKey('palet_listesi')));
            for (final b in tester.widgetList<ScratchBlok>(find.descendant(
                of: find.byKey(const ValueKey('palet_listesi')),
                matching: find.byType(ScratchBlok)))) {
              final r = tester.getRect(find.byWidget(b));
              expect(r.right, lessThanOrEqualTo(palet.right + 0.5),
                  reason: '${b.kimlik} palete sigmiyor');
              expect(b.olcek, lessThanOrEqualTo(0.76),
                  reason: 'palet blogu kod alanindan buyuk');
            }

            // Calistir (atolye) ya da bir blok ekle (ders): yine tasma yok.
            final st = tester
                .stateList<ScratchTezgahiState>(find.byType(ScratchTezgahi));
            if (st.isNotEmpty && st.first.kod.isNotEmpty) {
              st.first.calistir();
              for (var i = 0; i < 20; i++) {
                await tester.pump(const Duration(milliseconds: 100));
              }
              st.first.durdur();
              await tester.pump(const Duration(milliseconds: 300));
            } else {
              final ilk = find
                  .descendant(
                      of: find.byKey(const ValueKey('palet_listesi')),
                      matching: find.byType(GestureDetector))
                  .first;
              await tester.ensureVisible(ilk);
              await tester.pump();
              await tester.ensureVisible(ilk);
              await tester.pump();
              await tester.tap(ilk);
              await tester.pump(const Duration(milliseconds: 300));
              expect(_tezgah(tester).widget.kodSayisi, 1,
                  reason: 'dokununca blok eklenmedi');
            }
            expect(tester.takeException(), isNull);
            await _kapat(tester);
          });
        }
      }
    }
  });

  testWidgets('430x932: hedefler -> sahne -> tezgah 1.6 ekrandan kisa',
      (tester) async {
    await _nunito();
    await _ac(tester, _atolye(ScratchAtolyeleri.elmaYagmuru),
        boy: const Size(430, 932));
    final p = _sayfa(tester);
    // Calisma alaninin sonu (buyuk bayrak dugmesi) sayfanin icinde.
    final ust = tester.getTopLeft(find.byType(SingleChildScrollView).first).dy;
    final son =
        tester.getRect(find.byKey(const ValueKey('ders_bayrak'))).bottom - ust;
    expect(son, lessThan(1.6 * p.viewportDimension),
        reason: 'calisma alani ${son.round()} / ekran ${p.viewportDimension}');
    // Eskiden tezgah uzadikca sayfa da uzuyordu: butun sayfa da kisa.
    expect(p.maxScrollExtent, lessThan(p.viewportDimension));
    // Kod uzun: kod alani kendi icinde kayiyor.
    final t = _tezgah(tester);
    expect(t.kodKaydirma.position.maxScrollExtent, greaterThan(0));
    await _kapat(tester);
  });

  testWidgets('kategori sekmesi: dokununca palet o bolume kayar',
      (tester) async {
    await _ac(tester, _atolye(ScratchAtolyeleri.elmaYagmuru),
        boy: const Size(390, 844));
    final t = _tezgah(tester);
    expect(t.etkinKategori, ScratchKategori.hareket,
        reason: 'ilk bloklu kategori secili baslar');
    expect(find.byKey(const ValueKey('palet_kategori_seridi')), findsOneWidget);
    await tester
        .ensureVisible(find.byKey(const ValueKey('palet_kategori_seridi')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('palet_kategori_kontrol')));
    await tester.pumpAndSettle();
    expect(t.etkinKategori, ScratchKategori.kontrol);
    expect(t.paletKaydirma.offset, greaterThan(0));
    // Kontrol bolumunun ilk blogu paletin gorunen ust kisminda.
    final palet = tester.getRect(find.byKey(const ValueKey('palet_listesi')));
    final kontrol = find.byKey(const ValueKey('palet_repeat_10'));
    expect(kontrol, findsOneWidget);
    final r = tester.getRect(kontrol);
    expect(r.top, greaterThanOrEqualTo(palet.top - 1));
    expect(r.top, lessThan(palet.top + palet.height * 0.5));

    // Elle en uste kaydir: vurgu ilk kategoriye doner.
    t.paletKaydirma.jumpTo(0);
    await tester.pump();
    expect(t.etkinKategori, ScratchKategori.hareket);

    // Kod degisince palet yeniden kurulmuyor (ayni widget).
    final once = tester.widget(find.byKey(const ValueKey('palet_listesi')));
    await tester.tap(find.byKey(const ValueKey('palet_hide')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
        identical(
            once, tester.widget(find.byKey(const ValueKey('palet_listesi')))),
        isTrue);
    await _kapat(tester);
  });

  testWidgets('dokunarak ve surukleyerek ekleme', (tester) async {
    await _ac(tester, _atolye(ScratchAtolyeleri.yakalaOyunu, hazir: false),
        boy: const Size(375, 667));
    final st = tester.state<ScratchTezgahiState>(find.byType(ScratchTezgahi));
    expect(st.kod, isEmpty);
    await tester.ensureVisible(find.byType(KategoriliTezgah));
    await tester.pump();

    final bayrak = find.byKey(const ValueKey('palet_green_flag'));
    // Ic ice iki kaydirma: once palet, sonra sayfa (ikinci tur sayfayi
    // paletin yeni yerine gore duzeltir).
    await tester.ensureVisible(bayrak);
    await tester.pump();
    await tester.ensureVisible(bayrak);
    await tester.pump();
    await tester.tap(bayrak);
    await tester.pump(const Duration(milliseconds: 100));
    expect(st.kod.map((o) => o.id), ['green_flag']);

    // Basili tut + kod alanina surukle.
    final t = _tezgah(tester);
    await tester
        .ensureVisible(find.byKey(const ValueKey('palet_kategori_kontrol')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('palet_kategori_kontrol')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(t.etkinKategori, ScratchKategori.kontrol);
    final kaynak = find.byKey(const ValueKey('palet_forever'));
    expect(kaynak, findsOneWidget);
    final kodAlani =
        tester.getRect(find.byKey(const ValueKey('ic_ice_blok_0')));
    final g = await tester.startGesture(tester.getCenter(kaynak));
    await tester.pump(const Duration(milliseconds: 400));
    await g.moveTo(kodAlani.bottomLeft + const Offset(30, 30));
    await tester.pump(const Duration(milliseconds: 100));
    await g.moveTo(kodAlani.bottomLeft + const Offset(32, 34));
    await tester.pump(const Duration(milliseconds: 100));
    await g.up();
    await tester.pump(const Duration(milliseconds: 300));
    expect(st.kod.where((o) => !KodYapisi.isaretMi(o.id)).map((o) => o.id),
        ['green_flag', 'forever']);
    expect(tester.takeException(), isNull);
    await _kapat(tester);
  });

  testWidgets('kucuk ekran: hedefler ozete iner, dokununca acilir',
      (tester) async {
    await _ac(tester, _atolye(ScratchAtolyeleri.elmaYagmuru),
        boy: const Size(375, 667));
    expect(find.byKey(const ValueKey('atolye_hedef_ozeti')), findsOneWidget);
    expect(find.byKey(const ValueKey('atolye_hedef_0')), findsNothing);
    expect(find.text('0/4'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('atolye_hedef_ozeti')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('atolye_hedef_0')), findsOneWidget);
    await _kapat(tester);
  });

  testWidgets('buyuk ekran: hedefler acik', (tester) async {
    await _ac(tester, _atolye(ScratchAtolyeleri.elmaYagmuru),
        boy: const Size(430, 932));
    expect(find.byKey(const ValueKey('atolye_hedef_ozeti')), findsNothing);
    expect(find.byKey(const ValueKey('atolye_hedef_0')), findsOneWidget);
    await _kapat(tester);
  });

  testWidgets('dar tezgah (360x640, yazi 1.3): "Bloklar | Kod" secici',
      (tester) async {
    await _ac(tester, _atolye(ScratchAtolyeleri.elmaYagmuru),
        boy: const Size(360, 640), yazi: 1.3);
    final kodSekmesi = find.byKey(const ValueKey('tezgah_sekme_kod'));
    expect(kodSekmesi, findsOneWidget);
    expect(find.byKey(const ValueKey('palet_listesi')), findsOneWidget);
    expect(find.byKey(const ValueKey('ic_ice_blok_0')), findsNothing);
    await tester.ensureVisible(kodSekmesi);
    await tester.pump();
    await tester.tap(kodSekmesi);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('ic_ice_blok_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('palet_listesi')), findsNothing);
    // Kategoriye dokunmak paleti geri getiriyor.
    await tester.tap(find.byKey(const ValueKey('tezgah_sekme_bloklar')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('palet_kategori_degiskenler')));
    await tester.pumpAndSettle();
    expect(_tezgah(tester).etkinKategori, ScratchKategori.degiskenler);
    expect(tester.takeException(), isNull);
    await _kapat(tester);
  });

  testWidgets('sanal tuslar en az 44 pt', (tester) async {
    await _ac(tester, _atolye(ScratchAtolyeleri.elmaYagmuru),
        boy: const Size(360, 640));
    for (final t in ['tus_left', 'tus_right']) {
      final r = tester.getRect(find.byKey(ValueKey(t)));
      expect(r.height, greaterThanOrEqualTo(44));
      expect(r.width, greaterThanOrEqualTo(44));
    }
    await _kapat(tester);
  });

  testWidgets('serbest atolye: buyuk palet tembel liste, sekmeler calisiyor',
      (tester) async {
    await _ac(tester, _atolye(ScratchAtolyeleri.serbest, hazir: false),
        boy: const Size(390, 844));
    final liste = find.descendant(
        of: find.byKey(const ValueKey('palet_listesi')),
        matching: find.byType(ListView));
    expect(liste, findsOneWidget, reason: 'buyuk palet tembel kurulmali');
    final t = _tezgah(tester);
    final seritte = find.descendant(
        of: find.byKey(const ValueKey('palet_kategori_seridi')),
        matching: find.byType(InkWell));
    final son = seritte.last;
    await tester.ensureVisible(son);
    await tester.pump();
    await tester.tap(son);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(t.paletKaydirma.offset, greaterThan(0));
    expect(t.etkinKategori, isNot(ScratchKategori.hareket));
    expect(tester.takeException(), isNull);
    await _kapat(tester);
  });
}
