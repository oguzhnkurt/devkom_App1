import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../models/interactive_lesson_model.dart';
import '../../yurutme/blok_anlami.dart';
import '../../yurutme/blok_sozlugu.dart';
import '../../yurutme/blok_yorumlayici.dart';
import '../../yurutme/konusma_metni.dart';
import '../../yurutme/scratch_blok_katalogu.dart';
import 'step_widgets.dart' show lessonText;

/// Kodun ne YAPTIGINI satir satir gosteren iz.
///
/// NEDEN
///
/// Blok kurma adiminda "KODU CALISTIR" tusu yalnizca DOGRU cevap
/// bulunduktan sonra beliriyordu. Yani cocuk kendi yanlis kodunu
/// calistirip ne yaptigini hic goremiyordu — ogrenmenin tam tersi.
/// Kodu calistirmak bir odul degil, ogrenme aracidir: yanlis kod da
/// calisir ve yanlis sonuc verir, ogretici olan da budur.
///
/// Iz, tahmin degil GERCEK yurutmeden geliyor (bkz. BlokYorumlayici):
/// dongu turlari sayiliyor, degisken degerleri tutuluyor. Bir dongunun
/// dordüncü turunu gormek, "4 defa tekrarla"nin ne demek oldugunu bir
/// cumleden daha iyi anlatiyor.
///
/// EKRANA SIGMA: iz kendi icinde kaydiriliyor ve yuksekligi sinirli.
/// Sonsuz dongu yuzlerce satir uretebilir; o satirlar sayfayi asagi
/// dogru uzatsaydi cocuk kod alanini kaybederdi.
class CalismaIzi extends StatelessWidget {
  const CalismaIzi({
    super.key,
    required this.bloklar,
    required this.lang,
    this.enFazlaYukseklik = 220,
    this.yurutme,
    this.scratch = false,
    this.katlanabilir = false,
  });

  /// Baslik dokununca iz kapanip aciliyor (Scratch ders adiminda sahne
  /// asil gorunum; iz isteyene). Acik baslar.
  final bool katlanabilir;

  final List<ScratchBlock> bloklar;

  /// Scratch kursu: satirlar Scratch'in resmi blok yazisiyla ve blogun
  /// kategori rengiyle (kod alanindaki blokla ayni yazi).
  final bool scratch;

  /// Sahneyle ayni yurutme. Verilirse iz onu gosteriyor; boylece sahnede
  /// "4" diyen zarla izdeki zar ayni sayi oluyor (ikisi ayri ayri
  /// calistirildiginda rastgele blok iki farkli sayi soyluyordu).
  final Yurutme? yurutme;
  final String lang;
  final double enFazlaYukseklik;

