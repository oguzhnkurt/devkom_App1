/// Devi'nin bilmeceleri ve "Biliyor muydun?" bilgileri.
///
/// Her gun 3 bilmece: 1. her zaman Scratch, 2. mBlock (bes gunde bir
/// Tinkercad), 3. sirayla Arduino, donanim (ic/dis donanim, giris/cikis
/// birimleri) ve Tinkercad. 30 gunluk dongu: 90 bilmece, hicbiri 30 gun
/// icinde tekrar etmiyor. Ayni gun herkes ayni bilmeceleri goruyor.
///
/// Icerik dort dilde `tool/bilmeceler/*.py` dosyalarinda; bu klasordeki
/// `devi_bilmeceleri_veri.dart` oradan URETILIYOR (uret.py). Blok adlari
/// Scratch ve mBlock'un resmi ceviri dosyalarindan alindi.
library;

part 'devi_bilmeceleri_veri.dart';

class Bilmece {
  const Bilmece(this.kategori, this.dogru, this._metin);

  /// scratch, mblock, arduino, tinkercad, donanim
  final String kategori;

  /// Dogru sikkin sirasi (0-2).
  final int dogru;

  /// dil -> [soru, sik1, sik2, sik3, aciklama]
  final Map<String, List<String>> _metin;

  List<String> _dil(String lang) => _metin[lang] ?? _metin['en'] ?? _metin['tr']!;

  String soru(String lang) => _dil(lang)[0];
  List<String> siklar(String lang) => _dil(lang).sublist(1, 4);
  String aciklama(String lang) => _dil(lang)[4];
}

class DeviBilmeceleri {
  DeviBilmeceleri._();

  static const int donguGun = 30;

  static List<Bilmece> get hepsi => _hepsi;

  /// Dongudeki gun (0-29). Yerel takvim gunune gore, gece yarisi degisir.
  static int gunIndeksi(DateTime an) {
    final gun = DateTime.utc(an.year, an.month, an.day)
        .difference(DateTime.utc(2026, 1, 1))
        .inDays;
    return ((gun % donguGun) + donguGun) % donguGun;
  }

  /// O gunun 3 bilmecesi.
  static List<Bilmece> gunun(DateTime an) =>
      [for (final i in _gunler[gunIndeksi(an)]) _hepsi[i]];

  /// O gunun "Biliyor muydun?" bilgisi.
  static String gununBilgisi(DateTime an, String lang) {
    final b = _bilgiler[gunIndeksi(an)];
    return b[lang] ?? b['en']!;
  }

  /// Kayit anahtari icin gun (yyyy-mm-dd).
  static String gunAnahtari(DateTime an) =>
      '${an.year}-${an.month.toString().padLeft(2, '0')}-${an.day.toString().padLeft(2, '0')}';
}
