// mBlock: Hata Avcisi adimlari ve 4.1/4.2'nin sanal Uno'da calisan blok
// kurma adimlari.
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/mblock_lessons_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/screens/widgets/mblock_tezgahi.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/courses/yurutme/mblock_uno.dart';

BlockBuilderStep _adim(String id) => MBlockLessonsData.allLessons
    .expand((l) => l.steps)
    .whereType<BlockBuilderStep>()
    .firstWhere((s) => s.id == id);

Future<UnoKarti> _calistir(List<MBlockBlok> program,
    {int mesafe = 30, int butce = 400, void Function(UnoKarti)? her}) async {
  final kart = UnoKarti()..mesafe = mesafe;
  final y = UnoYorumlayici(
    kart: kart,
    butce: butce,
    uyku: (_) async {},
    onBlok: (_) => her?.call(kart),
  );
  await y.calistir([program]);
  return kart;
}

const _diller = ['tr', 'en', 'de', 'es'];

void main() {
  group('4.1 park alarmi ve 4.2 bariyer', () {
    for (final id in ['m4_1_build1', 'm4_2_build1']) {
      test('$id: cozum dort dilde kabul ediliyor ve araclarla kurulabiliyor',
          () {
        final a = _adim(id);
        for (final d in _diller) {
          final p = mblockCozumProgrami(a.mblock!.cozum, d);
          expect(mblockCozumDogruMu([p], a.mblock!.cozum), isTrue,
              reason: '$id $d');
          if (d != 'tr') {
            expect(a.goalFor(d), isNot(a.goal), reason: '$id $d cevrilmis');
          }
          expect(a.instructionFor(d).trim(), isNotEmpty);
        }
        // Cozumdeki (yuvalara takilanlar dahil) her blok arac kutusunda.
        final kutu = a.mblock!.bloklar.toSet();
        void gez(MBlockBeklenen b) {
          expect(kutu, contains(b.tip), reason: '$id: ${b.tip}');
          b.icerik.forEach(gez);
          b.girdiler.values.forEach(gez);
        }

        a.mblock!.cozum.forEach(gez);
        expect(MBlockTezgahi.kurulumJson(a.mblock!, 'de'),
            contains('dev_kucuktur'));
      });
    }

    test('park alarmi: yakinda buzzer otuyor, uzakta susuyor', () async {
      final p = mblockCozumProgrami(_adim('m4_1_build1').mblock!.cozum, 'tr');
      var otti = false;
      await _calistir(p, mesafe: 12, her: (k) {
        if (k.dijital[8] == true) otti = true;
      });
      expect(otti, isTrue);
      otti = false;
      await _calistir(p, mesafe: 80, her: (k) {
        if (k.dijital[8] == true) otti = true;
      });
      expect(otti, isFalse);
    });

    test('bariyer: yakinda servo 90, uzakta 0', () async {
      final p = mblockCozumProgrami(_adim('m4_2_build1').mblock!.cozum, 'tr');
      expect((await _calistir(p, mesafe: 10)).servo[9], 90);
      expect((await _calistir(p, mesafe: 50)).servo[9], 0);
      // Kartta mesafe sensoru ve servo cizilecek.
      final parca = UnoYorumlayici.parcalar([p]);
      expect(parca.mesafe, isTrue);
      expect(parca.servolar, [9]);
    });

    test('bariyerde iki "eger"in sirasi serbest', () {
      final a = _adim('m4_2_build1');
      final p = mblockCozumProgrami(a.mblock!.cozum, 'tr');
      final dongu = p[1];
      final ters = MBlockBlok(
          tip: dongu.tip, icerik: dongu.icerik.reversed.toList());
      expect(mblockCozumDogruMu([[p[0], ters]], a.mblock!.cozum), isTrue);
    });

    test('esik degeri denetleniyor: 30 yerine 50 yanlis', () {
      final a = _adim('m4_1_build1');
      final p = mblockCozumProgrami(a.mblock!.cozum, 'tr');
      final eger = p[1].icerik.first;
      final kosul = eger.girdiler['KOSUL']!;
      final yanlis = MBlockBlok(tip: kosul.tip, alanlar: {
        ...kosul.alanlar,
        'B': '50',
      }, girdiler: kosul.girdiler);
      final program = [
        p[0],
        MBlockBlok(tip: p[1].tip, icerik: [
          MBlockBlok(
              tip: eger.tip,
              girdiler: {'KOSUL': yanlis},
              icerik: eger.icerik),
        ]),
      ];
      expect(mblockCozumDogruMu([program], a.mblock!.cozum), isFalse);
    });
  });

  group('Hata Avcisi', () {
    final hatalar = MBlockLessonsData.allLessons
        .expand((l) => l.steps)
        .whereType<BlockBuilderStep>()
        .where((s) => s.mblock?.hataAvcisi ?? false)
        .toList();

    test('en az iki Hata Avcisi adimi var: biri kartta, biri kuklada', () {
      expect(hatalar.length, greaterThanOrEqualTo(2));
      expect(hatalar.any((s) => mblockKartProgramiMi(s.mblock!.cozum)),
          isTrue);
      expect(hatalar.any((s) => !mblockKartProgramiMi(s.mblock!.cozum)),
          isTrue);
    });

    for (final d in _diller) {
      test('hazir program HATALI, cozum dogru ve XML olarak tezgaha gidiyor '
          '($d)', () {
        for (final s in hatalar) {
          final ayar = s.mblock!;
          final hazir = mblockCozumProgrami(ayar.baslangic!, d);
          expect(mblockCozumDogruMu([hazir], ayar.cozum), isFalse,
              reason: '${s.id}: hazir program zaten dogru olmamali');
          final xml = ayar.baslangicXmlFor(d)!;
          expect(xml, startsWith('<xml>'));
          expect(xml, contains('<block type="${hazir.first.tip}" x="40"'));
          expect('<block '.allMatches(xml).length,
              '</block>'.allMatches(xml).length);
          expect(MBlockTezgahi.kurulumJson(ayar, d), contains('ICERIK'));
        }
      });
    }

    test('blink hatasi: LED neredeyse hep yanik; duzeltince yarisi',
        () async {
      final s = _adim('m2_2_hata');
      Future<double> yanikOrani(List<MBlockBlok> p) async {
        var yanik = 0, toplam = 0;
        final kart = UnoKarti();
        final y = UnoYorumlayici(
          kart: kart,
          butce: 200,
          // Sahte saat: beklemeler gercek sure kadar sayiliyor.
          uyku: (d) async {
            final adim = d.inMilliseconds ~/ 16 + 1;
            toplam += adim;
            if (kart.parlaklik(9) == 1) yanik += adim;
          },
        );
        await y.calistir([p]);
        return yanik / toplam;
      }

      final hatali =
          await yanikOrani(mblockCozumProgrami(s.mblock!.baslangic!, 'tr'));
      final dogru =
          await yanikOrani(mblockCozumProgrami(s.mblock!.cozum, 'tr'));
      expect(hatali, greaterThan(0.95));
      expect(dogru, closeTo(0.5, 0.05));
    });

    test('XML: alanlar field, sayilar golge, ic ice next', () {
      final xml = mblockXml([
        const [
          MBlockBlok(tip: 'dev_kart_acilis'),
          MBlockBlok(tip: 'dev_surekli', icerik: [
            MBlockBlok(
                tip: 'dev_dijital_yaz', alanlar: {'PIN': '9', 'SEVIYE': 'HIGH'}),
            MBlockBlok(tip: 'dev_bekle', alanlar: {'SANIYE': '1'}),
          ]),
        ]
      ]);
      expect(
          xml,
          '<xml><block type="dev_kart_acilis" x="40" y="30"><next>'
          '<block type="dev_surekli"><statement name="ICERIK">'
          '<block type="dev_dijital_yaz"><field name="PIN">9</field>'
          '<field name="SEVIYE">HIGH</field><next><block type="dev_bekle">'
          '<value name="SANIYE"><shadow type="math_number"><field name="NUM">1'
          '</field></shadow></value></block></next></block></statement>'
          '</block></next></block></xml>');
    });
  });
}
