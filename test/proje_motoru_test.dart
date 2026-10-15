// PROJE MOTORU: betikler AYNI ANDA calisiyor, bekleme sanal saatle,
// haberler alicilari baslatiyor, "degiyor mu?" olculuyor, ikizler var,
// tus dugmeleri betik baslatiyor; 3.1 ve 5.1 gercekten oynaniyor.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/scratch_atolye_bloklari.dart';
import 'package:devkom_app/courses/data/scratch_atolyeleri.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';
import 'package:devkom_app/courses/yurutme/atolye_hedefleri.dart';
import 'package:devkom_app/courses/yurutme/blok_yorumlayici.dart';
import 'package:devkom_app/courses/yurutme/kod_yapisi.dart';

final _palet = <ScratchBlock>[
  AtolyeBloklari.bayrak,
  AtolyeBloklari.surekli,
  AtolyeBloklari.tekrarla('4'),
  AtolyeBloklari.tekrarla('5'),
  AtolyeBloklari.tekrarla('10'),
  AtolyeBloklari.xDegistir,
  AtolyeBloklari.yYukari,
  AtolyeBloklari.yAsagi,
  AtolyeBloklari.git10,
  AtolyeBloklari.merhabaDe,
  AtolyeBloklari.bekle1,
  AtolyeBloklari.bekle2,
  AtolyeBloklari.dansSal,
  AtolyeBloklari.dansSalBekle,
  AtolyeBloklari.dansAl,
  AtolyeBloklari.sonrakiKostum,
  AtolyeBloklari.bosluktaTus,
  AtolyeBloklari.sagTus,
  AtolyeBloklari.egerSag,
  AtolyeBloklari.egerKenaraDegiyor,
  AtolyeBloklari.egerDokunuyor,
  AtolyeBloklari.egerZemineDegiyor,
  AtolyeBloklari.hepsiniDurdur,
  AtolyeBloklari.puanArtir,
  AtolyeBloklari.ikizYarat,
  AtolyeBloklari.ikizOlarak,
  AtolyeBloklari.ikiziSil,
  AtolyeBloklari.ortayaGit,
  AtolyeBloklari.git100_50,
  AtolyeBloklari.xSifir,
  AtolyeBloklari.yTepe,
  AtolyeBloklari.yon90,
  AtolyeBloklari.kenardaSek,
  AtolyeBloklari.kay,
  AtolyeBloklari.goster,
  AtolyeBloklari.gizle,
  AtolyeBloklari.nota('60'),
  AtolyeBloklari.fareyeYonel,
  AtolyeBloklari.rastgeleGit,
];

List<ScratchBlock> _bloklar(String kod) =>
    KodYapisi.blokla(KodYapisi.coz(kod), _palet);

ProjeMotoru _motor(String kod,
        {List<KuklaTanimi> kuklalar = const [],
        int tohum = 1,
        int gecikme = 15,
        double sure = ProjeMotoru.varsayilanSure}) =>
    ProjeMotoru(
      yorumlayici: BlokYorumlayici(rastgele: Random(tohum)),
      bloklar: _bloklar(kod),
      kuklalar: kuklalar,
      otomatikGecikme: gecikme,
      sureSiniri: sure,
    )..baslat();

Yurutme _sonuna(ProjeMotoru m) {
  while (!m.bitti) {
    m.kare();
  }
  return m.sonuc();
}

Yurutme _yurut(String kod, {List<KuklaTanimi> kuklalar = const []}) =>
    _sonuna(_motor(kod, kuklalar: kuklalar));

/// Yerinde duran, kodsuz bir Fare.
const _fare = KuklaTanimi(
    ad: 'Fare', gorunum: KuklaGorunumu.fare, x: 100, y: 0, yaricap: 18);

