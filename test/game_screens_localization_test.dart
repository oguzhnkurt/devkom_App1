import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Oyun ekranlarinda `_isEn ? 'English' : 'Türkçe'` kaliba karsi kaynak
/// taramasi.
///
/// Hata buydu: bu kalip 389 yerde vardi ve yalnizca iki dil biliyordu.
/// Arayuzu almanca yapan cocuk oyunun tamamini turkce goruyordu. Artik
/// bu yazilar `_tl(tr, en, de, es)` uzerinden geciyor; test kalibin geri
/// gelmesini engelliyor.
void main() {
  final dir = Directory('lib/screens/games');

  // Dart string literali (kacisli tirnaklari destekler), ardisik
  // literaller bitisik yazilabiliyor.
  const str = r"(?:'(?:\\.|[^'\\])*'|" r'"(?:\\.|[^"\\])*")';
  final ternary = RegExp('_isEn\\s*\\?\\s*(?:$str)(?:\\s*(?:$str))*\\s*:'
      '\\s*(?:$str)');

  test('oyun ekranlarinda iki dilli _isEn ternary kalmadi', () {
    final offenders = <String>[];
    for (final f in dir.listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      for (final m in ternary.allMatches(f.readAsStringSync())) {
        offenders.add('${f.path}: ${m.group(0)!.replaceAll('\n', ' ')}');
      }
    }
    expect(offenders, isEmpty,
        reason: 'Bu yazilar almanca ve ispanyolcada turkce gorunur. '
            '_tl(tr, en, de, es) kullan:\n${offenders.join('\n')}');
  });

  test('_tl cagrilarinin hepsi dort dil veriyor', () {
    // Uc argumanla cagrilan bir _tl, almanca ya da ispanyolcayi atlamis
    // demektir; AppLang.pick o zaman turkceye duser.
    final call = RegExp(r'_tl\(');
    var checked = 0;
    for (final f in dir.listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      for (final m in call.allMatches(src)) {
        // Kaba ama yeterli: cagri parantezinin icini tarayip virgul say.
        var depth = 0;
        var commas = 0;
        var inStr = false;
        String? quote;
        for (var i = m.end - 1; i < src.length; i++) {
          final c = src[i];
          if (inStr) {
            if (c == '\\') {
              i++;
            } else if (c == quote) {
              inStr = false;
            }
            continue;
          }
          if (c == "'" || c == '"') {
            inStr = true;
            quote = c;
          } else if (c == '(' || c == '[' || c == '{') {
            depth++;
          } else if (c == ')' || c == ']' || c == '}') {
            depth--;
            if (depth == 0) break;
          } else if (c == ',' && depth == 1) {
            commas++;
          }
        }
        checked++;
        expect(commas, 3,
            reason: '${f.path}: _tl cagrisi dort arguman almiyor '
                '(tr, en, de, es)');
      }
    }
    expect(checked, greaterThan(300),
        reason: 'Beklenen _tl cagrilari bulunamadi; test yanlis yeri tariyor');
  });
}
