import 'package:flutter/material.dart';
import 'dart:async';
import 'walking_cat_widget.dart';

/// Scratch bloklarının eylemlerini sırayla simüle eder
class BlockAnimationPlayer extends StatefulWidget {
  final List<String> blockIds;
  final double size;
  final VoidCallback? onComplete;

  const BlockAnimationPlayer({
    super.key,
    required this.blockIds,
    this.size = 60,
    this.onComplete,
  });

  @override
  State<BlockAnimationPlayer> createState() => _BlockAnimationPlayerState();
}

class _BlockAnimationPlayerState extends State<BlockAnimationPlayer> {
  int _currentBlockIndex = 0;
  String? _speechBubbleText;
  int _walkSteps = 0;
  bool _isWalking = false;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    print('🎬 Starting animation with blocks: ${widget.blockIds}');
    _executeNextBlock();
  }

  void _executeNextBlock() {
    if (_currentBlockIndex >= widget.blockIds.length) {
      print('✅ Animation complete!');
      setState(() {
        _animationComplete = true;
      });
      widget.onComplete?.call();
      return;
    }

    final blockId = widget.blockIds[_currentBlockIndex];
    print('🎬 Executing block ${_currentBlockIndex + 1}/${widget.blockIds.length}: $blockId');

    // Bloğun eylemini belirle ve simüle et
    if (blockId.startsWith('say_')) {
      print('💬 Say block detected: $blockId');
      _executeSayBlock(blockId);
    } else if (blockId.startsWith('move_')) {
      print('🚶 Move block detected: $blockId');
      _executeMoveBlock(blockId);
    } else if (blockId.startsWith('repeat_')) {
      print('🔁 Repeat block detected: $blockId');
      _executeRepeatBlock(blockId);
    } else {
      print('⏭️ Skipping non-action block: $blockId');
      // Diğer bloklar (green_flag, vb) - direk geç
      _currentBlockIndex++;
      _executeNextBlock();
    }
  }

  void _executeSayBlock(String blockId) {
    // Konuşma blokları (say_hello, say_meow, vb)
    String message = 'Merhaba!';

    if (blockId == 'say_hello') {
      message = 'Merhaba!';
    } else if (blockId == 'say_meow') {
      message = 'Miyav!';
    } else if (blockId == 'say_hi') {
      message = 'Selam!';
    } else if (blockId == 'say_bye') {
      message = 'Güle güle!';
    } else {
      // Generic say block
      message = blockId.replaceAll('say_', '').replaceAll('_', ' ');
    }

    print('💬 Showing speech bubble: "$message"');

    setState(() {
      _speechBubbleText = message;
    });

    // 1.5 saniye sonra konuşma balonunu kaldır ve sıradaki bloğa geç
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        print('💬 Hiding speech bubble');
        setState(() {
          _speechBubbleText = null;
          _currentBlockIndex++;
        });
        _executeNextBlock();
      }
    });
  }

  void _executeMoveBlock(String blockId) {
    // Yürüme blokları (move_10, move_5, vb)
    int steps = 2; // Default

    if (blockId == 'move_10') {
      steps = 2;
    } else if (blockId == 'move_5') {
      steps = 1;
    } else if (blockId == 'move_15') {
      steps = 3;
    } else if (blockId == 'move_20') {
      steps = 4;
    } else {
      // Parse sayıyı
      final match = RegExp(r'move_(\d+)').firstMatch(blockId);
      if (match != null) {
        final distance = int.tryParse(match.group(1) ?? '10') ?? 10;
        steps = (distance / 5).ceil();
      }
    }

    print('🚶 Walking $steps steps');

    setState(() {
      _walkSteps = steps;
      _isWalking = true;
    });

    // Yürüme animasyonu bitince sıradaki bloğa geç
    final duration = Duration(milliseconds: steps * 600);
    Future.delayed(duration, () {
      if (mounted) {
        print('🚶 Finished walking');
        setState(() {
          _isWalking = false;
          _currentBlockIndex++;
        });
        _executeNextBlock();
      }
    });
  }

  void _executeRepeatBlock(String blockId) {
    // Döngü blokları (repeat_4, repeat_10, vb)
    // Parse tekrar sayısını
    final match = RegExp(r'repeat_(\d+)').firstMatch(blockId);
    if (match == null) {
      print('⚠️ Invalid repeat block: $blockId');
      _currentBlockIndex++;
      _executeNextBlock();
      return;
    }

    final repeatCount = int.tryParse(match.group(1) ?? '1') ?? 1;
    print('🔁 Repeat $repeatCount times');

    // Sonraki blok döngü içindeki blok
    if (_currentBlockIndex + 1 >= widget.blockIds.length) {
      print('⚠️ No block inside repeat loop');
      _currentBlockIndex++;
      _executeNextBlock();
      return;
    }

    final nestedBlockId = widget.blockIds[_currentBlockIndex + 1];
    print('🔁 Nested block: $nestedBlockId');

    // Döngüyü çalıştır
    _executeLoop(nestedBlockId, repeatCount, 0);
  }

  void _executeLoop(String blockId, int totalCount, int currentIteration) {
    if (currentIteration >= totalCount) {
      print('🔁 Loop complete!');
      // Döngü bitti, hem repeat bloğunu hem de içindeki bloğu atla
      setState(() {
        _currentBlockIndex += 2;
      });
      _executeNextBlock();
      return;
    }

    print('🔁 Loop iteration ${currentIteration + 1}/$totalCount');

    // İç bloğu çalıştır
    if (blockId.startsWith('say_')) {
      _executeSayBlockInLoop(blockId, totalCount, currentIteration);
    } else if (blockId.startsWith('move_')) {
      _executeMoveBlockInLoop(blockId, totalCount, currentIteration);
    } else {
      // Desteklenmeyen blok, bir sonraki iterasyona geç
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _executeLoop(blockId, totalCount, currentIteration + 1);
        }
      });
    }
  }

  void _executeSayBlockInLoop(String blockId, int totalCount, int currentIteration) {
    // Konuşma bloğunu çalıştır
    String message = 'Merhaba!';

    if (blockId == 'say_hello') {
      message = 'Merhaba!';
    } else if (blockId == 'say_meow') {
      message = 'Miyav!';
    } else if (blockId == 'say_hi') {
      message = 'Selam!';
    } else if (blockId == 'say_bye') {
      message = 'Güle güle!';
    } else {
      message = blockId.replaceAll('say_', '').replaceAll('_', ' ');
    }

    print('💬 Showing speech bubble: "$message" (iteration ${currentIteration + 1}/$totalCount)');

    setState(() {
      _speechBubbleText = message;
    });

    // 1.5 saniye sonra konuşma balonunu kaldır ve bir sonraki iterasyona geç
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        print('💬 Hiding speech bubble');
        setState(() {
          _speechBubbleText = null;
        });
        // Bir sonraki iterasyona geç
        _executeLoop(blockId, totalCount, currentIteration + 1);
      }
    });
  }

  void _executeMoveBlockInLoop(String blockId, int totalCount, int currentIteration) {
    int steps = 2;

    if (blockId == 'move_10') {
      steps = 2;
    } else if (blockId == 'move_5') {
      steps = 1;
    } else if (blockId == 'move_15') {
      steps = 3;
    } else if (blockId == 'move_20') {
      steps = 4;
    } else {
      final match = RegExp(r'move_(\d+)').firstMatch(blockId);
      if (match != null) {
        final distance = int.tryParse(match.group(1) ?? '10') ?? 10;
        steps = (distance / 5).ceil();
      }
    }

    print('🚶 Walking $steps steps (iteration ${currentIteration + 1}/$totalCount)');

    setState(() {
      _walkSteps = steps;
      _isWalking = true;
    });

    final duration = Duration(milliseconds: steps * 600);
    Future.delayed(duration, () {
      if (mounted) {
        print('🚶 Finished walking');
        setState(() {
          _isWalking = false;
        });
        // Bir sonraki iterasyona geç
        _executeLoop(blockId, totalCount, currentIteration + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            '🎬 Kodun Çalışıyor!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // Konuşma balonu (kedi dışında, üstte) - AnimatedOpacity ile
          AnimatedOpacity(
            opacity: _speechBubbleText != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _speechBubbleText != null
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '💬',
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _speechBubbleText!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(height: 56), // Boş alan koru
          ),
          const SizedBox(height: 12),

          // Kedi animasyon alanı
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                // Başlangıç çizgisi
                Positioned(
                  left: 0,
                  bottom: 10,
                  child: Container(
                    width: 4,
                    height: 80,
                    color: Colors.green,
                  ),
                ),
                // Kedi
                Align(
                  alignment: Alignment.bottomLeft,
                  child: _isWalking
                      ? SimpleWalkingCat(
                          key: ValueKey(_currentBlockIndex),
                          steps: _walkSteps,
                          size: widget.size,
                          stepDuration: const Duration(milliseconds: 600),
                        )
                      : Text(
                          '🐱',
                          style: TextStyle(fontSize: widget.size),
                        ),
                ),
              ],
            ),
          ),

          if (_animationComplete) ...[
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text(
                  'Animasyon tamamlandı!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
