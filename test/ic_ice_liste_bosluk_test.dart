// Ic ice (shrinkWrap) GridView/ListView kendi dolgusunu sifirlamazsa
// MediaQuery'deki guvenli alani (ust ~59, alt ~34 px) ekliyor; ana sayfada
// "Genel bakis" kartlarinin ustunde ve altinda kocaman bosluk birakiyordu.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ana sayfa genel bakis izgarasi dolgusuz', () {
    final s = File('lib/screens/unified_home_screen.dart').readAsStringSync();
    final i = s.indexOf("_t('Genel bakış'");
    final g = s.indexOf('GridView.count(', i);
    final govde = s.substring(g, s.indexOf('children:', g));
    expect(govde.contains('padding: EdgeInsets.zero'), isTrue);
  });
}
