import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated Tech/Space Background for Splash Screen
/// Creates floating particles with parallax effect
class AnimatedTechBackground extends StatefulWidget {
  final Widget child;

  const AnimatedTechBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedTechBackground> createState() => _AnimatedTechBackgroundState();
}

class _AnimatedTechBackgroundState extends State<AnimatedTechBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize particles
    _particles = List.generate(50, (index) => _createParticle());
  }

  Particle _createParticle() {
    return Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 4 + 1,
      speed: _random.nextDouble() * 0.5 + 0.2,
      opacity: _random.nextDouble() * 0.5 + 0.3,
      color: _random.nextBool()
          ? Colors.blue.withOpacity(0.6)
          : Colors.cyan.withOpacity(0.6),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
            ),
          ),
        ),

        // Animated particles
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                animation: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Grid overlay
        CustomPaint(
          painter: GridPainter(),
          size: Size.infinite,
        ),

        // Child content (logo)
        widget.child,
      ],
    );
  }
}

/// Particle class
class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

/// Particle painter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position
      particle.y = (particle.y + particle.speed * 0.001) % 1.0;

      // Calculate actual position
      final dx = particle.x * size.width;
      final dy = particle.y * size.height;

      // Draw particle
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(dx, dy),
        particle.size,
        paint,
      );

      // Draw glow effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(
        Offset(dx, dy),
        particle.size * 2,
        glowPaint,
      );
    }

    // Draw connections between nearby particles
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];

        final dx1 = p1.x * size.width;
        final dy1 = p1.y * size.height;
        final dx2 = p2.x * size.width;
        final dy2 = p2.y * size.height;

        final distance = math.sqrt(
          math.pow(dx2 - dx1, 2) + math.pow(dy2 - dy1, 2),
        );

        // Draw line if particles are close enough
        if (distance < 150) {
          final opacity = (1 - distance / 150) * 0.3;
          final linePaint = Paint()
            ..color = Colors.cyan.withOpacity(opacity)
            ..strokeWidth = 1;

          canvas.drawLine(
            Offset(dx1, dy1),
            Offset(dx2, dy2),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

/// Grid painter for tech aesthetic
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.05)
      ..strokeWidth = 1;

    const gridSize = 50.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}

/// Animated circuit lines effect
class CircuitLinesBackground extends StatefulWidget {
  final Widget child;

  const CircuitLinesBackground({
    super.key,
    required this.child,
  });

  @override
  State<CircuitLinesBackground> createState() => _CircuitLinesBackgroundState();
}

class _CircuitLinesBackgroundState extends State<CircuitLinesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
                Color(0xFF0f3460),
              ],
            ),
          ),
        ),

        // Animated circuit lines
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: CircuitPainter(animation: _controller.value),
              size: Size.infinite,
            );
          },
        ),

        // Child content
        widget.child,
      ],
    );
  }
}

/// Circuit lines painter
class CircuitPainter extends CustomPainter {
  final double animation;

  CircuitPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.5 * animation)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // Draw some circuit-like paths
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.6, size.height * 0.5);

    final path2 = Path()
      ..moveTo(size.width, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.4)
      ..lineTo(size.width * 0.4, size.height * 0.4);

    canvas.drawPath(path1, glowPaint);
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, glowPaint);
    canvas.drawPath(path2, paint);

    // Draw circuit nodes
    final nodePaint = Paint()
      ..color = Colors.cyan.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 4, nodePaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.5), 4, nodePaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 4, nodePaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.4), 4, nodePaint);
  }

  @override
  bool shouldRepaint(CircuitPainter oldDelegate) =>
      animation != oldDelegate.animation;
}
