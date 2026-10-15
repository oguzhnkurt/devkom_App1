import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../theme.dart';
import '../../ui/motion.dart';
import '../../utils/lang.dart';
import '../../widgets/scratch_blok.dart';
import 'blok_tezgahi_karti.dart';

/// Paletteki bir blok: Scratch karsiligi ve verilen olcekte cizen
/// [builder] (dokunma / surukleme sarmalari tezgahin sahibinde).
class PaletOgesi {
  const PaletOgesi({
    required this.kimlik,
    required this.tanim,
    required this.builder,
  });

  final String kimlik;
  final ScratchBlokTanimi tanim;

  /// Blogu [olcek]te cizer. Olcek blok sutuna sigacak sekilde secildi.
  final Widget Function(BuildContext context, double olcek) builder;

  ScratchKategori get kategori => tanim.kategori.daire;
}

/// Kod alaninin icerigi: [olcek] tezgahin blok olcegi, [genislik] kod
/// sutununun kullanilabilir genisligi (sigdirmak icin).
typedef KodIcerigi = Widget Function(
    BuildContext context, double olcek, double genislik);

/// Bir bolumu birakma hedefiyle saran fonksiyon (DragTarget). Donen
/// widget [child]i tasimali ve verilen alani doldurmali.
typedef TezgahHedefi = Widget Function(Widget child);

/// SINIRLI YUKSEKLIKLI, KATEGORILI "Bloklar | Kod alani" tezgahi.
///
/// Eskiden palet tek uzun bir sutundu (bloklar kod alanindakilerin iki
/// kati buyuklukte) ve ustundeki kategori daireleri bir sey yapmiyordu:
/// sayfa asagi dogru uzuyor, cocuk surekli kaydiriyordu. Simdi:
///
///  * Tezgahin yuksekligi sabit ([yukseklik]); palet ve kod alani kendi
///    iclerinde kayiyor. Sayfa yalnizca hedefler -> sahne -> tezgah.
///  * Kategori seridi gercek sekmeler: dokununca palet o kategorinin
///    bolumune kayiyor (Scratch'teki gibi); kaydirdikca etkin kategori
///    vurgulaniyor.
///  * Paletteki bloklar kod alaniyla ayni olcekte; sutuna sigmayan uzun
///    blok kuculuyor (yatay tasma yok).
///  * Cok dar tezgahta (iki sutun okunmuyor) ustte "Bloklar | Kod"
///    secici; tek seferde biri gorunuyor.
///
/// Palet listesi tembel (ListView.builder) ve kod degisince yeniden
/// kurulmuyor: [ogeler] ayni liste oldukca liste widget'i onbellekte.
class KategoriliTezgah extends StatefulWidget {
  const KategoriliTezgah({
    super.key,
    required this.lang,
    required this.ogeler,
    required this.kodIcerigi,
    this.paletHedefi,
    this.kodHedefi,
    this.kodVurgusu,
    this.yukseklik,
    this.kodSayisi = 0,
    this.kodSurumu = 0,
    this.calisiyor = false,
  });

  final String lang;

  /// Paletin bloklari. Sahibi AYNI listeyi gecirdikce palet yeniden
  /// kurulmuyor (kod degisince palet yerinde kaliyor).
  final List<PaletOgesi> ogeler;
  final KodIcerigi kodIcerigi;
  final TezgahHedefi? paletHedefi;
  final TezgahHedefi? kodHedefi;
  final Color? kodVurgusu;

  /// null: ekran yuksekligine gore ([BlokTezgahiKarti.yukseklikFor]).
  final double? yukseklik;

  /// Kod alanindaki blok sayisi ("Kod" sekmesindeki rozet).
  final int kodSayisi;

  /// Kod her degistiginde artan sayac: kod alani imleci gorunur tutuyor.
  final int kodSurumu;

