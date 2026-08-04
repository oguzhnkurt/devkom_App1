import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import 'access_denied_screen.dart';

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  @override
  void initState() {
    super.initState();
    // Check access permission after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccess();
    });
  }

  void _checkAccess() {
    final authProvider = context.read<AuthProvider>();

    // If user doesn't have live camera access, navigate to access denied screen
    if (!authProvider.hasLiveCameraAccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AccessDeniedScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CANLI KAMERA'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Show loading while checking access
          if (authProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If no access, show nothing (navigation will happen)
          if (!authProvider.hasLiveCameraAccess) {
            return const SizedBox.shrink();
          }

          // User has access - show camera placeholder
          return Container(
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
            child: Column(
              children: [
                // Camera View Placeholder
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Camera Icon
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentTeal,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.videocam,
                            size: 80,
                            color: AppTheme.accentTeal,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Canlı Kamera',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Kamera görüntüsü burada gösterilecek',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.lightGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Live indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CANLI',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Control Panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.darkGray.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Control Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlButton(
                              icon: Icons.mic_off,
                              label: 'Ses',
                              onPressed: () {
                                // TODO: Implement audio toggle
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ses kontrolü yakında eklenecek'),
                                  ),
                                );
                              },
                            ),
                            _buildControlButton(
                              icon: Icons.fullscreen,
                              label: 'Tam Ekran',
                              onPressed: () {
                                // TODO: Implement fullscreen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tam ekran yakında eklenecek'),
                                  ),
                                );
                              },
                            ),
                            _buildControlButton(
                              icon: Icons.settings,
                              label: 'Ayarlar',
                              onPressed: () {
                                // TODO: Implement settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ayarlar yakında eklenecek'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Info Text
                        Text(
                          'Kamera entegrasyonu geliştirme aşamasındadır',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightGray.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.accentTeal.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon),
            color: AppTheme.accentTeal,
            iconSize: 28,
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
