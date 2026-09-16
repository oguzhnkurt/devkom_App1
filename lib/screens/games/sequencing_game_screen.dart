import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../auth/login_screen.dart';
import '../../providers/settings_provider.dart';
import '../../theme.dart';
import '../../ui/answer_feedback.dart';
import '../../ui/count_up.dart';
import '../../ui/press_button.dart';
import '../../services/sound_service.dart';
import '../../widgets/learning/how_to_play_demo.dart';
import '../../widgets/learning/token_sequence_builder.dart';
import '../../utils/lang.dart';

class SequencingGameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const SequencingGameScreen({
    super.key,
    required this.gameData,
  });

  @override
  State<SequencingGameScreen> createState() => _SequencingGameScreenState();
}

class _SequencingGameScreenState extends State<SequencingGameScreen> {
  int _currentLevel = 0;
  List<Map<String, dynamic>> _levels = [];
  final List<String> _userSequence = [];
  List<String> _correctSequence = [];
  List<Map<String, dynamic>> _shuffledCommands = [];
  bool _isChecking = false;
  int _score = 0;

  /// Cevap kontrol edildikten sonra alt seritte gosterilen sonuc.
  /// null ise serit ekranda degil.
  AnswerResult? _feedback;
  String? _feedbackDetail;

  /// Her yanlis cevapta artiyor; siralama alanini sallamak icin tetikleyici.
  int _wrongTick = 0;

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

  String _levelTitle(Map<String, dynamic> level) {
    if (_isEn && level['titleEn'] != null) return level['titleEn'];
    return level['title'];
  }

  String _levelDescription(Map<String, dynamic> level) {
    if (_isEn && level['descriptionEn'] != null) return level['descriptionEn'];
    return level['description'];
  }

