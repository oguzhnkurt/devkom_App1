import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme.dart';
import '../../../ui/motion.dart';
import '../../../services/sound_service.dart';
import '../../../ui/press_button.dart';
import '../../../utils/lang.dart';
import '../../../widgets/block_animation_player.dart';
import '../../../widgets/mascot.dart';
import '../../models/interactive_lesson_model.dart';
import '../../sahne/blok_tezgahi_karti.dart';
import '../../sahne/proje_sahnesi.dart';
import '../../sahne/scratch_sahnesi.dart';
import '../../yurutme/blok_yorumlayici.dart';
import '../../yurutme/kod_yapisi.dart';
import '../../yurutme/scratch_blok_katalogu.dart';
import 'calisma_izi.dart';
import 'ic_ice_kod_alani.dart';
import 'sayi_tus_takimi.dart';

/// IC ICE SCRATCH TEZGAHI: sahne + "Bloklar | Kod alani" + yesil bayrak.
///
/// Ic ice blok adimi ([IcIceBlokAdimi]) ve Proje Atolyesi
/// ([ProjeAtolyesiWidget]) ayni tezgahi kullaniyor; ustundeki yonerge
/// ve altindaki geri bildirim onlarin.
///
/// Kod her degistiginde [onKodDegisti], her calistirmada [onCalisti]
/// (yurutmeyle) cagriliyor. Sahne kodu calistirip bitirince
/// [onOynatmaBitti].
class ScratchTezgahi extends StatefulWidget {
  const ScratchTezgahi({
    super.key,
    required this.palet,
    required this.lang,
    required this.renk,
    this.baslangic = const [],
    this.duzenlenebilir = const {},
    this.cokBetik = false,
    this.onKodDegisti,
    this.onCalisti,
    this.onOynatmaBitti,
    this.dogru = false,
    this.sahneYuksekligi,
    this.izGoster = true,
    this.ana = KuklaTanimi.devi,
    this.kuklalar = const [],
    this.oyuncu = const OtomatikOyuncu(),
    this.sureSiniri = ProjeMotoru.varsayilanSure,
    this.hedefTamam,
  });

  final List<ScratchBlock> palet;
  final String lang;
  final Color renk;
  final List<KodOgesi> baslangic;
  final Set<String> duzenlenebilir;

  /// Proje Atolyesi: her sapka ayri betik ([BlokYorumlayici.yurutProje]).
  final bool cokBetik;

  final ValueChanged<List<KodOgesi>>? onKodDegisti;
  final void Function(Yurutme yurutme, List<KodOgesi> kod)? onCalisti;
  final VoidCallback? onOynatmaBitti;

  /// Dogru kodda sahne sonunda Devi sevincle zipliyor.
  final bool dogru;

  final double? sahneYuksekligi;
  final bool izGoster;

  /// Proje Atolyesi: cocugun kuklasi, hazir kodlu diger kuklalar,
  /// otomatik oyuncu ve sure siniri (bkz. [ProjeMotoru]).
  final KuklaTanimi ana;
  final List<KuklaTanimi> kuklalar;
  final OtomatikOyuncu oyuncu;
  final double sureSiniri;

  /// Proje Atolyesi: hedefler tamam mi? Tamamsa sonsuz dongulu oyun
  /// sure sinirini beklemeden bitiyor.
  final bool Function(Yurutme yurutme, List<KodOgesi> kod)? hedefTamam;

  @override
  State<ScratchTezgahi> createState() => ScratchTezgahiState();
}

class ScratchTezgahiState extends State<ScratchTezgahi> {
  late final List<KodOgesi> _kod = [...widget.baslangic];
  late int _imlec = _kod.length;
  int? _ekleSira;
  bool _alanUstunde = false;
  bool _calisiyor = false;
  Yurutme? _yurutme;
  List<ScratchBlock> _calisanBloklar = const [];
  GlobalKey<BlockAnimationPlayerState> _oynatici = GlobalKey();
  final ValueNotifier<int?> _calisanSira = ValueNotifier<int?>(null);
  final GlobalKey _sahneAnahtari = GlobalKey();

