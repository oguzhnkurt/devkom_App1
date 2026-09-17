@Tags(['shots'])
library;

// App Store ekran görüntülerini üretir — TEST DEĞİL, ARAÇ.
//
// NEDEN TESTİN İÇİNDE
// -------------------
// Ekranları gerçek Flutter motoruyla çizmenin en ucuz yolu bu: cihaz,
// emülatör ya da Supabase bağlantısı gerekmiyor. Widget'ları elle
// kurup çizdiğimiz için ekran görüntüleri her zaman GERÇEK arayüzü
// gösteriyor, elde çizilmiş bir taklidi değil.
//
// Normal `flutter test` koşusunda ÇALIŞMAZ (bkz. dart_test.yaml,
// 'shots' etiketi hariç tutuluyor). Elle çalıştırmak için:
//
//     flutter test --run-skipped --tags shots test/appstore_shots_test.dart
//
// Çıktı: outputs/appstore/ekranlar/*.png     (İngilizce)
//         outputs/appstore/ekranlar_de/*.png  (Almanca)
//         outputs/appstore/ekranlar_es/*.png  (İspanyolca)
//         outputs/appstore/ekranlar_tr/*.png  (Türkçe)
//
// Türkçe mağaza slaytlarında İNGİLİZCE ekran görüntüleri kullanılıyordu
// — Türk bir veli slaytta "when green flag clicked" görüyordu. Araç
// artık her iki dili de üretiyor.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/auth_provider.dart';
import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/courses/screens/course_catalog_screen.dart';
import 'package:devkom_app/screens/games/matching_game_screen.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/html_lessons_data.dart';
import 'package:devkom_app/courses/data/lessons_data.dart';
import 'package:devkom_app/courses/data/quizzes_data.dart';
import 'package:devkom_app/courses/screens/quiz_screen.dart';
import 'package:devkom_app/courses/data/scratch_lessons_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/step_widgets.dart';
import 'package:devkom_app/widgets/first_task.dart';
import 'package:devkom_app/utils/lang.dart';
import 'package:devkom_app/screens/auth/modern_splash_screen.dart';
import 'package:devkom_app/screens/games/word_match_game_screen.dart';
import 'package:devkom_app/screens/unified_home_screen.dart';
import 'package:devkom_app/screens/games/chess_game_screen.dart';
import 'package:devkom_app/models/chess_game_model.dart';
import 'package:devkom_app/screens/quiz/quiz_intro_screen.dart';
import 'package:devkom_app/widgets/mascot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:devkom_app/core/service_locator.dart';
import 'package:devkom_app/services/auth_service_supabase.dart';

/// Uretilecek cihaz olculeri.
///
/// iPad GERI GELDI: 1.0.8 iPhone-only yuklenmek istendi ve Apple
/// reddetti (hata 90101) — bir guncelleme onceki surumun destekledigi
/// cihazlari desteklemeyi surdurmek zorunda. iPad destegi acik oldugu
/// surece magaza iPad gorseli de istiyor.
class _Cihaz {
  const _Cihaz(this.ad, this.genislik, this.yukseklik, this.oran, this.klasor,
      this.diller);

  final String ad;
  final double genislik;
  final double yukseklik;
  final double oran;
  final String klasor;

  /// Hangi diller uretilecek. Telefon dort dil (slaytlar dort dilde
  /// hazir); iPad yalnizca magaza sayfasi acik olan iki dil.
  final List<String> diller;

  String dizin(String lang) =>
      lang == 'en' ? 'outputs/appstore/$klasor' : 'outputs/appstore/${klasor}_$lang';
}

const _telefon = _Cihaz('telefon', 430, 932, 3, 'ekranlar',
    ['en', 'tr', 'de', 'es']);

/// 13 inc iPad: 1032x1376 mantiksal, 2x => 2064x2752.
const _ipad = _Cihaz('ipad', 1032, 1376, 2, 'ipad', ['en', 'tr']);

const _cihazlar = [_telefon, _ipad];
final _key = GlobalKey();

/// Magaza slaytindaki karakter: uygulamanin TEK karakteri.
///
/// Once bes karakter vardi ve burasi acilis karakterini seciyordu.
/// Artik secilecek bir sey yok: Devi.

