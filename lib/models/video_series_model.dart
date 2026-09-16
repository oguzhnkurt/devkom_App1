/// Video dersler modelleri.
/// Tablolar: video_series, video_episodes, user_video_progress
/// (bkz. Supabase migration: video_series)
library;

import 'package:flutter/material.dart';

import '../utils/lang.dart';

enum VideoLevel { beginner, intermediate, advanced }

VideoLevel _parseLevel(String? value) {
  switch (value) {
    case 'intermediate':
      return VideoLevel.intermediate;
    case 'advanced':
      return VideoLevel.advanced;
    default:
      return VideoLevel.beginner;
  }
}

String videoLevelLabel(VideoLevel level, [String lang = 'tr']) {
  // Onceki surumde yalnizca 'en' biliniyordu: almanca ya da ispanyolca
  // secen cocuk seviye rozetini Turkce goruyordu.
  switch (level) {
    case VideoLevel.beginner:
      return AppLang.pick(lang,
          tr: 'Başlangıç', en: 'Beginner', de: 'Anfänger', es: 'Principiante');
    case VideoLevel.intermediate:
      return AppLang.pick(lang,
          tr: 'Orta', en: 'Intermediate', de: 'Mittelstufe', es: 'Intermedio');
    case VideoLevel.advanced:
      return AppLang.pick(lang,
          tr: 'İleri',
          en: 'Advanced',
          de: 'Fortgeschritten',
          es: 'Avanzado');
  }
}

/// Katalog alanlarinda dil secimi.
///
/// Katalogda yalnizca Turkce ve Ingilizce metin var. Kural, uygulamanin
/// her yerindeki zincirle ayni: `tr` ise Turkce, baska her dilde varsa
/// Ingilizce, o da yoksa Turkce. Onceki surumde kosul `lang == 'en'` idi;
/// almanca ya da ispanyolca secen cocuk Ingilizce cevirisi hazir oldugu
/// halde Turkce bolum basligi goruyordu.
String _pick(String base, String? en, String lang) {
  if (lang == 'tr') return base;
  if (en != null && en.trim().isNotEmpty) return en;
  return base;
}

Color videoLevelColor(VideoLevel level) {
  switch (level) {
    case VideoLevel.beginner:
      return const Color(0xFF2E7D32);
    case VideoLevel.intermediate:
      return const Color(0xFFEF6C00);
    case VideoLevel.advanced:
      return const Color(0xFFC62828);
  }
}

/// Bir video serisi (ör. "Scratch 101").
class VideoSeries {
  final String id;
  final String slug;
  final String title;
  final String? titleEn;
  final String? description;
  final String? descriptionEn;
  final String coverEmoji;
  final String colorHex;
  final VideoLevel level;
  final bool requiresPro;
  final int sortOrder;

  /// Serinin anlatim dili ('tr' / 'en'). Ingilizce arayuzde Turkce anlatimli
  /// bir seriyi one cikarmak kullaniciya yaramiyor; liste bu alana gore
  /// siralaniyor ve rozet gosteriyor.
  final String audioLang;

  /// Seriye ait bölümler. Liste ekranında boş gelir, detayda doldurulur.
  final List<VideoEpisode> episodes;

  const VideoSeries({
    required this.id,
    required this.slug,
    required this.title,
    this.titleEn,
    this.description,
    this.descriptionEn,
    required this.coverEmoji,
    required this.colorHex,
    required this.level,
    this.requiresPro = false,
    this.sortOrder = 0,
    this.audioLang = 'tr',
    this.episodes = const [],
  });

  /// Serinin kendi basligi zaten anlatim dilinde yazili (almanca seri
  /// almanca baslikli). Cocuk baska bir dildeyse turkce baslik gostermek
  /// yerine ingilizce cevirisine dusuyoruz - ingilizce, turkceden cok
  /// daha genis bir kitle icin okunabilir.
  String _localized(String base, String? en, String lang) {
    if (lang == audioLang) return base;
    if (lang != 'tr' && en != null && en.trim().isNotEmpty) return en;
    return base;
  }