  /// Proje Atolyesi: calisan (ya da son calisan) motor ve bayrak
  /// oncesindeki onizleme motoru (kuklalar baslangic yerlerinde).
  ProjeMotoru? _motor;
  ProjeMotoru? _onizleme;
  Duration _mesgulKare = ProjeSahnesi.kareSuresi;
  final GlobalKey<ProjeSahnesiState> _projeSahnesi = GlobalKey();
  final Random _tohumlar = Random();

  List<KodOgesi> get kod => List.unmodifiable(_kod);
  bool get calisiyor => _calisiyor;

  @override
  void dispose() {
    _calisanSira.dispose();
    super.dispose();
  }

  bool _cMi(String id) => widget.palet
      .any((b) => b.id == id && b.shape == ScratchBlockShape.cBlock);

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  /// Kodu disaridan degistirir (kayitli projeyi acmak, ornegi yuklemek).
  void kodYukle(List<KodOgesi> yeni) {
    setState(() {
      _kod
        ..clear()
        ..addAll(yeni);
      _imlec = _kod.length;
      _kapat();
    });
    widget.onKodDegisti?.call(kod);
  }

  void _kapat() {
    if (_calisiyor) _oynatici.currentState?.durdur();
    _calisiyor = false;
    _yurutme = null;
    _motor = null;
    _onizleme = null;
    _calisanSira.value = null;
  }

  ProjeMotoru _yeniMotor(List<ScratchBlock> bloklar, int tohum) => ProjeMotoru(
        yorumlayici: BlokYorumlayici(dil: widget.lang, rastgele: Random(tohum)),
        bloklar: bloklar,
        ana: widget.ana,
        kuklalar: widget.kuklalar,
        oyuncu: widget.oyuncu,
        sureSiniri: widget.sureSiniri,
        // Canli sahnede cocuga once kendisi basma firsati.
        otomatikGecikme: 45,
      );

  /// Proje Atolyesi: motoru canli sahnede baslatir.
  void _projeyiCalistir(List<ScratchBlock> bloklar) {
    final tohum = _tohumlar.nextInt(1 << 30);
    // Prova: ayni tohumla bastan sona (kimse dokunmadan). Hiz icin:
    // etkilesimsiz kisa kod (cizim, puan) yavas cekimde, oyunlar gercek
    // hizda oynatiliyor.
    final prova = _yeniMotor(bloklar, tohum)..baslat();
    while (!prova.bitti) {
      prova.kare();
    }
    final ms = prova.etkilesimli
        ? 33
        : (3000 / max(1, prova.mesgulKare)).clamp(33, 350).round();
    setState(() {
      _calisanBloklar = bloklar;
      _yurutme = null;
      _mesgulKare = Duration(milliseconds: ms);
      _motor = _yeniMotor(bloklar, tohum)..baslat();
      _calisiyor = true;
      _calisanSira.value = null;
    });
  }

  void _projeBitti() {
    final m = _motor;
    if (m == null || !mounted) return;
    final y = m.sonuc();
    setState(() {
      _yurutme = y;
      _calisiyor = false;
    });
    _calisanSira.value = null;
    widget.onCalisti?.call(y, kod);
    widget.onOynatmaBitti?.call();
  }

  void _degisti(VoidCallback fn, {bool oturdu = false}) {
    setState(() {
      fn();
      _imlec = _imlec.clamp(0, _kod.length);
      _kapat();
    });
    // Blok yerine oturduysa her yerde ayni kisa "tok" (titresim dahil);
    // silme ve sayi degistirme yalnizca titresim.
    if (oturdu) {
      SoundService.playBlokTak();
    } else {
      HapticFeedback.lightImpact();
    }
    widget.onKodDegisti?.call(kod);
  }

  void _ekle(ScratchBlock b, {int? hedef}) {
    _degisti(() {
      _imlec = KodYapisi.ekle(_kod, hedef ?? _imlec, b);
    }, oturdu: true);
  }

  void _sil(int i) => _degisti(() {
        final (bas, _) = KodYapisi.aralik(_kod, i, _cMi);
        KodYapisi.sil(_kod, i, _cMi);
        if (_imlec > bas) _imlec = bas;
      });

