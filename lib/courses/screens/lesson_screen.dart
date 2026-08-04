import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../data/lessons_data.dart';
import '../data/quizzes_data.dart';
import 'quiz_screen.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_progress_service.dart';

/// Lesson Screen - Interactive learning experience
class LessonScreen extends StatefulWidget {
  final Course course;
  final Lesson lesson;

  const LessonScreen({
    super.key,
    required this.course,
    required this.lesson,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isCompleted = false;
  bool _quizPassed = false;

  Quiz? get _quiz => QuizzesData.getQuizForLesson(widget.lesson.id);
  bool get _hasQuiz => _quiz != null;
  final Map<String, TextEditingController> _codeControllers = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeCodeControllers();
  }

  void _initializeCodeControllers() {
    for (final content in widget.lesson.contents) {
      if (content.type == ContentType.code && content.isInteractive) {
        _codeControllers[content.id] = TextEditingController(text: content.content);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _codeControllers.values) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _completeLesson() async {
    if (_isCompleted) return;

    setState(() => _isCompleted = true);

    // Add XP
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      await authProvider.addXP(widget.lesson.xpReward);
      // Jeton ödülü (Market'te harcanabilir)
      final userId = authProvider.currentUser?.uid;
      if (userId != null) {
        await UserProgressService().addJeton(userId, 8, source: 'lesson');
        await authProvider.refreshProgress();
      }
    }

    // Show completion dialog
    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Tebrikler!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Dersi tamamladin!',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '+${widget.lesson.xpReward} XP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to course
            },
            child: const Text('Kursa Don'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _goToNextLesson();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.course.primaryColor,
            ),
            child: const Text('Sonraki Ders'),
          ),
        ],
      ),
    );
  }

void _startQuiz() async {    if (_quiz == null) return;    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => QuizScreen(course: widget.course, lesson: widget.lesson, quiz: _quiz!)));    if (result == true && mounted) setState(() => _quizPassed = true);  }
  void _goToNextLesson() {
    final lessons = LessonsData.getLessonsForCourse(widget.course.id);
    final currentIndex = lessons.indexWhere((l) => l.id == widget.lesson.id);

    if (currentIndex < lessons.length - 1) {
      final nextLesson = lessons[currentIndex + 1];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LessonScreen(
            course: widget.course,
            lesson: nextLesson,
          ),
        ),
      );
    } else {
      // Last lesson - go back to course
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kursu tamamladin! 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: widget.course.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.lesson.title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade300, size: 20),
                const SizedBox(width: 4),
                Text(
                  '+${widget.lesson.xpReward}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: _isCompleted ? 1.0 : 0.5,
            backgroundColor: widget.course.primaryColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(widget.course.primaryColor),
            minHeight: 4,
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.lesson.contents.map((content) => _buildContent(content, isDark)),
                  if (_hasQuiz) _buildQuizCard(isDark),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Bottom action bar
          _buildBottomBar(isDark),
        ],
      ),
    );
  }

  Widget _buildContent(LessonContent content, bool isDark) {
    switch (content.type) {
      case ContentType.heading:
        return _buildHeading(content, isDark);
      case ContentType.text:
        return _buildText(content, isDark);
      case ContentType.code:
        return _buildCodeBlock(content, isDark);
      case ContentType.output:
        return _buildOutput(content, isDark);
      case ContentType.note:
        return _buildNote(content, isDark);
      case ContentType.task:
        return _buildTask(content, isDark);
      case ContentType.image:
        return _buildImage(content, isDark);
    }
  }

  Widget _buildHeading(LessonContent content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        content.content,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildText(LessonContent content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        content.content,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildCodeBlock(LessonContent content, bool isDark) {
    final isInteractive = content.isInteractive;
    final controller = _codeControllers[content.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.course.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.course.primaryColor.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Text(
                  content.language?.toUpperCase() ?? 'CODE',
                  style: TextStyle(
                    color: widget.course.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isInteractive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Duzenlenebilir',
                      style: TextStyle(color: Colors.green, fontSize: 10),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.grey, size: 18),
                  onPressed: () {
                    final text = controller?.text ?? content.content;
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kod kopyalandi!')),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Code
          Padding(
            padding: const EdgeInsets.all(12),
            child: isInteractive && controller != null
                ? TextField(
                    controller: controller,
                    maxLines: null,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Color(0xFFD4D4D4),
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : SelectableText(
                    content.content,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Color(0xFFD4D4D4),
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutput(LessonContent content, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2634) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text(
                'Cikti:',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content.content,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: isDark ? Colors.green.shade300 : Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote(LessonContent content, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2A1A) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTask(LessonContent content, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.course.primaryColor.withValues(alpha: 0.1),
            widget.course.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.course.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.course.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🎯', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Text(
                'Gorev',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.course.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content.content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          if (content.hint != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ipucu: ${content.hint}',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(LessonContent content, bool isDark) {
    // TODO: Implement image loading
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous lesson button
            OutlinedButton.icon(
              onPressed: () {
                final lessons = LessonsData.getLessonsForCourse(widget.course.id);
                final currentIndex = lessons.indexWhere((l) => l.id == widget.lesson.id);
                if (currentIndex > 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonScreen(
                        course: widget.course,
                        lesson: lessons[currentIndex - 1],
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Onceki'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.grey.shade700,
                side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              ),
            ),
            const Spacer(),
            // Complete button
            ElevatedButton.icon(
              onPressed: _isCompleted ? null : _completeLesson,
              icon: Icon(_isCompleted ? Icons.check : Icons.done_all, size: 20),
              label: Text(_isCompleted ? 'Tamamlandi' : 'Tamamla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCompleted ? Colors.green : widget.course.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _quizPassed
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.purple.shade400, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: (_quizPassed ? Colors.green : Colors.purple).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(_quizPassed ? Icons.check_circle : Icons.quiz, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_quizPassed ? 'Quiz Tamamlandi!' : 'Bilgini Test Et', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_quizPassed ? 'Tebrikler, quizi gectin!' : '${_quiz!.questions.length} soru ile ogrendiklerini pekistir', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
          ])),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, color: Colors.amber, size: 18), const SizedBox(width: 4), Text('+${_quiz!.xpReward} XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _quizPassed ? null : _startQuiz,
            icon: Icon(_quizPassed ? Icons.check : Icons.play_arrow),
            label: Text(_quizPassed ? 'Gecildi' : 'Quize Basla'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _quizPassed ? Colors.green : Colors.purple, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),
      ]),
    );
  }
}
