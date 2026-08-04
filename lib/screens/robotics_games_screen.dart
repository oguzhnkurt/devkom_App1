import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/game_model.dart';
import '../providers/settings_provider.dart';
import '../services/games_service.dart';
import '../widgets/category_selector.dart';
import 'game_play_screen.dart';
import 'leaderboard_screen.dart';

class RoboticsGamesScreen extends StatefulWidget {
  const RoboticsGamesScreen({super.key});

  @override
  State<RoboticsGamesScreen> createState() => _RoboticsGamesScreenState();
}

class _RoboticsGamesScreenState extends State<RoboticsGamesScreen>
    with SingleTickerProviderStateMixin {
  final GamesService _gamesService = GamesService();
  GameCategory? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _starsController;

  @override
  void initState() {
    super.initState();
    // Sadece tek bir hafif animasyon
    _starsController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildLightSpaceBackground(),
          Column(
            children: [
              const SizedBox(height: 100),
              _buildCategorySelector(),
              Expanded(child: _buildGamesGrid()),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00F5FF), Color(0xFF7B2FFF), Color(0xFFFF006B)],
            ).createShader(bounds),
            child: const Text(
              'DevX',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00F5FF), Color(0xFF7B2FFF)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Interactive',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E27).withValues(alpha: 0.95), Color(0xFF1A1D3F).withValues(alpha: 0.95)],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF00F5FF)),
          onPressed: _showSearchDialog,
        ),
      ],
    );
  }

  Widget _buildLightSpaceBackground() {
    // Hafif ve optimize edilmiş arka plan - sadece 30 yıldız
    return AnimatedBuilder(
      animation: _starsController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0E27), Color(0xFF1A1D3F), Color(0xFF2D1B69)],
            ),
          ),
          child: Stack(
            children: [
              // Azaltılmış yıldız sayısı (100 -> 30)
              ...List.generate(30, (index) {
                final random = math.Random(index);
                final size = random.nextDouble() * 2 + 1;
                final x = random.nextDouble();
                final y = random.nextDouble();

                return Positioned(
                  left: MediaQuery.of(context).size.width * x,
                  top: (MediaQuery.of(context).size.height * y + _starsController.value * 100) %
                       MediaQuery.of(context).size.height,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }),
              // Statik nebula (animasyonsuz, performans için)
              Positioned(
                right: -100,
                top: 100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF7B2FFF).withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -100,
                bottom: 150,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF00F5FF).withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CategorySelector(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) => setState(() => _selectedCategory = category),
      ),
    );
  }

  Widget _buildGamesGrid() {
    // TODO: Migrate to Supabase - Using FutureBuilder instead of StreamBuilder
    return FutureBuilder<List<dynamic>>(
      future: _selectedCategory == null
          ? _gamesService.getAllGames()
          : _gamesService.getGamesByCategory(_selectedCategory!.name),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00F5FF)),
          );
        }

        var games = snapshot.data!;

        // SADECE embedded_chess satranç oyununu göster, diğer satranç oyunlarını filtrele
        games = games.where((game) {
          if (game.type == GameType.chess) {
            return game.id == 'embedded_chess';
          }
          return true;
        }).toList();

        // Quiz type oyunları Quiz kategorisine taşı ve güzel bir default resim ekle
        // Color Coding oyununu aktif et
        games = games.map((game) {
          if (game.type == GameType.quiz) {
            // Quiz için kreativ ve çekici bir görsel
            const quizThumbnail = 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=400';

            return GameModel(
              id: game.id,
              title: game.title,
              description: game.description,
              titleEn: game.titleEn,
              descriptionEn: game.descriptionEn,
              category: GameCategory.quiz,
              type: game.type,
              thumbnailUrl: quizThumbnail, // Tüm quizlere aynı güzel görseli ver
              difficulty: game.difficulty,
              estimatedMinutes: game.estimatedMinutes,
              tags: game.tags,
              isActive: game.isActive,
              createdAt: game.createdAt,
              updatedAt: game.updatedAt,
              gameData: game.gameData,
            );
          }

          // Color Coding oyununu aktif et
          if (game.type == GameType.colorCoding) {
            return GameModel(
              id: game.id,
              title: game.title,
              description: game.description,
              titleEn: game.titleEn,
              descriptionEn: game.descriptionEn,
              category: game.category,
              type: game.type,
              thumbnailUrl: game.thumbnailUrl,
              difficulty: game.difficulty,
              estimatedMinutes: game.estimatedMinutes,
              tags: game.tags,
              isActive: true, // Color Coding oyununu aktif et
              createdAt: game.createdAt,
              updatedAt: game.updatedAt,
              gameData: game.gameData,
            );
          }

          return game;
        }).toList();

        if (_selectedCategory != null) {
          games = games.where((game) => game.category == _selectedCategory).toList();
        }

        final availableGameTypes = [
          GameType.chess,
          GameType.quiz,
          GameType.coordinates,
          GameType.blockCoding,
          GameType.wordMatch,
          GameType.sequencing,
          GameType.leftRightCoding,
          GameType.pipesPuzzle,
          GameType.arduinoSimulator,
          GameType.robotSimulator,
          GameType.mazeExplorer,
          GameType.colorCoding,
        ];

        games = games.where((game) => availableGameTypes.contains(game.type)).toList();

        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          games = games.where((game) {
            return game.title.toLowerCase().contains(q) ||
                game.description.toLowerCase().contains(q) ||
                (game.titleEn?.toLowerCase().contains(q) ?? false) ||
                (game.descriptionEn?.toLowerCase().contains(q) ?? false);
          }).toList();
        }

        // Akıllı sıralama - Satranç, Bilgi Yarışması ve Robot Simülatörü
        // (en gelişmiş/görsel oyunlar) her zaman en başta gösterilir.
        games.sort((a, b) {
          const featuredOrder = {
            GameType.chess: 0,
            GameType.quiz: 1,
            GameType.robotSimulator: 2,
          };
          final aFeatured = featuredOrder[a.type];
          final bFeatured = featuredOrder[b.type];
          if (aFeatured != null || bFeatured != null) {
            if (aFeatured != null && bFeatured != null) {
              return aFeatured.compareTo(bFeatured);
            }
            return aFeatured != null ? -1 : 1;
          }

          const categoryPriority = {
            GameCategory.age4to6: 1,
            GameCategory.age7to9: 2,
            GameCategory.quiz: 3,
            GameCategory.arduino: 4,
            GameCategory.python: 5,
          };
          final aPriority = categoryPriority[a.category] ?? 99;
          final bPriority = categoryPriority[b.category] ?? 99;
          if (aPriority != bPriority) return aPriority.compareTo(bPriority);
          return a.difficulty.compareTo(b.difficulty);
        });

        if (games.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videogame_asset_off, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'Henüz oyun eklenmemiş' : 'Arama sonucu bulunamadı',
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return _OptimizedGameCard(
              game: game,
              index: index,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GamePlayScreen(game: game)),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D3F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Color(0xFF00F5FF).withValues(alpha: 0.5), width: 2),
        ),
        title: const Text('Oyun Ara', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Oyun adı...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF00F5FF)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Color(0xFF00F5FF).withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF00F5FF), width: 2),
            ),
          ),
          onSubmitted: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Temizle', style: TextStyle(color: Color(0xFFFF006B))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _searchQuery = _searchController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00F5FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }
}