  @override
  Widget build(BuildContext context) {
    final sonuc = yurutme ?? BlokYorumlayici(dil: lang).yurut(bloklar);

    final baslik = Row(
      children: [
        const Icon(Icons.play_circle_outline,
            size: 18, color: Color(0xFF9AA4B2)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            lessonText(lang, 'Kodun ne yaptı', 'What your code did',
                'Was dein Code gemacht hat', 'Lo que hizo tu código'),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Color(0xFF9AA4B2),
            ),
          ),
        ),
      ],
    );
    final govde = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: enFazlaYukseklik),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final adim in sonuc.adimlar) _satir(adim),
              ],
            ),
          ),
        ),
        if (sonuc.butceBitti) ...[
          const SizedBox(height: 8),
          Text(
            // Sonsuz dongu bir hata degil; cocuk bilerek de yazmis
            // olabilir. Ekran "bitti" diye yalan soylemiyor.
            lessonText(
                lang,
                '… kod durmuyor. "Sürekli tekrarla" hiç bitmez — burada biz durdurduk.',
                '… the code does not stop. "forever" never ends — we stopped it here.',
                '… der Code hört nicht auf. "wiederhole fortlaufend" endet nie — wir haben hier gestoppt.',
                '… el código no para. "por siempre" nunca termina — lo hemos detenido aquí.'),
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFFFFB86C),
            ),
          ),
        ],
        const SizedBox(height: 10),
        _sonucSeridi(sonuc),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: katlanabilir
          ? _Katlanir(baslik: baslik, govde: govde, lang: lang)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [baslik, govde],
            ),
    );
  }

  Widget _satir(YurutmeAdimi adim) {
    // Kendi blogunun govdesi kod alaninda olmayabilir (bkz.
    // BlokYorumlayici.kutuphane): satir calisan asil blogu yaziyor.
    final blok = adim.blok ??
        (adim.blokSirasi >= 0 && adim.blokSirasi < bloklar.length
            ? bloklar[adim.blokSirasi]
            : bloklar.firstWhere(
                (b) => b.id == adim.blokId,
                orElse: () => bloklar.first,
              ));
    final sb = scratch ? ScratchBlokKatalogu.tanim(blok.id, lang) : null;
    return Padding(
      padding: EdgeInsets.only(left: adim.derinlik * 14.0, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sb != null)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4.5, right: 6),
              decoration: BoxDecoration(
                color:
                    sb.kategori.renk.withValues(alpha: adim.etkisiz ? 0.45 : 1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Text(
            '▸ ',
            style: TextStyle(
              color: adim.etkisiz
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF7ED321),
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              sb?.duzMetin ?? blok.labelFor(lang),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.35,
                color: adim.etkisiz
                    ? const Color(0xFF8A94A6)
                    : const Color(0xFFD4D4D4),
              ),
            ),
          ),
          if (adim.kosulSonucu != null) ...[
            const SizedBox(width: 6),
            Text(
              // Olculen kosul: cocuk govdenin NEDEN calismadigini
              // (ya da calistigini) goruyor.
              adim.kosulSonucu!
                  ? lessonText(lang, '→ doğru', '→ true', '→ wahr',
                      '→ verdadero')
                  : lessonText(lang, '→ yanlış', '→ false', '→ falsch',
                      '→ falso'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: adim.kosulSonucu!
                    ? const Color(0xFF7ED321)
                    : const Color(0xFFFF8A80),
              ),
            ),
          ],
          if (adim.tekrarNo != null) ...[
            const SizedBox(width: 6),
            Text(
              // Bir dongunun gercekten dondugunu gostermenin en
              // dogrudan yolu: kacinci tur oldugunu yazmak.
              lessonText(lang, '${adim.tekrarNo}. tur', 'turn ${adim.tekrarNo}',
                  '${adim.tekrarNo}. Runde', 'vuelta ${adim.tekrarNo}'),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFFFBF00),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Son soylenen metin, cocugun dilinde.
  ///
  /// Sozlukteki metin Turkce; sabit metinli bloklarda (rastgele sayi
  /// soylemeyenlerde) metin blogun kendi etiketinden aliniyor.
  String _soyledigi(Yurutme sonuc) {
    for (final adim in sonuc.adimlar.reversed) {
      final anlam = blokSozlugu[adim.blokId];
      if (anlam == null || anlam.komut != BlokKomutu.soyle) continue;
      if (anlam.rastgeleAlt != null) break; // sayi: dile bagli degil
      if (anlam.listeRastgele != null) break; // oge zaten cocugun dilinde
      for (final b in bloklar) {
        if (b.id == adim.blokId) return konusmaMetni(b, lang);
      }
      break;
    }
    return sonuc.sonSahne.soyledigi!;
  }

  Widget _sonucSeridi(Yurutme sonuc) {
    final parcalar = <String>[];
    sonuc.sonSahne.degiskenler.forEach((ad, deger) {
      parcalar.add('$ad: ${deger % 1 == 0 ? deger.toInt() : deger}');
    });
    if (sonuc.sonSahne.x != 0 || sonuc.sonSahne.y != 0) {
      parcalar.add('x: ${sonuc.sonSahne.x.toInt()}');
      parcalar.add('y: ${sonuc.sonSahne.y.toInt()}');
    }
    if (sonuc.sonSahne.soyledigi != null) {
      parcalar.add('"${_soyledigi(sonuc)}"');
    }
    if (sonuc.sonSahne.kostum != 1) {
      parcalar.add(
          '${lessonText(lang, 'kostüm', 'costume', 'Kostüm', 'disfraz')}: ${sonuc.sonSahne.kostum}');
    }
    if (sonuc.sonSahne.yon != 90) {
      parcalar.add(
          '${lessonText(lang, 'yön', 'direction', 'Richtung', 'dirección')}: ${sonuc.sonSahne.yon.toInt()}°');
    }
    if (sonuc.sonSahne.kalemInik) {
      parcalar.add(lessonText(
          lang, 'kalem inik', 'pen down', 'Stift unten', 'lápiz abajo'));
    }
    sonuc.sonSahne.listeler.forEach((ad, icerik) {
      parcalar.add('$ad: [${icerik.join(', ')}]');
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        parcalar.isEmpty && sonuc.yalnizTanim
            // 11.1: kod alaninda yalnizca kendi blogunun TANIMI var.
            ? lessonText(
                lang,
                'Tanım tek başına çalışmaz: bayrağa basınca hiçbir şey olmadı. Onu bir çağrı bloğu çalıştırır.',
                'A definition does not run on its own: nothing happened when the flag was clicked. A call block runs it.',
                'Eine Definition läuft nicht von selbst: Beim Klick auf die Flagge passierte nichts. Ein Aufruf-Block führt sie aus.',
                'Una definición no se ejecuta sola: al pulsar la bandera no pasó nada. La ejecuta un bloque de llamada.')
            : parcalar.isEmpty
            // "Sahnede degisen bir sey olmadi" bir HATA gibi
            // okunuyordu — oysa cogu zaman dogru olan buydu: bloklar
            // sirayla calisti ama gorunur bir iz birakmadi. Cumle artik
            // once ne OLDUGUNU soyluyor.
            ? lessonText(
                lang,
                'Bloklar sırayla çalıştı; sahnede görünür bir iz bırakmadılar.',
                'The blocks ran in order; they left no visible mark on the stage.',
                'Die Blöcke liefen der Reihe nach; auf der Bühne blieb nichts sichtbar.',
                'Los bloques se ejecutaron en orden; no dejaron marca visible en el escenario.')
            : parcalar.join('   ·   '),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12.5,
          color: Color(0xFF7ED321),
        ),
      ),
    );
  }
}

/// Basligina dokununca govdesi kapanip acilan iz.
class _Katlanir extends StatefulWidget {
  const _Katlanir(
      {required this.baslik, required this.govde, required this.lang});
  final Widget baslik;
  final Widget govde;
  final String lang;

  @override
  State<_Katlanir> createState() => _KatlanirState();
}

class _KatlanirState extends State<_Katlanir> {
  bool _acik = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _acik,
          child: InkWell(
            key: const ValueKey('iz_ac_kapa'),
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _acik = !_acik),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: widget.baslik),
                  Icon(
                    _acik
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF9AA4B2),
                    semanticLabel: _acik
                        ? lessonText(widget.lang, 'Gizle', 'Hide', 'Ausblenden',
                            'Ocultar')
                        : lessonText(widget.lang, 'Göster', 'Show', 'Anzeigen',
                            'Mostrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_acik) widget.govde,
      ],
    );
  }
}
