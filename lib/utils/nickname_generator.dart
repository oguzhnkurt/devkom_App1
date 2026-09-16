import 'dart:math';

import 'lang.dart';

/// Takma ad ureticisi.
///
/// Kullanicidan isim istemiyoruz: hesap acildiginda otomatik olarak
/// "CesurKaplan42" gibi bir ad ataniyor, kullanici isterse
/// degistirebiliyor. Kelimeler cocuklar icin guvenli ve pozitif secildi.
///
/// DILE GORE URETIYOR. Onceden kelime listeleri yalnizca Turkce idi ve
/// Almanca secen bir cocuga "MeraklıPiksel317" oneriliyordu — okuyamadigi
/// bir ad, kendi adi olarak. Simdi her dilin kendi kelimeleri var.
class NicknameGenerator {
  NicknameGenerator._();

  static const Map<String, List<String>> _adjectives = {
    AppLang.tr: [
      'Cesur', 'Hızlı', 'Akıllı', 'Neşeli', 'Meraklı', 'Şen', 'Zeki', 'Atak',
      'Sevimli', 'Güçlü', 'Uçan', 'Parlak', 'Yaman', 'Çevik', 'Gizemli',
      'Becerikli', 'Kahraman', 'Usta', 'Bilge', 'Kaşif', 'Yaratıcı', 'Azimli',
    ],
    AppLang.en: [
      'Brave', 'Swift', 'Clever', 'Happy', 'Curious', 'Bright', 'Sharp',
      'Bold', 'Mighty', 'Flying', 'Shiny', 'Nimble', 'Mystic', 'Handy',
      'Hero', 'Master', 'Wise', 'Explorer', 'Creative', 'Eager', 'Lucky',
      'Cosmic',
    ],
    AppLang.de: [
      'Mutig', 'Flink', 'Schlau', 'Froh', 'Neugierig', 'Hell', 'Scharf',
      'Kühn', 'Stark', 'Fliegend', 'Glänzend', 'Wendig', 'Geheim', 'Geschickt',
      'Held', 'Meister', 'Weise', 'Forscher', 'Kreativ', 'Eifrig', 'Glücklich',
      'Kosmisch',
    ],
    AppLang.es: [
      'Valiente', 'Rápido', 'Listo', 'Alegre', 'Curioso', 'Brillante', 'Agudo',
      'Audaz', 'Fuerte', 'Volador', 'Reluciente', 'Ágil', 'Misterioso',
      'Hábil', 'Héroe', 'Maestro', 'Sabio', 'Explorador', 'Creativo',
      'Ansioso', 'Afortunado', 'Cósmico',
    ],
  };

  /// Isimler bilerek buyuk olcude ORTAK: "Robot", "Pixel", "Laser" dort
  /// dilde de ayni okunuyor ve kodlama temasini tasiyor. Yalnizca
  /// hayvanlar ve birkac kelime dile gore degisiyor.
  static const Map<String, List<String>> _nouns = {
    AppLang.tr: [
      'Kaplan', 'Kartal', 'Panda', 'Tilki', 'Baykuş', 'Yunus', 'Şahin',
      'Kirpi', 'Ejderha', 'Kaptan', 'Robot', 'Piksel', 'Bayt', 'Devre',
      'Kod', 'Sensör', 'Motor', 'Işın', 'Gezgin', 'Mucit', 'Mühendis', 'Kâşif',
    ],
    AppLang.en: [
      'Tiger', 'Eagle', 'Panda', 'Fox', 'Owl', 'Dolphin', 'Falcon',
      'Hedgehog', 'Dragon', 'Captain', 'Robot', 'Pixel', 'Byte', 'Circuit',
      'Code', 'Sensor', 'Motor', 'Laser', 'Rover', 'Maker', 'Engineer',
      'Explorer',
    ],
    AppLang.de: [
      'Tiger', 'Adler', 'Panda', 'Fuchs', 'Eule', 'Delfin', 'Falke',
      'Igel', 'Drache', 'Kapitän', 'Roboter', 'Pixel', 'Byte', 'Schaltung',
      'Code', 'Sensor', 'Motor', 'Laser', 'Rover', 'Macher', 'Ingenieur',
      'Forscher',
    ],
    AppLang.es: [
      'Tigre', 'Águila', 'Panda', 'Zorro', 'Búho', 'Delfín', 'Halcón',
      'Erizo', 'Dragón', 'Capitán', 'Robot', 'Píxel', 'Byte', 'Circuito',
      'Código', 'Sensor', 'Motor', 'Láser', 'Rover', 'Creador', 'Ingeniero',
      'Explorador',
    ],
  };

  static final Random _random = Random();

  /// Rastgele bir takma ad uretir: "MeraklıPiksel317" / "CuriousPixel317".
  static String generate([String lang = AppLang.tr]) {
    final adjectives = _adjectives[lang] ?? _adjectives[AppLang.en]!;
    final nouns = _nouns[lang] ?? _nouns[AppLang.en]!;
    final adjective = adjectives[_random.nextInt(adjectives.length)];
    final noun = nouns[_random.nextInt(nouns.length)];
    final number = 10 + _random.nextInt(990);
    return '$adjective$noun$number';
  }

  /// Kullanicinin girdigi adi dogrular. Sorun yoksa null doner, varsa
  /// gosterilecek hata mesajini doner.
  static String? validate(String value, [String lang = AppLang.tr]) {
    String t(String tr, String en, String de, String es) =>
        AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return t('En az 3 karakter olmalı.', 'At least 3 characters.',
          'Mindestens 3 Zeichen.', 'Al menos 3 caracteres.');
    }
    if (trimmed.length > 20) {
      return t('En fazla 20 karakter olabilir.', 'At most 20 characters.',
          'Höchstens 20 Zeichen.', 'Como máximo 20 caracteres.');
    }
    if (trimmed.contains('@')) {
      return t(
        'E-posta adresi kullanma, bir takma ad seç.',
        'Do not use an email address — pick a nickname.',
        'Nutze keine E-Mail-Adresse, wähle einen Spitznamen.',
        'No uses un correo electrónico, elige un apodo.',
      );
    }
    if (RegExp(r'\d{7,}').hasMatch(trimmed)) {
      return t(
        'Telefon numarası gibi uzun sayılar kullanma.',
        'Do not use long numbers like a phone number.',
        'Nutze keine langen Zahlen wie eine Telefonnummer.',
        'No uses números largos como un teléfono.',
      );
    }
    // Almanca ve Ispanyolca harfler de kabul ediliyor; onceden yalnizca
    // Turkce harfler gecerliydi ve "Glücklich" ya da "Águila" gibi bir ad
    // REDDEDILIYORDU.
    if (!RegExp(r'^[a-zA-ZçÇğĞıİöÖşŞüÜäÄëËïÏàÀâÂéÉèÈêÊíÍìÌîÎóÓòÒôÔúÚùÙûÛñÑßáÁ0-9 _-]+$')
        .hasMatch(trimmed)) {
      return t(
        'Sadece harf, rakam, boşluk, - ve _ kullanabilirsin.',
        'Only letters, numbers, spaces, - and _ are allowed.',
        'Nur Buchstaben, Zahlen, Leerzeichen, - und _ sind erlaubt.',
        'Solo se permiten letras, números, espacios, - y _.',
      );
    }
    return null;
  }
}
