// Uygulama ici degerlendirme: "tadinda" sorma kurallari.
import 'dart:io';

import 'package:devkom_app/services/degerlendirme_servisi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final s = DegerlendirmeServisi.instance;
  late DateTime saat;
  late int acilan;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    s.sifirla();
    saat = DateTime(2026, 10, 1, 12);
    acilan = 0;
    s.simdi = () => saat;
    s.kullanilabilirMi = () async => true;
    s.kutuyuAc = () async => acilan++;
  });
  tearDown(s.sifirla);

  Future<void> basari(int n) async {
    for (var i = 0; i < n; i++) {
      await s.basariKaydet();
    }
  }

  test('yeni kullaniciya sorulmuyor: az basari ya da ilk gun', () async {
    await s.baslat();
    await basari(10);
    expect(s.bekliyor, isFalse, reason: 'ilk acilistan 2 gun gecmedi');

    saat = saat.add(const Duration(days: 3));
    SharedPreferences.setMockInitialValues({
      'degerlendirme_ilk_acilis': DateTime(2026, 10, 1).toIso8601String(),
    });
    await basari(DegerlendirmeServisi.enAzBasari - 1);
    expect(s.bekliyor, isFalse, reason: 'basari sayisi az');
    await basari(1);
    expect(s.bekliyor, isTrue);
  });

  test('kutu yalnizca gecis aninda aciliyor; sonra 120 gun sorulmuyor', () async {
    await s.baslat();
    saat = saat.add(const Duration(days: 3));
    await basari(4);
    expect(acilan, 0, reason: 'basari aninda acilmaz');
    expect(await s.bekliyorsaGoster(), isTrue);
    expect(acilan, 1);
    expect(s.bekliyor, isFalse);

    await basari(5);
    expect(s.bekliyor, isFalse, reason: 'ara sure dolmadi');

    saat = saat.add(const Duration(days: DegerlendirmeServisi.araGun + 1));
    await basari(1);
    expect(s.bekliyor, isTrue);
  });

  test('toplamda en fazla 3 kez', () async {
    await s.baslat();
    for (var i = 0; i < 5; i++) {
      saat = saat.add(const Duration(days: DegerlendirmeServisi.araGun + 3));
      await basari(4);
      await s.bekliyorsaGoster();
    }
    expect(acilan, DegerlendirmeServisi.enFazlaSorma);
  });

  test('magaza kutuyu desteklemiyorsa sayilmiyor', () async {
    s.kullanilabilirMi = () async => false;
    await s.baslat();
    saat = saat.add(const Duration(days: 3));
    await basari(4);
    expect(await s.bekliyorsaGoster(), isFalse);
    expect(acilan, 0);
  });

  test('kutudan once soru yok; reklamla ayni gecise binmiyor', () {
    final kaynak = File('lib/services/degerlendirme_servisi.dart').readAsStringSync();
    expect(kaynak.contains('sevdin mi?"'), isTrue,
        reason: 'aciklamada kural yazili olmali');
    final gozlemci = File('lib/services/ad_navigator_observer.dart').readAsStringSync();
    final i = gozlemci.indexOf('DegerlendirmeServisi.instance.bekliyor');
    final j = gozlemci.indexOf('showInterstitialIfDue');
    expect(i, greaterThan(0));
    expect(i, lessThan(j), reason: 'once degerlendirme, varsa reklam atlanir');
    // Ayarlar satiri kutuyu degil magazayi aciyor.
    final ayar = File('lib/screens/settings/settings_screen.dart').readAsStringSync();
    expect(ayar.contains('magazaSayfasiniAc'), isTrue);
    expect(ayar.contains('requestReview'), isFalse);
  });
}
