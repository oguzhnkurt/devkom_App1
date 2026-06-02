import 'package:flutter/material.dart';

/// Yürüyen kedi animasyonu widget'ı
/// 2 adım animasyonuyla kedi yürür
class WalkingCatWidget extends StatefulWidget {
  final int steps; // Kaç adım yürüyecek
  final Duration stepDuration; // Her adım ne kadar sürecek
  final VoidCallback? onWalkComplete; // Yürüme tamamlandığında
  final double size; // Kedi boyutu

  const WalkingCatWidget({
    super.key,
    this.steps = 2,
    this.stepDuration = const Duration(milliseconds: 500),
    this.onWalkComplete,
    this.size = 60,
  });

  @override
  State<WalkingCatWidget> createState() => _WalkingCatWidgetState();
}

class _WalkingCatWidgetState extends State<WalkingCatWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _walkAnimation;
  late Animation<double> _bobAnimation;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    // Animasyon controller'ı oluştur
    _controller = AnimationController(
      duration: widget.stepDuration,
      vsync: this,
    );

    // Yürüme animasyonu (yatay hareket)
    _walkAnimation = Tween<double>(
      begin: 0,
      end: 50, // Her adımda 50 pixel ilerle
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Zıplama animasyonu (yukarı-aşağı)
    _bobAnimation = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Animasyon tamamlandığında
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentStep++;
        });

        if (_currentStep < widget.steps) {
          // Bir sonraki adım için animasyonu tekrarla
          _controller.reset();
          _controller.forward();
        } else {
          // Tüm adımlar tamamlandı
          widget.onWalkComplete?.call();
        }
      }
    });

    // İlk adımı başlat
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _walkAnimation.value + (_currentStep * 50),
            _bobAnimation.value,
          ),
          child: _buildCat(),
        );
      },
    );
  }

  Widget _buildCat() {
    // Bacak animasyonu için controller değerini kullan
    final legPhase = _controller.value;
    final isLeftLegForward = legPhase < 0.5;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Kedi gövdesi
          Positioned(
            top: widget.size * 0.2,
            child: Text(
              '🐱',
              style: TextStyle(fontSize: widget.size * 0.8),
            ),
          ),

          // Sol bacak (animasyonlu)
          Positioned(
            left: widget.size * 0.25,
            bottom: widget.size * 0.15,
            child: Transform.rotate(
              angle: isLeftLegForward ? 0.3 : -0.3,
              child: Container(
                width: 3,
                height: widget.size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Sağ bacak (animasyonlu)
          Positioned(
            right: widget.size * 0.25,
            bottom: widget.size * 0.15,
            child: Transform.rotate(
              angle: isLeftLegForward ? -0.3 : 0.3,
              child: Container(
                width: 3,
                height: widget.size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Basit yürüyen kedi (sadece emoji animasyonu)
class SimpleWalkingCat extends StatefulWidget {
  final int steps;
  final Duration stepDuration;
  final VoidCallback? onWalkComplete;
  final double size;

  const SimpleWalkingCat({
    super.key,
    this.steps = 2,
    this.stepDuration = const Duration(milliseconds: 500),
    this.onWalkComplete,
    this.size = 60,
  });

  @override
  State<SimpleWalkingCat> createState() => _SimpleWalkingCatState();
}

class _SimpleWalkingCatState extends State<SimpleWalkingCat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.stepDuration * widget.steps,
      vsync: this,
    );

    // Yatay hareket
    _positionAnimation = Tween<double>(
      begin: 0,
      end: widget.steps * 50.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Yukarı-aşağı zıplama (adım efekti)
    _bounceAnimation = TweenSequence<double>([
      for (int i = 0; i < widget.steps; i++) ...[
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: -8)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 0.5,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: -8, end: 0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 0.5,
        ),
      ],
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onWalkComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Bacak hareketini simüle etmek için farklı emoji'ler
        final stepPhase = (_controller.value * widget.steps * 2) % 1;
        final catEmoji = stepPhase < 0.5 ? '🐱' : '🐈';

        return Transform.translate(
          offset: Offset(
            _positionAnimation.value,
            _bounceAnimation.value,
          ),
          child: Text(
            catEmoji,
            style: TextStyle(fontSize: widget.size),
          ),
        );
      },
    );
  }
}
