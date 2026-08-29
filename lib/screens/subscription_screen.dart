import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../services/subscription_service.dart';
import '../services/analytics_service.dart';
import '../theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _service = SubscriptionService();
  final _analytics = AnalyticsService();

  List<AdaptyPaywallProduct> _products = [];
  AdaptyPaywallProduct? _selected;
  bool _loading = true;
  bool _purchasing = false;

  static const _features = [
    (Icons.games_outlined, 'Sinirsiz oyun erisimi'),
    (Icons.smart_toy_outlined, 'Sinirsiz AI sohbet'),
    (Icons.school_outlined, 'Tum premium dersler'),
    (Icons.analytics_outlined, 'Gelismis ilerleme raporlari'),
    (Icons.family_restroom, 'Aile paylasimi (2 ogrenci)'),
    (Icons.support_agent_outlined, '7/24 oncelikli destek'),
  ];

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView('subscription_screen');
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final products = await _service.getProducts();
      final yearly =
          products.where((p) => p.vendorProductId.contains('yearly')).firstOrNull;
      setState(() {
        _products = products;
        _selected = yearly ?? products.firstOrNull;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _purchase() async {
    if (_selected == null || _purchasing) return;
    setState(() => _purchasing = true);
    try {
      final success = await _service.purchaseProduct(_selected!);
      if (!mounted) return;
      if (success) {
        _analytics.logPurchaseCompleted(_selected!.vendorProductId);

        // AuthProvider kullaniciyi onbellekte tutuyor; yenilemezsek satin alma
        // sonrasi arayuz hala "Pro'ya Yukselt" gostermeye devam ediyordu.
        await context.read<AuthProvider>().refreshUser();
        if (!mounted) return;

        // Snackbar'i pop'tan ONCE goster: pop sonrasi bu context artik
        // gecerli degil ve mesaj hic gorunmuyordu.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Devkom Pro'ya hos geldin!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    try {
      final restored = await _service.restorePurchases();
      if (!mounted) return;
      if (restored) {
        // Bkz. _purchase(): once provider'i yenile, snackbar'i pop'tan once goster.
        await context.read<AuthProvider>().refreshUser();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Satin almalar geri yuklendi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Geri yuklenecek satin alma bulunamadi')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildCloseButton(),
                Expanded(
                  child: _loading ? _buildLoading() : _buildContent(),
                ),
              ],
            ),
          ),
          if (_purchasing) _buildPurchasingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkBlue, AppTheme.primaryBlue, Color(0xFF1976D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.45, 1.0],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildFeatures(),
          const SizedBox(height: 8),
          _buildPlans(),
          _buildCta(),
          _buildFooter(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.workspace_premium, size: 40, color: Colors.amber),
          ),
          const SizedBox(height: 16),
          const Text(
            'Devkom Pro',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ogrenmeyi bir ust seviyeye tasi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: _features
            .map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(f.$1, color: Colors.amber, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        f.$2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildPlans() {
    if (_products.isEmpty) {
      // Neden bos oldugunu ayirt edip kullaniciya isine yarayan bir mesaj ver;
      // eskiden her durumda tek bir "Planlar yuklenemedi" gosteriliyordu.
      final failure = _service.lastFailure;
      final String message;
      final String hint;
      switch (failure) {
        case SubscriptionLoadFailure.paywallUnavailable:
          message = 'Abonelik planlarina su anda ulasilamiyor';
          hint = 'Internet baglantini kontrol edip tekrar dene.';
          break;
        case SubscriptionLoadFailure.noProducts:
          message = 'Abonelik planlari henuz hazir degil';
          hint = 'Kisa bir sure sonra tekrar dene.';
          break;
        case SubscriptionLoadFailure.error:
        case null:
          message = 'Planlar yuklenemedi';
          hint = 'Lutfen tekrar dene.';
          break;
      }

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.error_outline,
                color: Colors.white.withValues(alpha: 0.6), size: 40),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 4),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _load,
              child: const Text('Tekrar Dene',
                  style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: _products.map((product) {
          final isYearly = product.vendorProductId.contains('yearly');
          final isSelected =
              _selected?.vendorProductId == product.vendorProductId;
          final price = product.price.localizedString ?? '-';

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selected = product),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  left: isYearly ? 8 : 0,
                  right: isYearly ? 0 : 8,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.amber
                        : Colors.white.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isYearly)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'EN AVANTAJLI',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      const SizedBox(height: 20),
                    const SizedBox(height: 8),
                    Text(
                      isYearly ? 'Yillik' : 'Aylik',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? AppTheme.primaryBlue : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.darkBlue : Colors.white,
                      ),
                    ),
                    if (isYearly)
                      Text(
                        'Ayda ${_monthlyEquivalent(product)}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected ? Colors.grey[600] : Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _monthlyEquivalent(AdaptyPaywallProduct product) {
    final price = product.price;
    final monthly = price.amount / 12;
    final currency = price.currencyCode ?? '';
    return '${monthly.toStringAsFixed(2)} $currency'.trim();
  }

  Widget _buildCta() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _selected != null ? _purchase : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.white24,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            _selected != null
                ? 'Devam Et  ${_selected!.price.localizedString ?? ''}'
                : 'Plan Secin',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          TextButton(
            onPressed: _restore,
            child: Text(
              'Satin almalari geri yukle',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
            ),
          ),
          Text(
            'Abonelik otomatik yenilenir. Istediginiz zaman iptal edebilirsiniz. '
            'Odeme, satin alma onaylandiginda App Store / Google Play hesabiniza '
            'yansitilir. Abonelik, mevcut donem bitmeden en az 24 saat once iptal '
            'edilmezse otomatik olarak yenilenir.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _openUrl(_termsUrl),
                child: Text(
                  'Kullanim Kosullari',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                ),
              ),
              Text('·',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
              TextButton(
                onPressed: () => _openUrl(_privacyUrl),
                child: Text(
                  'Gizlilik Politikasi',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const String _termsUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
  static const String _privacyUrl =
      'https://oguzhnkurt.github.io/devkom_App1/privacy-policy.html';

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Baglanti acilamadi: $url')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Baglanti acilamadi: $url')),
        );
      }
    }
  }

  Widget _buildPurchasingOverlay() {
    return Container(
      color: Colors.black45,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Isleniyor...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
