import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../ui/press_button.dart';
import '../models/course_model.dart';
import '../sahne/mblock_sahnesi.dart';
import '../yurutme/mblock_blok_adlari.dart';
import '../yurutme/mblock_cozum.dart';
import 'widgets/mblock_atolye_tezgahi.dart';
import 'widgets/step_widgets.dart' show lessonLang, lessonText;

/// mBlock SERBEST ATOLYE: kursun butun bloklari, hedefsiz.
///
/// Scratch'teki Proje Atolyesi'nin duzeni: USTTE sahne (yesil bayrak
/// calistirir, kirmizi dur durdurur), ORTADA sinirli yukseklikli
/// kategorili tezgah (Flutter; [MBlockAtolyeTezgahi]), ALTTA Temizle ve
/// tek ana dugme. Eskiden burada WebView editoru vardi: telefonda blok
/// listesi ekranin cogunu kapliyor, birakma alani daraliyordu.
///
/// "when Arduino Uno starts up" ile baslayan program sanal Uno'da,
/// yesil bayrakla baslayan program kukla sahnesinde (Devi) calisiyor —
/// hangisi oldugu tahtadaki programdan anlasiliyor. Ders adimlarinin
/// tezgahi (WebView) degismedi.
class MBlockAtolyeEkrani extends StatefulWidget {
  const MBlockAtolyeEkrani({super.key, required this.course});

  final Course course;

  /// Arac kutusu: katalogdaki her blok (JS ile ayni sira).
  static final List<String> bloklar = mblockBlokTanimlari.keys.toList();

  @override
  State<MBlockAtolyeEkrani> createState() => MBlockAtolyeEkraniState();
}

class MBlockAtolyeEkraniState extends State<MBlockAtolyeEkrani> {
  final _tezgah = GlobalKey<MBlockAtolyeTezgahiState>();
  final _sahne = GlobalKey<MBlockSahnesiState>();
  List<List<MBlockBlok>> _yiginlar = const [];
  bool _calisiyor = false;

  /// Hazir bir programi tezgaha koyar (testler, ekran goruntusu araci).
  @visibleForTesting
  void durumVer(List<List<MBlockBlok>> y) {
    _tezgah.currentState?.yukle(y);
    _durum(y);
  }

  void _durum(List<List<MBlockBlok>> y) {
    if (mounted) setState(() => _yiginlar = y);
  }

  void _calisma(bool c) {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _calisma(c));
      return;
    }
    setState(() => _calisiyor = c);
  }

  /// Tahtada Uno programi var mi (yoksa kukla).
  bool get _kart =>
      _yiginlar.any((y) => y.isNotEmpty && y.first.tip == 'dev_kart_acilis');

  bool get _bos => !_yiginlar.any((y) => y.isNotEmpty);

  bool get calisiyor => _calisiyor;

  void calistir() {
    if (_bos) return;
    HapticFeedback.lightImpact();
    _sahne.currentState?.calistir(_yiginlar);
  }

  void durdur() => _sahne.currentState?.durdur();

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final koyu = Theme.of(context).brightness == Brightness.dark;
    final renk = widget.course.primaryColor;
    final kisa = MediaQuery.sizeOf(context).height < 700;
    return Scaffold(
      backgroundColor: koyu ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: renk,
        foregroundColor: Colors.white,
        title: Text(lessonText(lang, 'mBlock Atölyesi', 'mBlock Workshop',
            'mBlock-Werkstatt', 'Taller de mBlock')),
      ),
      body: SingleChildScrollView(
        key: const ValueKey('mblock_atolye_sayfasi'),
        padding: EdgeInsets.fromLTRB(
            kisa ? 12 : 16, kisa ? 10 : 14, kisa ? 12 : 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MBlockSahnesi(
              key: _sahne,
              kart: _kart,
              program: _yiginlar,
              lang: lang,
              renk: renk,
              onCalisma: _calisma,
              kuklaYuksekligi: kisa ? 190 : 230,
            ),
            const SizedBox(height: 12),
            MBlockAtolyeTezgahi(
              key: _tezgah,
              lang: lang,
              bloklar: MBlockAtolyeEkrani.bloklar,
              renk: renk,
              calisiyor: _calisiyor,
              // Sahne + aralar + alttaki dugme satiri: 430x932'de
              // sayfa tek ekrana sigiyor.
              ustunde: (kisa ? 200 : 250) + 12 + 12 + 56 + 28 + 14,
              onDegisti: _durum,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('mblock_atolye_temizle'),
                  onPressed: _bos
                      ? null
                      : () {
                          durdur();
                          _tezgah.currentState?.temizle();
                        },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    lessonText(lang, 'Temizle', 'Clear', 'Leeren', 'Limpiar'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PressButton(
                  key: const ValueKey('mblock_atolye_calistir'),
                  label: _calisiyor
                      ? lessonText(lang, 'Durdur', 'Stop', 'Stopp', 'Detener')
                      : lessonText(
                          lang, 'Çalıştır', 'Run', 'Starten', 'Ejecutar'),
                  icon: _calisiyor ? Icons.stop_rounded : Icons.flag_rounded,
                  color: _calisiyor
                      ? const Color(0xFFEC5959)
                      : const Color(0xFF4CBF56),
                  onPressed: _bos ? null : (_calisiyor ? durdur : calistir),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
