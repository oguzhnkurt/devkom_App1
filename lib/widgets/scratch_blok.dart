import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../courses/yurutme/scratch_resmi_etiketler.dart';
import 'scratch_blok_ikonlari.dart';

export 'scratch_blok_ikonlari.dart' show ScratchIkon;

// =====================================================================
// SCRATCH 3 BLOGU — gercek Scratch olculeri ve renkleriyle.
// =====================================================================
//
// NEDEN YENI BIR CIZIM
// --------------------
// Scratch kursundaki bloklar duz Flutter haplari gibiydi: tek renk,
// sabit yazi, bayrak yerine Material simgesi, sayilar yazinin icinde.
// Cocuk uygulamada gordugu blogu Scratch'i acinca TANIYAMIYORDU. Bu
// dosya blogu Scratch 3'un kendi olculeriyle ciziyor:
//
//  * olcu birimi Scratch'in GRID_UNIT'i (4 px). Yigin blok 48 yuksek,
//    centik soldan 12'de basliyor ve 36 genis, 8 derin; sapka egrisi
//    `c 25,-22 71,-22 96,0`; C blogunun kolu 16 genis, bos agzi 24.
//    (scratch-blocks: block_render_svg_vertical / zelos sabitleri,
//    assets/mblock/scratch_blocks.min.js icinde de goruluyor.)
//  * renkler Scratch 3'un kategori renkleri (ana / ikincil / kenar).
//  * girdiler beyaz oval (koyu yazi), acilir menuler ikincil renkte ve
//    Scratch'in kendi ok simgesiyle, bayrak ve don simgeleri Scratch'in
//    SVG yollari.
//  * yazi BEYAZ ve KALIN; Scratch "Helvetica Neue" kullaniyor, uygulama
//    paketinde Nunito var — en yakin karsilik o.
//
// ALT ALTA OTURMA
// ---------------
// Blogun yerlesim yuksekligi govdesi kadar; alttaki TIRNAK (8 px) bu
// sinirin DISINA cizilir. Bloklar arasinda bosluk olmayan bir Column'da
// tirnak bir sonraki blogun centigine oturur — Scratch'teki gibi.
//
// WEBVIEW DEGIL
// -------------
// mBlock kursu gercek scratch-blocks motorunu WebView'da calistiriyor.
// Scratch kursunda bunu yapmadik: ders adimlari (dokunarak ekle, basili
// tutup tasi, siralama denetimi, calistirma sahnesi) Flutter tarafinda
// ve test edilmis. Bu cizim internet istemiyor, ilk karede hazir, ve
// widget testleriyle olculebiliyor.

const double _gu = 4;

/// Scratch 3 kategorileri ve renkleri (ana, ikincil, kenar).
enum ScratchKategori {
  hareket(Color(0xFF4C97FF), Color(0xFF4280D7), Color(0xFF3373CC),
      'CATEGORY_MOTION'),
  gorunum(Color(0xFF9966FF), Color(0xFF855CD6), Color(0xFF774DCB),
      'CATEGORY_LOOKS'),
  ses(Color(0xFFCF63CF), Color(0xFFC94FC9), Color(0xFFBD42BD),
      'CATEGORY_SOUND'),
  olaylar(Color(0xFFFFBF00), Color(0xFFE6AC00), Color(0xFFCC9900),
      'CATEGORY_EVENTS'),
  kontrol(Color(0xFFFFAB19), Color(0xFFEC9C13), Color(0xFFCF8B17),
      'CATEGORY_CONTROL'),
  algilama(Color(0xFF5CB1D6), Color(0xFF47A8D1), Color(0xFF2E8EB8),
      'CATEGORY_SENSING'),
  islemler(Color(0xFF59C059), Color(0xFF46B946), Color(0xFF389438),
      'CATEGORY_OPERATORS'),
  degiskenler(Color(0xFFFF8C1A), Color(0xFFFF8000), Color(0xFFDB6E00),
      'CATEGORY_VARIABLES'),

  /// Liste bloklari Scratch'te Degiskenler kategorisinde ama daha koyu
  /// turuncu.
  listeler(Color(0xFFFF661A), Color(0xFFFF5500), Color(0xFFE64D00),
      'CATEGORY_VARIABLES'),
  bloklarim(Color(0xFFFF6680), Color(0xFFFF4D6A), Color(0xFFFF3355),
      'CATEGORY_MYBLOCKS'),

  /// Eklentiler (Kalem, Muzik) Scratch'te ayni yesil.
  kalem(Color(0xFF0FBD8C), Color(0xFF0DA57A), Color(0xFF0B8E69),
      'pen.categoryName'),
  muzik(Color(0xFF0FBD8C), Color(0xFF0DA57A), Color(0xFF0B8E69),
      'music.categoryName'),

  /// mBlock'un Arduino "Pin" kategorisi (dijital ayarla, PWM, oku).
  /// Scratch'te boyle bir kategori yok; renk ve ad mBlock'un kendi
  /// cihaz paketinden (assets/mblock/mblock_bloklari.js ile ayni).
  mblockPin(Color(0xFF4A90E2), Color(0xFF3F7CC4), Color(0xFF33639E), 'Pin'),

  /// mBlock'un cihaz kategorileri: seri port (yesil), Sensör (acik
  /// mavi), Veri (mor). Renkler mblock_bloklari.js RENKLER ile ayni.
  mblockSeriPort(Color(0xFF7ED321), Color(0xFF6BB41C), Color(0xFF569117),
      'mblock.serialPort'),
  mblockSensor(Color(0xFF4CBFE6), Color(0xFF40A2C4), Color(0xFF33829D),
      'mblock.sensor'),
  mblockVeri(Color(0xFFBD10E0), Color(0xFFA00EBE), Color(0xFF800B98),
      'mblock.data');

  const ScratchKategori(this.renk, this.renk2, this.renk3, this.adAnahtari);

  final Color renk;
  final Color renk2;
  final Color renk3;

  /// Kategori adinin Scratch sozlugundeki anahtari.
  final String adAnahtari;

  /// Kategori adi, Scratch'in kendi dil dosyasindan.
  String ad(String lang) =>
      _mblockAdlari[adAnahtari]?[lang] ??
      _mblockAdlari[adAnahtari]?['en'] ??
      (scratchResmiEtiketler[lang] ?? scratchResmiEtiketler['en']!)[
          adAnahtari] ??
      adAnahtari;

