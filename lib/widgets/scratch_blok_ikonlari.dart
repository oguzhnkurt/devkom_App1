import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

/// Scratch blok simgeleri — Scratch'in KENDI SVG yollari.
///
/// Yollar `assets/mblock/media/` altindaki scratch-blocks dosyalarindan
/// (Apache-2.0) birebir kopyalandi: yesil bayrak, saga don, tekrar oku ve
/// acilir menu oku. Uygulamada SVG paketi yok; bu kucuk okuyucu yalnizca
/// bu yollarin kullandigi komutlari (M L H V C S A Z, buyuk/kucuk)
/// taniyor. Material'in `Icons.flag` simgesi Scratch'in bayragina hic
/// benzemiyordu.
///
/// [kalem] ve [muzik] eklenti simgeleri: Scratch 3'te eklenti bloklari
/// (Kalem, Muzik) satirin solunda 40x40 bir simge ve onun saginda dikey
/// bir ayrac cizgisiyle basliyor. Bu iki simge SVG dosyasi degil, Path
/// ile burada cizildi ([_kalemCiz], [_muzikCiz]).
enum ScratchIkon { bayrak, donSag, tekrar, acilirOk, kalem, muzik }

class _IkonKatmani {
  const _IkonKatmani(this.renk, this.yol, {this.saydamlik = 1});
  final Color renk;
  final String yol;
  final double saydamlik;
}

class _IkonTanimi {
  const _IkonTanimi(this.genislik, this.yukseklik, this.katmanlar);
  final double genislik;
  final double yukseklik;
  final List<_IkonKatmani> katmanlar;
}

