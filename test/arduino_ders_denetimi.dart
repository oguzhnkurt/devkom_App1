// ARDUINO DERS DENETIMI — her modulun testi bunu cagiriyor.
//
// Bir Arduino dersinin "icerik dogru mu" sorusunu insan cevapliyor;
// burada yakalanan sey cocugun ilerlemesini FIZIKSEL olarak engelleyen
// ya da kurdugu devrenin hicbir sey yapmadigi durumlar:
//  * dort dilde baslik/alt baslik, adim metinleri;
//  * devre kurma adiminin parcalari breadboard'a sigiyor, cakismiyor;
//    hedeflerin hepsi takilinca devre TAMAM ve kisa devre yok;
//    baslangic devresi henuz tamam degil;
//  * kod adiminin cozumundeki her blok paletinde; cozum bir kart
//    programi; derste kurulan devrede CALISINCA bir sey oluyor (LED
//    yaniyor, buzzer caliyor, servo donuyor ya da seri porta yaziyor).
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/devre/devre_modeli.dart';
import 'package:devkom_app/courses/devre/devre_simulasyonu.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/yurutme/mblock_cozum.dart';
import 'package:devkom_app/courses/yurutme/mblock_uno.dart';
import 'package:devkom_app/services/sound_service.dart';

const _diller = ['tr', 'en', 'de', 'es'];

Iterable<String> _tipler(MBlockBeklenen b) sync* {
  yield b.tip;
  for (final i in b.icerik) {
    yield* _tipler(i);
  }
  for (final g in b.girdiler.values) {
    yield* _tipler(g);
  }
}

/// Programi devrede calistirir; girdileri her beklemede degistirir
/// (buton bas/birak, potansiyometre, isik, sicaklik, mesafe). Bir sey
/// olduysa true.
Future<bool> devredeEtkiVar(Devre devre, List<MBlockBlok> program) async {
  final kart = UnoKarti();
  final sim = DevreSimulasyonu(kart: kart, devre: devre, ses: false);
  var etki = false;
  void bak() {
    final s = sim.sonuc;
    if (s.ledler.values.any((v) => v > 0) ||
        s.buzzerlar.values.any((v) => v > 0) ||
        s.servolar.values.any((v) => v != null && v != 90) ||
        kart.seri.isNotEmpty ||
        kart.parlaklik(13) > 0) {
      etki = true;
    }
  }

  kart.addListener(bak);
  var adim = 0;
  final y = UnoYorumlayici(
    kart: kart,
    butce: 600,
    uyku: (_) async {
      adim++;
      bak();
      final butonlar = devre.parcalar.where((p) => p.tur == ParcaTuru.buton);
      for (final b in butonlar) {
        sim.butonBas(b.id, adim % 4 < 2);
      }
      for (final p in devre.parcalar.where((p) => p.tur == ParcaTuru.pot)) {
        sim.potAyarla(p.id, (adim % 5) / 4);
      }
      sim.isik = adim.isEven ? 5 : 95;
      sim.sicaklik = adim.isEven ? 18 : 38;
      sim.mesafe = adim.isEven ? 8 : 120;
    },
  );
  await y.calistir([program]);
  bak();
  sim.dispose();
  kart.dispose();
  return etki;
}

