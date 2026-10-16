import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../services/sound_service.dart';
import '../../../theme.dart';
import '../../../utils/lang.dart';
import '../../../widgets/scratch_blok.dart';
import '../../sahne/blok_tezgahi_karti.dart';
import '../../yurutme/kod_yapisi.dart';
import '../../yurutme/mblock_blok_adlari.dart';
import '../../yurutme/mblock_cozum.dart';
import '../../yurutme/mblock_kod.dart';
import '../../yurutme/mblock_yuvalari.dart';
import 'sayi_tus_takimi.dart';

/// Suruklenen mBlock blogu: paletten (kaynak null) ya da kod alanindan.
class MBlockTasima {
  const MBlockTasima(this.tip, {this.kaynak});
  final String tip;
  final int? kaynak;
}

/// FLUTTER mBLOCK TEZGAHI — Scratch atolyesindeki kategorili tezgah,
/// mBlock bloklariyla.
///
/// Serbest mBlock atolyesi eskiden WebView'daki scratch-blocks
/// editorunu kullaniyordu: telefonda blok listesi ekranin cogunu
/// kapliyor, birakma alani daraliyor, sayfa uzuyordu. Burada Scratch
/// atolyesinin AYNI tezgahi ([BlokTezgahiKarti.kategorili]): kategori
/// sekmeleri, kod olceginde palet, sinirli yukseklik, dar ekranda
/// "Bloklar | Kod". Bloklar Scratch 3 cizimiyle ama mBlock'un renk ve
/// etiketleriyle ([MBlockKod.cizim]).
///
///  * Dokun = imlecin yerine ekle; basili tut + surukle = istenen yere.
///  * C bloklari (surekli tekrarla, tekrarla, eger) icine blok alir.
///  * Beyaz ovale dokun: sayi tus takimi. Acilir listeye (pin, yuksek)
///    dokun: kucuk secici. Bos altigene dokun: kosul secici.
///  * Oval / altigen bloklar (dijital oku, mesafe, degil...) bir YUVAYA
///    takilir: dokununca imlecin ustundeki blogun bos yuvasina, bir
///    blogun ustune birakinca o blogun yuvasina. Takili bloga dokunmak
///    onu cikarir.
class MBlockAtolyeTezgahi extends StatefulWidget {
  const MBlockAtolyeTezgahi({
    super.key,
    required this.lang,
    required this.bloklar,
    required this.renk,
    this.onDegisti,
    this.ustunde = 0,
    this.calisiyor = false,
  });

  final String lang;

  /// Palette gosterilecek katalog kimlikleri.
  final List<String> bloklar;
  final Color renk;
  final ValueChanged<List<List<MBlockBlok>>>? onDegisti;

  /// Tezgahin ustunde kalan yukseklik (sahne): tezgah ekrana sigsin.
  final double ustunde;
  final bool calisiyor;

  @override
  State<MBlockAtolyeTezgahi> createState() => MBlockAtolyeTezgahiState();
}

class MBlockAtolyeTezgahiState extends State<MBlockAtolyeTezgahi> {
  final List<KodOgesi> _kod = [];
  int _imlec = 0;
  int _surum = 0;
  int? _ekleSira;
  bool _alanUstunde = false;

  List<PaletOgesi>? _ogeler;
  String? _ogelerDili;

  List<KodOgesi> get kod => List.unmodifiable(_kod);

  /// Sahnenin calistirdigi yiginlar.
  List<List<MBlockBlok>> get program => MBlockKod.program(_kod);

