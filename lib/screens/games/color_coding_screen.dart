import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../utils/score_calculator.dart';
import '../../services/sound_service.dart';
import '../../providers/settings_provider.dart';
import '../../utils/lang.dart';
import '../../ui/motion.dart';

/// Renkli Kodlar Oyunu
/// Renk kodları ile programlama öğretir
///
class ColorCodingScreen extends StatefulWidget {
  const ColorCodingScreen({super.key});

  @override
  State<ColorCodingScreen> createState() => _ColorCodingScreenState();
}

class _ColorCodingScreenState extends State<ColorCodingScreen> {
  final Random _random = Random();

  int currentLevel = 1;
  int score = 0;
  List<String> targetSequence = [];
  List<String> selectedSequence = [];
  bool isPracticeMode = false; // Pratik modu
  bool isShowingSequence = false; // Dizi gösterilme durumu
  int currentShowingIndex = 0; // Şu an gösterilen renk index'i

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  ///
  /// Onceki surumde her yerde `_isEn ? ingilizce : turkce` vardi; almanca
  /// ya da ispanyolca secen cocuk oyunun tamamini turkce goruyordu.
  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  // Renk-Komut mapping
  Map<String, Map<String, dynamic>> get colorCommands {
    // Seviye 10'dan sonra 5. renk (turuncu) ekle
    // Seviye 15'ten sonra 6. renk (mor) ekle
    final baseColors = {
      'red': {
        'name': _tl('İleri Git', 'Move Forward', 'Vorwärts gehen', 'Avanzar'),
        'icon': Icons.arrow_upward_rounded,
        'color': Colors.red
      },
      'blue': {
        'name': _tl('Sağa Dön', 'Turn Right', 'Nach rechts drehen', 'Girar a la derecha'),
        'icon': Icons.arrow_forward_rounded,
        'color': Colors.blue
      },
      'green': {
        'name': _tl('Sola Dön', 'Turn Left', 'Nach links drehen', 'Girar a la izquierda'),
        'icon': Icons.arrow_back_rounded,
        'color': Colors.green
      },
      'yellow': {
        'name': _tl('Topla', 'Collect', 'Einsammeln', 'Recoger'),
        'icon': Icons.star_rounded,
        'color': Colors.amber
      },
    };

    if (currentLevel >= 15) {
      baseColors['orange'] = {
        'name': _tl('Zıpla', 'Jump', 'Springen', 'Saltar'),
        'icon': Icons.trending_up_rounded,
        'color': Colors.orange
      };
      baseColors['purple'] = {
        'name': _tl('Bekle', 'Wait', 'Warten', 'Esperar'),
        'icon': Icons.pause_rounded,
        'color': Colors.purple
      };
    } else if (currentLevel >= 10) {
      baseColors['orange'] = {
        'name': _tl('Zıpla', 'Jump', 'Springen', 'Saltar'),
        'icon': Icons.trending_up_rounded,
        'color': Colors.orange
      };
    }

    return baseColors;
  }

