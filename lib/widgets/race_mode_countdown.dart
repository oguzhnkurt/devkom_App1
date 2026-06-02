import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

/// Race Mode Countdown Widget
/// Shows animated countdown before game starts
class RaceModeCountdown extends StatefulWidget {
  final int countdownSeconds;
  final VoidCallback onCountdownComplete;
  final String? title;

  const RaceModeCountdown({
    Key? key,
    this.countdownSeconds = 3,
    required this.onCountdownComplete,
    this.title,
  }) : super(key: key);

  @override
  State<RaceModeCountdown> createState() => _RaceModeCountdownState();
}

class _RaceModeCountdownState extends State<RaceModeCountdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Timer _timer;
  int _currentCount = 0;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.countdownSeconds;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _animationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCount > 1) {
        setState(() {
          _currentCount--;
          _animationController.reset();
          _animationController.forward();
        });
      } else {
        timer.cancel();
        widget.onCountdownComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
            ],
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.red.shade600,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _currentCount.toString(),
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Hazır ol!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live Score Ticker Widget
/// Shows real-time score updates for race mode
class LiveScoreTicker extends StatelessWidget {
  final Stream<List<ScoreUpdate>> scoresStream;
  final Duration displayDuration;

  const LiveScoreTicker({
    Key? key,
    required this.scoresStream,
    this.displayDuration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScoreUpdate>>(
      stream: scoresStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final updates = snapshot.data!.take(3).toList();

        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'CANLI SKORLAR',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...updates.map((update) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          update.isImprovement ? Icons.trending_up : Icons.emoji_events,
                          color: update.isImprovement ? Colors.green : Colors.yellow,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${update.userName}: ${update.score} puan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

/// Live Leaderboard Mini Widget
/// Shows top 5 scores in a compact format during gameplay
class LiveLeaderboardMini extends StatelessWidget {
  final Stream<List<LeaderboardMiniEntry>> leaderboardStream;
  final String? currentUserId;

  const LiveLeaderboardMini({
    Key? key,
    required this.leaderboardStream,
    this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LeaderboardMiniEntry>>(
      stream: leaderboardStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.data!.take(5).toList();

        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'TOP 5',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 16),
              ...entries.asMap().entries.map((entry) {
                final index = entry.key;
                final leaderboardEntry = entry.value;
                final isCurrentUser = leaderboardEntry.userId == currentUserId;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${index + 1}.',
                          style: TextStyle(
                            color: index == 0
                                ? Colors.amber
                                : index == 1
                                    ? Colors.grey.shade300
                                    : index == 2
                                        ? Colors.brown.shade300
                                        : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          leaderboardEntry.userName,
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.white70,
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${leaderboardEntry.score}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// Score Update Model
class ScoreUpdate {
  final String userName;
  final int score;
  final bool isImprovement;
  final DateTime timestamp;

  ScoreUpdate({
    required this.userName,
    required this.score,
    required this.isImprovement,
    required this.timestamp,
  });
}

/// Leaderboard Mini Entry Model
class LeaderboardMiniEntry {
  final String userId;
  final String userName;
  final int score;

  LeaderboardMiniEntry({
    required this.userId,
    required this.userName,
    required this.score,
  });
}
