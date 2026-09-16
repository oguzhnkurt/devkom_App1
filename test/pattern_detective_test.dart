// Desen Dedektifi icin kaynak okuyan koruma testleri.
//
// Sekil, renk ve sembol seviyelerinde (9-20) CIKARILABILIR BIR KURAL
// YOKTU: `pattern` yalnizca listenin ilk 2-3 ogesiydi, dogru cevap da bir
// sonraki ogeydi. Yani cocuktan koddaki gizli sirayi bilmesi
// bekleniyordu — ipucu "sıra tekrar ediyor" dedigi halde tekrar eden
// hicbir sey yoktu.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _yol = 'lib/screens/games/pattern_detective_game_screen.dart';

void main() {
  late String kaynak;
  setUpAll(() => kaynak = File(_yol).readAsStringSync());

  test('sekil/renk/sembol desenleri gercekten tekrar ediyor', () {
    // Eski uretici: pattern.add('shape_${i % shapes.length}')
    expect(RegExp(r"pattern\.add\('shape_\$\{i % shapes\.length\}'\)")
        .hasMatch(kaynak), isFalse);
    expect(RegExp(r"pattern\.add\('color_\$\{i % colors\.length\}'\)")
        .hasMatch(kaynak), isFalse);
    expect(RegExp(r'pattern\.add\(symbols\[i % symbols\.length\]\)')
        .hasMatch(kaynak), isFalse);
    expect(kaynak.contains('void _dongulukDesenKur('), isTrue);
    // Uc uretici de ayni yardimciyi kullaniyor mu?
    expect('_dongulukDesenKur('.allMatches(kaynak).length, greaterThanOrEqualTo(4));
  });

  test('ekranda en az iki tur gorunuyor', () {
    // Iki ogelik dongude 4, uc ogelikte 5 oge gosteriliyor: kural ancak
    // boyle cikarilabilir.
    final i = kaynak.indexOf('void _dongulukDesenKur(');
    final govde = kaynak.substring(i, i + 1400);
    expect(govde.contains('donguBoyu == 2 ? 4 : 5'), isTrue);
    expect(govde.contains('dongu[gorunen % donguBoyu]'), isTrue);
  });

  test('yanlis secenekler dongunun obur ogelerini de iceriyor', () {
    final i = kaynak.indexOf('void _dongulukDesenKur(');
    final govde = kaynak.substring(i, i + 1400);
    expect(govde.contains('for (final o in dongu)'), isTrue,
        reason: 'En cezbedici yanlis, dongunun obur ogesidir.');
  });

  test('ipucu ve yonerge dort dilde', () {
    // Ikisi de yalnizca Turkce/Ingilizce idi.
    expect(kaynak.contains('if (_isEn) {'), isFalse);
    expect(kaynak.contains('bool get _isEn'), isFalse);
    expect(kaynak.contains('Tipp: Die Reihenfolge der Formen wiederholt sich!'),
        isTrue);
    expect(kaynak.contains('Completa el patrón de colores'), isTrue);
  });
}
