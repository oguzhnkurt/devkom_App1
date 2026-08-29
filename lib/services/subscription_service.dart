import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abonelik planlari yuklenemedigi zaman nedenini ayirt etmek icin.
enum SubscriptionLoadFailure {
  /// Adapty placement'i alinamadi (panel yapilandirmasi ya da ag sorunu).
  paywallUnavailable,

  /// Paywall alindi ama StoreKit hic urun dondurmedi.
  noProducts,

  /// Beklenmeyen hata.
  error,
}

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

  /// Urun listesi bos donerse nedenini ayirt edebilmek icin kullanilir.
  /// Ekran bu bilgiyi kullaniciya anlamli bir mesaj gostermek icin okur.
  SubscriptionLoadFailure? lastFailure;

  Future<List<AdaptyPaywallProduct>> getProducts() async {
    lastFailure = null;
    try {
      final paywall = await getPaywall();
      if (paywall == null) {
        // Placement bulunamadi ya da Adapty'ye ulasilamadi.
        lastFailure = SubscriptionLoadFailure.paywallUnavailable;
        debugPrint(
          '⚠️ Adapty: "$_placementId" placement alinamadi. '
          'Adapty panelinde bu placement tanimli mi ve bir paywall atanmis mi?',
        );
        return [];
      }

      final products = await Adapty().getPaywallProducts(paywall: paywall);
      if (products.isEmpty) {
        // Paywall geldi ama StoreKit urunleri cozemedi. En sik nedenleri:
        //  * iOS Simulator (StoreKit Configuration dosyasi olmadan urun donmez)
        //  * App Store Connect'te urunler henuz yayilmamis (onay sonrasi birkac saat)
        //  * Adapty panelinde urunler paywall'a baglanmamis
        //  * Urun ID'leri App Store Connect ile birebir ayni degil
        lastFailure = SubscriptionLoadFailure.noProducts;
        debugPrint(
          '⚠️ Adapty: paywall "${paywall.placementId}" alindi ama urun listesi BOS. '
          'Beklenen ID\'ler: $monthlyProductId, $yearlyProductId. '
          'Simulator kullaniyorsan bu normaldir (StoreKit Configuration dosyasi gerekir).',
        );
        return [];
      }

      debugPrint('✅ Adapty: ${products.length} urun yuklendi '
          '(${products.map((p) => p.vendorProductId).join(", ")})');
      return products;
    } catch (e) {
      // Adapty, urun bulunamadiginda bos liste yerine istisna firlatiyor
      // (StoreKitManagerError.noProductIDsFound / adapty_code 1000). Bunu
      // "beklenmeyen hata" gibi gostermek yaniltici; ayni "urunler hazir
      // degil" durumu olarak ele aliyoruz.
      final text = e.toString();
      final isNoProducts = text.contains('noProductIDsFound') ||
          text.contains('No valid In-App Purchase products') ||
          text.contains('adapty_code":1000');

      lastFailure = isNoProducts
          ? SubscriptionLoadFailure.noProducts
          : SubscriptionLoadFailure.error;

      debugPrint('⚠️ Adapty getProducts error: $e');
      if (isNoProducts) {
        debugPrint(
          'ℹ️ StoreKit bu ID\'ler icin urun dondurmedi: '
          '$monthlyProductId, $yearlyProductId. Olasi nedenler: '
          'iOS Simulator (StoreKit Configuration dosyasi gerekir), '
          'App Store Connect Paid Applications sozlesmesi aktif degil, '
          'urunler henuz yayilmamis, ya da Adapty paywall\'inda urunler ekli degil.',
        );
      }
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