void arduinoDersleriniDenetle(String ad, List<InteractiveLesson> dersler) {
  setUpAll(() => SoundService.configure(sound: false));

  group(ad, () {
    test('basliklar dort dilde', () {
      for (final d in dersler) {
        for (final l in _diller) {
          expect(d.titleFor(l).trim(), isNotEmpty, reason: '${d.id} $l');
          expect(d.subtitleFor(l).trim(), isNotEmpty, reason: '${d.id} $l');
        }
        expect({d.titleEn, d.titleDe, d.titleEs}.contains(null), isFalse, reason: d.id);
        expect(d.courseId, 'arduino');
        expect(d.id.startsWith('arduino_6_'), isFalse,
            reason: 'arduino_6_* Arduino IDE kursunun on eki');
      }
    });

    test('adim kimlikleri benzersiz', () {
      final ids = dersler.expand((d) => d.steps).map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('coktan secmeli sorular saglam', () {
      for (final s in dersler.expand((d) => d.steps).whereType<MultipleChoiceStep>()) {
        expect(s.correctIndex, inInclusiveRange(0, s.options.length - 1), reason: s.id);
        for (final l in _diller) {
          final t = s.options.map((o) => o.textFor(l)).toList();
          expect(t.toSet().length, t.length, reason: '${s.id} $l');
          expect(s.questionFor(l).trim(), isNotEmpty);
          expect(s.explanationFor(l).trim(), isNotEmpty);
        }
        for (final o in s.options) {
          expect([o.textEn, o.textDe, o.textEs].contains(null), isFalse, reason: s.id);
        }
      }
    });

    test('devre kurma adimlari kurulabiliyor', () {
      for (final s in dersler.expand((d) => d.steps).whereType<DevreKurmaStep>()) {
        // Parcalar breadboard'da ve cakismiyor.
        var d = const Devre();
        for (final p in s.parcalar) {
          expect(d.yerlesebilir(p), isTrue, reason: '${s.id}: ${p.id} yerlesmiyor');
          d = d.parcaEkle(p);
        }
        for (final h in s.hedefler) {
          expect(gecerliUc(h.a) && gecerliUc(h.b), isTrue, reason: '${s.id}: ${h.a}-${h.b}');
          for (final l in _diller) {
            expect(h.metin(l).trim(), isNotEmpty, reason: '${s.id} $l');
          }
        }
        for (final k in s.tamami.kablolar) {
          expect(gecerliUc(k.a) && gecerliUc(k.b), isTrue, reason: '${s.id}: $k');
        }
        expect(s.hedefler, isNotEmpty, reason: s.id);
        expect(devreTamamMi(s.baslangic, s.hedefler), isFalse, reason: '${s.id}: bastan tamam');
        expect(devreTamamMi(s.tamami, s.hedefler), isTrue, reason: '${s.id}: tamami tamam degil');
        expect(devreyiCoz(s.tamami).kisaDevre, isFalse, reason: s.id);
        for (final l in _diller) {
          expect(s.talimatFor(l).trim(), isNotEmpty);
        }
      }
    });

    test('kod adimlari: palet, devre ve calisinca etki', () async {
      for (final s in dersler.expand((d) => d.steps).whereType<BlockBuilderStep>()) {
        final a = s.mblock;
        expect(a, isNotNull, reason: '${s.id}: Arduino kod adimi gercek tezgahla');
        expect(a!.devre, isNotNull, reason: '${s.id}: sahnede devre olmali');
        expect(a.cozum.first.tip, 'dev_kart_acilis', reason: s.id);
        for (final b in a.cozum) {
          for (final t in _tipler(b)) {
            expect(a.bloklar, contains(t), reason: '${s.id}: $t paletde yok');
          }
        }
        expect(s.correctSequence.toSet(), s.availableBlocks.map((b) => b.id).toSet(),
            reason: s.id);
        for (final l in _diller) {
          expect(s.instructionFor(l).trim(), isNotEmpty);
          expect(s.goalFor(l).trim(), isNotEmpty);
        }
        final etki = await devredeEtkiVar(a.devre!, mblockCozumProgrami(a.cozum, 'tr'));
        expect(etki, isTrue, reason: '${s.id}: cozum devrede hicbir sey yapmiyor');
        if (a.hataAvcisi) {
          expect(a.baslangic, isNotNull, reason: s.id);
          expect(mblockCozumDogruMu([mblockCozumProgrami(a.baslangic!, 'tr')], a.cozum), isFalse,
              reason: '${s.id}: hata avcisinin baslangici zaten dogru');
        }
        expect(mblockCozumDogruMu([mblockCozumProgrami(a.cozum, 'tr')], a.cozum), isTrue);
      }
    });
  });
}
