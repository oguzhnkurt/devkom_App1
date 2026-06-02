import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../services/analytics_service.dart';
import '../screens/subscription_screen.dart';

/// Pro Feature Guard
/// Provides utility functions and widgets to protect Pro-only features
///
/// Usage:
/// 1. Guard a function call:
///    await ProFeatureGuard.guard(context, () async {
///      // Pro-only code here
///    });
///
/// 2. Guard a widget:
///    ProFeatureGuard.guardWidget(
///      context: context,
///      child: MyProFeature(),
///      fallback: UpgradeButton(),
///    );
///
/// 3. Check in code:
///    if (await ProFeatureGuard.hasAccess()) {
///      // Pro code
///    }
class ProFeatureGuard {
  static final SubscriptionService _subscriptionService = SubscriptionService();
  static final AnalyticsService _analytics = AnalyticsService();

  /// Check if user has Pro access
  /// Returns true if user has active Pro subscription
  static Future<bool> hasAccess() async {
    try {
      return await _subscriptionService.hasActiveSubscription();
    } catch (e) {
      debugPrint('❌ Error checking Pro access: $e');
      return false;
    }
  }

  /// Guard a function - Execute only if user has Pro
  /// Shows upgrade dialog if user doesn't have Pro
  ///
  /// Example:
  /// ```dart
  /// await ProFeatureGuard.guard(context, () async {
  ///   await unlimitedAIChat();
  /// });
  /// ```
  static Future<bool> guard(
    BuildContext context,
    Future<void> Function() onAllowed, {
    String? featureName,
  }) async {
    final hasPro = await hasAccess();

    if (hasPro) {
      await onAllowed();
      return true;
    } else {
      // Track Pro feature block
      if (featureName != null) {
        await _analytics.logProFeatureBlocked(featureName);
      }
      _showUpgradeDialog(context, featureName: featureName);
      return false;
    }
  }

  /// Guard a widget - Show only if user has Pro
  /// Shows fallback widget or upgrade prompt if user doesn't have Pro
  ///
  /// Example:
  /// ```dart
  /// ProFeatureGuard.guardWidget(
  ///   context: context,
  ///   child: UnlimitedAIChatScreen(),
  ///   fallback: UpgradePrompt(feature: 'AI Sohbet'),
  /// );
  /// ```
  static Widget guardWidget({
    required BuildContext context,
    required Widget child,
    Widget? fallback,
    String? featureName,
  }) {
    return FutureBuilder<bool>(
      future: hasAccess(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final hasPro = snapshot.data ?? false;

        if (hasPro) {
          return child;
        } else {
          return fallback ??
              _buildDefaultFallback(context, featureName: featureName);
        }
      },
    );
  }

  /// Guard a navigation - Navigate only if user has Pro
  /// Shows upgrade dialog if user doesn't have Pro
  ///
  /// Example:
  /// ```dart
  /// ProFeatureGuard.guardNavigation(
  ///   context,
  ///   destination: UnlimitedGamesScreen(),
  ///   featureName: 'Sınırsız Oyunlar',
  /// );
  /// ```
  static Future<void> guardNavigation(
    BuildContext context, {
    required Widget destination,
    String? featureName,
  }) async {
    final hasPro = await hasAccess();

    if (hasPro) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    } else {
      // Track Pro feature block
      if (featureName != null) {
        await _analytics.logProFeatureBlocked(featureName);
      }
      _showUpgradeDialog(context, featureName: featureName);
    }
  }

  /// Show upgrade dialog
  static void _showUpgradeDialog(BuildContext context, {String? featureName}) {
    // Track upgrade prompt shown
    _analytics.logUpgradePromptShown(featureName ?? 'unknown');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            const Text('Pro Özellik'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (featureName != null) ...[
              Text(
                '"$featureName"',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Text(
              'Bu özellik sadece Devkom Pro kullanıcıları için kullanılabilir.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pro ile:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem('Sınırsız oyun erişimi'),
                  _buildFeatureItem('Sınırsız AI sohbet'),
                  _buildFeatureItem('Özel içerikler'),
                  _buildFeatureItem('Gelişmiş raporlar'),
                  _buildFeatureItem('Öncelikli destek'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.upgrade),
            label: const Text('Pro\'ya Yükselt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  /// Build default fallback widget when user doesn't have Pro
  static Widget _buildDefaultFallback(BuildContext context,
      {String? featureName}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              featureName ?? 'Pro Özellik',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu özellik Devkom Pro üyeleri için özel!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.upgrade),
              label: const Text('Pro\'ya Yükselt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pro Badge Widget - Show next to user's name
  static Widget proBadge({double size = 20}) {
    return FutureBuilder<bool>(
      future: hasAccess(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(left: 4),
          padding: EdgeInsets.symmetric(
            horizontal: size * 0.3,
            vertical: size * 0.1,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.orange],
            ),
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: size * 0.7, color: Colors.white),
              SizedBox(width: size * 0.2),
              Text(
                'PRO',
                style: TextStyle(
                  fontSize: size * 0.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Check and show upgrade prompt if needed
  /// Useful for features that should show a warning but not block
  ///
  /// Returns true if user has Pro, false otherwise
  static Future<bool> checkAndPrompt(
    BuildContext context, {
    String? featureName,
    String? message,
  }) async {
    final hasPro = await hasAccess();

    if (!hasPro && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Bu özellik Pro üyelere özeldir'),
          action: SnackBarAction(
            label: 'Yükselt',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    return hasPro;
  }
}

/// Pro Feature List Card Widget
/// Shows a beautiful list of Pro features
class ProFeaturesCard extends StatelessWidget {
  final VoidCallback? onUpgradePressed;

  const ProFeaturesCard({Key? key, this.onUpgradePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.star, color: Colors.amber, size: 32),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Devkom Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeature(Icons.games, 'Sınırsız Oyun Erişimi'),
            _buildFeature(Icons.chat, 'Sınırsız AI Sohbet'),
            _buildFeature(Icons.school, 'Özel İçerikler ve Dersler'),
            _buildFeature(Icons.analytics, 'Gelişmiş Raporlar'),
            _buildFeature(Icons.family_restroom, 'Aile Paylaşımı'),
            _buildFeature(Icons.support, 'Öncelikli Destek'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgradePressed ??
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionScreen(),
                        ),
                      );
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pro\'ya Yükselt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}
