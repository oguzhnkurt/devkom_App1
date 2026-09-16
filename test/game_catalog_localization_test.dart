import 'package:flutter_test/flutter_test.dart';
import 'package:devkom_app/services/embedded_games_service.dart';

/// Oyun listesi dort dilde de kendi dilinde gorunmeli.
///
/// Hata buydu: GameModel yalnizca titleEn/descriptionEn biliyordu, bu
/// yuzden almanca ya da ispanyolca secen cocuk oyun kartlarinda turkce
/// baslik ve aciklama goruyordu.
void main() {
  final games = EmbeddedGamesService.getAllEmbeddedGames();
  final turkishOnly = RegExp(r'[ğĞıİşŞ]');

  test('oyun listesi bos degil', () {
    expect(games, isNotEmpty);
  });

  for (final lang in ['en', 'de', 'es']) {
    test('$lang dilinde hicbir oyun turkce baslik/aciklama gostermiyor', () {
      for (final g in games) {
        final title = g.titleFor(lang);
        final desc = g.descriptionFor(lang);
        expect(turkishOnly.hasMatch(title), isFalse,
            reason: '${g.id}: $lang basligi hala turkce -> "$title"');
        expect(turkishOnly.hasMatch(desc), isFalse,
            reason: '${g.id}: $lang aciklamasi hala turkce -> "$desc"');
        expect(title, isNot(equals(g.title)),
            reason: '${g.id}: $lang basligi turkcenin aynisi');
        expect(desc, isNot(equals(g.description)),
            reason: '${g.id}: $lang aciklamasi turkcenin aynisi');
      }
    });
  }

  test('turkce arayuzde turkce metin kaliyor', () {
    for (final g in games) {
      expect(g.titleFor('tr'), g.title);
      expect(g.descriptionFor('tr'), g.description);
    }
  });
}
