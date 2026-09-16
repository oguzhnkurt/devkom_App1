import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// "Her şeyi aç" anahtarının yayın derlemesine sızmadığını kilitler.
///
/// Anahtar kilitli oyunları ve Pro kursları satın almadan denemek için var.
/// Yayın derlemesinde de çalışsaydı, uygulamanın ücretli her bölümünü açan
/// bir arka kapı olurdu — hem gelir tarafını hem App Store Kural 3.1.1
/// tarafını bozardı. Bu yüzden kDebugMode koşulu kaynak seviyesinde
/// doğrulanıyor.
void main() {
  final proGate = File('lib/utils/pro_gate.dart').readAsStringSync();
  final ayarlar =
      File('lib/screens/settings/settings_screen.dart').readAsStringSync();

  group('debug Pro simulasyonu', () {
    test('varsayilan kapali', () {
      expect(proGate.contains('static bool debugHerSeyAcik = false;'), isTrue);
    });

    test('yalnizca kDebugMode icinde dikkate aliniyor', () {
      expect(
        proGate.contains(
            'static bool get _debugAcik => kDebugMode && debugHerSeyAcik;'),
        isTrue,
        reason: 'kDebugMode kosulu kalkarsa yayinda her kilit acilir.',
      );
    });

    test('isPro ve watchIsPro ayni kapiyi kullaniyor', () {
      // Biri override'i okuyup digeri okumazsa kilit ekranda acik,
      // davranista kapali (ya da tersi) gorunur.
      for (final metot in ['static bool isPro(', 'static bool watchIsPro(']) {
        final i = proGate.indexOf(metot);
        expect(i, isNot(-1), reason: metot);
        final govde = proGate.substring(i, i + 220);
        expect(govde.contains('_debugAcik'), isTrue, reason: metot);
      }
    });

    test('ayarlardaki anahtar kDebugMode ile korunuyor', () {
      expect(ayarlar.contains('if (kDebugMode) const _ProSimTile()'), isTrue);
    });

    test('anahtar reklamlari kapatmiyor', () {
      // Pro uye hic reklam gormuyor; simulasyon AdsService'e dokunsaydi
      // reklam akisini debug'da hic test edemezdik.
      final i = ayarlar.indexOf('class _ProSimTileState');
      expect(i, isNot(-1));
      expect(ayarlar.substring(i).contains('AdsService'), isFalse);
    });
  });
}
