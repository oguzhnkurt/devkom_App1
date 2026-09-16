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
  static const List<String> supported = [tr, en, de, es];

  /// Dilin kendi adiyla gorunen etiketi.
  ///
  /// Bir dili SECERKEN kullanicinin o dili zaten okuyor olmasini
  /// bekleyemeyiz; bu yuzden "Almanca" degil "Deutsch" yaziyoruz.
  static const Map<String, String> nativeName = {
    tr: 'Türkçe',
    en: 'English',
    de: 'Deutsch',
    es: 'Español',
  };

  static const Map<String, String> flag = {
    tr: '🇹🇷',
    en: '🇬🇧',
    de: '🇩🇪',
    es: '🇪🇸',
  };

  static bool isSupported(String? code) =>
      code != null && supported.contains(code);

  /// Cihaz dili desteklenmiyorsa Ingilizce'ye dusuyoruz.
  ///
  /// Turkce'ye degil: Fransizca bir cihazda uygulamanin Turkce acilmasi,
  /// kullaniciya "bu uygulama sana gore degil" demek olur.
  static String resolve(String? deviceCode) =>
      isSupported(deviceCode) ? deviceCode! : en;

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
      default:
        return en;
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
