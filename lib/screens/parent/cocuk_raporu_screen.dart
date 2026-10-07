import 'package:flutter/material.dart';

import '../../services/child_link_service.dart';
import '../../services/cocuk_raporu.dart';
import '../../services/cocuk_raporu_kaynagi.dart';
import '../../services/progress_report_service.dart' show DayActivity;
import '../../theme.dart';
import '../../utils/lang.dart';

/// Velinin gordugu cocuk raporu.
///
/// Sira, velinin sordugu sorularin sirasi: "Nasil gidiyor?" (ust kart),
/// "Bu hafta calisti mi?" (son 7 gun), "Hangi gunler?" (14 gun), "Neler
/// iyi gidiyor?" (guzel haberler), "Nerede?" (kurslar), "Toplamda ne
/// yapti?" (basarilar), "Ben ne yapabilirim?" (sohbet sorusu).
///
/// Bu ekran HICBIR SEY YAZMIYOR; cocugun verisine dokunmuyor.
class CocukRaporuScreen extends StatefulWidget {
  const CocukRaporuScreen({
    super.key,
    required this.cocuk,
    this.yukleyici = cocukRaporuYukle,
    this.bagiKaldir,
  });

  final ChildLink cocuk;
  final CocukRaporuYukleyici yukleyici;

  /// Testte sahtesi veriliyor; verilmezse ChildLinkService.unlink.
  final Future<void> Function(String childId)? bagiKaldir;

  @override
  State<CocukRaporuScreen> createState() => _CocukRaporuScreenState();
}

class _CocukRaporuScreenState extends State<CocukRaporuScreen> {
  CocukRaporu? _rapor;
  bool _hata = false;

