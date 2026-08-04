import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_model.dart';

class GameCard extends StatefulWidget {
  final GameModel game;
  final VoidCallback onTap;
  final bool isLocked;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getCategoryColors().first.withValues(alpha: 0.3),
                blurRadius: _isHovered ? 25 : 15,
                offset: const Offset(0, 10),
                spreadRadius: _isHovered ? 3 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLocked
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bu oyuna erişim izniniz yok. Lütfen giriş yapın.'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    : widget.onTap,
                child: Stack(
                  children: [
                    // Background with gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _getCategoryColors(),
                        ),
                      ),
                    ),

                    // Animated particles background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ParticleBackgroundPainter(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),

                    // Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Thumbnail Section with enhanced visuals (more compact)
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                            ),
                            child: Stack(
                              children: [
                                // Background Image - Always show icon thumbnail for consistency
                                _buildIconThumbnail(),

                                // Gradient overlay for better text visibility
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.3),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Top badges
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  right: 8,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Type Badge
                                      Flexible(
                                        child: _buildBadge(
                                          _getTypeLabel(),
                                          Icons.category,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      // Difficulty Stars
                                      _buildDifficultyBadge(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Content Section with modern design
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title with icon
                                Row(
                                  children: [
                                    Icon(
                                      _getCategoryIcon(),
                                      size: 20,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.game.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Description
                                Expanded(
                                  child: Text(
                                    widget.game.description,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Bottom info bar
                                Row(
                                  children: [
                                    // Duration
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.timer_outlined,
                                            size: 14,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${widget.game.estimatedMinutes} dk',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),

                                    // Play button
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.3),
                                            Colors.white.withValues(alpha: 0.2),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Locked overlay
                    if (widget.isLocked)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Erişim İzniniz Yok',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Giriş Yapın',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconThumbnail() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getCategoryIcon(),
          size: 60,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Icon(
              Icons.star,
              size: 10,
              color: index < widget.game.difficulty
                  ? const Color(0xFFFFC107)
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getCategoryColors() {
    switch (widget.game.category) {
      case GameCategory.quiz:
        return [
          const Color(0xFFFF6B35),
          const Color(0xFFF7931E),
        ];
      case GameCategory.arduino:
        return [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
        ];
      case GameCategory.python:
        return [
          const Color(0xFF11998e),
          const Color(0xFF38ef7d),
        ];
      case GameCategory.age4to6:
        return [
          const Color(0xFFfb8634),
          const Color(0xFFf57300),
        ];
      case GameCategory.age7to9:
        return [
          const Color(0xFFa8099c),
          const Color(0xFFc92e9b),
        ];
      case GameCategory.robotics:
        return [
          const Color(0xFFf093fb),
          const Color(0xFFf5576c),
        ];
      case GameCategory.software:
        return [
          const Color(0xFF4facfe),
          const Color(0xFF00f2fe),
        ];
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.game.category) {
      case GameCategory.quiz:
        return Icons.quiz;
      case GameCategory.arduino:
        return Icons.memory;
      case GameCategory.python:
        return Icons.code;
      case GameCategory.age4to6:
        return Icons.child_care;
      case GameCategory.age7to9:
        return Icons.school;
      case GameCategory.robotics:
        return Icons.precision_manufacturing;
      case GameCategory.software:
        return Icons.computer;
    }
  }

  String _getTypeLabel() {
    return widget.game.getTypeDisplayName();
  }
}

/// Custom painter for particle background effect
class _ParticleBackgroundPainter extends CustomPainter {
  final Color color;

  _ParticleBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticleBackgroundPainter oldDelegate) => false;
}