/// Optimize edilmiş oyun kartı - daha hafif animasyonlar
class _OptimizedGameCard extends StatefulWidget {
  final GameModel game;
  final int index;
  final VoidCallback onTap;

  const _OptimizedGameCard({
    required this.game,
    required this.index,
    required this.onTap,
  });

  @override
  State<_OptimizedGameCard> createState() => _OptimizedGameCardState();
}

class _OptimizedGameCardState extends State<_OptimizedGameCard> {
  bool _isPressed = false;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  Color _getGameColor() {
    switch (widget.game.category) {
      case GameCategory.age4to6: return const Color(0xFF00F5FF);
      case GameCategory.age7to9: return const Color(0xFF7B2FFF);
      case GameCategory.quiz: return const Color(0xFFFF006B);
      case GameCategory.arduino: return const Color(0xFF00FF88);
      case GameCategory.python: return const Color(0xFFFFD700);
      case GameCategory.robotics: return const Color(0xFFFF6B35);
      case GameCategory.software: return const Color(0xFF4ECDC4);
    }
  }

  IconData _getGameIcon() {
    switch (widget.game.type) {
      case GameType.chess: return Icons.casino;
      case GameType.quiz: return Icons.quiz;
      case GameType.leftRightCoding: return Icons.directions;
      case GameType.coordinates: return Icons.grid_on;
      case GameType.blockCoding: return Icons.code;
      case GameType.wordMatch: return Icons.language;
      case GameType.sequencing: return Icons.sort;
      case GameType.arduinoSimulator: return Icons.memory;
      case GameType.pipesPuzzle: return Icons.plumbing;
      case GameType.robotSimulator: return Icons.precision_manufacturing;
      case GameType.mazeExplorer: return Icons.explore;
      case GameType.colorCoding: return Icons.palette;
      case GameType.matchingGame: return Icons.join_inner;
      default: return Icons.videogame_asset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getGameColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..scaleByDouble(
            _isPressed ? 0.95 : 1.0,
            _isPressed ? 0.95 : 1.0,
            _isPressed ? 0.95 : 1.0,
            1.0,
          ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
            ),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zorluk, Süre ve Sıralama
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color),
                          ),
                          child: Row(
                            children: List.generate(
                              widget.game.difficulty,
                              (i) => Icon(Icons.star, size: 12, color: color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Trophy Button - Leaderboard'a götür
                        GestureDetector(
                          onTap: () {
                            // Leaderboard ekranına git
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaderboardScreen(
                                  gameId: widget.game.id,
                                  gameName: widget.game.titleFor(_lang),
                                  gameType: widget.game.type,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              size: 14,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.white.withValues(alpha: 0.8)),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.game.estimatedMinutes}dk',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Oyun Görseli
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: widget.game.thumbnailUrl.isNotEmpty
                          ? Image.network(
                              widget.game.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [color, color.withValues(alpha: 0.5)],
                                    ),
                                  ),
                                  child: Icon(_getGameIcon(), color: Colors.white, size: 35),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [color, color.withValues(alpha: 0.5)],
                                    ),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [color, color.withValues(alpha: 0.5)],
                                ),
                              ),
                              child: Icon(_getGameIcon(), color: Colors.white, size: 35),
                            ),
                    ),
                  ),
                ),
                const Spacer(),
                // Başlık
                Text(
                  widget.game.titleFor(_lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Kategori
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    widget.game.getCategoryDisplayNameFor(_lang),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
