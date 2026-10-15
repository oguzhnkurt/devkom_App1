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
    this.girdiler = const {},
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

  /// Bir YUVAYA takilan blok: altigen kosul, oval deger.
  ///
  /// `alanlar` ile farki su: sayi ve metin kutularinin bir DEGERI var
  /// ("9", "Merhaba"); yuvaya takilan blogun degeri yok, kendisi var
  /// ("dijital oku pin 2"). Ikisi ayri alanlarda duruyor cunku ders
  /// "kutuya 9 yaz" ile "yuvaya su blogu tak" diye iki ayri sey
  /// sorabiliyor.
  ///
  /// Anahtar yuvanin adi (`KOSUL`, `GUC`).
  final Map<String, MBlockBlok> girdiler;

  static MBlockBlok _birindenOku(Map<String, dynamic> m) => MBlockBlok(
        tip: (m['tip'] ?? '').toString(),
        alanlar: {
          for (final e in ((m['alanlar'] as Map?) ?? {}).entries)
            e.key.toString(): e.value.toString(),
        },
        icerik: _listeOku(m['icerik']),
        girdiler: {
          for (final e in ((m['girdiler'] as Map?) ?? {}).entries)
            if (e.value is Map)
              e.key.toString():
                  _birindenOku((e.value as Map).cast<String, dynamic>()),
        },
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
    this.girdiler = const {},
    this.kardesKosullarSerbest = false,
  });

  final String tip;
  final Map<String, String> alanlar;
  final List<MBlockBeklenen> icerik;

  /// [icerik]teki YAN YANA "eger" bloklarinin sirasi serbest.
  ///
  /// `surekli { eger basili {yak}  eger basili degil {sondur} }` ile
  /// iki "eger"i ters sirada kuran cocuk ayni programi yazmis olur;
  /// denetleyici ise sirayi birebir istiyordu. Yalnizca ardisik "eger"
  /// gruplari icinde serbest: "eger"den once/sonra gelen bloklarin
  /// sirasi yine denetleniyor.
  final bool kardesKosullarSerbest;

  /// Yuvaya takilmasi beklenen bloklar. [alanlar] gibi bir ALT KUME:
  /// yalnizca yazilan yuvalar denetlenir.
  final Map<String, MBlockBeklenen> girdiler;

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
///  * Blok sirasi ve C kutularinin ici birebir ayni olmali (bir C
///    kutusu [MBlockBeklenen.kardesKosullarSerbest] diyorsa icindeki
///    yan yana "eger"lerin sirasi serbest).
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
  for (final e in b.girdiler.entries) {
    final takili = k.girdiler[e.key];
    if (takili == null) return false;
    if (!_blokUyuyor(takili, e.value)) return false;
  }
  return b.kardesKosullarSerbest
      ? _diziUyuyorKosullarSerbest(k.icerik, b.icerik)
      : _diziUyuyor(k.icerik, b.icerik);
}

/// Sirasi serbest sayilan kosul bloklari.
const Set<String> _kosulBloklari = {'dev_eger', 'dev_eger_degilse'};

/// [_diziUyuyor] gibi; ama beklenen dizideki ardisik kosul bloklari
/// (bir grup) kurulan dizide AYNI YERDE herhangi bir sirada olabilir.
bool _diziUyuyorKosullarSerbest(
    List<MBlockBlok> kurulan, List<MBlockBeklenen> beklenen) {
  if (kurulan.length != beklenen.length) return false;
  var i = 0;
  while (i < beklenen.length) {
    if (!_kosulBloklari.contains(beklenen[i].tip)) {
      if (!_blokUyuyor(kurulan[i], beklenen[i])) return false;
      i++;
      continue;
    }
    var j = i;
    while (j < beklenen.length && _kosulBloklari.contains(beklenen[j].tip)) {
      j++;
    }
    if (!_eslesmeVar(kurulan.sublist(i, j), beklenen.sublist(i, j))) {
      return false;
    }
    i = j;
  }
  return true;
}

