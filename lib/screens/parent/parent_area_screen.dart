import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_progress_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/certificate_service.dart';
import '../../services/child_link_service.dart';
import '../../services/progress_report_service.dart';
import '../../services/user_progress_service.dart';
import '../../services/weekly_goal_service.dart';
import '../../theme.dart';
import '../../ui/appear_in.dart';
import '../../utils/lang.dart';

/// Ebeveyn alani.
///
/// NEDEN BU EKRAN VAR:
///
/// Bu uygulamayi cocuk kullaniyor ama parayi ebeveyn oduyor, ve
/// ebeveynin urunle tek temasi simdiye kadar odeme ekraniydi. Rakip
/// urunlerin abonelik verilerinde en tekrar eden bulgu su: cocugunun
/// ilerlemesini gorebilen ebeveynin aboneligi surdurme olasiligi 2-3
/// kat daha yuksek. En sik iptal gerekcesi de "cocuk ilgisini
/// kaybetti" — ki bunu ebeveyn ancak bir rapor gorursen fark eder.
///
/// Yani bu ekran bir "ekstra ozellik" degil, urunun ikinci
/// kullanicisina yapilmis ilk arayuz.
///
/// TASARIM KARARLARI:
///
///  * Cocugun arayuzunden AYRI. Icinde satin alma yonlendirmesi yok;
///    Apple'in Cocuklar kategorisi kurali zaten satin alma ve dis
///    baglantilarin ebeveyn kapisinin arkasinda olmasini istiyor.
///  * Rakamlar abartilmiyor. Elimizde ders bazinda DOGRULUK verisi yok,
///    o yuzden "ustalik %85" gibi bir sey yazmiyoruz — tamamlama
///    sayisi yaziyoruz ve oyle adlandiriyoruz.
///  * Oyun suresi ile ders suresi AYRI gosteriliyor. Bazi rakipler oyun
///    suresini rapordan tamamen cikariyor ve bunun icin elestiriliyor;
///    ebeveyn ikisini de gormeli, hangisinin ne oldugunu bilerek.
class ParentAreaScreen extends StatefulWidget {
  const ParentAreaScreen({super.key});

  @override
  State<ParentAreaScreen> createState() => _ParentAreaScreenState();
}

class _ParentAreaScreenState extends State<ParentAreaScreen> {
  final ProgressReportService _service = ProgressReportService();

  String get _lang => Localizations.localeOf(context).languageCode;

  String _t(String tr, String en, [String? de, String? es]) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  ProgressReport? _report;
  List<Certificate> _certificates = const [];
  WeeklyGoalState? _goal;
  bool _loading = true;
  String? _error;

  /// Bu cihaz baska bir cocuga bagliysa rapor ONUN verisinden kuruluyor.
  ChildLink? _linkedChild;

