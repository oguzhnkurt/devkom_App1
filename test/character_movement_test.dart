import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Karakterin izgarada isinlanmasina karsi koruma.
///
/// Sag-Sol, Labirent Kasifi, Robot Simulatoru ve Blok Kodlama'da karakter
/// uzun sure hucrenin *icine* ciziliyordu: her komutta bir kareden
/// kayboluyor, digerinde aniden beliriyordu. Cocuk hangi yone gittigini
/// goremiyordu. Karakter artik izgaranin ustunde, `AnimatedPositioned`
/// (Flame tarafinda `MoveToEffect`) ile tasiniyor.
///
/// Bu bir gorsel degisiklik oldugu icin widget testi yakalamaz; kaynak
/// uzerinden denetliyoruz.
void main() {
  String oku(String yol) => File(yol).readAsStringSync();

  group('izgara oyunlarinda karakter kayarak hareket ediyor', () {
    const izgaraOyunlari = {
      'lib/screens/games/maze_explorer_game_screen.dart': '_playerX',
      'lib/screens/games/robot_simulator_game_screen.dart': '_robotX',
      'lib/screens/games/block_coding_game_screen.dart': '_playerX',
    };

    izgaraOyunlari.forEach((yol, alan) {
      test('$yol AnimatedPositioned kullaniyor', () {
        final k = oku(yol);
        expect(k.contains('AnimatedPositioned'), isTrue,
            reason: '$yol karakteri hucre icine ciziyor olabilir');
        expect(k.contains('left: konum($alan)'), isTrue,
            reason: '$yol karakteri izgara ustunde konumlandirmiyor');
      });

      test('$yol sureyi Motion uzerinden aliyor', () {
        final k = oku(yol);
        expect(k.contains("import '../../ui/motion.dart';"), isTrue);
        expect(k.contains('Motion.adapt(context'), isTrue,
            reason: 'hareket azaltma ayari sorulmuyor');
      });
    });

    test('Sag-Sol kuklasi MoveToEffect ile kayiyor', () {
      final k = oku('lib/screens/games/left_right_coding_game_screen.dart');
      expect(k.contains('MoveToEffect'), isTrue);
      expect(k.contains('Motion.reducedRaw'), isTrue,
          reason: 'hareket azaltma ayarinda aninda konumlanmali');
      // Eski davranis: moveTo dogrudan position atiyordu.
      expect(
        RegExp(r'void moveTo\(int newX, int newY\) \{[^}]*_updatePosition\(\);')
            .hasMatch(k),
        isFalse,
        reason: 'moveTo hala isinlaniyor',
      );
    });
  });

  group('Renkli Kodlar', () {
    final k = oku('lib/screens/games/color_coding_screen.dart');

    test('renk gecisi hareket azaltma ayarina bagli', () {
      expect(k.contains('Motion.adapt(context, Motion.short4)'), isTrue);
    });

    test('dizinin gosterim hizi KISALTILMAMIS', () {
      // displaySpeed oyunun mekanigi; Motion'a baglanirsa Simon Says
      // oynanamaz hale gelir. Bu test o hatayi geri gelmekten korur.
      expect(k.contains('Motion.adapt(context, displaySpeed'), isFalse);
      expect(k.contains('Duration(milliseconds: displaySpeed ~/ 2)'), isTrue);
    });
  });
}
