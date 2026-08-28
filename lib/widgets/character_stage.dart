import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/store_item_model.dart';

/// Karakterin canli/animasyonlu "sahne" gosterimi.
///
/// Karakterim ekrani (buyuk, etkilesimli "yakin cekim" sahne) ve Market
/// ekranindaki canli onizleme basligi tarafindan paylasilir. Boylece
/// kullanici ne giydigini her yerde ayni, hos animasyonlu haliyle gorur.
///
/// - Boşta hafif bir "nefes alma" (idle bounce) animasyonu vardır.
/// - Karaktere dokununca (interactive true ise) kucuk bir "sicrama" +
///   parlama (sparkle) efekti oynar - dokunmayi/etkilesimi eglenceli kilar.
class CharacterStage extends StatefulWidget {
  final StoreItem? character;
  final StoreItem? hat;
  final StoreItem? necklace;
  final StoreItem? glasses;
  final StoreItem? shoes;
  final double size;
  final bool interactive;
  final Color accentColor;
  final bool previewMode;

  const CharacterStage({
    super.key,
    this.character,
    this.hat,
    this.necklace,
    this.glasses,
    this.shoes,
    this.size = 200,
    this.interactive = true,
    this.accentColor = const Color(0xFF7C4DFF),
    this.previewMode = false,
  });

  static const String defaultEmoji = '👾';

  static Color parseColorHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF7C4DFF);
    }
  }

  @override
  State<CharacterStage> createState() => _CharacterStageState();
}

class _CharacterStageState extends State<CharacterStage> with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _reactController;
  final List<int> _burstIds = [];
  int _nextBurstId = 0;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _reactController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _idleController.dispose();
    _reactController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.interactive) return;
    HapticFeedback.mediumImpact();
    _reactController.forward(from: 0);
    final id = _nextBurstId++;
    setState(() => _burstIds.add(id));
  }

  double get _reactBump {
    final t = _reactController.value;
    if (t <= 0.5) return 1 + 0.22 * (t / 0.5);
    return 1 + 0.22 * (1 - (t - 0.5) / 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final baseEmoji = widget.character?.iconEmoji ?? CharacterStage.defaultEmoji;
    final baseColor = widget.character != null
        ? CharacterStage.parseColorHex(widget.character!.colorHex)
        : widget.accentColor;
    final size = widget.size;

    final stage = SizedBox(
        width: size,
        height: size * 1.05,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Pulsing glow ring
            AnimatedBuilder(
              animation: _idleController,
              builder: (context, child) {
                final glowT = Curves.easeInOut.transform(_idleController.value);
                return Container(
                  width: size * (0.78 + 0.05 * glowT),
                  height: size * (0.78 + 0.05 * glowT),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [baseColor.withValues(alpha: 0.30), baseColor.withValues(alpha: 0.0)],
                    ),
                  ),
                );
              },
            ),

            // Main character (bounces + reacts to tap)
            AnimatedBuilder(
              animation: Listenable.merge([_idleController, _reactController]),
              builder: (context, child) {
                final idleT = Curves.easeInOut.transform(_idleController.value);
                final bounceY = -size * 0.03 * idleT;
                return Transform.translate(
                  offset: Offset(0, bounceY),
                  child: Transform.scale(scale: _reactBump, child: child),
                );
              },
              child: Container(
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: baseColor.withValues(alpha: 0.18),
                  boxShadow: [
                    BoxShadow(color: baseColor.withValues(alpha: 0.35), blurRadius: size * 0.14, spreadRadius: size * 0.02),
                  ],
                ),
                child: Center(child: Text(baseEmoji, style: TextStyle(fontSize: size * 0.3))),
              ),
            ),

            // Hat
            if (widget.hat != null)
              Positioned(
                top: size * 0.04,
                child: AnimatedBuilder(
                  animation: _idleController,
                  builder: (context, child) {
                    final idleT = Curves.easeInOut.transform(_idleController.value);
                    return Transform.translate(offset: Offset(0, -size * 0.03 * idleT), child: child);
                  },
                  child: Text(widget.hat!.iconEmoji, style: TextStyle(fontSize: size * 0.17)),
                ),
              ),

            // Glasses (yuz/goz hizasinda, karakterin ustune biner)
            if (widget.glasses != null)
              Positioned(
                top: size * 0.40,
                child: Text(widget.glasses!.iconEmoji, style: TextStyle(fontSize: size * 0.16)),
              ),

            // Necklace
            if (widget.necklace != null)
              Positioned(
                bottom: size * 0.24,
                child: Text(widget.necklace!.iconEmoji, style: TextStyle(fontSize: size * 0.13)),
              ),

            // Shoes (sahnenin en altinda, ayak hizasinda)
            if (widget.shoes != null)
              Positioned(
                bottom: size * 0.0,
                child: Text(widget.shoes!.iconEmoji, style: TextStyle(fontSize: size * 0.14)),
              ),

            // Sparkle bursts on tap
            ..._burstIds.map(
              (id) => _SparkleBurst(
                key: ValueKey(id),
                onDone: () {
                  if (mounted) setState(() => _burstIds.remove(id));
                },
              ),
            ),

            // "Onizleniyor" badge (Market'te gecici deneme icin)
            if (widget.previewMode)
              Positioned(
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Önizleniyor',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
    );

    // Etkileşimli değilse (ör. kapanış diyaloğundaki büyük yakın çekim
    // görünümü) fazladan bir GestureDetector eklemiyoruz - böylece disari
    // sarilan bir "dokununca kapat" gibi jestlerle çakışmaz.
    if (!widget.interactive) return stage;
    return GestureDetector(onTap: _onTap, child: stage);
  }
}

class _SparkleBurst extends StatefulWidget {
  final VoidCallback onDone;
  const _SparkleBurst({super.key, required this.onDone});

  @override
  State<_SparkleBurst> createState() => _SparkleBurstState();
}

class _SparkleBurstState extends State<_SparkleBurst> {
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _particles = List.generate(6, (i) {
      final angle = (i / 6) * 2 * math.pi + rnd.nextDouble() * 0.4;
      final distance = 46.0 + rnd.nextDouble() * 22;
      const emojis = ['✨', '⭐', '💫'];
      return _Particle(angle: angle, distance: distance, emoji: emojis[i % emojis.length]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOut,
      onEnd: widget.onDone,
      builder: (context, t, child) {
        return Stack(
          alignment: Alignment.center,
          children: _particles.map((p) {
            final dx = math.cos(p.angle) * p.distance * t;
            final dy = math.sin(p.angle) * p.distance * t;
            return Transform.translate(
              offset: Offset(dx, dy),
              child: Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Text(p.emoji, style: TextStyle(fontSize: 14 + 8 * (1 - t))),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final String emoji;
  const _Particle({required this.angle, required this.distance, required this.emoji});
}
