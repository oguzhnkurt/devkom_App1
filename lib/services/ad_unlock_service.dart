import 'package:shared_preferences/shared_preferences.dart';

/// Odullu reklamla acilan kilitleri tutar.
///
/// NE ACILIR, NE ACILMAZ
/// ---------------------
/// - Pro bir kursun ILK IKI dersi odullu reklamla acilabiliyor ve acik
///   KALIYOR. Cocugun ayni derse geri donmek icin ikinci kez reklam
///   izlemesi gerekmiyor.
/// - Ucuncu ders ve sonrasi yalnizca Pro. Tadimlik olmasinin sebebi bu:
///   kursun tamami reklamla bitirilebilseydi Pro'nun satacagi bir sey
///   kalmazdi ve cocuk ilerlemek icin reklam izlemeye mecbur kalirdi.
/// - Pro oyunlar kalici olarak ACILMAZ. Reklam yalnizca TEK TUR veriyor;
///   o yuzden burada saklanmiyorlar (bkz. ProGate.ensureOrAd).
///
/// Ucretsiz kurslar bu sinifa hic ugramiyor.
class AdUnlockService {
  AdUnlockService._();

  static final AdUnlockService instance = AdUnlockService._();

  /// Pro bir kursta reklamla acilabilen ders sayisi.
  static const int reklamlaAcilabilirDers = 2;

  static const String _kKey = 'ad_unlocked_lessons';

  /// Test icin bellekte tutulan kopya; her cagri prefs okumasin diye.
  Set<String>? _onbellek;

  String _kayit(String courseId, String lessonId) => '$courseId/$lessonId';

  Future<Set<String>> _oku() async {
    if (_onbellek != null) return _onbellek!;
    final prefs = await SharedPreferences.getInstance();
    _onbellek = (prefs.getStringList(_kKey) ?? const <String>[]).toSet();
    return _onbellek!;
  }

  /// [dersSirasi] kurs icindeki sifir tabanli sira (modulleri duzlestirerek).
  ///
  /// Ilk iki ders icin true doner; uzerini reklam acmiyor.
  bool reklamlaAcilabilir(int dersSirasi) =>
      dersSirasi >= 0 && dersSirasi < reklamlaAcilabilirDers;

  /// Ders daha once reklamla acilmis mi?
  Future<bool> acikMi(String courseId, String lessonId) async =>
      (await _oku()).contains(_kayit(courseId, lessonId));

  /// Dersi kalici olarak acar. Sirasi ilk ikinin disindaysa hicbir sey
  /// yapmaz ve false doner — cagiran yeri yanlislikla acmaya karsi koruma.
  Future<bool> ac(String courseId, String lessonId, int dersSirasi) async {
    if (!reklamlaAcilabilir(dersSirasi)) return false;
    final mevcut = await _oku();
    if (mevcut.add(_kayit(courseId, lessonId))) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kKey, mevcut.toList()..sort());
    }
    return true;
  }

  /// Bir kursta reklamla acilmis ders sayisi.
  Future<int> acilanSayisi(String courseId) async {
    final hepsi = await _oku();
    return hepsi.where((k) => k.startsWith('$courseId/')).length;
  }

  /// Testler arasinda durumu sifirlamak icin.
  Future<void> temizle() async {
    _onbellek = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
