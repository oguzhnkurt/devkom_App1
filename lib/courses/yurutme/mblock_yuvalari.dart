/// mBlock bloklarinin YUVALARI: tur, varsayilan deger ve acilir liste
/// secenekleri — `assets/mblock/mblock_bloklari.js` icindeki `yuva(...)`
/// tanimlarinin Dart kopyasi.
///
/// Flutter mBlock atolyesi ([MBlockFlutterTezgahi]) WebView'siz calisiyor:
/// sayi kutusuna dokununca tus takimi, pin listesine dokununca kucuk bir
/// secici aciliyor; bunun icin her yuvanin ne oldugunu bilmesi gerekiyor.
/// `test/mblock_yuvalari_test.dart` iki kopyanin ayrismadigini denetliyor.
library;

/// Yuva turu (JS'teki `tip`).
enum MBlockYuvaTuru {
  /// Oval sayi (ondalik, eksi olabilir).
  sayi,

  /// Yalnizca tam sayi.
  tamsayi,

  /// 0'dan buyuk sayi.
  pozitif,

  /// Oval metin.
  metin,

  /// Acilir liste (alan; icine blok takilmaz).
  secim,

  /// Altigen yuva: icine dogru/yanlis blogu takilir.
  kosul,

  /// Renk ovali.
  renk;

  /// Icine oval (deger) blok takilabilir mi? Scratch'te sayi ve metin
  /// golgeleri bir deger yuvasi: ustune oval blok birakilir.
  bool get ovalAlir =>
      this == sayi || this == tamsayi || this == pozitif || this == metin;

  bool get sayiMi => this == sayi || this == tamsayi || this == pozitif;
}

/// Bir yuvanin tarifi.
class MBlockYuva {
  const MBlockYuva(this.ad, this.tur, {this.secenekler});

  final String ad;
  final MBlockYuvaTuru tur;

  /// Acilir liste secenekleri: dil -> [(gorunen ad, deger)]. Dilden
  /// bagimsiz listelerde (pin numaralari) yalnizca `*` anahtari var.
  final Map<String, List<(String, String)>>? secenekler;

  List<(String, String)> seceneklerFor(String lang) =>
      secenekler?[lang] ?? secenekler?['*'] ?? secenekler?['en'] ?? const [];
}

List<(String, String)> _pinler(Iterable<int> p) =>
    [for (final n in p) ('$n', '$n')];

final Map<String, List<(String, String)>> _dijitalPinler = {
  '*': _pinler(List.generate(14, (i) => i)),
};
final Map<String, List<(String, String)>> _pwmPinler = {
  '*': _pinler(const [3, 5, 6, 9, 10, 11]),
};
final Map<String, List<(String, String)>> _okumaPinleri = {
  '*': _pinler(List.generate(12, (i) => i + 2)),
};
final Map<String, List<(String, String)>> _analogPinler = {
  '*': _pinler(List.generate(6, (i) => i)),
};

/// Iki degisken blogunun (yap / degistir) ortak listesi.
const Map<String, List<(String, String)>> _degiskenler = {
  'tr': [
    ('parlaklik', 'parlaklik'),
    ('sayaç', 'sayac'),
    ('açı', 'aci'),
    ('toplananelma', 'toplananelma'),
  ],
  'en': [
    ('brightness', 'parlaklik'),
    ('counter', 'sayac'),
    ('angle', 'aci'),
    ('score', 'toplananelma'),
  ],
  'de': [
    ('helligkeit', 'parlaklik'),
    ('zähler', 'sayac'),
    ('winkel', 'aci'),
    ('punkte', 'toplananelma'),
  ],
  'es': [
    ('brillo', 'parlaklik'),
    ('contador', 'sayac'),
    ('ángulo', 'aci'),
    ('puntos', 'toplananelma'),
  ],
};

