import 'package:flutter/material.dart';

/// Modern, FreeCodeCamp-inspired interactive lesson model
/// Focused on engagement, not Wikipedia-style reading

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
  });

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

  const IntroStep({
    required super.id,
    required this.mascotMessage,
    this.mascotEmoji = '🤖',
    this.backgroundAnimation,
    this.highlights = const [],
  }) : super(type: StepType.intro, xpReward: 0);
}

/// Explanation with visuals - NOT boring text
class ExplanationStep extends LessonStep {
  final String title;
  final String content;
  final List<VisualElement> visuals;
  final String? tipEmoji;
  final String? tip;

  const ExplanationStep({
    required super.id,
    required this.title,
    required this.content,
    this.visuals = const [],
    this.tipEmoji,
    this.tip,
  }) : super(type: StepType.explanation, xpReward: 5);
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

  const MultipleChoiceStep({
    required super.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.codeContext,
    this.imageContext,
    super.xpReward = 10,
  }) : super(type: StepType.multipleChoice);
}

class ChoiceOption {
  final String text;
  final String? emoji;
  final bool isCode;

  const ChoiceOption({
    required this.text,
    this.emoji,
    this.isCode = false,
  });
}

/// Drag and drop - arrange items
class DragDropStep extends LessonStep {
  final String instruction;
  final List<DraggableItem> items;
  final List<DropZone> dropZones;
  final Map<String, String> correctMapping; // itemId -> zoneId
  final String successMessage;

  const DragDropStep({
    required super.id,
    required this.instruction,
    required this.items,
    required this.dropZones,
    required this.correctMapping,
    this.successMessage = 'Harika! Dogru eslestirdin!',
    super.xpReward = 15,
  }) : super(type: StepType.dragAndDrop);
}

class DraggableItem {
  final String id;
  final String content;
  final Color? color;
  final bool isBlock; // Scratch block style

  const DraggableItem({
    required this.id,
    required this.content,
    this.color,
    this.isBlock = false,
  });
}

class DropZone {
  final String id;
  final String label;
  final String? hint;

  const DropZone({
    required this.id,
    required this.label,
    this.hint,
  });
}

/// Code completion - fill in the blanks
class CodeCompleteStep extends LessonStep {
  final String instruction;
  final String codeTemplate; // Use ___ for blanks
  final List<CodeBlank> blanks;
  final String language;
  final String? expectedOutput;

  const CodeCompleteStep({
    required super.id,
    required this.instruction,
    required this.codeTemplate,
    required this.blanks,
    required this.language,
    this.expectedOutput,
    super.xpReward = 15,
  }) : super(type: StepType.codeComplete);
}

class CodeBlank {
  final int index;
  final String correctAnswer;
  final List<String>? acceptableAlternatives;
  final String hint;

  const CodeBlank({
    required this.index,
    required this.correctAnswer,
    this.acceptableAlternatives,
    required this.hint,
  });
}

/// Scratch Block Builder - visual programming
class BlockBuilderStep extends LessonStep {
  final String instruction;
  final String goal; // What should the sprite do?
  final List<ScratchBlock> availableBlocks;
  final List<String> correctSequence; // Block IDs in order
  final String? previewAnimation;

  const BlockBuilderStep({
    required super.id,
    required this.instruction,
    required this.goal,
    required this.availableBlocks,
    required this.correctSequence,
    this.previewAnimation,
    super.xpReward = 20,
  }) : super(type: StepType.blockBuilder);
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

  const ScratchBlock({
    required this.id,
    required this.blockType,
    required this.shape,
    required this.label,
    required this.color,
    this.inputs,
    this.hasOutput = false,
    this.defaultValue,
  });
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

  const MatchingStep({
    required super.id,
    required this.instruction,
    required this.pairs,
    this.mode = MatchingMode.drawLines,
    super.xpReward = 15,
  }) : super(type: StepType.matching);
}

class MatchPair {
  final String id;
  final String left;
  final String right;
  final bool isLeftCode;
  final bool isRightCode;

  const MatchPair({
    required this.id,
    required this.left,
    required this.right,
    this.isLeftCode = false,
    this.isRightCode = false,
  });
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

  const OrderingStep({
    required super.id,
    required this.instruction,
    required this.items,
    required this.correctOrder,
    required this.context,
    super.xpReward = 15,
  }) : super(type: StepType.ordering);
}

class OrderItem {
  final String id;
  final String content;
  final bool isCode;

  const OrderItem({
    required this.id,
    required this.content,
    this.isCode = false,
  });
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

  const SpotErrorStep({
    required super.id,
    required this.instruction,
    required this.code,
    required this.language,
    required this.errorLine,
    required this.errorDescription,
    required this.correctCode,
    required this.explanation,
    super.xpReward = 20,
  }) : super(type: StepType.spotTheError);
}

/// Type the code yourself
class TypeCodeStep extends LessonStep {
  final String instruction;
  final String targetCode;
  final String language;
  final String? starterCode;
  final List<String> hints;
  final String? expectedOutput;

  const TypeCodeStep({
    required super.id,
    required this.instruction,
    required this.targetCode,
    required this.language,
    this.starterCode,
    this.hints = const [],
    this.expectedOutput,
    super.xpReward = 25,
  }) : super(type: StepType.typeTheCode);
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

  const AnimationStep({
    required super.id,
    required this.title,
    required this.description,
    required this.animationType,
    required this.animationData,
    this.autoPlay = true,
  }) : super(type: StepType.animation, xpReward: 5);
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

  const SimulationStep({
    required super.id,
    required this.title,
    required this.instruction,
    required this.simulationType,
    required this.config,
    super.xpReward = 15,
  }) : super(type: StepType.simulation);
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

  const MiniGameStep({
    required super.id,
    required this.title,
    required this.instruction,
    required this.gameType,
    required this.gameConfig,
    this.targetScore = 100,
    super.xpReward = 30,
  }) : super(type: StepType.miniGame);
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

  const ProjectStep({
    required super.id,
    required this.title,
    required this.description,
    required this.requirements,
    this.hints = const [],
    required this.starterCode,
    required this.language,
    required this.validation,
    super.xpReward = 50,
  }) : super(type: StepType.project);
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

  const LessonBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.rarity = BadgeRarity.common,
    required this.category,
  });
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
