import 'package:flutter/material.dart';

import '../models/game_model.dart';
import '../theme.dart';

/// Bir oyunun gorsel kimligi: simge ve renk.
///
/// Oyunlar sekmesindeki kart ve oyunun kendi ekranindaki baslik
/// (`OyunBasligi`) ayni degerleri buradan aliyor. Cocuk turuncu bir karta
/// dokunup mavi bir ekrana dusmesin.
class OyunKimligi {
  OyunKimligi._();

  static IconData simge(GameType type) => switch (type) {
        GameType.chess => Icons.castle_rounded,
        GameType.quiz => Icons.emoji_events_rounded,
        GameType.blockCoding => Icons.widgets_rounded,
        GameType.wordMatch => Icons.abc_rounded,
        GameType.sequencing => Icons.reorder_rounded,
        GameType.coordinates => Icons.grid_4x4_rounded,
        GameType.mazeExplorer => Icons.route_rounded,
        GameType.colorCoding => Icons.palette_rounded,
        GameType.robotSimulator => Icons.smart_toy_rounded,
        GameType.leftRightCoding => Icons.turn_right_rounded,
        GameType.arduinoSimulator => Icons.memory_rounded,
        GameType.pipesPuzzle => Icons.water_drop_rounded,
        GameType.patternDetective => Icons.pattern_rounded,
        GameType.variableMaster => Icons.inventory_2_rounded,
        GameType.bugHunter => Icons.pest_control_rounded,
        GameType.matchingGame => Icons.join_inner_rounded,
        GameType.puzzle => Icons.extension_rounded,
        GameType.simulation => Icons.science_rounded,
      };

  /// Aynı aileden oyunlar aynı rengi paylaşıyor: mavi = mantık/algoritma,
  /// mor = bloklar, turuncu = quiz, yeşil = robotik.
  static Color renk(GameType type) => switch (type) {
        // Ekim 2026: ayni bolumdeki oyunlar artik ayni rengi paylasmiyor
        // (oyunlar sekmesinde yan yana uc mavi kart vardi).
        GameType.chess => const Color(0xFF455A64),
        GameType.quiz => const Color(0xFFF57C00),
        GameType.blockCoding => const Color(0xFFFF8C1A),
        GameType.sequencing => const Color(0xFF43A047),
        GameType.wordMatch => const Color(0xFF00897B),
        GameType.matchingGame => const Color(0xFF7E57C2),
        GameType.coordinates => const Color(0xFF5C6BC0),
        GameType.mazeExplorer => const Color(0xFFF4511E),
        GameType.leftRightCoding => const Color(0xFF1E88E5),
        GameType.patternDetective => const Color(0xFF8E24AA),
        GameType.variableMaster => const Color(0xFF3949AB),
        GameType.bugHunter => const Color(0xFFD81B60),
        GameType.colorCoding => const Color(0xFFEC407A),
        GameType.robotSimulator => const Color(0xFF43A047),
        GameType.arduinoSimulator => const Color(0xFF00897B),
        GameType.pipesPuzzle => const Color(0xFF0097A7),
        GameType.puzzle => AppTheme.mediumGray,
        GameType.simulation => AppTheme.mediumGray,
      };

}