/// Iki grup birebir eslesebiliyor mu (sira serbest)? Gruplar kucuk
/// (iki uc blok), geri izleme yeterli.
bool _eslesmeVar(List<MBlockBlok> kurulan, List<MBlockBeklenen> beklenen) {
  if (beklenen.isEmpty) return kurulan.isEmpty;
  final b = beklenen.first;
  for (var k = 0; k < kurulan.length; k++) {
    if (_blokUyuyor(kurulan[k], b) &&
        _eslesmeVar([...kurulan]..removeAt(k), beklenen.sublist(1))) {
      return true;
    }
  }
  return false;
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

// ---------------------------------------------------------------------
// Ipucu: ilk fark
// ---------------------------------------------------------------------

/// Cocugun programi ile cozum arasindaki ILK farkin turu.
enum MBlockFarkTuru {
  /// Tahtada hic blok yok.
  bosTahta,

  /// Birden fazla yigin: bir parca kopuk duruyor.
  cokYigin,

  /// O sirada bir blok olmali ama yok.
  eksikBlok,

  /// O sirada fazladan bir blok var.
  fazlaBlok,

  /// O sirada baska bir blok olmali.
  farkliBlok,

  /// Blok dogru, bir kutudaki deger (pin, sayi) farkli.
  deger,

  /// Blok dogru, yuvasina takilan blok eksik ya da farkli.
  girdi,
}

/// Ilk farkin yeri ve ne oldugu. [sira] cocugun okudugu sirayla (blok,
/// C kutusunun ici, alttaki blok) 1'den sayilir.
class MBlockFark {
  const MBlockFark(this.tur,
      {this.sira = 0, this.beklenenTip, this.kurulanTip, this.yuva});

  final MBlockFarkTuru tur;
  final int sira;
  final String? beklenenTip;
  final String? kurulanTip;
  final String? yuva;

  @override
  String toString() => 'MBlockFark($tur, $sira, $beklenenTip, $kurulanTip, $yuva)';
}

/// Cocugun programinin cozumden ILK ayrildigi yer; program dogruysa null.
///
/// Ipucu cevabi ele vermesin diye yalnizca YERI ve orada beklenen blogun
/// TURUNU soyluyor; kutulardaki degerleri soylemiyor.
MBlockFark? mblockIlkFark(
  List<List<MBlockBlok>> yiginlar,
  List<MBlockBeklenen> beklenen,
) {
  if (mblockCozumDogruMu(yiginlar, beklenen)) return null;
  if (yiginlar.isEmpty || yiginlar.every((y) => y.isEmpty)) {
    return const MBlockFark(MBlockFarkTuru.bosTahta);
  }
  if (yiginlar.length != 1) return const MBlockFark(MBlockFarkTuru.cokYigin);
  final sayac = [0];
  return _diziFark(yiginlar.first, beklenen, sayac) ??
      const MBlockFark(MBlockFarkTuru.cokYigin);
}

MBlockFark? _diziFark(
    List<MBlockBlok> k, List<MBlockBeklenen> b, List<int> sayac) {
  final n = k.length > b.length ? k.length : b.length;
  for (var i = 0; i < n; i++) {
    if (i >= k.length) {
      return MBlockFark(MBlockFarkTuru.eksikBlok,
          sira: sayac[0] + 1, beklenenTip: b[i].tip);
    }
    sayac[0]++;
    if (i >= b.length) {
      return MBlockFark(MBlockFarkTuru.fazlaBlok,
          sira: sayac[0], kurulanTip: k[i].tip);
    }
    final f = _blokFark(k[i], b[i], sayac[0], sayac);
    if (f != null) return f;
  }
  return null;
}

int _blokSay(List<MBlockBlok> l) =>
    l.fold(0, (t, b) => t + 1 + _blokSay(b.icerik));

MBlockFark? _blokFark(
    MBlockBlok k, MBlockBeklenen b, int sira, List<int> sayac) {
  if (k.tip != b.tip) {
    return MBlockFark(MBlockFarkTuru.farkliBlok,
        sira: sira, beklenenTip: b.tip, kurulanTip: k.tip);
  }
  for (final e in b.alanlar.entries) {
    final d = k.alanlar[e.key];
    if (d == null || !_degerEsit(d, e.value)) {
      return MBlockFark(MBlockFarkTuru.deger,
          sira: sira, beklenenTip: b.tip, yuva: e.key);
    }
  }
  for (final e in b.girdiler.entries) {
    final t = k.girdiler[e.key];
    if (t == null || !_blokUyuyor(t, e.value)) {
      return MBlockFark(MBlockFarkTuru.girdi,
          sira: sira, beklenenTip: e.value.tip, kurulanTip: t?.tip, yuva: e.key);
    }
  }
  if (b.kardesKosullarSerbest &&
      _diziUyuyorKosullarSerbest(k.icerik, b.icerik)) {
    sayac[0] += _blokSay(k.icerik);
    return null;
  }
  return _diziFark(k.icerik, b.icerik, sayac);
}

// ---------------------------------------------------------------------
// Cozumden calistirilabilir program
// ---------------------------------------------------------------------

/// Bloklarin varsayilan degerleri (JS katalogundaki `varsayilan`lar).
/// Cozum yalnizca denetledigi alanlari yaziyor; cozumu CALISTIRMAK icin
/// gerisi buradan.
const Map<String, Map<String, String>> mblockVarsayilanAlanlar = {
  'dev_tekrarla': {'KERE': '10'},
  'dev_bekle': {'SANIYE': '1'},
  'dev_dijital_yaz': {'PIN': '9', 'SEVIYE': 'HIGH'},
  'dev_pwm_yaz': {'PIN': '5', 'GUC': '128'},
  'dev_dijital_oku': {'PIN': '2'},
  'dev_analog_oku': {'PIN': '0'},
  'dev_servo': {'PIN': '9', 'ACI': '90'},
  'dev_seri_yaz': {'METIN': 'merhaba'},
  'dev_mesafe': {'TRIG': '13', 'ECHO': '12'},
  'dev_harita': {'DEGER': '0', 'A': '0', 'B': '1023', 'C': '0', 'D': '255'},
  'dev_degisken_yap': {'AD': 'parlaklik', 'DEGER': '0'},
  'dev_git': {'ADIM': '10'},
  'dev_don': {'ACI': '15'},
  'dev_boyut': {'MIKTAR': '10'},
  'dev_yonune_don': {'YON': '90'},
  'dev_ses_bitene': {'SES': 'Bubbles'},
  'dev_x_yap': {'X': '0'},
  'dev_y_yap': {'Y': '0'},
  'dev_y_degistir': {'DY': '10'},
  'dev_dokunuyor': {'NESNE': 'Kase'},
  'dev_renge_dokunuyor': {'RENK': '#663b00'},
  'dev_degisken_degistir': {'AD': 'toplananelma', 'DEGER': '1'},
};

/// Cozumun kendisi, calistirilabilir bir program olarak (cozumu goster,
/// tezgah acilmadiginda sahne). Cozumun yazmadigi alanlar varsayilan;
/// "de" blogunun sozu cocugun dilinde.
List<MBlockBlok> mblockCozumProgrami(
    List<MBlockBeklenen> cozum, String lang) {
  MBlockBlok cevir(MBlockBeklenen b) => MBlockBlok(
        tip: b.tip,
        alanlar: {
          ...?mblockVarsayilanAlanlar[b.tip],
          if (b.tip == 'dev_de')
            'METIN': switch (lang) {
              'en' => 'Hello!',
              'de' => 'Hallo!',
              'es' => '¡Hola!',
              _ => 'Merhaba!',
            },
          ...b.alanlar,
        },
        icerik: [for (final i in b.icerik) cevir(i)],
        girdiler: {for (final e in b.girdiler.entries) e.key: cevir(e.value)},
      );
  return [for (final b in cozum) cevir(b)];
}

/// Cozum bir KART programi mi (Arduino Uno), yoksa kukla programi mi?
bool mblockKartProgramiMi(List<MBlockBeklenen> cozum) =>
    cozum.isNotEmpty && cozum.first.tip == 'dev_kart_acilis';
