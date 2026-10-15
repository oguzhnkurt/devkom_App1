import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme.dart';
import '../models/course_model.dart';
import '../sahne/mblock_sahnesi.dart';
import '../yurutme/mblock_blok_adlari.dart';
import '../yurutme/mblock_cozum.dart';
import 'widgets/mblock_tezgahi.dart';
import 'widgets/step_widgets.dart' show lessonLang, lessonText;

/// mBlock SERBEST ATOLYE: kursun butun bloklari, hedefsiz.
///
/// Dersler bir soruya cevap istiyor; burada cocuk istedigini kuruyor.
/// "Arduino Uno baslatildiginda" ile baslayan program sanal Uno'da,
/// yesil bayrakla baslayan program kukla sahnesinde calisiyor — hangisi
/// oldugu tahtadaki programdan anlasiliyor.
class MBlockAtolyeEkrani extends StatefulWidget {
  const MBlockAtolyeEkrani({super.key, required this.course});

  final Course course;

  /// Arac kutusu: katalogdaki her blok (JS ile ayni sira).
  static final MBlockTezgahAyari ayar = MBlockTezgahAyari(
    bloklar: mblockBlokTanimlari.keys.toList(),
    cozum: const [],
  );

  @override
  State<MBlockAtolyeEkrani> createState() => MBlockAtolyeEkraniState();
}

class MBlockAtolyeEkraniState extends State<MBlockAtolyeEkrani> {
  final _tezgah = GlobalKey<MBlockTezgahiState>();
  final _sahne = GlobalKey<MBlockSahnesiState>();
  List<List<MBlockBlok>> _yiginlar = const [];
  bool _tezgahYok = false;

  /// Testler ve ekran goruntusu araci tezgahi WebView'siz besliyor.
  @visibleForTesting
  void durumVer(List<List<MBlockBlok>> y) => _durum(y);

  void _durum(List<List<MBlockBlok>> y) {
    if (mounted) setState(() => _yiginlar = y);
  }

  /// Tahtada Uno programi var mi (yoksa kukla).
  bool get _kart =>
      _yiginlar.any((y) => y.isNotEmpty && y.first.tip == 'dev_kart_acilis');

  int get _blokSayisi =>
      _yiginlar.fold(0, (t, y) => t + y.length);

  void calistir() {
    HapticFeedback.lightImpact();
    _sahne.currentState?.calistir(_yiginlar);
  }

  @override
  Widget build(BuildContext context) {
    final lang = lessonLang(context);
    final koyu = Theme.of(context).brightness == Brightness.dark;
    final renk = widget.course.primaryColor;
    return Scaffold(
      backgroundColor: koyu ? const Color(0xFF0A0A0F) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: renk,
        foregroundColor: Colors.white,
        title: Text(lessonText(lang, 'mBlock Atölyesi', 'mBlock Workshop',
            'mBlock-Werkstatt', 'Taller de mBlock')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              lessonText(
                  lang,
                  'Kursun bütün blokları burada. "when Arduino Uno starts up" ile başlarsan program sanal Uno\'da, yeşil bayrakla başlarsan sahnede Devi ile çalışır.',
                  'Every block of the course is here. Start with "when Arduino Uno starts up" to run on the virtual Uno, or with the green flag to run with Devi on the stage.',
                  'Hier sind alle Blöcke des Kurses. Beginnst du mit „wenn Arduino Uno startet“, läuft das Programm auf dem virtuellen Uno; mit der grünen Flagge läuft es mit Devi auf der Bühne.',
                  'Aquí están todos los bloques del curso. Si empiezas con "cuando Arduino Uno se inicia", el programa funciona en el Uno virtual; con la bandera verde, con Devi en el escenario.'),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: koyu ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            MBlockSahnesi(
              key: _sahne,
              kart: _kart,
              program: _yiginlar,
              lang: lang,
              renk: renk,
            ),
            const SizedBox(height: 12),
            if (_tezgahYok)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(lessonText(
                    lang,
                    'Sürükle-bırak tezgahı bu cihazda açılmadı.',
                    'The drag-and-drop workbench did not open on this device.',
                    'Die Drag-and-drop-Werkbank ging auf diesem Gerät nicht auf.',
                    'El taller de arrastrar y soltar no se abrió en este dispositivo.')),
              )
            else
              MBlockTezgahi(
                key: _tezgah,
                ayar: MBlockAtolyeEkrani.ayar,
                onDurum: _durum,
                onHata: () => setState(() => _tezgahYok = true),
                onizleme: _yiginlar,
              ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _tezgah.currentState?.temizle(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(lessonText(
                      lang, 'Temizle', 'Clear', 'Leeren', 'Limpiar')),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  key: const ValueKey('mblock_atolye_calistir'),
                  onPressed: _blokSayisi == 0 ? null : calistir,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(lessonText(
                      lang, 'Çalıştır', 'Run', 'Starten', 'Ejecutar')),
                  style: FilledButton.styleFrom(
                    backgroundColor: renk,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
