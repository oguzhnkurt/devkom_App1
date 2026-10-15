import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/sound_service.dart';
import '../../../theme.dart';
import '../../../utils/lang.dart';
import '../../models/course_model.dart';
import '../../models/interactive_lesson_model.dart';
import '../../yurutme/atolye_hedefleri.dart';
import '../../yurutme/blok_yorumlayici.dart';
import '../../yurutme/kod_yapisi.dart';
import 'devi_tepkisi.dart';
import 'ic_ice_kod_alani.dart';
import 'proje_atolyesi.dart';
import 'scratch_tezgahi.dart';
import 'step_widgets.dart' show karistir;

/// IC ICE BLOK ADIMI: C blogu icindekileri sariyor, sayilar
/// degistirilebiliyor, denetim yapiya ya da sonuca bakiyor.
///
/// Iki tur denetim var (bkz. [BlockBuilderStep]):
///
///  * YAPI ([BlockBuilderStep.yapi]): kod alanindaki bloklarin sayisi
///    cozumunkine ulasinca yapi karsilastiriliyor — hangi blok hangi
///    agzin icinde, hangisi donguden sonra.
///  * SONUC ([BlockBuilderStep.sonucHedefleri]): kod CALISINCA sahnede
///    olana bakiliyor ("ucgen ciz": 3 x 120 de 120 x 3 de dogru).
///
/// Iki yanlis denemeden sonra adimin ipucu, dort yanlistan sonra ornek
/// cozum gosteriliyor.
class IcIceBlokAdimi extends StatefulWidget {
  const IcIceBlokAdimi({
    super.key,
    required this.step,
    required this.course,
    required this.isDark,
    required this.lang,
    required this.onComplete,
    this.onDevam,
  });

  final BlockBuilderStep step;
  final Course course;
  final bool isDark;
  final String lang;
  final ValueChanged<bool> onComplete;
  final VoidCallback? onDevam;

  @override
  State<IcIceBlokAdimi> createState() => _IcIceBlokAdimiState();
}

class _IcIceBlokAdimiState extends State<IcIceBlokAdimi> {
  late final List<ScratchBlock> _palet = karistir(widget.step.availableBlocks,
      widget.step.id, widget.step.correctSequence, (b) => b.id);

  bool _tamam = false;
  bool _bildirildi = false;
  bool _yanlis = false;
  int _yanlisSayisi = 0;
  int _denemeNo = 0;
  List<bool>? _sonDurum;
  List<bool>? _gosterilen;

