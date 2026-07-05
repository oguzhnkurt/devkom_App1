import 'dart:math';
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../data/scratch_lessons_data.dart';
import '../data/python_lessons_data.dart';
import '../data/arduino_lessons_data.dart';
import 'interactive_lesson_screen.dart';

/// Genel Interaktif Kurs Ekrani
/// Tum kurslar icin kullanilabilir
class InteractiveCourseScreen extends StatefulWidget {
  final Course course;

  const InteractiveCourseScreen({super.key, required this.course});

  @override
  State<InteractiveCourseScreen> createState() => _InteractiveCourseScreenState();
}

class _InteractiveCourseScreenState extends State<InteractiveCourseScreen> {
  int _selectedModule = 0;
  late List<_ModuleInfo> _modules;

  @override
  void initState() {
    super.initState();
    _loadCourseModules();
  }

  void _loadCourseModules() {
    switch (widget.course.id) {
      case 'scratch':
        _modules = [
          _ModuleInfo(
            title: 'Scratch\'a Merhaba',
            description: 'Blok programlamaya ilk adim',
            emoji: '👋',
            lessons: ScratchLessonsData.module1,
          ),
          _ModuleInfo(
            title: 'Etkilesim & Kontrol',
            description: 'Kosullar ve hareket',
            emoji: '🎮',
            lessons: ScratchLessonsData.module2,
          ),
          _ModuleInfo(
            title: 'Ilk Oyunun',
            description: 'Gercek bir oyun yap!',
            emoji: '🚀',
            lessons: ScratchLessonsData.module3,
          ),
          _ModuleInfo(
            title: 'Degiskenler & Puan',
            description: 'Bilgiyi sakla, puan tut',
            emoji: '🔢',
            lessons: ScratchLessonsData.module4,
          ),
          _ModuleInfo(
            title: 'Klonlar',
            description: 'Kuklalari cogalt',
            emoji: '👯',
            lessons: ScratchLessonsData.module5,
          ),
          _ModuleInfo(
            title: 'Mesajlar & Yayinlar',
            description: 'Kuklalar arasi iletisim',
            emoji: '📢',
            lessons: ScratchLessonsData.module6,
          ),
          _ModuleInfo(
            title: 'Ses & Muzik',
            description: 'Oyununa ses ekle',
            emoji: '🎵',
            lessons: ScratchLessonsData.module7,
          ),
        ];
        break;
      case 'python':
        _modules = [
          _ModuleInfo(
            title: 'Python Temelleri',
            description: 'print, degiskenler, matematik',
            emoji: '🐍',
            lessons: PythonLessonsData.module1,
          ),
          _ModuleInfo(
            title: 'Kullanici Etkilesimi',
            description: 'input() ile veri al',
            emoji: '⌨️',
            lessons: PythonLessonsData.module2,
          ),
          _ModuleInfo(
            title: 'If-Else Kosullar',
            description: 'Programin karar vermesi',
            emoji: '🔀',
            lessons: PythonLessonsData.module3,
          ),
          _ModuleInfo(
            title: 'Donguler',
            description: 'for ve while dongusu',
            emoji: '🔁',
            lessons: PythonLessonsData.module4,
          ),
          _ModuleInfo(
            title: 'Listeler',
            description: 'Birden fazla veri',
            emoji: '📋',
            lessons: PythonLessonsData.module5,
          ),
          _ModuleInfo(
            title: 'Fonksiyonlar',
            description: 'Kendi komutlarin',
            emoji: '⚡',
            lessons: PythonLessonsData.module6,
          ),
          _ModuleInfo(
            title: 'Sozlukler',
            description: 'Anahtar-deger ciftleri',
            emoji: '📖',
            lessons: PythonLessonsData.module7,
          ),
          _ModuleInfo(
            title: 'Dosya Islemleri',
            description: 'Dosya oku ve yaz',
            emoji: '📂',
            lessons: PythonLessonsData.module8,
          ),
        ];
        break;
      case 'arduino':
        _modules = [
          _ModuleInfo(
            title: 'Arduino\'ya Giris',
            description: 'Elektronik + kod dunyasi',
            emoji: '🤖',
            lessons: ArduinoLessonsData.module1,
          ),
          _ModuleInfo(
            title: 'Butonlar',
            description: 'Dijital giris oku',
            emoji: '🔘',
            lessons: ArduinoLessonsData.module2,
          ),
          _ModuleInfo(
            title: 'Analog & PWM',
            description: 'Sensorler ve parlaklik',
            emoji: '📊',
            lessons: ArduinoLessonsData.module3,
          ),
          _ModuleInfo(
            title: 'Servo Motor',
            description: 'Hareket kontrolu',
            emoji: '🦾',
            lessons: ArduinoLessonsData.module4,
          ),
          _ModuleInfo(
            title: 'Ses & Buzzer',
            description: 'Melodi cal',
            emoji: '🔊',
            lessons: ArduinoLessonsData.module5,
          ),
        ];
        break;
      default:
        _modules = [];
    }
  }

