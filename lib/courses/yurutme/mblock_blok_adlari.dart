import 'dart:ui' show Color;

import 'mblock_cozum.dart';

/// mBlock bloklarinin Dart tarafindaki tarifi: kategori, sekil, yuva
/// sirasi ve dort dildeki etiket sablonu.
///
/// NEDEN IKINCI BIR KOPYA
/// ----------------------
/// Bloklarin asil tanimi `assets/mblock/mblock_bloklari.js` icinde ve
/// WebView tezgahi onu kullaniyor. Dart tarafi ise WebView'siz is
/// yapiyor: ipucunda blogun ADINI soylemek ("3. bloga bak: orada
/// "dijital ayarla pin … cikis …" olmali"), sahnede calisan blogu
/// gostermek, tezgah acilmazsa cozumu yazmak. Bu tablo JS'ten uretildi
/// ve `test/mblock_uno_test.dart` iki kopyanin ayrismadigini denetliyor.
class MBlockBlokTanimi {
  const MBlockBlokTanimi({
    required this.kategori,
    required this.sekil,
    required this.yuvalar,
    required this.etiket,
  });

  /// JS'teki kategori adi (`pin`, `kontrol`, `hareket`...).
  final String kategori;

  /// `sapka`, `duz`, `c`, `cson`, `son`, `oval`, `altigen`.
  final String sekil;

  /// Yuvalarin adlari, `%1`, `%2` sirasiyla.
  final List<String> yuvalar;

  /// Dil -> sablon (`%1` yuvanin yeri).
  final Map<String, String> etiket;

  bool get cMi => sekil == 'c' || sekil == 'cson';
  bool get sapkaMi => sekil == 'sapka';

  Color get renk => mblockKategoriRengi[kategori] ?? const Color(0xFF888888);
}

/// JS'teki `RENKLER` tablosunun ana tonlari.
const Map<String, Color> mblockKategoriRengi = {
  'pin': Color(0xFF4A90E2),
  'seriPort': Color(0xFF7ED321),
  'veri': Color(0xFFBD10E0),
  'sensor': Color(0xFF4CBFE6),
  'olaylar': Color(0xFFFFBF00),
  'kontrol': Color(0xFFFFAB19),
  'islemler': Color(0xFF59C059),
  'degisken': Color(0xFFFF8C1A),
  'hareket': Color(0xFF4C97FF),
  'gorunum': Color(0xFF9966FF),
  'ses': Color(0xFFCF63CF),
  'algilama': Color(0xFF5CB1D6),
};

