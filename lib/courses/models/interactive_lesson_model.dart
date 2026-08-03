import 'package:flutter/material.dart';

/// Modern, FreeCodeCamp-inspired interactive lesson model
/// Focused on engagement, not Wikipedia-style reading
///
/// BILINGUAL SUPPORT (TR/EN)
/// -------------------------
/// Every user-facing text field has an optional `...En` counterpart.
/// Content authored before bilingual support simply leaves them null and
/// keeps working exactly as before: the `...For(lang)` helpers fall back to
/// the Turkish text whenever the English one is missing. This means EN can
/// be filled in incrementally, lesson by lesson, without a big-bang refactor.

/// Picks the English value when the app language is English AND a translation
/// actually exists; otherwise returns the original (Turkish) value.
String pickLang(String tr, String? en, String lang) {
  if (lang == 'en' && en != null && en.trim().isNotEmpty) return en;
  return tr;
}

/// Nullable variant of [pickLang] - used for optional fields like tips.
String? pickLangNullable(String? tr, String? en, String lang) {
  if (lang == 'en' && en != null && en.trim().isNotEmpty) return en;
  return tr;
}

/// List variant of [pickLang] - falls back when the EN list is missing/empty.
List<String> pickLangList(List<String> tr, List<String>? en, String lang) {
  if (lang == 'en' && en != null && en.isNotEmpty) return en;
  return tr;
}

// ==========================================
// STEP-BASED LESSON STRUCTURE
// ==========================================

/// A lesson consists of multiple steps (challenges)
class InteractiveLesson {
  final String id;
  final String courseId;
  final String title;
  final String subtitle;
  final int order;
  final List<LessonStep> steps;
  final int xpReward;
  final String? badge; // Badge earned on completion
  final LessonCategory category;

  // Bilingual (optional - falls back to TR when absent)
  final String? titleEn;
  final String? subtitleEn;

  const InteractiveLesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.subtitle,
    required this.order,
    required this.steps,
    this.xpReward = 50,
    this.badge,
    this.category = LessonCategory.learn,
    this.titleEn,
    this.subtitleEn,
  });

  String titleFor(String lang) => pickLang(title, titleEn, lang);
  String subtitleFor(String lang) => pickLang(subtitle, subtitleEn, lang);

  int get totalSteps => steps.length;
  int get estimatedMinutes => (steps.length * 2).clamp(5, 30);
}

enum LessonCategory {
  learn,      // Teaching new concept
  practice,   // Apply what you learned
  project,    // Build something
  challenge,  // Test yourself
}

// ==========================================
// STEP TYPES - The Core of Interactivity
// ==========================================

/// Base class for all step types
abstract class LessonStep {
  final String id;
  final StepType type;
  final int xpReward;

  const LessonStep({
    required this.id,
    required this.type,
    this.xpReward = 5,
  });
}

enum StepType {
  // Content Steps
  intro,           // Introduction with animation
  explanation,     // Concept explanation
  demonstration,   // Show how it works

  // Interactive Steps
  multipleChoice,  // Pick the right answer
  dragAndDrop,     // Arrange items correctly
  codeComplete,    // Fill in the blanks
  blockBuilder,    // Build with Scratch blocks
  matching,        // Match pairs
  ordering,        // Put in correct order
  spotTheError,    // Find the bug
  typeTheCode,     // Type the code yourself

  // Visual Steps
  animation,       // Watch animation
  simulation,      // Interactive simulation

  // Challenge Steps
  miniGame,        // Play a mini game
  project,         // Build a project
}

// ==========================================
// CONTENT STEPS
// ==========================================

/// Introduction step with mascot/animation
class IntroStep extends LessonStep {
  final String mascotMessage;
  final String? mascotEmoji;
  final String? backgroundAnimation;
  final List<String> highlights;

  // Bilingual
  final String? mascotMessageEn;
  final List<String>? highlightsEn;

  const IntroStep({
    required super.id,
    required this.mascotMessage,
    this.mascotEmoji = '🤖',
    this.backgroundAnimation,
    this.highlights = const [],
    this.mascotMessageEn,
    this.highlightsEn,
  }) : super(type: StepType.intro, xpReward: 0);

