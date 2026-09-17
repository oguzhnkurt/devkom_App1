import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Kodun istediği her dosya pakete giriyor mu?
///
/// GERÇEK OLAY: tek maskota geçerken `assets/maskot/devi.png` ve
/// `devi_kutlama.webp` repoya kondu, `Mascot` widget'ı onları okuyor —
/// ama `pubspec.yaml`'ın `assets:` listesine eklenmedi. Flutter yalnızca
/// listelenen yolları pakete koyar; dolayısıyla derlenen uygulamada
/// maskotun görselleri **yoktu**. `Image.asset` sessizce `errorBuilder`'a
/// düşüyor ve maskotun yerinde `Icons.smart_toy_rounded` çiziliyordu:
/// uygulamanın tek karakteri, her ekranda genel bir robot simgesi.
///
/// Hiçbir test bunu yakalamadı çünkü **widget testlerinde** eski
/// `build/unit_test_assets` klasöründe dosyalar duruyordu; hata yalnızca
/// gerçek pakette görünüyordu. 1.0.8 (build 13) bu hatayla App Store
/// Connect'e yüklendi.
///
/// Bu test kaynağı tek yerden denetliyor: `lib/` içinde geçen her
/// `'assets/...'` sabiti, pubspec'teki bir girdi tarafından
/// kapsanmalı.
void main() {
  test('lib icindeki her assets/ yolu pubspec tarafindan kapsaniyor', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final blok = pubspec.substring(
      pubspec.indexOf('  assets:'),
      pubspec.indexOf('  fonts:'),
    );
    final girdiler = blok
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.startsWith('- '))
        .map((l) => l.substring(2).trim())
        .toList();

    expect(girdiler, isNotEmpty, reason: 'pubspec assets listesi okunamadi');

    final referanslar = <String, String>{};
    for (final dosya in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final kaynak = dosya.readAsStringSync();
      // Yorum satirlarini atliyoruz: aciklamada gecen bir yol
      // paketlenmek zorunda degil.
      final kod = kaynak
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      // Icinde $ olan (dizeye gomulu degisken) yollar burada
      // denetlenemez; onlari atliyoruz.
      for (final m in RegExp(r"'(assets/[^'\$]+?)'").allMatches(kod)) {
        referanslar[m.group(1)!] = dosya.path;
      }
    }

    final eksik = <String>[];
    referanslar.forEach((yol, dosya) {
      final kapsandi = girdiler.any((g) =>
          g == yol || (g.endsWith('/') && yol.startsWith(g)));
      if (!kapsandi) eksik.add('$yol  ($dosya)');
    });

    expect(eksik, isEmpty,
        reason: 'Bu yollar kodda okunuyor ama pubspec.yaml assets '
            'listesinde yok — derlenen uygulamada dosya BULUNMAZ:\n'
            '${eksik.join('\n')}');
  });

  test('pubspecte yazan asset klasorleri diskte var', () {
    // Ters yon: listede olup diskte olmayan bir klasor `flutter build`
    // sirasinda uyari uretiyor ve gozden kaciyor.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final blok = pubspec.substring(
      pubspec.indexOf('  assets:'),
      pubspec.indexOf('  fonts:'),
    );
    for (final satir in blok.split('\n')) {
      final t = satir.trim();
      if (!t.startsWith('- ')) continue;
      final yol = t.substring(2).trim();
      if (!yol.startsWith('assets/')) continue;
      final varMi = yol.endsWith('/')
          ? Directory(yol).existsSync()
          : File(yol).existsSync();
      expect(varMi, isTrue, reason: 'pubspec "$yol" diyor ama diskte yok');
    }
  });
}
