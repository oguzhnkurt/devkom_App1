// Video Dersler listesi icin kaynak okuyan koruma testleri.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const ekran = 'lib/screens/videos/video_series_screen.dart';
  const model = 'lib/models/video_series_model.dart';

  test('liste anlatim diline gore iki bolume ayriliyor', () {
    final s = File(ekran).readAsStringSync();
    // Eskiden tek liste vardi ve yalnizca siralaniyordu: Ingilizce secen
    // cocuk kendi dilindeki tek serinin altinda 14 yabanci seri
    // goruyordu.
    expect(s.contains('_kendiDilinde'), isTrue);
    expect(s.contains('_baskaDilde'), isTrue);
    expect(s.contains('_buildOtherLangHeader'), isTrue);
    expect(RegExp(r'List<VideoSeries> _series').hasMatch(s), isFalse,
        reason: 'Tek listeye donuldugu an ayrim kaybolur.');
  });

  test('kendi dilinde seri yoksa ekran sebep soyluyor', () {
    final s = File(ekran).readAsStringSync();
    expect(s.contains('_kendiDilinde.isEmpty'), isTrue,
        reason: 'Almanca/Ispanyolca icin bu dal gercekten calisiyor.');
  });

  test('katalog metinleri iki dilli ternary kullanmiyor', () {
    final s = File(model).readAsStringSync();
    expect(s.contains('isEn ?'), isFalse);
    expect(RegExp(r"lang == 'en' \?").hasMatch(s), isFalse);
    expect(s.contains('AppLang.pick'), isTrue,
        reason: 'Seviye rozeti dort dilde olmali.');
  });

  test('katalogda de/es icin Ingilizce yedegi calisiyor', () {
    final s = File(model).readAsStringSync();
    // _pick eskiden yalnizca lang == 'en' icin Ingilizceye geciyordu;
    // almanca secen cocuk Ingilizcesi hazir oldugu halde Turkce bolum
    // basligi goruyordu.
    expect(RegExp(r"if \(lang == 'tr'\) return base;").hasMatch(s), isTrue);
  });
}
