// "İLERLEMENİ KAYDET" AKIŞINDAKİ KIRMIZI EKRAN.
//
// Şikâyet: "hesap oluştur dedim, mail şifre yazdım, butona bastım kırmızı
// ekran verdi sonra ana sayfaya attı."
//
// Hata: "Looking up a deactivated widget's ancestor is unsafe."
//
// Sebep: RoleBasedHomeScreen, `authProvider.isLoading` true olduğunda TAM
// EKRAN bir yükleme halkası gösteriyordu. `linkAccount()` işin başında
// `_isLoading = true` yapıp dinleyicilere haber veriyor; o anda bütün ev
// ekranı — sekmeler, profil, açık alt sayfa — ağaçtan kalkıyordu. İşlem
// bitince ölü bir context üzerinden çeviri/ScaffoldMessenger aranınca
// uygulama çöküyor ve kullanıcı yeniden kurulan ağaçta ana sayfada
// buluyordu kendini.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final ev =
      File('lib/screens/role_based_home_screen.dart').readAsStringSync();
  final profil =
      File('lib/screens/auth/profile_screen.dart').readAsStringSync();

  String kodu(String s) => s
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//'))
      .join('\n');

  test('arka plandaki yükleme ev ekranını yıkmıyor', () {
    expect(kodu(ev).contains('authProvider.isLoading ||'), isFalse,
        reason: 'isLoading yine tüm ağacı söküyor — hesap bağlama, ilerleme '
            'yenileme gibi her arka plan işi ekranı yok eder.');
    // Ilk acilista kullanici yokken halka yine gorunmeli.
    expect(kodu(ev).contains('if (user == null)'), isTrue);
  });

  test('hesap bağlama işlemi bitince ölü context aranmıyor', () {
    final bas = profil.indexOf('Future<void> _showLinkAccountSheet');
    final govde = profil.substring(bas, profil.indexOf('\n  Widget _buildReportCard', bas));

    // Metinler ve messenger await ONCESINDE aliniyor.
    expect(govde.contains('ScaffoldMessenger.maybeOf(context)'), isTrue);
    final submitBas = govde.indexOf('Future<void> submit()');
    final submitSon = govde.indexOf('return Padding(', submitBas);
    final submit = govde.substring(submitBas, submitSon);
    final awaitIndex = submit.indexOf('await auth.linkAccount');
    expect(awaitIndex, greaterThan(0));

    final awaitSonrasi = submit.substring(awaitIndex);
    expect(awaitSonrasi.contains('_t4(context'), isFalse,
        reason: 'İşlem bittikten sonra context üzerinden çeviri aranıyor.');
    expect(awaitSonrasi.contains('ScaffoldMessenger.of(context)'), isFalse,
        reason: 'İşlem bittikten sonra context üzerinden messenger aranıyor.');
  });
}
