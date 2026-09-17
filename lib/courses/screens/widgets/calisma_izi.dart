import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../models/interactive_lesson_model.dart';
import '../../yurutme/blok_yorumlayici.dart';
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
  });

  final List<ScratchBlock> bloklar;
  final String lang;
  final double enFazlaYukseklik;

  @override
  Widget build(BuildContext context) {
    const yorumlayici = BlokYorumlayici();
    final sonuc = yorumlayici.yurut(bloklar);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle_outline,
                  size: 18, color: Color(0xFF9AA4B2)),
              const SizedBox(width: 8),
              Text(
                lessonText(lang, 'Kodun ne yaptı', 'What your code did',
                    'Was dein Code gemacht hat', 'Lo que hizo tu código'),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFF9AA4B2),
                ),
              ),
            ],
          ),
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
      ),
    );
  }

  Widget _satir(YurutmeAdimi adim) {
    final blok = bloklar.firstWhere(
      (b) => b.id == adim.blokId,
      orElse: () => bloklar.first,
    );
    return Padding(
      padding: EdgeInsets.only(left: adim.derinlik * 14.0, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              blok.labelFor(lang),
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
      parcalar.add('"${sonuc.sonSahne.soyledigi}"');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        parcalar.isEmpty
            ? lessonText(
                lang,
                'Sahnede değişen bir şey olmadı.',
                'Nothing on the stage changed.',
                'Auf der Bühne hat sich nichts geändert.',
                'Nada cambió en el escenario.')
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
