/// FLUTTER mBLOCK ATOLYESININ KODU — duz belirtec listesi ve agac.
///
/// Scratch atolyesi kodu duz bir [KodOgesi] listesinde tutuyor; C
/// bloklarinin sonu bir isaret ([KodYapisi.sonId]). mBlock atolyesi ayni
/// yapiyi kullaniyor (ekle, sil, tasi, girinti — [KodYapisi]), yalnizca
/// her oge mBlock blogunun ALANLARINI (pin 13, yuksek, 1 saniye) ve
/// YUVALARINA takili bloklari (eger `<dijital oku pin 2>`) da tasiyor:
/// [MBlockKodOgesi].
///
/// Calistirmak icin liste sahnenin anladigi agaca ([MBlockBlok]
/// yiginlari) cevriliyor: [MBlockKod.program]. Sanal Uno ve kukla
/// sahnesi derslerdekiyle ayni yorumlayicilar.
library;

import 'dart:ui' show Color;

import '../../widgets/scratch_blok.dart';
import 'kod_yapisi.dart';
import 'mblock_blok_adlari.dart';
import 'mblock_cozum.dart';
import 'mblock_yuvalari.dart';

/// Kod alanindaki bir mBlock blogu.
class MBlockKodOgesi extends KodOgesi {
  const MBlockKodOgesi(super.id,
      {this.alanlar = const {}, this.girdiler = const {}});

  final Map<String, String> alanlar;
  final Map<String, MBlockBlok> girdiler;

  /// Ic (C) bloklari olmadan blogun kendisi.
  MBlockBlok get blok =>
      MBlockBlok(tip: id, alanlar: alanlar, girdiler: girdiler);

  MBlockKodOgesi blokIle(MBlockBlok b) =>
      MBlockKodOgesi(id, alanlar: b.alanlar, girdiler: b.girdiler);

  @override
  Map<String, Object?> toJson() => {
        'id': id,
        if (alanlar.isNotEmpty) 'a': alanlar,
        if (girdiler.isNotEmpty)
          'g': {for (final e in girdiler.entries) e.key: _blokJson(e.value)},
      };

  static Map<String, Object?> _blokJson(MBlockBlok b) => {
        'tip': b.tip,
        if (b.alanlar.isNotEmpty) 'alanlar': b.alanlar,
        if (b.girdiler.isNotEmpty)
          'girdiler': {
            for (final e in b.girdiler.entries) e.key: _blokJson(e.value)
          },
      };

  @override
  bool operator ==(Object other) =>
      other is MBlockKodOgesi &&
      other.id == id &&
      mblockXml([
            [other.blok]
          ]) ==
          mblockXml([
            [blok]
          ]);

  @override
  int get hashCode => Object.hash(
      id,
      mblockXml([
        [blok]
      ]));

  @override
  String toString() => blok.toString();
}

/// Bir blogun cizimi ve yuvalarin satirdaki yeri.
class MBlockCizim {
  MBlockCizim(this.tanim, this.yuvaAdlari, this.ic);

  final ScratchBlokTanimi tanim;

  /// Satir parcasinin sirasi -> yuvanin adi.
  final Map<int, String> yuvaAdlari;

  /// Satir parcasinin sirasi -> o yuvaya takili blogun cizimi.
  final Map<int, MBlockCizim> ic;

  /// [ScratchBlokOlcer.parcaKutulari]nin yolunu yuva adlarina cevirir
  /// ([2, 0] -> ['KOSUL', 'PIN']). Yol yuvaya varmiyorsa null.
  List<String>? yuvaYolu(List<int> yol) {
    final out = <String>[];
    MBlockCizim? c = this;
    for (var k = 0; k < yol.length; k++) {
      if (c == null) return null;
      final ad = c.yuvaAdlari[yol[k]];
      if (ad == null) return null;
      out.add(ad);
      c = c.ic[yol[k]];
    }
    return out;
  }
}

class MBlockKod {
  MBlockKod._();

  static MBlockBlokTanimi? _t(String tip) => mblockBlokTanimlari[tip];

