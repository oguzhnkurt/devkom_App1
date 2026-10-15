import 'dart:ui' show Color;

import '../models/interactive_lesson_model.dart';

/// IC ICE KOD ALANI — belirtec dizisi.
///
/// NEDEN DUZ BIR LISTE
/// -------------------
/// Eski kod alani duz bir liste tutuyordu ve bir C blogunun govdesi
/// kendisinden SONRAKI her seydi. "4 kere {git, don} SONRA Merhaba de"
/// kurulamiyordu; "eger ... degilse ..." hic kurulamiyordu.
///
/// Agac tutmak yerine listeyi koruyup iki ISARET ekledik:
///
///  * [sonId]     — en icteki acik C blogunun sonu (`}`),
///  * [degilseId] — eger-degilse blogunun ikinci kolu (`|`).
///
/// Kod alanina bir C blogu eklenince kapanisi da birlikte geliyor;
/// cocuk isaretleri hic gormuyor, yalnizca C seklini goruyor. Liste
/// oldugu icin eski adimlarin butun mekanigi (sira, surukleme, sahnede
/// calisan blogun sirasi) aynen isliyor; yorumlayici da kapanisi olmayan
/// C blogunda eski kurala ("geri kalan her sey icinde") donuyor — eski
/// adimlar hic degismedi.
class KodYapisi {
  KodYapisi._();

  /// C blogunun sonu.
  static const String sonId = '__son__';

  /// Eger-degilse blogunun "degilse" kolu.
  static const String degilseId = '__degilse__';

  static bool isaretMi(String id) => id == sonId || id == degilseId;

  /// Eger-degilse bloklarinin kimlik oneki.
  static bool egerDegilseMi(String id) => id.startsWith('ifelse_');

  /// Belirtec gosterimi: `}` ve `|`.
  static String belirtec(String id) => switch (id) {
        sonId => '}',
        degilseId => '|',
        _ => id,
      };

  static String kimlik(String belirtec) => switch (belirtec) {
        '}' => sonId,
        '|' => degilseId,
        _ => belirtec,
      };

  /// Isaret bloklari (yorumlayici ve sahne, sira numaralari tutsun diye
  /// listede onlari da goruyor; hicbir etkileri yok).
  static const ScratchBlock sonBlogu = ScratchBlock(
    id: sonId,
    blockType: ScratchBlockType.control,
    shape: ScratchBlockShape.stack,
    label: '',
    color: Color(0xFFFFAB19),
  );
  static const ScratchBlock degilseBlogu = ScratchBlock(
    id: degilseId,
    blockType: ScratchBlockType.control,
    shape: ScratchBlockShape.stack,
    label: '',
    color: Color(0xFFFFAB19),
  );

  /// Belirtec dizisini ("green_flag repeat_4 move_10 } say_hello")
  /// kod ogelerine cevirir. `repeat_4=5` cocugun 4'u 5 yaptigi blok.
  static List<KodOgesi> coz(String belirtecler) => [
        for (final t in belirtecler.split(RegExp(r'\s+')))
          if (t.isNotEmpty)
            if (t.contains('='))
              KodOgesi(t.substring(0, t.indexOf('=')),
                  deger: num.parse(t.substring(t.indexOf('=') + 1)))
            else
              KodOgesi(kimlik(t)),
      ];

  /// Kod ogelerinin belirtec dizisi (degerler dahil degil).
  static String imza(List<KodOgesi> kod) =>
      kod.map((o) => belirtec(o.id)).join(' ');

  /// Belirtec dizisini tek bosluklu hale getirir.
  static String duzle(String belirtecler) =>
      belirtecler.trim().split(RegExp(r'\s+')).join(' ');

  /// Isaretler cikarilinca kalan blok kimlikleri.
  static List<String> bloklar(String belirtecler) => [
        for (final o in coz(belirtecler))
          if (!isaretMi(o.id)) o.id,
      ];

  /// [i]'deki C blogunun kapanisinin sirasi; kapanisi yoksa listenin
  /// sonu (eski kural).
  static int kapanis(List<KodOgesi> kod, int i, bool Function(String) cMi) {
    var derinlik = 0;
    for (var k = i + 1; k < kod.length; k++) {
      final id = kod[k].id;
      if (id == sonId) {
        if (derinlik == 0) return k;
        derinlik--;
      } else if (cMi(id)) {
        derinlik++;
      }
    }
    return kod.length;
  }

  /// [i]'deki eger-degilse blogunun "degilse" isaretinin sirasi, yoksa -1.
  static int degilse(List<KodOgesi> kod, int i, bool Function(String) cMi) {
    final son = kapanis(kod, i, cMi);
    var derinlik = 0;
    for (var k = i + 1; k < son; k++) {
      final id = kod[k].id;
      if (id == sonId) {
        derinlik--;
      } else if (cMi(id)) {
        derinlik++;
      } else if (id == degilseId && derinlik == 0) {
        return k;
      }
    }
    return -1;
  }

