import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/lang.dart';
import '../../widgets/scratch_blok.dart';
import '../data/course_modules.dart';
import '../data/courses_data.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../yurutme/scratch_blok_katalogu.dart';

/// Bir kursun acilis sahnesi ve kapanis toreni icin ayar.
///
/// NEDEN AYAR, NEDEN TEK KURS
/// --------------------------
/// Acilis (Devi + tek blokluk mini etkinlik) ve kapanis (konfeti, ozet,
/// sertifika, siradaki kurs) kursa bagli degil: ekranlar yalnizca
/// buradaki ayari okuyor. Simdilik yalnizca Scratch'te acik, cunku
/// mini etkinlik gercek bir Scratch blogu kullaniyor ve o bloklarin
/// cizimi ([ScratchBlok]) yalnizca Scratch kursunda var. Baska bir kurs
/// eklemek = buraya bir satir + o kursun iki blogu.
class KursTanitimi {
  const KursTanitimi({
    required this.courseId,
    required this.sapkaBlokId,
    required this.yerlesecekBlokId,
    required this.adimSayisi,
  });

  final String courseId;

  /// Kod alaninda hazir duran baslatici (sapka) blok.
  final String sapkaBlokId;

  /// Cocugun yerine koyacagi TEK blok.
  final String yerlesecekBlokId;

  /// Bu blok calisinca kuklanin attigi adim (sahnedeki noktalar).
  final int adimSayisi;

  static const Map<String, KursTanitimi> _kurslar = {
    'scratch': KursTanitimi(
      courseId: 'scratch',
      sapkaBlokId: 'green_flag',
      yerlesecekBlokId: 'move_10',
      adimSayisi: 10,
    ),
  };

  /// Kursun tanitimi; acik degilse null.
  static KursTanitimi? forCourse(String courseId) => _kurslar[courseId];

  static bool acik(String courseId) => _kurslar.containsKey(courseId);

  ScratchBlokTanimi sapka(String lang) =>
      ScratchBlokKatalogu.tanim(sapkaBlokId, lang)!;

  ScratchBlokTanimi blok(String lang) =>
      ScratchBlokKatalogu.tanim(yerlesecekBlokId, lang)!;

  /// Ogrenme yolunda bu kurstan sonra gelen kurs (Scratch -> mBlock).
  ///
  /// Elle yazilmiyor: yol `pathStep` ile siralanmis, siradaki adim
  /// oradan okunuyor. Yol degisirse kart da kendiliginden degisir.
  static Course? sonrakiKurs(String courseId) {
    final yol = CoursesData.learningPath;
    final i = yol.indexWhere((c) => c.id == courseId);
    if (i < 0 || i + 1 >= yol.length) return null;
    return yol[i + 1];
  }
}

/// Acilis/kapanis "goruldu" isaretleri (cihazda, kurs basina).
class KursTanitimDeposu {
  KursTanitimDeposu._();

  static String acilisAnahtari(String courseId) =>
      'kurs_acilis_goruldu_v1_$courseId';
  static String kapanisAnahtari(String courseId) =>
      'kurs_kapanis_goruldu_v1_$courseId';

  static Future<bool> acilisGoruldu(String courseId) async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(acilisAnahtari(courseId)) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> acilisIsaretle(String courseId) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(acilisAnahtari(courseId), true);
    } catch (_) {}
  }

  static Future<bool> kapanisGoruldu(String courseId) async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(kapanisAnahtari(courseId)) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> kapanisIsaretle(String courseId) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(kapanisAnahtari(courseId), true);
    } catch (_) {}
  }
}

/// Kapanis ekranindaki ozet. HER SAYI GERCEK VERIDEN.
///
/// Uydurma istatistik yok: "yuzde 92 basari" gibi bir sey tutmuyoruz,
/// o yuzden gostermiyoruz. Ne biliyorsak o:
///  * bitirilen ders sayisi (cihaz + sunucu kaydindan),
///  * o derslerin blok kurma adimlarinda DOGRU cozumde gecen farkli
///    Scratch bloklari (ayni blogun farkli degerleri — "10 adim git" ve
///    "100 adim git" — tek blok sayiliyor),
///  * o derslerin ders XP'si (kurs sayfasindaki XP satiriyla ayni hesap).
class KursOzeti {
  const KursOzeti({
    required this.bitenDers,
    required this.toplamDers,
    required this.farkliBlok,
    required this.xp,
  });

  final int bitenDers;
  final int toplamDers;
  final int farkliBlok;
  final int xp;

  bool get kursBitti => toplamDers > 0 && bitenDers >= toplamDers;

  static KursOzeti hesapla(String courseId, Set<String> tamamlanan) {
    final dersler = CourseModules.allLessons(courseId);
    final biten = dersler.where((l) => tamamlanan.contains(l.id)).toList();
    return KursOzeti(
      bitenDers: biten.length,
      toplamDers: dersler.length,
      farkliBlok: farkliBloklar(biten).length,
      xp: biten.fold<int>(0, (t, l) => t + l.xpReward),
    );
  }

  /// Derslerin blok kurma adimlarinda dogru cozumde gecen bloklarin
  /// "turu". Katalogda karsiligi olan blok Scratch'teki sekli ve sabit
  /// yazisiyla (girdi degerleri haric) anahtarlaniyor; olmayan kendi
  /// kimligiyle.
  static Set<String> farkliBloklar(Iterable<InteractiveLesson> dersler) {
    final out = <String>{};
    for (final ders in dersler) {
      for (final adim in ders.steps.whereType<BlockBuilderStep>()) {
        for (final id in adim.correctSequence) {
          out.add(_blokTuru(id));
        }
      }
    }
    return out;
  }

  static String _blokTuru(String id) {
    final t = ScratchBlokKatalogu.tanim(id, 'en');
    if (t == null) return 'id:$id';
    final yazilar = t.satir.whereType<SbYazi>().map((y) => y.metin).join(' ');
    return '${t.kategori.name}|${t.sekil.name}|$yazilar';
  }
}

/// Bu iki ekranin kisa arayuz yazilari icin dort dilli yardimci.
String tanitimMetni(String lang, String tr, String en, String de, String es) =>
    AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
