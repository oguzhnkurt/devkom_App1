import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../utils/lang.dart';
import 'kategorili_tezgah.dart';

export 'kategorili_tezgah.dart'
    show PaletOgesi, KodIcerigi, TezgahHedefi, KategoriliTezgah,
        KategoriliTezgahState;

/// "Bloklar | Kod alani" karti — acilis sahnesinde ve butun Scratch blok
/// kurma adimlarinda ayni.
///
/// Scratch editorundeki gibi: solda hafif gri palet seridi, ince bir
/// ayrac, sagda beyaz kod alani. Dar ekranda (kart [dikeyEsik]'ten dar)
/// palet ustte, kod alani altta — bloklar okunamayacak kadar kuculmesin.
class BlokTezgahiKarti extends StatelessWidget {
  const BlokTezgahiKarti({
    super.key,
    required this.lang,
    required this.palet,
    required this.kod,
    this.sigdir = false,
    this.paletPayi = 9,
    this.kodPayi = 11,
    this.dikeyEsik = 0,
    this.kodVurgusu,
    this.dolgu = 12,
  })  : ogeler = null,
        kodIcerigi = null,
        paletHedefi = null,
        kodHedefi = null,
        yukseklik = null,
        kodSayisi = 0,
        kodSurumu = 0,
        calisiyor = false,
        tezgahAnahtari = null;

  /// SINIRLI YUKSEKLIKLI, KATEGORILI tezgah (ders adimlari ve Proje
  /// Atolyesi): kategori sekmeleri, kod alaniyla ayni olcekte palet,
  /// palet ve kod alani kendi iclerinde kayiyor. Bkz. [KategoriliTezgah].
  const BlokTezgahiKarti.kategorili({
    super.key,
    required this.lang,
    required List<PaletOgesi> this.ogeler,
    required KodIcerigi this.kodIcerigi,
    this.paletHedefi,
    this.kodHedefi,
    this.kodVurgusu,
    this.yukseklik,
    this.kodSayisi = 0,
    this.kodSurumu = 0,
    this.calisiyor = false,
    this.tezgahAnahtari,
  })  : palet = const SizedBox.shrink(),
        kod = const SizedBox.shrink(),
        sigdir = false,
        paletPayi = 1,
        kodPayi = 1,
        dikeyEsik = 0,
        dolgu = 0;

  final String lang;
  final Widget palet;
  final Widget kod;

  /// [BlokTezgahiKarti.kategorili] alanlari.
  final List<PaletOgesi>? ogeler;
  final KodIcerigi? kodIcerigi;
  final TezgahHedefi? paletHedefi;
  final TezgahHedefi? kodHedefi;
  final double? yukseklik;
  final int kodSayisi;
  final int kodSurumu;
  final bool calisiyor;
  final GlobalKey<KategoriliTezgahState>? tezgahAnahtari;

  /// Tezgahtaki blok olcegi (palet ve kod alani ayni). Scratch editoru
  /// 0.675 ile ciziyor; dar telefonda biraz daha kucuk.
  static double olcekFor(double kartGenisligi) => kartGenisligi < 420
      ? 0.62
      : kartGenisligi < 600
          ? 0.68
          : 0.75;

  /// Kucuk ekran: yukseklik 700'den ya da genislik 380'den az (iPhone
  /// SE, 360x640 Android). Hedefler ozete iner, sahne kisalir.
  static bool kompakt(BuildContext context) {
    final s = MediaQuery.sizeOf(context);
    return s.height < 700 || s.width < 380;
  }

  /// Sinirli tezgahin yuksekligi: sahnenin altinda kalan ekran (en az
  /// ekranin %45i), 320..560 arasi. [ustunde]: sahne kartinin boyu.
  static double yukseklikFor(BuildContext context, {double ustunde = 0}) {
    final mq = MediaQuery.of(context);
    final ekran = mq.size.height - mq.padding.vertical - kToolbarHeight;
    final kalan = ekran - ustunde - 24;
    return math.max(kalan, ekran * 0.45).clamp(320.0, 560.0);
  }

  /// true: icerik kartin yuksekligine olceklenerek sigdiriliyor (sabit
  /// yukseklikli acilis sahnesi). false: kart icerik kadar uzuyor (ders
  /// adimi, sayfa kayiyor).
  final bool sigdir;