/// Katalog kimligi -> tarif.
const Map<String, MBlockBlokTanimi> mblockBlokTanimlari = {
  'dev_bayrak': MBlockBlokTanimi(
    kategori: 'olaylar',
    sekil: 'sapka',
    yuvalar: [],
    etiket: {
      'tr': '%1 tıklandığında',
      'en': 'when %1 clicked',
      'de': 'wenn %1 angeklickt',
      'es': 'al hacer clic en %1',
    },
  ),
  'dev_kart_acilis': MBlockBlokTanimi(
    kategori: 'olaylar',
    sekil: 'sapka',
    yuvalar: [],
    etiket: {
      'tr': 'when Arduino Uno starts up',
      'en': 'when Arduino Uno starts up',
      'de': 'wenn Arduino Uno startet',
      'es': 'cuando Arduino Uno se inicia',
    },
  ),
  'dev_surekli': MBlockBlokTanimi(
    kategori: 'kontrol',
    sekil: 'cson',
    yuvalar: [],
    etiket: {
      'tr': 'sürekli tekrarla',
      'en': 'forever',
      'de': 'wiederhole fortlaufend',
      'es': 'por siempre',
    },
  ),
  'dev_tekrarla': MBlockBlokTanimi(
    kategori: 'kontrol',
    sekil: 'c',
    yuvalar: ['KERE'],
    etiket: {
      'tr': '%1 defa tekrarla',
      'en': 'repeat %1',
      'de': 'wiederhole %1 mal',
      'es': 'repetir %1',
    },
  ),
  'dev_bekle': MBlockBlokTanimi(
    kategori: 'kontrol',
    sekil: 'duz',
    yuvalar: ['SANIYE'],
    etiket: {
      'tr': '%1 saniye bekle',
      'en': 'wait %1 seconds',
      'de': 'warte %1 Sekunden',
      'es': 'esperar %1 segundos',
    },
  ),
  'dev_eger': MBlockBlokTanimi(
    kategori: 'kontrol',
    sekil: 'c',
    yuvalar: ['KOSUL'],
    etiket: {
      'tr': 'eğer %1 ise',
      'en': 'if %1 then',
      'de': 'falls %1, dann',
      'es': 'si %1 entonces',
    },
  ),
  'dev_dijital_yaz': MBlockBlokTanimi(
    kategori: 'pin',
    sekil: 'duz',
    yuvalar: ['PIN', 'SEVIYE'],
    etiket: {
      'tr': 'dijital ayarla pin %1 çıkış %2',
      'en': 'set digital pin %1 output as %2',
      'de': 'digitalen Pin von Ausgang %1 als %2 setzen',
      'es': 'pon el pin digital %1 a %2',
    },
  ),
  'dev_pwm_yaz': MBlockBlokTanimi(
    kategori: 'pin',
    sekil: 'duz',
    yuvalar: ['PIN', 'GUC'],
    etiket: {
      'tr': 'PWM ayarla pin%1 çıkış %2',
      'en': 'set PWM %1 output as %2',
      'de': 'PWM-Ausgang %1 als %2 festlegen',
      'es': 'pon la salida PWM %1 a %2',
    },
  ),
  'dev_dijital_oku': MBlockBlokTanimi(
    kategori: 'pin',
    sekil: 'altigen',
    yuvalar: ['PIN'],
    etiket: {
      'tr': 'dijital oku pin %1',
      'en': 'read digital pin %1',
      'de': 'Digitalpin lesen %1',
      'es': 'lee pin digital %1',
    },
  ),
  'dev_analog_oku': MBlockBlokTanimi(
    kategori: 'pin',
    sekil: 'oval',
    yuvalar: ['PIN'],
    etiket: {
      'tr': 'analog oku pin (A) %1',
      'en': 'read analog pin (A) %1',
      'de': 'analogen Pin（A）%1 lesen',
      'es': 'lee pin analógico %1',
    },
  ),
  'dev_servo': MBlockBlokTanimi(
    kategori: 'pin',
    sekil: 'duz',
    yuvalar: ['PIN', 'ACI'],
    etiket: {
      'tr': 'servo pin %1 açı %2',
      'en': 'set servo pin %1 angle as %2',
      'de': 'setze Servo an Anschluss %1 auf Winkel %2',
      'es': 'mueve el servo en pin %1 al ángulo %2',
    },
  ),
  'dev_seri_yaz': MBlockBlokTanimi(
    kategori: 'seriPort',
    sekil: 'duz',
    yuvalar: ['METIN'],
    etiket: {
      'tr': 'seri port %1 yaz',
      'en': 'serial write %1',
      'de': 'serieller Port schreibt %1',
      'es': 'puerto serie escribe %1',
    },
  ),
  'dev_mesafe': MBlockBlokTanimi(
    kategori: 'sensor',
    sekil: 'oval',
    yuvalar: ['TRIG', 'ECHO'],
    etiket: {
      'tr': 'mesafe algılayıcı %1 trig pin %2 echo pin',
      'en': 'read ultrasonic sensor trig pin %1 echo pin %2',
      'de': 'Ultraschallsensor Trig-Pin %1 Echo-Pin %2 lesen',
      'es': 'lee el sensor de distancia pin trig %1 pin echo %2',
    },
  ),
  'dev_harita': MBlockBlokTanimi(
    kategori: 'veri',
    sekil: 'oval',
    yuvalar: ['DEGER', 'A', 'B', 'C', 'D'],
    etiket: {
      'tr': 'harita %1 den [%2 , %3] e [%4 , %5]',
      'en': 'map %1 from [%2 , %3] to [%4 , %5]',
      'de': 'ordne %1 von [%2 , %3] zu [%4 , %5]',
      'es': 'mapea %1 de [%2 , %3] a [%4 , %5]',
    },
  ),
  'dev_degil': MBlockBlokTanimi(
    kategori: 'islemler',
    sekil: 'altigen',
    yuvalar: ['KOSUL'],
    etiket: {
      'tr': '%1 değil',
      'en': 'not %1',
      'de': 'nicht %1',
      'es': 'no %1',
    },
  ),
  'dev_kucuktur': MBlockBlokTanimi(
    kategori: 'islemler',
    sekil: 'altigen',
    yuvalar: ['A', 'B'],
    etiket: {
      'tr': '%1 < %2',
      'en': '%1 < %2',
      'de': '%1 < %2',
      'es': '%1 < %2',
    },
  ),
  'dev_ton': MBlockBlokTanimi(
    kategori: 'pin',
    sekil: 'duz',
    yuvalar: ['PIN', 'FREKANS', 'SANIYE'],
    etiket: {
      'tr': 'pin %1 ton çal frekans %2 süre %3 saniye',
      'en': 'play tone on pin %1 frequency %2 for %3 secs',
      'de': 'spiele Ton an Pin %1 Frequenz %2 für %3 Sek.',
      'es': 'tocar tono en pin %1 frecuencia %2 durante %3 s',
    },
  ),
  'dev_sicaklik': MBlockBlokTanimi(
    kategori: 'sensor',
    sekil: 'oval',
    yuvalar: ['PIN'],
    etiket: {
      'tr': 'sıcaklık sensörü pin (A) %1 °C',
      'en': 'temperature sensor pin (A) %1 °C',
      'de': 'Temperatursensor Pin (A) %1 °C',
      'es': 'sensor de temperatura pin (A) %1 °C',
    },
  ),
  'dev_buyuktur': MBlockBlokTanimi(
    kategori: 'islemler',
    sekil: 'altigen',
    yuvalar: ['A', 'B'],
    etiket: {
      'tr': '%1 > %2',
      'en': '%1 > %2',
      'de': '%1 > %2',
      'es': '%1 > %2',
    },
  ),
  'dev_bekle_kadar': MBlockBlokTanimi(
    kategori: 'kontrol',
    sekil: 'duz',
    yuvalar: ['KOSUL'],
    etiket: {
      'tr': '%1 olana kadar bekle',
      'en': 'wait until %1',
      'de': 'warte bis %1',
      'es': 'esperar hasta que %1',
    },
  ),
  'dev_sayac_oku': MBlockBlokTanimi(
    kategori: 'degisken',
    sekil: 'oval',
    yuvalar: [],
    etiket: {
      'tr': 'sayaç',
      'en': 'counter',
      'de': 'zähler',
      'es': 'contador',
    },
  ),
  'dev_aci_oku': MBlockBlokTanimi(
    kategori: 'degisken',
    sekil: 'oval',
    yuvalar: [],
    etiket: {
      'tr': 'açı',
      'en': 'angle',
      'de': 'winkel',
      'es': 'ángulo',
    },
  ),
  'dev_degisken_yap': MBlockBlokTanimi(
    kategori: 'degisken',
    sekil: 'duz',
    yuvalar: ['AD', 'DEGER'],
    etiket: {
      'tr': '%1 değişkenini %2 yap',
      'en': 'set %1 to %2',
      'de': 'setze %1 auf %2',
      'es': 'dar a %1 el valor %2',
    },
  ),
  'dev_degisken_oku': MBlockBlokTanimi(
    kategori: 'degisken',
    sekil: 'oval',
    yuvalar: [],
    etiket: {
      'tr': 'parlaklik',
      'en': 'brightness',
      'de': 'helligkeit',
      'es': 'brillo',
    },
  ),
  'dev_git': MBlockBlokTanimi(
    kategori: 'hareket',
    sekil: 'duz',
    yuvalar: ['ADIM'],
    etiket: {
      'tr': '%1 adım git',
      'en': 'move %1 steps',
      'de': 'gehe %1 er Schritt',
      'es': 'mover %1 pasos',
    },
  ),
  'dev_don': MBlockBlokTanimi(
    kategori: 'hareket',
    sekil: 'duz',
    yuvalar: ['ACI'],
    etiket: {
      'tr': '↻ %1 derece dön',
      'en': 'turn ↻ %1 degrees',
      'de': 'drehe dich ↻ um %1 Grad',
      'es': 'girar ↻ %1 grados',
    },
  ),
  'dev_de': MBlockBlokTanimi(
    kategori: 'gorunum',
    sekil: 'duz',
    yuvalar: ['METIN'],
    etiket: {
      'tr': '%1 de',
      'en': 'say %1',
      'de': 'sage %1',
      'es': 'decir %1',
    },
  ),
  'dev_boyut': MBlockBlokTanimi(
    kategori: 'gorunum',
    sekil: 'duz',
    yuvalar: ['MIKTAR'],
    etiket: {
      'tr': 'boyutu %1 değiştir',
      'en': 'change size by %1',
      'de': 'ändere Größe um %1',
      'es': 'cambiar tamaño por %1',
    },
  ),
  'dev_yonune_don': MBlockBlokTanimi(
    kategori: 'hareket',
    sekil: 'duz',
    yuvalar: ['YON'],
    etiket: {
      'tr': '%1 yönüne dön',
      'en': 'point in direction %1',
      'de': 'setze Richtung auf %1 Grad',
      'es': 'apuntar en dirección %1',
    },
  ),
  'dev_sek': MBlockBlokTanimi(
    kategori: 'hareket',
    sekil: 'duz',
    yuvalar: [],
    etiket: {
      'tr': 'kenara geldiyse sek',
      'en': 'if on edge, bounce',
      'de': 'pralle vom Rand ab',
      'es': 'si toca un borde, rebotar',
    },
  ),
  'dev_kostum': MBlockBlokTanimi(
    kategori: 'gorunum',
    sekil: 'duz',
    yuvalar: [],
    etiket: {
      'tr': 'sonraki kostüm',
      'en': 'next costume',
      'de': 'wechsle zum nächsten Kostüm',
      'es': 'siguiente disfraz',
    },
  ),
  'dev_ses_bitene': MBlockBlokTanimi(
    kategori: 'ses',
    sekil: 'duz',
    yuvalar: ['SES'],
    etiket: {
      'tr': '%1 sesini bitene kadar çal',
      'en': 'play sound %1 until done',
      'de': 'spiele Klang %1 ganz',
      'es': 'tocar sonido %1 hasta que termine',
    },
  ),
  'dev_x_yap': MBlockBlokTanimi(
    kategori: 'hareket',
    sekil: 'duz',
    yuvalar: ['X'],
    etiket: {
      'tr': 'x konumunu %1 yap',
      'en': 'set x to %1',
      'de': 'setze x auf %1',
      'es': 'dar a x el valor %1',
    },
  ),
  'dev_y_yap': MBlockBlokTanimi(
    kategori: 'hareket',
    sekil: 'duz',
    yuvalar: ['Y'],
    etiket: {
      'tr': 'y konumunu %1 yap',
      'en': 'set y to %1',
      'de': 'setze y auf %1',
      'es': 'dar a y el valor %1',
    },
  ),
  'dev_y_degistir': MBlockBlokTanimi(
    kategori: 'hareket',
    sekil: 'duz',
    yuvalar: ['DY'],
    etiket: {
      'tr': 'y konumunu %1 değiştir',
      'en': 'change y by %1',
      'de': 'ändere y um %1',
      'es': 'sumar a y %1',
    },
  ),
  'dev_fare_x': MBlockBlokTanimi(
    kategori: 'algilama',
    sekil: 'oval',
    yuvalar: [],
    etiket: {
      'tr': 'farenin x i',
      'en': 'mouse x',
      'de': 'Maus x-Position',
      'es': 'posición x del ratón',
    },
  ),
  'dev_dokunuyor': MBlockBlokTanimi(
    kategori: 'algilama',
    sekil: 'altigen',
    yuvalar: ['NESNE'],
    etiket: {
      'tr': '%1 e değiyor mu?',
      'en': 'touching %1?',
      'de': 'wird %1 berührt?',
      'es': '¿tocando %1?',
    },
  ),
  'dev_renge_dokunuyor': MBlockBlokTanimi(
    kategori: 'algilama',
    sekil: 'altigen',
    yuvalar: ['RENK'],
    etiket: {
      'tr': '%1 rengine değiyor mu?',
      'en': 'touching color %1?',
      'de': 'wird Farbe %1 berührt?',
      'es': '¿tocando el color %1?',
    },
  ),
  'dev_ikiz_basla': MBlockBlokTanimi(
    kategori: 'kontrol',
    sekil: 'sapka',
    yuvalar: [],
    etiket: {
      'tr': 'ikiz olarak başladığımda',
      'en': 'when I start as a clone',
      'de': 'Wenn ich als Klon entstehe',
      'es': 'al comenzar como clon',
    },
  ),
  'dev_ikizi_sil': MBlockBlokTanimi(
    kategori: 'kontrol',
    sekil: 'son',
    yuvalar: [],
    etiket: {
      'tr': 'bu ikizi sil',
      'en': 'delete this clone',
      'de': 'lösche diesen Klon',
      'es': 'eliminar este clon',
    },
  ),
  'dev_goster': MBlockBlokTanimi(
    kategori: 'gorunum',
    sekil: 'duz',
    yuvalar: [],
    etiket: {
      'tr': 'göster',
      'en': 'show',
      'de': 'zeige dich',
      'es': 'mostrar',
    },
  ),
  'dev_gizle': MBlockBlokTanimi(
    kategori: 'gorunum',
    sekil: 'duz',
    yuvalar: [],
    etiket: {
      'tr': 'gizle',
      'en': 'hide',
      'de': 'verstecke dich',
      'es': 'esconder',
    },
  ),
  'dev_degisken_degistir': MBlockBlokTanimi(
    kategori: 'degisken',
    sekil: 'duz',
    yuvalar: ['AD', 'DEGER'],
    etiket: {
      'tr': '%1 i %2 kadar değiştir',
      'en': 'change %1 by %2',
      'de': 'ändere %1 um %2',
      'es': 'sumar a %1 %2',
    },
  ),
};

