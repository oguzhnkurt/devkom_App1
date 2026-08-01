import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/roboakademi_service.dart';
import '../../models/workshop_student_model.dart';
import '../../courses/data/roboakademi_curriculum_data.dart';
import '../../theme.dart';

/// Standalone "Müfredat" screen — read-only view of the 8-week RoboAkademi
/// curriculum matching the parent's child's assigned age group
/// (workshop_students.age_group). Reachable from the drawer for
/// RoboAkademi-enrolled parents only.
class RoboAkademiCurriculumScreen extends StatefulWidget {
  const RoboAkademiCurriculumScreen({super.key});

  @override
  State<RoboAkademiCurriculumScreen> createState() => _RoboAkademiCurriculumScreenState();
}

class _RoboAkademiCurriculumScreenState extends State<RoboAkademiCurriculumScreen> {
  final _service = RoboAkademiService();

  bool _isLoading = true;
  String? _error;
  List<WorkshopStudentModel> _children = [];
  WorkshopStudentModel? _selected;

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _children = children;
        _selected = children.isNotEmpty ? children.first : null;
      });
    } catch (e) {
      setState(() => _error = 'Müfredat yüklenemedi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müfredat'),
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
            const Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey),
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
    final curriculum = RoboAkademiCurriculumData.forAgeGroup(student.ageGroup);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_children.length > 1)
          Padding(
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
              },
            ),
          ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00979D), Color(0xFF00BCD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                curriculum.programTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                curriculum.programSubtitle,
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                curriculum.programDescription,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('📚 Haftalık Program', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
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
        const SizedBox(height: 20),
        const Text('🧰 Materyaller', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: curriculum.materials
                  .map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $m'),
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
