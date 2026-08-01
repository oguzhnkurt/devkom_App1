/// RoboAkademi Yaz Kursu Müfredatı — 3 Yaş Grubu, 8 Haftalık Programlar
///
/// Bu dosya, RoboAkademi'nin atölye müfredatını (statik içerik olarak) tutar.
/// Öğrencinin HANGI haftada olduğu / hangi haftaların tamamlandığı gibi
/// dinamik ilerleme bilgisi Supabase'deki `workshop_students.current_week`
/// alanında tutulur; bu dosyadaki veri sadece "8 hafta boyunca ne işleniyor"
/// içeriğidir. Hangi öğrencinin hangi yaş grubu müfredatını göreceği ise
/// `workshop_students.age_group` alanına göre belirlenir (bkz. migration 21).
///
/// Üç ayrı yaş grubu:
///   * age_4_6   -> Kreş / Anaokulu Grubu (kaynak: RoboAkademi_5-6-7_Yas_8_Haftalik_Mufredat.pdf)
///   * age_7_10  -> İlkokul Grubu
///   * age_11_14 -> Ortaokul Grubu
class RoboAkademiWeek {
  final int weekNumber;
  final String theme;
  final List<String> activities;
  final List<String> outcomes;

  const RoboAkademiWeek({
    required this.weekNumber,
    required this.theme,
    required this.activities,
    required this.outcomes,
  });
}

/// One full 8-week curriculum track for a single age band.
class RoboAkademiAgeGroupCurriculum {
  final String ageGroup;
  final String displayName;
  final String programTitle;
  final String programSubtitle;
  final String programDescription;
  final List<String> generalOutcomes;
  final List<String> weeklyFlow;
  final List<String> materials;
  final List<RoboAkademiWeek> weeks;

  const RoboAkademiAgeGroupCurriculum({
    required this.ageGroup,
    required this.displayName,
    required this.programTitle,
    required this.programSubtitle,
    required this.programDescription,
    required this.generalOutcomes,
    required this.weeklyFlow,
    required this.materials,
    required this.weeks,
  });

  RoboAkademiWeek? weekByNumber(int number) {
    try {
      return weeks.firstWhere((w) => w.weekNumber == number);
    } catch (_) {
      return null;
    }
  }
}

