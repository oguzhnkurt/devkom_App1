// Blok Kodlama oyunu icin kaynak okuyan koruma testleri.
//
// Iki kusur vardi:
//   (a) `repeat` blogu, cevresinde ne olursa olsun ILERI GIT komutunu
//       N kez calistiriyordu. "Tekrarla 2x" aslinda "2 adim ileri"
//       demekti — dongu ogretmiyor, gizli bir hareket blogu gibi
//       davraniyordu.
//   (b) Seviye 4-10'un hepsi `default` dalina dusuyordu: yedi kez ayni
//       bos tahta.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _yol = 'lib/screens/games/block_coding_game_screen.dart';

/// Kaynaktaki `case N:` dallarindan seviye tahtalarini cikarir.
Map<int, _Seviye> _seviyeler(String kaynak) {
  final bas = kaynak.indexOf('void _loadLevel(int level)');
  final son = kaynak.indexOf('void _addBlock(', bas);
  final blok = kaynak.substring(bas, son);

  final out = <int, _Seviye>{};
  final caseRe = RegExp(r'case (\d+):');
  final parcalar = caseRe.allMatches(blok).toList();
  for (var i = 0; i < parcalar.length; i++) {
    final n = int.parse(parcalar[i].group(1)!);
    final bitis =
        i + 1 < parcalar.length ? parcalar[i + 1].start : blok.length;
    final govde = blok.substring(parcalar[i].end, bitis);

    final gx = RegExp(r'_goalX = (\d+);').firstMatch(govde);
    final gy = RegExp(r'_goalY = (\d+);').firstMatch(govde);
    if (gx == null || gy == null) continue;

    final izgara = List.generate(5, (_) => List.filled(5, 0));
    for (final m
        in RegExp(r'_grid\[(\d+)\]\[(\d+)\] = (\d+);').allMatches(govde)) {
      izgara[int.parse(m.group(1)!)][int.parse(m.group(2)!)] =
          int.parse(m.group(3)!);
    }
    out[n] = _Seviye(int.parse(gx.group(1)!), int.parse(gy.group(1)!), izgara);
  }
  return out;
}

class _Seviye {
  _Seviye(this.goalX, this.goalY, this.grid);
  final int goalX;
  final int goalY;
  final List<List<int>> grid;

  /// (0,0)'dan duvarlara takilmadan gidilebilen hucreler.
  Set<String> _ulasilabilir() {
    final gorulen = <String>{'0,0'};
    final kuyruk = <List<int>>[
      [0, 0]
    ];
    while (kuyruk.isNotEmpty) {
      final p = kuyruk.removeAt(0);
      for (final d in const [
        [1, 0],
        [-1, 0],
        [0, 1],
        [0, -1]
      ]) {
        final nx = p[0] + d[0], ny = p[1] + d[1];
        if (nx < 0 || nx > 4 || ny < 0 || ny > 4) continue;
        if (grid[ny][nx] == 1) continue;
        if (!gorulen.add('$nx,$ny')) continue;
        kuyruk.add([nx, ny]);
      }
    }
    return gorulen;
  }

  bool get hedefeGidilir => _ulasilabilir().contains('$goalX,$goalY');

  List<String> get ulasilmazYildizlar {
    final u = _ulasilabilir();
    final out = <String>[];
    for (var y = 0; y < 5; y++) {
      for (var x = 0; x < 5; x++) {
        if (grid[y][x] == 2 && !u.contains('$x,$y')) out.add('($x,$y)');
      }
    }
    return out;
  }
}

void main() {
  late String kaynak;
  setUpAll(() => kaynak = File(_yol).readAsStringSync());

  test('tekrar blogu KENDINDEN SONRAKI blogu tekrarliyor', () {
    // Eskiden cevresinden bagimsiz olarak hep ileri gidiyordu.
    expect(
        kaynak.contains('await _executeCommand(BlockType.moveForward);'),
        isFalse,
        reason: 'Tekrar blogu yine gizli bir "ileri git" olmus.');
    expect(kaynak.contains('await _executeCommand(icerdeki.type);'), isTrue);
    expect(kaynak.contains('bool _tekrarIcinde(int index)'), isTrue,
        reason: 'Icerideki blok gorsel olarak da belli olmali.');
  });

  test('tekrar blogunun etiketi neyi tekrarladigini soyluyor', () {
    expect(kaynak.contains(r"'Tekrarla ${block.repeatCount}x'"), isFalse);
    expect(kaynak.contains('Sonrakini'), isTrue);
  });

  test('on seviyenin onu da tanimli ve birbirinden farkli', () {
    final s = _seviyeler(kaynak);
    for (var i = 1; i <= 10; i++) {
      expect(s.containsKey(i), isTrue, reason: '$i. seviye tanimli degil');
    }
    // Ayni tahta iki kez kullanilmasin.
    final imzalar = <String>{};
    for (var i = 1; i <= 10; i++) {
      final imza = '${s[i]!.goalX},${s[i]!.goalY}|${s[i]!.grid}';
      expect(imzalar.add(imza), isTrue,
          reason: '$i. seviye baska bir seviyeyle ayni tahtaya sahip');
    }
  });

  test('her seviyede hedefe gidilebiliyor', () {
    final s = _seviyeler(kaynak);
    final bozuk = <String>[];
    s.forEach((n, sev) {
      if (!sev.hedefeGidilir) bozuk.add('$n. seviye: hedefe yol yok');
      if (sev.grid[sev.goalY][sev.goalX] == 1) {
        bozuk.add('$n. seviye: hedef duvarin ustunde');
      }
      if (sev.ulasilmazYildizlar.isNotEmpty) {
        bozuk.add('$n. seviye: ulasilmaz yildiz ${sev.ulasilmazYildizlar}');
      }
    });
    expect(bozuk, isEmpty, reason: bozuk.join('\n'));
  });
}