  /// mBlock cihaz kategorilerinin adlari (mBlock'un kendi dil
  /// dosyalarindaki gibi; Scratch sozlugunde yoklar).
  static const Map<String, Map<String, String>> _mblockAdlari = {
    'mblock.serialPort': {
      'tr': 'seri port',
      'en': 'serial port',
      'de': 'serieller Port',
      'es': 'puerto serie',
    },
    'mblock.sensor': {
      'tr': 'Sensör',
      'en': 'Sensor',
      'de': 'Sensor',
      'es': 'Sensor',
    },
    'mblock.data': {
      'tr': 'Veri',
      'en': 'Data',
      'de': 'Daten',
      'es': 'Datos',
    },
  };

  /// Paletin solundaki kategori dairesi hangi kategoriyi temsil ediyor
  /// (liste bloklari Degiskenler dairesinde).
  ScratchKategori get daire => this == listeler ? degiskenler : this;
}

/// Scratch blok sekilleri.
enum ScratchSekil {
  /// Olay sapkasi: ustu kavisli, altta tirnak.
  sapka,

  /// Yigin blok: ustte centik, altta tirnak.
  yigin,

  /// Kapak: ustte centik, altta tirnak YOK ("bu ikizi sil").
  kapak,

  /// C blogu: icine blok alir ("tekrarla", "eger").
  c,

  /// Alti kapali C ("surekli tekrarla"): altina blok takilmaz.
  cKapak,

  /// Oval deger blogu.
  raportor,

  /// Altigen dogru/yanlis blogu.
  mantiksal,

  /// "tanimla" sapkasi (Bloklarim).
  tanim,
}

/// Blok satirindaki bir parca.
sealed class SbParca {
  const SbParca();
}

/// Beyaz kalin etiket yazisi.
final class SbYazi extends SbParca {
  const SbYazi(this.metin);
  final String metin;
}

/// Beyaz oval sayi/metin girdisi.
final class SbGirdi extends SbParca {
  const SbGirdi(this.deger);
  final String deger;
}

/// Acilir menu. [kutu] true ise alan (degisken/liste/haber adi:
/// koseli kutu), degilse golge menu (oval).
final class SbAcilir extends SbParca {
  const SbAcilir(this.deger, {this.kutu = false});
  final String deger;
  final bool kutu;
}

/// Scratch simgesi (yesil bayrak, saga don).
final class SbIkon extends SbParca {
  const SbIkon(this.ikon);
  final ScratchIkon ikon;
}

/// Ic ice blok (oval/altigen deger blogu, tanimdaki prototip).
final class SbIcBlok extends SbParca {
  const SbIcBlok(this.blok);
  final ScratchBlokTanimi blok;
}

/// Bos altigen yuva ("eger < > ise").
final class SbBosKosul extends SbParca {
  const SbBosKosul();
}

/// Renk yuvasi ("[■] rengine degiyor mu?"): Scratch'teki gibi renkli
/// oval. [ad] ekran okuyucu ve duz yazi icin ("yeşil").
final class SbRenk extends SbParca {
  const SbRenk(this.renk, this.ad);
  final Color renk;
  final String ad;
}

/// Satirdaki dokunulabilir bir parcanin kutusu ([ScratchBlokOlcer.parcaKutulari]).
class SbParcaKutusu {
  const SbParcaKutusu(this.yol, this.kutu, this.parca);
  final List<int> yol;
  final Rect kutu;
  final SbParca parca;
}

/// Bir Scratch blogunun tam tarifi: kategori, sekil, satirdaki parcalar.
class ScratchBlokTanimi {
  const ScratchBlokTanimi({
    required this.kategori,
    required this.sekil,
    required this.satir,
    this.degilse,
    this.ic = const [],
    this.ic2 = const [],
    this.tekrarOku = false,
    this.prototip = false,
  });

  final ScratchKategori kategori;
  final ScratchSekil sekil;
  final List<SbParca> satir;

  /// "eger ... degilse" blogunun ikinci satiri.
  final List<SbParca>? degilse;

  /// C blogunun agzindaki bloklar (yalnizca sabit cizimde; kod
  /// alaninda agzi ders adimi dolduruyor).
  final List<ScratchBlokTanimi> ic;
  final List<ScratchBlokTanimi> ic2;

  /// "tekrarla" / "surekli tekrarla": alt kolun sagindaki ok.
  final bool tekrarOku;

  /// "tanimla"nin icindeki pembe prototip blogu (ikincil renkte).
  final bool prototip;

  bool get cMi => sekil == ScratchSekil.c || sekil == ScratchSekil.cKapak;

  /// Altina blok takilabilir mi?
  bool get altiAcik =>
      sekil == ScratchSekil.sapka ||
      sekil == ScratchSekil.yigin ||
      sekil == ScratchSekil.c ||
      sekil == ScratchSekil.tanim;

  /// Ekran okuyucu ve iz icin duz yazi ("10 adım git").
  String get duzMetin => _duz(satir);

  static String _duz(List<SbParca> p) => p
      .map((e) => switch (e) {
            SbYazi(:final metin) => metin,
            SbGirdi(:final deger) => deger,
            SbAcilir(:final deger) => deger,
            SbIkon(:final ikon) => switch (ikon) {
                ScratchIkon.bayrak => '⚑',
                ScratchIkon.kalem => '✎',
                ScratchIkon.muzik => '♫',
                _ => '↻',
              },
            SbIcBlok(:final blok) => blok.sekil == ScratchSekil.mantiksal
                ? '<${blok.duzMetin}>'
                : blok.sekil == ScratchSekil.raportor
                    ? '(${blok.duzMetin})'
                    : blok.duzMetin,
            SbBosKosul() => '< >',
            SbRenk(:final ad) => '[$ad]',
          })
      .join(' ');
}

/// C blogunun hangi parcasi cizilecek.
enum ScratchCParcasi {
  /// Tam blok (C ise agziyla, [ScratchBlokTanimi.ic] dahil).
  tamami,

  /// Yalnizca ust kol (kod alani; agzi ve ayagi adim ciziyor).
  ust,

