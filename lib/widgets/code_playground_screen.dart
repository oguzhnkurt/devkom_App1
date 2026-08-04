import 'package:flutter/material.dart';
import 'code_playground/command_card.dart';
import 'code_playground/robot_character.dart';
import 'animated_gradient_background.dart';
import 'dart:async';

/// Code Playground Screen - Interactive coding game
class CodePlaygroundScreen extends StatefulWidget {
  const CodePlaygroundScreen({super.key});

  @override
  State<CodePlaygroundScreen> createState() => _CodePlaygroundScreenState();
}

class _CodePlaygroundScreenState extends State<CodePlaygroundScreen>
    with TickerProviderStateMixin {
  // Grid state
  int _robotX = 0;
  int _robotY = 0;
  int _robotDirection = 0; // 0: up, 1: right, 2: down, 3: left
  final int _gridSize = 5;

  // Commands
  List<CommandType?> _commandQueue = List.filled(8, null);
  bool _isExecuting = false;
  int _currentCommandIndex = -1;

  // Level state
  final List<Point> _collectables = [
    Point(2, 1),
    Point(4, 3),
  ];
  final List<Point> _collectedStars = [];
  final Point _startPos = Point(0, 0);
  final Point _endPos = Point(4, 4);

  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _addCommand(int index, CommandType command) {
    setState(() {
      _commandQueue[index] = command;
    });
  }

  void _removeCommand(int index) {
    setState(() {
      _commandQueue[index] = null;
    });
  }

  void _clearCommands() {
    setState(() {
      _commandQueue = List.filled(8, null);
      _resetRobot();
    });
  }

  void _resetRobot() {
    setState(() {
      _robotX = _startPos.x;
      _robotY = _startPos.y;
      _robotDirection = 0;
      _collectedStars.clear();
      _currentCommandIndex = -1;
    });
  }

  Future<void> _executeCommands() async {
    if (_isExecuting) return;

    _resetRobot();
    setState(() {
      _isExecuting = true;
    });

    final commands = _commandQueue.where((c) => c != null).toList();

    for (int i = 0; i < commands.length; i++) {
      setState(() {
        _currentCommandIndex = i;
      });

      await _executeCommand(commands[i]!);
      await Future.delayed(const Duration(milliseconds: 300));

      _checkCollectable();
    }

    _checkLevelComplete();

    setState(() {
      _isExecuting = false;
      _currentCommandIndex = -1;
    });
  }

  Future<void> _executeCommand(CommandType command) async {
    switch (command) {
      case CommandType.moveForward:
        await _moveForward();
        break;
      case CommandType.turnRight:
        _turnRight();
        break;
      case CommandType.turnLeft:
        _turnLeft();
        break;
      case CommandType.jump:
        await _jump();
        break;
      case CommandType.collect:
        _collect();
        break;
      case CommandType.wait:
        await Future.delayed(const Duration(milliseconds: 500));
        break;
    }
  }

  Future<void> _moveForward() async {
    int newX = _robotX;
    int newY = _robotY;

    switch (_robotDirection) {
      case 0: // up
        newY = (_robotY - 1).clamp(0, _gridSize - 1);
        break;
      case 1: // right
        newX = (_robotX + 1).clamp(0, _gridSize - 1);
        break;
      case 2: // down
        newY = (_robotY + 1).clamp(0, _gridSize - 1);
        break;
      case 3: // left
        newX = (_robotX - 1).clamp(0, _gridSize - 1);
        break;
    }

    setState(() {
      _robotX = newX;
      _robotY = newY;
    });

    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _turnRight() {
    setState(() {
      _robotDirection = (_robotDirection + 1) % 4;
    });
  }

  void _turnLeft() {
    setState(() {
      _robotDirection = (_robotDirection - 1) % 4;
      if (_robotDirection < 0) _robotDirection = 3;
    });
  }

  Future<void> _jump() async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  void _collect() {
    _checkCollectable();
  }

  void _checkCollectable() {
    final robotPos = Point(_robotX, _robotY);
    final collectable = _collectables.firstWhere(
      (c) => c.x == robotPos.x && c.y == robotPos.y,
      orElse: () => Point(-1, -1),
    );

    if (collectable.x != -1 && !_collectedStars.contains(collectable)) {
      setState(() {
        _collectedStars.add(collectable);
      });
    }
  }

  void _checkLevelComplete() {
    if (_robotX == _endPos.x &&
        _robotY == _endPos.y &&
        _collectedStars.length == _collectables.length) {
      _successController.forward();
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF10B981),
                Color(0xFF059669),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                color: Colors.white,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tebrikler!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seviyeyi başarıyla tamamladın!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _clearCommands();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Oyna'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.home),
                    label: const Text('Ana Menü'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        colors: const [
          Color(0xFF6366F1),
          Color(0xFF8B5CF6),
          Color(0xFFEC4899),
        ],
        opacity: 0.15,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    // Command Palette (left side)
                    Expanded(
                      flex: 1,
                      child: _buildCommandPalette(),
                    ),

                    // Main content (right side)
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // Game Grid
                          Expanded(
                            flex: 3,
                            child: _buildGameGrid(),
                          ),

                          const SizedBox(height: 12),

                          // Command Queue
                          _buildCommandQueue(),

                          const SizedBox(height: 12),

                          // Control Buttons
                          _buildControlButtons(),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Kod Macerası',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_collectedStars.length}/${_collectables.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandPalette() {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.construction,
                  color: Colors.purple.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Komutlar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  DraggableCommandCard(type: CommandType.moveForward),
                  DraggableCommandCard(type: CommandType.turnRight),
                  DraggableCommandCard(type: CommandType.turnLeft),
                  DraggableCommandCard(type: CommandType.jump),
                  DraggableCommandCard(type: CommandType.collect),
                  DraggableCommandCard(type: CommandType.wait),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridSize,
          childAspectRatio: 1,
        ),
        itemCount: _gridSize * _gridSize,
        itemBuilder: (context, index) {
          final x = index % _gridSize;
          final y = index ~/ _gridSize;
          final hasCollectable = _collectables.any((c) => c.x == x && c.y == y) &&
              !_collectedStars.any((c) => c.x == x && c.y == y);

          return GameGridTile(
            isStart: x == _startPos.x && y == _startPos.y,
            isEnd: x == _endPos.x && y == _endPos.y,
            hasCollectable: hasCollectable,
            hasRobot: x == _robotX && y == _robotY,
            direction: _robotDirection,
          );
        },
      ),
    );
  }

  Widget _buildCommandQueue() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Komut Sırası',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                8,
                (index) => Container(
                  decoration: _currentCommandIndex == index
                      ? BoxDecoration(
                          border: Border.all(
                            color: Colors.green.shade400,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        )
                      : null,
                  child: CommandSlot(
                    index: index,
                    command: _commandQueue[index],
                    onAccept: (command) => _addCommand(index, command),
                    onRemove: () => _removeCommand(index),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isExecuting ? null : _clearCommands,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.delete_sweep),
              label: const Text(
                'Temizle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isExecuting ? null : _executeCommands,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              icon: _isExecuting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.play_arrow, size: 28),
              label: Text(
                _isExecuting ? 'Çalışıyor...' : 'Çalıştır!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple Point class
class Point {
  final int x;
  final int y;

  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
