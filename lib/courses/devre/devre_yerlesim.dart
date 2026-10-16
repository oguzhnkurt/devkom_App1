import 'dart:math' as math;
import 'dart:ui';

import '../sahne/uno_karti.dart' show UnoOlcu;
import 'devre_modeli.dart';

/// Devre sahnesinin DUNYA olculeri.
///
/// Birim: breadboard delik araligi (2,54 mm = 1). Uno ustte (dijital
/// pinler yukarida, guc ve analog pinler asagida), breadboard altinda;
/// devrede servo varsa breadboard'un altinda bir servo seridi.
///
/// Cizim ([DevreBoyaci]) ve dokunma ([DevreDuzenleyici]) AYNI yerlesimi
/// kullaniyor: bir deligin ekrandaki yeri ile parmagin degdigi yer
/// arasinda iki ayri hesap yok.
class DevreDunyasi {
  const DevreDunyasi({this.servoSayisi = 0});

  /// Servo seridindeki yuva sayisi (0 = serit yok).
  final int servoSayisi;

  factory DevreDunyasi.icin(Devre d) {
    var n = 0;
    for (final p in d.parcalar) {
      if (p.tur == ParcaTuru.servo) n = math.max(n, p.sutun + 1);
    }
    return DevreDunyasi(servoSayisi: n);
  }

  static const double bbW = 33.2;
  static const double bbH = 17.3;

  /// 0,1 mm -> dunya birimi.
  static const double unoS = 1 / 25.4;
  static const double unoW = UnoOlcu.kartW * unoS;
  static const double unoH = UnoOlcu.kartH * unoS;

  /// Uno'nun sol ust kosesi (sag kenara yakin; solda USB kablosu).
  static const Offset unoO = Offset(bbW - unoW - 0.5, 0.7);

  /// Breadboard'un ustu.
  static const double bbY = 0.7 + unoH + 2.8;

  static const double servoH = 6.2;
  static const double servoW = 10.4;

  double get genislik => bbW;

  double get yukseklik =>
      bbY + bbH + (servoSayisi > 0 ? 0.8 + servoH : 0.4);

  Size get boyut => Size(genislik, yukseklik);

  Rect get breadboard => const Rect.fromLTWH(0, bbY, bbW, bbH);

  Rect get uno => Rect.fromLTWH(unoO.dx, unoO.dy, unoW, unoH);

  /// k. servonun govdesi.
  Rect servoKutusu(int k) =>
      Rect.fromLTWH(7.2 + k * (servoW + 4.5), bbY + bbH + 0.8, servoW, servoH);

  /// Breadboard sutununun x'i.
  static double sutunX(int c) => 1.1 + c;

  /// Satir indeksinin (0 = a) y'si.
  static double satirY(int r) => bbY + (r >= 5 ? 3.7 + (9 - r) : 9.7 + (4 - r));

  /// Ray satirinin y'si.
  static double rayY(bool ust, bool arti) =>
      bbY + (ust ? (arti ? 1.95 : 1.05) : (arti ? 16.35 : 15.45));

  static Offset _uno(Offset o) => unoO + o * unoS;

  /// Uno pininin delik merkezi.
  static Offset? unoPini(String pin) {
    final d = dijitalPinNo(pin);
    if (d != null && d >= 0 && d <= 13) return _uno(UnoOlcu.dijitalPin(d));
    final a = analogPinNo(pin);
    if (a != null && a >= 0 && a <= 5) {
      return _uno(Offset(UnoOlcu.analogX + UnoOlcu.adim * (a + 0.5),
          UnoOlcu.altY + UnoOlcu.baslikH / 2));
    }
    switch (pin) {
      case 'GND':
        return _uno(Offset(UnoOlcu.dijital1X + UnoOlcu.adim * 3.5,
            UnoOlcu.ustY + UnoOlcu.baslikH / 2));
      case '3V3':
        return _uno(UnoOlcu.gucPin(3));
      case '5V':
        return _uno(UnoOlcu.gucPin(4));
      case 'GND1':
        return _uno(UnoOlcu.gucPin(5));
      case 'GND2':
        return _uno(UnoOlcu.gucPin(6));
      case 'VIN':
        return _uno(UnoOlcu.gucPin(7));
    }
    return null;
  }

  /// Uno pini ust baslikta mi (kablo yukari cikar).
  static bool ustBaslik(String pin) =>
      pin == 'GND' || dijitalPinNo(pin) != null;

  /// Servo ucunun yeri (servo govdesinin solundaki fis).
  Offset? servoUcu(Parca p, String bacak) {
    final i = const ['gnd', 'vcc', 'sinyal'].indexOf(bacak);
    if (i < 0) return null;
    final r = servoKutusu(p.sutun);
    return Offset(r.left - 4.6, r.top + 1.8 + i * 1.3);
  }

  /// Bir ucun dunya konumu; bilinmeyen uc null.
  Offset? konum(String uc, [Devre? devre]) {
    final d = delikCoz(uc);
    if (d != null) return Offset(sutunX(d.$2), satirY(d.$1));
    final r = rayCoz(uc);
    if (r != null) return Offset(sutunX(r.$3), rayY(r.$1, r.$2));
    final u = unoPini(uc);
    if (u != null) return u;
    final nokta = uc.indexOf('.');
    if (nokta > 0 && devre != null) {
      final p = devre.parca(uc.substring(0, nokta));
      if (p != null && p.tur.kartDisi) {
        return servoUcu(p, uc.substring(nokta + 1));
      }
    }
    return null;
  }

