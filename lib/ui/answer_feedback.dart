import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'motion.dart';
import 'press_button.dart';

/// Cevap sonucunun rengi ve metni.
enum AnswerResult { correct, wrong }

/// Cevabin dogru/yanlis oldugunu soyleyen alt serit.
///
/// Uygulamada bugune kadar bunun yerine `showDialog` ile ortaya bir
/// `AlertDialog` aciliyordu. Uc sorunu vardi: (1) ekranin ortasinda beliren
/// bir kutu sorunun kendisini kapatiyor, cocuk neyi yanlis yaptigini
/// goremiyordu; (2) her seferinde "Tamam"a basmak akisi kesiyordu; (3) her
/// oyun kendi dialogunu yazdigi icin ayni an ekranin her yerinde farkli
/// gorunuyordu.
///
/// Serit sorunun ustune degil altina biniyor, sorunun kendisi ekranda kaliyor
/// ve devam butonu parmagin zaten oldugu yerde cikiyor. Yanlista dogru cevap
/// da yaziliyor — ogrenme aninin tamami burada.
///
/// Renk tek basina anlam tasimiyor: her durumda bir ikon ve metin de var
/// (renk korlugu icin gereklilik).
class AnswerFeedbackBar extends StatelessWidget {
  const AnswerFeedbackBar({
    super.key,
    required this.result,
    required this.onContinue,
    this.title,
    this.detail,
    this.continueLabel,
    this.inline = false,
  });

  final AnswerResult result;
  final VoidCallback onContinue;

  /// Bos birakilirsa sonuca gore varsayilan baslik kullanilir.
  final String? title;

  /// Yanlista dogru cevap, dogruda kisa bir tebrik/aciklama.
  final String? detail;

  final String? continueLabel;

  /// Ekranin altina sabitlenmis serit yerine, akisin icinde duran bir kart
  /// olarak ciz. Ders adimlarinda kullaniyoruz: orada icerik zaten
  /// kaydiriliyor ve alta yapisan bir serit sorunun ustune biniyor.
  final bool inline;

  static const Color _correctInk = Color(0xFF2E7D32);
  static const Color _correctBg = Color(0xFFE8F6E9);
  static const Color _wrongInk = Color(0xFFC62828);
  static const Color _wrongBg = Color(0xFFFDECEC);

  bool get _ok => result == AnswerResult.correct;

  @override
  Widget build(BuildContext context) {
    final ink = _ok ? _correctInk : _wrongInk;
    final bg = _ok ? _correctBg : _wrongBg;

    final body = Padding(
      padding: EdgeInsets.fromLTRB(inline ? 16 : 20, 16, inline ? 16 : 20, 12),
      child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: ink,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? (_ok ? 'Doğru!' : 'Bu sefer olmadı'),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                        if (detail != null && detail!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            detail!,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                              color: ink.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              PressButton(
                label: continueLabel ?? (_ok ? 'Devam' : 'Anladım'),
                color: ink,
                onPressed: onContinue,
                height: 50,
              ),
            ],
          ),
    );

    if (inline) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ink.withValues(alpha: 0.25)),
        ),
        child: body,
      );
    }

    return Container(
      width: double.infinity,
      color: bg,
      child: SafeArea(top: false, child: body),
    );
  }

  /// Seridi ekranin altina, iceri kayarak yerlestiren sarmalayici.
  ///
  /// `AnimatedSwitcher` kullanmiyoruz: serit ic icgeriktekinden bagimsiz
  /// yukseklige sahip ve switcher gecis sirasinda ikisini de olcup zipliyordu.
  static Widget host({
    required Widget child,
    required Widget? bar,
  }) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            duration: Motion.short4,
            curve: Motion.emphasizedDecelerate,
            offset: bar == null ? const Offset(0, 1) : Offset.zero,
            child: AnimatedOpacity(
              duration: Motion.short4,
              opacity: bar == null ? 0 : 1,
              child: bar ?? const SizedBox(width: double.infinity),
            ),
          ),
        ),
      ],
    );
  }

  /// Cevap gonderildiginde titresim. Dogru ve yanlisin dokunsal imzasi
  /// farkli olsun ki cocuk ekrana bakmadan da anlasin.
  static void haptic(AnswerResult result) {
    if (result == AnswerResult.correct) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }
}

/// [trigger] her degistiginde icerigini yatayda sallar.
///
/// Yanlis cevapta kullaniyoruz: cocuk hangi alanin yanlis oldugunu renkten
/// once hareketten anliyor.
class ShakeOnChange extends StatefulWidget {
  const ShakeOnChange({
    super.key,
    required this.trigger,
    required this.child,
    this.enabled = true,
  });

  /// Degeri her degistiginde sallama tetiklenir.
  final Object? trigger;
  final Widget child;
  final bool enabled;

  @override
  State<ShakeOnChange> createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<ShakeOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.medium2,
  );

  @override
  void didUpdateWidget(covariant ShakeOnChange old) {
    super.didUpdateWidget(old);
    if (widget.enabled &&
        widget.trigger != null &&
        widget.trigger != old.trigger &&
        !Motion.reduced(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        if (_c.value == 0) return child!;
        // Sonune dogru sonen uc salinim: sert baslayip yumusak biten bir
        // "hayir" hareketi.
        final decay = 1 - _c.value;
        final dx = 8 * decay * _sin3(_c.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }

  /// Uc tam salinim.
  static double _sin3(double t) => math.sin(2 * math.pi * 3 * t);
}
