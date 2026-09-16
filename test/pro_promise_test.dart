// Pro sayfasinin VERDIGI SOZ katalogla ayni olmali.
//
// Paywall'da "13 ek oyun" yaziyordu; katalogda Pro'nun actigi oyun
// sayisi 9. Sayi elle yazildigi icin oyun eklendikce/cikarildikca kimse
// guncellemiyordu. Tutulmayan bir soz hem kullaniciya karsi yanlis hem
// de App Store Kural 3.1.2 acisindan riskli.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/screens/robotics_games_screen.dart' show ProGames;
import 'package:devkom_app/services/embedded_games_service.dart';

void main() {
  test('Pro oyun sayisi katalogla tutarli', () {
    final all = EmbeddedGamesService.getAllEmbeddedGames();
    final locked = all.where((g) => ProGames.isProGame(g.type)).length;
    expect(ProGames.lockedGameCount, locked);
    expect(locked, lessThan(all.length),
        reason: 'Butun oyunlar kilitliyse ucretsiz katman bos demektir');
  });

  test('hicbir ekranda elle yazilmis oyun sayisi kalmadi', () {
    // "13 ek oyun", "13 more games", "13 weitere Spiele", "13 juegos mas"
    final hardcoded = RegExp(
        r"'\d+ (ek oyun|more games|weitere Spiele|juegos más)'");
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      for (final m in hardcoded.allMatches(f.readAsStringSync())) {
        offenders.add('${f.path}: ${m.group(0)}');
      }
    }
    expect(offenders, isEmpty,
        reason: 'Bu sayilar katalog degistikce yanlis kalir; '
            'ProGames.lockedGameCount kullan:\n${offenders.join('\n')}');
  });
}
