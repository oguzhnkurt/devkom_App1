import 'package:flutter/material.dart';

import '../models/game_model.dart';
import 'oyun_kimligi.dart';

/// Oyun ekranlarinin ortak basligi.
///
/// Oyunlar sekmesinden acilan her oyun eskiden kendi AppBar'ini ciziyordu:
/// kimi duz mavi bir serit, kimi beyaz, kimi siyah. Oyunlar birbirinin
/// devami gibi degil, baska uygulamalardan alinmis gibi gorunuyordu.
///
/// Bu baslik hepsine ayni dili veriyor: oyunun kendi renginde yumusak bir
/// gecis, alt koseleri yuvarlak, beyaz daire icinde geri tusu, oyunun
/// simgesi ve adi. Renk her oyunda farkli kaliyor; oyunlar birbirinden
/// ayirt ediliyor ama ayni aileden oldugu belli.
class OyunBasligi extends StatelessWidget implements PreferredSizeWidget {
  const OyunBasligi({
    super.key,
    this.baslik,
    this.baslikWidget,
    required this.renk,
    this.simge,
    this.altBaslik,
    this.eylemler = const [],
    this.geriTusu = true,
  });

  /// Oyunlar sekmesindeki kartla ayni renk ve simgeyle.
  OyunBasligi.oyun(
    GameType tur, {
    super.key,
    this.baslik,
    this.baslikWidget,
    this.altBaslik,
    this.eylemler = const [],
    this.geriTusu = true,
  })  : renk = OyunKimligi.renk(tur),
        simge = OyunKimligi.simge(tur);

  final String? baslik;

  /// Baslik metni dile ya da seviyeye gore degisen bir widget ise.
  /// Beyaz, kalin ve tek satir ciziliyor.
  final Widget? baslikWidget;
  final Color renk;

  /// Basliktaki rozet. Oyun kartindaki simgeyle ayni olmali.
  final IconData? simge;

  /// Seviye gibi kisa bir bilgi; uzun cumle icin degil.
  final String? altBaslik;

  /// Sag taraftaki tuslar (ipucu, yeniden baslat). Beyaz ciziliyor.
  final List<Widget> eylemler;

  /// Bitis ekranlari gibi geri donulmemesi gereken yerlerde false.
  final bool geriTusu;

  static const double yukseklik = 76;

  @override
  Size get preferredSize => const Size.fromHeight(yukseklik);

  @override
  Widget build(BuildContext context) {
    final ust = MediaQuery.paddingOf(context).top;
    final acik = Color.lerp(renk, Colors.white, 0.28)!;
    final geriVar = geriTusu && Navigator.of(context).canPop();

    return Container(
      height: yukseklik + ust,
      padding: EdgeInsets.fromLTRB(10, ust, 10, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [renk, acik],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: renk.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconTheme(
        data: const IconThemeData(color: Colors.white, size: 24),
        child: Row(
          children: [
            if (geriVar)
              _Daire(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onTap: () => Navigator.of(context).maybePop(),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              )
            else
              const SizedBox(width: 6),
            const SizedBox(width: 10),
            if (simge != null) ...[
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(simge, size: 22),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                    child: baslikWidget ?? Text(baslik ?? ''),
                  ),
                  if (altBaslik != null)
                    Text(
                      altBaslik!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            for (final e in eylemler) ...[
              const SizedBox(width: 6),
              // Simge tuslari beyaz dairede; puan/sure gibi yazili
              // bilgiler yarı saydam bir hapta.
              if (e is IconButton || e is Icon) _Daire(child: e) else _Hap(child: e),
            ],
          ],
        ),
      ),
    );
  }
}

/// Basliktaki yarı saydam beyaz daire (geri ve eylem tuslari icin).
class _Daire extends StatelessWidget {
  const _Daire({required this.child, this.onTap, this.tooltip});

  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final icerik = Material(
      color: Colors.white.withValues(alpha: 0.22),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          // Eylem zaten kendi IconButton'u; yalnizca zemini veriyoruz.
          ? SizedBox(width: 44, height: 44, child: Center(child: child))
          : InkWell(
              onTap: onTap,
              child: SizedBox(width: 44, height: 44, child: Center(child: child)),
            ),
    );
    return tooltip == null ? icerik : Tooltip(message: tooltip!, child: icerik);
  }
}

/// Basliktaki yazili bilgi (puan, sure, seviye) icin hap.
class _Hap extends StatelessWidget {
  const _Hap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Oyunlarin eski AppBar eylemleri cogu zaman `Center(Text)` ya da
    // `Padding(Center(...))`. Satirda genislik sinirsiz oldugu icin Center
    // sonsuz genislik istiyor ve ekran cizilmiyordu. IntrinsicWidth
    // icerigi kendi genisligine sabitliyor; uzun puan yazisi 170 px'te
    // kesiliyor, basligi itmiyor.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170, minHeight: 36),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(18),
        ),
        child: DefaultTextStyle.merge(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
          // Yine de sigmazsa (Almanca uzun) yazi kesilmiyor, kucultuluyor.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: IntrinsicHeight(child: IntrinsicWidth(child: child)),
          ),
        ),
      ),
    );
  }
}

