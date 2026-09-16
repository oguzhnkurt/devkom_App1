import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/sound_service.dart';
import '../../theme.dart';
import '../../ui/motion.dart';
import '../../ui/press_button.dart';
import 'success_burst.dart';

/// Oyun acilinca bir kere oynayan "nasil oynanir" gosterimi.
///
/// Oyunlarin basinda mavi bir kutu icinde iki satir yazi vardi: "Sol
/// taraftaki yuvarlaga tikla, sonra sagdaki dogru kelimeyi esestir."
/// Hedef kitlemiz 7 yasindan basliyor; bir kismi bu cumleyi rahat
/// okuyamiyor, okuyanlarin cogu da oyun ekranindaki yaziyi atliyor.
///
/// Burada ayni sey GOSTERILIYOR: bir el kaynak noktadan hedefe suruluyor,
/// arkasinda ok cizgisi uzuyor, hedefe varinca esleme kilitleniyor,
/// basari efekti + ses + titresim geliyor. Iki tur donuyor, sonra cocuk
/// baslayabiliyor.
///
/// Her oyun icin bir kere gosteriliyor ([gameKey] ile isaretleniyor);
/// cocuk isterse oyun icindeki "?" tusundan tekrar acabiliyor.
/// Gosterimin ANLATTIGI hareket.
///
/// Ilk surumde tek bir sahne vardi — iki sutun arasinda eslestirme — ve
/// dort oyunda da o kullaniliyordu. Kelime eslestirmede dogruydu, ama
/// Blok Kodlama'da tamamen yanlis bir sey ogretiyordu: o oyunda iki
/// seyi eslestirmiyorsun, bir blogu kod alanina birakiyorsun. Ekranda
/// "1 Adım Git" ile "Kodun" arasinda bir ok cikiyor ve cocuga
/// yapmayacagi bir hareket gosteriliyordu.
///
/// Artik her oyun kendi hareketini gosteriyor.
enum DemoScene {
  /// Iki sutun arasinda eslestirme. Kelime Eslestirme, Eslestirme.
  matchPairs,

  /// Bir parcayi asagidaki alana birakma. Blok Kodlama.
  dragIntoArea,

  /// Sirayla dokunma. Siralama.
  tapInOrder,
}

class HowToPlayDemo extends StatefulWidget {
  const HowToPlayDemo({
    super.key,
    required this.title,
    required this.sourceLabel,
    required this.targetLabel,
    required this.decoyLabel,
    required this.hint,
    required this.startLabel,
    this.scene = DemoScene.matchPairs,
    this.extraLabel,
    this.color = AppTheme.primaryBlue,
    this.sourceIcon,
    this.targetIcon,
  });

  final String title;

  /// Surukleme baslangicindaki etiket (ornek: "Robot").
  final String sourceLabel;

  /// Dogru hedef (ornek: "Robot" - Turkcesi).
  final String targetLabel;

  /// Yanlis secenek: el bunun UZERINDEN gecip dogruya gidiyor, boylece
  /// cocuk "herhangi bir yere degil, DOGRU olana" mesajini aliyor.
  final String decoyLabel;

  final String hint;
  final String startLabel;

  /// Hangi hareket gosterilecek.
  final DemoScene scene;

  /// [DemoScene.tapInOrder] icin ucuncu etiket.
  final String? extraLabel;
  final Color color;
  final IconData? sourceIcon;
  final IconData? targetIcon;

  /// Bu oyunun gosterimi daha once izlendi mi?
  static Future<bool> seen(String gameKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('howto_seen_$gameKey') ?? false;
    } catch (_) {
      // Depolama okunamiyorsa gosterimi atlamak, her acilista tekrar
      // gostermekten iyidir.
      return true;
    }
  }

  static Future<void> markSeen(String gameKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('howto_seen_$gameKey', true);
    } catch (_) {
      // Onemli degil: en kotu ihtimalle gosterim bir kez daha cikar.
    }
  }

  /// Gosterimi bir kere acar. [force] true ise "daha once izledi" kaydini
  /// yok sayar (oyun icindeki "?" tusu bunu kullaniyor).
  static Future<void> maybeShow(
    BuildContext context, {
    required String gameKey,
    required HowToPlayDemo demo,
    bool force = false,
  }) async {
    if (!force && await seen(gameKey)) return;
    if (!context.mounted) return;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      barrierLabel: demo.title,
      transitionDuration: Motion.medium4,
      pageBuilder: (_, __, ___) => demo,
      transitionBuilder: (context, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Motion.emphasizedDecelerate),
          ),
          child: child,
        ),
      ),
    );
    await markSeen(gameKey);
  }

  @override
  State<HowToPlayDemo> createState() => _HowToPlayDemoState();
}