  static bool cMi(String tip) => _t(tip)?.cMi ?? false;
  static bool sapkaMi(String tip) => _t(tip)?.sapkaMi ?? false;

  /// Oval ya da altigen: yigina degil, bir YUVAYA takilan blok.
  static bool degerMi(String tip) =>
      _t(tip)?.sekil == 'oval' || _t(tip)?.sekil == 'altigen';

  static bool altigenMi(String tip) => _t(tip)?.sekil == 'altigen';

  /// Atolyenin kategori sirasi: once olaylar ve kontrol, sonra cihaz
  /// (mBlock'taki gibi), en sonda kukla kategorileri.
  static const List<ScratchKategori> kategoriSirasi = [
    ScratchKategori.olaylar,
    ScratchKategori.kontrol,
    ScratchKategori.mblockPin,
    ScratchKategori.mblockSeriPort,
    ScratchKategori.mblockSensor,
    ScratchKategori.mblockVeri,
    ScratchKategori.islemler,
    ScratchKategori.degiskenler,
    ScratchKategori.hareket,
    ScratchKategori.gorunum,
    ScratchKategori.ses,
    ScratchKategori.algilama,
  ];

  static ScratchKategori kategori(String k) => switch (k) {
        'pin' => ScratchKategori.mblockPin,
        'seriPort' => ScratchKategori.mblockSeriPort,
        'sensor' => ScratchKategori.mblockSensor,
        'veri' => ScratchKategori.mblockVeri,
        'olaylar' => ScratchKategori.olaylar,
        'kontrol' => ScratchKategori.kontrol,
        'islemler' => ScratchKategori.islemler,
        'degisken' => ScratchKategori.degiskenler,
        'hareket' => ScratchKategori.hareket,
        'gorunum' => ScratchKategori.gorunum,
        'ses' => ScratchKategori.ses,
        _ => ScratchKategori.algilama,
      };

  static ScratchSekil sekil(String s) => switch (s) {
        'sapka' => ScratchSekil.sapka,
        'c' => ScratchSekil.c,
        'cson' => ScratchSekil.cKapak,
        'son' => ScratchSekil.kapak,
        'oval' => ScratchSekil.raportor,
        'altigen' => ScratchSekil.mantiksal,
        _ => ScratchSekil.yigin,
      };

  /// Yeni blogun varsayilan alanlari ("de" blogunun sozu cocugun
  /// dilinde — tezgah.js ile ayni).
  static Map<String, String> varsayilanlar(String tip, String lang) => {
        ...?mblockVarsayilanAlanlar[tip],
        if (tip == 'dev_de')
          'METIN': switch (lang) {
            'en' => 'Hello!',
            'de' => 'Hallo!',
            'es' => '¡Hola!',
            _ => 'Merhaba!',
          },
      };

  static MBlockKodOgesi yeni(String tip, String lang) =>
      MBlockKodOgesi(tip, alanlar: varsayilanlar(tip, lang));

  static MBlockBlok yeniBlok(String tip, String lang) =>
      MBlockBlok(tip: tip, alanlar: varsayilanlar(tip, lang));

  /// [imlec]e blok ekler (C blogu kapanisiyla); yeni imleci dondurur.
  static int ekle(List<KodOgesi> kod, int imlec, MBlockKodOgesi o) {
    final i = imlec.clamp(0, kod.length);
    if (cMi(o.id)) {
      kod.insertAll(i, [o, const KodOgesi(KodYapisi.sonId)]);
    } else {
      kod.insert(i, o);
    }
    return i + 1;
  }

