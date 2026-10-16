import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme.dart';
import '../../utils/lang.dart';
import '../../widgets/block_animation_player.dart';
import '../../widgets/mascot.dart';
import '../yurutme/blok_yorumlayici.dart';
import '../yurutme/mblock_blok_adlari.dart';
import '../yurutme/mblock_cozum.dart';
import '../yurutme/mblock_kukla.dart';
import '../yurutme/mblock_uno.dart';
import 'scratch_sahnesi.dart';
import 'uno_karti.dart';

/// mBlock adiminin SAHNESI — tezgahtaki program burada gercekten calisir.
///
/// Iki tur:
///  * KART (moduller 1-4): sanal Arduino Uno. LED'ler yanip soner, PWM
///    parlakligi degisir, buton basilir, servo doner, seri port yazar.
///  * KUKLA (modul 0 ve projeler): Scratch dersleriyle AYNI sahne karti
///    ve oynatici; program [MBlockKuklaProgrami] ile cevriliyor.
///
/// Scratch'teki gibi: sahne ustte, bloklar altta; yesil bayrak kodu
/// calistirir, kirmizi dur durdurur. Ders adimi "Kontrol et"ten sonra
/// [MBlockSahnesiState.calistir] ile kendisi de calistiriyor.
class MBlockSahnesi extends StatefulWidget {
  const MBlockSahnesi({
    super.key,
    required this.kart,
    required this.program,
    required this.lang,
    required this.renk,
    this.dogru = false,
    this.zamanOlcegi = 1.0,
    this.onCalisma,
  });

  /// Calisma basladi / bitti (sahibinin "Calistir | Durdur" dugmesi).
  final ValueChanged<bool>? onCalisma;

  /// true: Arduino Uno; false: kukla sahnesi.
  final bool kart;

  /// Tezgahtaki son program (yiginlar).
  final List<List<MBlockBlok>> program;

  final String lang;
  final Color renk;

  /// Program cozumle ayni mi (kukla sahnesinin bitis serit yazisi).
  final bool dogru;

  final double zamanOlcegi;

  @override
  State<MBlockSahnesi> createState() => MBlockSahnesiState();
}

class MBlockSahnesiState extends State<MBlockSahnesi> {
  /// Sanal kart (kart turunde). Testler okuyabilsin diye acik.
  final UnoKarti unoKarti = UnoKarti();

  UnoYorumlayici? _uno;
  UnoBitis? _unoBitis;
  MBlockBlok? _calisanBlok;
  Timer? _blokYazisi;

  /// Calistirilan program (calistirma aninda dondurulur: cocuk tezgahta
  /// degistirse de calisan program degismez).
  List<List<MBlockBlok>> _calisan = const [];

  // Kukla.
  MBlockKuklaProgrami? _kukla;
  Yurutme? _yurutme;
  GlobalKey<BlockAnimationPlayerState> _oynatici = GlobalKey();

  bool _calisiyor = false;
  bool get calisiyor => _calisiyor;

  /// Baslik bayragi: tezgahta blok yoksa pasif; calisirken "basili".
  VoidCallback? get _bayrak =>
      _calisiyor || !widget.program.any((y) => y.isNotEmpty)
          ? null
          : () => calistir();

  void _durumDegisti(bool c) {
    if (_calisiyor == c) return;
    _calisiyor = c;
    widget.onCalisma?.call(c);
  }

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  @override
  void dispose() {
    _uno?.durdur();
    _blokYazisi?.cancel();
    unoKarti.dispose();
    super.dispose();
  }

  /// Programi bastan calistirir ([program] verilmezse widget'in).
  void calistir([List<List<MBlockBlok>>? program]) {
    final p = program ?? widget.program;
    if (widget.kart) {
      _kartiCalistir(p);
    } else {
      _kuklayiCalistir(p);
    }
  }

