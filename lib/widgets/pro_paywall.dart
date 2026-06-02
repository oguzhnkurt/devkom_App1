import 'package:flutter/material.dart';
import '../screens/subscription_screen.dart';
import '../theme.dart';

/// Pro Paywall Widget - Shown when user hits a limit or tries to access Pro feature
class ProPaywall extends StatelessWidget {
  final String title;
  final String message;
  final String? featureDescription;
  final VoidCallback? onUpgrade;

  const ProPaywall({
    super.key,
    required this.title,
    required this.message,
    this.featureDescription,
    this.onUpgrade,
  });

  /// Show paywall as bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String? featureDescription,
    VoidCallback? onUpgrade,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProPaywall(
        title: title,
        message: message,
        featureDescription: featureDescription,
        onUpgrade: onUpgrade,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Pro Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Pro Features List
            _buildFeaturesList(),
            const SizedBox(height: 24),

            // Upgrade Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgrade ?? () => _handleUpgrade(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pro\'ya Geç - İlk 3 Ay ₺69.99',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Belki Daha Sonra',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.check_circle,
          text: 'Sınırsız paylaşım yapın',
        ),
        _buildFeatureItem(
          icon: Icons.smart_toy,
          text: 'Sınırsız AI asistan kullanımı',
        ),
        _buildFeatureItem(
          icon: Icons.analytics,
          text: 'Detaylı ilerleme raporları',
        ),
        _buildFeatureItem(
          icon: Icons.workspace_premium,
          text: 'Özel sertifikalar',
        ),
        _buildFeatureItem(
          icon: Icons.download,
          text: 'Offline içerik indirme',
        ),
        _buildFeatureItem(
          icon: Icons.support_agent,
          text: 'Öncelikli destek',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }
}

/// Quick helper to show limit reached paywall
class LimitReachedPaywall {
  static Future<void> showPostLimit(BuildContext context, int remaining) {
    return ProPaywall.show(
      context: context,
      title: 'Günlük Paylaşım Limitine Ulaştınız',
      message: 'Bugün $remaining/2 paylaşımınızı kullandınız. Pro ile sınırsız paylaşım yapın!',
    );
  }

  static Future<void> showAiMessageLimit(BuildContext context, int remaining) {
    return ProPaywall.show(
      context: context,
      title: 'AI Mesaj Limitine Ulaştınız',
      message: 'Bugün $remaining/10 AI mesajınızı kullandınız. Pro ile sınırsız sohbet edin!',
    );
  }
}