void main() {
  group('eszamanli betikler', () {
    test('iki surekli tekrarla AYNI ANDA donuyor (kare kare sirayla)', () {
      final m = _motor('green_flag forever change_x } '
          'green_flag forever change_y_up }');
      for (var i = 0; i < 5; i++) {
        m.kare();
      }
      final s = m.sonuc().sonSahne;
      expect(s.x, 50);
      expect(s.y, 50);
      // Iz: x ve y adimlari sirayla (once biri bitip sonra oteki degil).
      final ids = m
          .sonuc()
          .adimlar
          .map((a) => a.blokId)
          .where((id) => id.startsWith('change'))
          .toList();
      expect(ids.take(4), ['change_x', 'change_y_up', 'change_x', 'change_y_up']);
    });

    test('surekli tekrarla sure sinirinda duruyor ve bunu soyluyor', () {
      final y = _yurut('green_flag forever change_x }');
      expect(y.butceBitti, isTrue);
      expect(y.sure, closeTo(ProjeMotoru.varsayilanSure, 0.05));
      // Her kare bir tur: 10 saniye x 30 kare.
      expect(y.sonSahne.x, 300 * 10);
    });

    test('tumunu durdur her seyi o anda bitiriyor', () {
      final y = _yurut('green_flag forever change_x } '
          'green_flag wait_1s stop_all');
      expect(y.durduruldu, isTrue);
      expect(y.butceBitti, isFalse);
      expect(y.sure, closeTo(1, 0.05));
      expect(y.sonSahne.x, inInclusiveRange(290, 310));
    });

    test('bekle sanal saatle: 1 saniye = 30 kare', () {
      final m = _motor('green_flag wait_1s say_hello');
      var kare = 0;
      while (m.sonuc().sonSahne.soyledigi == null) {
        m.kare();
        kare++;
      }
      expect(kare, 31, reason: '0. karede bekleme basliyor, 30. karede bitiyor');
      expect(_yurut('green_flag wait_2 say_hello').sure, closeTo(2, 0.05));
    });

    test('ayni tohum ayni yurutme (belirlenimci)', () {
      String iz(int t) {
        final y = _sonuna(_motor(
            'green_flag repeat_10 create_clone } when_clone goto_random',
            tohum: t));
        return y.adimlar.map((a) => '${a.sahne.x},${a.sahne.y}').join(';');
      }

      expect(iz(4), iz(4));
      expect(iz(4), isNot(iz(5)));
    });
  });

  group('haberler', () {
    test('haberini sal: alici baslar, salan betik devam eder', () {
      final y = _yurut('green_flag broadcast_dance say_hello '
          'receive_dance repeat_4 next_costume }');
      expect(y.alinanHaberler, {'dans'});
      expect(y.sonSahne.kostum, 5);
      final ids = y.adimlar.map((a) => a.blokId).toList();
      expect(ids.indexOf('say_hello'), lessThan(ids.indexOf('next_costume')));
    });

    test('haberini sal ve bekle: alicilar bitince devam ediyor', () {
      final y = _yurut('green_flag broadcast_dance_wait say_hello '
          'receive_dance repeat_4 next_costume }');
      final merhaba = y.adimlar.firstWhere((a) => a.blokId == 'say_hello');
      expect(merhaba.sahne.kostum, 5,
          reason: 'dort kostum degisikligi bitmeden Merhaba denmemeli');
      expect(y.olayBloklari['haber:dans'], contains('next_costume'));
    });
  });

  group('degme', () {
    test('kenara degiyor mu? kukla kenara gelince dogru', () {
      final y = _yurut('green_flag goto_center forever move_10 '
          'if_touching_edge stop_all } }');
      expect(y.durduruldu, isTrue);
      // Devi'nin yaricapi 30: x + 30 >= 240.
      expect(y.sonSahne.x, 210);
      final kosullar = y.adimlar
          .where((a) => a.blokId == 'if_touching_edge')
          .map((a) => a.kosulSonucu)
          .toList();
      expect(kosullar.last, isTrue);
      expect(kosullar.where((k) => k == false), isNotEmpty);
    });

    test('baska bir kuklaya degiyor mu? (ad ile)', () {
      final y = _yurut(
          'green_flag forever change_x if_touching change_score stop_all } }',
          kuklalar: [_fare]);
      expect(y.sonSahne.degiskenler['Puan'], 1);
      // (30 + 18) * 0.85 = 40.8: x = 60'ta degiyor, 50'de degmiyor.
      expect(y.sonSahne.x, 60);
    });

    test('gizli kukla degmiyor', () {
      final y = _yurut(
          'green_flag hide forever change_x if_touching stop_all } }',
          kuklalar: [_fare]);
      expect(y.durduruldu, isFalse);
    });

    test('Fare yoksa "Fare e degiyor mu?" yanlis', () {
      final y = _yurut('green_flag repeat_4 if_touching change_score } }');
      expect(y.sonSahne.degiskenler['Puan'], isNull);
    });

    test('renge degiyor mu? yesil zemin seridi', () {
      final y = _yurut('green_flag goto_center forever change_y_down '
          'if_touching_ground stop_all } }');
      // 30 * 0.85 = 25.5: y - 25.5 <= -150.
      expect(y.sonSahne.y, -130);
    });

    test('fare imleci: son dokunulan nokta', () {
      final m = _motor('green_flag goto_center', gecikme: 1000);
      m.kare();
      expect(m.sonuc().sonSahne.x, 0);
      final m2 = ProjeMotoru(
        yorumlayici: BlokYorumlayici(rastgele: Random(1)),
        bloklar: KodYapisi.blokla(
            KodYapisi.coz('green_flag forever point_towards_mouse move_10 }'),
            _palet),
        otomatikGecikme: 1000,
      )..baslat();
      // Fare (kukla) yok: yon degismiyor, Devi saga gidiyor.
      m2.kare();
      expect(m2.sonuc().sonSahne.x, 10);
    });
  });

  group('ikizler', () {
    test('ikiz yaratiliyor, kendi betigini calistiriyor, siliniyor', () {
      final y = _yurut('green_flag goto_100_50 repeat_5 create_clone } '
          'goto_center when_clone wait_1s change_x delete_clone');
      expect(y.klonSayisi, 5);
      expect(y.silinenKlon, 5);
      final ikizAdimi = y.adimlar.firstWhere((a) => a.blokId == 'change_x');
      expect(ikizAdimi.klon, isTrue);
      expect(ikizAdimi.sahne.x, 110,
          reason: 'ikiz yaratildigi andaki yerden (100, 50) basliyor');
      expect(y.sonSahne.x, 0, reason: 'asil kukla ortaya gitti');
      expect(y.olayBloklari['ikiz'], contains('change_x'));
    });

    test('ikiz siniri: ayni anda en fazla 30', () {
      final m = _motor('green_flag forever create_clone }');
      var enCok = 0;
      while (!m.bitti) {
        m.kare();
        enCok = max(enCok, m.canliIkiz);
      }
      expect(enCok, ProjeMotoru.enFazlaIkiz);
      expect(m.sonuc().klonSayisi, ProjeMotoru.enFazlaIkiz);
      expect(m.kuklalar.length, ProjeMotoru.enFazlaIkiz + 1);
    });

    test('asil kukla "bu ikizi sil" ile silinmiyor', () {
      final y = _yurut('green_flag delete_clone say_hello');
      expect(y.sonSahne.soyledigi, isNotNull);
      expect(y.silinenKlon, 0);
    });
  });

  group('tus dugmeleri', () {
    test('tusa basinca o tusun betigi calisiyor', () {
      final m = _motor('green_flag say_hello when_key_space change_y_up',
          gecikme: 1000);
      for (var i = 0; i < 5; i++) {
        m.kare();
      }
      expect(m.bitti, isFalse, reason: 'tus betigi var: sahne bekliyor');
      expect(m.tuslar, ['space']);
      m.tusBas('space');
      m.kare();
      m.tusBirak('space');
      final y = m.sonuc();
      expect(y.sonSahne.y, 10);
      expect(y.calisanOlaylar, ['bayrak', 'tus:space']);
      expect(m.elleOynandi, isTrue);
      // Cocuk oynuyor: son dokunustan bir sure sonra bitiyor.
      while (!m.bitti) {
        m.kare();
      }
      expect(m.kareNo, lessThan(6 + ProjeMotoru.elleBeklemeKaresi + 3));
    });

    test('"tus basili mi?" basili tutulan tusu okuyor', () {
      final m = _motor('green_flag forever if_right change_x } }',
          gecikme: 1000);
      m.kare();
      m.tusBas('right');
      for (var i = 0; i < 3; i++) {
        m.kare();
      }
      m.tusBirak('right');
      for (var i = 0; i < 3; i++) {
        m.kare();
      }
      expect(m.sonuc().sonSahne.x, 30);
    });

    test('kimse basmazsa otomatik oyuncu her tusa bir kez basiyor', () {
      final y = _yurut('green_flag say_hello when_key_right change_x '
          'when_key_space change_y_up');
      expect(y.calisanOlaylar, ['bayrak', 'tus:right', 'tus:space']);
      expect(y.sonSahne.x, 10);
      expect(y.sonSahne.y, 10);
    });
  });

  group('hareket ve gorunum bloklari', () {
    test('x yap, y yap, git, kay', () {
      final y = _yurut('green_flag set_x_0 set_y_170 goto_100_50 glide_1_0_0');
      final ids = y.adimlar.map((a) => a.blokId).toList();
      expect(y.adimlar[ids.indexOf('set_y_170')].sahne.y, 170);
      expect(y.adimlar[ids.indexOf('goto_100_50')].sahne.x, 100);
      expect(y.sonSahne.x, 0);
      expect(y.sonSahne.y, 0);
      expect(y.sure, closeTo(1, 0.1), reason: 'kayma 1 saniye suruyor');
    });

    test('kayarken kukla ara noktalardan geciyor', () {
      final m = _motor('green_flag goto_100_50 glide_1_0_0');
      for (var i = 0; i < 16; i++) {
        m.kare();
      }
      expect(m.kuklalar.single.sahne.x, closeTo(50, 4));
    });

    test('kenara geldiyse sek: yon donuyor, kukla sahnede kaliyor', () {
      final y = _sonuna(_motor('green_flag point_90 forever move_10 '
          'edge_bounce }', sure: 2));
      final xler = y.adimlar.map((a) => a.sahne.x);
      expect(xler.reduce(max), lessThanOrEqualTo(210));
      expect(y.adimlar.any((a) => a.sahne.yon == 270), isTrue);
    });

    test('goster / gizle ve nota', () {
      final m = _motor('green_flag hide wait_1s show play_note_60');
      m.kare();
      expect(m.kuklalar.single.sahne.gorunur, isFalse);
      while (m.sonuc().adimlar.last.blokId != 'play_note_60') {
        m.kare();
      }
      expect(m.kuklalar.single.sahne.gorunur, isTrue);
      expect(m.kuklalar.single.notaCaliyor(m.zaman), isTrue);
    });
  });

  group('3.1 ve 5.1 gercek oyunlar', () {
    AtolyeSonucu calistir(ProjeAtolyesiStep a, int t) =>
        AtolyeDenetimi.atolyede(a, KodYapisi.coz(a.ornekCozum),
            rastgele: Random(t));

    test('3.1 Yakala: Devi Fare\'yi kovaliyor, 5 kez yakaliyor, duruyor', () {
      for (var t = 0; t < 12; t++) {
        final s = calistir(ScratchAtolyeleri.yakalaOyunu, t);
        expect(AtolyeDenetimi.durumlar(ScratchAtolyeleri.yakalaOyunu.hedefler, s),
            everyElement(isTrue),
            reason: 'tohum $t');
        expect(s.yurutme.sonSahne.degiskenler['Puan'], 5);
        expect(s.yurutme.durduruldu, isTrue);
        expect(s.yurutme.sure, lessThan(30), reason: 'tohum $t');
      }
    });

    test('3.1: Devi Fare\'den yavassa (1 adim) yakalayamiyor', () {
      final a = ScratchAtolyeleri.yakalaOyunu;
      final s = AtolyeDenetimi.atolyede(
          a,
          KodYapisi.coz(a.ornekCozum.replaceFirst('move_10=6', 'move_10=1')),
          rastgele: Random(2));
      expect(AtolyeDenetimi.durumlar(a.hedefler, s)[2], isFalse);
    });

    test('5.1 Elma Yagmuru: ikizler duser, kase en az 5 tanesini tutar', () {
      for (var t = 0; t < 12; t++) {
        final s = calistir(ScratchAtolyeleri.elmaYagmuru, t);
        expect(AtolyeDenetimi.durumlar(ScratchAtolyeleri.elmaYagmuru.hedefler, s),
            everyElement(isTrue),
            reason: 'tohum $t');
        expect(s.yurutme.klonSayisi, 10);
        expect(s.yurutme.silinenKlon, 10);
      }
    });

    test('5.1: ikizler yere degince silinmezse "kendini silsin" tutmuyor', () {
      final a = ScratchAtolyeleri.elmaYagmuru;
      final kod =
          a.ornekCozum.replaceFirst('if_touching_ground delete_clone }', '');
      // Kase kimse oynamadan yerinde duruyor: elmalarin cogu yere dusuyor.
      final s = AtolyeDenetimi.calistir(KodYapisi.coz(kod), a.palet,
          rastgele: Random(1),
          ana: a.anaKukla,
          kuklalar: a.kuklalar,
          sureSiniri: a.sureSiniri);
      expect(s.yurutme.silinenKlon, lessThan(10));
      expect(AtolyeDenetimi.durumlar(a.hedefler, s)[3], isFalse);
      expect(s.yurutme.butceBitti, isTrue,
          reason: 'silinmeyen ikizler sonsuza duser: sure siniri');
    });

    test('5.1: cocuk oklara basinca otomatik oyuncu susuyor', () {
      final a = ScratchAtolyeleri.elmaYagmuru;
      final m = ProjeMotoru(
        yorumlayici: BlokYorumlayici(rastgele: Random(1)),
        bloklar: KodYapisi.blokla(KodYapisi.coz(a.ornekCozum), a.palet),
        ana: a.anaKukla,
        kuklalar: a.kuklalar,
        oyuncu: a.oyuncu,
        sureSiniri: a.sureSiniri,
      )..baslat();
      expect(m.tuslar, containsAll(['right', 'left']));
      for (var i = 0; i < 20; i++) {
        m.kare();
      }
      expect(m.otomatikOynuyor, isTrue);
      final kase = m.kuklalar.firstWhere((k) => k.tanim.ad == 'Kase');
      m.tusBas('left');
      final x0 = kase.sahne.x;
      for (var i = 0; i < 5; i++) {
        m.kare();
      }
      expect(m.otomatikOynuyor, isFalse);
      expect(kase.sahne.x, x0 - 40);
    });
  });
}