const Map<ScratchIkon, _IkonTanimi> _ikonlar = {
  // media/green-flag.svg
  ScratchIkon.bayrak: _IkonTanimi(24, 24, [
    _IkonKatmani(
        Color(0xFF45993D),
        'M20.8,3.7c-0.4-0.2-0.9-0.1-1.2,0.2c-2,1.6-4.8,1.6-6.8,0c-2.3-1.9-5.6-2.3-8.3-1V2.5c0-0.6-0.5-1-1-1'
        's-1,0.4-1,1v18.8c0,0.5,0.5,1,1,1h0.1c0.5,0,1-0.5,1-1v-6.4c1-0.7,2.1-1.2,3.4-1.3c1.2,0,2.4,0.4,3.4,1.2c2.9,2.3,7,2.3,9.8,0'
        'c0.3-0.2,0.4-0.5,0.4-0.9V4.7C21.6,4.2,21.3,3.8,20.8,3.7z M20.5,13.9C20.5,13.9,20.5,13.9,20.5,13.9C18,16,14.4,16,11.9,14'
        'c-1.1-0.9-2.5-1.4-4-1.4c-1.2,0.1-2.3,0.5-3.4,1.1V4C7,2.6,10,2.9,12.2,4.6c2.4,1.9,5.7,1.9,8.1,0c0.1,0,0.1,0,0.2,0'
        'c0,0,0.1,0.1,0.1,0.1L20.5,13.9z'),
    _IkonKatmani(
        Color(0xFF4CBF56),
        'M20.6,4.8l-0.1,9.1c0,0,0,0.1,0,0.1c-2.5,2-6.1,2-8.6,0c-1.1-0.9-2.5-1.4-4-1.4c-1.2,0.1-2.3,0.5-3.4,1.1V4'
        'C7,2.6,10,2.9,12.2,4.6c2.4,1.9,5.7,1.9,8.1,0c0.1,0,0.1,0,0.2,0C20.5,4.7,20.6,4.7,20.6,4.8z'),
  ]),
  // media/rotate-right.svg
  ScratchIkon.donSag: _IkonTanimi(24, 24, [
    _IkonKatmani(
        Color(0xFF3D79CC),
        'M22.68,12.2a1.6,1.6,0,0,1-1.27.63H13.72a1.59,1.59,0,0,1-1.16-2.58l1.12-1.41a4.82,4.82,0,0,0-3.14-.77,'
        '4.31,4.31,0,0,0-2,.8,4.25,4.25,0,0,0-1.34,1.73,5.06,5.06,0,0,0,.54,4.62A5.58,5.58,0,0,0,12,17.74h0a2.26,'
        '2.26,0,0,1-.16,4.52A10.25,10.25,0,0,1,3.74,18,10.14,10.14,0,0,1,2.25,8.78,9.7,9.7,0,0,1,5.08,4.64,9.92,'
        '9.92,0,0,1,9.66,2.5a10.66,10.66,0,0,1,7.72,1.68l1.08-1.35a1.57,1.57,0,0,1,1.24-.6,1.6,1.6,0,0,1,1.54,'
        '1.21l1.7,7.37A1.57,1.57,0,0,1,22.68,12.2Z'),
    _IkonKatmani(
        Color(0xFFFFFFFF),
        'M21.38,11.83H13.77a.59.59,0,0,1-.43-1l1.75-2.19a5.9,5.9,0,0,0-4.7-1.58,5.07,5.07,0,0,0-4.11,3.17A6,6,0,'
        '0,0,7,15.77a6.51,6.51,0,0,0,5,2.92,1.31,1.31,0,0,1-.08,2.62,9.3,9.3,0,0,1-7.35-3.82A9.16,9.16,0,0,1,3.17,'
        '9.12,8.51,8.51,0,0,1,5.71,5.4,8.76,8.76,0,0,1,9.82,3.48a9.71,9.71,0,0,1,7.75,2.07l1.67-2.1a.59.59,0,0,1,'
        '1,.21L22,11.08A.59.59,0,0,1,21.38,11.83Z'),
  ]),
  // media/repeat.svg
  ScratchIkon.tekrar: _IkonTanimi(24, 24, [
    _IkonKatmani(
        Color(0xFFCF8B17),
        'M23.3,11c-0.3,0.6-0.9,1-1.5,1h-1.6c-0.1,1.3-0.5,2.5-1.1,3.6c-0.9,1.7-2.3,3.2-4.1,4.1'
        'c-1.7,0.9-3.6,1.2-5.5,0.9c-1.8-0.3-3.5-1.1-4.9-2.3c-0.7-0.7-0.7-1.9,0-2.6c0.6-0.6,1.6-0.7,2.3-0.2H7c0.9,0.6,1.9,0.9,2.9,0.9'
        's1.9-0.3,2.7-0.9c1.1-0.8,1.8-2.1,1.8-3.5h-1.5c-0.9,0-1.7-0.7-1.7-1.7c0-0.4,0.2-0.9,0.5-1.2l4.4-4.4c0.7-0.6,1.7-0.6,2.4,0L23,9.2'
        'C23.5,9.7,23.6,10.4,23.3,11z'),
    _IkonKatmani(
        Color(0xFFFFFFFF),
        'M21.8,11h-2.6c0,1.5-0.3,2.9-1,4.2c-0.8,1.6-2.1,2.8-3.7,3.6c-1.5,0.8-3.3,1.1-4.9,0.8c-1.6-0.2-3.2-1-4.4-2.1'
        'c-0.4-0.3-0.4-0.9-0.1-1.2c0.3-0.4,0.9-0.4,1.2-0.1l0,0c1,0.7,2.2,1.1,3.4,1.1s2.3-0.3,3.3-1c0.9-0.6,1.6-1.5,2-2.6'
        'c0.3-0.9,0.4-1.8,0.2-2.8h-2.4c-0.4,0-0.7-0.3-0.7-0.7c0-0.2,0.1-0.3,0.2-0.4l4.4-4.4c0.3-0.3,0.7-0.3,0.9,0L22,9.8'
        'c0.3,0.3,0.4,0.6,0.3,0.9S22,11,21.8,11z'),
  ]),
  // media/dropdown-arrow.svg
  ScratchIkon.acilirOk: _IkonTanimi(12.71, 8.79, [
    _IkonKatmani(
        Color(0xFF231F20),
        'M12.71,2.44A2.41,2.41,0,0,1,12,4.16L8.08,8.08a2.45,2.45,0,0,1-3.45,0L0.72,4.16A2.42,2.42,0,0,1,0,2.44,'
        '2.48,2.48,0,0,1,.71.71C1,0.47,1.43,0,6.36,0S11.75,0.46,12,.71A2.44,2.44,0,0,1,12.71,2.44Z',
        saydamlik: 0.1),
    _IkonKatmani(
        Color(0xFFFFFFFF),
        'M6.36,7.79a1.43,1.43,0,0,1-1-.42L1.42,3.45a1.44,1.44,0,0,1,0-2c0.56-.56,9.31-0.56,9.87,0a1.44,1.44,0,0,1,'
        '0,2L7.37,7.37A1.43,1.43,0,0,1,6.36,7.79Z'),
  ]),
};

/// Simgenin dogal boyutu (Scratch'te 1x olcekte, piksel).
Size scratchIkonBoyutu(ScratchIkon ikon) {
  if (ikon == ScratchIkon.kalem || ikon == ScratchIkon.muzik) {
    return const Size(_uzantiIkonu, _uzantiIkonu);
  }
  final t = _ikonlar[ikon]!;
  return Size(t.genislik, t.yukseklik);
}

