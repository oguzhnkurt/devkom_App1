import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/store_service.dart';
import '../../services/user_progress_service.dart';
import '../../services/sound_service.dart';
import '../../ui/motion.dart';
import '../../utils/lang.dart';

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

  const RobotSimulatorGameScreen({super.key, this.gameData});

  @override
  State<RobotSimulatorGameScreen> createState() =>
      _RobotSimulatorGameScreenState();
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
    // Bu ekranin ses rengi (Robot). Ekran tamamen sessizdi ve
    // bir onceki oyunun ses rengini devraliyordu.
    SoundService.useVoice(SfxVoice.deep);
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
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
      final skin =
          await _storeService.getEquippedItem(StoreItemCategory.robotSkin);
      if (!mounted) return;
      setState(() {
        if (skin != null) {
          _robotColor =
              Color(int.parse(skin.colorHex.replaceFirst('#', '0xFF')));
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
      _showMessage(_tl('🚧 Sınıra ulaşıldı, ilerlenemiyor!', '🚧 Edge reached, can\'t move further!', '🚧 Rand erreicht, es geht nicht weiter!', '🚧 Llegaste al borde, no se puede avanzar.'));
      return;
    }

    if (_grid[newY][newX] == 1) {
      _showMessage(_tl('🚧 Sensör engel algıladı, çarpışma önlendi!', '🚧 Sensor detected an obstacle, collision avoided!', '🚧 Sensor hat ein Hindernis erkannt, Zusammenstoß verhindert!', '🚧 El sensor detectó un obstáculo y evitó el choque.'));
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
    await UserProgressService()
        .addJeton(userId, jeton, source: 'robot_simulator');
    if (mounted) await auth.refreshProgress();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), duration: const Duration(milliseconds: 800)),
    );
  }

  void _showWinDialog(int gained) {
    final jeton = (gained / 4).round().clamp(5, 40);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_tl('🤖 Görev Tamamlandı!', '🤖 Mission Complete!', '🤖 Auftrag erfüllt!', '🤖 ¡Misión cumplida!')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                _tl('Seviye $_level tamamlandı.', 'Level $_level completed.', 'Level $_level geschafft.', 'Nivel $_level completado.'),
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(_tl('Puan: $_score', 'Score: $_score', 'Punkte: $_score', 'Puntos: $_score'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_tl('Hamle sayısı: $_moves', 'Moves: $_moves', 'Züge: $_moves', 'Movimientos: $_moves')),
            const SizedBox(height: 8),
            Text(
              _tl('+$jeton 🪙 jeton kazandın!', 'You earned +$jeton 🪙 coins!', 'Du hast +$jeton 🪙 Münzen verdient!', '¡Ganaste +$jeton 🪙 monedas!'),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFB8860B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _generateLevel();
            },
            child: Text(_tl('Tekrar Oyna', 'Play Again', 'Noch mal spielen', 'Jugar otra vez')),
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
            child: Text(_tl('Sonraki Seviye', 'Next Level', 'Nächstes Level', 'Siguiente nivel')),
          ),
        ],
      ),
    );
  }

  IconData get _directionIcon {
    switch (_direction) {
      case RobotDirection.up:
        return Icons.arrow_upward_rounded;
      case RobotDirection.right:
        return Icons.arrow_forward_rounded;
      case RobotDirection.down:
        return Icons.arrow_downward_rounded;
      case RobotDirection.left:
        return Icons.arrow_back_rounded;
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
        title: Text(_tl('Robot Simülatörü', 'Robot Simulator', 'Roboter-Simulator', 'Simulador de robots')),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _tl('Sv.$_level · $_score puan · $_sessionJeton 🪙', 'Lv.$_level · $_score pts · $_sessionJeton 🪙', 'Lv.$_level · $_score Punkte · $_sessionJeton 🪙', 'Nv.$_level · $_score ptos · $_sessionJeton 🪙'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white),
                ),
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
                color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
                child: Row(
                  children: [
                    const Icon(Icons.sensors_rounded, color: Color(0xFF6C63FF)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sensorDistance == 0
                            ? (_tl('⚠️ Ultrasonik sensör: hemen önde engel var!', '⚠️ Ultrasonic sensor: obstacle right ahead!', '⚠️ Ultraschallsensor: direkt voraus ist ein Hindernis!', '⚠️ Sensor ultrasónico: ¡hay un obstáculo justo delante!'))
                            : (_tl('📡 Ultrasonik sensör: önde $sensorDistance kare boşluk var', '📡 Ultrasonic sensor: $sensorDistance cells of open space ahead', '📡 Ultraschallsensor: $sensorDistance freie Felder voraus', '📡 Sensor ultrasónico: $sensorDistance casillas libres por delante')),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
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
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, kutu) {
                            // Robot hucrenin icine cizilirse her komutta bir
                            // kareden kaybolup digerinde beliriyordu. Izgara
                            // artik robotsuz ciziliyor, robot ustune
                            // AnimatedPositioned ile konuyor; boylece komut
                            // calistiginda gercekten yuruyor gibi gorunuyor.
                            const kenar = 8.0;
                            const bosluk = 3.0;
                            final hucre = (kutu.maxWidth -
                                    kenar * 2 -
                                    bosluk * (gridSize - 1)) /
                                gridSize;
                            double konum(int i) => kenar + i * (hucre + bosluk);

                            return Stack(
                              children: [
                                GridView.builder(
                                  padding: const EdgeInsets.all(kenar),
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: gridSize,
                                    mainAxisSpacing: bosluk,
                                    crossAxisSpacing: bosluk,
                                  ),
                                  itemCount: gridSize * gridSize,
                                  itemBuilder: (context, index) {
                                    final x = index % gridSize;
                                    final y = index ~/ gridSize;
                                    final isGoal = x == _goalX && y == _goalY;
                                    final isObstacle = _grid[y][x] == 1;

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: isObstacle
                                            ? Colors.grey[800]
                                            : isGoal
                                                ? Colors.green[200]
                                                : Colors.grey[50],
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: isGoal
                                            ? const Icon(Icons.flag_rounded,
                                                color: Colors.green, size: 22)
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                                AnimatedPositioned(
                                  duration:
                                      Motion.adapt(context, Motion.short4),
                                  curve: Motion.emphasized,
                                  left: konum(_robotX),
                                  top: konum(_robotY),
                                  width: hucre,
                                  height: hucre,
                                  child: Center(child: _buildAnimatedRobot()),
                                ),
                              ],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _controlButton(
                              icon: Icons.rotate_left_rounded,
                              label: _tl('Sola Dön', 'Turn Left', 'Nach links drehen', 'Girar a la izquierda'),
                              onTap: _turnLeft),
                          const SizedBox(width: 16),
                          _controlButton(
                            icon: _directionIcon,
                            label: _tl('İleri Git', 'Move Forward', 'Vorwärts gehen', 'Avanzar'),
                            onTap: _moveForward,
                            primary: true,
                          ),
                          const SizedBox(width: 16),
                          _controlButton(
                              icon: Icons.rotate_right_rounded,
                              label: _tl('Sağa Dön', 'Turn Right', 'Nach rechts drehen', 'Girar a la derecha'),
                              onTap: _turnRight),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _generateLevel,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(_tl('Haritayı Yenile', 'Refresh Map', 'Karte aktualisieren', 'Actualizar el mapa')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  /// Kuşanılan skin'e ve seviyeye (glow tier) göre animasyonlu robot görseli.
  Widget _buildAnimatedRobot() {
    if (!_robotSkinLoaded) {
      return Transform.rotate(
        angle: _directionAngle,
        child: Icon(Icons.smart_toy_rounded, color: _robotColor, size: 24),
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
                      Positioned(
                          top: 0,
                          left: 18,
                          child: Icon(Icons.auto_awesome_rounded,
                              size: 9, color: animatedColor)),
                      Positioned(
                          bottom: 0,
                          right: 2,
                          child: Icon(Icons.auto_awesome_rounded,
                              size: 7,
                              color: animatedColor.withValues(alpha: 0.7))),
                      Positioned(
                          bottom: 2,
                          left: 0,
                          child: Icon(Icons.auto_awesome_rounded,
                              size: 6,
                              color: animatedColor.withValues(alpha: 0.5))),
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
                    BoxShadow(
                        color: animatedColor.withValues(alpha: 0.6),
                        blurRadius: (10 + (tier * 2)).toDouble(),
                        spreadRadius: (1 + tier).toDouble()),
                  ],
                ),
              ),
            Transform.scale(
              scale: pulseScale,
              child: Transform.rotate(
                angle: _directionAngle,
                child: Icon(Icons.smart_toy_rounded,
                    color: animatedColor, size: 24),
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
            backgroundColor: primary
                ? const Color(0xFF6C63FF)
                : const Color(0xFF6C63FF).withValues(alpha: 0.15),
            foregroundColor: primary ? Colors.white : const Color(0xFF6C63FF),
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 4),
        // Almanca ve ispanyolca etiketler ("Nach rechts drehen") bu
        // dugmenin altinda tasiyordu; genisligi sinirlayip sariyoruz.
        SizedBox(
          width: 92,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
