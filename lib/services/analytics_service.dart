import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class AnalyticsService {
  static AnalyticsService? _instance;
  static Mixpanel? _mp;

  factory AnalyticsService() => _instance ??= AnalyticsService._();
  AnalyticsService._();

  Future<void> initialize() async {
    try {
      final token = dotenv.env['MIXPANEL_TOKEN'] ?? '';
      if (token.isEmpty || token == 'your_mixpanel_token_here') {
        debugPrint('📊 Mixpanel: token eksik, atlanıyor');
        return;
      }
      _mp = await Mixpanel.init(
        token,
        trackAutomaticEvents: false,
        optOutTrackingDefault: kDebugMode,
      );
      debugPrint('✅ Mixpanel initialized');
    } catch (e) {
      debugPrint('⚠️ Mixpanel initialization failed: $e');
    }
  }

  // ── Kullanıcı kimliği ────────────────────────────────────────────────────

  void identify(String userId) {
    _mp?.identify(userId);
  }

  Future<void> setUserId(String userId) async {
    identify(userId);
  }

  Future<void> setUserProperties({
    String? role,
    String? ageGroup,
    bool? isPro,
    String? displayName,
  }) async {
    final people = _mp?.getPeople();
    if (people == null) return;
    if (role != null) people.set('role', role);
    if (ageGroup != null) people.set('age_group', ageGroup);
    if (isPro != null) people.set('is_pro', isPro);
    if (displayName != null) people.set('\$name', displayName);
  }

  void reset() {
    _mp?.reset();
  }

  // ── Auth olayları ────────────────────────────────────────────────────────

  Future<void> logSignUp(String method) async {
    _track('Sign Up', {'method': method});
  }

  Future<void> logLogin(String method) async {
    _track('Login', {'method': method});
  }

  // ── Ekran görüntüleme ────────────────────────────────────────────────────

  Future<void> logScreenView(String screenName) async {
    _track('Screen View', {'screen': screenName});
  }

  // ── Oyun olayları ────────────────────────────────────────────────────────

  Future<void> logGamePlayed(String gameId, int score) async {
    _track('Game Played', {'game_id': gameId, 'score': score});
  }

  // ── Abonelik / satın alma ────────────────────────────────────────────────

  Future<void> logViewSubscription() async {
    _track('View Subscription');
  }

  Future<void> logPurchaseCompleted(String productId) async {
    _track('Purchase Completed', {'product_id': productId});
    // Mixpanel People revenue tracking
    _mp?.getPeople().trackCharge(0); // Gerçek tutarı Adapty webhook'undan alabilirsin
  }

  Future<void> logPurchase({
    required String productId,
    required double value,
    required String currency,
  }) async {
    _track('Purchase', {
      'product_id': productId,
      'value': value,
      'currency': currency,
    });
    _mp?.getPeople().trackCharge(value);
  }

  // ── Pro özellik olayları ─────────────────────────────────────────────────

  Future<void> logProFeatureBlocked(String featureName) async {
    _track('Pro Feature Blocked', {'feature': featureName});
  }

  Future<void> logUpgradePromptShown(String featureName) async {
    _track('Upgrade Prompt Shown', {'feature': featureName});
  }

  // ── Genel olay ───────────────────────────────────────────────────────────

  Future<void> logEvent(String eventName,
      {Map<String, dynamic>? parameters}) async {
    _track(eventName, parameters);
  }

  // ── İç yardımcı ─────────────────────────────────────────────────────────

  void _track(String event, [Map<String, dynamic>? props]) {
    debugPrint('📊 $event ${props ?? ''}');
    _mp?.track(event, properties: props);
  }
}
