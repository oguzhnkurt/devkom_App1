import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionService {
  static const String _placementId = 'main_paywall';
  static const String _accessLevelId = 'premium';

  // App Store Connect / Google Play ürün kimlikleri ile birebir aynı olmalı.
  static const String monthlyProductId = 'com.devkom.app.pro.monthly';
  static const String yearlyProductId = 'com.devkom.app.pro.yearly';

  AdaptyPaywall? _cachedPaywall;

  Future<void> initialize() async {
    try {
      final configuration = AdaptyConfiguration(
        apiKey: dotenv.env['ADAPTY_PUBLIC_KEY'] ?? '',
      )..withLogLevel(kDebugMode ? AdaptyLogLevel.verbose : AdaptyLogLevel.warn);

      await Adapty().activate(configuration: configuration);
      debugPrint('✅ Adapty initialized');
    } catch (e) {
      debugPrint('⚠️ Adapty initialization failed: $e');
    }
  }

  Future<bool> hasActiveSubscription() async {
    try {
      final profile = await Adapty().getProfile();
      return profile.accessLevels[_accessLevelId]?.isActive ?? false;
    } catch (e) {
      debugPrint('⚠️ Adapty hasActiveSubscription error: $e');
      return false;
    }
  }

  Future<bool> checkProStatus(String userId) async {
    try {
      await Adapty().identify(userId);
      final profile = await Adapty().getProfile();
      return profile.accessLevels[_accessLevelId]?.isActive ?? false;
    } catch (e) {
      debugPrint('⚠️ Adapty checkProStatus error: $e');
      return false;
    }
  }

  Future<AdaptyPaywall?> getPaywall() async {
    try {
      _cachedPaywall ??= await Adapty().getPaywall(placementId: _placementId);
      return _cachedPaywall;
    } catch (e) {
      debugPrint('⚠️ Adapty getPaywall error: $e');
      return null;
    }
  }

  Future<List<AdaptyPaywallProduct>> getProducts() async {
    try {
      final paywall = await getPaywall();
      if (paywall == null) return [];
      return await Adapty().getPaywallProducts(paywall: paywall);
    } catch (e) {
      debugPrint('⚠️ Adapty getProducts error: $e');
      return [];
    }
  }

  Future<bool> purchaseProduct(AdaptyPaywallProduct product) async {
    try {
      await Adapty().makePurchase(product: product);
      final profile = await Adapty().getProfile();
      final isActive = profile.accessLevels[_accessLevelId]?.isActive ?? false;
      if (isActive) await _syncProStatusToSupabase(isPro: true);
      return isActive;
    } on AdaptyError catch (e) {
      if (e.code == AdaptyErrorCode.paymentCancelled) return false;
      debugPrint('⚠️ Adapty purchase error: ${e.message}');
      rethrow;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      await Adapty().restorePurchases();
      final profile = await Adapty().getProfile();
      final isActive = profile.accessLevels[_accessLevelId]?.isActive ?? false;
      await _syncProStatusToSupabase(isPro: isActive);
      return isActive;
    } catch (e) {
      debugPrint('⚠️ Adapty restore error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSubscriptionInfo() async {
    try {
      final profile = await Adapty().getProfile();
      final level = profile.accessLevels[_accessLevelId];
      return {
        'isActive': level?.isActive ?? false,
        'expiryDate': level?.expiresAt,
      };
    } catch (e) {
      debugPrint('⚠️ Adapty getSubscriptionInfo error: $e');
      return {'isActive': false, 'expiryDate': null};
    }
  }

  Future<DateTime?> getProExpiryDate(String userId) async {
    try {
      final profile = await Adapty().getProfile();
      return profile.accessLevels[_accessLevelId]?.expiresAt;
    } catch (e) {
      return null;
    }
  }

  Future<void> _syncProStatusToSupabase({required bool isPro}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('users')
          .update({'is_pro': isPro, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      debugPrint('⚠️ Supabase pro sync error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await Adapty().logout();
    } catch (e) {
      debugPrint('⚠️ Adapty logout error: $e');
    }
  }
}
