import '../models/interactive_lesson_model.dart';

/// Arduino Course - Interactive lessons for electronics and programming
/// Hands-on Arduino programming with sensors and actuators
class ArduinoLessonsData {
  // ==========================================
  // MODULE 1: ARDUINO'YA GİRİŞ
  // ==========================================
  static final List<InteractiveLesson> module1 = [
    // LESSON 1.1: Arduino Nedir?
    InteractiveLesson(
      id: 'arduino_1_1',
      courseId: 'arduino',
      title: 'Arduino\'ya Hos Geldin!',
      subtitle: 'Elektronik + Kod = Harika Projeler',
      order: 1,
      xpReward: 50,
      badge: 'arduino_starter',
      steps: [
        IntroStep(
          id: 'a1_1_intro',
          mascotEmoji: '🤖',
          mascotMessage: 'Merhaba! Arduino ile kod yazarak gercek dunyayi kontrol edeceksin! LED yakalim mi?',
          highlights: [
            'Fiziksel projeler yap',
            'Sensörler oku',
            'Motorlar kontrol et',
          ],
        ),

        ExplanationStep(
          id: 'a1_1_exp1',
          title: 'Arduino Nedir?',
          content: 'Arduino, elektronik projeleri kolayca yapabilmeni saglayan bir mikrodenetleyicidir. LED yakabilir, motor calistiirabilir, sensor okuyabilirsin!',
          tipEmoji: '💡',
          tip: 'Arduino sayesinde hayal ettigin her elektronik projeyi yapabilirsin!',
        ),

        ExplanationStep(
          id: 'a1_1_exp2',
          title: 'Arduino Pinleri',
          content: 'Arduino\'da iki tur pin var:\n\nDijital Pinler (0-13): Acik/Kapali (HIGH/LOW)\nAnalog Pinler (A0-A5): 0-1023 arasi degerler\n\nGND: Toprak (eksi)\n5V/3.3V: Arti (+) gerilim',
        ),

        MultipleChoiceStep(
          id: 'a1_1_q1',
          question: 'LED yakmak icin hangi pin turunu kullanirsin?',
          options: [
            ChoiceOption(text: 'Dijital Pin', emoji: '✅'),
            ChoiceOption(text: 'Analog Pin', emoji: '❌'),
            ChoiceOption(text: 'GND', emoji: '❌'),
            ChoiceOption(text: 'Hicbiri', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'LED acik veya kapali olabilir, bu yuzden Dijital Pin kullanilir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a1_1_summary',
          title: 'Arduino Baslangic!',
          content: '🤖 Arduino dunyasina hosgeldin!\n\n✓ Arduino\'yu tandin\n✓ Pin turlerini ogrendin\n✓ Ilk adimi attin\n\nSonraki ders: LED yakacagiz!',
          tipEmoji: '🏆',
          tip: 'Arduino Baslangic rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.2: İlk LED Projesi
    InteractiveLesson(
      id: 'arduino_1_2',
      courseId: 'arduino',
      title: 'Ilk LED Projesi',
      subtitle: 'LED yak, sondur!',
      order: 2,
      xpReward: 60,
      badge: 'led_master',
      steps: [
        IntroStep(
          id: 'a1_2_intro',
          mascotEmoji: '💡',
          mascotMessage: 'Simdiye kadar ekranda kod yazdik. Simdi gercek bir LED yakacagiz!',
        ),

        ExplanationStep(
          id: 'a1_2_exp1',
          title: 'pinMode() Komutu',
          content: 'Bir pini kullanmadan once tur belirtmeliyiz:\n\npinMode(pin_numarasi, INPUT);  // Giris\npinMode(pin_numarasi, OUTPUT); // Cikis\n\nOrnek:\npinMode(13, OUTPUT); // 13. pin cikis olsun',
          tipEmoji: '📌',
          tip: 'pinMode() sadece setup() fonksiyonunda bir kez yazilir!',
        ),

        MultipleChoiceStep(
          id: 'a1_2_q1',
          question: 'LED bagli pin 7\'yi cikis yapmak icin ne yazmaliyiz?',
          options: [
            ChoiceOption(text: 'pinMode(7, OUTPUT);', emoji: '✅'),
            ChoiceOption(text: 'pinMode(7, INPUT);', emoji: '❌'),
            ChoiceOption(text: 'digitalWrite(7, OUTPUT);', emoji: '❌'),
            ChoiceOption(text: 'pinMode(OUTPUT, 7);', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'pinMode(7, OUTPUT); dogru kullanim!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a1_2_exp2',
          title: 'digitalWrite() Komutu',
          content: 'Pini acmak veya kapamak icin:\n\ndigitalWrite(pin, HIGH);  // Pin acik (5V)\ndigitalWrite(pin, LOW);   // Pin kapali (0V)\n\nOrnek:\ndigitalWrite(13, HIGH); // LED yak\ndigitalWrite(13, LOW);  // LED sondur',
        ),

        TypeCodeStep(
          id: 'a1_2_type1',
          instruction: 'Pin 13\'teki LED\'i yakan kodu tamamla:',
          targetCode: 'void setup() {\n  pinMode(13, OUTPUT);\n}\n\nvoid loop() {\n  digitalWrite(13, HIGH);\n}',
          language: 'cpp',
          starterCode: 'void setup() {\n  // Pin 13\'u cikis yap\n}\n\nvoid loop() {\n  // LED\'i yak\n}',
          hints: [
            'setup() icinde pinMode(13, OUTPUT);',
            'loop() icinde digitalWrite(13, HIGH);',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'a1_2_exp3',
          title: 'delay() - Bekleme',
          content: 'Kodu belirli sure bekletmek icin:\n\ndelay(1000); // 1000 milisaniye = 1 saniye bekle\n\nYanip sonen LED:\ndigitalWrite(13, HIGH);\ndelay(1000);\ndigitalWrite(13, LOW);\ndelay(1000);',
          tipEmoji: '⏱️',
          tip: 'delay() milisaniye cinsinden sure alir. 1000ms = 1 saniye',
        ),

        TypeCodeStep(
          id: 'a1_2_type2',
          instruction: 'Pin 13\'teki LED\'i 1 saniye arayla yanip sonduren kod yaz:',
          targetCode: 'void setup() {\n  pinMode(13, OUTPUT);\n}\n\nvoid loop() {\n  digitalWrite(13, HIGH);\n  delay(1000);\n  digitalWrite(13, LOW);\n  delay(1000);\n}',
          language: 'cpp',
          hints: [
            'HIGH yap, 1000ms bekle',
            'LOW yap, 1000ms bekle',
            'loop() surekli tekrar eder!',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'a1_2_summary',
          title: 'LED Ustasi!',
          content: '💡 Ilk Arduino projenizi tamamladin!\n\n✓ pinMode() ile pin turu belirledin\n✓ digitalWrite() ile LED yaktın\n✓ delay() ile bekleme yaptın\n\nArtik gercek LED kontrol edebilirsin!',
          tipEmoji: '🏆',
          tip: 'LED Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 2: DİJİTAL GİRİŞ VE BUTONLAR
  // ==========================================
  static final List<InteractiveLesson> module2 = [
    // LESSON 2.1: Buton Okuma
    InteractiveLesson(
      id: 'arduino_2_1',
      courseId: 'arduino',
      title: 'Buton Okuma',
      subtitle: 'Butona basinca LED yak!',
      order: 3,
      xpReward: 70,
      badge: 'button_reader',
      steps: [
        IntroStep(
          id: 'a2_1_intro',
          mascotEmoji: '🔘',
          mascotMessage: 'Simdi Arduino\'ya veri gonderecegiz! Butona basinca LED yakacagiz!',
        ),

        ExplanationStep(
          id: 'a2_1_exp1',
          title: 'digitalRead() Komutu',
          content: 'Bir pinii okumak icin:\n\nint deger = digitalRead(pin);\n\nDegerler:\nHIGH (1): Buton basilmis / 5V var\nLOW (0): Buton basilmamis / 0V var',
          tipEmoji: '📖',
          tip: 'Okuyacagimiz pini pinMode(pin, INPUT); yapmayi unutma!',
        ),

        MultipleChoiceStep(
          id: 'a2_1_q1',
          question: 'Pin 2\'yi okumak icin once ne yapmaliyiz?',
          options: [
            ChoiceOption(text: 'pinMode(2, INPUT);', emoji: '✅'),
            ChoiceOption(text: 'pinMode(2, OUTPUT);', emoji: '❌'),
            ChoiceOption(text: 'digitalWrite(2, HIGH);', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Okuma yapacaksak pini INPUT yapmamiz gerek!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a2_1_exp2',
          title: 'Buton ile LED Kontrolu',
          content: 'Butona basildiginda LED yakan kod:\n\nint butonDurumu = digitalRead(2);\n\nif (butonDurumu == HIGH) {\n  digitalWrite(13, HIGH); // LED yak\n} else {\n  digitalWrite(13, LOW);  // LED sondur\n}',
        ),

        TypeCodeStep(
          id: 'a2_1_type1',
          instruction: 'Pin 2\'deki butona basilinca pin 13\'teki LED\'i yakan kod yaz:',
          targetCode: 'void setup() {\n  pinMode(2, INPUT);\n  pinMode(13, OUTPUT);\n}\n\nvoid loop() {\n  int butonDurumu = digitalRead(2);\n  if (butonDurumu == HIGH) {\n    digitalWrite(13, HIGH);\n  } else {\n    digitalWrite(13, LOW);\n  }\n}',
          language: 'cpp',
          hints: [
            'Pin 2 INPUT, Pin 13 OUTPUT',
            'digitalRead(2) ile oku',
            'HIGH ise LED yak, degilse sondur',
          ],
          xpReward: 30,
        ),

        ExplanationStep(
          id: 'a2_1_summary',
          title: 'Buton Okuyucu!',
          content: '🔘 Artik girdi okuyabilirsin!\n\n✓ digitalRead() ile buton okudun\n✓ INPUT pin modu kullandin\n✓ if-else ile kontrol yaptın\n\nSonraki: Pull-up resistor!',
          tipEmoji: '🏆',
          tip: 'Buton Okuyucu rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 3: ANALOG GİRİŞ VE PWM
  // ==========================================
  static final List<InteractiveLesson> module3 = [
    // LESSON 3.1: Analog Okuma
    InteractiveLesson(
      id: 'arduino_3_1',
      courseId: 'arduino',
      title: 'Analog Okuma',
      subtitle: 'Potansiyometre ve sensorler',
      order: 4,
      xpReward: 80,
      badge: 'analog_reader',
      steps: [
        IntroStep(
          id: 'a3_1_intro',
          mascotEmoji: '📊',
          mascotMessage: 'Dijital sadece 0 veya 1\'di. Analog ise 0-1023 arasi herhangi bir deger!',
        ),

        ExplanationStep(
          id: 'a3_1_exp1',
          title: 'analogRead() Komutu',
          content: 'Analog pin okumak icin:\n\nint deger = analogRead(A0);\n\nDegerler: 0-1023 arasi\n0 = 0V\n1023 = 5V\n512 = yaklaşik 2.5V',
          tipEmoji: '📈',
          tip: 'Analog pinler A0, A1, A2... seklinde isimlendirilir!',
        ),

        MultipleChoiceStep(
          id: 'a3_1_q1',
          question: 'analogRead(A0) ne dondurur?',
          options: [
            ChoiceOption(text: '0-1023 arasi sayi', emoji: '✅'),
            ChoiceOption(text: 'Sadece 0 veya 1', emoji: '❌'),
            ChoiceOption(text: '0-255 arasi sayi', emoji: '❌'),
            ChoiceOption(text: 'HIGH veya LOW', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'analogRead() 0-1023 arasi bir tamsayi dondurur!',
          xpReward: 10,
        ),

        TypeCodeStep(
          id: 'a3_1_type1',
          instruction: 'A0 pinini okuyup Serial Monitor\'a yazdiran kod yaz:',
          targetCode: 'void setup() {\n  Serial.begin(9600);\n}\n\nvoid loop() {\n  int deger = analogRead(A0);\n  Serial.println(deger);\n  delay(100);\n}',
          language: 'cpp',
          hints: [
            'Serial.begin(9600) ile baslat',
            'analogRead(A0) ile oku',
            'Serial.println() ile yazdir',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'a3_1_summary',
          title: 'Analog Okuyucu!',
          content: '📊 Analog degerler okuyabilirsin!\n\n✓ analogRead() kullandin\n✓ 0-1023 arasi degerleri anladın\n✓ Serial Monitor\'a yazdırdin\n\nSonraki: PWM ile analog cikis!',
          tipEmoji: '🏆',
          tip: 'Analog Okuyucu rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 3.2: PWM ve LED Parlakligi
    InteractiveLesson(
      id: 'arduino_3_2',
      courseId: 'arduino',
      title: 'PWM - Analog Cikis',
      subtitle: 'LED parlakligini ayarla',
      order: 5,
      xpReward: 90,
      badge: 'pwm_master',
      steps: [
        IntroStep(
          id: 'a3_2_intro',
          mascotEmoji: '🔆',
          mascotMessage: 'PWM ile LED\'in parlakligini ayarlayacagiz! 0\'dan 255\'e kadar!',
        ),

        ExplanationStep(
          id: 'a3_2_exp1',
          title: 'analogWrite() Komutu',
          content: 'PWM pinlere analog deger yazmak icin:\n\nanalogWrite(pin, deger);\n\nDegerler: 0-255\n0 = Tamamen kapali\n127 = Yarim parlaklik\n255 = Tam parlaklik\n\nPWM pinleri: 3, 5, 6, 9, 10, 11 (~isaretli)',
          tipEmoji: '⚡',
          tip: 'PWM aslinda cok hizli yanip sondurmedir! Goz fark etmez.',
        ),

        MultipleChoiceStep(
          id: 'a3_2_q1',
          question: 'Pin 9\'a %50 parlaklik vermek icin ne yazmaliyiz?',
          options: [
            ChoiceOption(text: 'analogWrite(9, 127);', emoji: '✅'),
            ChoiceOption(text: 'analogWrite(9, 255);', emoji: '❌'),
            ChoiceOption(text: 'digitalWrite(9, 127);', emoji: '❌'),
            ChoiceOption(text: 'analogWrite(9, 50);', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '%50 = 255 / 2 = 127 (yaklasik). analogWrite(9, 127) dogru!',
          xpReward: 10,
        ),

        TypeCodeStep(
          id: 'a3_2_type1',
          instruction: 'Pin 9\'daki LED\'i gittikce parlatlastiiran kod yaz:',
          targetCode: 'void setup() {\n  pinMode(9, OUTPUT);\n}\n\nvoid loop() {\n  for (int i = 0; i <= 255; i++) {\n    analogWrite(9, i);\n    delay(10);\n  }\n}',
          language: 'cpp',
          hints: [
            'for dongusu kullan: 0\'dan 255\'e',
            'Her adimda analogWrite(9, i)',
            'Gorulebilmesi icin kucuk delay ekle',
          ],
          xpReward: 30,
        ),

        ExplanationStep(
          id: 'a3_2_summary',
          title: 'PWM Ustasi!',
          content: '🔆 PWM kontrol edebilirsin!\n\n✓ analogWrite() kullandin\n✓ LED parlakligini ayarladin\n✓ for dongusu ile animasyon yaptın\n\nArtik analog cikis yapabilirsin!',
          tipEmoji: '🏆',
          tip: 'PWM Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 4: SERVO MOTOR
  // ==========================================
  static final List<InteractiveLesson> module4 = [
    InteractiveLesson(
      id: 'arduino_4_1',
      courseId: 'arduino',
      title: 'Servo Motor',
      subtitle: 'Hareket ettir, kontrol et',
      order: 7,
      xpReward: 100,
      badge: 'servo_master',
      steps: [
        IntroStep(
          id: 'a4_1_intro',
          mascotEmoji: '🦾',
          mascotMessage: 'Servo motorlar robot kollarinda, kapilarda kullanilir! Simdi servo motorunu kontrol etmeyi ogrenelim!',
        ),

        ExplanationStep(
          id: 'a4_1_exp1',
          title: 'Servo Motor Nedir?',
          content: 'Servo motor, belirli acilarla donus yapabilen bir motortur.\n\n📐 Aci araligi: 0-180 derece\n🎯 Hassas kontrol\n🦾 Robot, kapi, mekanizma\n\nOrnek kullanim:\n• Robot kollari\n• Kamera platformlari\n• Kapi kilitleri',
          tipEmoji: '🔧',
          tip: 'Servo motor 3 pine sahiptir: VCC (kirmizi), GND (siyah/kahve), Signal (turuncu/sari)',
        ),

        MultipleChoiceStep(
          id: 'a4_1_q1',
          question: 'Servo motor kac derece donebilir?',
          options: [
            ChoiceOption(text: '0-90 derece', emoji: '📐'),
            ChoiceOption(text: '0-180 derece', emoji: '✅'),
            ChoiceOption(text: '0-360 derece', emoji: '🔄'),
            ChoiceOption(text: 'Sinirsiz', emoji: '♾️'),
          ],
          correctIndex: 1,
          explanation: 'Standart servo motorlar 0-180 derece arasinda hareket eder!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a4_1_exp2',
          title: 'Servo Baglantisi',
          content: 'Servo motor baglantisi:\n\n🔴 Kirmizi (VCC) → 5V\n⚫ Siyah/Kahve (GND) → GND\n🟠 Turuncu/Sari (Signal) → Pin 9\n\nKutuphanenin icindeki hazirlari:\n#include <Servo.h>\nServo myservo;\nmyservo.attach(9);',
          tipEmoji: '⚠️',
          tip: 'Servo motor cok akim ceker! Buyuk servolar icin harici guc kaynagi kullan.',
        ),

        TypeCodeStep(
          id: 'a4_1_type1',
          instruction: 'Servo motoru 90 dereceye getiren kodu yaz:',
          targetCode: '#include <Servo.h>\n\nServo myservo;\n\nvoid setup() {\n  myservo.attach(9);\n  myservo.write(90);\n}\n\nvoid loop() {\n  // Bos\n}',
          language: 'cpp',
          hints: [
            'Servo.h kutuphanesini ekle',
            'Servo nesnesi olustur',
            'attach(9) ile pin 9\'a bagla',
            'write(90) ile 90 dereceye getir',
          ],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 'a4_1_exp3',
          title: 'Servo Komutlari',
          content: 'Servo motor fonksiyonlari:\n\n• myservo.attach(pin): Servo pini bagla\n• myservo.write(aci): Aciya git (0-180)\n• myservo.read(): Mevcut aciyi oku\n• myservo.detach(): Servoyu ayir',
        ),

        ProjectStep(
          id: 'a4_1_project',
          title: 'Mini Proje: Servo Sweep',
          description: 'Servo 0-180 derece gidip gelsin!',
          requirements: [
            'Servo 0 dereceden 180 dereceye gitsin',
            'Her aci arasi 15ms beklesin',
            '180 dereceden 0\'a geri donsin',
            'Surekli tekrarlasin',
          ],
          hints: [
            'for dongusu kullan',
            'delay(15) ile bekle',
            'Ileri ve geri iki dongu yap',
          ],
          starterCode: '#include <Servo.h>\\n\\nServo myservo;\\n\\nvoid setup() {\\n  myservo.attach(9);\\n}\\n\\nvoid loop() {\\n  // Buraya kod yaz\\n}',
          language: 'cpp',
          validation: ProjectValidation(
            mustContain: ['for', 'write', 'delay'],
          ),
          xpReward: 40,
        ),

        ExplanationStep(
          id: 'a4_1_summary',
          title: 'Servo Ustasi!',
          content: '🦾 Artik servo motor kontrol edebilirsin!\n\n✓ Servo baglantisi\n✓ Aci kontrolu\n✓ Sweep hareketi\n\nSonraki: Ses ve buzzer!',
          tipEmoji: '🏆',
          tip: 'Servo Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 5: SES VE BUZZER
  // ==========================================
  static final List<InteractiveLesson> module5 = [
    InteractiveLesson(
      id: 'arduino_5_1',
      courseId: 'arduino',
      title: 'Buzzer ve Ses',
      subtitle: 'Ses cikart, melodi cal',
      order: 8,
      xpReward: 95,
      badge: 'sound_maker',
      steps: [
        IntroStep(
          id: 'a5_1_intro',
          mascotEmoji: '🔊',
          mascotMessage: 'Buzzer ile ses cikartabilir, melodiler calabilirsin! Haydi Arduino\'yu konusturalim!',
        ),

        ExplanationStep(
          id: 'a5_1_exp1',
          title: 'Buzzer Nedir?',
          content: 'Buzzer, ses cikaran elektronik bir bilesenidir.\n\n🔊 Aktif Buzzer: Tek ses cikarir\n🎵 Pasif Buzzer: Farkli frekanslar calabilir\n\nKullanim alanlari:\n• Alarm sistemleri\n• Bildirim sesleri\n• Muzik calma',
          tipEmoji: '🎶',
          tip: 'Pasif buzzer kullan, daha cok sey yapabilirsin!',
        ),

        MultipleChoiceStep(
          id: 'a5_1_q1',
          question: 'Hangi buzzer farkli notalar calabilir?',
          options: [
            ChoiceOption(text: 'Aktif buzzer', emoji: '🔴'),
            ChoiceOption(text: 'Pasif buzzer', emoji: '✅'),
            ChoiceOption(text: 'Her ikisi de', emoji: '🎵'),
            ChoiceOption(text: 'Hicbiri', emoji: '❌'),
          ],
          correctIndex: 1,
          explanation: 'Pasif buzzer farkli frekanslarda ses cikarabilir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'a5_1_exp2',
          title: 'Buzzer Baglantisi',
          content: 'Buzzer baglantisi:\n\n🔴 Kirmizi (pozitif) → Pin 8\n⚫ Siyah (negatif) → GND\n\nKod:\ntone(pin, frekans);\ntone(8, 440); // La notasi (A)\ndelay(1000);\nnoTone(8); // Sesi durdur',
        ),

        ExplanationStep(
          id: 'a5_1_exp3',
          title: 'Muzik Notalari',
          content: 'Her nota bir frekanstir:\n\n• Do (C): 262 Hz\n• Re (D): 294 Hz\n• Mi (E): 330 Hz\n• Fa (F): 349 Hz\n• Sol (G): 392 Hz\n• La (A): 440 Hz\n• Si (B): 494 Hz',
          tipEmoji: '🎹',
          tip: 'Bu frekanslari ezberle, melodi yapabilirsin!',
        ),

        TypeCodeStep(
          id: 'a5_1_type1',
          instruction: 'Do-Re-Mi melodisi cal:',
          targetCode: '#define BUZZER 8\n\nvoid setup() {\n  tone(BUZZER, 262); // Do\n  delay(500);\n  tone(BUZZER, 294); // Re\n  delay(500);\n  tone(BUZZER, 330); // Mi\n  delay(500);\n  noTone(BUZZER);\n}\n\nvoid loop() {\n  // Bos\n}',
          language: 'cpp',
          hints: [
            '#define ile pin tanimla',
            'tone() fonksiyonu ile nota cal',
            'delay() ile bekle',
            'noTone() ile durdur',
          ],
          xpReward: 25,
        ),

        ProjectStep(
          id: 'a5_1_project',
          title: 'Mini Proje: Melodili Alarm',
          description: 'Buton basilinca alarm cals!',
          requirements: [
            'Buton pin 2\'ye baglan',
            'Buzzer pin 8\'e baglan',
            'Buton basilinca 3 notali alarm cals',
            'Alarm bitince sesi durdur',
          ],
          hints: [
            'digitalRead() ile buton oku',
            'if ile kontrol et',
            'tone() ile alarm melodisi',
          ],
          starterCode: '#define BUZZER 8\\n#define BUTTON 2\\n\\nvoid setup() {\\n  pinMode(BUZZER, OUTPUT);\\n  pinMode(BUTTON, INPUT_PULLUP);\\n}\\n\\nvoid loop() {\\n  // Buraya kod yaz\\n}',
          language: 'cpp',
          validation: ProjectValidation(
            mustContain: ['digitalRead', 'tone', 'if'],
          ),
          xpReward: 40,
        ),

        ExplanationStep(
          id: 'a5_1_summary',
          title: 'Ses Yapimcisi!',
          content: '🔊 Artik Arduino ile ses calabilirsin!\n\n✓ Buzzer kullanimi\n✓ Frekans kontrolu\n✓ Melodi yaratma\n\nTebrikler! Arduino temellerini bitirdin!',
          tipEmoji: '🏆',
          tip: 'Ses Yapimcisi rozetini kazandin!',
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
      description: 'Arduino dunyasina adim attin!',
      emoji: '🤖',
      rarity: BadgeRarity.common,
      category: BadgeCategory.lesson,
    ),
    LessonBadge(
      id: 'led_master',
      name: 'LED Ustasi',
      description: 'Ilk LED\'ini yaktın!',
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
      id: 'analog_reader',
      name: 'Analog Okuyucu',
      description: 'Analog degerler okudun!',
      emoji: '📊',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'pwm_master',
      name: 'PWM Ustasi',
      description: 'PWM ile analog cikis yaptın!',
      emoji: '🔆',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'servo_master',
      name: 'Servo Ustasi',
      description: 'Servo motor kontrol ettin!',
      emoji: '🦾',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'sound_maker',
      name: 'Ses Yapimcisi',
      description: 'Buzzer ile melodi caldin!',
      emoji: '🔊',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
  ];
}
