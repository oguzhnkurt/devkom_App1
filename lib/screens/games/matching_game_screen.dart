import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_progress_service.dart';
import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import '../../widgets/learning/how_to_play_demo.dart';
import '../../utils/lang.dart';

/// Eşleştirme Oyunu (Matching Game)
/// Wordwall'daki "Match up" aktivitesine benzer, sürükle-bırak ile
/// cevapları doğru ipucuna eşleştirme oyunu. İçerik `gameData['pairs']`
/// üzerinden verilir, böylece farklı konular (Arduino, Scratch, Python vb.)
/// için tekrar tekrar kullanılabilir.
///
/// Beklenen gameData formatı (tek seviye, eski/basit kullanım):
/// {
///   'title': 'Arduino Eşleştirme',
///   'timeSeconds': 90,
///   'pairs': [
///     {'answer': 'Kütüphane Çağırma', 'prompt': '#include <Servo.h>', 'icon': 'code'},
///     {'answer': 'Servo Motor', 'prompt': 'Servo Motor', 'icon': 'servo'},
///     ...
///   ],
/// }
///
/// Çoklu seviye desteği (önerilen kullanım):
/// {
///   'title': 'Arduino Eşleştirme',
///   'levels': [
///     {'title': 'Seviye 1', 'timeSeconds': 90, 'mode': 'text', 'pairs': [...]},
///     {'title': 'Seviye 2', 'timeSeconds': 75, 'mode': 'image', 'pairs': [...]},
///   ],
/// }
/// 'mode': 'text' -> cevap çipleri metin, ipucu metin/kod.
/// 'mode': 'image' -> cevap çipleri ikon (Wordwall'daki ters/görsel eşleştirme), ipucu sabit metin etiket.
class MatchingGameScreen extends StatefulWidget {
  final Map<String, dynamic>? gameData;

