# 🤖 DEVKOM Robotik Bölümü - Profesyonel Uygulama Kılavuzu

## 📋 Genel Bakış

Robotik bölümü 4 ana ekrandan oluşur:
1. **Oyunlar Ekranı** - Arduino, Python, 4-6 yaş, 7-9 yaş kategorileri
2. **Ödevlerim Ekranı** - Öğrenciler ödevlerini görür ve teslim eder
3. **Admin Paneli** - Ödev yönetimi ve takip
4. **Ana Robotik Ekranı** - Müfredat ve özelliklere erişim

## 🎨 Tasarım Prensipleri

### Renk Paleti
- **Primary**: `Color(0xFF2196F3)` - Mavi (Teknoloji)
- **Secondary**: `Color(0xFF00BCD4)` - Cyan (Robotik)
- **Accent**: `Color(0xFFFF9800)` - Turuncu (Enerji)
- **Success**: `Color(0xFF4CAF50)` - Yeşil
- **Warning**: `Color(0xFFFFC107)` - Sarı
- **Error**: `Color(0xFFF44336)` - Kırmızı

### UI Bileşenleri
- **Kartlar**: Elevation 4, rounded corners 16px
- **Butonlar**: Rounded 12px, gradient background
- **İkonlar**: Material Icons + Custom robotik ikonları
- **Animasyonlar**: Smooth transitions, 300ms duration

## 📁 Dosya Yapısı

```
lib/
├── models/
│   ├── game_model.dart          ✅ Oluşturuldu
│   └── homework_model.dart       ✅ Oluşturuldu
│
├── services/
│   ├── games_service.dart        📝 Oluşturulacak
│   └── homework_service.dart     📝 Oluşturulacak
│
├── screens/
│   ├── robotics_screen.dart             📝 Güncellenecek
│   ├── robotics_games_screen.dart       📝 Oluşturulacak
│   ├── game_play_screen.dart            📝 Oluşturulacak
│   ├── homework_screen.dart             📝 Oluşturulacak
│   └── robotics_admin_screen.dart       📝 Oluşturulacak
│
└── widgets/
    ├── game_card.dart                   📝 Oluşturulacak
    ├── homework_card.dart               📝 Oluşturulacak
    └── category_selector.dart           📝 Oluşturulacak
```

## 🚀 Hızlı Başlangıç

### 1. Dependencies Yükleme
```bash
cd C:\Users\Oguzhan\devkom_app
flutter pub get
```

### 2. Firebase Veri Ekleme

Firebase Console > Firestore Database > Start Collection

**`games` koleksiyonu:**
```javascript
{
  title: "Arduino LED Kontrolü",
  description: "LED'leri digitalWrite ile kontrol etmeyi öğren",
  category: "arduino",
  type: "quiz",
  thumbnailUrl: "",
  difficulty: 2,
  estimatedMinutes: 15,
  tags: ["led", "digital", "başlangıç"],
  isActive: true,
  createdAt: firebase.firestore.FieldValue.serverTimestamp(),
  gameData: {
    questions: [
      {
        question: "LED'i yakmak için hangi komut kullanılır?",
        options: ["digitalWrite(13, HIGH)", "analogRead(13)", "pinMode(13)"],
        correctAnswer: 0,
        explanation: "digitalWrite() komutu dijital pini HIGH/LOW yapar"
      },
      {
        question: "LED bağlantısında hangi eleman gereklidir?",
        options: ["Direnç", "Kondansatör", "Transistör"],
        correctAnswer: 0,
        explanation: "LED'i korumak için direnç gereklidir"
      }
    ]
  }
}
```

**`homework` koleksiyonu:**
```javascript
{
  title: "İlk Arduino Projem",
  description: "13 numaralı pine LED bağlayın ve yanıp sönen kod yazın",
  dueDate: new Date("2025-11-15"),
  createdAt: firebase.firestore.FieldValue.serverTimestamp(),
  createdBy: "admin-uid",
  ageGroup: "age7to9",
  assignedUserIds: [],
  isActive: true,
  maxScore: 100
}
```

### 3. Örnek Servis Kullanımı

