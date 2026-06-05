import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../utils/score_calculator.dart';
import '../../models/game_model.dart';
import '../../services/sound_service.dart';

/// Pipes Puzzle Game - Boruları döndürerek bağlantı yap
class PipesGameScreen extends StatelessWidget {
  const PipesGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          'Pipes Puzzle',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showGameInfo(context),
          ),
        ],
      ),
      body: GameWidget(
        game: PipesGame(),
      ),
    );
  }

  void _showGameInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎮 Pipes Puzzle'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nasıl Oynanır?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Yeşil noktadan (kaynak) kırmızı noktaya (hedef) boru hattı oluşturun\n'
                '• Boru parçalarına dokunarak döndürün\n'
                '• Tüm boruları bağlayarak hedefe ulaşın\n'
                '• En az hamleyle tamamlamaya çalışın!',
              ),
              SizedBox(height: 16),
              Text(
                'Boru Türleri',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '🟢 Yeşil: Başlangıç noktası\n'
                '🔴 Kırmızı: Hedef noktası\n'
                '━ Düz boru: İki yönlü bağlantı\n'
                '┛ Köşe boru: 90 derece dönüş',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

enum PipeType {
  empty,
  straight, // Düz boru (─ veya │)
  corner, // Köşe boru (└ ┌ ┐ ┘)
  source, // Başlangıç noktası
  sink, // Bitiş noktası
}

class PipeTile {
  PipeType type;
  int rotation; // 0, 1, 2, 3 (0, 90, 180, 270 derece)
  bool isConnected;

  PipeTile({
    required this.type,
    this.rotation = 0,
    this.isConnected = false,
  });

  void rotate() {
    if (type != PipeType.source && type != PipeType.sink) {
      rotation = (rotation + 1) % 4;
    }
  }

  /// Bağlantı noktalarını döndürme açısına göre al
  /// Direction mapping: 0=Sol, 1=Üst, 2=Sağ, 3=Alt
  List<int> getConnections() {
    switch (type) {
      case PipeType.straight:
        return rotation % 2 == 0
            ? [0, 2] // Yatay: sol-sağ
            : [1, 3]; // Dikey: üst-alt
      case PipeType.corner:
        // Saat yönünde rotation
        switch (rotation) {
          case 0:
            return [3, 0]; // Alt-Sol (└)
          case 1:
            return [0, 1]; // Sol-Üst (┌)
          case 2:
            return [1, 2]; // Üst-Sağ (┐)
          case 3:
            return [2, 3]; // Sağ-Alt (┘)
          default:
            return [];
        }
      case PipeType.source:
      case PipeType.sink:
        // Kaynak ve hedef tüm yönlere bağlanabilir
        return [0, 1, 2, 3];
      case PipeType.empty:
        return [];
    }
  }
}

class PipesGame extends FlameGame with TapCallbacks {
  static const double spacing = 3.0;
  static const double uiHeight = 110.0;

  double tileSize = 56.0;

  late List<List<PipeTile>> grid;
  late Vector2 gridOffset;
  int moveCount = 0;
  bool gameWon = false;
  int currentLevel = 1;
  int score = 0;

  late TextComponent moveCountText;
  late TextComponent statusText;
  late TextComponent levelText;
  late TextComponent scoreText;
  late NewGameButton newGameButton;

  // Kademeli grid boyutu: seviye arttıkça yavaşça büyür
  int get gridSize {
    if (currentLevel <= 2) return 4;
    if (currentLevel <= 5) return 5;
    if (currentLevel <= 8) return 6;
    if (currentLevel <= 12) return 7;
    return 8;
  }

  // Seviyeye göre sahte boru yoğunluğu
  double get _decoyFillRate {
    return (0.15 + currentLevel * 0.04).clamp(0.15, 0.60);
  }

  void _computeTileSize() {
    final availableW = size.x - 24;
    final availableH = size.y - uiHeight - 24;
    final maxTile = min(availableW / gridSize, availableH / gridSize);
    tileSize = min(maxTile, 64.0).floorToDouble();
  }

  void _computeGridOffset() {
    final totalSize = gridSize * (tileSize + spacing) - spacing;
    gridOffset = Vector2(
      (size.x - totalSize) / 2,
      uiHeight + (size.y - uiHeight - totalSize) / 2,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _computeTileSize();
    _computeGridOffset();

    // UI elementleri
    // Seviye göstergesi
    levelText = TextComponent(
      text: 'Seviye: $currentLevel',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.cyan,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(levelText);

    // Skor göstergesi
    scoreText = TextComponent(
      text: 'Skor: $score',
      position: Vector2(size.x - 20, 20),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

    moveCountText = TextComponent(
      text: 'Hamle: 0',
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(moveCountText);

    statusText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, 90),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(statusText);

    newGameButton = NewGameButton(
      position: Vector2(size.x - 160, 20),
      size: Vector2(140, 40),
      onPressed: _newGame,
    );
    add(newGameButton);

    _newGame();
  }

  void _newGame() {
    // Tüm oyunu sıfırla (seviye 1'den başla)
    currentLevel = 1;
    score = 0;
    levelText.text = 'Seviye: $currentLevel';
    scoreText.text = 'Skor: $score';
    resetGame();
  }

  void resetGame() {
    moveCount = 0;
    gameWon = false;
    moveCountText.text = 'Hamle: 0';
    statusText.text = '';

    // Grid boyutu değişince tile size yeniden hesapla
    _computeTileSize();
    _computeGridOffset();

    children.whereType<PipeTileComponent>().forEach((tile) => tile.removeFromParent());

    _generateGrid();
    _renderGrid();
    _checkConnections();
  }

  void _generateGrid() {
    grid = List.generate(
      gridSize,
      (i) => List.generate(
        gridSize,
        (j) => PipeTile(type: PipeType.empty),
      ),
    );

    final random = Random();

    // Kaynak ve hedef noktaları farklı kenarlarda yerleştir
    final sourceY = 0;
    final sinkY = gridSize - 1;
    final sourceX = random.nextInt(gridSize);
    final sinkX = random.nextInt(gridSize);

    grid[sourceY][sourceX] = PipeTile(type: PipeType.source);
    grid[sinkY][sinkX] = PipeTile(type: PipeType.sink);

    // Çözülebilir yol oluştur
    _createPath(sourceX, sourceY, sinkX, sinkY);

    // Rastgele pipe'lar ekle — seviyeye göre yoğunluk artar
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].type == PipeType.empty && random.nextDouble() < _decoyFillRate) {
          grid[i][j] = PipeTile(
            type: random.nextBool() ? PipeType.straight : PipeType.corner,
            rotation: random.nextInt(4),
          );
        }
      }
    }

    // Tüm pipe'ları rastgele döndür (zorlaştırma için)
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].type != PipeType.source && grid[i][j].type != PipeType.sink && grid[i][j].type != PipeType.empty) {
          grid[i][j].rotation = random.nextInt(4);
        }
      }
    }
  }

  void _createPath(int startX, int startY, int endX, int endY) {
    int currentX = startX;
    int currentY = startY;

    // Aşağıya doğru git
    while (currentY < endY) {
      currentY++;
      if (currentY < endY && grid[currentY][currentX].type == PipeType.empty) {
        grid[currentY][currentX] = PipeTile(
          type: PipeType.straight,
          rotation: 1, // Dikey
        );
      }
    }

    // Yatay hareket gerekiyorsa
    if (currentX != endX) {
      // Köşe koy
      if (grid[currentY][currentX].type == PipeType.empty) {
        grid[currentY][currentX] = PipeTile(
          type: PipeType.corner,
          rotation: currentX < endX ? 2 : 1, // Sağa gidiyorsa 2 (┐), sola gidiyorsa 1 (┌)
        );
      }

      // Yatay hareketi tamamla
      while (currentX != endX) {
        currentX += currentX < endX ? 1 : -1;
        if (currentX != endX && grid[currentY][currentX].type == PipeType.empty) {
          grid[currentY][currentX] = PipeTile(
            type: PipeType.straight,
            rotation: 0, // Yatay
          );
        }
      }

      // Son köşe (hedefe bağlantı)
      if (currentY == endY && currentX == endX - 1) {
        // Hedefe bir adım kala
      } else if (currentY == endY && currentX == endX + 1) {
        // Hedefe bir adım kala
      }
    }
  }

  void _renderGrid() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        final tile = PipeTileComponent(
          tile: grid[i][j],
          gridX: j,
          gridY: i,
          game: this,
        );
        add(tile);
      }
    }
  }

  void _checkConnections() {
    // Tüm bağlantıları sıfırla
    for (var row in grid) {
      for (var tile in row) {
        tile.isConnected = false;
      }
    }

    // Kaynaktan başlayarak BFS ile bağlı tile'ları bul
    Vector2? sourcePos;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].type == PipeType.source) {
          sourcePos = Vector2(j.toDouble(), i.toDouble());
          break;
        }
      }
      if (sourcePos != null) break;
    }

    if (sourcePos == null) return;

    final visited = <String>{};
    final queue = <Vector2>[];

    // İlk node'u işaretle ve queue'ya ekle
    final sourceKey = '${sourcePos.x.toInt()},${sourcePos.y.toInt()}';
    visited.add(sourceKey);
    queue.add(sourcePos);
    grid[sourcePos.y.toInt()][sourcePos.x.toInt()].isConnected = true;

    // Yön vektörleri: sol, üst, sağ, alt
    final directions = [
      Vector2(-1, 0), // 0: Sol
      Vector2(0, -1), // 1: Üst
      Vector2(1, 0), // 2: Sağ
      Vector2(0, 1), // 3: Alt
    ];

    while (queue.isNotEmpty) {
      final pos = queue.removeAt(0);
      final currentTile = grid[pos.y.toInt()][pos.x.toInt()];
      final connections = currentTile.getConnections();

      // Mevcut tile'ın her bağlantı yönünü kontrol et
      for (int dir in connections) {
        final newPos = pos + directions[dir];
        final newX = newPos.x.toInt();
        final newY = newPos.y.toInt();

        // Sınır kontrolü
        if (newX < 0 || newX >= gridSize || newY < 0 || newY >= gridSize) continue;

        final neighborKey = '$newX,$newY';
        if (visited.contains(neighborKey)) continue;

        final neighborTile = grid[newY][newX];
        final oppositeDir = (dir + 2) % 4; // Karşı yön

        // Komşu tile bu yönden bağlanabiliyorsa
        if (neighborTile.getConnections().contains(oppositeDir)) {
          visited.add(neighborKey);
          neighborTile.isConnected = true;
          queue.add(newPos);
        }
      }
    }

    // Kazanma kontrolü
    bool sinkConnected = false;
    for (var row in grid) {
      for (var tile in row) {
        if (tile.type == PipeType.sink && tile.isConnected) {
          sinkConnected = true;
          break;
        }
      }
      if (sinkConnected) break;
    }

    if (sinkConnected && !gameWon) {
      gameWon = true;

      // Seviye tamamlama sesi
      SoundService.playLevelComplete();

      // Standardize edilmiş skor hesapla
      final levelScore = ScoreCalculator.calculatePipesScore(
        level: currentLevel,
        moves: moveCount,
        gridSize: gridSize,
      );

      score += levelScore;

      // Skor kazanma sesi
      SoundService.playScore();

      statusText.text = '🎉 Tebrikler! +$levelScore puan!';
      scoreText.text = 'Skor: $score';

      // 2 saniye sonra sonraki seviyeye geç
      Future.delayed(const Duration(seconds: 2), () {
        currentLevel++;
        levelText.text = 'Seviye: $currentLevel';
        resetGame();
      });
    }

    // Görsel güncelleme
    children.whereType<PipeTileComponent>().forEach((component) {
      component.updateConnection();
    });
  }

  void onTileTapped(int x, int y) {
    if (gameWon) return;

    final tile = grid[y][x];
    if (tile.type == PipeType.empty) return;

    // Tıklama sesi
    SoundService.playClick();

    tile.rotate();
    moveCount++;
    moveCountText.text = 'Hamle: $moveCount';

    _checkConnections();
  }
}

