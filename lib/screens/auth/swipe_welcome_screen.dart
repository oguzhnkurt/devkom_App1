import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'onboarding_screen.dart';
import '../../utils/app_localizations.dart';

/// Modern Swipe-to-Unlock Welcome Screen
/// Devkom Yazılım - Smart Education Platform
/// Shows on first app launch, before onboarding
class SwipeWelcomeScreen extends StatefulWidget {
  const SwipeWelcomeScreen({super.key});

  @override
  State<SwipeWelcomeScreen> createState() => _SwipeWelcomeScreenState();
}

class _SwipeWelcomeScreenState extends State<SwipeWelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  double _dragPosition = 0.0;
  bool _isUnlocked = false;
  final double _maxDragDistance = 250.0;

  @override
  void initState() {
    super.initState();

    // Glow animation for background
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Pulse animation for slider
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0.0, _maxDragDistance);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragPosition >= _maxDragDistance * 0.85) {
      // Unlocked!
      setState(() {
        _isUnlocked = true;
        _dragPosition = _maxDragDistance;
      });

      // Navigate to onboarding after animation
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      });
    } else {
      // Reset position
      setState(() {
        _dragPosition = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    _glowAnimation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF0f3460),
                    const Color(0xFF16213e),
                    _glowAnimation.value,
                  )!,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Branding
                  Text(
                    'DEVKOM',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF00D9FF), Color(0xFF9D4EDD)],
                        ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                  ),

                  const SizedBox(height: 100),

                  // Main Content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Icon/Logo
                        Transform.scale(
                          scale: 1.0 + math.sin(_glowAnimation.value * math.pi) * 0.05,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF667eea).withValues(alpha: 0.4 + _glowAnimation.value * 0.3),
                                  blurRadius: 40 + _glowAnimation.value * 20,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.rocket_launch,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Main Title
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFE0E0E0)],
                          ).createShader(bounds),
                          child: const Text(
                            'SMART\nEDUCATION',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle with gradient
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00D9FF), Color(0xFF9D4EDD)],
                          ).createShader(bounds),
                          child: const Text(
                            'PLATFORM',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            loc.smartEducationPlatform,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Swipe to Unlock Widget
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: _buildSwipeToUnlock(screenWidth),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwipeToUnlock(double screenWidth) {
    final sliderWidth = screenWidth - 80;
    final progress = _dragPosition / _maxDragDistance;

    return Container(
      width: sliderWidth,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Progress background
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _dragPosition + 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFF667eea),
                    const Color(0xFF00FF87),
                    progress,
                  )!,
                  Color.lerp(
                    const Color(0xFF764ba2),
                    const Color(0xFF60EFFF),
                    progress,
                  )!,
                ],
              ),
            ),
          ),

          // Arrow hints (right side)
          if (!_isUnlocked)
            Positioned(
              right: 80,
              top: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.keyboard_double_arrow_right,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 28,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_double_arrow_right,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 28,
                    ),
                  ],
                ),
                builder: (context, child) {
                  return Opacity(
                    opacity: 1.0 - (progress * 2).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(_pulseAnimation.value * 5, 0),
                      child: child,
                    ),
                  );
                },
              ),
            ),

          // Draggable circle
          AnimatedPositioned(
            duration: _isUnlocked ? const Duration(milliseconds: 300) : Duration.zero,
            curve: Curves.easeOut,
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: _isUnlocked ? null : _onHorizontalDragUpdate,
              onHorizontalDragEnd: _isUnlocked ? null : _onHorizontalDragEnd,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: _isUnlocked
                        ? const Color(0xFF00FF87).withValues(alpha: 0.6)
                        : const Color(0xFF667eea).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isUnlocked ? Icons.check : Icons.arrow_forward,
                  color: _isUnlocked
                    ? const Color(0xFF00FF87)
                    : const Color(0xFF667eea),
                  size: 32,
                ),
              ),
            ),
          ),

          // Swipe text
          if (!_isUnlocked && _dragPosition < 50)
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 80),
                  child: Text(
                    AppLocalizations.of(context).swipeToStart,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
