# 📊 Firebase Analytics Integration Guide

## Tamamlanan Özellikler

Firebase Analytics başarıyla entegre edildi ve tüm kritik kullanıcı davranışları izleniyor.

---

## 🎯 İzlenen Eventler

### 1. Kullanıcı Olayları (User Events)

#### Sign Up
```dart
await analytics.logSignUp('email'); // veya 'apple'
```
**Ne zaman:** Yeni kullanıcı kayıt olduğunda
**Parametreler:** `signUpMethod` (email/apple)

#### Login
```dart
await analytics.logLogin('email'); // veya 'apple'
```
**Ne zaman:** Kullanıcı giriş yaptığında
**Parametreler:** `loginMethod` (email/apple)

#### User Properties
```dart
await analytics.setUserId(userId);
await analytics.setUserProperties(
  role: 'student',
  ageGroup: 'age7to9',
  isPro: true,
);
```
**Ne zaman:** Login/register sonrası
**Kullanım:** Kullanıcı segmentasyonu için

---

### 2. Subscription Olayları (Subscription Events)

#### View Subscription Screen
```dart
await analytics.logViewSubscription();
```
**Ne zaman:** Subscription ekranı açıldığında
**Kod:** `lib/screens/subscription_screen.dart:26`

#### Begin Checkout
```dart
await analytics.logBeginCheckout('devkom_pro_monthly', 49.99);
```
**Ne zaman:** Kullanıcı subscription satın almaya başladığında
**Kod:** `lib/services/subscription_service.dart:89`

#### Purchase Complete
```dart
await analytics.logPurchase('devkom_pro_monthly', 49.99, 'TRY');
```
**Ne zaman:** Satın alma başarıyla tamamlandığında
**Kod:** `lib/services/subscription_service.dart:196`

#### Restore Purchases
```dart
await analytics.logRestorePurchases(true, 2); // success, count
```
**Ne zaman:** Kullanıcı satın almaları geri yüklediğinde
**Kod:** `lib/services/subscription_service.dart:121`

---

### 3. Pro Feature Olayları (Pro Feature Events)

#### Pro Feature Blocked
```dart
await analytics.logProFeatureBlocked('Sınırsız Oyunlar');
```
**Ne zaman:** Free kullanıcı Pro özelliğe erişmeye çalıştığında
**Kod:** `lib/utils/pro_feature_guard.dart:63`

#### Upgrade Prompt Shown
```dart
await analytics.logUpgradePromptShown('ai_chat');
```
**Ne zaman:** Pro'ya yükselt dialogu gösterildiğinde
**Kod:** `lib/utils/pro_feature_guard.dart:141`

---

### 4. Game Olayları (Game Events)

#### Game Start
```dart
await analytics.logGameStart('Chess', 'standard');
```
**Kullanım Örneği:**
```dart
// Oyun başladığında
@override
void initState() {
  super.initState();
  AnalyticsService().logGameStart(
    widget.gameName,
    widget.gameType,
  );
}
```

#### Game Complete
```dart
await analytics.logGameComplete(
  'Chess',
  score: 1200,
  duration: 300, // seconds
  level: 5,
  isPro: true,
);
```
**Kullanım Örneği:**
```dart
// Oyun bittiğinde
void _onGameEnd() {
  AnalyticsService().logGameComplete(
    gameName,
    score: finalScore.round(),
    duration: elapsedSeconds,
    level: currentLevel,
    isPro: isPro,
  );
}
```

#### Level Up
```dart
await analytics.logLevelUp('Chess', 6);
```

---

### 5. İçerik Olayları (Content Events)

#### Screen View
```dart
await analytics.logScreenView('home_screen');
```
**Kullanım Örneği:**
```dart
@override
void initState() {
  super.initState();
  AnalyticsService().logScreenView('student_home');
}
```

#### Content Selection
```dart
await analytics.logSelectContent('lesson', 'python_basics');
```

#### Search
```dart
await analytics.logSearch(searchQuery);
```

#### Share
```dart
await analytics.logShare('post', postId);
```

---

### 6. AI Chat Olayları (AI Chat Events)

#### AI Chat Message
```dart
await analytics.logAIChatMessage(isPro: true, messageCount: 5);
```
**Kullanım Örneği:**
```dart
Future<void> _sendMessage(String message) async {
  final isPro = await ProFeatureGuard.hasAccess();

  setState(() => _messageCount++);

  await AnalyticsService().logAIChatMessage(
    isPro: isPro,
    messageCount: _messageCount,
  );

  // Send message...
}
```

#### AI Chat Limit Reached
```dart
await analytics.logAIChatLimitReached(10);
```

---

### 7. Sosyal Olaylar (Social Events)

#### Post Created
```dart
await analytics.logPostCreated('image'); // text, video, image
```

#### Comment Created
```dart
await analytics.logCommentCreated(postId);
```

---

### 8. Destek Olayları (Support Events)

#### Support Message
```dart
await analytics.logSupportMessage('student');
```

---

## 🎨 Kullanım Örnekleri

