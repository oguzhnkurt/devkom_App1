import 'ceviri.dart';

/// Uygulamanin destekledigi diller.
///
/// Dort dil var ve hepsi ESIT degil: Turkce ana dil (icerik once Turkce
/// yaziliyor), Ingilizce ise yedek dil. Almanca ya da Ispanyolca bir
/// metin henuz yazilmadiysa Ingilizcesi gosteriliyor — bos bir ekran ya
/// da Turkce bir cumle degil.
///
/// Bu zincir bilerek boyle: Almanya'da yasayan bir kullanici icin
/// Ingilizce anlasilabilir bir yedek, Turkce degil.
class AppLang {
  AppLang._();

  static const String tr = 'tr';
  static const String en = 'en';
  static const String de = 'de';
  static const String es = 'es';

  /// Ayarlar ekraninda ve dil seciminde kullanilan sira.
  ///
  /// 51 DIL (2 Kasim 2026). Ilk dordu elle yazilmis tam diller; digerleri
  /// arayuz cevirisiyle geliyor (bkz. `ceviri.dart`), ders icerigi o
  /// dillerde Ingilizce.
  static const List<String> elleYazilan = [tr, en, de, es];

  static const List<String> supported = [
    tr, en, de, es,
    'fr', 'it', 'pt', 'nl', 'pl', 'ru', 'uk', 'cs', 'sk', 'sl', 'hr', 'sr',
    'bg', 'ro', 'hu', 'el', 'sv', 'da', 'nb', 'fi', 'et', 'lv', 'lt', 'ca',
    'ar', 'he', 'fa', 'ur', 'hi', 'bn', 'ta', 'id', 'ms', 'vi', 'th', 'fil',
    'ja', 'ko', 'zh', 'sw', 'az', 'kk', 'uz', 'ka', 'mk', 'af', 'is',
  ];

  /// Dilin kendi adiyla gorunen etiketi.
  ///
  /// Bir dili SECERKEN kullanicinin o dili zaten okuyor olmasini
  /// bekleyemeyiz; bu yuzden "Almanca" degil "Deutsch" yaziyoruz.
  static const Map<String, String> nativeName = {
    tr: 'Türkçe',
    en: 'English',
    de: 'Deutsch',
    es: 'Español',
    'fr': 'Français',
    'it': 'Italiano',
    'pt': 'Português',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'ru': 'Русский',
    'uk': 'Українська',
    'cs': 'Čeština',
    'sk': 'Slovenčina',
    'sl': 'Slovenščina',
    'hr': 'Hrvatski',
    'sr': 'Српски',
    'bg': 'Български',
    'ro': 'Română',
    'hu': 'Magyar',
    'el': 'Ελληνικά',
    'sv': 'Svenska',
    'da': 'Dansk',
    'nb': 'Norsk',
    'fi': 'Suomi',
    'et': 'Eesti',
    'lv': 'Latviešu',
    'lt': 'Lietuvių',
    'ca': 'Català',
    'ar': 'العربية',
    'he': 'עברית',
    'fa': 'فارسی',
    'ur': 'اردو',
    'hi': 'हिन्दी',
    'bn': 'বাংলা',
    'ta': 'தமிழ்',
    'id': 'Bahasa Indonesia',
    'ms': 'Bahasa Melayu',
    'vi': 'Tiếng Việt',
    'th': 'ไทย',
    'fil': 'Filipino',
    'ja': '日本語',
    'ko': '한국어',
    'zh': '中文',
    'sw': 'Kiswahili',
    'az': 'Azərbaycanca',
    'kk': 'Қазақ тілі',
    'uz': 'Oʻzbekcha',
    'ka': 'ქართული',
    'mk': 'Македонски',
    'af': 'Afrikaans',
    'is': 'Íslenska',
  };

  /// Bayrak yalnizca elle yazilan dort dilde; diger dillerin bir ulkeyle
  /// eslestirilmesi (Ispanyolca/Ingilizce gibi) tartismali, bos birakildi.
  static const Map<String, String> flag = {
    tr: '🇹🇷',
    en: '🇬🇧',
    de: '🇩🇪',
    es: '🇪🇸',
  };

  /// Cihazlarin eski / farkli kodlari.
  static const Map<String, String> _esAnlamli = {
    'no': 'nb',
    'nn': 'nb',
    'iw': 'he',
    'in': 'id',
    'tl': 'fil',
  };

  static String _normal(String code) => _esAnlamli[code] ?? code;

  static bool isSupported(String? code) =>
      code != null && supported.contains(_normal(code));

  /// Cihaz dili desteklenmiyorsa Ingilizce'ye dusuyoruz.
  ///
  /// Turkce'ye degil: Fransizca bir cihazda uygulamanin Turkce acilmasi,
  /// kullaniciya "bu uygulama sana gore degil" demek olur.
  static String resolve(String? deviceCode) =>
      isSupported(deviceCode) ? _normal(deviceCode!) : en;

  /// Sagdan sola yazilan diller.
  static const Set<String> sagdanSola = {'ar', 'he', 'fa', 'ur'};

  /// Dile gore metin secer.
  ///
  /// [de] ve [es] verilmemisse [en] kullanilir. Boylece bir metnin
  /// Almancasi henuz yazilmamis olsa bile ekran dogru calisiyor ve
  /// ceviri sonradan tek satir eklenerek tamamlanabiliyor.
  static String pick(
    String lang, {
    required String tr,
    required String en,
    String? de,
    String? es,
  }) {
    switch (lang) {
      case AppLang.tr:
        return tr;
      case AppLang.de:
        return de ?? en;
      case AppLang.es:
        return es ?? en;
      case AppLang.en:
        return en;
      default:
        // Diger 47 dil: Ingilizce metin anahtar, yoksa Ingilizce.
        return Ceviri.bul(lang, en) ?? en;
    }
  }

  /// Metin disindaki degerler (liste, sayi, widget) icin [pick] esdegeri.
  ///
  /// Ornegin oyunlardaki sekil/renk adi listeleri: dile gore bir LISTE
  /// seciliyor, tek bir metin degil. [pick] String'e sabitli oldugu icin
  /// oralarda `lang == 'tr' ? trListesi : enListesi` yazilmisti ve bu
  /// Almanca/Ispanyolca oynayan cocuga Ingilizce gosteriyordu.
  static T pickOf<T>(
    String lang, {
    required T tr,
    required T en,
    T? de,
    T? es,
  }) {
    switch (lang) {
      case AppLang.tr:
        return tr;
      case AppLang.de:
        return de ?? en;
      case AppLang.es:
        return es ?? en;
      default:
        return en;
    }
  }
}
