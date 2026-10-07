// Professional block coding game
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/oyun_basligi.dart';
import '../../widgets/oyun_kimligi.dart';
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
    with TickerProviderStateMixin {
  /// Yildizlarin nabzi ve bayragin dalgalanmasi.
  late final AnimationController _nabiz = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();

  /// Robotun gectigi kareler (calisirken iz birakiyor).
  final List<String> _iz = [];

  /// O an calisan blogun sirasi; kod alaninda parliyor.
  int? _calisanBlok;

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
    _nabiz.dispose();
    super.dispose();
  }

  void _loadLevel(int level) {
    setState(() {
      _playerX = 0;
      _playerY = 0;
      _playerDirection = Direction.right;
      _collectedStars.clear();
      _codeBlocks.clear();
      _iz.clear();
      _calisanBlok = null;
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
      _iz
        ..clear()
        ..add('0,0');
    });

    try {
      await _executeBlocks(_codeBlocks);
      if (mounted) setState(() => _calisanBlok = null);

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
      if (mounted) setState(() => _calisanBlok = i);

      if (block.type == BlockType.repeat) {
        final tekrar = block.repeatCount ?? 0;
        final icerdeki = i + 1 < blocks.length ? blocks[i + 1] : null;
        if (icerdeki == null || icerdeki.type == BlockType.repeat) {
          // Bos dongu: yapacak is yok.
          continue;
        }
        if (mounted) setState(() => _calisanBlok = i + 1);
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

    if (newX < 0 || newX >= 5 || newY < 0 || newY >= 5 ||
        _grid[newY][newX] == 1) {
      // Duvara ya da kenara carpti: kisa bir titresim.
      HapticFeedback.heavyImpact();
      return;
    }

    _playerX = newX;
    _playerY = newY;
    _iz.add('$newX,$newY');

    if (_grid[newY][newX] == 2 && !_collectedStars.contains('$newX,$newY')) {
      _collectedStars.add('$newX,$newY');
      _score += 10;
      _totalStarsCollected++;
      SoundService.playJeton();
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
      backgroundColor: OyunZemini.ustRenk(OyunKimligi.renk(GameType.blockCoding)),
      appBar: OyunBasligi.oyun(
        GameType.blockCoding,
        baslikWidget: Text(_tl('Kod Blokları', 'Code Blocks', 'Code-Blöcke', 'Bloques de código')),
        eylemler: [
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
      body: OyunZemini(
        renk: OyunKimligi.renk(GameType.blockCoding),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 800;

              return isWideScreen ? _buildWideLayout() : _buildNarrowLayout();
            },
          )),
      ),
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
          height: 132,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white),
          ),
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
        spacing: 10,
        runSpacing: 12,
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
    // DOKUNARAK EKLEME: eskiden blok yalnizca surukleniyordu. 6-8 yas
    // icin surukle-birak zor; dokunmak blogu kodun sonuna ekliyor,
    // surukleme de calismaya devam ediyor.
    return Draggable<BlockType>(
      data: type,
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.rotate(
          angle: -0.04,
          child: _buildBlockDisplay(type, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildBlockDisplay(type),
      ),
      child: _Basinca(
        key: ValueKey('blok_paleti_${type.name}'),
        onTap: _isRunning
            ? null
            : () {
                HapticFeedback.lightImpact();
                _addBlock(type);
              },
        child: _buildBlockDisplay(type),
      ),
    );
  }

  (Color, IconData, String) _blokGorunumu(BlockType type, {int? tekrar}) {
    switch (type) {
      case BlockType.moveForward:
        return (const Color(0xFF4C97FF), Icons.arrow_upward_rounded,
            _tl('1 Adım Git', 'Move 1 Step', '1 Schritt gehen', 'Avanzar 1 paso'));
      case BlockType.turnRight:
        return (const Color(0xFFFF8C1A), Icons.rotate_right_rounded,
            _tl('Sağa Dön', 'Turn Right', 'Nach rechts drehen', 'Girar a la derecha'));
      case BlockType.turnLeft:
        return (const Color(0xFF9966FF), Icons.rotate_left_rounded,
            _tl('Sola Dön', 'Turn Left', 'Nach links drehen', 'Girar a la izquierda'));
      case BlockType.repeat:
        return (
          const Color(0xFFFFAB19),
          Icons.repeat_rounded,
          tekrar == null
              ? _tl('Tekrarla', 'Repeat', 'Wiederholen', 'Repetir')
              // Etiket neyi tekrarladigini soyluyor.
              : _tl('Sonrakini ${tekrar}x tekrarla', 'Repeat the next one ${tekrar}x',
                  'Wiederhole den nächsten ${tekrar}x', 'Repite el siguiente ${tekrar}x'),
        );
    }
  }

  /// Scratch'e benzeyen blok: dolu renk, ustte kucuk bir girinti (centik),
  /// altta koyu bir golge. Bloklar "takilacak parca" gibi duruyor.
  Widget _buildBlockDisplay(BlockType type, {bool isDragging = false}) {
    final (color, icon, label) = _blokGorunumu(type);
    return _BlokSekli(
      renk: color,
      genislik: isDragging ? 150 : null,
      golge: !isDragging,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    final toplamYildiz = _grid.expand((r) => r).where((c) => c == 2).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        children: [
          // Gorev seridi: hedef ve toplanan yildizlar.
          Row(
            children: [
              Flexible(
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _tl('🏁 Bayrağa ulaş!', '🏁 Reach the flag!', '🏁 Erreiche die Flagge!',
                      '🏁 ¡Llega a la bandera!'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              ),
              const SizedBox(width: 8),
              if (toplamYildiz > 0)
                Container(
                  key: const ValueKey('blok_yildiz_sayaci'),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4CC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '⭐ ${_collectedStars.length}/$toplamYildiz',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Color(0xFF8A6500)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3E8E41), Color(0xFF2E6B31)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFF1F4A21), offset: Offset(0, 6)),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, kutu) {
                      // Kukla hucrenin icinde cizilirse her komutta bir kareden
                      // kaybolup digerinde beliriyor. Izgara kuklasiz ciziliyor,
                      // kukla ustune AnimatedPositioned ile konuyor.
                      const kenar = 4.0;
                      const bosluk = 3.0;
                      final hucre = (kutu.maxWidth - kenar * 2 - bosluk * 4) / 5;
                      double konum(int i) => kenar + i * (hucre + bosluk);

                      return AnimatedBuilder(
                        animation: _nabiz,
                        builder: (context, _) {
                          final v = _nabiz.value * math.pi * 2;
                          return Stack(
                            children: [
                              for (var y = 0; y < 5; y++)
                                for (var x = 0; x < 5; x++)
                                  Positioned(
                                    left: konum(x),
                                    top: konum(y),
                                    width: hucre,
                                    height: hucre,
                                    child: _hucre(x, y, hucre, v),
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
                                        final scale = _isRunning
                                            ? 1.0 + (_animationController.value * 0.15)
                                            : 1.0 + 0.04 * math.sin(v * 2);
                                        return Transform.scale(scale: scale, child: child);
                                      },
                                      child: CustomPaint(
                                        key: const ValueKey('blok_robot'),
                                        size: Size.square(hucre * 0.78),
                                        painter: _RobotRessami(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hucre(int x, int y, double boy, double v) {
    final isGoal = x == _goalX && y == _goalY;
    final cellType = _grid[y][x];
    final duvar = cellType == 1;
    final yildiz = cellType == 2 && !_collectedStars.contains('$x,$y');
    final izde = _iz.contains('$x,$y');
    final acik = (x + y).isEven;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(boy * 0.18),
        gradient: duvar
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF9E9E9E), Color(0xFF616161)],
              )
            : null,
        color: duvar
            ? null
            : isGoal
                ? const Color(0xFFFFF59D)
                : (acik ? const Color(0xFFA8DB72) : const Color(0xFF97CF5E)),
        boxShadow: duvar
            ? const [BoxShadow(color: Color(0xFF424242), offset: Offset(0, 3))]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (izde && !duvar)
            Container(
              width: boy * 0.22,
              height: boy * 0.22,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          if (duvar) Text('🪨', style: TextStyle(fontSize: boy * 0.42)),
          if (isGoal)
            Transform.rotate(
              angle: 0.12 * math.sin(v * 2),
              alignment: Alignment.bottomLeft,
              child: Text('🏁', style: TextStyle(fontSize: boy * 0.5)),
            ),
          if (yildiz)
            Transform.scale(
              scale: 0.9 + 0.15 * math.sin(v * 2 + x),
              child: Text('⭐', style: TextStyle(fontSize: boy * 0.45)),
            ),
        ],
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
            color: candidateData.isNotEmpty
                ? const Color(0xFFE8FFF5)
                : Colors.white,
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? const Color(0xFF0FBD8C)
                  : const Color(0xFFE1E5EC),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF0FBD8C), // Scratch green
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
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
    final (color, icon, label) =
        _blokGorunumu(block.type, tekrar: block.repeatCount);

    // Tekrar blogunun ICINDEKI blok iceri giriyor ve solunda dongunun
    // renginde bir sirt tasiyor: cocuk neyin tekrarlandigini goruyor.
    final icerde = _tekrarIcinde(index);
    final calisiyor = _calisanBlok == index;

    return Padding(
      key: ValueKey(block.id),
      padding: EdgeInsets.only(bottom: 6, left: icerde ? 22 : 0),
      child: Row(
        children: [
          if (icerde)
            Container(
              width: 6,
              height: 40,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFAB19),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          Expanded(
            child: AnimatedScale(
              scale: calisiyor ? 1.04 : 1,
              duration: const Duration(milliseconds: 180),
              child: _BlokSekli(
                renk: color,
                parlak: calisiyor,
                child: Row(
                  children: [
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    InkResponse(
                      onTap: _isRunning ? null : () => _removeBlock(index),
                      radius: 22,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded,
                            color: Colors.white.withValues(alpha: 0.9), size: 18),
                      ),
                    ),
                    const Icon(Icons.drag_handle_rounded,
                        color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Basinca biraz cokup geri gelen sarmalayici (palet bloklari).
class _Basinca extends StatefulWidget {
  const _Basinca({super.key, required this.child, required this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_Basinca> createState() => _BasincaState();
}

class _BasincaState extends State<_Basinca> {
  bool _basili = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _basili = true),
      onTapCancel: () => setState(() => _basili = false),
      onTapUp: (_) {
        setState(() => _basili = false);
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _basili ? 0.92 : 1,
        duration: const Duration(milliseconds: 90),
        child: widget.child,
      ),
    );
  }
}

/// Scratch tarzi blok govdesi: dolu renk, ustte centik, altta golge.
class _BlokSekli extends StatelessWidget {
  const _BlokSekli({
    required this.renk,
    required this.child,
    this.genislik,
    this.golge = true,
    this.parlak = false,
  });

  final Color renk;
  final Widget child;
  final double? genislik;
  final bool golge;
  final bool parlak;

  @override
  Widget build(BuildContext context) {
    final koyu = Color.lerp(renk, Colors.black, 0.25)!;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: genislik,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: renk,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: koyu, width: 1.2),
            boxShadow: [
              if (golge) BoxShadow(color: koyu, offset: const Offset(0, 3)),
              if (parlak)
                BoxShadow(
                  color: Colors.yellowAccent.withValues(alpha: 0.9),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: child,
        ),
        // Centik: Scratch bloklarinin ust kenarindaki girinti.
        Positioned(
          top: -1,
          left: 14,
          child: Container(
            width: 16,
            height: 5,
            decoration: BoxDecoration(
              color: Color.lerp(renk, Colors.white, 0.35),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Izgaradaki robot. Yukari bakan halde ciziliyor; yon AnimatedRotation ile.
class _RobotRessami extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    // Tekerlekler
    final teker = Paint()..color = const Color(0xFF37474F);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.3, w * 0.16, h * 0.5), Radius.circular(w * 0.06)),
        teker);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.84, h * 0.3, w * 0.16, h * 0.5), Radius.circular(w * 0.06)),
        teker);
    // Govde
    final govde = Rect.fromLTWH(w * 0.12, h * 0.18, w * 0.76, h * 0.72);
    canvas.drawRRect(
        RRect.fromRectAndRadius(govde.shift(Offset(0, h * 0.04)), Radius.circular(w * 0.22)),
        Paint()..color = const Color(0xFF0D47A1));
    canvas.drawRRect(
      RRect.fromRectAndRadius(govde, Radius.circular(w * 0.22)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
        ).createShader(govde),
    );
    // Anten
    canvas.drawLine(Offset(w / 2, h * 0.18), Offset(w / 2, h * 0.04),
        Paint()
          ..color = const Color(0xFF1E88E5)
          ..strokeWidth = w * 0.05);
    canvas.drawCircle(Offset(w / 2, h * 0.04), w * 0.07, Paint()..color = const Color(0xFFFF5252));
    // Yuz (ileriye, yani yukariya bakiyor)
    final yuz = Rect.fromLTWH(w * 0.22, h * 0.26, w * 0.56, h * 0.3);
    canvas.drawRRect(RRect.fromRectAndRadius(yuz, Radius.circular(w * 0.12)),
        Paint()..color = const Color(0xFFE3F2FD));
    final goz = Paint()..color = const Color(0xFF0D47A1);
    canvas.drawCircle(Offset(w * 0.38, h * 0.39), w * 0.07, goz);
    canvas.drawCircle(Offset(w * 0.62, h * 0.39), w * 0.07, goz);
    final parilti = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.40, h * 0.37), w * 0.025, parilti);
    canvas.drawCircle(Offset(w * 0.64, h * 0.37), w * 0.025, parilti);
    // Gogus isigi
    canvas.drawCircle(Offset(w / 2, h * 0.72), w * 0.06, Paint()..color = const Color(0xFFFFD54F));
  }

  @override
  bool shouldRepaint(_RobotRessami old) => false;
}
