import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/ui/answer_feedback.dart';
import 'package:devkom_app/ui/appear_in.dart';
import 'package:devkom_app/ui/count_up.dart';
import 'package:devkom_app/ui/press_button.dart';
import 'package:devkom_app/widgets/learning/token_sequence_builder.dart';
import 'package:devkom_app/widgets/playful_background.dart';

/// Ortak arayuz parcalarinin gercekten cizilebildigini dogrular.
///
/// Bunlar analiz asamasinda yakalanmayan hatalar: `flutter analyze` temiz
/// olsa bile bir widget yerlestirme sirasinda cokebiliyor. Ozellikle
/// `PressButton` icindeki tam genislik istegi, genisligi sinirsiz olan bir
/// kabin (AlertDialog'un aksiyon satiri gibi) icine konuldugunda calisma
/// aninda patliyor — o yuzden ilk test tam olarak o durumu kuruyor.
void main() {
  Widget host(Widget child) => MaterialApp(
        home: Scaffold(body: Center(child: child)),
      );

  group('PressButton', () {
    testWidgets('normal yerlesimde cizilir ve basilinca tetiklenir',
        (tester) async {
      var tapped = 0;
      await tester.pumpWidget(host(
        PressButton(label: 'Kontrol Et', onPressed: () => tapped++),
      ));
      expect(find.text('Kontrol Et'), findsOneWidget);

      await tester.tap(find.text('Kontrol Et'));
      await tester.pumpAndSettle();
      expect(tapped, 1);
    });

    testWidgets('onPressed null iken basmak bir sey yapmaz', (tester) async {
      await tester.pumpWidget(host(
        const PressButton(label: 'Kontrol Et', onPressed: null),
      ));
      await tester.tap(find.text('Kontrol Et'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('loading durumunda etiket yerine gostergeye doner',
        (tester) async {
      await tester.pumpWidget(host(
        PressButton(label: 'Bitir', loading: true, onPressed: () {}),
      ));
      await tester.pump();
      expect(find.text('Bitir'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AlertDialog aksiyon satirinda cizilebilir', (tester) async {
      // Ders bitis penceresi butonu tam olarak buraya koyuyor. Aksiyon satiri
      // (OverflowBar) cocuguna sinirsiz genislik veriyor; buton kendi
      // genisligini sinirlamazsa burada "unbounded width" ile cokuyor.
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  content: const Text('Tebrikler'),
                  actions: [
                    PressButton(label: 'Harika!', onPressed: () {}),
                  ],
                ),
              ),
              child: const Text('ac'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('ac'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Harika!'), findsOneWidget);
    });
  });

  group('AnswerFeedbackBar', () {
    testWidgets('dogru cevapta yesil basligi ve devam tusunu gosterir',
        (tester) async {
      var continued = false;
      await tester.pumpWidget(host(
        AnswerFeedbackBar(
          result: AnswerResult.correct,
          detail: 'Sıralama doğru.',
          onContinue: () => continued = true,
        ),
      ));
      expect(find.text('Doğru!'), findsOneWidget);
      expect(find.text('Sıralama doğru.'), findsOneWidget);

      await tester.tap(find.text('Devam'));
      await tester.pumpAndSettle();
      expect(continued, isTrue);
    });

    testWidgets('yanlis cevapta dogru cevabi yazar', (tester) async {
      await tester.pumpWidget(host(
        AnswerFeedbackBar(
          result: AnswerResult.wrong,
          detail: 'Doğru sıralama: uyan → giyin',
          onContinue: () {},
        ),
      ));
      expect(find.text('Bu sefer olmadı'), findsOneWidget);
      expect(find.text('Doğru sıralama: uyan → giyin'), findsOneWidget);
      // Devam degil "Anladim": yanlis cevapta akis ilerlemiyor.
      expect(find.text('Anladım'), findsOneWidget);
    });

    testWidgets('inline bicimi de cizilir', (tester) async {
      await tester.pumpWidget(host(
        AnswerFeedbackBar(
          inline: true,
          result: AnswerResult.correct,
          onContinue: () {},
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('Doğru!'), findsOneWidget);
    });

    testWidgets('host() serit yokken de cizilir', (tester) async {
      await tester.pumpWidget(host(
        SizedBox(
          height: 300,
          child: AnswerFeedbackBar.host(
            child: const Text('icerik'),
            bar: null,
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('icerik'), findsOneWidget);
    });
  });

  group('TokenSequenceBuilder', () {
    const tokens = [
      SequenceToken(id: 'a', label: 'uyan'),
      SequenceToken(id: 'b', label: 'giyin'),
    ];

    testWidgets('havuzdaki parcaya dokununca cevaba eklenir', (tester) async {
      List<SequenceToken> answer = const [];
      await tester.pumpWidget(host(
        StatefulBuilder(
          builder: (context, setState) => TokenSequenceBuilder(
            bank: tokens.where((t) => !answer.contains(t)).toList(),
            answer: answer,
            onChanged: (next) => setState(() => answer = next),
          ),
        ),
      ));

      await tester.tap(find.text('uyan'));
      await tester.pumpAndSettle();

      expect(answer.map((t) => t.id).toList(), ['a']);
    });

    testWidgets('cevaptaki parcaya dokununca havuza doner', (tester) async {
      List<SequenceToken> answer = List.of(tokens);
      await tester.pumpWidget(host(
        StatefulBuilder(
          builder: (context, setState) => TokenSequenceBuilder(
            bank: const [],
            answer: answer,
            onChanged: (next) => setState(() => answer = next),
          ),
        ),
      ));

      await tester.tap(find.text('uyan'));
      await tester.pumpAndSettle();

      expect(answer.map((t) => t.id).toList(), ['b']);
    });

    testWidgets('kilitliyken dokunma sirayi degistirmez', (tester) async {
      List<SequenceToken> answer = List.of(tokens);
      await tester.pumpWidget(host(
        StatefulBuilder(
          builder: (context, setState) => TokenSequenceBuilder(
            bank: const [],
            answer: answer,
            locked: true,
            correctness: const [true, false],
            onChanged: (next) => setState(() => answer = next),
          ),
        ),
      ));

      await tester.tap(find.text('uyan'));
      await tester.pumpAndSettle();

      expect(answer.length, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bos cevap alaninda ipucu metni gorunur', (tester) async {
      await tester.pumpWidget(host(
        TokenSequenceBuilder(
          bank: const [],
          answer: const [],
          emptyHint: 'Buraya sürükle',
          onChanged: (_) {},
        ),
      ));
      expect(find.text('Buraya sürükle'), findsOneWidget);
    });
  });

  group('Sayaclar', () {
    testWidgets('CountUpText hedef degere ulasir', (tester) async {
      await tester.pumpWidget(host(
        const CountUpText(value: 40, prefix: '+', suffix: ' XP'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('+40 XP'), findsOneWidget);
    });

    testWidgets('ProgressTrack sinir degerlerde cokmez', (tester) async {
      for (final v in [-1.0, 0.0, 0.5, 1.0, 2.0]) {
        await tester.pumpWidget(host(SizedBox(
          width: 200,
          child: ProgressTrack(value: v),
        )));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'deger: $v');
      }
    });
  });

  group('AppearIn', () {
    testWidgets('animasyon bitince cocuk tam opak ve yerinde olur',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: AppearIn(delay: Duration(milliseconds: 90), child: Text('x')),
      ));
      // Ilk karede henuz gorunmuyor.
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, lessThan(1));
      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('hareket azaltilmisken hic sarmalamaz', (tester) async {
      await tester.pumpWidget(const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: AppearIn(child: Text('x'))),
      ));
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      expect(find.text('x'), findsOneWidget);
    });

    test('stagger artar ama bir tavana vurur', () {
      expect(AppearIn.stagger(0), Duration.zero);
      expect(AppearIn.stagger(2), const Duration(milliseconds: 90));
      // 30. kart 1.5 saniye beklemesin.
      expect(AppearIn.stagger(30), const Duration(milliseconds: 360));
    });
  });

  group('PlayfulBackground', () {
    testWidgets('cocugu cizer ve kare kare ilerler', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: PlayfulBackground(child: Text('icerik')),
      ));
      await tester.pump();
      expect(find.text('icerik'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      // Sonsuz dongu acik: testi bitirmek icin widget'i sokuyoruz.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('hareket azaltilmisken denetleyici baslamaz', (tester) async {
      await tester.pumpWidget(const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: PlayfulBackground(child: Text('icerik'))),
      ));
      await tester.pumpAndSettle();
      expect(find.text('icerik'), findsOneWidget);
    });
  });
}
