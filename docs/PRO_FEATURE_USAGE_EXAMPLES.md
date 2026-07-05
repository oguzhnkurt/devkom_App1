# 🛡️ Pro Feature Guard - Kullanım Örnekleri

## 📚 İçindekiler
1. [Temel Kullanım](#temel-kullanım)
2. [Widget Koruma](#widget-koruma)
3. [Navigation Koruma](#navigation-koruma)
4. [Function Koruma](#function-koruma)
5. [Pro Badge](#pro-badge)
6. [Gerçek Dünya Örnekleri](#gerçek-dünya-örnekleri)

---

## 🎯 Temel Kullanım

### 1. Simple Check (Basit Kontrol)
```dart
import 'package:devkom_app/utils/pro_feature_guard.dart';

// Herhangi bir yerde Pro kontrolü
if (await ProFeatureGuard.hasAccess()) {
  // Pro kullanıcı - özelliği göster
  print('User has Pro!');
} else {
  // Free kullanıcı - upgrade prompt göster
  print('User needs to upgrade');
}
```

---

## 🎨 Widget Koruma

### Örnek 1: Tüm Ekranı Koruma
```dart
import 'package:devkom_app/utils/pro_feature_guard.dart';

class UnlimitedGamesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sınırsız Oyunlar')),
      body: ProFeatureGuard.guardWidget(
        context: context,
        featureName: 'Sınırsız Oyunlar',
        child: _buildGamesList(), // Gerçek içerik
        // fallback parametresi opsiyonel - otomatik upgrade prompt gösterir
      ),
    );
  }
}
```

### Örnek 2: Sadece Bir Butonu Koruma
```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      // Normal buton - herkes görebilir
      ElevatedButton(
        onPressed: () => playBasicGame(),
        child: Text('Temel Oyun'),
      ),

      // Pro buton - sadece Pro kullanıcılar görebilir
      ProFeatureGuard.guardWidget(
        context: context,
        child: ElevatedButton(
          onPressed: () => playAdvancedGame(),
          child: Row(
            children: [
              Icon(Icons.star),
              Text('Gelişmiş Oyun (Pro)'),
            ],
          ),
        ),
        // Pro değilse bu widget gösterilir
        fallback: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubscriptionScreen(),
              ),
            );
          },
          child: Text('Pro\'ya Yükselt'),
        ),
      ),
    ],
  );
}
```

### Örnek 3: Custom Fallback Widget
```dart
ProFeatureGuard.guardWidget(
  context: context,
  featureName: 'AI Asistan',
  child: AIChat(), // Gerçek Pro özelliği
  fallback: Container(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Icon(Icons.lock, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'AI Asistan Pro Üyelere Özel!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('Sınırsız AI sohbet için Pro\'ya yükseltin'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => showUpgradeScreen(context),
          child: Text('Pro\'ya Yükselt'),
        ),
      ],
    ),
  ),
);
```

---

## 🧭 Navigation Koruma

### Örnek 1: Ekrana Geçişi Koruma
```dart
// Herhangi bir buton/listtile'da
ListTile(
  leading: Icon(Icons.videogame_asset),
  title: Text('Pro Oyunlar'),
  trailing: Icon(Icons.star, color: Colors.amber),
  onTap: () {
    ProFeatureGuard.guardNavigation(
      context,
      destination: ProGamesScreen(),
      featureName: 'Pro Oyunlar',
    );
  },
)
```

### Örnek 2: Drawer Menu İtemini Koruma
```dart
Drawer(
  child: ListView(
    children: [
      // Normal menu items
      ListTile(
        title: Text('Ana Sayfa'),
        onTap: () => Navigator.pushNamed(context, '/home'),
      ),

      // Pro menu item
      ListTile(
        leading: Icon(Icons.analytics),
        title: Row(
          children: [
            Text('Gelişmiş Raporlar'),
            SizedBox(width: 8),
            Icon(Icons.star, size: 16, color: Colors.amber),
          ],
        ),
        onTap: () {
          Navigator.pop(context); // Drawer'ı kapat
          ProFeatureGuard.guardNavigation(
            context,
            destination: AdvancedReportsScreen(),
            featureName: 'Gelişmiş Raporlar',
          );
        },
      ),
    ],
  ),
)
```

---

## ⚙️ Function Koruma

### Örnek 1: AI Sohbet Limitini Koruma
```dart
class AIChat extends StatelessWidget {
  Future<void> _sendMessage(BuildContext context, String message) async {
    // Pro kontrolü yap - Pro değilse dialog göster
    final allowed = await ProFeatureGuard.guard(
      context,
      () async {
        // Bu kod sadece Pro kullanıcılar için çalışır
        await sendAIMessage(message);
      },
      featureName: 'Sınırsız AI Sohbet',
    );

    if (!allowed) {
      // Free kullanıcı - limit kontrolü yap
      if (dailyMessageCount >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Günlük 10 mesaj limitine ulaştınız'),
            action: SnackBarAction(
              label: 'Pro Al',
              onPressed: () => showSubscriptionScreen(),
            ),
          ),
        );
      }
    }
  }
}
```

### Örnek 2: Dosya Export Limitini Koruma
```dart
Future<void> exportReport(BuildContext context) async {
  await ProFeatureGuard.guard(
    context,
    () async {
      // Pro kullanıcılar tüm formatları export edebilir
      await exportToPDF();
      await exportToExcel();
      await exportToCSV();
    },
    featureName: 'Rapor Export',
  );
  // Free kullanıcılar için upgrade dialog otomatik gösterildi
}
```

### Örnek 3: Soft Guard (Uyarı Göster ama Engelleme)
```dart
Future<void> playGame(BuildContext context) async {
  // Pro kontrolü yap ama engelleme
  final hasPro = await ProFeatureGuard.checkAndPrompt(
    context,
    message: 'Pro üyeler reklamsız oynar',
  );

  if (hasPro) {
    // Pro - reklamsız oynat
    await startGame(showAds: false);
  } else {
    // Free - reklamlarla oynat
    await startGame(showAds: true);
  }
}
```

---

## ⭐ Pro Badge

### Örnek 1: Kullanıcı Profili
```dart
Widget build(BuildContext context) {
  return Row(
    children: [
      CircleAvatar(
        backgroundImage: NetworkImage(user.profilePictureUrl),
      ),
      SizedBox(width: 12),
      Text(
        user.displayName,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      ProFeatureGuard.proBadge(), // ⭐ PRO badge
    ],
  );
}
```

### Örnek 2: Leaderboard
```dart
ListTile(
  leading: CircleAvatar(child: Text('#${index + 1}')),
  title: Row(
    children: [
      Text(player.name),
      if (player.isPro) ProFeatureGuard.proBadge(size: 16),
    ],
  ),
  trailing: Text('${player.score} puan'),
)
```

---

## 🌍 Gerçek Dünya Örnekleri

### Örnek 1: Oyun Ekranı (Sınırlı Erişim)
```dart
class GameScreen extends StatefulWidget {
  final Game game;

  const GameScreen({required this.game});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int playCount = 0;
  static const FREE_PLAY_LIMIT = 3;

  Future<void> _startGame() async {
    final hasPro = await ProFeatureGuard.hasAccess();

    if (hasPro) {
      // Pro - sınırsız oyna
      await _playGame();
    } else {
      // Free - limit kontrolü
      if (playCount >= FREE_PLAY_LIMIT) {
        ProFeatureGuard.checkAndPrompt(
          context,
          message: 'Günlük $FREE_PLAY_LIMIT oyun hakkınız doldu. Pro ile sınırsız oynayın!',
        );
      } else {
        await _playGame();
        setState(() => playCount++);

        // Son hak uyarısı
        if (playCount == FREE_PLAY_LIMIT) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Son oyun hakkınızı kullandınız'),
              action: SnackBarAction(
                label: 'Pro Al',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionScreen(),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.name),
        actions: [
          FutureBuilder<bool>(
            future: ProFeatureGuard.hasAccess(),
            builder: (context, snapshot) {
              if (snapshot.data == true) return SizedBox.shrink();

              // Free kullanıcılara kalan hak göster
              return Chip(
                avatar: Icon(Icons.videogame_asset, size: 16),
                label: Text('${FREE_PLAY_LIMIT - playCount} hak'),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _startGame,
          child: Text('Oyunu Başlat'),
        ),
      ),
    );
  }
}
```

### Örnek 2: AI Sohbet (Mesaj Limiti)
```dart
class AIChatScreen extends StatefulWidget {
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  static const FREE_MESSAGE_LIMIT = 10;
  int dailyMessageCount = 0;

  Future<void> _sendMessage(String message) async {
    final hasPro = await ProFeatureGuard.hasAccess();

    if (hasPro) {
      // Pro - sınırsız
      await _actualSendMessage(message);
    } else {
      // Free - limit kontrolü
      if (dailyMessageCount >= FREE_MESSAGE_LIMIT) {
        await ProFeatureGuard.guard(
          context,
          () async {}, // Boş - sadece dialog göstermek için
          featureName: 'Sınırsız AI Sohbet',
        );
      } else {
        await _actualSendMessage(message);
        setState(() => dailyMessageCount++);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Asistan'),
        actions: [
          FutureBuilder<bool>(
            future: ProFeatureGuard.hasAccess(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return Chip(
                  avatar: Icon(Icons.all_inclusive, size: 16),
                  label: Text('Sınırsız'),
                  backgroundColor: Colors.amber,
                );
              }

              return Chip(
                label: Text('$dailyMessageCount/$FREE_MESSAGE_LIMIT'),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(child: _buildMessageList()),

          // Input field
          _buildInputField(),

          // Pro upgrade banner (sadece free kullanıcılar için)
          FutureBuilder<bool>(
            future: ProFeatureGuard.hasAccess(),
            builder: (context, snapshot) {
              if (snapshot.data == true) return SizedBox.shrink();

              return ProFeaturesCard();
            },
          ),
        ],
      ),
    );
  }
}
```

### Örnek 3: Home Screen (Pro Features Showcase)
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // Pro status card
          FutureBuilder<bool>(
            future: ProFeatureGuard.hasAccess(),
            builder: (context, snapshot) {
              final hasPro = snapshot.data ?? false;

              if (hasPro) {
                // Pro kullanıcı - teşekkür mesajı
                return Card(
                  color: Colors.amber[50],
                  child: ListTile(
                    leading: Icon(Icons.star, color: Colors.amber),
                    title: Text('Devkom Pro Aktif'),
                    subtitle: Text('Tüm özelliklere erişiminiz var!'),
                  ),
                );
              } else {
                // Free kullanıcı - upgrade prompt
                return ProFeaturesCard();
              }
            },
          ),

          // Games section
          _buildSection(
            'Oyunlar',
            [
              _buildGameCard('Temel Oyun', isPro: false),
              _buildGameCard('Pro Oyun', isPro: true),
            ],
          ),

          // AI Chat section
          _buildSection(
            'AI Asistan',
            [
              ListTile(
                leading: Icon(Icons.chat),
                title: Text('AI Sohbet'),
                trailing: FutureBuilder<bool>(
                  future: ProFeatureGuard.hasAccess(),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return Chip(label: Text('Sınırsız'));
                    }
                    return Chip(label: Text('10/gün'));
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIChatScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(String name, {required bool isPro}) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.games),
        title: Row(
          children: [
            Text(name),
            if (isPro) ...[
              SizedBox(width: 8),
              Icon(Icons.star, size: 16, color: Colors.amber),
            ],
          ],
        ),
        onTap: () {
          if (isPro) {
            ProFeatureGuard.guardNavigation(
              context,
              destination: GameScreen(),
              featureName: name,
            );
          } else {
            // Normal navigation
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GameScreen()),
            );
          }
        },
      ),
    );
  }
}
```

---

## 📝 Best Practices

### 1. Kullanıcı Deneyimi
```dart
// ✅ İYİ: Kullanıcıya ne kazanacağını göster
ProFeatureGuard.guard(
  context,
  () async => unlockFeature(),
  featureName: 'Sınırsız Oyun',
);

// ❌ KÖTÜ: Sadece blokla, açıklama yapma
if (!hasPro) return;
```

### 2. Soft Limits (Yumuşak Limitler)
```dart
// ✅ İYİ: Bazı özellikleri limitli sun, tamamen engelleme
final hasPro = await ProFeatureGuard.checkAndPrompt(context);
if (hasPro) {
  // Reklamsız
} else {
  // Reklamlı ama yine de çalışıyor
}

// ❌ KÖTÜ: Hiç erişim verme
if (!hasPro) return;
```

### 3. Görünürlük
```dart
// ✅ İYİ: Pro özelliği göster ama kilitle
ProFeatureGuard.guardWidget(
  context: context,
  child: ProFeature(),
  fallback: UpgradePrompt(),
);

// ❌ KÖTÜ: Pro özelliği tamamen gizle
if (hasPro) ProFeature()
```

---

## 🧪 Test Kullanıcıları

Oluşturulan test kullanıcıları ile test edin:

| Email | Role | Pro | Açıklama |
|-------|------|-----|----------|
| free.student@devkom.test | Student | ❌ | Ücretsiz öğrenci |
| pro.student@devkom.test | Student | ✅ | Pro öğrenci (30 gün) |
| expired.pro@devkom.test | Student | ⏰ | Süresi dolmuş Pro |

**Şifre**: `Test123456`

---

## 🚀 Sonraki Adımlar

1. **Mevcut Özellikleri Koruma**
   - AI Sohbet limitini ekle
   - Oyun limitini ekle
   - Export özelliklerini koruma

2. **UI İyileştirmeleri**
   - Pro badge ekle
   - Upgrade prompts güzelleştir
   - Analytics ekle

3. **Backend Validation**
   - Firebase Functions ile server-side kontrol
   - Abuse prevention

---

**Hazırlayan**: Claude Code
**Tarih**: 2025-11-21
