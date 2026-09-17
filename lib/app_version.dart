/// Uygulamanın sürümü — tek kaynak.
///
/// NEDEN BU DOSYA VAR
/// ------------------
/// Ayarlar ekranında sürüm iki yerde `'1.0.0'` diye elle yazılmıştı.
/// `pubspec.yaml` çoktan `1.0.6+10`'a gelmişti ama ekran hep `1.0.0`
/// gösteriyordu: kullanıcı "version hep aynı duruyor, niye ilerlemiyor"
/// diye sordu. Elle yazılan sürüm numarası kaymaya mahkûm.
///
/// `package_info_plus` eklemek en doğrudan çözüm gibi görünüyor ama
/// pubspec'te yok; eklemek yeni bir yerel eklenti ve `pod install`
/// demek. Onun yerine sürümü burada tek yerde tutuyoruz ve
/// `test/app_version_test.dart` her koşuşta `pubspec.yaml`'ı okuyup
/// bu sabitlerle karşılaştırıyor. Sürüm yükseltilip burası
/// güncellenmezse testler kırmızıya döner — yani bir daha sessizce
/// kayamaz.
class AppVersion {
  const AppVersion._();

  /// Kullanıcıya gösterilen sürüm (pubspec'teki `+`'dan önceki kısım).
  static const String name = '1.0.8';

  /// Derleme numarası (pubspec'teki `+`'dan sonraki kısım).
  static const String build = '14';

  /// "1.0.6 (10)" — hakkında ekranı için.
  static const String full = '$name ($build)';
}
