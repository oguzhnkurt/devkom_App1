import 'dart:math';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../../utils/lang.dart';
import '../../../widgets/scratch_blok.dart';
import '../../models/interactive_lesson_model.dart';
import '../../yurutme/blok_anlami.dart';
import '../../yurutme/blok_yorumlayici.dart';
import '../../yurutme/kod_yapisi.dart';
import '../../yurutme/scratch_blok_katalogu.dart';

/// Suruklenen blok: paletten (kaynak null) ya da kod alanindan.
class IcIceTasima {
  const IcIceTasima(this.blok, {this.kaynak});
  final ScratchBlock blok;
  final int? kaynak;
}

/// IC ICE KOD ALANI — Scratch 3'teki gibi C blogu icindekileri SARAR.
///
/// Eski kod alaninda C blogu kendisinden sonraki her seyi agzina
/// aliyordu. Burada her C blogunun kendi agzi ve ayagi var:
///
///  * agza (ya da agizdaki bir blogun ustune) birakilan blok ICERI,
///  * ayagin altina birakilan blok donguden SONRA,
///  * sari cizgi (imlec) paletten dokununca blogun nereye gidecegini
///    gosteriyor. C bloguna dokununca imlec agzinin icine, ayagina
///    dokununca altina, bir bloga dokununca o blogun altina geciyor.
///  * blogun sagindaki "x" blogu cikarir; beyaz sayi ovaline dokunmak
///    (duzenlenebilir bloklarda) sayi tus takimini acar.
///
/// Birden fazla sapka varsa (atolye) her sapka yeni bir betik baslatir
/// ve betikler arasinda bosluk birakilir — Scratch'teki ayri yiginlar
/// gibi.
class IcIceKodAlani extends StatelessWidget {
  const IcIceKodAlani({
    super.key,
    required this.kod,
    required this.palet,
    required this.lang,
    required this.imlec,
    required this.onImlec,
    required this.onSil,
    required this.onBirak,
    this.onSayi,
    this.duzenlenebilir = const {},
    this.calisanSira,
    this.ekleSira,
    this.onEkleSira,
    this.saltOkunur = false,
  });

  final List<KodOgesi> kod;
  final List<ScratchBlock> palet;
  final String lang;
  final int imlec;
  final ValueChanged<int> onImlec;
  final ValueChanged<int> onSil;
  final void Function(IcIceTasima t, int hedef) onBirak;
  final ValueChanged<int>? onSayi;
  final Set<String> duzenlenebilir;
  final ValueListenable<int?>? calisanSira;

  /// Surukleme sirasinda uzerinde durulan hedef (vurgulaniyor).
  final int? ekleSira;
  final ValueChanged<int?>? onEkleSira;

  /// Yalnizca gosterim (hazir kodlu kuklanin kodu): bloklarda "x" yok.
  final bool saltOkunur;

  bool _cMi(String id) =>
      palet.any((b) => b.id == id && b.shape == ScratchBlockShape.cBlock);

  bool _sapkaMi(String id) {
    final b = palet.where((b) => b.id == id).firstOrNull;
    if (b == null) return false;
    final a = BlokYorumlayici.anlamOf(b);
    return a.komut == BlokKomutu.baslat || a.komut == BlokKomutu.tanimla;
  }

  ScratchBlock? _blok(int i) {
    final id = kod[i].id;
    for (final b in palet) {
      if (b.id == id) return b;
    }
    return null;
  }

  ScratchBlokTanimi? _tanim(int i) =>
      ScratchBlokKatalogu.tanimDegerli(kod[i].id, lang, kod[i].deger);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final girinti = KodYapisi.girintiler(kod, _cMi);
      double genislik(double s) {
        var m = 0.0;
        for (var i = 0; i < kod.length; i++) {
          if (KodYapisi.isaretMi(kod[i].id)) continue;
          final t = _tanim(i);
          if (t == null) continue;
          final w = ScratchBlokOlcer.genislik(t, s,
              parca: t.cMi ? ScratchCParcasi.ust : ScratchCParcasi.tamami,
              silme: !saltOkunur);
          m = max(m, girinti[i] * ScratchBlokOlcer.kolGenisligi(s) + w);
        }
        return m;
      }

