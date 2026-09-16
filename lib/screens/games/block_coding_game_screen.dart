// Professional block coding game
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/score_cache_service.dart';
import '../../models/leaderboard_model.dart';
import '../../models/game_model.dart';
import '../../services/leaderboard_service.dart';
import '../../widgets/animated_rank_display.dart';
import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import '../../ui/motion.dart';
import '../../widgets/learning/how_to_play_demo.dart';
import '../../utils/lang.dart';

// Block types
enum BlockType {
  moveForward,
  turnRight,
  turnLeft,
  repeat,
}

// Block model
class CodeBlock {
  final String id;
  final BlockType type;
  int? repeatCount;

  CodeBlock({
    required this.id,
    required this.type,
    this.repeatCount,
  });

  CodeBlock copyWith({String? id}) {
    return CodeBlock(
      id: id ?? this.id,
      type: type,
      repeatCount: repeatCount,
    );
  }
}

// Direction enum
enum Direction { up, right, down, left }

class BlockCodingGameScreen extends StatefulWidget {
  final Map<String, dynamic>? gameData;

  const BlockCodingGameScreen({
    super.key,
    this.gameData,
  });

  @override
  State<BlockCodingGameScreen> createState() => _BlockCodingGameScreenState();
}

class _BlockCodingGameScreenState extends State<BlockCodingGameScreen>
    with SingleTickerProviderStateMixin {
  // Player state
  int _playerX = 0;
  int _playerY = 0;
  Direction _playerDirection = Direction.right;

  // Goal
  int _goalX = 4;
  int _goalY = 0;

  // Game state
  int _currentLevel = 1;
  bool _isRunning = false;
  int _score = 0;
  DateTime? _startTime;
  int _totalStarsCollected = 0;

  // Code blocks
  List<CodeBlock> _codeBlocks = [];
  int _blockIdCounter = 0;

  // Grid (0 = empty, 1 = wall, 2 = star)
  List<List<int>> _grid = [];
  Set<String> _collectedStars = {};

  // Animation
  late AnimationController _animationController;

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  ///
  /// Onceki surumde her yerde `_isEn ? ingilizce : turkce` vardi; almanca
  /// ya da ispanyolca secen cocuk oyunun tamamini turkce goruyordu.
  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (Blok kodlama). Butun oyunlarda ayni tonu
    // calmak oyunlari birbirinden ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.deep);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _startTime = DateTime.now();
    _loadLevel(_currentLevel);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHowToPlay());
  }

  /// Ilk acilista "nasil oynanir": bir el blok havuzundan bir blogu alip
  /// kod alanina birakiyor.
  Future<void> _showHowToPlay({bool force = false}) async {
    if (!mounted) return;
    await HowToPlayDemo.maybeShow(
      context,
      gameKey: 'block_coding',
      force: force,
      demo: HowToPlayDemo(
        // BU OYUNDA ESLESTIRME YOK.
        //
        // Onceden burada iki sutunlu eslestirme gosterimi cikiyordu:
        // "1 Adım Git" ile "Kodun" arasinda bir ok. Cocuga bu oyunda
        // hic yapmayacagi bir hareket ogretiliyordu. Blok kodlamada
        // yapilan sey bir blogu ALIP KOD ALANINA BIRAKMAK — gosterim de
        // artik onu gosteriyor.
        scene: DemoScene.dragIntoArea,
        title: _tl('Nasıl oynanır?', 'How to play', 'So wird gespielt', 'Cómo se juega'),
        hint: _tl('Bir bloğu kod alanına sürükle, sonra Çalıştır\'a bas ve '
                'robotu izle.', 'Drag a block into the code area, then press Run and watch '
                'the robot move.', 'Zieh einen Block in den Codebereich, drück dann auf Ausführen und schau dem Roboter zu.', 'Arrastra un bloque al área de código, pulsa Ejecutar y observa al robot.'),
        sourceLabel: _tl('1 Adım Git', 'Move 1 Step', '1 Schritt gehen', 'Avanzar 1 paso'),
        decoyLabel: _tl('Sağa Dön', 'Turn Right', 'Nach rechts drehen', 'Girar a la derecha'),
        targetLabel: _tl('Blokları buraya sürükle', 'Drop blocks here', 'Blöcke hierher ziehen', 'Suelta los bloques aquí'),
        startLabel: _tl('Başla', 'Start', 'Start', 'Empezar'),
        color: const Color(0xFF7E57C2),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadLevel(int level) {
    setState(() {
      _playerX = 0;
      _playerY = 0;
      _playerDirection = Direction.right;
      _collectedStars.clear();
      _codeBlocks.clear();
      _isRunning = false;

      switch (level) {
        case 1:
          _goalX = 4;
          _goalY = 0;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
          _grid[0][2] = 2; // Star
          break;
        case 2:
          _goalX = 4;
          _goalY = 4;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
          _grid[0][2] = 2;
          _grid[2][4] = 2;
          break;
        case 3:
          _goalX = 0;
          _goalY = 4;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
          _grid[2][0] = 1; // Wall
          _grid[2][1] = 1;
          _grid[2][2] = 1;
          _grid[1][3] = 2; // Star
          break;
        // SEVIYE 4-10 AYNI BOS TAHTAYDI.
        //
        // Yedi seviye de `default` dalina dusuyordu: her seferinde bos
        // bir 5x5 tahta, hedef sag alt kosede, tek bir yildiz bile yok.
        // Yorumda "Random level" yaziyordu ama rastgele olan hicbir sey
        // yoktu. Cocuk 4. seviyeden sonra ayni ekrani yedi kez
        // oynuyordu.
        //
        // Yeni seviyeler kademeli: once tek duvar dolasma, sonra koridor,
        // zikzak, uzun kosu (tekrar blogunun gercekten ise yaradigi yer),
        // dar gecit. Hepsi COZULEBILIR; yildizlar yol ustunde ya da bir
        // adim sapmayla ulasilabilir yerde. Izgara [y][x]: 0 bos,
        // 1 duvar, 2 yildiz. Oyuncu (0,0)'da saga bakarak basliyor.
        case 4:
          // Duvari dolas: duz yol kapali, asagidan gecmek gerekiyor.
          _goalX = 4;
          _goalY = 0;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
          _grid[0][2] = 1;
          _grid[1][2] = 2;
          break;
        case 5:
          // Koridor: ortadaki duvar sirasi yalnizca kenarlardan geciyor.
          _goalX = 4;
          _goalY = 4;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
          _grid[2][1] = 1;
          _grid[2][2] = 1;
          _grid[2][3] = 1;
          _grid[0][3] = 2;
          _grid[3][4] = 2;
          break;
        case 6:
          // Zikzak: once sol kenardan in, sonra saga kay, sonra sola don.
          _goalX = 0;
          _goalY = 4;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
          _grid[1][1] = 1;
          _grid[1][2] = 1;
          _grid[1][3] = 1;
          _grid[1][4] = 1;
          _grid[3][0] = 1;
          _grid[3][1] = 1;
          _grid[3][2] = 1;
          _grid[2][4] = 2;
          break;
        case 7:
          // Uzun kosu: dort adimlik iki duz parca — tekrar blogunun
          // gercekten kisalttigi ilk seviye.
          _goalX = 4;
          _goalY = 4;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
          _grid[1][1] = 1;
          _grid[2][1] = 1;
          _grid[3][1] = 1;
          _grid[0][2] = 2;
          _grid[2][4] = 2;
          break;
        case 8:
          // Dort donus: hedef alt kenarin ortasinda.
          _goalX = 2;
          _goalY = 4;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
          _grid[1][2] = 1;
          _grid[2][2] = 1;
          _grid[3][0] = 1;
          _grid[3][1] = 1;
          _grid[0][3] = 2;
          _grid[4][3] = 2;
          break;
        case 9:
          // Dar gecit: sol kenardan in, alt kenardan gec, sagdan cik.
          _goalX = 4;
          _goalY = 2;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
          _grid[1][1] = 1;
          _grid[2][1] = 1;
          _grid[3][1] = 1;
          _grid[0][3] = 1;
          _grid[4][2] = 2;
          _grid[3][4] = 2;
          break;
        case 10:
          // Usta: uc yildiz, dort donus, iki uzun parca.
          _goalX = 4;
          _goalY = 4;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
          _grid[0][2] = 1;
          _grid[1][2] = 1;
          _grid[2][2] = 1;
          _grid[2][3] = 1;
          _grid[2][4] = 1;
          _grid[0][1] = 2;
          _grid[3][2] = 2;
          _grid[4][3] = 2;
          break;
        default:
          _goalX = 4;
          _goalY = 4;
          _grid = List.generate(5, (y) => List.generate(5, (x) => 0));
      }
    });
  }

  void _addBlock(BlockType type) {
    setState(() {
      _codeBlocks.add(CodeBlock(
        id: 'block_${_blockIdCounter++}',
        type: type,
        repeatCount: type == BlockType.repeat ? 2 : null,
      ));
    });
  }

  void _removeBlock(int index) {
    setState(() {
      _codeBlocks.removeAt(index);
    });
  }

  Future<void> _runCode() async {
    if (_isRunning || _codeBlocks.isEmpty) return;

    setState(() {
      _isRunning = true;
      _playerX = 0;
      _playerY = 0;
      _playerDirection = Direction.right;
      _collectedStars.clear();
    });

    try {
      await _executeBlocks(_codeBlocks);

      // Check if goal reached
      if (_playerX == _goalX && _playerY == _goalY) {
        SoundService.playLevelComplete();
        _showLevelCompleteDialog();
      } else {
        SoundService.playWrong();
        _showMessage(_tl('❌ Hedefe ulaşamadın. Tekrar dene!', '❌ You did not reach the goal. Try again!', '❌ Du hast das Ziel nicht erreicht. Versuch es noch mal!', '❌ No llegaste a la meta. ¡Inténtalo otra vez!'));
      }
    } catch (e) {
      _showMessage(_tl('❌ Hata: $e', '❌ Error: $e', '❌ Fehler: $e', '❌ Error: $e'));
    }

    setState(() {
      _isRunning = false;
    });
  }

  /// Blok dizisini calistirir.
  ///
  /// TEKRAR BLOGU DONGUYU YANLIS OGRETIYORDU.
  ///
  /// Eskiden `repeat` blogu, cevresinde ne olursa olsun ILERI GIT
  /// komutunu N kez calistiriyordu. Yani "Tekrarla 2x" aslinda
  /// "2 adim ileri" demekti: donguyu ogretmiyor, gizli bir hareket
  /// blogu gibi davraniyordu. Cocuk "Sağa Dön" blogunu tekrarlamak
  /// istediginde de ileri gidiyordu.
  ///
  /// Dogrusu: tekrar blogu KENDINDEN SONRAKI blogu N kez calistirir ve
  /// o blok bir daha tek basina calistirilmaz. Icine konacak blok yoksa
  /// hicbir sey yapmaz (bos dongu).
  Future<void> _executeBlocks(List<CodeBlock> blocks) async {
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];

      if (block.type == BlockType.repeat) {
        final tekrar = block.repeatCount ?? 0;
        final icerdeki = i + 1 < blocks.length ? blocks[i + 1] : null;
        if (icerdeki == null || icerdeki.type == BlockType.repeat) {
          // Bos dongu: yapacak is yok.
          continue;
        }
        for (var t = 0; t < tekrar; t++) {
          await _executeCommand(icerdeki.type);
        }
        i++; // icerdeki blok bir daha tek basina calismasin
        continue;
      }

      await _executeCommand(block.type);
    }
  }

  /// [index] numarali blok bir tekrar blogunun ICINDE mi?
  bool _tekrarIcinde(int index) =>
      index > 0 && _codeBlocks[index - 1].type == BlockType.repeat;

  Future<void> _executeCommand(BlockType type) async {
    await _animationController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      switch (type) {
        case BlockType.moveForward:
          _moveForward();
          break;
        case BlockType.turnRight:
          _turnRight();
          break;
        case BlockType.turnLeft:
          _turnLeft();
          break;
        case BlockType.repeat:
          break;
      }
    });

    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _moveForward() {
    int newX = _playerX;
    int newY = _playerY;

    switch (_playerDirection) {
      case Direction.up:
        newY--;
        break;
      case Direction.right:
        newX++;
        break;
      case Direction.down:
        newY++;
        break;
      case Direction.left:
        newX--;
        break;
    }

    if (newX < 0 || newX >= 5 || newY < 0 || newY >= 5) return;
    if (_grid[newY][newX] == 1) return;

    _playerX = newX;
    _playerY = newY;

    if (_grid[newY][newX] == 2 && !_collectedStars.contains('$newX,$newY')) {
      _collectedStars.add('$newX,$newY');
      _score += 10;
      _totalStarsCollected++;
    }
  }

  void _turnRight() {
    _playerDirection = Direction.values[(_playerDirection.index + 1) % 4];
  }

  void _turnLeft() {
    _playerDirection = Direction.values[(_playerDirection.index - 1 + 4) % 4];
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _saveScoreAndShowRank() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        return;
      }

      final totalDuration = DateTime.now().difference(_startTime!).inSeconds;

      // Calculate time bonus (faster = more points)
      final timeBonus =
          (300 - totalDuration).clamp(0, 200); // Max 200 bonus for under 5 min
      final finalScore = _score + timeBonus;

      final entry = LeaderboardEntry(
        id: '',
        userId: user.id,
        userName: user.name,
        userPhotoUrl: user.profilePictureUrl,
        gameType: GameType.blockCoding,
        score: finalScore,
        timeSeconds: totalDuration,
        correctCount: _totalStarsCollected,
        totalQuestions: _currentLevel * 3, // Approximate
        difficulty: _currentLevel,
        completedAt: DateTime.now(),
        metadata: {
          'starsCollected': _totalStarsCollected,
          'levelsCompleted': _currentLevel,
          'timeBonus': timeBonus,
        },
      );

      // Save to leaderboard
      await ScoreCacheService().saveScore(entry);

      // Get user rank
      final leaderboardService = LeaderboardService();
      final topEntries = await leaderboardService.getTopEntries(
        gameType: GameType.blockCoding,
        limit: 100,
      );

      final userRank = topEntries.indexWhere((e) => e.userId == user.id) + 1;

      if (mounted && userRank > 0) {
        // Show animated rank display
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AnimatedRankDisplay(
            rank: userRank,
            totalScore: finalScore,
            userName: user.name,
            isNewRecord: false,
            onClose: () {
              Navigator.pop(context);
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving score: $e');
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emoji_events_rounded,
                color: Colors.amber[600], size: 32),
            const SizedBox(width: 12),
            Text(_tl('🎉 Hedefe Ulaştınız!', '🎉 You Reached the Goal!', '🎉 Du hast das Ziel erreicht!', '🎉 ¡Llegaste a la meta!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _tl('Seviye $_currentLevel Tamamlandı!', 'Level $_currentLevel Complete!', 'Level $_currentLevel geschafft!', '¡Nivel $_currentLevel completado!'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    _tl('Puan: $_score', 'Score: $_score', 'Punkte: $_score', 'Puntos: $_score'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _loadLevel(_currentLevel);
              });
            },
            child: Text(_tl('Tekrar Oyna', 'Play Again', 'Noch mal spielen', 'Jugar otra vez')),
          ),
          if (_currentLevel < 10)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentLevel++;
                  _loadLevel(_currentLevel);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0FBD8C), // Scratch green
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(_tl('Sonraki Seviye', 'Next Level', 'Nächstes Level', 'Siguiente nivel')),
            ),
          if (_currentLevel >= 3)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _saveScoreAndShowRank();
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(_tl('Skoru Kaydet', 'Save Score', 'Punktzahl speichern', 'Guardar puntuación')),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tl('Kod Blokları', 'Code Blocks', 'Code-Blöcke', 'Bloques de código')),
        backgroundColor: const Color(0xFF0FBD8C), // Scratch green
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                _tl('Seviye $_currentLevel | Puan: $_score', 'Level $_currentLevel | Score: $_score', 'Level $_currentLevel | Punkte: $_score', 'Nivel $_currentLevel | Puntos: $_score'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 800;

              return isWideScreen ? _buildWideLayout() : _buildNarrowLayout();
            },
          )),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Block palette
        Container(
          width: 180,
          color: Colors.grey[100],
          child: _buildBlockPalette(),
        ),
        // Main area
        Expanded(
          child: Column(
            children: [
              Expanded(flex: 3, child: _buildGameGrid()),
              Expanded(flex: 2, child: _buildCodeArea()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        Expanded(flex: 3, child: _buildGameGrid()),
        Container(
          height: 148,
          color: Colors.grey[100],
          child: _buildBlockPaletteHorizontal(),
        ),
        Expanded(flex: 2, child: _buildCodeArea()),
      ],
    );
  }

  Widget _buildBlockPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF4CAF50),
          child: Text(
            _tl('Bloklar', 'Blocks', 'Blöcke', 'Bloques'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              _buildDraggableBlock(BlockType.moveForward),
              const SizedBox(height: 8),
              _buildDraggableBlock(BlockType.turnRight),
              const SizedBox(height: 8),
              _buildDraggableBlock(BlockType.turnLeft),
              const SizedBox(height: 8),
              _buildDraggableBlock(BlockType.repeat),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlockPaletteHorizontal() {
    // Not: yatay kaydırılan bir ListView içine Draggable koymak, dokunma
    // hareketlerinin (sürükleme vs kaydırma) birbiriyle çakışmasına ve
    // blokların kaymaması / sağda kesik görünmesine yol açıyordu.
    // Bunun yerine tüm bloklar Wrap ile iki satıra sığdırılıyor, böylece
    // kaydırmaya gerek kalmadan hepsi görünür ve sürüklenebilir olur.
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildDraggableBlock(BlockType.moveForward),
          _buildDraggableBlock(BlockType.turnRight),
          _buildDraggableBlock(BlockType.turnLeft),
          _buildDraggableBlock(BlockType.repeat),
        ],
      ),
    );
  }

  Widget _buildDraggableBlock(BlockType type) {
    return Draggable<BlockType>(
      data: type,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: 0.8,
          child: _buildBlockDisplay(type, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildBlockDisplay(type),
      ),
      child: _buildBlockDisplay(type),
    );
  }

  Widget _buildBlockDisplay(BlockType type, {bool isDragging = false}) {
    Color color;
    IconData icon;
    String label;

    switch (type) {
      case BlockType.moveForward:
        color = Colors.blue;
        icon = Icons.arrow_upward_rounded;
        label = _tl('1 Adım Git', 'Move 1 Step', '1 Schritt gehen', 'Avanzar 1 paso'); // Grid'de tek kare ileri gider
        break;
      case BlockType.turnRight:
        color = Colors.orange;
        icon = Icons.rotate_right_rounded;
        label = _tl('Sağa Dön', 'Turn Right', 'Nach rechts drehen', 'Girar a la derecha'); // Grid'de 90° sağa döner
        break;
      case BlockType.turnLeft:
        color = Colors.purple;
        icon = Icons.rotate_left_rounded;
        label = _tl('Sola Dön', 'Turn Left', 'Nach links drehen', 'Girar a la izquierda'); // Grid'de 90° sola döner
        break;
      case BlockType.repeat:
        color = Colors.green;
        icon = Icons.repeat_rounded;
        label = _tl('Tekrarla', 'Repeat', 'Wiederholen', 'Repetir');
        break;
    }

    return Container(
      width: isDragging ? 140 : null,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, kutu) {
                // Kukla hucrenin icinde cizilirse her komutta bir kareden
                // kaybolup digerinde beliriyor. Izgara kuklasiz ciziliyor,
                // kukla ustune AnimatedPositioned ile konuyor; donme de
                // AnimatedRotation'a bagli, boylece "ileri git" ile "don"
                // arasindaki fark gorunur oluyor.
                const kenar = 8.0;
                const bosluk = 4.0;
                final hucre = (kutu.maxWidth - kenar * 2 - bosluk * 4) / 5;
                double konum(int i) => kenar + i * (hucre + bosluk);

                return Stack(
                  children: [
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(kenar),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: bosluk,
                        crossAxisSpacing: bosluk,
                      ),
                      itemCount: 25,
                      itemBuilder: (context, index) {
                        final x = index % 5;
                        final y = index ~/ 5;
                        final isGoal = x == _goalX && y == _goalY;
                        final cellType = _grid[y][x];
                        final hasStar = cellType == 2;
                        final isCollected = _collectedStars.contains('$x,$y');

                        return AnimatedContainer(
                          duration: Motion.adapt(context, Motion.medium2),
                          decoration: BoxDecoration(
                            color: cellType == 1
                                ? Colors.grey[800]
                                : isGoal
                                    ? Colors.green[200]
                                    : Colors.grey[50],
                            border: Border.all(
                                color: Colors.grey[300]!, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              if (isGoal)
                                Center(
                                  child: Icon(Icons.flag_rounded,
                                      color: Colors.green[700], size: 28),
                                ),
                              if (hasStar && !isCollected)
                                const Center(
                                  child: Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 22),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    AnimatedPositioned(
                      duration: Motion.adapt(context, Motion.short4),
                      curve: Motion.emphasized,
                      left: konum(_playerX),
                      top: konum(_playerY),
                      width: hucre,
                      height: hucre,
                      child: Center(
                        child: AnimatedRotation(
                          turns: _playerDirection.index / 4,
                          duration: Motion.adapt(context, Motion.short4),
                          curve: Motion.emphasized,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              // Kukla her zaman gorunur, sadece hareket
                              // ederken hafifce buyur.
                              final scale = _isRunning
                                  ? 1.0 + (_animationController.value * 0.2)
                                  : 1.0;
                              return Transform.scale(scale: scale, child: child);
                            },
                            child: const Icon(
                              Icons.navigation_rounded,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeArea() {
    return DragTarget<BlockType>(
      onAccept: (type) {
        _addBlock(type);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                candidateData.isNotEmpty ? Colors.green[50] : Colors.grey[50],
            border: Border.all(
              color:
                  candidateData.isNotEmpty ? Colors.green : Colors.grey[300]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _tl('Kodun', 'Your Code', 'Dein Code', 'Tu código'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_codeBlocks.isNotEmpty)
                          IconButton(
                            onPressed: _isRunning
                                ? null
                                : () {
                                    setState(() {
                                      _codeBlocks.clear();
                                    });
                                  },
                            icon: const Icon(Icons.delete_rounded, size: 18),
                            color: Colors.red,
                            tooltip: _tl('Temizle', 'Clear', 'Löschen', 'Borrar'),
                            padding: EdgeInsets.zero,
                            // Ikon kucuk ama BASILABILIR ALAN degil: bos
                            // BoxConstraints(), IconButton'in 48x48 varsayilan
                            // hedefini siliyordu ve geriye yalnizca ikonun kendi
                            // boyu kaliyordu. En az 44x44 (Apple HIG).
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                          ),
                        const SizedBox(width: 4),
                        ElevatedButton.icon(
                          onPressed: _isRunning || _codeBlocks.isEmpty
                              ? null
                              : _runCode,
                          icon: Icon(
                            _isRunning
                                ? Icons.stop_rounded
                                : Icons.flag_rounded, // Scratch green flag
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            _isRunning
                                ? (_tl('Çalışıyor...', 'Running...', 'Läuft ...', 'Ejecutando...'))
                                : (_tl('Çalıştır', 'Run', 'Ausführen', 'Ejecutar')),
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF0FBD8C), // Scratch green
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _codeBlocks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.drag_indicator_rounded,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              _tl('Blokları buraya sürükle', 'Drag blocks here', 'Blöcke hierher ziehen', 'Arrastra los bloques aquí'),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        itemCount: _codeBlocks.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = _codeBlocks.removeAt(oldIndex);
                            _codeBlocks.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final block = _codeBlocks[index];
                          return _buildCodeBlockTile(block, index);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCodeBlockTile(CodeBlock block, int index) {
    Color color;
    IconData icon;
    String label;

    switch (block.type) {
      case BlockType.moveForward:
        color = Colors.blue;
        icon = Icons.arrow_upward_rounded;
        label = _tl('1 Adım Git', 'Move 1 Step', '1 Schritt gehen', 'Avanzar 1 paso');
        break;
      case BlockType.turnRight:
        color = Colors.orange;
        icon = Icons.rotate_right_rounded;
        label = _tl('Sağa Dön', 'Turn Right', 'Nach rechts drehen', 'Girar a la derecha');
        break;
      case BlockType.turnLeft:
        color = Colors.purple;
        icon = Icons.rotate_left_rounded;
        label = _tl('Sola Dön', 'Turn Left', 'Nach links drehen', 'Girar a la izquierda');
        break;
      case BlockType.repeat:
        color = Colors.green;
        icon = Icons.repeat_rounded;
        // Etiket neyi tekrarladigini soyluyor: "Tekrarla 2x" cocuga
        // neyin tekrarlandigini anlatmiyordu.
        label = _tl(
            'Sonrakini ${block.repeatCount}x tekrarla',
            'Repeat the next one ${block.repeatCount}x',
            'Wiederhole den nächsten ${block.repeatCount}x',
            'Repite el siguiente ${block.repeatCount}x');
        break;
    }

    // Tekrar blogunun ICINDEKI blok iceri giriyor ve solunda dongunun
    // renginde bir sirt tasiyor: cocuk neyin tekrarlandigini duz bir
    // listede goremiyordu.
    final icerde = _tekrarIcinde(index);

    return Container(
      key: ValueKey(block.id),
      margin: EdgeInsets.only(bottom: 6, left: icerde ? 22 : 0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: icerde
            ? Border(
                top: BorderSide(color: color, width: 2),
                right: BorderSide(color: color, width: 2),
                bottom: BorderSide(color: color, width: 2),
                left: BorderSide(color: Colors.green, width: 8),
              )
            : Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle_rounded, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              '${index + 1}.',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            // Almanca "Nach rechts drehen" ve ispanyolca "Girar a la
            // derecha" bu satirdan tasiyordu; etiket artik sigmazsa
            // kisaliyor.
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close_rounded, size: 18),
          onPressed: () => _removeBlock(index),
          color: Colors.red,
          padding: EdgeInsets.zero,
          // Ikon kucuk ama BASILABILIR ALAN degil: bos
          // BoxConstraints(), IconButton'in 48x48 varsayilan
          // hedefini siliyordu ve geriye yalnizca ikonun kendi
          // boyu kaliyordu. En az 44x44 (Apple HIG).
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
        ),
      ),
    );
  }
}
