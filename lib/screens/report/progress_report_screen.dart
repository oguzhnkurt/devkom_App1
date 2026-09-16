import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/progress_report_service.dart';
import '../certificate/certificate_screen.dart';

/// Pro'ya özel ilerleme raporu.
///
/// Amaç ebeveynin "para verdiğim şey ne işe yarıyor" sorusuna somut cevap
/// vermek: hangi kursta nerede, hangi gün çalışmış, neyi yarım bırakmış.
class ProgressReportScreen extends StatefulWidget {
  const ProgressReportScreen({super.key});

  @override
  State<ProgressReportScreen> createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends State<ProgressReportScreen> {
  final ProgressReportService _service = ProgressReportService();

  bool _isLoading = true;
  ProgressReport? _report;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _isLoading = true);
    final progress = context.read<AuthProvider>().userProgress;
    final report = await _service.build(progress);
    if (!mounted) return;
    setState(() {
      _report = report;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<AuthProvider>().userProgress;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('İlerleme Raporu'),
        backgroundColor: const Color(0xFF6C3CE0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading || _report == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                children: [
                  _buildHeadline(_report!, progress?.totalXP ?? 0),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Son 14 gün'),
                  const SizedBox(height: 10),
                  _buildActivityChart(_report!),
                  const SizedBox(height: 22),
                  _buildSectionTitle('Kurslar'),
                  const SizedBox(height: 10),
                  ..._report!.courses.map(_buildCourseRow),
                  const SizedBox(height: 22),
                  _buildSectionTitle('Öneriler'),
                  const SizedBox(height: 10),
                  ..._buildSuggestions(_report!),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.grey[800],
        ),
      );

  Widget _buildHeadline(ProgressReport r, int totalXP) {
    final finished = r.courses.where((c) => c.finished).length;
    final started = r.courses.where((c) => c.started).length;

    final items = [
      ('Bu hafta XP', '${r.weeklyXP}'),
      ('Aktif gün', '${r.activeDays} / 14'),
      ('Başlanan kurs', '$started'),
      ('Biten kurs', '$finished'),
      ('İzlenen video', '${r.videosWatched}'),
      ('Biten görev', '${r.questsCompleted}'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C3CE0), Color(0xFF9B6BFF)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toplam $totalXP XP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items
                .map((i) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(i.$1,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(i.$2,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(ProgressReport r) {
    final maxXP = r.lastDays.fold<int>(0, (a, d) => d.xp > a ? d.xp : a);
    const labels = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: r.lastDays.map((d) {
                final h = maxXP == 0 ? 0.0 : (d.xp / maxXP) * 92;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (d.xp > 0)
                          Text('${d.xp}',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[600])),
                        const SizedBox(height: 3),
                        Container(
                          height: h < 3 && d.xp > 0 ? 3 : h,
                          decoration: BoxDecoration(
                            color: d.isEmpty
                                ? Colors.grey.shade200
                                : const Color(0xFF6C3CE0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: r.lastDays.map((d) {
              return Expanded(
                child: Text(
                  labels[d.day.weekday - 1],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9.5, color: Colors.grey[500]),
                ),
              );
            }).toList(),
          ),
          if (maxXP == 0) ...[
            const SizedBox(height: 8),
            Text(
              'Henüz kayıt yok — bir ders bitirdiğinde burada görünecek.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseRow(CourseProgress c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: c.finished
                ? c.course.primaryColor.withValues(alpha: 0.4)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Text(c.course.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.course.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${c.completed} / ${c.total}',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: c.ratio,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(c.course.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            // Biten kursta sertifika girisi — Pro'nun somut ciktisi.
            if (c.finished) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Sertifikanı gör',
                icon: Icon(Icons.workspace_premium_rounded,
                    color: c.course.primaryColor, size: 24),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CertificateScreen(
                      course: c.course,
                      completedAt: DateTime.now(),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSuggestions(ProgressReport r) {
    final tips = <(IconData, String, String)>[];

    for (final c in r.unfinished) {
      tips.add((
        Icons.play_circle_outline_rounded,
        '${c.course.name} yarım kaldı',
        '${c.total - c.completed} ders kaldı. Buradan devam etmek, yeni bir kursa '
            'başlamaktan daha hızlı ilerletir.',
      ));
    }

    final next = r.nextStep;
    if (next != null) {
      tips.add((
        Icons.flag_outlined,
        'Sıradaki adım: ${next.course.name}',
        next.course.description,
      ));
    }

    if (r.activeDays < 4) {
      tips.add((
        Icons.calendar_today_outlined,
        'Düzen henüz oturmamış',
        'Son iki haftada ${r.activeDays} gün çalışılmış. Günde 10 dakika, '
            'haftada bir saatten daha çok işe yarıyor.',
      ));
    }

    if (tips.isEmpty) {
      tips.add((
        Icons.emoji_events_outlined,
        'Her şey yolunda',
        'Başlanan kursların hepsi bitmiş ve düzenli çalışılıyor. Yeni bir '
            'kursa başlamak için iyi bir zaman.',
      ));
    }

    return tips
        .map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(t.$1, size: 19, color: const Color(0xFF6C3CE0)),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.$2,
                              style: const TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(t.$3,
                              style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }
}