  // Seviye bazlı hız faktörü (ms cinsinden)
  int get displaySpeed {
    if (isPracticeMode) return 1500; // Pratik modda sabit ve yavaş
    // Seviye 1-3: 1500ms, Seviye 4-6: 1200ms, Seviye 7-9: 1000ms, Seviye 10+: 800ms
    if (currentLevel <= 3) return 1500;
    if (currentLevel <= 6) return 1200;
    if (currentLevel <= 9) return 1000;
    return 800;
  }

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (Renk). Butun oyunlarda ayni tonu
    // calmak oyunlari birbirinden ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.soft);
    _generateLevel();
  }

  void _generateLevel() {
    setState(() {
      targetSequence.clear();
      selectedSequence.clear();
      isShowingSequence = false;
      currentShowingIndex = 0;

      // Seviye arttıkça daha uzun diziler
      int sequenceLength = 3 + (currentLevel ~/ 2);
      if (sequenceLength > 12) sequenceLength = 12; // Maksimum 12'ye çıkarıldı

      for (int i = 0; i < sequenceLength; i++) {
        final colors = colorCommands.keys.toList();
        targetSequence.add(colors[_random.nextInt(colors.length)]);
      }
    });

    // Diziyi otomatik olarak göster
    _showSequenceAnimation();
  }

  // Renk dizisini animasyonlu göster
  Future<void> _showSequenceAnimation() async {
    setState(() {
      isShowingSequence = true;
      currentShowingIndex = -1;
    });

    for (int i = 0; i < targetSequence.length; i++) {
      await Future.delayed(Duration(milliseconds: displaySpeed ~/ 2));
      if (!mounted) return;
      setState(() {
        currentShowingIndex = i;
      });
      await Future.delayed(Duration(milliseconds: displaySpeed ~/ 2));
    }

    if (!mounted) return;
    setState(() {
      isShowingSequence = false;
      currentShowingIndex = -1;
    });
  }

  void _selectColor(String color) {
    if (isShowingSequence) return; // Gösterim sırasında tıklamayı engelle

    if (selectedSequence.length < targetSequence.length) {
      // Tıklama sesi
      SoundService.playClick();

      setState(() {
        selectedSequence.add(color);
      });

      // Tüm dizilim tamamlandıysa kontrol et
      if (selectedSequence.length == targetSequence.length) {
        _checkAnswer();
      }
    }
  }

  void _checkAnswer() {
    bool isCorrect = true;
    for (int i = 0; i < targetSequence.length; i++) {
      if (targetSequence[i] != selectedSequence[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      // Doğru cevap sesi
      SoundService.playCorrect();

      int levelScore = 0;

      if (!isPracticeMode) {
        // Standardize edilmiş skor hesapla
        levelScore = ScoreCalculator.calculateColorCodingScore(
          level: currentLevel,
          sequenceLength: targetSequence.length,
          isPracticeMode: false,
        );

        setState(() {
          score += levelScore;
          currentLevel++;
        });

        // Skor kazanma sesi
        SoundService.playScore();
      }

      _showMessage(
        isPracticeMode
            ? (_tl('Harika! Doğru! 🎉', 'Great! Correct! 🎉', 'Super! Richtig! 🎉', '¡Genial! ¡Correcto! 🎉'))
            : (_tl('Harika! +$levelScore puan! 🎉', 'Great! +$levelScore points! 🎉', 'Super! +$levelScore Punkte! 🎉', '¡Genial! ¡+$levelScore puntos! 🎉')),
        AppTheme.successGreen,
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _generateLevel();
      });
    } else {
      // Yanlış cevap sesi
      SoundService.playWrong();
      _showMessage(
          _tl('Yanlış sıralama. Tekrar dene!', 'Wrong order. Try again!', 'Falsche Reihenfolge. Versuch es noch mal!', 'Orden incorrecto. ¡Inténtalo otra vez!'),
          AppTheme.errorRed);
      setState(() {
        selectedSequence.clear();
      });
    }
  }

  void _togglePracticeMode() {
    setState(() {
      isPracticeMode = !isPracticeMode;
      currentLevel = 1;
      score = 0;
      _generateLevel();
    });
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isPracticeMode
            ? (_tl('Renkli Kodlar (Pratik)', 'Color Codes (Practice)', 'Farbcodes (Übung)', 'Códigos de colores (práctica)'))
            : (_tl('Renkli Kodlar', 'Color Codes', 'Farbcodes', 'Códigos de colores'))),
        actions: [
          // Pratik Modu Toggle
          IconButton(
            icon: Icon(
              isPracticeMode
                  ? Icons.school_rounded
                  : Icons.emoji_events_rounded,
              color: isPracticeMode ? Colors.blue : AppTheme.warningOrange,
            ),
            onPressed: _togglePracticeMode,
            tooltip: isPracticeMode
                ? (_tl('Yarışma Moduna Geç', 'Switch to Competition Mode', 'In den Wettkampfmodus wechseln', 'Cambiar al modo competición'))
                : (_tl('Pratik Moduna Geç', 'Switch to Practice Mode', 'In den Übungsmodus wechseln', 'Cambiar al modo práctica')),
          ),
          if (!isPracticeMode)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppTheme.warningOrange),
                    const SizedBox(width: 4),
                    Text(
                      _tl('Skor: $score', 'Score: $score', 'Punkte: $score', 'Puntos: $score'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Level bilgisi
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          _tl('Seviye $currentLevel', 'Level $currentLevel', 'Level $currentLevel', 'Nivel $currentLevel'),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _tl('Hedef Renk Dizilimini Hatırla:', 'Remember the Target Color Sequence:', 'Merk dir die Zielfarbfolge:', 'Recuerda la secuencia de colores:'),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        // Hedef renk dizilimi - animasyonlu gösterim
                        // Sadece o an sırası gelen renk kısaca açığa çıkar, geri kalanı
                        // gizli kalır ki öğrenci diziyi ezberlemeye çalışsın (Simon Says mantığı).
                        Wrap(
                          spacing: 8,
                          children: targetSequence.asMap().entries.map((entry) {
                            final index = entry.key;
                            final color = entry.value;
                            final cmd = colorCommands[color]!;
                            final isHighlighted = isShowingSequence &&
                                currentShowingIndex == index;

                            // Dizinin sirayla yanmasi oyunun MEKANIGI
                            // (Simon Says); `displaySpeed` hareket azaltma
                            // ayarinda bile kisaltilmaz, yoksa oyun
                            // oynanamaz hale gelir. Kisaltilan tek sey
                            // rengin yanip sonme gecisi: hareket
                            // duyarliligi olan cocukta bu gecis anlik olur,
                            // sinyal yine gorunur.
                            return AnimatedContainer(
                              duration:
                                  Motion.adapt(context, Motion.short4),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isHighlighted
                                    ? cmd['color']
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                                boxShadow: isHighlighted
                                    ? [
                                        BoxShadow(
                                          color: (cmd['color'] as Color)
                                              .withValues(alpha: 0.8),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ]
                                    : null,
                              ),
                              transform: isHighlighted
                                  ? (Matrix4.identity()..scale(1.2))
                                  : Matrix4.identity(),
                              child: isHighlighted
                                  ? Icon(
                                      cmd['icon'],
                                      color: Colors.white,
                                      size: 32,
                                    )
                                  : Icon(
                                      Icons.question_mark_rounded,
                                      color: Colors.grey.shade500,
                                      size: 20,
                                    ),
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            isShowingSequence
                                ? (_tl('Dikkatle izle...', 'Watch closely...', 'Genau hinschauen ...', 'Observa con atención...'))
                                : (_tl('Diziyi aklında tutmaya çalış!', 'Try to remember the sequence!', 'Versuch dir die Folge zu merken!', '¡Intenta memorizar la secuencia!')),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Seçilen dizilim
                Card(
                  color: AppTheme.lightBlue.withValues(alpha: 0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          _tl('Senin Seçimin:', 'Your Selection:', 'Deine Auswahl:', 'Tu selección:'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // SABIT 60 PIKSEL TASIYORDU.
                        //
                        // Secilen renkler bir Wrap icinde 50x50 daireler
                        // olarak diziliyor. Dizi 12 adima ciktiginda (10.
                        // seviyeden sonra) dar telefonda uc satira
                        // sariyor, ama kutunun yuksekligi 60 piksele
                        // sabitlenmisti: cocuk kendi sectigi renklerin
                        // yarisini goremiyordu. Artik 60 en AZ deger.
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 60),
                          child: selectedSequence.isEmpty
                              ? Center(
                                  child: Text(
                                    _tl('Renkleri sırayla seç', 'Select the colors in order', 'Wähle die Farben der Reihe nach', 'Selecciona los colores en orden'),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  children: selectedSequence.map((color) {
                                    final cmd = colorCommands[color]!;
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: cmd['color'],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(cmd['icon'],
                                          color: Colors.white),
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Renk butonları
                Text(
                  isShowingSequence
                      ? (_tl('Dikkatle İzle...', 'Watch Closely...', 'Genau hinschauen ...', 'Observa con atención...'))
                      : (_tl('Renkleri Seç:', 'Select the Colors:', 'Farben auswählen:', 'Selecciona los colores:')),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isShowingSequence ? Colors.grey : null,
                  ),
                ),
                const SizedBox(height: 16),
                Opacity(
                  opacity: isShowingSequence ? 0.5 : 1.0,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: colorCommands.entries.map((entry) {
                      final color = entry.key;
                      final cmd = entry.value;
                      return GestureDetector(
                        onTap: () => _selectColor(color),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: cmd['color'],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (cmd['color'] as Color)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(cmd['icon'],
                                  color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cmd['name'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Butonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tekrar Göster butonu
                    if (!isShowingSequence)
                      ElevatedButton.icon(
                        onPressed: _showSequenceAnimation,
                        icon: const Icon(Icons.replay_rounded),
                        label: Text(_tl('Tekrar Göster', 'Show Again', 'Noch mal zeigen', 'Mostrar otra vez')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    if (!isShowingSequence && selectedSequence.isNotEmpty)
                      const SizedBox(width: 12),
                    // Temizle butonu
                    if (selectedSequence.isNotEmpty && !isShowingSequence)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedSequence.clear();
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(_tl('Temizle', 'Clear', 'Löschen', 'Borrar')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
