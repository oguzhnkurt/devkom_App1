import 'package:flutter/material.dart';

import '../models/game_model.dart';
import '../theme.dart';
import '../utils/lang.dart';
import '../utils/pro_gate.dart';
import 'oyun_kimligi.dart';
import 'oyun_sahnesi.dart';

/// Pro oyununa dokununca acilan bilgi sayfasi.
///
/// Kartlarda tac vardi; cocuk tacin ne demek oldugunu anlamiyor, kilitli
/// oyuna dokununca da uzun bir Pro listesiyle karsilasiyordu (Ekim 2026
/// geri bildirimi). Simdi sayfa oyunun KENDI kapagiyla aciliyor ve tek
/// bir seyi acikca soyluyor: bu oyun Pro'da; kisa bir video izlersen bir
/// tur ucretsiz oynarsin. Iki buyuk dugme, alti kisa bir not.
///
/// Reklam yoksa (gunluk sinir dolu, platform desteklemiyor) reklam
/// dugmesi cizilmiyor ve not bunu soyluyor — basinca hicbir sey olmayan
/// bir dugme gostermiyoruz.
class OyunBilgiSayfasi extends StatelessWidget {
  const OyunBilgiSayfasi({
    super.key,
    required this.game,
    required this.lang,
    required this.reklamVar,
    required this.kategori,
  });

  final GameModel game;
  final String lang;
  final bool reklamVar;

  /// Oyunun kategorisinin adi (etiket olarak).
  final String kategori;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

  @override
  Widget build(BuildContext context) {
    final renk = OyunKimligi.renk(game.type);
    final koyu = Color.lerp(renk, const Color(0xFF14102B), 0.35)!;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  OyunSahnesi(tur: game.type, lang: lang),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [renk.withValues(alpha: 0), renk],
                        stops: const [0.45, 1],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 14,
                    child: Text(
                      game.titleFor(lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 30,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _etiket(oyunZorlukEtiketi(game, lang), renk),
                      _etiket(kategori, renk),
                      _etiket(_t('Pro oyunu', 'Pro game', 'Pro-Spiel', 'Juego Pro'), renk),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${oyunDaveti(game.type, lang)} ${_t(
                      'Bu oyun Pro üyelikte. İstersen kısa bir video izleyip bir tur ücretsiz oynayabilirsin.',
                      'This game is part of Pro. You can watch a short video to play one round for free.',
                      'Dieses Spiel gehört zu Pro. Schau ein kurzes Video und spiel eine Runde gratis.',
                      'Este juego es de Pro. Puedes ver un vídeo corto y jugar una ronda gratis.',
                    )}',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A4560),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (reklamVar) ...[
                    _dugme(
                      context,
                      metin: _t('Reklam izle, ücretsiz oyna', 'Watch an ad, play free',
                          'Werbung ansehen, gratis spielen', 'Ver anuncio y jugar gratis'),
                      simge: Icons.play_arrow_rounded,
                      zemin: renk,
                      yazi: Colors.white,
                      govde: koyu,
                      secim: ProSecim.reklam,
                    ),
                    const SizedBox(height: 10),
                  ],
                  _dugme(
                    context,
                    metin: _t('Pro ile sınırsız oyna', 'Play unlimited with Pro',
                        'Unbegrenzt spielen mit Pro', 'Juega sin límites con Pro'),
                    simge: Icons.star_rounded,
                    zemin: const Color(0xFFF3EFFF),
                    yazi: const Color(0xFF5E35B1),
                    govde: const Color(0xFFD1C4E9),
                    secim: ProSecim.pro,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    reklamVar
                        ? _t('Kısa bir video izlenir · 1 tur açılır',
                            'A short video plays · unlocks 1 round',
                            'Ein kurzes Video · schaltet 1 Runde frei',
                            'Un vídeo corto · desbloquea 1 ronda')
                        : _t('Şu an izlenecek video yok. Daha sonra yeniden dene.',
                            'No video available right now. Try again later.',
                            'Gerade ist kein Video verfügbar. Versuch es später.',
                            'Ahora no hay vídeo disponible. Inténtalo más tarde.'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A85A0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etiket(String yazi, Color renk) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: renk.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          yazi,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: Color.lerp(renk, Colors.black, 0.2),
          ),
        ),
      );

  Widget _dugme(
    BuildContext context, {
    required String metin,
    required IconData simge,
    required Color zemin,
    required Color yazi,
    required Color govde,
    required ProSecim secim,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, secim),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: zemin,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: govde, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(simge, color: yazi, size: 26),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                metin,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: yazi,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