/// Acilir listelerin DEGERI dilden bagimsiz ('HIGH', 'Kase'); ekranda
/// cocugun dilindeki adiyla gorunuyor.
const Map<String, Map<String, String>> _degerAdlari = {
  'HIGH': {'tr': 'yüksek', 'en': 'high', 'de': 'hoch', 'es': 'alto'},
  'LOW': {'tr': 'düşük', 'en': 'low', 'de': 'niedrig', 'es': 'bajo'},
  'Kase': {'tr': 'Kase', 'en': 'Bowl', 'de': 'Schüssel', 'es': 'Cuenco'},
  'parlaklik': {
    'tr': 'parlaklik',
    'en': 'brightness',
    'de': 'helligkeit',
    'es': 'brillo'
  },
  'sayac': {'tr': 'sayaç', 'en': 'counter', 'de': 'zähler', 'es': 'contador'},
  'aci': {'tr': 'açı', 'en': 'angle', 'de': 'winkel', 'es': 'ángulo'},
  'toplananelma': {
    'tr': 'toplananelma',
    'en': 'score',
    'de': 'punkte',
    'es': 'puntos'
  },
};

String _dil(String lang) =>
    const {'tr', 'en', 'de', 'es'}.contains(lang) ? lang : 'en';

/// Bir degerin ekrandaki adi.
String mblockDegerAdi(String deger, String lang) =>
    _degerAdlari[deger]?[_dil(lang)] ?? deger;

