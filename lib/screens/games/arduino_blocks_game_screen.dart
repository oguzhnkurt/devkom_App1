import 'package:flutter/material.dart';

import '../../courses/models/interactive_lesson_model.dart';
import '../../data/arduino_gorev_data.dart';
import '../../services/sound_service.dart';
import '../../ui/ekran_olcusu.dart';
import '../../utils/lang.dart';
import '../../widgets/arduino_board_view.dart';
import '../../widgets/scratch_block_widget.dart';

/// Arduino oyunu — blokla kod kur, sanal kart tepki versin.
///
/// Bu ekran eski `ArduinoSimulatorScreen`in yerine geçti. Eskisi 2.400
/// satırlık bir breadboard simülatörüydü: elle çizilen delikli devre
/// tahtası, kablo çizimi ve 20x12 piksellik pin hedefleri. Telefonda
/// parmakla kablolamak neredeyse imkânsızdı, ekran kalabalık görünüyordu
/// ve Tinkercad'in masaüstü etkileşimini 390 puntoya sığdırmaya
/// çalışmak baştan yanlış bir karardı.
///
/// Yerine iki tür görev kondu (bkz. [ArduinoGorevleri]):
///  * KOD — mBlock bloklarıyla kodu kur, Çalıştır'a bas, LED gerçekten
///    yanıp sönsün. Kablolama yok.
///  * DEVRE — çizili devrede eksik parçayı üç büyük seçenekten seç.
///
/// Yanlış cevap puanı DÜŞÜRMÜYOR; yalnızca doğru cevap puan ekliyor.
class ArduinoBlocksGameScreen extends StatefulWidget {
  final Map<String, dynamic>? gameData;

  const ArduinoBlocksGameScreen({super.key, this.gameData});

  @override
  State<ArduinoBlocksGameScreen> createState() =>
      _ArduinoBlocksGameScreenState();
}

class _ArduinoBlocksGameScreenState extends State<ArduinoBlocksGameScreen> {
  int _seviye = 0;
  int _puan = 0;

  /// Kod görevinde kurulan blok kimlikleri, sırayla.
  final List<String> _kurulan = [];

  /// Devre görevinde seçilen şık; null ise henüz seçilmedi.
  int? _secilen;

  // Sanal kartın durumu.
  bool _ledAcik = false;
  String? _nota;
  double? _servoAcisi;
  bool _calisiyor = false;

  bool _bitti = false;
  String? _geriBildirim;
  bool _geriBildirimOlumlu = false;

  ArduinoSeviye get _gorev => ArduinoGorevleri.seviyeler[_seviye];

