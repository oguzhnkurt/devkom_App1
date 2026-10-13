import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama ici degerlendirme (App Store / Google Play puan kutusu).
///
/// NE ZAMAN SORUYORUZ - "tadinda":
///  * Bir ders ya da oyun BITTIKTEN sonra, yani iyi bir anin hemen ardindan.
///  * Kutu oyunun/dersin ustune binmiyor: tipki gecis reklami gibi yalnizca
///    bir bayrak kalkiyor, kutu kullanici o ekrandan CIKARKEN aciliyor
///    (bkz. [AdNavigatorObserver]). O gecis reklamsiz geciyor.
///  * En az [enAzBasari] tamamlanmis ders/oyun ve ilk acilistan bu yana en
///    az [enAzGun] gun. Yeni kullaniciya hic sorulmuyor.
///  * Iki sorma arasinda en az [araGun] gun, toplamda en fazla
///    [enFazlaSorma] kez. Apple zaten yilda 3 kezle, Google da kendi
///    kotasiyla sinirliyor; bizim sinirimiz daha siki.
///
/// NE YAPMIYORUZ:
///  * Kutudan once "Uygulamayi sevdin mi?" diye sormuyoruz. Google'in
///    kurali acik: puan kartindan once ya da sirasinda soru sorulmaz.
///    Ayrica cocugu bir "evet"e yonlendirmek de istemiyoruz.
///  * Ayarlar'daki "Degerlendir" satiri bu kutuyu ACMIYOR; magaza sayfasini
///    aciyor. Kota dolunca kutu sessizce gelmiyor; dugme bozuk gorunurdu.
class DegerlendirmeServisi {
  DegerlendirmeServisi._();
  static final DegerlendirmeServisi instance = DegerlendirmeServisi._();

  static const int enAzBasari = 4;
  static const int enAzGun = 2;
  static const int araGun = 120;
  static const int enFazlaSorma = 3;

  /// App Store kimligi (apps.apple.com/app/id6775481665).
  static const String appStoreId = '6775481665';

  static const _kBasari = 'degerlendirme_basari';
  static const _kIlkAcilis = 'degerlendirme_ilk_acilis';
  static const _kSonSorma = 'degerlendirme_son_sorma';
  static const _kSormaSayisi = 'degerlendirme_sorma_sayisi';

  bool _bekliyor = false;

  /// Bir sonraki ekran gecisinde kutu acilacak mi?
  bool get bekliyor => _bekliyor;

  /// Testlerde gercek eklenti yerine sahtesi konuyor.
  @visibleForTesting
  Future<bool> Function()? kullanilabilirMi;
  @visibleForTesting
  Future<void> Function()? kutuyuAc;
  @visibleForTesting
  Future<void> Function()? magazayiAc;
  @visibleForTesting
  DateTime Function() simdi = DateTime.now;

  @visibleForTesting
  void sifirla() {
    _bekliyor = false;
    kullanilabilirMi = null;
    kutuyuAc = null;
    magazayiAc = null;
    simdi = DateTime.now;
  }

  /// Uygulama acilisinda bir kez: ilk acilis tarihini yazar (yoksa).
  Future<void> baslat() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (!p.containsKey(_kIlkAcilis)) {
        await p.setString(_kIlkAcilis, simdi().toIso8601String());
      }
    } catch (_) {}
  }

  /// Ders ya da oyun bitti. Kosullar tutuyorsa bir sonraki gecise bayrak
  /// kaldirir; kutuyu burada ACMAZ.
  Future<void> basariKaydet() async {
    try {
      final p = await SharedPreferences.getInstance();
      final sayi = (p.getInt(_kBasari) ?? 0) + 1;
      await p.setInt(_kBasari, sayi);
      if (!p.containsKey(_kIlkAcilis)) {
        await p.setString(_kIlkAcilis, simdi().toIso8601String());
      }
      if (_uygun(p, sayi)) _bekliyor = true;
    } catch (e) {
      debugPrint('DegerlendirmeServisi.basariKaydet: $e');
    }
  }

  bool _uygun(SharedPreferences p, int basari) {
    if (basari < enAzBasari) return false;
    final sorma = p.getInt(_kSormaSayisi) ?? 0;
    if (sorma >= enFazlaSorma) return false;
    final ilk = DateTime.tryParse(p.getString(_kIlkAcilis) ?? '');
    if (ilk == null || simdi().difference(ilk).inDays < enAzGun) return false;
    final son = DateTime.tryParse(p.getString(_kSonSorma) ?? '');
    if (son != null && simdi().difference(son).inDays < araGun) return false;
    return true;
  }

  /// Ekran gecisinde cagriliyor. Bayrak kalkiksa kutuyu acar.
  /// Donus: kutu istendi mi (o gecisteki reklam atlanir).
  Future<bool> bekliyorsaGoster() async {
    if (!_bekliyor) return false;
    _bekliyor = false;
    try {
      final hazir = await (kullanilabilirMi ?? InAppReview.instance.isAvailable)();
      if (!hazir) return false;
      final p = await SharedPreferences.getInstance();
      await p.setString(_kSonSorma, simdi().toIso8601String());
      await p.setInt(_kSormaSayisi, (p.getInt(_kSormaSayisi) ?? 0) + 1);
      await (kutuyuAc ?? InAppReview.instance.requestReview)();
      return true;
    } catch (e) {
      debugPrint('DegerlendirmeServisi.bekliyorsaGoster: $e');
      return false;
    }
  }

  /// Ayarlar → "Uygulamayi degerlendir": magaza sayfasini acar.
  Future<void> magazaSayfasiniAc() async {
    try {
      await (magazayiAc ??
          () => InAppReview.instance.openStoreListing(appStoreId: appStoreId))();
    } catch (e) {
      debugPrint('DegerlendirmeServisi.magazaSayfasiniAc: $e');
    }
  }
}