  /// Cocugun cihazinda gosterilen eslestirme kodu.
  String? _pairCode;
  int _watchers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    var progress = context.read<AuthProvider>().userProgress;
    try {
      // Once: bu cihaz bir cocuga bagli mi? Bagliysa rapor onun
      // verisinden kuruluyor, cihazin sahibininkinden degil.
      final link = await ChildLinkService.linkedChild();
      if (link != null) {
        progress = await UserProgressService().loadUserProgress(link.childId);
      }

      final report = await _service.build(progress, forUserId: link?.childId);
      final target = await WeeklyGoalService.target();

      // Cocugun kendi cihazinda: kod ve kac kisinin takip ettigi.
      final code = link == null ? await ChildLinkService.currentCode() : null;
      final watchers = link == null ? await ChildLinkService.watcherCount() : 0;

      if (!mounted) return;
      setState(() {
        _linkedChild = link;
        _pairCode = code;
        _watchers = watchers;
        _report = report;
        _certificates = CertificateService.build(progress, report);
        _goal = WeeklyGoalService.stateFrom(report.lastDays, target);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Ham istisna metni ekrana basilmiyor.
      debugPrint('Parent area load failed: $e');
      setState(() {
        _error = _t(
          'Rapor şu an yüklenemedi. İnternet bağlantınızı kontrol edip '
              'tekrar deneyin.',
          'The report could not be loaded. Check your connection and try '
              'again.',
          'Der Bericht konnte nicht geladen werden. Prüfe deine Verbindung '
              'und versuch es erneut.',
          'No se ha podido cargar el informe. Comprueba tu conexión e '
              'inténtalo de nuevo.',
        );
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<AuthProvider>().userProgress;
    // Bagli bir cocuk varsa onun adi; yoksa cihazin sahibinin adi.
    final childName = _linkedChild?.childName ??
        context.watch<AuthProvider>().currentUser?.name;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.lightGray,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppTheme.darkGray,
        elevation: 0,
        title: Text(
          _t('Ebeveyn Alanı', 'Parent Area', 'Elternbereich',
              'Área para familias'),
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkGray,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    if (_error != null) _errorCard(_error!),
                    AppearIn(
                      delay: AppearIn.stagger(0),
                      child: _linkCard(),
                    ),
                    const SizedBox(height: 14),
                    AppearIn(
                      delay: AppearIn.stagger(1),
                      child: _weekCard(childName),
                    ),
                    const SizedBox(height: 14),
                    AppearIn(
                      delay: AppearIn.stagger(1),
                      child: _timeCard(),
                    ),
                    const SizedBox(height: 14),
                    AppearIn(
                      delay: AppearIn.stagger(2),
                      child: _coursesCard(),
                    ),
                    const SizedBox(height: 14),
                    AppearIn(
                      delay: AppearIn.stagger(3),
                      child: _certificatesCard(),
                    ),
                    const SizedBox(height: 14),
                    AppearIn(
                      delay: AppearIn.stagger(4),
                      child: _totalsCard(progress),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // Kartlar
  // -----------------------------------------------------------------

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8EAEE)),
        ),
        child: child,
      );

  Widget _title(String text, {String? trailing}) => Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkGray,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.mediumGray,
              ),
            ),
        ],
      );

  Widget _errorCard(String message) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _card(
          child: Row(
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: AppTheme.mediumGray, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13.5,
                    height: 1.35,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  /// Eslestirme karti.
  ///
  /// Iki hali var:
  ///  * Cocugun cihazinda: alti karakterlik kod ve kac kisinin takip
  ///    ettigi. Kod buradan cikiyor, yani gormek icin telefona fiziksel
  ///    erisim ve ebeveyn kapisindan gecmek gerekiyor.
  ///  * Ebeveynin cihazinda: kime bagli oldugu ve bagi koparma.
  Widget _linkCard() {
    final link = _linkedChild;

    if (link != null) {
      return _card(
        child: Row(
          children: [
            const Icon(Icons.link_rounded, color: AppTheme.primaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.childName ??
                        _t('Çocuğun', 'Your child', 'Dein Kind', 'Tu hijo/a'),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  Text(
                    _t(
                        'Bu rapor ona ait.',
                        'This report is theirs.',
                        'Dieser Bericht gehört ihm/ihr.',
                        'Este informe es suyo.'),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12.5,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                await ChildLinkService.unlink(childId: link.childId);
                if (mounted) _load();
              },
              child:
                  Text(_t('Bağı kaldır', 'Unlink', 'Trennen', 'Desvincular')),
            ),
          ],
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(_t('Takip kodu', 'Follow code', 'Zugangscode',
              'Código de seguimiento')),
          const SizedBox(height: 4),
          Text(
            _t(
              'Bu kodu ebeveyn telefonundaki uygulamaya girerek çocuğunuzun '
                  'ilerlemesini oradan takip edebilirsiniz.',
              'Enter this code in the app on a parent phone to follow your '
                  "child's progress from there.",
              'Gib diesen Code in der App auf einem Elterntelefon ein, um '
                  'den Fortschritt deines Kindes dort zu verfolgen.',
              'Escribe este código en la app del móvil de una madre o padre '
                  'para seguir el progreso desde allí.',
            ),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12.5,
              height: 1.4,
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.30),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _pairCode == null
                        ? '••• •••'
                        : ChildLinkService.pretty(_pairCode!),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _watchers == 0
                ? _t(
                    'Kod 24 saat geçerli. Henüz kimse takip etmiyor.',
                    'The code is valid for 24 hours. Nobody follows yet.',
                    'Der Code gilt 24 Stunden. Noch folgt niemand.',
                    'El código vale 24 horas. Todavía no te sigue nadie.')
                : _t(
                    'Kod 24 saat geçerli. $_watchers kişi takip ediyor.',
                    'The code is valid for 24 hours. $_watchers following.',
                    'Der Code gilt 24 Stunden. $_watchers folgen.',
                    'El código vale 24 horas. $_watchers siguiéndote.'),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              TextButton.icon(
                onPressed: () async {
                  await ChildLinkService.revokeCode();
                  if (mounted) _load();
                },
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: Text(
                    _t('Yeni kod', 'New code', 'Neuer Code', 'Código nuevo')),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _enterCode,
                icon: const Icon(Icons.login_rounded, size: 17),
                label: Text(_t('Kod gir', 'Enter a code', 'Code eingeben',
                    'Introducir código')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Ebeveynin kod girdigi kutu.
  Future<void> _enterCode() async {
    final controller = TextEditingController();
    var busy = false;
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setLocal) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            _t(
                'Çocuğunun kodunu gir',
                "Enter your child's code",
                'Code deines Kindes eingeben',
                'Escribe el código de tu hijo/a'),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t(
                  'Kodu çocuğunun telefonunda Ayarlar → Ebeveyn Alanı '
                      'bölümünde bulabilirsin.',
                  'You can find the code on your child\'s phone under '
                      'Settings → Parent Area.',
                  'Du findest den Code auf dem Telefon deines Kindes unter '
                      'Einstellungen → Elternbereich.',
                  'Encontrarás el código en el móvil de tu hijo/a en '
                      'Ajustes → Área para familias.',
                ),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  height: 1.4,
                  color: AppTheme.mediumGray,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                maxLength: 7,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                ),
                decoration: InputDecoration(
                  hintText: 'ABC-123',
                  counterText: '',
                  errorText: error,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) {
                  if (error != null) setLocal(() => error = null);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(dialogContext),
              child: Text(_t('Vazgeç', 'Cancel', 'Abbrechen', 'Cancelar')),
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      setLocal(() => busy = true);
                      final childId =
                          await ChildLinkService.redeem(controller.text);
                      if (childId == null) {
                        setLocal(() {
                          busy = false;
                          error = _t(
                            'Bu kod geçerli değil ya da süresi dolmuş.',
                            'That code is not valid or has expired.',
                            'Dieser Code ist ungültig oder abgelaufen.',
                            'Ese código no es válido o ha caducado.',
                          );
                        });
                        return;
                      }
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      if (mounted) _load();
                    },
              child: Text(_t('Bağlan', 'Connect', 'Verbinden', 'Conectar')),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  /// Bu haftaki hedef — ekranin en ustunde, cunku ebeveynin sordugu ilk
  /// soru bu: "bu hafta calisti mi?"
  Widget _weekCard(String? childName) {
    final goal = _goal;
    if (goal == null) return const SizedBox.shrink();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(childName == null
              ? _t('Bu hafta', 'This week', 'Diese Woche', 'Esta semana')
              : '$childName — ${_t('bu hafta', 'this week', 'diese Woche', 'esta semana')}'),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${goal.done}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2E7D32),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 4),
                child: Text(
                  '/ ${goal.target} ${_t('ders', 'lessons', 'Lektionen', 'lecciones')}',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _editGoal,
                icon: const Icon(Icons.tune_rounded, size: 17),
                label: Text(_t('Hedefi değiştir', 'Change goal', 'Ziel ändern',
                    'Cambiar meta')),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.ratio,
              minHeight: 10,
              backgroundColor: const Color(0xFFE7EBEF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            goal.reached
                ? _t(
                    'Bu haftanın hedefi tamamlandı. ${goal.activeDays} gün çalıştı.',
                    'This week\'s goal is done. Studied on ${goal.activeDays} days.',
                    'Das Wochenziel ist geschafft. An ${goal.activeDays} Tagen gelernt.',
                    'La meta de esta semana está cumplida. Ha estudiado ${goal.activeDays} días.',
                  )
                : _t(
                    'Hedefe ${goal.remaining} ders kaldı. Bu hafta ${goal.activeDays} gün çalıştı.',
                    '${goal.remaining} lessons to go. Studied on ${goal.activeDays} days this week.',
                    'Noch ${goal.remaining} Lektionen. Diese Woche an ${goal.activeDays} Tagen gelernt.',
                    'Faltan ${goal.remaining} lecciones. Esta semana ha estudiado ${goal.activeDays} días.',
                  ),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13.5,
              height: 1.35,
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  /// Son 14 gunun gunluk dagilimi.
  Widget _timeCard() {
    final days = _report?.lastDays ?? const <DayActivity>[];
    if (days.isEmpty) return const SizedBox.shrink();

    final maxLessons =
        days.fold<int>(1, (a, d) => d.lessons > a ? d.lessons : a);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(
              _t('Son 14 gün', 'Last 14 days', 'Letzte 14 Tage',
                  'Últimos 14 días'),
              trailing: '${_report?.activeDays ?? 0} '
                  '${_t('aktif gün', 'active days', 'aktive Tage', 'días activos')}'),
          const SizedBox(height: 16),
          SizedBox(
            height: 78,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final d in days)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height:
                                (d.lessons / maxLessons * 56).clamp(3.0, 56.0),
                            decoration: BoxDecoration(
                              color: d.isEmpty
                                  ? const Color(0xFFE7EBEF)
                                  : AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _dayLetter(d.day),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Ders ve oyun AYRI. Sadece dersi gostermek raporu guzellestirir
          // ama ebeveyni yanlis bilgilendirir.
          Row(
            children: [
              _stat(_t('Ders', 'Lessons', 'Lektionen', 'Lecciones'),
                  days.fold(0, (a, d) => a + d.lessons)),
              _stat(_t('Sınav', 'Quizzes', 'Quiz', 'Pruebas'),
                  days.fold(0, (a, d) => a + d.quizzes)),
              _stat(_t('Video', 'Videos', 'Videos', 'Vídeos'),
                  days.fold(0, (a, d) => a + d.videos)),
              _stat('XP', days.fold(0, (a, d) => a + d.xp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value) => Expanded(
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        ),
      );

  static String _dayLetter(DateTime d) =>
      const ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'][d.weekday - 1];

  /// Kurs kurs tamamlama. "Ustalik" demiyoruz — elimizde dogruluk
  /// verisi yok, tamamlama sayisi var.
  Widget _coursesCard() {
    final courses = _report?.courses ?? const <CourseProgress>[];
    if (courses.isEmpty) return const SizedBox.shrink();

    final started = courses.where((c) => c.started).toList();
    final shown = started.isEmpty ? courses.take(3).toList() : started;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(_t('Konular', 'Topics', 'Themen', 'Temas')),
          const SizedBox(height: 4),
          Text(
            _t(
              'Tamamlanan ders sayısı. Doğruluk oranı henüz ölçülmüyor.',
              'Lessons completed. Accuracy is not measured yet.',
              'Abgeschlossene Lektionen. Die Trefferquote wird noch nicht '
                  'gemessen.',
              'Lecciones completadas. Todavía no medimos el porcentaje de '
                  'aciertos.',
            ),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 14),
          for (final c in shown) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.course.nameFor(_lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ),
                Text(
                  '${c.completed} / ${c.total}',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: c.ratio,
                minHeight: 7,
                backgroundColor: const Color(0xFFE7EBEF),
                valueColor: AlwaysStoppedAnimation(
                  c.finished ? const Color(0xFF2E7D32) : AppTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _certificatesCard() {
    if (_certificates.isEmpty) return const SizedBox.shrink();
    final earned = CertificateService.earnedCount(_certificates);
    final next = CertificateService.nextUp(_certificates);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(
              _t('Sertifikalar', 'Certificates', 'Zertifikate', 'Certificados'),
              trailing: '$earned / ${_certificates.length}'),
          const SizedBox(height: 4),
          const Text(
            'Bir kursun tüm derslerini bitirdiğinde adına bir sertifika '
            'açılıyor.',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              height: 1.35,
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 14),
          if (next != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      color: AppTheme.primaryBlue, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_t('Sıradaki', 'Next up', 'Als Nächstes', 'Siguiente')}: '
                          '${next.titleFor(_lang)}',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${next.completed} / ${next.total} '
                          '${_t('ders tamamlandı', 'lessons done', 'Lektionen geschafft', 'lecciones hechas')}',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          for (final c in _certificates.where((c) => c.earned)) ...[
            Row(
              children: [
                const Icon(Icons.verified_rounded,
                    color: Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    c.titleFor(_lang),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (earned == 0)
            Text(
              _t('Henüz sertifika yok.', 'No certificates yet.',
                  'Noch keine Zertifikate.', 'Todavía no hay certificados.'),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: AppTheme.mediumGray,
              ),
            ),
        ],
      ),
    );
  }

  Widget _totalsCard(UserProgress? progress) {
    if (progress == null) return const SizedBox.shrink();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(_t('Toplam', 'Total', 'Gesamt', 'Total')),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat(_t('Ders', 'Lessons', 'Lektionen', 'Lecciones'),
                  progress.completedLessonIds.length),
              _stat('XP', progress.totalXP),
              _stat(_t('Seviye', 'Level', 'Stufe', 'Nivel'), progress.level),
              _stat(_t('Gün serisi', 'Day streak', 'Tagesserie', 'Racha'),
                  progress.streakDays),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _editGoal() async {
    final current = _goal?.target ?? WeeklyGoalService.defaultTarget;
    final picked = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                _t('Haftalık hedef', 'Weekly goal', 'Wochenziel',
                    'Meta semanal'),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkGray,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                _t(
                  'Haftada kaç ders? Günlük seri yerine haftalık bir hedef '
                      'kullanıyoruz: okula giden bir çocuk bir günü '
                      'atladığında her şeyi kaybetmesin.',
                  'How many lessons a week? We use a weekly goal instead of '
                      'a daily streak, so a school day missed does not wipe '
                      'everything out.',
                  'Wie viele Lektionen pro Woche? Wir nutzen ein Wochenziel '
                      'statt einer Tagesserie — ein verpasster Schultag soll '
                      'nicht alles zunichtemachen.',
                  '¿Cuántas lecciones por semana? Usamos una meta semanal en '
                      'vez de una racha diaria: perder un día de colegio no '
                      'debería borrarlo todo.',
                ),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  height: 1.4,
                  color: AppTheme.mediumGray,
                ),
              ),
            ),
            // RadioListTile'in `groupValue`/`onChanged` alanlari
            // kullanimdan kaldirildi; ayrica burada tek bir secim
            // yapilip sayfa kapaniyor, yani bir radyo grubuna gerek yok.
            for (final n in WeeklyGoalService.choices)
              ListTile(
                onTap: () => Navigator.pop(sheetContext, n),
                leading: Icon(
                  n == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color:
                      n == current ? AppTheme.primaryBlue : AppTheme.mediumGray,
                ),
                title: Text(
                  _t('Haftada $n ders', '$n lessons a week',
                      '$n Lektionen pro Woche', '$n lecciones por semana'),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    color:
                        n == current ? AppTheme.primaryBlue : AppTheme.darkGray,
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (picked == null || !mounted) return;
    await WeeklyGoalService.setTarget(picked);
    final days = _report?.lastDays ?? const <DayActivity>[];
    if (!mounted) return;
    setState(() => _goal = WeeklyGoalService.stateFrom(days, picked));
  }
}
