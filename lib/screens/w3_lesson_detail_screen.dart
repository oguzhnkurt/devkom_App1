/// W3Schools-style Lesson Detail Screen
/// The main learning screen - scrolls through content items
library;

import 'package:flutter/material.dart';
import '../models/w3_lesson_model.dart';
import '../widgets/w3_widgets.dart';
import 'w3_code_editor_screen.dart';
import 'w3_quiz_screen.dart';

class W3LessonDetailScreen extends StatefulWidget {
  final W3Course course;
  final W3Chapter chapter;
  final W3Lesson lesson;

  const W3LessonDetailScreen({
    super.key,
    required this.course,
    required this.chapter,
    required this.lesson,
  });

  @override
  State<W3LessonDetailScreen> createState() => _W3LessonDetailScreenState();
}

class _W3LessonDetailScreenState extends State<W3LessonDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentContentIndex = 0;
  int _currentXP = 150; // Mock XP

  double get _progress {
    if (widget.lesson.contents.isEmpty) return 0;
    return (_currentContentIndex + 1) / widget.lesson.contents.length;
  }

  bool get _isLastContent {
    return _currentContentIndex >= widget.lesson.contents.length - 1;
  }

  void _nextContent() {
    if (!_isLastContent) {
      setState(() {
        _currentContentIndex++;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _previousContent() {
    if (_currentContentIndex > 0) {
      setState(() {
        _currentContentIndex--;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startQuiz() {
    if (widget.lesson.quiz != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => W3QuizScreen(
            lesson: widget.lesson,
            quiz: widget.lesson.quiz!,
            onQuizComplete: (score, earnedXP) {
              setState(() {
                _currentXP += earnedXP;
              });
              Navigator.pop(context); // Return to lesson
              _showCompletionDialog(score, earnedXP);
            },
          ),
        ),
      );
    }
  }

  void _showCompletionDialog(int score, int earnedXP) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Ders Tamamlandı!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quiz Skoru: $score/100'),
            const SizedBox(height: 8),
            Text(
              '+$earnedXP XP kazandın!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: W3Colors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to lesson list
            },
            child: const Text('Ders Listesine Dön'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson.title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${_currentContentIndex + 1}/${widget.lesson.contents.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          // XP badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: W3Colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: W3Colors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_currentXP XP',
                  style: const TextStyle(
                    color: W3Colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          W3ProgressBar(
            progress: _progress,
            height: 4,
          ),

          // Content area
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: _buildContent(widget.lesson.contents[_currentContentIndex]),
            ),
          ),

          // Bottom navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: _isLastContent
                ? _buildQuizButton()
                : _buildNavigationButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(W3Content content) {
    switch (content.type) {
      case W3ContentType.text:
        return _buildTextContent(content);

      case W3ContentType.codeExample:
        return _buildCodeContent(content);

      case W3ContentType.tip:
        return W3TipBox(
          text: content.text ?? '',
          title: content.title,
        );

      case W3ContentType.warning:
        return W3WarningBox(
          text: content.text ?? '',
          title: content.title,
        );

      case W3ContentType.interactive:
        return _buildInteractiveContent(content);

      default:
        return const SizedBox();
    }
  }

  Widget _buildTextContent(W3Content content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.title != null) ...[
          Text(
            content.title!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          content.text ?? '',
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeContent(W3Content content) {
    return W3CodeBlock(
      code: content.code ?? '',
      language: content.language ?? 'python',
      output: content.output,
      showTryButton: content.editable ?? true,
      onTryIt: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => W3CodeEditorScreen(
              code: content.code ?? '',
              language: content.language ?? 'python',
              expectedOutput: content.output,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractiveContent(W3Content content) {
    final data = content.interactiveData;
    if (data == null) return const SizedBox();

    final type = data['type'] as String?;

    switch (type) {
      case 'code_editor':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (content.title != null) ...[
              Text(
                content.title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
            ],
            W3InteractiveCodeEditor(
              language: data['language'] as String? ?? 'python',
              starterCode: data['starterCode'] as String? ?? '',
              testCases: List<Map<String, dynamic>>.from(
                data['testCases'] as List? ?? [],
              ),
              successCriteria: data['successCriteria'] as Map<String, dynamic>?,
              challengeId: data['challengeId'] as String? ?? '',
              xpReward: data['xpReward'] as int? ?? 0,
              onComplete: (success, xp) {
                if (success) {
                  setState(() {
                    _currentXP += xp;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Harika! +$xp XP kazandın!'),
                      backgroundColor: W3Colors.successGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );

      case 'scratch_workspace':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (content.title != null) ...[
              Text(
                content.title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
            ],
            W3ScratchWorkspace(
              availableBlocks: List<Map<String, dynamic>>.from(
                data['availableBlocks'] as List? ?? [],
              ),
              expectedSequence: data['expectedSequence'] as List? ?? [],
              stage: data['stage'] is Map ? Map<String, dynamic>.from(data['stage'] as Map) : null,
              challengeId: data['challengeId'] as String? ?? '',
              xpReward: data['xpReward'] as int? ?? 0,
              onComplete: (success, xp) {
                if (success) {
                  setState(() {
                    _currentXP += xp;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Harika! +$xp XP kazandın!'),
                      backgroundColor: W3Colors.successGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );

      default:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(Icons.widgets, size: 48, color: Colors.blue.shade700),
              const SizedBox(height: 12),
              Text(
                'Bilinmeyen Widget Tipi: $type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Previous button
        Expanded(
          child: OutlinedButton(
            onPressed: _currentContentIndex > 0 ? _previousContent : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              '« Önceki',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Next button
        Expanded(
          child: ElevatedButton(
            onPressed: _nextContent,
            style: ElevatedButton.styleFrom(
              backgroundColor: W3Colors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Sonraki »',
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

  Widget _buildQuizButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_currentContentIndex > 0)
          TextButton(
            onPressed: _previousContent,
            child: const Text('« Önceki İçerik'),
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: widget.lesson.quiz != null ? _startQuiz : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: W3Colors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.lesson.quiz != null ? 'Quiz\'e Başla' : 'Quiz Yok',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
