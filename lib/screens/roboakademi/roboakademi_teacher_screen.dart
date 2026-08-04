import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/roboakademi_service.dart';
import '../../models/workshop_student_model.dart';
import '../../utils/workshop_schedule_utils.dart';
import '../auth/login_screen.dart';

/// Simple teacher/admin data-entry screen for the RoboAkademi workshop:
/// mark today's attendance + weekly feedback, add points/badges, update the
/// current curriculum week, and set monthly payment status.
///
/// Intentionally minimal — this is a working tool for the person running
/// the sessions, not a polished admin dashboard.
class RoboAkademiTeacherScreen extends StatefulWidget {
  const RoboAkademiTeacherScreen({super.key});

  @override
  State<RoboAkademiTeacherScreen> createState() => _RoboAkademiTeacherScreenState();
}

class _RoboAkademiTeacherScreenState extends State<RoboAkademiTeacherScreen> {
  final _service = RoboAkademiService();

  bool _isLoading = true;
  List<WorkshopStudentModel> _students = [];
  WorkshopStudentModel? _selected;
  List<WorkshopHolidayModel> _holidays = [];
  final _holidayNameController = TextEditingController();
  DateTime? _newHolidayDate;
  List<WorkshopLessonRequest> _lessonRequests = [];

  // Attendance form state
  bool _attended = true;
  WorkshopAttendanceFeedback? _feedback;
  final _attendanceNoteController = TextEditingController();

  // Points/badge form state
  final _pointsController = TextEditingController(text: '10');
  final _badgeController = TextEditingController();

  // Teacher note
  final _teacherNoteController = TextEditingController();