  /// Kod calisiyor: dar tezgahta "Kod" sekmesi aciliyor (calisan blok
  /// parliyor; cocuk onu gorsun).
  final bool calisiyor;

  /// Yan yana sutunlarda palet payi.
  static const double paletOrani = 0.42;

  /// Bundan genis tezgahta kategori seridi solda dikey (Scratch gibi).
  static const double dikeySeritEsigi = 560;

  @override
  State<KategoriliTezgah> createState() => KategoriliTezgahState();
}

/// Paletin olculeri: bolum baslarinin kaydirma ofsetleri.
class _PaletOlcumu {
  List<double> baslar = const [];
}

class KategoriliTezgahState extends State<KategoriliTezgah> {
  final ScrollController _paletK = ScrollController();
  final ScrollController _kodK = ScrollController();
  final ScrollController _kodYatayK = ScrollController();
  final ValueNotifier<int> _etkin = ValueNotifier<int>(0);
  final _PaletOlcumu _olcum = _PaletOlcumu();
  final GlobalKey _kodAlani = GlobalKey();

  bool _kodSekmesi = false;
  bool _atlaniyor = false;

  late List<ScratchKategori> _kategoriler;
  Widget? _liste;
  Object? _listeAnahtari;

  /// Etkin kategori (testler ve sahibi icin).
  ScratchKategori? get etkinKategori =>
      _kategoriler.isEmpty ? null : _kategoriler[_etkin.value];

  ScrollController get paletKaydirma => _paletK;
  ScrollController get kodKaydirma => _kodK;

  @override
  void initState() {
    super.initState();
    _kategoriler = _kategorileriBul(widget.ogeler);
    _paletK.addListener(_kaydirildi);
    _etkin.addListener(_seritteGoster);
  }

  /// Seritteki etkin kategori seridin gorunen yerinde kalsin (dar
  /// ekranda serit yana kayiyor).
  final Map<int, GlobalKey> _seritAnahtarlari = {};

  void _seritteGoster() {
    final c = _seritAnahtarlari[_etkin.value]?.currentContext;
    if (c == null) return;
    final ro = c.findRenderObject();
    final serit = Scrollable.maybeOf(c);
    if (ro == null || serit == null) return;
    // Yalnizca serit kaysin, sayfa degil.
    serit.position.ensureVisible(ro,
        alignment: 0.5,
        duration: Motion.reduced(context) ? Duration.zero : Motion.short4,
        curve: Motion.standard);
  }

