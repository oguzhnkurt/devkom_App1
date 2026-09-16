// Ana sayfadaki Pro kartinin kurallari.
//
// Kartta FIYAT YAZMAMALI. Ayni abonelik App Store'da 175 ulkede farkli
// tutar ve para birimiyle satiliyor (yillik plan ABD'de $39.99, bircok
// pazarda $34.99); karta sabit bir fiyat yazmak kullanicilarin cogunda
// yanlis bilgi gostermek ve Apple'in "gercek yerel fiyati goster"
// kuralini cignemek demek. Fiyatin tek dogru kaynagi StoreKit ve onu
// paywall ekrani gosteriyor.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ana sayfa Pro kartinda sabit fiyat yok', () {
    final src =
        File('lib/screens/unified_home_screen.dart').readAsStringSync();
    final start = src.indexOf('Widget _buildProCard');
    expect(start, greaterThan(0), reason: 'Pro karti bulunamadi');
    final end = src.indexOf('void _openPaywall', start);
    final card = src.substring(start, end);

    // Yorum satirlarini ve Dart kayit erisimlerini (perk.\$1) ele:
    // ikisi de fiyat degil.
    final code = card
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n')
        .replaceAll(RegExp(r'\.\$\d'), '');

    // Para birimi + rakam kaliplari.
    final money = RegExp(
      r'(\$|€|£|₺)\s?\d+[.,]?\d*|\d+[.,]\d{2}\s?(\$|€|£|₺|USD|EUR|TRY|TL)',
    );
    final hits = money.allMatches(code).map((m) => m.group(0)!).toList();
    expect(hits, isEmpty,
        reason: 'Kartta sabit fiyat var: ${hits.join(", ")}. '
            'Fiyat yalnizca StoreKit\'ten gelmeli.');
  });

  test('Pro kullaniciya kart cizilmiyor', () {
    final src =
        File('lib/screens/unified_home_screen.dart').readAsStringSync();
    expect(src.contains('if (!ProGate.watchIsPro(context)) ...['), isTrue,
        reason: 'Kart Pro kullaniciya da gosteriliyor');
  });
}
