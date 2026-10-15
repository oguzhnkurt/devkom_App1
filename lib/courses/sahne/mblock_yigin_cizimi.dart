import 'package:flutter/material.dart';

import '../../theme.dart';
import '../yurutme/mblock_blok_adlari.dart';
import '../yurutme/mblock_cozum.dart';

/// Bir mBlock yiginin SALT OKUNUR cizimi: bloklar kendi kategori
/// renginde, C bloklarinin ici girintili ve kollu.
///
/// Tezgahin (WebView) yerine gecmiyor; tezgahin olmadigi yerlerde bir
/// programi GOSTERMEK icin: "Cozumu goster" karti, tezgahsiz test ve
/// onizleme ekranlari.
class MBlockYiginCizimi extends StatelessWidget {
  const MBlockYiginCizimi({
    super.key,
    required this.bloklar,
    required this.lang,
    this.olcek = 1,
  });

  final List<MBlockBlok> bloklar;
  final String lang;
  final double olcek;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [for (final b in bloklar) _blok(b)],
    );
  }

  Widget _blok(MBlockBlok b) {
    final t = mblockBlokTanimlari[b.tip];
    final renk = t?.renk ?? const Color(0xFF888888);
    final koyu = Color.alphaBlend(Colors.black.withValues(alpha: 0.18), renk);
    final s = olcek;
    final yazi = Text(
      mblockBlokYazisi(b, lang),
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 13 * s,
        fontWeight: FontWeight.w800,
        color: t?.kategori == 'olaylar' || t?.kategori == 'seriPort'
            ? const Color(0xFF3A2A00)
            : Colors.white,
      ),
    );
    final sapka = t?.sapkaMi ?? false;
    final ust = Container(
      padding: EdgeInsets.fromLTRB(10 * s, (sapka ? 12 : 7) * s, 12 * s, 7 * s),
      decoration: BoxDecoration(
        color: renk,
        border: Border.all(color: koyu, width: 1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular((sapka ? 16 : 5) * s),
          topRight: Radius.circular((sapka ? 16 : 5) * s),
          bottomLeft: Radius.circular((t?.cMi ?? false) ? 0 : 5 * s),
          bottomRight: Radius.circular(5 * s),
        ),
      ),
      child: yazi,
    );
    if (!(t?.cMi ?? false)) {
      return Padding(padding: EdgeInsets.only(bottom: 2 * s), child: ust);
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 2 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ust,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 14 * s, color: renk),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 3 * s),
                  child: b.icerik.isEmpty
                      ? SizedBox(height: 18 * s, width: 40 * s)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [for (final i in b.icerik) _blok(i)],
                        ),
                ),
              ],
            ),
          ),
          Container(
            width: 64 * s,
            height: 14 * s,
            decoration: BoxDecoration(
              color: renk,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5 * s),
                bottomRight: Radius.circular(5 * s),
                topRight: Radius.circular(5 * s),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
