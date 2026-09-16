import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/settings_provider.dart';
import '../../../services/sound_service.dart';
import '../../../utils/lang.dart';
import '../../models/course_model.dart';
import '../../models/interactive_lesson_model.dart';

// ==========================================
// BLOK YAKALA
// ==========================================
//
// Oyun "dusen blogu dogru kategoriye gonder" oyunu. Iki seyi BILEREK
// yapmiyor:
//
//  1. Dusen blok RENKSIZ. Once blogun rengi Hareket mavisi ya da
//     Gorunum moruydu; alttaki iki buton da ayni renklerdeydi. Boyle
//     olunca oyun "blogu oku, ne yaptigini dusun" oyunu olmaktan cikip
//     "ayni rengi bul" oyununa donuyordu — cocuk bloga bakmadan
//     kazanabiliyordu. Renk, cevap VERILDIKTEN sonra kisa bir an
//     gosteriliyor: boylece renk hala ogretiliyor ama cevabi ele
//     vermiyor.
//
//  2. Blok yazilari UYDURULMADI. Hepsi Scratch 3.0'in kendi dil
//     dosyasindan (scratch-blocks `msg/scratch_msgs.js`) birebir
//     alindi ve dort dile de oradan yazildi. Cocuk Scratch'i actiginda
//     burada gordugu yaziyi aynen bulmali.

/// Oyunda dusebilecek bir Scratch blogu.
class _BlockDef {
  const _BlockDef({
    required this.type,
    required this.tr,
    required this.en,
    required this.de,
    required this.es,
  });

  /// 'motion' ya da 'looks'.
  final String type;
  final String tr;
  final String en;
  final String de;
  final String es;

  String labelFor(String lang) => AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
}

/// Havuz. Scratch'in kendi cevirilerinden; %1/%2 yuvalarina Scratch'in
/// varsayilan degerleri yazildi (10 adim, 15 derece, x:0 y:0 ...).
const List<_BlockDef> _blockPool = [
  // --- Hareket ---
  _BlockDef(
    type: 'motion',
    tr: '10 adım git',
    en: 'move 10 steps',
    de: 'gehe 10 er Schritt',
    es: 'mover 10 pasos',
  ),
  _BlockDef(
    type: 'motion',
    tr: '↻ 15 derece dön',
    en: 'turn ↻ 15 degrees',
    de: 'drehe dich ↻ um 15 Grad',
    es: 'girar ↻ 15 grados',
  ),
  _BlockDef(
    type: 'motion',
    tr: 'x: 0 y: 0 konumuna git',
    en: 'go to x: 0 y: 0',
    de: 'gehe zu x: 0 y: 0',
    es: 'ir a x: 0 y: 0',
  ),
  _BlockDef(
    type: 'motion',
    tr: 'x konumunu 10 değiştir',
    en: 'change x by 10',
    de: 'ändere x um 10',
    es: 'sumar a x 10',
  ),
  _BlockDef(
    type: 'motion',
    tr: 'y konumunu 10 değiştir',
    en: 'change y by 10',
    de: 'ändere y um 10',
    es: 'sumar a y 10',
  ),
  _BlockDef(
    type: 'motion',
    tr: 'kenara geldiyse sek',
    en: 'if on edge, bounce',
    de: 'pralle vom Rand ab',
    es: 'si toca un borde, rebotar',
  ),
  _BlockDef(
    type: 'motion',
    tr: '90 yönüne dön',
    en: 'point in direction 90',
    de: 'setze Richtung auf 90 Grad',
    es: 'apuntar en dirección 90',
  ),

  // --- Gorunum ---
  _BlockDef(
    type: 'looks',
    tr: '2 saniye boyunca Merhaba! de',
    en: 'say Hello! for 2 seconds',
    de: 'sage Hallo! für 2 Sekunden',
    es: 'decir ¡Hola! durante 2 segundos',
  ),
  _BlockDef(
    type: 'looks',
    tr: 'Merhaba! de',
    en: 'say Hello!',
    de: 'sage Hallo!',
    es: 'decir ¡Hola!',
  ),
  _BlockDef(
    type: 'looks',
    tr: 'Hmm... diye düşün',
    en: 'think Hmm...',
    de: 'denke Hmm...',
    es: 'pensar Hmm...',
  ),
  _BlockDef(
    type: 'looks',
    tr: 'göster',
    en: 'show',
    de: 'zeige dich',
    es: 'mostrar',
  ),
  _BlockDef(
    type: 'looks',
    tr: 'gizle',
    en: 'hide',
    de: 'verstecke dich',
    es: 'esconder',
  ),
  _BlockDef(
    type: 'looks',
    tr: 'boyutu 10 birim değiştir',
    en: 'change size by 10',
    de: 'ändere Größe um 10',
    es: 'cambiar tamaño por 10',
  ),
  _BlockDef(
    type: 'looks',
    tr: 'sonraki kostüm',
    en: 'next costume',
    de: 'wechsle zum nächsten Kostüm',
    es: 'siguiente disfraz',
  ),
];

