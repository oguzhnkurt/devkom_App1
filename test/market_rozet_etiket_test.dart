// Market: rozet, etiket ve pahali cerceveler (Ekim 2026).
import 'dart:io';

import 'package:devkom_app/data/store_catalog_locale.dart';
import 'package:devkom_app/models/store_item_model.dart';
import 'package:devkom_app/widgets/avatar_cercevesi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

StoreItem _urun(String key, String kat, {String emoji = '⭐', int fiyat = 100}) =>
    StoreItem.fromMap({
      'id': key,
      'item_key': key,
      'category': kat,
      'name': key,
      'price_jeton': fiyat,
      'icon_emoji': emoji,
      'color_hex': '#7C4DFF',
    });

void main() {
  final sql = File('supabase/migrations/36_market_tamamlama.sql').readAsStringSync();

  test('kategori kisiti yeni kategorileri kabul ediyor', () {
    // Uretimde 33/34'un sessizce dusmesinin sebebi bu kisitti.
    final kisit = sql.substring(sql.indexOf('add constraint store_items_category_check'));
    for (final k in ['profile_banner', 'name_badge', 'profile_tag', 'avatar_frame']) {
      expect(kisit.contains("'$k'"), isTrue, reason: k);
    }
    expect(sql.indexOf('add constraint'), lessThan(sql.indexOf('insert into store_items')),
        reason: 'kisit eklemeden ONCE genisletilmeli');
  });

  test('gocteki her urunun kategorisi kisitta var', () {
    final kisit = sql.substring(sql.indexOf('check (category in'), sql.indexOf('));'));
    final satir = RegExp(r"\('([a-z_]+)',\s*'([a-z_]+)'");
    for (final m in satir.allMatches(sql)) {
      expect(kisit.contains("'${m.group(2)}'"), isTrue, reason: m.group(1));
    }
  });

  test('etiketler ve yeni rozetler dort dilde', () {
    final satir = RegExp(r"\('((?:tag|badge|frame|banner)_[a-z]+)',");
    for (final m in satir.allMatches(sql)) {
      final key = m.group(1)!;
      final metin = kStoreUrunMetinleri[key];
      expect(metin, isNotNull, reason: '$key cevirisi yok');
      for (final l in ['tr', 'en', 'de', 'es']) {
        expect(metin!.ad(l).trim(), isNotEmpty, reason: '$key/$l');
      }
    }
  });

  test('pahali cerceveler kendi cizim ailesinde', () {
    expect(cerceveStili('frame_dragon'), CerceveStili.kanat);
    expect(cerceveStili('frame_angel'), CerceveStili.kanat);
    expect(cerceveStili('frame_emperor'), CerceveStili.tac);
    expect(cerceveStili('frame_legend'), CerceveStili.efsane);
    expect(cerceveStili('frame_cosmic'), CerceveStili.efsane);
    for (final k in ['frame_cosmic', 'frame_dragon', 'frame_angel', 'frame_legend', 'frame_emperor']) {
      final satir = sql.split('\n').firstWhere((l) => l.contains("('$k',"));
      final fiyat = int.parse(RegExp(r"',\s*(\d+),\s*'").firstMatch(satir)!.group(1)!);
      expect(fiyat, greaterThanOrEqualTo(400), reason: k);
    }
  });

  test('profile_tag kategorisi okunuyor ve markette satiliyor', () {
    expect(_urun('tag_coder', 'profile_tag').category, StoreItemCategory.profileTag);
    expect(satilanKategoriler, contains(StoreItemCategory.profileTag));
    expect(storeCategoryKey(StoreItemCategory.profileTag), 'profile_tag');
    for (final l in ['tr', 'en', 'de', 'es']) {
      expect(storeCategoryDisplayName(StoreItemCategory.profileTag, l), isNotEmpty);
    }
  });

  testWidgets('cerceveye rozet ve etiket takiliyor', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: AvatarCercevesi(
            boyut: 150,
            cerceve: _urun('frame_emperor', 'avatar_frame', emoji: '👑'),
            rozet: _urun('badge_trophy', 'name_badge', emoji: '🏆'),
            etiket: _urun('tag_coder', 'profile_tag', emoji: '💻'),
            child: const Text('D'),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(TakiliRozet), findsOneWidget);
    expect(find.byType(TakiliEtiket), findsOneWidget);
    // Etiket ingilizce olmayan ortamda Turkce adi gosteriyor.
    expect(find.textContaining('Code Master'), findsOneWidget);
    // Rozet takiliyken cercevenin kendi kose simgesi cizilmiyor.
    expect(find.text('👑'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('profil takilanlari yukluyor ve gosteriyor', () {
    final s = File('lib/screens/auth/profile_screen.dart').readAsStringSync();
    expect(s.contains('getEquippedItem(StoreItemCategory.nameBadge)'), isTrue);
    expect(s.contains('getEquippedItem(StoreItemCategory.profileTag)'), isTrue);
    expect(s.contains('rozet: _rozet'), isTrue);
    expect(s.contains('etiket: _etiket'), isTrue);
  });
}
