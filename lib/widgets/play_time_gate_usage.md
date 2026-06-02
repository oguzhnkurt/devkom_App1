# PlayTimeGate Kullanım Rehberi

PlayTimeGate, çocukların oyun oynamadan önce süre limiti kontrolü yapan bir widget'tır. Tüm oyun ekranlarını bu widget ile sarmalayarak otomatik limit kontrolü yapabilirsiniz.

## Nasıl Kullanılır?

### 1. Import Ekleyin

```dart
import '../../widgets/play_time_gate.dart';
```

### 2. Oyun Ekranınızı PlayTimeGate ile Sarmalayın

**Eski Kod:**
```dart
class CoordinatesGameScreen extends StatefulWidget {
  const CoordinatesGameScreen({Key? key}) : super(key: key);

  @override
  State<CoordinatesGameScreen> createState() => _CoordinatesGameScreenState();
}
```

**Yeni Kod:**
```dart
class CoordinatesGameScreen extends StatelessWidget {
  const CoordinatesGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlayTimeGate(
      gameName: 'Koordinat Macerası',
      child: _CoordinatesGameContent(),
    );
  }
}

class _CoordinatesGameContent extends StatefulWidget {
  const _CoordinatesGameContent({Key? key}) : super(key: key);

  @override
  State<_CoordinatesGameContent> createState() => _CoordinatesGameContentState();
}

class _CoordinatesGameContentState extends State<_CoordinatesGameContent> {
  // Eski CoordinatesGameScreen state'i buraya taşınır
  // ...
}
```

### 3. PlayTimeGate Ne Yapar?

- **Otomatik Limit Kontrolü:** Oyun başlamadan önce günlük/haftalık limitleri kontrol eder
- **Zaman Aralığı Kontrolü:** Yasak saatlerde oyun oynamayı engeller
- **Oturum Yönetimi:** Oyun süresini otomatik olarak Firestore'a kaydeder
- **Kullanıcı Dostu Mesajlar:** Limit aşıldığında açıklayıcı ekran gösterir
- **Süre İstatistikleri:** Kullanıcıya bugün ve bu hafta oynadığı süreyi gösterir

### 4. Özellikler

#### Limit Türleri:
- **Günlük Limit:** Çocuğun günde oyun oynayabileceği maksimum süre
- **Haftalık Limit:** Çocuğun haftada oyun oynayabileceği maksimum süre
- **Zaman Aralığı:** Belirli saatlerde oyun oynamayı engelleme (örn: 20:00-22:00)

#### Otomatik Oturum Yönetimi:
- Oyun başladığında otomatik oturum başlatır
- Oyun bittiğinde (veya ekran kapatıldığında) otomatik oturum sonlandırır
- Oturum süresini Firestore'da `play_sessions` koleksiyonuna kaydeder

#### Kullanıcı Arayüzü:
- Loading ekranı (kontrol sırasında)
- Limit aşıldığında detaylı bilgi ekranı
- Süre istatistikleri görüntüleme
- Ana menüye dönüş butonu

### 5. PlayTimeWarningBanner Kullanımı

Oyun içerisinde kalan süre uyarısı göstermek için:

```dart
@override
Widget build(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);
  final userId = authProvider.currentUser?.uid;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Oyun'),
    ),
    body: Column(
      children: [
        // Uyarı banner'ını üstte göster
        FutureBuilder<PlayTimeCheck>(
          future: PlayTimeLimitService().checkPlayTimeLimit(userId!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();

            final check = snapshot.data!;
            if (check.remainingMinutes != null && check.remainingMinutes! <= 10) {
              return PlayTimeWarningBanner(
                remainingMinutes: check.remainingMinutes!,
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Oyun içeriği
        Expanded(
          child: YourGameContent(),
        ),
      ],
    ),
  );
}
```

### 6. Manuel Kontrol (Opsiyonel)

PlayTimeGate dışında manuel kontrol yapmak isterseniz:

```dart
final playTimeService = PlayTimeLimitService();
final userId = 'USER_ID';

// Limit kontrolü
final check = await playTimeService.checkPlayTimeLimit(userId);
if (check.canPlay) {
  // Oyuna izin ver
  print('Kalan süre: ${check.remainingMinutes} dakika');
} else {
  // Oyunu engelle
  print('Limit aşıldı: ${check.message}');
}

// Bugünkü oyun süresi
final todayMinutes = await playTimeService.getTodayPlayTime(userId);
print('Bugün oynanan: $todayMinutes dakika');
```

### 7. Firestore Veri Yapısı

PlayTimeGate aşağıdaki Firestore yapısını kullanır:

```
users/{userId}/
  └── settings/
      └── play_time/
          ├── isEnabled: bool
          ├── dailyLimitMinutes: int
          ├── weeklyLimitMinutes: int
          ├── restrictedTimeRanges: array
          ├── showWarningAt80Percent: bool
          └── parentNotificationEnabled: bool

  └── play_sessions/{sessionId}/
      ├── startTime: timestamp
      ├── endTime: timestamp
      ├── durationMinutes: int
      └── isActive: bool
```

### 8. Tüm Oyunları Güncellemek

Tüm oyun ekranlarınıza PlayTimeGate eklemek için aşağıdaki oyunları güncelleyin:

- ✅ coordinates_game_screen.dart
- ✅ pipes_game_screen.dart
- ✅ sequencing_game_screen.dart
- ✅ word_match_game_screen.dart
- ✅ maze_explorer_game_screen.dart
- ✅ left_right_coding_game_screen.dart
- ✅ block_coding_game_screen.dart
- ✅ chess_game_screen.dart
- ✅ millionaire_game_screen.dart
- ✅ maze_3d_game_screen.dart
- ✅ maze_planet_game_screen.dart

Her oyun için aynı yapıyı uygulayın: StatefulWidget'ı StatelessWidget yapın, içeriği alt widget'a taşıyın, PlayTimeGate ile sarmalayın.

## Notlar

- PlayTimeGate sadece `role='student'` olan kullanıcılar için çalışır
- Ebeveynler ve yöneticiler için limit kontrolü yapılmaz
- Oturum bilgileri SharedPreferences'da da saklanır (cihaz kapanırsa veri kaybını önlemek için)
- Limit ayarları veliler tarafından `PlayTimeSettingsScreen` üzerinden yapılır
