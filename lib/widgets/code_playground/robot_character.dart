import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Robot character with animations
class RobotCharacter extends StatefulWidget {
  final double size;
  final int direction; // 0: up, 1: right, 2: down, 3: left
  final bool isJumping;
  final bool isCollecting;

  const RobotCharacter({
    super.key,
    this.size = 60,
    this.direction = 0,
    this.isJumping = false,
    this.isCollecting = false,
  });

  @override
  State<RobotCharacter> createState() => _RobotCharacterState();
}

class _RobotCharacterState extends State<RobotCharacter>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _collectController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _collectAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _collectController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOut),
    );

    _collectAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _collectController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(RobotCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isJumping && !oldWidget.isJumping) {
      _bounceController.forward().then((_) => _bounceController.reverse());
    }

    if (widget.isCollecting && !oldWidget.isCollecting) {
      _collectController.forward().then((_) => _collectController.reverse());
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _collectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceController, _collectController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _collectAnimation.value,
            child: Transform.rotate(
              angle: widget.direction * math.pi / 2,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Robot face
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Eyes
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Smile
                          Container(
                            width: 20,
                            height: 10,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Direction indicator
                    Positioned(
                      top: 4,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 16,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Grid tile for the playground
class GameGridTile extends StatelessWidget {
  final bool isStart;
  final bool isEnd;
  final bool hasCollectable;
  final bool isObstacle;
  final bool hasRobot;
  final int direction;

  const GameGridTile({
    super.key,
    this.isStart = false,
    this.isEnd = false,
    this.hasCollectable = false,
    this.isObstacle = false,
    this.hasRobot = false,
    this.direction = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isObstacle
            ? Colors.grey.shade700
            : isStart
                ? Colors.green.shade100
                : isEnd
                    ? Colors.purple.shade100
                    : Colors.white,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Start marker
          if (isStart && !hasRobot)
            Center(
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.green.shade600,
                size: 30,
              ),
            ),

          // End marker
          if (isEnd)
            Center(
              child: Icon(
                Icons.flag,
                color: Colors.purple.shade600,
                size: 30,
              ),
            ),

          // Collectable star
          if (hasCollectable)
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Transform.rotate(
                      angle: value * math.pi * 2,
                      child: Icon(
                        Icons.star,
                        color: Colors.amber.shade400,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Robot
          if (hasRobot)
            Center(
              child: RobotCharacter(
                size: 50,
                direction: direction,
              ),
            ),
        ],
      ),
    );
  }
}