      var s = ScratchBlok.varsayilanOlcek;
      final w = genislik(s);
      if (c.maxWidth.isFinite && w > c.maxWidth) {
        s = s * c.maxWidth / w * 0.99;
      }
      return Padding(
        padding: EdgeInsets.only(bottom: ScratchBlokOlcer.tirnakPayi(s)),
        child: _dizi(context, 0, kod.length, 0, s),
      );
    });
  }

  /// Sari imlec cizgisi: paletten dokunulan blok buraya girecek.
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

  Widget _hedef(int hedef, Widget child) => DragTarget<IcIceTasima>(
        onWillAcceptWithDetails: (_) {
          if (ekleSira != hedef) onEkleSira?.call(hedef);
          return true;
        },
        onLeave: (_) {
          if (ekleSira == hedef) onEkleSira?.call(null);
        },
        onAcceptWithDetails: (d) => onBirak(d.data, hedef),
        builder: (context, a, r) => child,
      );

  Widget _dizi(BuildContext context, int bas, int bitis, int derinlik,
      double s) {
    final ogeler = <Widget>[];
    var i = bas;
    while (i < bitis) {
      if (imlec == i) ogeler.add(_imlecCizgisi(s));
      final o = kod[i];
      if (KodYapisi.isaretMi(o.id)) {
        i++;
        continue;
      }
      // Yeni betik: sapkadan once bosluk.
      if (derinlik == 0 && i > bas && _sapkaMi(o.id)) {
        ogeler.add(SizedBox(height: 18 * s));
      }
      final t = _tanim(i);
      if (t == null) {
        i++;
        continue;
      }
      if (_cMi(o.id)) {
        final son = KodYapisi.kapanis(kod, i, _cMi);
        final dg = KodYapisi.degilse(kod, i, _cMi);
        final ustBitis = dg >= 0 ? dg : son;
        ogeler.add(_yerlesik(context, i, t, s, ScratchCParcasi.ust));
        ogeler.add(ScratchCSirti(
          kategori: t.kategori,
          olcek: s,
          child: _agiz(context, i + 1, ustBitis, derinlik + 1, s),
        ));
        if (dg >= 0) {
          ogeler.add(GestureDetector(
            onTap: () => onImlec(dg + 1),
            child: ScratchBlok(
              tanim: t,
              olcek: s,
              sigdir: false,
              parca: ScratchCParcasi.orta,
              icDolu: dg > i + 1,
            ),
          ));
          ogeler.add(ScratchCSirti(
            kategori: t.kategori,
            olcek: s,
            child: _agiz(context, dg + 1, son, derinlik + 1, s),
          ));
        }
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
              icDolu: (dg >= 0 ? son > dg + 1 : son > i + 1),
            ),
          ),
        ));
        i = sonrasi;
        continue;
      }
      ogeler.add(_yerlesik(context, i, t, s, ScratchCParcasi.tamami));
      i++;
    }
    if (imlec == bitis && (derinlik == 0 || bitis > bas)) {
      ogeler.add(_imlecCizgisi(s));
    }
    // Agzin sonuna birakmak icin ince bir hedef.
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

  /// C blogunun agzi: doluysa icindekiler, bossa birakma yeri.
  Widget _agiz(BuildContext context, int bas, int bitis, int derinlik,
      double s) {
    if (bitis > bas) return _dizi(context, bas, bitis, derinlik, s);
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

  Widget _yerlesik(BuildContext context, int i, ScratchBlokTanimi t,
      double s, ScratchCParcasi parca) {
    final blok = _blok(i)!;
    final duzenle = onSayi != null && duzenlenebilir.contains(blok.id);
    final girdi = duzenle ? ScratchBlokOlcer.ilkGirdi(t, s, silme: !saltOkunur) : null;
    final genislik = ScratchBlokOlcer.genislik(t, s, parca: parca, silme: !saltOkunur);
    final ekleme = ekleSira == i;

    Widget gorunum(bool calisiyor) => ScratchBlok(
          tanim: t,
          olcek: s,
          sigdir: false,
          silme: !saltOkunur,
          parca: parca,
          kimlik: blok.id,
          vurgu: calisiyor
              ? ScratchBlok.calisanRengi
              : ekleme
                  ? Colors.white
                  : null,
        );

    Widget katman(bool calisiyor) => Stack(
          clipBehavior: Clip.none,
          children: [
            gorunum(calisiyor),
            // Duzenlenebilir sayi: ovalin cevresinde ince bir halka.
            if (girdi != null)
              Positioned.fromRect(
                rect: girdi.inflate(2),
                child: IgnorePointer(
                  child: Container(
                    key: ValueKey('ic_ice_sayi_$i'),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(girdi.height),
                      border: Border.all(
                          color: const Color(0xFFFFB800), width: 2),
                    ),
                  ),
                ),
              ),
          ],
        );

    final dokunma = GestureDetector(
      key: ValueKey('ic_ice_blok_$i'),
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) {
        final p = d.localPosition;
        if (p.dx > genislik - 28 * s) {
          onSil(i);
        } else if (girdi != null && girdi.inflate(8).contains(p)) {
          onSayi!(i);
        } else {
          onImlec(i + 1);
        }
      },
      child: calisanSira == null
          ? katman(false)
          : ValueListenableBuilder<int?>(
              valueListenable: calisanSira!,
              builder: (context, calisan, _) => Semantics(
                selected: calisan == i,
                child: katman(calisan == i),
              ),
            ),
    );

    return _hedef(
      i,
      LongPressDraggable<IcIceTasima>(
        data: IcIceTasima(blok, kaynak: i),
        delay: const Duration(milliseconds: 150),
        hapticFeedbackOnStart: true,
        feedback: Material(
          color: Colors.transparent,
          child: ScratchBlok(
              tanim: t, olcek: s, sigdir: false, parca: ScratchCParcasi.bas),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: gorunum(false)),
        child: dokunma,
      ),
    );
  }
}

