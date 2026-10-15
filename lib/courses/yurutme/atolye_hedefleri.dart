import 'dart:math';

import '../models/interactive_lesson_model.dart';
import 'blok_yorumlayici.dart';
import 'kod_yapisi.dart';

/// PROJE ATOLYESI HEDEFLERI — sonuca bakan denetim.
///
/// Eski blok adimlari tek bir DOGRU SIRA istiyordu. Bir proje ise
/// boyle denetlenemez: ucgeni "3 kere 120 derece" diye de "120 derece,
/// 3 kere" diye de cizen cocuk dogru yapmistir. Hedefler bu yuzden
/// kodun SIRASINA degil, kod CALISINCA ne oldugunu soyleyen
/// [Yurutme]ye bakiyor: kalemin cizdigi cizgiler, kuklanin son konumu,
/// degiskenler, soylenenler, alinan haberler.
///
/// Bir iki hedef KOD yapisina da bakiyor ("bir dongu kullan"): projenin
/// ogrettigi kavram kullanilmadan ayni sonuca varilmasin diye.
class AtolyeSonucu {
  const AtolyeSonucu({required this.yurutme, required this.kod});

  final Yurutme yurutme;

  /// Kod alanindaki ogeler (isaretler dahil).
  final List<KodOgesi> kod;

  Iterable<String> get blokKimlikleri =>
      kod.where((o) => !KodYapisi.isaretMi(o.id)).map((o) => o.id);
}

/// Bir atolye hedefi: cocuga gorunen cumle ve denetimi.
abstract class AtolyeHedefi {
  const AtolyeHedefi({
    required this.metin,
    required this.metinEn,
    required this.metinDe,
    required this.metinEs,
  });

  final String metin;
  final String metinEn;
  final String metinDe;
  final String metinEs;

  String metinFor(String lang) =>
      pickLang(metin, metinEn, lang, metinDe, metinEs);

  bool saglandi(AtolyeSonucu s);
}

/// Kalem cizgilerini KENARLARA cevirir: ayni yone giden ve birbirine
/// degen parcalar tek kenar ("10 kere 10 adim git" tek bir cizgi).
List<KalemCizgisi> kenarlar(List<KalemCizgisi> cizgiler) {
  final out = <KalemCizgisi>[];
  for (final c in cizgiler) {
    if (c.uzunluk < 0.01) continue;
    if (out.isNotEmpty) {
      final o = out.last;
      final bitisik = (o.x2 - c.x1).abs() < 0.5 && (o.y2 - c.y1).abs() < 0.5;
      final a1 = atan2(o.y2 - o.y1, o.x2 - o.x1);
      final a2 = atan2(c.y2 - c.y1, c.x2 - c.x1);
      var fark = (a1 - a2).abs() % (2 * pi);
      if (fark > pi) fark = 2 * pi - fark;
      if (bitisik && fark < 0.01) {
        out[out.length - 1] = KalemCizgisi(o.x1, o.y1, c.x2, c.y2);
        continue;
      }
    }
    out.add(c);
  }
  return out;
}

/// Cizim kapali mi: kalem basladigi noktaya geri dondu mu?
bool kapaliMi(List<KalemCizgisi> cizgiler) {
  final k = kenarlar(cizgiler);
  if (k.length < 3) return false;
  final ilk = k.first, son = k.last;
  return (ilk.x1 - son.x2).abs() < 1.5 && (ilk.y1 - son.y2).abs() < 1.5;
}

/// "Kapali bir sekil ciz" — istenirse tam [kenar] kenarli, yoksa en az
/// [enAzKenar] kenarli.
class KapaliSekilHedefi extends AtolyeHedefi {
  const KapaliSekilHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    this.kenar,
    this.enAzKenar = 3,
  });

  final int? kenar;
  final int enAzKenar;

  @override
  bool saglandi(AtolyeSonucu s) {
    final c = s.yurutme.cizgiler;
    if (!kapaliMi(c)) return false;
    final n = kenarlar(c).length;
    return kenar != null ? n == kenar : n >= enAzKenar;
  }
}

