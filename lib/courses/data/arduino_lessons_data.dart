import 'package:flutter/material.dart';
import '../models/interactive_lesson_model.dart';

/// Arduino Course - Interactive lessons for electronics and mBlock programming
/// Icerik, Kodluyoruz Dernegi'nin "mBlock ile Arduino Uygulamalari El Kitapcigi"
/// müfredatindan uyarlanmistir: LED yakma, trafik isigi, potansiyometre, buzzer,
/// LDR gece lambasi, mesafe olcer, park sensoru, LCD ekran, yagmur sensörlü
/// cam sileceği. Kod RAW C/C++ (pinMode, digitalWrite vb.) DEGIL, mBlock'un
/// gercek blok isimleriyle ogretilir:
///  - "_ sayisal pini YUKSEK/DUSUK yap"   (dijital cikis)
///  - "_ sayisal pini oku"                (dijital giris, 0=basili / 1=birakili)
///  - "_ analog pini oku"                 (0-1023 arasi analog deger)
///  - "_ pwm pini _ yap"                  (0-255 arasi PWM cikis)
///  - "_ ses tonu pini _ notasinda _ vurus cal" (buzzer, C4/D4... + Tam/Yarim vurus)
///  - "Arduino Programi" / "_ tiklandiginda" (baslangic bloklari)
class ArduinoLessonsData {
  // ==========================================
  // MODULE 1: ARDUINO'YA GİRİŞ VE LED
  // ==========================================
  static final List<InteractiveLesson> module1 = [
    // LESSON 1.1: Arduino, mBlock ve Devre Elemanlari
    InteractiveLesson(
      id: 'arduino_1_1',
      courseId: 'arduino',
      title: 'Arduino\'ya Hos Geldin!',
      subtitle: 'mBlock ile blok blok kodlama',
      order: 1,
      xpReward: 50,
      badge: 'arduino_starter',
      steps: [
        IntroStep(
          id: 'a1_1_intro',
          mascotEmoji: '🤖',
          mascotMessage: 'Merhaba! Arduino ile gercek dunyayi kontrol edecegiz - LED yakacak, buzzer calacak, sensor okuyacagiz! Hem de hic kod YAZMADAN, sadece bloklari surukleyerek!',
          highlights: [
            'Fiziksel devre kur',
            'Bloklari surukle-birak',
            'LED, buton, sensor, buzzer',
          ],
        ),

        ExplanationStep(
          id: 'a1_1_exp1',
          title: 'Arduino ve mBlock Nedir?',
          content: 'Arduino, elektronik projeleri kolayca yapabilmeni saglayan kucuk bir bilgisayar (mikrodenetleyici) karttir.\n\nmBlock ise, Arduino\'yu Scratch\'takine COK benzer, renkli bloklari surukleyerek programlamani saglayan programdir. Yani C++ kodu (pinMode, digitalWrite gibi satirlar) YAZMIYORUZ - hazir bloklari birbirine baglayip Arduino kartina yukluyoruz!',
          tipEmoji: '🧩',
          tip: 'Scratch bildiginiz her sey burada da gecerli - sadece bloklar artik gercek LED, buton ve sensorleri kontrol ediyor!',
        ),

        ExplanationStep(
          id: 'a1_1_exp2',
          title: 'LED ve Direnc Neden Birlikte Kullanilir?',
          content: 'LED (Light Emitting Diode), isik yayan bir devre elemanidir. Iki bacagi vardir:\n\nUzun bacak (+) -> Arduino\'nun dijital pinine\nKisa bacak (-) -> GND (toprak) pinine\n\nOnemli bir nokta: Arduino pinleri 5V gonderir ama LED\'ler 3V ile calisir! Aradaki 2V\'lik farki dengelemek icin LED ile GND arasina bir DIRENC (220 ohm) baglariz - yoksa LED yanabilir!',
          tipEmoji: '⚡',
          tip: 'Direnc, LED\'i fazla akimdan koruyan bir "sigortadir" diye dusunebilirsin!',
        ),

        MultipleChoiceStep(
          id: 'a1_1_q1',
          question: 'LED ile devreye direnc eklememizin sebebi nedir?',
          options: [
            ChoiceOption(text: 'Arduino\'nun 5V\'unu LED\'in calistigi 3V seviyesine dengelemek', emoji: '✅'),
            ChoiceOption(text: 'LED\'i daha parlak yakmak', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sebebi yok, sadece gorunum icin', emoji: '❌'),
            ChoiceOption(text: 'Arduino\'yu yavaslatmak icin', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Arduino 5V gonderir ama LED 3V ister - direnc araidaki fazla enerjiyi dengeleyerek LED\'i korur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a1_1_exp3',
          title: 'Her mBlock Projesi Nasil Baslar?',
          content: 'mBlock\'ta bir projeye baslamanin iki yolu vardir:\n\n🟩 "_ tıklandığında" (Olaylar sekmesi) - bilgisayara bagliyken test etmek icin\n🔧 "Arduino Programı" (Robotlar sekmesi) - Arduino\'ya kalici olarak yuklemek icin\n\nHer ikisinin de altina "surekli tekrarla" blogu koyarak icindeki bloklarin hic durmadan tekrarlanmasini sagliyoruz.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'tıklandığında',
              color: Color(0xFFFFBF00),
              label: 'Baslatici Blok (Olaylar)',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'sürekli tekrarla',
              color: Color(0xFFFFAB19),
              label: 'Kontrol Blogu',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'a1_1_q2',
          question: 'Arduino\'ya kalici olarak kod yuklerken hangi baslangic blogu kullanilir?',
          options: [
            ChoiceOption(text: '"Arduino Programı" blogu', emoji: '✅'),
            ChoiceOption(text: 'Hicbir blok gerekmez', emoji: '❌'),
            ChoiceOption(text: 'Sadece "sürekli tekrarla"', emoji: '❌'),
            ChoiceOption(text: '"bekle" blogu', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '"Arduino Programı" blogu, Robotlar sekmesinde bulunur ve kalici yukleme icin kullanilir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a1_1_summary',
          title: 'Arduino Baslangic!',
          content: '🤖 Arduino ve mBlock dunyasina hosgeldin!\n\n✓ Arduino ve mBlock\'un ne oldugunu ogrendin\n✓ LED + direnc mantigini kavradin\n✓ "tıklandığında" ve "Arduino Programı" bloklarini tandin\n\nSonraki ders: Ilk LED projeni yapacagiz!',
          tipEmoji: '🏆',
          tip: 'Arduino Baslangic rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.2: Ilk LED Projesi (Blink)
    InteractiveLesson(
      id: 'arduino_1_2',
      courseId: 'arduino',
      title: 'Ilk LED Projesi',
      subtitle: 'mBlock bloklariyla LED yak, sondur!',
      order: 2,
      xpReward: 60,
      badge: 'led_master',
      steps: [
        IntroStep(
          id: 'a1_2_intro',
          mascotEmoji: '💡',
          mascotMessage: 'Simdiye kadar sadece konustuk. Simdi gercek bir LED\'i mBlock bloklariyla yakip sondurecegiz!',
        ),

        ExplanationStep(
          id: 'a1_2_exp1',
          title: 'Dijital Cikis Bloklari',
          content: 'mBlock\'ta Robotlar sekmesinde bir pini acmak/kapamak icin hazir bloklar vardir:\n\n"9 sayısal pini YÜKSEK yap" -> o pindeki LED\'i yakar\n"9 sayısal pini DÜŞÜK yap" -> o pindeki LED\'i sondurur\n\nBuradaki "9", LED\'i taktigimiz dijital pin numarasidir.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '9 sayısal pini YÜKSEK yap',
              color: Color(0xFF00979D),
              label: 'Robotlar - Dijital Cikis',
            ),
          ],
          tipEmoji: '📌',
          tip: 'YUKSEK = pin acik (5V), DUSUK = pin kapali (0V)',
        ),

        MultipleChoiceStep(
          id: 'a1_2_q1',
          question: 'Pin 9\'daki LED\'i yakmak icin hangi blogu kullaniriz?',
          options: [
            ChoiceOption(text: '"9 sayısal pini YÜKSEK yap"', emoji: '✅'),
            ChoiceOption(text: '"9 sayısal pini oku"', emoji: '❌'),
            ChoiceOption(text: '"sürekli tekrarla"', emoji: '❌'),
            ChoiceOption(text: '"9 analog pini oku"', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '"9 sayısal pini YÜKSEK yap" blogu, o pine bagli LED\'i yakar!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a1_2_exp2',
          title: '"Bekle" Blogu',
          content: 'LED\'in yanik kalma suresini ayarlamak icin Kontrol sekmesindeki "bekle" blogu kullanilir:\n\n"1 saniye bekle"\n\nBu blok olmadan LED o kadar hizli acilip kapanir ki goz bunu fark edemez!',
          tipEmoji: '⏱️',
          tip: '"bekle" blogunu Kontrol sekmesinde bulabilirsin!',
        ),

        ExplanationStep(
          id: 'a1_2_exp3',
          title: 'Yanip Sonen LED\'in Blok Sirasi',
          content: 'LED\'i surekli yanip sondurmek icin bloklari su sirayla dizeriz:\n\n🟩 tıklandığında\n🔁 sürekli tekrarla\n  💡 9 sayısal pini YÜKSEK yap\n  ⏱️ 1 saniye bekle\n  💡 9 sayısal pini DÜŞÜK yap\n  ⏱️ 1 saniye bekle\n\nBu dongu sonsuza kadar tekrar eder - LED surekli yanip soner!',
        ),

        MultipleChoiceStep(
          id: 'a1_2_q2',
          question: 'LED surekli yanip sonsun istiyoruz. Hangi blogun icine LED bloklarini koymaliyiz?',
          options: [
            ChoiceOption(text: '"sürekli tekrarla" blogunun icine', emoji: '✅'),
            ChoiceOption(text: '"tıklandığında" blogunun disina', emoji: '❌'),
            ChoiceOption(text: 'Hicbir seyin icine, tek basina yeter', emoji: '❌'),
            ChoiceOption(text: '"bekle" blogunun icine', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '"sürekli tekrarla" blogu olmadan LED sadece BIR KEZ yanip soner ve durur!',
          xpReward: 15,
        ),

        BlockBuilderStep(
          id: 'a1_2_build1',
          instruction: 'LED\'i surekli yanip sonduren mBlock kodunu olustur!',
          goal: 'Pin 9\'daki LED 1\'er saniye arayla yanip sonsun',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'sürekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'led_high',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '9 sayısal pini YÜKSEK yap',
              color: Color(0xFF00979D),
            ),
            ScratchBlock(
              id: 'wait_1',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.stack,
              label: '1 saniye bekle',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'led_low',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '9 sayısal pini DÜŞÜK yap',
              color: Color(0xFF00979D),
            ),
          ],
          correctSequence: ['green_flag', 'forever', 'led_high', 'wait_1', 'led_low', 'wait_1'],
          xpReward: 30,
        ),

        ExplanationStep(
          id: 'a1_2_summary',
          title: 'LED Ustasi!',
          content: '💡 Ilk Arduino projeni mBlock ile tamamladin!\n\n✓ Dijital cikis bloklarini kullandin\n✓ "bekle" blogu ile zamanlama yaptın\n✓ "sürekli tekrarla" ile donguyu kurdun\n\nArtik gercek bir LED\'i blok blok kontrol edebilirsin!',
          tipEmoji: '🏆',
          tip: 'LED Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 2: BUTON ILE KONTROL
  // ==========================================
  static final List<InteractiveLesson> module2 = [
    // LESSON 2.1: Buton Okuma ve Sayac
    InteractiveLesson(
      id: 'arduino_2_1',
      courseId: 'arduino',
      title: 'Buton ile LED Yakma',
      subtitle: 'Basisi say, LED\'i kontrol et!',
      order: 3,
      xpReward: 70,
      badge: 'button_reader',
      steps: [
        IntroStep(
          id: 'a2_1_intro',
          mascotEmoji: '🔘',
          mascotMessage: 'Simdi Arduino\'dan veri okuyacagiz! Butona her bastigimizda bunu sayacagiz.',
        ),

        ExplanationStep(
          id: 'a2_1_exp1',
          title: 'Buton Okuma Blogu ve 0/1 Mantigi',
          content: 'mBlock\'ta bir pindeki degeri okumak icin bir REPORTER blok kullanilir:\n\n"6 sayısal pini oku"\n\nÖnemli: Butonumuz basiliyken 0, birakilmisken 1 degerini verir! Bu, Scratch\'taki true/false\'un tersi gibi dusunulebilir - Arduino\'da butonun "basili" durumu genelde 0 (DÜŞÜK) olarak okunur.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '6 sayısal pini oku',
              color: Color(0xFF5CB1D6),
              label: 'Robotlar - Algilama',
            ),
          ],
          tipEmoji: '📖',
          tip: 'Butona basili iken 0, birakinca 1 okunur - bunu ezberle, cok onemli!',
        ),

        MultipleChoiceStep(
          id: 'a2_1_q1',
          question: '"6 sayısal pini oku" blogu buton BASILI iken hangi degeri verir?',
          options: [
            ChoiceOption(text: '0', emoji: '✅'),
            ChoiceOption(text: '1', emoji: '❌'),
            ChoiceOption(text: '1023', emoji: '❌'),
            ChoiceOption(text: '255', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Bu devrede buton basili iken pin 0 (DÜŞÜK), birakili iken 1 (YÜKSEK) okunur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a2_1_exp2',
          title: 'Sayac Degiskeni Olustur',
          content: 'Butona kac kez basildigini saymak icin bir DEGISKEN kullaniriz:\n\n1. "Veri&Blok" sekmesinde "Bir Değişken Oluştur" -> "sayaç" adinda bir degisken olustur\n2. "sayaç 0 olsun" ile baslangicta sifirla\n3. Butona her basista "sayaç\'ı 1 arttır" ile bir arttir',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'sayaç 0 olsun',
              color: Color(0xFFFF8C1A),
              label: 'Veri & Blok',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'a2_1_q2',
          question: '"sayaç\'ı 1 arttır" blogu ne yapar?',
          options: [
            ChoiceOption(text: 'sayaç degiskeninin degerini 1 artirir', emoji: '✅'),
            ChoiceOption(text: 'sayaç degiskenini siler', emoji: '❌'),
            ChoiceOption(text: 'sayaç degiskenini 1 yapar (sifirlamaz, hep 1 yapar)', emoji: '❌'),
            ChoiceOption(text: 'LED\'i yakar', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '"arttır" bloklari mevcut degere EKLEME yapar - "1 arttır" her seferinde degeri 1 fazlasi yapar!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a2_1_exp3',
          title: '"Olana Kadar Bekle" Blogu',
          content: 'Butona basilip birakilmasini dogru saymak icin ozel bir blok kullanilir:\n\n"eğer <6 sayısal pini oku> = 0 ise\n  sayaç\'ı 1 arttır\n  <6 sayısal pini oku> = 1 olana kadar bekle"\n\n"olana kadar bekle" blogu, kosul dogru olana kadar (yani buton birakilana kadar) bir sonraki adima GECMEZ. Bu, ayni basisin birden fazla kez sayilmasini engeller!',
          tipEmoji: '⏳',
          tip: 'Bu blok olmadan tek bir basis, Arduino cok hizli calistigi icin onlarca kez sayilabilir!',
        ),

        MultipleChoiceStep(
          id: 'a2_1_q3',
          question: '"<6 sayısal pini oku> = 1 olana kadar bekle" blogu ne zaman devam eder?',
          options: [
            ChoiceOption(text: 'Buton birakilip pin tekrar 1 oldugunda', emoji: '✅'),
            ChoiceOption(text: 'Hemen, beklemeden', emoji: '❌'),
            ChoiceOption(text: '1 saniye sonra, kosula bakmadan', emoji: '❌'),
            ChoiceOption(text: 'Asla devam etmez', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '"olana kadar bekle" blogu, tam olarak belirtilen kosul dogru olana kadar (burada buton birakilana kadar) kodun bir sonraki satirina gecmez!',
          xpReward: 15,
        ),

        BlockBuilderStep(
          id: 'a2_1_build1',
          instruction: 'Butona her basildiginda sayaci 1 artiran kodu olustur!',
          goal: 'Pin 6\'daki butona basilinca sayac artsin, tekrar basilana kadar beklensin',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'set_counter',
              blockType: ScratchBlockType.variables,
              shape: ScratchBlockShape.stack,
              label: 'sayaç 0 olsun',
              color: Color(0xFFFF8C1A),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'sürekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'if_pressed',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'eğer <6 sayısal pini oku = 0> ise',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'increment',
              blockType: ScratchBlockType.variables,
              shape: ScratchBlockShape.stack,
              label: 'sayaç\'ı 1 arttır',
              color: Color(0xFFFF8C1A),
            ),
            ScratchBlock(
              id: 'wait_until',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.stack,
              label: '<6 sayısal pini oku = 1> olana kadar bekle',
              color: Color(0xFFFFAB19),
            ),
          ],
          correctSequence: ['green_flag', 'set_counter', 'forever', 'if_pressed', 'increment', 'wait_until'],
          xpReward: 35,
        ),

        ExplanationStep(
          id: 'a2_1_summary',
          title: 'Buton Okuyucu!',
          content: '🔘 Artik girdi okuyabilirsin!\n\n✓ "sayısal pini oku" ile buton okudun\n✓ Degisken ile sayma yaptin\n✓ "olana kadar bekle" ile dogru sayim sagladin\n\nSonraki: LED\'i acar-kapar bir dugme yapacagiz!',
          tipEmoji: '🏆',
          tip: 'Buton Okuyucu rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 2.2: Buton ile Led Ac/Kapa (Degisken ile Toggle)
    InteractiveLesson(
      id: 'arduino_2_2',
      courseId: 'arduino',
      title: 'Buton ile LED Ac/Kapa',
      subtitle: 'Degisken kullanarak dugme gibi calistir!',
      order: 9,
      xpReward: 70,
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'a2_2_intro',
          mascotEmoji: '🔀',
          mascotMessage: 'Onceki derste sayiyorduk. Simdi gercek bir dugme gibi calistiralim: bir bas LED yansin, bir daha bas sonsun!',
          highlights: [
            'Ikinci bir degisken olustur',
            'true/false ile durum takibi',
            'Gercek bir ac/kapa dugmesi',
          ],
        ),

        ExplanationStep(
          id: 'a2_2_exp1',
          title: 'Neden Ikinci Bir Degiskene Ihtiyacimiz Var?',
          content: 'Onceki projede sadece basis SAYIYORDUK. Ama biz "bir kere bas, LED\'i AÇIK birak; bir daha bas, KAPALI birak" istiyoruz.\n\nBunun icin LED\'in ŞU ANKI durumunu HATIRLAMAMIZ gerekir - iste bunun icin "açık" adinda YENI bir degisken olustururuz!',
          tipEmoji: '🧠',
          tip: 'Degisken, Arduino\'nun bir bilgiyi hatirlamasini saglayan bir "kutu" gibidir!',
        ),

        ExplanationStep(
          id: 'a2_2_exp2',
          title: '"açık" Degiskenini Olustur',
          content: '"Veri&Blok" sekmesinde "Bir Değişken Oluştur" ile "açık" adinda yeni bir degisken olustururuz.\n\nBu degisken LED\'in su an acik mi kapali mi oldugunu (1 veya 0) tutar. Bu, gercek kitapciktaki mBlock projesinin son (en gelismis) adimidir!',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'açık değişkenini oluştur',
              color: Color(0xFFFF8C1A),
              label: 'Veri & Blok',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'a2_2_q1',
          question: '"açık" degiskeni ne icin kullanilir?',
          options: [
            ChoiceOption(text: 'LED\'in su anki durumunu (acik/kapali) hatirlamak icin', emoji: '✅'),
            ChoiceOption(text: 'LED\'in rengini degistirmek icin', emoji: '❌'),
            ChoiceOption(text: 'Butonu silmek icin', emoji: '❌'),
            ChoiceOption(text: 'Arduino\'yu yeniden baslatmak icin', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Degisken, bir bilgiyi (burada LED\'in acik/kapali durumunu) hatirlamamizi saglar!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a2_2_exp3',
          title: 'Basisi Algilama ve Durumu Ters Cevirme',
          content: 'Her butona basista "açık" degiskeninin degerini TERSINE ceviririz:\n\neğer <6 sayısal pini oku = 0> ise\n  eğer <açık = 0> ise\n    açık\'ı 1 yap\n    9 sayısal pini YÜKSEK yap\n  değilse\n    açık\'ı 0 yap\n    9 sayısal pini DÜŞÜK yap\n  <6 sayısal pini oku = 1> olana kadar bekle\n\nSondaki "olana kadar bekle" cok onemli - yoksa tek basis onlarca kez algilanir!',
          tipEmoji: '⏱️',
          tip: '"olana kadar bekle" olmadan, parmagin butondan cok kisa sure once cekilse bile LED onlarca kez acilip kapanabilir!',
        ),

        MultipleChoiceStep(
          id: 'a2_2_q2',
          question: 'Basisi algiladiktan sonra "<6 sayısal pini oku = 1> olana kadar bekle" blogunu koymamizin sebebi nedir?',
          options: [
            ChoiceOption(text: 'Tek bir basisin yanlislikla defalarca sayilmasini onlemek', emoji: '✅'),
            ChoiceOption(text: 'LED\'i daha parlak yakmak icin', emoji: '❌'),
            ChoiceOption(text: 'Buzzer\'i durdurmak icin', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sebebi yok', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Bu blok olmadan, cok hizli calisan Arduino tek bir basisi onlarca kez algilayabilir!',
          xpReward: 15,
        ),

        DragDropStep(
          id: 'a2_2_dd1',
          instruction: 'Blogu dogru aciklamasina surukle!',
          items: [
            DraggableItem(id: 'd1', content: 'Bir Değişken Oluştur'),
            DraggableItem(id: 'd2', content: 'eğer...ise...değilse'),
            DraggableItem(id: 'd3', content: '...olana kadar bekle'),
          ],
          dropZones: [
            DropZone(id: 'z1', label: 'Bilgiyi hatirlamak icin', hint: 'LED durumu gibi'),
            DropZone(id: 'z2', label: 'Karar vermek icin', hint: 'Kosula gore dallanma'),
            DropZone(id: 'z3', label: 'Ayni basisin tekrar sayilmasini onlemek icin', hint: 'Kosul saglanana kadar durur'),
          ],
          correctMapping: {
            'd1': 'z1',
            'd2': 'z2',
            'd3': 'z3',
          },
          successMessage: 'Degisken, kontrol ve bekle bloklarinin gorevini tam kavradin!',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'a2_2_summary',
          title: 'Proje Tamam!',
          content: '🔀 Buton ile LED Ac/Kapa projesini tamamladin!\n\n✓ Ikinci bir degisken olusturup kullandin\n✓ "eger...ise...degilse" ile durum kontrolu yaptin\n✓ "olana kadar bekle" ile dogru sayim sagladin\n\nSonraki modul: Birden fazla LED ile Trafik Isigi!',
          tipEmoji: '🏆',
          tip: 'Asansor dugmeleri ve lamba anahtarlari da ayni mantikla calisir!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 3: TRAFIK IŞIĞI VE ANALOG GİRİŞ
  // ==========================================
  static final List<InteractiveLesson> module3 = [
    // LESSON 3.1: Trafik Isigi Yapimi
    InteractiveLesson(
      id: 'arduino_3_1',
      courseId: 'arduino',
      title: 'Trafik Isigi Yapimi',
      subtitle: '3 LED ile gercek trafik isigi',
      order: 4,
      xpReward: 80,
      badge: 'traffic_light_master',
      steps: [
        IntroStep(
          id: 'a3_1_intro',
          mascotEmoji: '🚦',
          mascotMessage: 'Gunluk hayatta gordugumuz trafik isiklarinin nasil calistigini simdi kendi ellerinle kuracaksin! Kirmizi, sari ve yesil - uc LED birden!',
        ),

        ExplanationStep(
          id: 'a3_1_exp1',
          title: 'Birden Fazla LED Kontrolu',
          content: 'Trafik isigi icin 3 farkli LED kullaniriz, her biri ayri bir dijital pine bagli:\n\nKirmizi LED -> Pin 9\nSari LED -> Pin 10\nYesil LED -> Pin 11\n\nHer birini ayri ayri "sayısal pini YÜKSEK/DÜŞÜK yap" bloklariyla kontrol ederiz.',
          tipEmoji: '🚦',
          tip: 'Gercek trafik isiklarinda her renk belirli bir sure yanar, sonra soner - biz de ayni mantigi kuracagiz!',
        ),

        MultipleChoiceStep(
          id: 'a3_1_q1',
          question: 'Kirmizi (pin 9), sari (pin 10) ve yesil (pin 11) LED\'leri ayni anda mi kontrol ederiz?',
          options: [
            ChoiceOption(text: 'Hayir, her birini ayri "sayısal pini YÜKSEK/DÜŞÜK yap" blogu ile ayri kontrol ederiz', emoji: '✅'),
            ChoiceOption(text: 'Evet, tek bir blokla hepsini birden kontrol ederiz', emoji: '❌'),
            ChoiceOption(text: 'LED\'lere hic dokunmayiz', emoji: '❌'),
            ChoiceOption(text: 'Sadece kirmiziyi kontrol ederiz', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Her LED farkli bir pine bagli oldugu icin, her birini kendi blogu ile ayri ayri acip kapatiriz!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a3_1_exp2',
          title: 'Trafik Isigi Zamanlamasi',
          content: 'Gercekci bir trafik isigi sirasi soyledir:\n\n🔴 Kirmizi yanar (3 saniye)\n🔴🟡 Kirmizi + Sari birlikte yanar (kisa sure, 0.2sn)\n🟢 Yesil yanar (3 saniye)\n🟡 Sari yanar (1 saniye)\n🔴 Tekrar kirmiziya donulur...\n\nBu dongu, "sürekli tekrarla" icinde surekli tekrar eder!',
        ),

        MultipleChoiceStep(
          id: 'a3_1_q2',
          question: 'Trafik isiginda yesilden kirmiziya gecmeden once hangi renk yanar?',
          options: [
            ChoiceOption(text: 'Sari', emoji: '✅'),
            ChoiceOption(text: 'Mavi', emoji: '❌'),
            ChoiceOption(text: 'Dogrudan kirmiziya gecilir', emoji: '❌'),
            ChoiceOption(text: 'Beyaz', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Gercek trafik isiklarinda yesilden sonra kisa bir sari uyari sureci olur, sonra kirmiziya gecilir!',
          xpReward: 10,
        ),

        BlockBuilderStep(
          id: 'a3_1_build1',
          instruction: 'Basit bir trafik isigi dongusu olustur: kirmizi -> yesil -> sari -> tekrar kirmizi!',
          goal: 'Her renk sirayla yanip sonsun',
          availableBlocks: [
            ScratchBlock(
              id: 'arduino_program',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'Arduino Programı',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'sürekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'red_on',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '9 (kırmızı) sayısal pini YÜKSEK yap',
              color: Color(0xFF00979D),
            ),
            ScratchBlock(
              id: 'wait_3',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.stack,
              label: '3 saniye bekle',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'red_off_green_on',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '9 DÜŞÜK, 11 (yeşil) YÜKSEK yap',
              color: Color(0xFF00979D),
            ),
            ScratchBlock(
              id: 'green_off_yellow_on',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '11 DÜŞÜK, 10 (sarı) YÜKSEK yap',
              color: Color(0xFF00979D),
            ),
            ScratchBlock(
              id: 'wait_1',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.stack,
              label: '1 saniye bekle',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'yellow_off',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '10 sayısal pini DÜŞÜK yap',
              color: Color(0xFF00979D),
            ),
          ],
          correctSequence: [
            'arduino_program', 'forever', 'red_on', 'wait_3', 'red_off_green_on',
            'wait_3', 'green_off_yellow_on', 'wait_1', 'yellow_off',
          ],
          xpReward: 40,
        ),

        ExplanationStep(
          id: 'a3_1_summary',
          title: 'Trafik Isigi Ustasi!',
          content: '🚦 Gercek bir trafik isigi devresi kurdun!\n\n✓ Birden fazla LED\'i ayri ayri kontrol ettin\n✓ Zamanlamali bir dongu olusturdun\n✓ Gunluk hayattan bir sistemi kodladin\n\nIleri seviye fikir: Yaya butonu eklersen, butona basildiginda kirmizi yanan bir "yaya gecidi" de yapabilirsin!\n\nSonraki: Potansiyometre ile LED parlakligi!',
          tipEmoji: '🏆',
          tip: 'Trafik Isigi Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 3.2: Potansiyometre ile LED Kontrolu
    InteractiveLesson(
      id: 'arduino_3_2',
      courseId: 'arduino',
      title: 'Potansiyometre ile LED',
      subtitle: 'Analog deger oku, parlakligi ayarla',
      order: 5,
      xpReward: 90,
      badge: 'pwm_master',
      steps: [
        IntroStep(
          id: 'a3_2_intro',
          mascotEmoji: '🎛️',
          mascotMessage: 'Potansiyometre, cevirdikce deger degistiren ayarlanabilir bir dirençtir - tipki ses acma dugmesi gibi! Bunu kullanarak LED parlakligini ayarlayacagiz.',
        ),

        ExplanationStep(
          id: 'a3_2_exp1',
          title: 'Potansiyometre Nedir?',
          content: 'Potansiyometre (ayarli direnc), 3 bacaga sahiptir:\n\nA Bacağı -> 5V\nB Bacağı -> GND\nC Bacağı -> Analog Sinyal (Arduino\'ya)\n\nC bacagindan, potu cevirdikce 0 ile 1023 arasinda degisen bir deger okuruz!',
          tipEmoji: '🎚️',
          tip: 'Potansiyometreyi cevirmek, ses acma dugmesini cevirmeye benzer!',
        ),

        MultipleChoiceStep(
          id: 'a3_2_q1',
          question: '"A0 analog pini oku" blogu ile potansiyometreden hangi araliktaki degerler okunur?',
          options: [
            ChoiceOption(text: '0 ile 1023 arasi', emoji: '✅'),
            ChoiceOption(text: 'Sadece 0 veya 1', emoji: '❌'),
            ChoiceOption(text: '0 ile 255 arasi', emoji: '❌'),
            ChoiceOption(text: 'Sadece YÜKSEK veya DÜŞÜK', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Analog okuma blogu 0-1023 arasi bir sayi dondurur - buton gibi sadece 0/1 degil!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a3_2_exp2',
          title: 'Degeri Ekranda Gorme',
          content: 'Potansiyometreden gelen degerleri gormek icin Görünüm sekmesindeki "merhaba de 2 saniye" blogunu kullaniriz - "merhaba" yerine "A0 analog pini oku" blogunu koyariz.\n\nBoylece kuklanin konusma balonunda potun anlik degerini goruruz!',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '<A0 analog pini oku> de 2 saniye',
              color: Color(0xFF9966FF),
              label: 'Görünüm Blogu',
            ),
          ],
        ),

        ExplanationStep(
          id: 'a3_2_exp3',
          title: '1023\'u 255\'e Cevirme',
          content: 'Potansiyometre 0-1023 arasi deger verir. Ama LED\'imizin bagli oldugu PWM pini sadece 0-255 arasi deger kabul eder!\n\nBu yuzden potansiyometreden gelen degeri 4\'e BOLERIZ (1023 / 4 ≈ 255):\n\n"pot" değişkenini <A0 analog pini oku> / 4 yap\n"5 pwm pini pot yap"\n\nBoylece potu cevirdikce LED\'in parlakligi degisir!',
          tipEmoji: '➗',
          tip: '1023 / 4 = 255.75, yani yaklasik 255 - PWM\'in ust siniri!',
        ),

        MultipleChoiceStep(
          id: 'a3_2_q2',
          question: 'Potansiyometreden gelen 0-1023 arasi degeri, neden 4\'e boleriz?',
          options: [
            ChoiceOption(text: 'PWM pini sadece 0-255 arasi deger kabul ettigi icin', emoji: '✅'),
            ChoiceOption(text: 'LED\'i daha yavas yakmak icin', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sebebi yok', emoji: '❌'),
            ChoiceOption(text: 'Potu bozmamak icin', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '1023 / 4 ≈ 255 - boylece potansiyometrenin araligini PWM\'in kabul ettigi araliga (0-255) esitleriz!',
          xpReward: 15,
        ),

        BlockBuilderStep(
          id: 'a3_2_build1',
          instruction: 'Potansiyometre ile LED parlakligini ayarlayan kodu olustur!',
          goal: 'Pot cevrildikce pin 5\'teki LED\'in parlakligi degissin',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'sürekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'set_pot',
              blockType: ScratchBlockType.variables,
              shape: ScratchBlockShape.stack,
              label: 'pot değişkenini <A0 analog pini oku / 4> yap',
              color: Color(0xFFFF8C1A),
            ),
            ScratchBlock(
              id: 'pwm_set',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '5 pwm pini pot yap',
              color: Color(0xFF00979D),
            ),
          ],
          correctSequence: ['green_flag', 'forever', 'set_pot', 'pwm_set'],
          xpReward: 35,
        ),

        ExplanationStep(
          id: 'a3_2_summary',
          title: 'PWM Ustasi!',
          content: '🎛️ Potansiyometre ile LED kontrolu yaptin!\n\n✓ Analog deger okudun (0-1023)\n✓ Degeri PWM araligina (0-255) cevirdin\n✓ Potu cevirdikce LED parlakligini degistirdin\n\nSonraki modul: Buzzer ve sensorlerle projeler!',
          tipEmoji: '🏆',
          tip: 'PWM Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 4: BUZZER VE SENSÖRLER
  // ==========================================
  static final List<InteractiveLesson> module4 = [
    // LESSON 4.1: Buzzer ile Ses Cikartma
    InteractiveLesson(
      id: 'arduino_4_1',
      courseId: 'arduino',
      title: 'Buzzer ile Ses Cikartma',
      subtitle: 'Notalar cal, melodi yap',
      order: 7,
      xpReward: 95,
      badge: 'sound_maker',
      steps: [
        IntroStep(
          id: 'a4_1_intro',
          mascotEmoji: '🔊',
          mascotMessage: 'Buzzer, projelerimizde uyari sesi cikaran mini bir hoparlordur! Notalar calarak kendi melodilerini yapabilirsin.',
        ),

        ExplanationStep(
          id: 'a4_1_exp1',
          title: 'Aktif ve Pasif Buzzer',
          content: 'Iki cesit buzzer vardir:\n\n🔴 Aktif buzzer: Sadece TEK bir tonda ses cikarir, uyari amaclidir\n🎵 Pasif buzzer: Istenilen notaya gore ses cikarabilir, MELODI calabilir\n\nBiz farkli notalar kullanacagimiz icin PASIF buzzer kullanmaliyiz!',
          tipEmoji: '🎶',
          tip: 'Alarm sistemleri genelde aktif buzzer, muzik kutulari ise pasif buzzer kullanir!',
        ),

        MultipleChoiceStep(
          id: 'a4_1_q1',
          question: 'Melodi calmak icin hangi buzzer turu gereklidir?',
          options: [
            ChoiceOption(text: 'Pasif buzzer', emoji: '✅'),
            ChoiceOption(text: 'Aktif buzzer', emoji: '❌'),
            ChoiceOption(text: 'Her ikisi de ayni sekilde calisir', emoji: '❌'),
            ChoiceOption(text: 'Hicbiri melodi calamaz', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Pasif buzzer farkli frekanslarda (notalarda) ses cikarabildigi icin melodi calmaya uygundur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a4_1_exp2',
          title: 'Buzzer Calma Blogu',
          content: 'mBlock\'ta Robotlar sekmesinde hazir bir buzzer blogu vardir:\n\n"9 ses tonu pini C4 notasında Yarım vuruş çal"\n\nBurada:\n"9" = buzzer\'in takili oldugu pin\n"C4" = nota (Do, 4. oktav)\n"Yarım vuruş" = ne kadar sure calacagi',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '9 ses tonu pini C4 notasında Yarım vuruş çal',
              color: Color(0xFF00979D),
              label: 'Buzzer Blogu',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'a4_1_q2',
          question: '"9 ses tonu pini C4 notasında Yarım vuruş çal" blogunda "C4" ne anlama gelir?',
          options: [
            ChoiceOption(text: 'Do notasi, 4. oktav', emoji: '✅'),
            ChoiceOption(text: 'Pin numarasi', emoji: '❌'),
            ChoiceOption(text: 'Calma suresi', emoji: '❌'),
            ChoiceOption(text: 'Ses seviyesi', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'C4, "Do" notasinin 4. oktavdaki (orta kalinlikta) halidir. C=Do, D=Re, E=Mi, F=Fa, G=Sol, A=La, B=Si!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'a4_1_exp3',
          title: 'Notalari Ard Arda Calmak',
          content: 'Bir melodi yapmak icin buzzer bloklarini art arda dizeriz:\n\n9 ses tonu pini C4 notasında Yarım vuruş çal\n9 ses tonu pini D4 notasında Yarım vuruş çal\n9 ses tonu pini E4 notasında Yarım vuruş çal\n\nBu, Do-Re-Mi melodisini calar! Her blok bir onceki bitince otomatik baslar.',
          tipEmoji: '🎹',
          tip: 'Bildigin bir sarkinin notalarini sirayla dizersen kendi melodini yapabilirsin!',
        ),

        BlockBuilderStep(
          id: 'a4_1_build1',
          instruction: 'Do-Re-Mi melodisini calan kodu olustur!',
          goal: 'Buzzer sirasiyla Do, Re, Mi notalarini calsin',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'note_c',
              blockType: ScratchBlockType.sound,
              shape: ScratchBlockShape.stack,
              label: '9 ses tonu pini C4 notasında Yarım vuruş çal',
              color: Color(0xFFCF63CF),
            ),
            ScratchBlock(
              id: 'note_d',
              blockType: ScratchBlockType.sound,
              shape: ScratchBlockShape.stack,
              label: '9 ses tonu pini D4 notasında Yarım vuruş çal',
              color: Color(0xFFCF63CF),
            ),
            ScratchBlock(
              id: 'note_e',
              blockType: ScratchBlockType.sound,
              shape: ScratchBlockShape.stack,
              label: '9 ses tonu pini E4 notasında Yarım vuruş çal',
              color: Color(0xFFCF63CF),
            ),
          ],
          correctSequence: ['green_flag', 'note_c', 'note_d', 'note_e'],
          xpReward: 30,
        ),

        ExplanationStep(
          id: 'a4_1_summary',
          title: 'Ses Yapimcisi!',
          content: '🔊 Artik Arduino ile melodi calabilirsin!\n\n✓ Aktif/pasif buzzer farkini ogrendin\n✓ Nota + oktav + vurus sistemini kavradin\n✓ Kendi melodini olusturdun\n\nSonraki: LDR ile otomatik gece lambasi!',
          tipEmoji: '🏆',
          tip: 'Ses Yapimcisi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 4.2: LDR ile Gece Lambasi
    InteractiveLesson(
      id: 'arduino_4_2',
      courseId: 'arduino',
      title: 'LDR ile Gece Lambasi',
      subtitle: 'Karanlikta otomatik yanan isik',
      order: 8,
      xpReward: 90,
      badge: 'analog_reader',
      steps: [
        IntroStep(
          id: 'a4_2_intro',
          mascotEmoji: '🌙',
          mascotMessage: 'Sokak lambalari karanlik cokunce otomatik yanar, degil mi? Simdi bunun sirrini ogrenecegiz: LDR (isik sensoru)!',
        ),

        ExplanationStep(
          id: 'a4_2_exp1',
          title: 'LDR Nedir?',
          content: 'LDR (Light Dependent Resistor - Isiga Bagli Direnc), uzerine dusen isik miktarina gore direnc degeri degisen bir sensordur.\n\nIsik siddeti ARTARSA -> direnc DUSER\nIsik siddeti AZALIRSA -> direnc ARTAR\n\nYani karanlikta LDR\'nin verdigi analog deger degisir - bunu olcerek karanlik mi aydinlik mi oldugunu anlariz!',
          tipEmoji: '💡',
          tip: 'LDR, isik ile kontrol gereken tum projelerde (sokak lambasi, gece lambasi) kullanilir!',
        ),

        MultipleChoiceStep(
          id: 'a4_2_q1',
          question: 'Isik siddeti azaldiginda (ortam karardiginda) LDR\'nin direnci ne olur?',
          options: [
            ChoiceOption(text: 'Artar', emoji: '✅'),
            ChoiceOption(text: 'Azalir', emoji: '❌'),
            ChoiceOption(text: 'Hic degismez', emoji: '❌'),
            ChoiceOption(text: 'Sifir olur', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'LDR ile isik ters orantilidir: isik azalinca (karanlik) direnc artar!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a4_2_exp2',
          title: 'Esik Deger (Threshold) Belirleme',
          content: 'Once LDR\'nin karanlikta ve aydinlikta verdigi degerleri "merhaba de 2 saniye" blogu ile ekranda gozlemleriz.\n\nDiyelim ki karanlikta deger 100\'un altina dusuyor. Bu durumda "100" bizim ESIK DEGERIMIZ olur:\n\n"ldr" değişkenini <A0 analog pini oku> yap\neğer <ldr < 100> ise\n  LED\'i yak (karanlik!)\ndeğilse\n  LED\'i sondur (aydinlik!)',
          tipEmoji: '🔬',
          tip: 'Esik degeri, kendi ortaminda deneme yaparak bulman gereken bir sayidir - her odada farkli olabilir!',
        ),

        MultipleChoiceStep(
          id: 'a4_2_q2',
          question: '"ldr < 100" kosulu ne zaman DOGRU olur?',
          options: [
            ChoiceOption(text: 'Ortam karardiginda (LDR degeri 100\'den kucuk oldugunda)', emoji: '✅'),
            ChoiceOption(text: 'Ortam aydinlandiginda', emoji: '❌'),
            ChoiceOption(text: 'Asla dogru olmaz', emoji: '❌'),
            ChoiceOption(text: 'Her zaman dogrudur', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Bu ornekte ldr degeri 100\'un altina dustugunde ortamin karardigini anlariz!',
          xpReward: 15,
        ),

        BlockBuilderStep(
          id: 'a4_2_build1',
          instruction: 'Karanlikta otomatik yanan bir gece lambasi kodu olustur!',
          goal: 'LDR degeri 100\'den kucukse LED yansin, degilse sonsun',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'sürekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'set_ldr',
              blockType: ScratchBlockType.variables,
              shape: ScratchBlockShape.stack,
              label: 'ldr değişkenini <A0 analog pini oku> yap',
              color: Color(0xFFFF8C1A),
            ),
            ScratchBlock(
              id: 'if_dark',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'eğer <ldr < 100> ise',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'led_on',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '9 sayısal pini YÜKSEK yap',
              color: Color(0xFF00979D),
            ),
            ScratchBlock(
              id: 'led_off',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '9 sayısal pini DÜŞÜK yap',
              color: Color(0xFF00979D),
            ),
          ],
          correctSequence: ['green_flag', 'forever', 'set_ldr', 'if_dark', 'led_on', 'led_off'],
          xpReward: 35,
        ),

        ExplanationStep(
          id: 'a4_2_summary',
          title: 'Analog Okuyucu!',
          content: '🌙 Kendi gece lambani yaptin!\n\n✓ LDR ile isik olctun\n✓ Esik deger (threshold) mantigini ogrendin\n✓ Otomatik karar veren bir sistem kurdun\n\nSonraki modul: Mesafe olcer ve park sensoru!',
          tipEmoji: '🏆',
          tip: 'Analog Okuyucu rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 5: MESAFE, PARK SENSÖRÜ VE FİNAL PROJE
  // ==========================================
  static final List<InteractiveLesson> module5 = [
    // LESSON 5.1: Mesafe Olcer ve Park Sensoru
    InteractiveLesson(
      id: 'arduino_5_1',
      courseId: 'arduino',
      title: 'Mesafe Olcer ve Park Sensoru',
      subtitle: 'Ultrasonik sensor ile mesafe olc',
      order: 10,
      xpReward: 100,
      badge: 'ultrasonic_master',
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'a5_1_intro',
          mascotEmoji: '📏',
          mascotMessage: 'Arabalardaki park sensorlerinin nasil calistigini hic merak ettin mi? Ultrasonik sensor ile kendi park sensorunu yapacagiz!',
        ),

        ExplanationStep(
          id: 'a5_1_exp1',
          title: 'Ultrasonik Sensor Nasil Calisir?',
          content: 'Ultrasonik sensor, insan kulaginin duyamayacagi ses dalgalari gonderir. Bu dalga bir nesneye carpip geri donunce sensor bunu algilar.\n\nGiden ve donen ses arasindaki SURE ile sesin HIZI carpilarak mesafe hesaplanir - tipki "yol = hiz x zaman" formulu gibi!',
          tipEmoji: '📡',
          tip: 'Bu, yarasalarin karanlikta yon bulma yontemine (ekolokasyon) benzer!',
        ),

        ExplanationStep(
          id: 'a5_1_exp2',
          title: 'Ultrasonik Okuma Blogu',
          content: 'mBlock\'ta mesafe okumak icin ozel bir blok vardir:\n\n"ultrasonik 12 tetik pini 13 okuma pini"\n\n"Tetik pini" (trig) ses dalgasini gonderir, "okuma pini" (echo) geri gelen dalgayi algilar. Bu blok bize dogrudan cm cinsinden mesafe verir!',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'ultrasonik 12 tetik pini 13 okuma pini',
              color: Color(0xFF5CB1D6),
              label: 'Robotlar - Ultrasonik',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'a5_1_q1',
          question: '"ultrasonik 12 tetik pini 13 okuma pini" blogu ne dondurur?',
          options: [
            ChoiceOption(text: 'Nesneye olan mesafe (cm)', emoji: '✅'),
            ChoiceOption(text: 'Sadece 0 veya 1', emoji: '❌'),
            ChoiceOption(text: 'Ses seviyesi', emoji: '❌'),
            ChoiceOption(text: 'Isik siddeti', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Ultrasonik blogu, sensor ile onundeki nesne arasindaki mesafeyi cm cinsinden dondurur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a5_1_exp3',
          title: '"Yuvarla" ile Tam Sayi Elde Etme',
          content: 'Mesafe degeri bazen kusuratli (ondalikli) gelebilir. Bunu tam sayi yapmak icin Islemler sekmesindeki "yuvarla" blogunu kullaniriz:\n\n"mesafe" değişkenini <<ultrasonik 12 tetik pini 13 okuma pini> i yuvarla> yap\n\nBoylece mesafe degerimiz duzgun bir tam sayi (orn: 25 cm) olarak degiskenimize kaydedilir.',
          tipEmoji: '➗',
          tip: '"yuvarla" blogunu Islemler (Operators) sekmesinde bulabilirsin!',
        ),

        ExplanationStep(
          id: 'a5_1_exp4',
          title: 'Park Sensoru: Mesafe + Buzzer',
          content: 'Simdi ogrendigimiz iki seyi birlestirelim: mesafe olcme + buzzer!\n\neğer <mesafe < 20> ise\n  9 ses tonu pini C4 notasında Yarım vuruş çal\n\nBu, bir nesne arabaya (sensore) 20 cm\'den daha yakinlassa alarm calmasini saglar - aynen gercek park sensorleri gibi!',
          tipEmoji: '🚗',
          tip: 'Farkli mesafelerde farkli notalar calarak "yaklastikca hizlanan" bir alarm da yapabilirsin!',
        ),

        MultipleChoiceStep(
          id: 'a5_1_q2',
          question: 'Park sensoru projesinde "eğer <mesafe < 20> ise" kosulu ne zaman dogru olur?',
          options: [
            ChoiceOption(text: 'Bir nesne sensore 20 cm\'den daha yakin oldugunda', emoji: '✅'),
            ChoiceOption(text: 'Sensorun onu bombos oldugunda', emoji: '❌'),
            ChoiceOption(text: 'Her zaman', emoji: '❌'),
            ChoiceOption(text: 'Asla', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Mesafe 20\'den kucukse, yani nesne cok yakinsa, bu kosul dogru olur ve alarm calar!',
          xpReward: 15,
        ),

        ProjectStep(
          id: 'a5_1_project',
          title: 'Final Proje: Park Sensoru',
          description: 'Ultrasonik sensor ve buzzer kullanarak gercek bir park sensoru sistemi yap!',
          requirements: [
            '"mesafe" degiskeni olustur ve ultrasonik sensorden gelen degeri (yuvarlanmis) icine yaz',
            '"sürekli tekrarla" icinde mesafeyi surekli guncelle',
            'Mesafe 20 cm\'den kucukse buzzer\'dan alarm sesi cal',
            'Mesafe uzaksa buzzer sessiz kalsin',
          ],
          hints: [
            'mesafe değişkenini <<ultrasonik 12 tetik pini 13 okuma pini> i yuvarla> yap',
            'eğer <mesafe < 20> ise ... buzzer çal',
            'Robolink ve Kodluyoruz Dernegi kitapciklarindaki devre semasini referans al',
          ],
          starterCode: 'tıklandığında\nsürekli tekrarla\n  mesafe değişkenini <ultrasonik oku> yap\n  eğer <mesafe < 20> ise\n    // buzzer çal',
          language: 'mblock',
          validation: ProjectValidation(
            mustContain: ['mesafe', 'ultrasonik', 'eğer'],
          ),
          xpReward: 50,
        ),

        ExplanationStep(
          id: 'a5_1_summary',
          title: 'Ultrasonik Ustasi!',
          content: '📏 Kendi park sensorunu yaptin!\n\n✓ Ultrasonik sensor ile mesafe olctun\n✓ "yuvarla" ile temiz sayilar elde ettin\n✓ Mesafe + buzzer ile gercek bir alarm sistemi kurdun\n\nSonraki: Servo motor ile final projemiz - yagmur sensorlu cam sileceği!',
          tipEmoji: '🏆',
          tip: 'Ultrasonik Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 5.2: Final Proje - Yagmur Sensörlü Cam Sileceği
    InteractiveLesson(
      id: 'arduino_5_2',
      courseId: 'arduino',
      title: 'Final Proje: Cam Sileceği',
      subtitle: 'Yagmur sensoru + servo motor',
      order: 11,
      xpReward: 130,
      badge: 'servo_master',
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'a5_2_intro',
          mascotEmoji: '🌧️',
          mascotMessage: 'Son projemiz: Arabalardaki otomatik cam sileceklerinin mantigini kuracagiz! Yagmur yagdiginda servo motor otomatik calisacak.',
        ),

        ExplanationStep(
          id: 'a5_2_exp1',
          title: 'Servo Motor Hatirlatmasi',
          content: 'Servo motor, 0-180 derece arasinda hassas donus yapabilen bir motordur. mBlock\'ta kontrolu tek bir blokla yapilir:\n\n"9 servo pinini 90 dereceye ayarla"\n\nBu tek blok, servo motoru istedigin aciya cevirir!',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '9 servo pinini 90 dereceye ayarla',
              color: Color(0xFF00979D),
              label: 'Servo Blogu',
            ),
          ],
          tipEmoji: '🦾',
          tip: 'Servo motorun bacaklarindaki enkoder, motorun tam olarak dogru aciya gitmesini saglar!',
        ),

        MultipleChoiceStep(
          id: 'a5_2_q1',
          question: 'Servo motor kac derece arasinda hareket edebilir?',
          options: [
            ChoiceOption(text: '0-180 derece', emoji: '✅'),
            ChoiceOption(text: '0-360 derece', emoji: '❌'),
            ChoiceOption(text: 'Sadece 0 veya 90', emoji: '❌'),
            ChoiceOption(text: 'Sinirsiz', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Standart servo motorlar 0-180 derece arasinda hassas hareket yapabilir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a5_2_exp2',
          title: 'Yagmur Sensoru Nasil Calisir?',
          content: 'Yagmur sensoru, uzerine birbirine paralel cizilmis iletken hatlardan olusur. Su bu hatlara temas edince, sensorun analog cikisindan farkli bir deger okuruz.\n\nKuru halde YUKSEK bir deger, islak halde ise DUSUK bir deger okunur (ya da tam tersi - sensorune gore degisir, once test etmeliyiz!).',
          tipEmoji: '💧',
          tip: 'Su ve elektronik bir arada dikkat gerektirir - test ederken bilgisayara su damlatmamaya ozen goster!',
        ),

        ExplanationStep(
          id: 'a5_2_exp3',
          title: 'Once Degerleri Olc, Sonra Kodla',
          content: 'Kitapcigin onerdigi yontem: Once sensorden gelen KURU ve ISLAK degerleri "merhaba de 2 saniye" ile ekranda gozlemleriz. Boylece kendi sensorumuz icin dogru esik degerini bulmus oluruz.\n\nyagmur değişkenini <A0 analog pini oku> yap\n<yagmur> de 2 saniye',
          tipEmoji: '🔬',
          tip: 'Her sensor biraz farkli degerler verebilir - bu yuzden once olcup sonra kodlamak en dogru yontemdir!',
        ),

        MultipleChoiceStep(
          id: 'a5_2_q2',
          question: 'Yagmur sensorunun esik degerini kodlamadan once neden once olcmemiz gerekir?',
          options: [
            ChoiceOption(text: 'Her sensor biraz farkli deger verebilir, dogru esigi bulmak icin', emoji: '✅'),
            ChoiceOption(text: 'Hicbir sebebi yok', emoji: '❌'),
            ChoiceOption(text: 'Sadece gorunum icin', emoji: '❌'),
            ChoiceOption(text: 'Arduino\'yu yormamak icin', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Sensorler arasinda kucuk farklar olabilir - once gozlemleyip dogru esik degerini bulmak, projenin dogru calismasi icin onemlidir!',
          xpReward: 15,
        ),

        BlockBuilderStep(
          id: 'a5_2_build1',
          instruction: 'Yagmur algilaninca servo motoru calistiran final kodunu olustur!',
          goal: 'Yagmur sensoru islaklik algilarsa servo hareket etsin (sileceği simule etsin)',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'sürekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'set_yagmur',
              blockType: ScratchBlockType.variables,
              shape: ScratchBlockShape.stack,
              label: 'yağmur değişkenini <A0 analog pini oku> yap',
              color: Color(0xFFFF8C1A),
            ),
            ScratchBlock(
              id: 'if_wet',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'eğer <yağmur < 300> ise',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'servo_sweep_1',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '9 servo pinini 0 dereceye ayarla',
              color: Color(0xFF00979D),
            ),
            ScratchBlock(
              id: 'servo_sweep_2',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '9 servo pinini 90 dereceye ayarla',
              color: Color(0xFF00979D),
            ),
          ],
          correctSequence: ['green_flag', 'forever', 'set_yagmur', 'if_wet', 'servo_sweep_1', 'servo_sweep_2'],
          xpReward: 45,
        ),

        ProjectStep(
          id: 'a5_2_project',
          title: 'Final Proje: Otomatik Cam Sileceği',
          description: 'Ogrendigin HER SEYI birlestirerek yagmur sensörlü otomatik bir cam sileceği sistemi yap!',
          requirements: [
            '"yağmur" değişkeni olustur ve A0 analog pininden oku',
            'Once kuru/islak degerlerini gozlemleyip dogru esik degerini bul',
            '"eğer <yağmur esik-degerinden kucuk/buyuk> ise" ile islakligi kontrol et',
            'Islaklik algilandiginda servo motoru 0 ve 90 derece arasinda hareket ettir (silecek simulasyonu)',
            'Kuruyken servo hareket etmesin',
          ],
          hints: [
            'yağmur değişkenini <A0 analog pini oku> yap',
            'Once <yağmur> de 2 saniye ile degerleri gozlemle',
            'Servo bloklarini "eğer" icine yerlestir',
          ],
          starterCode: 'tıklandığında\nsürekli tekrarla\n  yağmur değişkenini <A0 analog pini oku> yap\n  eğer <yağmur < ESIK_DEGERI> ise\n    // servo hareket etsin',
          language: 'mblock',
          validation: ProjectValidation(
            mustContain: ['yağmur', 'servo', 'eğer'],
          ),
          xpReward: 70,
        ),

        ExplanationStep(
          id: 'a5_2_summary',
          title: '🎓 ARDUINO KURSUNU TAMAMLADIN!',
          content: '🎉🤖🎉 Kodluyoruz Dernegi müfredatındaki tum temel projeleri tamamladin!\n\n✓ LED yakma ve buton kontrolu\n✓ Trafik isigi ve potansiyometre\n✓ Buzzer ve LDR gece lambasi\n✓ Ultrasonik mesafe olcer ve park sensoru\n✓ Servo motor ve yagmur sensörlü cam sileceği\n\nBonus bilgi: Ileri seviyede 8x8 LED ekran ve LCD ekran gibi ozel donanimlari da mBlock\'un "Uzantılar" (Extensions) menusunden ekleyerek kullanabilirsin!\n\nArtik kendi Arduino projelerini tasarlayabilirsin!',
          tipEmoji: '🏆',
          tip: 'Arduino Mezunu oldun! Bu becerilerle kendi icat ettigin projeleri yapmaya baslayabilirsin.',
        ),
      ],
    ),
  ];

  /// Get all Arduino lessons
  static List<InteractiveLesson> getArduinoInteractiveLessons() {
    return [
      ...module1,
      ...module2,
      ...module3,
      ...module4,
      ...module5,
    ];
  }

  /// Get lessons for a specific module
  static List<InteractiveLesson> getLessonsForModule(int moduleNumber) {
    switch (moduleNumber) {
      case 1:
        return module1;
      case 2:
        return module2;
      case 3:
        return module3;
      case 4:
        return module4;
      case 5:
        return module5;
      default:
        return [];
    }
  }
}

/// Arduino badges
class ArduinoBadges {
  static const List<LessonBadge> all = [
    LessonBadge(
      id: 'arduino_starter',
      name: 'Arduino Baslangic',
      description: 'Arduino ve mBlock dunyasina adim attin!',
      emoji: '🤖',
      rarity: BadgeRarity.common,
      category: BadgeCategory.lesson,
    ),
    LessonBadge(
      id: 'led_master',
      name: 'LED Ustasi',
      description: 'Ilk LED\'ini mBlock ile yaktın!',
      emoji: '💡',
      rarity: BadgeRarity.common,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'button_reader',
      name: 'Buton Okuyucu',
      description: 'Buton girisi okudun!',
      emoji: '🔘',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'traffic_light_master',
      name: 'Trafik Isigi Ustasi',
      description: '3 LED ile trafik isigi yaptin!',
      emoji: '🚦',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'pwm_master',
      name: 'PWM Ustasi',
      description: 'Potansiyometre ile LED parlakligi ayarladin!',
      emoji: '🎛️',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'sound_maker',
      name: 'Ses Yapimcisi',
      description: 'Buzzer ile melodi caldin!',
      emoji: '🔊',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'analog_reader',
      name: 'Analog Okuyucu',
      description: 'LDR ile gece lambasi yaptin!',
      emoji: '🌙',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'ultrasonic_master',
      name: 'Ultrasonik Ustasi',
      description: 'Mesafe olcer ve park sensoru yaptin!',
      emoji: '📏',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'servo_master',
      name: 'Servo Ustasi',
      description: 'Yagmur sensörlü cam sileceği final projesini tamamladin!',
      emoji: '🦾',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.course,
    ),
  ];
}