  /// Yalnizca alt kol (ayak).
  alt,

  /// Yalnizca "degilse" kolu (ic ice kod alani: eger-degilse blogunun
  /// iki agzi arasindaki satir). [ScratchBlok.icDolu]: ust agiz dolu mu.
  orta,

  /// C blogu tek satirlik yigin blok gibi (calisma sahnesindeki cip).
  bas,
}

// ---------------------------------------------------------------------
// Yerlesim
// ---------------------------------------------------------------------

enum _Bicim { yazi, yuvarlak, altigen, kutu, ikon }

const Color _girdiYazisi = Color(0xFF575E75);

/// Yazi yerlesimi onbellegi.
///
/// Ayni blok yazisi (ayni metin, olcek, renk) kod alani her yeniden
/// cizildiginde bastan olculuyordu; kod calisirken bu her adimda tum
/// bloklar icin tekrarlaniyordu. Sinirli: dolunca bosaltiliyor.
final Map<String, TextPainter> _yaziOnbellegi = {};
const int _yaziOnbellekSiniri = 600;

TextPainter _yazi(String s, double olcek, Color renk) {
  final anahtar = '$s\u0000$olcek\u0000${renk.toARGB32()}';
  final onceki = _yaziOnbellegi[anahtar];
  if (onceki != null) return onceki;
  if (_yaziOnbellegi.length >= _yaziOnbellekSiniri) _yaziOnbellegi.clear();
  return _yaziOnbellegi[anahtar] = _yaziOlc(s, olcek, renk);
}

TextPainter _yaziOlc(String s, double olcek, Color renk) => TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          // Scratch: 12pt = 16 px, 1x olcekte.
          fontSize: 16 * olcek,
          height: 1.15,
          color: renk,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      maxLines: 1,
    )..layout();

abstract class _Oge {
  double get w;
  double get h;
  _Bicim get bicim;
  void ciz(Canvas c, Offset o);
}

class _YaziOge extends _Oge {
  _YaziOge(String s, double olcek) : tp = _yazi(s, olcek, Colors.white);
  final TextPainter tp;
  @override
  double get w => tp.width;
  @override
  double get h => tp.height;
  @override
  _Bicim get bicim => _Bicim.yazi;
  @override
  void ciz(Canvas c, Offset o) => tp.paint(c, o);
}

class _GirdiOge extends _Oge {
  _GirdiOge(String deger, this.s, this.kenar)
      : tp = _yazi(deger, s, _girdiYazisi);
  final double s;
  final Color kenar;
  final TextPainter tp;
  @override
  double get w => math.max(40 * s, tp.width + 24 * s);
  @override
  double get h => 32 * s;
  @override
  _Bicim get bicim => _Bicim.yuvarlak;
  @override
  void ciz(Canvas c, Offset o) {
    final r = RRect.fromRectAndRadius(o & Size(w, h), Radius.circular(h / 2));
    c.drawRRect(r, Paint()..color = Colors.white);
    c.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, s)
          ..color = kenar);
    tp.paint(c, o + Offset((w - tp.width) / 2, (h - tp.height) / 2));
  }
}

class _AcilirOge extends _Oge {
  _AcilirOge(String deger, this.s, this.kutu, this.dolgu, this.kenar)
      : tp = _yazi(deger, s, Colors.white);
  final double s;
  final bool kutu;
  final Color dolgu;
  final Color kenar;
  final TextPainter tp;
  double get _pay => (kutu ? 8 : 12) * s;
  static const double _okW = 12.71;
  static const double _okH = 8.79;
  @override
  double get w => _pay + tp.width + 8 * s + _okW * s + _pay;
  @override
  double get h => 32 * s;
  @override
  _Bicim get bicim => kutu ? _Bicim.kutu : _Bicim.yuvarlak;
  @override
  void ciz(Canvas c, Offset o) {
    final r = RRect.fromRectAndRadius(
        o & Size(w, h), Radius.circular(kutu ? _gu * s : h / 2));
    c.drawRRect(r, Paint()..color = dolgu);
    c.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, s)
          ..color = kenar);
    tp.paint(c, o + Offset(_pay, (h - tp.height) / 2));
    scratchIkonCiz(c, ScratchIkon.acilirOk,
        o + Offset(w - _pay - _okW * s, (h - _okH * s) / 2), s);
  }
}

class _IkonOge extends _Oge {
  _IkonOge(this.ikon, this.s);
  final ScratchIkon ikon;
  final double s;
  @override
  double get w => scratchIkonBoyutu(ikon).width * s;
  @override
  double get h => scratchIkonBoyutu(ikon).height * s;
  @override
  _Bicim get bicim => _Bicim.ikon;
  @override
  void ciz(Canvas c, Offset o) => scratchIkonCiz(c, ikon, o, s);
}

class _BosKosulOge extends _Oge {
  _BosKosulOge(this.s, this.renk);
  final double s;
  final Color renk;
  @override
  double get w => 40 * s;
  @override
  double get h => 32 * s;
  @override
  _Bicim get bicim => _Bicim.altigen;
  @override
  void ciz(Canvas c, Offset o) {
    c.drawPath(_altigen(w, h).shift(o), Paint()..color = renk);
  }
}

/// Renk yuvasi: beyaz kenarli renkli oval.
class _RenkOge extends _Oge {
  _RenkOge(this.s, this.renk);
  final double s;
  final Color renk;
  @override
  double get w => 40 * s;
  @override
  double get h => 32 * s;
  @override
  _Bicim get bicim => _Bicim.yuvarlak;
  @override
  void ciz(Canvas c, Offset o) {
    final r = RRect.fromRectAndRadius(o & Size(w, h), Radius.circular(h / 2));
    c.drawRRect(r, Paint()..color = renk);
    c.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, 1.5 * s)
          ..color = Colors.white);
  }
}

/// Eklenti simgesinin sagindaki dikey ayrac (Scratch'in
/// field_vertical_separator'u: simge boyunda, kenar renginde).
class _AyracOge extends _Oge {
  _AyracOge(this.s, this.renk);
  final double s;
  final Color renk;
  @override
  double get w => math.max(1, s);
  @override
  double get h => 40 * s;
  @override
  _Bicim get bicim => _Bicim.ikon;
  @override
  void ciz(Canvas c, Offset o) => c.drawLine(
      o + Offset(w / 2, 0),
      o + Offset(w / 2, h),
      Paint()
        ..color = renk
        ..strokeWidth = w);
}

