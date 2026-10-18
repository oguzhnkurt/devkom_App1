// AdMob askisi (Ekim 2026): tum reklam secenekleri gecici olarak kapali.
//
// Kullanici karari (18 Ekim 2026): oyunlarin hepsi acik, "Reklamla"
// etiketi yok; yalnizca son uc kurs (Arduino IDE, Java, C#) Pro ile
// aciliyor ve orada "reklam izle" secenegi yok. Askı bitince
// AdConfig.reklamlarKapali false yapilir; o zaman bu dosya da guncellenir.
import 'dart:io';

import 'package:devkom_app/config/ad_config.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/screens/robotics_games_screen.dart' show ProGames;
import 'package:devkom_app/services/ads_service.dart';
import 'package:devkom_app/services/embedded_games_service.dart';
import 'package:devkom_app/widgets/surpriz_sandik.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('anahtar acik', () {
    expect(AdConfig.reklamlarKapali, isTrue);
  });

  test('hicbir oyun kilitli degil; Pro sayfalarinda oyun sozu yok', () {
    for (final g in EmbeddedGamesService.getAllEmbeddedGames()) {
      expect(ProGames.isProGame(g.type), isFalse, reason: g.title);
    }
    expect(ProGames.lockedGameCount, 0);
  });

  test('surpriz sandik butun oyunlari cikarabiliyor (reklamsiz)', () {
    final hepsi = EmbeddedGamesService.getAllEmbeddedGames().length;
    expect(SurprizSandik.havuz(pro: false, reklamVar: false).length, hepsi);
  });

  test('odullu video ve gecis reklami istenmiyor', () async {
    expect(await AdsService.instance.canWatchRewarded(), isFalse);
    expect(await AdsService.instance.canWatchRewarded(gonullu: true), isFalse);
    expect(await AdsService.instance.showInterstitialIfDue(), isFalse);
  });

  test('son uc kurs Pro; Pro kurs derslerinde reklam yolu kapali', () {
    final pro = CoursesData.allCourses.where((c) => c.isPremium).toList();
    expect(pro.length, 3);
    final src = File('lib/courses/screens/interactive_course_screen.dart')
        .readAsStringSync();
    expect(src.contains('!AdConfig.reklamlarKapali &&'), isTrue);
    expect(src.contains('Bu ileri seviye kurs Pro üyelikte.'), isTrue);
  });

  test('Bilgi Yarismasi soru siniri askida yok', () {
    final src = File('lib/screens/games/millionaire_game_screen.dart')
        .readAsStringSync();
    final i = src.indexOf('Future<void> _siradakiSoruyuAc()');
    expect(i, greaterThan(0));
    final govde = src.substring(i, i + 300);
    expect(govde.contains('if (AdConfig.reklamlarKapali)'), isTrue);
  });

  test('ana sayfa: renkli gorev karti ilk dersten sonra da kaliyor', () {
    final src =
        File('lib/screens/unified_home_screen.dart').readAsStringSync();
    expect(src.contains('_buildContinueCard'), isFalse);
    expect(src.contains('_buildIlkGorev(next, isDark, yeni: isNewUser)'),
        isTrue);
    expect(src.contains("'SIRADAKİ GÖREVİN'"), isTrue);
  });
}