  void _birak(IcIceTasima t, int hedef) {
    setState(() {
      _ekleSira = null;
      _alanUstunde = false;
    });
    if (t.kaynak == null) {
      _ekle(t.blok, hedef: hedef);
      return;
    }
    _degisti(() {
      final yeni = KodYapisi.tasi(_kod, t.kaynak!, hedef, _cMi);
      if (yeni != null) _imlec = yeni + 1;
    }, oturdu: true);
  }

  Future<void> _sayi(int i) async {
    final o = _kod[i];
    final eski = o.deger ?? ScratchBlokKatalogu.ilkSayi(o.id) ?? 0;
    final yeni = await SayiTusTakimi.goster(context,
        baslangic: eski, lang: widget.lang, renk: widget.renk);
    if (yeni == null || !mounted) return;
    _degisti(() => _kod[i] = o.degerIle(yeni));
  }

  void calistir() {
    if (_kod.isEmpty) return;
    HapticFeedback.lightImpact();
    final bloklar = KodYapisi.blokla(_kod, widget.palet);
    if (widget.cokBetik) {
      _projeyiCalistir(bloklar);
      _sahneyiGoster();
      return;
    }
    final y = BlokYorumlayici(dil: widget.lang).yurut(bloklar);
    setState(() {
      _calisanBloklar = bloklar;
      _yurutme = y;
      _calisiyor = true;
      _oynatici = GlobalKey();
      _calisanSira.value = null;
    });
    widget.onCalisti?.call(y, kod);
    _sahneyiGoster();
  }

