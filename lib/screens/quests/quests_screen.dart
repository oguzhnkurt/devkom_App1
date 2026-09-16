import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/lang.dart';
import '../../providers/settings_provider.dart';
import '../../models/quest_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/quest_service.dart';
import '../../utils/pro_gate.dart';

/// Görevlerim.
///
/// Eski "Ödevlerim" ekranının yerini alıyor. Görev atayan bir öğretmen yok;
/// görevler kolaydan zora kademeli açılıyor ve çoğu, kullanıcı zaten ders
/// çalışırken kendiliğinden tamamlanıyor.
class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  final QuestService _service = QuestService();

  bool _isLoading = true;
  List<QuestState> _quests = [];
  String? _busySlug;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final quests = await _service.getQuests(auth.userProgress);
    if (!mounted) return;
    setState(() {
      _quests = quests;
      _isLoading = false;
    });
  }

  /// Tamamlanmış ama ödülü alınmamış görevlerin ödülünü verir.
  Future<void> _claim(QuestState state) async {
    if (_busySlug != null) return;

    if (state.quest.requiresPro) {
      final ok = await ProGate.ensure(
        context,
        featureName: state.quest.title,
        explanation: 'Bu görevin ödülünü almak için Pro üyelik gerekiyor.',
      );
      if (!ok || !mounted) return;
    }

    setState(() => _busySlug = state.quest.slug);

    final ok = await _service.claimReward(state.quest);
    if (!mounted) return;

    if (ok) {
      await context.read<AuthProvider>().refreshProgress();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Görev tamam! +${state.quest.xpReward} XP, +${state.quest.jetonReward} 🪙',
          ),
        ),
      );
    }
    setState(() => _busySlug = null);
    await _load();
  }

  /// Manuel görevlerde "yaptım" akışı: kısa bir not istiyoruz.
  Future<void> _submitManual(QuestState state) async {
    if (state.quest.requiresPro) {
      final ok = await ProGate.ensure(
        context,
        featureName: state.quest.title,
        explanation: 'Pro görevleri en büyük ödülleri veriyor — bu görev '
            '${state.quest.xpReward} XP ve ${state.quest.jetonReward} jeton kazandırıyor.',
      );
      if (!ok || !mounted) return;
    }

    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => _ManualQuestSheet(quest: state.quest),
    );
    if (note == null || !mounted) return;

    setState(() => _busySlug = state.quest.slug);
    final saved = await _service.completeManual(state.quest, note);
    if (saved) await _service.claimReward(state.quest);
    if (!mounted) return;
    await context.read<AuthProvider>().refreshProgress();
    if (!mounted) return;

    setState(() => _busySlug = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Aferin! +${state.quest.xpReward} XP, +${state.quest.jetonReward} 🪙'
              : 'Kaydedilemedi, tekrar dener misin?',
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_t(context, 'Görevlerim', 'My quests', 'Meine Aufgaben', 'Mis misiones')),
        backgroundColor: const Color(0xFF6C3CE0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_quests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 140),
          const Center(child: Text('🎯', style: TextStyle(fontSize: 48))),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Görevler yüklenemedi. Aşağı çekip tekrar dene.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
        ],
      );
    }

    final done = _quests.where((q) => q.completed).length;

    final widgets = <Widget>[_buildSummary(done, _quests.length)];
    for (final difficulty in QuestDifficulty.values) {
      final group = _quests.where((q) => q.quest.difficulty == difficulty).toList();
      if (group.isEmpty) continue;
      widgets.add(const SizedBox(height: 22));
      widgets.add(_buildTierHeader(difficulty, group));
      widgets.add(const SizedBox(height: 10));
      for (final q in group) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildQuestCard(q),
        ));
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: widgets,
    );
  }

  Widget _buildSummary(int done, int total) {
    final ratio = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C3CE0), Color(0xFF9B6BFF)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Görev Yolun',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$done / $total',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Görevlerin çoğu sen ders çalışırken kendiliğinden tamamlanır. '
            'Bazılarında ise bir şey üretip buraya not düşersin.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierHeader(QuestDifficulty difficulty, List<QuestState> group) {
    final color = questDifficultyColor(difficulty);
    final done = group.where((q) => q.completed).length;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            questDifficultyLabel(difficulty),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            questDifficultyTagline(difficulty),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        Text(
          '$done/${group.length}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestCard(QuestState state) {
    final quest = state.quest;
    final color = questDifficultyColor(quest.difficulty);
    final busy = _busySlug == quest.slug;
    final locked = state.locked;
    final claimable = state.completed && !state.rewarded;

    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: state.completed ? color.withValues(alpha: 0.45) : Colors.grey.shade200,
            width: state.completed ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: locked
                        ? Icon(Icons.lock_rounded, size: 20, color: Colors.grey[500])
                        : Text(quest.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F1D36),
                          decoration: state.completed ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.description,
                        style: TextStyle(fontSize: 12.5, color: Colors.grey[700], height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (state.completed)
                  Icon(Icons.check_circle_rounded, color: color, size: 22)
                else if (quest.requiresPro)
                  ProGate.badge(size: 9),
              ],
            ),
            const SizedBox(height: 12),
            if (!quest.isManual && !locked) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: state.ratio,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    state.progressLabel ?? '',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                _rewardChip('⭐', '${quest.xpReward} XP', color),
                const SizedBox(width: 8),
                _rewardChip('🪙', '${quest.jetonReward}', color),
                const Spacer(),
                if (locked)
                  Text(
                    'Önceki görevi bitir',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                  )
                else if (claimable)
                  FilledButton(
                    onPressed: busy ? null : () => _claim(state),
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _t(context, 'Ödülü al', 'Collect reward',
                                'Belohnung holen', 'Recoger premio'),
                            style: const TextStyle(fontSize: 12.5)),
                  )
                else if (quest.isManual && !state.completed)
                  OutlinedButton(
                    onPressed: busy ? null : () => _submitManual(state),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                        _t(context, 'Yaptım', 'Done', 'Erledigt', 'Hecho'),
                        style: const TextStyle(fontSize: 12.5)),
                  ),
              ],
            ),
            if (state.note != null && state.note!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  state.note!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[800], height: 1.35),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rewardChip(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

/// Manuel görev tamamlama sayfası: ne yaptığını kısaca yazdırıyoruz.
class _ManualQuestSheet extends StatefulWidget {
  final Quest quest;

  const _ManualQuestSheet({required this.quest});

  @override
  State<_ManualQuestSheet> createState() => _ManualQuestSheetState();
}

class _ManualQuestSheetState extends State<_ManualQuestSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.length < 10) {
      setState(() => _error = 'Birkaç cümle yaz — en az 10 karakter.');
      return;
    }
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.quest.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.quest.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Ne yaptığını kısaca anlat. Hangi blokları kullandın, ne zorlandı, '
            'sonuç ne oldu?',
            style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 4,
            maxLength: 400,
            decoration: InputDecoration(
              hintText: 'Örn. Kediyi ok tuşlarıyla hareket ettirdim ve...',
              errorText: _error,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_t(context, 'Gönder  ·  +${widget.quest.xpReward} XP',
                    'Send  ·  +${widget.quest.xpReward} XP',
                    'Senden  ·  +${widget.quest.xpReward} XP',
                    'Enviar  ·  +${widget.quest.xpReward} XP')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ekrandaki kısa arayüz yazıları için dört dilli yardımcı.
///
/// Bu ekran tamamen Türkçe sabit yazılarla yazılmıştı; İngilizce,
/// Almanca ya da İspanyolca seçen çocuk uygulamanın geri kalanı
/// çevrilmişken burada Türkçe görüyordu.
String _t(BuildContext context, String tr, String en, String de, String es) =>
    AppLang.pick(
      Provider.of<SettingsProvider>(context).locale.languageCode,
      tr: tr,
      en: en,
      de: de,
      es: es,
    );