/// Atolyenin ve ic ice adimin paleti: kategori seridi ve bloklar.
/// Dokun = imlecin yerine ekle; basili tut + surukle = istenen yere.
class IcIcePalet extends StatelessWidget {
  const IcIcePalet({
    super.key,
    required this.palet,
    required this.lang,
    required this.onEkle,
    required this.onKodDanCikar,
  });

  final List<ScratchBlock> palet;
  final String lang;
  final ValueChanged<ScratchBlock> onEkle;
  final ValueChanged<int> onKodDanCikar;

  @override
  Widget build(BuildContext context) {
    final kategoriler = ScratchKategoriSeridi.sirala([
      for (final b in palet)
        if (ScratchBlokKatalogu.tanim(b.id, lang) case final t?) t.kategori,
    ]);
    return DragTarget<IcIceTasima>(
      onWillAcceptWithDetails: (d) => d.data.kaynak != null,
      onAcceptWithDetails: (d) => onKodDanCikar(d.data.kaynak!),
      builder: (context, a, r) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (kategoriler.length >= 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ScratchKategoriSeridi(
                  kategoriler: kategoriler, lang: lang, koyu: false),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final b in palet)
                if (ScratchBlokKatalogu.tanim(b.id, lang) case final t?)
                  LongPressDraggable<IcIceTasima>(
                    data: IcIceTasima(b),
                    delay: const Duration(milliseconds: 150),
                    hapticFeedbackOnStart: true,
                    feedback: Material(
                      color: Colors.transparent,
                      child: ScratchBlok(tanim: t, sigdir: false),
                    ),
                    childWhenDragging: Opacity(
                        opacity: 0.4, child: ScratchBlok(tanim: t)),
                    child: GestureDetector(
                      key: ValueKey('palet_${b.id}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onEkle(b),
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: ScratchBlokOlcer.tirnakPayi(
                                ScratchBlok.varsayilanOlcek)),
                        child: ScratchBlok(tanim: t, kimlik: b.id),
                      ),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ornek cozumun okunur hali (ipucu): her satir bir blok, girintili.
List<String> cozumSatirlari(
    String belirtecler, List<ScratchBlock> palet, String lang) {
  final kod = KodYapisi.coz(belirtecler);
  bool cMi(String id) =>
      palet.any((b) => b.id == id && b.shape == ScratchBlockShape.cBlock);
  final girinti = KodYapisi.girintiler(kod, cMi);
  final satirlar = <String>[];
  for (var i = 0; i < kod.length; i++) {
    final o = kod[i];
    if (o.id == KodYapisi.sonId) continue;
    final pay = '    ' * girinti[i];
    if (o.id == KodYapisi.degilseId) {
      satirlar.add('$pay${ScratchBlokKatalogu.etiket('CONTROL_ELSE', lang)}');
      continue;
    }
    final t = ScratchBlokKatalogu.tanimDegerli(o.id, lang, o.deger);
    satirlar.add('$pay${t?.duzMetin ?? o.id}');
  }
  return satirlar;
}