  /// Bir parcanin govdesinin kapladigi alan (secmek icin).
  Rect parcaKutusu(Parca p) {
    if (p.tur == ParcaTuru.servo) {
      final r = servoKutusu(p.sutun);
      return Rect.fromLTRB(r.left - 5.2, r.top, r.right, r.bottom);
    }
    final uclar = p.bacakUclari.values.whereType<String>().map(konum).whereType<Offset>().toList();
    if (uclar.isEmpty) return Rect.zero;
    var r = Rect.fromPoints(uclar.first, uclar.first);
    for (final u in uclar) {
      r = r.expandToInclude(Rect.fromCenter(center: u, width: 0.01, height: 0.01));
    }
    switch (p.tur) {
      case ParcaTuru.led:
        return Rect.fromLTRB(r.left - 0.5, r.top - 2.4, r.right + 0.5, r.bottom + 0.4);
      case ParcaTuru.direnc:
        return r.inflate(0.45);
      case ParcaTuru.buton:
        return r.inflate(0.55);
      case ParcaTuru.pot:
        return Rect.fromLTRB(r.left - 0.6, r.top - 3.1, r.right + 0.6, r.bottom + 0.4);
      case ParcaTuru.buzzer:
        return Rect.fromLTRB(r.left - 0.3, r.top - 1.9, r.right + 0.3, r.bottom + 1.9);
      case ParcaTuru.ldr:
        return Rect.fromLTRB(r.left - 0.4, r.top - 1.9, r.right + 0.4, r.bottom + 0.4);
      case ParcaTuru.sicaklik:
        return Rect.fromLTRB(r.left - 0.6, r.top - 2.1, r.right + 0.6, r.bottom + 0.4);
      case ParcaTuru.mesafe:
        return Rect.fromLTRB(r.left - 1.9, r.top - 4.6, r.right + 1.9, r.bottom + 0.4);
      case ParcaTuru.servo:
        return r;
    }
  }

  /// Kablo takilabilen butun uclar (delikler, ray delikleri, pinler,
  /// kart disi parca uclari).
  Iterable<String> uclar(Devre devre) sync* {
    for (var r = 0; r < 10; r++) {
      for (var c = 1; c <= devreSutunSayisi; c++) {
        yield delik(devreSatirlari[r], c);
      }
    }
    for (var c = 1; c <= devreSutunSayisi; c++) {
      if (!rayDeligiVar(c)) continue;
      yield 'U-$c';
      yield 'U+$c';
      yield 'L-$c';
      yield 'L+$c';
    }
    yield* unoPinleri;
    for (final p in devre.parcalar) {
      if (p.tur.kartDisi) yield* p.bacakUclari.values.whereType<String>();
    }
  }

  /// [nokta]ya en yakin uc ([yaricap] icinde); yoksa null.
  String? enYakinUc(Offset nokta, Devre devre, {double yaricap = 0.75}) {
    String? en;
    var enD = yaricap * yaricap;
    for (final u in uclar(devre)) {
      final k = konum(u, devre);
      if (k == null) continue;
      final d = (k - nokta).distanceSquared;
      if (d < enD) {
        enD = d;
        en = u;
      }
    }
    return en;
  }

  /// [nokta]ya en yakin breadboard deligi (parca yerlestirirken).
  static String? enYakinDelik(Offset nokta, {double yaricap = 1.2}) {
    String? en;
    var enD = yaricap * yaricap;
    for (var r = 0; r < 10; r++) {
      for (var c = 1; c <= devreSutunSayisi; c++) {
        final d = (Offset(sutunX(c), satirY(r)) - nokta).distanceSquared;
        if (d < enD) {
          enD = d;
          en = delik(devreSatirlari[r], c);
        }
      }
    }
    return en;
  }

  /// Kablonun yolu: iki ucu yumusak bir egriyle birlestiriyor. Ust
  /// baslik pinlerinden cikan kablo once yukari, guc basligindan cikan
  /// asagi kivriliyor (karti delip gecmesin diye).
  Path kabloYolu(Offset a, Offset b, String ua, String ub) {
    final l = (b - a).distance;
    Offset yon(String u, Offset p, Offset diger) {
      if (unoPini(u) != null) {
        return Offset(0, ustBaslik(u) ? -1 : 1);
      }
      if (u.contains('.')) return const Offset(-1, 0);
      return Offset(0, diger.dy < p.dy ? -1 : 1);
    }

    final k = math.min(6.0, math.max(1.2, l * 0.35));
    final c1 = a + yon(ua, a, b) * k;
    final c2 = b + yon(ub, b, a) * k;
    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy);
  }

  /// Bir noktaya en yakin kablo (indeks) [yaricap] icinde.
  int? enYakinKablo(Offset nokta, Devre devre, {double yaricap = 0.55}) {
    int? en;
    var enD = yaricap;
    for (var i = 0; i < devre.kablolar.length; i++) {
      final k = devre.kablolar[i];
      final a = konum(k.a, devre), b = konum(k.b, devre);
      if (a == null || b == null) continue;
      final yol = kabloYolu(a, b, k.a, k.b);
      for (final m in yol.computeMetrics()) {
        for (var t = 0.0; t <= m.length; t += 0.25) {
          final p = m.getTangentForOffset(t)?.position;
          if (p == null) continue;
          final d = (p - nokta).distance;
          if (d < enD) {
            enD = d;
            en = i;
          }
        }
      }
    }
    return en;
  }
}
