import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

/// Ana sayfadaki GUNLUK SANDIGIN kalici durumu (cihazda).
///
/// KURAL
/// -----
/// * Her takvim gununde (cihazin yerel tarihi) sandik bir kez acilir.
/// * Odul jetonu RASTGELE DEGIL: kacinci gun ust uste acildigina bagli
///   (1. gun 5, 2. gun 6 ... en fazla 10). Bir gun kacarsa 1. gune doner.
///   Cocuga yaniltici bir "sans" sunulmuyor; yalnizca oyun rastgele.
/// * Gunun oyunu acilista secilip kaydediliyor: gun boyu ayni oyun.
///
/// CIFT ODUL OLMASIN
/// -----------------
/// [talepEt] tarihi ve odulu AYNI ANDA yaziyor; odul once "bekleyen"
/// kutusuna giriyor, sunucuya gidince oradan dusuyor ([bekleyeniGonder]).
/// Boylece ikinci dokunus (ya da uygulamanin yeniden acilmasi) ikinci bir
/// odul uretmiyor; ag yoksa ya da oturum henuz yoksa odul kaybolmuyor,
/// sonraki acilista gonderiliyor.
///
/// SAAT GERI ALINIRSA: son acilis tarihi bugunden ilerideyse sandik hazir
/// sayilmiyor (saati geri alip ayni gunu tekrar acmak olmuyor). Saat
/// ileri alinirsa bir acilis olur ama seri bozulur; kazanc yok.
class GunlukSandikDeposu {
  GunlukSandikDeposu._();

  static const anahtarGun = 'gunluk_sandik_son_gun';
  static const anahtarSeri = 'gunluk_sandik_seri';
  static const anahtarOyun = 'gunluk_sandik_oyun';
  static const anahtarOdul = 'gunluk_sandik_odul';
  static const anahtarBekleyen = 'gunluk_sandik_bekleyen';

  static const enAz = 5;
  static const enCok = 10;

  /// [gun]. gunun odulu: 5, 6, 7 ... 10'da sabit.
  static int odul(int gun) => math.min<int>(enAz + math.max<int>(gun, 1) - 1, enCok);

  /// Yerel takvim gunu, "2026-10-16".
  static String gunAnahtari(DateTime t) {
    final y = t.toLocal();
    String iki(int n) => n.toString().padLeft(2, '0');
    return '${y.year}-${iki(y.month)}-${iki(y.day)}';
  }

  static DateTime? _coz(String? s) {
    if (s == null) return null;
    final p = s.split('-');
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]), a = int.tryParse(p[1]), g = int.tryParse(p[2]);
    if (y == null || a == null || g == null) return null;
    return DateTime(y, a, g);
  }

  /// Iki yerel tarih arasindaki takvim gunu farki (yaz saati
  /// degisiminden etkilenmesin diye UTC ogle uzerinden).
  static int _fark(DateTime eski, DateTime yeni) =>
      DateTime.utc(yeni.year, yeni.month, yeni.day)
          .difference(DateTime.utc(eski.year, eski.month, eski.day))
          .inDays;

  static Future<GunlukSandikDurumu> oku(DateTime simdi) async {
    final p = await SharedPreferences.getInstance();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final son = _coz(p.getString(anahtarGun));
    final seri = p.getInt(anahtarSeri) ?? 0;
    final bekleyen = p.getInt(anahtarBekleyen) ?? 0;
    if (son != null && _fark(son, bugun) <= 0) {
      // Bugun (ya da saat geri alinmissa "gelecekte") acilmis.
      return GunlukSandikDurumu(
        hazir: false,
        gun: math.max(seri, 1),
        odul: p.getInt(anahtarOdul) ?? odul(seri),
        oyunId: p.getString(anahtarOyun),
        bekleyen: bekleyen,
      );
    }
    final siradaki = (son != null && _fark(son, bugun) == 1) ? seri + 1 : 1;
    return GunlukSandikDurumu(
      hazir: true,
      gun: siradaki,
      odul: odul(siradaki),
      oyunId: null,
      bekleyen: bekleyen,
    );
  }

  /// Bugunun sandigini acar. Bugun zaten acildiysa `null` (cift odul yok).
  static Future<GunlukSandikDurumu?> talepEt(DateTime simdi,
      {required String oyunId}) async {
    final d = await oku(simdi);
    if (!d.hazir) return null;
    final p = await SharedPreferences.getInstance();
    final bekleyen = (p.getInt(anahtarBekleyen) ?? 0) + d.odul;
    await Future.wait([
      p.setString(anahtarGun, gunAnahtari(simdi)),
      p.setInt(anahtarSeri, d.gun),
      p.setInt(anahtarOdul, d.odul),
      p.setString(anahtarOyun, oyunId),
      p.setInt(anahtarBekleyen, bekleyen),
    ]);
    return GunlukSandikDurumu(
        hazir: false, gun: d.gun, odul: d.odul, oyunId: oyunId, bekleyen: bekleyen);
  }

  /// Gunun oyunu havuzdan cikmissa (Pro bitti, reklam hakki yok) yenisi.
  static Future<void> oyunuDegistir(String oyunId) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(anahtarOyun, oyunId);
  }

  static bool _gonderiliyor = false;

  /// Bekleyen jetonu [gonder] ile sunucuya yollar. `true` donerse kutu
  /// bosaltilir; `false` ya da hata ise kutu oldugu gibi kalir.
  /// Donen deger: gonderilen miktar (0 = bir sey gitmedi).
  static Future<int> bekleyeniGonder(Future<bool> Function(int) gonder) async {
    if (_gonderiliyor) return 0;
    _gonderiliyor = true;
    try {
      final p = await SharedPreferences.getInstance();
      final miktar = p.getInt(anahtarBekleyen) ?? 0;
      if (miktar <= 0) return 0;
      // Once kutuyu bosalt: gonderim surerken gelen ikinci cagri ayni
      // jetonu bir daha yollamasin. Basarisizsa geri konuyor.
      await p.setInt(anahtarBekleyen, 0);
      var tamam = false;
      try {
        tamam = await gonder(miktar);
      } catch (_) {
        tamam = false;
      }
      if (!tamam) {
        await p.setInt(
            anahtarBekleyen, (p.getInt(anahtarBekleyen) ?? 0) + miktar);
        return 0;
      }
      return miktar;
    } finally {
      _gonderiliyor = false;
    }
  }
}

class GunlukSandikDurumu {
  const GunlukSandikDurumu({
    required this.hazir,
    required this.gun,
    required this.odul,
    required this.oyunId,
    required this.bekleyen,
  });

  /// Bugun henuz acilmadi.
  final bool hazir;

  /// Hazirsa acilinca kacinci gun olacagi; acildiysa bugunun gunu.
  final int gun;

  /// Jeton (hazirsa alinacak, acildiysa alinan).
  final int odul;

  /// Gunun oyunu (acildiysa).
  final String? oyunId;

  /// Henuz sunucuya gitmemis jeton.
  final int bekleyen;
}