  /// Ekranin dili.
  ///
  /// `Provider.of<SettingsProvider>(context)` DEGIL: bu yardimci build
  /// disindan da cagriliyor (kod calistiktan sonraki geri bildirim),
  /// dinleyen bir Provider okumasi orada "outside of the widget tree"
  /// hatasi veriyor. Localizations hem her yerden guvenli hem de dil
  /// degisince ekrani yeniden ciziyor.
  String get _lang => Localizations.localeOf(context).languageCode;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    SoundService.useVoice(SfxVoice.deep);
  }

  // ----------------------------------------------------------------- akış

  void _blokEkle(ScratchBlock blok) {
    if (_calisiyor) return;
    SoundService.playDrop();
    setState(() {
      _kurulan.add(blok.id);
      _geriBildirim = null;
    });
  }

  void _blokCikar(int index) {
    if (_calisiyor) return;
    setState(() {
      _kurulan.removeAt(index);
      _geriBildirim = null;
    });
  }

  void _temizle() {
    setState(() {
      _kurulan.clear();
      _geriBildirim = null;
      _kartiSifirla();
    });
  }

  void _kartiSifirla() {
    _ledAcik = false;
    _nota = null;
    _servoAcisi = null;
  }

  /// Kurulan blokları sırayla çalıştırıp kartı oynatır.
  ///
  /// Doğruluk kontrolü ayrı: çocuk yanlış kod kurduğunda da kartın ne
  /// yaptığını GÖRMELİ. Hatayı görmek, "yanlış" yazısını okumaktan daha
  /// çok öğretiyor.
  Future<void> _calistir() async {
    if (_calisiyor || _kurulan.isEmpty) return;
    setState(() {
      _calisiyor = true;
      _geriBildirim = null;
      _kartiSifirla();
    });

    final dongude = _kurulan.contains('forever');
    final turlar = dongude ? 2 : 1;

    for (var tur = 0; tur < turlar && mounted; tur++) {
      for (final id in _kurulan) {
        if (!mounted) return;
        switch (etkiOf(id)) {
          case ArduinoEtki.baslangic:
          case ArduinoEtki.dongu:
            break;
          case ArduinoEtki.ledYak:
            setState(() => _ledAcik = true);
            break;
          case ArduinoEtki.ledSondur:
            setState(() => _ledAcik = false);
            break;
          case ArduinoEtki.nota:
            setState(() => _nota = 'C4');
            await Future.delayed(const Duration(milliseconds: 500));
            if (!mounted) return;
            setState(() => _nota = null);
            break;
          case ArduinoEtki.servo:
            setState(() => _servoAcisi = 90);
            break;
          case ArduinoEtki.pwm:
            setState(() => _ledAcik = true);
            break;
          case ArduinoEtki.bekle:
            break;
        }
        await Future.delayed(const Duration(milliseconds: 520));
      }
    }

    if (!mounted) return;
    setState(() => _calisiyor = false);
    _kodKontrol();
  }

  void _kodKontrol() {
    final dogru = _kurulan.length == _gorev.cozum.length &&
        List.generate(_kurulan.length, (i) => _kurulan[i] == _gorev.cozum[i])
            .every((x) => x);

    if (dogru) {
      SoundService.playLevelComplete();
      setState(() {
        _puan += 100;
        _geriBildirimOlumlu = true;
        _geriBildirim = _gorev.ipucuFor(_lang);
      });
    } else {
      // Puan DÜŞMÜYOR — yalnızca doğru cevap puan ekliyor.
      SoundService.playWrong();
      setState(() {
        _geriBildirimOlumlu = false;
        _geriBildirim = _t(
          'Kartın yaptığına bak: hedefe ulaştı mı? Blokların sırasını değiştirmeyi dene.',
          'Look at what the board did: did it reach the goal? Try changing the order.',
          'Schau, was die Platine gemacht hat: Ziel erreicht? Ändere die Reihenfolge.',
          'Mira lo que hizo la placa: ¿logró el objetivo? Prueba a cambiar el orden.',
        );
      });
    }
  }

  void _secenekSec(int index) {
    if (_secilen != null) return;
    final dogru = index == _gorev.dogruIndeks;
    if (dogru) {
      SoundService.playCorrect();
      _puan += 100;
    } else {
      SoundService.playWrong();
    }
    setState(() {
      _secilen = index;
      _geriBildirimOlumlu = dogru;
      _geriBildirim = _gorev.ipucuFor(_lang);
    });
  }

  void _sonraki() {
    if (_seviye + 1 >= ArduinoGorevleri.seviyeler.length) {
      setState(() => _bitti = true);
      return;
    }
    setState(() {
      _seviye++;
      _kurulan.clear();
      _secilen = null;
      _geriBildirim = null;
      _kartiSifirla();
    });
  }

  void _bastanBasla() {
    setState(() {
      _seviye = 0;
      _puan = 0;
      _kurulan.clear();
      _secilen = null;
      _geriBildirim = null;
      _bitti = false;
      _kartiSifirla();
    });
  }

  /// Bu seviye geçilebilir mi (doğru cevap verildi mi)?
  bool get _gecilebilir => _gorev.tur == ArduinoGorevTuru.kod
      ? (_geriBildirim != null && _geriBildirimOlumlu)
      : _secilen == _gorev.dogruIndeks;

  // ------------------------------------------------------------------ çizim

  @override
  Widget build(BuildContext context) {
    final ara = EkranOlcusu.bosluk(context, 16);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5C63),
        foregroundColor: Colors.white,
        title: Text(_t('Arduino Atölyesi', 'Arduino Workshop',
            'Arduino-Werkstatt', 'Taller de Arduino')),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⭐ $_puan',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _bitti
            ? _bitisEkrani()
            : ListView(
                padding: EdgeInsets.fromLTRB(16, ara, 16, 24),
                children: [
                  _ilerleme(),
                  SizedBox(height: ara),
                  _hedefKarti(),
                  SizedBox(height: ara),
                  if (_gorev.tur == ArduinoGorevTuru.kod) ...[
                    ArduinoBoardView(
                      ledAcik: _ledAcik,
                      nota: _nota,
                      servoAcisi: _servoAcisi,
                      calisiyor: _calisiyor,
                    ),
                    SizedBox(height: ara),
                    _kodAlani(),
                    SizedBox(height: ara),
                    _calistirSatiri(),
                  ] else ...[
                    _devreSeridi(),
                    SizedBox(height: ara),
                    _secenekListesi(),
                  ],
                  if (_geriBildirim != null) ...[
                    SizedBox(height: ara),
                    _geriBildirimKarti(),
                  ],
                  if (_gecilebilir) ...[
                    SizedBox(height: ara),
                    _sonrakiDugmesi(),
                  ],
                  if (_gorev.tur == ArduinoGorevTuru.kod) ...[
                    SizedBox(height: ara),
                    _palet(),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _ilerleme() {
    final toplam = ArduinoGorevleri.seviyeler.length;
    return Row(
      children: List.generate(toplam, (i) {
        final gecildi = i < _seviye;
        final simdi = i == _seviye;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: i == toplam - 1 ? 0 : 4),
            decoration: BoxDecoration(
              color: gecildi
                  ? const Color(0xFF0E5C63)
                  : simdi
                      ? const Color(0xFF4DB6AC)
                      : const Color(0xFFD7DDE1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _hedefKarti() {
    final kodMu = _gorev.tur == ArduinoGorevTuru.kod;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E8EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: (kodMu ? const Color(0xFF4A90E2) : const Color(0xFFFF8A65))
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              kodMu ? Icons.extension_rounded : Icons.bolt_rounded,
              color: kodMu ? const Color(0xFF4A90E2) : const Color(0xFFFF8A65),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_t('Görev', 'Task', 'Aufgabe', 'Tarea')} ${_seviye + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600],
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _gorev.hedefFor(_lang),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- kod görevi -------------------------------------------------------

  Widget _kodAlani() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFCFD8DC), width: 1.6, style: BorderStyle.solid),
      ),
      child: _kurulan.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Text(
                  _t('Aşağıdaki bloklara dokun, kodun buraya dizilsin.',
                      'Tap the blocks below and your code appears here.',
                      'Tippe unten auf die Blöcke, dein Code erscheint hier.',
                      'Toca los bloques de abajo y tu código aparece aquí.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _kurulan.length; i++)
                  _kurulanBlok(i),
              ],
            ),
    );
  }

  Widget _kurulanBlok(int index) {
    final id = _kurulan[index];
    final blok = _blokBul(id);
    if (blok == null) return const SizedBox.shrink();

    // "sürekli tekrarla"dan SONRAKİ bloklar içeride duruyor: döngünün
    // içini göstermenin en okunaklı yolu girinti + renkli ray.
    final donguIndeksi = _kurulan.indexOf('forever');
    final icerde = donguIndeksi != -1 && index > donguIndeksi;

    return Padding(
      padding: EdgeInsets.only(left: icerde ? 18 : 0),
      child: Row(
        children: [
          if (icerde)
            Container(
              width: 4,
              height: 34,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFAB19),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Flexible(
            child: ScratchBlockWidget(
              block: blok,
              lang: _lang,
              isPlaced: true,
              showRemoveIcon: !_calisiyor,
              cHeadOnly: blok.shape == ScratchBlockShape.cBlock,
              onTap: () => _blokCikar(index),
            ),
          ),
        ],
      ),
    );
  }

  ScratchBlock? _blokBul(String id) {
    for (final b in _gorev.havuz) {
      if (b.id == id) return b;
    }
    return null;
  }

  Widget _calistirSatiri() {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _calisiyor || _kurulan.isEmpty ? null : _calistir,
            icon: Icon(_calisiyor
                ? Icons.hourglass_top_rounded
                : Icons.play_arrow_rounded),
            label: Text(_calisiyor
                ? _t('Çalışıyor...', 'Running...', 'Läuft...', 'Ejecutando...')
                : _t('Çalıştır', 'Run', 'Start', 'Ejecutar')),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0E5C63),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: _calisiyor || _kurulan.isEmpty ? null : _temizle,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(_t('Temizle', 'Clear', 'Leeren', 'Limpiar')),
        ),
      ],
    );
  }

  Widget _palet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('Bloklar', 'Blocks', 'Blöcke', 'Bloques'),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.grey[700],
              letterSpacing: 0.4),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final blok in _gorev.havuz)
              ScratchBlockWidget(
                block: blok,
                lang: _lang,
                onTap: () => _blokEkle(blok),
              ),
          ],
        ),
      ],
    );
  }

  // ---- devre görevi -----------------------------------------------------

  Widget _devreSeridi() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E8EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < _gorev.devreParcalari.length; i++) ...[
            if (i > 0) _kabloCizgisi(),
            _devreParcasi(_gorev.devreParcalari[i]),
          ],
        ],
      ),
    );
  }

  Widget _kabloCizgisi() => Container(
        width: 26,
        height: 3,
        color: const Color(0xFFB0BEC5),
      );

  Widget _devreParcasi(String parca) {
    final eksik = parca == '?';
    final cozuldu = eksik && _secilen == _gorev.dogruIndeks;
    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: eksik && !cozuldu ? const Color(0xFFFFF3E0) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: eksik && !cozuldu
              ? const Color(0xFFFFB74D)
              : const Color(0xFFE3E8EB),
          width: eksik && !cozuldu ? 2 : 1.4,
        ),
      ),
      child: Text(
        cozuldu ? _gorev.secenekler[_gorev.dogruIndeks].emoji : parca,
        style: const TextStyle(fontSize: 26),
      ),
    );
  }

  Widget _secenekListesi() {
    return Column(
      children: [
        for (var i = 0; i < _gorev.secenekler.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _secenekKarti(i),
          ),
      ],
    );
  }

  Widget _secenekKarti(int index) {
    final secenek = _gorev.secenekler[index];
    final secildi = _secilen == index;
    final dogruSik = index == _gorev.dogruIndeks;
    final cevaplandi = _secilen != null;

    Color kenar = const Color(0xFFE3E8EB);
    Color zemin = Colors.white;
    if (cevaplandi && dogruSik) {
      kenar = const Color(0xFF4CAF50);
      zemin = const Color(0xFFE8F5E9);
    } else if (secildi) {
      kenar = const Color(0xFFEF5350);
      zemin = const Color(0xFFFFEBEE);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: cevaplandi ? null : () => _secenekSec(index),
        child: Container(
          // Dokunma hedefi kart boyunda: eski simülatörün 20x12 piksellik
          // pinlerinin tersi.
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: zemin,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kenar, width: 1.8),
          ),
          child: Row(
            children: [
              Text(secenek.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppLang.pick(_lang,
                      tr: secenek.tr,
                      en: secenek.en,
                      de: secenek.de,
                      es: secenek.es),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              if (cevaplandi && dogruSik)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF4CAF50)),
            ],
          ),
        ),
      ),
    );
  }

  // ---- ortak ------------------------------------------------------------

  Widget _geriBildirimKarti() {
    final renk =
        _geriBildirimOlumlu ? const Color(0xFF2E7D32) : const Color(0xFFE65100);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: renk.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _geriBildirimOlumlu
                ? Icons.emoji_objects_rounded
                : Icons.refresh_rounded,
            color: renk,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _geriBildirim!,
              style: TextStyle(
                  fontSize: 13.5, color: renk, height: 1.35,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sonrakiDugmesi() {
    final son = _seviye + 1 >= ArduinoGorevleri.seviyeler.length;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _sonraki,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          son
              ? _t('Bitir', 'Finish', 'Fertig', 'Terminar')
              : _t('Sonraki görev', 'Next task', 'Nächste Aufgabe',
                  'Siguiente tarea'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    );
  }

  Widget _bitisEkrani() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎛️', style: TextStyle(fontSize: 62)),
            const SizedBox(height: 14),
            Text(
              _t('Atölye tamam!', 'Workshop complete!', 'Werkstatt geschafft!',
                  '¡Taller completado!'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '⭐ $_puan',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              _t(
                  'Artık gerçek bir Arduino kartıyla aynısını yapabilirsin: bloklar mBlock\'takilerle birebir aynı.',
                  'You can do the same on a real Arduino board now: these blocks match mBlock exactly.',
                  'Das Gleiche kannst du jetzt auf einer echten Arduino-Platine machen: die Blöcke sind genau die von mBlock.',
                  'Ahora puedes hacer lo mismo en una placa Arduino real: estos bloques son los de mBlock.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.5, color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _bastanBasla,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0E5C63),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_t('Tekrar oyna', 'Play again', 'Nochmal spielen',
                  'Jugar otra vez')),
            ),
          ],
        ),
      ),
    );
  }
}