  String get _lang => Localizations.localeOf(context).languageCode;
  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  static const _mor = Color(0xFF5B3CC4);
  static const _yesil = Color(0xFF00A88F);
  static const _metin = Color(0xFF1F1B3A);
  static const _soluk = Color(0xFF6E6A85);

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    try {
      final r = await widget.yukleyici(widget.cocuk);
      if (!mounted) return;
      setState(() {
        _rapor = r;
        _hata = false;
      });
    } catch (e) {
      debugPrint('CocukRaporuScreen: $e');
      if (!mounted) return;
      setState(() => _hata = true);
    }
  }

  String get _ad {
    final ad = (widget.cocuk.childName ?? '').trim();
    return ad.isNotEmpty
        ? ad
        : _t('Çocuğunuz', 'Your child', 'Ihr Kind', 'Su hijo/a');
  }

  @override
  Widget build(BuildContext context) {
    final r = _rapor;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F2FB),
        surfaceTintColor: Colors.transparent,
        foregroundColor: _metin,
        elevation: 0,
        title: Text(
          _t('Gelişim raporu', 'Progress report', 'Lernbericht',
              'Informe de progreso'),
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: _metin,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _hata
            ? _hataGorunumu()
            : r == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _yukle,
                    child: ListView(
                      key: const ValueKey('cocuk_raporu_liste'),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      children: [
                        _ustKart(r),
                        const SizedBox(height: 14),
                        _son7Kart(r),
                        const SizedBox(height: 14),
                        _gunlerKart(r),
                        const SizedBox(height: 14),
                        _haberlerKart(r),
                        const SizedBox(height: 14),
                        if (r.ilerlemeVar) ...[
                          _kurslarKart(r),
                          const SizedBox(height: 14),
                          _basarilarKart(r),
                          const SizedBox(height: 14),
                        ] else ...[
                          _notKart(),
                          const SizedBox(height: 14),
                        ],
                        _sohbetKart(r),
                        const SizedBox(height: 18),
                        _altBilgi(),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ------------------------------------------------------------- parcalar

  Widget _kart({required Widget child, Color renk = Colors.white, Key? key}) =>
      Container(
        key: key,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: renk,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2A1F6B).withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: child,
      );

  Widget _baslik(String yazi, IconData simge, Color renk) => Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(simge, size: 18, color: renk),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              yazi,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _metin,
              ),
            ),
          ),
        ],
      );

  Widget _ustKart(CocukRaporu r) {
    final p = r.ilerleme;
    return Container(
      key: const ValueKey('rapor_ust'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A3DE8), Color(0xFF00B4C6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A3DE8).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Text(
                  _ad.characters.first.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6A3DE8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _ad,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            r.baslik(_lang),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 23,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.altBaslik(_lang),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          if (p != null) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _hap('⭐ ${_t('Seviye', 'Level', 'Level', 'Nivel')} ${p.level}'),
                _hap('⚡ ${p.totalXP} XP'),
                _hap('📘 ${r.toplamDers} ${_t('ders', 'lessons', 'Lektionen', 'lecciones')}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _hap(String yazi) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          yazi,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );

  Widget _son7Kart(CocukRaporu r) {
    final s = r.son7;
    return _kart(
      key: const ValueKey('rapor_son7'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _baslik(_t('Son 7 gün', 'Last 7 days', 'Letzte 7 Tage', 'Últimos 7 días'),
              Icons.calendar_today_rounded, _mor),
          const SizedBox(height: 14),
          Row(
            children: [
              _sayi('${s.aktifGun}/7',
                  _t('çalıştığı gün', 'days studied', 'Lerntage', 'días de estudio'),
                  const Color(0xFF7C4DFF)),
              _sayi('${s.yeniDers}', _t('yeni ders', 'new lessons', 'neue Lektionen', 'lecciones nuevas'),
                  const Color(0xFF00A88F)),
              _sayi('${s.quiz}', _t('quiz', 'quizzes', 'Quiz', 'cuestionarios'),
                  const Color(0xFFFF8F00)),
              _sayi('${s.xp}', 'XP', const Color(0xFF1E88E5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _t(
              'Önceki 7 gün: ${r.onceki7.aktifGun} gün çalıştı, ${r.onceki7.xp} XP kazandı.',
              'The 7 days before: studied ${r.onceki7.aktifGun} days, earned ${r.onceki7.xp} XP.',
              'Die 7 Tage davor: ${r.onceki7.aktifGun} Lerntage, ${r.onceki7.xp} XP.',
              'Los 7 días anteriores: ${r.onceki7.aktifGun} días, ${r.onceki7.xp} XP.',
            ),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _soluk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sayi(String deger, String etiket, Color renk) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: renk.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              FittedBox(
                child: Text(
                  deger,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: renk,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                etiket,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: _soluk,
                ),
              ),
            ],
          ),
        ),
      );

  static const _gunHarfleri = {
    'tr': ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'],
    'en': ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
    'de': ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
    'es': ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá', 'Do'],
  };

  Widget _gunlerKart(CocukRaporu r) {
    final harfler = _gunHarfleri[_lang] ?? _gunHarfleri['en']!;
    final enCok = r.gunler.fold<int>(0, (a, d) => d.xp > a ? d.xp : a);
    return _kart(
      key: const ValueKey('rapor_gunler'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _baslik(
              _t('Son 14 günde çalıştığı günler', 'Study days in the last 14 days',
                  'Lerntage der letzten 14 Tage', 'Días de estudio (últimos 14)'),
              Icons.bar_chart_rounded,
              _yesil),
          const SizedBox(height: 14),
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < r.gunler.length; i++)
                  _cubuk(r.gunler[i], enCok, harfler,
                      bugun: i == r.gunler.length - 1),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _t(
              'Her sütun bir gün. Renkli olanlar çalıştığı günler; '
                  'yükseklik o gün kazandığı XP.',
              'Each bar is a day. Coloured bars are study days; the height '
                  'is the XP earned that day.',
              'Jede Säule ist ein Tag. Farbige Säulen sind Lerntage; die Höhe '
                  'zeigt die XP des Tages.',
              'Cada barra es un día. Las de color son días de estudio; la '
                  'altura es el XP de ese día.',
            ),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: _soluk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cubuk(DayActivity d, int enCok, List<String> harfler,
      {required bool bugun}) {
    final dolu = !d.isEmpty;
    // Calisilan gun en az gorunur bir boy aliyor: XP'si az da olsa o gun
    // calisilmis, cubuk "yok" gibi durmamali.
    final oran = !dolu ? 0.0 : (enCok == 0 ? 0.35 : (0.25 + 0.75 * d.xp / enCok));
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: FractionallySizedBox(
                heightFactor: dolu ? oran : 0.08,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: dolu
                        ? const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF00A88F), Color(0xFF5BE3C5)],
                          )
                        : null,
                    color: dolu ? null : const Color(0xFFE6E3F0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              harfler[d.day.weekday - 1],
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 9.5,
                fontWeight: bugun ? FontWeight.w900 : FontWeight.w700,
                color: bugun ? _mor : _soluk,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _haberlerKart(CocukRaporu r) {
    final haberler = r.guzelHaberler(_lang);
    return _kart(
      key: const ValueKey('rapor_haberler'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _baslik(_t('Güzel haberler', 'Good news', 'Gute Nachrichten', 'Buenas noticias'),
              Icons.celebration_rounded, const Color(0xFFFF8F00)),
          const SizedBox(height: 10),
          if (haberler.isEmpty)
            Text(
              _t(
                'İlk güzel haber birlikte açacağınız ilk derste! '
                    'Her ders yaklaşık 10 dakika sürüyor.',
                'The first good news is waiting in the first lesson you open '
                    'together! Each lesson takes about 10 minutes.',
                'Die erste gute Nachricht wartet in der ersten gemeinsamen '
                    'Lektion! Eine Lektion dauert etwa 10 Minuten.',
                '¡La primera buena noticia está en la primera lección que abran '
                    'juntos! Cada lección dura unos 10 minutos.',
              ),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: _metin,
              ),
            )
          else
            for (final h in haberler)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 1),
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2EBD85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        h,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: _metin,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _kurslarKart(CocukRaporu r) {
    // Baslanmis kurslar + siradaki (ilk baslanmamis) kurs.
    final gosterilen = <KursDurumu>[];
    KursDurumu? siradaki;
    for (final k in r.kurslar) {
      if (k.basladi) {
        gosterilen.add(k);
      } else {
        siradaki ??= k;
      }
    }
    return _kart(
      key: const ValueKey('rapor_kurslar'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _baslik(_t('Kurslardaki yeri', 'Where they are in the courses',
                  'Stand in den Kursen', 'Dónde va en los cursos'),
              Icons.school_rounded, const Color(0xFF1E88E5)),
          const SizedBox(height: 6),
          for (final k in gosterilen) _kursSatiri(k),
          if (siradaki != null) _kursSatiri(siradaki, siradakiMi: true),
        ],
      ),
    );
  }

  Widget _kursSatiri(KursDurumu k, {bool siradakiMi = false}) {
    final renk = k.kurs.primaryColor;
    final sag = k.bitti
        ? _t('Tamamlandı 🏆', 'Completed 🏆', 'Fertig 🏆', 'Completado 🏆')
        : siradakiMi
            ? _t('Sıradaki', 'Up next', 'Als Nächstes', 'Siguiente')
            : '${k.biten} / ${k.toplam}';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  k.kurs.nameFor(_lang),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _metin,
                  ),
                ),
              ),
              Text(
                sag,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: siradakiMi ? _soluk : renk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: k.oran,
              minHeight: 9,
              backgroundColor: renk.withValues(alpha: 0.13),
              valueColor: AlwaysStoppedAnimation(renk),
            ),
          ),
        ],
      ),
    );
  }

  Widget _basarilarKart(CocukRaporu r) {
    final p = r.ilerleme!;
    final ogeler = <(String, String, String)>[
      ('📘', '${r.toplamDers}', _t('biten ders', 'lessons done', 'Lektionen', 'lecciones')),
      ('🏆', '${r.bitenKurslar.length}', _t('biten kurs', 'courses done', 'Kurse fertig', 'cursos')),
      ('⭐', '${p.level}', _t('seviye', 'level', 'Level', 'nivel')),
      ('⚡', '${p.totalXP}', _t('toplam XP', 'total XP', 'XP gesamt', 'XP total')),
      ('🎯', '${r.bitenGorev}', _t('görev', 'quests', 'Aufgaben', 'misiones')),
      ('🎬', '${r.izlenenVideo}', _t('video', 'videos', 'Videos', 'vídeos')),
    ];
    return _kart(
      key: const ValueKey('rapor_basarilar'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _baslik(_t('Bugüne kadar', 'So far', 'Bisher', 'Hasta ahora'),
              Icons.emoji_events_rounded, const Color(0xFFE6A100)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.15,
            children: [
              for (final (simge, deger, etiket) in ogeler)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F4FC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(simge, style: const TextStyle(fontSize: 18)),
                      FittedBox(
                        child: Text(
                          deger,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: _metin,
                          ),
                        ),
                      ),
                      Text(
                        etiket,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _soluk,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _notKart() => _kart(
        key: const ValueKey('rapor_not'),
        renk: const Color(0xFFEFF7FF),
        child: Text(
          _t(
            'Kurs ilerlemesi şu an alınamadı. Yukarıdaki günlük çalışma '
                'bilgileri günceldir; birazdan aşağı çekerek yenileyebilirsiniz.',
            'Course progress could not be loaded right now. The daily study '
                'data above is up to date; pull down to refresh in a moment.',
            'Der Kursfortschritt konnte gerade nicht geladen werden. Die '
                'Lerntage oben sind aktuell; zieh gleich nach unten zum Aktualisieren.',
            'Ahora no se pudo cargar el progreso de los cursos. Los días de '
                'estudio de arriba están al día; desliza hacia abajo para actualizar.',
          ),
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D5B8A),
          ),
        ),
      );

  Widget _sohbetKart(CocukRaporu r) => _kart(
        key: const ValueKey('rapor_sohbet'),
        renk: const Color(0xFFFFF7E0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _baslik(_t('Bu akşam sorabilirsiniz', 'Ask tonight', 'Heute Abend fragen',
                    'Pregúntele esta noche'),
                Icons.chat_bubble_rounded, const Color(0xFFE08A00)),
            const SizedBox(height: 10),
            Text(
              r.sohbetSorusu(_lang),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w800,
                color: _metin,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _t(
                'Sonuçtan çok merakı övmek, çocukların öğrenmeye devam etmesine '
                    'yardım eder.',
                'Praising curiosity more than results helps children keep learning.',
                'Neugier statt Ergebnisse zu loben, hilft Kindern dranzubleiben.',
                'Elogiar la curiosidad más que el resultado ayuda a seguir aprendiendo.',
              ),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: _soluk,
              ),
            ),
          ],
        ),
      );

  Widget _altBilgi() => Column(
        children: [
          Text(
            _t(
              'Veriler çocuğunuzun hesabından okunur ve yalnızca görüntülenir; '
                  'hiçbir şey değiştirilmez. Yenilemek için aşağı çekin.',
              "Data is read from your child's account and only displayed; "
                  'nothing is changed. Pull down to refresh.',
              'Die Daten werden aus dem Konto Ihres Kindes gelesen und nur '
                  'angezeigt; nichts wird geändert. Zum Aktualisieren nach unten ziehen.',
              'Los datos se leen de la cuenta de su hijo/a y solo se muestran; '
                  'no se cambia nada. Desliza hacia abajo para actualizar.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: _soluk,
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            key: const ValueKey('rapor_kaldir'),
            onPressed: _kaldir,
            style: TextButton.styleFrom(foregroundColor: _soluk),
            child: Text(
              _t('Bu çocuğu listemden kaldır', 'Remove this child from my list',
                  'Dieses Kind aus meiner Liste entfernen',
                  'Quitar a este niño/a de mi lista'),
              style: const TextStyle(
                  fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );

  Future<void> _kaldir() async {
    final evet = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _t('Listeden kaldırılsın mı?', 'Remove from the list?',
              'Aus der Liste entfernen?', '¿Quitar de la lista?'),
          style: const TextStyle(
              fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w900),
        ),
        content: Text(
          _t(
            'Raporu artık bu telefonda görmezsiniz. İsterseniz yeni bir '
                'kodla tekrar ekleyebilirsiniz.',
            "You won't see the report on this phone any more. You can add "
                'them again with a new code.',
            'Sie sehen den Bericht auf diesem Telefon nicht mehr. Mit einem '
                'neuen Code können Sie es wieder hinzufügen.',
            'Ya no verá el informe en este teléfono. Puede volver a añadirlo '
                'con un código nuevo.',
          ),
          style: const TextStyle(fontFamily: AppTheme.fontFamily, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(_t('Vazgeç', 'Cancel', 'Abbrechen', 'Cancelar')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(_t('Kaldır', 'Remove', 'Entfernen', 'Quitar')),
          ),
        ],
      ),
    );
    if (evet != true || !mounted) return;
    final kaldir = widget.bagiKaldir ??
        (String id) => ChildLinkService.unlink(childId: id);
    await kaldir(widget.cocuk.childId);
    if (mounted) Navigator.of(context).pop(true);
  }

  Widget _hataGorunumu() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: _soluk),
              const SizedBox(height: 12),
              Text(
                _t(
                  'Rapor şu an yüklenemedi. İnternet bağlantınızı kontrol edip '
                      'tekrar deneyin.',
                  'The report could not be loaded. Check your connection and try again.',
                  'Der Bericht konnte nicht geladen werden. Prüfen Sie die Verbindung.',
                  'No se pudo cargar el informe. Compruebe la conexión e inténtelo de nuevo.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: _metin,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  setState(() => _hata = false);
                  _yukle();
                },
                child: Text(_t('Tekrar dene', 'Try again', 'Erneut versuchen',
                    'Reintentar')),
              ),
            ],
          ),
        ),
      );
}