  String mascotMessageFor(String lang) => pickLang(mascotMessage, mascotMessageEn, lang);
  List<String> highlightsFor(String lang) => pickLangList(highlights, highlightsEn, lang);
}

/// Explanation with visuals - NOT boring text
class ExplanationStep extends LessonStep {
  final String title;
  final String content;
  final List<VisualElement> visuals;
  final String? tipEmoji;
  final String? tip;

  // Bilingual
  final String? titleEn;
  final String? contentEn;
  final String? tipEn;

  const ExplanationStep({
    required super.id,
    required this.title,
    required this.content,
    this.visuals = const [],
    this.tipEmoji,
    this.tip,
    this.titleEn,
    this.contentEn,
    this.tipEn,
  }) : super(type: StepType.explanation, xpReward: 5);

  String titleFor(String lang) => pickLang(title, titleEn, lang);
  String contentFor(String lang) => pickLang(content, contentEn, lang);
  String? tipFor(String lang) => pickLangNullable(tip, tipEn, lang);
}

/// Visual element in explanation
class VisualElement {
  final VisualType type;
  final String content;
  final Color? color;
  final String? label;

  const VisualElement({
    required this.type,
    required this.content,
    this.color,
    this.label,
  });
}

enum VisualType {
  scratchBlock,    // Scratch block visual
  codeSnippet,     // Code with syntax highlighting
  diagram,         // Simple diagram
  icon,            // Icon/emoji illustration
  comparison,      // Before/after comparison
  flowchart,       // Step by step flow
}

// ==========================================
// INTERACTIVE STEPS - The Fun Part!
// ==========================================

/// Multiple choice question
class MultipleChoiceStep extends LessonStep {
  final String question;
  final List<ChoiceOption> options;
  final int correctIndex;
  final String explanation;
  final String? codeContext;
  final String? imageContext;

  // Bilingual
  final String? questionEn;
  final String? explanationEn;

  const MultipleChoiceStep({
    required super.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.codeContext,
    this.imageContext,
    this.questionEn,
    this.explanationEn,
    super.xpReward = 10,
  }) : super(type: StepType.multipleChoice);

  String questionFor(String lang) => pickLang(question, questionEn, lang);
  String explanationFor(String lang) => pickLang(explanation, explanationEn, lang);
}

class ChoiceOption {
  final String text;
  final String? emoji;
  final bool isCode;

  // Bilingual
  final String? textEn;

  const ChoiceOption({
    required this.text,
    this.emoji,
    this.isCode = false,
    this.textEn,
  });

  String textFor(String lang) => pickLang(text, textEn, lang);
}

/// Drag and drop - arrange items
class DragDropStep extends LessonStep {
  final String instruction;
  final List<DraggableItem> items;
  final List<DropZone> dropZones;
  final Map<String, String> correctMapping; // itemId -> zoneId
  final String successMessage;

  // Bilingual
  final String? instructionEn;
  final String? successMessageEn;

  const DragDropStep({
    required super.id,
    required this.instruction,
    required this.items,
    required this.dropZones,
    required this.correctMapping,
    this.successMessage = 'Harika! Dogru eslestirdin!',
    this.instructionEn,
    this.successMessageEn,
    super.xpReward = 15,
  }) : super(type: StepType.dragAndDrop);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang);
  String successMessageFor(String lang) => pickLang(successMessage, successMessageEn, lang);
}

class DraggableItem {
  final String id;
  final String content;
  final Color? color;
  final bool isBlock; // Scratch block style

  // Bilingual
  final String? contentEn;

  const DraggableItem({
    required this.id,
    required this.content,
    this.color,
    this.isBlock = false,
    this.contentEn,
  });

  String contentFor(String lang) => pickLang(content, contentEn, lang);
}

class DropZone {
  final String id;
  final String label;
  final String? hint;

  // Bilingual
  final String? labelEn;
  final String? hintEn;

  const DropZone({
    required this.id,
    required this.label,
    this.hint,
    this.labelEn,
    this.hintEn,
  });

  String labelFor(String lang) => pickLang(label, labelEn, lang);
  String? hintFor(String lang) => pickLangNullable(hint, hintEn, lang);
}

