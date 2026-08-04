import 'dart:math';
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../data/courses_data.dart';
import 'course_detail_screen.dart';
import 'interactive_course_screen.dart';

/// Course Catalog Screen - Main course listing
class CourseCatalogScreen extends StatefulWidget {
  const CourseCatalogScreen({super.key});

  @override
  State<CourseCatalogScreen> createState() => _CourseCatalogScreenState();
}

class _CourseCatalogScreenState extends State<CourseCatalogScreen> {
  CourseCategory? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Course> get filteredCourses {
    var courses = CoursesData.allCourses;

    if (_selectedCategory != null) {
      courses = courses.where((c) => c.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      courses = CoursesData.search(_searchQuery);
      if (_selectedCategory != null) {
        courses = courses.where((c) => c.category == _selectedCategory).toList();
      }
    }

    return courses;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark),
          SliverToBoxAdapter(child: _buildSearchBar(isDark)),
          SliverToBoxAdapter(child: _buildCategoryFilter(isDark)),
          SliverToBoxAdapter(child: _buildCourseCount(isDark)),
          _buildCourseGrid(isDark),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚀 ', style: TextStyle(fontSize: 20)),
            Text(
              'Kurslar',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Space background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A1A2E), const Color(0xFF0A0A0F)]
                      : [const Color(0xFFE8EAF6), const Color(0xFFF5F7FA)],
                ),
              ),
            ),
            // Stars
            CustomPaint(
              painter: _StarsPainter(isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            hintText: 'Kurs ara... (ornegin: Python, Web)',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    final categories = [
      (null, 'Tumu', '🌟'),
      (CourseCategory.kids, 'Baslangic', '🧩'),
      (CourseCategory.web, 'Web', '🌐'),
      (CourseCategory.mobile, 'Mobil', '📱'),
      (CourseCategory.systems, 'Sistem', '⚙️'),
      (CourseCategory.robotics, 'Robotik', '🤖'),
      (CourseCategory.data, 'Veri/AI', '📊'),
      (CourseCategory.scripting, 'Script', '💻'),
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final (category, label, emoji) = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(label),
                ],
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              selectedColor: const Color(0xFF667eea).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF667eea),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF667eea)
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF667eea)
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseCount(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${filteredCourses.length} kurs bulundu',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          if (_selectedCategory != null || _searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              child: const Text(
                'Temizle',
                style: TextStyle(color: Color(0xFF667eea)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseGrid(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = filteredCourses[index];
            return _CourseCard(course: course, isDark: isDark);
          },
          childCount: filteredCourses.length,
        ),
      ),
    );
  }
}

/// Individual Course Card
class _CourseCard extends StatelessWidget {
  final Course course;
  final bool isDark;

  const _CourseCard({required this.course, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Interaktif ders sistemi olan kurslar, diğerleri için CourseDetailScreen
        const interactiveCourseIds = {
          'scratch', 'python', 'arduino', 'html', 'css', 'java', 'csharp',
        };
        if (interactiveCourseIds.contains(course.id)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InteractiveCourseScreen(course: course),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              course.primaryColor.withValues(alpha: 0.9),
              course.secondaryColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: course.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Stars overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: _MiniStarsPainter(),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      course.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    course.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Difficulty badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      course.difficultyText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Stats
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${course.totalLessons} ders',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        course.estimatedTimeText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Premium badge
            if (course.isPremium)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Stars painter for app bar background
class _StarsPainter extends CustomPainter {
  final bool isDark;
  _StarsPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = Random(42);

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 2 + 0.5;
      final opacity = random.nextDouble() * 0.5 + 0.2;

      paint.color = (isDark ? Colors.white : const Color(0xFF667eea)).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mini stars for course cards
class _MiniStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    final random = Random(42);

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 1.5 + 0.3;

      paint.color = Colors.white.withValues(alpha: random.nextDouble() * 0.3 + 0.1);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