/// Oyun ekraninin zemini: oyunun renginden beyaza inen yumusak gecis ve
/// arkada iki bulanik isik lekesi. Duz gri zemin yerine.
class OyunZemini extends StatelessWidget {
  const OyunZemini({super.key, required this.renk, required this.child});

  /// Zeminin en ustteki tonu. Scaffold'un `backgroundColor`'i bu olmali:
  /// basligin yuvarlak alt koselerinin arkasi saydam kalirsa orada siyah
  /// bir serit gorunuyor.
  static Color ustRenk(Color renk) => Color.lerp(renk, Colors.white, 0.86)!;

  final Color renk;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ustRenk(renk),
            Color.lerp(renk, Colors.white, 0.96)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -80,
            top: 60,
            child: _Leke(renk: renk, boyut: 220),
          ),
          Positioned(
            left: -90,
            bottom: 40,
            child: _Leke(renk: renk, boyut: 260),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Leke extends StatelessWidget {
  const _Leke({required this.renk, required this.boyut});

  final Color renk;
  final double boyut;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: boyut,
        height: boyut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              renk.withValues(alpha: 0.16),
              renk.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Oyunlardaki cevap secenegi: renkli "jole" kart.
///
/// Quiz ekranindaki siklarla ayni renk sirasi. Eskiden oyunlarda cevaplar
/// soluk mavi, birbirinin aynisi kutulardi; cocuk hangisine bastigini
/// ayirt etmekte zorlaniyordu ve ekran oyun gibi gorunmuyordu.
class OyunCevapKarti extends StatelessWidget {
  const OyunCevapKarti({
    super.key,
    required this.sira,
    required this.onTap,
    required this.child,
  });

  /// Kartin rengi bu siraya gore seciliyor.
  final int sira;
  final VoidCallback? onTap;
  final Widget child;

  static const List<Color> renkler = [
    Color(0xFFFF6B6B),
    Color(0xFF4D96FF),
    Color(0xFFFFA726),
    Color(0xFF26C6A6),
    Color(0xFF9B5DE5),
    Color(0xFFEC407A),
  ];

  @override
  Widget build(BuildContext context) {
    final renk = renkler[sira % renkler.length];
    final koyu = Color.lerp(renk, const Color(0xFF14102B), 0.28)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.lerp(renk, Colors.white, 0.12)!, renk],
            ),
            border: Border(bottom: BorderSide(color: koyu, width: 5)),
            boxShadow: [
              BoxShadow(
                color: renk.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IconTheme(
            data: const IconThemeData(color: Colors.white, size: 46),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