  // Payment form state
  DateTime _paymentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  WorkshopPaymentStatus _paymentStatus = WorkshopPaymentStatus.pending;
  final _paymentAmountController = TextEditingController();
  final _paymentNoteController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _loadHolidays();
    _loadLessonRequests();
  }

  @override
  void dispose() {
    _attendanceNoteController.dispose();
    _pointsController.dispose();
    _badgeController.dispose();
    _teacherNoteController.dispose();
    _paymentAmountController.dispose();
    _paymentNoteController.dispose();
    _holidayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadHolidays() async {
    try {
      final holidays = await _service.getHolidays();
      if (!mounted) return;
      setState(() => _holidays = holidays);
    } catch (e) {
      debugPrint('❌ Tatil günleri yüklenemedi: $e');
    }
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _service.getAllStudents();
      setState(() {
        _students = students;
        _selected = students.isNotEmpty ? students.first : null;
        if (_selected != null) {
          _teacherNoteController.text = _selected!.teacherNote ?? '';
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Öğrenciler yüklenemedi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSelectStudent(WorkshopStudentModel? student) {
    if (student == null) return;
    setState(() {
      _selected = student;
      _teacherNoteController.text = student.teacherNote ?? '';
    });
  }

  Future<void> _saveAttendance() async {
    final student = _selected;
    final teacherId = context.read<AuthProvider>().currentUser?.uid;
    if (student == null || teacherId == null) return;

    setState(() => _isSaving = true);
    try {
      await _service.recordAttendance(
        studentId: student.id,
        sessionDate: DateTime.now(),
        attended: _attended,
        weekNumber: student.currentWeek,
        feedback: _feedback,
        teacherNote: _attendanceNoteController.text.trim().isEmpty
            ? null
            : _attendanceNoteController.text.trim(),
        createdBy: teacherId,
      );
      _showSnack('Bugünkü yoklama kaydedildi ✅');
    } catch (e) {
      _showSnack('Hata: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _addPoints() async {
    final student = _selected;
    if (student == null) return;
    final points = int.tryParse(_pointsController.text) ?? 0;
    if (points == 0) return;

    setState(() => _isSaving = true);
    try {
      await _service.addPoints(studentId: student.id, pointsToAdd: points);
      await _loadStudents();
      _showSnack('$points puan eklendi 🌟');
    } catch (e) {
      _showSnack('Hata: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _addBadge() async {
    final student = _selected;
    final badge = _badgeController.text.trim();
    if (student == null || badge.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await _service.addBadge(studentId: student.id, badge: badge);
      _badgeController.clear();
      await _loadStudents();
      _showSnack('Rozet eklendi 🏅');
    } catch (e) {
      _showSnack('Hata: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _updateWeek(int week) async {
    final student = _selected;
    if (student == null) return;
    setState(() => _isSaving = true);
    try {
      await _service.updateCurrentWeek(studentId: student.id, week: week);
      await _loadStudents();
      _showSnack('Hafta $week olarak güncellendi');
    } catch (e) {
      _showSnack('Hata: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _updateClassWeekday(int weekday) async {
    final student = _selected;
    if (student == null) return;
    setState(() => _isSaving = true);
    try {
      await _service.updateClassWeekday(studentId: student.id, weekday: weekday);
      await _loadStudents();
      _showSnack('Ders günü ${WorkshopStudentModel.weekdayNames[weekday]} olarak güncellendi');
    } catch (e) {
      _showSnack('Hata: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickNewHolidayDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'Tatil Tarihi Seç',
      cancelText: 'İptal',
      confirmText: 'Tamam',
    );
    if (picked != null) {
      setState(() => _newHolidayDate = picked);
    }
  }

  Future<void> _addHoliday() async {
    final date = _newHolidayDate;
    final name = _holidayNameController.text.trim();
    final teacherId = context.read<AuthProvider>().currentUser?.uid;
    if (date == null || name.isEmpty || teacherId == null) {
      _showSnack('Tarih ve tatil adı gerekli', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      await _service.addHoliday(date: date, name: name, createdBy: teacherId);
      _holidayNameController.clear();
      setState(() => _newHolidayDate = null);
      await _loadHolidays();
      _showSnack('Tatil günü eklendi 📅');
    } catch (e) {
      _showSnack('Hata: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteHoliday(String id) async {
    try {
      await _service.deleteHoliday(id);
      await _loadHolidays();
      _showSnack('Tatil günü kaldırıldı');
    } catch (e) {
      _showSnack('Hata: $e', isError: true);
    }
  }

  Future<void> _loadLessonRequests() async {
    try {
      final requests = await _service.getAllLessonRequests();
      if (!mounted) return;
      setState(() => _lessonRequests = requests);
    } catch (e) {
      debugPrint('❌ Ders talepleri yüklenemedi: $e');
    }
  }

  Future<void> _respondToRequest(WorkshopLessonRequest request, LessonRequestStatus status) async {
    setState(() => _isSaving = true);
    try {
      await _service.updateLessonRequestStatus(id: request.id, status: status);
      await _loadLessonRequests();
      _showSnack(status == LessonRequestStatus.approved ? 'Talep onaylandı ✅' : 'Talep reddedildi');
    } catch (e) {
      _showSnack('Hata: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveTeacherNote() async {
    final student = _selected;
    if (student == null) return;
    setState(() => _isSaving = true);
    try {
      await _service.updateTeacherNote(studentId: student.id, note: _teacherNoteController.text.trim());
      _showSnack('Not kaydedildi');
    } catch (e) {
      _showSnack('Hata: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _savePayment() async {
    final student = _selected;
    final teacherId = context.read<AuthProvider>().currentUser?.uid;
    if (student == null || teacherId == null) return;

    setState(() => _isSaving = true);
    try {
      await _service.setPaymentStatus(
        studentId: student.id,
        periodMonth: _paymentMonth,
        status: _paymentStatus,
        amount: double.tryParse(_paymentAmountController.text.replaceAll(',', '.')),
        note: _paymentNoteController.text.trim().isEmpty ? null : _paymentNoteController.text.trim(),
        updatedBy: teacherId,
      );
      _showSnack('Ödeme durumu kaydedildi 💳');
    } catch (e) {
      _showSnack('Hata: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
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
        title: const Text('RoboAkademi — Ders Girişi'),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
          : _students.isEmpty
              ? const Center(child: Text('Henüz kayıtlı bir öğrenci yok.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStudentPicker(),
                    if (_selected != null) ...[
                      const SizedBox(height: 20),
                      _buildAttendanceCard(),
                      const SizedBox(height: 16),
                      _buildPointsBadgeCard(),
                      const SizedBox(height: 16),
                      _buildWeekCard(),
                      const SizedBox(height: 16),
                      _buildClassDayCard(),
                      const SizedBox(height: 16),
                      _buildTeacherNoteCard(),
                      const SizedBox(height: 16),
                      _buildPaymentCard(),
                    ],
                    const SizedBox(height: 16),
                    _buildLessonRequestsCard(),
                    const SizedBox(height: 16),
                    _buildHolidaysCard(),
                  ],
                ),
    );
  }

  Widget _buildStudentPicker() {
    return DropdownButtonFormField<WorkshopStudentModel>(
      initialValue: _selected,
      decoration: const InputDecoration(
        labelText: 'Öğrenci Seç',
        prefixIcon: Icon(Icons.person_search_rounded),
      ),
      items: _students
          .map((s) => DropdownMenuItem(value: s, child: Text('${s.fullName} (Hafta ${s.currentWeek})')))
          .toList(),
      onChanged: _onSelectStudent,
    );
  }

  Widget _buildAttendanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bugünkü Yoklama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Derse katıldı'),
              value: _attended,
              onChanged: (v) => setState(() => _attended = v),
            ),
            const SizedBox(height: 8),
            const Text('Gülümseme Kartı'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: WorkshopAttendanceFeedback.values.map((f) {
                final selected = _feedback == f;
                return ChoiceChip(
                  label: Text('${feedbackEmoji(f)} ${feedbackDisplayName(f)}'),
                  selected: selected,
                  onSelected: (_) => setState(() => _feedback = f),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _attendanceNoteController,
              decoration: const InputDecoration(labelText: 'Kısa not (isteğe bağlı)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveAttendance,
              child: const Text('Yoklamayı Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsBadgeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Puan / Rozet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Toplam: ${_selected!.totalPoints} puan', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Eklenecek puan'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _isSaving ? null : _addPoints, child: const Text('Ekle')),
              ],
            ),
            const SizedBox(height: 12),
            if (_selected!.badges.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selected!.badges.map((b) => Chip(label: Text(b))).toList(),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _badgeController,
                    decoration: const InputDecoration(labelText: 'Yeni rozet adı'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _isSaving ? null : _addBadge, child: const Text('Ekle')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Müfredat Haftası', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _selected!.currentWeek,
              decoration: const InputDecoration(labelText: 'Şu anki hafta'),
              items: List.generate(8, (i) => i + 1)
                  .map((w) => DropdownMenuItem(value: w, child: Text('Hafta $w')))
                  .toList(),
              onChanged: (w) {
                if (w != null) _updateWeek(w);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDayCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Haftalık Ders Günü', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'Veli panelindeki ders takvimi bu güne göre hesaplanır',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _selected!.classWeekday,
              decoration: const InputDecoration(labelText: 'Ders günü'),
              items: WorkshopStudentModel.weekdayNames.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (w) {
                if (w != null) _updateClassWeekday(w);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonRequestsCard() {
    final pending = _lessonRequests.where((r) => r.status == LessonRequestStatus.pending).toList();
    final resolved = _lessonRequests.where((r) => r.status != LessonRequestStatus.pending).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ders Talepleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'Velilerin ek ders / telafi dersi talepleri',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              const Text('Bekleyen talep yok.', style: TextStyle(color: Colors.grey))
            else
              Column(children: pending.map((r) => _buildLessonRequestTile(r)).toList()),
            if (resolved.isNotEmpty) ...[
              const Divider(height: 24),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Geçmiş Talepler', style: TextStyle(fontSize: 13, color: Colors.grey)),
                children: resolved.map((r) => _buildLessonRequestTile(r)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLessonRequestTile(WorkshopLessonRequest r) {
    final isPending = r.status == LessonRequestStatus.pending;
    Color statusColor;
    switch (r.status) {
      case LessonRequestStatus.approved:
        statusColor = Colors.green;
        break;
      case LessonRequestStatus.rejected:
        statusColor = Colors.red;
        break;
      case LessonRequestStatus.pending:
        statusColor = Colors.orange;
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          r.type == LessonRequestType.makeup ? Icons.refresh_rounded : Icons.add_circle_outline_rounded,
          color: statusColor,
        ),
        title: Text(
          '${r.studentName ?? 'Öğrenci'} — ${requestTypeDisplayName(r.type)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${formatWorkshopDate(r.requestedDate)}, ${r.requestedTime}'
          '${r.note != null && r.note!.isNotEmpty ? '\n${r.note}' : ''}'
          '${!isPending ? '\n${requestStatusDisplayName(r.status)}' : ''}',
        ),
        isThreeLine: (r.note != null && r.note!.isNotEmpty) || !isPending,
        trailing: isPending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Onayla',
                    onPressed: _isSaving ? null : () => _respondToRequest(r, LessonRequestStatus.approved),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Reddet',
                    onPressed: _isSaving ? null : () => _respondToRequest(r, LessonRequestStatus.rejected),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildHolidaysCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resmi Tatil Günleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'Bu tarihlerde tüm öğrenciler için ders yok kabul edilir',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (_holidays.isEmpty)
              const Text('Henüz eklenmiş bir tatil günü yok.', style: TextStyle(color: Colors.grey))
            else
              Column(
                children: _holidays.map((h) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_busy_rounded, color: Colors.redAccent),
                    title: Text(formatWorkshopDate(h.holidayDate)),
                    subtitle: Text(h.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _deleteHoliday(h.id),
                    ),
                  );
                }).toList(),
              ),
            const Divider(height: 24),
            InkWell(
              onTap: _pickNewHolidayDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Tarih'),
                child: Text(
                  _newHolidayDate != null ? formatWorkshopDate(_newHolidayDate!) : 'Tarih seçin',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _holidayNameController,
              decoration: const InputDecoration(labelText: 'Tatil adı (örn: Cumhuriyet Bayramı)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isSaving ? null : _addHoliday,
              child: const Text('Tatil Günü Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherNoteCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Genel Gelişim Notu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('Veli panelinde görünür', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: _teacherNoteController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Örn: Bu hafta çok istekliydi, takım çalışmasında öne çıktı.'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _isSaving ? null : _saveTeacherNote, child: const Text('Notu Kaydet')),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard() {
    const monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ödeme Durumu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _paymentMonth.month,
                    decoration: const InputDecoration(labelText: 'Ay'),
                    items: List.generate(12, (i) => i + 1)
                        .map((m) => DropdownMenuItem(value: m, child: Text(monthNames[m - 1])))
                        .toList(),
                    onChanged: (m) {
                      if (m != null) {
                        setState(() => _paymentMonth = DateTime(_paymentMonth.year, m, 1));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _paymentMonth.year,
                    decoration: const InputDecoration(labelText: 'Yıl'),
                    items: [DateTime.now().year - 1, DateTime.now().year, DateTime.now().year + 1]
                        .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                    onChanged: (y) {
                      if (y != null) {
                        setState(() => _paymentMonth = DateTime(y, _paymentMonth.month, 1));
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Ödendi'),
                  selected: _paymentStatus == WorkshopPaymentStatus.paid,
                  onSelected: (_) => setState(() => _paymentStatus = WorkshopPaymentStatus.paid),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bekliyor'),
                  selected: _paymentStatus == WorkshopPaymentStatus.pending,
                  onSelected: (_) => setState(() => _paymentStatus = WorkshopPaymentStatus.pending),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _paymentAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Tutar (isteğe bağlı)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _paymentNoteController,
              decoration: const InputDecoration(labelText: 'Not (isteğe bağlı)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _isSaving ? null : _savePayment, child: const Text('Ödeme Durumunu Kaydet')),
          ],
        ),
      ),
    );
  }
}