class CatchBlockGame extends StatefulWidget {
  final MiniGameStep step;
  final Course course;
  final bool isDark;
  final Function(int score) onComplete;

  const CatchBlockGame({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  @override
  State<CatchBlockGame> createState() => _CatchBlockGameState();
}

class _CatchBlockGameState extends State<CatchBlockGame>
    with TickerProviderStateMixin {
  int _score = 0;
  int _timeLeft = 30;
  bool _gameOver = false;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  final List<_FallingBlock> _blocks = [];
  final FocusNode _focusNode = FocusNode();
  final Random _random = Random();

  /// Torba: havuz karistirilip sirayla tuketiliyor, bitince yeniden
  /// karistiriliyor. `nextBool()` ile secseydik ayni blok ust uste
  /// gelebilirdi — sikayetin sebebi tam olarak buydu.
  final List<_BlockDef> _bag = [];

  /// Scratch'in gercek kategori renkleri. Yalnizca BUTONLARDA ve cevap
  /// verildikten sonraki kisa aciklamada kullaniliyor; dusen blokta
  /// kullanilmiyor (bkz. dosya basindaki not).
  static const Color _motionColor = Color(0xFF4C97FF);
  static const Color _looksColor = Color(0xFF9966FF);

  /// Blogun dusme suresi. `gameConfig['speed']` ile ayarlanabiliyor.
  Duration get _fallDuration {
    switch (widget.step.gameConfig['speed'] as String?) {
      case 'fast':
        return const Duration(milliseconds: 2200);
      case 'slow':
        return const Duration(milliseconds: 4500);
      default:
        return const Duration(milliseconds: 3200);
    }
  }

  @override
  void initState() {
    super.initState();
    // Blok kodlama oyunlarinin ses rengi.
    SoundService.useVoice(SfxVoice.deep);
    _startGame();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    for (final block in _blocks) {
      block.controller.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    _timeLeft = widget.step.gameConfig['duration'] as int? ?? 30;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) _endGame();
      });
    });

    _spawnTimer = Timer.periodic(
      const Duration(milliseconds: 1700),
      (_) => _spawnBlock(),
    );

    _spawnBlock();
  }

  _BlockDef _nextDef() {
    if (_bag.isEmpty) {
      _bag.addAll(_blockPool);
      _bag.shuffle(_random);
    }
    return _bag.removeLast();
  }

  void _spawnBlock() {
    if (_gameOver || !mounted || _blocks.length >= 4) return;

    final controller = AnimationController(duration: _fallDuration, vsync: this);
    final block = _FallingBlock(
      def: _nextDef(),
      left: _random.nextDouble() * 0.55 + 0.05,
      controller: controller,
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Blok yere degdi, kaciridik.
        setState(() => _blocks.remove(block));
        controller.dispose();
      }
    });
    controller.forward();

    setState(() => _blocks.add(block));
  }

  /// Butona basildiginda en alttaki (butona en yakin) blok degerlendirilir.
  void _categorize(String category) {
    _FallingBlock? bottom;
    var maxValue = -1.0;
    for (final block in _blocks) {
      if (block.resolvedCorrect != null) continue; // zaten cevaplandi
      if (block.controller.value > maxValue) {
        maxValue = block.controller.value;
        bottom = block;
      }
    }
    if (bottom == null) return;

    final block = bottom;
    final isCorrect = block.def.type == category;

    // Blok, cevaptan sonra kisa bir an gercek kategori rengine boyanip
    // ekranda kaliyor: cocuk "demek ki bu mavi bir blokmus" diyor.
    // Renk cevabi ele vermiyor cunku karar zaten verildi.
    block.controller.stop();
    setState(() {
      block.resolvedCorrect = isCorrect;
      if (isCorrect) {
        _score += 10;
      } else {
        _score = (_score - 5).clamp(0, 999999);
      }
    });

    if (isCorrect) {
      SoundService.playCorrect();
    } else {
      SoundService.playWrong();
    }

    Timer(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      setState(() => _blocks.remove(block));
      block.controller.dispose();
    });
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      _categorize('motion');
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      _categorize('looks');
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _gameOver = true;

    final basarili = _score >= widget.step.targetScore;
    if (basarili) {
      SoundService.playLevelComplete();
    } else {
      SoundService.playGameOver();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onComplete(_score);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().locale.languageCode;

    if (_gameOver) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              AppLang.pick(lang,
                  tr: 'Oyun Bitti!',
                  en: 'Game Over!',
                  de: 'Spiel vorbei!',
                  es: '¡Fin del juego!'),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${AppLang.pick(lang, tr: 'Puanın', en: 'Your score', de: 'Deine Punkte', es: 'Tu puntuación')}: $_score',
              style: TextStyle(
                fontSize: 24,
                color: widget.course.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _score >= widget.step.targetScore
                  ? AppLang.pick(lang,
                      tr: 'Harika! Hedefi geçtin! 🎯',
                      en: 'Great! You beat the target! 🎯',
                      de: 'Super! Du hast das Ziel geschafft! 🎯',
                      es: '¡Genial! ¡Superaste el objetivo! 🎯')
                  : AppLang.pick(lang,
                      tr: 'İyi deneme! Tekrar dene! 💪',
                      en: 'Good try! Give it another go! 💪',
                      de: 'Guter Versuch! Probier es noch mal! 💪',
                      es: '¡Buen intento! ¡Prueba otra vez! 💪'),
              style: TextStyle(
                fontSize: 16,
                color:
                    widget.isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Puan ve sure
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.course.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '$_score',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '$_timeLeft',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _timeLeft <= 10
                            ? Colors.red
                            : (widget.isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Oyun alani
          SizedBox(
            height: 400,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color:
                    widget.isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: _blocks.map((block) {
                      return AnimatedBuilder(
                        animation: block.controller,
                        builder: (context, child) {
                          return Positioned(
                            left: constraints.maxWidth * block.left,
                            top: (constraints.maxHeight - 56) *
                                block.controller.value,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.9,
                              ),
                              child: _BlockWidget(
                                block: block,
                                lang: lang,
                                isDark: widget.isDark,
                                categoryColor: block.def.type == 'motion'
                                    ? _motionColor
                                    : _looksColor,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            AppLang.pick(lang,
                tr: 'Bloğu oku, ne yaptığını düşün, doğru butona dokun.',
                en: 'Read the block, think what it does, tap the right button.',
                de: 'Lies den Block, überlege, was er tut, und tippe auf den richtigen Knopf.',
                es: 'Lee el bloque, piensa qué hace y toca el botón correcto.'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.course.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Kategori butonlari. Renkler BURADA duruyor: Scratch'te
          // Hareket mavi, Gorunum mor — cocuk bunu ogrenmeli. Dusen
          // blokta renk olmadigi icin cevabi ele vermiyorlar.
          Row(
            children: [
              Expanded(
                child: _CategoryButton(
                  label: AppLang.pick(lang,
                      tr: 'Hareket',
                      en: 'Motion',
                      de: 'Bewegung',
                      es: 'Movimiento'),
                  emoji: '🏃',
                  color: _motionColor,
                  isDark: widget.isDark,
                  onPressed: () => _categorize('motion'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CategoryButton(
                  label: AppLang.pick(lang,
                      tr: 'Görünüm',
                      en: 'Looks',
                      de: 'Aussehen',
                      es: 'Apariencia'),
                  emoji: '👀',
                  color: _looksColor,
                  isDark: widget.isDark,
                  onPressed: () => _categorize('looks'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FallingBlock {
  _FallingBlock({
    required this.def,
    required this.left,
    required this.controller,
  });

  final _BlockDef def;
  final double left;
  final AnimationController controller;

  /// null: henuz cevaplanmadi. Cevaplandiktan sonra blok kisa bir sure
  /// gercek kategori renginde ekranda kaliyor.
  bool? resolvedCorrect;
}

class _BlockWidget extends StatelessWidget {
  const _BlockWidget({
    required this.block,
    required this.lang,
    required this.isDark,
    required this.categoryColor,
  });

  final _FallingBlock block;
  final String lang;
  final bool isDark;
  final Color categoryColor;

  @override
  Widget build(BuildContext context) {
    final cevaplandi = block.resolvedCorrect != null;

    // Cevap verilene kadar blok NOTR: kategori rengi yok ki oyun
    // "rengi eslestir" oyununa donmesin.
    final arka = cevaplandi
        ? categoryColor
        : (isDark ? const Color(0xFF3A3F47) : Colors.white);
    final cerceve = cevaplandi
        ? categoryColor
        : (isDark ? const Color(0xFF5A626D) : const Color(0xFFBFC6CF));
    final yazi = cevaplandi
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1A1A1A));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: arka,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cerceve, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              block.def.labelFor(lang),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: yazi,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (cevaplandi) ...[
            const SizedBox(width: 6),
            Text(
              block.resolvedCorrect! ? '✓' : '✗',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isDark,
    required this.onPressed,
  });

  final String label;
  final String emoji;
  final Color color;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