/// Kod alanindaki bloklarin sagindaki kucuk "x" (dokununca cikar).
class _SilOge extends _Oge {
  _SilOge(this.s);
  final double s;
  @override
  double get w => 20 * s;
  @override
  double get h => 20 * s;
  @override
  _Bicim get bicim => _Bicim.ikon;
  @override
  void ciz(Canvas c, Offset o) {
    final m = o + Offset(w / 2, h / 2);
    c.drawCircle(
        m, w / 2, Paint()..color = Colors.black.withValues(alpha: 0.18));
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2 * s
      ..strokeCap = StrokeCap.round;
    final d = 4.5 * s;
    c.drawLine(m + Offset(-d, -d), m + Offset(d, d), p);
    c.drawLine(m + Offset(d, -d), m + Offset(-d, d), p);
  }
}

class _IcBlokOge extends _Oge {
  _IcBlokOge(this.d);
  final _BlokDuzeni d;
  @override
  double get w => d.w;
  @override
  double get h => d.govdeH;
  @override
  _Bicim get bicim => switch (d.sekil) {
        ScratchSekil.raportor => _Bicim.yuvarlak,
        ScratchSekil.mantiksal => _Bicim.altigen,
        _ => _Bicim.kutu,
      };
  @override
  void ciz(Canvas c, Offset o) => d.ciz(c, o);
}

Path _altigen(double w, double h) {
  final p = math.min(h / 2, 12 * _gu);
  return Path()
    ..moveTo(p, 0)
    ..lineTo(w - p, 0)
    ..lineTo(w, h / 2)
    ..lineTo(w - p, h)
    ..lineTo(p, h)
    ..lineTo(0, h / 2)
    ..close();
}

/// Tek satirin yerlesimi.
class _Satir {
  _Satir(this.ogeler, this.sekil, this.s);
  final List<_Oge> ogeler;
  final ScratchSekil sekil;
  final double s;

  bool get _cikti =>
      sekil == ScratchSekil.raportor || sekil == ScratchSekil.mantiksal;

  /// Kenardan ilk/son ogeye bosluk (Scratch'in SHAPE_IN_SHAPE_PADDING
  /// tablosu: dis sekil x ic sekil).
  double _pay(_Oge? o) {
    if (!_cikti) return 2 * _gu * s;
    final b = o?.bicim ?? _Bicim.yazi;
    if (sekil == ScratchSekil.mantiksal) {
      return switch (b) {
            _Bicim.altigen => 2 * _gu,
            _ => 5 * _gu,
          } *
          s;
    }
    return switch (b) {
          _Bicim.yuvarlak => 1 * _gu,
          _Bicim.kutu || _Bicim.ikon => 2 * _gu,
          _ => 3 * _gu,
        } *
        s;
  }

  double get icerikW {
    var t = 0.0;
    for (var i = 0; i < ogeler.length; i++) {
      t += ogeler[i].w;
      if (i > 0) t += 2 * _gu * s;
    }
    return t;
  }

  double get icerikH => ogeler.fold(0.0, (m, o) => math.max(m, o.h));

  double get solPay => _pay(ogeler.isEmpty ? null : ogeler.first);
  double get sagPay => _pay(ogeler.isEmpty ? null : ogeler.last);
  double get w => solPay + icerikW + sagPay;

  double get h {
    if (_cikti) {
      final yalnizYazi = ogeler.every((o) => o.bicim == _Bicim.yazi);
      return yalnizYazi
          ? math.max(8 * _gu * s, icerikH + 2 * _gu * s)
          : math.max(10 * _gu * s, icerikH + 2 * _gu * s);
    }
    return math.max(12 * _gu * s, icerikH + 4 * _gu * s);
  }

  void ciz(Canvas c, Offset o, double satirH) {
    var x = o.dx + solPay;
    for (final g in ogeler) {
      g.ciz(c, Offset(x, o.dy + (satirH - g.h) / 2));
      x += g.w + 2 * _gu * s;
    }
  }
}

/// Bir blogun (C ise ust satirinin) tam yerlesimi.
class _BlokDuzeni {
  _BlokDuzeni(this.t, this.s, {bool silme = false, ScratchSekil? sekilZorla})
      : sekil = sekilZorla ?? t.sekil {
    satir = _Satir(_ogeler(t.satir, silme), sekil, s);
    if (t.degilse != null) {
      degilseSatiri =
          _Satir(_ogeler(t.degilse!, false, ilkSatir: false), sekil, s);
    }
  }

  final ScratchBlokTanimi t;
  final double s;
  final ScratchSekil sekil;
  late final _Satir satir;
  _Satir? degilseSatiri;

  ScratchKategori get k => t.kategori;
  Color get dolgu => t.prototip ? k.renk2 : k.renk;

  /// Eklenti blogu (Kalem, Muzik): satir eklenti simgesi ve dikey
  /// ayracla basliyor — Scratch 3'teki gibi.
  ScratchIkon? get _uzantiIkonu => t.prototip
      ? null
      : switch (k) {
          ScratchKategori.kalem => ScratchIkon.kalem,
          ScratchKategori.muzik => ScratchIkon.muzik,
          _ => null,
        };

  List<_Oge> _ogeler(List<SbParca> p, bool silme, {bool ilkSatir = true}) => [
        if (ilkSatir && _uzantiIkonu != null) ...[
          _IkonOge(_uzantiIkonu!, s),
          _AyracOge(s, k.renk3),
        ],
        for (final e in p)
          switch (e) {
            SbYazi(:final metin) => _YaziOge(metin, s),
            SbGirdi(:final deger) => _GirdiOge(deger, s, k.renk3),
            SbAcilir(:final deger, :final kutu) =>
              _AcilirOge(deger, s, kutu, k.renk2, k.renk3),
            SbIkon(:final ikon) => _IkonOge(ikon, s),
            SbIcBlok(:final blok) => _IcBlokOge(_BlokDuzeni(blok, s)),
            SbBosKosul() => _BosKosulOge(s, k.renk3),
            SbRenk(:final renk) => _RenkOge(s, renk),
          },
        if (silme) _SilOge(s),
      ];