  BlockBuilderStep get _s => widget.step;
  String get _l => widget.lang;
  Color get _renk => widget.course.primaryColor;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_l, tr: tr, en: en, de: de, es: es);

  bool get _sonucAdimi => _s.sonucHedefleri != null;

  String get _ornek => _s.yapi ?? _s.correctSequence.join(' ');

  void _kodDegisti(List<KodOgesi> kod) {
    if (_sonucAdimi) {
      if (_yanlis || _gosterilen != null) {
        setState(() {
          _yanlis = false;
          _gosterilen = null;
        });
      }
      return;
    }
    final bloklar = kod.where((o) => !KodYapisi.isaretMi(o.id)).length;
    if (bloklar != _s.correctSequence.length) {
      if (_yanlis) setState(() => _yanlis = false);
      return;
    }
    final dogru = KodYapisi.imza(kod) == KodYapisi.duzle(_ornek);
    _sonuc(dogru);
  }

  void _sonuc(bool dogru) {
    setState(() {
      _denemeNo++;
      _yanlis = !dogru;
      if (dogru) {
        _tamam = true;
      } else {
        _yanlisSayisi++;
      }
    });
    if (dogru) {
      HapticFeedback.heavyImpact();
      SoundService.playSoruDogru();
      if (!_bildirildi) {
        _bildirildi = true;
        widget.onComplete(true);
      }
    } else {
      SoundService.playWrong();
    }
  }

  void _calisti(Yurutme y, List<KodOgesi> kod) {
    if (!_sonucAdimi) return;
    _sonDurum = AtolyeDenetimi.durumlar(
        _s.sonucHedefleri!, AtolyeSonucu(yurutme: y, kod: kod));
  }

  void _oynatmaBitti() {
    if (!_sonucAdimi || _sonDurum == null) return;
    setState(() => _gosterilen = _sonDurum);
    if (!_tamam) _sonuc(_sonDurum!.every((d) => d));
  }

  @override
  Widget build(BuildContext context) {
    final yazi = widget.isDark ? Colors.white : const Color(0xFF1A1A1A);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _s.instructionFor(_l),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: yazi,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          key: const ValueKey('ic_ice_hedef'),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _renk.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const Text('🎯', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_t('Hedef', 'Goal', 'Ziel', 'Objetivo')}: ${_s.goalFor(_l)}',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14.5,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white : _renk,
                ),
              ),
            ),
          ]),
        ),
        if (_s.sayiDuzenlenebilir.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            _t(
                'Sarı halkalı sayılara dokunup değiştirebilirsin.',
                'Tap the numbers with a yellow ring to change them.',
                'Tippe auf die Zahlen mit gelbem Ring, um sie zu ändern.',
                'Toca los números con anillo amarillo para cambiarlos.'),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: yazi.withValues(alpha: 0.65),
            ),
          ),
        ],
        if (_sonucAdimi) ...[
          const SizedBox(height: 8),
          HedefListesi(
            hedefler: _s.sonucHedefleri!,
            durumlar: _gosterilen,
            lang: _l,
            renk: _renk,
          ),
        ],
        const SizedBox(height: 12),
        ScratchTezgahi(
          palet: _palet,
          lang: _l,
          renk: _renk,
          duzenlenebilir: _s.sayiDuzenlenebilir,
          dogru: _tamam,
          onKodDegisti: _kodDegisti,
          onCalisti: _calisti,
          onOynatmaBitti: _oynatmaBitti,
        ),
        if (_tamam || _yanlis) ...[
          const SizedBox(height: 12),
          DeviTepkisi(
            key: ValueKey('devi_tepkisi_$_denemeNo'),
            tur: _tamam ? DeviTepkiTuru.dogru : DeviTepkiTuru.tekrarDene,
            lang: _l,
            tohum: _s.id.hashCode + _denemeNo,
            koyu: widget.isDark,
          ),
        ],
        if (_yanlis && !_sonucAdimi) ...[
          const SizedBox(height: 10),
          Container(
            key: const ValueKey('ic_ice_yanlis'),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
            ),
            child: Text(
              _t(
                  'Bloklar doğru ama yerleri değil. Hangisi döngünün İÇİNDE, hangisi döngüden SONRA olmalı?',
                  'The blocks are right but not where they sit. Which one belongs INSIDE the loop, and which one AFTER it?',
                  'Die Blöcke stimmen, aber nicht ihr Platz. Welcher gehört IN die Schleife und welcher DANACH?',
                  'Los bloques son correctos, pero no su sitio. ¿Cuál va DENTRO del bucle y cuál DESPUÉS?'),
              style: const TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.w700),
            ),
          ),
        ],
        if (!_tamam) ...[
          const SizedBox(height: 10),
          IlerleyenIpucu(
            yanlis: _yanlisSayisi,
            lang: _l,
            ipucu: _s.ipucuFor(_l),
            cozum: cozumSatirlari(_ornek, _s.availableBlocks, _l),
          ),
        ],
        if (_tamam) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Text('✅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _sonucAdimi
                      ? _t('Harika! Kodun hedefi tuttu!',
                          'Great! Your code hit the goal!',
                          'Super! Dein Code hat das Ziel erreicht!',
                          '¡Genial! ¡Tu código cumplió el objetivo!')
                      : _t('Mükemmel! Her blok doğru yerde!',
                          'Perfect! Every block is in the right place!',
                          'Perfekt! Jeder Block sitzt an der richtigen Stelle!',
                          '¡Perfecto! ¡Cada bloque está en su sitio!'),
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (!_bildirildi) {
                _bildirildi = true;
                widget.onComplete(true);
              }
              widget.onDevam?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _renk,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_t('DEVAM', 'CONTINUE', 'WEITER', 'CONTINUAR'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }
}
