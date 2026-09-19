import 'package:flutter/material.dart';

/// Modern, FreeCodeCamp-inspired interactive lesson model
/// Focused on engagement, not Wikipedia-style reading
///
/// DERS ICERIGININ DILI (TR + EN, DE/ES ICIN EN)
/// ---------------------------------------------
/// Kullaniciya gorunen her metin alaninin istege bagli bir `...En` esi var.
/// Ceviri yoksa alan null kaliyor ve `...For(lang)` yardimcilari Turkce
/// metne dusuyor. Boylece Ingilizce ders ders, buyuk bir refactor olmadan
/// doldurulabiliyor.
///
/// ONEMLI DUZELTME: bu yardimcilar eskiden yalnizca `lang == 'en'` ise
/// Ingilizceyi seciyordu. Uygulama Almanca ve Ispanyolcayi da destekler
/// hale gelince bu, Almanca secen bir kullaniciya — Ingilizce cevirisi
/// HAZIR OLDUGU HALDE — Turkce ders icerigi gostermek demek oluyordu.
/// Artik Turkce disindaki her dil, varsa Ingilizceye dusuyor. Turkce hala
/// birincil dil: `lang == 'tr'` her zaman Turkce metni aliyor.
///
/// Bu bir ceviri DEGIL, makul bir yedek. Almanca/Ispanyolca ders metinleri
/// yazildiginda buraya `...De` / `...Es` alanlari eklenecek.

/// Ders metni icin dil secimi.
///
/// SIRA: once dilin KENDI metni, yoksa Ingilizce, o da yoksa Turkce.
///
/// Almanca ya da Ispanyolca alan bos birakilabilir; o zaman metin
/// Ingilizce gider. Yani ceviri kurs kurs eklenebiliyor, yarim kalan
/// bir kurs bozuk gorunmuyor - sadece o kismi Ingilizce kaliyor.
String pickLang(String tr, String? en, String lang,
    [String? de, String? es]) {
  final kendi = lang == 'de' ? de : (lang == 'es' ? es : null);
  if (kendi != null && kendi.trim().isNotEmpty) return kendi;
  if (lang != 'tr' && en != null && en.trim().isNotEmpty) return en;
  return tr;
}

/// Nullable variant of [pickLang] - used for optional fields like tips.
String? pickLangNullable(String? tr, String? en, String lang,
    [String? de, String? es]) {
  final kendi = lang == 'de' ? de : (lang == 'es' ? es : null);
  if (kendi != null && kendi.trim().isNotEmpty) return kendi;
  if (lang != 'tr' && en != null && en.trim().isNotEmpty) return en;
  return tr;
}

/// List variant of [pickLang] - falls back when the EN list is missing/empty.
List<String> pickLangList(List<String> tr, List<String>? en, String lang,
    [List<String>? de, List<String>? es]) {
  final kendi = lang == 'de' ? de : (lang == 'es' ? es : null);
  if (kendi != null && kendi.isNotEmpty) return kendi;
  if (lang != 'tr' && en != null && en.isNotEmpty) return en;
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
  final String? titleDe;
  final String? titleEs;
  final String? subtitleEn;
  final String? subtitleDe;
  final String? subtitleEs;

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
    this.titleDe,
    this.titleEs,
    this.subtitleEn,
    this.subtitleDe,
    this.subtitleEs,
  });

  String titleFor(String lang) => pickLang(title, titleEn, lang, titleDe, titleEs);
  String subtitleFor(String lang) => pickLang(subtitle, subtitleEn, lang, subtitleDe, subtitleEs);

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
  final String? mascotMessageDe;
  final String? mascotMessageEs;
  final List<String>? highlightsEn;
  final List<String>? highlightsDe;
  final List<String>? highlightsEs;

  const IntroStep({
    required super.id,
    required this.mascotMessage,
    this.mascotEmoji = '🤖',
    this.backgroundAnimation,
    this.highlights = const [],
    this.mascotMessageEn,
    this.mascotMessageDe,
    this.mascotMessageEs,
    this.highlightsEn,
    this.highlightsDe,
    this.highlightsEs,
  }) : super(type: StepType.intro, xpReward: 0);

  String mascotMessageFor(String lang) => pickLang(mascotMessage, mascotMessageEn, lang, mascotMessageDe, mascotMessageEs);
  List<String> highlightsFor(String lang) => pickLangList(highlights, highlightsEn, lang, highlightsDe, highlightsEs);
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
  final String? titleDe;
  final String? titleEs;
  final String? contentEn;
  final String? contentDe;
  final String? contentEs;
  final String? tipEn;
  final String? tipDe;
  final String? tipEs;

  const ExplanationStep({
    required super.id,
    required this.title,
    required this.content,
    this.visuals = const [],
    this.tipEmoji,
    this.tip,
    this.titleEn,
    this.titleDe,
    this.titleEs,
    this.contentEn,
    this.contentDe,
    this.contentEs,
    this.tipEn,
    this.tipDe,
    this.tipEs,
  }) : super(type: StepType.explanation, xpReward: 5);

  String titleFor(String lang) => pickLang(title, titleEn, lang, titleDe, titleEs);
  String contentFor(String lang) => pickLang(content, contentEn, lang, contentDe, contentEs);
  String? tipFor(String lang) => pickLangNullable(tip, tipEn, lang, tipDe, tipEs);
}

