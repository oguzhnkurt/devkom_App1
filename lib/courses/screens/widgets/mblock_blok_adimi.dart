import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/sound_service.dart';
import '../../../theme.dart';
import '../../models/course_model.dart';
import '../../models/interactive_lesson_model.dart';
import '../../yurutme/mblock_cozum.dart';
import 'mblock_tezgahi.dart';
import 'step_widgets.dart' show lessonLang, lessonText;

/// mBlock kursunda blok kurma adimi — gercek tezgahla.
///
/// Eski `BlockBuilderStepWidget` bloklari SIRAYA DIZDIRIYORDU: cocuk
/// kartlara dokunuyor, alt alta geliyorlardi. Ogrettigimiz sey ise
/// surukleyip yapistirmak, C kutusunun icine blok koymak, acilir
/// listeden pin secmek. mBlock derslerinde artik bunun kendisi
/// yapiliyor.
///
/// Denetim `mblock_cozum.dart` icinde ve WebView'siz sinanabiliyor;
/// burasi yalnizca ekran.
class MBlockBlokAdimi extends StatefulWidget {
  const MBlockBlokAdimi({
    super.key,
    required this.step,
    required this.ayar,
    required this.course,
    required this.isDark,
    required this.onComplete,
  });

  final BlockBuilderStep step;
  final MBlockTezgahAyari ayar;
  final Course course;
  final bool isDark;
  final Function(bool correct) onComplete;

  @override
  State<MBlockBlokAdimi> createState() => _MBlockBlokAdimiState();
}

class _MBlockBlokAdimiState extends State<MBlockBlokAdimi> {
  final _tezgah = GlobalKey<MBlockTezgahiState>();

  List<List<MBlockBlok>> _yiginlar = const [];
  bool? _sonuc;
  bool _bitti = false;

  /// Kac blok var (dugmenin acik olup olmayacagini belirliyor).
  int get _blokSayisi =>
      _yiginlar.fold(0, (t, y) => t + _say(y));

  int _say(List<MBlockBlok> liste) =>
      liste.fold(0, (t, b) => t + 1 + _say(b.icerik));

  void _durum(List<List<MBlockBlok>> yiginlar) {
    if (!mounted) return;
    setState(() {
      _yiginlar = yiginlar;
      // Tahtaya dokunulunca eski not silinir: kirmizi bir uyari,
      // cocuk duzeltmeye baslamisken ekranda asili kalmamali.
      if (!_bitti) _sonuc = null;
    });
  }

  void _kontrolEt() {
    final dogru = mblockCozumDogruMu(_yiginlar, widget.ayar.cozum);
    setState(() {
      _sonuc = dogru;
      if (dogru) _bitti = true;
    });
    if (dogru) {
      HapticFeedback.heavyImpact();
      SoundService.playSoruDogru();
      Future.delayed(const Duration(milliseconds: 600), () {
        widget.onComplete(true);
      });
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final yaziRengi = widget.isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.step.instructionFor(lang),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 18,
            height: 1.4,
            fontWeight: FontWeight.w800,
            color: yaziRengi,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.course.primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.flag_rounded,
                  size: 18, color: widget.course.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.step.goalFor(lang),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: widget.course.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        MBlockTezgahi(
          key: _tezgah,
          ayar: widget.ayar,
          onDurum: _durum,
        ),

        const SizedBox(height: 8),
        Text(
          lessonText(
            lang,
            'Blokları soldaki listeden sürükle, alt alta yapıştır.',
            'Drag blocks from the list on the left and snap them together.',
            'Zieh Blöcke aus der Liste links und stecke sie zusammen.',
            'Arrastra bloques de la lista de la izquierda y encájalos.',
          ),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 14),

        if (_sonuc == false)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade600, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lessonText(
                        lang,
                        'Henüz olmadı. Hedefi bir daha oku, blokların '
                            'sırasına ve kutulardaki sayılara bak.',
                        'Not yet. Read the goal again and check the order of '
                            'the blocks and the numbers in the slots.',
                        'Noch nicht. Lies das Ziel noch einmal und prüfe die '
                            'Reihenfolge der Blöcke und die Zahlen.',
                        'Todavía no. Vuelve a leer el objetivo y mira el '
                            'orden de los bloques y los números.',
                      ),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark
                            ? Colors.orange.shade200
                            : Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (_bitti)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lessonText(lang, 'Program doğru!', 'The program is right!',
                        'Das Programm stimmt!', '¡El programa es correcto!'),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tezgah.currentState?.temizle(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    lessonText(lang, 'Temizle', 'Clear', 'Leeren', 'Limpiar'),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  // Bos tahtada kontrol yok: cocuga "yanlis" demenin
                  // en anlamsiz hali hicbir sey kurmamisken olur.
                  onPressed: _blokSayisi == 0 ? null : _kontrolEt,
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(
                    lessonText(lang, 'Kontrol et', 'Check', 'Prüfen',
                        'Comprobar'),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.course.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
