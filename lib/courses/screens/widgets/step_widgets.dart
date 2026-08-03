import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/interactive_lesson_model.dart';
import '../../../providers/settings_provider.dart';
import 'catch_block_game.dart';
import 'coordinate_tap_game.dart';
import '../../../widgets/scratch_block_widget.dart';
import '../../../widgets/walking_cat_widget.dart';
import '../../../widgets/block_animation_player.dart';

/// Current app language code ('tr' | 'en') for lesson content.
/// Listens so that switching the language rebuilds lesson content in place.
/// Call this from build().
String lessonLang(BuildContext context) =>
    context.watch<SettingsProvider>().locale.languageCode;

/// Same value without subscribing - safe to call from helper methods that are
/// invoked during build (the enclosing build() already subscribes via
/// [lessonLang], so rebuilds still propagate).
String lessonLangRead(BuildContext context) =>
    Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

// ==========================================
// INTRO STEP WIDGET
// ==========================================

class IntroStepWidget extends StatefulWidget {
  final IntroStep step;
  final Course course;
  final VoidCallback onComplete;

  const IntroStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.onComplete,
  });

  @override
  State<IntroStepWidget> createState() => _IntroStepWidgetState();
}

class _IntroStepWidgetState extends State<IntroStepWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final highlights = widget.step.highlightsFor(lang);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mascot with bounce animation
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_bounceAnimation.value),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.course.primaryColor.withOpacity(0.2),
                      widget.course.secondaryColor.withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.step.mascotEmoji ?? '🤖',
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Speech bubble
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.course.primaryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                widget.step.mascotMessageFor(lang),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (highlights.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...highlights.map((highlight) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.course.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          highlight,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// EXPLANATION STEP WIDGET
// ==========================================

class ExplanationStepWidget extends StatelessWidget {
  final ExplanationStep step;
  final Course course;
  final bool isDark;
  final VoidCallback onComplete;

  const ExplanationStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final tipText = step.tipFor(lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          step.titleFor(lang),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),

        // Content
        Text(
          step.contentFor(lang),
          style: TextStyle(
            fontSize: 16,
            height: 1.7,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 24),

        // Visual elements
        if (step.visuals.isNotEmpty) ...[
          ...step.visuals.map((visual) => _buildVisual(visual)),
        ],

        // Tip box
        if (tipText != null) ...[
          const SizedBox(height: 24),
          _buildTipBox(tipText),
        ],
      ],
    );
  }

  Widget _buildVisual(VisualElement visual) {
    switch (visual.type) {
      case VisualType.scratchBlock:
        return _buildScratchBlock(visual);
      case VisualType.codeSnippet:
        return _buildCodeSnippet(visual);
      default:
        return const SizedBox();
    }
  }

  Widget _buildScratchBlock(VisualElement visual) {
    // Check if this is a green flag block
    final bool isGreenFlag = visual.content == 'tıklandığında';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: visual.color ?? course.primaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: (visual.color ?? course.primaryColor).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isGreenFlag
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.flag,
                        color: Color(0xFF0FBD8C),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        visual.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  )
                : Text(
                    visual.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
          if (visual.label != null) ...[
            const SizedBox(width: 16),
            Text(
              visual.label!,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeSnippet(VisualElement visual) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        visual.content,
        style: const TextStyle(
          fontFamily: 'monospace',
          color: Color(0xFFD4D4D4),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTipBox(String tipText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2A1A) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.tipEmoji ?? '💡', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tipText,
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
}

// ==========================================
// MULTIPLE CHOICE STEP WIDGET
// ==========================================

class MultipleChoiceStepWidget extends StatefulWidget {
  final MultipleChoiceStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const MultipleChoiceStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<MultipleChoiceStepWidget> createState() => _MultipleChoiceStepWidgetState();
}

class _MultipleChoiceStepWidgetState extends State<MultipleChoiceStepWidget> {
  int? _selectedIndex;
  bool _answered = false;
  bool get _isCorrect => _selectedIndex == widget.step.correctIndex;

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onComplete(_isCorrect);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final isEn = lang == 'en';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              const Text('🤔', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 16),
              Text(
                widget.step.questionFor(lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Code context if any
        if (widget.step.codeContext != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.step.codeContext!,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFFD4D4D4),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Options
        ...List.generate(widget.step.options.length, (index) {
          final option = widget.step.options[index];
          final isSelected = _selectedIndex == index;
          final isCorrectAnswer = widget.step.correctIndex == index;

          Color backgroundColor;
          Color borderColor;

          if (_answered) {
            if (isCorrectAnswer) {
              backgroundColor = Colors.green.withOpacity(0.15);
              borderColor = Colors.green;
            } else if (isSelected && !isCorrectAnswer) {
              backgroundColor = Colors.red.withOpacity(0.15);
              borderColor = Colors.red;
            } else {
              backgroundColor = widget.isDark ? const Color(0xFF1E1E2E) : Colors.white;
              borderColor = widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300;
            }
          } else {
            backgroundColor = isSelected
                ? widget.course.primaryColor.withOpacity(0.1)
                : (widget.isDark ? const Color(0xFF1E1E2E) : Colors.white);
            borderColor = isSelected
                ? widget.course.primaryColor
                : (widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300);
          }

          return GestureDetector(
            onTap: () => _selectAnswer(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  if (option.emoji != null) ...[
                    Text(option.emoji!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      option.textFor(lang),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontFamily: option.isCode ? 'monospace' : null,
                        color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  if (_answered && isCorrectAnswer)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (_answered && isSelected && !isCorrectAnswer)
                    const Icon(Icons.cancel, color: Colors.red),
                ],
              ),
            ),
          );
        }),

        // Explanation after answering
        if (_answered) ...[
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCorrect
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isCorrect ? '✅' : '💡',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCorrect
                            ? (isEn ? 'Correct!' : 'Dogru!')
                            : (isEn ? 'Wrong!' : 'Yanlis!'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isCorrect ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.step.explanationFor(lang),
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                    ],
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

// ==========================================
// DRAG & DROP STEP WIDGET
// ==========================================

class DragDropStepWidget extends StatefulWidget {
  final DragDropStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const DragDropStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<DragDropStepWidget> createState() => _DragDropStepWidgetState();
}

class _DragDropStepWidgetState extends State<DragDropStepWidget> {
  final Map<String, String?> _placements = {}; // itemId -> zoneId
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    for (var item in widget.step.items) {
      _placements[item.id] = null;
    }
  }

  void _checkCompletion() {
    // Check if all items are placed
    if (_placements.values.any((v) => v == null)) return;

    // Check if all placements are correct
    bool allCorrect = true;
    for (var entry in _placements.entries) {
      if (widget.step.correctMapping[entry.key] != entry.value) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      setState(() => _completed = true);
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction
        Text(
          widget.step.instructionFor(lang),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 24),

        // Drop zones
        Row(
          children: widget.step.dropZones.map((zone) {
            return Expanded(
              child: _buildDropZone(zone),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Draggable items
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.step.items
              .where((item) => _placements[item.id] == null)
              .map((item) => _buildDraggableItem(item))
              .toList(),
        ),

        // Success message
        if (_completed) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.step.successMessageFor(lang),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDropZone(DropZone zone) {
    final itemsInZone = widget.step.items
        .where((item) => _placements[item.id] == zone.id)
        .toList();

    return DragTarget<DraggableItem>(
      onAcceptWithDetails: (details) {
        setState(() {
          _placements[details.data.id] = zone.id;
        });
        HapticFeedback.lightImpact();
        _checkCompletion();
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(minHeight: 150),
          decoration: BoxDecoration(
            color: isHovering
                ? widget.course.primaryColor.withOpacity(0.1)
                : (widget.isDark ? const Color(0xFF1E1E2E) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering
                  ? widget.course.primaryColor
                  : (widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              width: 2,
              style: isHovering ? BorderStyle.solid : BorderStyle.none,
            ),
          ),
          child: Column(
            children: [
              Text(
                zone.labelFor(lessonLangRead(context)),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.course.primaryColor,
                ),
              ),
              if (zone.hintFor(lessonLangRead(context)) != null) ...[
                const SizedBox(height: 4),
                Text(
                  zone.hintFor(lessonLangRead(context))!,
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ...itemsInZone.map((item) => _buildPlacedItem(item)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(DraggableItem item) {
    return Draggable<DraggableItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: _buildItemContent(item, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildItemContent(item),
      ),
      child: _buildItemContent(item),
    );
  }

  Widget _buildItemContent(DraggableItem item, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: item.color ?? widget.course.primaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Text(
        item.contentFor(lessonLangRead(context)),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlacedItem(DraggableItem item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _placements[item.id] = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: item.color ?? widget.course.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                item.contentFor(lessonLangRead(context)),
                style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.close, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// BLOCK BUILDER STEP WIDGET
// ==========================================

class BlockBuilderStepWidget extends StatefulWidget {
  final BlockBuilderStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const BlockBuilderStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<BlockBuilderStepWidget> createState() => _BlockBuilderStepWidgetState();
}

class _BlockBuilderStepWidgetState extends State<BlockBuilderStepWidget> {
  final List<String> _placedBlocks = [];
  bool _completed = false;
  bool _isCorrect = false;
  bool _showAnimation = false;

  void _addBlock(ScratchBlock block) {
    setState(() {
      _placedBlocks.add(block.id);
    });
    HapticFeedback.lightImpact();
    _checkAnswer();
  }

  void _removeBlock(int index) {
    setState(() {
      _placedBlocks.removeAt(index);
      _completed = false;
    });
  }

  void _checkAnswer() {
    if (_placedBlocks.length != widget.step.correctSequence.length) {
      setState(() {
        _completed = false;
        _isCorrect = false;
      });
      return;
    }

    bool correct = true;
    for (int i = 0; i < _placedBlocks.length; i++) {
      if (_placedBlocks[i] != widget.step.correctSequence[i]) {
        correct = false;
        break;
      }
    }

    setState(() {
      _isCorrect = correct;
      if (correct) {
        _completed = true;
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final goalLabel = lang == 'en' ? 'Goal' : 'Hedef';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruction
        Text(
          widget.step.instructionFor(lang),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),

        // Goal
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$goalLabel: ${widget.step.goalFor(lang)}',
                  style: TextStyle(
                    color: widget.isDark ? Colors.blue.shade200 : Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Code area
        Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 150),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            border: _completed
                ? Border.all(color: Colors.green, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kod Alani:',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              if (_placedBlocks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Bloklari buraya surukle',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                ..._placedBlocks.asMap().entries.map((entry) {
                  final block = widget.step.availableBlocks
                      .firstWhere((b) => b.id == entry.value);
                  return _buildPlacedBlock(block, entry.key);
                }),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Available blocks
        Text(
          'Kullanilabilir Bloklar:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.step.availableBlocks.map((block) {
            return GestureDetector(
              onTap: () => _addBlock(block),
              child: _buildBlockWidget(block),
            );
          }).toList(),
        ),

        // Success indicator
        if (_completed) ...[
          const SizedBox(height: 24),

          // Kedi animasyonu göster
          if (_showAnimation)
            BlockAnimationPlayer(
              key: UniqueKey(), // Her seferinde yeni widget oluştur
              blockIds: _placedBlocks,
              size: 50,
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Text('✅', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mukemmel! Dogru siralamayi buldun!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!_showAnimation)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAnimation = true;
                      });
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('KODU ÇALIŞTIR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (_showAnimation) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onComplete(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.course.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'DEVAM',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBlockWidget(ScratchBlock block) {
    return ScratchBlockWidget(
      block: block,
      onTap: null, // Zaten tap handler dışarıda
    );
  }

  Widget _buildPlacedBlock(ScratchBlock block, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ScratchBlockWidget(
        block: block,
        isPlaced: true,
        showRemoveIcon: true,
        onTap: () => _removeBlock(index),
      ),
    );
  }
}

// ==========================================
// ORDERING STEP WIDGET
// ==========================================

class OrderingStepWidget extends StatefulWidget {
  final OrderingStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const OrderingStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<OrderingStepWidget> createState() => _OrderingStepWidgetState();
}

class _OrderingStepWidgetState extends State<OrderingStepWidget> {
  late List<OrderItem> _orderedItems;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _orderedItems = List.from(widget.step.items)..shuffle();
  }

  void _checkOrder() {
    final currentOrder = _orderedItems.map((e) => e.id).toList();
    if (currentOrder.join(',') == widget.step.correctOrder.join(',')) {
      setState(() => _completed = true);
      HapticFeedback.heavyImpact();
    } else {
      setState(() => _completed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.step.instructionFor(lang),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.step.contextFor(lang),
          style: TextStyle(
            color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),

        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _orderedItems.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) newIndex--;
              final item = _orderedItems.removeAt(oldIndex);
              _orderedItems.insert(newIndex, item);
            });
            _checkOrder();
          },
          itemBuilder: (context, index) {
            final item = _orderedItems[index];
            return ReorderableDragStartListener(
              key: ValueKey(item.id),
              index: index,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.drag_handle,
                      color: widget.isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.course.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: widget.course.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: item.content == 'tıklandığında'
                          ? Row(
                              children: [
                                const Icon(
                                  Icons.flag,
                                  color: Color(0xFF0FBD8C),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.contentFor(lang),
                                  style: TextStyle(
                                    fontFamily: item.isCode ? 'monospace' : null,
                                    color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              item.contentFor(lang),
                              style: TextStyle(
                                fontFamily: item.isCode ? 'monospace' : null,
                                color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        if (_completed) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('✅', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dogru sira! Harika!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onComplete(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.course.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'DEVAM',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ==========================================
// MATCHING STEP WIDGET
// ==========================================

class MatchingStepWidget extends StatefulWidget {
  final MatchingStep step;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  const MatchingStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<MatchingStepWidget> createState() => _MatchingStepWidgetState();
}

class _MatchingStepWidgetState extends State<MatchingStepWidget> {
  String? _selectedLeft;
  final Map<String, String> _matches = {}; // leftId -> rightId
  final Map<String, bool> _matchCorrectness = {}; // leftId -> isCorrect
  bool _completed = false;
  late List<MatchPair> _shuffledPairs;

  @override
  void initState() {
    super.initState();
    // Shuffle both left and right items
    _shuffledPairs = List.from(widget.step.pairs)..shuffle();
  }

  void _selectLeft(String id) {
    // If already matched, allow unmatch
    if (_matches.containsKey(id)) {
      setState(() {
        _matches.remove(id);
        _matchCorrectness.remove(id);
        _selectedLeft = null;
      });
      return;
    }

    setState(() => _selectedLeft = id);
  }

  void _selectRight(String rightId) {
    if (_selectedLeft == null) return;

    // Find the correct right answer for selected left
    final selectedPair = _shuffledPairs.firstWhere((p) => p.id == _selectedLeft);
    final isCorrect = selectedPair.id == rightId;

    setState(() {
      _matches[_selectedLeft!] = rightId;
      _matchCorrectness[_selectedLeft!] = isCorrect;
      _selectedLeft = null;
    });

    HapticFeedback.lightImpact();
    _checkCompletion();
  }

  void _checkCompletion() {
    if (_matches.length != widget.step.pairs.length) return;

    // Check if ALL matches are correct
    bool allCorrect = _matchCorrectness.values.every((correct) => correct);

    if (allCorrect) {
      setState(() => _completed = true);
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final rightItems = List<MatchPair>.from(_shuffledPairs)..shuffle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.step.instructionFor(lang),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 24),

        // Matching cards with improved design
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Conditions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.course.primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Koşullar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.course.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(_shuffledPairs.length, (index) {
                    final pair = _shuffledPairs[index];
                    final isSelected = _selectedLeft == pair.id;
                    final isMatched = _matches.containsKey(pair.id);
                    final isCorrect = _matchCorrectness[pair.id] ?? false;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        elevation: isSelected ? 4 : (isMatched ? 2 : 0),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _selectLeft(pair.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? (isCorrect
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1))
                                  : (isSelected
                                      ? widget.course.primaryColor.withOpacity(0.1)
                                      : (widget.isDark ? const Color(0xFF1E1E2E) : Colors.white)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMatched
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : (isSelected
                                        ? widget.course.primaryColor
                                        : Colors.grey.shade300),
                                width: isMatched || isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isMatched
                                        ? (isCorrect ? Colors.green : Colors.red)
                                        : (isSelected
                                            ? widget.course.primaryColor
                                            : Colors.grey.shade400),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pair.leftFor(lang),
                                    style: TextStyle(
                                      fontFamily: pair.isLeftCode ? 'monospace' : null,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                if (isMatched)
                                  Icon(
                                    isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: isCorrect ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Right column - Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.course.secondaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Sonuçlar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.course.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(rightItems.length, (index) {
                    final pair = rightItems[index];
                    final isMatched = _matches.values.contains(pair.id);
                    bool? isCorrect;
                    for (var entry in _matches.entries) {
                      if (entry.value == pair.id) {
                        isCorrect = _matchCorrectness[entry.key];
                        break;
                      }
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        elevation: isMatched ? 2 : 0,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: isMatched ? null : () => _selectRight(pair.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? (isCorrect == true
                                      ? Colors.green.withOpacity(0.1)
                                      : (isCorrect == false
                                          ? Colors.red.withOpacity(0.1)
                                          : (widget.isDark ? const Color(0xFF1E1E2E) : Colors.white)))
                                  : (widget.isDark ? const Color(0xFF1E1E2E) : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMatched
                                    ? (isCorrect == true
                                        ? Colors.green
                                        : (isCorrect == false ? Colors.red : Colors.grey.shade300))
                                    : (_selectedLeft != null && !isMatched
                                        ? widget.course.primaryColor.withOpacity(0.3)
                                        : Colors.grey.shade300),
                                width: isMatched ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isMatched
                                        ? (isCorrect == true
                                            ? Colors.green
                                            : (isCorrect == false
                                                ? Colors.red
                                                : Colors.grey.shade400))
                                        : Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pair.rightFor(lang),
                                    style: TextStyle(
                                      fontFamily: pair.isRightCode ? 'monospace' : null,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                if (isMatched && isCorrect != null)
                                  Icon(
                                    isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: isCorrect ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),

        if (_selectedLeft != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.course.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.course.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app, color: widget.course.primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Şimdi sağ taraftan uygun sonucu seç',
                    style: TextStyle(
                      color: widget.course.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_completed) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.2),
                  Colors.green.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harika! Tüm eşleştirmeler doğru!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tebrikler, devam edebilirsin!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ],
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


// ==========================================
// MINI GAME STEP WIDGET
// ==========================================

class MiniGameStepWidget extends StatefulWidget {
  final MiniGameStep step;
  final Course course;
  final bool isDark;
  final Function(int score) onComplete;

  const MiniGameStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<MiniGameStepWidget> createState() => _MiniGameStepWidgetState();
}

class _MiniGameStepWidgetState extends State<MiniGameStepWidget> {
  bool _gameStarted = false;

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    if (!_gameStarted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎮', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            widget.step.titleFor(lang),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.step.instructionFor(lang),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _gameStarted = true;
              });
            },
            icon: const Icon(Icons.play_arrow),
            label: Text(lang == 'en' ? 'Start Game' : 'Oyunu Baslat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.course.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      );
    }

    // Show the actual game based on gameType
    if (widget.step.gameType == MiniGameType.catchTheBlock) {
      return CatchBlockGame(
        step: widget.step,
        course: widget.course,
        isDark: widget.isDark,
        onComplete: (score) {
          widget.onComplete(score);
        },
      );
    }

    if (widget.step.gameType == MiniGameType.blockPuzzle) {
      // Check the config type for blockPuzzle games
      final configType = widget.step.gameConfig['type'] as String?;

      if (configType == 'loop_calculator') {
        return LoopCalculatorGame(
          step: widget.step,
          course: widget.course,
          isDark: widget.isDark,
          onComplete: (score) {
            widget.onComplete(score);
          },
        );
      }

      if (configType == 'coordinate_tap') {
        return CoordinateTapGame(
          step: widget.step,
          course: widget.course,
          isDark: widget.isDark,
          onComplete: (score) {
            widget.onComplete(score);
          },
        );
      }

      // Fall through to placeholder for other blockPuzzle types
    }

    // Placeholder for other game types (to be implemented)

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videogame_asset,
              size: 80,
              color: widget.course.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              widget.step.titleFor(lang),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.step.instructionFor(lang),
              style: TextStyle(
                fontSize: 16,
                color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lang == 'en'
                    ? 'This game is coming soon! You can continue for now.'
                    : 'Oyun yakinda eklenecek! Simdilik devam edebilirsin.',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onComplete(widget.step.targetScore);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.course.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Devam Et', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PROJECT STEP WIDGET
// ==========================================

class ProjectStepWidget extends StatelessWidget {
  final ProjectStep step;
  final Course course;
  final bool isDark;
  final VoidCallback onComplete;

  const ProjectStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final isEn = lang == 'en';
    final hints = step.hintsFor(lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [course.primaryColor, course.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'PROJECT' : 'PROJE',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      step.titleFor(lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Description
        Text(
          step.descriptionFor(lang),
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 24),

        // Requirements
        Text(
          isEn ? 'Requirements:' : 'Gereksinimler:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        ...step.requirementsFor(lang).map((req) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: course.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  req,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        )),

        // Hints
        if (hints.isNotEmpty) ...[
          const SizedBox(height: 24),
          ExpansionTile(
            title: Text(isEn ? 'Hints' : 'Ipuclari'),
            leading: const Icon(Icons.lightbulb_outline),
            children: hints.map((hint) => ListTile(
              leading: const Text('💡'),
              title: Text(hint),
            )).toList(),
          ),
        ],

        const SizedBox(height: 32),

        // Complete button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check),
            label: Text(isEn ? 'I Finished the Project!' : 'Projeyi Tamamladim!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: course.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// ANIMATION STEP WIDGET
// ==========================================

class AnimationStepWidget extends StatelessWidget {
  final AnimationStep step;
  final Course course;
  final bool isDark;
  final VoidCallback onComplete;

  const AnimationStepWidget({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          step.titleFor(lang),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),

        // Description
        Text(
          step.descriptionFor(lang),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 24),

        // Animation based on type
        if (step.animationType == AnimationType.comparison)
          _buildComparisonAnimation(),

        const SizedBox(height: 32),

        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: course.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(lang == 'en' ? 'Continue' : 'Devam', style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonAnimation() {
    final beforeItems = step.animationData['before'] as List<dynamic>? ?? [];
    final afterItems = step.animationData['after'] as List<dynamic>? ?? [];

    return Row(
      children: [
        // Before (Without loop)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.close,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dongusuz',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...beforeItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C97FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // After (With loop)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: course.primaryColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: course.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dongulu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...afterItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFAB19),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// ==========================================
// Loop Calculator Game - Mini Game for Loop Lesson
// ==========================================

class LoopCalculatorGame extends StatefulWidget {
  final MiniGameStep step;
  final Course course;
  final bool isDark;
  final Function(int score) onComplete;

  const LoopCalculatorGame({
    Key? key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<LoopCalculatorGame> createState() => _LoopCalculatorGameState();
}

class _LoopCalculatorGameState extends State<LoopCalculatorGame> {
  int currentLevel = 0;
  int score = 0;
  int? selectedAnswer;
  bool? isCorrect;

  final List<Map<String, int>> levels = [
    {'stepSize': 10, 'target': 30},
    {'stepSize': 5, 'target': 25},
    {'stepSize': 15, 'target': 45},
    {'stepSize': 8, 'target': 40},
    {'stepSize': 12, 'target': 60},
  ];

  @override
  void initState() {
    super.initState();
  }

  int _getCorrectAnswer() {
    final level = levels[currentLevel];
    return level['target']! ~/ level['stepSize']!;
  }

  List<int> _generateAnswers() {
    final correct = _getCorrectAnswer();
    final answers = <int>{correct};

    final random = Random();
    while (answers.length < 4) {
      final offset = random.nextInt(5) - 2;
      final candidate = correct + offset;
      if (candidate > 0 && candidate != correct) {
        answers.add(candidate);
      }
    }

    final list = answers.toList()..shuffle();
    return list;
  }

  void _selectAnswer(int answer) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = answer;
      isCorrect = answer == _getCorrectAnswer();
      if (isCorrect!) {
        score += 20;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentLevel < levels.length - 1) {
        setState(() {
          currentLevel++;
          selectedAnswer = null;
          isCorrect = null;
        });
      } else {
        widget.onComplete(score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final level = levels[currentLevel];
    final answers = _generateAnswers();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Score header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.course.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seviye ${currentLevel + 1}/${levels.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '$score puan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Question
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.course.primaryColor,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '🐱 Kediyi yürütmek için:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C97FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '"${level['stepSize']} adım git" bloğunu',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Toplam ${level['target']} adım gitmek için',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'kaç kere tekrarlamalıyız?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.course.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Answer options (2x2 grid)
          SizedBox(
            height: 400,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: answers.map((answer) {
                final isSelected = selectedAnswer == answer;
                final isThisCorrect = answer == _getCorrectAnswer();

                Color? backgroundColor;
                if (isSelected) {
                  backgroundColor = isCorrect! ? Colors.green : Colors.red;
                } else if (selectedAnswer != null && isThisCorrect) {
                  backgroundColor = Colors.green;
                }

                return InkWell(
                  onTap: () => _selectAnswer(answer),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor ?? const Color(0xFFFFAB19),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$answer',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'kere',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