/// Code completion - fill in the blanks
class CodeCompleteStep extends LessonStep {
  final String instruction;
  final String codeTemplate; // Use ___ for blanks
  final List<CodeBlank> blanks;
  final String language;
  final String? expectedOutput;

  // Bilingual
  final String? instructionEn;

  const CodeCompleteStep({
    required super.id,
    required this.instruction,
    required this.codeTemplate,
    required this.blanks,
    required this.language,
    this.expectedOutput,
    this.instructionEn,
    super.xpReward = 15,
  }) : super(type: StepType.codeComplete);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang);
}

class CodeBlank {
  final int index;
  final String correctAnswer;
  final List<String>? acceptableAlternatives;
  final String hint;

  // Bilingual
  final String? hintEn;

  const CodeBlank({
    required this.index,
    required this.correctAnswer,
    this.acceptableAlternatives,
    required this.hint,
    this.hintEn,
  });

  String hintFor(String lang) => pickLang(hint, hintEn, lang);
}

/// Scratch Block Builder - visual programming
class BlockBuilderStep extends LessonStep {
  final String instruction;
  final String goal; // What should the sprite do?
  final List<ScratchBlock> availableBlocks;
  final List<String> correctSequence; // Block IDs in order
  final String? previewAnimation;

  // Bilingual
  final String? instructionEn;
  final String? goalEn;

  const BlockBuilderStep({
    required super.id,
    required this.instruction,
    required this.goal,
    required this.availableBlocks,
    required this.correctSequence,
    this.previewAnimation,
    this.instructionEn,
    this.goalEn,
    super.xpReward = 20,
  }) : super(type: StepType.blockBuilder);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang);
  String goalFor(String lang) => pickLang(goal, goalEn, lang);
}

class ScratchBlock {
  final String id;
  final ScratchBlockType blockType;
  final ScratchBlockShape shape;  // Yapboz şekli
  final String label;
  final Color color;
  final List<BlockInput>? inputs;  // Girdi yuvaları
  final bool hasOutput;  // Çıktı veriri mi (reporter block)
  final String? defaultValue;  // Varsayılan değer

  // Bilingual
  final String? labelEn;

  const ScratchBlock({
    required this.id,
    required this.blockType,
    required this.shape,
    required this.label,
    required this.color,
    this.inputs,
    this.hasOutput = false,
    this.defaultValue,
    this.labelEn,
  });

  String labelFor(String lang) => pickLang(label, labelEn, lang);
}

/// Blok input tanımı (yapboz girdileri)
class BlockInput {
  final String name;  // Input adı (örn: "steps", "seconds")
  final BlockInputType type;  // Input tipi
  final String? placeholder;  // Placeholder metin
  final dynamic defaultValue;  // Varsayılan değer

  const BlockInput({
    required this.name,
    required this.type,
    this.placeholder,
    this.defaultValue,
  });
}

/// Input tipleri (Scratch'teki gibi)
enum BlockInputType {
  number,      // Sayı girişi
  text,        // Metin girişi
  boolean,     // Koşul/boolean girişi
  color,       // Renk seçici
  block,       // İçine blok alabilir
  dropdown,    // Açılır menü
}

/// Blok şekilleri (Scratch yapboz parçaları)
enum ScratchBlockShape {
  stack,       // Üst üste takılır (hat blocks)
  cap,         // Başlangıç bloğu (event blocks)
  cBlock,      // C-şekli, içine blok alır (if, repeat)
  reporter,    // Oval, değer döndürür
  boolean,     // Altıgen, true/false döndürür
}

enum ScratchBlockType {
  motion,      // Blue #4C97FF - hareket
  looks,       // Purple #9966FF - gorunum
  sound,       // Pink #CF63CF - ses
  events,      // Yellow #FFBF00 - olaylar
  control,     // Orange #FFAB19 - kontrol
  sensing,     // Cyan #5CB1D6 - algilama
  operators,   // Green #59C059 - operatorler
  variables,   // Red #FF8C1A - degiskenler
  myBlocks,    // Purple #FF6680 - ozel bloklar
}

/// Matching pairs game
class MatchingStep extends LessonStep {
  final String instruction;
  final List<MatchPair> pairs;
  final MatchingMode mode;

  // Bilingual
  final String? instructionEn;