final Map<String, Path> _yolOnbellegi = {};

/// Simgeyi [konum]a [olcek] ile cizer.
void scratchIkonCiz(
    Canvas canvas, ScratchIkon ikon, Offset konum, double olcek) {
  canvas.save();
  canvas.translate(konum.dx, konum.dy);
  canvas.scale(olcek);
  if (ikon == ScratchIkon.kalem) {
    _kalemCiz(canvas);
    canvas.restore();
    return;
  }
  if (ikon == ScratchIkon.muzik) {
    _muzikCiz(canvas);
    canvas.restore();
    return;
  }
  final t = _ikonlar[ikon]!;
  for (final k in t.katmanlar) {
    final yol = _yolOnbellegi.putIfAbsent(k.yol, () => svgYolu(k.yol));
    canvas.drawPath(
      yol,
      Paint()
        ..isAntiAlias = true
        ..color = k.renk.withValues(alpha: k.saydamlik),
    );
  }
  canvas.restore();
}

// ---------------------------------------------------------------------
// Eklenti simgeleri (40x40, Scratch'in eklenti blogu simge boyutu)
// ---------------------------------------------------------------------

const double _uzantiIkonu = 40;

/// Scratch'in eklenti simgelerindeki koyu gri kontur.
const Color _ikonKontur = Color(0xFF575E75);

Paint _dolgu(Color c) => Paint()
  ..isAntiAlias = true
  ..color = c;

Paint _kontur([double w = 1.6]) => Paint()
  ..isAntiAlias = true
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeJoin = StrokeJoin.round
  ..strokeCap = StrokeCap.round
  ..color = _ikonKontur;

/// Kalem eklentisi: capraz duran bir kalem (ucu sol altta), beyaz
/// govde, mavi bilezik, ahsap uc ve grafit — Scratch'in kalem simgesi
/// gibi koyu gri konturlu.
void _kalemCiz(Canvas c) {
  c.save();
  // Kalemi yatay ciz, merkez etrafinda -45 derece dondur.
  c.translate(20, 20);
  c.rotate(-math.pi / 4);
  c.translate(-20, -20);

  const ust = 15.5, alt = 24.5, orta = 20.0;
  // Ahsap uc (koni).
  final uc = Path()
    ..moveTo(4, orta)
    ..lineTo(12, ust)
    ..lineTo(12, alt)
    ..close();
  c.drawPath(uc, _dolgu(const Color(0xFFF7D9A8)));
  // Grafit.
  final grafit = Path()
    ..moveTo(4, orta)
    ..lineTo(7.2, orta - 2)
    ..lineTo(7.2, orta + 2)
    ..close();
  c.drawPath(grafit, _dolgu(_ikonKontur));
  // Govde.
  final govde = RRect.fromLTRBAndCorners(12, ust, 29, alt);
  c.drawRRect(govde, _dolgu(const Color(0xFFFFFFFF)));
  // Govdedeki ince serit (kalemin yuzleri).
  c.drawLine(const Offset(12, orta), const Offset(29, orta),
      _kontur(0.9)..color = const Color(0xFFD9DCE3));
  // Mavi bilezik ve silgi ucu.
  c.drawRect(
      const Rect.fromLTRB(29, ust, 32, alt), _dolgu(const Color(0xFF4C97FF)));
  final silgi = RRect.fromLTRBAndCorners(32, ust, 36, alt,
      topRight: const Radius.circular(2.5),
      bottomRight: const Radius.circular(2.5));
  c.drawRRect(silgi, _dolgu(const Color(0xFFFF8C9E)));
  // Dis kontur.
  final dis = Path()
    ..moveTo(4, orta)
    ..lineTo(12, ust)
    ..lineTo(33.5, ust)
    ..arcToPoint(const Offset(36, ust + 2.5),
        radius: const Radius.circular(2.5))
    ..lineTo(36, alt - 2.5)
    ..arcToPoint(const Offset(33.5, alt), radius: const Radius.circular(2.5))
    ..lineTo(12, alt)
    ..close();
  c.drawPath(dis, _kontur());
  c.drawLine(const Offset(12, ust), const Offset(12, alt), _kontur(1.2));
  c.drawLine(const Offset(29, ust), const Offset(29, alt), _kontur(1.2));
  c.restore();
}

