import 'package:flutter/material.dart';
import '../models/game_model.dart';

class CategorySelector extends StatelessWidget {
  final GameCategory? selectedCategory;
  final Function(GameCategory?) onCategorySelected;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCategoryChip(
            context,
            label: 'Tümü',
            icon: Icons.apps,
            color: Colors.grey,
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: 12),
          _buildCategoryChip(
            context,
            label: 'Quiz',
            icon: Icons.quiz,
            color: const Color(0xFFFF6B35),
            isSelected: selectedCategory == GameCategory.quiz,
            onTap: () => onCategorySelected(GameCategory.quiz),
          ),
          const SizedBox(width: 12),
          _buildCategoryChip(
            context,
            label: 'Arduino',
            icon: Icons.memory,
            color: const Color(0xFF2196F3),
            isSelected: selectedCategory == GameCategory.arduino,
            onTap: () => onCategorySelected(GameCategory.arduino),
          ),
          const SizedBox(width: 12),
          _buildCategoryChip(
            context,
            label: 'Python',
            icon: Icons.code,
            color: const Color(0xFF4CAF50),
            isSelected: selectedCategory == GameCategory.python,
            onTap: () => onCategorySelected(GameCategory.python),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.7)],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
              size: 16,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int gameCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gameCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with background
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Game Count Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videogame_asset,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$gameCount Oyun',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