```dart
// Oyunları çekme
final gamesService = GamesService();
final games = await gamesService.getGamesByCategory(GameCategory.arduino);

// Ödev oluşturma (Admin)
final homeworkService = HomeworkService();
await homeworkService.createHomework(
  title: "LED Devresi",
  description: "...",
  dueDate: DateTime.now().add(Duration(days: 7)),
  ageGroup: AgeGroup.age7to9,
);

// Ödev teslimi
await homeworkService.submitHomework(
  homeworkId: "hw123",
  fileUrls: ["https://..."],
  notes: "Tamamlandı",
);
```

## 🎮 Oyunlar Sistemi

### Kategori Yapısı

**1. Arduino (Mavi)**
- Temel Arduino
- LED Kontrolü
- Buton Okuma
- Sensör Kullanımı

**2. Python (Yeşil)**
- Python Temelleri
- Robot Programlama
- Sensör Okuma
- Karar Yapıları

**3. 4-6 Yaş (Turuncu)**
- Renk Eşleştirme
- Şekil Tanıma
- Basit Kodlama
- Robot Yönlendirme

**4. 7-9 Yaş (Mor)**
- Algoritma Temelleri
- Döngüler
- Mantık Oyunları
- Basit Projeler

### Oyun Tipleri

**Quiz (Bilgi Yarışması)**
- Çoktan seçmeli sorular
- Zamanlayıcı (opsiyonel)
- Puan sistemi
- Açıklamalı cevaplar

**Simulation (Simülasyon)**
- Sanal devre kurma
- LED/Motor kontrolü
- Gerçek zamanlı feedback

**Coding (Kodlama)**
- Blok tabanlı kodlama
- Sürükle-bırak
- Kod çalıştırma
- Hata gösterimi

**Puzzle (Bulmaca)**
- Mantık bulmacaları
- Sıralama problemleri
- Görsel-uzamsal oyunlar

### UI Tasarım Özellikleri

**Oyun Kartı:**
```
┌─────────────────────────────────┐
│  🎮 [Icon]                      │
│                                 │
│  Arduino LED Kontrolü           │
│  LED'leri kontrol etmeyi öğren │
│                                 │
│  ⭐⭐⭐ Orta    ⏱ 15 dk         │
│                                 │
│  [ 🎯 Oyna ]                    │
└─────────────────────────────────┘
```

**Özellikler:**
- Gradient background
- Kategori renk kodları
- Zorluk göstergesi (yıldız)
- Süre bilgisi
- Animasyonlu "Oyna" butonu

## 📝 Ödev Sistemi

### Ödev Kartı Tasarımı

```
┌─────────────────────────────────────┐
│  📋 İlk Arduino Projem             │
│  ────────────────────────           │
│  LED yanıp sönen kod yazın         │
│                                     │
│  📅 Teslim: 15 Kasım 2025          │
│  👤 7-9 Yaş                        │
│  ⏰ 5 gün kaldı                    │
│                                     │
│  [ 📤 Teslim Et ]  [ 📖 Detay ]   │
└─────────────────────────────────────┘
```

**Durum Göstergeleri:**
- 🟢 Zamanında
- 🟡 Yaklaşıyor (3 gün kaldı)
- 🔴 Gecikmede
- ✅ Teslim Edildi
- ⭐ Değerlendirildi

### Dosya Yükleme Akışı

1. Öğrenci "Teslim Et" butonuna tıklar
2. Dialog açılır:
   - Fotoğraf çek (📷)
   - Galeri'den seç (🖼️)
   - PDF yükle (📄)
3. Önizleme gösterilir
4. Not ekleme alanı
5. "Gönder" butonu
6. Firebase Storage'a yükleme
7. Firestore'a kayıt
8. Başarı mesajı

### Admin Ödev Yönetimi

**Oluşturma Formu:**
```
Başlık: [___________________]
Açıklama: [________________]
          [________________]
Teslim Tarihi: [📅 Seç____]
Yaş Grubu: [ ] 4-6  [ ] 7-9
           [ ] 10-12 [ ] Tümü
Kullanıcılar: [🔍 Ara______]
              ☑ Ahmet
              ☐ Mehmet
              ☑ Ayşe
Maks Puan: [100___]

[İptal]  [Oluştur]
```