/// Muzik eklentisi: kirisle bagli iki sekizlik nota, beyaz dolgu, koyu
/// gri kontur.
void _muzikCiz(Canvas c) {
  // Nota baslari (hafif egik elipsler).
  Path bas(double cx, double cy) => _donmus(
      Path()
        ..addOval(Rect.fromCenter(center: Offset.zero, width: 10, height: 7.4)),
      -0.42,
      cx,
      cy);

  final sol = bas(12, 30);
  final sag = bas(28.5, 26.5);
  // Saplar ve kiris tek parca.
  final govde = Path()
    ..moveTo(15.6, 29)
    ..lineTo(15.6, 10.5)
    ..lineTo(32.2, 6.5)
    ..lineTo(32.2, 25.5)
    ..lineTo(29.8, 25.5)
    ..lineTo(29.8, 12.6)
    ..lineTo(18, 15.4)
    ..lineTo(18, 29)
    ..close();
  final hepsi = Path.combine(
      PathOperation.union, Path.combine(PathOperation.union, sol, sag), govde);
  c.drawPath(hepsi, _dolgu(const Color(0xFFFFFFFF)));
  c.drawPath(hepsi, _kontur());
}

/// [p]yi [aci] kadar dondurup ([cx], [cy])ye tasir.
Path _donmus(Path p, double aci, double cx, double cy) {
  final co = math.cos(aci), si = math.sin(aci);
  return p.transform(Float64List.fromList([
    co, si, 0, 0, //
    -si, co, 0, 0, //
    0, 0, 1, 0, //
    cx, cy, 0, 1,
  ]));
}

/// SVG `d` ozniteligini Flutter [Path]'ine cevirir.
///
/// Destek: M L H V C S A Z (buyuk = mutlak, kucuk = goreli).
Path svgYolu(String d) {
  final yol = Path();
  final belirtec =
      RegExp(r'[MmLlHhVvCcSsAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');
  final parcalar = belirtec.allMatches(d).map((m) => m.group(0)!).toList();
  var i = 0;
  var komut = 'M';
  double x = 0, y = 0, baslaX = 0, baslaY = 0;
  double? sonKontrolX, sonKontrolY;

  bool sayiMi(int j) =>
      j < parcalar.length && !RegExp(r'^[A-Za-z]$').hasMatch(parcalar[j]);
  double sayi() => double.parse(parcalar[i++]);

  while (i < parcalar.length) {
    if (!sayiMi(i)) {
      komut = parcalar[i++];
      if (komut == 'Z' || komut == 'z') {
        yol.close();
        x = baslaX;
        y = baslaY;
        sonKontrolX = null;
        continue;
      }
    }
    final goreli = komut.toLowerCase() == komut;
    final ox = goreli ? x : 0.0;
    final oy = goreli ? y : 0.0;
    switch (komut.toUpperCase()) {
      case 'M':
        x = ox + sayi();
        y = oy + sayi();
        yol.moveTo(x, y);
        baslaX = x;
        baslaY = y;
        // Ardisik koordinatlar L sayilir.
        komut = goreli ? 'l' : 'L';
        sonKontrolX = null;
      case 'L':
        x = ox + sayi();
        y = oy + sayi();
        yol.lineTo(x, y);
        sonKontrolX = null;
      case 'H':
        x = ox + sayi();
        yol.lineTo(x, y);
        sonKontrolX = null;
      case 'V':
        y = oy + sayi();
        yol.lineTo(x, y);
        sonKontrolX = null;
      case 'C':
        final x1 = ox + sayi(), y1 = oy + sayi();
        final x2 = ox + sayi(), y2 = oy + sayi();
        x = ox + sayi();
        y = oy + sayi();
        yol.cubicTo(x1, y1, x2, y2, x, y);
        sonKontrolX = x2;
        sonKontrolY = y2;
      case 'S':
        final x1 = sonKontrolX == null ? x : 2 * x - sonKontrolX;
        final y1 = sonKontrolY == null || sonKontrolX == null
            ? y
            : 2 * y - sonKontrolY;
        final x2 = ox + sayi(), y2 = oy + sayi();
        x = ox + sayi();
        y = oy + sayi();
        yol.cubicTo(x1, y1, x2, y2, x, y);
        sonKontrolX = x2;
        sonKontrolY = y2;
      case 'A':
        final rx = sayi(), ry = sayi(), aci = sayi();
        final buyuk = sayi() != 0, saat = sayi() != 0;
        x = ox + sayi();
        y = oy + sayi();
        yol.arcToPoint(Offset(x, y),
            radius: Radius.elliptical(rx, ry),
            rotation: aci,
            largeArc: buyuk,
            clockwise: saat);
        sonKontrolX = null;
      default:
        i++;
    }
  }
  return yol;
}