/// Visual element in explanation
class VisualElement {
  final VisualType type;
  final String content;
  final Color? color;
  final String? label;

  /// Çeviriler.
  ///
  /// Bu alanların olmaması bir eksikti ve ceviri hattı kurulunca ortaya
  /// çıktı: `content` ve `label` çocuğa GÖRÜNEN metinler — blok
  /// görsellerinin üstündeki yazılar, diyagram etiketleri. Modelde
  /// karşılıkları olmadığı için Ingilizce ekranda bile Türkçe
  /// kalıyorlardı ("Mavi - Hareket ettir", "10 adım git" gibi).
  final String? contentEn;
  final String? contentDe;
  final String? contentEs;
  final String? labelEn;
  final String? labelDe;
  final String? labelEs;

  const VisualElement({
    required this.type,
    required this.content,
    this.color,
    this.label,
    this.contentEn,
    this.contentDe,
    this.contentEs,
    this.labelEn,
    this.labelDe,
    this.labelEs,
  });

  String contentFor(String lang) => pickLang(content, contentEn, lang, contentDe, contentEs);
  String? labelFor(String lang) => pickLangNullable(label, labelEn, lang, labelDe, labelEs);
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
  final String? questionDe;
  final String? questionEs;
  final String? explanationEn;
  final String? explanationDe;
  final String? explanationEs;

  const MultipleChoiceStep({
    required super.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.codeContext,
    this.imageContext,
    this.questionEn,
    this.questionDe,
    this.questionEs,
    this.explanationEn,
    this.explanationDe,
    this.explanationEs,
    super.xpReward = 10,
  }) : super(type: StepType.multipleChoice);

  String questionFor(String lang) => pickLang(question, questionEn, lang, questionDe, questionEs);
  String explanationFor(String lang) => pickLang(explanation, explanationEn, lang, explanationDe, explanationEs);
}

class ChoiceOption {
  final String text;
  final String? emoji;
  final bool isCode;

  // Bilingual
  final String? textEn;
  final String? textDe;
  final String? textEs;

  const ChoiceOption({
    required this.text,
    this.emoji,
    this.isCode = false,
    this.textEn,
    this.textDe,
    this.textEs,
  });

  String textFor(String lang) => pickLang(text, textEn, lang, textDe, textEs);
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
  final String? instructionDe;
  final String? instructionEs;
  final String? successMessageEn;
  final String? successMessageDe;
  final String? successMessageEs;

  const DragDropStep({
    required super.id,
    required this.instruction,
    required this.items,
    required this.dropZones,
    required this.correctMapping,
    this.successMessage = 'Harika! Doğru eşleştirdin!',
    this.instructionEn,
    this.instructionDe,
    this.instructionEs,
    this.successMessageEn,
    this.successMessageDe,
    this.successMessageEs,
    super.xpReward = 15,
  }) : super(type: StepType.dragAndDrop);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang, instructionDe, instructionEs);
  String successMessageFor(String lang) => pickLang(successMessage, successMessageEn, lang, successMessageDe, successMessageEs);
}

class DraggableItem {
  final String id;
  final String content;
  final Color? color;
  final bool isBlock; // Scratch block style

  // Bilingual
  final String? contentEn;
  final String? contentDe;
  final String? contentEs;

  const DraggableItem({
    required this.id,
    required this.content,
    this.color,
    this.isBlock = false,
    this.contentEn,
    this.contentDe,
    this.contentEs,
  });

  String contentFor(String lang) => pickLang(content, contentEn, lang, contentDe, contentEs);
}

class DropZone {
  final String id;
  final String label;
  final String? hint;

  // Bilingual
  final String? labelEn;
  final String? labelDe;
  final String? labelEs;
  final String? hintEn;
  final String? hintDe;
  final String? hintEs;

  const DropZone({
    required this.id,
    required this.label,
    this.hint,
    this.labelEn,
    this.labelDe,
    this.labelEs,
    this.hintEn,
    this.hintDe,
    this.hintEs,
  });

  String labelFor(String lang) => pickLang(label, labelEn, lang, labelDe, labelEs);
  String? hintFor(String lang) => pickLangNullable(hint, hintEn, lang, hintDe, hintEs);
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
  final String? instructionDe;
  final String? instructionEs;

