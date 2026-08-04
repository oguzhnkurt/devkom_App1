import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ERİŞİM ENGELLENDİ'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBlue.withValues(alpha: 0.9),
              AppTheme.darkBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Lock Icon with Animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.5),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.block,
                          size: 100,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),

                // Main Message
                Text(
                  'Erişim Yetkiniz Bulunmamaktadır',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Error Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: AppTheme.darkGray,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Icon
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.accentTeal,
                          size: 40,
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          'Bu içeriğe erişim yetkiniz bulunmamaktadır',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Divider(
                          color: AppTheme.lightGray.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                        const SizedBox(height: 16),

                        // Explanation
                        Text(
                          'Canlı kamera erişimi sadece Veli hesapları için mevcuttur.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightGray,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Additional Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Erişim için Veli hesabı ile giriş yapmanız gerekmektedir.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Access Types Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.darkGray.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.accentTeal.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Erişim Türleri:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.accentTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAccessTypeRow(
                        icon: Icons.check_circle,
                        text: 'Veli - Tam erişim (Canlı kamera dahil)',
                        hasAccess: true,
                      ),
                      const SizedBox(height: 12),
                      _buildAccessTypeRow(
                        icon: Icons.cancel,
                        text: 'Ziyaretçi - Sınırlı erişim',
                        hasAccess: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Ana Sayfaya Dön'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.accentTeal,
                      foregroundColor: AppTheme.darkBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Support Button
                OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri(
                      scheme: 'mailto',
                      path: 'info@devkom.com.tr',
                      query: 'subject=DevKom Destek Talebi',
                    );
                    try {
                      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                      if (!launched && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('E-posta uygulaması açılamadı. info@devkom.com.tr adresinden bize ulaşabilirsiniz.'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('E-posta uygulaması açılamadı. info@devkom.com.tr adresinden bize ulaşabilirsiniz.'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Destek İle İletişime Geç'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    side: const BorderSide(color: AppTheme.accentTeal, width: 2),
                    foregroundColor: AppTheme.accentTeal,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessTypeRow({
    required IconData icon,
    required String text,
    required bool hasAccess,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: hasAccess ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: hasAccess
                  ? Colors.green.shade200
                  : Colors.red.shade200,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
