import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sanal Arduino kartı ve ona bağlı üç parça.
///
/// NEDEN KABLO YOK
/// ---------------
/// Önceki ekran gerçek bir breadboard simülatörüydü: delikli devre
/// tahtası, elle çizilen kablolar, 20x12 piksellik pin hedefleri.
/// Telefonda parmakla kablolamak neredeyse imkânsızdı ve ekran
/// kalabalık görünüyordu. Burada parçalar kartla ZATEN bağlı; çocuğun
/// işi kodu kurmak, kablo çekmek değil. Arduino'nun çocuğa verdiği asıl
/// ödül — "yazdığım şey bir şeyi hareket ettirdi" — kablolamada değil,
/// kodun karşılığını görmekte.
///
/// Parçalar büyük ve az sayıda: LED, buzzer, servo. Üçü de tek bakışta
/// okunuyor ve durumları renkle/hareketle belli oluyor.
class ArduinoBoardView extends StatelessWidget {
  final bool ledAcik;

  /// Çalınan nota (örn. "C4"); yoksa buzzer sessiz.
  final String? nota;

  /// Servo açısı 0-180; null ise servo hiç kullanılmadı.
  final double? servoAcisi;

  /// Kod o an çalışıyor mu — kartın güç ışığı buna göre yanıyor.
  final bool calisiyor;

  const ArduinoBoardView({
    super.key,
    this.ledAcik = false,
    this.nota,
    this.servoAcisi,
    this.calisiyor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E5C63),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Güç ışığı — kod çalışırken yeşil.
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: calisiyor
                      ? const Color(0xFF7CFF7C)
                      : Colors.white.withValues(alpha: 0.25),
                  boxShadow: calisiyor
                      ? [
                          const BoxShadow(
                              color: Color(0xFF7CFF7C), blurRadius: 8),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ARDUINO UNO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              _PinSeridi(ledAcik: ledAcik),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _LedKutusu(acik: ledAcik)),
              const SizedBox(width: 10),
              Expanded(child: _BuzzerKutusu(nota: nota)),
              const SizedBox(width: 10),
              Expanded(child: _ServoKutusu(aci: servoAcisi)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartın üstündeki pin başlığı — dekoratif ama 13. pin gerçekten yanıyor.
class _PinSeridi extends StatelessWidget {
  final bool ledAcik;
  const _PinSeridi({required this.ledAcik});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (i) {
        final onuc = i == 7; // sagdaki pin 13'u temsil ediyor
        return Container(
          width: 5,
          height: 12,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            color: onuc && ledAcik
                ? const Color(0xFFFFD54F)
                : Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

/// Ortak parça kutusu: koyu zemin, ikon, altında etiket.
class _Parca extends StatelessWidget {
  final Widget gorsel;
  final String etiket;
  final bool vurgulu;

  const _Parca({
    required this.gorsel,
    required this.etiket,
    this.vurgulu = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: vurgulu
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: vurgulu
              ? Colors.white.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.10),
          width: 1.4,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 38, child: Center(child: gorsel)),
          const SizedBox(height: 6),
          Text(
            etiket,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedKutusu extends StatelessWidget {
  final bool acik;
  const _LedKutusu({required this.acik});

  @override
  Widget build(BuildContext context) {
    return _Parca(
      etiket: 'LED · pin 13',
      vurgulu: acik,
      gorsel: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: acik ? 30 : 24,
        height: acik ? 30 : 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: acik ? const Color(0xFFFFD54F) : const Color(0xFF5A6B6E),
          boxShadow: acik
              ? [
                  const BoxShadow(
                      color: Color(0xAAFFD54F), blurRadius: 22, spreadRadius: 4),
                ]
              : null,
        ),
      ),
    );
  }
}

class _BuzzerKutusu extends StatelessWidget {
  final String? nota;
  const _BuzzerKutusu({required this.nota});

  @override
  Widget build(BuildContext context) {
    final calan = nota != null;
    return _Parca(
      etiket: 'Buzzer · pin 8',
      vurgulu: calan,
      gorsel: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            calan ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
            color: calan ? const Color(0xFF7CFF7C) : const Color(0xFF5A6B6E),
            size: 26,
          ),
          if (calan)
            Text(
              nota!,
              style: const TextStyle(
                color: Color(0xFF7CFF7C),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _ServoKutusu extends StatelessWidget {
  final double? aci;
  const _ServoKutusu({required this.aci});

  @override
  Widget build(BuildContext context) {
    final hareketli = aci != null;
    return _Parca(
      etiket: 'Servo · pin 9',
      vurgulu: hareketli,
      gorsel: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        tween: Tween(begin: 0, end: aci ?? 0),
        builder: (context, deger, _) => CustomPaint(
          size: const Size(38, 38),
          painter: _ServoCizer(
            aci: deger,
            renk: hareketli
                ? const Color(0xFFFF8A65)
                : const Color(0xFF5A6B6E),
          ),
        ),
      ),
    );
  }
}

/// Servo kolunu çizer: yarım daire gövde + açıya dönen kol.
class _ServoCizer extends CustomPainter {
  final double aci;
  final Color renk;

  _ServoCizer({required this.aci, required this.renk});

  @override
  void paint(Canvas canvas, Size size) {
    final merkez = Offset(size.width / 2, size.height * 0.78);
    final yaricap = size.width * 0.42;

    final govde = Paint()
      ..color = renk.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: merkez, radius: yaricap),
      math.pi,
      math.pi,
      true,
      govde,
    );

    // 0 derece solu, 180 derece sagi gosteriyor.
    final radyan = math.pi - (aci.clamp(0, 180) / 180) * math.pi;
    final uc = Offset(
      merkez.dx + yaricap * math.cos(radyan),
      merkez.dy - yaricap * math.sin(radyan),
    );
    final kol = Paint()
      ..color = renk
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(merkez, uc, kol);
    canvas.drawCircle(merkez, 3.2, Paint()..color = renk);
  }

  @override
  bool shouldRepaint(covariant _ServoCizer old) =>
      old.aci != aci || old.renk != renk;
}