class _HowToPlayDemoState extends State<HowToPlayDemo>
    with SingleTickerProviderStateMixin {
  /// Tek tur: 0.00-0.12 bekle, 0.12-0.62 suru, 0.62-0.80 kilitlen,
  /// 0.80-1.00 basari efekti ve bekleme.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  bool _burstFired = false;
  bool _showBurst = false;
  int _loops = 0;

  /// Sahneye gore yerlesim.
  ///
  /// `matchPairs`: kaynak solda, dogru ve yanlis secenek sagda.
  /// `dragIntoArea`: parca yukarida, birakma alani asagida — iki sutun
  ///   yok, cunku o oyunda iki sutun yok.
  /// `tapInOrder`: uc parca yan yana, sirayla dokunuluyor.
  Offset get _sourceAnchor => switch (widget.scene) {
        DemoScene.matchPairs => const Offset(0.22, 0.26),
        DemoScene.dragIntoArea => const Offset(0.28, 0.18),
        DemoScene.tapInOrder => const Offset(0.18, 0.30),
      };

  Offset get _decoyAnchor => switch (widget.scene) {
        DemoScene.matchPairs => const Offset(0.78, 0.26),
        DemoScene.dragIntoArea => const Offset(0.72, 0.18),
        DemoScene.tapInOrder => const Offset(0.50, 0.30),
      };

  Offset get _targetAnchor => switch (widget.scene) {
        DemoScene.matchPairs => const Offset(0.78, 0.74),
        DemoScene.dragIntoArea => const Offset(0.50, 0.74),
        DemoScene.tapInOrder => const Offset(0.82, 0.30),
      };

  @override
  void initState() {
    super.initState();
    _c.addListener(_tick);
    _c.addStatusListener(_onStatus);
    if (Motion.reducedRaw) {
      // Hareket azaltilmisken tur donmuyor: son kare (eslesmis hali)
      // dogrudan gosteriliyor.
      _c.value = 1.0;
    } else {
      _c.forward();
    }
  }

  void _onStatus(AnimationStatus s) {
    if (s != AnimationStatus.completed) return;
    _loops++;
    // Iki tur yeter: ucuncusu cocugu bekletmeye baslar.
    if (_loops < 2 && mounted) {
      _burstFired = false;
      _showBurst = false;
      _c.forward(from: 0);
    }
  }

  void _tick() {
    // Kilitlenme aninda ses + titresim + efekt. Sadece bir kez.
    if (!_burstFired && _c.value >= 0.78) {
      _burstFired = true;
      SoundService.playCorrect();
      if (mounted) setState(() => _showBurst = true);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _c
      ..removeListener(_tick)
      ..removeStatusListener(_onStatus)
      ..dispose();
    super.dispose();
  }

  /// Elin bu andaki konumu (0..1 oranli).
  ///
  /// Yol duz degil: once yanlis secenege dogru gidip oradan asagi kiriliyor.
  /// Duz bir cizgi "bir yerden bir yere" derdi; kirilma "dogru olani sec"
  /// diyor.
  Offset _handAt(double t) {
    if (t <= 0.12) return _sourceAnchor;
    if (t >= 0.78) return _targetAnchor;
    final p = ((t - 0.12) / 0.66).clamp(0.0, 1.0);
    final eased = Curves.easeInOutCubic.transform(p);

    // Blok kodlamada yol DUZ: parcayi alip asagidaki alana birakiyorsun.
    // Kirilma orada bir sey anlatmaz, sadece kafa karistirir.
    if (widget.scene == DemoScene.dragIntoArea) {
      return Offset.lerp(_sourceAnchor, _targetAnchor, eased)!;
    }

    // Siralamada el uc parcaya SIRAYLA dokunuyor.
    if (widget.scene == DemoScene.tapInOrder) {
      if (eased < 0.4) {
        return Offset.lerp(_sourceAnchor, _decoyAnchor, eased / 0.4)!;
      }
      return Offset.lerp(_decoyAnchor, _targetAnchor, (eased - 0.4) / 0.6)!;
    }

    // Eslestirmede iki parcali yol: kaynak -> yanlis secenegin yani ->
    // dogru hedef. Kirilma "herhangi bir yere degil, DOGRU olana" diyor.
    const mid = Offset(0.74, 0.34);
    if (eased < 0.55) {
      final k = eased / 0.55;
      return Offset.lerp(_sourceAnchor, mid, k)!;
    }
    final k = (eased - 0.55) / 0.45;
    return Offset.lerp(mid, _targetAnchor, k)!;
  }

  double get _dragProgress => ((_c.value - 0.12) / 0.66).clamp(0.0, 1.0);
  bool get _locked => _c.value >= 0.78;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final boardHeight = math.min(300.0, media.size.height * 0.42);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 4),
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                    child: Text(
                      widget.hint,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        height: 1.35,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: boardHeight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final size = Size(c.maxWidth, c.maxHeight);
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Ok cizgisi kartlarin ARKASINDA.
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _TrailPainter(
                                    from: _sourceAnchor,
                                    to: _handAt(_c.value),
                                    progress: _dragProgress,
                                    color: widget.color,
                                    locked: _locked,
                                  ),
                                ),
                              ),
                              ..._sceneChips(size),
                              if (_showBurst)
                                Positioned.fill(
                                  child: SuccessBurst(
                                    center: Offset(
                                      _targetAnchor.dx * size.width,
                                      _targetAnchor.dy * size.height,
                                    ),
                                    color: const Color(0xFF2E7D32),
                                    onDone: () {
                                      if (mounted) {
                                        setState(() => _showBurst = false);
                                      }
                                    },
                                  ),
                                ),
                              if (!Motion.reducedRaw) _hand(size),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                    child: PressButton(
                      label: widget.startLabel,
                      color: widget.color,
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Sahnenin parcalari.
  List<Widget> _sceneChips(Size size) {
    switch (widget.scene) {
      case DemoScene.matchPairs:
        return [
          _chip(size, _sourceAnchor, widget.sourceLabel,
              icon: widget.sourceIcon, active: true, highlight: _locked),
          _chip(size, _decoyAnchor, widget.decoyLabel, muted: true),
          _chip(size, _targetAnchor, widget.targetLabel,
              icon: widget.targetIcon, active: _locked, highlight: _locked),
        ];

      case DemoScene.dragIntoArea:
        // Ustte iki blok, altta kesikli cerceveli birakma alani.
        // Cocuk ekranda tam olarak oyundaki seyi goruyor.
        return [
          _chip(size, _sourceAnchor, widget.sourceLabel, active: true),
          _chip(size, _decoyAnchor, widget.decoyLabel, muted: true),
          _dropZone(size),
        ];

      case DemoScene.tapInOrder:
        // Uc parca yan yana; el sirayla dokunurken her biri numarasini
        // aliyor. Siralama oyununda ogrenilecek sey bu.
        return [
          _step(size, _sourceAnchor, widget.sourceLabel, 1,
              done: _c.value > 0.30),
          _step(size, _decoyAnchor, widget.decoyLabel, 2,
              done: _c.value > 0.55),
          _step(size, _targetAnchor, widget.extraLabel ?? widget.targetLabel, 3,
              done: _locked),
        ];
    }
  }

  /// Blok kodlamadaki "Blokları buraya sürükle" alani.
  Widget _dropZone(Size size) {
    final filled = _locked;
    return Positioned(
      left: size.width * 0.12,
      top: _targetAnchor.dy * size.height - 34,
      width: size.width * 0.76,
      child: AnimatedContainer(
        duration: Motion.medium2,
        curve: Motion.emphasized,
        height: 68,
        decoration: BoxDecoration(
          color: filled
              ? const Color(0xFF2E7D32).withValues(alpha: 0.08)
              : const Color(0xFFF4F6F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: filled ? const Color(0xFF2E7D32) : const Color(0xFFCFD5DB),
            width: filled ? 2 : 1.6,
          ),
        ),
        alignment: Alignment.center,
        child: filled
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.sourceLabel,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: Color(0xFF2E7D32)),
                ],
              )
            : Text(
                widget.targetLabel,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mediumGray,
                ),
              ),
      ),
    );
  }

  /// Siralama sahnesindeki numarali parca.
  Widget _step(Size size, Offset anchor, String label, int order,
      {required bool done}) {
    return Positioned(
      left: anchor.dx * size.width - 46,
      top: anchor.dy * size.height - 26,
      width: 92,
      child: AnimatedContainer(
        duration: Motion.medium2,
        curve: Motion.emphasized,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: done
              ? widget.color.withValues(alpha: 0.10)
              : const Color(0xFFF4F6F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done ? widget.color : const Color(0xFFE0E4E9),
            width: done ? 2 : 1.4,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              duration: Motion.short4,
              opacity: done ? 1 : 0.25,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: done ? widget.color : AppTheme.mediumGray,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$order',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: done ? widget.color : AppTheme.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hand(Size size) {
    final pos = _handAt(_c.value);
    // Kilitlenme aninda el hafifce kuculuyor: "bastim" hissi.
    final scale = _locked ? 0.86 : 1.0;
    return Positioned(
      left: pos.dx * size.width - 16,
      top: pos.dy * size.height - 6,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topLeft,
        child: Opacity(
          opacity: _c.value < 0.06 ? _c.value / 0.06 : 1,
          // Ilk denemede el kucuk ve koyuydu; beyaz kartin uzerinde
          // etiket yazilarina karisiyordu. Beyaz bir daire icine alip
          // golge verince parmak, arka plandan ayri bir katman gibi
          // okunuyor.
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: widget.color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.touch_app_rounded, size: 22, color: widget.color),
          ),
        ),
      ),
    );
  }

  Widget _chip(
    Size size,
    Offset anchor,
    String label, {
    IconData? icon,
    bool active = false,
    bool muted = false,
    bool highlight = false,
  }) {
    final color = muted ? AppTheme.mediumGray : widget.color;
    return Positioned(
      left: anchor.dx * size.width - 62,
      top: anchor.dy * size.height - 21,
      width: 124,
      child: AnimatedContainer(
        duration: Motion.medium2,
        curve: Motion.emphasized,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: highlight
              ? const Color(0xFF2E7D32).withValues(alpha: 0.10)
              : (active ? color.withValues(alpha: 0.10) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlight
                ? const Color(0xFF2E7D32)
                : (active ? color : const Color(0xFFE0E0E0)),
            width: active || highlight ? 2 : 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: muted ? color : color),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: muted ? AppTheme.mediumGray : AppTheme.darkGray,
                ),
              ),
            ),
            if (highlight && !muted) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: Color(0xFF2E7D32)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Elin arkasinda uzayan kesikli ok.
