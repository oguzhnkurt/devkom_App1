/// W3Schools-style Chapter List Screen
/// Shows chapters in a course with progress
import 'package:flutter/material.dart';
import '../models/w3_lesson_model.dart';
import '../widgets/w3_widgets.dart';
import 'w3_lesson_list_screen.dart';

class W3ChapterListScreen extends StatefulWidget {
  final W3Course course;

  const W3ChapterListScreen({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<W3ChapterListScreen> createState() => _W3ChapterListScreenState();
}

class _W3ChapterListScreenState extends State<W3ChapterListScreen> {
  // Mock chapter completion data
  final Set<String> _completedChapters = {'ch1_intro'};

  double get _overallProgress {
    if (widget.course.chapters.isEmpty) return 0;
    return _completedChapters.length / widget.course.chapters.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.course.title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Course header with progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      widget.course.icon,
                      style: const TextStyle(fontSize: 50),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.course.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.course.totalLessons} ders • ${widget.course.estimatedHours} saat',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                W3ProgressBar(
                  progress: _overallProgress,
                  showPercentage: true,
                ),
              ],
            ),
          ),

          // Chapter list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.course.chapters.length,
              itemBuilder: (context, index) {
                final chapter = widget.course.chapters[index];
                final isCompleted = _completedChapters.contains(chapter.id);
                final isLocked = chapter.isLocked;
                final lessonCount = chapter.lessons.length;
                final estimatedMinutes = chapter.lessons
                    .fold(0, (sum, lesson) => sum + lesson.estimatedMinutes);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isCompleted
                            ? W3Colors.primary
                            : Colors.grey.shade300,
                        width: isCompleted ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: isLocked
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => W3LessonListScreen(
                                    course: widget.course,
                                    chapter: chapter,
                                  ),
                                ),
                              );
                            },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Chapter emoji/icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isLocked
                                    ? Colors.grey.shade200
                                    : W3Colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  isLocked ? '🔒' : (chapter.emoji ?? '📚'),
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Chapter info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chapter.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isLocked
                                          ? Colors.grey.shade500
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$lessonCount ders • ~${estimatedMinutes} dakika',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (isLocked)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Önceki bölümü tamamla',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange.shade700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Completion indicator
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: W3Colors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            else if (!isLocked)
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