/// Katalog kimligi -> yuvalar (`%1`, `%2` sirasiyla; bkz.
/// `mblockBlokTanimlari[tip].yuvalar`).
final Map<String, List<MBlockYuva>> mblockYuvalari = {
  'dev_bayrak': const [],
  'dev_kart_acilis': const [],
  'dev_surekli': const [],
  'dev_tekrarla': const [MBlockYuva('KERE', MBlockYuvaTuru.tamsayi)],
  'dev_bekle': const [MBlockYuva('SANIYE', MBlockYuvaTuru.pozitif)],
  'dev_eger': const [MBlockYuva('KOSUL', MBlockYuvaTuru.kosul)],
  'dev_dijital_yaz': [
    MBlockYuva('PIN', MBlockYuvaTuru.secim, secenekler: _dijitalPinler),
    const MBlockYuva('SEVIYE', MBlockYuvaTuru.secim, secenekler: {
      'tr': [('yüksek', 'HIGH'), ('düşük', 'LOW')],
      'en': [('high', 'HIGH'), ('low', 'LOW')],
      'de': [('hoch', 'HIGH'), ('niedrig', 'LOW')],
      'es': [('alto', 'HIGH'), ('bajo', 'LOW')],
    }),
  ],
  'dev_pwm_yaz': [
    MBlockYuva('PIN', MBlockYuvaTuru.secim, secenekler: _pwmPinler),
    const MBlockYuva('GUC', MBlockYuvaTuru.tamsayi),
  ],
  'dev_dijital_oku': [
    MBlockYuva('PIN', MBlockYuvaTuru.secim, secenekler: _okumaPinleri),
  ],
  'dev_analog_oku': [
    MBlockYuva('PIN', MBlockYuvaTuru.secim, secenekler: _analogPinler),
  ],
  'dev_servo': [
    MBlockYuva('PIN', MBlockYuvaTuru.secim, secenekler: _pwmPinler),
    const MBlockYuva('ACI', MBlockYuvaTuru.tamsayi),
  ],
  'dev_seri_yaz': const [MBlockYuva('METIN', MBlockYuvaTuru.metin)],
  'dev_mesafe': const [
    MBlockYuva('TRIG', MBlockYuvaTuru.tamsayi),
    MBlockYuva('ECHO', MBlockYuvaTuru.tamsayi),
  ],
  'dev_harita': const [
    MBlockYuva('DEGER', MBlockYuvaTuru.sayi),
    MBlockYuva('A', MBlockYuvaTuru.sayi),
    MBlockYuva('B', MBlockYuvaTuru.sayi),
    MBlockYuva('C', MBlockYuvaTuru.sayi),
    MBlockYuva('D', MBlockYuvaTuru.sayi),
  ],
  'dev_degil': const [MBlockYuva('KOSUL', MBlockYuvaTuru.kosul)],
  'dev_kucuktur': const [
    MBlockYuva('A', MBlockYuvaTuru.sayi),
    MBlockYuva('B', MBlockYuvaTuru.sayi),
  ],
  'dev_degisken_yap': const [
    MBlockYuva('AD', MBlockYuvaTuru.secim, secenekler: _degiskenler),
    MBlockYuva('DEGER', MBlockYuvaTuru.sayi),
  ],
  'dev_ton': [
    MBlockYuva('PIN', MBlockYuvaTuru.secim, secenekler: _okumaPinleri),
    const MBlockYuva('FREKANS', MBlockYuvaTuru.tamsayi),
    const MBlockYuva('SANIYE', MBlockYuvaTuru.pozitif),
  ],
  'dev_sicaklik': [
    MBlockYuva('PIN', MBlockYuvaTuru.secim, secenekler: _analogPinler),
  ],
  'dev_buyuktur': const [
    MBlockYuva('A', MBlockYuvaTuru.sayi),
    MBlockYuva('B', MBlockYuvaTuru.sayi),
  ],
  'dev_bekle_kadar': const [MBlockYuva('KOSUL', MBlockYuvaTuru.kosul)],
  'dev_sayac_oku': const [],
  'dev_aci_oku': const [],
  'dev_degisken_oku': const [],
  'dev_git': const [MBlockYuva('ADIM', MBlockYuvaTuru.sayi)],
  'dev_don': const [MBlockYuva('ACI', MBlockYuvaTuru.sayi)],
  'dev_de': const [MBlockYuva('METIN', MBlockYuvaTuru.metin)],
  'dev_boyut': const [MBlockYuva('MIKTAR', MBlockYuvaTuru.sayi)],
  'dev_yonune_don': const [MBlockYuva('YON', MBlockYuvaTuru.sayi)],
  'dev_sek': const [],
  'dev_kostum': const [],
  'dev_ses_bitene': const [MBlockYuva('SES', MBlockYuvaTuru.metin)],
  'dev_x_yap': const [MBlockYuva('X', MBlockYuvaTuru.sayi)],
  'dev_y_yap': const [MBlockYuva('Y', MBlockYuvaTuru.sayi)],
  'dev_y_degistir': const [MBlockYuva('DY', MBlockYuvaTuru.sayi)],
  'dev_fare_x': const [],
  'dev_dokunuyor': const [
    MBlockYuva('NESNE', MBlockYuvaTuru.secim, secenekler: {
      'tr': [('Kase', 'Kase')],
      'en': [('Bowl', 'Kase')],
      'de': [('Schüssel', 'Kase')],
      'es': [('Cuenco', 'Kase')],
    }),
  ],
  'dev_renge_dokunuyor': const [MBlockYuva('RENK', MBlockYuvaTuru.renk)],
  'dev_ikiz_basla': const [],
  'dev_ikizi_sil': const [],
  'dev_goster': const [],
  'dev_gizle': const [],
  'dev_degisken_degistir': const [
    MBlockYuva('AD', MBlockYuvaTuru.secim, secenekler: _degiskenler),
    MBlockYuva('DEGER', MBlockYuvaTuru.sayi),
  ],
};

/// [tip] blogunun [ad] yuvasi (yoksa null).
MBlockYuva? mblockYuva(String tip, String ad) {
  for (final y in mblockYuvalari[tip] ?? const <MBlockYuva>[]) {
    if (y.ad == ad) return y;
  }
  return null;
}