/// "En az N cizgi ciz".
class CizgiHedefi extends AtolyeHedefi {
  const CizgiHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    required this.enAz,
  });

  final int enAz;

  @override
  bool saglandi(AtolyeSonucu s) =>
      kenarlar(s.yurutme.cizgiler).length >= enAz;
}

/// Kuklanin konumu. [herhangiAn] ise yurutmenin HERHANGI bir aninda
/// (zipladi mi?), degilse sonunda (sag kenarda mi bitti?).
class KonumHedefi extends AtolyeHedefi {
  const KonumHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    this.xEnAz,
    this.xEnCok,
    this.yEnAz,
    this.yEnCok,
    this.herhangiAn = false,
  });

  final double? xEnAz, xEnCok, yEnAz, yEnCok;
  final bool herhangiAn;

  bool _uyar(Sahne s) =>
      (xEnAz == null || s.x >= xEnAz!) &&
      (xEnCok == null || s.x <= xEnCok!) &&
      (yEnAz == null || s.y >= yEnAz!) &&
      (yEnCok == null || s.y <= yEnCok!);

  @override
  bool saglandi(AtolyeSonucu s) => herhangiAn
      ? s.yurutme.adimlar.any((a) => _uyar(a.sahne))
      : _uyar(s.yurutme.sonSahne);
}

/// Bir degiskenin SON degeri ("puan 5 olsun").
class DegiskenHedefi extends AtolyeHedefi {
  const DegiskenHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    required this.ad,
    required this.islem,
    required this.deger,
  });

  final String ad;

  /// '=', '>=', '<=', '>', '<'.
  final String islem;
  final num deger;

  @override
  bool saglandi(AtolyeSonucu s) {
    final v = s.yurutme.sonSahne.degiskenler[ad];
    if (v == null) return false;
    return switch (islem) {
      '>=' => v >= deger,
      '<=' => v <= deger,
      '>' => v > deger,
      '<' => v < deger,
      _ => v == deger,
    };
  }
}

/// Kukla bir sey soyledi. [bloklar] verilirse bu bloklardan biri
/// calisarak; [sayi] ise soyledigi bir SAYI ([alt]-[ust] araliginda).
class SoylediHedefi extends AtolyeHedefi {
  const SoylediHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    this.bloklar,
    this.sayi = false,
    this.alt,
    this.ust,
    this.enAz = 1,
  });

  final Set<String>? bloklar;
  final bool sayi;
  final num? alt, ust;
  final int enAz;

  @override
  bool saglandi(AtolyeSonucu s) {
    if (bloklar != null) {
      final n = s.yurutme.adimlar
          .where((a) => bloklar!.contains(a.blokId) && a.sahne.soyledigi != null)
          .length;
      return n >= enAz;
    }
    final sozler = s.yurutme.soylenenler;
    if (!sayi) return sozler.length >= enAz;
    final sayilar = [
      for (final z in sozler)
        if (num.tryParse(z) case final n?)
          if ((alt == null || n >= alt!) && (ust == null || n <= ust!)) n,
    ];
    return sayilar.length >= enAz;
  }
}

/// Bir haber salindi ve ALINDI (alicisi calisti).
class HaberHedefi extends AtolyeHedefi {
  const HaberHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    required this.haber,
  });

  final String haber;

  @override
  bool saglandi(AtolyeSonucu s) => s.yurutme.alinanHaberler.contains(haber);
}

