// Anlatim metnindeki kod satirlari ayri bir kod panelinde ciziliyor;
// duz yazi paragraflari kod sayilmamali.
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/screens/widgets/anlatim_kodu.dart';

void main() {
  test('Ornek: basligi yazi, altindaki satirlar kod', () {
    final p = AnlatimKodu.ayir('Example:\nprint("Hello")\nprint(\'Hi\')');
    expect(p, hasLength(2));
    expect(p[0].kod, isFalse);
    expect(p[0].metin, 'Example:');
    expect(p[1].kod, isTrue);
    expect(p[1].metin, 'print("Hello")\nprint(\'Hi\')');
  });

  test('girintili Python blogu tek parca kod, girinti korunuyor', () {
    final p = AnlatimKodu.ayir(
        'try:\n    x = int(input())\nexcept ValueError:\n    print("No")');
    expect(p.single.kod, isTrue);
    expect(p.single.metin, contains('    x = int(input())'));
  });

  test('Java, HTML ve CSS taniniyor', () {
    expect(AnlatimKodu.ayir('System.out.println("A");').single.kod, isTrue);
    expect(AnlatimKodu.ayir('<ul>\n  <li>Apple</li>\n</ul>').single.kod,
        isTrue);
    expect(AnlatimKodu.ayir('div {\n  color: red;\n}').single.kod, isTrue);
  });

  test('duz yazi kod sayilmiyor', () {
    for (final m in [
      'You want Devi to walk 100 steps. Do you have to write it out one by one?',
      'elif (else if) checks other conditions:',
      'range() creates a sequence of numbers:',
      'Semantic = meaningful.',
      '✓ You learned the print() command',
      'int: whole number (12, -5, 100)\ndouble: decimal number (3.14, 1.45)',
    ]) {
      final p = AnlatimKodu.ayir(m);
      expect(p.single.kod, isFalse, reason: m);
      expect(p.single.metin, m);
    }
  });

  test('kod paneli dil etiketi', () {
    expect(AnlatimKodu.dil('python'), 'python');
    expect(AnlatimKodu.dil('csharp'), 'c#');
    expect(AnlatimKodu.dil('scratch'), isNull);
  });
}