  String titleFor(String lang) => _localized(title, titleEn, lang);
  String? descriptionFor(String lang) => description == null
      ? descriptionEn
      : _localized(description!, descriptionEn, lang);

  /// Anlatim dili arayuz dilinden farkliysa kartta bir rozet gosteriyoruz;
  /// cocuk videoyu acmadan once hangi dilde anlatildigini bilsin.
  bool needsLangBadge(String lang) => audioLang != lang;

  Color get color {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF6C3CE0);
    }
  }

  factory VideoSeries.fromMap(Map<String, dynamic> map) {
    final rawEpisodes = map['video_episodes'];
    return VideoSeries(
      id: map['id'],
      slug: map['slug'] ?? '',
      title: map['title'] ?? '',
      titleEn: map['title_en'],
      description: map['description'],
      descriptionEn: map['description_en'],
      coverEmoji: map['cover_emoji'] ?? '🎬',
      colorHex: map['color_hex'] ?? '#6C3CE0',
      level: _parseLevel(map['level']),
      requiresPro: map['requires_pro'] ?? false,
      sortOrder: map['sort_order'] ?? 0,
      audioLang: map['audio_lang'] ?? 'tr',
      episodes: rawEpisodes is List
          ? (rawEpisodes.map((e) => VideoEpisode.fromMap(e)).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
          : const [],
    );
  }

  VideoSeries copyWith({List<VideoEpisode>? episodes}) => VideoSeries(
        id: id,
        slug: slug,
        title: title,
        titleEn: titleEn,
        description: description,
        descriptionEn: descriptionEn,
        coverEmoji: coverEmoji,
        colorHex: colorHex,
        level: level,
        requiresPro: requiresPro,
        sortOrder: sortOrder,
        audioLang: audioLang,
        episodes: episodes ?? this.episodes,
      );
}

/// Bir seri içindeki tek bölüm.
class VideoEpisode {
  final String id;
  final String seriesId;
  final String title;
  final String? titleEn;
  final String? description;
  final String? descriptionEn;
  final String youtubeUrl;
  final int? durationSeconds;
  final int xpReward;
  final int jetonReward;
  final int sortOrder;

  /// Videoyu yayınlayan YouTube kanalı. Gömülü içerikte atıf zorunlu:
  /// bu videolar bize ait değil, seçkimizin parçası.
  final String? channelName;
  final String? channelUrl;

  const VideoEpisode({
    required this.id,
    required this.seriesId,
    required this.title,
    this.titleEn,
    this.description,
    this.descriptionEn,
    required this.youtubeUrl,
    this.durationSeconds,
    this.xpReward = 5,
    this.jetonReward = 3,
    this.sortOrder = 0,
    this.channelName,
    this.channelUrl,
  });

  String titleFor(String lang) => _pick(title, titleEn, lang);
  String? descriptionFor(String lang) =>
      description == null ? descriptionEn : _pick(description!, descriptionEn, lang);

  /// "8:05" biçiminde süre; süre girilmemişse null.
  String? get durationLabel {
    final total = durationSeconds;
    if (total == null || total <= 0) return null;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory VideoEpisode.fromMap(Map<String, dynamic> map) {
    return VideoEpisode(
      id: map['id'],
      seriesId: map['series_id'] ?? '',
      title: map['title'] ?? '',
      titleEn: map['title_en'],
      description: map['description'],
      descriptionEn: map['description_en'],
      youtubeUrl: map['youtube_url'] ?? '',
      durationSeconds: map['duration_seconds'],
      xpReward: map['xp_reward'] ?? 5,
      jetonReward: map['jeton_reward'] ?? 3,
      sortOrder: map['sort_order'] ?? 0,
      channelName: map['channel_name'],
      channelUrl: map['channel_url'],
    );
  }
}
