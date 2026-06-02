import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/course_model.dart';
import '../../models/interactive_lesson_model.dart';

// ==========================================
// CATCH BLOCK GAME
// ==========================================

class CatchBlockGame extends StatefulWidget {
  final MiniGameStep step;
  final Course course;
  final bool isDark;
  final Function(int score) onComplete;

  const CatchBlockGame({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<CatchBlockGame> createState() => _CatchBlockGameState();
}

class _CatchBlockGameState extends State<CatchBlockGame> with TickerProviderStateMixin {
  int _score = 0;
  int _timeLeft = 30;
  bool _gameOver = false;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  final List<_FallingBlock> _blocks = [];
  _FallingBlock? _selectedBlock; // Track selected block
  final FocusNode _focusNode = FocusNode();

  final Color _motionColor = const Color(0xFF4C97FF); // Blue
  final Color _looksColor = const Color(0xFF9966FF);  // Purple

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    for (var block in _blocks) {
      block.controller.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    // Get duration from config or default to 30
    _timeLeft = widget.step.gameConfig['duration'] as int? ?? 30;

    // Start countdown timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });

    // Spawn blocks every 1.5 seconds
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _spawnBlock();
    });

    // Spawn first block immediately
    _spawnBlock();
  }

  void _spawnBlock() {
    if (_blocks.length < 5 && !_gameOver && mounted) {
      final random = Random();
      final isMotion = random.nextBool();

      final controller = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      );

      final block = _FallingBlock(
        type: isMotion ? 'motion' : 'looks',
        color: isMotion ? _motionColor : _looksColor,
        left: random.nextDouble() * 0.7 + 0.1, // 10% to 80% of screen width
        controller: controller,
      );

      controller.forward();
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          // Block reached bottom - missed
          // Clear selection if the missed block was selected          if (_selectedBlock == block) _selectedBlock = null;
          setState(() {
            _blocks.remove(block);
          });
          controller.dispose();
        }
      });

      if (mounted) {
        setState(() {
          _blocks.add(block);
        });
      }
    }
  }

  void _selectBlock(_FallingBlock block) {
    setState(() {
      _selectedBlock = block;
    });
    HapticFeedback.selectionClick();
  }

  void _categorizeSelectedBlock(String category) {
    // Always automatically select the bottommost block (closest to buttons)
    if (_blocks.isEmpty) return;
    
    // Find the block closest to the bottom (highest controller value)
    _FallingBlock? bottomBlock;
    double maxValue = -1;
    
    for (var block in _blocks) {
      if (block.controller.value > maxValue) {
        maxValue = block.controller.value;
        bottomBlock = block;
      }
    }
    
    if (bottomBlock == null) return;

    final block = bottomBlock;
    final isCorrect = (block.type == 'motion' && category == 'motion') ||
                     (block.type == 'looks' && category == 'looks');

    setState(() {
      if (isCorrect) {
        _score += 10;
        HapticFeedback.mediumImpact();
      } else {
        _score = (_score - 5).clamp(0, 999999);
        HapticFeedback.lightImpact();
      }

      _blocks.remove(block);
      block.controller.dispose();
      _selectedBlock = null; // Clear any manual selection
    });
  }


  void _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    
    // Get the bottommost block (closest to categorization buttons)
    if (_blocks.isEmpty) return;
    
    // Select the block closest to the bottom
    _FallingBlock? bottomBlock;
    double maxValue = -1;
    
    for (var block in _blocks) {
      if (block.controller.value > maxValue) {
        maxValue = block.controller.value;
        bottomBlock = block;
      }
    }
    
    if (bottomBlock == null) return;
    
    // Handle arrow keys and letter keys
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft || 
        event.logicalKey == LogicalKeyboardKey.keyA) {
      // Left arrow or A = Motion category
      setState(() {
        _selectedBlock = bottomBlock;
      });
      _categorizeSelectedBlock('motion');
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || 
               event.logicalKey == LogicalKeyboardKey.keyD) {
      // Right arrow or D = Looks category
      setState(() {
        _selectedBlock = bottomBlock;
      });
      _categorizeSelectedBlock('looks');
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      // Space = just select the block
      setState(() {
        _selectedBlock = bottomBlock;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() {
      _gameOver = true;
    });

    // Wait a bit then call onComplete
    Future.delayed(const Duration(seconds: 2), () {
      widget.onComplete(_score);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              'Oyun Bitti!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Puanın: $_score',
              style: TextStyle(
                fontSize: 24,
                color: widget.course.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _score >= widget.step.targetScore
                  ? 'Harika! Hedefi geçtin! 🎯'
                  : 'İyi deneme! Tekrar dene! 💪',
              style: TextStyle(
                fontSize: 16,
                color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyPress,
      child: Column(
      mainAxisSize: MainAxisSize.min,
        children: [
        // Header with score and timer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.course.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '$_score',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.timer, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '$_timeLeft',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 10 ? Colors.red : (widget.isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Game area
        SizedBox(
          height: 400,
          width: double.infinity,
          child: Container(
            height: 400, // Fixed height for game area
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: _blocks.map((block) {
                    return AnimatedBuilder(
                      animation: block.controller,
                      builder: (context, child) {
                        return Positioned(
                          left: constraints.maxWidth * block.left,
                          top: constraints.maxHeight * block.controller.value,
                          child: _BlockWidget(
                            block: block,
                            isSelected: false, // No manual selection
                            onTap: () {}, // Disabled - use buttons only
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 8),
        
        // Game instructions
        Text(
          'Alttaki butona dokun! Touch the button below!',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: widget.course.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Category buttons
        Row(
          children: [
            Expanded(
              child: _CategoryButton(
                label: 'HAREKET',
                emoji: '🏃',
                color: _motionColor,
                isDark: widget.isDark,
                onPressed: () => _categorizeSelectedBlock('motion'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CategoryButton(
                label: 'GÖRÜNÜM',
                emoji: '👀',
                color: _looksColor,
                isDark: widget.isDark,
                onPressed: () => _categorizeSelectedBlock('looks'),
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }
}

class _FallingBlock {
  final String type;
  final Color color;
  final double left;
  final AnimationController controller;

  _FallingBlock({
    required this.type,
    required this.color,
    required this.left,
    required this.controller,
  });
}

class _BlockWidget extends StatelessWidget {
  final _FallingBlock block;
  final bool isSelected;
  final VoidCallback onTap;

  const _BlockWidget({
    required this.block,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: block.color,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: block.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          block.type == 'motion' ? '🏃 GIT' : '👀 GÖR',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool isDark;
  final VoidCallback onPressed;

  const _CategoryButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
