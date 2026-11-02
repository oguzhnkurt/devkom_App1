import 'dart:io';

import 'package:devkom_app/utils/lang.dart';
import 'package:flutter_test/flutter_test.dart';

/// `Info.plist` icindeki dil listesi ile uygulamanin gercekten
/// destekledigi dillerin ayni kalmasini kilitler.
///
/// NEDEN
/// -----
/// App Store urun sayfasindaki "Diller" alani uygulama ici cevirilerden
/// degil, ikilinin `CFBundleLocalizations` listesinden okunuyor. 1.0.7
/// yayina ciktiginda bu liste yalnizca tr ve en iceriyordu; uygulama
/// dort dil destekledigi halde magaza sayfasi onu Turkce bir uygulama
/// gibi gosteriyordu. Almanya ya da Ispanya'daki bir kullanici sayfaya
/// bakip "bu bende calismaz" diye geciyordu - dunyaya acilma planinin
/// tam ortasinda sessiz bir indirme kaybi.
///
/// Yeni bir dil eklenirse iki yerin birlikte guncellenmesi gerekiyor;
/// bu test unutuldugunda kirmiziya doner.
void main() {
  test('Info.plist dil listesi MaterialApp ile ayni', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    final blok = RegExp(
      r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>',
      dotAll: true,
    ).firstMatch(plist);
    expect(blok, isNotNull,
        reason: 'Info.plist icinde CFBundleLocalizations yok. Olmadan '
            'App Store urun sayfasi uygulamayi tek dilli gosteriyor.');

    final plistDilleri = RegExp(r'<string>([A-Za-z-]+)</string>')
        .allMatches(blok!.group(1)!)
        .map((m) => m.group(1)!)
        .toSet();

    // 51 dil (2 Kasim 2026): kaynak AppLang.supported. iOS Cince'yi
    // betik koduyla istiyor (zh-Hans).
    final uygulamaDilleri = AppLang.supported
        .map((d) => d == 'zh' ? 'zh-Hans' : d)
        .toSet(); // 'zh-Hant' iOS'ta da ayni

    expect(plistDilleri, equals(uygulamaDilleri),
        reason: 'Info.plist ile AppLang.supported ayni olmali - yoksa ya '
            'magaza sayfasi eksik dil gosterir ya da desteklenmeyen bir '
            'dil vaat edilir.');
  });
}
