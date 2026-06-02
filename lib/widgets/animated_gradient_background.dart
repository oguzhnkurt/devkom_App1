import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated Gradient Background
/// Creates a flowing, animated gradient effect perfect for backgrounds
class AnimatedGradientBackground extends StatefulWidget {
  final List<Color> colors;
  final Duration duration;
  final Widget? child;
  final double opacity;

  const AnimatedGradientBackground({
    Key? key,
    required this.colors,
    this.duration = const Duration(seconds: 4),
    this.child,
    this.opacity = 0.3,
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                math.cos(_animation.value * 2 * math.pi),
                math.sin(_animation.value * 2 * math.pi),
              ),
              end: Alignment(
                -math.cos(_animation.value * 2 * math.pi),
                -math.sin(_animation.value * 2 * math.pi),
              ),
              colors: widget.colors,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(widget.opacity),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Pulsing Icon Animation
/// Makes icons pulse with a glowing effect
class PulsingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;

  const PulsingIcon({
    Key? key,
    required this.icon,
    this.size = 72,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  State<PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Transform.scale(
              scale: _scaleAnimation.value * 1.5,
              child: Container(
                width: widget.size * 1.5,
                height: widget.size * 1.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(_opacityAnimation.value * 0.3),
                ),
              ),
            ),
            // Middle glow
            Transform.scale(
              scale: _scaleAnimation.value * 1.2,
              child: Container(
                width: widget.size * 1.2,
                height: widget.size * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(_opacityAnimation.value * 0.5),
                ),
              ),
            ),
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: widget.size,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}