class PipeTileComponent extends PositionComponent with TapCallbacks {
  final PipeTile tile;
  final int gridX;
  final int gridY;
  final PipesGame game;

  late Paint basePaint;
  late Paint connectedPaint;
  late Paint disconnectedPaint;
  late Paint sourcePaint;
  late Paint sinkPaint;

  PipeTileComponent({
    required this.tile,
    required this.gridX,
    required this.gridY,
    required this.game,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2.all(game.tileSize);
    position = game.gridOffset +
        Vector2(
          gridX * (game.tileSize + PipesGame.spacing),
          gridY * (game.tileSize + PipesGame.spacing),
        );

    basePaint = Paint()
      ..color = const Color(0xFF2d2d44)
      ..style = PaintingStyle.fill;

    connectedPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    disconnectedPaint = Paint()
      ..color = const Color(0xFF666666)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    sourcePaint = Paint()..color = const Color(0xFF4CAF50);
    sinkPaint = Paint()..color = const Color(0xFFF44336);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Arkaplan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      basePaint,
    );

    final center = size / 2;
    final paint = tile.isConnected ? connectedPaint : disconnectedPaint;

    canvas.save();
    canvas.translate(center.x, center.y);
    canvas.rotate(tile.rotation * pi / 2);
    canvas.translate(-center.x, -center.y);

    switch (tile.type) {
      case PipeType.straight:
        // Yatay çizgi (rotation ile dikey olur)
        canvas.drawLine(
          Offset(0, center.y),
          Offset(size.x, center.y),
          paint,
        );
        break;

      case PipeType.corner:
        // L şekli: soldan gelen, aşağı giden (└)
        canvas.drawLine(
          Offset(0, center.y),
          Offset(center.x, center.y),
          paint,
        );
        canvas.drawLine(
          Offset(center.x, center.y),
          Offset(center.x, size.y),
          paint,
        );
        break;

      case PipeType.source:
        canvas.restore();
        canvas.drawCircle(
          Offset(center.x, center.y),
          size.x * 0.33,
          sourcePaint,
        );
        canvas.drawCircle(
          Offset(center.x, center.y),
          size.x * 0.13,
          Paint()..color = Colors.white,
        );
        canvas.save();
        break;

      case PipeType.sink:
        canvas.restore();
        canvas.drawCircle(
          Offset(center.x, center.y),
          size.x * 0.33,
          sinkPaint,
        );
        canvas.drawCircle(
          Offset(center.x, center.y),
          size.x * 0.13,
          Paint()..color = Colors.white,
        );
        canvas.save();
        break;

      case PipeType.empty:
        break;
    }

    canvas.restore();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.onTileTapped(gridX, gridY);
  }

  void updateConnection() {
    // Render tetikle
  }
}

class NewGameButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  late Paint buttonPaint;
  late TextComponent buttonText;

  NewGameButton({
    required Vector2 position,
    required Vector2 size,
    required this.onPressed,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    buttonPaint = Paint()..color = const Color(0xFF4CAF50);

    buttonText = TextComponent(
      text: 'Yeni Oyun',
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(buttonText);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      buttonPaint,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }
}
