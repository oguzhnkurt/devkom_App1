import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/models/video_series_model.dart';

/// Video kataloguna Ingilizce alanlar eklendi. Buradaki testlerin tamami tek
/// bir riski koruyor: **eksik ceviri yuzunden ekranda bos baslik cikmasin.**
/// Katalog Supabase'den geliyor ve `title_en` bos birakilabiliyor; o durumda
/// Turkce metne dusmemiz sart.
void main() {
  VideoSeries seriesFrom(Map<String, dynamic> extra) => VideoSeries.fromMap({
        'id': 's1',
        'slug': 'demo',
        'title': 'Scratch 101',
        'description': 'Blok kodlama',
        'cover_emoji': '🎬',
        'color_hex': '#6C3CE0',
        'level': 'beginner',
        ...extra,
      });

  group('Iki dilli alanlar', () {
    test('Ingilizce metin varsa Ingilizce arayuzde o kullanilir', () {
      final s = seriesFrom({
        'title_en': 'Scratch 101 EN',
        'description_en': 'Block coding',
      });
      expect(s.titleFor('en'), 'Scratch 101 EN');
      expect(s.descriptionFor('en'), 'Block coding');
      expect(s.titleFor('tr'), 'Scratch 101');
    });

    test('Ingilizce metin yoksa Turkce metne duser', () {
      final s = seriesFrom({});
      expect(s.titleFor('en'), 'Scratch 101');
      expect(s.descriptionFor('en'), 'Blok kodlama');
    });

    test('Ingilizce metin bos string ise de Turkce metne duser', () {
      // Panelde alan acilip bos birakilmasi cok olasi; bos string'i "ceviri
      // var" saymak ekranda bos baslik demek.
      final s = seriesFrom({'title_en': '   '});
      expect(s.titleFor('en'), 'Scratch 101');
    });

    test('bolumler icin de ayni kural gecerli', () {
      final e = VideoEpisode.fromMap({
        'id': 'e1',
        'series_id': 's1',
        'title': 'Ders 1',
        'youtube_url': 'https://youtu.be/x',
      });
      expect(e.titleFor('en'), 'Ders 1');
      expect(e.titleFor('tr'), 'Ders 1');
    });
  });

  group('Anlatim dili', () {
    test('varsayilan tr', () {
      expect(seriesFrom({}).audioLang, 'tr');
    });

    test('arayuz diliyle ayni ise rozet gerekmiyor', () {
      final tr = seriesFrom({'audio_lang': 'tr'});
      expect(tr.needsLangBadge('tr'), isFalse);
      expect(tr.needsLangBadge('en'), isTrue);
    });

    test('Ingilizce seri Turkce arayuzde rozet ister', () {
      final en = seriesFrom({'audio_lang': 'en'});
      expect(en.needsLangBadge('tr'), isTrue);
      expect(en.needsLangBadge('en'), isFalse);
    });
  });

  group('Seviye etiketi', () {
    test('dile gore degisir', () {
      expect(videoLevelLabel(VideoLevel.beginner, 'tr'), 'Başlangıç');
      expect(videoLevelLabel(VideoLevel.beginner, 'en'), 'Beginner');
      expect(videoLevelLabel(VideoLevel.advanced, 'en'), 'Advanced');
    });

    test('dil verilmezse Turkce', () {
      expect(videoLevelLabel(VideoLevel.intermediate), 'Orta');
    });
  });

  group('Sure etiketi', () {
    test('sure yoksa null', () {
      // Ingilizce seride sureleri dogrulayamadigimiz icin bos biraktik;
      // arayuz bunu sessizce atlamali, "0:00" yazmamali.
      final e = VideoEpisode.fromMap({
        'id': 'e1',
        'series_id': 's1',
        'title': 'x',
        'youtube_url': 'u',
      });
      expect(e.durationLabel, isNull);
    });

    test('sure varsa dakika:saniye', () {
      final e = VideoEpisode.fromMap({
        'id': 'e1',
        'series_id': 's1',
        'title': 'x',
        'youtube_url': 'u',
        'duration_seconds': 485,
      });
      expect(e.durationLabel, '8:05');
    });
  });
}
