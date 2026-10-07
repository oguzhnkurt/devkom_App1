import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_model.dart';
import '../screens/robotics_games_screen.dart' show ProGames;
import '../services/embedded_games_service.dart';
import '../theme.dart';
import '../utils/lang.dart';
import 'oyun_kimligi.dart';
import 'oyun_sahnesi.dart';

/// "Surpriz oyun" sandigi (ana sayfa, ilk acilis).
///
/// Cocuk "bugun ne oynasam?" diye listeye bakmak yerine sandiga dokunuyor:
/// sandik sallaniyor, oyunlarin canli kapaklari slot makinesi gibi hizla
/// donup yavaslıyor ve bir oyunda duruyor. "Oyna" o oyunu aciyor,
/// "Tekrar" yeniden karistiriyor.
///
/// Yalnizca UCRETSIZ oyunlar cikiyor: surprizin sonu bir kilit olursa
/// odul degil hayal kirikligi olur.
///
/// Hareketi azalt aciksa karistirma animasyonu yok; oyun dogrudan secilir.
class SurprizSandik extends StatefulWidget {
  const SurprizSandik({super.key, required this.lang, required this.onOyna});

  final String lang;
  final ValueChanged<GameModel> onOyna;

  @override
  State<SurprizSandik> createState() => _SurprizSandikState();
}

enum _Durum { kapali, karisiyor, acik }

class _SurprizSandikState extends State<SurprizSandik>
    with SingleTickerProviderStateMixin {
  final _r = math.Random();
  late final List<GameModel> _oyunlar = EmbeddedGamesService.getAllEmbeddedGames()
      .where((g) => !ProGames.isProGame(g.type))
      .toList();

  late final AnimationController _salla = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));

  _Durum _durum = _Durum.kapali;
  int _gosterilen = 0;
  GameModel? _secilen;
  Timer? _zamanlayici;

  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(widget.lang, tr: tr, en: en, de: de, es: es);

  @override
  void dispose() {
    _zamanlayici?.cancel();
    _salla.dispose();
    super.dispose();
  }

  Future<void> _karistir() async {
    if (_oyunlar.isEmpty || _durum == _Durum.karisiyor) return;
    final hedef = _r.nextInt(_oyunlar.length);
    final azHareket = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (azHareket) {
      setState(() {
        _secilen = _oyunlar[hedef];
        _gosterilen = hedef;
        _durum = _Durum.acik;
      });
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _durum = _Durum.karisiyor);
    await _salla.forward(from: 0);
    if (!mounted) return;
    // Slot makinesi: aralik her adimda biraz uzuyor; son adim hedefte.
    final adimSayisi = 14 + _r.nextInt(4);
    var adim = 0;
    var bekle = 70;
    void sonraki() {
      if (!mounted) return;
      adim++;
      setState(() {
        _gosterilen = adim >= adimSayisi
            ? hedef
            : (_gosterilen + 1 + _r.nextInt(_oyunlar.length - 1)) % _oyunlar.length;
      });
      HapticFeedback.selectionClick();
      if (adim >= adimSayisi) {
        HapticFeedback.mediumImpact();
        setState(() {
          _secilen = _oyunlar[hedef];
          _durum = _Durum.acik;
        });
        return;
      }
      bekle = (bekle * 1.14).round();
      _zamanlayici = Timer(Duration(milliseconds: bekle), sonraki);
    }

    sonraki();
  }

  @override
  Widget build(BuildContext context) {
    final acik = _durum == _Durum.acik && _secilen != null;
    final renk = acik ? OyunKimligi.renk(_secilen!.type) : const Color(0xFFFF8F00);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('Sürpriz oyun', 'Surprise game', 'Überraschungsspiel', 'Juego sorpresa'),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF14161A),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _durum == _Durum.kapali ? _karistir : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            height: 168,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.3),
                radius: 1.3,
                colors: acik
                    ? [Color.lerp(renk, Colors.white, 0.35)!, renk]
                    : const [Color(0xFFFFE082), Color(0xFFFF8F00)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.lerp(renk, Colors.black, 0.3)!,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
              child: Row(
                children: [
                  SizedBox(width: 140, child: _sol()),
                  const SizedBox(width: 12),
                  Expanded(child: _sag()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Sol: kapaliyken sallanan sandik, sonra oyunlarin donen kapagi.
  Widget _sol() {
    if (_durum == _Durum.kapali || (_durum == _Durum.karisiyor && _salla.isAnimating)) {
      return AnimatedBuilder(
        animation: _salla,
        builder: (_, child) => Transform.rotate(
          angle: math.sin(_salla.value * math.pi * 6) * 0.12 * (1 - _salla.value) - 0.08,
          child: Transform.scale(scale: 1 + 0.08 * math.sin(_salla.value * math.pi), child: child),
        ),
        child: Image.asset(
          'assets/images/ui/sandik.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.card_giftcard_rounded, size: 90, color: Colors.white),
        ),
      );
    }
    final g = _oyunlar[_gosterilen];
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 90),
        transitionBuilder: (c, a) => SlideTransition(
          position: Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(a),
          child: c,
        ),
        child: SizedBox.expand(
          key: ValueKey(_gosterilen),
          child: OyunSahnesi(tur: g.type, lang: widget.lang),
        ),
      ),
    );
  }

  Widget _sag() {
    const beyaz = TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white);
    switch (_durum) {
      case _Durum.kapali:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _t('Sandığa dokun,\noyun seç!', 'Tap the chest,\nget a game!',
                  'Tipp auf die Truhe,\nhol dir ein Spiel!', '¡Toca el cofre\ny elige juego!'),
              style: beyaz.copyWith(fontSize: 20, height: 1.05, fontWeight: FontWeight.w900, shadows: const [
                Shadow(color: Color(0x33000000), offset: Offset(0, 2)),
              ]),
            ),
            const SizedBox(height: 6),
            Text(
              _t('Oyunlar karışır, biri çıkar', 'The games shuffle, one pops out',
                  'Die Spiele mischen sich, eins kommt raus', 'Los juegos se mezclan y sale uno'),
              style: beyaz.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _hap(Icons.touch_app_rounded, _t('Dokun', 'Tap', 'Tippen', 'Toca'),
                const Color(0xFFE65100), _karistir),
          ],
        );
      case _Durum.karisiyor:
        final g = _oyunlar[_gosterilen];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_t('Karışıyor...', 'Shuffling...', 'Mischen...', 'Mezclando...'),
                style: beyaz.copyWith(fontSize: 12.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(g.titleFor(widget.lang),
                maxLines: 2,
                style: beyaz.copyWith(fontSize: 19, height: 1.1, fontWeight: FontWeight.w900)),
          ],
        );
      case _Durum.acik:
        final g = _secilen!;
        final koyu = Color.lerp(OyunKimligi.renk(g.type), Colors.black, 0.3)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_t('🎉 Sürprizin:', '🎉 Your surprise:', '🎉 Deine Überraschung:', '🎉 Tu sorpresa:'),
                style: beyaz.copyWith(fontSize: 12.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(g.titleFor(widget.lang),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: beyaz.copyWith(fontSize: 19, height: 1.1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Row(
              children: [
                _hap(Icons.play_arrow_rounded, _t('Oyna', 'Play', 'Spielen', 'Jugar'), koyu,
                    () => widget.onOyna(g)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() => _durum = _Durum.kapali);
                    _karistir();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _hap(IconData simge, String yazi, Color renk, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(simge, size: 18, color: renk),
            const SizedBox(width: 3),
            Text(yazi,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: renk)),
          ],
        ),
      ),
    );
  }
}