### Örnek 1: Oyun Screen'i
```dart
import '../services/analytics_service.dart';

class GameScreen extends StatefulWidget {
  final String gameName;
  // ...
}

class _GameScreenState extends State<GameScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  int _score = 0;
  int _level = 1;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Track game start
    _analytics.logGameStart(widget.gameName, 'standard');
    _analytics.logScreenView('game_${widget.gameName}');
  }

  void _onLevelUp() {
    setState(() => _level++);
    _analytics.logLevelUp(widget.gameName, _level);
  }

  void _onGameEnd() async {
    final duration = DateTime.now().difference(_startTime).inSeconds;
    final isPro = await ProFeatureGuard.hasAccess();

    await _analytics.logGameComplete(
      widget.gameName,
      score: _score,
      duration: duration,
      level: _level,
      isPro: isPro,
    );

    Navigator.pop(context);
  }
}
```

### Örnek 2: Pro Feature ile Game
```dart
class UnlimitedGamesScreen extends StatelessWidget {
  Future<void> _startGame(BuildContext context, String gameName) async {
    await ProFeatureGuard.guard(
      context,
      () async {
        // Track game start only if allowed
        await AnalyticsService().logGameStart(gameName, 'unlimited');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(gameName: gameName),
          ),
        );
      },
      featureName: 'Sınırsız Oyunlar',
    );
  }
}
```

### Örnek 3: Search Functionality
```dart
class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    // Debounce search analytics
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 3) {
        _analytics.logSearch(query);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

---

## 📈 Firebase Console'da Görüntüleme

### 1. Real-time Events
```
Firebase Console → Analytics → DebugView
```
- iOS: Xcode'da scheme → Edit Scheme → Arguments → `-FIRDebugEnabled`
- Android: `adb shell setprop debug.firebase.analytics.app com.example.devkom_app`

### 2. Event Raporları
```
Firebase Console → Analytics → Events
```
- En çok kullanılan eventler
- Event parametreleri
- Kullanıcı özellikleri

### 3. Custom Dashboards
```
Firebase Console → Analytics → Dashboard
```
- Subscription conversion rate
- Game completion rates
- Pro feature block rate
- Daily active users by role

---

## 🔧 Debug Komutları

### iOS Debug Mode Aktif Et
```bash
# Xcode'da
Edit Scheme → Run → Arguments Passed On Launch
-FIRDebugEnabled
```

### Android Debug Mode Aktif Et
```bash
# Emulator için
adb shell setprop debug.firebase.analytics.app com.example.devkom_app

# Kapat
adb shell setprop debug.firebase.analytics.app .none.
```

### Logları Görüntüle
```bash
# Tüm analytics logları
flutter logs | grep "📊\\|Analytics"

# Sadece eventler
flutter logs | grep "Analytics:"

# Sadece hatalar
flutter logs | grep "❌.*Analytics"
```

---

## 📊 Önemli Metrikler

### Conversion Metrics
- **Subscription View → Purchase**: `view_subscription` → `purchase`
- **Pro Block → Upgrade**: `pro_feature_blocked` → `view_subscription`
- **Free → Pro Conversion**: User properties `is_pro=true` artışı

### Engagement Metrics
- **Daily Active Users (DAU)**: Role bazında segmente et
- **Game Completion Rate**: `game_start` / `game_complete`
- **AI Chat Usage**: `ai_chat_message` count
- **Average Session Duration**: Firebase otomatik hesaplar

### Retention Metrics
- **D1, D7, D30 Retention**: Firebase otomatik hesaplar
- **Pro User Retention**: `is_pro=true` segmentinde retention
- **Cohort Analysis**: Role bazında cohort analizi

---

## 🎯 Gelecek İyileştirmeler

### 1. Custom Event Parameters
```dart
// Şu anda
await analytics.logGameComplete('Chess', score: 1200, duration: 300);

// Gelecekte eklenebilir
await analytics.logGameComplete(
  'Chess',
  score: 1200,
  duration: 300,
  difficulty: 'hard',
  opponent: 'ai_level_5',
  moves: 45,
);
```

### 2. User Journey Tracking
```dart
// User journey event'leri
await analytics.logEvent('onboarding_step', {
  'step': 1,
  'step_name': 'age_selection',
});
```

### 3. Performance Monitoring
```dart
// Trace API calls
final trace = FirebasePerformance.instance.newTrace('load_games');
await trace.start();
// ... load games
await trace.stop();
```

---

## 🚨 Önemli Notlar

1. **User Privacy**: Analytics GDPR uyumlu, kullanıcı kimliği hash'leniyor
2. **Data Retention**: Firebase Analytics 14 ay veri tutuyor
3. **Event Limits**: Günlük 500 farklı event adı, event başına 25 parametre
4. **Debug Mode**: Production'da debug mode'u kapatmayı unutma
5. **Custom Dimensions**: 50 custom user property limiti var

---

## 📚 Kaynaklar

- [Firebase Analytics Docs](https://firebase.google.com/docs/analytics)
- [Flutter Firebase Analytics](https://firebase.flutter.dev/docs/analytics/overview/)
- [Analytics Events Reference](https://support.google.com/analytics/answer/9267735)
- [Best Practices](https://firebase.google.com/docs/analytics/best-practices)

---

**Oluşturma Tarihi**: 2025-11-21
**Versiyon**: 1.0
**Durum**: Production-Ready
**Dosya**: `lib/services/analytics_service.dart`
