// Pro bilgisi nerede durur (Ekim 2026).
//
// Ana sayfadaki "Kilitli olan her sey acilsin · Planlari gor" karti
// kaldirildi: cocugun her gun actigi ekranda satis cagrisi durmamali
// (Apple 1.3, Google Families). Pro bilgisi Profil > Hesap Islemleri'nde,
// EBEVEYN KAPISININ arkasinda. Kartta/satirda sabit fiyat da yok: fiyatin
// tek dogru kaynagi StoreKit ve onu paywall ekrani gosteriyor.
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

  test('profilde Pro satiri ebeveyn kapisinin arkasinda', () {
    final i = profil.indexOf("ValueKey('profil_pro_ebeveyn')");
    expect(i, greaterThan(0));
    final blok = profil.substring(i, profil.indexOf('SubscriptionScreen()', i));
    expect(blok.contains('ParentGate.verify'), isTrue);
    expect(blok.contains('if (!ok'), isTrue);
  });

  test('Pro kullaniciya satir cizilmiyor ve fiyat yazmiyor', () {
    final i = profil.indexOf("ValueKey('profil_pro_ebeveyn')");
    final once = profil.substring(i - 400, i);
    expect(once.contains('if (!ProGate.watchIsPro(context))'), isTrue);
    final blok = profil.substring(i, i + 1600);
    final money = RegExp(r'(\$|€|£|₺)\s?\d+[.,]?\d*|\d+[.,]\d{2}\s?(\$|€|£|₺|USD|EUR|TRY|TL)');
    expect(money.hasMatch(blok), isFalse);
  });
}
