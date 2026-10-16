import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/sound_service.dart';
import '../../../theme.dart';
import '../../devre/devre_duzenleyici.dart';
import '../../devre/devre_modeli.dart';
import '../../devre/devre_simulasyonu.dart';
import '../../models/course_model.dart';
import '../../models/interactive_lesson_model.dart';
import '../../yurutme/mblock_uno.dart';
import 'step_widgets.dart' show lessonLang, lessonText;

/// Arduino dersinde REHBERLI DEVRE KURMA adimi.
///
/// Ustte kisa talimat ve ilerleme ("2/4"), altinda siradaki baglanti;
/// ortada devre duzenleyicisi (rehberli kip): parcalar yerinde, siradaki
/// hedefin iki ucu yanip soner, ait oldugu 5'li serit hafifce boyanir.
/// Hedefler bitince yesil serit ve "Devam".
class DevreKurmaAdimi extends StatefulWidget {
  const DevreKurmaAdimi({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  final DevreKurmaStep step;
  final Course course;
  final bool isDark;
  final ValueChanged<bool> onComplete;

  @override
  State<DevreKurmaAdimi> createState() => DevreKurmaAdimiState();
}

class DevreKurmaAdimiState extends State<DevreKurmaAdimi> {
  final UnoKarti _kart = UnoKarti();
  late final DevreSimulasyonu _sim =
      DevreSimulasyonu(kart: _kart, devre: widget.step.baslangic, ses: false);
  final GlobalKey<DevreDuzenleyiciState> _duzenleyici = GlobalKey();
  bool _bitti = false;
  bool _yardimAlindi = false;

  @visibleForTesting
  DevreDuzenleyiciState? get duzenleyici => _duzenleyici.currentState;

  bool get bitti => _bitti;

  @override
  void dispose() {
    _sim.dispose();
    _kart.dispose();
    super.dispose();
  }

  void _tamam() {
    if (_bitti) return;
    SoundService.playBlokTamam();
    HapticFeedback.mediumImpact();
    setState(() => _bitti = true);
    widget.onComplete(!_yardimAlindi);
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final s = widget.step;
    final hedefler = s.hedefler;
    final durum = hedefDurumu(_sim.devre, hedefler);
    final tamam = durum.where((x) => x).length;
    final siradaki = [
      for (var i = 0; i < hedefler.length; i++)
        if (!durum[i]) hedefler[i]
    ].firstOrNull;
    final renk = widget.course.primaryColor;
    final yazi = widget.isDark ? Colors.white : const Color(0xFF263238);
    final h = MediaQuery.sizeOf(context).height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cable_rounded, color: renk, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(s.talimatFor(lang),
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: yazi)),
          ),
        ]),
        const SizedBox(height: 10),
        AnimatedContainer(
          key: const ValueKey('devre_adim_hedef'),
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: _bitti ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _bitti ? const Color(0xFFA5D6A7) : const Color(0xFFFFE082)),
          ),
          child: Row(children: [
            Icon(_bitti ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                size: 20, color: _bitti ? const Color(0xFF2E7D32) : const Color(0xFFB26A00)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _bitti
                    ? lessonText(lang, 'Devre tamam! Bütün kablolar yerinde.', 'Circuit done! Every wire is in place.',
                        'Schaltung fertig! Alle Kabel sitzen.', '¡Circuito listo! Todos los cables están en su sitio.')
                    : (siradaki?.metin(lang) ?? ''),
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13.5,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: _bitti ? const Color(0xFF1B5E20) : const Color(0xFF6D4C00)),
              ),
            ),
            const SizedBox(width: 8),
            Text('$tamam/${hedefler.length}',
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: _bitti ? const Color(0xFF2E7D32) : const Color(0xFFB26A00))),
          ]),
        ),
        const SizedBox(height: 10),
        DevreDuzenleyici(
          key: _duzenleyici,
          sim: _sim,
          lang: lang,
          renk: renk,
          kip: DevreKipi.rehberli,
          hedefler: hedefler,
          kilitli: _bitti,
          yukseklik: (h * 0.46).clamp(250.0, 400.0),
          onDegisti: (_) => setState(() {}),
          onYanlis: () => setState(() {}),
          onYardim: () => _yardimAlindi = true,
          onHedeflerTamam: _tamam,
        ),
        if (!_bitti)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              lessonText(
                  lang,
                  'İpucu: Kablonun bir ucuna dokun, sonra öbür ucuna. Aynı sıradaki (sütundaki) 5 delik birbirine bağlıdır.',
                  'Tip: tap one end of the wire, then the other. The 5 holes in the same column strip are connected.',
                  'Tipp: Tippe auf ein Kabelende, dann aufs andere. Die 5 Löcher einer Spalte sind miteinander verbunden.',
                  'Pista: toca un extremo del cable y luego el otro. Los 5 agujeros de la misma columna están conectados.'),
              style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: yazi.withValues(alpha: 0.55)),
            ),
          ),
      ],
    );
  }
}
