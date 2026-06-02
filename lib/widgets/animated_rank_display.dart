import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

/// Animated Rank Display Widget
/// Shows user's rank with celebration animation
class AnimatedRankDisplay extends StatefulWidget {
  final int rank;
  final int totalScore;
  final String userName;
  final bool isNewRecord;
  final int? previousRank;
  final VoidCallback onClose;

  const AnimatedRankDisplay({
    Key? key,
    required this.rank,
    required this.totalScore,
    required this.userName,
    this.isNewRecord = false,
    this.previousRank,
    required this.onClose,
  }) : super(key: key);

  @override
  State<AnimatedRankDisplay> createState() => _AnimatedRankDisplayState();
}

class _AnimatedRankDisplayState extends State<AnimatedRankDisplay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rankController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<int> _rankAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    // Slide animation from bottom
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Scale animation for rank badge
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Animated rank counter
    _rankController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rankAnimation = IntTween(
      begin: widget.previousRank ?? (widget.rank + 20),
      end: widget.rank,
    ).animate(CurvedAnimation(
      parent: _rankController,
      curve: Curves.easeOutCubic,
    ));

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
      _rankController.forward();
    });

    // Start confetti for top 10
    if (widget.rank <= 10) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _rankController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Color _getRankColor() {
    if (widget.rank == 1) return Colors.amber;
    if (widget.rank == 2) return Colors.grey.shade300;
    if (widget.rank == 3) return Colors.brown.shade300;
    if (widget.rank <= 10) return Colors.blue;
    return Colors.green;
  }

  IconData _getRankIcon() {
    if (widget.rank == 1) return Icons.emoji_events;
    if (widget.rank <= 3) return Icons.military_tech;
    if (widget.rank <= 10) return Icons.star;
    return Icons.trending_up;
  }

  String _getRankMessage() {
    if (widget.isNewRecord && widget.previousRank != null) {
      final improvement = widget.previousRank! - widget.rank;
      return 'Yeni Rekor! ${improvement} sıra yükseldin!';
    }
    if (widget.rank == 1) return 'Birinci Oldun!';
    if (widget.rank <= 3) return 'Harika! İlk 3\'tesin!';
    if (widget.rank <= 10) return 'Süper! İlk 10\'dasın!';
    return 'Tebrikler!';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.2,
            shouldLoop: false,
            colors: [
              Colors.amber,
              Colors.blue,
              Colors.green,
              Colors.red,
              Colors.purple,
            ],
          ),
        ),

        // Main content
        SlideTransition(
          position: _slideAnimation,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getRankColor().withOpacity(0.1),
                    _getRankColor().withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rank badge with animation
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getRankColor(),
                            boxShadow: [
                              BoxShadow(
                                color: _getRankColor().withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getRankIcon(),
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              AnimatedBuilder(
                                animation: _rankAnimation,
                                builder: (context, child) {
                                  return Text(
                                    '${_rankAnimation.value}.',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Message
                  Text(
                    _getRankMessage(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _getRankColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // User info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.totalScore} Puan',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getRankColor(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Devam Et',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