  double get w {
    var m = satir.w;
    if (degilseSatiri != null) m = math.max(m, degilseSatiri!.w);
    return math.max(
        m,
        switch (sekil) {
          ScratchSekil.c || ScratchSekil.cKapak => 40 * _gu * s,
          ScratchSekil.sapka || ScratchSekil.tanim => 25 * _gu * s,
          ScratchSekil.yigin || ScratchSekil.kapak => 16 * _gu * s,
          ScratchSekil.raportor ||
          ScratchSekil.mantiksal =>
            satir.ogeler.every((o) => o.bicim == _Bicim.yazi)
                ? 10 * _gu * s
                : 12 * _gu * s,
        });
  }

  /// Sapkanin / tanimin satir ustundeki payi.
  double get ustPay => switch (sekil) {
        ScratchSekil.sapka => 16.5 * s,
        ScratchSekil.tanim => 4 * _gu * s,
        _ => 0,
      };

  /// Tanimda prototipin tirnagi icin altta pay.
  double get altPay => sekil == ScratchSekil.tanim ? 2 * _gu * s : 0;

  double get satirH => satir.h;

  /// Yerlesim yuksekligi (tirnak HARIC). C icin ust kolun yuksekligi.
  double get govdeH => ustPay + satirH + altPay;

  /// Bos agiz, alt kol, "degilse" satiri.
  double get bosAgizH => 6 * _gu * s;
  double get altKolH => 8 * _gu * s;
  double get ortaH => degilseSatiri == null
      ? 0
      : math.max(10 * _gu * s, degilseSatiri!.icerikH + 2 * _gu * s);

  /// Tek basina (C degil) bloku [o]ya cizer.
  void ciz(Canvas c, Offset o, {Color? vurgu}) {
    final y = _Yol(s);
    final W = w;
    final T = govdeH;
    switch (sekil) {
      case ScratchSekil.raportor:
        y.rrect(Rect.fromLTWH(0, 0, W, T), T / 2);
      case ScratchSekil.mantiksal:
        y.yolEkle(_altigen(W, T));
      case ScratchSekil.sapka:
        final hp = ustPay;
        y.m(0, hp);
        y.rc(25, -22, 71, -22, 96, 0);
        y.l(W - 4 * s, hp);
        y.ark(W, hp + 4 * s);
        y.l(W, T - 4 * s);
        y.ark(W - 4 * s, T);
        y.tirnak(T);
        y.l(4 * s, T);
        y.ark(0, T - 4 * s);
        y.kapat();
      case ScratchSekil.tanim:
        final r = 5 * _gu * s;
        y.m(0, r);
        y.ark(r, 0, r: r);
        y.l(W - r, 0);
        y.ark(W, r, r: r);
        y.l(W, T - 4 * s);
        y.ark(W - 4 * s, T);
        y.tirnak(T);
        y.l(4 * s, T);
        y.ark(0, T - 4 * s);
        y.kapat();
      case ScratchSekil.yigin ||
            ScratchSekil.kapak ||
            ScratchSekil.c ||
            ScratchSekil.cKapak:
        y.m(0, 4 * s);
        y.ark(4 * s, 0);
        y.centik(0);
        y.l(W - 4 * s, 0);
        y.ark(W, 4 * s);
        y.l(W, T - 4 * s);
        y.ark(W - 4 * s, T);
        if (sekil != ScratchSekil.kapak && sekil != ScratchSekil.cKapak) {
          y.tirnak(T);
        }
        y.l(4 * s, T);
        y.ark(0, T - 4 * s);
        y.kapat();
    }
    y.boya(c, o, dolgu, k.renk3, vurgu: vurgu);
    satir.ciz(c, o + Offset(0, ustPay), satirH);
  }

  // --- C parcalari -------------------------------------------------

  /// Ust kol: ustte centik, sagda kenar, agza dogru ic tirnak.
  void cizUst(Canvas c, Offset o, {Color? vurgu}) {
    final y = _Yol(s);
    final W = w;
    final H = satirH;
    y.m(0, H + 4 * s);
    y.l(0, 4 * s);
    y.ark(4 * s, 0);
    y.centik(0);
    y.l(W - 4 * s, 0);
    y.ark(W, 4 * s);
    y.l(W, H - 4 * s);
    y.ark(W - 4 * s, H);
    y.icTirnak(H);
    y.l(20 * s, H);
    y.ark(16 * s, H + 4 * s, saat: false);
    y.l(0, H + 4 * s, dikis: true);
    y.kapat(cizgi: false);
    y.boya(c, o, dolgu, k.renk3, vurgu: vurgu);
    satir.ciz(c, o, H);
  }

  /// "degilse" satiri: iki agiz arasindaki kol.
  void cizOrta(Canvas c, Offset o, {required bool ustDolu}) {
    final y = _Yol(s);
    final W = w;
    final H = ortaH;
    y.m(0, -4 * s);
    y.l(16 * s, -4 * s, dikis: true);
    y.ark(20 * s, 0, saat: false);
    if (ustDolu) y.icCentik(0);
    y.l(W - 4 * s, 0);
    y.ark(W, 4 * s);
    y.l(W, H - 4 * s);
    y.ark(W - 4 * s, H);
    y.icTirnak(H);
    y.l(20 * s, H);
    y.ark(16 * s, H + 4 * s, saat: false);
    y.l(0, H + 4 * s, dikis: true);
    y.l(0, -4 * s);
    y.kapat(cizgi: false);
    y.boya(c, o, dolgu, k.renk3);
    degilseSatiri!.ciz(c, o, H);
  }

