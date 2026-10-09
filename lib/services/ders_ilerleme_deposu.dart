import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ders ilerlemesinin CIHAZDAKI kalici kopyasi.
///
/// NEDEN AYRI BIR YEREL KAYIT
/// --------------------------
/// Bitirilen derslerin listesi (`completed_lesson_ids`) yalnizca
/// Supabase'teki `user_progress` satirinda duruyordu ve uygulama onu her
/// acilista AGDAN okuyordu. Ag yoksa, istek hata verirse ya da anonim
/// oturum henuz acilmadiysa liste bos geliyordu; cocuk 3 ders bitirip
/// ertesi gun girdiginde kurs "hic baslanmamis" gibi gorunuyor ve tus
/// onu 1. derse goturuyordu ("Scratch'te 3 dersi bitirdim, ertesi gun
/// yine 'Ogrenmeye basla' cikti").
///
/// Artik her bitis ONCE burada (SharedPreferences) yaziliyor, sonra
/// sunucuya gidiyor. Ekranlar ikisinin birlesimini okuyor: sunucu
/// hata verse de cihazdaki kayit kaybolmuyor.
///
/// Hata durumunda hicbir metot istisna firlatmiyor: ilerleme kaydi bir
/// dersin bitis kutlamasini asla bozmamali.
class DersIlerlemeDeposu {
  DersIlerlemeDeposu._();

  /// Bitirilen ders kimlikleri (StringList).
  static const String tamamlananAnahtari = 'ders_ilerleme.tamamlanan';

  /// En az bir dersi ACILMIS kurslar (StringList). Hic ders bitirmemis
  /// ama bir derse girmis cocuga da "kaldigin yerden devam et" demek icin.
  static const String baslananAnahtari = 'ders_ilerleme.baslanan_kurslar';

  /// En son ders acilan kurs. Ana sayfa "kaldigin yer"i once burada
  /// ariyor: cocuk katalogdan yolun disindaki bir kursa baslamis olabilir.
  static const String sonKursAnahtari = 'ders_ilerleme.son_kurs';

  static Future<Set<String>> tamamlananlar() =>
      _liste(tamamlananAnahtari);

  static Future<Set<String>> baslananKurslar() =>
      _liste(baslananAnahtari);

  static Future<String?> sonKurs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(sonKursAnahtari);
    } catch (e) {
      debugPrint('Son kurs okunamadi: $e');
      return null;
    }
  }

  /// Dersi bitmis olarak isaretler. Ayni ders ikinci kez yazilmaz.
  static Future<void> dersTamamlandi(String lessonId) =>
      ekle(tamamlananAnahtari, [lessonId]);

  /// Sunucudan gelen listeyi cihaza da yazar; bir sonraki acilista ag
  /// olmasa bile ilerleme gorunsun diye.
  static Future<void> tamamlananlariEkle(Iterable<String> ids) =>
      ekle(tamamlananAnahtari, ids);

  /// Kursun bir dersi acildi: kurs "baslanmis" sayilir ve son kurs olur.
  static Future<void> kursAcildi(String courseId) async {
    await ekle(baslananAnahtari, [courseId]);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(sonKursAnahtari, courseId);
    } catch (e) {
      debugPrint('Son kurs yazilamadi: $e');
    }
  }

  /// Cikista temizlenir: ayni cihazda baska bir hesap acildiginda
  /// onceki cocugun ilerlemesi onun yerine gecmesin.
  static Future<void> temizle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(tamamlananAnahtari);
      await prefs.remove(baslananAnahtari);
      await prefs.remove(sonKursAnahtari);
    } catch (e) {
      debugPrint('Ders ilerlemesi temizlenemedi: $e');
    }
  }

  static Future<Set<String>> _liste(String anahtar) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(anahtar) ?? const <String>[]).toSet();
    } catch (e) {
      debugPrint('Ders ilerlemesi okunamadi ($anahtar): $e');
      return <String>{};
    }
  }

  /// Listeye eksik olanlari ekler; sira korunur, tekrar yazilmaz.
  static Future<void> ekle(String anahtar, Iterable<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final liste = prefs.getStringList(anahtar) ?? <String>[];
      var degisti = false;
      for (final id in ids) {
        if (!liste.contains(id)) {
          liste.add(id);
          degisti = true;
        }
      }
      if (degisti) await prefs.setStringList(anahtar, liste);
    } catch (e) {
      debugPrint('Ders ilerlemesi yazilamadi ($anahtar): $e');
    }
  }
}
