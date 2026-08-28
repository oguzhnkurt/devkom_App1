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

  // ==========================================
  // MODUL 6: ILERI SEVIYE - GERCEK KOD ILE ARDUINO
  // mBlock'ta ogrenilen mantigin Arduino IDE'de C++ ile yazilmasi.
  // Kaynak: Arduino resmi dokumantasyonu (setup/loop, digitalWrite),
  // LiquidCrystal_I2C kutuphanesi (0x27 adresi, lcd.init/backlight/
  // setCursor/print) ve yaygin toprak nemi sensoru + role projelerinden
  // (analogRead esikleme, once olc-sonra-esikle yontemi) arastirilarak
  // dogrulandi.
  // ==========================================
  static final List<InteractiveLesson> module6 = [
    InteractiveLesson(
      id: 'arduino_6_1',
      courseId: 'arduino',
      title: 'Bloklardan Koda: Arduino IDE\'ye Merhaba',
      subtitle: 'Ogrendigin mantigi gercek kodla yaz',
      titleEn: 'From Blocks to Code: Hello Arduino IDE',
      subtitleEn: 'Write the logic you learned in real code',
      order: 12,
      xpReward: 110,
      badge: 'arduino_coder',
      category: LessonCategory.learn,
      steps: [
        IntroStep(
          id: 'a6_1_intro',
          mascotMessage: 'Tebrikler! mBlock ile bes modulu tamamladin. Simdi gercek Arduino muhendislerinin kullandigi Arduino IDE ile METIN KOD yazmayi ogrenecegiz. Merak etme, mantik ayni - sadece bloklar yerine kelimeler kullanacagiz!',
          mascotEmoji: '🧑‍💻',
          highlights: [
            'Arduino IDE nedir, nasil acilir',
            'setup() ve loop() fonksiyonlari',
            'Bildigin bloklarin metin karsiligi',
          ],
          mascotMessageEn: 'Congratulations! You finished five mBlock modules. Now we\'ll learn to write real TEXT CODE with the Arduino IDE, just like professional engineers. Don\'t worry - the logic is the same, only the blocks turn into words!',
          highlightsEn: [
            'What the Arduino IDE is and how to open it',
            'The setup() and loop() functions',
            'The text version of blocks you already know',
          ],
        ),
        ExplanationStep(
          id: 'a6_1_exp1',
          title: 'Her Arduino Kodunun Iskeleti',
          content: 'Arduino IDE\'de yazdigin her programa "sketch" (kroki) denir. Her sketch\'in iki temel fonksiyonu vardir:\n\nvoid setup() {\n  // Burasi SADECE 1 KEZ calisir\n}\n\nvoid loop() {\n  // Burasi SONSUZA KADAR tekrar eder\n}\n\nBu, mBlock\'taki "tiklandiginda" (bir kere) ve "surekli tekrarla" (sonsuz dongu) bloklarinin tam karsiligi!',
          tipEmoji: '🏗️',
          tip: 'setup() = bir kerelik hazirlik, loop() = surekli calisan ana gorev.',
          titleEn: 'The Skeleton of Every Arduino Sketch',
          contentEn: 'Every program you write in the Arduino IDE is called a "sketch". Every sketch has two core functions:\n\nvoid setup() {\n  // Runs ONLY ONCE\n}\n\nvoid loop() {\n  // Repeats FOREVER\n}\n\nThis is the exact text equivalent of mBlock\'s "when clicked" (runs once) and "forever" (infinite loop) blocks!',
          tipEn: 'setup() = one-time preparation, loop() = the task that keeps running.',
        ),
        ExplanationStep(
          id: 'a6_1_exp2',
          title: 'Bildigin Bloklarin Metin Karsiligi',
          content: 'mBlock\'ta kullandigin bloklari artik boyle yazacaksin:\n\n"pini CIKIS yap" -> pinMode(9, OUTPUT);\n"pini AC" -> digitalWrite(9, HIGH);\n"pini KAPAT" -> digitalWrite(9, LOW);\n"X saniye bekle" -> delay(1000); (Arduino\'da milisaniye kullanilir! 1000 ms = 1 saniye)\n\nHer satirin sonunda noktali virgul ( ; ) olmasi ZORUNLUDUR - bu, "bu komut bitti" demenin Arduino dilindeki yolu.',
          tipEmoji: '🔤',
          tip: 'Noktali virgulu unutursan Arduino IDE sana kirmizi bir hata verir - bu normal, hata ayiklamanin bir parcasi!',
          titleEn: 'The Text Equivalent of Blocks You Know',
          contentEn: 'The blocks you used in mBlock are now written like this:\n\n"set pin to OUTPUT" -> pinMode(9, OUTPUT);\n"turn pin ON" -> digitalWrite(9, HIGH);\n"turn pin OFF" -> digitalWrite(9, LOW);\n"wait X seconds" -> delay(1000); (Arduino uses milliseconds! 1000 ms = 1 second)\n\nEvery line MUST end with a semicolon ( ; ) - that\'s how Arduino\'s language says "this command is finished".',
          tipEn: 'If you forget the semicolon, the Arduino IDE shows a red error - that\'s normal, it\'s part of debugging!',
        ),
        MultipleChoiceStep(
          id: 'a6_1_q1',
          question: 'loop() fonksiyonu kac kere calisir?',
          options: [
            ChoiceOption(text: 'Sadece 1 kez', emoji: '❌'),
            ChoiceOption(text: 'Sonsuza kadar tekrar tekrar', emoji: '✅'),
            ChoiceOption(text: 'Hicbir zaman', emoji: '❌'),
            ChoiceOption(text: 'Sadece butona basinca', emoji: '❌'),
          ],
          correctIndex: 1,
          explanation: 'loop() fonksiyonu Arduino calistigi surece sonsuza kadar tekrar eder - tipki mBlock\'taki "surekli tekrarla" blogu gibi!',
          questionEn: 'How many times does the loop() function run?',
          explanationEn: 'The loop() function repeats forever as long as the Arduino is powered on - just like mBlock\'s "forever" block!',
          xpReward: 10,
        ),
        SpotErrorStep(
          id: 'a6_1_spot1',
          instruction: 'Bu kodda bir hata var. Bulabilir misin?',
          code: 'void setup() {\n  pinMode(9, OUTPUT)\n}\n\nvoid loop() {\n  digitalWrite(9, HIGH);\n  delay(1000);\n  digitalWrite(9, LOW);\n  delay(1000);\n}',
          language: 'cpp',
          errorLine: 2,
          errorDescription: 'pinMode satirinin sonunda noktali virgul ( ; ) eksik!',
          correctCode: 'void setup() {\n  pinMode(9, OUTPUT);\n}\n\nvoid loop() {\n  digitalWrite(9, HIGH);\n  delay(1000);\n  digitalWrite(9, LOW);\n  delay(1000);\n}',
          explanation: 'Arduino\'da (ve C++\'ta) her komut satiri noktali virgul ile bitmelidir. Bu, derleyiciye "bu satir tamamlandi" der.',
          instructionEn: 'There\'s a bug in this code. Can you find it?',
          errorDescriptionEn: 'The pinMode line is missing a semicolon ( ; ) at the end!',
          explanationEn: 'In Arduino (and C++), every command line must end with a semicolon. It tells the compiler "this line is complete".',
          xpReward: 20,
        ),
        TypeCodeStep(
          id: 'a6_1_type1',
          instruction: '9. pindeki LED\'i 1 saniye ac, 1 saniye kapa (blink) kodunu yaz.',
          targetCode: 'void setup() {\n  pinMode(9, OUTPUT);\n}\n\nvoid loop() {\n  digitalWrite(9, HIGH);\n  delay(1000);\n  digitalWrite(9, LOW);\n  delay(1000);\n}',
          language: 'cpp',
          starterCode: 'void setup() {\n  \n}\n\nvoid loop() {\n  \n}',
          hints: [
            'setup() icinde pinMode(9, OUTPUT); yazmalisin',
            'loop() icinde once HIGH sonra delay, sonra LOW sonra delay olmali',
          ],
          hintsEn: [
            'Inside setup() you need pinMode(9, OUTPUT);',
            'Inside loop() you need HIGH then delay, then LOW then delay',
          ],
          instructionEn: 'Write code that turns the LED on pin 9 on for 1 second and off for 1 second (blink).',
          xpReward: 25,
        ),
        ExplanationStep(
          id: 'a6_1_summary',
          title: 'Ilk Metin Kodunu Yazdin!',
          content: '💻 Artik gercek bir Arduino programcisisin!\n\n✓ setup() ve loop() ne ise yarar biliyorsun\n✓ pinMode, digitalWrite, delay komutlarini yazabiliyorsun\n✓ Noktali virgulun onemini ogrendin\n✓ Kodda hata bulup duzeltebiliyorsun\n\nSirada: degiskenler ve Seri Port ile hata ayiklama var!',
          tipEmoji: '🎉',
          tip: 'Kod Yazari rozetini kazandin!',
          titleEn: 'You Wrote Your First Text Code!',
          contentEn: '💻 You\'re now a real Arduino programmer!\n\n✓ You know what setup() and loop() do\n✓ You can write pinMode, digitalWrite, delay commands\n✓ You learned why semicolons matter\n✓ You can spot and fix bugs in code\n\nNext up: variables and debugging with the Serial Monitor!',
          tipEn: 'You earned the Code Writer badge!',
        ),
      ],
    ),
    InteractiveLesson(
      id: 'arduino_6_2',
      courseId: 'arduino',
      title: 'Degiskenler ve Seri Port ile Hata Ayiklama',
      subtitle: 'Kodun icini gorunur yap',
      titleEn: 'Variables and Debugging with the Serial Monitor',
      subtitleEn: 'Make what\'s happening inside your code visible',
      order: 13,
      xpReward: 120,
      badge: 'debug_master',
      category: LessonCategory.learn,
      steps: [
        IntroStep(
          id: 'a6_2_intro',
          mascotMessage: 'mBlock\'ta degisken olusturmustun, hatirliyor musun? Simdi ayni seyi kodla yapacagiz. Ustelik "Seri Port" denen sihirli bir pencereyle, Arduino\'nun icinde ne oldugunu bilgisayar ekraninda canli canli gorecegiz!',
          mascotEmoji: '🔍',
          highlights: [
            'int, float gibi degisken turleri',
            'Serial.begin() ve Serial.println()',
            'Hata ayiklama (debugging) nedir',
          ],
          mascotMessageEn: 'Remember creating variables in mBlock? Now we\'ll do the same thing in code. Plus, with a magic window called the "Serial Monitor", we\'ll watch what\'s happening inside the Arduino live on our computer screen!',
          highlightsEn: [
            'Variable types like int and float',
            'Serial.begin() and Serial.println()',
            'What debugging means',
          ],
        ),
        ExplanationStep(
          id: 'a6_2_exp1',
          title: 'Degisken Tanimlamak',
          content: 'Bir kutuya isim verip icine sayi koymak gibi dusun:\n\nint ledPin = 9;\nint bekleme = 500;\n\n"int" bu kutunun TAM SAYI tutacagini soyler. Artik kodun her yerinde "9" yazmak yerine "ledPin" yazabilirsin - ve pini degistirmek istersen sadece TEK satiri guncellersin!',
          tipEmoji: '📦',
          tip: 'Degisken isimleri anlamli olmali: "ledPin" yaz, "x" yazma - kodun kendini anlatsin!',
          titleEn: 'Declaring a Variable',
          contentEn: 'Think of it like a labeled box holding a number:\n\nint ledPin = 9;\nint waitTime = 500;\n\n"int" tells the box it holds a WHOLE NUMBER. Now instead of typing "9" everywhere, you can type "ledPin" - and if you want to change the pin, you only update ONE line!',
          tipEn: 'Variable names should be meaningful: write "ledPin", not "x" - let your code explain itself!',
        ),
        ExplanationStep(
          id: 'a6_2_exp2',
          title: 'Seri Port: Arduino\'nun Gunlugu',
          content: 'Arduino\'nun ne dusundugunu gormek icin Seri Port\'u kullanirsin:\n\nvoid setup() {\n  Serial.begin(9600);\n}\n\nvoid loop() {\n  Serial.println("Merhaba!");\n  delay(1000);\n}\n\nArduino IDE\'de sag ustteki bureç simgesine tiklayinca acilan "Seri Port Ekrani" (Serial Monitor) penceresinde bu mesajlari canli goreceksin. Profesyonel programcilarin en cok kullandigi hata ayiklama yontemi budur!',
          tipEmoji: '📟',
          tip: 'Serial.begin(9600) sadece setup() icinde bir kez yazilir - hiz ayarini yapar.',
          titleEn: 'The Serial Monitor: Arduino\'s Diary',
          contentEn: 'To see what the Arduino is "thinking", you use the Serial Monitor:\n\nvoid setup() {\n  Serial.begin(9600);\n}\n\nvoid loop() {\n  Serial.println("Hello!");\n  delay(1000);\n}\n\nClicking the magnifying-glass icon in the top-right of the Arduino IDE opens the Serial Monitor window, where you\'ll see these messages live. This is the debugging technique professional programmers use the most!',
          tipEn: 'Serial.begin(9600) is written only once, inside setup() - it sets the communication speed.',
        ),
        MultipleChoiceStep(
          id: 'a6_2_q1',
          question: 'Bir sensorden okunan degeri ekranda gormek icin hangi komutu kullanirsin?',
          options: [
            ChoiceOption(text: 'Serial.println(deger);', emoji: '✅'),
            ChoiceOption(text: 'digitalWrite(deger);', emoji: '❌'),
            ChoiceOption(text: 'delay(deger);', emoji: '❌'),
            ChoiceOption(text: 'pinMode(deger);', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Serial.println() bir degeri Seri Port Ekrani\'na yazdirir - sensor degerlerini test etmenin en hizli yolu budur.',
          questionEn: 'Which command shows a value read from a sensor on the screen?',
          explanationEn: 'Serial.println() prints a value to the Serial Monitor - the fastest way to test sensor readings.',
          xpReward: 10,
        ),
        CodeCompleteStep(
          id: 'a6_2_complete1',
          instruction: 'Bir potansiyometreden okunan degeri Seri Port\'a yazdiran kodu tamamla.',
          codeTemplate: 'int potPin = A0;\n\nvoid setup() {\n  ___(9600);\n}\n\nvoid loop() {\n  int deger = analogRead(___);\n  Serial.println(___);\n  delay(200);\n}',
          language: 'cpp',
          blanks: [
            CodeBlank(index: 0, correctAnswer: 'Serial.begin', hint: 'Seri Portu baslatan komut', hintEn: 'The command that starts the Serial Monitor'),
            CodeBlank(index: 1, correctAnswer: 'potPin', hint: 'Az once tanimladigin degisken adi', hintEn: 'The variable name you just declared'),
            CodeBlank(index: 2, correctAnswer: 'deger', hint: 'Okunan degeri tutan degisken', hintEn: 'The variable holding the reading'),
          ],
          instructionEn: 'Complete the code that prints a potentiometer reading to the Serial Monitor.',
          xpReward: 20,
        ),
        ExplanationStep(
          id: 'a6_2_summary',
          title: 'Artik Hata Avcisisin!',
          content: '🕵️ Kodunun icini gorebiliyorsun artik!\n\n✓ Degisken tanimlamayi ogrendin (int)\n✓ Serial.begin() ve Serial.println() kullanabiliyorsun\n✓ Sensor degerlerini canli izleyebiliyorsun\n\nBu, gercek muhendislerin projelerini test ederken ilk yaptigi seydir!',
          tipEmoji: '🏆',
          tip: 'Hata Avcisi rozetini kazandin!',
          titleEn: 'You\'re a Bug Hunter Now!',
          contentEn: '🕵️ You can see inside your code now!\n\n✓ You learned to declare variables (int)\n✓ You can use Serial.begin() and Serial.println()\n✓ You can watch sensor readings live\n\nThis is the very first thing real engineers do when testing their projects!',
          tipEn: 'You earned the Bug Hunter badge!',
        ),
      ],
    ),
    InteractiveLesson(
      id: 'arduino_6_3',
      courseId: 'arduino',
      title: 'Fonksiyonlarla Kodu Sadelestirmek',
      subtitle: 'Kendi komutlarini yaz',
      titleEn: 'Simplifying Code with Functions',
      subtitleEn: 'Write your own commands',
      order: 14,
      xpReward: 130,
      badge: 'arduino_function_master',
      category: LessonCategory.learn,
      steps: [
        IntroStep(
          id: 'a6_3_intro',
          mascotMessage: 'mBlock\'ta "Kendi Bloklarim" (myBlocks) ozelligini kullanmistin, hatirliyor musun? Iste onun metin koddaki karsiligi: FONKSIYONLAR! Tekrar eden kodu bir kere yazip istedigin kadar cagirabilirsin.',
          mascotEmoji: '🧩',
          highlights: [
            'Fonksiyon nedir, neden kullanilir',
            'Parametre ile fonksiyona bilgi gonderme',
            'Kod tekrarini azaltma',
          ],
          mascotMessageEn: 'Remember using "My Blocks" in mBlock? Here\'s its text-code equivalent: FUNCTIONS! Write repeated code once and call it as many times as you like.',
          highlightsEn: [
            'What a function is and why we use it',
            'Sending information to a function with parameters',
            'Reducing code repetition',
          ],
        ),
        ExplanationStep(
          id: 'a6_3_exp1',
          title: 'Neden Fonksiyon Yazariz?',
          content: 'Bir LED\'i 3 kere yakip sondurmek istesen, ayni satirlari 3 kere kopyalayabilirsin. Ama ya 10 kere istersen? Ya da 5 farkli yerde kullanmak istersen?\n\nIste burada FONKSIYON devreye girer - kodu bir kere yazarsin, istedigin kadar cagirirsin:\n\nvoid ledYanip Son() {\n  digitalWrite(9, HIGH);\n  delay(300);\n  digitalWrite(9, LOW);\n  delay(300);\n}\n\nSonra loop() icinde sadece ledYanipSon(); yazarak cagirirsin!',
          tipEmoji: '♻️',
          tip: 'Fonksiyonlar "kod tekrarini azaltma" (DRY - Don\'t Repeat Yourself) prensibinin temelidir - profesyonel yazilimcilarin altin kurali!',
          titleEn: 'Why Do We Write Functions?',
          contentEn: 'If you want to blink an LED 3 times, you could copy the same lines 3 times. But what if you wanted 10 times? Or wanted to use it in 5 different places?\n\nThat\'s where a FUNCTION comes in - you write the code once, and call it as many times as you like:\n\nvoid blinkLed() {\n  digitalWrite(9, HIGH);\n  delay(300);\n  digitalWrite(9, LOW);\n  delay(300);\n}\n\nThen inside loop() you just write blinkLed(); to call it!',
          tipEn: 'Functions are the foundation of "Don\'t Repeat Yourself" (DRY) - a golden rule for professional programmers!',
        ),
        ExplanationStep(
          id: 'a6_3_exp2',
          title: 'Fonksiyona Bilgi Gondermek: Parametreler',
          content: 'Fonksiyonlar parametre alarak daha da guclu olur:\n\nvoid ledYanipSon(int pin, int sure) {\n  digitalWrite(pin, HIGH);\n  delay(sure);\n  digitalWrite(pin, LOW);\n  delay(sure);\n}\n\nArtik loop() icinde:\nledYanipSon(9, 300);  // 9. pin, 300ms\nledYanipSon(10, 100); // 10. pin, 100ms\n\nAyni fonksiyonu farkli pinler ve sureler icin kullanabiliyorsun!',
          tipEmoji: '🎛️',
          tip: 'Parametreler, fonksiyona "bu seferlik boyle yap" demenin yoludur.',
          titleEn: 'Sending Information to a Function: Parameters',
          contentEn: 'Functions become even more powerful with parameters:\n\nvoid blinkLed(int pin, int duration) {\n  digitalWrite(pin, HIGH);\n  delay(duration);\n  digitalWrite(pin, LOW);\n  delay(duration);\n}\n\nNow inside loop():\nblinkLed(9, 300);  // pin 9, 300ms\nblinkLed(10, 100); // pin 10, 100ms\n\nYou can reuse the same function for different pins and timings!',
          tipEn: 'Parameters are how you tell a function "do it this way, just this once".',
        ),
        MultipleChoiceStep(
          id: 'a6_3_q1',
          question: 'Fonksiyon yazmanin en buyuk faydasi nedir?',
          options: [
            ChoiceOption(text: 'Ayni kodu tekrar tekrar yazmayi onler', emoji: '✅'),
            ChoiceOption(text: 'Kodu yavaslatir', emoji: '❌'),
            ChoiceOption(text: 'LED\'leri daha parlak yapar', emoji: '❌'),
            ChoiceOption(text: 'Hicbir fayda saglamaz', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Fonksiyonlar kod tekrarini azaltir, kodu okunakli hale getirir ve hata yapma ihtimalini dusurur.',
          questionEn: 'What is the biggest benefit of writing a function?',
          explanationEn: 'Functions reduce code repetition, make code easier to read, and lower the chance of mistakes.',
          xpReward: 10,
        ),
        TypeCodeStep(
          id: 'a6_3_type1',
          instruction: '2 parametre alan (pin, tekrarSayisi) ve LED\'i o kadar kere yanip sondüren bir fonksiyon yaz.',
          targetCode: 'void ledYanipSon(int pin, int tekrarSayisi) {\n  for (int i = 0; i < tekrarSayisi; i++) {\n    digitalWrite(pin, HIGH);\n    delay(200);\n    digitalWrite(pin, LOW);\n    delay(200);\n  }\n}',
          language: 'cpp',
          starterCode: 'void ledYanipSon(int pin, int tekrarSayisi) {\n  \n}',
          hints: [
            'for dongusu ile tekrarSayisi kadar donebilirsin',
            'Her dongude HIGH-delay-LOW-delay sirasi olmali',
          ],
          hintsEn: [
            'You can loop tekrarSayisi times with a for loop',
            'Each loop needs the HIGH-delay-LOW-delay order',
          ],
          instructionEn: 'Write a function that takes 2 parameters (pin, repeatCount) and blinks the LED that many times.',
          xpReward: 30,
        ),
        ExplanationStep(
          id: 'a6_3_summary',
          title: 'Kendi Komutlarini Yazdin!',
          content: '🧩 Artik fonksiyonlarla kod yaziyorsun!\n\n✓ Fonksiyon nedir, neden onemlidir biliyorsun\n✓ Parametre kullanarak esnek fonksiyonlar yazabiliyorsun\n✓ Kod tekrarini azaltmayi ogrendin\n\nSirada gercek bir donanim parcasi: LCD ekran ile mesaj gostermek var!',
          tipEmoji: '🏆',
          tip: 'Fonksiyon Ustasi rozetini kazandin!',
          titleEn: 'You Wrote Your Own Commands!',
          contentEn: '🧩 You now write code using functions!\n\n✓ You know what a function is and why it matters\n✓ You can write flexible functions using parameters\n✓ You learned to reduce code repetition\n\nNext up: displaying messages with a real piece of hardware, the LCD screen!',
          tipEn: 'You earned the Function Master badge!',
        ),
      ],
    ),
    InteractiveLesson(
      id: 'arduino_6_4',
      courseId: 'arduino',
      title: 'I2C LCD Ekran ile Mesaj Gostermek',
      subtitle: 'Projene bir ekran ekle',
      titleEn: 'Displaying Messages with an I2C LCD',
      subtitleEn: 'Add a screen to your project',
      order: 15,
      xpReward: 130,
      badge: 'lcd_master',
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'a6_4_intro',
          mascotMessage: 'Simdiye kadar projelerin LED ve buzzer ile "konusuyordu". Simdi gercek bir EKRAN ekleyecegiz - 16x2 I2C LCD! Boylece projen sicaklik, mesafe ya da mesaj gibi bilgileri yazi olarak gosterebilecek.',
          mascotEmoji: '📺',
          highlights: [
            'I2C LCD nedir, nasil baglanir (SDA/SCL)',
            'LiquidCrystal_I2C kutuphanesi',
            'Ekrana yazi yazdirma',
          ],
          mascotMessageEn: 'Until now your projects "spoke" through LEDs and buzzers. Now we\'ll add a real SCREEN - a 16x2 I2C LCD! Your project will be able to display information like temperature, distance, or messages as text.',
          highlightsEn: [
            'What an I2C LCD is and how to wire it (SDA/SCL)',
            'The LiquidCrystal_I2C library',
            'Printing text to the screen',
          ],
        ),
        ExplanationStep(
          id: 'a6_4_exp1',
          title: 'I2C LCD Nasil Baglanir?',
          content: '16x2 I2C LCD ekranin sadece 4 kablosu vardir:\n\nVCC -> Arduino 5V\nGND -> Arduino GND\nSDA -> Arduino A4 (Uno\'da)\nSCL -> Arduino A5 (Uno\'da)\n\n"I2C" sayesinde tek bir kabloyla (SDA) veri gonderilir - normal LCD\'lerin 6-7 kablosuna gerek kalmaz! Once mBlock\'ta "Uzantilar" menusunden LCD eklemistik, hatirliyor musun? Simdi ayni ekrani kodla kontrol edecegiz.',
          tipEmoji: '🔌',
          tip: 'Cogu I2C LCD modulunun adresi 0x27 veya 0x3F\'tir - calismazsa "I2C Scanner" kodu ile adresi bulabilirsin.',
          titleEn: 'How to Wire an I2C LCD',
          contentEn: 'A 16x2 I2C LCD screen only needs 4 wires:\n\nVCC -> Arduino 5V\nGND -> Arduino GND\nSDA -> Arduino A4 (on Uno)\nSCL -> Arduino A5 (on Uno)\n\nThanks to "I2C", data travels over a single wire (SDA) - no need for a regular LCD\'s 6-7 wires! Remember adding an LCD from the "Extensions" menu in mBlock? Now we\'ll control the same screen with code.',
          tipEn: 'Most I2C LCD modules use address 0x27 or 0x3F - if it doesn\'t work, an "I2C Scanner" sketch can find the right address.',
        ),
        ExplanationStep(
          id: 'a6_4_exp2',
          title: 'Kutuphaneyi Kullanmak',
          content: '#include <LiquidCrystal_I2C.h>\nLiquidCrystal_I2C lcd(0x27, 16, 2);\n\nvoid setup() {\n  lcd.init();\n  lcd.backlight();\n  lcd.setCursor(0, 0);\n  lcd.print("Merhaba Dunya!");\n}\n\nlcd.setCursor(sutun, satir) imlecin nereye yazacagini belirler (0,0 sol ust kosedir). lcd.print() ise imlecin oldugu yerden itibaren yazi yazar.',
          tipEmoji: '📚',
          tip: 'Kutuphane, Arduino IDE\'de Araclar > Kutuphane Yonet menusunden "LiquidCrystal I2C" aranarak kurulur.',
          titleEn: 'Using the Library',
          contentEn: '#include <LiquidCrystal_I2C.h>\nLiquidCrystal_I2C lcd(0x27, 16, 2);\n\nvoid setup() {\n  lcd.init();\n  lcd.backlight();\n  lcd.setCursor(0, 0);\n  lcd.print("Hello World!");\n}\n\nlcd.setCursor(column, row) decides where the cursor writes (0,0 is the top-left corner). lcd.print() then prints text starting from the cursor.',
          tipEn: 'Install the library from Tools > Manage Libraries in the Arduino IDE by searching "LiquidCrystal I2C".',
        ),
        MultipleChoiceStep(
          id: 'a6_4_q1',
          question: 'lcd.setCursor(0, 1) komutu imleci nereye tasir?',
          options: [
            ChoiceOption(text: 'Ikinci satirin en basina', emoji: '✅'),
            ChoiceOption(text: 'Ilk satirin sonuna', emoji: '❌'),
            ChoiceOption(text: 'Ekranin ortasina', emoji: '❌'),
            ChoiceOption(text: 'Hicbir yere', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'setCursor(sutun, satir) formatinda ikinci sayi satiri belirtir; satirlar 0\'dan basladigi icin "1" ikinci satirdir.',
          questionEn: 'Where does lcd.setCursor(0, 1) move the cursor?',
          explanationEn: 'In setCursor(column, row), the second number is the row; since rows start at 0, "1" is the second row.',
          xpReward: 10,
        ),
        SpotErrorStep(
          id: 'a6_4_spot1',
          instruction: 'Bu kod LCD\'de hicbir sey gostermiyor. Hatayi bul!',
          code: '#include <LiquidCrystal_I2C.h>\nLiquidCrystal_I2C lcd(0x27, 16, 2);\n\nvoid setup() {\n  lcd.setCursor(0, 0);\n  lcd.print("Merhaba!");\n}\n\nvoid loop() {\n}',
          language: 'cpp',
          errorLine: 5,
          errorDescription: 'lcd.init() ve lcd.backlight() cagrilmadigi icin ekran baslatilmamis ve isik yanmiyor!',
          correctCode: '#include <LiquidCrystal_I2C.h>\nLiquidCrystal_I2C lcd(0x27, 16, 2);\n\nvoid setup() {\n  lcd.init();\n  lcd.backlight();\n  lcd.setCursor(0, 0);\n  lcd.print("Merhaba!");\n}\n\nvoid loop() {\n}',
          explanation: 'Her LCD projesinde setup() icinde once lcd.init() ile ekran baslatilmali, sonra lcd.backlight() ile isik acilmalidir.',
          instructionEn: 'This code shows nothing on the LCD. Find the bug!',
          errorDescriptionEn: 'lcd.init() and lcd.backlight() are never called, so the screen is never started and the backlight stays off!',
          explanationEn: 'Every LCD project must call lcd.init() first inside setup() to start the screen, then lcd.backlight() to turn on the light.',
          xpReward: 20,
        ),
        TypeCodeStep(
          id: 'a6_4_type1',
          instruction: 'Ekranin ilk satirina "Devkom Robotik", ikinci satirina "Merhaba!" yazdiran kodu tamamla.',
          targetCode: '#include <LiquidCrystal_I2C.h>\nLiquidCrystal_I2C lcd(0x27, 16, 2);\n\nvoid setup() {\n  lcd.init();\n  lcd.backlight();\n  lcd.setCursor(0, 0);\n  lcd.print("Devkom Robotik");\n  lcd.setCursor(0, 1);\n  lcd.print("Merhaba!");\n}\n\nvoid loop() {\n}',
          language: 'cpp',
          starterCode: '#include <LiquidCrystal_I2C.h>\nLiquidCrystal_I2C lcd(0x27, 16, 2);\n\nvoid setup() {\n  \n}\n\nvoid loop() {\n}',
          hints: [
            'Once lcd.init() ve lcd.backlight() cagir',
            'Her satir icin ayri setCursor + print kullan',
          ],
          hintsEn: [
            'Call lcd.init() and lcd.backlight() first',
            'Use a separate setCursor + print for each line',
          ],
          instructionEn: 'Complete the code that prints "Devkom Robotics" on the first line and "Hello!" on the second.',
          xpReward: 25,
        ),
        ExplanationStep(
          id: 'a6_4_summary',
          title: 'Projene Ekran Ekledin!',
          content: '📺 Artik projelerinde gercek bir ekran kullanabiliyorsun!\n\n✓ I2C LCD\'nin nasil baglandigini biliyorsun\n✓ LiquidCrystal_I2C kutuphanesini kullanabiliyorsun\n✓ Ekranin istedigin satirina istedigin yazi yazdirabiliyorsun\n\nSirada: ogrendigin her seyi birlestiren buyuk final projesi - Akilli Bitki Sulama Sistemi!',
          tipEmoji: '🏆',
          tip: 'Ekran Ustasi rozetini kazandin!',
          titleEn: 'You Added a Screen to Your Project!',
          contentEn: '📺 You can now use a real screen in your projects!\n\n✓ You know how to wire an I2C LCD\n✓ You can use the LiquidCrystal_I2C library\n✓ You can print any text to any line of the screen\n\nNext up: the grand final project combining everything you\'ve learned - the Smart Plant Watering System!',
          tipEn: 'You earned the Screen Master badge!',
        ),
      ],
    ),
    InteractiveLesson(
      id: 'arduino_6_5',
      courseId: 'arduino',
      title: 'Final Proje: Akilli Bitki Sulama Sistemi',
      subtitle: 'Toprak nemi sensoru + LCD + role',
      titleEn: 'Final Project: Smart Plant Watering System',
      subtitleEn: 'Soil moisture sensor + LCD + relay',
      order: 16,
      xpReward: 160,
      badge: 'smart_garden_engineer',
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'a6_5_intro',
          mascotMessage: 'Ileri Seviye modulunun final projesindesin! Bu modulde ogrendigin HER SEYI birlestirecegiz: degiskenler, Serial Monitor, fonksiyonlar ve LCD ekran. Gercek bir problemi cozecegiz: bitkiler susadiginda kim anlayacak?',
          mascotEmoji: '🌱',
          highlights: [
            'Toprak nemi sensoru nasil calisir',
            'Once olc, sonra esik degeri belirle',
            'LCD\'de canli nem yuzdesi gosterme',
          ],
          mascotMessageEn: 'You\'ve reached the final project of the Advanced module! We\'ll combine EVERYTHING you learned here: variables, the Serial Monitor, functions, and the LCD screen. We\'ll solve a real problem: who notices when a plant gets thirsty?',
          highlightsEn: [
            'How a soil moisture sensor works',
            'Measure first, then decide on a threshold',
            'Showing live moisture percentage on the LCD',
          ],
        ),
        ExplanationStep(
          id: 'a6_5_exp1',
          title: 'Toprak Nemi Sensoru Nasil Calisir?',
          content: 'Toprak nemi sensoru, topraga batirilan iki metal ucun arasindaki elektrigi iletme kapasitesini olcer: toprak ne kadar nemliyse, o kadar iyi iletir.\n\nanalogRead() ile 0-1023 arasinda bir deger okursun. Sensorden sensore degerler degisebilir - bu yuzden mBlock\'ta yagmur sensorunde ogrendigin gibi ONCE OLCUP SONRA ESIK DEGERI BELIRLEMEK gerekir!\n\nKuru toprak genelde YUKSEK deger, islak toprak DUSUK deger verir (bu da sensore gore degisebilir - once test et).',
          tipEmoji: '🌾',
          tip: 'Profesyonel bir muhendis asla "internet boyle diyor" diye sabit bir esik degeri kullanmaz - her zaman kendi sensorunu test eder!',
          titleEn: 'How a Soil Moisture Sensor Works',
          contentEn: 'A soil moisture sensor measures how well electricity flows between two metal prongs stuck in the soil: the wetter the soil, the better it conducts.\n\nWith analogRead() you get a value between 0-1023. Values vary sensor to sensor - so just like the rain sensor lesson in mBlock, you must MEASURE FIRST, THEN DECIDE ON A THRESHOLD!\n\nDry soil usually gives a HIGH value, wet soil a LOW value (this can vary by sensor - always test first).',
          tipEn: 'A professional engineer never hardcodes a threshold just because "the internet says so" - they always test their own sensor!',
        ),
        ExplanationStep(
          id: 'a6_5_exp2',
          title: 'Sistemin Parcalarini Birlestirmek',
          content: 'Projemiz 3 parcadan olusuyor:\n\n1. Toprak nemi sensoru (A0 pininden analogRead)\n2. LCD ekran (nem yuzdesini goster)\n3. Role + su pompasi (nem dusukse pompayi calistir)\n\nAna mantik:\nint nem = analogRead(A0);\nint yuzde = map(nem, 1023, 300, 0, 100); // kalibre edilmis deger araligi\n\nif (yuzde < 30) {\n  digitalWrite(rolePin, HIGH); // pompa calissin\n} else {\n  digitalWrite(rolePin, LOW); // pompa dursun\n}\n\nmap() fonksiyonu, ham sensor degerini anlasilir bir yuzdeye cevirir!',
          tipEmoji: '🔧',
          tip: 'map()\'teki sayilar senin kendi olcumune gore degisir - bu yuzden once Seri Port ile ham degerleri gozlemlemelisin.',
          titleEn: 'Putting the System Pieces Together',
          contentEn: 'Our project has 3 parts:\n\n1. Soil moisture sensor (analogRead from pin A0)\n2. LCD screen (show the moisture percentage)\n3. Relay + water pump (run the pump if moisture is low)\n\nCore logic:\nint moisture = analogRead(A0);\nint percent = map(moisture, 1023, 300, 0, 100); // calibrated to your own readings\n\nif (percent < 30) {\n  digitalWrite(relayPin, HIGH); // run the pump\n} else {\n  digitalWrite(relayPin, LOW); // stop the pump\n}\n\nThe map() function turns the raw sensor value into an understandable percentage!',
          tipEn: 'The numbers inside map() depend on your own measurements - always observe the raw values through the Serial Monitor first.',
        ),
        MultipleChoiceStep(
          id: 'a6_5_q1',
          question: 'Toprak nemi sensorunun esik degerini belirlemeden once ne yapmaliyiz?',
          options: [
            ChoiceOption(text: 'Once Seri Port ile kuru ve islak toprak degerlerini olcmeliyiz', emoji: '✅'),
            ChoiceOption(text: 'Internetten bulunan sabit bir sayi kullanmaliyiz', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey, direkt kodlariz', emoji: '❌'),
            ChoiceOption(text: 'Sadece LCD\'ye bakmaliyiz', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Her sensor biraz farkli degerler uretebilir. Guvenilir bir sistem icin once kendi sensorunu kuru ve islak toprakta test edip gercek degerleri gozlemlemelisin.',
          questionEn: 'What should we do before deciding the soil moisture sensor\'s threshold?',
          explanationEn: 'Every sensor can give slightly different readings. For a reliable system, you must first test your own sensor in dry and wet soil and observe the real values.',
          xpReward: 15,
        ),
        ProjectStep(
          id: 'a6_5_project',
          title: 'Akilli Bitki Sulama Sistemi',
          description: 'Toprak nemi sensoru, LCD ekran ve role kullanarak toprak kuruyunca otomatik sulama yapan bir sistem kodla. LCD\'de anlik nem yuzdesini ve pompa durumunu goster.',
          requirements: [
            'analogRead ile A0 pininden nem degeri oku',
            'map() ile 0-100 arasi yuzdeye cevir',
            'LCD\'nin ilk satirinda nem yuzdesini goster',
            'LCD\'nin ikinci satirinda pompa durumunu (ACIK/KAPALI) goster',
            'Yuzde 30\'un altindaysa role/pompayi calistir, uzerindeyse durdur',
          ],
          hints: [
            'Once Serial.println ile ham degerleri gozlemleyip kendi esik degerini bul',
            'lcd.print() cagirmadan once lcd.setCursor() ile dogru konuma git',
            'Pompayi surekli acip kapatmamak icin delay ekle (ornek: 2000ms)',
          ],
          requirementsEn: [
            'Read the moisture value from pin A0 with analogRead',
            'Convert it to a 0-100 percentage with map()',
            'Show the moisture percentage on the LCD\'s first line',
            'Show the pump status (ON/OFF) on the LCD\'s second line',
            'Turn the relay/pump on below 30%, off above it',
          ],
          hintsEn: [
            'First observe the raw values with Serial.println to find your own threshold',
            'Always call lcd.setCursor() before lcd.print() to move to the right spot',
            'Add a delay (e.g. 2000ms) so the pump doesn\'t flicker on/off constantly',
          ],
          starterCode: '#include <LiquidCrystal_I2C.h>\nLiquidCrystal_I2C lcd(0x27, 16, 2);\nint nemPin = A0;\nint rolePin = 8;\n\nvoid setup() {\n  Serial.begin(9600);\n  lcd.init();\n  lcd.backlight();\n  pinMode(rolePin, OUTPUT);\n}\n\nvoid loop() {\n  // Buraya kodunu yaz\n}',
          language: 'cpp',
          validation: ProjectValidation(
            mustContain: ['analogRead', 'map(', 'lcd.print', 'rolePin'],
          ),
          descriptionEn: 'Code a system that automatically waters a plant using a soil moisture sensor, an LCD screen, and a relay. Show the live moisture percentage and pump status on the LCD.',
          titleEn: 'Smart Plant Watering System',
          xpReward: 80,
        ),
        ExplanationStep(
          id: 'a6_5_summary',
          title: '🎓 ILERI SEVIYE ARDUINO\'YU TAMAMLADIN!',
          content: '🌱🏆🌱 Blok kodlamadan gercek Arduino C++ koduna gectin ve profesyonel bir IoT projesi tamamladin!\n\n✓ setup()/loop() ve degiskenler\n✓ Serial Monitor ile hata ayiklama\n✓ Kendi fonksiyonlarini yazma\n✓ I2C LCD ekran kontrolu\n✓ Sensor + ekran + role birlesimi (gercek bir IoT sistemi!)\n\nBu becerilerle artik sicaklik takip sistemleri, guvenlik alarmlari veya kendi hayal ettigin herhangi bir akilli cihazi tasarlayabilirsin. Muhendisligin kapisi sonuna kadar acik!',
          tipEmoji: '🏆',
          tip: 'Ileri Seviye Arduino Muhendisi rozetini kazandin - bir sonraki hedefin kendi ozgun projeni tasarlamak!',
          titleEn: '🎓 YOU COMPLETED ADVANCED ARDUINO!',
          contentEn: '🌱🏆🌱 You went from block coding to real Arduino C++ and finished a professional IoT project!\n\n✓ setup()/loop() and variables\n✓ Debugging with the Serial Monitor\n✓ Writing your own functions\n✓ Controlling an I2C LCD screen\n✓ Combining a sensor + screen + relay (a real IoT system!)\n\nWith these skills you can now design temperature monitors, security alarms, or any smart device you can imagine. The door to engineering is wide open!',
          tipEn: 'You earned the Advanced Arduino Engineer badge - your next goal is designing your own original project!',
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
      ...module6,
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
      case 6:
        return module6;
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
    LessonBadge(
      id: 'arduino_coder',
      name: 'Kod Yazari',
      description: 'Bloklardan gercek Arduino C++ koduna gectin!',
      emoji: '💻',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
      nameEn: 'Code Writer',
      descriptionEn: 'You went from blocks to real Arduino C++ code!',
    ),
    LessonBadge(
      id: 'debug_master',
      name: 'Hata Avcisi',
      description: 'Seri Port ile degiskenleri izleyip hata ayikladin!',
      emoji: '🕵️',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
      nameEn: 'Bug Hunter',
      descriptionEn: 'You debugged code by watching variables with the Serial Monitor!',
    ),
    LessonBadge(
      id: 'arduino_function_master',
      name: 'Fonksiyon Ustasi',
      description: 'Kendi fonksiyonlarini yazip kod tekrarini azalttin!',
      emoji: '🧩',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
      nameEn: 'Function Master',
      descriptionEn: 'You wrote your own functions and reduced code repetition!',
    ),
    LessonBadge(
      id: 'lcd_master',
      name: 'Ekran Ustasi',
      description: 'I2C LCD ekranla projene mesaj gosterdin!',
      emoji: '📺',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
      nameEn: 'Screen Master',
      descriptionEn: 'You displayed messages on your project with an I2C LCD screen!',
    ),
    LessonBadge(
      id: 'smart_garden_engineer',
      name: 'Ileri Seviye Arduino Muhendisi',
      description: 'Sensor + ekran + role birlestiren akilli sulama sistemini tamamladin!',
      emoji: '🌱',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.course,
      nameEn: 'Advanced Arduino Engineer',
      descriptionEn: 'You completed a smart watering system combining a sensor, screen, and relay!',
    ),
  ];
}
