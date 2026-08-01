import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/store_service.dart';
import '../../services/user_progress_service.dart';

/// Robot Simülatörü
/// Basit bir grid üzerinde sanal robotu sensörlerle birlikte programlayıp
/// hedefe ulaştırma oyunu. Robotun görünümü, Market'te satın alınıp
/// kuşanılan "robot kılıfı" (skin) rengine göre değişir; seviye arttıkça
/// robot daha parlak/hareketli hale gelir (parıltı halkası, nabız animasyonu,
/// dönen yıldız parçacıkları). Kazanılan puanlar hem XP hem de Market'te
/// harcanabilir jetona dönüşür ve kalıcı olarak user_progress'e işlenir.
/// Bkz. supabase/migrations/23_store_and_jeton_economy.sql
enum RobotDirection { up, right, down, left }

class RobotSimulatorGameScreen extends StatefulWidget {
  final Map<String, dynamic>? gameData;

  const RobotSimulatorGameScreen({Key? key, this.gameData}) : super(key: key);

  @override
  State<RobotSimulatorGameScreen> createState() => _RobotSimulatorGameScreenState();
}

class _RobotSimulatorGameScreenState extends State<RobotSimulatorGameScreen>
    with SingleTickerProviderStateMixin {
  static const int gridSize = 6;

  int _level = 1;
  int _score = 0;
  int _moves = 0;
  int _sessionJeton = 0;

  int _robotX = 0;
  int _robotY = 0;
  RobotDirection _direction = RobotDirection.right;

  int _goalX = 5;
  int _goalY = 5;

  // 0 = empty, 1 = obstacle
  List<List<int>> _grid = [];
  final Random _rng = Random();

  final StoreService _storeService = StoreService();
  Color _robotColor = const Color(0xFF9AA5B1);
  bool _isRainbowSkin = false;
  bool _robotSkinLoaded = false;

  late final AnimationController _pulseController;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _generateLevel();
    _loadEquippedSkin();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadEquippedSkin() async {
    try {
      final skin = await _storeService.getEquippedItem(StoreItemCategory.robotSkin);
      if (!mounted) return;
      setState(() {
        if (skin != null) {
          _robotColor = Color(int.parse(skin.colorHex.replaceFirst('#', '0xFF')));
          _isRainbowSkin = skin.itemKey == 'robot_rainbow';
        }
        _robotSkinLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _robotSkinLoaded = true);
    }
  }

  /// Robotun "parlaklık evresi": seviye arttıkça görsel efektler katmanlanır.
  /// 1-2: düz renk. 3-4: parıltı halkası. 5-6: + nabız animasyonu.
  /// 7+: + dönen yıldız parçacıkları.
  int get _glowTier {
    if (_level >= 7) return 3;
    if (_level >= 5) return 2;
    if (_level >= 3) return 1;
    return 0;
  }

  void _generateLevel() {
    _robotX = 0;
    _robotY = 0;
    _direction = RobotDirection.right;
    _moves = 0;
    _goalX = gridSize - 1;
    _goalY = gridSize - 1;

    // Garanti bir yol oy (labirent oyunundaki ile aynı yaklaşım),
    // sonra kalan hücrelere rastgele engel dağıt. Böylece robot her zaman
    // hedefe ulaşabilir, "sıkışma" hatası oluşmaz.
    final Set<String> guaranteedPath = {};
    int cx = 0, cy = 0;
    guaranteedPath.add('$cx,$cy');
    while (cx != _goalX || cy != _goalY) {
      final canRight = cx < _goalX;
      final canDown = cy < _goalY;
      if (canRight && (!canDown || _rng.nextBool())) {
        cx++;
      } else if (canDown) {
        cy++;
      }
      guaranteedPath.add('$cx,$cy');
    }

    _grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => 0));
    final obstacleDensity = 0.15 + (_level * 0.02).clamp(0.0, 0.15);
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (guaranteedPath.contains('$x,$y')) continue;
        if (_rng.nextDouble() < obstacleDensity) {
          _grid[y][x] = 1;
        }
      }
    }

    setState(() {});
  }

  // Sensörün baktığı yöndeki en yakın engele/duvara olan mesafe (hücre sayısı)
  int _sensorDistanceAhead() {
    int dx = 0, dy = 0;
    switch (_direction) {
      case RobotDirection.up:
        dy = -1;
        break;
      case RobotDirection.right:
        dx = 1;
        break;
      case RobotDirection.down:
        dy = 1;
        break;
      case RobotDirection.left:
        dx = -1;
        break;
    }

    int x = _robotX;
    int y = _robotY;
    int distance = 0;
    while (true) {
      x += dx;
      y += dy;
      if (x < 0 || x >= gridSize || y < 0 || y >= gridSize) break;
      distance++;
      if (_grid[y][x] == 1) break;
    }
    return distance;
  }

  void _turnLeft() {
    setState(() {
      _direction = RobotDirection.values[(_direction.index - 1 + 4) % 4];
    });
  }

  void _turnRight() {
    setState(() {
      _direction = RobotDirection.values[(_direction.index + 1) % 4];
    });
  }

  void _moveForward() {
    int dx = 0, dy = 0;
    switch (_direction) {
      case RobotDirection.up:
        dy = -1;
        break;
      case RobotDirection.right:
        dx = 1;
        break;
      case RobotDirection.down:
        dy = 1;
        break;
      case RobotDirection.left:
        dx = -1;
        break;
    }

    final newX = _robotX + dx;
    final newY = _robotY + dy;

    if (newX < 0 || newX >= gridSize || newY < 0 || newY >= gridSize) {
      _showMessage(_isEn ? '🚧 Edge reached, can\'t move further!' : '🚧 Sınıra ulaşıldı, ilerlenemiyor!');
      return;
    }

    if (_grid[newY][newX] == 1) {
      _showMessage(_isEn ? '🚧 Sensor detected an obstacle, collision avoided!' : '🚧 Sensör engel algıladı, çarpışma önlendi!');
      return;
    }

    setState(() {
      _robotX = newX;
      _robotY = newY;
      _moves++;
    });

    if (_robotX == _goalX && _robotY == _goalY) {
      final gained = max(100 - _moves * 2, 20);
      _score += gained;
      _awardProgress(gained);
      _showWinDialog(gained);
    }
  }

  /// Kazanılan skoru kalıcı XP ve jetona çevirir (user_progress).
  Future<void> _awardProgress(int gained) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.currentUser?.uid;
    if (userId == null) return;
    final jeton = (gained / 4).round().clamp(5, 40);
    setState(() => _sessionJeton += jeton);
    await auth.addXP((gained / 5).round());
    await UserProgressService().addJeton(userId, jeton, source: 'robot_simulator');
    if (mounted) await auth.refreshProgress();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(milliseconds: 800)),
    );
  }

  void _showWinDialog(int gained) {
    final jeton = (gained / 4).round().clamp(5, 40);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_isEn ? '🤖 Mission Complete!' : '🤖 Görev Tamamlandı!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isEn ? 'Level $_level completed.' : 'Seviye $_level tamamlandı.', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(_isEn ? 'Score: $_score' : 'Puan: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_isEn ? 'Moves: $_moves' : 'Hamle sayısı: $_moves'),
            const SizedBox(height: 8),
            Text(
              _isEn ? 'You earned +$jeton 🪙 coins!' : '+$jeton 🪙 jeton kazandın!',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB8860B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateLevel();
            },
            child: Text(_isEn ? 'Play Again' : 'Tekrar Oyna'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _level++);
              _generateLevel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
            child: Text(_isEn ? 'Next Level' : 'Sonraki Seviye'),
          ),
        ],
      ),
    );
  }

  IconData get _directionIcon {
    switch (_direction) {
      case RobotDirection.up:
        return Icons.arrow_upward;
      case RobotDirection.right:
        return Icons.arrow_forward;
      case RobotDirection.down:
        return Icons.arrow_downward;
      case RobotDirection.left:
        return Icons.arrow_back;
    }
  }

  double get _directionAngle {
    switch (_direction) {
      case RobotDirection.up:
        return 0;
      case RobotDirection.right:
        return pi / 2;
      case RobotDirection.down:
        return pi;
      case RobotDirection.left:
        return -pi / 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sensorDistance = _sensorDistanceAhead();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEn ? 'Robot Simulator' : 'Robot Simülatörü'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isEn ? 'Lv.$_level · $_score pts · $_sessionJeton 🪙' : 'Sv.$_level · $_score puan · $_sessionJeton 🪙',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            color: const Color(0xFF6C63FF).withOpacity(0.08),
            child: Row(
              children: [
                const Icon(Icons.sensors, color: Color(0xFF6C63FF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sensorDistance == 0
                        ? (_isEn ? '⚠️ Ultrasonic sensor: obstacle right ahead!' : '⚠️ Ultrasonik sensör: hemen önde engel var!')
                        : (_isEn ? '📡 Ultrasonic sensor: $sensorDistance cells of open space ahead' : '📡 Ultrasonik sensör: önde $sensorDistance kare boşluk var'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3,
                      ),
                      itemCount: gridSize * gridSize,
                      itemBuilder: (context, index) {
                        final x = index % gridSize;
                        final y = index ~/ gridSize;
                        final isRobot = x == _robotX && y == _robotY;
                        final isGoal = x == _goalX && y == _goalY;
                        final isObstacle = _grid[y][x] == 1;

                        return Container(
                          decoration: BoxDecoration(
                            color: isObstacle
                                ? Colors.grey[800]
                                : isGoal
                                    ? Colors.green[200]
                                    : Colors.grey[50],
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: isRobot
                                ? _buildAnimatedRobot()
                                : isGoal
                                    ? const Icon(Icons.flag, color: Colors.green, size: 22)
                                    : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _controlButton(icon: Icons.rotate_left, label: _isEn ? 'Turn Left' : 'Sola Dön', onTap: _turnLeft),
                      const SizedBox(width: 16),
                      _controlButton(
                        icon: _directionIcon,
                        label: _isEn ? 'Move Forward' : 'İleri Git',
                        onTap: _moveForward,
                        primary: true,
                      ),
                      const SizedBox(width: 16),
                      _controlButton(icon: Icons.rotate_right, label: _isEn ? 'Turn Right' : 'Sağa Dön', onTap: _turnRight),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _generateLevel,
                    icon: const Icon(Icons.refresh),
                    label: Text(_isEn ? 'Refresh Map' : 'Haritayı Yenile'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kuşanılan skin'e ve seviyeye (glow tier) göre animasyonlu robot görseli.
  Widget _buildAnimatedRobot() {
    if (!_robotSkinLoaded) {
      return Transform.rotate(
        angle: _directionAngle,
        child: Icon(Icons.smart_toy, color: _robotColor, size: 24),
      );
    }

    final tier = _glowTier;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final t = _pulseController.value; // 0..1 döngüsel
        // Rainbow kılıf: renk sürekli döngüsel değişir.
        final hue = (t * 360) % 360;
        final animatedColor = _isRainbowSkin
            ? HSVColor.fromAHSV(1, hue, 0.7, 0.95).toColor()
            : _robotColor;
        final pulseScale = tier >= 2 ? 1.0 + (sin(t * 2 * pi) * 0.08) : 1.0;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (tier >= 3)
              Transform.rotate(
                angle: t * 2 * pi,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    children: [
                      Positioned(top: 0, left: 18, child: Icon(Icons.auto_awesome, size: 9, color: animatedColor)),
                      Positioned(bottom: 0, right: 2, child: Icon(Icons.auto_awesome, size: 7, color: animatedColor.withOpacity(0.7))),
                      Positioned(bottom: 2, left: 0, child: Icon(Icons.auto_awesome, size: 6, color: animatedColor.withOpacity(0.5))),
                    ],
                  ),
                ),
              ),
            if (tier >= 1)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: animatedColor.withOpacity(0.6), blurRadius: (10 + (tier * 2)).toDouble(), spreadRadius: (1 + tier).toDouble()),
                  ],
                ),
              ),
            Transform.scale(
              scale: pulseScale,
              child: Transform.rotate(
                angle: _directionAngle,
                child: Icon(Icons.smart_toy, color: animatedColor, size: 24),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          iconSize: primary ? 40 : 32,
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: primary ? const Color(0xFF6C63FF) : const Color(0xFF6C63FF).withOpacity(0.15),
            foregroundColor: primary ? Colors.white : const Color(0xFF6C63FF),
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