  void _sahneyiGoster() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final c = _sahneAnahtari.currentContext;
      if (c == null || !mounted) return;
      await Scrollable.ensureVisible(c,
          duration: Motion.reduced(context)
              ? Duration.zero
              : const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    });
  }

  void durdur() {
    if (!_calisiyor) return;
    if (widget.cokBetik) {
      // Sahne motoru durduruyor; bitis _projeBitti'de.
      final s = _projeSahnesi.currentState;
      if (s != null) {
        s.durdur();
        return;
      }
      _motor?.durdur();
      _projeBitti();
      return;
    }
    _oynatici.currentState?.durdur();
    setState(() => _calisiyor = false);
    _calisanSira.value = null;
    widget.onOynatmaBitti?.call();
  }

  void _bitti() {
    if (mounted && _calisiyor) {
      setState(() => _calisiyor = false);
      widget.onOynatmaBitti?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final kisa = MediaQuery.sizeOf(context).height < 700;
    final kukla = kisa ? 56.0 : 72.0;
    final oynuyor = _yurutme != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: _sahneAnahtari,
          child: widget.cokBetik
              ? _projeSahnesiKarti(kisa)
              : SizedBox(
                  height: widget.sahneYuksekligi ?? (kisa ? 210 : 248),
                  child: ScratchSahneKarti(
                    lang: widget.lang,
                    bayrakAnahtari: const ValueKey('sahne_bayragi'),
                    durAnahtari: const ValueKey('sahne_dur'),
                    onBayrak: _kod.isNotEmpty && !_calisiyor ? calistir : null,
                    onDur: _calisiyor ? durdur : null,
                    child: oynuyor
                        ? BlockAnimationPlayer(
                            key: _oynatici,
                            sahne: true,
                            blocks: _calisanBloklar,
                            lang: widget.lang,
                            scratch: true,
                            size: kukla,
                            yurutme: _yurutme,
                            dogru: widget.dogru,
                            renk: widget.renk,
                            baslamaGecikmesi: const Duration(milliseconds: 350),
                            // Proje cizimi yarida kesilmesin; uzun kod hizli.
                            adimSiniri: widget.cokBetik ? 400 : null,
                            hiz:
                                (_yurutme!.adimlar.length / 40).clamp(1.0, 4.0),
                            onComplete: _bitti,
                            onAdim: (sira) {
                              if (mounted) _calisanSira.value = sira;
                            },
                          )
                        : _bosSahne(kukla),
                  ),
                ),
        ),
        if (widget.cokBetik && widget.kuklalar.isNotEmpty) ...[
          const SizedBox(height: 8),
          _kuklaSeridi(),
        ],
        const SizedBox(height: 12),
        BlokTezgahiKarti(
          lang: widget.lang,
          paletPayi: 1,
          kodPayi: 1,
          dikeyEsik: 330,
          kodVurgusu: _alanUstunde ? widget.renk.withValues(alpha: 0.08) : null,
          palet: IcIcePalet(
            palet: widget.palet,
            lang: widget.lang,
            onEkle: (b) => _ekle(b),
            onKodDanCikar: _sil,
          ),
          kod: _kodBolumu(),
        ),
        const SizedBox(height: 14),
        PressButton(
          key: const ValueKey('ders_bayrak'),
          label: _calisiyor
              ? _t('Durdur', 'Stop', 'Stopp', 'Detener')
              : _t('Yeşil bayrağa bas', 'Press the green flag',
                  'Grüne Flagge drücken', 'Pulsa la bandera verde'),
          icon: _calisiyor ? Icons.stop_rounded : Icons.flag_rounded,
          color: _calisiyor ? const Color(0xFFEC5959) : const Color(0xFF4CBF56),
          onPressed: _kod.isEmpty ? null : (_calisiyor ? durdur : calistir),
        ),
        if (oynuyor && (_yurutme!.sapkasizBlok > 0)) ...[
          const SizedBox(height: 10),
          _not(
              Icons.info_outline_rounded,
              _t(
                  '${_yurutme!.sapkasizBlok} blok hiçbir şapka bloğunun altında değil, o yüzden çalışmadı. Bir olay bloğunun altına tak.',
                  '${_yurutme!.sapkasizBlok} blocks are not under any hat block, so they did not run. Attach them under an event block.',
                  '${_yurutme!.sapkasizBlok} Blöcke hängen unter keinem Hutblock und sind nicht gelaufen. Häng sie unter einen Ereignisblock.',
                  '${_yurutme!.sapkasizBlok} bloques no están bajo ningún bloque de sombrero y no se ejecutaron. Engánchalos bajo un bloque de evento.')),
        ],
        if (oynuyor && widget.izGoster) ...[
          const SizedBox(height: 12),
          CalismaIzi(
            bloklar: _calisanBloklar,
            lang: widget.lang,
            yurutme: _yurutme,
            scratch: true,
            katlanabilir: true,
          ),
        ],
      ],
    );
  }

  /// Proje Atolyesi sahnesi: Scratch olcusunde (4:3), program tus
  /// kullaniyorsa altinda sanal tuslar.
  Widget _projeSahnesiKarti(bool kisa) {
    final motor = _motor ??
        (_onizleme ??= _yeniMotor(KodYapisi.blokla(_kod, widget.palet), 0));
    return LayoutBuilder(builder: (context, kutu) {
      var tuval = kutu.maxWidth * 0.75;
      // Kisa ekranda sahne kod alanini ekrandan itmesin.
      final enFazla = MediaQuery.sizeOf(context).height * (kisa ? 0.36 : 0.42);
      if (tuval > enFazla) tuval = enFazla;
      final tuslar = motor.tuslar.isNotEmpty;
      return SizedBox(
        height: ScratchSahneKarti.baslikYuksekligi +
            tuval +
            (tuslar ? ProjeSahnesi.tusSeridi : 0),
        child: ScratchSahneKarti(
          lang: widget.lang,
          bayrakAnahtari: const ValueKey('sahne_bayragi'),
          durAnahtari: const ValueKey('sahne_dur'),
          onBayrak: _kod.isNotEmpty && !_calisiyor ? calistir : null,
          onDur: _calisiyor ? durdur : null,
          child: ProjeSahnesi(
            key: _projeSahnesi,
            motor: motor,
            lang: widget.lang,
            calisiyor: _calisiyor && _motor != null,
            renk: widget.renk,
            mesgulKare: _mesgulKare,
            baslamaGecikmesi: const Duration(milliseconds: 350),
            dogru: widget.dogru,
            ipucu: _calisiyor || _motor != null
                ? null
                : _kod.isEmpty
                    ? _t(
                        'Bloklarla kodunu kur, sonra yeşil bayrağa bas.',
                        'Build your code with blocks, then press the green flag.',
                        'Bau deinen Code aus Blöcken und drück dann die grüne Flagge.',
                        'Arma tu código con bloques y luego pulsa la bandera verde.')
                    : _t(
                        'Hazır! Yeşil bayrağa bas ve izle.',
                        'Ready! Press the green flag and watch.',
                        'Fertig! Drück die grüne Flagge und schau zu.',
                        '¡Listo! Pulsa la bandera verde y mira.'),
            hedefTamam: widget.hedefTamam == null || _motor == null
                ? null
                : () => widget.hedefTamam!(_motor!.sonuc(), kod),
            onAdim: (sira) {
              if (mounted) _calisanSira.value = sira;
            },
            onBitti: _projeBitti,
          ),
        ),
      );
    });
  }

  /// Hazir kodlu kuklalar: dokununca kodlari (degistirilemez) aciliyor.
  Widget _kuklaSeridi() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _kuklaCipi(widget.ana, null),
        for (final k in widget.kuklalar) _kuklaCipi(k, () => _koduGoster(k)),
      ],
    );
  }

  Widget _kuklaCipi(KuklaTanimi k, VoidCallback? onTap) {
    final ad = k.adFor(widget.lang);
    final metin = onTap == null
        ? _t('$ad · senin kodun', '$ad · your code', '$ad · dein Code',
            '$ad · tu código')
        : _t('$ad · hazır kodu', '$ad · ready-made code', '$ad · fertiger Code',
            '$ad · código listo');
    return Material(
      color: onTap == null
          ? widget.renk.withValues(alpha: 0.12)
          : const Color(0xFFF1F4F9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        key: ValueKey('kukla_cipi_${k.ad}'),
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(onTap == null ? Icons.edit_rounded : Icons.visibility_rounded,
                size: 16,
                color: onTap == null ? widget.renk : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(metin,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color:
                        onTap == null ? widget.renk : const Color(0xFF475569))),
          ]),
        ),
      ),
    );
  }

  void _koduGoster(KuklaTanimi k) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t(
                    '${k.adFor(widget.lang)} kuklasının kodu',
                    '${k.adFor(widget.lang)}\'s code',
                    'Code von ${k.adFor(widget.lang)}',
                    'Código de ${k.adFor(widget.lang)}'),
                style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w900,
                    fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                _t(
                    'Bu kukla hazır gelir; kodunu okuyabilirsin ama değiştiremezsin. Senin kuklanla aynı anda çalışır.',
                    'This sprite comes ready-made: you can read its code but not change it. It runs at the same time as your sprite.',
                    'Diese Figur ist fertig: Du kannst ihren Code lesen, aber nicht ändern. Er läuft gleichzeitig mit deiner Figur.',
                    'Este objeto viene listo: puedes leer su código pero no cambiarlo. Funciona a la vez que tu objeto.'),
                style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF475569)),
              ),
              const SizedBox(height: 12),
              IgnorePointer(
                child: IcIceKodAlani(
                  kod: KodYapisi.coz(k.kod),
                  palet: k.palet,
                  lang: widget.lang,
                  imlec: -1,
                  onImlec: (_) {},
                  onSil: (_) {},
                  onBirak: (_, __) {},
                  saltOkunur: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _not(IconData ikon, String yazi) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4DB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(ikon, color: const Color(0xFFB7791F), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(yazi,
                style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF8A5A00))),
          ),
        ]),
      );

  Widget _kodBolumu() {
    return DragTarget<IcIceTasima>(
      onWillAcceptWithDetails: (_) {
        if (!_alanUstunde) setState(() => _alanUstunde = true);
        return true;
      },
      onLeave: (_) => setState(() {
        _alanUstunde = false;
        _ekleSira = null;
      }),
      onAcceptWithDetails: (d) => _birak(d.data, _ekleSira ?? _kod.length),
      builder: (context, a, r) => ConstrainedBox(
        constraints:
            const BoxConstraints(minHeight: 124, minWidth: double.infinity),
        child: _kod.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _t(
                      'Bloklara dokun ya da basılı tutup buraya sürükle',
                      'Tap the blocks, or hold and drag them here',
                      'Tippe auf die Blöcke oder halte sie gedrückt und zieh sie hierher',
                      'Toca los bloques o mantenlos pulsados y arrástralos aquí'),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              )
            : Align(
                alignment: Alignment.topLeft,
                child: IcIceKodAlani(
                  kod: _kod,
                  palet: widget.palet,
                  lang: widget.lang,
                  imlec: _imlec,
                  onImlec: (i) => setState(() => _imlec = i),
                  onSil: _sil,
                  onBirak: _birak,
                  onSayi: widget.duzenlenebilir.isEmpty ? null : _sayi,
                  duzenlenebilir: widget.duzenlenebilir,
                  calisanSira: _calisanSira,
                  ekleSira: _ekleSira,
                  onEkleSira: (i) => setState(() => _ekleSira = i),
                ),
              ),
      ),
    );
  }

  Widget _bosSahne(double kukla) {
    return ScratchSahneZemini(builder: (context, boyut, zemin) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: boyut.width * 0.08,
            top: zemin - kukla + 4,
            child: Mascot(size: kukla, showShadow: false),
          ),
          Positioned(
            left: 8,
            right: 8,
            top: 6,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _kod.isEmpty
                      ? _t(
                          'Bloklarla kodunu kur, sonra yeşil bayrağa bas.',
                          'Build your code with blocks, then press the green flag.',
                          'Bau deinen Code aus Blöcken und drück dann die grüne Flagge.',
                          'Arma tu código con bloques y luego pulsa la bandera verde.')
                      : _t(
                          'Hazır! Yeşil bayrağa bas ve izle.',
                          'Ready! Press the green flag and watch.',
                          'Fertig! Drück die grüne Flagge und schau zu.',
                          '¡Listo! Pulsa la bandera verde y mira.'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A4F5C),
                    height: 1.25,
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

/// Ilerleyen ipucu: iki basarisiz denemeden sonra ipucu, dorduncuden
/// sonra ornek cozum.
///
/// Cevabi bastan vermiyor; "nereye bakmali"yi once soyluyor. Cocuk
/// takilip kalmasin diye dorduncu denemeden sonra tam diziyi gosteriyor.
class IlerleyenIpucu extends StatelessWidget {
  const IlerleyenIpucu({
    super.key,
    required this.yanlis,
    required this.lang,
    required this.cozum,
    this.ipucu,
  });

  static const int ipucuEsigi = 2;
  static const int cozumEsigi = 4;

  final int yanlis;
  final String lang;
  final String? ipucu;
  final List<String> cozum;

  @override
  Widget build(BuildContext context) {
    if (yanlis < ipucuEsigi) return const SizedBox.shrink();
    final tam = yanlis >= cozumEsigi;
    final metin = ipucu;
    return Container(
      key: ValueKey(tam ? 'ipucu_cozum' : 'ipucu_1'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF9CC3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.lightbulb_rounded, color: Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Text(
              AppLang.pick(lang,
                  tr: 'İpucu', en: 'Hint', de: 'Tipp', es: 'Pista'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ]),
          if (metin != null) ...[
            const SizedBox(height: 6),
            Text(metin,
                style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A))),
          ],
          if (tam && cozum.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              AppLang.pick(lang,
                  tr: 'Bir çözüm şöyle:',
                  en: 'Here is one way to do it:',
                  de: 'So geht es zum Beispiel:',
                  es: 'Una forma de hacerlo:'),
              style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 6),
            Container(
              key: const ValueKey('ipucu_cozum_satirlari'),
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                // Bayrak bir simge; duz yazida kelimeyle.
                cozum.join('\n').replaceAll(
                    '⚑',
                    AppLang.pick(lang,
                        tr: 'yeşil bayrak',
                        en: 'green flag',
                        de: 'grüne Flagge',
                        es: 'bandera verde')),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ] else if (!tam) ...[
            const SizedBox(height: 6),
            Text(
              AppLang.pick(lang,
                  tr: 'Biraz daha denersen bir çözüm göstereceğim.',
                  en: 'Try a little more and I will show you a solution.',
                  de: 'Versuch es noch ein bisschen, dann zeige ich dir eine Lösung.',
                  es: 'Inténtalo un poco más y te mostraré una solución.'),
              style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12.5,
                  color: Color(0xFF475569)),
            ),
          ],
        ],
      ),
    );
  }
}
