import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/animated_tech_background.dart';
import 'auth_wrapper.dart';
import 'login_screen.dart';
import '../../utils/app_localizations.dart';
import '../unified_home_screen.dart';
import 'swipe_welcome_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late AnimationController _floatingController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;

  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    // Button animations
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeIn,
      ),
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOutBack,
      ),
    );

    // Floating animation (continuous)
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations sequentially
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _continueAsVisitor() async {
    if (!mounted) return;

    // Mark onboarding as seen
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.markOnboardingAsSeen();

    // Navigate to unified home screen (supports unauthenticated visitors)
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const UnifiedHomeScreen()),
    );
  }

  void _navigateToLogin() async {
    if (!mounted) return;

    // Mark onboarding as seen
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.markOnboardingAsSeen();

    // Navigate to swipe welcome screen for login
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SwipeWelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedTechBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo with animations
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _logoSlideAnimation,
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: AnimatedBuilder(
                            animation: _floatingAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _floatingAnimation.value),
                                child: child,
                              );
                            },
                            child: Container(
                              width: size.width * 0.6,
                              height: size.width * 0.6,
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withValues(alpha: 0.4),
                                    blurRadius: 50,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                    blurRadius: 80,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Animated title and subtitle
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          children: [
                            // Main title
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.cyan.withValues(alpha: 0.2),
                                    Colors.blue.withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.cyan.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.code,
                                    color: Colors.cyan[300],
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'DEVKOM',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                      shadows: [
                                        Shadow(
                                          color: Colors.cyan.withValues(alpha: 0.5),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Subtitle
                            Text(
                              loc.softwareRoboticsEducation,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.4,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Features
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _buildFeatureChip(loc.robotics),
                                _buildFeatureChip(loc.coding),
                                _buildFeatureChip(loc.chess),
                                _buildFeatureChip(loc.games),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 3),

                // Main button - Continue as Visitor
                AnimatedBuilder(
                  animation: _buttonController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _buttonFadeAnimation,
                      child: ScaleTransition(
                        scale: _buttonScaleAnimation,
                        child: Container(
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00C9FF),
                                Color(0xFF0099FF),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _continueAsVisitor,
                              borderRadius: BorderRadius.circular(32),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.explore,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    loc.explore,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Login button (secondary)
                AnimatedBuilder(
                  animation: _buttonController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _buttonFadeAnimation,
                      child: TextButton(
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.login,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              loc.continueWithLogin,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
