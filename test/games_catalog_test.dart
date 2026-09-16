import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/models/game_model.dart';
import 'package:devkom_app/services/embedded_games_service.dart';
import 'package:devkom_app/screens/robotics_games_screen.dart' show ProGames;

/// Oyun katalogu denetimi.
///
/// Oyunlari elle tek tek acmanin otomatik karsiligi. Asil yakalamak
/// istedigimiz sey: ekrani yazilmis ama listeye eklenmemis oyunlar. Boyle bir
/// oyun kimseye gorunmez, kimse de fark etmez - dort tanesi tam olarak bu
/// durumdaydi (Kod Dedektifi, Degisken Ustasi, Hata Avcisi, Arduino
/// Simulatoru).
void main() {
  final games = EmbeddedGamesService.getAllEmbeddedGames();

  /// game_play_screen'in yonlendirebildigi oyun turleri. Buraya bir tur
  /// eklendiginde ekran tarafinda da karsiligi olmali.
  const playableTypes = {
    GameType.quiz,
    GameType.chess,
    GameType.coordinates,
    GameType.blockCoding,
    GameType.wordMatch,
    GameType.sequencing,
    GameType.mazeExplorer,
    GameType.leftRightCoding,
    GameType.arduinoSimulator,
    GameType.pipesPuzzle,
    GameType.colorCoding,
    GameType.patternDetective,
    GameType.variableMaster,
    GameType.bugHunter,
    GameType.robotSimulator,
    GameType.matchingGame,
  };

  /// Ekrani olmayan, "yakinda" gosteren turler.
  const comingSoonTypes = {GameType.puzzle, GameType.simulation};

  group('Katalog butunlugu', () {
    test('katalog bos degil', () {
      expect(games, isNotEmpty);
    });

    test('oyun id leri benzersiz', () {
      final ids = games.map((g) => g.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('her oyunun basligi, aciklamasi ve gorseli var', () {
      for (final g in games) {
        expect(g.title.trim(), isNotEmpty, reason: g.id);
        expect(g.description.trim(), isNotEmpty, reason: g.id);
        expect(g.thumbnailUrl.trim(), isNotEmpty, reason: g.id);
        expect(g.estimatedMinutes, greaterThan(0), reason: g.id);
        expect(g.difficulty, inInclusiveRange(1, 5), reason: g.id);
      }
    });

    test('listedeki her oyunun oynanabilir bir ekrani var', () {
      for (final g in games) {
        expect(playableTypes.contains(g.type), isTrue,
            reason:
                '"${g.title}" (${g.type}) listede var ama game_play_screen bu '
                'turu bir ekrana yonlendirmiyor - tiklayinca "yakinda" cikar.');
        expect(comingSoonTypes.contains(g.type), isFalse,
            reason: '"${g.title}" henuz yazilmamis bir tur.');
      }
    });

    test('ekrani olan her oyun turu katalogda da var', () {
      final listed = games.map((g) => g.type).toSet();
      final missing = playableTypes.difference(listed);
      expect(missing, isEmpty,
          reason:
              'Su turlerin ekrani yazilmis ama katalogda oyun kaydi yok, yani '
              'kullanici bunlara hic ulasamiyor: $missing');
    });
  });

  // NOT: Ustteki kategori seridi kaldirildi (tek duzenli liste kaldi), o
  // yuzden "her sekmede oyun var mi" testleri de kaldirildi. Kategori alani
  // modelde duruyor ama artik arayuzde filtre olarak kullanilmiyor.

  group('Pro kilidi', () {
    test('ucretsiz oyun turlerinin hepsi katalogda var', () {
      final listed = games.map((g) => g.type).toSet();
      for (final t in ProGames.free) {
        expect(listed.contains(t), isTrue,
            reason: '$t ucretsiz sayiliyor ama katalogda oyunu yok.');
      }
    });

    test('hem ucretsiz hem Pro oyun var', () {
      // Hepsi ucretsiz olursa Pro vaadi bos kalir; hepsi kilitli olursa
      // uygulama denenmeden satin alma istemis olur.
      final free = games.where((g) => !ProGames.isProGame(g.type));
      final pro = games.where((g) => ProGames.isProGame(g.type));
      expect(free, isNotEmpty);
      expect(pro, isNotEmpty);
    });

    test('Pro oyun sayisi paywall vaadini karsiliyor', () {
      // Abonelik ekraninda "ek oyunlar" vaat ediliyor; sayinin gercekten
      // karsiligi olmali (App Store 3.1.2).
      final pro = games.where((g) => ProGames.isProGame(g.type)).length;
      expect(pro, greaterThanOrEqualTo(5),
          reason: 'Pro tarafinda yalnizca $pro oyun var.');
    });
  });
}