  const MatchingGameScreen({super.key, this.gameData});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingPair {
  final String id;
  final String answer;
  final String? answerEn;
  final String prompt;
  final String? promptEn;
  final String iconKey;

  _MatchingPair({
    required this.id,
    required this.answer,
    this.answerEn,
    required this.prompt,
    this.promptEn,
    required this.iconKey,
  });

  String displayAnswer(bool isEn) =>
      (isEn && answerEn != null && answerEn!.isNotEmpty) ? answerEn! : answer;
  String displayPrompt(bool isEn) =>
      (isEn && promptEn != null && promptEn!.isNotEmpty) ? promptEn! : prompt;
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  late List<_MatchingPair> _pairs;
  late List<String> _pool; // answers not yet placed (shuffled)
  late Map<String, String?> _slotAnswer; // promptId -> placed answer
  late Map<String, bool?>
      _slotCorrect; // promptId -> null(unchecked)/true/false after submit

  int _totalSeconds = 90;
  int _secondsLeft = 90;
  Timer? _timer;
  bool _submitted = false;

  // Multi-level support: gameData can provide 'levels': [ {title, timeSeconds, pairs, mode}, ... ]
  // Falls back to a single level built from the flat 'pairs'/'title'/'timeSeconds' keys.
  // 'mode': 'text' (default) -> answer chips are text, prompts are text/code.
  // 'mode': 'image' -> answer chips are icons (reversed Wordwall style), prompts are text labels.
  late List<Map<String, dynamic>> _levels;
  int _levelIndex = 0;
  int _totalScore = 0;
  String _mode = 'text';

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  /// Oyun ICERIGI (kod satirlari, seviye basliklari, eslestirme ciftleri)
  /// yalnizca turkce ve ingilizce yazildi. Almanca ya da ispanyolca secen
  /// cocuga turkce icerik vermek yerine ingilizcesini veriyoruz; ceviriler
  /// gelene kadar dogru olan bu.
  bool get _isEn => _lang != 'tr';

  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  ///
  /// Onceki surumde her yerde `_isEn ? ingilizce : turkce` vardi; almanca
  /// ya da ispanyolca secen cocuk oyunun tamamini turkce goruyordu.
  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  final List<Color> _chipColors = [
    const Color(0xFF4CAF50),
    const Color(0xFF2196F3),
    const Color(0xFF9C27B0),
    const Color(0xFFFF9800),
    const Color(0xFFE53935),
    const Color(0xFF00BCD4),
    const Color(0xFF8D6E63),
    const Color(0xFF3F51B5),
  ];

  static const Map<String, IconData> _iconMap = {
    'lcd': Icons.tv_rounded,
    'servo': Icons.settings_input_component,
    'arduino': Icons.developer_board,
    'code': Icons.code_rounded,
    'pin': Icons.settings_ethernet,
    'chip': Icons.memory_rounded,
    'led': Icons.lightbulb_rounded,
    'sensor': Icons.sensors_rounded,
    'resistor': Icons.horizontal_rule,
    'ldr': Icons.wb_sunny_rounded,
    'water': Icons.water_drop_rounded,
    'scratch': Icons.extension_rounded,
    'mblock': Icons.widgets_rounded,
    'button': Icons.radio_button_checked_rounded,
    'wire': Icons.cable_rounded,
  };

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (Eslestirme). Butun oyunlarda ayni tonu
    // calmak oyunlari birbirinden ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.warm);
    _levels =
        (widget.gameData?['levels'] as List?)?.cast<Map<String, dynamic>>() ??
            [
              {
                'title': widget.gameData?['title'],
                'timeSeconds': widget.gameData?['timeSeconds'],
                'pairs': widget.gameData?['pairs'] ?? _defaultPairs,
              }
            ];
    _loadGame();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHowToPlay());
  }

  /// Ilk acilista "nasil oynanir": bir el havuzdaki cevabi alip dogru
  /// yuvaya birakiyor, yanlis yuvanin uzerinden gecip dogruya gidiyor.
  Future<void> _showHowToPlay({bool force = false}) async {
    if (!mounted) return;
    await HowToPlayDemo.maybeShow(
      context,
      gameKey: 'matching_game',
      force: force,
      demo: HowToPlayDemo(
        // Bu oyunda cevap havuzdan alinip bir YUVAYA birakiliyor;
        // iki sutun arasinda cizgi cekilmiyor.
        scene: DemoScene.dragIntoArea,
        title: _tl('Nasıl oynanır?', 'How to play', 'So wird gespielt', 'Cómo se juega'),
        hint: _tl('Havuzdaki cevabı sürükleyip ait olduğu kutuya bırak.', 'Drag an answer from the pool into the box it belongs to.', 'Zieh eine Antwort aus dem Vorrat in das passende Feld.', 'Arrastra una respuesta del grupo a la casilla que le corresponde.'),
        sourceLabel: 'LED',
        decoyLabel: _tl('Motor', 'Motor', 'Motor', 'Motor'),
        targetLabel: _tl('Işık verir', 'Gives light', 'Gibt Licht', 'Da luz'),
        startLabel: _tl('Başla', 'Start', 'Start', 'Empezar'),
        color: const Color(0xFF00897B),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadGame() {
    final level = _levels[_levelIndex];
    final rawPairs = level['pairs'] as List? ?? _defaultPairs;
    _totalSeconds = (level['timeSeconds'] as int?) ?? 90;
    _secondsLeft = _totalSeconds;
    _mode = level['mode']?.toString() ?? 'text';

    _pairs = rawPairs.asMap().entries.map((entry) {
      final map = entry.value as Map;
      return _MatchingPair(
        id: 'p${entry.key}',
        answer: map['answer']?.toString() ?? '',
        answerEn: map['answerEn']?.toString(),
        prompt: map['prompt']?.toString() ?? '',
        promptEn: map['promptEn']?.toString(),
        iconKey: map['icon']?.toString() ?? 'code',
      );
    }).toList();

    _pool = _pairs.map((p) => p.answer).toList()..shuffle();
    _slotAnswer = {for (var p in _pairs) p.id: null};
    _slotCorrect = {for (var p in _pairs) p.id: null};
    _submitted = false;
  }

  // Fallback content (Arduino/electronics) if no gameData is supplied.
  static final List<Map<String, String>> _defaultPairs = [
    {
      'answer': 'Kütüphane Çağırma',
      'answerEn': 'Library Include',
      'prompt': '#include <Servo.h>',
      'icon': 'code'
    },
    {
      'answer': 'Servo Motor',
      'answerEn': 'Servo Motor',
      'prompt': 'Servo Motor',
      'icon': 'servo'
    },
    {
      'answer': 'Lcd Ekran',
      'answerEn': 'LCD Screen',
      'prompt': 'Lcd Ekran',
      'promptEn': 'LCD Screen',
      'icon': 'lcd'
    },
    {
      'answer': 'Arduino',
      'answerEn': 'Arduino',
      'prompt': 'Arduino',
      'promptEn': 'Arduino',
      'icon': 'arduino'
    },
    {
      'answer': 'Digital Yazma',
      'answerEn': 'Digital Write',
      'prompt': 'digitalWrite(5, HIGH);',
      'icon': 'code'
    },
    {
      'answer': 'Digital Okuma',
      'answerEn': 'Digital Read',
      'prompt': 'digitalRead(5);',
      'icon': 'code'
    },
    {
      'answer': 'Input Metod',
      'answerEn': 'Input Method',
      'prompt': 'pinMode(button, INPUT);',
      'icon': 'pin'
    },
    {
      'answer': 'Mikro İşlemci',
      'answerEn': 'Microcontroller',
      'prompt': 'Arduino Uno Çipi',
      'promptEn': 'Arduino Uno Chip',
      'icon': 'chip'
    },
    {
      'answer': 'PWM Pinleri',
      'answerEn': 'PWM Pins',
      'prompt': '3, 5, 6, 9, 10, 11',
      'icon': 'pin'
    },
  ];

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          timer.cancel();
          if (!_submitted) _submitAnswers();
        }
      });
    });
  }

  void _placeAnswer(String answer, String slotId) {
    if (_submitted) return;
    setState(() {
      // If this slot already had an answer, return it to the pool first.
      final previous = _slotAnswer[slotId];
      if (previous != null) _pool.add(previous);

      _pool.remove(answer);
      _slotAnswer[slotId] = answer;
    });
    // Parca yerine oturdu: kisa bir ses + dokunsal geri bildirim. Dogru mu
    // yanlis mi oldugunu SOYLEMIYOR — kontrol en sonda, "Kontrol et" ile.
    SoundService.playDrop();
  }

  void _removeFromSlot(String slotId) {
    if (_submitted) return;
    final current = _slotAnswer[slotId];
    if (current == null) return;
    setState(() {
      _pool.add(current);
      _slotAnswer[slotId] = null;
    });
  }

  void _submitAnswers() {
    _timer?.cancel();
    int correct = 0;
    for (final pair in _pairs) {
      final placed = _slotAnswer[pair.id];
      final isCorrect = placed == pair.answer;
      _slotCorrect[pair.id] = isCorrect;
      if (isCorrect) correct++;
    }
    _totalScore += correct * 10;
    setState(() => _submitted = true);
    if (correct == _pairs.length) {
      SoundService.playLevelComplete();
    } else if (correct > 0) {
      SoundService.playCorrect();
    } else {
      SoundService.playWrong();
    }
    _awardProgress(correct);
    _showResultDialog(correct, _pairs.length);
  }

  /// Doğru eşleştirme sayısına göre kalıcı XP ve jeton kazandırır
  /// (Market'te harcanabilir). Eşleştirme skoru önceden hiç kaydedilmiyordu.
  Future<void> _awardProgress(int correct) async {
    if (correct <= 0) return;
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.currentUser?.uid;
      if (userId == null) return;
      final jeton = correct * 4;
      await auth.addXP(correct * 3);
      await UserProgressService()
          .addJeton(userId, jeton, source: 'matching_game');
      await auth.refreshProgress();
    } catch (e) {
      debugPrint('❌ Eşleştirme oyunu ödül hatası: $e');
    }
  }

  void _showResultDialog(int correct, int total) {
    final passed = correct == total;
    final hasNextLevel = _levelIndex < _levels.length - 1;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(passed
            ? (_tl('🎉 Harika, Hepsi Doğru!', '🎉 Great, All Correct!', '🎉 Super, alles richtig!', '🎉 ¡Genial, todo correcto!'))
            : (_tl('📋 Sonuçlar', '📋 Results', '📋 Ergebnisse', '📋 Resultados'))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_levels.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _tl('Seviye ${_levelIndex + 1} / ${_levels.length}', 'Level ${_levelIndex + 1} / ${_levels.length}', 'Level ${_levelIndex + 1} / ${_levels.length}', 'Nivel ${_levelIndex + 1} / ${_levels.length}'),
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600),
                ),
              ),
            Text(
              _tl('$correct / $total doğru eşleştirme', '$correct / $total correct matches', '$correct / $total richtige Zuordnungen', '$correct / $total emparejamientos correctos'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _tl('Puan: ${correct * 10}  •  Toplam: $_totalScore', 'Score: ${correct * 10}  •  Total: $_totalScore', 'Punkte: ${correct * 10}  •  Gesamt: $_totalScore', 'Puntos: ${correct * 10}  •  Total: $_totalScore'),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_tl('Çıkış', 'Exit', 'Beenden', 'Salir')),
          ),
          if (passed && hasNextLevel)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _levelIndex++;
                  _loadGame();
                  _startTimer();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: Text(_tl('Sonraki Seviye', 'Next Level', 'Nächstes Level', 'Siguiente nivel')),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _loadGame();
                  _startTimer();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              child: Text(_tl('Tekrar Oyna', 'Play Again', 'Noch mal spielen', 'Jugar otra vez')),
            ),
        ],
      ),
    );
  }

  Color _colorFor(String answer) {
    final index = _pairs.indexWhere((p) => p.answer == answer);
    return _chipColors[index % _chipColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            (_isEn ? _levels[_levelIndex]['titleEn']?.toString() : null) ??
                _levels[_levelIndex]['title']?.toString() ??
                (_isEn ? (widget.gameData?['titleEn']?.toString()) : null) ??
                widget.gameData?['title']?.toString() ??
                (_tl('Eşleştirme Oyunu', 'Matching Game', 'Zuordnungsspiel', 'Juego de emparejar'))),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.timer_rounded, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_levels.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          _tl('Seviye ${_levelIndex + 1} / ${_levels.length}', 'Level ${_levelIndex + 1} / ${_levels.length}', 'Level ${_levelIndex + 1} / ${_levels.length}', 'Nivel ${_levelIndex + 1} / ${_levels.length}'),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2196F3)),
                        ),
                      ),
                    Text(
                      _mode == 'image'
                          ? (_tl('Görselleri sürükleyip doğru etiketin yanındaki kutuya bırak, sonra "Cevapları Gönder"e bas!', 'Drag the images to the box next to the correct label, then tap "Submit Answers"!', 'Zieh die Bilder in das Feld neben der richtigen Bezeichnung und tippe dann auf "Antworten abschicken"!', 'Arrastra las imágenes a la casilla junto a la etiqueta correcta y pulsa "Enviar respuestas".'))
                          : (_tl('Cevapları sürükleyip doğru ipucunun yanındaki kutuya bırak, sonra "Cevapları Gönder"e bas!', 'Drag the answers to the box next to the correct clue, then tap "Submit Answers"!', 'Zieh die Antworten in das Feld neben dem richtigen Hinweis und tippe dann auf "Antworten abschicken"!', 'Arrastra las respuestas a la casilla junto a la pista correcta y pulsa "Enviar respuestas".')),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Answer pool (draggable chips)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _pool
                      .map((answer) => _buildDraggableChip(answer))
                      .toList(),
                ),
              ),
              const Divider(height: 1),

              // Prompt rows with drop slots
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _pairs.length,
                  itemBuilder: (context, index) =>
                      _buildPromptRow(_pairs[index]),
                ),
              ),

              // Submit button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitted ? null : _submitAnswers,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: Text(_tl('Cevapları Gönder', 'Submit Answers', 'Antworten abschicken', 'Enviar respuestas')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildDraggableChip(String answer) {
    final color = _colorFor(answer);
    Widget chip;
    if (_mode == 'image') {
      final pair = _pairs.firstWhere((p) => p.answer == answer,
          orElse: () => _pairs.first);
      final icon = _iconMap[pair.iconKey] ?? Icons.image_rounded;
      chip = Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      );
    } else {
      chip = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Text(
          _pairs
              .firstWhere((p) => p.answer == answer, orElse: () => _pairs.first)
              .displayAnswer(_isEn),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      );
    }

    return Draggable<String>(
      data: answer,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.85, child: chip),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: chip,
    );
  }

  Widget _buildPromptRow(_MatchingPair pair) {
    final placed = _slotAnswer[pair.id];
    final correctness = _slotCorrect[pair.id];
    // In image mode, pair.iconKey belongs to the ANSWER (draggable chip) — showing it
    // here next to the prompt would give the answer away, so use a neutral icon instead.
    final icon = _mode == 'image'
        ? Icons.help_outline_rounded
        : (_iconMap[pair.iconKey] ?? Icons.text_snippet_rounded);

    Color slotColor = Colors.grey.shade100;
    Color slotBorder = Colors.grey.shade300;
    if (_submitted && correctness != null) {
      slotColor = correctness ? Colors.green.shade50 : Colors.red.shade50;
      slotBorder = correctness ? Colors.green : Colors.red;
    } else if (placed != null) {
      slotColor = _colorFor(placed).withValues(alpha: 0.12);
      slotBorder = _colorFor(placed);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2196F3), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              pair.displayPrompt(_isEn),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: DragTarget<String>(
              onWillAcceptWithDetails: (details) => !_submitted,
              onAcceptWithDetails: (details) =>
                  _placeAnswer(details.data, pair.id),
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onTap: placed != null ? () => _removeFromSlot(pair.id) : null,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: candidateData.isNotEmpty
                          ? Colors.blue.shade100
                          : slotColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: slotBorder, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: placed == null
                        ? Icon(Icons.add_rounded,
                            color: Colors.grey.shade400, size: 18)
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_mode == 'image')
                                  Icon(
                                    _iconMap[_pairs
                                            .firstWhere(
                                                (p) => p.answer == placed,
                                                orElse: () => _pairs.first)
                                            .iconKey] ??
                                        Icons.image_rounded,
                                    size: 22,
                                    color: const Color(0xFF2196F3),
                                  )
                                else
                                  Flexible(
                                    child: Text(
                                      _pairs
                                          .firstWhere((p) => p.answer == placed,
                                              orElse: () => _pairs.first)
                                          .displayAnswer(_isEn),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                if (_submitted && correctness != null)
                                  Icon(
                                    correctness
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color:
                                        correctness ? Colors.green : Colors.red,
                                    size: 16,
                                  ),
                              ],
                            ),
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
}