  const CodeCompleteStep({
    required super.id,
    required this.instruction,
    required this.codeTemplate,
    required this.blanks,
    required this.language,
    this.expectedOutput,
    this.instructionEn,
    this.instructionDe,
    this.instructionEs,
    super.xpReward = 15,
  }) : super(type: StepType.codeComplete);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang, instructionDe, instructionEs);
}

class CodeBlank {
  final int index;
  final String correctAnswer;
  final List<String>? acceptableAlternatives;
  final String hint;

  // Bilingual
  final String? hintEn;
  final String? hintDe;
  final String? hintEs;

  const CodeBlank({
    required this.index,
    required this.correctAnswer,
    this.acceptableAlternatives,
    required this.hint,
    this.hintEn,
    this.hintDe,
    this.hintEs,
  });

  String hintFor(String lang) => pickLang(hint, hintEn, lang, hintDe, hintEs);
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
  final String? instructionDe;
  final String? instructionEs;
  final String? goalEn;
  final String? goalDe;
  final String? goalEs;

  const BlockBuilderStep({
    required super.id,
    required this.instruction,
    required this.goal,
    required this.availableBlocks,
    required this.correctSequence,
    this.previewAnimation,
    this.instructionEn,
    this.instructionDe,
    this.instructionEs,
    this.goalEn,
    this.goalDe,
    this.goalEs,
    super.xpReward = 20,
  }) : super(type: StepType.blockBuilder);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang, instructionDe, instructionEs);
  String goalFor(String lang) => pickLang(goal, goalEn, lang, goalDe, goalEs);
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
  final String? labelDe;
  final String? labelEs;

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
    this.labelDe,
    this.labelEs,
  });

  String labelFor(String lang) => pickLang(label, labelEn, lang, labelDe, labelEs);
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

  // Bilingual
  final String? instructionEn;
  final String? instructionDe;
  final String? instructionEs;

  const MatchingStep({
    required super.id,
    required this.instruction,
    required this.pairs,
    this.instructionEn,
    this.instructionDe,
    this.instructionEs,
    super.xpReward = 15,
  }) : super(type: StepType.matching);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang, instructionDe, instructionEs);
}

class MatchPair {
  final String id;
  final String left;
  final String right;
  final bool isLeftCode;
  final bool isRightCode;

  // Bilingual
  final String? leftEn;
  final String? leftDe;
  final String? leftEs;
  final String? rightEn;
  final String? rightDe;
  final String? rightEs;

  const MatchPair({
    required this.id,
    required this.left,
    required this.right,
    this.isLeftCode = false,
    this.isRightCode = false,
    this.leftEn,
    this.leftDe,
    this.leftEs,
    this.rightEn,
    this.rightDe,
    this.rightEs,
  });

  String leftFor(String lang) => pickLang(left, leftEn, lang, leftDe, leftEs);
  String rightFor(String lang) => pickLang(right, rightEn, lang, rightDe, rightEs);
}

/// Put items in correct order
class OrderingStep extends LessonStep {
  final String instruction;
  final List<OrderItem> items;
  final List<String> correctOrder; // Item IDs
  final String context; // What are we ordering?

  // Bilingual
  final String? instructionEn;
  final String? instructionDe;
  final String? instructionEs;
  final String? contextEn;
  final String? contextDe;
  final String? contextEs;

  const OrderingStep({
    required super.id,
    required this.instruction,
    required this.items,
    required this.correctOrder,
    required this.context,
    this.instructionEn,
    this.instructionDe,
    this.instructionEs,
    this.contextEn,
    this.contextDe,
    this.contextEs,
    super.xpReward = 15,
  }) : super(type: StepType.ordering);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang, instructionDe, instructionEs);
  String contextFor(String lang) => pickLang(context, contextEn, lang, contextDe, contextEs);
}

class OrderItem {
  final String id;
  final String content;
  final bool isCode;

  // Bilingual
  final String? contentEn;
  final String? contentDe;
  final String? contentEs;

  const OrderItem({
    required this.id,
    required this.content,
    this.isCode = false,
    this.contentEn,
    this.contentDe,
    this.contentEs,
  });

