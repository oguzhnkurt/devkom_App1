import 'package:flutter/material.dart';

/// "Slide to start" tarzı kaydırarak onaylama butonu.
/// Quiz Merkezi giriş ekranında kullanılıyor; kullanıcı thumb'ı sona kadar
/// sürükleyince [onConfirmed] tetiklenir. Yeterince sürüklenmezse thumb
/// yay animasyonuyla başa döner.
class SlideToStartButton extends StatefulWidget {
  final String label;
  final VoidCallback onConfirmed;
  final Color trackColor;
  final Color thumbColor;
  final Color labelColor;
  final IconData icon;

  const SlideToStartButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.trackColor = Colors.white,
    this.thumbColor = const Color(0xFF6C3CE0),
    this.labelColor = const Color(0xFF6C3CE0),
    this.icon = Icons.arrow_forward_rounded,
  });

  @override
  State<SlideToStartButton> createState() => _SlideToStartButtonState();
}

class _SlideToStartButtonState extends State<SlideToStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;
  double _dragX = 0;
  double _maxDrag = 1;
  bool _completed = false;

  static const double _thumbSize = 52;
  static const double _trackHeight = 60;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        setState(() => _dragX = _snapController.value);
      });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_completed) return;
    setState(() {
      _dragX = (_dragX + details.delta.dx).clamp(0.0, _maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_completed) return;
    if (_dragX > _maxDrag * 0.75) {
      setState(() {
        _dragX = _maxDrag;
        _completed = true;
      });
      widget.onConfirmed();
    } else {
      _snapController.value = _dragX;
      _snapController.animateTo(0, curve: Curves.easeOutBack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxDrag = constraints.maxWidth - _thumbSize - 8;
        final progress = _maxDrag > 0 ? (_dragX / _maxDrag).clamp(0.0, 1.0) : 0.0;

        return Container(
          height: _trackHeight,
          decoration: BoxDecoration(
            color: widget.trackColor,
            borderRadius: BorderRadius.circular(_trackHeight / 2),
            border: Border.all(color: widget.thumbColor.withValues(alpha: 0.25), width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Arka plan dolgu (kaydırma ilerledikçe renklenir)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_trackHeight / 2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (progress * 0.9 + 0.12).clamp(0.0, 1.0),
                      child: Container(color: widget.thumbColor.withValues(alpha: 0.12)),
                    ),
                  ),
                ),
              ),
              Center(
                child: Opacity(
                  opacity: (1 - progress * 1.4).clamp(0.0, 1.0),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.labelColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Transform.translate(
                  offset: Offset(_dragX, 0),
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        color: widget.thumbColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.thumbColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
