import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

/// Arduino Projeleri Eğitim Ekranı
/// Başlangıç seviyesinden başlayan Arduino projeleri ve eğitimleri
class ArduinoSimulatorMainScreen extends StatefulWidget {
  const ArduinoSimulatorMainScreen({super.key});

  @override
  State<ArduinoSimulatorMainScreen> createState() => _ArduinoSimulatorMainScreenState();
}

class _ArduinoSimulatorMainScreenState extends State<ArduinoSimulatorMainScreen> {
  String _selectedCategory = 'all';

  final List<ArduinoProject> _projects = [
    // LED Projeleri
    ArduinoProject(
      id: '1',
      title: 'İlk LED Yakma',
      description: 'Arduino ile ilk programınızı yazın ve bir LED yakın',
      category: 'led',
      difficulty: 'Başlangıç',
      duration: '15 dk',
      icon: Icons.lightbulb,
      color: const Color(0xFFFFD700),
      components: ['Arduino Uno', '1x LED', '1x 220Ω Direnç', 'Breadboard', 'Jumper Kablolar'],
      steps: [
        'LED\'in uzun bacağını (anot) breadboard\'a takın',
        '220Ω direnci LED\'in kısa bacağına (katot) bağlayın',
        'Direncin diğer ucunu GND\'ye bağlayın',
        'LED\'in uzun bacağını Arduino\'nun pin 13\'üne bağlayın',
        'Arduino IDE\'yi açın ve kodu yazın',
        'Kodu Arduino\'ya yükleyin',
      ],
      code: '''void setup() {
  pinMode(13, OUTPUT);
}

void loop() {
  digitalWrite(13, HIGH);   // LED'i yak
  delay(1000);              // 1 saniye bekle
  digitalWrite(13, LOW);    // LED'i söndür
  delay(1000);              // 1 saniye bekle
}''',
      learningPoints: [
        'pinMode() fonksiyonu pinleri giriş veya çıkış olarak ayarlar',
        'digitalWrite() fonksiyonu dijital pinlere HIGH (5V) veya LOW (0V) yazar',
        'delay() fonksiyonu milisaniye cinsinden bekleme süresi ekler',
      ],
    ),
    ArduinoProject(
      id: '2',
      title: 'RGB LED Kontrolü',
      description: 'RGB LED ile renk karışımları oluşturun',
      category: 'led',
      difficulty: 'Orta',
      duration: '30 dk',
      icon: Icons.palette,
      color: const Color(0xFFE91E63),
      components: ['Arduino Uno', '1x RGB LED', '3x 220Ω Direnç', 'Breadboard', 'Jumper Kablolar'],
      steps: [
        'RGB LED\'in ortak katodunu GND\'ye bağlayın',
        'Kırmızı pini 220Ω direnç ile pin 9\'a bağlayın',
        'Yeşil pini 220Ω direnç ile pin 10\'a bağlayın',
        'Mavi pini 220Ω direnç ile pin 11\'e bağlayın',
        'Kodu Arduino\'ya yükleyin',
      ],
      code: '''int redPin = 9;
int greenPin = 10;
int bluePin = 11;

void setup() {
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
}

void loop() {
  setColor(255, 0, 0);     // Kırmızı
  delay(1000);
  setColor(0, 255, 0);     // Yeşil
  delay(1000);
  setColor(0, 0, 255);     // Mavi
  delay(1000);
  setColor(255, 255, 0);   // Sarı
  delay(1000);
  setColor(255, 0, 255);   // Mor
  delay(1000);
  setColor(0, 255, 255);   // Cyan
  delay(1000);
}

void setColor(int red, int green, int blue) {
  analogWrite(redPin, red);
  analogWrite(greenPin, green);
  analogWrite(bluePin, blue);
}''',
      learningPoints: [
        'RGB LED\'ler kırmızı, yeşil ve mavi ışığı karıştırarak farklı renkler oluşturur',
        'analogWrite() fonksiyonu 0-255 arası PWM değerleri ile parlaklık kontrolü sağlar',
        'Fonksiyon tanımlama ve kullanma',
      ],
    ),

    // Sensör Projeleri
    ArduinoProject(
      id: '3',
      title: 'Buton ile LED Kontrolü',
      description: 'Buton ile LED yakma söndürme',
      category: 'sensor',
      difficulty: 'Başlangıç',
      duration: '20 dk',
      icon: Icons.touch_app,
      color: const Color(0xFF2196F3),
      components: ['Arduino Uno', '1x LED', '1x Buton', '1x 220Ω Direnç', '1x 10kΩ Direnç', 'Breadboard'],
      steps: [
        'Butonu breadboard\'a yerleştirin',
        'Butonun bir bacağını 10kΩ direnç ile GND\'ye bağlayın',
        'Butonun aynı bacağını pin 2\'ye bağlayın',
        'Butonun diğer bacağını 5V\'a bağlayın',
        'LED\'i 220Ω direnç ile pin 13\'e bağlayın',
      ],
      code: '''const int buttonPin = 2;
const int ledPin = 13;

int buttonState = 0;

void setup() {
  pinMode(ledPin, OUTPUT);
  pinMode(buttonPin, INPUT);
}

void loop() {
  buttonState = digitalRead(buttonPin);

  if (buttonState == HIGH) {
    digitalWrite(ledPin, HIGH);  // Butona basılı, LED yak
  } else {
    digitalWrite(ledPin, LOW);   // Butona basılı değil, LED söndür
  }
}''',
      learningPoints: [
        'digitalRead() fonksiyonu dijital pinlerin durumunu okur',
        'Pull-down direnci kullanımı',
        'if-else koşul yapıları',
      ],
    ),
    ArduinoProject(
      id: '4',
      title: 'Mesafe Ölçüm (Ultrasonic)',
      description: 'HC-SR04 sensörü ile mesafe ölçümü',
      category: 'sensor',
      difficulty: 'Orta',
      duration: '35 dk',
      icon: Icons.straighten,
      color: const Color(0xFF4CAF50),
      components: ['Arduino Uno', '1x HC-SR04 Ultrasonic Sensör', 'Breadboard', 'Jumper Kablolar'],
      steps: [
        'HC-SR04\'ün VCC pinini Arduino 5V\'a bağlayın',
        'GND pinini Arduino GND\'ye bağlayın',
        'Trig pinini Arduino pin 9\'a bağlayın',
        'Echo pinini Arduino pin 10\'a bağlayın',
        'Serial Monitor\'ü açın (115200 baud)',
      ],
      code: '''const int trigPin = 9;
const int echoPin = 10;

long duration;
int distance;

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(115200);
}

void loop() {
  // Temiz bir sinyal için trig pinini temizle
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  // 10 mikrosaniyelik ultrasonik sinyal gönder
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  // Echo pininden sinyalin dönüş süresini ölç
  duration = pulseIn(echoPin, HIGH);

  // Mesafeyi hesapla (cm cinsinden)
  distance = duration * 0.034 / 2;

  // Sonucu serial monitöre yazdır
  Serial.print("Mesafe: ");
  Serial.print(distance);
  Serial.println(" cm");

  delay(500);
}''',
      learningPoints: [
        'Ultrasonik sensörler ses dalgaları ile mesafe ölçer',
        'Serial iletişim ile veri gönderme',
        'pulseIn() fonksiyonu kullanımı',
      ],
    ),

    // Motor Projeleri
    ArduinoProject(
      id: '5',
      title: 'DC Motor Kontrolü',
      description: 'L298N motor sürücü ile DC motor kontrolü',
      category: 'motor',
      difficulty: 'Orta',
      duration: '40 dk',
      icon: Icons.settings,
      color: const Color(0xFFFF9800),
      components: ['Arduino Uno', '1x DC Motor', '1x L298N Motor Sürücü', '9V Batarya', 'Jumper Kablolar'],
      steps: [
        'L298N motor sürücünün IN1 pinini Arduino pin 8\'e bağlayın',
        'IN2 pinini Arduino pin 9\'a bağlayın',
        'ENA pinini Arduino pin 10\'a bağlayın',
        'Motor çıkışlarına DC motoru bağlayın',
        '9V bataryayı motor sürücüye bağlayın',
        'GND\'leri ortak bağlayın',
      ],
      code: '''const int motorPin1 = 8;
const int motorPin2 = 9;
const int enablePin = 10;

void setup() {
  pinMode(motorPin1, OUTPUT);
  pinMode(motorPin2, OUTPUT);
  pinMode(enablePin, OUTPUT);
}

void loop() {
  // İleri yön - Tam hız
  digitalWrite(motorPin1, HIGH);
  digitalWrite(motorPin2, LOW);
  analogWrite(enablePin, 255);
  delay(2000);

  // Dur
  analogWrite(enablePin, 0);
  delay(1000);

  // Geri yön - Yarı hız
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, HIGH);
  analogWrite(enablePin, 128);
  delay(2000);

  // Dur
  analogWrite(enablePin, 0);
  delay(1000);
}''',
      learningPoints: [
        'Motor sürücüler yüksek akım gerektiren motorları kontrol eder',
        'PWM ile hız kontrolü yapılabilir',
        'H-Bridge mantığı ile yön kontrolü',
      ],
    ),

    // Ekran Projeleri
    ArduinoProject(
      id: '6',
      title: 'LCD Ekran Kullanımı',
      description: '16x2 LCD ekranda yazı gösterme',
      category: 'display',
      difficulty: 'Orta',
      duration: '30 dk',
      icon: Icons.tv,
      color: const Color(0xFF9C27B0),
      components: ['Arduino Uno', '16x2 LCD Ekran', '10kΩ Potansiyometre', 'Breadboard', 'Jumper Kablolar'],
      steps: [
        'LCD\'nin VSS pinini GND\'ye bağlayın',
        'VDD pinini 5V\'a bağlayın',
        'V0 pinini potansiyometreye bağlayın (kontrast ayarı)',
        'RS pinini Arduino pin 12\'ye bağlayın',
        'RW pinini GND\'ye bağlayın',
        'E pinini Arduino pin 11\'e bağlayın',
        'D4, D5, D6, D7 pinlerini Arduino 5, 4, 3, 2 pinlerine bağlayın',
        'A (anode) pinini 5V\'a, K (katot) pinini GND\'ye bağlayın',
      ],
      code: '''#include <LiquidCrystal.h>

// LCD pinleri: RS, E, D4, D5, D6, D7
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup() {
  // 16 sütun, 2 satırlık LCD\'yi başlat
  lcd.begin(16, 2);

  // İlk satıra mesaj yaz
  lcd.print("Arduino LCD");

  // İkinci satıra geç
  lcd.setCursor(0, 1);
  lcd.print("Merhaba Dunya!");
}

void loop() {
  // İkinci satırda sayaç göster
  lcd.setCursor(0, 1);
  lcd.print("Sayac: ");
  lcd.print(millis() / 1000);
  lcd.print("s ");
  delay(100);
}''',
      learningPoints: [
        'LCD kütüphanesi kullanımı',
        'setCursor() ile imleç konumu ayarlama',
        'millis() fonksiyonu ile zaman ölçümü',
      ],
    ),

    // Ses Projeleri
    ArduinoProject(
      id: '7',
      title: 'Buzzer ile Melodi Çalma',
      description: 'Piezo buzzer ile basit melodiler',
      category: 'sound',
      difficulty: 'Başlangıç',
      duration: '25 dk',
      icon: Icons.music_note,
      color: const Color(0xFF00BCD4),
      components: ['Arduino Uno', '1x Piezo Buzzer', 'Breadboard', 'Jumper Kablolar'],
      steps: [
        'Buzzer\'ın pozitif (+) bacağını Arduino pin 8\'e bağlayın',
        'Negatif (-) bacağını GND\'ye bağlayın',
        'Kodu yükleyin ve melodiyi dinleyin',
      ],
      code: '''#define NOTE_C4  262
#define NOTE_D4  294
#define NOTE_E4  330
#define NOTE_F4  349
#define NOTE_G4  392
#define NOTE_A4  440
#define NOTE_B4  494
#define NOTE_C5  523

const int buzzerPin = 8;

// Melodi notaları
int melody[] = {
  NOTE_C4, NOTE_G4, NOTE_G4, NOTE_A4, NOTE_G4, 0, NOTE_B4, NOTE_C5
};

// Nota süreleri: 4 = çeyrek nota, 8 = sekizlik nota
int noteDurations[] = {
  4, 8, 8, 4, 4, 4, 4, 4
};

void setup() {
  // Melodiyi çal
  for (int i = 0; i < 8; i++) {
    int noteDuration = 1000 / noteDurations[i];
    tone(buzzerPin, melody[i], noteDuration);

    int pauseBetweenNotes = noteDuration * 1.30;
    delay(pauseBetweenNotes);

    noTone(buzzerPin);
  }
}

void loop() {
  // Tek seferlik çalma
}''',
      learningPoints: [
        'tone() fonksiyonu ile ses frekansı üretme',
        'Dizi (array) kullanımı',
        'Müzikal notaların frekansları',
      ],
    ),

    // İleri Seviye
    ArduinoProject(
      id: '8',
      title: 'Sıcaklık ve Nem Ölçer',
      description: 'DHT11 sensörü ile sıcaklık ve nem takibi',
      category: 'sensor',
      difficulty: 'İleri',
      duration: '45 dk',
      icon: Icons.thermostat,
      color: const Color(0xFFF44336),
      components: ['Arduino Uno', '1x DHT11 Sensör', '1x 10kΩ Direnç', 'Breadboard', 'Jumper Kablolar'],
      steps: [
        'DHT11\'in VCC pinini 5V\'a bağlayın',
        'GND pinini GND\'ye bağlayın',
        'DATA pinini Arduino pin 2\'ye bağlayın',
        '10kΩ pull-up direncini VCC ve DATA arasına bağlayın',
        'DHT kütüphanesini Arduino IDE\'ye yükleyin',
        'Serial Monitor\'ü açın',
      ],
      code: '''#include <DHT.h>

#define DHTPIN 2
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  Serial.println("DHT11 Sensör Testi");
  dht.begin();
}

void loop() {
  // 2 saniye bekle
  delay(2000);

  // Nem oranını oku
  float h = dht.readHumidity();

  // Sıcaklığı Celsius olarak oku
  float t = dht.readTemperature();

  // Okuma hatası kontrolü
  if (isnan(h) || isnan(t)) {
    Serial.println("DHT sensöründen okuma hatası!");
    return;
  }

  // Sonuçları ekrana yazdır
  Serial.print("Nem: ");
  Serial.print(h);
  Serial.print("%  ");
  Serial.print("Sıcaklık: ");
  Serial.print(t);
  Serial.println("°C");
}''',
      learningPoints: [
        'Harici kütüphane yükleme ve kullanma',
        'Sensör verilerini okuma ve işleme',
        'Hata kontrolü (isnan fonksiyonu)',
      ],
    ),
  ];

