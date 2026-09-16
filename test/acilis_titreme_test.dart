import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Acilis akisindaki titremeye karsi kurallar.
///
/// Belirti: "Sana nasil seslenelim?" sayfasinda metin kutusuna
/// dokunulunca basliklar titriyor, sonraki sayfada yazilar durmadan
/// yeniden beliriyordu.
///
/// Sebep bir animasyon degil, bir BAGIMLILIK hatasiydi:
/// `MediaQuery.of` / `MediaQuery.maybeOf` widget'i MediaQueryData'nin
/// tamamina abone ediyor. Klavye acilirken `viewInsets` her karede
/// degisiyor; basligin her kelimesi, alt yazi ve sayfa gecisi saniyede
/// 60 kez bastan kuruluyordu.
///
/// Bu test gorsel bir seyi degil, o bagimliligin geri gelmemesini
/// sinar — hatanin kendisi ekran goruntusunde gorunmuyor, kodda
/// goruluyor.
String _kodu(String yol) => File(yol)
    .readAsLinesSync()
    .where((s) => !s.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  test('Motion.reduced butun MediaQuery\'ye abone olmuyor', () {
    final kod = _kodu('lib/ui/motion.dart');
    expect(kod.contains('MediaQuery.maybeOf'), isFalse);
    expect(kod.contains('maybeDisableAnimationsOf'), isTrue);
  });

  test('tanitim karuseli olcu ve bosluklari tek tek okuyor', () {
    final kod = _kodu('lib/screens/auth/intro_carousel.dart');
    expect(kod.contains('MediaQuery.of(context)'), isFalse,
        reason: 'sizeOf / paddingOf / viewInsetsOf kullanilmali.');
    expect(kod.contains('MediaQuery.sizeOf'), isTrue);
    expect(kod.contains('MediaQuery.paddingOf'), isTrue);
  });

  test('panel yuksekligi zıplamiyor', () {
    final kod = _kodu('lib/screens/auth/intro_carousel.dart');
    // Yukseklik dogrudan SizedBox'a verilirse ileri tusuna basildigi
    // anda ziplar; icerik ise gecisin ortasina kadar hala eski sayfadir.
    // Ortaya "eski yazi + yeni panel" diye melez bir kare cikiyor ve
    // kullanici bunu araya giren ucuncu bir sayfa olarak goruyor.
    expect(kod.contains('Tween(begin: height, end: height)'), isTrue,
        reason: 'Panel yuksekligi panelin rengiyle ayni surede suzulmeli.');
  });

  test('sayfa gecisi agacin seklini degistirmiyor', () {
    final kod = _kodu('lib/screens/auth/intro_carousel.dart');
    // Eski surum gecisin basinda ve sonunda dogrudan `widget.child`
    // donuyor, arada sarmaliyordu. Ayni slot'ta farkli bir widget
    // zinciri bulan Flutter icerigin State'ini bastan kuruyor ve
    // baslik kelime kelime BIR DAHA beliriyordu.
    final govde = kod.substring(kod.indexOf('class _PageSwapState'));
    expect(govde.contains('if (t == 0 || t == 1) return widget.child;'),
        isFalse);
    // Icerik AnimatedBuilder'in `child` parametresinden geciyor: gecisin
    // her karesinde sayfa yeniden KURULMUYOR.
    expect(govde.contains('builder: (context, child)'), isTrue);
  });
}
