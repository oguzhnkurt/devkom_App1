import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'motion.dart';

/// Basildiginda gercekten "cokerek" tepki veren ana buton.
///
/// Alt kenarinda 4 px'lik koyu bir seri var; parmak degdiginde buton o kadar
/// asagi iniyor ve seri kayboluyor. Egitim uygulamalarinin tamaminda ayni
/// numara var (Duolingo, Mimo, Elevate) ve sebebi su: cocuk dokunusunun
/// kaydedildigini ekrandan aninda goruyor, iki kez basmiyor.
///
/// Flutter'in kendi `ElevatedButton`'i bunu yapmiyor: gorsel tepkisi yalnizca
/// bir dalga efekti ve o da bizim gibi tam genislikte, buyuk butonlarda
/// neredeyse fark edilmiyordu.
class PressButton extends StatefulWidget {
  const PressButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppTheme.primaryBlue,
    this.foreground = Colors.white,
    this.icon,
    this.loading = false,
    this.height = 56,
    this.expand = true,
  });

  final String label;

  /// null ise buton pasif: rengi soluyor ve basmaya tepki vermiyor.
  final VoidCallback? onPressed;

  final Color color;
  final Color foreground;
  final IconData? icon;

  /// Satin alma / kayit gibi ag isleri surerken. Etiket yerine halka doner,
  /// buton tiklanamaz olur — kullanici ikinci kez gondermesin.
  final bool loading;

  final double height;
  final bool expand;

  @override
  State<PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {
  bool _down = false;

  static const double _lip = 4;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _setDown(bool value) {
    if (!_enabled || _down == value) return;
    setState(() => _down = value);
    if (value) HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final base = _enabled ? widget.color : const Color(0xFFC9CDD6);
    // Seri, butonun kendisinin koyulastirilmis hali; ayri bir renk tanimlamak
    // her cagri yerinde iki renk gecirmeyi gerektirirdi.
    final lip = Color.alphaBlend(Colors.black.withValues(alpha: 0.22), base);
    final pressed = _down && _enabled;

    final button = SizedBox(
      width: widget.expand ? double.infinity : null,
      height: widget.height + _lip,
      child: GestureDetector(
        onTapDown: (_) => _setDown(true),
        onTapUp: (_) => _setDown(false),
        onTapCancel: () => _setDown(false),
        onTap: _enabled
            ? () {
                HapticFeedback.mediumImpact();
                widget.onPressed!.call();
              }
            : null,
        child: Stack(
          children: [
            // Seri: her zaman en altta durur, buton uzerine biner.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: widget.height,
              child: Container(
                decoration: BoxDecoration(
                  color: lip,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Motion.adapt(
                  context, pressed ? Motion.short2 : Motion.short3),
              curve: pressed ? Motion.emphasizedAccelerate : Motion.overshoot,
              left: 0,
              right: 0,
              top: pressed ? _lip : 0,
              height: widget.height,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget.loading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: widget.foreground,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon,
                                size: 20, color: widget.foreground),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                                color: widget.foreground,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: ExcludeSemantics(child: button),
    );
  }
}
