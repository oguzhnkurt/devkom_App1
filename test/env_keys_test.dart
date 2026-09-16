// `.env` icinde KULLANILMAYAN anahtar birikmesin.
//
// `.env` pubspec'te assets altinda: dosya uygulama PAKETINE giriyor ve
// IPA'dan cikarilabiliyor. Kodda hic okunmayan bir anahtar orada
// durursa, hicbir ise yaramadan sizmis oluyor. `GEMINI_API_KEY` ve
// `MIXPANEL_TOKEN` tam olarak bu durumdaydi.
//
// Not: dosyanin DEGERLERI hicbir yerde okunmuyor, yalnizca anahtar
// adlari kontrol ediliyor.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Kodun okumasi beklenmeyen ama zararsiz olan anahtarlar.
const _serbest = <String>{
  // Yer tutucu: cihaza ozel kimlik, ancak elle doldurulabiliyor.
  'ADMOB_TEST_DEVICE_IDS',
  // Yalnizca yayin derlemesinde okunuyor; ad_config icinde platforma
  // gore secildigi icin duz metin aramasiyla bulunuyor zaten.
};

void main() {
  test('.env icindeki her anahtar kodda okunuyor', () {
    final env = File('.env');
    if (!env.existsSync()) {
      // CI'da .env olmayabilir; o zaman denetlenecek bir sey de yok.
      return;
    }

    final anahtarlar = <String>[];
    for (final satir in env.readAsLinesSync()) {
      final t = satir.trim();
      if (t.isEmpty || t.startsWith('#') || !t.contains('=')) continue;
      anahtarlar.add(t.split('=').first.trim());
    }
    expect(anahtarlar, isNotEmpty);

    // lib/ altindaki butun kaynagi tek bir metin olarak tara.
    final govde = StringBuffer();
    for (final e in Directory('lib').listSync(recursive: true)) {
      if (e is File && e.path.endsWith('.dart')) {
        govde.write(e.readAsStringSync());
      }
    }
    final kaynak = govde.toString();

    final kullanilmayan = anahtarlar
        .where((a) => !_serbest.contains(a) && !kaynak.contains(a))
        .toList();

    expect(kullanilmayan, isEmpty,
        reason: 'Bu anahtarlar kodda hic okunmuyor ama uygulama paketine '
            'giriyor: $kullanilmayan');
  });
}
