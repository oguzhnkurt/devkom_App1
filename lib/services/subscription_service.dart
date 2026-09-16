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

/// [SubscriptionService.claimProJeton] sonucu.
class ProJetonGrant {
  const ProJetonGrant({
    required this.granted,
    required this.isWelcome,
    required this.isMonthly,
    required this.balance,
  });

  /// Bu cagrida eklenen jeton. 0 ise verilecek bir sey yoktu.
  final int granted;

  /// Bir kerelik "Pro'ya hos geldin" paketi mi?
  final bool isWelcome;

  /// Bu ayin duzenli Pro jetonu mu?
  final bool isMonthly;

  /// Islem sonrasi toplam bakiye.
  final int balance;

  bool get hasReward => granted > 0;
}

class SubscriptionService {
  static const String _placementId = 'main_paywall';
  static const String _accessLevelId = 'premium';

  // App Store Connect / Google Play ürün kimlikleri ile birebir aynı olmalı.
  static const String weeklyProductId = 'com.devkom.app.pro.weekly';
  static const String monthlyProductId = 'com.devkom.app.pro.monthly';
  static const String yearlyProductId = 'com.devkom.app.pro.yearly';

  /// Cikista sunulan indirimli yillik plan.
  ///
  /// NOT: Bu bir GERCEK urun olmali. App Store Connect'te ayri bir abonelik
  /// urunu (ya da yillik urune bagli bir promosyon teklifi) tanimlanmadan
  /// uygulama uydurma bir indirimli fiyat gosteremez — fiyat her zaman
  /// StoreKit'ten okunur. Urun yoksa cikis teklifi indirim iddia etmez,
  /// yalnizca yillik planin gercek aylik karsiligini gosterir.
  static const String yearlyDiscountProductId =
      'com.devkom.app.pro.yearly.offer';

  AdaptyPaywall? _cachedPaywall;

  Future<void> initialize() async {
    try {
      final configuration = AdaptyConfiguration(
        apiKey: dotenv.env['ADAPTY_PUBLIC_KEY'] ?? '',
      )..withLogLevel(
          kDebugMode ? AdaptyLogLevel.verbose : AdaptyLogLevel.warn);

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
          '⚠️ Adapty: paywall "${paywall.placementId}" alındı ama ürün listesi BOS. '
          'Beklenen ID\'ler: $monthlyProductId, $yearlyProductId. '
          'Simulator kullanıyorsan bu normaldir (StoreKit Configuration dosyasi gerekir).',
        );
        return [];
      }

      debugPrint('✅ Adapty: ${products.length} ürün yüklendi '
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
          'ℹ️ StoreKit bu ID\'ler için ürün dondurmedi: '
          '$monthlyProductId, $yearlyProductId. Olasi nedenler: '
          'iOS Simulator (StoreKit Configuration dosyasi gerekir), '
          'App Store Connect Paid Applications sozlesmesi aktif degil, '
          'urunler henüz yayilmamis, ya da Adapty paywall\'inda urunler ekli degil.',
        );
      }
      return [];
    }
  }

  /// Pro jetonlarini talep eder.
  ///
  /// Sunucudaki `claim_pro_jeton()` fonksiyonu bir kerelik hos geldin paketini
  /// ve icinde bulunulan ayin jetonunu veriyor. Ayni donem icin ikinci kez
  /// jeton vermiyor, o yuzden bu metodu istedigimiz kadar cagirabiliriz.
  /// Pro degilse ya da oturum yoksa `granted: 0` doner.
  Future<ProJetonGrant?> claimProJeton() async {
    try {
      final result = await Supabase.instance.client.rpc('claim_pro_jeton');
      if (result is! Map) return null;
      final granted = (result['granted'] as num?)?.toInt() ?? 0;
      if (granted > 0) {
        debugPrint('🪙 Pro jetonu eklendi: $granted');
      }
      return ProJetonGrant(
        granted: granted,
        isWelcome: result['welcome'] == true,
        isMonthly: result['monthly'] == true,
        balance: (result['balance'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      // Jeton verilemedi diye satin almayi basarisiz saymiyoruz; kullanici
      // uygulamayi bir dahaki acisinda tekrar denenecek.
      debugPrint('⚠️ claim_pro_jeton error: $e');
      return null;
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
      await Supabase.instance.client.from('users').update({
        'is_pro': isPro,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', userId);
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
