import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Eslestirme adiminda "bedava deneme" acigi.
///
/// Eskiden her eslestirme aninda notlaniyordu: cocuk soldaki karti sagdaki
/// bir karta baglar baglamaz kutu yesil ya da kirmizi oluyordu. Dort
/// ciftlik bir adimda bu, adimi dusunmeden cozulebilir hale getiriyordu —
/// rastgele dokun, kirmizi olursa geri al, birkac denemede garanti bitir.
///
/// Yeni davranis: geri bildirim yalnizca tahtanin tamami dolunca geliyor.
/// Geri alma yine serbest, yanlista puan yine kesilmiyor.
void main() {
  final kaynak =
      File('lib/courses/screens/widgets/step_widgets.dart').readAsStringSync();

  // _MatchingStepWidgetState govdesini ayikla.
  final bas = kaynak.indexOf('class _MatchingStepWidgetState');
  final son = kaynak.indexOf('class ', bas + 10);
  final govde = kaynak.substring(bas, son == -1 ? kaynak.length : son);

  group('eslestirme adimi', () {
    test('_selectRight tek bir eslestirmeyi notlamiyor', () {
      final selectRight = govde.substring(
        govde.indexOf('void _selectRight('),
        govde.indexOf('void _checkCompletion('),
      );
      expect(selectRight.contains('_matchCorrectness'), isFalse,
          reason: 'tek eslestirme aninda notlaniyor — bedava deneme acigi');
    });

    test('notlama bayragi var ve tahta dolunca aciliyor', () {
      expect(govde.contains('bool _kontrolEdildi = false;'), isTrue);
      expect(govde.contains('_kontrolEdildi = true;'), isTrue);
      final check = govde.substring(govde.indexOf('void _checkCompletion('));
      expect(
        check.contains('_matches.length != widget.step.pairs.length'),
        isTrue,
        reason: 'notlama tahtanin dolmasina bagli degil',
      );
    });

    test('bir kart bozulunca butun notlar siliniyor', () {
      final selectLeft = govde.substring(
        govde.indexOf('void _selectLeft('),
        govde.indexOf('void _selectRight('),
      );
      expect(selectLeft.contains('_matchCorrectness.clear()'), isTrue);
      expect(selectLeft.contains('_kontrolEdildi = false'), isTrue);
    });

    test('notlanmamis eslesme notr gosteriliyor', () {
      expect(govde.contains('bool? _durum(String leftId)'), isTrue);
      expect(govde.contains('_matchCorrectness[pair.id] ?? false'), isFalse,
          reason: 'notlanmamis eslesme yanlis (kirmizi) gorunur');
    });

    test('yanlista puan kesilmiyor', () {
      expect(
        RegExp(r'(xp|score|puan)\s*-=', caseSensitive: false).hasMatch(govde),
        isFalse,
      );
    });
  });

  group('olu model tipleri silindi', () {
    final model = File('lib/courses/models/interactive_lesson_model.dart')
        .readAsStringSync();

    for (final tip in ['MatchingMode', 'SimulationStep', 'SimulationType']) {
      test('$tip modelde yok', () {
        expect(model.contains(tip), isFalse);
      });
    }

    test('MiniGameType yalnizca ekrani olan iki turu tasiyor', () {
      final bas = model.indexOf('enum MiniGameType {');
      final govde = model.substring(bas, model.indexOf('}', bas));
      expect(govde.contains('catchTheBlock'), isTrue);
      expect(govde.contains('blockPuzzle'), isTrue);
      for (final olu in [
        'codeRunner',
        'bugHunter',
        'memoryMatch',
        'typeRacer',
      ]) {
        expect(govde.contains(olu), isFalse, reason: '$olu hic uretilmedi');
      }
    });
  });
}