  @override
  void didUpdateWidget(KategoriliTezgah oldWidget) {
    final old = oldWidget;
    super.didUpdateWidget(oldWidget);
    if (!identical(old.ogeler, widget.ogeler)) {
      _kategoriler = _kategorileriBul(widget.ogeler);
      if (_etkin.value >= _kategoriler.length) _etkin.value = 0;
    }
    if (widget.calisiyor && !old.calisiyor && !_kodSekmesi) {
      _kodSekmesi = true;
    }
    if (old.kodSurumu != widget.kodSurumu) {
      final buyudu = widget.kodSayisi > old.kodSayisi;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _imleceKaydir(sonaGit: buyudu));
    }
  }

  @override
  void dispose() {
    _paletK.removeListener(_kaydirildi);
    _etkin.removeListener(_seritteGoster);
    _paletK.dispose();
    _kodK.dispose();
    _kodYatayK.dispose();
    _etkin.dispose();
    super.dispose();
  }

  static List<ScratchKategori> _kategorileriBul(List<PaletOgesi> o) =>
      ScratchKategoriSeridi.sirala(o.map((e) => e.kategori));

  void _kaydirildi() {
    if (_atlaniyor || !_paletK.hasClients) return;
    final b = _olcum.baslar;
    if (b.isEmpty) return;
    final p = _paletK.position;
    var i = 0;
    for (var k = 0; k < b.length; k++) {
      if (b[k] <= p.pixels + 12) i = k;
    }
    // En dipte: son bolumler tepeye cikamiyor; ekranda olani sec.
    if (p.pixels >= p.maxScrollExtent - 1 && p.maxScrollExtent > 0) {
      for (var k = i + 1; k < b.length; k++) {
        if (b[k] < p.pixels + p.viewportDimension * 0.5) i = k;
      }
    }
    if (_etkin.value != i) _etkin.value = i;
  }

  /// Kategoriye dokunuldu: palet o bolume kayiyor.
  Future<void> kategoriyeGit(int i) async {
    if (i < 0 || i >= _kategoriler.length) return;
    _etkin.value = i;
    if (_kodSekmesi) setState(() => _kodSekmesi = false);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !_paletK.hasClients) return;
    final b = _olcum.baslar;
    if (i >= b.length) return;
    final p = _paletK.position;
    final hedef = b[i].clamp(0.0, p.maxScrollExtent);
    _atlaniyor = true;
    try {
      if (Motion.reduced(context)) {
        _paletK.jumpTo(hedef);
      } else {
        await _paletK.animateTo(hedef,
            duration: Motion.medium4, curve: Motion.emphasized);
      }
    } finally {
      _atlaniyor = false;
    }
  }

  /// Kod degisti: imlec (sari cizgi) kod alaninin gorunur yerinde
  /// kalsin; imlec yoksa ve kod buyuduyse en alta.
  void _imleceKaydir({required bool sonaGit}) {
    if (!mounted || !_kodK.hasClients) return;
    Element? bulunan;
    void ara(Element e) {
      if (bulunan != null) return;
      if (e.widget.key == const ValueKey('ic_ice_imlec')) {
        bulunan = e;
        return;
      }
      e.visitChildren(ara);
    }

    final kok = _kodAlani.currentContext as Element?;
    kok?.visitChildren(ara);
    final p = _kodK.position;
    final sure = Motion.reduced(context) ? Duration.zero : Motion.medium2;
    void git(double h) {
      final x = h.clamp(p.minScrollExtent, p.maxScrollExtent);
      if ((x - p.pixels).abs() < 1) return;
      if (sure == Duration.zero) {
        _kodK.jumpTo(x);
      } else {
        _kodK.animateTo(x, duration: sure, curve: Motion.standard);
      }
    }

    final ro = bulunan?.findRenderObject();
    if (ro is RenderBox && ro.attached) {
      final vp = RenderAbstractViewport.maybeOf(ro);
      if (vp == null) return;
      final ust = vp.getOffsetToReveal(ro, 0).offset;
      final alt = vp.getOffsetToReveal(ro, 1).offset;
      if (p.pixels > ust) {
        git(ust - 8);
      } else if (p.pixels < alt) {
        git(alt + 8);
      }
      return;
    }
    if (sonaGit) git(p.maxScrollExtent);
  }

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  @override
  Widget build(BuildContext context) {
    final h = widget.yukseklik ?? BlokTezgahiKarti.yukseklikFor(context);
    return Container(
      key: const ValueKey('kategorili_tezgah'),
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth;
        final olcek = BlokTezgahiKarti.olcekFor(w);
        final yaziOlcegi = MediaQuery.textScalerOf(context).scale(10) / 10;
        final tekSutun = w < 300 || (yaziOlcegi >= 1.2 && w < 340);
        final dikeySerit = !tekSutun && w >= KategoriliTezgah.dikeySeritEsigi;
        final seritVar = _kategoriler.length >= 2;

        final liste = _paletListesi(olcek);
        Widget paletBolumu() {
          final p = ColoredBox(
            color: BlokTezgahiKarti.paletRengi,
            child: SizedBox.expand(child: liste),
          );
          return widget.paletHedefi?.call(p) ?? p;
        }

        if (tekSutun) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sekmeler(),
              if (!_kodSekmesi && seritVar) _yatayKategoriSeridi(),
              Container(height: 1, color: BlokTezgahiKarti.ayracRengi),
              Expanded(
                child: _kodSekmesi
                    ? _kodBolumu(olcek, baslik: false)
                    : paletBolumu(),
              ),
            ],
          );
        }

        final pw = (w * (dikeySerit ? 0.34 : KategoriliTezgah.paletOrani))
            .clamp(118.0, 280.0);
        final govde = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (dikeySerit && seritVar) ...[
              _dikeyKategoriSeridi(),
              Container(width: 1, color: BlokTezgahiKarti.ayracRengi),
            ],
            SizedBox(width: pw, child: paletBolumu()),
            Container(width: 1, color: BlokTezgahiKarti.ayracRengi),
            Expanded(child: _kodBolumu(olcek)),
          ],
        );
        if (dikeySerit || !seritVar) return govde;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _yatayKategoriSeridi(),
            Container(height: 1, color: BlokTezgahiKarti.ayracRengi),
            Expanded(child: govde),
          ],
        );
      }),
    );
  }

  /// Palet listesi onbellekte: kod degisince yeniden kurulmuyor.
  Widget _paletListesi(double olcek) {
    final anahtar = Object.hash(identityHashCode(widget.ogeler), olcek,
        widget.lang, _kategoriler.length);
    if (_liste == null || _listeAnahtari != anahtar) {
      _listeAnahtari = anahtar;
      _liste = _PaletListesi(
        key: const ValueKey('palet_listesi'),
        ogeler: widget.ogeler,
        kategoriler: _kategoriler,
        olcek: olcek,
        lang: widget.lang,
        kaydirma: _paletK,
        olcum: _olcum,
        basliklar: _kategoriler.length >= 2,
      );
    }
    return _liste!;
  }

  Widget _kodBolumu(double olcek, {bool baslik = true}) {
    final icerik = LayoutBuilder(builder: (context, c) {
      const yan = 10.0;
      final genislik = math.max(40.0, c.maxWidth - 2 * yan);
      return Scrollbar(
        controller: _kodK,
        notificationPredicate: (n) => n.depth == 1,
        child: SingleChildScrollView(
          controller: _kodYatayK,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: c.maxWidth,
                maxHeight: c.maxHeight,
                minHeight: c.maxHeight),
            child: SingleChildScrollView(
              controller: _kodK,
              padding: EdgeInsets.fromLTRB(yan, baslik ? 2 : 10, yan, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: genislik),
                child: KeyedSubtree(
                  key: _kodAlani,
                  child: widget.kodIcerigi(context, olcek, genislik),
                ),
              ),
            ),
          ),
        ),
      );
    });
    final hedefli = widget.kodHedefi?.call(icerik) ?? icerik;
    return AnimatedContainer(
      duration: Motion.reduced(context) ? Duration.zero : Motion.short3,
      color: widget.kodVurgusu ?? Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (baslik)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: BlokTezgahiBasligi(_t(
                  'Kod alanı', 'Code area', 'Codebereich', 'Área de código')),
            ),
          Expanded(child: hedefli),
        ],
      ),
    );
  }

  /// Dar tezgah: "Bloklar | Kod" secici.
  Widget _sekmeler() {
    Widget sekme(bool kod, String ad, IconData ikon) {
      final secili = _kodSekmesi == kod;
      return Expanded(
        child: Semantics(
          button: true,
          selected: secili,
          child: InkWell(
            key: ValueKey(kod ? 'tezgah_sekme_kod' : 'tezgah_sekme_bloklar'),
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _kodSekmesi = kod),
            child: AnimatedContainer(
              duration: Motion.reduced(context) ? Duration.zero : Motion.short3,
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: secili ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: secili
                    ? [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2)),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(ikon,
                      size: 18,
                      color: secili
                          ? const Color(0xFF3D4A66)
                          : const Color(0xFF8A94A6)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      ad,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: secili
                            ? const Color(0xFF3D4A66)
                            : const Color(0xFF8A94A6),
                      ),
                    ),
                  ),
                  if (kod && widget.kodSayisi > 0) ...[
                    const SizedBox(width: 6),
                    _Rozet(sayi: widget.kodSayisi),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFE9EDF3),
      padding: const EdgeInsets.all(4),
      child: Row(children: [
        sekme(false, _t('Bloklar', 'Blocks', 'Blöcke', 'Bloques'),
            Icons.widgets_rounded),
        const SizedBox(width: 4),
        sekme(true, _t('Kod', 'Code', 'Code', 'Código'), Icons.code_rounded),
      ]),
    );
  }

  Widget _kategoriDugmesi(int i, {required bool dikey}) {
    final k = _kategoriler[i];
    return ValueListenableBuilder<int>(
      valueListenable: _etkin,
      builder: (context, etkin, _) {
        final secili = etkin == i;
        return Semantics(
          key: _seritAnahtarlari.putIfAbsent(i, GlobalKey.new),
          button: true,
          selected: secili,
          label: k.ad(widget.lang),
          excludeSemantics: true,
          child: InkWell(
            key: ValueKey('palet_kategori_${k.name}'),
            borderRadius: BorderRadius.circular(12),
            onTap: () => kategoriyeGit(i),
            child: AnimatedContainer(
              duration: Motion.reduced(context) ? Duration.zero : Motion.short3,
              width: dikey ? 64 : null,
              constraints:
                  BoxConstraints(minWidth: dikey ? 0 : 58, minHeight: 44),
              padding: EdgeInsets.symmetric(
                  horizontal: dikey ? 2 : 8, vertical: dikey ? 6 : 2),
              decoration: BoxDecoration(
                color: secili
                    ? k.renk.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration:
                        Motion.reduced(context) ? Duration.zero : Motion.short3,
                    width: secili ? 20 : 18,
                    height: secili ? 20 : 18,
                    decoration: BoxDecoration(
                      color: k.renk,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: secili ? Colors.white : k.renk3,
                          width: secili ? 2.5 : 1),
                      boxShadow: secili
                          ? [BoxShadow(color: k.renk3, spreadRadius: 1)]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      k.ad(widget.lang),
                      maxLines: 1,
                      textScaler: MediaQuery.textScalerOf(context)
                          .clamp(maxScaleFactor: 1.15),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        fontWeight: secili ? FontWeight.w900 : FontWeight.w700,
                        color: secili ? k.renk3 : const Color(0xFF575E75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _yatayKategoriSeridi() {
    return Container(
      key: const ValueKey('palet_kategori_seridi'),
      color: BlokTezgahiKarti.paletRengi,
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        itemCount: _kategoriler.length,
        separatorBuilder: (_, __) => const SizedBox(width: 2),
        itemBuilder: (context, i) => _kategoriDugmesi(i, dikey: false),
      ),
    );
  }

  Widget _dikeyKategoriSeridi() {
    return Container(
      key: const ValueKey('palet_kategori_seridi'),
      color: BlokTezgahiKarti.paletRengi,
      width: 72,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        itemCount: _kategoriler.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, i) => _kategoriDugmesi(i, dikey: true),
      ),
    );
  }
}

class _Rozet extends StatelessWidget {
  const _Rozet({required this.sayi});
  final int sayi;

  @override
  Widget build(BuildContext context) {
    final rozet = Container(
      key: const ValueKey('tezgah_kod_rozeti'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFFFAB19),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$sayi',
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.w900,
          fontSize: 11.5,
          color: Colors.white,
        ),
      ),
    );
    if (Motion.reduced(context)) return rozet;
    // Yeni blok eklenince rozet bir kez ziplar.
    return TweenAnimationBuilder<double>(
      key: ValueKey(sayi),
      tween: Tween(begin: 1.35, end: 1),
      duration: Motion.medium2,
      curve: Motion.overshoot,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: rozet,
    );
  }
}

/// Palet: kategori bolumleri (baslik + bloklar), tembel liste. Her
/// ogenin yuksekligi blok olcerinden hesaplaniyor; kategoriye atlamak
/// icin bolum baslari [olcum]a yaziliyor.
class _PaletListesi extends StatelessWidget {
  const _PaletListesi({
    super.key,
    required this.ogeler,
    required this.kategoriler,
    required this.olcek,
    required this.lang,
    required this.kaydirma,
    required this.olcum,
    required this.basliklar,
  });

  final List<PaletOgesi> ogeler;
  final List<ScratchKategori> kategoriler;
  final double olcek;
  final String lang;
  final ScrollController kaydirma;
  final _PaletOlcumu olcum;
  final bool basliklar;

  static const double _yan = 8;
  static const double _ust = 6;
  static const double _baslikBoyu = 28;
  static const double _ara = 6;

  /// Bundan cok satirli palet tembel listeyle kuruluyor.
  static const int tembelEsik = 40;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final sigma = math.max(40.0, c.maxWidth - 2 * _yan);
      final satirlar = <_Satir>[];
      final baslar = <double>[];
      var y = _ust;
      for (final k in kategoriler) {
        final bloklar = [
          for (final o in ogeler)
            if (o.kategori == k) o
        ];
        baslar.add(y - _ust);
        if (basliklar) {
          satirlar.add(_Satir.baslik(k, _baslikBoyu));
          y += _baslikBoyu;
        }
        for (final o in bloklar) {
          var s = olcek;
          final w = ScratchBlokOlcer.genislik(o.tanim, s);
          if (w > sigma) s = s * sigma / w * 0.995;
          final h = ScratchBlokOlcer.yukseklik(o.tanim, s) +
              ScratchBlokOlcer.tirnakPayi(s) +
              _ara;
          satirlar.add(_Satir.blok(o, s, h));
          y += h;
        }
      }
      // Kategorisi bilinmeyen blok yok (ogeler Scratch tanimli); yine
      // de liste bossa bir sey cizme.
      olcum.baslar = baslar;
      Widget satir(BuildContext context, int i) {
        final s = satirlar[i];
        if (s.oge == null) return _baslik(s.kategori!);
        return Align(
          alignment: Alignment.topLeft,
          child: s.oge!.builder(context, s.olcek),
        );
      }

      const dolgu = EdgeInsets.fromLTRB(_yan, _ust, _yan, 24);
      // Ders ve atolye paletleri kucuk (bir iki duzine blok): hepsi
      // kurulu duruyor — kaydirirken takilma yok, ekran okuyucu ve
      // testler ekran disindaki bloklari da buluyor. Buyuk palet
      // (serbest atolye gibi) tembel listeyle: yalnizca gorunen kurulur.
      if (satirlar.length <= tembelEsik) {
        return SingleChildScrollView(
          controller: kaydirma,
          padding: dolgu,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < satirlar.length; i++)
                SizedBox(
                  height: satirlar[i].yukseklik,
                  child: Builder(builder: (context) => satir(context, i)),
                ),
            ],
          ),
        );
      }
      return ListView.builder(
        controller: kaydirma,
        padding: dolgu,
        itemCount: satirlar.length,
        itemExtentBuilder: (i, _) =>
            i < satirlar.length ? satirlar[i].yukseklik : null,
        itemBuilder: satir,
      );
    });
  }

  Widget _baslik(ScratchKategori k) => Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: k.renk, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                k.ad(lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                  color: k.renk3,
                ),
              ),
            ),
          ],
        ),
      );
}

class _Satir {
  _Satir.baslik(ScratchKategori this.kategori, this.yukseklik)
      : oge = null,
        olcek = 0;
  _Satir.blok(PaletOgesi this.oge, this.olcek, this.yukseklik)
      : kategori = null;

  final ScratchKategori? kategori;
  final PaletOgesi? oge;
  final double olcek;
  final double yukseklik;
}