  const MatchingStep({
    required super.id,
    required this.instruction,
    required this.pairs,
    this.mode = MatchingMode.drawLines,
    this.instructionEn,
    super.xpReward = 15,
  }) : super(type: StepType.matching);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang);
}

class MatchPair {
  final String id;
  final String left;
  final String right;
  final bool isLeftCode;
  final bool isRightCode;

  // Bilingual
  final String? leftEn;
  final String? rightEn;

  const MatchPair({
    required this.id,
    required this.left,
    required this.right,
    this.isLeftCode = false,
    this.isRightCode = false,
    this.leftEn,
    this.rightEn,
  });

  String leftFor(String lang) => pickLang(left, leftEn, lang);
  String rightFor(String lang) => pickLang(right, rightEn, lang);
}

enum MatchingMode {
  drawLines,   // Draw lines between pairs
  tapToMatch,  // Tap two items to match
}

/// Put items in correct order
class OrderingStep extends LessonStep {
  final String instruction;
  final List<OrderItem> items;
  final List<String> correctOrder; // Item IDs
  final String context; // What are we ordering?

  // Bilingual
  final String? instructionEn;
  final String? contextEn;

  const OrderingStep({
    required super.id,
    required this.instruction,
    required this.items,
    required this.correctOrder,
    required this.context,
    this.instructionEn,
    this.contextEn,
    super.xpReward = 15,
  }) : super(type: StepType.ordering);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang);
  String contextFor(String lang) => pickLang(context, contextEn, lang);
}

class OrderItem {
  final String id;
  final String content;
  final bool isCode;

  // Bilingual
  final String? contentEn;

  const OrderItem({
    required this.id,
    required this.content,
    this.isCode = false,
    this.contentEn,
  });

  String contentFor(String lang) => pickLang(content, contentEn, lang);
}

/// Find the bug/error
class SpotErrorStep extends LessonStep {
  final String instruction;
  final String code;
  final String language;
  final int errorLine;
  final String errorDescription;
  final String correctCode;
  final String explanation;

  // Bilingual
  final String? instructionEn;
  final String? errorDescriptionEn;
  final String? explanationEn;

  const SpotErrorStep({
    required super.id,
    required this.instruction,
    required this.code,
    required this.language,
    required this.errorLine,
    required this.errorDescription,
    required this.correctCode,
    required this.explanation,
    this.instructionEn,
    this.errorDescriptionEn,
    this.explanationEn,
    super.xpReward = 20,
  }) : super(type: StepType.spotTheError);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang);
  String errorDescriptionFor(String lang) => pickLang(errorDescription, errorDescriptionEn, lang);
  String explanationFor(String lang) => pickLang(explanation, explanationEn, lang);
}

/// Type the code yourself
class TypeCodeStep extends LessonStep {
  final String instruction;
  final String targetCode;
  final String language;
  final String? starterCode;
  final List<String> hints;
  final String? expectedOutput;

  // Bilingual (code itself is language-neutral, only prose is translated)
  final String? instructionEn;
  final List<String>? hintsEn;

  const TypeCodeStep({
    required super.id,
    required this.instruction,
    required this.targetCode,
    required this.language,
    this.starterCode,
    this.hints = const [],
    this.expectedOutput,
    this.instructionEn,
    this.hintsEn,
    super.xpReward = 25,
  }) : super(type: StepType.typeTheCode);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang);
  List<String> hintsFor(String lang) => pickLangList(hints, hintsEn, lang);
}

// ==========================================
// VISUAL STEPS
// ==========================================

/// Animation showing concept
class AnimationStep extends LessonStep {
  final String title;
  final String description;
  final AnimationType animationType;
  final Map<String, dynamic> animationData;
  final bool autoPlay;

  // Bilingual
  final String? titleEn;
  final String? descriptionEn;

  const AnimationStep({
    required super.id,
    required this.title,
    required this.description,
    required this.animationType,
    required this.animationData,
    this.autoPlay = true,
    this.titleEn,
    this.descriptionEn,
  }) : super(type: StepType.animation, xpReward: 5);

  String titleFor(String lang) => pickLang(title, titleEn, lang);
  String descriptionFor(String lang) => pickLang(description, descriptionEn, lang);
}