  List<ArduinoProject> get filteredProjects {
    if (_selectedCategory == 'all') {
      return _projects;
    }
    return _projects.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Arduino Projeleri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Başlangıçtan İleri Seviyeye',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00979D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: filteredProjects.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectCard(filteredProjects[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      color: const Color(0xFF00979D),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildCategoryChip('all', 'Tümü', Icons.apps),
            const SizedBox(width: 8),
            _buildCategoryChip('led', 'LED', Icons.lightbulb_outline),
            const SizedBox(width: 8),
            _buildCategoryChip('sensor', 'Sensörler', Icons.sensors),
            const SizedBox(width: 8),
            _buildCategoryChip('motor', 'Motor', Icons.settings),
            const SizedBox(width: 8),
            _buildCategoryChip('display', 'Ekran', Icons.tv),
            const SizedBox(width: 8),
            _buildCategoryChip('sound', 'Ses', Icons.music_note),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? const Color(0xFF00979D) : Colors.white70,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF00979D) : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
    );
  }

  Widget _buildProjectCard(ArduinoProject project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArduinoProjectDetailScreen(project: project),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [project.color, project.color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      project.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildInfoBadge(
                        Icons.star,
                        project.difficulty,
                        _getDifficultyColor(project.difficulty),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoBadge(
                        Icons.access_time,
                        project.duration,
                        AppTheme.primaryBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArduinoProjectDetailScreen(project: project),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Projeyi Başlat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: project.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Başlangıç':
        return const Color(0xFF4CAF50);
      case 'Orta':
        return const Color(0xFFFF9800);
      case 'İleri':
        return const Color(0xFFF44336);
      default:
        return AppTheme.primaryBlue;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Bu kategoride proje bulunamadı',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// Arduino Project Detail Screen
class ArduinoProjectDetailScreen extends StatefulWidget {
  final ArduinoProject project;

  const ArduinoProjectDetailScreen({super.key, required this.project});

  @override
  State<ArduinoProjectDetailScreen> createState() => _ArduinoProjectDetailScreenState();
}

class _ArduinoProjectDetailScreenState extends State<ArduinoProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        backgroundColor: widget.project.color,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Adımlar'),
            Tab(icon: Icon(Icons.code), text: 'Kod'),
            Tab(icon: Icon(Icons.memory), text: 'Malzemeler'),
            Tab(icon: Icon(Icons.school), text: 'Öğrenme'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStepsTab(),
          _buildCodeTab(),
          _buildComponentsTab(),
          _buildLearningTab(),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.project.steps.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.project.color,
              foregroundColor: Colors.white,
              child: Text('${index + 1}'),
            ),
            title: Text(
              widget.project.steps[index],
              style: const TextStyle(fontSize: 15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Arduino Kodu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.project.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kod kopyalandı!'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      },
                      tooltip: 'Kodu Kopyala',
                    ),
                  ],
                ),
                const Divider(color: Colors.white24),
                SelectableText(
                  widget.project.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.project.components.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              Icons.check_circle,
              color: widget.project.color,
            ),
            title: Text(widget.project.components[index]),
          ),
        );
      },
    );
  }

  Widget _buildLearningTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.project.learningPoints.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb,
                  color: widget.project.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.project.learningPoints[index],
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Arduino Project Model
class ArduinoProject {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String duration;
  final IconData icon;
  final Color color;
  final List<String> components;
  final List<String> steps;
  final String code;
  final List<String> learningPoints;

  ArduinoProject({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.icon,
    required this.color,
    required this.components,
    required this.steps,
    required this.code,
    required this.learningPoints,
  });
}
