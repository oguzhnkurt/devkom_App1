// Reklamlari SESSIZCE kapatan iki hata, iki test.
//
// 1) SURESI DOLMUS ABONE SONSUZA KADAR REKLAMSIZ KALIYORDU
//    `AuthProvider` reklam servisine ham `isPro` bayragini veriyordu.
//    `UserModel.isPro` yalnizca "bir zamanlar abone oldu mu" demek;
//    bitis tarihini `hasActivePro` kontrol ediyor. Sonuc sessiz bir
//    gelir kaybiydi: abonelik bitiyor, kullanici uygulamayi kullanmaya
//    devam ediyor, ne reklam geliri geliyor ne de yeniden abone olma
//    baskisi olusuyor. Hicbir yerde hata gorunmuyordu.
//
// 2) "REKLAM IZLE" SERIDI BIR DAHA GERI GELMIYORDU
//    Market ekrani uygunlugu `initState` icinde bir kez hesapliyordu.
//    Pro bayragi ise agdan sonra geliyor; ekran o ana kadar acilmissa
//    serit gizli kaliyor ve kendini toparlamiyordu. Artik uygunluk
//    degisince `durumSurumu` artiyor ve ekran dinliyor.
import 'dart:io';

import 'package:devkom_app/services/ads_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('AuthProvider reklam servisine hasActivePro veriyor', () {
    final src =
        File('lib/providers/auth_provider.dart').readAsStringSync();

    expect(src.contains('setProMember(_currentUser!.hasActivePro)'), isTrue,
        reason: 'Reklam servisine yine ham `isPro` veriliyor. Suresi '
            'dolmus abone reklam gormez, gelir kaybi sessizce surer.');
    expect(src.contains('setProMember(_currentUser!.isPro)'), isFalse,
        reason: 'Eski `isPro` cagrisi geri gelmis.');
  });

  group('durum degisince ekranlar haber aliyor', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      AdsService.instance.resetForTest();
      AdsService.instance.markInitializedForTest();
    });

    tearDown(() => AdsService.instance.resetForTest());

    test('Pro bayragi degisince durumSurumu artiyor', () {
      final once = AdsService.instance.durumSurumu.value;

      AdsService.instance.setProMember(true, kalici: false);
      expect(AdsService.instance.durumSurumu.value, greaterThan(once),
          reason: 'Pro olunca serit gizlenmeli; ekran haber almadan '
              'gizleyemez.');

      final ortada = AdsService.instance.durumSurumu.value;
      AdsService.instance.setProMember(false, kalici: false);
      expect(AdsService.instance.durumSurumu.value, greaterThan(ortada),
          reason: 'Pro bitince serit geri gelmeli.');
    });

    test('ayni deger tekrar yazilinca bosuna bildirim yok', () {
      AdsService.instance.setProMember(true, kalici: false);
      final sonra = AdsService.instance.durumSurumu.value;

      AdsService.instance.setProMember(true, kalici: false);
      expect(AdsService.instance.durumSurumu.value, sonra,
          reason: 'Degismeyen durum icin bildirim atilirsa her ekran '
              'bosuna yeniden cizilir.');
    });
  });
}
