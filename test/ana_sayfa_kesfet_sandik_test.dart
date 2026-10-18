// Ana sayfa "Kesfet" sirasi, surpriz sandigin havuzu ve Oyunlar
// ekraninin alt boslugu (Ekim 2026, uygulama sahibinin istekleri).
import 'dart:io';

import 'package:devkom_app/models/game_model.dart';
import 'package:devkom_app/screens/robotics_games_screen.dart' show ProGames;
import 'package:devkom_app/services/embedded_games_service.dart';
import 'package:devkom_app/widgets/oyun_sahnesi.dart';
import 'package:devkom_app/widgets/surpriz_sandik.dart';
import 'package:devkom_app/config/ad_config.dart';
import 'package:flutter_test/flutter_test.dart';

String _oku(String yol) => File(yol).readAsStringSync();

void main() {
  // Bu dosya reklamli/kilitli NORMAL davranisi siniyor; AdMob askisindaki
  // gecici "reklamlar kapali" anahtari test/reklam_askisi_test.dart'ta.
  setUpAll(() => AdConfig.reklamlarKapali = false);
  tearDownAll(() => AdConfig.reklamlarKapali = true);
  group('Kesfet kartlari', () {
    test('sira: gunun bilgisi, etkinlikler, Devi\'ye sor, oyun onerisi', () {
      final src = _oku('lib/screens/unified_home_screen.dart');
      final govde = src.substring(src.indexOf('Widget _buildKesfet('),
          src.indexOf('Widget _kesfetKarti('));
      final sira = [
        "'Günün bilgisi'",
        "'ETKİNLİKLER'",
        "\"DEVİ'YE SOR\"",
        "'OYUN ÖNERİSİ'",
      ].map(govde.indexOf).toList();
      expect(sira, everyElement(greaterThan(-1)),
          reason: 'Kesfet kartlarindan biri eksik.');
      for (var i = 1; i < sira.length; i++) {
        expect(sira[i], greaterThan(sira[i - 1]),
            reason: 'Kesfet kartlarinin sirasi bozulmus.');
      }
    });

    test('oyun onerisi ve sandik Pro/reklam kapisindan geciyor', () {
      final src = _oku('lib/screens/unified_home_screen.dart');
      // Ana sayfa oyunu dogrudan acarsa reklam ve Pro kilidi atlanir.
      expect(src.contains('GamePlayScreen('), isFalse);
      expect(RegExp(r'oyunuAc\(context, oyun,').hasMatch(src), isTrue);
      expect(RegExp(r'onOyna: \(g\) => oyunuAc\(context, g,').hasMatch(src),
          isTrue);
      expect(_oku('lib/widgets/surpriz_sandik.dart').contains('GamePlayScreen'),
          isFalse);
      // Ortak kapi reklam secenegini sunan ProGate.ensureOrAd'i kullaniyor.
      final oyunlar = _oku('lib/screens/robotics_games_screen.dart');
      final i = oyunlar.indexOf('Future<void> oyunuAc(');
      expect(i, greaterThan(-1));
      expect(oyunlar.indexOf('ProGate.ensureOrAd', i), greaterThan(i));
    });
  });

  group('Surpriz sandik havuzu', () {
    final hepsi = EmbeddedGamesService.getAllEmbeddedGames();
    bool pro(GameModel g) => ProGames.isProGame(g.type);

    test('reklam yoksa Pro olmayana yalnizca ucretsiz oyunlar', () {
      final h = SurprizSandik.havuz(pro: false, reklamVar: false);
      expect(h, isNotEmpty);
      expect(h.where(pro), isEmpty);
    });

    test('reklam varsa reklamla acilan oyunlar da havuzda', () {
      final h = SurprizSandik.havuz(pro: false, reklamVar: true);
      final reklamli = h.where(pro).toList();
      expect(reklamli, isNotEmpty);
      // Yalnizca Pro olan (reklamla acilmayan) oyun cikmamali.
      expect(
          reklamli.every((g) => ProGames.reklamlaAcilabilir(g.type)), isTrue);
      expect(
          h.length,
          hepsi
              .where((g) => !pro(g) || ProGames.reklamlaAcilabilir(g.type))
              .length);
    });

    test('Pro uyeye butun oyunlar', () {
      expect(SurprizSandik.havuz(pro: true, reklamVar: false).length,
          hepsi.length);
    });

    test('yalnizca Pro oyun reklamla acilabilir sayilmiyor', () {
      for (final t in ProGames.yalnizPro) {
        expect(ProGames.reklamlaAcilabilir(t), isFalse);
      }
      for (final t in ProGames.free) {
        expect(ProGames.reklamlaAcilabilir(t), isFalse,
            reason: 'Ucretsiz oyun icin reklam gerekmez.');
      }
    });
  });

  group('Oyunlar ekrani', () {
    test('liste alt boslugu cam cubugu hesaba katiyor', () {
      final src = _oku('lib/screens/robotics_games_screen.dart');
      // En alttaki Satranc kartinin zorluk yazisi cubugun altinda
      // kaliyordu: sabit 28 piksel geri gelmemeli.
      expect(src.contains('EdgeInsets.only(bottom: 28)'), isFalse);
      expect(src.contains('EdgeInsets.fromLTRB(0, 18, 0, 28)'), isFalse);
      expect(
          RegExp(r'_altBosluk\s*=>\s*28 \+ MediaQuery\.paddingOf\(context\)\.bottom')
              .hasMatch(src),
          isTrue);
    });

    test('satranc kartinda dort seviyenin araligi yaziyor', () {
      final satranc = EmbeddedGamesService.getAllEmbeddedGames()
          .firstWhere((g) => g.type == GameType.chess);
      expect(oyunZorlukEtiketi(satranc, 'tr'), 'Kolay – İmkânsız');
      expect(oyunZorlukEtiketi(satranc, 'en'), 'Easy – Impossible');
      expect(oyunZorlukEtiketi(satranc, 'de'), 'Leicht – Unmöglich');
      expect(oyunZorlukEtiketi(satranc, 'es'), 'Fácil – Imposible');
      expect(satranc.gameData['difficulties'],
          ['beginner', 'intermediate', 'advanced', 'impossible']);
    });
  });
}