  /// Duz listeyi sahnenin calistirdigi yiginlara cevirir: her sapka
  /// yeni bir yigin; C blogunun ici `icerik`.
  static List<List<MBlockBlok>> program(List<KodOgesi> kod) {
    var i = 0;
    List<MBlockBlok> dizi() {
      final out = <MBlockBlok>[];
      while (i < kod.length) {
        final o = kod[i];
        if (o.id == KodYapisi.sonId) {
          i++;
          return out;
        }
        i++;
        if (o is! MBlockKodOgesi) continue;
        if (cMi(o.id)) {
          final ic = dizi();
          out.add(MBlockBlok(
              tip: o.id,
              alanlar: o.alanlar,
              girdiler: o.girdiler,
              icerik: ic));
        } else {
          out.add(o.blok);
        }
      }
      return out;
    }

    final yiginlar = <List<MBlockBlok>>[];
    while (i < kod.length) {
      final o = kod[i];
      if (o.id == KodYapisi.sonId) {
        i++;
        continue;
      }
      // Ust duzeyde: sapka yeni yigin; sapkasiz blok onceki yigina.
      final tek = <MBlockBlok>[];
      final yeniYigin = sapkaMi(o.id) || yiginlar.isEmpty;
      i++;
      if (o is MBlockKodOgesi) {
        if (cMi(o.id)) {
          tek.add(MBlockBlok(
              tip: o.id,
              alanlar: o.alanlar,
              girdiler: o.girdiler,
              icerik: dizi()));
        } else {
          tek.add(o.blok);
        }
      }
      if (yeniYigin) {
        yiginlar.add(tek);
      } else {
        yiginlar.last.addAll(tek);
      }
    }
    return yiginlar;
  }

  /// Yiginlari duz listeye cevirir (hazir program yuklemek).
  static List<KodOgesi> duzle(List<List<MBlockBlok>> yiginlar) {
    final out = <KodOgesi>[];
    void blok(MBlockBlok b) {
      out.add(MBlockKodOgesi(b.tip, alanlar: b.alanlar, girdiler: b.girdiler));
      if (cMi(b.tip)) {
        b.icerik.forEach(blok);
        out.add(const KodOgesi(KodYapisi.sonId));
      }
    }

    for (final y in yiginlar) {
      y.forEach(blok);
    }
    return out;
  }

  // ------------------------------------------------------------------
  // Cizim
  // ------------------------------------------------------------------

