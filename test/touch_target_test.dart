import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Dokunma hedefi denetimi.
///
/// NEDEN
/// -----
/// Apple'in Human Interface Guidelines'i basilabilir her ogenin en az
/// 44x44 punto olmasini istiyor. Cocuk uygulamasinda bu daha da kritik:
/// 6 yasindaki bir parmak 20 puntoluk bir carpi tusunu tutturamiyor,
/// tutturamayinca da yanlis yere basiyor.
///
/// Iki kalip bu kurali SESSIZCE bozuyordu ve ikisi de derlemeden geciyor:
///
///  1. `IconButton(constraints: const BoxConstraints())` — IconButton'in
///     48x48 varsayilan minimumunu tamamen siliyor, geriye yalnizca
///     ikonun kendi boyu (16-20 punto) kaliyor.
///  2. Cok buyuk izgaralar — 10x10 koordinat izgarasi 390 puntoluk bir
///     telefonda hucre basina ~32 punto birakiyordu.
///
/// Kaynak okuyan bir test, cunku bunlar gorsel olarak "calisiyor"
/// gorunuyor: dugme duruyor, sadece basilamiyor.
void main() {
  Iterable<File> dartDosyalari(String kok) sync* {
    for (final e in Directory(kok).listSync(recursive: true)) {
      if (e is File && e.path.endsWith('.dart')) yield e;
    }
  }

  test('IconButton dokunma hedefi silinmiyor', () {
    final suclu = <String>[];

    for (final f in dartDosyalari('lib')) {
      final satirlar = f.readAsStringSync().split('\n');
      for (var i = 0; i < satirlar.length; i++) {
        if (!satirlar[i].contains('constraints: const BoxConstraints()')) {
          continue;
        }
        // Yalnizca IconButton icindekiler onemli; baska widget'larda bos
        // kisit gecerli bir kullanim olabiliyor.
        final bas = i - 12 < 0 ? 0 : i - 12;
        final pencere = satirlar.sublist(bas, i).join('\n');
        if (pencere.contains('IconButton(')) {
          suclu.add('${f.path}:${i + 1}');
        }
      }
    }

    expect(suclu, isEmpty,
        reason: 'Bos BoxConstraints() IconButton\'in 48x48 hedefini siler. '
            'Ikonu kucuk tutmak icin size: kullan, hedefi minWidth/minHeight '
            'ile en az 44 birak:\n${suclu.join('\n')}');
  });

  test('koordinat izgarasi ekrana gore sinirlaniyor', () {
    // 10x10 izgara dar telefonda ~32 puntoluk hucre demekti. Seviye
    // ilerlemesi duruyor ama izgara ekrana sigmiyorsa buyumuyor.
    final kaynak =
        File('lib/screens/games/coordinates_game_screen.dart').readAsStringSync();
    expect(kaynak.contains('_ekranaSiganIzgara'), isTrue);
    expect(kaynak.contains('/ 44).floor()'), isTrue,
        reason: 'Hucre genisligi 44 puntoya gore hesaplanmali.');
    // initState'te MediaQuery okumak patliyor; olcum bayragi sart.
    expect(kaynak.contains('if (!_olculdu) return istenen;'), isTrue);
  });
}
