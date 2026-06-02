import 'package:flutter/material.dart';
import 'dart:math';

/// Drag and Drop Matching Question Widget
class DragDropMatchingQuestion extends StatefulWidget {
  final Map<String, String> pairs;
  final Function(bool) onComplete;

  const DragDropMatchingQuestion({
    Key? key,
    required this.pairs,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<DragDropMatchingQuestion> createState() => _DragDropMatchingQuestionState();
}

class _DragDropMatchingQuestionState extends State<DragDropMatchingQuestion>
    with SingleTickerProviderStateMixin {
  late Map<String, String?> _userMatches;
  late List<String> _shuffledValues;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _userMatches = {for (var key in widget.pairs.keys) key: null};
    _shuffledValues = widget.pairs.values.toList()..shuffle();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    bool isCorrect = true;
    for (var entry in widget.pairs.entries) {
      if (_userMatches[entry.key] != entry.value) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onComplete(true);
      });
    } else {
      // Shake animation for wrong answer
      _animationController.repeat(reverse: true);
      Future.delayed(const Duration(milliseconds: 600), () {
        _animationController.stop();
        _animationController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Left side - Questions
        ...widget.pairs.keys.map((key) => _buildDropTarget(key)),
        const SizedBox(height: 32),

        // Right side - Draggable answers
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _shuffledValues
              .where((value) => !_userMatches.values.contains(value))
              .map((value) => _buildDraggableAnswer(value))
              .toList(),
        ),

        const SizedBox(height: 24),

        // Check button
        if (_userMatches.values.every((v) => v != null))
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_animationController.value * 0.1),
                child: child,
              );
            },
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kontrol Et',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropTarget(String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.arrow_forward, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: DragTarget<String>(
              onAcceptWithDetails: (details) {
                setState(() {
                  // Remove from other matches
                  _userMatches.forEach((k, v) {
                    if (v == details.data) {
                      _userMatches[k] = null;
                    }
                  });
                  _userMatches[key] = details.data;
                });
              },
              builder: (context, candidateData, rejectedData) {
                final hasMatch = _userMatches[key] != null;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasMatch ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? Colors.blue
                          : hasMatch
                              ? Colors.green
                              : Colors.grey.shade300,
                      width: candidateData.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  child: hasMatch
                      ? Row(
                          children: [
                            Expanded(
                              child: Text(
                                _userMatches[key]!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _userMatches[key] = null;
                                });
                              },
                              child: const Icon(Icons.close, size: 20),
                            ),
                          ],
                        )
                      : const Text(
                          'Surukle birak',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableAnswer(String value) {
    return Draggable<String>(
      data: value,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildAnswerChip(value),
      ),
      child: _buildAnswerChip(value),
    );
  }

  Widget _buildAnswerChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Live Code Editor Widget with Syntax Highlighting Simulation
class LiveCodeEditor extends StatefulWidget {
  final String initialCode;
  final String expectedOutput;
  final Function(bool) onValidate;

  const LiveCodeEditor({
    Key? key,
    required this.initialCode,
    required this.expectedOutput,
    required this.onValidate,
  }) : super(key: key);

  @override
  State<LiveCodeEditor> createState() => _LiveCodeEditorState();
}

class _LiveCodeEditorState extends State<LiveCodeEditor>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _runAnimationController;
  bool _isRunning = false;
  String _output = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
    _runAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _runAnimationController.dispose();
    super.dispose();
  }

  void _runCode() async {
    setState(() {
      _isRunning = true;
      _output = '';
    });

    _runAnimationController.forward();

    // Simulate code execution
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _output = widget.expectedOutput;
      _isRunning = false;
    });

    _runAnimationController.reset();

    // Check if code is correct
    final isCorrect = _controller.text.trim() == widget.initialCode.trim();
    widget.onValidate(isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Code editor
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editor header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'main.py',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Code input
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  maxLines: 10,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFF9CDCFE),
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Kodunuzu yazin...',
                    hintStyle: TextStyle(
                      color: Colors.white30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Run button
        AnimatedBuilder(
          animation: _runAnimationController,
          builder: (context, child) {
            return ElevatedButton.icon(
              onPressed: _isRunning ? null : _runCode,
              icon: _isRunning
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        value: _runAnimationController.value,
                      ),
                    )
                  : const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                _isRunning ? 'Calistiriliyor...' : 'Calistir',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),

        // Output
        if (_output.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade700),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.terminal, color: Colors.green.shade400, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Cikti:',
                      style: TextStyle(
                        color: Colors.green.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _output,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Progress XP Widget with Animation
class XPProgressWidget extends StatefulWidget {
  final int currentXP;
  final int requiredXP;
  final int level;

  const XPProgressWidget({
    Key? key,
    required this.currentXP,
    required this.requiredXP,
    required this.level,
  }) : super(key: key);

  @override
  State<XPProgressWidget> createState() => _XPProgressWidgetState();
}

class _XPProgressWidgetState extends State<XPProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.currentXP / widget.requiredXP,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.purple.shade500],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Level',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${widget.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${widget.currentXP} / ${widget.requiredXP} XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _animation.value,
                      minHeight: 12,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_animation.value * 100).toInt()}% tamamlandi',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