/// Telefon ölçüsü: 430x932 mantıksal piksel, 3x yoğunluk => 1290x2796.
///
/// Apple yeni gönderimlerde 6.9 inç boyutunu istiyor; eski 1170x2532
/// (6.5 inç) artık tek başına yetmiyor.
Future<void> _shoot(
  WidgetTester tester,
  String name,
  Widget child, {
  String lang = 'en',
  _Cihaz cihaz = _telefon,
  Duration settle = const Duration(milliseconds: 400),
  // Gercek bir ekrani (kendi Scaffold'u ve baslik cubugu olan) oldugu
  // gibi cekmek icin. Parcali widget'lar icin false: onlari kendi
  // Scaffold'umuza yerlestiriyoruz.
  bool fullScreen = false,
  // Cekmeden once ekranda bir sey yapmak icin (bir sikki secmek,
  // ipucunu acmak gibi). Magaza slayti BOS bir ekrani degil,
  // cocugun icinde oldugu ani gostermeli.
  Future<void> Function(WidgetTester)? act,
}) async {
  SharedPreferences.setMockInitialValues({'language_code': lang});
  final settings = SettingsProvider();
  await settings.setLocale(Locale(lang));

  tester.view.physicalSize =
      Size(cihaz.genislik * cihaz.oran, cihaz.yukseklik * cihaz.oran);
  tester.view.devicePixelRatio = cihaz.oran;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        // Bazi oyun ekranlari oynama suresi kapisi icin AuthProvider
        // ariyor; olmayinca kirmizi hata ekrani ciziliyor.
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // Bazi ekranlar dili SettingsProvider'dan degil
        // `Localizations.localeOf(context)`ten okuyor (QuizIntroScreen
        // gibi). Locale verilmezse o ekranlar dort koşuda da
        // Ingilizce cikiyordu.
        locale: Locale(lang),
        supportedLocales: const [Locale('tr'), Locale('en'), Locale('de'), Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Nunito',
          fontFamilyFallback: const ['EmojiFallback'],
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        ),
        home: RepaintBoundary(
          key: _key,
          child: fullScreen
              ? child
              : Scaffold(
                  backgroundColor: const Color(0xFFF5F7FA),
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: child,
                    ),
                  ),
                ),
        ),
      ),
    ),
  );
  await tester.pump(settle);

  // Image.asset test motorunda kendiliginden COZULMUYOR: acilis
  // ekranindaki uygulama simgesi bir kosuda robot, digerinde bos mor
  // kare cikiyordu. runAsync icinde onbellege alip bir kare daha
  // pompalamak gerekiyor.
  await tester.runAsync(() async {
    await precacheImage(
        const AssetImage('assets/images/app_icon.png'), _key.currentContext!);
    // Satranc tahtasinin zemini paket icinden gelen bir PNG. Onbellege
    // alinmazsa taslar ciziliyor ama KARELER bos kaliyor — tahtasiz bir
    // satranc ekrani cikiyordu.
    for (final ad in ['brown', 'dark_brown', 'green', 'orange']) {
      await precacheImage(
        AssetImage('images/${ad}_board.png', package: 'flutter_chess_board'),
        _key.currentContext!,
      );
    }
    // MASKOT.
    //
    // iPad kosusunda Devi'nin yerinde `Icons.smart_toy_rounded`
    // cikiyordu — yani `Image.asset`'in errorBuilder'i. Onbellege
    // alinmadan cizilen kare, gorsel daha cozulmeden yaziliyor.
    // Magaza gorselinde maskotun yerinde bir yedek simge olamaz.
    for (final yol in [Mascot.durgunGorsel, Mascot.kutlamaGorseli]) {
      try {
        await precacheImage(AssetImage(yol), _key.currentContext!);
      } catch (_) {
        // Gorsel yoksa arac durmasin; eksikligi ciktida zaten gorunur.
      }
    }
  });
  await tester.pump(const Duration(milliseconds: 120));

  if (act != null) {
    await act(tester);
    await tester.pump(const Duration(milliseconds: 400));
  }

  await tester.runAsync(() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: cihaz.oran);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = cihaz.dizin(lang);
    Directory(dir).createSync(recursive: true);
    File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });

  // Agaci sokup zamanlayicilarin dolmasini bekliyoruz. Ana sayfa
  // anonim oturum acmayi deniyor; erisilemez Supabase adresi yuzunden
  // basarisiz oluyor ve yeniden deneme zamanlayicisi asili kaliyor,
  // test "Pending timers" ile patliyordu.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 8));
}

