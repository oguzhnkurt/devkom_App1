/// mBlock tezgahindan okunan ve beklenen programlarin modeli.
///
/// NEDEN AYRI BIR DOSYA
/// --------------------
/// Tezgah bir WebView; birim testinde acilmiyor. Ama asil is —
/// "cocugun kurdugu program dogru mu" — saf Dart ve WebView'siz
/// sinanabilir. Karsilastirma burada duruyor, tezgah yalnizca JSON
/// tasiyor.
library;

import 'dart:convert';

/// Cocugun tezgahta kurdugu tek bir blok.
class MBlockBlok {
  const MBlockBlok({
    required this.tip,
    this.alanlar = const {},
    this.icerik = const [],
  });

  /// Katalogdaki blok kimligi: `dev_dijital_yaz` gibi.
  final String tip;

  /// Acilir liste ve sayi/metin kutularinin degerleri.
  ///
  /// Anahtar yuvanin adi (`PIN`, `SEVIYE`, `SANIYE`), deger her zaman
  /// metin — sayfa tarafinda hepsi dizeye cevriliyor ki "9" ile 9
  /// ayrimi bir hata kaynagi olmasin.
  final Map<String, String> alanlar;

  /// C blogunun (tekrarla, eger) icindeki bloklar.
  final List<MBlockBlok> icerik;

  static MBlockBlok _birindenOku(Map<String, dynamic> m) => MBlockBlok(
        tip: (m['tip'] ?? '').toString(),
        alanlar: {
          for (final e in ((m['alanlar'] as Map?) ?? {}).entries)
            e.key.toString(): e.value.toString(),
        },
        icerik: _listeOku(m['icerik']),
      );

  static List<MBlockBlok> _listeOku(dynamic liste) {
    if (liste is! List) return const [];
    return liste
        .whereType<Map>()
        .map((m) => _birindenOku(m.cast<String, dynamic>()))
        .toList();
  }

  /// Tezgahin gonderdigi `{"tur":"durum","veri":{"yiginlar":[[...]]}}`
  /// mesajindan yiginlari cikarir.
  ///
  /// Bozuk ya da beklenmedik bir mesaj bos liste dondurur; tezgahin
  /// bir hatasi dersi cokertmemeli.
  static List<List<MBlockBlok>> mesajdanYiginlar(String mesaj) {
    try {
      final j = jsonDecode(mesaj);
      if (j is! Map) return const [];
      if (j['tur'] != 'durum') return const [];
      final veri = j['veri'];
      if (veri is! Map) return const [];
      final yiginlar = veri['yiginlar'];
      if (yiginlar is! List) return const [];
      return yiginlar.map(_listeOku).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  String toString() =>
      '$tip${alanlar.isEmpty ? '' : alanlar}${icerik.isEmpty ? '' : icerik}';
}

/// Dersin beklediği blok.
///
/// [alanlar] BIR ALT KUME: yalnizca yazilan alanlar denetlenir. Ders
/// "pin 9 olsun" diyorsa cocugun `SEVIYE` secimi serbest kalir. Boylece
/// bir dersin neyi olctugu tanimin kendisinden okunuyor.
class MBlockBeklenen {
  const MBlockBeklenen(
    this.tip, {
    this.alanlar = const {},
    this.icerik = const [],
  });

  final String tip;
  final Map<String, String> alanlar;
  final List<MBlockBeklenen> icerik;

  @override
  String toString() =>
      '$tip${alanlar.isEmpty ? '' : alanlar}${icerik.isEmpty ? '' : icerik}';
}

/// Bir blok kurma adiminin tezgah ayari.
class MBlockTezgahAyari {
  const MBlockTezgahAyari({
    required this.bloklar,
    required this.cozum,
    this.baslangicXml,
  });

  /// Arac kutusunda gosterilecek katalog kimlikleri.
  ///
  /// Kasten SINIRLI: cocuga on sekiz blogun tamamini vermek, dersin
  /// sordugu soruyu bir arama isine cevirir.
  final List<String> bloklar;

  /// Dogru program.
  final List<MBlockBeklenen> cozum;

  /// Tahtada hazir duran baslangic programi (varsa).
  final String? baslangicXml;
}

/// Cocugun kurdugu program dersin bekledigiyle ortusuyor mu.
///
/// KURAL
///  * Tahtada tam bir yigin olmali. Iki ayri yigin "yarim birakilmis"
///    demek; tezgah bunu dogru saymiyor.
///  * Blok sirasi ve C kutularinin ici birebir ayni olmali.
///  * Alanlardan yalnizca dersin yazdiklari denetlenir.
bool mblockCozumDogruMu(
  List<List<MBlockBlok>> yiginlar,
  List<MBlockBeklenen> beklenen,
) {
  if (beklenen.isEmpty) return false;
  if (yiginlar.length != 1) return false;
  return _diziUyuyor(yiginlar.first, beklenen);
}

bool _diziUyuyor(List<MBlockBlok> kurulan, List<MBlockBeklenen> beklenen) {
  if (kurulan.length != beklenen.length) return false;
  for (var i = 0; i < kurulan.length; i++) {
    if (!_blokUyuyor(kurulan[i], beklenen[i])) return false;
  }
  return true;
}

bool _blokUyuyor(MBlockBlok k, MBlockBeklenen b) {
  if (k.tip != b.tip) return false;
  for (final e in b.alanlar.entries) {
    final deger = k.alanlar[e.key];
    if (deger == null) return false;
    if (!_degerEsit(deger, e.value)) return false;
  }
  return _diziUyuyor(k.icerik, b.icerik);
}

/// "1" ile "1.0" ayni sayidir.
///
/// Golge bloklarin degeri metin olarak geliyor ve cocuk kutuya "1.0"
/// yazdiginda ya da Blockly degeri "1.0" diye dondurdugunde ders
/// yanlis diyordu. Sayiya cevrilebiliyorsa sayi olarak, cevrilemiyorsa
/// metin olarak karsilastiriliyor.
bool _degerEsit(String a, String b) {
  if (a == b) return true;
  final x = double.tryParse(a);
  final y = double.tryParse(b);
  if (x != null && y != null) return x == y;
  return a.trim().toLowerCase() == b.trim().toLowerCase();
}