  String contentFor(String lang) => pickLang(content, contentEn, lang, contentDe, contentEs);
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
  final String? instructionDe;
  final String? instructionEs;
  final String? errorDescriptionEn;
  final String? errorDescriptionDe;
  final String? errorDescriptionEs;
  final String? explanationEn;
  final String? explanationDe;
  final String? explanationEs;

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
    this.instructionDe,
    this.instructionEs,
    this.errorDescriptionEn,
    this.errorDescriptionDe,
    this.errorDescriptionEs,
    this.explanationEn,
    this.explanationDe,
    this.explanationEs,
    super.xpReward = 20,
  }) : super(type: StepType.spotTheError);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang, instructionDe, instructionEs);
  String errorDescriptionFor(String lang) => pickLang(errorDescription, errorDescriptionEn, lang, errorDescriptionDe, errorDescriptionEs);
  String explanationFor(String lang) => pickLang(explanation, explanationEn, lang, explanationDe, explanationEs);
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
  final String? instructionDe;
  final String? instructionEs;
  final List<String>? hintsEn;
  final List<String>? hintsDe;
  final List<String>? hintsEs;

  const TypeCodeStep({
    required super.id,
    required this.instruction,
    required this.targetCode,
    required this.language,
    this.starterCode,
    this.hints = const [],
    this.expectedOutput,
    this.instructionEn,
    this.instructionDe,
    this.instructionEs,
    this.hintsEn,
    this.hintsDe,
    this.hintsEs,
    super.xpReward = 25,
  }) : super(type: StepType.typeTheCode);

  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang, instructionDe, instructionEs);
  List<String> hintsFor(String lang) => pickLangList(hints, hintsEn, lang, hintsDe, hintsEs);
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
  final String? titleDe;
  final String? titleEs;
  final String? descriptionEn;
  final String? descriptionDe;
  final String? descriptionEs;

  const AnimationStep({
    required super.id,
    required this.title,
    required this.description,
    required this.animationType,
    required this.animationData,
    this.autoPlay = true,
    this.titleEn,
    this.titleDe,
    this.titleEs,
    this.descriptionEn,
    this.descriptionDe,
    this.descriptionEs,
  }) : super(type: StepType.animation, xpReward: 5);

  String titleFor(String lang) => pickLang(title, titleEn, lang, titleDe, titleEs);
  String descriptionFor(String lang) => pickLang(description, descriptionEn, lang, descriptionDe, descriptionEs);
}

enum AnimationType {
  scratchSprite,     // Sprite animation
  codeExecution,     // Code running step by step
  conceptDiagram,    // Animated diagram
  comparison,        // Before/after
  flowVisualization, // Data flow
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
  final String? titleDe;
  final String? titleEs;
  final String? instructionEn;
  final String? instructionDe;
  final String? instructionEs;

  const MiniGameStep({
    required super.id,
    required this.title,
    required this.instruction,
    required this.gameType,
    required this.gameConfig,
    this.targetScore = 100,
    this.titleEn,
    this.titleDe,
    this.titleEs,
    this.instructionEn,
    this.instructionDe,
    this.instructionEs,
    super.xpReward = 30,
  }) : super(type: StepType.miniGame);

  String titleFor(String lang) => pickLang(title, titleEn, lang, titleDe, titleEs);
  String instructionFor(String lang) => pickLang(instruction, instructionEn, lang, instructionDe, instructionEs);
}

/// Yalnizca gercekten ekrani olan iki tur duruyor. codeRunner, bugHunter,
/// memoryMatch ve typeRacer hic uretilmedi; enum'da durduklari surece
/// "yarin yazariz" izlenimi veriyorlardi.
enum MiniGameType {
  catchTheBlock,     // Catch falling Scratch blocks
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
  final String? titleDe;
  final String? titleEs;
  final String? descriptionEn;
  final String? descriptionDe;
  final String? descriptionEs;
  final List<String>? requirementsEn;
  final List<String>? requirementsDe;
  final List<String>? requirementsEs;
  final List<String>? hintsEn;
  final List<String>? hintsDe;
  final List<String>? hintsEs;

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
    this.titleDe,
    this.titleEs,
    this.descriptionEn,
    this.descriptionDe,
    this.descriptionEs,
    this.requirementsEn,
    this.requirementsDe,
    this.requirementsEs,
    this.hintsEn,
    this.hintsDe,
    this.hintsEs,
    super.xpReward = 50,
  }) : super(type: StepType.project);

  String titleFor(String lang) => pickLang(title, titleEn, lang, titleDe, titleEs);
  String descriptionFor(String lang) => pickLang(description, descriptionEn, lang, descriptionDe, descriptionEs);
  List<String> requirementsFor(String lang) => pickLangList(requirements, requirementsEn, lang, requirementsDe, requirementsEs);
  List<String> hintsFor(String lang) => pickLangList(hints, hintsEn, lang, hintsDe, hintsEs);
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
  final String? nameDe;
  final String? nameEs;
  final String? descriptionEn;
  final String? descriptionDe;
  final String? descriptionEs;

  const LessonBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.rarity = BadgeRarity.common,
    required this.category,
    this.nameEn,
    this.nameDe,
    this.nameEs,
    this.descriptionEn,
    this.descriptionDe,
    this.descriptionEs,
  });

  String nameFor(String lang) => pickLang(name, nameEn, lang, nameDe, nameEs);
  String descriptionFor(String lang) => pickLang(description, descriptionEn, lang, descriptionDe, descriptionEs);
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
