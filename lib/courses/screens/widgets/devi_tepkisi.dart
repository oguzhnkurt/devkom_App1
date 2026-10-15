import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../../ui/motion.dart';
import '../../../widgets/mascot.dart';

/// Devi'nin cevaba tepkisi hangi tur.
enum DeviTepkiTuru {
  /// Dogru cevap / dogru program.
  dogru,

  /// Yanlis ama tekrar denenebilir (blok kurma).
  tekrarDene,

  /// Yanlis ve soru kapandi (coktan secmeli): dogrusu ekranda.
  yanlis,
}

/// Devi'nin kucuk tepkisi: soldaki kucuk Devi zipliyor, yaninda kisa bir
/// balon ("Super!", "Neredeyse! Bir daha dene").
///
/// KUCUK VE ENGELLEMEYEN: hicbir dokunusu yakalamiyor, yerlesimi
/// itmiyor (sabit yukseklik), kendi kendine kaybolmuyor (cocuk okumadan
/// gitmesin) ama bir sonraki cevapta yenisiyle degisiyor.
///
/// CESITLI: ayni soz arka arkaya gelmesin diye soz [tohum] ile seciliyor
/// (adimin kimligi + deneme sayisi). Ayni tohum hep ayni sozu veriyor:
/// test edilebilir ve geri gelince degismiyor.
///
/// SUCLAMA YOK: yanlis cevapta da Devi neseli ([MascotMood.encouraging]),
/// sozler "olsun, bir daha" diyor.
class DeviTepkisi extends StatelessWidget {
  const DeviTepkisi({
    super.key,
    required this.tur,
    required this.lang,
    this.tohum = 0,
    this.koyu = false,
  });

  final DeviTepkiTuru tur;
  final String lang;
  final int tohum;
  final bool koyu;

  static const Map<String, List<String>> _dogru = {
    'tr': ['Süper!', 'Tam isabet!', 'Harikasın!', 'İşte bu!', 'Bravo, kodcu!'],
    'en': ['Super!', 'Spot on!', "You're awesome!", "That's it!", 'Bravo, coder!'],
    'de': ['Super!', 'Volltreffer!', 'Klasse!', 'Genau so!', 'Bravo, Coder!'],
    'es': ['¡Súper!', '¡En el blanco!', '¡Eres genial!', '¡Eso es!', '¡Bravo, programador!'],
  };

  static const Map<String, List<String>> _tekrar = {
    'tr': [
      'Neredeyse! Bir daha dene',
      'Az kaldı, sen yaparsın!',
      'Hata yapmak öğrenmektir. Tekrar dene!',
      'Bir daha bakalım, olacak!',
    ],
    'en': [
      'Almost! Try again',
      'So close, you can do it!',
      'Mistakes help us learn. Try again!',
      "Let's look again, you've got this!",
    ],
    'de': [
      'Fast! Versuch es noch mal',
      'Knapp daneben, du schaffst das!',
      'Aus Fehlern lernt man. Noch mal!',
      'Schau noch mal hin, das klappt!',
    ],
    'es': [
      '¡Casi! Inténtalo otra vez',
      '¡Muy cerca, tú puedes!',
      'Equivocarse ayuda a aprender. ¡Otra vez!',
      'Miremos otra vez, ¡lo lograrás!',
    ],
  };

  static const Map<String, List<String>> _yanlis = {
    'tr': [
      'Olsun! Açıklamaya bir bak',
      'Neredeyse! Doğrusu yeşil olan',
      'Böyle öğreniyoruz. Hadi devam!',
    ],
    'en': [
      'No worries! Check the explanation',
      'Almost! The green one is right',
      "That's how we learn. Let's go on!",
    ],
    'de': [
      'Macht nichts! Lies die Erklärung',
      'Fast! Die grüne ist richtig',
      'So lernen wir. Weiter geht’s!',
    ],
    'es': [
      '¡No pasa nada! Mira la explicación',
      '¡Casi! La verde es la correcta',
      'Así aprendemos. ¡Sigamos!',
    ],
  };

  /// Bu tepkinin sozu (test ve ekran okuyucu icin de).
  static String soz(DeviTepkiTuru tur, String lang, int tohum) {
    final tablo = switch (tur) {
      DeviTepkiTuru.dogru => _dogru,
      DeviTepkiTuru.tekrarDene => _tekrar,
      DeviTepkiTuru.yanlis => _yanlis,
    };
    final liste = tablo[lang] ?? tablo['en']!;
    return liste[tohum.abs() % liste.length];
  }

  /// Butun sozler (dort dil testi icin).
  static Iterable<String> butunSozler(String lang) => [
        ...?_dogru[lang],
        ...?_tekrar[lang],
        ...?_yanlis[lang],
      ];

  @override
  Widget build(BuildContext context) {
    final dogru = tur == DeviTepkiTuru.dogru;
    final vurgu = dogru ? const Color(0xFF2E9E45) : const Color(0xFFE08A00);
    final metin = soz(tur, lang, tohum);
    final azalt = Motion.reduced(context);

    Widget devi = Mascot(
      size: 46,
      mood: dogru ? MascotMood.happy : MascotMood.encouraging,
      showShadow: false,
    );
    if (!azalt) {
      // Ziplama: kucukten buyuge yaylanarak (her yeni tepkide bastan,
      // cunku cagiran her cevapta yeni bir anahtar veriyor).
      devi = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 650),
        builder: (context, t, child) {
          final ziplama = Curves.elasticOut.transform(t);
          return Transform.translate(
            offset: Offset(0, (1 - ziplama) * 14),
            child: Transform.scale(scale: 0.7 + 0.3 * ziplama, child: child),
          );
        },
        child: devi,
      );
    }

    final balon = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: koyu ? const Color(0xFF26263A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: vurgu.withValues(alpha: 0.55), width: 2),
        boxShadow: [
          BoxShadow(
            color: vurgu.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        metin,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 14.5,
          height: 1.25,
          fontWeight: FontWeight.w800,
          color: koyu ? Colors.white : const Color(0xFF1F2430),
        ),
      ),
    );

    return IgnorePointer(
      child: Semantics(
        liveRegion: true,
        label: '${Mascot.ad}: $metin',
        child: ExcludeSemantics(
          child: SizedBox(
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RepaintBoundary(child: devi),
                const SizedBox(width: 8),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: azalt
                        ? balon
                        : TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Motion.medium4,
                            curve: Motion.emphasizedDecelerate,
                            builder: (context, t, child) => Opacity(
                              opacity: t,
                              child: Transform.translate(
                                  offset: Offset(-10 * (1 - t), 0),
                                  child: child),
                            ),
                            child: balon,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
