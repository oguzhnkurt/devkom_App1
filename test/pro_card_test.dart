// Pro bilgisi nerede durur (Ekim 2026).
//
// Ana sayfadaki Pro satis karti kaldirildi: cocugun her gun actigi ekranda
// satis cagrisi durmamali. Pro bilgisi Profil > Hesap Islemleri'nde.
// Ebeveyn kapisi (dogum yili) da kalkti: uygulama Kids Category'de degil;
// satira dokununca dogrudan odeme ekrani aciliyor. Satirda sabit fiyat
// yok: fiyatin tek dogru kaynagi StoreKit ve onu paywall gosteriyor.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ana = File('lib/screens/unified_home_screen.dart').readAsStringSync();
  final profil = File('lib/screens/auth/profile_screen.dart').readAsStringSync();

  test('ana sayfada Pro satis karti yok', () {
    expect(ana.contains('_buildProCard'), isFalse);
    expect(ana.contains('SubscriptionScreen'), isFalse,
        reason: 'ana sayfa dogrudan odeme ekranina gidiyor');
  });

  test('profildeki Pro satiri dogrudan odeme ekranini aciyor', () {
    final i = profil.indexOf("ValueKey('profil_pro_satiri')");
    expect(i, greaterThan(0));
    final blok = profil.substring(i, profil.indexOf('SubscriptionScreen()', i));
    expect(blok.contains('ParentGate'), isFalse);
    expect(profil.contains('ParentGate.verify'), isFalse);
  });

  test('Pro kullaniciya satir cizilmiyor ve fiyat yazmiyor', () {
    final i = profil.indexOf("ValueKey('profil_pro_satiri')");
    final once = profil.substring(i - 700, i);
    expect(once.contains('if (!ProGate.watchIsPro(context))'), isTrue);
    final blok = profil.substring(i, i + 600);
    final money = RegExp(r'(\$|€|£|₺)\s?\d+[.,]?\d*|\d+[.,]\d{2}\s?(\$|€|£|₺|USD|EUR|TRY|TL)');
    expect(money.hasMatch(blok), isFalse);
  });
}
