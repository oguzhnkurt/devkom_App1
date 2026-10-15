import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../../ui/motion.dart';
import '../../../widgets/mascot.dart';
import 'devi_tepkisi.dart';

/// Arkadasin konustugu adim turu.
enum DersArkadasiTuru {
  /// Anlatim, animasyon: "Anladin mi? Devam'a bas".
  anlatim,

  /// Coktan secmeli soru: "Acele etme, dusun bakalim!".
  soru,

  /// Uygulama (surukle-birak, siralama, eslestirme, kod): "Adim adim".
  uygulama,
}

/// Ders adiminin altindaki DEVI ARKADAS.
///
/// NEDEN: kisa adimlar (bir soru ve dort sik, iki paragraflik anlatim)
/// ekranin ust yarisinda bitiyor, alt yari bombos kaliyordu. Devi o
/// bosluga oturuyor: yaninda kisa bir balon, adima gore cesitli bir soz
/// ("Acele etme, dusun bakalim!"). Cevap verilince ayni Devi tepki
/// veriyor (sevinc / "olsun") — ikinci bir Devi cikmiyor.
///
/// CEVAP SIZDIRMIYOR: sozler genel; soruya ozel ipucu yok.
///
/// HAREKET: yavasca suzuluyor, tepkide bir kez zipliyor; "hareketi
/// azalt" acikken ikisi de yok. Dokunmalari yakalamiyor.
///
/// INTRINSIC BOYUT VERIR: ders ekrani bunu `SliverFillRemaining` icinde
/// kullaniyor; icinde LayoutBuilder gibi intrinsic boyut veremeyen bir
/// sey OLMAMALI.
class DersArkadasi extends StatefulWidget {
  const DersArkadasi({
    super.key,
    required this.tur,
    required this.lang,
    required this.renk,
    this.tohum = 0,
    this.tepki,
    this.coktanSecmeli = false,
    this.tepkiNo = 0,
    this.koyu = false,
    this.boyut = 84,
    this.sonAdim = false,
  });

  /// Dersin son adimi: Devi "bitirdin" diyor.
  final bool sonAdim;

  final DersArkadasiTuru tur;
  final String lang;
  final Color renk;

  /// Sozu secen sabit tohum (adimin kimligi).
  final int tohum;

  /// Cevaba tepki; null ise henuz cevap yok.
  final DeviTepkiTuru? tepki;

  /// Tepki coktan secmeli bir soruya mi ("dogrusu yesil olan").
  final bool coktanSecmeli;

  /// Her yeni tepkide artiyor: Devi yeniden zipliyor.
  final int tepkiNo;

  final bool koyu;

  /// Devi'nin boyu.
  final double boyut;

  static const Map<String, List<String>> _soru = {
    'tr': [
      'Acele etme, düşün bakalım! 🤔',
      'Her seçeneği dikkatlice oku.',
      'Emin değil misin? Soruyu bir daha oku.',
      'Sen yaparsın, ben buradayım!',
    ],
    'en': [
      'No rush, have a think! 🤔',
      'Read every option carefully.',
      'Not sure? Read the question again.',
      "You've got this, I'm right here!",
    ],
    'de': [
      'Keine Eile, denk mal nach! 🤔',
      'Lies jede Antwort genau.',
      'Unsicher? Lies die Frage noch mal.',
      'Du schaffst das, ich bin bei dir!',
    ],
    'es': [
      'Sin prisa, ¡piénsalo! 🤔',
      'Lee bien cada opción.',
      '¿No estás seguro? Lee otra vez la pregunta.',
      '¡Tú puedes, aquí estoy contigo!',
    ],
  };

  static const Map<String, List<String>> _anlatim = {
    'tr': [
      'Anladın mı? Devam\'a bas, birlikte deneyelim!',
      'Birazdan bunu birlikte deneyeceğiz!',
      'Kodcular hep böyle başlar! 😊',
      'Bunu kafanda canlandırabiliyor musun?',
    ],
    'en': [
      "Got it? Tap Continue and let's try it together!",
      "We'll try this together in a moment!",
      'This is how every coder starts! 😊',
      'Can you picture it in your head?',
    ],
    'de': [
      'Verstanden? Tippe auf Weiter, wir probieren es aus!',
      'Gleich probieren wir das zusammen aus!',
      'So fängt jeder Coder an! 😊',
      'Kannst du es dir schon vorstellen?',
    ],
    'es': [
      '¿Entendido? Pulsa Continuar y ¡probémoslo juntos!',
      '¡Enseguida lo probamos juntos!',
      '¡Así empieza todo programador! 😊',
      '¿Te lo imaginas en tu cabeza?',
    ],
  };

  static const Map<String, List<String>> _uygulama = {
    'tr': [
      'Adım adım, acele yok!',
      'Takılırsan bir daha dene, sorun değil.',
      'Bunu çözebilirsin! 💪',
    ],
    'en': [
      'Step by step, no rush!',
      "Stuck? Try again, that's okay.",
      'You can solve this! 💪',
    ],
    'de': [
      'Schritt für Schritt, keine Eile!',
      'Hängst du? Versuch es noch mal, kein Problem.',
      'Das schaffst du! 💪',
    ],
    'es': [
      '¡Paso a paso, sin prisa!',
      '¿Atascado? Inténtalo otra vez, no pasa nada.',
      '¡Tú puedes resolverlo! 💪',
    ],
  };

  static const Map<String, String> _son = {
    'tr': 'Son adım! Tamamla\'ya bas, kupa seni bekliyor 🏆',
    'en': 'Last step! Tap Finish, the trophy is waiting 🏆',
    'de': 'Letzter Schritt! Tippe auf Fertig, der Pokal wartet 🏆',
    'es': '¡Último paso! Pulsa Terminar, el trofeo te espera 🏆',
  };