  /// [i]'deki blogun kapladigi aralik (C blogu kapanisiyla birlikte).
  static (int, int) aralik(
      List<KodOgesi> kod, int i, bool Function(String) cMi) {
    if (!cMi(kod[i].id)) return (i, i);
    final son = kapanis(kod, i, cMi);
    return (i, son >= kod.length ? kod.length - 1 : son);
  }

  /// [imlec]e blok ekler; C blogu kapanisiyla (ve gerekiyorsa
  /// "degilse"siyle) gelir. Yeni imleci dondurur: C blogunun AGZININ
  /// ici, digerlerinde eklenen blogun hemen alti.
  static int ekle(List<KodOgesi> kod, int imlec, ScratchBlock blok,
      {num? deger}) {
    final i = imlec.clamp(0, kod.length);
    if (blok.shape == ScratchBlockShape.cBlock) {
      kod.insertAll(i, [
        KodOgesi(blok.id, deger: deger),
        if (egerDegilseMi(blok.id)) const KodOgesi(degilseId),
        const KodOgesi(sonId),
      ]);
      return i + 1;
    }
    kod.insert(i, KodOgesi(blok.id, deger: deger));
    return i + 1;
  }

  /// [i]'deki blogu cikarir. C blogunun ICI kaybolmuyor: bloklar bir
  /// kademe disari cikiyor (cocuk dongunun icini yeniden kurmak zorunda
  /// kalmasin). Isaretler de gidiyor.
  static void sil(List<KodOgesi> kod, int i, bool Function(String) cMi) {
    if (i < 0 || i >= kod.length || isaretMi(kod[i].id)) return;
    if (cMi(kod[i].id)) {
      final son = kapanis(kod, i, cMi);
      final d = degilse(kod, i, cMi);
      if (son < kod.length) kod.removeAt(son);
      if (d >= 0) kod.removeAt(d);
    }
    kod.removeAt(i);
  }

  /// [kaynak]taki blogu (C ise butun govdesiyle) [hedef]in ONUNE tasir;
  /// hedef null ise en sona. Hedef kendi govdesinin icindeyse hicbir
  /// sey yapmaz. Yeni yerin sirasini dondurur.
  static int? tasi(List<KodOgesi> kod, int kaynak, int? hedef,
      bool Function(String) cMi) {
    if (kaynak < 0 || kaynak >= kod.length || isaretMi(kod[kaynak].id)) {
      return null;
    }
    final (bas, son) = aralik(kod, kaynak, cMi);
    var h = hedef ?? kod.length;
    if (h >= bas && h <= son + 1) return null; // yerinde kaldi
    final parca = kod.sublist(bas, son + 1);
    kod.removeRange(bas, son + 1);
    if (h > son) h -= parca.length;
    h = h.clamp(0, kod.length);
    kod.insertAll(h, parca);
    return h;
  }

  /// Her ogenin kac C blogunun icinde oldugu.
  static List<int> girintiler(List<KodOgesi> kod, bool Function(String) cMi) {
    final out = <int>[];
    var d = 0;
    for (final o in kod) {
      if (o.id == sonId) {
        d = d > 0 ? d - 1 : 0;
        out.add(d);
      } else if (o.id == degilseId) {
        out.add(d > 0 ? d - 1 : 0);
      } else {
        out.add(d);
        if (cMi(o.id)) d++;
      }
    }
    return out;
  }

  /// Kod ogelerini palet bloklarina cevirir (isaretler isaret blogu,
  /// sayilar [ScratchBlock.degerli]). Palette olmayan kimlik atlanir.
  static List<ScratchBlock> blokla(
      List<KodOgesi> kod, List<ScratchBlock> palet) {
    final harita = {for (final b in palet) b.id: b};
    return [
      for (final o in kod)
        if (o.id == sonId)
          sonBlogu
        else if (o.id == degilseId)
          degilseBlogu
        else if (harita[o.id] case final b?)
          o.deger == null ? b : b.degerli(o.deger),
    ];
  }
}

/// Kod alanindaki tek bir oge: blok kimligi ve (varsa) cocugun yazdigi
/// sayi.
class KodOgesi {
  const KodOgesi(this.id, {this.deger});
  final String id;
  final num? deger;

  KodOgesi degerIle(num? yeni) => KodOgesi(id, deger: yeni);

  Map<String, Object?> toJson() => {
        'id': id,
        if (deger != null) 'd': deger,
      };

  static KodOgesi fromJson(Map<String, Object?> j) =>
      KodOgesi(j['id'] as String, deger: j['d'] as num?);

  @override
  bool operator ==(Object other) =>
      other is KodOgesi && other.id == id && other.deger == deger;

  @override
  int get hashCode => Object.hash(id, deger);

  @override
  String toString() => deger == null ? id : '$id($deger)';
}
