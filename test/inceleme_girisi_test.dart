// GOOGLE PLAY INCELEME GIRISI (6 Kasim 2026)
//
// 1.0.18 (29) Play'de "App content is restricted by a paywall" ile reddedildi:
// inceleyici odeme ekranini gecemiyordu. Apple sandbox ile deneme alabiliyor,
// Google inceleyicisi alamiyor. Cozum: odeme ekrani -> Hesap -> "Giris yap"
// ile inceleme hesabina (sureli hediye Pro) giris; giristen sonra AuthWrapper
// abonelik kapisini yeniden calistiriyor.
//
// Ayrica: giris/kayit sonrasi dogrudan RoleBasedHomeScreen'e gitmek kapiyi
// atliyordu. Bu testler o yolun geri gelmesini engelliyor.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String kodu(String yol) => File(yol)
      .readAsStringSync()
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//'))
      .join('\n');

  test('anonim kullanici Hesap ekranindan giris yapabiliyor', () {
    final k = kodu('lib/screens/auth/hesap_ekrani.dart');
    expect(k.contains('if (auth.isAnonymous) ...['), isTrue);
    expect(k.contains("'Giriş yap', 'Sign in', 'Anmelden'"), isTrue);
    expect(k.contains('builder: (_) => const LoginScreen()'), isTrue);
  });

  test('odeme ekraninda Hesap baglantisi ve donuste yeniden kontrol var', () {
    final k = kodu('lib/screens/subscription_screen.dart');
    expect(k.contains('HesapEkrani()'), isTrue);
    expect(k.contains('widget.yenidenKontrol?.call()'), isTrue);
  });

  test('giris ve kayit abonelik kapisini atlamiyor', () {
    for (final yol in [
      'lib/screens/auth/login_screen.dart',
      'lib/screens/auth/register_screen.dart',
    ]) {
      final k = kodu(yol);
      expect(k.contains('RoleBasedHomeScreen()'), isFalse,
          reason: '$yol giristen sonra kapiyi atlayip ana ekrana gidiyor.');
      expect(k.contains('const AuthWrapper()'), isTrue, reason: yol);
    }
  });

  test('ana ekran yalniz kapinin arkasinda', () {
    final k = kodu('lib/screens/auth/auth_wrapper.dart');
    expect(k.contains('AbonelikKapisi(child: RoleBasedHomeScreen())'), isTrue);
  });

  test('hediye Pro kapiyi aciyor (inceleme hesabi bununla giriyor)', () {
    final k = kodu('lib/screens/auth/abonelik_kapisi.dart');
    expect(k.contains('sureliHediyeVar(user, DateTime.now())'), isTrue);
  });
}