  /// Uygulama adimi bitti ama ilk denemede degil / atlandi.
  static const Map<String, String> _olsun = {
    'tr': 'Olsun! Böyle öğreniyoruz.',
    'en': "That's okay! That's how we learn.",
    'de': 'Macht nichts! So lernen wir.',
    'es': '¡No pasa nada! Así aprendemos.',
  };

  /// Adim turune gore soz (cevaptan once).
  static String soz(DersArkadasiTuru tur, String lang, int tohum) {
    final tablo = switch (tur) {
      DersArkadasiTuru.soru => _soru,
      DersArkadasiTuru.anlatim => _anlatim,
      DersArkadasiTuru.uygulama => _uygulama,
    };
    final liste = tablo[lang] ?? tablo['en']!;
    return liste[tohum.abs() % liste.length];
  }

  /// Butun sozler (dort dil testi icin).
  static Iterable<String> butunSozler(String lang) => [
        ...?_soru[lang],
        ...?_anlatim[lang],
        ...?_uygulama[lang],
        if (_olsun[lang] != null) _olsun[lang]!,
        if (_son[lang] != null) _son[lang]!,
      ];

  /// Ekranda gorunen soz.
  String get metin {
    final t = tepki;
    if (t == null) {
      if (sonAdim && tur == DersArkadasiTuru.anlatim) {
        return _son[lang] ?? _son['en']!;
      }
      return soz(tur, lang, tohum);
    }
    if (t != DeviTepkiTuru.dogru && !coktanSecmeli) {
      return _olsun[lang] ?? _olsun['en']!;
    }
    return DeviTepkisi.soz(t, lang, tohum + tepkiNo);
  }

  @override
  State<DersArkadasi> createState() => _DersArkadasiState();
}

class _DersArkadasiState extends State<DersArkadasi>
    with TickerProviderStateMixin {
  late final AnimationController _suzul = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600));
  late final AnimationController _zipla = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _suzul.stop();
    } else if (!_suzul.isAnimating) {
      _suzul.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(DersArkadasi old) {
    super.didUpdateWidget(old);
    if (widget.tepki != null &&
        (old.tepki != widget.tepki || old.tepkiNo != widget.tepkiNo) &&
        !Motion.reduced(context)) {
      _zipla.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _suzul.dispose();
    _zipla.dispose();
    super.dispose();
  }

  MascotMood get _mood => switch (widget.tepki) {
        DeviTepkiTuru.dogru => MascotMood.happy,
        DeviTepkiTuru.yanlis || DeviTepkiTuru.tekrarDene =>
          MascotMood.encouraging,
        null => widget.tur == DersArkadasiTuru.anlatim
            ? MascotMood.happy
            : MascotMood.thinking,
      };

  Color get _vurgu => switch (widget.tepki) {
        DeviTepkiTuru.dogru => const Color(0xFF2E9E45),
        DeviTepkiTuru.yanlis || DeviTepkiTuru.tekrarDene =>
          const Color(0xFFE08A00),
        null => widget.renk,
      };

  @override
  Widget build(BuildContext context) {
    final metin = widget.metin;
    final koyu = widget.koyu;
    final vurgu = _vurgu;
    final cevapli = widget.tepki != null;

    final devi = AnimatedBuilder(
      animation: Listenable.merge([_suzul, _zipla]),
      builder: (context, child) {
        final s = Curves.easeInOut.transform(_suzul.value);
        final z = _zipla.value;
        final ziplama = math.sin(z * math.pi) * widget.boyut * 0.16;
        final ezilme = 1 + math.sin(z * math.pi * 2) * 0.04;
        return Transform.translate(
          offset: Offset(0, -s * 5 - ziplama),
          child: Transform.scale(scaleY: ezilme, child: child),
        );
      },
      child: Mascot(size: widget.boyut, mood: _mood, showShadow: false),
    );

    // Devi'nin altinda yumusak bir golge: havada suzuldugu belli olsun.
    final golge = AnimatedBuilder(
      animation: _suzul,
      builder: (context, _) {
        final s = Curves.easeInOut.transform(_suzul.value);
        return Container(
          width: widget.boyut * (0.56 - s * 0.08),
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: RadialGradient(
              colors: [
                (koyu ? Colors.black : widget.renk)
                    .withValues(alpha: koyu ? 0.40 : 0.20 - s * 0.05),
                (koyu ? Colors.black : widget.renk).withValues(alpha: 0),
              ],
            ),
          ),
        );
      },
    );

    final balon = AnimatedContainer(
      duration: Motion.medium2,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
      decoration: BoxDecoration(
        color: koyu ? const Color(0xFF22233A) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(6),
        ),
        border: Border.all(
          color: vurgu.withValues(alpha: cevapli ? 0.60 : 0.22),
          width: cevapli ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: vurgu.withValues(alpha: koyu ? 0.0 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: Motion.medium2,
        transitionBuilder: (child, a) => FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(a),
            alignment: Alignment.bottomLeft,
            child: child,
          ),
        ),
        child: Text(
          metin,
          key: ValueKey(metin),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 15.5,
            height: 1.3,
            fontWeight: FontWeight.w800,
            color: koyu ? Colors.white : const Color(0xFF2A3050),
          ),
        ),
      ),
    );

    return IgnorePointer(
      child: Semantics(
        key: const ValueKey('ders_arkadasi'),
        liveRegion: cevapli,
        label: '${Mascot.ad}: $metin',
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RepaintBoundary(child: devi),
                    // Gorselin altinda saydam pay var; golge ayaklara
                    // yaklassin.
                    Transform.translate(
                      offset: Offset(0, -widget.boyut * 0.12),
                      child: golge,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: widget.boyut * 0.45),
                    child: balon,
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