  String _cmdLabel(Map<String, dynamic> cmd) {
    if (_isEn && cmd['labelEn'] != null) return cmd['labelEn'];
    return cmd['label'];
  }

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (Siralama). Butun oyunlarda ayni tonu
    // calmak oyunlari birbirinden ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.warm);
    _loadLevels();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHowToPlay());
  }

  /// Ilk acilista "nasil oynanir" gosterimi: bir el komutu alip dogru
  /// siradaki yuvaya birakiyor. Sirali komut kurmayi bir cumleyle
  /// anlatmak zor; hareketle anlatmak kolay.
  Future<void> _showHowToPlay({bool force = false}) async {
    if (!mounted) return;
    await HowToPlayDemo.maybeShow(
      context,
      gameKey: 'sequencing',
      force: force,
      demo: HowToPlayDemo(
        // Bu oyunda iki sutun arasinda eslestirme yok; komutlara DOGRU
        // SIRAYLA dokunuluyor. Gosterim de tam olarak onu yapiyor:
        // el uc komuta sirayla dokunuyor, her biri numarasini aliyor.
        scene: DemoScene.tapInOrder,
        title: _tl('Nasıl oynanır?', 'How to play', 'So wird gespielt', 'Cómo se juega'),
        hint: _tl('Komutlara doğru sırayla dokun. Sürükleyerek yerlerini '
                'değiştirebilirsin.', 'Tap the commands in the right order. Drag to swap them.', 'Tippe die Befehle in der richtigen Reihenfolge an. Zum Tauschen kannst du sie ziehen.', 'Toca los comandos en el orden correcto. Arrástralos para cambiarlos de sitio.'),
        sourceLabel: _tl('İleri git', 'Move', 'Vorwärts', 'Avanzar'),
        decoyLabel: _tl('Sağa dön', 'Turn', 'Drehen', 'Girar'),
        extraLabel: _tl('Dur', 'Stop', 'Stopp', 'Detener'),
        targetLabel: _tl('Dur', 'Stop', 'Stopp', 'Detener'),
        startLabel: _tl('Başla', 'Start', 'Start', 'Empezar'),
        color: const Color(0xFF7E57C2),
      ),
    );
  }

  void _loadLevels() {
    final levelsData = widget.gameData['levels'];
    if (levelsData is List) {
      _levels = List<Map<String, dynamic>>.from(levelsData);
    } else {
      _levels = _getDefaultLevels();
    }
    _loadLevel(_currentLevel);
  }

  List<Map<String, dynamic>> _getDefaultLevels() {
    return [
      {
        'title': 'Sabah Rutini',
        'titleEn': 'Morning Routine',
        'description': 'Sabah rutinini doğru sıraya koy',
        'descriptionEn': 'Put the morning routine in the right order',
        'commands': [
          {
            'id': 'wake',
            'label': 'Uyan',
            'labelEn': 'Wake Up',
            'icon': 'alarm'
          },
          {
            'id': 'wash',
            'label': 'Yüzünü Yıka',
            'labelEn': 'Wash Your Face',
            'icon': 'wash'
          },
          {
            'id': 'dress',
            'label': 'Giyim',
            'labelEn': 'Get Dressed',
            'icon': 'checkroom'
          },
          {
            'id': 'breakfast',
            'label': 'Kahvaltı Yap',
            'labelEn': 'Have Breakfast',
            'icon': 'breakfast_dining'
          },
          {
            'id': 'school',
            'label': 'Okula Git',
            'labelEn': 'Go to School',
            'icon': 'school'
          },
        ],
        'correctOrder': ['wake', 'wash', 'dress', 'breakfast', 'school'],
        'hasRobotMap': false,
      },
      {
        'title': 'Robot Hareketi - Seviye 1',
        'titleEn': 'Robot Movement - Level 1',
        'description': 'Robotu hedefe ulaştırmak için komutları sırala',
        'descriptionEn': 'Order the commands to get the robot to the goal',
        'commands': [
          {
            'id': 'start',
            'label': 'Başla',
            'labelEn': 'Start',
            'icon': 'play_arrow'
          },
          {
            'id': 'forward',
            'label': 'İleri Git',
            'labelEn': 'Move Forward',
            'icon': 'arrow_upward'
          },
          {
            'id': 'turn',
            'label': 'Sola Dön',
            'labelEn': 'Turn Left',
            'icon': 'turn_left'
          },
          {
            'id': 'forward2',
            'label': 'İleri Git',
            'labelEn': 'Move Forward',
            'icon': 'arrow_upward'
          },
          {'id': 'stop', 'label': 'Dur', 'labelEn': 'Stop', 'icon': 'stop'},
        ],
        'correctOrder': ['start', 'forward', 'turn', 'forward2', 'stop'],
        'hasRobotMap': true,
        'robotStartX': 0,
        'robotStartY': 0,
        'robotStartDirection': 'down',
        'goalX': 1,
        'goalY': 1,
        'obstacles': [],
        'mapSize': 3,
      },
      {
        'title': 'Robot Hareketi - Seviye 2',
        'titleEn': 'Robot Movement - Level 2',
        'description': 'Robotu engelleri aşarak hedefe götür',
        'descriptionEn': 'Get the robot past the obstacles to the goal',
        'commands': [
          {
            'id': 'start',
            'label': 'Başla',
            'labelEn': 'Start',
            'icon': 'play_arrow'
          },
          {
            'id': 'forward1',
            'label': 'İleri Git',
            'labelEn': 'Move Forward',
            'icon': 'arrow_upward'
          },
          {
            'id': 'turn_right',
            'label': 'Sağa Dön',
            'labelEn': 'Turn Right',
            'icon': 'turn_right'
          },
          {
            'id': 'forward2',
            'label': 'İleri Git',
            'labelEn': 'Move Forward',
            'icon': 'arrow_upward'
          },
          {
            'id': 'forward3',
            'label': 'İleri Git',
            'labelEn': 'Move Forward',
            'icon': 'arrow_upward'
          },
          {
            'id': 'forward4',
            'label': 'İleri Git',
            'labelEn': 'Move Forward',
            'icon': 'arrow_upward'
          },
          {'id': 'stop', 'label': 'Dur', 'labelEn': 'Stop', 'icon': 'stop'},
        ],
        'correctOrder': [
          'start',
          'forward1',
          'turn_right',
          'forward2',
          'forward3',
          'forward4',
          'stop'
        ],
        'hasRobotMap': true,
        'robotStartX': 0,
        'robotStartY': 0,
        'robotStartDirection': 'right',
        'goalX': 1,
        'goalY': 3,
        'obstacles': [
          {'x': 0, 'y': 1},
          {'x': 0, 'y': 2},
        ],
        'mapSize': 4,
      },
      {
        'title': 'Döngü ile Hareket',
        'titleEn': 'Movement with a Loop',
        'description': 'Döngü kullanarak hareketi optimize et',
        'descriptionEn': 'Optimize the movement using a loop',
        'commands': [
          {
            'id': 'start',
            'label': 'Başla',
            'labelEn': 'Start',
            'icon': 'play_arrow'
          },
          {
            'id': 'loop_start',
            'label': '3 Kez Tekrarla {',
            'labelEn': 'Repeat 3 Times {',
            'icon': 'repeat'
          },
          {
            'id': 'forward',
            'label': '  İleri Git',
            'labelEn': '  Move Forward',
            'icon': 'arrow_upward'
          },
          {
            'id': 'turn',
            'label': '  Sağa Dön',
            'labelEn': '  Turn Right',
            'icon': 'turn_right'
          },
          {'id': 'loop_end', 'label': '}', 'labelEn': '}', 'icon': 'repeat_on'},
          {'id': 'stop', 'label': 'Dur', 'labelEn': 'Stop', 'icon': 'stop'},
        ],
        'correctOrder': [
          'start',
          'loop_start',
          'forward',
          'turn',
          'loop_end',
          'stop'
        ],
      },
      {
        'title': 'Koşullu Hareket',
        'titleEn': 'Conditional Movement',
        'description': 'If-else yapısını kullan',
        'descriptionEn': 'Use an if-else structure',
        'commands': [
          {
            'id': 'start',
            'label': 'Başla',
            'labelEn': 'Start',
            'icon': 'play_arrow'
          },
          {
            'id': 'if',
            'label': 'Eğer (sensör aktif)',
            'labelEn': 'If (sensor active)',
            'icon': 'help'
          },
          {
            'id': 'turn_left',
            'label': '  Sola Dön',
            'labelEn': '  Turn Left',
            'icon': 'turn_left'
          },
          {
            'id': 'else',
            'label': 'Değilse',
            'labelEn': 'Else',
            'icon': 'help_outline'
          },
          {
            'id': 'turn_right',
            'label': '  Sağa Dön',
            'labelEn': '  Turn Right',
            'icon': 'turn_right'
          },
          {
            'id': 'endif',
            'label': 'Bitir',
            'labelEn': 'End If',
            'icon': 'done'
          },
          {'id': 'stop', 'label': 'Dur', 'labelEn': 'Stop', 'icon': 'stop'},
        ],
        'correctOrder': [
          'start',
          'if',
          'turn_left',
          'else',
          'turn_right',
          'endif',
          'stop'
        ],
      },
    ];
  }

  void _loadLevel(int levelIndex) {
    if (levelIndex >= _levels.length) {
      _showCompletionDialog();
      return;
    }

    final level = _levels[levelIndex];
    setState(() {
      _correctSequence = List<String>.from(level['correctOrder']);
      _userSequence.clear();
      _isChecking = false;
      _feedback = null;
      _feedbackDetail = null;

      // Shuffle commands for display (except for robot map levels)
      _shuffledCommands = List<Map<String, dynamic>>.from(level['commands']);
      if (level['hasRobotMap'] != true) {
        _shuffledCommands.shuffle(Random());
      }
    });
  }

  void _checkAnswer() {
    bool isCorrect = _userSequence.length == _correctSequence.length;
    if (isCorrect) {
      for (int i = 0; i < _userSequence.length; i++) {
        if (_userSequence[i] != _correctSequence[i]) {
          isCorrect = false;
          break;
        }
      }
    }

    // Geri bildirim artik ekranin ortasinda acilan bir AlertDialog degil,
    // alttan giren bir serit: soru ve kullanicinin kurdugu sira ekranda
    // kaliyor, cocuk neyi yanlis yaptigini gorerek okuyor.
    setState(() {
      _isChecking = true;
      _feedback = isCorrect ? AnswerResult.correct : AnswerResult.wrong;
      if (isCorrect) {
        _score += 20;
        _feedbackDetail = _tl('Harika! Komutları doğru sıraladın.', 'Great! You ordered the commands correctly.', 'Super! Du hast die Befehle richtig sortiert.', '¡Genial! Ordenaste los comandos correctamente.');
      } else {
        _wrongTick++;
        _feedbackDetail = (_tl('Doğru sıralama: ', 'Correct order: ', 'Richtige Reihenfolge: ', 'Orden correcto: ')) +
            _correctSequence.map(_labelForId).join(' → ');
      }
    });
    // Titresim zaten seritten geliyordu; ses eksikti.
    if (isCorrect) {
      SoundService.playCorrect();
    } else {
      SoundService.playWrong();
    }
  }

  /// Serit uzerindeki "Devam"/"Anladim" tusuna basildiginda.
  void _onFeedbackContinue() {
    final wasCorrect = _feedback == AnswerResult.correct;
    setState(() {
      _feedback = null;
      _feedbackDetail = null;
      _isChecking = false;
    });
    if (wasCorrect) {
      // Ilk seviye bitince giris istemi akisi korunuyor.
      final isGuest = Provider.of<app_auth.AuthProvider>(context, listen: false)
              .currentUser ==
          null;
      if (_currentLevel == 0 && isGuest) {
        _showLoginRequiredDialog();
        return;
      }
      setState(() => _currentLevel++);
      _loadLevel(_currentLevel);
    } else {
      setState(() => _userSequence.clear());
    }
  }

  String _labelForId(String id) {
    final list = _shuffledCommands.isNotEmpty
        ? _shuffledCommands
        : List<Map<String, dynamic>>.from(
            _levels[_currentLevel]['commands'] as List);
    for (final c in list) {
      if (c['id'] == id) return _cmdLabel(c);
    }
    return id;
  }

  // --- Siralama etkinligi icin veri donusumleri ---------------------------
  //
  // Ekran komutlari `Map<String, dynamic>` olarak tutuyor (seviye verisinden
  // geldigi gibi), etkinlik widget'i ise tipli `SequenceToken` istiyor.
  // Donusumu tek yerde yapiyoruz ki id/etiket eslesmesi bozulmasin.

  SequenceToken _tokenFor(Map<String, dynamic> cmd) => SequenceToken(
        id: cmd['id'] as String,
        label: _cmdLabel(cmd),
        icon: _getIcon((cmd['icon'] as String?) ?? ''),
      );

  Map<String, dynamic>? _cmdById(List<dynamic> commands, String id) {
    for (final c in commands) {
      final map = Map<String, dynamic>.from(c as Map);
      if (map['id'] == id) return map;
    }
    return null;
  }

  List<SequenceToken> _answerTokens(List<dynamic> commands) {
    final out = <SequenceToken>[];
    for (final id in _userSequence) {
      final cmd = _cmdById(commands, id);
      if (cmd != null) out.add(_tokenFor(cmd));
    }
    return out;
  }

  List<SequenceToken> _bankTokens(List<dynamic> commands) {
    return commands
        .map((c) => Map<String, dynamic>.from(c as Map))
        .where((c) => !_userSequence.contains(c['id']))
        .map(_tokenFor)
        .toList();
  }

  /// Kontrol sonrasi her pozisyonun dogru olup olmadigi; parca parca
  /// renklendirmek icin. Tek bir "yanlis" yerine hangi adimin yanlis
  /// oldugunu gostermek ogrenme acisindan cok daha ise yariyor.
  List<bool> _correctnessFlags() {
    return [
      for (int i = 0; i < _userSequence.length; i++)
        i < _correctSequence.length && _userSequence[i] == _correctSequence[i],
    ];
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_tl('🏆 Tebrikler!', '🏆 Congratulations!', '🏆 Glückwunsch!', '🏆 ¡Felicidades!')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_tl('Tüm seviyeleri tamamladın!', 'You completed all levels!', 'Du hast alle Level geschafft!', '¡Completaste todos los niveles!')),
            const SizedBox(height: 16),
            Text(
              _tl('Toplam Puan: $_score', 'Total Score: $_score', 'Gesamtpunkte: $_score', 'Puntuación total: $_score'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentLevel = 0;
                _score = 0;
              });
              _loadLevel(0);
            },
            child: Text(_tl('Yeniden Başla', 'Start Over', 'Neu starten', 'Empezar de nuevo')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_tl('Bitir', 'Finish', 'Beenden', 'Terminar')),
          ),
        ],
      ),
    );
  }

  void _resetLevel() {
    setState(() {
      _userSequence.clear();
      _isChecking = false;
      _feedback = null;
      _feedbackDetail = null;
    });
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'alarm':
        return Icons.alarm;
      case 'wash':
        return Icons.wash;
      case 'checkroom':
        return Icons.checkroom;
      case 'breakfast_dining':
        return Icons.breakfast_dining;
      case 'school':
        return Icons.school_rounded;
      case 'play_arrow':
        return Icons.play_arrow_rounded;
      case 'arrow_upward':
        return Icons.arrow_upward_rounded;
      case 'turn_right':
        return Icons.turn_right;
      case 'turn_left':
        return Icons.turn_left;
      case 'stop':
        return Icons.stop_rounded;
      case 'repeat':
        return Icons.repeat_rounded;
      case 'repeat_on':
        return Icons.repeat_on;
      case 'help':
        return Icons.help_rounded;
      case 'help_outline':
        return Icons.help_outline_rounded;
      case 'done':
        return Icons.done;
      default:
        return Icons.code_rounded;
    }
  }

  IconData _getDirectionIcon(String direction) {
    switch (direction.toLowerCase()) {
      case 'up':
        return Icons.arrow_upward_rounded;
      case 'down':
        return Icons.arrow_downward_rounded;
      case 'left':
        return Icons.arrow_back_rounded;
      case 'right':
        return Icons.arrow_forward_rounded;
      default:
        return Icons.arrow_upward_rounded;
    }
  }

  Widget _buildRobotMapWidget(Map<String, dynamic> level) {
    final mapSize = level['mapSize'] ?? 3;
    final robotStartX = level['robotStartX'] ?? 0;
    final robotStartY = level['robotStartY'] ?? 0;
    final robotStartDirection = level['robotStartDirection'] ?? 'up';
    final goalX = level['goalX'] ?? 0;
    final goalY = level['goalY'] ?? 0;
    final obstacles = (level['obstacles'] as List?) ?? [];

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 300,
          maxHeight: 300,
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: mapSize,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: mapSize * mapSize,
                itemBuilder: (context, index) {
                  final x = index % mapSize;
                  final y = index ~/ mapSize;

                  final isRobotStart = x == robotStartX && y == robotStartY;
                  final isGoal = x == goalX && y == goalY;
                  final isObstacle =
                      obstacles.any((obs) => obs['x'] == x && obs['y'] == y);

                  return Container(
                    decoration: BoxDecoration(
                      color: isObstacle
                          ? Colors.grey[800]
                          : isGoal
                              ? Colors.green[200]
                              : isRobotStart
                                  ? Colors.blue[100]
                                  : Colors.white,
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: isRobotStart
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.smart_toy_rounded,
                                  color: Colors.blue,
                                  size: 32,
                                ),
                                Positioned(
                                  bottom: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.orange,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      _getDirectionIcon(robotStartDirection),
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : isGoal
                              ? const Icon(
                                  Icons.flag_rounded,
                                  color: Colors.green,
                                  size: 32,
                                )
                              : isObstacle
                                  ? const Icon(
                                      Icons.block,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLevel >= _levels.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final level = _levels[_currentLevel];
    final commands = _shuffledCommands.isNotEmpty
        ? _shuffledCommands
        : level['commands'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tl('Komut Dizilimi - Seviye ${_currentLevel + 1}', 'Command Sequencing - Level ${_currentLevel + 1}', 'Befehlsfolge - Level ${_currentLevel + 1}', 'Secuencia de comandos - Nivel ${_currentLevel + 1}')),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              // Puan bir anda siciramaz: sayarak geciyor ki kazanc
              // fark edilsin. Tabular rakamlar sayesinde 9 -> 10 gecisinde
              // sayac titremiyor.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _tl('Puan: ', 'Score: ', 'Punkte: ', 'Puntos: '),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CountUpText(value: _score, fontSize: 19),
                ],
              ),
            ),
          ),
        ],
      ),
      body: AnswerFeedbackBar.host(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Level info
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _levelTitle(level),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _levelDescription(level),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Robot map visualization (if level has robot map)
                  if (level['hasRobotMap'] == true) ...[
                    Text(
                      _tl('Robot Haritası:', 'Robot Map:', 'Roboterkarte:', 'Mapa del robot:'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.smart_toy_rounded,
                            color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _tl('Robot (Altındaki sarı ok başlangıç yönünü gösterir)', 'Robot (the yellow arrow below shows the start direction)', 'Roboter (der gelbe Pfeil darunter zeigt die Startrichtung)', 'Robot (la flecha amarilla de abajo indica la dirección inicial)'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.flag_rounded, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(_tl('Hedef', 'Goal', 'Ziel', 'Meta')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.block, color: Colors.grey[800], size: 20),
                        const SizedBox(width: 8),
                        Text(_tl('Engel', 'Obstacle', 'Hindernis', 'Obstáculo')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRobotMapWidget(level),
                    const SizedBox(height: 24),
                  ],

                  // Siralama etkinligi.
                  //
                  // Eskiden iki ayri blok vardi: ustte "Komutlar" listesi,
                  // altta salt okunur bir "Senin Siralaman" kutusu. Bir komutu
                  // yanlis yere koyduysan tek care hepsini sifirlamakti — sirayi
                  // duzeltmenin yolu yoktu. Simdi cevap alanindaki parcalar
                  // basili tutulup birbirinin uzerine birakilarak yer
                  // degistirebiliyor; dokunma da caliismaya devam ediyor
                  // (ekran okuyucu icin tek erisilebilir yol o).
                  Text(
                    _tl('Senin Sıralaman:', 'Your Order:', 'Deine Reihenfolge:', 'Tu orden:'),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ShakeOnChange(
                    trigger: _wrongTick,
                    child: TokenSequenceBuilder(
                      answer: _answerTokens(commands),
                      bank: _bankTokens(commands),
                      locked: _isChecking,
                      correctness:
                          _feedback == null ? null : _correctnessFlags(),
                      emptyHint: _tl('Aşağıdaki komutlara dokun ya da buraya sürükle', 'Tap a command below, or drag it here', 'Tippe unten auf einen Befehl oder zieh ihn hierher', 'Toca un comando de abajo o arrástralo aquí'),
                      onChanged: (next) {
                        setState(() {
                          _userSequence
                            ..clear()
                            ..addAll(next.map((t) => t.id));
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextButton.icon(
                          onPressed: _isChecking ? null : _resetLevel,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(_tl('Sıfırla', 'Reset', 'Zurücksetzen', 'Reiniciar')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: PressButton(
                          label: _tl('Kontrol Et', 'Check', 'Prüfen', 'Comprobar'),
                          // Cevap eksikken buton pasif: cocuk bos cevabi
                          // gonderip bosuna "yanlis" yemesin.
                          onPressed:
                              _userSequence.length == _correctSequence.length &&
                                      !_isChecking
                                  ? _checkAnswer
                                  : null,
                          height: 52,
                        ),
                      ),
                    ],
                  ),
                  // Alt seride yer birak.
                  SizedBox(height: _feedback == null ? 8 : 180),
                ],
              ),
            );
          },
        ),
        bar: _feedback == null
            ? null
            : AnswerFeedbackBar(
                result: _feedback!,
                detail: _feedbackDetail,
                onContinue: _onFeedbackContinue,
              ),
      ),
    );
  }

  Future<void> _showLoginRequiredDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Colors.orange, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _tl('Devam Etmek İçin Giriş Yapın', 'Sign In to Continue', 'Zum Weiterspielen anmelden', 'Inicia sesión para continuar'),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded,
                size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              _tl('İlk seviyeyi tamamladınız!', 'You completed the first level!', 'Du hast das erste Level geschafft!', '¡Completaste el primer nivel!'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _tl('Skor: $_score', 'Score: $_score', 'Punkte: $_score', 'Puntos: $_score'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              _tl('Devam etmek ve tüm seviyelere erişmek için giriş yapın.', 'Sign in to continue and access all levels.', 'Melde dich an, um weiterzuspielen und alle Level freizuschalten.', 'Inicia sesión para seguir y acceder a todos los niveles.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(_tl('Ana Sayfa', 'Home', 'Startseite', 'Inicio')),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final authProvider =
                  Provider.of<app_auth.AuthProvider>(context, listen: false);
              await authProvider.signOut();

              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.login_rounded),
            label: Text(_tl('Giriş Yap', 'Sign In', 'Anmelden', 'Iniciar sesión')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
