import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/lang.dart';
import '../../widgets/scratch_blok.dart';
import '../data/course_modules.dart';
import '../data/courses_data.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../yurutme/mblock_blok_adlari.dart';
import '../yurutme/mblock_cozum.dart';
import '../yurutme/scratch_blok_katalogu.dart';

/// Acilis sahnesinde blok calisinca ne oluyor.
enum TanitimSahnesi {
  /// Scratch: Devi kukla olarak sahnede yuruyor.
  kukla,

  /// mBlock: sanal Arduino Uno'da bir LED yaniyor.
  kart,
}

/// Bir kursun acilis sahnesi ve kapanis toreni icin ayar.
///
/// NEDEN AYAR
/// ----------
/// Acilis (Devi + tek blokluk mini etkinlik) ve kapanis (konfeti, ozet,
/// sertifika, siradaki kurs) kursa bagli degil: ekranlar yalnizca
/// buradaki ayari okuyor. Bir kurs eklemek = buraya bir satir + o kursun
/// iki blogu.
///
///  * Scratch: "yesil bayrak tiklandiginda" + "10 adim git"; Devi kukla
///    olarak sahnede yuruyor.
///  * mBlock: "when Arduino Uno starts up" + "dijital ayarla pin 13
///    cikis yuksek"; sanal Uno'nun 13. pinindeki LED yaniyor.
class KursTanitimi {
  const KursTanitimi({
    required this.courseId,
    required this.sapkaBlokId,
    required this.yerlesecekBlokId,
    this.adimSayisi = 0,
    this.sahne = TanitimSahnesi.kukla,
    this.ledPini = 13,
  });

  final String courseId;

  /// Kod alaninda hazir duran baslatici (sapka) blok.
  final String sapkaBlokId;

  /// Cocugun yerine koyacagi TEK blok.
  final String yerlesecekBlokId;

  /// Bu blok calisinca kuklanin attigi adim (sahnedeki noktalar).
  final int adimSayisi;

  final TanitimSahnesi sahne;

  /// Kart sahnesinde yanan LED'in pini.
  final int ledPini;

  bool get kart => sahne == TanitimSahnesi.kart;

  static const Map<String, KursTanitimi> _kurslar = {
    'scratch': KursTanitimi(
      courseId: 'scratch',
      sapkaBlokId: 'green_flag',
      yerlesecekBlokId: 'move_10',
      adimSayisi: 10,
    ),
    'mblock': KursTanitimi(
      courseId: 'mblock',
      sapkaBlokId: 'dev_kart_acilis',
      yerlesecekBlokId: 'dev_dijital_yaz',
      sahne: TanitimSahnesi.kart,
      ledPini: 13,
    ),
    // Arduino'nun acilisi ayri bir ekran (ArduinoTanitimEkrani: Devi
    // malzemeleri tanitiyor); bu satir acilis/kapanisi acik yapiyor.
    'arduino': KursTanitimi(
      courseId: 'arduino',
      sapkaBlokId: 'dev_kart_acilis',
      yerlesecekBlokId: 'dev_dijital_yaz',
      sahne: TanitimSahnesi.kart,
      ledPini: 13,
    ),
  };

  /// Kursun tanitimi; acik degilse null.
  static KursTanitimi? forCourse(String courseId) => _kurslar[courseId];

  static bool acik(String courseId) => _kurslar.containsKey(courseId);

  ScratchBlokTanimi sapka(String lang) => kart
      ? mblockScratchTanimi(sapkaBlokId, const {}, lang)
      : ScratchBlokKatalogu.tanim(sapkaBlokId, lang)!;

  ScratchBlokTanimi blok(String lang) => kart
      ? mblockScratchTanimi(yerlesecekBlokId,
          {'PIN': '$ledPini', 'SEVIYE': 'HIGH'}, lang)
      : ScratchBlokKatalogu.tanim(yerlesecekBlokId, lang)!;

  /// Kart sahnesinde calisan program (tezgahin okuduguyla ayni yapi).
  List<MBlockBlok> get kartProgrami => [
        MBlockBlok(tip: sapkaBlokId),
        MBlockBlok(
            tip: yerlesecekBlokId,
            alanlar: {'PIN': '$ledPini', 'SEVIYE': 'HIGH'}),
      ];

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
    void mblock(MBlockBeklenen b) {
      out.add('mblock:${b.tip}');
      b.icerik.forEach(mblock);
      b.girdiler.values.forEach(mblock);
    }

    for (final ders in dersler) {
      for (final adim in ders.steps.whereType<BlockBuilderStep>()) {
        // mBlock adimlari tezgahta kuruluyor: kullanilan bloklar cozumun
        // agacindan (C kutularinin ici ve yuvalara takilanlar dahil).
        final tezgah = adim.mblock;
        if (tezgah != null) {
          tezgah.cozum.forEach(mblock);
          continue;
        }
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

/// mBlock blogunu acilis sahnesindeki Scratch cizimiyle ([ScratchBlok])
/// gosterir: sapka "when Arduino Uno starts up", pin bloklari mBlock'un
/// Pin mavisinde, acilir listeler kendi degerleriyle.
ScratchBlokTanimi mblockScratchTanimi(
    String tip, Map<String, String> alanlar, String lang) {
  final t = mblockBlokTanimlari[tip]!;
  final kategori = switch (t.kategori) {
    'pin' => ScratchKategori.mblockPin,
    'kontrol' => ScratchKategori.kontrol,
    _ => ScratchKategori.olaylar,
  };
  final sablon = t.etiket[lang] ?? t.etiket['en']!;
  final parcalar = <SbParca>[];
  final re = RegExp(r'%(\d)');
  var i = 0;
  for (final m in re.allMatches(sablon)) {
    final once = sablon.substring(i, m.start).trim();
    if (once.isNotEmpty) parcalar.add(SbYazi(once));
    final n = int.parse(m.group(1)!);
    final yuva = n - 1 < t.yuvalar.length ? t.yuvalar[n - 1] : null;
    final deger = yuva == null
        ? ''
        : alanlar[yuva] ?? mblockVarsayilanAlanlar[tip]?[yuva] ?? '';
    parcalar.add(SbAcilir(mblockDegerAdi(deger, lang)));
    i = m.end;
  }
  final son = sablon.substring(i).trim();
  if (son.isNotEmpty) parcalar.add(SbYazi(son));
  return ScratchBlokTanimi(
    kategori: kategori,
    sekil: t.sapkaMi ? ScratchSekil.sapka : ScratchSekil.yigin,
    satir: parcalar,
  );
}