  /// Alt kol (ayak). [icDolu]: agizda blok var, onun tirnagi bu kolun
  /// ust kenarindaki centige oturuyor.
  void cizAlt(Canvas c, Offset o, {required bool icDolu}) {
    final y = _Yol(s);
    final W = w;
    final H = altKolH;
    y.m(0, -4 * s);
    y.l(16 * s, -4 * s, dikis: true);
    y.ark(20 * s, 0, saat: false);
    if (icDolu) y.icCentik(0);
    y.l(W - 4 * s, 0);
    y.ark(W, 4 * s);
    y.l(W, H - 4 * s);
    y.ark(W - 4 * s, H);
    if (sekil == ScratchSekil.c) y.tirnak(H);
    y.l(4 * s, H);
    y.ark(0, H - 4 * s);
    y.l(0, -4 * s);
    y.kapat(cizgi: false);
    y.boya(c, o, dolgu, k.renk3);
    if (t.tekrarOku) {
      final b = scratchIkonBoyutu(ScratchIkon.tekrar) * s;
      scratchIkonCiz(c, ScratchIkon.tekrar,
          o + Offset(W - b.width - 2 * _gu * s, (H - b.height) / 2), s);
    }
  }
}

/// Dolgu ve kenar yolunu birlikte kuran yardimci. Parcalarin birlestigi
/// "dikis" kenarlari yalnizca dolguya girer, cizgiye girmez: C blogunun
/// ust kolu, sirti ve ayagi ayri widget'lar ama tek blok gibi gorunur.
class _Yol {
  _Yol(this.s);
  final double s;
  final Path dolgu = Path();
  final Path cizgi = Path();
  double _x = 0, _y = 0;

  void m(double x, double y) {
    dolgu.moveTo(x, y);
    cizgi.moveTo(x, y);
    _x = x;
    _y = y;
  }

  void l(double x, double y, {bool dikis = false}) {
    dolgu.lineTo(x, y);
    if (dikis) {
      cizgi.moveTo(x, y);
    } else {
      cizgi.lineTo(x, y);
    }
    _x = x;
    _y = y;
  }

  /// Goreli kubik egri (Scratch olculerinde, olceklenir).
  void rc(double x1, double y1, double x2, double y2, double x, double y) {
    final a = _x, b = _y;
    for (final p in [dolgu, cizgi]) {
      p.cubicTo(
          a + x1 * s, b + y1 * s, a + x2 * s, b + y2 * s, a + x * s, b + y * s);
    }
    _x = a + x * s;
    _y = b + y * s;
  }

  void rl(double x, double y) => l(_x + x * s, _y + y * s);

  void ark(double x, double y, {double? r, bool saat = true}) {
    final rr = Radius.circular(r ?? 4 * s);
    dolgu.arcToPoint(Offset(x, y), radius: rr, clockwise: saat);
    cizgi.arcToPoint(Offset(x, y), radius: rr, clockwise: saat);
    _x = x;
    _y = y;
  }

  void rrect(Rect r, double yaricap) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(yaricap));
    dolgu.addRRect(rr);
    cizgi.addRRect(rr);
  }

  void yolEkle(Path p) {
    dolgu.addPath(p, Offset.zero);
    cizgi.addPath(p, Offset.zero);
  }

  /// Soldan saga giderken asagi inen centik (x0 + 12'de baslar).
  void _centikEgri() {
    rc(2, 0, 3, 1, 4, 2);
    rl(4, 4);
    rc(1, 1, 2, 2, 4, 2);
    rl(12, 0);
    rc(2, 0, 3, -1, 4, -2);
    rl(4, -4);
    rc(1, -1, 2, -2, 4, -2);
  }

  /// Sagdan sola giderken asagi cikan tirnak (36 genis).
  void _tirnakEgri() {
    rc(-2, 0, -3, 1, -4, 2);
    rl(-4, 4);
    rc(-1, 1, -2, 2, -4, 2);
    rl(-12, 0);
    rc(-2, 0, -3, -1, -4, -2);
    rl(-4, -4);
    rc(-1, -1, -2, -2, -4, -2);
  }

  /// Ust kenardaki centik (blogun solundan 12).
  void centik(double y) {
    l(12 * s, y);
    _centikEgri();
  }

  /// Alt kenardaki tirnak.
  void tirnak(double y) {
    l(48 * s, y);
    _tirnakEgri();
  }

  /// Agzin alt kenarindaki centik (kolun 16'sindan 12 iceride).
  void icCentik(double y) {
    l(28 * s, y);
    _centikEgri();
  }

  /// Agzin ust kenarindan sarkan tirnak.
  void icTirnak(double y) {
    l(64 * s, y);
    _tirnakEgri();
  }

  void kapat({bool cizgi = true}) {
    dolgu.close();
    if (cizgi) this.cizgi.close();
  }

  void boya(Canvas c, Offset o, Color dolguRengi, Color kenarRengi,
      {Color? vurgu}) {
    final d = dolgu.shift(o);
    final k = cizgi.shift(o);
    if (vurgu != null) {
      // Scratch'te calisan yigin sari bir haleyle parlar.
      c.drawPath(
          d,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7 * s
            ..strokeJoin = StrokeJoin.round
            ..color = vurgu);
    }
    c.drawPath(
        d,
        Paint()
          ..isAntiAlias = true
          ..color = dolguRengi);
    c.drawPath(
        k,
        Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, s)
          ..strokeJoin = StrokeJoin.round
          ..color = kenarRengi);
  }
}

// ---------------------------------------------------------------------
// Olcum
// ---------------------------------------------------------------------

/// Bloklarin dogal boyutu (yerlesimden once olcek secmek icin).
class ScratchBlokOlcer {
  ScratchBlokOlcer._();

  /// Blogun genisligi. C blogunun [ScratchCParcasi.tamami] genisligi
  /// agzindaki bloklari da hesaba katar.
  static double genislik(ScratchBlokTanimi t, double olcek,
      {ScratchCParcasi parca = ScratchCParcasi.tamami, bool silme = false}) {
    final d = _BlokDuzeni(t, olcek,
        silme: silme,
        sekilZorla:
            parca == ScratchCParcasi.bas && t.cMi ? ScratchSekil.yigin : null);
    if (!t.cMi || parca != ScratchCParcasi.tamami) return d.w;
    var m = d.w;
    for (final i in [...t.ic, ...t.ic2]) {
      m = math.max(m, 16 * olcek + genislik(i, olcek));
    }
    return m;
  }

