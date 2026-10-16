import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/devre/devre_modeli.dart';

/// Pin 13 -> LED (c12/c13) -> 220 ohm (d13..g13 kanalin ustunden) ->
/// j13 -> ust eksi hat -> GND.
Devre _ledDevresi({bool ters = false, bool direncsiz = false}) => Devre(
      parcalar: [
        Parca.led('L1', 'c12', ters: ters),
        if (!direncsiz) Parca.direnc('R1', 'd13', dikey: true),
      ],
      kablolar: [
        const Kablo('D13', 'a12'),
        Kablo(direncsiz ? 'a13' : 'j13', 'U-13'),
        const Kablo('U-1', 'GND'),
      ],
    );

const _yuksek = DevreCikislari(dijital: {13: true});

void main() {
  group('uclar', () {
    test('delik ve ray cozumu', () {
      expect(delikCoz('a1'), (0, 1));
      expect(delikCoz('j30'), (9, 30));
      expect(delikCoz('k1'), isNull);
      expect(delikCoz('a31'), isNull);
      expect(rayCoz('U-5'), (true, false, 5));
      expect(rayCoz('L+12'), isNull, reason: '6. sutunlarda delik yok');
      expect(temelDugum('a5'), temelDugum('e5'));
      expect(temelDugum('e5') == temelDugum('f5'), isFalse,
          reason: 'kanal iki yarimi ayiriyor');
      expect(temelDugum('GND2'), temelDugum('GND'));
    });

    test('parca bacaklari', () {
      final l = Parca.led('L', 'b10');
      expect(l.bacakUclari, {'anot': 'b10', 'katot': 'b11'});
      expect(Parca.led('L', 'b10', ters: true).bacakUclari['anot'], 'b11');
      expect(Parca.direnc('R', 'd5', dikey: true).bacakUclari,
          {'u1': 'd5', 'u2': 'g5'});
      expect(Parca.led('L', 'b30').yerlesimGecerli, isFalse);
      expect(Parca.servo('S').bacakUclari['sinyal'], 'S.sinyal');
    });

    test('yerlesim cakismasi', () {
      final d = Devre(parcalar: [Parca.led('L1', 'b10')]);
      expect(d.yerlesebilir(Parca.led('L2', 'b11')), isFalse);
      expect(d.yerlesebilir(Parca.led('L2', 'b12')), isTrue);
      expect(d.kabloTakilabilir('b10'), isFalse);
      expect(d.kabloTakilabilir('a10'), isTrue);
      expect(d.kabloTakilabilir('D13'), isTrue);
    });

    test('json gidip geliyor', () {
      final d = _ledDevresi();
      final e = Devre.coz(d.kodla());
      expect(e.parcalar.length, 2);
      expect(e.parcalar[1].dikey, isTrue);
      expect(e.kablolar, d.kablolar);
      expect(Devre.coz('bozuk').bosMu, isTrue);
    });
  });

  group('LED', () {
    test('pin yuksekken yanar, dusukken soner', () {
      expect(devreyiCoz(_ledDevresi(), cikislar: _yuksek).ledler['L1'], 1);
      expect(
          devreyiCoz(_ledDevresi(),
                  cikislar: const DevreCikislari(dijital: {13: false}))
              .ledler['L1'],
          0);
      expect(devreyiCoz(_ledDevresi()).ledler['L1'], 0,
          reason: 'program yokken pin bos');
    });

    test('PWM yari parlak', () {
      final s = devreyiCoz(_ledDevresi(),
          cikislar: const DevreCikislari(pwm: {13: 51}));
      expect(s.ledler['L1'], closeTo(0.2, 0.01));
    });

    test('ters LED yanmaz ve uyari verir', () {
      final s = devreyiCoz(_ledDevresi(ters: true), cikislar: _yuksek);
      expect(s.ledler['L1'], 0);
      expect(s.uyarilar,
          contains(const DevreUyarisi(DevreUyariTuru.ledTers, parca: 'L1')));
    });

    test('direncsiz LED yanar ama uyari verir', () {
      final s = devreyiCoz(_ledDevresi(direncsiz: true), cikislar: _yuksek);
      expect(s.ledler['L1'], 1);
      expect(s.uyarilar.map((u) => u.tur),
          contains(DevreUyariTuru.ledDirencsiz));
    });

    test('10k direncle sonuk', () {
      final d = _ledDevresi();
      final d2 = d.parcaDegistir(d.parca('R1')!.kopya(ohm: 10000));
      final p = devreyiCoz(d2, cikislar: _yuksek).ledler['L1']!;
      expect(p, greaterThan(0));
      expect(p, lessThan(0.3));
    });

    test('iki bacak ayni seritte', () {
      final d = Devre(parcalar: [
        const Parca(id: 'L1', tur: ParcaTuru.led, sutun: 5, satir: 0)
            .kopya(),
      ], kablolar: const [
        Kablo('D9', 'a5'),
      ]);
      // Dikey bir LED olmadigi icin ayni seridi kablo ile kuralim.
      final d2 = d.kabloEkle(const Kablo('c6', 'D9'));
      final s = devreyiCoz(d2,
          cikislar: const DevreCikislari(dijital: {9: true}));
      expect(s.ledler['L1'], 0);
      expect(s.uyarilar.map((u) => u.tur),
          contains(DevreUyariTuru.ledAyniDugum));
    });

    test('5V ile GND kisa devre', () {
      final s = devreyiCoz(const Devre(kablolar: [
        Kablo('5V', 'U+1'),
        Kablo('U+2', 'GND'),
      ]));
      expect(s.kisaDevre, isTrue);
      expect(devreyiCoz(_ledDevresi(), cikislar: _yuksek).kisaDevre, isFalse);
    });
  });

  group('girisler', () {
    // Buton e10/f10 - e12/f12; sol taraf 5V, sag taraf pin 2 ve 10k ile GND.
    Devre buton() => Devre(parcalar: [
          Parca.buton('B1', 'e10'),
          Parca.direnc('R1', 'a12', ohm: 10000),
        ], kablolar: const [
          Kablo('5V', 'U+1'),
          Kablo('U-1', 'GND'),
          Kablo('j10', 'U+10'),
          Kablo('c12', 'D2'),
          Kablo('a15', 'L-15'),
          Kablo('L-1', 'U-2'),
        ]);

    test('cekme direncli buton', () {
      expect(devreyiCoz(buton()).dijitalOku(2), isFalse);
      expect(
          devreyiCoz(buton(),
                  girdiler: const DevreGirdileri(basililar: {'B1'}))
              .dijitalOku(2),
          isTrue);
      expect(devreyiCoz(buton(),
              girdiler: const DevreGirdileri(basililar: {'B1'}))
          .kisaDevre, isFalse);
    });

    test('bos pin', () {
      final s = devreyiCoz(const Devre());
      expect(s.pinBagli('D2'), isFalse);
      expect(s.dijitalOku(2), isFalse);
      expect(s.analogOku(0), 0);
    });

    test('potansiyometre', () {
      final d = Devre(parcalar: [Parca.pot('P1', 'a20')], kablolar: const [
        Kablo('5V', 'e20'),
        Kablo('GND', 'e22'),
        Kablo('A0', 'e21'),
      ]);
      int oku(double k) => devreyiCoz(d,
              girdiler: DevreGirdileri(potlar: {'P1': k}))
          .analogOku(0);
      expect(oku(0), 1023);
      expect(oku(1), 0);
      expect(oku(0.5), closeTo(511, 2));
    });

    test('LDR + 10k bolucu: aydinlik yuksek, karanlik dusuk', () {
      final d = Devre(parcalar: [
        Parca.ldr('IS', 'a3'),
        Parca.direnc('R1', 'a5', ohm: 10000),
      ], kablolar: const [
        Kablo('5V', 'e3'),
        Kablo('A0', 'e5'),
        Kablo('e8', 'GND'),
      ]);
      final aydinlik = devreyiCoz(d,
          girdiler: const DevreGirdileri(isik: 100)).analogOku(0);
      final karanlik = devreyiCoz(d,
          girdiler: const DevreGirdileri(isik: 0)).analogOku(0);
      expect(aydinlik, greaterThan(800));
      expect(karanlik, lessThan(150));
    });

    test('sicaklik sensoru', () {
      final d = Devre(parcalar: [Parca.sicaklik('T1', 'a5')], kablolar: const [
        Kablo('5V', 'e5'),
        Kablo('A1', 'e6'),
        Kablo('e7', 'GND'),
      ]);
      final v = devreyiCoz(d, girdiler: const DevreGirdileri(sicaklik: 30))
          .analogOku(1);
      expect(analogdanSicaklik(v), closeTo(30, 0.6));
      // Gucsuz sensor okunmuyor ve uyari veriyor.
      final d2 = Devre(parcalar: d.parcalar, kablolar: const [
        Kablo('A1', 'e6'),
        Kablo('e7', 'GND'),
      ]);
      final s = devreyiCoz(d2);
      expect(s.analogOku(1), 0);
      expect(s.uyarilar.map((u) => u.tur),
          contains(DevreUyariTuru.sensorGucsuz));
    });

    test('mesafe sensoru pinleri dogruysa okunur', () {
      final d = Devre(parcalar: [Parca.mesafe('M1', 'a10')], kablolar: const [
        Kablo('5V', 'e10'),
        Kablo('D12', 'e11'),
        Kablo('D11', 'e12'),
        Kablo('e13', 'GND'),
      ]);
      final s = devreyiCoz(d, girdiler: const DevreGirdileri(mesafe: 25));
      expect(s.mesafe(12, 11), 25);
      expect(s.mesafe(13, 12), 0);
    });

    test('servo', () {
      final d = Devre(parcalar: [Parca.servo('S1')], kablolar: const [
        Kablo('S1.gnd', 'GND'),
        Kablo('S1.vcc', '5V'),
        Kablo('S1.sinyal', 'D9'),
      ]);
      expect(
          devreyiCoz(d, cikislar: const DevreCikislari(servo: {9: 120}))
              .servolar['S1'],
          120);
      final gucsuz = Devre(parcalar: d.parcalar, kablolar: const [
        Kablo('S1.sinyal', 'D9'),
      ]);
      final s = devreyiCoz(gucsuz,
          cikislar: const DevreCikislari(servo: {9: 120}));
      expect(s.servolar['S1'], isNull);
      expect(s.uyarilar.map((u) => u.tur), contains(DevreUyariTuru.servoGucsuz));
    });

    test('buzzer tonla calar', () {
      final d = Devre(parcalar: [Parca.buzzer('Z1', 'a20')], kablolar: const [
        Kablo('D8', 'e20'),
        Kablo('e23', 'GND'),
      ]);
      expect(
          devreyiCoz(d, cikislar: const DevreCikislari(ton: {8: 440}))
              .buzzerlar['Z1'],
          440);
      expect(devreyiCoz(d).buzzerlar['Z1'], 0);
    });
  });

  test('rehberli hedefler serit esdegerligine bakiyor', () {
    final hedef = [
      const HedefBaglanti('D13', 'c12', tr: '', en: '', de: '', es: ''),
    ];
    expect(devreTamamMi(_ledDevresi(), hedef), isTrue,
        reason: 'kablo a12de ama c12 ile ayni serit');
    expect(devreTamamMi(const Devre(), hedef), isFalse);
  });
}
