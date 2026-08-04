import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/settings_provider.dart';
import '../../theme.dart';
import '../../utils/app_localizations.dart';
import '../../services/subscription_service.dart';
import '../subscription_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings.toUpperCase()),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              // Subscription Section
              _buildSectionHeader(context, 'Devkom Pro', Icons.star),
              FutureBuilder<Map<String, dynamic>?>(
                future: SubscriptionService().getSubscriptionInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: Icon(Icons.hourglass_empty),
                      title: Text('Yükleniyor...'),
                    );
                  }

                  final subscriptionInfo = snapshot.data;
                  final bool isPro = subscriptionInfo?['isActive'] ?? false;

                  if (isPro) {
                    // User has active subscription
                    final expiryDate = subscriptionInfo!['expiryDate'] as DateTime?;
                    final expiryText = expiryDate != null
                        ? 'Bitiş: \${expiryDate.day}/\${expiryDate.month}/\${expiryDate.year}'
                        : 'Aktif';

                    return Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.amber, Colors.orange],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.star, color: Colors.white),
                          ),
                          title: const Text(
                            'Devkom Pro Aktif',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(expiryText),
                          trailing: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        ListTile(
                          leading: const Icon(Icons.restore),
                          title: const Text('Satın Almaları Geri Yükle'),
                          subtitle: const Text('Önceki satın almalarınızı geri yükleyin'),
                          onTap: () async {
                            try {
                              await SubscriptionService().restorePurchases();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Satın almalar geri yüklendi'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hata: \$e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    );
                  } else {
                    // User doesn't have subscription
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[700]!, Colors.purple[700]!],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.upgrade, color: Colors.white),
                      ),
                      title: const Text(
                        'Devkom Pro\'ya Yukselt',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Tum ozelliklere sinirsiz erisim'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              const Divider(),

              // Language Section
              _buildSectionHeader(context, loc.languageAndRegion, Icons.language),
              _buildLanguageTile(context, settings),
              const Divider(),

              // Notifications Section
              _buildSectionHeader(context, loc.notifications, Icons.notifications),
              _buildSwitchTile(
                context,
                title: loc.enableNotifications,
                subtitle: loc.appNotifications,
                icon: Icons.notifications_active,
                value: settings.notificationsEnabled,
                onChanged: (value) => settings.setNotificationsEnabled(value),
              ),
              if (settings.notificationsEnabled) ...[
                _buildSwitchTile(
                  context,
                  title: loc.sound,
                  subtitle: loc.notificationSounds,
                  icon: Icons.volume_up,
                  value: settings.soundEnabled,
                  onChanged: (value) => settings.setSoundEnabled(value),
                ),
                _buildSwitchTile(
                  context,
                  title: loc.vibration,
                  subtitle: loc.notificationVibration,
                  icon: Icons.vibration,
                  value: settings.vibrationEnabled,
                  onChanged: (value) => settings.setVibrationEnabled(value),
                ),
              ],
              const Divider(),

              // Accessibility Section
              _buildSectionHeader(context, loc.accessibility, Icons.accessibility_new),
              _buildTextScaleTile(context, settings),
              _buildSwitchTile(
                context,
                title: loc.highContrast,
                subtitle: loc.makeColorsBolder,
                icon: Icons.contrast,
                value: settings.highContrastMode,
                onChanged: (value) => settings.setHighContrastMode(value),
              ),
              const Divider(),

              // Privacy Section
              _buildSectionHeader(context, loc.privacy, Icons.privacy_tip),
              _buildSwitchTile(
                context,
                title: loc.dataSharing,
                subtitle: loc.shareAnonymousData,
                icon: Icons.analytics,
                value: settings.shareDataForImprovement,
                onChanged: (value) => settings.setShareDataForImprovement(value),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description_outlined, color: AppTheme.primaryBlue),
                ),
                title: Text(
                  settings.locale.languageCode == 'en' ? 'Privacy Policy' : 'Gizlilik Politikası',
                ),
                subtitle: Text(
                  settings.locale.languageCode == 'en'
                      ? 'View our privacy policy and account deletion'
                      : 'Gizlilik politikamızı ve hesap silmeyi görüntüle',
                ),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () async {
                  final uri = Uri.parse(
                    'https://oguzhnkurt.github.io/devkom_App1/privacy-policy.html',
                  );
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
              const Divider(),

              // App Experience Section
              _buildSectionHeader(context, loc.appExperience, Icons.touch_app),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                ),
                title: Text(loc.showOnboardingAgain),
                subtitle: Text(loc.onboardingWillShow),
                trailing: ElevatedButton.icon(
                  onPressed: () async {
                    await settings.resetOnboarding();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.onboardingResetMessage),
                          backgroundColor: AppTheme.successGreen,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(loc.reset),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const Divider(),

              // About Section
              _buildSectionHeader(context, loc.about, Icons.info),
              _buildAboutTile(context),
              const SizedBox(height: 16),

              // Reset Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: OutlinedButton.icon(
                  onPressed: () => _showResetDialog(context, settings),
                  icon: const Icon(Icons.restore, color: Colors.red),
                  label: Text(
                    loc.resetSettings,
                    style: const TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, SettingsProvider settings) {
    final loc = AppLocalizations.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.accentTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.translate, color: AppTheme.accentTeal),
      ),
      title: Text(loc.language, style: const TextStyle(inherit: true)),
      subtitle: Text(settings.currentLanguageName, style: const TextStyle(inherit: true)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, settings),
    );
  }

  Widget _buildTextScaleTile(BuildContext context, SettingsProvider settings) {
    final loc = AppLocalizations.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.text_fields, color: Colors.orange),
      ),
      title: Text(loc.textSize, style: const TextStyle(inherit: true)),
      subtitle: Slider(
        value: settings.textScaleFactor,
        min: 0.8,
        max: 1.4,
        divisions: 6,
        label: '${(settings.textScaleFactor * 100).round()}%',
        onChanged: (value) => settings.setTextScaleFactor(value),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.accentTeal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.accentTeal),
      ),
      title: Text(title, style: const TextStyle(inherit: true)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, inherit: true)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.accentTeal,
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.info_outline, color: Colors.purple),
      ),
      title: Text(loc.aboutApp, style: const TextStyle(inherit: true)),
      subtitle: Text('${loc.version} 1.0.0', style: const TextStyle(inherit: true)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAboutDialog(context),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: Text(loc.turkish),
              subtitle: const Text('Turkish'),
              value: const Locale('tr', 'TR'),
              groupValue: settings.locale,
              onChanged: (value) async {
                if (value != null && value != settings.locale) {
                  Navigator.pop(dialogContext);
                  _showLanguageChangingOverlay(context, 'tr');
                  await Future.delayed(const Duration(milliseconds: 100));
                  await settings.setLocale(value);
                  await Future.delayed(const Duration(milliseconds: 1500));
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close loading overlay
                  }
                } else {
                  Navigator.pop(dialogContext);
                }
              },
            ),
            RadioListTile<Locale>(
              title: Text(loc.english),
              subtitle: const Text('İngilizce'),
              value: const Locale('en', 'US'),
              groupValue: settings.locale,
              onChanged: (value) async {
                if (value != null && value != settings.locale) {
                  Navigator.pop(dialogContext);
                  _showLanguageChangingOverlay(context, 'en');
                  await Future.delayed(const Duration(milliseconds: 100));
                  await settings.setLocale(value);
                  await Future.delayed(const Duration(milliseconds: 1500));
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close loading overlay
                  }
                } else {
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.cancel),
          ),
        ],
      ),
    );
  }

  void _showLanguageChangingOverlay(BuildContext context, String languageCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: _LanguageChangingOverlay(languageCode: languageCode),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${loc.version}: 1.0.0'),
            const SizedBox(height: 8),
            Text(loc.appDescription),
            const SizedBox(height: 16),
            const Text('© 2025 Devkom', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.resetSettings),
        content: Text(loc.resetConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              settings.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.settingsResetSuccess),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.reset),
          ),
        ],
      ),
    );
  }
}

/// Modern language changing overlay with animation
class _LanguageChangingOverlay extends StatefulWidget {
  final String languageCode;

  const _LanguageChangingOverlay({required this.languageCode});

  @override
  State<_LanguageChangingOverlay> createState() => _LanguageChangingOverlayState();
}

class _LanguageChangingOverlayState extends State<_LanguageChangingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.languageCode == 'tr'
        ? 'Dil Türkçe olarak değiştirildi'
        : 'The language has been changed to English';

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.95),
                    AppTheme.accentTeal.withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated check icon
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 50,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Success message
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