  int get blokSayisi => _kod.where((o) => !KodYapisi.isaretMi(o.id)).length;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  @override
  void didUpdateWidget(MBlockAtolyeTezgahi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.bloklar, widget.bloklar)) _ogeler = null;
  }

  // ------------------------------------------------------------------
  // Kod
  // ------------------------------------------------------------------

  /// Hazir programi tezgaha koyar.
  void yukle(List<List<MBlockBlok>> yiginlar) {
    setState(() {
      _kod
        ..clear()
        ..addAll(MBlockKod.duzle(yiginlar));
      _imlec = _kod.length;
      _surum++;
    });
    _bildir();
  }

  void temizle() {
    if (_kod.isEmpty) return;
    setState(() {
      _kod.clear();
      _imlec = 0;
      _surum++;
    });
    HapticFeedback.lightImpact();
    _bildir();
  }

  void _bildir() {
    final cb = widget.onDegisti;
    if (cb == null) return;
    final p = program;
    // Kurulum sirasinda (yukle initState'ten) sahibin setState'i
    // cerceve sonuna.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) cb(p);
      });
    } else {
      cb(p);
    }
  }

  void _degisti(VoidCallback fn, {bool oturdu = false}) {
    setState(() {
      fn();
      _imlec = _imlec.clamp(0, _kod.length);
      _surum++;
    });
    if (oturdu) {
      SoundService.playBlokTak();
    } else {
      HapticFeedback.lightImpact();
    }
    _bildir();
  }

  /// Paletten dokunuldu.
  void ekle(String tip) {
    if (MBlockKod.degerMi(tip)) {
      _yuvayaTak(tip);
      return;
    }
    _degisti(() {
      _imlec = MBlockKod.ekle(_kod, _imlec, MBlockKod.yeni(tip, widget.lang));
    }, oturdu: true);
  }

  void _sil(int i) => _degisti(() {
        final (bas, _) = KodYapisi.aralik(_kod, i, MBlockKod.cMi);
        KodYapisi.sil(_kod, i, MBlockKod.cMi);
        if (_imlec > bas) _imlec = bas;
      });

  void _birak(MBlockTasima t, int hedef) {
    setState(() {
      _ekleSira = null;
      _alanUstunde = false;
    });
    if (MBlockKod.degerMi(t.tip)) {
      _yuvayaTak(t.tip, hedef: hedef < _kod.length ? hedef : null);
      return;
    }
    if (t.kaynak == null) {
      _degisti(() {
        _imlec = MBlockKod.ekle(_kod, hedef, MBlockKod.yeni(t.tip, widget.lang));
      }, oturdu: true);
      return;
    }
    _degisti(() {
      final yeni = KodYapisi.tasi(_kod, t.kaynak!, hedef, MBlockKod.cMi);
      if (yeni != null) _imlec = yeni + 1;
    }, oturdu: true);
  }

  /// Oval/altigen blogu bir yuvaya takar: [hedef] verilmisse o bloga,
  /// yoksa imlecin ustundeki (ve daha yukaridaki) ilk uygun bloga.
  bool _yuvayaTak(String tip, {int? hedef}) {
    final adaylar = hedef != null
        ? [hedef]
        : [for (var i = min(_imlec, _kod.length) - 1; i >= 0; i--) i];
    for (final i in adaylar) {
      if (i < 0 || i >= _kod.length) continue;
      final o = _kod[i];
      if (o is! MBlockKodOgesi) continue;
      final yol = MBlockKod.bosYuva(o.blok, tip);
      if (yol == null) continue;
      _degisti(() {
        _kod[i] = o.blokIle(MBlockKod.tak(
            o.blok, yol, MBlockKod.yeniBlok(tip, widget.lang)));
      }, oturdu: true);
      return true;
    }
    final altigen = MBlockKod.altigenMi(tip);
    _ipucu(altigen
        ? _t(
            'Bu altıgen blok bir "eğer" bloğunun yuvasına takılır. Önce "eğer" koy.',
            'This hexagon block goes into the slot of an "if" block. Add an "if" first.',
            'Dieser Sechseck-Block gehört in das Feld eines „falls“-Blocks. Setz zuerst „falls“ ein.',
            'Este bloque hexagonal va en el hueco de un bloque «si». Pon primero un «si».')
        : _t(
            'Bu yuvarlak blok bir bloğun beyaz yuvasına takılır. Önce o bloğu koy.',
            'This round block goes into the white slot of a block. Add that block first.',
            'Dieser runde Block gehört in das weiße Feld eines Blocks. Setz zuerst diesen Block ein.',
            'Este bloque redondo va en el hueco blanco de un bloque. Pon primero ese bloque.'));
    return false;
  }

  void _ipucu(String metin) {
    HapticFeedback.selectionClick();
    final m = ScaffoldMessenger.maybeOf(context);
    if (m == null) return;
    m
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        key: const ValueKey('mblock_tezgah_ipucu'),
        content: Text(metin,
            style: const TextStyle(
                fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
  }

  /// Bir yuvaya dokunuldu.
  Future<void> yuvayaDokun(int i, List<String> yol, SbParca parca) async {
    final o = _kod[i];
    if (o is! MBlockKodOgesi) return;
    final sahip = MBlockKod.sahip(o.blok, yol);
    if (sahip == null) return;
    final ad = yol.last;
    final yuva = mblockYuva(sahip.tip, ad);
    void yaz(String deger) =>
        _degisti(() => _kod[i] = o.blokIle(MBlockKod.alanYaz(o.blok, yol, deger)));

    switch (parca) {
      case SbIcBlok():
        _degisti(() => _kod[i] = o.blokIle(MBlockKod.cikar(o.blok, yol)));
      case SbBosKosul():
        final tip = await _kosulSec();
        if (tip == null || !mounted) return;
        final guncel = _kod[i];
        if (guncel is! MBlockKodOgesi) return;
        _degisti(
            () => _kod[i] = guncel.blokIle(MBlockKod.tak(
                guncel.blok, yol, MBlockKod.yeniBlok(tip, widget.lang))),
            oturdu: true);
      case SbAcilir():
        if (yuva == null) return;
        final secenekler = yuva.seceneklerFor(widget.lang);
        if (secenekler.length < 2) return;
        final d = await _sec(
            _yuvaBasligi(ad), secenekler,
            sahip.alanlar[ad] ?? MBlockKod.varsayilanlar(sahip.tip, widget.lang)[ad]);
        if (d != null && mounted) yaz(d);
      case SbGirdi(:final deger):
        if (yuva == null) return;
        if (yuva.tur == MBlockYuvaTuru.metin) {
          final d = await _sec(_yuvaBasligi(ad), _metinler(ad), deger);
          if (d != null && mounted) yaz(d);
          return;
        }
        final eski = num.tryParse(deger) ?? 0;
        final yeni = await SayiTusTakimi.goster(context,
            baslangic: eski, lang: widget.lang, renk: widget.renk);
        if (yeni == null || !mounted) return;
        if (yuva.tur == MBlockYuvaTuru.pozitif && yeni <= 0) return;
        yaz(yeni == yeni.roundToDouble() ? '${yeni.toInt()}' : '$yeni');
      case SbRenk() || SbYazi() || SbIkon():
        return;
    }
  }

  /// Secicinin basligi: yuvanin cocuk dilindeki adi.
  String _yuvaBasligi(String ad) => switch (ad) {
        'PIN' => _t('Pin seç', 'Choose a pin', 'Pin wählen', 'Elige un pin'),
        'SEVIYE' => _t('Çıkış seviyesi', 'Output level', 'Ausgangspegel',
            'Nivel de salida'),
        'AD' => _t('Değişken', 'Variable', 'Variable', 'Variable'),
        'NESNE' => _t('Kukla', 'Sprite', 'Figur', 'Objeto'),
        'SES' => _t('Ses', 'Sound', 'Klang', 'Sonido'),
        _ => _t('Yazı seç', 'Choose a text', 'Text wählen', 'Elige un texto'),
      };

  List<(String, String)> _metinler(String ad) {
    if (ad == 'SES') {
      return const [('Bubbles', 'Bubbles'), ('Pop', 'Pop'), ('Chomp', 'Chomp')];
    }
    final l = switch (widget.lang) {
      'en' => ['Hello!', 'Hi!', 'Great!', 'Let\'s go!', 'hello'],
      'de' => ['Hallo!', 'Hi!', 'Super!', 'Los geht\'s!', 'hallo'],
      'es' => ['¡Hola!', '¡Hey!', '¡Genial!', '¡Vamos!', 'hola'],
      _ => ['Merhaba!', 'Selam!', 'Harika!', 'Hadi!', 'merhaba'],
    };
    return [for (final x in l) (x, x)];
  }

  /// Kucuk secici: buyuk dokunma alanli secenekler.
  Future<String?> _sec(
      String baslik, List<(String, String)> secenekler, String? secili) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(baslik,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF3D4A66))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (ad, d) in secenekler)
                    Material(
                      color: d == secili
                          ? widget.renk
                          : const Color(0xFFF1F4F9),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        key: ValueKey('mblock_secenek_$d'),
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pop(c, d),
                        child: Container(
                          constraints:
                              const BoxConstraints(minWidth: 52, minHeight: 48),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Center(
                           widthFactor: 1,
                           heightFactor: 1,
                           child: Text(ad,
                              style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: d == secili
                                      ? Colors.white
                                      : const Color(0xFF3D4A66))),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bos altigene dokunuldu: palette olan kosul bloklarindan biri.
  Future<String?> _kosulSec() {
    final kosullar = [
      for (final t in widget.bloklar)
        if (MBlockKod.altigenMi(t)) t
    ];
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  _t('Hangi koşul?', 'Which condition?', 'Welche Bedingung?',
                      '¿Qué condición?'),
                  style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF3D4A66))),
              const SizedBox(height: 12),
              for (final t in kosullar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    key: ValueKey('mblock_kosul_$t'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(c, t),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ScratchBlok(
                          tanim: MBlockKod.cizim(
                                  MBlockKod.yeniBlok(t, widget.lang),
                                  widget.lang)
                              .tanim,
                          olcek: 0.8,
                          kimlik: t,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Gorunum
  // ------------------------------------------------------------------

  List<PaletOgesi> get _paletOgeleri {
    if (_ogeler != null && _ogelerDili == widget.lang) return _ogeler!;
    _ogelerDili = widget.lang;
    return _ogeler = [
      for (final tip in widget.bloklar)
        if (mblockBlokTanimlari.containsKey(tip))
          () {
            final t = MBlockKod.cizim(
                    MBlockKod.yeniBlok(tip, widget.lang), widget.lang)
                .tanim;
            return PaletOgesi(
              kimlik: tip,
              tanim: t,
              builder: (context, s) => LongPressDraggable<MBlockTasima>(
                data: MBlockTasima(tip),
                delay: const Duration(milliseconds: 150),
                hapticFeedbackOnStart: true,
                feedback: Material(
                  color: Colors.transparent,
                  child: ScratchBlok(tanim: t, olcek: s * 1.08, sigdir: false),
                ),
                childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: ScratchBlok(tanim: t, olcek: s, sigdir: false)),
                child: GestureDetector(
                  key: ValueKey('mblock_palet_$tip'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => ekle(tip),
                  child: ScratchBlok(
                      tanim: t, olcek: s, sigdir: false, kimlik: tip),
                ),
              ),
            );
          }(),
    ];
  }

  Widget _paletHedefi(Widget child) => DragTarget<MBlockTasima>(
        onWillAcceptWithDetails: (d) => d.data.kaynak != null,
        onAcceptWithDetails: (d) => _sil(d.data.kaynak!),
        builder: (context, a, r) => child,
      );

  Widget _kodHedefi(Widget child) => DragTarget<MBlockTasima>(
        onWillAcceptWithDetails: (_) {
          if (!_alanUstunde) setState(() => _alanUstunde = true);
          return true;
        },
        onLeave: (_) => setState(() {
          _alanUstunde = false;
          _ekleSira = null;
        }),
        onAcceptWithDetails: (d) => _birak(d.data, _ekleSira ?? _kod.length),
        builder: (context, a, r) => child,
      );

  Widget _kodIcerigi(BuildContext context, double olcek, double genislik) {
    if (_kod.isEmpty) {
      return SizedBox(
        width: genislik,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _t(
                'Bloklara dokun ya da basılı tutup buraya sürükle. Uno için "when Arduino Uno starts up", Devi için yeşil bayrakla başla.',
                'Tap the blocks, or hold and drag them here. Start with "when Arduino Uno starts up" for the Uno, or the green flag for Devi.',
                'Tippe auf die Blöcke oder zieh sie hierher. Beginne mit „wenn Arduino Uno startet“ für den Uno oder der grünen Flagge für Devi.',
                'Toca los bloques o arrástralos aquí. Empieza con «cuando Arduino Uno se inicia» para el Uno o con la bandera verde para Devi.'),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      );
    }
    return MBlockKodAlani(
      kod: _kod,
      lang: widget.lang,
      imlec: _imlec,
      olcek: olcek,
      sigmaGenisligi: genislik,
      enKucukOlcek: olcek * 0.8,
      ekleSira: _ekleSira,
      onImlec: (i) => setState(() => _imlec = i),
      onSil: _sil,
      onBirak: _birak,
      onYuva: yuvayaDokun,
      onEkleSira: (i) => setState(() => _ekleSira = i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlokTezgahiKarti.kategorili(
      lang: widget.lang,
      ogeler: _paletOgeleri,
      kategoriSirasi: MBlockKod.kategoriSirasi,
      paletEnKucukOrani: 0.8,
      yukseklik:
          BlokTezgahiKarti.yukseklikFor(context, ustunde: widget.ustunde),
      kodSayisi: blokSayisi,
      kodSurumu: _surum,
      calisiyor: widget.calisiyor,
      kodVurgusu: _alanUstunde ? widget.renk.withValues(alpha: 0.08) : null,
      paletHedefi: _paletHedefi,
      kodHedefi: _kodHedefi,
      kodIcerigi: _kodIcerigi,
    );
  }
}

/// mBlock kod alani: [IcIceKodAlani] ile ayni duzen (C bloklari agzini
/// sarar, sari imlec, sagda "x"), bloklar [MBlockKod.cizim] ile.
class MBlockKodAlani extends StatelessWidget {
  const MBlockKodAlani({
    super.key,
    required this.kod,
    required this.lang,
    required this.imlec,
    required this.onImlec,
    required this.onSil,
    required this.onBirak,
    required this.onYuva,
    this.ekleSira,
    this.onEkleSira,
    this.olcek = ScratchBlok.varsayilanOlcek,
    this.sigmaGenisligi,
    this.enKucukOlcek = 0,
  });

  final List<KodOgesi> kod;
  final String lang;
  final int imlec;
  final ValueChanged<int> onImlec;
  final ValueChanged<int> onSil;
  final void Function(MBlockTasima t, int hedef) onBirak;
  final void Function(int sira, List<String> yol, SbParca parca) onYuva;
  final int? ekleSira;
  final ValueChanged<int?>? onEkleSira;
  final double olcek;
  final double? sigmaGenisligi;
  final double enKucukOlcek;

  MBlockCizim? _cizim(int i) {
    final o = kod[i];
    if (o is! MBlockKodOgesi) return null;
    return MBlockKod.cizim(o.blok, lang);
  }

  @override
  Widget build(BuildContext context) {
    final cizimler = [for (var i = 0; i < kod.length; i++) _cizim(i)];
    return LayoutBuilder(builder: (context, c) {
      final girinti = KodYapisi.girintiler(kod, MBlockKod.cMi);
      double genislik(double s) {
        var m = 0.0;
        for (var i = 0; i < kod.length; i++) {
          final t = cizimler[i]?.tanim;
          if (t == null) continue;
          final w = ScratchBlokOlcer.genislik(t, s,
              parca: t.cMi ? ScratchCParcasi.ust : ScratchCParcasi.tamami,
              silme: true);
          m = max(m, girinti[i] * ScratchBlokOlcer.kolGenisligi(s) + w);
        }
        return m;
      }

      var s = olcek;
      final w = genislik(s);
      final sinir = sigmaGenisligi ?? c.maxWidth;
      if (sinir.isFinite && w > sinir) {
        s = max(enKucukOlcek, s * sinir / w * 0.99);
      }
      return Padding(
        padding: EdgeInsets.only(bottom: ScratchBlokOlcer.tirnakPayi(s)),
        child: _dizi(context, cizimler, 0, kod.length, 0, s),
      );
    });
  }

  Widget _imlecCizgisi(double s) => Padding(
        key: const ValueKey('ic_ice_imlec'),
        padding: EdgeInsets.symmetric(vertical: 2 * s),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded,
                size: 16 * s + 4, color: const Color(0xFFFFB800)),
            Container(
              width: 72 * s,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD43B),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      );

  /// Yigin birakma hedefi; oval/altigen blok o bloga takiliyor.
  Widget _hedef(int hedef, Widget child) => DragTarget<MBlockTasima>(
        onWillAcceptWithDetails: (d) {
          if (MBlockKod.degerMi(d.data.tip)) {
            if (hedef >= kod.length) return false;
            final o = kod[hedef];
            return o is MBlockKodOgesi &&
                MBlockKod.bosYuva(o.blok, d.data.tip) != null;
          }
          if (ekleSira != hedef) onEkleSira?.call(hedef);
          return true;
        },
        onLeave: (_) {
          if (ekleSira == hedef) onEkleSira?.call(null);
        },
        onAcceptWithDetails: (d) => onBirak(d.data, hedef),
        builder: (context, a, r) => child,
      );

  Widget _dizi(BuildContext context, List<MBlockCizim?> cizimler, int bas,
      int bitis, int derinlik, double s) {
    final ogeler = <Widget>[];
    var i = bas;
    while (i < bitis) {
      if (imlec == i) ogeler.add(_imlecCizgisi(s));
      final o = kod[i];
      if (KodYapisi.isaretMi(o.id)) {
        i++;
        continue;
      }
      if (derinlik == 0 && i > bas && MBlockKod.sapkaMi(o.id)) {
        ogeler.add(SizedBox(height: 18 * s));
      }
      final c = cizimler[i];
      if (c == null) {
        i++;
        continue;
      }
      final t = c.tanim;
      if (MBlockKod.cMi(o.id)) {
        final son = KodYapisi.kapanis(kod, i, MBlockKod.cMi);
        ogeler.add(_yerlesik(context, i, c, s, ScratchCParcasi.ust));
        ogeler.add(ScratchCSirti(
          kategori: t.kategori,
          olcek: s,
          child: _agiz(context, cizimler, i + 1, son, derinlik + 1, s),
        ));
        final sonrasi = min(son + 1, kod.length);
        ogeler.add(_hedef(
          sonrasi,
          GestureDetector(
            key: ValueKey('ic_ice_ayak_$i'),
            behavior: HitTestBehavior.opaque,
            onTap: () => onImlec(sonrasi),
            child: ScratchBlok(
              tanim: t,
              olcek: s,
              sigdir: false,
              parca: ScratchCParcasi.alt,
              icDolu: son > i + 1,
            ),
          ),
        ));
        i = sonrasi;
        continue;
      }
      ogeler.add(_yerlesik(context, i, c, s, ScratchCParcasi.tamami));
      i++;
    }
    if (imlec == bitis && (derinlik == 0 || bitis > bas)) {
      ogeler.add(_imlecCizgisi(s));
    }
    if (derinlik > 0 && bitis > bas) {
      ogeler.add(_hedef(
          bitis,
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onImlec(bitis),
            child: SizedBox(height: 8 * s, width: 60 * s),
          )));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ogeler,
    );
  }

  Widget _agiz(BuildContext context, List<MBlockCizim?> cizimler, int bas,
      int bitis, int derinlik, double s) {
    if (bitis > bas) return _dizi(context, cizimler, bas, bitis, derinlik, s);
    final secili = imlec == bitis;
    return _hedef(
      bitis,
      GestureDetector(
        key: ValueKey('ic_ice_agiz_$bitis'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onImlec(bitis),
        child: Container(
          height: ScratchBlokOlcer.bosAgiz(s) + 4,
          constraints: BoxConstraints(minWidth: 120 * s),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 6 * s),
          decoration: ekleSira == bitis
              ? BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: secili
              ? _imlecCizgisi(s)
              : Text(
                  AppLang.pick(lang,
                      tr: 'buraya koy',
                      en: 'put blocks here',
                      de: 'Blöcke hierher',
                      es: 'pon bloques aquí'),
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: const Color(0xFF8A94A6),
                    fontSize: 11.5 * s / ScratchBlok.varsayilanOlcek,
                    fontStyle: FontStyle.italic,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _yerlesik(BuildContext context, int i, MBlockCizim c, double s,
      ScratchCParcasi parca) {
    final t = c.tanim;
    final tip = kod[i].id;
    final genislik =
        ScratchBlokOlcer.genislik(t, s, parca: parca, silme: true);
    final kutular = ScratchBlokOlcer.parcaKutulari(t, s, silme: true);
    final ekleme = ekleSira == i;

    final gorunum = ScratchBlok(
      tanim: t,
      olcek: s,
      sigdir: false,
      silme: true,
      parca: parca,
      kimlik: tip,
      vurgu: ekleme ? Colors.white : null,
    );

    final dokunma = GestureDetector(
      key: ValueKey('ic_ice_blok_$i'),
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) {
        final p = d.localPosition;
        if (p.dx > genislik - 28 * s) {
          onSil(i);
          return;
        }
        // En icteki (en uzun yollu) parca kazanir: takili blogun pin
        // listesi, takili blogun kendisinden once.
        SbParcaKutusu? bulunan;
        for (final k in kutular) {
          if (!k.kutu.inflate(6).contains(p)) continue;
          if (bulunan == null || k.yol.length >= bulunan.yol.length) {
            bulunan = k;
          }
        }
        final yol = bulunan == null ? null : c.yuvaYolu(bulunan.yol);
        if (bulunan != null && yol != null) {
          onYuva(i, yol, bulunan.parca);
        } else {
          onImlec(i + 1);
        }
      },
      child: gorunum,
    );

    return _hedef(
      i,
      LongPressDraggable<MBlockTasima>(
        data: MBlockTasima(tip, kaynak: i),
        delay: const Duration(milliseconds: 150),
        hapticFeedbackOnStart: true,
        feedback: Material(
          color: Colors.transparent,
          child: ScratchBlok(
              tanim: t, olcek: s, sigdir: false, parca: ScratchCParcasi.bas),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: gorunum),
        child: dokunma,
      ),
    );
  }
}
