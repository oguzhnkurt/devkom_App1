// Testler icin sahte magaza urunleri (Adapty testte urun veremiyor).
// ignore_for_file: implementation_imports
import 'package:adapty_flutter/src/models/adapty_paywall_product.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:devkom_app/services/subscription_service.dart';

AdaptyPaywallProduct sahteUrun(String id, double fiyat, String yazi) =>
    AdaptyPaywallProductJSONBuilder.fromJsonValue({
      'vendor_product_id': id,
      'adapty_product_id': id,
      'access_level_id': 'premium',
      'product_type': 'subscription',
      'paywall_variation_id': 'v',
      'paywall_ab_test_name': 't',
      'paywall_name': 'p',
      'localized_description': '',
      'localized_title': id,
      'paywall_product_index': 0,
      'price': {
        'amount': fiyat,
        'currency_code': 'TRY',
        'currency_symbol': '₺',
        'localized_string': yazi,
      },
    });

class SahteMagaza extends SubscriptionService {
  @override
  Future<List<AdaptyPaywallProduct>> getProducts() async => [
        sahteUrun(SubscriptionService.monthlyProductId, 79.99, '₺79,99'),
        sahteUrun(SubscriptionService.yearlyProductId, 699.99, '₺699,99'),
        sahteUrun(SubscriptionService.yearlyDiscountProductId, 599.99, '₺599,99'),
      ];
  @override
  Future<void> logShowPaywall() async {}
}

