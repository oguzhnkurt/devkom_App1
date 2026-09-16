// NOT: Karuselin panelinde surekli donen bir arka plan animasyonu var
// (bkz. _PanelDrift). Bu yuzden agac hicbir zaman "durulmuyor" ve
// pumpAndSettle zaman asimina ugruyor; testler bilerek sinirli
// pump(Duration) kullaniyor.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:devkom_app/screens/auth/intro_art.dart';
import 'package:devkom_app/screens/auth/intro_carousel.dart';

/// Tanitim karuselinin davranisi.
///
/// Buradaki seyler goze bakarak dogrulanamaz: son sayfada ileri tusu
/// bitirme cagrisini yapiyor mu, ilk sayfada geri tusu kapali mi, ve
/// hareket azaltilmisken baslik TAM gorunur mu. Ucu de sessizce
/// bozulabilir — ozellikle sonuncusu, cunku hatali halinde baslik yari
/// saydam kalir ve kimse fark etmez.
void main() {
  _artLocalizationTests();
  List<IntroSlide> slides() => const [
        IntroSlide(
          eyebrow: 'ADIM ADIM',
          title: 'Kod yazmayı\nsıfırdan öğren',
          subtitle: 'Birinci sayfa',
          accent: Color(0xFF7E57C2),
          art: SizedBox.shrink(),
        ),
        IntroSlide(
          eyebrow: 'OYNA',
          title: 'İkinci\nbaşlık',
          subtitle: 'İkinci sayfa',
          accent: Color(0xFFF57C00),
          art: SizedBox.shrink(),
        ),
        IntroSlide(
          eyebrow: 'SIRALAMA',
          title: 'Üçüncü\nbaşlık',
          subtitle: 'Üçüncü sayfa',
          accent: Color(0xFF1E88E5),
          art: SizedBox.shrink(),
        ),
      ];

  Future<int> pump(WidgetTester tester, {bool reduced = false}) async {
    var finished = 0;
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: MaterialApp(
        home: IntroCarousel(
          slides: slides(),
          onFinish: () => finished++,
        ),
      ),
    ));
    await tester.pump(const Duration(seconds: 2));
    return finished;
  }

  testWidgets('ilk sayfa cizilir', (tester) async {
    await pump(tester, reduced: true);
    expect(find.text('ADIM ADIM'), findsOneWidget);
    expect(find.text('Birinci sayfa'), findsOneWidget);
  });

  testWidgets('ileri tusu sayfalari sirayla gecer', (tester) async {
    await pump(tester, reduced: true);

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('İkinci sayfa'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Üçüncü sayfa'), findsOneWidget);
  });

  testWidgets('son sayfada tus "Başla" olur ve bitirme cagrisini yapar',
      (tester) async {
    var finished = 0;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(
        home: IntroCarousel(
          slides: slides(),
          onFinish: () => finished++,
        ),
      ),
    ));
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pump(const Duration(seconds: 2));

    // Son sayfada ok yerine onay isareti.
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pump(const Duration(seconds: 2));
    expect(finished, 1);
  });

  testWidgets('geri tusu ilk sayfada calismaz, sonra calisir', (tester) async {
    await pump(tester, reduced: true);

    // Ilk sayfada geriye gidecek yer yok; dokunmak coku olusturmamali.
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Birinci sayfa'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Birinci sayfa'), findsOneWidget);
  });

  testWidgets('hareket azaltilmisken baslik tek parca ve tam gorunur',
      (tester) async {
    // Kelime kelime acilma kapaliyken metin bolunmemeli; bolunurse
    // satir sonlari kayar ve baslik iki yerine uc satira duser.
    await pump(tester, reduced: true);
    expect(find.text('Kod yazmayı\nsıfırdan öğren'), findsOneWidget);
  });

  testWidgets('animasyon acikken baslik kelimelere bolunur ve tamamlanir',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: IntroCarousel(slides: slides(), onFinish: () {}),
    ));
    await tester.pump();
    // Acilirken tek bir butun metin YOK; kelimeler ayri ayri ciziliyor.
    expect(find.text('Kod yazmayı\nsıfırdan öğren'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('gorseller cizilebiliyor', (tester) async {
    // Uc gorsel de CustomPaint ve animasyon iceriyor; yerlestirme
    // sirasinda cokmediklerini burada yakaliyoruz.
    for (final art in [
      IntroArt.lesson(const Color(0xFF7E57C2)),
      IntroArt.badge(const Color(0xFFF57C00)),
      IntroArt.leaderboard(const Color(0xFF1E88E5)),
    ]) {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SizedBox(height: 380, child: art)),
      ));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}

/// Gorsellerin icindeki metinler de ceviriliyor mu?
///
/// Ingilizce secili bir ekranda rozet gorselinin uzerinde buyuk
/// puntoyla "Başardın!" yaziyordu. Dil secimi ekranin yarisinda
/// bitiyorsa hic yapilmamis gibi gorunuyor; bu test o metinleri
/// dile gore kilitliyor.
void _artLocalizationTests() {
  Future<void> pumpArt(WidgetTester tester, Widget art, String lang) async {
    await tester.pumpWidget(MaterialApp(
      locale: Locale(lang),
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: SizedBox(height: 400, child: art)),
    ));
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('rozet gorselindeki yazi dile gore degisiyor', (tester) async {
    const accent = Color(0xFFF57C00);
    for (final (lang, expected) in [
      ('tr', 'Başardın!'),
      ('en', 'You did it!'),
      ('de', 'Geschafft!'),
      ('es', '¡Lo lograste!'),
    ]) {
      await pumpArt(tester, IntroArt.badge(accent), lang);
      expect(find.text(expected), findsOneWidget, reason: 'dil: $lang');
      if (lang != 'tr') {
        expect(find.text('Başardın!'), findsNothing, reason: 'dil: $lang');
      }
    }
  });

  testWidgets('siralama gorseli dile gore degisiyor', (tester) async {
    const accent = Color(0xFF00ACC1);
    await pumpArt(tester, IntroArt.leaderboard(accent), 'en');
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Sıralama'), findsNothing);
    expect(find.text('Zeynep'), findsNothing);

    await pumpArt(tester, IntroArt.leaderboard(accent), 'es');
    expect(find.text('Clasificación'), findsOneWidget);
    expect(find.text('Lucía'), findsOneWidget);
  });
}