**Takip Tablosu:**
```
╔═══════════════════╦═══════════╦══════════╦═══════╗
║ Ödev              ║ Öğrenci   ║ Durum    ║ Puan  ║
╠═══════════════════╬═══════════╬══════════╬═══════╣
║ Arduino LED       ║ Ahmet     ║ ✅ Teslim ║ -     ║
║ Arduino LED       ║ Mehmet    ║ ⏰ Bekle  ║ -     ║
║ Python Robot      ║ Ayşe      ║ ⭐ 85    ║ 85/100║
╚═══════════════════╩═══════════╩══════════╩═══════╝
```

## 🎯 Ana Robotik Ekranı Tasarımı

```
╔════════════════════════════════════╗
║  🤖 ROBOTIK                        ║
║  ────────────────                  ║
║                                    ║
║  ┌──────────┐  ┌──────────┐       ║
║  │  🎮      │  │  📋      │       ║
║  │ Oyunlar  │  │ Ödevler  │       ║
║  │          │  │          │       ║
║  │  12      │  │   3      │       ║
║  │  Oyun    │  │  Ödev    │       ║
║  └──────────┘  └──────────┘       ║
║                                    ║
║  ┌──────────┐  ┌──────────┐       ║
║  │  📚      │  │  👨‍💼     │       ║
║  │ Müfredat │  │  Admin   │       ║
║  │          │  │  Panel   │       ║
║  └──────────┘  └──────────┘       ║
║                                    ║
║  📊 İlerleme                       ║
║  ████████░░ 80%                   ║
╚════════════════════════════════════╝
```

## 🔐 Güvenlik ve İzinler

### User Roles
- **Admin**: Tüm yetkiler
- **Parent**: Çocuğun ödevlerini görme
- **Student**: Kendi ödevleri ve oyunlar
- **Visitor**: Sadece oyunlar

### Firestore Rules
```javascript
// Admin kontrolü
function isAdmin() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}

// Ödev erişimi
match /homework/{hwId} {
  allow read: if request.auth != null;
  allow write: if isAdmin();
}

// Teslim erişimi
match /homework_submissions/{subId} {
  allow read: if request.auth.uid == resource.data.userId || isAdmin();
  allow create: if request.auth.uid == request.resource.data.userId;
  allow update: if isAdmin();
}
```

## 📱 Responsive Tasarım

### Breakpoints
- **Mobile**: < 600px (1 kolon)
- **Tablet**: 600-900px (2 kolon)
- **Desktop**: > 900px (3-4 kolon)

### Grid Layouts
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 :
                    MediaQuery.of(context).size.width > 600 ? 2 : 1,
    childAspectRatio: 1.2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
)
```

## ⚡ Performance Optimizations

1. **Lazy Loading**: Oyunlar sayfalama ile yüklenir
2. **Caching**: Görüntülenen oyunlar cache'lenir
3. **Image Optimization**: Thumbnails için optimize edilmiş boyutlar
4. **Debouncing**: Arama işlemlerinde debounce

## 🧪 Test Senaryoları

### Oyunlar
- [ ] Kategorilere göre filtreleme
- [ ] Oyun açılma ve kapanma
- [ ] Quiz'de doğru/yanlış cevap
- [ ] Puan hesaplama
- [ ] İlerleme kaydetme

### Ödevler
- [ ] Ödev listesini görme
- [ ] Dosya yükleme
- [ ] Teslim etme
- [ ] Admin puanlama
- [ ] Bildirimler

### Admin
- [ ] Ödev oluşturma
- [ ] Kullanıcı seçimi
- [ ] Durum takibi
- [ ] Filtreleme

## 📊 Analytics Entegrasyonu

### Takip Edilecek Metrikler
- Oyun tamamlama oranı
- Ortalama puan
- Ödev teslim süresi
- Popüler kategoriler
- Kullanıcı engagement

## 🚀 Deployment

### Build Komutu
```bash
flutter build web --release
```

### Firebase Hosting
```bash
firebase deploy --only hosting
```

## 📞 Destek

Sorular için: support@devkom.com

---

**Hazırlayan**: DEVKOM Yazılım Ekibi
**Versiyon**: 1.0.0
**Tarih**: 2025
**Durum**: ✅ Hazır
