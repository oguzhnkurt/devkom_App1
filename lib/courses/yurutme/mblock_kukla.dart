import 'dart:ui' show Color;

import '../models/interactive_lesson_model.dart';
import 'blok_anlami.dart';
import 'blok_yorumlayici.dart';
import 'mblock_blok_adlari.dart';
import 'mblock_cozum.dart';

/// mBlock tezgahindaki KUKLA programi, Scratch sahnesinin anladigi
/// bicimde: duz bir [ScratchBlock] listesi.
///
/// Scratch sahnesi ([BlockAnimationPlayer] + [BlokYorumlayici]) duz bir
/// liste calistiriyor ve bir C blogunun govdesini "ondan sonra gelen her
/// sey" sayiyor. mBlock tezgahi ise bir agac veriyor (C blogunun ici
/// `icerik`). Agac okuma sirasiyla duzlestiriliyor; derslerdeki her
/// kukla programinda C blogu yiginin sonunda, yani iki yapi ayni.
/// C blogundan SONRA kardes blok varsa (ders cozumu degil, cocugun
/// denemesi) o bloklar da donguye girmis sayilir; [yaklasik] bunu
/// soyluyor.
class MBlockKuklaProgrami {
  const MBlockKuklaProgrami(this.bloklar, {this.yaklasik = false});

  final List<ScratchBlock> bloklar;
  final bool yaklasik;

  bool get bos => bloklar.isEmpty;

  /// Calistirilacak yigin: once bayrakla baslayan, sonra ikiz olarak
  /// baslayan, yoksa ilk yigin.
  static List<MBlockBlok> yiginSec(List<List<MBlockBlok>> yiginlar) {
    for (final bas in const ['dev_bayrak', 'dev_ikiz_basla']) {
      for (final y in yiginlar) {
        if (y.isNotEmpty && y.first.tip == bas) return y;
      }
    }
    return yiginlar.isEmpty ? const [] : yiginlar.first;
  }

  static MBlockKuklaProgrami cevir(
      List<List<MBlockBlok>> yiginlar, String lang) {
    final out = <ScratchBlock>[];
    var yaklasik = false;

    void dizi(List<MBlockBlok> l) {
      for (var i = 0; i < l.length; i++) {
        final b = l[i];
        out.add(_blok(b, out.length, lang));
        final t = mblockBlokTanimlari[b.tip];
        if (t != null && t.cMi) {
          dizi(b.icerik);
          if (i < l.length - 1) yaklasik = true;
        }
      }
    }

    dizi(yiginSec(yiginlar));
    return MBlockKuklaProgrami(out, yaklasik: yaklasik);
  }

  static num? _n(MBlockBlok b, String yuva) =>
      num.tryParse(b.alanlar[yuva] ?? '') ??
      num.tryParse(mblockVarsayilanAlanlar[b.tip]?[yuva] ?? '');

  static ScratchBlock _blok(MBlockBlok b, int sira, String lang) {
    final (BlokKomutu komut, num? sayi, String? degisken) = switch (b.tip) {
      'dev_bayrak' || 'dev_ikiz_basla' => (BlokKomutu.baslat, null, null),
      'dev_git' => (BlokKomutu.ilerle, _n(b, 'ADIM'), null),
      'dev_don' => (BlokKomutu.don, _n(b, 'ACI'), null),
      'dev_yonune_don' => (BlokKomutu.yonAyarla, _n(b, 'YON'), null),
      'dev_y_degistir' => (BlokKomutu.yDegistir, _n(b, 'DY'), null),
      'dev_de' => (BlokKomutu.soyle, null, null),
      'dev_bekle' => (BlokKomutu.bekle, _n(b, 'SANIYE'), null),
      'dev_tekrarla' => (BlokKomutu.tekrarla, _n(b, 'KERE'), null),
      'dev_surekli' => (BlokKomutu.surekli, null, null),
      'dev_eger' => (BlokKomutu.eger, null, null),
      'dev_kostum' => (BlokKomutu.sonrakiKostum, null, null),
      'dev_degisken_degistir' => (
          BlokKomutu.degiskenArtir,
          _n(b, 'DEGER'),
          mblockDegerAdi(b.alanlar['AD'] ?? 'toplananelma', lang),
        ),
      _ => (BlokKomutu.etkisiz, null, null),
    };
    final t = mblockBlokTanimlari[b.tip];
    final sekil = t == null
        ? ScratchBlockShape.stack
        : t.cMi
            ? ScratchBlockShape.cBlock
            : t.sapkaMi
                ? ScratchBlockShape.cap
                : ScratchBlockShape.stack;
    // Etiket her dilde ayni dizeden: cocugun dili sahnede; konusma
    // balonu da bu yazidan cikiyor ("Merhaba! de" -> "Merhaba!").
    String y(String l) => mblockBlokYazisi(b, l);
    return ScratchBlock(
      id: BlokYorumlayici.mblockKimligi(komut,
          sayi: sayi, degisken: degisken, sira: sira),
      blockType: ScratchBlockType.motion,
      shape: sekil,
      label: y('tr'),
      labelEn: y('en'),
      labelDe: y('de'),
      labelEs: y('es'),
      color: t?.renk ?? const Color(0xFF4C97FF),
    );
  }
}