  String _getCourseEmoji() {
    switch (widget.course.id) {
      case 'scratch':
        return '🐱';
      case 'scratch_junior':
        return '🌟';
      case 'html':
        return '🌐';
      case 'css':
        return '🎨';
      case 'javascript':
        return '⚡';
      case 'python':
        return '🐍';
      case 'arduino':
        return '🤖';
      default:
        return '📚';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_modules.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.course.name)),
        body: const Center(
          child: Text('Bu kurs icin interaktif icerik henuz hazir degil.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(isDark),
          SliverToBoxAdapter(child: _buildProgressCard(isDark)),
          SliverToBoxAdapter(child: _buildModuleTabs(isDark)),
          SliverToBoxAdapter(child: _buildModuleContent(isDark)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: widget.course.primaryColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.course.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.course.primaryColor,
                    widget.course.secondaryColor,
                  ],
                ),
              ),
            ),
            // Course emoji
            Positioned(
              right: 20,
              bottom: 60,
              child: _AnimatedEmoji(emoji: _getCourseEmoji()),
            ),
            // Decorative elements
            ...List.generate(8, (i) {
              final random = Random(i);
              return Positioned(
                left: random.nextDouble() * 300,
                top: random.nextDouble() * 150,
                child: Opacity(
                  opacity: 0.15,
                  child: Transform.rotate(
                    angle: random.nextDouble() * 0.5,
                    child: Container(
                      width: 40 + random.nextDouble() * 30,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(bool isDark) {
    final totalLessons = _modules.fold<int>(0, (sum, m) => sum + m.lessons.length);
    const completedLessons = 0; // TODO: Get from user data
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    final totalXp = _modules.fold<int>(0, (sum, m) =>
      sum + m.lessons.fold<int>(0, (s, l) => s + l.xpReward));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.course.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Progress circle
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: widget.course.primaryColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(widget.course.primaryColor),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ilerleme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      icon: Icons.school,
                      label: 'Ders',
                      value: '$completedLessons / $totalLessons',
                      color: widget.course.primaryColor,
                    ),
                    const SizedBox(height: 4),
                    _buildStatRow(
                      icon: Icons.star,
                      label: 'XP',
                      value: '0 / $totalXp',
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startFirstAvailableLesson(),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.course.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Ogrenmeye Basla',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildModuleTabs(bool isDark) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _modules.length,
        itemBuilder: (context, index) {
          final module = _modules[index];
          final isSelected = _selectedModule == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedModule = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 130,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.course.primaryColor
                    : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: widget.course.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    module.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Modul ${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white70
                          : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                    ),
                  ),
                  Text(
                    module.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModuleContent(bool isDark) {
    final module = _modules[_selectedModule];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module header
          Row(
            children: [
              Text(module.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      module.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.course.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${module.lessons.length} ders',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.course.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Lessons list
          ...module.lessons.asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            return _buildLessonCard(lesson, index, isDark);
          }),
        ],
      ),
    );
  }

  Widget _buildLessonCard(InteractiveLesson lesson, int index, bool isDark) {
    const isCompleted = false; // TODO: Get from user data
    const isLocked = false; // For now, don't lock

    return GestureDetector(
      onTap: isLocked ? null : () => _openLesson(lesson),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(color: Colors.green, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isLocked ? null : () => _openLesson(lesson),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Lesson number
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? const LinearGradient(
                              colors: [Colors.green, Colors.teal],
                            )
                          : LinearGradient(
                              colors: [
                                widget.course.primaryColor,
                                widget.course.secondaryColor,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (isCompleted
                                  ? Colors.green
                                  : widget.course.primaryColor)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                          : (isLocked
                              ? const Icon(Icons.lock, color: Colors.white, size: 20)
                              : Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Lesson info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? Colors.grey
                                : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildLessonStat(
                              Icons.flash_on,
                              '${lesson.steps.length} adim',
                              Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            _buildLessonStat(
                              Icons.star,
                              '+${lesson.xpReward} XP',
                              Colors.amber,
                            ),
                            if (lesson.badge != null) ...[
                              const SizedBox(width: 16),
                              _buildLessonStat(
                                Icons.emoji_events,
                                'Rozet',
                                Colors.purple,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonStat(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _openLesson(InteractiveLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InteractiveLessonScreen(
          course: widget.course,
          lesson: lesson,
        ),
      ),
    );
  }

  void _startFirstAvailableLesson() {
    if (_modules.isNotEmpty && _modules[0].lessons.isNotEmpty) {
      _openLesson(_modules[0].lessons.first);
    }
  }
}

class _ModuleInfo {
  final String title;
  final String description;
  final String emoji;
  final List<InteractiveLesson> lessons;

  const _ModuleInfo({
    required this.title,
    required this.description,
    required this.emoji,
    required this.lessons,
  });
}

/// Animated Emoji Widget
class _AnimatedEmoji extends StatefulWidget {
  final String emoji;

  const _AnimatedEmoji({required this.emoji});

  @override
  State<_AnimatedEmoji> createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<_AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: Text(
            widget.emoji,
            style: const TextStyle(fontSize: 80),
          ),
        );
      },
    );
  }
}
