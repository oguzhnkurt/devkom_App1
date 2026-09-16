// Pro (paywall) ekranı: dil kapsaması, taşma ve VERİLEN SÖZ.
//
// Bu ekran uygulamanın en hassas yeri: para burada isteniyor ve App
// Store incelemesi en çok buraya bakıyor. İki ayrı risk var:
//
//  1. DİL. Ekranın geri kalanı dört dile çevrilmişken paywall'ın yarısı
//     Türkçe kalmıştı — Almanca seçen bir veli "Pro'yu Aç" düğmesini
//     Türkçe görüyordu.
//  2. SÖZ. Özellik listesinde "13 ek oyun" yazıyordu; katalogda Pro'nun
//     açtığı oyun sayısı 9. Tutulmayan bir söz, hem kullanıcıya karşı
//     yanlış hem de Kural 3.1.2 açısından riskli.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devkom_app/providers/settings_provider.dart';
import 'package:devkom_app/screens/robotics_games_screen.dart' show ProGames;
import 'package:devkom_app/screens/subscription_screen.dart';
import 'package:devkom_app/services/embedded_games_service.dart';

/// Türkçe kalıntı ararken hangi harflere bakılacağı DİLE GÖRE değişir.
///
/// İlk sürüm her dilde `çğıöşü` arıyordu ve Almanca metni Türkçe sandı:
/// "verlängert", "gekündigt" — ä ve ü Almancanın kendi harfleri. Aynı
/// tuzak İspanyolcada ó/ú/ñ için var. Bu yüzden her dil için yalnızca
/// O DİLDE BULUNMAYAN Türkçe harfler aranıyor.
const _turkishOnly = {
  'en': 'çÇğĞıİöÖşŞüÜ',
  'de': 'çÇğĞıİşŞ', // ä ö ü Almancada da var
  'es': 'ğĞıİşŞöÖ', // á é í ó ú ñ ü İspanyolcada var; ç Katalanca
};

Future<List<String>> _renderAndScan(WidgetTester tester, String lang) async {
  SharedPreferences.setMockInitialValues({'language_code': lang});
  final settings = SettingsProvider();
  await settings.setLocale(Locale(lang));

  tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: const MaterialApp(home: SubscriptionScreen()),
    ),
  );
  await tester.pump(const Duration(seconds: 3));

  final letters = _turkishOnly[lang] ?? 'çÇğĞıİöÖşŞüÜ';
  final found = <String>[];
  for (final t in tester.widgetList<Text>(find.byType(Text))) {
    final text = t.data ?? t.textSpan?.toPlainText() ?? '';
    for (final ch in letters.split('')) {
      if (text.contains(ch)) {
        found.add('"$text"');
        break;
      }
    }
  }
  return found;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Pro ekranindaki her metin dort dilde yazilmis', () {
    // NEDEN KAYNAK TARAMASI: ekranin bir kismi yalnizca magazadan urun
    // gelince ciziliyor; testte ag yok, o yuzden basliklar ve plan
    // kartlari hic render edilmiyor. Onlarin cevirisini yalnizca kaynak
    // uzerinden dogrulayabiliyoruz.
    //
    // `_t(tr, en, [de, es])` imzasinda de/es opsiyonel; verilmezse
    // Almanca/Ispanyolca kullanici INGILIZCE goruyor. Paywall'da bu
    // kabul edilebilir degil: para istenen ekran kullanicinin dilinde
    // olmali.
    final src = File('lib/screens/subscription_screen.dart').readAsStringSync();
    final eksik = <String>[];
    var i = 0;
    while (true) {
      i = src.indexOf('_t(', i);
      if (i < 0) break;
      var j = i + 3;
      var depth = 1;
      while (depth > 0 && j < src.length) {
        if (src[j] == '(') depth++;
        if (src[j] == ')') depth--;
        j++;
      }
      final call = src.substring(i, j);
      if (!call.startsWith('_t(String')) {
        var d = 0;
        var args = 1;
        String? inStr;
        for (var k = 3; k < call.length - 1; k++) {
          final ch = call[k];
          if (inStr != null) {
            if (ch == inStr && call[k - 1] != r'\') inStr = null;
            continue;
          }
          if (ch == '"' || ch == "'") {
            inStr = ch;
          } else if (ch == '(' || ch == '[' || ch == '{') {
            d++;
          } else if (ch == ')' || ch == ']' || ch == '}') {
            d--;
          } else if (ch == ',' && d == 0) {
            args++;
          }
        }
        if (args < 4) {
          final line = '\n'.allMatches(src.substring(0, i)).length + 1;
          eksik.add('satir $line: ${call.replaceAll('\n', ' ')}');
        }
      }
      i = j;
    }
    expect(eksik, isEmpty,
        reason: 'Paywall metinlerinde Almanca/Ispanyolca eksik:\n'
            '${eksik.join('\n')}');
  });

  test('Pro ekranindaki oyun sayisi katalogla ayni', () {
    final gercekSayi = EmbeddedGamesService.getAllEmbeddedGames()
        .where((g) => ProGames.isProGame(g.type))
        .length;
    expect(ProGames.lockedGameCount, gercekSayi);

    // Elle yazilmis bir sayi kalmasin: paywall metni bu getter'i
    // kullanmali. (Sayi degisirse metin de kendiliginden degisir.)
    expect(gercekSayi, greaterThan(0));
  });

  for (final lang in ['en', 'de', 'es']) {
    testWidgets('Pro ekrani $lang dilinde Turkce metin icermiyor',
        (tester) async {
      final leaks = await _renderAndScan(tester, lang);
      expect(leaks, isEmpty,
          reason: '$lang secilmisken Pro ekraninda Turkce metin var:\n'
              '${leaks.take(20).join('\n')}');
    });
  }

  testWidgets('Pro ekrani Turkcede de calisiyor', (tester) async {
    final leaks = await _renderAndScan(tester, 'tr');
    expect(leaks, isNotEmpty, reason: 'Turkce ekran Turkce olmali');
  });
}