/// Gerçek yazı tipini yükler.
///
/// Yüklenmezse `flutter test` her harfi SİYAH KUTU olarak çiziyor
/// (glyph'siz varsayılan font). Ekran görüntüsü aracı için bu ölümcül:
/// mağazaya yüklenecek görselde yazı yerine kutular olur.
Future<void> _loadFonts() async {
  final loader = FontLoader('Nunito');
  for (final w in ['400', '600', '700', '800']) {
    final file = File('assets/fonts/Nunito-$w.ttf');
    loader.addFont(
        Future.value(file.readAsBytesSync().buffer.asByteData()));
  }
  await loader.load();

  // Emoji: Nunito'da emoji glifi yok. Gerçek cihazda iOS kendi emoji
  // fontuna düşüyor, ama test motorunda böyle bir yedek yok ve her
  // emoji BOŞ KARE çıkıyor. Mağaza görselinde tofu kabul edilemez.
  for (final path in [
    '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
    '/System/Library/Fonts/Apple Color Emoji.ttc',
  ]) {
    final f = File(path);
    if (!f.existsSync()) continue;
    final emoji = FontLoader('EmojiFallback')
      ..addFont(Future.value(f.readAsBytesSync().buffer.asByteData()));
    await emoji.load();
    break;
  }

  // KOD KUTULARININ YAZI TIPI.
  //
  // Uygulamada 33 yerde `fontFamily: 'monospace'` geciyor. Bu paketlenmis
  // bir yazi tipi degil: gercek cihazda iOS kendi monospace'ine (Menlo)
  // dusuyor. Test motorunda boyle bir yedek YOK — HTML kod ekraninin
  // ekran goruntusunde kodun her harfi BOS KUTU cikiyordu. Magazaya
  // "cocuk gercek kod yaziyor" diye kutulardan olusan bir gorsel
  // koyamayiz.
  //
  // Sistem yazi tipine guvenmiyoruz: ekran goruntusu her makinede ayni
  // cikmali. Yazi tipi repoda (tool/fonts/), yalnizca bu arac okuyor —
  // uygulamaya paketlenmiyor.
  final monoFile = File('tool/fonts/DejaVuSansMono.ttf');
  if (monoFile.existsSync()) {
    final mono = FontLoader('monospace')
      ..addFont(Future.value(monoFile.readAsBytesSync().buffer.asByteData()));
    await mono.load();
  }

  // Material simgeleri: test motoru bunları kendiliğinden yüklemiyor,
  // her simge yerine boş kare çiziliyor (ekran görüntüsünde el işareti
  // yeşil bir kutu olarak çıkmıştı). Font Flutter SDK'sının içinde.
  final root = Platform.environment['FLUTTER_ROOT'] ??
      (File(Platform.resolvedExecutable).parent.parent.parent.path);
  final icons =
      File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final l = FontLoader('MaterialIcons')
      ..addFont(Future.value(icons.readAsBytesSync().buffer.asByteData()));
    await l.load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);
  // Ana sayfa `Supabase.instance`'i cagiriyor ve baslatilmamis
  // ornekte assert atiyor (kirmizi hata ekrani cikiyordu). Testte
  // gercek bir sunucuya baglanmiyoruz: erisilemez bir adresle
  // baslatmak assert'i gecmeye yetiyor, ekran bos veriyle ciziliyor —
  // magaza slayti icin istedigimiz de bu.
  setUpAll(() async {
    // Supabase acilirken SharedPreferences'i okuyor; sahte degerler
    // once verilmezse eklenti kanali yok diye patliyor.
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
        url: 'http://127.0.0.1:1', anonKey: 'test', debug: false);
    // Bazi ekranlar (Satranc) servisleri GetIt'ten aliyor; kayitli
    // degilse initState'te StateError atip ekran hic cizilmiyor.
    if (!getIt.isRegistered<AuthServiceSupabase>()) {
      await setupServiceLocator();
    }
  });

  final scratch = CoursesData.byId('scratch')!;

  for (final cihaz in _cihazlar) {
  for (final lang in cihaz.diller) {
    // Dort dilin dordu de uretiliyor. Onceden burada `lang == 'en'`
    // ikilisi vardi: Almanca ve Ispanyolca slaytlarda maskotun repligi
    // TURKCE cikiyordu — Alman App Store'una Turkce yazili bir slayt
    // gitmesi demekti.

  testWidgets('01 ilk gorev ($lang, ${cihaz.ad})', (tester) async {
    await _shoot(
      tester,
      '01_first_task',
      // Ust hizali: ortalarsak slaytta ustte ve altta esit bosluk
      // kaliyor ve gorsel kucuk gorunuyor.
      Align(
        alignment: Alignment.topCenter,
        child: FirstTask(lang: lang, onSolved: (_) {}),
      ),
      lang: lang,
      cihaz: cihaz,
    );
  });

  testWidgets('02 ders adimi ($lang, ${cihaz.ad})', (tester) async {
    // Gercek bir Scratch dersinin gercek bir aciklama adimi.
    final step = ScratchLessonsData.module1
        .expand((l) => l.steps)
        .whereType<ExplanationStep>()
        .firstWhere((s) => s.visuals.isNotEmpty);

    await _shoot(
      tester,
      '02_lesson',
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MascotSays(
              mood: MascotMood.curious,
              size: 64,
              color: Color(0xFFFF8C1A),
              text: AppLang.pick(lang,
                  tr: 'Her proje bir blokla başlar. Sana göstereyim.',
                  en: 'Every project starts with a block. Let me show you.',
                  de: 'Jedes Projekt beginnt mit einem Block. '
                      'Ich zeig es dir.',
                  es: 'Cada proyecto empieza con un bloque. Te lo enseño.'),
            ),
            const SizedBox(height: 24),
            ExplanationStepWidget(
              tumunuGoster: true,
              step: step,
              course: scratch,
              isDark: false,
              onComplete: () {},
            ),
          ],
        ),
      ),
      lang: lang,
      cihaz: cihaz,
    );
  });

  testWidgets('03 karakter ($lang, ${cihaz.ad})', (tester) async {
    await _shoot(
      tester,
      '03_character',
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(Mascot.ad,
              style: const TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
              AppLang.pick(lang,
                  tr: 'Kod arkadaşın',
                  en: 'Your coding buddy',
                  de: 'Dein Code-Kumpel',
                  es: 'Tu amigo del código'),
              style: const TextStyle(fontSize: 17, color: Colors.black54)),
          const SizedBox(height: 28),
          // Giydirme kalkti: slaytta da Devi oldugu gibi duruyor.
          // Olmayan bir ozelligi (sapka, gozluk) magazada gostermek
          // indiren cocuga verilmis yanlis bir soz olurdu.
          const Mascot(size: 220, mood: MascotMood.happy),
        ],
      ),
      lang: lang,
      cihaz: cihaz,
    );
  });

  // Quiz ekrani GERCEK ekran: kendi baslik cubugu, ilerleme cizgisi ve
  // butonlariyla oldugu gibi cekiliyor. Secilen soru bilerek kod
  // ciktisi sorusu — magazada "cocuk ne YAPIYOR" sorusunun cevabi
  // guzel bir arayuz degil, kodun ne yazacagini tahmin etmesi.
  testWidgets('05 kod tahmini ($lang, ${cihaz.ad})', (tester) async {
    final lesson = LessonsData.getLessonsForCourse('python')
        .firstWhere((l) => l.id == 'python_02');
    await _shoot(
      tester,
      '05_predict_code',
      QuizScreen(
        course: CoursesData.byId('python')!,
        lesson: lesson,
        quiz: QuizzesData.all['python_02']!,
      ),
      lang: lang,
      cihaz: cihaz,
      fullScreen: true,
      settle: const Duration(milliseconds: 600),
    );
  });

  // Ayni quiz ekrani, ama cocuk bir sik secmis ve ipucunu acmis
  // halde. Magazada gosterilmeye deger olan bos soru degil, sorunun
  // ardindan gelen ACIKLAMA: bu uygulamanin verdigi soz o.
  testWidgets('06 ipucu ($lang, ${cihaz.ad})', (tester) async {
    final lesson = LessonsData.getLessonsForCourse('python')
        .firstWhere((l) => l.id == 'python_02');
    await _shoot(
      tester,
      '06_hint',
      QuizScreen(
        course: CoursesData.byId('python')!,
        lesson: lesson,
        quiz: QuizzesData.all['python_02']!,
      ),
      lang: lang,
      cihaz: cihaz,
      fullScreen: true,
      settle: const Duration(milliseconds: 600),
      act: (t) async {
        // Dogru sikki sec (indeks 0), sonra ampule bas.
        await t.tap(find.text('8'));
        await t.pump(const Duration(milliseconds: 200));
        await t.tap(find.byIcon(Icons.lightbulb));
        await t.pump(const Duration(milliseconds: 300));
      },
    );
  });

  // Esleştirme oyunu: uygulamanin EN RENKLI ekrani. Magaza slaytinda
  // acik gri ve yarisi bos bir ekran hicbir sey soylemiyordu; burada
  // renkli etiketler ve dolu bir liste var.
  testWidgets('07 esleştirme oyunu ($lang, ${cihaz.ad})', (tester) async {
    await _shoot(
      tester,
      '07_matching',
      const MatchingGameScreen(),
      lang: lang,
      cihaz: cihaz,
      fullScreen: true,
      settle: const Duration(milliseconds: 700),
    );
  });

  // Kurs katalogu: "Ogrenme Yolu". Uygulamanin en cok sey anlatan
  // ekrani — dokuz kurs numaralanmis bir yol halinde, her birinde
  // ders sayisi ve sure. Magaza slaytinda "9 kurs" iddiasinin
  // karsiligi bu ekran.
  testWidgets('08 kurs yolu ($lang, ${cihaz.ad})', (tester) async {
    await _shoot(
      tester,
      '08_path',
      const CourseCatalogScreen(),
      lang: lang,
      cihaz: cihaz,
      fullScreen: true,
      settle: const Duration(milliseconds: 700),
    );
  });

  // Ana sayfa: cocugun uygulamayi actiginda gordugu ekran.
  testWidgets('09 ana sayfa ($lang, ${cihaz.ad})', (tester) async {
    await _shoot(
      tester,
      '09_home',
      const UnifiedHomeScreen(),
      lang: lang,
      cihaz: cihaz,
      fullScreen: true,
      settle: const Duration(milliseconds: 900),
    );
  });

  // Acilis ekrani: uygulamanin adini ve ne oldugunu tek karede
  // soyleyen tek ekran.
  testWidgets('10 acilis ($lang, ${cihaz.ad})', (tester) async {
    await _shoot(
      tester,
      '10_splash',
      const ModernSplashScreen(),
      lang: lang,
      cihaz: cihaz,
      fullScreen: true,
      settle: const Duration(milliseconds: 900),
    );
  });

  // Kelime eslestirme: terimlerin Ingilizce-Turkce karsiligi.
  testWidgets('11 kelime eslestirme ($lang, ${cihaz.ad})', (tester) async {
    await _shoot(
      tester,
      '11_word_match',
      const WordMatchGameScreen(gameData: {}),
      lang: lang,
      cihaz: cihaz,
      fullScreen: true,
      settle: const Duration(milliseconds: 700),
    );
  });

  // Satranc: oyun gorunumu. `initialDifficulty` verilince ekran
  // dogrudan tahtayi kuruyor.
  testWidgets('12 satranc ($lang, ${cihaz.ad})', (tester) async {
    await _shoot(
      tester,
      '12_chess',
      const ChessGameScreen(initialDifficulty: ChessDifficulty.beginner),
      lang: lang,
      cihaz: cihaz,
      fullScreen: true,
      settle: const Duration(milliseconds: 900),
      // Ekran once tahta temasi soruyor; "Baslat"a basmadan tahta
      // kurulmuyor.
      act: (tester) async {
        await tester.pump(const Duration(milliseconds: 300));
        final basla = find.widgetWithText(
          ElevatedButton,
          AppLang.pick(lang,
              tr: 'Başlat', en: 'Start', de: 'Starten', es: 'Empezar'),
        );
        if (basla.evaluate().isNotEmpty) {
          await tester.tap(basla.first);
          // Yesil "Oyun basladi!" seridi slaytin altini kapatiyordu;
          // 2 saniyelik omru bitene kadar pompaliyoruz.
          for (var i = 0; i < 14; i++) {
            await tester.pump(const Duration(milliseconds: 400));
          }
        }
      },
    );
  });

  // Quiz girisi: "Basla" tusu yerine kaydirmali tus olan ekran.
  testWidgets('13 kaydirarak basla ($lang, ${cihaz.ad})', (tester) async {
    await _shoot(
      tester,
      '13_slide_to_start',
      const QuizIntroScreen(),
      lang: lang,
      cihaz: cihaz,
      fullScreen: true,
      settle: const Duration(milliseconds: 500),
    );
  });

  // Scratch dersinin GERCEK surukle-birak adimi.
  //
  // Onceden burada elle kurulmus bir mBlock/Arduino adimi vardi:
  // magazada gosterdigimiz ekran, cocugun Scratch dersinde gordugu
  // ekran degildi. Artik ders verisinden geliyor (s1_2_build2) ve
  // slaytta cocugun tam ortasinda oldugu an goruluyor: iki blok
  // yerlestirilmis, ucuncusu hala palette.
  testWidgets('04 scratch bloklari ($lang, ${cihaz.ad})', (tester) async {
    final step = ScratchLessonsData.module1
        .expand((l) => l.steps)
        .whereType<BlockBuilderStep>()
        .firstWhere((s) => s.id == 's1_2_build2');

    await _shoot(
      tester,
      '04_blocks',
      SingleChildScrollView(
        child: BlockBuilderStepWidget(
          step: step,
          course: scratch,
          isDark: false,
          onComplete: (_) {},
        ),
      ),
      lang: lang,
      cihaz: cihaz,
      // Iki blogu yerine koyuyoruz. UCUNCUSUNU KOYMUYORUZ: dizi
      // tamamlanirsa kutlama animasyonu basliyor ve testte asili
      // zamanlayici birakiyor; ustelik slaytta gosterilmesi gereken
      // "cocuk cozuyor" ani, "cozdu" ani degil.
      act: (t) async {
        for (final etiket in [
          AppLang.pick(lang,
              tr: 'tıklandığında',
              en: 'when green flag clicked',
              de: 'Wenn die grüne Flagge angeklickt',
              es: 'al hacer clic en la bandera verde'),
          AppLang.pick(lang,
              tr: '10 adım git',
              en: 'move 10 steps',
              de: 'gehe 10 Schritte',
              es: 'muévete 10 pasos'),
        ]) {
          final blok = find.text(etiket);
          if (blok.evaluate().isEmpty) continue;
          await t.ensureVisible(blok.last);
          await t.pump(const Duration(milliseconds: 120));
          await t.tap(blok.last, warnIfMissed: false);
          await t.pump(const Duration(milliseconds: 250));
        }
      },
    );
  });

  // HTML kod ekrani: cocugun kendi elleriyle kod YAZDIGI ekran.
  //
  // Magazada blok surukleyen ekranlarin yaninda bu duruyor: uygulama
  // bloklarda kalmiyor, gercek kodu da yazdiriyor.
  testWidgets('14 html kod ($lang, ${cihaz.ad})', (tester) async {
    final step = HtmlLessonsData.module1
        .expand((l) => l.steps)
        .whereType<TypeCodeStep>()
        .firstWhere((s) => s.id == 'h1_2_type1');

    await _shoot(
      tester,
      '14_html_code',
      SingleChildScrollView(
        child: TypeCodeStepWidget(
          step: step,
          course: CoursesData.byId('html')!,
          isDark: false,
          onComplete: (_) {},
        ),
      ),
      lang: lang,
      cihaz: cihaz,
      // Bos bir kod kutusu hicbir sey anlatmiyor. Cocugun yazdigi
      // kodu editore koyuyoruz — hedef kodun kendisi, uydurma degil.
      act: (t) async {
        final alan = find.byType(TextField);
        if (alan.evaluate().isEmpty) return;
        await t.ensureVisible(alan.first);
        await t.enterText(alan.first, step.targetCode);
        await t.pump(const Duration(milliseconds: 250));
      },
    );
  });

  }
  }
}
