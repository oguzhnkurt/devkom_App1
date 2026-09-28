// Uygulama ilk karesini doğru dille çizmeli.
//
// SORUN NEYDİ
// -----------
// `SettingsProvider` dili şöyle başlatıyordu:
//
//     Locale _locale = const Locale('tr', 'TR');
//
// Gerçek dil ise `_loadSettings()` ile SharedPreferences'tan ASENKRON
// geliyordu. Arada geçen kareler boyunca uygulama Türkçeydi — dili
// İngilizce olan bir kullanıcı için de.
//
// O kareler uygulamanın ilk gördüğü yüzü: açılış ekranı. Kullanıcı
// İngilizce seçmiş olmasına rağmen açılışta Türkçe bir metin okuyordu.
// Ekran kısa ömürlü olduğu için hata "bazen oluyor" gibi görünüyordu;
// oysa HER açılışta oluyordu.
//
// İki katmanlı düzeltme:
//   1. Başlangıç değeri artık sabit Türkçe değil, cihazın dili
//      (senkron okunabiliyor).
//   2. Kayıtlı tercih `main()` içinde `runApp`ten ÖNCE okunup
//      sağlanıyor; böylece cihazı Türkçe olup uygulamada İngilizce
//      seçmiş kullanıcı da parlama görmüyor.
import 'dart:io';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('baslangic dili sabit Turkce degil', () {
    final src =
        File('lib/providers/settings_provider.dart').readAsStringSync();

    expect(src.contains("Locale _locale = const Locale('tr', 'TR')"), isFalse,
        reason: 'Baslangic dili yine sabit Turkce. Ingilizce kullanici '
            'acilis ekraninda Turkce metin gorur.');
  });

  test('verilen dil ILK KAREDE gecerli, beklemeden', () {
    // Asenkron yukleme beklenmeden okunuyor: ilk kare bu degeri kullanir.
    final p = SettingsProvider(baslangicDili: const Locale('en', 'US'));
    expect(p.locale.languageCode, 'en',
        reason: 'Saglanan dil ilk karede gecerli degil; acilis ekrani '
            'yanlis dille cizilir.');
  });

  test('dil verilmezse cihazin diline dusuyor, Turkceye degil', () {
    // Test ortaminda cihaz dili en_US. Sabit 'tr' donerse hata budur.
    final p = SettingsProvider();
    expect(p.locale.languageCode, isNot('tr'),
        reason: 'Dil verilmediginde yine Turkce donuyor.');
  });

  test('main kayitli dili runApp oncesi okuyor', () {
    final src = File('lib/main.dart').readAsStringSync();

    // `runApp(` uc kez geciyor: ikisi acilis hatasi dali. Asil olan
    // uygulamayi baslatan cagri.
    final runAppYeri = src.indexOf('runApp(DevkomApp(');
    final okumaYeri = src.indexOf("getString('language_code')");

    expect(runAppYeri, greaterThan(0),
        reason: 'runApp(DevkomApp(...)) bulunamadi; bicim degismis.');

    expect(okumaYeri, greaterThan(0),
        reason: 'main() kayitli dili hic okumuyor.');
    expect(okumaYeri, lessThan(runAppYeri),
        reason: 'Kayitli dil runApp SONRASI okunuyor; ilk kareler yine '
            'yanlis dille cizilir.');
    expect(src.contains('baslangicDili'), isTrue,
        reason: 'Okunan dil SettingsProvider\'a verilmiyor.');
  });
}