  /// Yerlesim yuksekligi (alt tirnak haric).
  static double yukseklik(ScratchBlokTanimi t, double olcek,
      {ScratchCParcasi parca = ScratchCParcasi.tamami}) {
    final d = _BlokDuzeni(t, olcek,
        sekilZorla:
            parca == ScratchCParcasi.bas && t.cMi ? ScratchSekil.yigin : null);
    if (!t.cMi || parca == ScratchCParcasi.bas) return d.govdeH;
    if (parca == ScratchCParcasi.ust) return d.satirH;
    if (parca == ScratchCParcasi.alt) return d.altKolH;
    double agiz(List<ScratchBlokTanimi> ic) => ic.isEmpty
        ? d.bosAgizH
        : ic.fold(0.0, (a, b) => a + yukseklik(b, olcek));
    var h = d.satirH + agiz(t.ic) + d.altKolH;
    if (t.degilse != null) h += d.ortaH + agiz(t.ic2);
    return h;
  }

  /// Satirdaki ILK beyaz ovalin (sayi girdisi) blogun sol ustune gore
  /// yeri. Ic ice kod alani sayiya dokunmayi bununla yakaliyor. C
  /// blogunda ust kola gore.
  static Rect? ilkGirdi(ScratchBlokTanimi t, double olcek,
      {bool silme = false}) {
    final d = _BlokDuzeni(t, olcek, silme: silme);
    var x = d.satir.solPay;
    for (final g in d.satir.ogeler) {
      if (g is _GirdiOge) {
        return Rect.fromLTWH(
            x, d.ustPay + (d.satirH - g.h) / 2, g.w, g.h);
      }
      x += g.w + 2 * _gu * olcek;
    }
    return null;
  }

  /// Satirdaki DOKUNULABILIR parcalarin (beyaz oval, acilir liste,
  /// takili blok, bos altigen, renk) blogun sol ustune gore kutulari.
  /// [SbParcaKutusu.yol] parcanin [ScratchBlokTanimi.satir] icindeki
  /// sirasi; takili blogun kendi parcalari icin yol uzuyor ([2, 0]:
  /// ucuncu parcadaki takili blogun ilk parcasi). Takili blogun
  /// kendisi de (kendi yoluyla) listede, parcalarindan ONCE.
  static List<SbParcaKutusu> parcaKutulari(ScratchBlokTanimi t, double olcek,
      {bool silme = false}) {
    final out = <SbParcaKutusu>[];
    void gez(_BlokDuzeni d, Offset o, List<int> yol) {
      final atla = d._uzantiIkonu == null ? 0 : 2;
      var x = o.dx + d.satir.solPay;
      for (var i = 0; i < d.satir.ogeler.length; i++) {
        final g = d.satir.ogeler[i];
        final y = o.dy + d.ustPay + (d.satirH - g.h) / 2;
        final pi = i - atla;
        if (pi >= 0 && pi < d.t.satir.length) {
          final p = d.t.satir[pi];
          final kutu = Rect.fromLTWH(x, y, g.w, g.h);
          switch (p) {
            case SbGirdi() || SbAcilir() || SbBosKosul() || SbRenk():
              out.add(SbParcaKutusu([...yol, pi], kutu, p));
            case SbIcBlok():
              out.add(SbParcaKutusu([...yol, pi], kutu, p));
              if (g is _IcBlokOge) gez(g.d, Offset(x, y), [...yol, pi]);
            case SbYazi() || SbIkon():
              break;
          }
        }
        x += g.w + 2 * _gu * olcek;
      }
    }

    gez(_BlokDuzeni(t, olcek, silme: silme), Offset.zero, const []);
    return out;
  }

  /// "Degilse" satirinin yuksekligi.
  static double ortaYuksekligi(ScratchBlokTanimi t, double olcek) =>
      _BlokDuzeni(t, olcek).ortaH;

  /// Alt tirnagin yuksekligi: son blogun altinda bu kadar pay birak.
  static double tirnakPayi(double olcek) => 2 * _gu * olcek;

  /// C blogunun kol genisligi.
  static double kolGenisligi(double olcek) => 4 * _gu * olcek;

  /// Bos agiz yuksekligi.
  static double bosAgiz(double olcek) => 6 * _gu * olcek;
}

// ---------------------------------------------------------------------
// Widget'lar
// ---------------------------------------------------------------------

/// Tek bir Scratch 3 blogu.
class ScratchBlok extends StatelessWidget {
  const ScratchBlok({
    super.key,
    required this.tanim,
    this.olcek = varsayilanOlcek,
    this.parca = ScratchCParcasi.tamami,
    this.vurgu,
    this.silme = false,
    this.sigdir = true,
    this.icDolu = false,
    this.kimlik,
  });

  /// Telefonda okunur boyut. Scratch editoru 0.675 ile ciziyor; o boyut
  /// telefonda cocuk icin kucuk.
  static const double varsayilanOlcek = 0.85;

  /// Calisan blogun halesi (Scratch'in yigin parlamasi).
  static const Color calisanRengi = Color(0xFFFFF200);

  final ScratchBlokTanimi tanim;
  final double olcek;
  final ScratchCParcasi parca;

  /// Verilirse blogun cevresinde bu renkte hale.
  final Color? vurgu;

  /// Satirin sonunda "x" (kod alani: dokununca cikar).
  final bool silme;

  /// Sigmazsa kucult.
  final bool sigdir;

  /// [ScratchCParcasi.alt]: agizda blok var mi (centik acilsin mi).
  final bool icDolu;

  /// Ders verisindeki blok kimligi (testler ve hata ayiklama icin).
  final String? kimlik;

  double genislik(double s) =>
      ScratchBlokOlcer.genislik(tanim, s, parca: parca, silme: silme);

  @override
  Widget build(BuildContext context) {
    final govde = sigdir
        ? LayoutBuilder(builder: (context, c) {
            var s = olcek;
            final w = genislik(s);
            if (c.maxWidth.isFinite && w > c.maxWidth && w > 0) {
              s = olcek * (c.maxWidth / w) * 0.995;
            }
            return _ciz(s);
          })
        : _ciz(olcek);
    return Semantics(
      label: tanim.duzMetin,
      container: true,
      child: ExcludeSemantics(child: govde),
    );
  }

