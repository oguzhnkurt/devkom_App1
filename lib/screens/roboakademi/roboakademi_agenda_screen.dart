import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/auth_provider.dart';
import '../../services/roboakademi_service.dart';
import '../../models/workshop_student_model.dart';
import '../../utils/workshop_schedule_utils.dart';

/// Standalone RoboAkademi calendar screen — a real month-view agenda that
/// automatically marks lesson dates (the student's fixed weekly class day,
/// e.g. every Saturday) and skips official holidays. Reachable from the
/// drawer under "Ders Programı", "Devamsızlık" and "Ajanda" (all three point
/// here since they represent the same underlying calendar), for
/// RoboAkademi-enrolled parents only.
class RoboAkademiAgendaScreen extends StatefulWidget {
  const RoboAkademiAgendaScreen({super.key});

  @override
  State<RoboAkademiAgendaScreen> createState() => _RoboAkademiAgendaScreenState();
}

class _RoboAkademiAgendaScreenState extends State<RoboAkademiAgendaScreen> {
  final _service = RoboAkademiService();

  bool _isLoading = true;
  bool _isUpdatingAbsence = false;
  bool _isSubmittingRequest = false;
  String? _error;
  List<WorkshopStudentModel> _children = [];
  WorkshopStudentModel? _selected;
  List<WorkshopAttendanceRecord> _attendance = [];
  List<WorkshopHolidayModel> _holidays = [];
  List<WorkshopLessonRequest> _requests = [];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _load();
  }

  Future<void> _load() async {
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
        await _loadAttendance(_selected!.id);
        await _loadRequests(_selected!.id);
      }
    } catch (e) {
      setState(() => _error = 'Ajanda yüklenemedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAttendance(String studentId) async {
    try {
      final attendance = await _service.getAttendance(studentId);
      setState(() => _attendance = attendance);
    } catch (e) {
      setState(() => _error = 'Devam kayıtları yüklenemedi: $e');
    }
  }

  Future<void> _loadRequests(String studentId) async {
    try {
      final requests = await _service.getLessonRequests(studentId);
      setState(() => _requests = requests);
    } catch (e) {
      setState(() => _error = 'Talepler yüklenemedi: $e');
    }
  }

  List<WorkshopScheduleEntry> get _schedule {
    if (_selected == null) return [];
    return computeWorkshopSchedule(
      student: _selected!,
      holidays: _holidays,
      attendance: _attendance,
    );
  }

  Map<DateTime, WorkshopScheduleEntry> get _scheduleByDate {
    return {for (final e in _schedule) DateTime(e.date.year, e.date.month, e.date.day): e};
  }

  WorkshopScheduleEntry? _entryForDay(DateTime day) {
    return _scheduleByDate[DateTime(day.year, day.month, day.day)];
  }

  Color _colorForEntry(WorkshopScheduleEntry entry) {
    if (entry.isHoliday) return Colors.grey;
    if (entry.hasTeacherRecord) {
      return entry.record!.attended ? Colors.green : Colors.red;
    }
    if (entry.isPlannedAbsence) return Colors.orange;
    if (!entry.isPast) return Colors.teal;
    return Colors.grey;
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
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Vazgeç')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Evet, Bildir')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isUpdatingAbsence = true);
    try {
      await _service.markPlannedAbsence(studentId: student.id, sessionDate: entry.date, weekNumber: entry.weekNumber);
      await _loadAttendance(student.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Öğretmene bildirildi'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
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
      await _loadAttendance(student.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bildirim kaldırıldı')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUpdatingAbsence = false);
    }
  }

  Future<void> _showRequestDialog(LessonRequestType type) async {
    final student = _selected;
    if (student == null) return;

    DateTime? pickedDate;
    TimeOfDay? pickedTime;
    final noteController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(type == LessonRequestType.makeup ? 'Telafi Dersi Talep Et' : 'Ek Ders Talep Et'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type == LessonRequestType.makeup
                      ? 'Kaçırılan ders için önerdiğiniz telafi tarihi ve saatini seçin.'
                      : 'Talep ettiğiniz ek ders için tarih ve saat seçin.',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(pickedDate == null ? 'Tarih Seç' : formatWorkshopDate(pickedDate!)),
                  onPressed: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (date != null) setDialogState(() => pickedDate = date);
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.access_time_rounded, size: 18),
                  label: Text(pickedTime == null ? 'Saat Seç' : pickedTime!.format(context)),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 10, minute: 0),
                    );
                    if (time != null) setDialogState(() => pickedTime = time);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Not (opsiyonel)', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Vazgeç')),
            ElevatedButton(
              onPressed: (pickedDate != null && pickedTime != null)
                  ? () => Navigator.pop(dialogContext, true)
                  : null,
              child: const Text('Talep Et'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || pickedDate == null || pickedTime == null) return;
    if (!mounted) return;

    final timeStr =
        '${pickedTime!.hour.toString().padLeft(2, '0')}:${pickedTime!.minute.toString().padLeft(2, '0')}';

    setState(() => _isSubmittingRequest = true);
    try {
      final userId = context.read<AuthProvider>().currentUser?.uid ?? '';
      await _service.createLessonRequest(
        studentId: student.id,
        type: type,
        date: pickedDate!,
        time: timeStr,
        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
        createdBy: userId,
      );
      await _loadRequests(student.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Talebiniz öğretmene iletildi'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmittingRequest = false);
    }
  }

  Future<void> _cancelRequest(WorkshopLessonRequest request) async {
    setState(() => _isSubmittingRequest = true);
    try {
      await _service.cancelLessonRequest(request.id);
      if (_selected != null) await _loadRequests(_selected!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Talep iptal edildi')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmittingRequest = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Programı / Ajanda'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
              : _children.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_note_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Henüz eklenmiş bir çocuk yok.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final student = _selected!;
    final selected = _selectedDay ?? DateTime.now();
    final selectedEntry = _entryForDay(selected);

    return Column(
      children: [
        if (_children.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DropdownButtonFormField<WorkshopStudentModel>(
              initialValue: _selected,
              decoration: const InputDecoration(
                labelText: 'Çocuk Seç',
                prefixIcon: Icon(Icons.family_restroom_rounded),
              ),
              items: _children.map((c) => DropdownMenuItem(value: c, child: Text(c.fullName))).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selected = value);
                _loadAttendance(value.id);
                _loadRequests(value.id);
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
        TableCalendar<WorkshopScheduleEntry>(
          firstDay: DateTime.now().subtract(const Duration(days: 120)),
          lastDay: DateTime.now().add(const Duration(days: 180)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          startingDayOfWeek: StartingDayOfWeek.monday,
          eventLoader: (day) {
            final entry = _entryForDay(day);
            return entry == null ? [] : [entry];
          },
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Color(0xFF00979D), shape: BoxShape.circle),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;
              final entry = events.first;
              return Positioned(
                bottom: 4,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: _colorForEntry(entry), shape: BoxShape.circle),
                ),
              );
            },
          ),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          onDaySelected: (day, focused) {
            setState(() {
              _selectedDay = day;
              _focusedDay = focused;
            });
          },
          onPageChanged: (focused) => _focusedDay = focused,
        ),
        const Divider(height: 1),
        _buildLegend(),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _buildSelectedDayDetail(selected, selectedEntry),
              const Divider(height: 24),
              _buildRequestActions(),
              const SizedBox(height: 8),
              _buildRequestsList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Ek Ders Talep Et'),
              onPressed: _isSubmittingRequest ? null : () => _showRequestDialog(LessonRequestType.extra),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Telafi Talep Et'),
              onPressed: _isSubmittingRequest ? null : () => _showRequestDialog(LessonRequestType.makeup),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📨 Taleplerim', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_requests.isEmpty)
            const Text('Henüz bir talebiniz yok.', style: TextStyle(color: Colors.grey))
          else
            ..._requests.map((r) => _buildRequestTile(r)),
        ],
      ),
    );
  }

  Widget _buildRequestTile(WorkshopLessonRequest r) {
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          r.type == LessonRequestType.makeup ? Icons.refresh_rounded : Icons.add_circle_outline_rounded,
          color: statusColor,
        ),
        title: Text('${requestTypeDisplayName(r.type)} — ${formatWorkshopDate(r.requestedDate)}, ${r.requestedTime}'),
        subtitle: Text(
          r.note != null && r.note!.isNotEmpty
              ? '${requestStatusDisplayName(r.status)} · ${r.note}'
              : requestStatusDisplayName(r.status),
          style: TextStyle(color: statusColor),
        ),
        trailing: r.status == LessonRequestStatus.pending
            ? TextButton(
                onPressed: _isSubmittingRequest ? null : () => _cancelRequest(r),
                child: const Text('İptal Et'),
              )
            : null,
      ),
    );
  }

  Widget _buildLegend() {
    Widget dot(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 14,
        runSpacing: 4,
        children: [
          dot(Colors.teal, 'Yaklaşan ders'),
          dot(Colors.green, 'Katıldı'),
          dot(Colors.red, 'Katılmadı'),
          dot(Colors.orange, 'Katılamayacağız'),
          dot(Colors.grey, 'Tatil'),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetail(DateTime day, WorkshopScheduleEntry? entry) {
    if (entry == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '${formatWorkshopDate(day)}\nBu tarihte RoboAkademi dersi yok.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    if (entry.isHoliday) {
      return ListTile(
        leading: const Icon(Icons.event_busy_rounded, color: Colors.grey),
        title: Text(formatWorkshopDate(entry.date)),
        subtitle: Text('Tatil — ${entry.holidayName}', style: const TextStyle(color: Colors.grey)),
      );
    }

    if (entry.hasTeacherRecord) {
      final record = entry.record!;
      return ListTile(
        leading: Icon(
          record.attended ? Icons.check_circle : Icons.cancel,
          color: record.attended ? Colors.green : Colors.red,
        ),
        title: Text('${formatWorkshopDate(entry.date)} — Hafta ${entry.weekNumber}'),
        subtitle: record.teacherNote != null && record.teacherNote!.isNotEmpty
            ? Text(record.teacherNote!)
            : Text(record.attended ? 'Derse katıldı' : 'Derse katılmadı'),
      );
    }

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

    if (!entry.isPast) {
      return ListTile(
        leading: const Icon(Icons.schedule_rounded, color: Colors.teal),
        title: Text('${formatWorkshopDate(entry.date)} — Hafta ${entry.weekNumber}'),
        subtitle: const Text('Yaklaşan ders'),
        trailing: TextButton(
          onPressed: _isUpdatingAbsence ? null : () => _markAbsence(entry),
          child: const Text('Katılamayacağız'),
        ),
      );
    }

    return ListTile(
      leading: const Icon(Icons.help_outline_rounded, color: Colors.grey),
      title: Text('${formatWorkshopDate(entry.date)} — Hafta ${entry.weekNumber}'),
      subtitle: const Text('Henüz kayıt girilmedi', style: TextStyle(color: Colors.grey)),
    );
  }
}
