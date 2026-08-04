import 'package:flutter/material.dart';

/// Command types for the robot
enum CommandType {
  moveForward,
  turnRight,
  turnLeft,
  jump,
  collect,
  wait,
}

/// Command Card Widget - Draggable code command
class CommandCard extends StatelessWidget {
  final CommandType type;
  final VoidCallback? onTap;
  final bool isSmall;

  const CommandCard({
    super.key,
    required this.type,
    this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmall ? 70 : 90,
        height: isSmall ? 70 : 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getGradientColors()[0].withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              color: Colors.white,
              size: isSmall ? 28 : 36,
            ),
            const SizedBox(height: 6),
            Text(
              _getLabel(),
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmall ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (type) {
      case CommandType.moveForward:
        return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
      case CommandType.turnRight:
        return [const Color(0xFFEC4899), const Color(0xFFBE185D)];
      case CommandType.turnLeft:
        return [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)];
      case CommandType.jump:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case CommandType.collect:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case CommandType.wait:
        return [const Color(0xFF6B7280), const Color(0xFF4B5563)];
    }
  }

  IconData _getIcon() {
    switch (type) {
      case CommandType.moveForward:
        return Icons.arrow_upward;
      case CommandType.turnRight:
        return Icons.rotate_right;
      case CommandType.turnLeft:
        return Icons.rotate_left;
      case CommandType.jump:
        return Icons.flight_takeoff;
      case CommandType.collect:
        return Icons.stars;
      case CommandType.wait:
        return Icons.timer;
    }
  }

  String _getLabel() {
    switch (type) {
      case CommandType.moveForward:
        return 'İlerle';
      case CommandType.turnRight:
        return 'Sağa Dön';
      case CommandType.turnLeft:
        return 'Sola Dön';
      case CommandType.jump:
        return 'Zıpla';
      case CommandType.collect:
        return 'Topla';
      case CommandType.wait:
        return 'Bekle';
    }
  }
}

/// Draggable Command Card
class DraggableCommandCard extends StatelessWidget {
  final CommandType type;
  final bool isSmall;

  const DraggableCommandCard({
    super.key,
    required this.type,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<CommandType>(
      data: type,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: Opacity(
            opacity: 0.8,
            child: CommandCard(type: type, isSmall: isSmall),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: CommandCard(type: type, isSmall: isSmall),
      ),
      child: CommandCard(type: type, isSmall: isSmall),
    );
  }
}

/// Command Slot - Drop target for commands
class CommandSlot extends StatelessWidget {
  final CommandType? command;
  final Function(CommandType) onAccept;
  final VoidCallback? onRemove;
  final int index;

  const CommandSlot({
    super.key,
    this.command,
    required this.onAccept,
    this.onRemove,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<CommandType>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80,
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: isDraggingOver
                ? Colors.blue.shade100
                : command != null
                    ? Colors.white
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDraggingOver
                  ? Colors.blue.shade400
                  : command != null
                      ? Colors.grey.shade300
                      : Colors.grey.shade300,
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: command != null
              ? Stack(
                  children: [
                    Center(
                      child: CommandCard(
                        type: command!,
                        isSmall: true,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
