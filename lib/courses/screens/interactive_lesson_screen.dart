import 'package:flutter/material.dart';
import '../../ui/ekran_olcusu.dart';
import '../../widgets/playful_background.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_progress_service.dart';
import 'widgets/step_widgets.dart';
import 'package:confetti/confetti.dart';
import '../../theme.dart';
import '../../ui/count_up.dart';
import '../../ui/motion.dart';
import '../../ui/press_button.dart';
import '../../widgets/cikis_penceresi.dart';
import '../../services/sound_service.dart';

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
      // Ders ekraninin zemini duz griydi. Artik kursun renginde, cok
      // yavas suzulen kodlama sembolleri var (blok, disli, ok, dugum,
      // parantez). Dikkat calmiyor — metin hala en belirgin sey — ama
      // ekran "bos bir form" gibi durmuyor. "Hareketi azalt" acikken
      // PlayfulBackground hicbir sey cizmiyor.
      body: PlayfulBackground(
        baseColor:
            isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FB),
        tint: widget.course.primaryColor,
        symbolCount: 14,
        child: SafeArea(
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
                      : 'Adım ${_currentStepIndex + 1} / ${widget.lesson.steps.length}',
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

    // Dolgu ekran boyuna gore: iPhone SE'de her kenardan 20 pt,
    // ustelik adimlarin kendi ic araliklariyla birlikte, icerigi
    // gereksiz yere ekranin disina itiyordu.
    final dolgu = EkranOlcusu.kisa(context) ? 12.0 : 20.0;
    return SingleChildScrollView(
      key: ValueKey(step.id),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(dolgu, dolgu, dolgu, dolgu + 8),
      child: _buildStepWidget(step, isDark),
    );
  }

  Widget _buildStepWidget(LessonStep step, bool isDark) {
    switch (step.type) {
      case StepType.intro:
        return IntroStepWidget(
          step: step as IntroStep,
          course: widget.course,
          isDark: isDark,
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
            xpEarned: score >= step.targetScore ? step.xpReward : step.xpReward ~/ 2,
          ),
        );

      case StepType.project:
        return ProjectStepWidget(
          step: step as ProjectStep,
          course: widget.course,
          isDark: isDark,
          // Proje adimi artik iki cikisli: "Yaptim" (XP var) ve
          // "Sonra yaparim" (ilerler, XP yok). Uygulama projeyi
          // goremiyor; gordugunu iddia etmiyoruz.
          onComplete: (yapti) =>
              _onStepCompleted(xpEarned: yapti ? step.xpReward : 0),
        );


      // Bu uc tip icerikte VARDI ama ekranda karsiligi yoktu: Python,
      // Arduino ve HTML derslerinde 24 adim "Step tipi henüz
      // desteklenmiyor" yazisina dusuyordu.
      case StepType.codeComplete:
        return CodeCompleteStepWidget(
          step: step as CodeCompleteStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) => _onStepCompleted(
            xpEarned: correct ? step.xpReward : 0,
          ),
        );

      case StepType.typeTheCode:
        return TypeCodeStepWidget(
          step: step as TypeCodeStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) => _onStepCompleted(
            xpEarned: correct ? step.xpReward : 0,
          ),
        );

      case StepType.spotTheError:
        return SpotErrorStepWidget(
          step: step as SpotErrorStep,
          course: widget.course,
          isDark: isDark,
          onComplete: (correct) => _onStepCompleted(
            xpEarned: correct ? step.xpReward : 0,
          ),
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
            lessonText(
              lessonLang(context),
              'Bu adım tipi henüz desteklenmiyor: ${step.type}',
              'This step type is not supported yet: ${step.type}',
            ),
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
              label: Text(lessonText(lessonLang(context), 'Önceki', 'Back')),
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
    // ANLATIM ADIMI ARTIK KENDILIGINDEN GECMIYOR.
    //
    // Metnin tamami bir anda ekranda duruyor ve DEVAM tusu hazir
    // bekliyordu; cocuk tek dokunusla geciyordu. Anlatim artik paragraf
    // paragraf aciliyor (bkz. ExplanationStepWidget) ve son paragraf
    // gorununce adim tamamlanmis sayiliyor. Tek paragrafli metinlerde
    // ve ekran okuyucu acikken bu ilk karede oluyor, yani kimse
    // beklemiyor.
    if (_currentStep.type == StepType.intro) return true;
    return _currentStepCompleted;
  }

  void _showExitConfirmation() async {
    // Dil build disinda okunuyor: `lessonLang` (context.watch) burada
    // provider assertion atar ve diyalog SESSIZCE acilmaz.
    // Bkz. nickname_button_test.dart — ayni hata "Baska bir tane oner"
    // dugmesini calismaz hale getirmisti.
    final lang = lessonLangRead(context);
    final cik = await CikisPenceresi.dersten(context, lang,
        renk: widget.course.primaryColor);
    if (cik && mounted) Navigator.pop(context);
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
  /// Tek bir denetleyici, birden cok gecikmeli parca.
  ///
  /// ONCEDEN tum pencere birlikte `elasticOut` ile zipliyordu: bilgiler ayni
  /// anda geldigi icin goz nereye bakacagini bilmiyor, kazanc (XP, rozet)
  /// kutlamanin icinde kayboluyordu. Simdi parcalar 80 ms arayla sirayla
  /// giriyor — once "tebrikler", sonra XP, sonra rozet — ve XP sayarak
  /// yukseliyor.
  late final AnimationController _controller = AnimationController(
    duration: Motion.extraLong2,
    vsync: this,
  );

  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    // Ders bitti: soru sesinin buyugu. Tek tek dogrularin ustune
    // binmesin diye yalnizca bu anda caliyor.
    SoundService.playOdul();
    // MediaQuery'yi initState icinde okumak dogru degil (inherited widget
    // henuz baglanmamis olabiliyor); ilk kareden sonra bakiyoruz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !Motion.reduced(context)) _confetti.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confetti.dispose();
    super.dispose();
  }

  /// [order]. parcanin 0..1 ilerlemesi. Her parca bir oncekinden 80 ms sonra
  /// basliyor.
  Animation<double> _step(int order) {
    const stagger = 0.14;
    final begin = (order * stagger).clamp(0.0, 0.7);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, (begin + 0.45).clamp(0.0, 1.0),
          curve: Motion.emphasizedDecelerate),
    );
  }

  Widget _enter(int order, Widget child) {
    final a = _step(order);
    return AnimatedBuilder(
      animation: a,
      builder: (context, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - a.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = lessonLang(context) == 'en';

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _enter(0, const Text('🎉', style: TextStyle(fontSize: 66))),
              const SizedBox(height: 14),
              _enter(
                1,
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      widget.course.primaryColor,
                      widget.course.secondaryColor
                    ],
                  ).createShader(bounds),
                  child: Text(
                    isEn ? 'CONGRATULATIONS!' : 'TEBRİKLER!',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _enter(
                2,
                Text(
                  isEn
                      ? '"${widget.lesson.titleFor('en')}" completed!'
                      : '"${widget.lesson.title}" tamamlandı!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _enter(
                3,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
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
                      const Icon(Icons.star_rounded,
                          color: Colors.white, size: 26),
                      const SizedBox(width: 8),
                      // Sayarak yukselen XP: kazanc bir olay haline geliyor.
                      CountUpText(
                        value: widget.totalXp,
                        prefix: '+',
                        suffix: ' XP',
                        fontSize: 24,
                        color: Colors.white,
                        duration: Motion.extraLong2,
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.badge != null) ...[
                const SizedBox(height: 20),
                _enter(
                  4,
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.course.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            widget.course.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isEn ? 'NEW BADGE!' : 'YENİ ROZET!',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getBadgeEmoji(widget.badge!),
                          style: const TextStyle(fontSize: 46),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getBadgeName(widget.badge!, isEn),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.w700,
                            color: widget.course.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            _enter(
              5,
              PressButton(
                label: isEn ? 'Awesome!' : 'Harika!',
                color: widget.course.primaryColor,
                height: 52,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        // Konfeti pencerenin ustunden dokuluyor; dokunuslari engellemesin
        // diye IgnorePointer icinde.
        IgnorePointer(
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0,
            numberOfParticles: 26,
            maxBlastForce: 22,
            minBlastForce: 9,
            gravity: 0.28,
            colors: [
              widget.course.primaryColor,
              widget.course.secondaryColor,
              Colors.amber,
              AppTheme.successGreen,
            ],
          ),
        ),
      ],
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

  /// Rozet adı — kutlama ekranında çocuğa gösteriliyor.
  ///
  /// Rozet adları burada SABİT yazılı olduğu için İngilizce ekranda da
  /// Türkçe çıkıyordu: ders İngilizce bitiyor, kutlama "Döngü Ustası"
  /// diyordu.
  String _getBadgeName(String badgeId, bool isEn) {
    const tr = {
      'scratch_starter': 'Scratch Başlangıç',
      'first_code': 'İlk Kod',
      'loop_master': 'Döngü Ustası',
      'condition_wizard': 'Koşul Büyücüsü',
      'coordinate_explorer': 'Koordinat Kaptanı',
      'game_developer': 'Oyun Geliştirici',
    };
    const en = {
      'scratch_starter': 'Scratch Starter',
      'first_code': 'First Code',
      'loop_master': 'Loop Master',
      'condition_wizard': 'Condition Wizard',
      'coordinate_explorer': 'Coordinate Captain',
      'game_developer': 'Game Developer',
    };
    return (isEn ? en[badgeId] : tr[badgeId]) ?? (isEn ? 'Badge' : 'Rozet');
  }
}