/// Bir olay betigi calisti (`tus:space`, `tikla`, `bayrak`). Sonu `*`
/// ile biten olay onekle eslesiyor (`tus:*` = herhangi bir tus).
class OlayHedefi extends AtolyeHedefi {
  const OlayHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    required this.olay,
    this.bloklar,
  });

  final String olay;

  /// Verilirse betik bu bloklardan en az birini de calistirmis olmali
  /// ("bosluk tusuna basinca bir NOTA calsin").
  final Set<String>? bloklar;

  bool _eslesir(String o) => olay.endsWith('*')
      ? o.startsWith(olay.substring(0, olay.length - 1))
      : o == olay;

  @override
  bool saglandi(AtolyeSonucu s) {
    if (bloklar == null) return s.yurutme.calisanOlaylar.any(_eslesir);
    return s.yurutme.olayBloklari.entries
        .any((e) => _eslesir(e.key) && e.value.any(bloklar!.contains));
  }
}

/// Kodda bu bloklardan biri (en az [enAz] kez) var — "bir dongu kullan".
class BlokHedefi extends AtolyeHedefi {
  const BlokHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    required this.bloklar,
    this.enAz = 1,
  });

  final Set<String> bloklar;
  final int enAz;

  @override
  bool saglandi(AtolyeSonucu s) =>
      s.blokKimlikleri.where(bloklar.contains).length >= enAz;
}

/// Bir liste en az [enAz] ogeli.
class ListeHedefi extends AtolyeHedefi {
  const ListeHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    required this.liste,
    required this.enAz,
  });

  final String liste;
  final int enAz;

  @override
  bool saglandi(AtolyeSonucu s) =>
      (s.yurutme.sonSahne.listeler[liste]?.length ?? 0) >= enAz;
}

/// Kendi blogu en az [farkliGirdi] FARKLI girdiyle cagrildi ("cicek":
/// ayni blok farkli boyda cokgenler ciziyor).
class CagriHedefi extends AtolyeHedefi {
  const CagriHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    required this.yordam,
    this.farkliGirdi = 1,
    this.enAzCagri = 1,
  });

  final String yordam;
  final int farkliGirdi;
  final int enAzCagri;

  @override
  bool saglandi(AtolyeSonucu s) {
    final c = s.yurutme.cagrilar.where((e) => e.$1 == yordam).toList();
    return c.length >= enAzCagri &&
        c.map((e) => e.$2).toSet().length >= farkliGirdi;
  }
}

/// Kostum en az [enAz] kez degisti (dans).
class KostumHedefi extends AtolyeHedefi {
  const KostumHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    required this.enAz,
  });

  final int enAz;

  @override
  bool saglandi(AtolyeSonucu s) => s.yurutme.sonSahne.kostum - 1 >= enAz;
}

/// Bir blok en az [enAz] kez CALISTI (izde gecti).
class CalistiHedefi extends AtolyeHedefi {
  const CalistiHedefi({
    required super.metin,
    required super.metinEn,
    required super.metinDe,
    required super.metinEs,
    required this.bloklar,
    this.enAz = 1,
    this.farkli = false,
  });

  final Set<String> bloklar;
  final int enAz;

  /// Sayilan sey FARKLI blok sayisi ("uc farkli nota").
  final bool farkli;

  @override
  bool saglandi(AtolyeSonucu s) {
    final calisan =
        s.yurutme.adimlar.map((a) => a.blokId).where(bloklar.contains);
    return (farkli ? calisan.toSet().length : calisan.length) >= enAz;
  }
}

/// Atolyenin kodunu calistirir ve her hedefin durumunu dondurur.
class AtolyeDenetimi {
  AtolyeDenetimi._();

  static AtolyeSonucu calistir(List<KodOgesi> kod, List<ScratchBlock> palet,
      {String dil = 'tr', Random? rastgele, int butce = 700}) {
    final y = BlokYorumlayici(butce: butce, dil: dil, rastgele: rastgele)
        .yurutProje(KodYapisi.blokla(kod, palet));
    return AtolyeSonucu(yurutme: y, kod: kod);
  }

  static List<bool> durumlar(
          List<AtolyeHedefi> hedefler, AtolyeSonucu sonuc) =>
      [for (final h in hedefler) h.saglandi(sonuc)];
}