/// Blogun adi, yuvalari "…" ile: "dijital ayarla pin … çıkış …".
/// Katalogda yoksa kimligin kendisi.
String mblockBlokAdi(String tip, String lang) {
  final t = mblockBlokTanimlari[tip];
  if (t == null) return tip;
  return _doldur(t, lang, (_) => '…');
}

/// Blogun cocugun kurdugu degerlerle yazisi: "dijital ayarla pin 9
/// çıkış yüksek". Yuvaya takili blok parantez icinde yazilir.
String mblockBlokYazisi(MBlockBlok b, String lang) {
  final t = mblockBlokTanimlari[b.tip];
  if (t == null) return b.tip;
  return _doldur(t, lang, (yuva) {
    final ic = b.girdiler[yuva];
    if (ic != null) {
      final y = mblockBlokYazisi(ic, lang);
      final ict = mblockBlokTanimlari[ic.tip];
      return ict?.sekil == 'altigen' ? '<$y>' : '($y)';
    }
    final d = b.alanlar[yuva];
    return d == null ? '…' : mblockDegerAdi(d, lang);
  });
}

String _doldur(
    MBlockBlokTanimi t, String lang, String Function(String yuva) deger) {
  var s = t.etiket[_dil(lang)] ?? t.etiket['en']!;
  if (t.yuvalar.isEmpty) return s.replaceAll('%1', '⚑').trim();
  for (var i = t.yuvalar.length; i >= 1; i--) {
    s = s.replaceAll('%$i', deger(t.yuvalar[i - 1]));
  }
  return s.trim();
}
