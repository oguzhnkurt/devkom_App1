import '../models/learner_profile.dart';
import '../utils/lang.dart';

/// Bir yerleştirme görevinin sonucu.
///
/// Kaç denemede yapıldığı ve ipucu alınıp alınmadığı ayrı tutuluyor:
/// ilk denemede yapmakla, ipucundan sonra yapmak aynı şey değil.
class PlacementAttempt {
  const PlacementAttempt({
    required this.taskId,
    required this.solved,
    this.tries = 1,
    this.usedHint = false,
  });

  final String taskId;
  final bool solved;
  final int tries;
  final bool usedHint;

  /// 0.0 ile 1.0 arasında bir puan.
  ///
  /// Çözemediyse 0 ama CEZA yok — sadece o görevden puan gelmiyor.
  /// İpucu aldıysa yarım puan: yapabildi ama yardımla.
  double get score {
    if (!solved) return 0;
    if (usedHint) return 0.5;
    if (tries == 1) return 1.0;
    return 0.75;
  }
}

/// Çocuğun nereden başlayacağını belirleyen yerleştirme.
///
/// TASARIM — NEDEN BÖYLE
/// ---------------------
/// Önceki akış çocuğa "Daha önce kod yazdın mı?" diye SORUYORDU. Bunun
/// iki sorunu var: 9 yaşındaki bir çocuk "kod yazmak" ile "Scratch'te
/// blok sürüklemek" arasındaki farkı bilmiyor, ve kendi seviyesini
/// olduğundan yüksek ya da düşük söylüyor. Cevap yanlışsa yol da yanlış
/// kuruluyor.
///
/// Artık ÖLÇÜYORUZ. Ama bir sınav gibi değil:
///
/// * **Sınav denmiyor, sınav gibi görünmüyor.** Çocuk sadece birkaç
///   küçük şey yapıyor. Prodigy'nin yaptığı da bu: yerleştirme testi
///   oyunun içine gömülü, çocuk "değerlendirildiğini fark etmeden"
///   tamamlıyor.
/// * **Yaş bir PENCERE belirliyor, seviye değil.** Prodigy'de sorular
///   "seçilen sınıfın bir altı ile bir üstü" arasından geliyor; performans
///   pencerenin içindeki noktayı buluyor. Burada da aynı: 7 yaşındaki bir
///   çocuk hepsini doğru yapsa bile Python'a atılmıyor.
/// * **Yanlış cevap kimseyi geri düşürmüyor.** İpucu var, ikinci deneme
///   var, "yanlış" kelimesi yok. Khan Academy'nin iki seviye geri düşürme
///   mekaniği bilerek KOPYALANMADI: 7 yaşındaki bir çocuğa görünür bir
///   düşüş göstermek, ölçmek istediğimiz şeyi bozar.
/// * **Atlanabilir.** Hiçbir görev yapılmasa da uygulama çalışıyor ve
///   makul bir varsayılan seviyeyle başlıyor. Apple'ın 5.1.4(a) maddesi
///   bunu zorunlu kılıyor: uygulama "kişinin yaşından bağımsız olarak"
///   işe yarar olmalı, yani hiçbir işlev bu sorulara kilitlenemez.
class PlacementService {
  PlacementService._();

  /// Yaşın açtığı pencere: bu yaşta en fazla hangi seviyeye çıkılabilir?
  ///
  /// Üst sınır bilgiyle ilgili değil, okuma ve yazma yüküyle ilgili.
  /// 4-6 yaş bandındaki bir çocuk blokları harika kullanabilir ama
  /// klavyeyle Python yazmak o yaşta dersin kendisini değil, yazmayı
  /// öğretmek olur.
  static SkillLevel ceilingFor(LearnerAgeBand? band) => switch (band) {
        LearnerAgeBand.age4to6 => SkillLevel.beginner,
        LearnerAgeBand.age7to9 => SkillLevel.someBlocks,
        LearnerAgeBand.age10to12 => SkillLevel.someCode,
        LearnerAgeBand.age13plus => SkillLevel.someCode,
        // Yaş söylenmediyse pencereyi kapatmıyoruz: sorulmadığı için
        // çocuğu cezalandırmak olurdu.
        null => SkillLevel.someCode,
      };

  /// Yaşın belirlediği taban: hiç görev yapılmasa bile buradan başlanır.
  static SkillLevel floorFor(LearnerAgeBand? band) => SkillLevel.beginner;

  /// Görev sonuçlarından seviyeyi çıkarır.
  ///
  /// [attempts] boşsa — çocuk görevleri atladıysa — yaşa göre makul bir
  /// varsayılan dönüyor. Bu bir tahmin ve öyle davranılıyor: yol
  /// ilerledikçe gerçek performans zaten devreye giriyor.
  static SkillLevel levelFrom(
    List<PlacementAttempt> attempts, {
    LearnerAgeBand? ageBand,
  }) {
    final ceiling = ceilingFor(ageBand);

    if (attempts.isEmpty) {
      // Ölçüm yok. En güvenli yer başlangıç: fazla kolay bir ders
      // sıkabilir ama fazla zor bir ders çocuğu kaybeder.
      return SkillLevel.beginner;
    }

    final total = attempts.fold<double>(0, (sum, a) => sum + a.score);
    final ratio = total / attempts.length;

    final measured = switch (ratio) {
      >= 0.80 => SkillLevel.someCode,
      >= 0.45 => SkillLevel.someBlocks,
      _ => SkillLevel.beginner,
    };

    return _min(measured, ceiling);
  }

  /// İki seviyeden düşük olanı.
  static SkillLevel _min(SkillLevel a, SkillLevel b) =>
      a.index <= b.index ? a : b;

  /// Ölçüm ne kadar güvenilir?
  ///
  /// Bunu kullanıcıya göstermiyoruz; yalnızca yol kurulurken "bu tahmine
  /// ne kadar yaslanalım" sorusunun cevabı. Tek görevden çıkan bir sonuç
  /// üç görevden çıkana göre çok daha zayıf.
  static double confidence(List<PlacementAttempt> attempts) {
    if (attempts.isEmpty) return 0;
    return (attempts.length / 3).clamp(0.0, 1.0);
  }

  /// Çocuğa gösterilecek kapanış cümlesi.
  ///
  /// DİKKAT: burada asla puan, yüzde ya da "şu kadarını bildin" YOK.
  /// Çocuk kaç tanesini doğru yaptığını öğrenmiyor, çünkü bu bir sınav
  /// değil — öğrenirse sınav olur. Cümleler çabayı anlatıyor, sonucu
  /// değil: Duolingo'nun kendi A/B testinde koçun "gelişim zihniyeti"
  /// diliyle konuşması, standart övgüye göre 14 günlük tutmayı %7,2
  /// artırmıştı.
  static String closingLine(List<PlacementAttempt> attempts, String lang) {
    final tr = attempts.isEmpty
        ? 'Hazırsın! Sana uygun bir yerden başlıyoruz.'
        : 'Tamamdır — nereden başlayacağını buldum. Hadi başlayalım!';
    final en = attempts.isEmpty
        ? 'You are all set. We will start somewhere that fits you.'
        : 'Got it — I found where to start you. Let\'s go!';
    final de = attempts.isEmpty
        ? 'Alles bereit! Wir fangen an einer Stelle an, die zu dir passt.'
        : 'Alles klar — ich habe deinen Startpunkt gefunden. Los geht es!';
    final es = attempts.isEmpty
        ? 'Todo listo. Empezaremos en un punto que te venga bien.'
        : 'Listo: encontre por donde empezar. ¡Vamos!';
    return AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
  }
}
