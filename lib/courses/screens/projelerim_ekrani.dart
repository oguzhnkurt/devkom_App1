import 'package:flutter/material.dart';

import '../../services/proje_deposu.dart';
import '../../theme.dart';
import '../../utils/lang.dart';
import '../data/scratch_atolyeleri.dart';
import '../models/course_model.dart';
import '../models/interactive_lesson_model.dart';
import '../yurutme/kod_yapisi.dart';
import 'widgets/proje_atolyesi.dart';
import 'widgets/step_widgets.dart' show lessonLang;

/// Kurs ekranindaki "Projelerim" karti.
class KursAtolyeKarti extends StatelessWidget {
  const KursAtolyeKarti({
    super.key,
    required this.course,
    required this.baslik,
    required this.altBaslik,
    required this.ikon,
    required this.onTap,
  });

  final Course course;
  final String baslik;
  final String altBaslik;
  final IconData ikon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final koyu = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: koyu ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: course.primaryColor.withValues(alpha: 0.35),
                  width: 1.5),
            ),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: course.primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(ikon, color: course.primaryColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(baslik,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: koyu ? Colors.white : const Color(0xFF1A1A1A),
                        )),
                    const SizedBox(height: 2),
                    Text(altBaslik,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: koyu ? Colors.white60 : Colors.grey.shade600,
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: course.primaryColor),
            ]),
          ),
        ),
      ),
    );
  }
}

/// PROJELERIM: cocugun atolyede kaydettigi projeler.
///
/// Bir projeye dokununca atolye o kodla aciliyor; yesil bayrakla yeniden
/// calisiyor, degistirilip ustune kaydedilebiliyor. "Yeni proje" bos
/// (hedefsiz) atolyeyi butun atolye bloklariyla aciyor.
class ProjelerimEkrani extends StatefulWidget {
  const ProjelerimEkrani({super.key, required this.course});

  final Course course;

  @override
  State<ProjelerimEkrani> createState() => _ProjelerimEkraniState();
}

class _ProjelerimEkraniState extends State<ProjelerimEkrani> {
  List<KayitliProje>? _projeler;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final l = await ProjeDeposu.tumu(kursId: widget.course.id);
    if (mounted) setState(() => _projeler = l);
  }

  String _t(String lang, String tr, String en, String de, String es) =>
      AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

  Future<void> _ac(KayitliProje? proje) async {
    final adim = ScratchAtolyeleri.bul(proje?.adimId) ??
        ScratchAtolyeleri.serbest;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AtolyeEkrani(
          course: widget.course,
          step: adim,
          kayitli: proje,
        ),
      ),
    );
    await _yukle();
  }

  Future<void> _sil(KayitliProje p, String lang) async {
    final evet = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(_t(lang, 'Projeyi sil?', 'Delete project?',
            'Projekt löschen?', '¿Borrar el proyecto?')),
        content: Text('"${p.ad}"'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(_t(lang, 'Vazgeç', 'Cancel', 'Abbrechen',
                  'Cancelar'))),
          TextButton(
              key: const ValueKey('proje_sil_onay'),
              onPressed: () => Navigator.pop(c, true),
              child: Text(_t(lang, 'Sil', 'Delete', 'Löschen', 'Borrar'))),
        ],
      ),
    );
    if (evet != true) return;
    await ProjeDeposu.sil(p.id);
    await _yukle();
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final koyu = Theme.of(context).brightness == Brightness.dark;
    final renk = widget.course.primaryColor;
    final projeler = _projeler;
    return Scaffold(
      backgroundColor: koyu ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: renk,
        foregroundColor: Colors.white,
        title: Text(_t(lang, 'Projelerim', 'My Projects', 'Meine Projekte',
            'Mis proyectos')),
      ),
      body: projeler == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ElevatedButton.icon(
                  key: const ValueKey('yeni_proje'),
                  onPressed: () => _ac(null),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(_t(lang, 'Yeni proje (serbest atölye)',
                      'New project (free workshop)',
                      'Neues Projekt (freie Werkstatt)',
                      'Proyecto nuevo (taller libre)')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: renk,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
                if (projeler.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      _t(
                          lang,
                          'Henüz kayıtlı projen yok. Derslerdeki Proje Atölyesi\'nde "Kaydet"e basınca projelerin burada durur.',
                          'No saved projects yet. Press "Save" in a lesson\'s Project Workshop and your projects will wait here.',
                          'Noch keine gespeicherten Projekte. Drück in der Projektwerkstatt einer Lektion auf „Speichern“, dann warten deine Projekte hier.',
                          'Aún no tienes proyectos guardados. Pulsa "Guardar" en el Taller de proyectos de una lección y tus proyectos te esperarán aquí.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        height: 1.4,
                        color: koyu ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                for (final p in projeler) _kart(p, lang, koyu, renk),
              ],
            ),
    );
  }

  Widget _kart(KayitliProje p, String lang, bool koyu, Color renk) {
    final adim = ScratchAtolyeleri.bul(p.adimId);
    final blok = p.kod.where((o) => !KodYapisi.isaretMi(o.id)).length;
    final t = p.tarih;
    String iki(int n) => n.toString().padLeft(2, '0');
    final tarih = '${iki(t.day)}.${iki(t.month)}.${t.year}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: koyu ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: ValueKey('proje_${p.id}'),
          borderRadius: BorderRadius.circular(16),
          onTap: () => _ac(p),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: renk.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.extension_rounded, color: renk),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.ad,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                          color: koyu ? Colors.white : const Color(0xFF1A1A1A),
                        )),
                    const SizedBox(height: 2),
                    Text(
                      [
                        adim?.titleFor(lang) ??
                            ScratchAtolyeleri.serbest.titleFor(lang),
                        _t(lang, '$blok blok', '$blok blocks', '$blok Blöcke',
                            '$blok bloques'),
                        tarih,
                      ].join(' · '),
                      maxLines: 2,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: koyu ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: _t(lang, 'Çalıştır', 'Run', 'Ausführen', 'Ejecutar'),
                icon: const Icon(Icons.play_circle_fill_rounded,
                    color: Color(0xFF4CBF56), size: 30),
                onPressed: () => _ac(p),
              ),
              IconButton(
                key: ValueKey('proje_sil_${p.id}'),
                tooltip: _t(lang, 'Sil', 'Delete', 'Löschen', 'Borrar'),
                icon: Icon(Icons.delete_outline_rounded,
                    color: Colors.grey.shade500),
                onPressed: () => _sil(p, lang),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Atolyeyi tek basina (ders disinda) acan ekran.
class AtolyeEkrani extends StatelessWidget {
  const AtolyeEkrani({
    super.key,
    required this.course,
    required this.step,
    this.kayitli,
  });

  final Course course;
  final ProjeAtolyesiStep step;
  final KayitliProje? kayitli;

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final koyu = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: koyu ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: course.primaryColor,
        foregroundColor: Colors.white,
        title: Text(kayitli?.ad ?? step.titleFor(lang)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: ProjeAtolyesiWidget(
          step: step,
          course: course,
          isDark: koyu,
          lang: lang,
          kayitli: kayitli,
        ),
      ),
    );
  }
}
