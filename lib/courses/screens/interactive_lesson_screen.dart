import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_progress_service.dart';
import 'widgets/step_widgets.dart';

/// Modern, Interactive Lesson Screen
/// FreeCodeCamp-inspired step-by-step learning experience
class InteractiveLessonScreen extends StatefulWidget {
  final Course course;
  final InteractiveLesson lesson;

  const InteractiveLessonScreen({
    super.key,
    required this.course,
    required this.lesson,
  });

  @override
  State<InteractiveLessonScreen> createState() => _InteractiveLessonScreenState();
}

class _InteractiveLessonScreenState extends State<InteractiveLessonScreen>
    with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  int _earnedXp = 0;
  bool _currentStepCompleted = false;
  final Map<String, bool> _completedSteps = {};

  late AnimationController _progressController;
  late AnimationController _celebrationController;

  LessonStep get _currentStep => widget.lesson.steps[_currentStepIndex];
  bool get _isLastStep => _currentStepIndex == widget.lesson.steps.length - 1;
  bool get _isFirstStep => _currentStepIndex == 0;
  double get _progress => (_currentStepIndex + 1) / widget.lesson.steps.length;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressController.value = _progress;
  }

  @override
  void dispose() {
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _onStepCompleted({int xpEarned = 0}) {
    setState(() {
      _currentStepCompleted = true;
      _completedSteps[_currentStep.id] = true;
      _earnedXp += xpEarned;
    });
    HapticFeedback.mediumImpact();
  }

  void _nextStep() {
    if (_isLastStep) {
      _completeLesson();
      return;
    }

    setState(() {
      _currentStepIndex++;
      _currentStepCompleted = _completedSteps[_currentStep.id] ?? false;
    });

    _progressController.animateTo(_progress);
    HapticFeedback.lightImpact();
  }

  void _previousStep() {
    if (_isFirstStep) return;

    setState(() {
      _currentStepIndex--;
      _currentStepCompleted = _completedSteps[_currentStep.id] ?? false;
    });

    _progressController.animateTo(_progress);
  }

  Future<void> _completeLesson() async {
    // Add XP
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final totalXp = _earnedXp + widget.lesson.xpReward;

    if (authProvider.isAuthenticated) {
      await authProvider.addXP(totalXp);
      // Jeton ödülü (Market'te harcanabilir)
      final userId = authProvider.currentUser?.uid;
      if (userId != null) {
        await UserProgressService().addJeton(userId, 8, source: 'interactive_lesson');
        await authProvider.refreshProgress();
      }
    }

    // Show completion dialog
    if (mounted) {
      _showCompletionDialog(totalXp);
    }
  }

  void _showCompletionDialog(int totalXp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LessonCompleteDialog(
        course: widget.course,
        lesson: widget.lesson,
        totalXp: totalXp,
        badge: widget.lesson.badge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with progress
            _buildTopBar(isDark),

            // Progress indicator
            _buildProgressBar(),

            // Step content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(isDark),
              ),
            ),

            // Bottom navigation
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Close button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                size: 20,
              ),
            ),
            onPressed: () => _showExitConfirmation(),
          ),

          const SizedBox(width: 12),

          // Lesson title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lesson.titleFor(lessonLang(context)),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  lessonLang(context) == 'en'
                      ? 'Step ${_currentStepIndex + 1} / ${widget.lesson.steps.length}'
                      : 'Adim ${_currentStepIndex + 1} / ${widget.lesson.steps.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // XP earned
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '+$_earnedXp',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 6,
      decoration: BoxDecoration(
        color: widget.course.primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressController.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.course.primaryColor, widget.course.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: widget.course.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(bool isDark) {
    final step = _currentStep;

    return SingleChildScrollView(
      key: ValueKey(step.id),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: _buildStepWidget(step, isDark),
    );
  }

  Widget _buildStepWidget(LessonStep step, bool isDark) {
    switch (step.type) {
      case StepType.intro:
        return IntroStepWidget(
          step: step as IntroStep,
          course: widget.course,
          onComplete: () => _onStepCompleted(),
        );

      case StepType.explanation:
        return ExplanationStepWidget(
          step: step as ExplanationStep,
          course: widget.course,
          isDark: isDark,
          onComplete: () => _onStepCompleted(xpEarned: step.xpReward),
        );

      case StepType.multipleChoice:
        return MultipleChoiceStepWidget(
          step: step as MultipleChoiceStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) => _onStepCompleted(
            xpEarned: correct ? step.xpReward : 0,
          ),
        );

      case StepType.dragAndDrop:
        return DragDropStepWidget(
          step: step as DragDropStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) => _onStepCompleted(
            xpEarned: correct ? step.xpReward : 0,
          ),
        );

      case StepType.blockBuilder:
        return BlockBuilderStepWidget(
          step: step as BlockBuilderStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) => _onStepCompleted(
            xpEarned: correct ? step.xpReward : 0,
          ),
        );

      case StepType.ordering:
        return OrderingStepWidget(
          step: step as OrderingStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) => _onStepCompleted(
            xpEarned: correct ? step.xpReward : 0,
          ),
        );

      case StepType.matching:
        return MatchingStepWidget(
          step: step as MatchingStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) => _onStepCompleted(
            xpEarned: correct ? step.xpReward : 0,
          ),
        );

      case StepType.miniGame:
        return MiniGameStepWidget(
          step: step as MiniGameStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (score) => _onStepCompleted(
            xpEarned: score >= (step as MiniGameStep).targetScore ? step.xpReward : step.xpReward ~/ 2,
          ),
        );

      case StepType.project:
        return ProjectStepWidget(
          step: step as ProjectStep,
          course: widget.course,
          isDark: isDark,
          onComplete: () => _onStepCompleted(xpEarned: step.xpReward),
        );


      case StepType.animation:
        return AnimationStepWidget(
          step: step as AnimationStep,
          course: widget.course,
          isDark: isDark,
          onComplete: () => _onStepCompleted(xpEarned: step.xpReward),
        );