  void durdur() {
    if (widget.kart) {
      _uno?.durdur();
    } else {
      _oynatici.currentState?.durdur();
      setState(() => _durumDegisti(false));
    }
  }

  Future<void> _kartiCalistir(List<List<MBlockBlok>> p) async {
    _uno?.durdur();
    final y = UnoYorumlayici(
      kart: unoKarti,
      zamanOlcegi: widget.zamanOlcegi,
      // Sonsuz dongu iki dakika kadar calisir (pil); sonra "durdurduk".
      butce: 8000,
      onBlok: (b) => _calisanBlok = b,
    );
    _uno = y;
    setState(() {
      _calisan = p;
      _durumDegisti(true);
      _unoBitis = null;
    });
    // Calisan blogun yazisi saniyede birkac kez tazeleniyor (her blokta
    // setState yerine).
    _blokYazisi?.cancel();
    _blokYazisi = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && _calisiyor) setState(() {});
    });
    final bitis = await y.calistir(p);
    if (!mounted || !identical(_uno, y)) return;
    _blokYazisi?.cancel();
    setState(() {
      _durumDegisti(false);
      _unoBitis = bitis;
      _calisanBlok = null;
    });
  }

  void _kuklayiCalistir(List<List<MBlockBlok>> p) {
    final k = MBlockKuklaProgrami.cevir(p, widget.lang);
    setState(() {
      _calisan = p;
      _kukla = k;
      _oynatici = GlobalKey();
      _yurutme =
          k.bos ? null : BlokYorumlayici(dil: widget.lang).yurut(k.bloklar);
      _durumDegisti(!k.bos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.kart ? _kartSahnesi() : _kuklaSahnesi();
  }

  // ------------------------------------------------------------------
  // Kart
  // ------------------------------------------------------------------

  Widget _kartSahnesi() {
    final parcalar = UnoYorumlayici.parcalar(
        _calisan.isNotEmpty ? _calisan : widget.program);
    final gorunen = parcalar.parcaSayisi == 0 && !parcalar.pot &&
            !parcalar.mesafe && !parcalar.seri
        ? bosUnoParcalari
        : parcalar;
    return LayoutBuilder(builder: (context, c) {
      final govdeH = UnoKartiGorunumu.yukseklik(gorunen, c.maxWidth);
      return Container(
        key: const ValueKey('mblock_kart_sahnesi'),
        decoration: _kartSusu(),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _baslik(_t('Arduino Uno', 'Arduino Uno', 'Arduino Uno',
                'Arduino Uno')),
            Container(
              height: govdeH,
              color: const Color(0xFFF1F8F8),
              child: UnoKartiGorunumu(
                kart: unoKarti,
                parcalar: gorunen,
                lang: widget.lang,
              ),
            ),
            _durumSeridi(),
          ],
        ),
      );
    });
  }

  BoxDecoration _kartSusu() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      );

  Widget _baslik(String ad) {
    return SizedBox(
      height: ScratchSahneKarti.baslikYuksekligi,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 12),
        child: Row(
          children: [
            SahneBayrakDugmesi(
              key: const ValueKey('mblock_sahne_bayragi'),
              lang: widget.lang,
              onTap: _bayrak,
              calisiyor: _calisiyor,
            ),
            SahneDurDugmesi(
              key: const ValueKey('mblock_sahne_dur'),
              lang: widget.lang,
              onTap: _calisiyor ? durdur : null,
            ),
            const Spacer(),
            Text(
              ad,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _durumSeridi() {
    final String metin;
    final Color renk;
    final IconData ikon;
    if (_calisiyor) {
      final b = _calisanBlok;
      metin = b == null
          ? _t('Çalışıyor…', 'Running…', 'Läuft…', 'Ejecutando…')
          : mblockBlokYazisi(b, widget.lang);
      renk = const Color(0xFF00878F);
      ikon = Icons.play_circle_fill_rounded;
    } else {
      switch (_unoBitis) {
        case null:
          metin = _t('Yeşil bayrağa bas: kodun kartta çalışsın.',
              'Press the green flag to run your code on the board.',
              'Drück die grüne Flagge: dein Code läuft auf der Platine.',
              'Pulsa la bandera verde: tu código se ejecuta en la placa.');
          renk = const Color(0xFF5B6070);
          ikon = Icons.flag_rounded;
        case UnoBitis.bitti:
          metin = _t('Program bitti. Kart son hâlinde kaldı.',
              'The program finished. The board keeps its last state.',
              'Das Programm ist fertig. Die Platine bleibt so.',
              'El programa terminó. La placa se queda así.');
          renk = const Color(0xFF2E7D32);
          ikon = Icons.check_circle_rounded;
        case UnoBitis.durduruldu:
          metin = _t('Kodu durdurdun.', 'You stopped the code.',
              'Du hast den Code gestoppt.', 'Detuviste el código.');
          renk = const Color(0xFFB84848);
          ikon = Icons.stop_circle_rounded;
        case UnoBitis.butceBitti:
          metin = _t('Bu kod hiç durmuyor; bir süre sonra biz durdurduk.',
              'This code never stops; we paused it after a while.',
              'Dieser Code hört nie auf; wir haben ihn angehalten.',
              'Este código no para nunca; lo pausamos tras un rato.');
          renk = const Color(0xFFB26A00);
          ikon = Icons.all_inclusive_rounded;
        case UnoBitis.baslangicYok:
          metin = _t(
              'Kart, "${mblockBlokAdi('dev_kart_acilis', 'tr')}" bloğuyla başlar.',
              'The board starts with "${mblockBlokAdi('dev_kart_acilis', 'en')}".',
              'Die Platine startet mit „${mblockBlokAdi('dev_kart_acilis', 'de')}“.',
              'La placa empieza con «${mblockBlokAdi('dev_kart_acilis', 'es')}».');
          renk = const Color(0xFF3D5A80);
          ikon = Icons.info_rounded;
      }
    }
    return Container(
      key: const ValueKey('mblock_sahne_durumu'),
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white,
      child: Row(
        children: [
          Icon(ikon, size: 17, color: renk),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              metin,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: renk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Kukla
  // ------------------------------------------------------------------

  Widget _kuklaSahnesi() {
    final k = _kukla;
    final y = _yurutme;
    return SizedBox(
      key: const ValueKey('mblock_kukla_sahnesi'),
      height: 230,
      child: ScratchSahneKarti(
        lang: widget.lang,
        bayrakAnahtari: const ValueKey('mblock_sahne_bayragi'),
        durAnahtari: const ValueKey('mblock_sahne_dur'),
        onBayrak: _bayrak,
        onDur: _calisiyor ? durdur : null,
        calisiyor: _calisiyor,
        child: k == null || y == null
            ? _bosKukla()
            : BlockAnimationPlayer(
                key: _oynatici,
                sahne: true,
                blocks: k.bloklar,
                lang: widget.lang,
                size: 64,
                yurutme: y,
                dogru: widget.dogru,
                renk: widget.renk,
                baslamaGecikmesi: const Duration(milliseconds: 300),
                onComplete: () {
                  if (mounted && _calisiyor) {
                    setState(() => _durumDegisti(false));
                  }
                },
              ),
      ),
    );
  }

  Widget _bosKukla() {
    return ScratchSahneZemini(builder: (context, boyut, zemin) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: boyut.width * 0.08,
            top: zemin - 64 + 4,
            child: const Mascot(size: 64, showShadow: false),
          ),
          Positioned(
            left: 8,
            right: 8,
            top: 6,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _t('Yeşil bayrağa bas: kodun burada çalışsın.',
                      'Press the green flag to run your code here.',
                      'Drück die grüne Flagge: dein Code läuft hier.',
                      'Pulsa la bandera verde: tu código se ejecuta aquí.'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3D5A80),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