class _TrailPainter extends CustomPainter {
  _TrailPainter({
    required this.from,
    required this.to,
    required this.progress,
    required this.color,
    required this.locked,
  });

  final Offset from;
  final Offset to;
  final double progress;
  final Color color;
  final bool locked;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final a = Offset(from.dx * size.width, from.dy * size.height);
    final b = Offset(to.dx * size.width, to.dy * size.height);
    if ((b - a).distance < 4) return;

    final paint = Paint()
      ..color = (locked ? const Color(0xFF2E7D32) : color)
          .withValues(alpha: locked ? 0.9 : 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Kesikli cizgi: hareket yonunu duz bir cizgiden daha iyi anlatiyor.
    const dash = 9.0;
    const gap = 6.0;
    final dir = (b - a) / (b - a).distance;
    final total = (b - a).distance;
    var d = 0.0;
    while (d < total) {
      final end = math.min(d + dash, total);
      canvas.drawLine(a + dir * d, a + dir * end, paint);
      d = end + gap;
    }

    // Ok ucu.
    final angle = math.atan2(dir.dy, dir.dx);
    const head = 11.0;
    for (final s in [2.6, -2.6]) {
      canvas.drawLine(
        b,
        b - Offset(math.cos(angle + s) * -head, math.sin(angle + s) * -head),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) =>
      old.to != to || old.progress != progress || old.locked != locked;
}
