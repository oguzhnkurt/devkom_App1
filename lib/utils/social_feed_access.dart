import '../models/user_model.dart';
import '../models/homework_model.dart' show AgeGroup;

/// Sosyal akisa (feed) erisim kurali - tek merkezden yonetilir.
///
/// Neden var: Apple, App Store Connect yas derecelendirme anketine
/// "Social Media" sorusunu ekledi (Temmuz 2026, Eylul 2026'dan itibaren
/// zorunlu). Sosyal akis iceren uygulamalar minimum 13+ derecelendirme
/// aliyor ve secilen kategoriden bagimsiz olarak "Sosyal Medya" Time
/// Allowance kategorisine konuyor. Ancak Apple bir istisna taniyor:
/// sosyal medya ozellikleri 13 yas altina KAPALI ise, uygulama 13 yas alti
/// kullanicilar icin bu kategoriye dahil edilmiyor.
///
/// Devkom cocuklara yonelik bir kodlama/egitim uygulamasi oldugu icin
/// feed'i 13 yas altina kapatiyoruz. Bu dosya o kurali tek yerde tutar;
/// yeni bir feed girisi eklenirse buradaki kontrol kullanilmali.
class SocialFeedAccess {
  const SocialFeedAccess._();

  /// Apple'in esik degeri.
  static const int minimumAge = 13;

  /// Feed (paylasim akisi, gonderi olusturma, yorum, begeni) erisimi.
  ///
  /// Yas dogrulanamiyorsa BILINCLI OLARAK kapatilir - "emin degilsek kapali"
  /// yaklasimi, cunku Apple'a verilen beyan 13 yas altinda kapali oldugu
  /// yonunde ve yanlis beyan reddedilme sebebi.
  static bool isAllowed(UserModel? user) {
    // Misafir / giris yapmamis kullanici: yasi bilinmiyor -> kapali.
    if (user == null) return false;

    // Yetiskin roller (veli, ogretmen, admin) her zaman erisebilir.
    switch (user.role) {
      case UserRole.parent:
      case UserRole.teacher:
      case UserRole.admin:
        return true;
      case UserRole.student:
      case UserRole.visitor:
        break;
    }

    // Dogum tarihi varsa en guvenilir kaynak odur.
    final birthDate = user.birthDate;
    if (birthDate != null) {
      return _ageFrom(birthDate) >= minimumAge;
    }

    // Dogum tarihi yoksa yas grubuna bak.
    switch (user.ageGroup) {
      case AgeGroup.age13plus:
        return true;
      case AgeGroup.age4to6:
      case AgeGroup.age7to9:
      case AgeGroup.age10to12:
        return false;
      case AgeGroup.all:
      case null:
        // "all" ve bos deger yasi belirlemiyor -> kapali.
        return false;
    }
  }

  /// Feed kapaliysa kullaniciya gosterilecek aciklama.
  static String restrictionMessage({bool isEnglish = false}) {
    if (isEnglish) {
      return 'The social feed is available to users aged $minimumAge and over. '
          'You can keep learning with courses, games and quizzes.';
    }
    return 'Sosyal akis $minimumAge yas ve uzeri kullanicilar icindir. '
        'Kurslar, oyunlar ve quizlerle ogrenmeye devam edebilirsin.';
  }

  static int _ageFrom(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hadBirthdayThisYear = now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthdayThisYear) age--;
    return age;
  }
}
