/// Yorumlayicinin degisken, liste ve liste ogesi adlari ("Puan",
/// "alışveriş", "elma") Turkce tutuluyor; sahne ve iz bunlari cocugun
/// dilinde gostermeli. Bloklarin uzerindeki adlar da (bkz.
/// ScratchBlokKatalogu) bu cevirilerle ayni.
library;

const Map<String, Map<String, String>> _adlar = {
  'Puan': {'tr': 'Puan', 'en': 'Score', 'de': 'Punkte', 'es': 'Puntos'},
  'zar': {'tr': 'zar', 'en': 'dice', 'de': 'Würfel', 'es': 'dado'},
  'süre': {'tr': 'süre', 'en': 'time', 'de': 'Zeit', 'es': 'tiempo'},
  'alışveriş': {
    'tr': 'alışveriş',
    'en': 'shopping',
    'de': 'Einkauf',
    'es': 'compra'
  },
  'sorular': {
    'tr': 'sorular',
    'en': 'questions',
    'de': 'Fragen',
    'es': 'preguntas'
  },
  'elma': {'tr': 'elma', 'en': 'apple', 'de': 'Apfel', 'es': 'manzana'},
  'muz': {'tr': 'muz', 'en': 'banana', 'de': 'Banane', 'es': 'plátano'},
  'süt': {'tr': 'süt', 'en': 'milk', 'de': 'Milch', 'es': 'leche'},
};

/// [ad]in [lang] dilindeki hali; bilinmiyorsa kendisi.
String yorumlayiciAdi(String ad, String lang) =>
    _adlar[ad]?[lang] ?? _adlar[ad]?['en'] ?? ad;
