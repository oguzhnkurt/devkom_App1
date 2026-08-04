import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_localizations.dart';
import '../../theme.dart';
import '../role_based_home_screen.dart';
import '../roboakademi/add_workshop_child_screen.dart';

/// Purpose Selection Screen - Shown after registration
/// User selects their purpose: Learn (Student), Track Child (Parent), or Visit (Visitor)
class PurposeSelectionScreen extends StatefulWidget {
  const PurposeSelectionScreen({super.key});

  @override
  State<PurposeSelectionScreen> createState() => _PurposeSelectionScreenState();
}

class _PurposeSelectionScreenState extends State<PurposeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectPurpose(BuildContext context, UserRole role, {bool isRoboAkademi = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Update user role in Firestore
      await authProvider.updateUserRole(role, isRoboAkademi: isRoboAkademi);

      // Navigate to home screen (RoboAkademi parents go via the
      // add-child screen first so they can register their child right away)
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isRoboAkademi
              ? const AddWorkshopChildScreen()
              : const RoleBasedHomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                    // Title
                    Text(
                      loc.howWouldYouLikeToUseDevkom,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      loc.selectYourPurpose,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Student Option Card
                    _buildPurposeCard(
                      context: context,
                      icon: Icons.school_rounded,
                      title: loc.toLearn,
                      subtitle: loc.toLearnDescription,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF8E7CE5)],
                      ),
                      onTap: () => _selectPurpose(context, UserRole.student),
                    ),

                    const SizedBox(height: 14),

                    // Parent Option Card
                    _buildPurposeCard(
                      context: context,
                      icon: Icons.family_restroom_rounded,
                      title: loc.trackMyChild,
                      subtitle: loc.trackMyChildDescription,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B894), Color(0xFF00D2A0)],
                      ),
                      onTap: () => _selectPurpose(context, UserRole.parent),
                      badge: loc.fullAccessContinues,
                    ),

                    const SizedBox(height: 14),

                    // RoboAkademi Workshop Parent Option Card
                    _buildPurposeCard(
                      context: context,
                      icon: Icons.precision_manufacturing_rounded,
                      title: 'RoboAkademi Atölye Öğrencim Var',
                      subtitle: 'Çocuğumun robotik kodlama atölyesindeki yoklama, puan ve ödeme durumunu takip etmek istiyorum',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00979D), Color(0xFF00BCD4)],
                      ),
                      onTap: () => _selectPurpose(context, UserRole.parent, isRoboAkademi: true),
                      badge: 'Atölye takip paneli',
                    ),

                    const SizedBox(height: 14),

                    // Visitor Option Card (NEW!)
                    _buildPurposeCard(
                      context: context,
                      icon: Icons.explore_rounded,
                      title: 'Ziyaret Etmek İçin',
                      subtitle: 'AI, robotik ve teknoloji dünyasını keşfetmek istiyorum',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                      ),
                      onTap: () => _selectPurpose(context, UserRole.visitor),
                      badge: 'Öğretmen ataması yok',
                    ),

                    const SizedBox(height: 32),

                    // Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.canChangeInSettings,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Skip option: default to student role so undecided users
                    // aren't blocked from entering the app. They can still
                    // change their role later from profile settings.
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => _selectPurpose(context, UserRole.student),
                      child: Text(
                        'Şimdilik atla, öğrenci olarak devam et',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurposeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