default:
        return Center(
          child: Text(
            'Step tipi henuz desteklenmiyor: ${step.type}',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
        );
    }
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
      child: Row(
        children: [
          // Previous button
          if (!_isFirstStep)
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Onceki'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            )
          else
            const SizedBox(width: 100),

          const Spacer(),

          // Next/Complete button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: _canProceed() ? _nextStep : null,
              icon: Icon(
                _isLastStep ? Icons.check_circle : Icons.arrow_forward,
                size: 20,
              ),
              label: Text(_isLastStep ? 'Tamamla' : 'Devam'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canProceed()
                    ? widget.course.primaryColor
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _canProceed() ? 4 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    // Intro and explanation steps auto-complete
    if (_currentStep.type == StepType.intro ||
        _currentStep.type == StepType.explanation) {
      return true;
    }
    return _currentStepCompleted;
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Dersten cikiliyor'),
        content: const Text('Ilerleme kaybedilecek. Emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Devam Et'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: const Text('Cik'),
          ),
        ],
      ),
    );
  }
}

/// Lesson completion dialog
class _LessonCompleteDialog extends StatefulWidget {
  final Course course;
  final InteractiveLesson lesson;
  final int totalXp;
  final String? badge;

  const _LessonCompleteDialog({
    required this.course,
    required this.lesson,
    required this.totalXp,
    this.badge,
  });

  @override
  State<_LessonCompleteDialog> createState() => _LessonCompleteDialogState();
}

class _LessonCompleteDialogState extends State<_LessonCompleteDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration emoji
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),

              // Title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [widget.course.primaryColor, widget.course.secondaryColor],
                ).createShader(bounds),
                child: Text(
                  lessonLang(context) == 'en' ? 'CONGRATULATIONS!' : 'TEBRIKLER!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                lessonLang(context) == 'en'
                    ? '"${widget.lesson.titleFor('en')}" completed!'
                    : '"${widget.lesson.title}" tamamlandi!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // XP earned
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.orange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.totalXp} XP',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge if earned
              if (widget.badge != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.course.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.course.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'YENI ROZET!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getBadgeEmoji(widget.badge!),
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getBadgeName(widget.badge!),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.course.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.course.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Harika!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBadgeEmoji(String badgeId) {
    final badges = {
      'scratch_starter': '🐱',
      'first_code': '💻',
      'loop_master': '🔄',
      'condition_wizard': '🧙',
      'coordinate_explorer': '🧭',
      'game_developer': '🎮',
    };
    return badges[badgeId] ?? '🏆';
  }

  String _getBadgeName(String badgeId) {
    final names = {
      'scratch_starter': 'Scratch Baslangic',
      'first_code': 'Ilk Kod',
      'loop_master': 'Dongu Ustasi',
      'condition_wizard': 'Kosul Buyucusu',
      'coordinate_explorer': 'Koordinat Kaptani',
      'game_developer': 'Oyun Gelistirici',
    };
    return names[badgeId] ?? 'Rozet';
  }
}