  final int paletPayi;
  final int kodPayi;

  /// Bu genislikten dar kartta palet ustte, kod altta.
  final double dikeyEsik;

  /// Kod alaninin uzerinde blok suruklenirken hafif renk.
  final Color? kodVurgusu;

  final double dolgu;

  static const Color paletRengi = Color(0xFFF4F6FA);
  static const Color ayracRengi = Color(0xFFE3E7EE);

  @override
  Widget build(BuildContext context) {
    if (ogeler != null) {
      return KategoriliTezgah(
        key: tezgahAnahtari,
        lang: lang,
        ogeler: ogeler!,
        kodIcerigi: kodIcerigi!,
        paletHedefi: paletHedefi,
        kodHedefi: kodHedefi,
        kodVurgusu: kodVurgusu,
        yukseklik: yukseklik,
        kodSayisi: kodSayisi,
        kodSurumu: kodSurumu,
        calisiyor: calisiyor,
      );
    }
    Widget bolum(String baslik, Widget icerik) {
      final govde = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlokTezgahiBasligi(baslik),
          const SizedBox(height: 10),
          icerik,
        ],
      );
      if (!sigdir) return govde;
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: govde,
      );
    }

    final paletBolumu = bolum(
        AppLang.pick(lang,
            tr: 'Bloklar', en: 'Blocks', de: 'Blöcke', es: 'Bloques'),
        palet);
    final kodBolumu = bolum(
        AppLang.pick(lang,
            tr: 'Kod alanı',
            en: 'Code area',
            de: 'Codebereich',
            es: 'Área de código'),
        kod);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (context, c) {
        final dikey = c.maxWidth < dikeyEsik;
        if (dikey) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: sigdir ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Container(
                color: paletRengi,
                padding: EdgeInsets.all(dolgu),
                alignment: Alignment.topLeft,
                child: paletBolumu,
              ),
              Container(height: 1, color: ayracRengi),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                color: kodVurgusu ?? Colors.white,
                padding: EdgeInsets.all(dolgu),
                alignment: Alignment.topLeft,
                child: kodBolumu,
              ),
            ],
          );
        }
        // Yan yana. Palet seridinin grisi ve ayrac ARKA PLANDA boyaniyor:
        // iki sutun farkli boyda olsa da gri serit kartin dibine kadar
        // iniyor (IntrinsicHeight gerekmiyor; kod alani LayoutBuilder
        // kullaniyor ve intrinsic olcum desteklemiyor).
        final oran = paletPayi / (paletPayi + kodPayi);
        return CustomPaint(
          painter: _TezgahZemini(oran: oran, kodVurgusu: kodVurgusu),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: paletPayi,
                child: Padding(
                  padding: EdgeInsets.all(dolgu),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: paletBolumu,
                  ),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                flex: kodPayi,
                child: Padding(
                  padding: EdgeInsets.all(dolgu),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: kodBolumu,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _TezgahZemini extends CustomPainter {
  _TezgahZemini({required this.oran, this.kodVurgusu});
  final double oran;
  final Color? kodVurgusu;

  @override
  void paint(Canvas canvas, Size size) {
    // Row: Expanded(p) + 1 + Expanded(k) -> palet genisligi.
    final pw = (size.width - 1) * oran;
    canvas.drawRect(Rect.fromLTWH(0, 0, pw, size.height),
        Paint()..color = BlokTezgahiKarti.paletRengi);
    canvas.drawRect(Rect.fromLTWH(pw, 0, 1, size.height),
        Paint()..color = BlokTezgahiKarti.ayracRengi);
    if (kodVurgusu != null) {
      canvas.drawRect(
          Rect.fromLTWH(pw + 1, 0, size.width - pw - 1, size.height),
          Paint()..color = kodVurgusu!);
    }
  }

  @override
  bool shouldRepaint(covariant _TezgahZemini old) =>
      old.oran != oran || old.kodVurgusu != kodVurgusu;
}

/// "Bloklar" / "Kod alani" basligi.
class BlokTezgahiBasligi extends StatelessWidget {
  const BlokTezgahiBasligi(this.metin, {super.key});
  final String metin;

  @override
  Widget build(BuildContext context) => Text(
        metin,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 0.4,
        ),
      );
}