  static Color _renk(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.tryParse('FF$h', radix: 16) ?? 0xFF663B00);
  }

  /// Blogun Scratch 3 cizimi: etiket mBlock katalogundan (dort dil),
  /// yuvalar degerleriyle; takili bloklar icinde.
  static MBlockCizim cizim(MBlockBlok b, String lang) {
    final t = _t(b.tip);
    if (t == null) {
      return MBlockCizim(
          ScratchBlokTanimi(
              kategori: ScratchKategori.kontrol,
              sekil: ScratchSekil.yigin,
              satir: [SbYazi(b.tip)]),
          const {},
          const {});
    }
    final sablon = t.etiket[lang] ?? t.etiket['en']!;
    final parcalar = <SbParca>[];
    final yuvaAdlari = <int, String>{};
    final ic = <int, MBlockCizim>{};
    var i = 0;
    void yazi(String s) {
      final y = s.trim();
      if (y.isNotEmpty) parcalar.add(SbYazi(y));
    }

    for (final m in RegExp(r'%(\d)').allMatches(sablon)) {
      yazi(sablon.substring(i, m.start));
      i = m.end;
      final n = int.parse(m.group(1)!);
      if (t.yuvalar.isEmpty) {
        parcalar.add(const SbIkon(ScratchIkon.bayrak));
        continue;
      }
      if (n - 1 >= t.yuvalar.length) continue;
      final ad = t.yuvalar[n - 1];
      final yuva = mblockYuva(b.tip, ad);
      final takili = b.girdiler[ad];
      yuvaAdlari[parcalar.length] = ad;
      if (takili != null) {
        final c = cizim(takili, lang);
        ic[parcalar.length] = c;
        parcalar.add(SbIcBlok(c.tanim));
        continue;
      }
      final deger = b.alanlar[ad] ?? varsayilanlar(b.tip, lang)[ad] ?? '';
      parcalar.add(switch (yuva?.tur) {
        MBlockYuvaTuru.secim => SbAcilir(_secenekAdi(yuva!, deger, lang),
            kutu: ad == 'AD'),
        MBlockYuvaTuru.kosul => const SbBosKosul(),
        MBlockYuvaTuru.renk => SbRenk(_renk(deger), deger),
        _ => SbGirdi(deger),
      });
    }
    yazi(sablon.substring(i));
    return MBlockCizim(
      ScratchBlokTanimi(
        kategori: kategori(t.kategori),
        sekil: sekil(t.sekil),
        satir: parcalar,
        tekrarOku: b.tip == 'dev_tekrarla' || b.tip == 'dev_surekli',
      ),
      yuvaAdlari,
      ic,
    );
  }

  static String _secenekAdi(MBlockYuva y, String deger, String lang) {
    for (final (ad, d) in y.seceneklerFor(lang)) {
      if (d == deger) return ad;
    }
    return mblockDegerAdi(deger, lang);
  }

  // ------------------------------------------------------------------
  // Yuvalar
  // ------------------------------------------------------------------

  /// [b]nin [yol]daki yuvasini [fn] ile degistirir (yol ['KOSUL', 'PIN']:
  /// KOSUL'a takili blogun PIN'i).
  static MBlockBlok _yoldaDegistir(MBlockBlok b, List<String> yol,
      MBlockBlok Function(MBlockBlok sahip, String yuva) fn) {
    if (yol.length == 1) return fn(b, yol.first);
    final ic = b.girdiler[yol.first];
    if (ic == null) return b;
    return MBlockBlok(
      tip: b.tip,
      alanlar: b.alanlar,
      icerik: b.icerik,
      girdiler: {...b.girdiler, yol.first: _yoldaDegistir(ic, yol.sublist(1), fn)},
    );
  }

  /// Yuvanin degeri (alan).
  static MBlockBlok alanYaz(MBlockBlok b, List<String> yol, String deger) =>
      _yoldaDegistir(
          b,
          yol,
          (s, y) => MBlockBlok(
              tip: s.tip,
              alanlar: {...s.alanlar, y: deger},
              icerik: s.icerik,
              girdiler: {...s.girdiler}..remove(y)));

  /// Yuvaya blok takar.
  static MBlockBlok tak(MBlockBlok b, List<String> yol, MBlockBlok takilan) =>
      _yoldaDegistir(
          b,
          yol,
          (s, y) => MBlockBlok(
              tip: s.tip,
              alanlar: s.alanlar,
              icerik: s.icerik,
              girdiler: {...s.girdiler, y: takilan}));

  /// Yuvadaki blogu cikarir (yuva varsayilan degerine doner).
  static MBlockBlok cikar(MBlockBlok b, List<String> yol) => _yoldaDegistir(
      b,
      yol,
      (s, y) => MBlockBlok(
          tip: s.tip,
          alanlar: s.alanlar,
          icerik: s.icerik,
          girdiler: {...s.girdiler}..remove(y)));

  /// [yol]daki yuvanin sahibi olan blok ([b]nin kendisi ya da takili
  /// bir blok).
  static MBlockBlok? sahip(MBlockBlok b, List<String> yol) {
    var s = b;
    for (var k = 0; k < yol.length - 1; k++) {
      final ic = s.girdiler[yol[k]];
      if (ic == null) return null;
      s = ic;
    }
    return s;
  }

  /// [tip] blogunun takilabilecegi ilk BOS yuvanin yolu (derinlemesine,
  /// soldan saga). Altigen kosul yuvasina, oval sayi/metin yuvasina.
  static List<String>? bosYuva(MBlockBlok b, String tip) {
    final altigen = altigenMi(tip);
    for (final ad in _t(b.tip)?.yuvalar ?? const <String>[]) {
      final y = mblockYuva(b.tip, ad);
      if (y == null) continue;
      final ic = b.girdiler[ad];
      if (ic != null) {
        final derin = bosYuva(ic, tip);
        if (derin != null) return [ad, ...derin];
        continue;
      }
      if (altigen ? y.tur == MBlockYuvaTuru.kosul : y.tur.ovalAlir) {
        return [ad];
      }
    }
    return null;
  }
}
