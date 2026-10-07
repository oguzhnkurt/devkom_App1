import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/lang.dart';

/// Kelime Eslestirme'nin 24 seviyesi (Ekim 2026).
///
/// Eskiden 5 seviye vardi ve hepsi ayniydi: 5 cift, sure yok, hata
/// serbest. Cocuk 5 dakikada bitirip bir daha acmiyordu. Simdi alti
/// dunyada dort seviye; zorluk dort koldan ve YAVAS artiyor:
///
///  * Cift sayisi: 3'ten 6'ya. (Ust sinir bilerek 6: 11 yasinda calisma
///    bellegi ~4 birim; 6 cift kaydirmadan sigiyor ve zorluyor ama
///    bogmuyor.)
///  * Kelime havuzu: Robotik → Scratch → Arduino → Kodlama → Usta
///    kavramlar → hepsi karisik.
///  * Can: 11. seviyeden itibaren 3 can, son dunyada 2. Yanlis eslesme
///    bir can goturuyor; bitince seviye bastan.
///  * Sure: 17. seviyeden itibaren geri sayim (90 sn'den 45 sn'ye).
///
/// Ilk on seviyede ne can ne sure var: once oyunu sevsin.
class KelimeSeviyesi {
  const KelimeSeviyesi({
    required this.no,
    required this.dunya,
    required this.cift,
    required this.temalar,
    this.can,
    this.sure,
  });

  final int no;

  /// 1-6.
  final int dunya;

  /// Tahtadaki cift sayisi.
  final int cift;

  /// Kelimelerin cekildigi havuzlar (word_match_words.dart anahtarlari).
  final List<int> temalar;

  /// Hata hakki; null = sinirsiz.
  final int? can;

  /// Saniye; null = suresiz.
  final int? sure;
}

class KelimeSeviyeleri {
  KelimeSeviyeleri._();

  static const int toplam = 24;

  static final List<KelimeSeviyesi> hepsi = List.unmodifiable([
    // Dunya 1 — Robotik
    for (final (i, c) in [(1, 3), (2, 3), (3, 4), (4, 4)])
      KelimeSeviyesi(no: i, dunya: 1, cift: c, temalar: const [1]),
    // Dunya 2 — Scratch
    for (final (i, c) in [(5, 4), (6, 4), (7, 5), (8, 5)])
      KelimeSeviyesi(no: i, dunya: 2, cift: c, temalar: const [2]),
    // Dunya 3 — Arduino (11'den itibaren can)
    for (final (i, can) in [(9, null), (10, null), (11, 3), (12, 3)])
      KelimeSeviyesi(no: i, dunya: 3, cift: 5, temalar: const [3], can: can),
    // Dunya 4 — Kodlama
    for (final (i, c) in [(13, 5), (14, 5), (15, 6), (16, 6)])
      KelimeSeviyesi(no: i, dunya: 4, cift: c, temalar: const [4], can: 3),
    // Dunya 5 — Usta kavramlar, geri sayim
    for (final (i, s) in [(17, 90), (18, 80), (19, 70), (20, 60)])
      KelimeSeviyesi(
          no: i, dunya: 5, cift: 6, temalar: const [5], can: 3, sure: s),
    // Dunya 6 — Efsane: her seyden karisik, 2 can
    for (final (i, s) in [(21, 60), (22, 55), (23, 50), (24, 45)])
      KelimeSeviyesi(
          no: i,
          dunya: 6,
          cift: 6,
          temalar: const [1, 2, 3, 4, 5],
          can: 2,
          sure: s),
  ]);

  static KelimeSeviyesi seviye(int no) => hepsi[(no - 1).clamp(0, toplam - 1)];

  static String dunyaAdi(int dunya, String lang) {
    String t(String tr, String en, String de, String es) =>
        AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
    switch (dunya) {
      case 1:
        return t('Robotik', 'Robotics', 'Robotik', 'Robótica');
      case 2:
        return 'Scratch';
      case 3:
        return 'Arduino';
      case 4:
        return t('Kodlama', 'Coding', 'Programmieren', 'Programación');
      case 5:
        return t('Usta Kavramlar', 'Master Concepts', 'Profi-Begriffe',
            'Conceptos maestros');
      default:
        return t('Efsane Karışık', 'Legend Mix', 'Legenden-Mix',
            'Mezcla legendaria');
    }
  }

  /// Yildiz: hatasiz 3, en fazla 2 hata 2, gerisi 1.
  static int yildiz(int hata) => hata == 0 ? 3 : (hata <= 2 ? 2 : 1);
}

/// Seviye ilerlemesi cihazda (SharedPreferences). Kayit okunamazsa oyun
/// 1. seviyeden acilir; hicbir sey kaybolmaz, yalnizca kilitler kapali
/// gorunur.
class KelimeIlerlemesi {
  KelimeIlerlemesi._();

  static const _acikAnahtar = 'kelime_eslestirme_acik_seviye';
  static String _yildizAnahtar(int no) => 'kelime_eslestirme_yildiz_$no';

  /// Oynanabilen en yuksek seviye.
  static Future<int> acik() async {
    try {
      final p = await SharedPreferences.getInstance();
      return (p.getInt(_acikAnahtar) ?? 1).clamp(1, KelimeSeviyeleri.toplam);
    } catch (_) {
      return 1;
    }
  }

  static Future<Map<int, int>> yildizlar() async {
    try {
      final p = await SharedPreferences.getInstance();
      return {
        for (var i = 1; i <= KelimeSeviyeleri.toplam; i++)
          if ((p.getInt(_yildizAnahtar(i)) ?? 0) > 0)
            i: p.getInt(_yildizAnahtar(i))!,
      };
    } catch (_) {
      return const {};
    }
  }

  /// Seviye bitti: yildizi (daha iyiyse) yazar, sonrakini acar.
  static Future<void> bitti(int no, int yildiz) async {
    try {
      final p = await SharedPreferences.getInstance();
      final eski = p.getInt(_yildizAnahtar(no)) ?? 0;
      if (yildiz > eski) await p.setInt(_yildizAnahtar(no), yildiz);
      final acik = p.getInt(_acikAnahtar) ?? 1;
      final yeni = (no + 1).clamp(1, KelimeSeviyeleri.toplam);
      if (yeni > acik) await p.setInt(_acikAnahtar, yeni);
    } catch (_) {}
  }
}