  Widget _ciz(double s) {
    if (!tanim.cMi || parca == ScratchCParcasi.bas) {
      final d = _BlokDuzeni(tanim, s,
          silme: silme, sekilZorla: tanim.cMi ? ScratchSekil.yigin : null);
      return CustomPaint(
        size: Size(d.w, d.govdeH),
        painter: _Boyaci((c) => d.ciz(c, Offset.zero, vurgu: vurgu),
            anahtar: '${tanim.duzMetin}|$s|$vurgu|$silme'),
      );
    }
    final d = _BlokDuzeni(tanim, s, silme: silme);
    final ust = CustomPaint(
      size: Size(d.w, d.satirH),
      painter: _Boyaci((c) => d.cizUst(c, Offset.zero, vurgu: vurgu),
          anahtar: 'u${tanim.duzMetin}|$s|$vurgu|$silme'),
    );
    final alt = CustomPaint(
      size: Size(d.w, d.altKolH),
      painter: _Boyaci((c) => d.cizAlt(c, Offset.zero, icDolu: icDolu),
          anahtar: 'a${tanim.duzMetin}|$s|$icDolu'),
    );
    switch (parca) {
      case ScratchCParcasi.ust:
        return ust;
      case ScratchCParcasi.alt:
        return alt;
      case ScratchCParcasi.orta:
        if (tanim.degilse == null) return const SizedBox.shrink();
        return CustomPaint(
          size: Size(d.w, d.ortaH),
          painter: _Boyaci(
              (c) => d.cizOrta(c, Offset.zero, ustDolu: icDolu),
              anahtar: 'o${tanim.duzMetin}|$s|$icDolu'),
        );
      case ScratchCParcasi.bas:
      case ScratchCParcasi.tamami:
        Widget agiz(List<ScratchBlokTanimi> ic) => ScratchCSirti(
              kategori: tanim.kategori,
              olcek: s,
              child: ic.isEmpty
                  ? null
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final b in ic)
                          ScratchBlok(tanim: b, olcek: s, sigdir: false),
                      ],
                    ),
            );
        // Saydam ama dokunulabilir: C blogunun bos agzina dokunmak da
        // bloga dokunmak sayilir.
        return ColoredBox(
          color: const Color(0x00000000),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ust,
              agiz(tanim.ic),
              if (tanim.degilse != null) ...[
                CustomPaint(
                  size: Size(d.w, d.ortaH),
                  painter: _Boyaci(
                      (c) => d.cizOrta(c, Offset.zero,
                          ustDolu: tanim.ic.isNotEmpty),
                      anahtar: 'o${tanim.duzMetin}|$s'),
                ),
                agiz(tanim.ic2),
              ],
              CustomPaint(
                size: Size(d.w, d.altKolH),
                painter: _Boyaci(
                    (c) => d.cizAlt(c, Offset.zero,
                        icDolu: (tanim.degilse != null ? tanim.ic2 : tanim.ic)
                            .isNotEmpty),
                    anahtar: 'A${tanim.duzMetin}|$s'),
              ),
            ],
          ),
        );
    }
  }
}

/// C blogunun sol kolu: [child] agzin icinde, kol solunda.
///
/// [child] yoksa Scratch'in bos agzi (24 px) cizilir.
class ScratchCSirti extends StatelessWidget {
  const ScratchCSirti({
    super.key,
    required this.kategori,
    required this.olcek,
    this.child,
  });

  final ScratchKategori kategori;
  final double olcek;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final s = olcek;
    return CustomPaint(
      painter: _Boyaci((c) {}, anahtar: 'sirt', boyut: (c, size) {
        final kol = 16 * s;
        c.drawRect(Rect.fromLTWH(0, 0, kol, size.height),
            Paint()..color = kategori.renk);
        final p = Paint()
          ..color = kategori.renk3
          ..strokeWidth = math.max(1, s);
        c.drawLine(Offset.zero, Offset(0, size.height), p);
        if (size.height > 8 * s) {
          c.drawLine(Offset(kol, 4 * s), Offset(kol, size.height - 4 * s), p);
        }
      }),
      child: Padding(
        padding: EdgeInsets.only(left: 16 * s),
        child: child ?? SizedBox(height: 24 * s, width: 24 * s),
      ),
    );
  }
}

class _Boyaci extends CustomPainter {
  _Boyaci(this.fn, {required this.anahtar, this.boyut});
  final void Function(Canvas c) fn;
  final void Function(Canvas c, Size s)? boyut;
  final String anahtar;

  @override
  void paint(Canvas canvas, Size size) {
    if (boyut != null) {
      boyut!(canvas, size);
    } else {
      fn(canvas);
    }
  }

  @override
  bool shouldRepaint(_Boyaci old) => old.anahtar != anahtar || boyut != null;
}

/// Scratch editorunun solundaki kategori dairesi: renkli daire, altinda
/// kategorinin Scratch'teki adi.
class ScratchKategoriDairesi extends StatelessWidget {
  const ScratchKategoriDairesi({
    super.key,
    required this.kategori,
    required this.lang,
    this.cap = 22,
    this.yaziRengi,
  });

  final ScratchKategori kategori;
  final String lang;
  final double cap;
  final Color? yaziRengi;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: cap,
          height: cap,
          decoration: BoxDecoration(
            color: kategori.renk,
            shape: BoxShape.circle,
            border: Border.all(color: kategori.renk3, width: 1),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          kategori.ad(lang),
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: yaziRengi ?? _girdiYazisi,
          ),
        ),
      ],
    );
  }
}

/// Paletin ustundeki kategori seridi (Scratch editorunun sol sutunu,
/// telefona gore yatay).
class ScratchKategoriSeridi extends StatelessWidget {
  const ScratchKategoriSeridi({
    super.key,
    required this.kategoriler,
    required this.lang,
    this.koyu = false,
  });

  final List<ScratchKategori> kategoriler;
  final String lang;
  final bool koyu;

  /// Bloklarin kategorileri, Scratch'teki sirayla, tekrarsiz.
  static List<ScratchKategori> sirala(Iterable<ScratchKategori> k) {
    final set = k.map((e) => e.daire).toSet();
    return ScratchKategori.values.where(set.contains).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        for (final k in kategoriler)
          ScratchKategoriDairesi(
            kategori: k,
            lang: lang,
            cap: 18,
            yaziRengi: koyu ? Colors.white70 : null,
          ),
      ],
    );
  }
}
