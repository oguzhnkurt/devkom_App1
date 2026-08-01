import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/roboakademi_service.dart';
import '../../models/workshop_student_model.dart';
import '../../courses/data/roboakademi_curriculum_data.dart';
import '../../theme.dart';
import '../../utils/workshop_schedule_utils.dart';
import '../auth/login_screen.dart';
import '../student/student_home_screen.dart';

/// Parent-facing RoboAkademi tracking dashboard: weekly curriculum progress,
/// attendance calendar, points/badges/development, and payment status.
class RoboAkademiParentScreen extends StatefulWidget {
  const RoboAkademiParentScreen({super.key});

  @override
  State<RoboAkademiParentScreen> createState() => _RoboAkademiParentScreenState();
}

class _RoboAkademiParentScreenState extends State<RoboAkademiParentScreen> {
  final _service = RoboAkademiService();

  bool _isLoading = true;
  String? _error;
  List<WorkshopStudentModel> _children = [];
  WorkshopStudentModel? _selected;
  List<WorkshopAttendanceRecord> _attendance = [];
  List<WorkshopPaymentRecord> _payments = [];
  List<WorkshopHolidayModel> _holidays = [];
  bool _isUpdatingAbsence = false;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final parentUserId = context.read<AuthProvider>().currentUser?.uid;
    if (parentUserId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final children = await _service.getChildrenForParent(parentUserId);
      final holidays = await _service.getHolidays();
      setState(() {
        _children = children;
        _holidays = holidays;
        _selected = children.isNotEmpty ? children.first : null;
      });
      if (_selected != null) {
        await _loadChildDetails(_selected!.id);
      }
    } catch (e) {
      setState(() => _error = 'Bilgiler yüklenemedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChildDetails(String studentId) async {
    try {
      final attendance = await _service.getAttendance(studentId);
      final payments = await _service.getPayments(studentId);
      setState(() {
        _attendance = attendance;
        _payments = payments;
      });
    } catch (e) {
      setState(() => _error = 'Detaylar yüklenemedi: $e');
    }
  }

  Future<void> _markAbsence(WorkshopScheduleEntry entry) async {
    final student = _selected;
    if (student == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Katılamayacağız'),
        content: Text(
          '${formatWorkshopDate(entry.date)} tarihli derse katılamayacağınızı öğretmene bildirmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Evet, Bildir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isUpdatingAbsence = true);
    try {
      await _service.markPlannedAbsence(
        studentId: student.id,
        sessionDate: entry.date,
        weekNumber: entry.weekNumber,
      );
      await _loadChildDetails(student.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Öğretmene bildirildi'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingAbsence = false);
    }
  }

  Future<void> _cancelAbsence(WorkshopScheduleEntry entry) async {
    final student = _selected;
    if (student == null) return;

    setState(() => _isUpdatingAbsence = true);
    try {
      await _service.cancelPlannedAbsence(studentId: student.id, sessionDate: entry.date);
      await _loadChildDetails(student.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bildirim kaldırıldı')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingAbsence = false);
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.signOut();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoboAkademi Takip'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Ana Menü',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const StudentHomeScreen()),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
              : _children.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadChildren,
                      child: _buildContent(),
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.child_care_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Henüz eklenmiş bir çocuk yok.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Profil ayarlarından RoboAkademi öğrencinizi ekleyebilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final student = _selected!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_children.length > 1) _buildChildSelector(),
        _buildHeaderCard(student),
        const SizedBox(height: 20),
        _buildSectionTitle('📚 Haftalık Müfredat ve İlerleme'),
        _buildCurriculumSection(student),
        const SizedBox(height: 20),
        _buildSectionTitle('📅 Ders Takvimi'),
        _buildScheduleSection(student),
        const SizedBox(height: 20),
        _buildSectionTitle('🏆 Puan / Rozet / Gelişim'),
        _buildDevelopmentSection(student),
        const SizedBox(height: 20),
        _buildSectionTitle('💳 Ödeme Durumu'),
        _buildPaymentSection(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildChildSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<WorkshopStudentModel>(
        initialValue: _selected,
        decoration: const InputDecoration(
          labelText: 'Çocuk Seç',
          prefixIcon: Icon(Icons.family_restroom_rounded),
        ),
        items: _children
            .map((c) => DropdownMenuItem(value: c, child: Text(c.fullName)))
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() => _selected = value);
          _loadChildDetails(value.id);
        },
      ),
    );
  }

  Widget _buildHeaderCard(WorkshopStudentModel student) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00979D), Color(0xFF00BCD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: Text(
              student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hafta ${student.currentWeek} / 8',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (student.teacherNote != null && student.teacherNote!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '💬 "${student.teacherNote}"',
                    style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCurriculumSection(WorkshopStudentModel student) {
    final curriculum = RoboAkademiCurriculumData.forAgeGroup(student.ageGroup);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            curriculum.displayName,
            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        ...curriculum.weeks.map((week) {
        final isDone = week.weekNumber < student.currentWeek;
        final isCurrent = week.weekNumber == student.currentWeek;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: isDone
                  ? Colors.green
                  : isCurrent
                      ? AppTheme.primaryBlue
                      : Colors.grey.shade300,
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '${week.weekNumber}',
                      style: TextStyle(color: isCurrent ? Colors.white : Colors.grey.shade700),
                    ),
            ),
            title: Text(
              week.theme,
              style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
            ),
            subtitle: Text(isDone ? 'Tamamlandı' : (isCurrent ? 'Bu hafta işleniyor' : 'Yaklaşıyor')),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Etkinlikler', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...week.activities.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $a'),
                        )),
                    const SizedBox(height: 12),
                    const Text('Kazanımlar', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...week.outcomes.map((o) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('✓ $o'),
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
        }),
      ],
    );
  }

  Widget _buildScheduleSection(WorkshopStudentModel student) {
    final schedule = computeWorkshopSchedule(
      student: student,
      holidays: _holidays,
      attendance: _attendance,
    );

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Ders günü: ${student.classWeekdayName}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...schedule.map((entry) => _buildScheduleRow(entry)),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(WorkshopScheduleEntry entry) {
    if (entry.isHoliday) {
      return ListTile(
        leading: const Icon(Icons.event_busy_rounded, color: Colors.grey),
        title: Text(
          formatWorkshopDate(entry.date),
          style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough),
        ),
        subtitle: Text('Tatil — ${entry.holidayName}', style: const TextStyle(color: Colors.grey)),
      );
    }

    final record = entry.record;

    // Teacher has already recorded the real outcome for this date.
    if (entry.hasTeacherRecord) {
      final attended = record!.attended;
      return ListTile(
        leading: Icon(
          attended ? Icons.check_circle : Icons.cancel,
          color: attended ? Colors.green : Colors.red,
        ),
        title: Text('${formatWorkshopDate(entry.date)} — Hafta ${entry.weekNumber}'),
        subtitle: record.teacherNote != null && record.teacherNote!.isNotEmpty
            ? Text(record.teacherNote!)
            : null,
        trailing: record.feedback != null
            ? Text(
                '${feedbackEmoji(record.feedback!)} ${feedbackDisplayName(record.feedback!)}',
                style: const TextStyle(fontSize: 13),
              )
            : null,
      );
    }

    // Parent has marked an advance "we won't attend" for a future date.
    if (entry.isPlannedAbsence) {
      return ListTile(
        leading: const Icon(Icons.event_note_rounded, color: Colors.orange),
        title: Text('${formatWorkshopDate(entry.date)} — Hafta ${entry.weekNumber}'),
        subtitle: const Text('Katılamayacağınızı bildirdiniz', style: TextStyle(color: Colors.orange)),
        trailing: TextButton(
          onPressed: _isUpdatingAbsence ? null : () => _cancelAbsence(entry),
          child: const Text('Geri Al'),
        ),
      );
    }

    // Future session with no record yet — parent can mark absence.
    if (!entry.isPast) {
      return ListTile(
        leading: const Icon(Icons.schedule_rounded, color: Colors.blueGrey),
        title: Text('${formatWorkshopDate(entry.date)} — Hafta ${entry.weekNumber}'),
        subtitle: const Text('Yaklaşan ders'),
        trailing: TextButton(
          onPressed: _isUpdatingAbsence ? null : () => _markAbsence(entry),
          child: const Text('Katılamayacağız'),
        ),
      );
    }

    // Past session with no record at all (teacher hasn't logged it).
    return ListTile(
      leading: const Icon(Icons.help_outline_rounded, color: Colors.grey),
      title: Text(
        '${formatWorkshopDate(entry.date)} — Hafta ${entry.weekNumber}',
        style: const TextStyle(color: Colors.grey),
      ),
      subtitle: const Text('Henüz kayıt girilmedi', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildDevelopmentSection(WorkshopStudentModel student) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber),
                const SizedBox(width: 8),
                Text('${student.totalPoints} Puan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            if (student.badges.isEmpty)
              const Text('Henüz kazanılmış rozet yok.', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: student.badges
                    .map((b) => Chip(
                          avatar: const Icon(Icons.emoji_events, size: 18, color: Colors.orange),
                          label: Text(b),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    if (_payments.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Henüz kaydedilmiş bir ödeme bilgisi yok.'),
        ),
      );
    }
    const monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return Card(
      child: Column(
        children: _payments.map((p) {
          final paid = p.status == WorkshopPaymentStatus.paid;
          return ListTile(
            leading: Icon(
              paid ? Icons.check_circle : Icons.pending_actions,
              color: paid ? Colors.green : Colors.orange,
            ),
            title: Text('${monthNames[p.periodMonth.month - 1]} ${p.periodMonth.year}'),
            subtitle: p.note != null && p.note!.isNotEmpty ? Text(p.note!) : null,
            trailing: Chip(
              label: Text(paid ? 'Ödendi' : 'Bekliyor'),
              backgroundColor: paid ? Colors.green.shade50 : Colors.orange.shade50,
              labelStyle: TextStyle(color: paid ? Colors.green.shade800 : Colors.orange.shade800),
            ),
          );
        }).toList(),
      ),
    );
  }
}