enum AnimationType {
  scratchSprite,     // Sprite animation
  codeExecution,     // Code running step by step
  conceptDiagram,    // Animated diagram
  comparison,        // Before/after
  flowVisualization, // Data flow
}

/// Interactive simulation
class SimulationStep extends LessonStep {
  final String title;
  final String instruction;
  final SimulationType simulationType;
  final Map<String, dynamic> config;

  // Bilingual
  final String? titleEn;
  final String? instructionEn;

  const SimulationStep({
    required super.id,
    required this.title,
    required this.instruction,
    required this.simulationType,
    required this.config,
    this.titleEn,
    this.instructionEn,
    super.xpReward = 15,
  }) : super(type: StepType.simulation);

  String titleFor(String lang) => pickLang(title, titleEn, lang);
  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang);
}

enum SimulationType {
  scratchStage,      // Mini Scratch stage
  webPreview,        // HTML/CSS preview
  terminal,          // Command output
  robotSimulator,    // Arduino/robot
}

// ==========================================
// CHALLENGE STEPS
// ==========================================

/// Mini game for learning
class MiniGameStep extends LessonStep {
  final String title;
  final String instruction;
  final MiniGameType gameType;
  final Map<String, dynamic> gameConfig;
  final int targetScore;

  // Bilingual
  final String? titleEn;
  final String? instructionEn;

  const MiniGameStep({
    required super.id,
    required this.title,
    required this.instruction,
    required this.gameType,
    required this.gameConfig,
    this.targetScore = 100,
    this.titleEn,
    this.instructionEn,
    super.xpReward = 30,
  }) : super(type: StepType.miniGame);

  String titleFor(String lang) => pickLang(title, titleEn, lang);
  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang);
}

enum MiniGameType {
  catchTheBlock,     // Catch falling Scratch blocks
  codeRunner,        // Run to collect code pieces
  bugHunter,         // Find and squash bugs
  memoryMatch,       // Memory card game with code
  typeRacer,         // Type code fast
  blockPuzzle,       // Arrange blocks puzzle
}

/// Build a project
class ProjectStep extends LessonStep {
  final String title;
  final String description;
  final List<String> requirements;
  final List<String> hints;
  final String starterCode;
  final String language;
  final ProjectValidation validation;

  // Bilingual
  final String? titleEn;
  final String? descriptionEn;
  final List<String>? requirementsEn;
  final List<String>? hintsEn;

  const ProjectStep({
    required super.id,
    required this.title,
    required this.description,
    required this.requirements,
    this.hints = const [],
    required this.starterCode,
    required this.language,
    required this.validation,
    this.titleEn,
    this.descriptionEn,
    this.requirementsEn,
    this.hintsEn,
    super.xpReward = 50,
  }) : super(type: StepType.project);

  String titleFor(String lang) => pickLang(title, titleEn, lang);
  String descriptionFor(String lang) => pickLang(description, descriptionEn, lang);
  List<String> requirementsFor(String lang) => pickLangList(requirements, requirementsEn, lang);
  List<String> hintsFor(String lang) => pickLangList(hints, hintsEn, lang);
}

class ProjectValidation {
  final List<String> mustContain;
  final List<String> mustNotContain;
  final String? expectedOutput;

  const ProjectValidation({
    this.mustContain = const [],
    this.mustNotContain = const [],
    this.expectedOutput,
  });
}

// ==========================================
// BADGES & ACHIEVEMENTS
// ==========================================

class LessonBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final BadgeRarity rarity;
  final BadgeCategory category;

  // Bilingual
  final String? nameEn;
  final String? descriptionEn;

  const LessonBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.rarity = BadgeRarity.common,
    required this.category,
    this.nameEn,
    this.descriptionEn,
  });

  String nameFor(String lang) => pickLang(name, nameEn, lang);
  String descriptionFor(String lang) => pickLang(description, descriptionEn, lang);
}

enum BadgeRarity {
  common,      // Easy to get
  uncommon,    // Some effort
  rare,        // Significant achievement
  epic,        // Hard to get
  legendary,   // Very rare
}

enum BadgeCategory {
  course,      // Course completion
  lesson,      // Lesson milestones
  streak,      // Consecutive days
  skill,       // Skill mastery
  social,      // Community
  special,     // Events/seasonal
}