class RoboAkademiCurriculumData {
  // ============================================================
  // AGE 4-6 — Kreş / Anaokulu Grubu
  // ============================================================
  static const RoboAkademiAgeGroupCurriculum age4to6 = RoboAkademiAgeGroupCurriculum(
    ageGroup: 'age_4_6',
    displayName: '4-6 Yaş · Kreş/Anaokulu Grubu',
    programTitle: 'RoboAkademi Yaz Kursu Müfredatı',
    programSubtitle: '4-6 Yaş Grubu · 8 Haftalık Program',
    programDescription:
        'LEGO SPIKE Prime robotik kitleri, laptoplar üzerinden Scratch, mBlock ve '
        'Tinkercad kullanımı, öğretmen rehberliğinde yapılan Arduino devre '
        'denemeleri, Wordwall üzerinden dijital pekiştirme oyunları, algoritmik '
        'etkinlik kitapları, akıl-zekâ etkinlikleri, satranç ve İngilizceyi oyun '
        'temelli, eğlenceli bir yaklaşımla bir araya getirir.',
    generalOutcomes: [
      'Yönergeleri dinler ve sırayla uygular (ileri, geri, sağ, sol gibi temel komutlar)',
      'Nesneler arasında sebep-sonuç ilişkisi kurar',
      'Basit örüntü, eşleştirme ve labirent problemlerini çözer',
      'Grup içinde sırasını bekler, işbirliği yapar ve kurallara uyar',
      '10\'a kadar İngilizce sayı, temel renkler, hayvanlar ve aile üyelerini tanır',
      'Satranç tahtasını ve temel taş hareketlerini (piyon, at, fil, şah) tanır',
      'Fare ve klavyeyi temel düzeyde, güvenle kullanır',
      'Scratch\'in renkli kod bloklarıyla basit bir animasyon veya küçük bir hikâye oluşturur',
      '\'Yazılım\' ve \'yapay zekâ\' kavramlarını günlük hayattan sevimli örneklerle ilişkilendirir',
      'Tinkercad\'de basit şekil ve devre tasarımı yapar',
      'Öğretmen rehberliğinde basit bir Arduino devresini keyifle dener',
      'Algoritmik etkinlik kitapları ile temel mantık ve sıralama becerisini geliştirir',
    ],
    weeklyFlow: [
      '1. Blok (45 dk): LEGO SPIKE Prime etkinliği',
      '2. Blok (45 dk): Scratch / mBlock / Tinkercad ile kodlama ve tasarım (haftaya göre değişir)',
      '3. Blok (45 dk): Akıl-zekâ oyunları, satranç, Wordwall ve algoritmik etkinlik kitabı çalışmaları',
      '4. Blok (45 dk): İngilizce etkinliği ve mouse-klavye kullanım pratiği',
    ],
    materials: [
      'LEGO SPIKE Prime setleri',
      'Laptoplar — Scratch, mBlock ve Tinkercad uygulamaları için',
      'Wordwall üzerinden dijital pekiştirme oyunları',
      'Algoritmik etkinlik kitapları (mantık ve sıralama çalışmaları için)',
      'Mouse-klavye kullanım pratiği materyalleri',
      'Arduino başlangıç seti: kart, breadboard, jumper kablolar, direnç, LED, buton, LDR (ışık) sensörü',
      'Akıl-zekâ oyun kartları (örüntü, eşleştirme, labirent)',
      'Satranç tahtası ve taşları (büyük boy, çocuklara uygun)',
      'İngilizce kelime kartları, şarkı ve görsel materyaller',
      'Drone tanıtım görselleri/videosu',
    ],
    weeks: [
      RoboAkademiWeek(
        weekNumber: 1,
        theme: 'Tanışma, Bilgisayar ve SPIKE\'a Giriş',
        activities: [
          'Grup tanışma oyunu, kurs kuralları',
          'Bilgisayar donanımı tanıma: ekran, klavye, fare, kasa — \'bilgisayarın parçaları\' oyunu',
          'Mouse-klavye kullanım etkinliği: tıklama, sürükleme, harfleri tanıma',
          'Laptop ile Scratch ekranına ilk bakış: renkli blokları ve kendi karakterini tanıma',
          'SPIKE Prime kutusu tanıtımı: parçalar, hub, motor',
          'Wordwall üzerinden örüntü/eşleştirme oyunu',
          'Algoritmik etkinlik kitabından ilgili sayfaların tamamlanması',
          'İngilizce: renkler ve sayılar (1-10)',
          'Satranç: tahtayı tanıma, kareler',
        ],
        outcomes: [
          'Bilgisayarın temel parçalarını tanır ve isimlendirir',
          'Fare ve klavyeyi temel düzeyde kullanır',
          'Scratch ekranındaki temel öğeleri tanır',
          '10\'a kadar İngilizce sayabilir',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 2,
        theme: 'Yazılım Nedir? ve Scratch\'le İlk Adımlar',
        activities: [
          '\'Yazılım nedir?\' hikâyesi: Defne ve robot arkadaşı Robo\'nun talimat oyunu',
          'Scratch\'te basit blokları birleştirerek karakteri hareket ettirme',
          'SPIKE Prime: ileri-geri hareket blokları',
          'Wordwall eşleştirme oyunu',
          'Algoritmik etkinlik kitabından ilgili sayfaların tamamlanması',
          'Satranç: piyonun hareketi',
          'İngilizce: hayvanlar ve sesleri',
        ],
        outcomes: [
          '\'Yazılım\' kavramını basit bir örnekle ilişkilendirir',
          'Scratch\'te birkaç bloğu birleştirerek karakteri hareket ettirir',
          'Yönergeyi (ileri/geri) eyleme döker',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 3,
        theme: 'Yapay Zekâ: Günlük Hayattaki Yardımcılar',
        activities: [
          'Yapay zekânın sevimli günlük örnekleri: sevdiğimiz şarkıları öneren uygulamalar, hayvan/bitki tanıyan uygulamalar — hikâye ve görsellerle',
          'Scratch\'te karakteri döndüren blokları kullanma',
          'SPIKE Prime: sağa-sola dönüş blokları, mini labirentten çıkış',
          'Wordwall labirent/eşleştirme oyunu',
          'Algoritmik etkinlik kitabından ilgili sayfaların tamamlanması',
          'İngilizce: aile üyeleri',
        ],
        outcomes: [
          'Yapay zekânın günlük hayattaki yardımcı rolünü tanır',
          'Scratch\'te dönüş bloklarını kullanır',
          'Yön kavramlarını (sağ/sol) doğru kullanır',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 4,
        theme: 'Arduino ile İlk Deneme: Işıklı Devre',
        activities: [
          'Arduino kartı, kablo, direnç ve LED\'i meraklı bir kâşif gözüyle tanıma',
          'Öğretmen rehberliğinde adım adım LED\'i yakma denemesi',
          'mBlock yazılımıyla LED\'in yanıp sönmesini kodlama',
          'Aynı devrenin Tinkercad\'de bilgisayar üzerinde canlandırılması',
          'SPIKE Prime: dokunma sensörü ile \'dokun-çalıştır\' mini proje',
          'Algoritmik etkinlik kitabından ilgili sayfaların tamamlanması',
          'Satranç: at ve fil taşlarının hareketi',
        ],
        outcomes: [
          'LED, direnç ve kablo gibi parçaları tanır',
          'Öğretmen rehberliğinde basit bir devreyi keyifle dener',
          'mBlock\'ta basit bir kod bloğunu LED\'e uygular',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 5,
        theme: 'Düğmeli Devre ve Gökyüzündeki Yardımcılar',
        activities: [
          'Bir önceki haftanın Tinkercad çalışmasının kısa bir gözden geçirmesi',
          'Öğretmen rehberliğinde düğme ile LED\'i kontrol etme denemesi, mBlock ile kodlama',
          '\'Drone nedir?\' tanıtımı: kayıp evcil hayvanları bulmaya, çiftçilere yardım etmeye yarayan uçan yardımcı robotlar — görsel anlatım, imkân varsa mini gösterim',
          'Wordwall zekâ oyunları turnuvası',
          'Algoritmik etkinlik kitabından ilgili sayfaların tamamlanması',
          'İngilizce: günlük rutinler',
        ],
        outcomes: [
          'Düğme ile LED arasındaki ilişkiyi keşfeder',
          'Drone\'ların günlük hayatta insanlara nasıl yardımcı olduğunu tanır',
          'Öğrendiklerini kısa bir gösterimle paylaşır',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 6,
        theme: 'Işığı Hisseden Devre (Sensör)',
        activities: [
          'Arduino\'da ışık sensörünü (LDR) tanıma; öğretmen rehberliğinde basit denemesi (karanlıkta LED\'in yanması)',
          'mBlock ve Tinkercad\'de aynı devrenin tekrar edilmesi',
          'SPIKE Prime: ışık/renk sensörü ile renk algılama oyunu',
          'Algoritmik etkinlik kitabından ilgili sayfaların tamamlanması',
          'Satranç: şah kavramı, \'şahı koru\' oyunu',
        ],
        outcomes: [
          'Bir sensörün etrafını \'algıladığı\' fikrini kavrar',
          'İki farklı sistemde benzer bir sensör mantığını ilişkilendirir',
          'Şah taşının önemini kavrar',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 7,
        theme: 'Gerçek Hayat Projesi: Akıllı Lamba',
        activities: [
          'Grup projesi: ışık sensörüyle otomatik yanan \'Akıllı Lamba\' — öğretmen rehberliğinde tamamlama, mBlock ile kodlama',
          'Tinkercad ile proje için küçük bir kapak/aksesuar tasarımı',
          'Scratch\'te projeyi anlatan kısa bir hikâye/animasyon oluşturma',
          'SPIKE Prime: proje temalı küçük görev',
          'Algoritmik etkinlik kitabından ilgili sayfaların tamamlanması',
          'İngilizce: proje kelimeleri (robot, sensor, code, light)',
        ],
        outcomes: [
          'Öğrendiği sensör bilgisini küçük bir projeye uygular',
          'Grupça ortak bir hedefe yönelik işbirliği yapar',
          'Scratch\'te kısa bir hikâye/animasyon oluşturur',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 8,
        theme: 'Final Sergisi ve Kutlama',
        activities: [
          'Final projesinin son prova ve süslemesi',
          'Veli/Sergi günü: projelerin ve Scratch hikâyelerinin sunumu',
          'Wordwall ve satranç mini gösterisi',
          'Ödül ve katılım madalyası töreni',
        ],
        outcomes: [
          'Kendi çalışmasını grup önünde sunar',
          '8 hafta boyunca kazandığı becerileri bütüncül şekilde sergiler',
          'Başarı ve emek duygusunu deneyimler',
        ],
      ),
    ],
  );

  // ============================================================
  // AGE 7-10 — İlkokul Grubu
  // ============================================================
  static const RoboAkademiAgeGroupCurriculum age7to10 = RoboAkademiAgeGroupCurriculum(
    ageGroup: 'age_7_10',
    displayName: '7-10 Yaş · İlkokul Grubu',
    programTitle: 'RoboAkademi Yaz Kursu Müfredatı',
    programSubtitle: '7-10 Yaş Grubu · 8 Haftalık Program',
    programDescription:
        'LEGO SPIKE Prime ile otonom görevler, Scratch\'te değişken/döngü/koşul '
        'yapılarıyla gerçek programlama mantığı, mBlock ve Arduino ile '
        'breadboard üzerinde kurulan gerçek devreler (LED, buton, buzzer, LDR, '
        'ultrasonik mesafe sensörü), Tinkercad\'de devre ve temel 3B tasarım, '
        'satranç taktikleri ve İngilizce teknoloji kelime dağarcığını bir araya '
        'getiren, proje tabanlı bir programdır.',
    generalOutcomes: [
      'Scratch\'te döngü (tekrarla) ve koşul (eğer/değilse) bloklarını doğru senaryolarda kullanır',
      'Bir problemi küçük adımlara bölerek algoritma (akış) olarak ifade eder',
      'SPIKE Prime ile sensör verisine göre karar veren otonom bir görev tasarlar',
      'Direnç, LED, buton, LDR ve ultrasonik sensörün breadboard üzerindeki yerini doğru kurar',
      'mBlock ile kurduğu devreyi kodlayıp gerçek zamanlı test eder',
      'Tinkercad\'de bir devreyi veya basit bir 3B nesneyi tasarlar',
      'Satrançta temel taktikleri (çatal, açık şah, rok) tanır ve uygular',
      'Teknoloji temalı kısa İngilizce metinleri okuyup temel soruları yanıtlar',
      'Bir grup projesinde görev paylaşımı yaparak fikrini sunar',
    ],
    weeklyFlow: [
      '1. Blok (45 dk): LEGO SPIKE Prime — otonom görev ve parkur çalışmaları',
      '2. Blok (45 dk): Scratch (değişken/döngü/koşul) veya mBlock + Arduino devre çalışması (haftaya göre değişir)',
      '3. Blok (45 dk): Tinkercad tasarım, algoritma/akış şeması çalışması ve satranç',
      '4. Blok (45 dk): İngilizce teknoloji okuma-konuşma etkinliği ve proje çalışması',
    ],
    materials: [
      'LEGO SPIKE Prime setleri',
      'Laptoplar — Scratch, mBlock ve Tinkercad uygulamaları için',
      'Arduino seti: kart, breadboard, jumper kablolar, direnç, LED, buton, buzzer, LDR, ultrasonik mesafe sensörü (HC-SR04)',
      'Algoritma/akış şeması çalışma kağıtları',
      'Satranç tahtası ve taşları',
      'İngilizce teknoloji kelime kartları ve kısa okuma metinleri',
      'Wordwall üzerinden pekiştirme oyunları',
    ],
    weeks: [
      RoboAkademiWeek(
        weekNumber: 1,
        theme: 'Kod Mantığına Giriş ve SPIKE ile Tanışma',
        activities: [
          'Grup tanışma oyunu, kurs kuralları ve güvenlik (elektronik malzemelerle çalışma kuralları)',
          'Scratch\'e giriş: hareket, görünüm ve ses blokları ile kısa bir sahne kurma',
          'SPIKE Prime: hub, motor ve sensörlerin tanıtımı, ilk parkur denemesi',
          'Klavye-fare hız ve doğruluk pratiği (yazma/tıklama oyunu)',
          'Satranç: tahta, kareler, taşların başlangıç dizilimi',
          'İngilizce: teknoloji kelimeleri (computer, code, robot, sensor)',
        ],
        outcomes: [
          'Scratch arayüzünde temel blok kategorilerini tanır',
          'SPIKE Prime\'ın temel parçalarını ve motor bağlantısını tanır',
          'Satranç taşlarının başlangıç konumunu bilir',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 2,
        theme: 'Döngüler ve Diziler',
        activities: [
          'Scratch\'te \'tekrarla\' bloğuyla bir hareketi otomatikleştirme (ör. kare çizen karakter)',
          'SPIKE Prime: ileri-geri-dön bloklarıyla belirli bir parkuru döngü kullanarak tamamlama',
          'Algoritma çalışma kağıdı: günlük bir işi (diş fırçalama, sandviç yapma) adım adım yazma',
          'Satranç: piyon ve kale hareketleri',
        ],
        outcomes: [
          'Tekrar eden bir hareketi döngü bloğuyla ifade eder',
          'Bir günlük eylemi sıralı adımlara böler',
          'Kale ve piyonun hareket kurallarını uygular',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 3,
        theme: 'Karar Yapıları: Eğer / Değilse',
        activities: [
          'Scratch\'te \'eğer-değilse\' bloğuyla karaktere basit bir karar aldırma (ör. kenara değerse dön)',
          'SPIKE Prime: çizgi izleyen sensör ile basit bir çizgi takip denemesi',
          'Algoritma çalışma kağıdı: \'eğer yağmur yağıyorsa şemsiye al\' türünden karar senaryoları',
          'Satranç: at ve filin hareketleri',
          'İngilizce: sayılar 1-100, basit ölçüm ifadeleri',
        ],
        outcomes: [
          'Bir senaryoda \'eğer-değilse\' mantığını kurar',
          'Sensör verisine göre robotun farklı tepki verebileceğini kavrar',
          'At ve fil taşlarının hareket kurallarını uygular',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 4,
        theme: 'Arduino\'ya Giriş: LED Devresi',
        activities: [
          'Breadboard\'un yapısı ve devre kurma güvenliği',
          'Direnç-LED-kablo bağlantısıyla ilk devrenin kurulması',
          'mBlock ile LED\'i yakıp söndürme, yanıp sönme hızını kodla değiştirme',
          'Tinkercad\'de aynı devrenin bilgisayar ortamında tekrarı',
          'Satranç: kısa bir mat senaryosu (şah-mat kavramı)',
        ],
        outcomes: [
          'Breadboard üzerinde basit bir LED devresi kurar',
          'mBlock kodunu değiştirerek devrenin davranışını kontrol eder',
          'Şah-mat kavramını tanır',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 5,
        theme: 'Buton ve Buzzer ile Etkileşimli Devre',
        activities: [
          'Butonun devreye eklenmesi: basınca LED yanan/buzzer çalan bir sistem kurma',
          'mBlock ile buton durumuna göre karar veren kod yazma (dijital giriş okuma)',
          'SPIKE Prime: dokunma sensörüyle \'dokun-çalıştır\' mini oyun tasarımı',
          'İngilizce: günlük rutin cümleleri (I press, it turns on...)',
        ],
        outcomes: [
          'Butonu bir devreye doğru şekilde ekler',
          'Dijital girişe göre çıkışı değiştiren bir kod yazar',
          'Basit İngilizce cümlelerle devrenin çalışmasını anlatır',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 6,
        theme: 'Sensörler: Işık ve Mesafe',
        activities: [
          'LDR (ışık) sensörü ile karanlıkta otomatik yanan LED devresi',
          'Ultrasonik mesafe sensörünün (HC-SR04) tanıtımı ve basit bir mesafe ölçüm denemesi',
          'mBlock ile iki sensörden birini seçip devreyi kodlama',
          'SPIKE Prime: renk sensörüyle nesneleri sıralama oyunu',
          'Satranç: rok (castling) kuralı',
        ],
        outcomes: [
          'Analog bir sensörün (LDR) çalışma mantığını açıklar',
          'Ultrasonik sensörün mesafe ölçme fikrini kavrar',
          'Rok kuralını doğru uygular',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 7,
        theme: 'Grup Projesi: Akıllı Park Sensörü / Gece Lambası',
        activities: [
          'Grup halinde proje seçimi: ultrasonik sensörlü \'akıllı park sensörü\' ya da LDR\'li \'gece lambası\'',
          'Tinkercad\'de projenin devre tasarımının tamamlanması',
          'mBlock ile projenin kodlanması ve test edilmesi',
          'Scratch\'te projeyi tanıtan kısa bir sunum animasyonu hazırlama',
        ],
        outcomes: [
          'Öğrendiği sensör bilgisini bir projeye uygular',
          'Grup içinde görev paylaşarak ortak bir hedefe ulaşır',
          'Projesini kısa bir dijital sunumla anlatır',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 8,
        theme: 'Final Sergisi ve Kutlama',
        activities: [
          'Projelerin son testleri ve provası',
          'Veli/Sergi günü: proje ve Scratch sunumlarının izleyici önünde anlatılması',
          'Satranç mini turnuvası ve Wordwall yarışması',
          'Ödül ve katılım sertifikası töreni',
        ],
        outcomes: [
          'Projesini bir izleyici kitlesine güvenle sunar',
          '8 hafta boyunca kazandığı becerileri bütüncül şekilde sergiler',
          'Takım çalışmasının ve emeğin değerini deneyimler',
        ],
      ),
    ],
  );

  // ============================================================
  // AGE 11-14 — Ortaokul Grubu
  // ============================================================
  static const RoboAkademiAgeGroupCurriculum age11to14 = RoboAkademiAgeGroupCurriculum(
    ageGroup: 'age_11_14',
    displayName: '11-14 Yaş · Ortaokul Grubu',
    programTitle: 'RoboAkademi Yaz Kursu Müfredatı',
    programSubtitle: '11-14 Yaş Grubu · 8 Haftalık Program',
    programDescription:
        'Blok tabanlı kodlamadan gerçek metin tabanlı kodlamaya (Arduino IDE, '
        'C/C++ temelli) geçişi hedefleyen; SPIKE Prime ile daha karmaşık otonom '
        'görevler, breadboard üzerinde analog sensör okuma, servo motor '
        'kontrolü ve ultrasonik sensörle otomasyon projeleri kuran; satrançta '
        'orta seviye taktikleri ve teknik İngilizce okuma becerisini '
        'geliştiren, proje ve dokümantasyon odaklı bir programdır.',
    generalOutcomes: [
      'Değişken, döngü, koşul ve fonksiyon kavramlarını metin tabanlı kodda (Arduino C/C++) kullanır',
      'pinMode, digitalWrite/digitalRead ve analogRead/analogWrite komutlarını doğru bağlamda kullanır',
      'Bir problemi akış şemasıyla planlayıp kodunu buna göre yapılandırır',
      'Servo motor ve ultrasonik sensör içeren bir devreyi kurup kodlar',
      'SPIKE Prime ile sensör verisine dayalı, çok adımlı otonom bir görev tasarlar',
      'Kendi kodunu satır satır açıklayan kısa bir teknik dokümantasyon yazar',
      'Satrançta orta oyun taktiklerini (çatal, şiş, keşif şahı) tanır ve uygular',
      'Teknoloji temalı İngilizce metinleri okuyup özetler',
      'Bir mühendislik projesini planlama, kurma ve sunma sürecinin tamamını deneyimler',
    ],
    weeklyFlow: [
      '1. Blok (45 dk): LEGO SPIKE Prime — çok adımlı otonom görev tasarımı',
      '2. Blok (45 dk): Arduino IDE ile metin tabanlı kodlama ve devre kurulumu',
      '3. Blok (45 dk): Tinkercad simülasyon, akış şeması / kod dokümantasyonu ve satranç',
      '4. Blok (45 dk): İngilizce teknik okuma ve proje geliştirme çalışması',
    ],
    materials: [
      'LEGO SPIKE Prime setleri',
      'Laptoplar — Arduino IDE, Tinkercad ve Scratch/mBlock (köprü dersleri için)',
      'Arduino seti: kart, breadboard, jumper kablolar, direnç, LED, buton, buzzer, LDR, potansiyometre, servo motor, ultrasonik mesafe sensörü (HC-SR04)',
      'Akış şeması ve kod dokümantasyonu çalışma kağıtları',
      'Satranç tahtası ve taşları',
      'Teknoloji temalı İngilizce okuma metinleri',
    ],
    weeks: [
      RoboAkademiWeek(
        weekNumber: 1,
        theme: 'Blok Kodlamadan Metin Kodlamaya Köprü',
        activities: [
          'Grup tanışma oyunu, kurs kuralları ve elektronik güvenliği',
          'Scratch\'teki bir bloğun (\'eğer-değilse\', \'tekrarla\') Arduino C/C++ karşılığını tartışma — köprü etkinliği',
          'SPIKE Prime: hub/motor/sensörlerle daha karmaşık bir görev tasarımı',
          'Satranç: açılış prensipleri (merkezi kontrol, taş geliştirme)',
          'İngilizce: kısa bir teknoloji haberi okuma',
        ],
        outcomes: [
          'Blok tabanlı bir yapının metin koddaki karşılığını tahmin eder',
          'Satrançta temel açılış prensiplerini açıklar',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 2,
        theme: 'Değişkenler, Döngüler ve Akış Şeması',
        activities: [
          'Akış şeması ile bir problemi (ör. \'3 kere yanıp sönen LED\') planlama',
          'Arduino IDE\'ye giriş: setup()/loop() yapısı, değişken tanımlama',
          'for döngüsüyle LED\'i belirli sayıda yakıp söndürme kodu yazma',
          'SPIKE Prime: otonom görevde döngü mantığının kullanımı',
        ],
        outcomes: [
          'Bir problemi akış şemasıyla planlar',
          'setup()/loop() yapısını ve basit bir for döngüsünü doğru yazar',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 3,
        theme: 'Arduino IDE ile İlk Devre: pinMode ve digitalWrite',
        activities: [
          'Breadboard üzerinde LED ve direnç bağlantısı',
          'pinMode(), digitalWrite() komutlarıyla LED\'i kod satırlarıyla kontrol etme',
          'Buton ekleyip digitalRead() ile giriş okuma',
          'Satranç: orta oyun taktikleri — çatal',
        ],
        outcomes: [
          'pinMode ve digitalWrite/digitalRead komutlarını doğru kullanır',
          'Satrançta çatal taktiğini tanır',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 4,
        theme: 'Analog Okuma: LDR ve Potansiyometre',
        activities: [
          'analogRead() ile LDR ve potansiyometre değerlerini okuma',
          'Okunan analog değere göre LED parlaklığını analogWrite() ile ayarlama',
          'Tinkercad\'de aynı devrenin simülasyonu ve kod testi',
          'İngilizce: analog/digital kavramlarını açıklayan kısa metin',
        ],
        outcomes: [
          'analogRead ve analogWrite komutlarını doğru bağlamda kullanır',
          'Analog ile dijital sinyal arasındaki farkı açıklar',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 5,
        theme: 'Servo Motor ile Hareket Kontrolü',
        activities: [
          'Servo kütüphanesi (Servo.h) ile bir servo motorun açısını koddan kontrol etme',
          'Basit bir pan-tilt (döner) mekanizması kurma denemesi',
          'SPIKE Prime: motor gücü ve açısını sensör verisine göre ayarlayan görev',
          'Satranç: orta oyun taktikleri — şiş',
        ],
        outcomes: [
          'Servo motoru koddan kontrol eder',
          'Satrançta şiş taktiğini tanır',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 6,
        theme: 'Ultrasonik Sensör ile Otomasyon',
        activities: [
          'HC-SR04 ultrasonik sensörle mesafe ölçme kodu yazma',
          'Ölçülen mesafeye göre karar veren bir sistem kurma (ör. yakınlaşınca LED/buzzer tetiklenmesi)',
          'Kodun her satırını açıklayan kısa bir dokümantasyon yazma pratiği',
          'İngilizce: sensör/otomasyon temalı teknik kelimeler',
        ],
        outcomes: [
          'Ultrasonik sensörle mesafeye dayalı bir karar mekanizması kurar',
          'Yazdığı kodu satır satır açıklayan bir not oluşturur',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 7,
        theme: 'Grup Projesi: Engel Algılayan Sistem / Akıllı Ev Modülü',
        activities: [
          'Grup halinde proje seçimi: ultrasonik sensörlü \'engel algılayan sistem\' ya da LDR+servo\'lu \'akıllı ev modülü\' (ör. otomatik perde/kapı)',
          'Devrenin Tinkercad\'de tasarlanıp Arduino IDE\'de kodlanması',
          'Projenin kod dokümantasyonunun tamamlanması',
          'Satranç: öğrenilen taktiklerin uygulandığı mini maçlar',
        ],
        outcomes: [
          'Birden fazla sensör/aktüatörü tek bir projede entegre eder',
          'Projesinin kodunu ve mantığını yazılı olarak dokümante eder',
        ],
      ),
      RoboAkademiWeek(
        weekNumber: 8,
        theme: 'Final Sergisi ve Kutlama',
        activities: [
          'Projelerin son testleri ve provası',
          'Veli/Sergi günü: proje demosu ve kod anlatımı',
          'Satranç turnuvasının finali',
          'Ödül ve katılım sertifikası töreni',
        ],
        outcomes: [
          'Teknik bir projeyi izleyici önünde sunar ve sorulara yanıt verir',
          '8 hafta boyunca kazandığı mühendislik ve kodlama becerilerini bütüncül şekilde sergiler',
        ],
      ),
    ],
  );

  static const List<RoboAkademiAgeGroupCurriculum> allAgeGroups = [age4to6, age7to10, age11to14];

  /// Returns the curriculum track for the given `workshop_students.age_group`
  /// value, falling back to the 4-6 track (the default) for unknown values.
  static RoboAkademiAgeGroupCurriculum forAgeGroup(String? ageGroup) {
    return allAgeGroups.firstWhere(
      (c) => c.ageGroup == ageGroup,
      orElse: () => age4to6,
    );
  }

  // Backwards-compatible shortcuts (default to the 4-6 track).
  static String get programTitle => age4to6.programTitle;
  static String get programSubtitle => age4to6.programSubtitle;
  static String get programDescription => age4to6.programDescription;
  static List<String> get generalOutcomes => age4to6.generalOutcomes;
  static List<String> get weeklyFlow => age4to6.weeklyFlow;
  static List<String> get materials => age4to6.materials;
  static List<RoboAkademiWeek> get weeks => age4to6.weeks;

  static RoboAkademiWeek? weekByNumber(int number) => age4to6.weekByNumber(number);
}
