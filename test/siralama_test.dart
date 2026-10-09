// Yarisma tablosu: iki kulvar (genel XP ve satranc), ana sayfa karti,
// Etkinlikler'deki video karti (Ekim 2026).
import 'dart:io';

import 'package:devkom_app/models/game_model.dart';
import 'package:devkom_app/screens/leaderboard/leaderboard_screen.dart';
import 'package:devkom_app/services/siralama_servisi.dart';
import 'package:devkom_app/widgets/siralama_karti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _cerceve() => {
      'id': 'f1',
      'item_key': 'frame_gold',
      'category': 'avatar_frame',
      'name': 'Altın Çerçeve',
      'price_jeton': 200,
      'icon_emoji': '🏅',
      'color_hex': '#F2A33C',
    };

Map<String, dynamic> _etiket() => {
      'id': 't1',
      'item_key': 'tag_coder',
      'category': 'profile_tag',
      'name': 'Kod Ustası',
      'price_jeton': 50,
      'icon_emoji': '💻',
      'color_hex': '#5A34E8',
    };

final _genel = <Map<String, dynamic>>[
  {'sira': 1, 'ad': 'Ayşe K.', 'xp': 2450, 'seviye': 9, 'cerceve': _cerceve(), 'rozet': null, 'etiket': _etiket(), 'ben': false},
  {'sira': 2, 'ad': 'Can', 'xp': 900, 'seviye': 4, 'cerceve': null, 'rozet': null, 'etiket': null, 'ben': false},
  {'sira': 57, 'ad': 'Deniz Y.', 'xp': 120, 'seviye': 1, 'cerceve': null, 'rozet': null, 'etiket': null, 'ben': true},
];

final _satranc = <Map<String, dynamic>>[
  {'sira': 1, 'ad': 'Mert A.', 'zorluk': 3, 'sure': 247, 'cerceve': null, 'rozet': null, 'etiket': null, 'ben': false},
  {'sira': 2, 'ad': 'Deniz Y.', 'zorluk': 2, 'sure': 95, 'cerceve': null, 'rozet': null, 'etiket': null, 'ben': true},
];

Widget _uygulama(Widget w) => MaterialApp(
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: w,
    );

void main() {
  setUp(() {
    SiralamaServisi.rpcCagir = (fn, p) async =>
        fn == 'siralama_genel' ? _genel : _satranc;
  });
  tearDown(() => SiralamaServisi.rpcCagir = null);

  test('satir cozumleniyor; takili urunler StoreItem oluyor', () async {
    final l = await SiralamaServisi.getir(SiralamaKulvari.genel);
    expect(l.length, 3);
    expect(l.first.cerceve?.itemKey, 'frame_gold');
    expect(l.first.etiket?.itemKey, 'tag_coder');
    expect(SiralamaServisi.benimSatirim(l)?.sira, 57);
    expect(SiralamaServisi.sureYazisi(247), '4:07');
  });

  testWidgets('iki sekme; genelde XP, benim yerim ayrica gorunuyor',
      (tester) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_uygulama(const LeaderboardScreen()));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const ValueKey('siralama_sekme_genel')), findsOneWidget);
    expect(find.byKey(const ValueKey('siralama_sekme_satranc')), findsOneWidget);
    expect(find.text('Ayşe K.'), findsOneWidget);
    expect(find.text('2.450 XP'), findsOneWidget);
    expect(find.byKey(const ValueKey('siralama_benim_yerim')), findsOneWidget);
    expect(find.text('Senin yerin: 57.'), findsOneWidget);
  });

  testWidgets('satranctan acilinca satranc sekmesi: seviye ve sure',
      (tester) async {
    tester.view.physicalSize = const Size(430 * 3, 932 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_uygulama(
        const LeaderboardScreen(initialGameType: GameType.chess)));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Mert A.'), findsOneWidget);
    expect(find.textContaining('İmkânsız · 4:07'), findsOneWidget);
    expect(find.textContaining('Zor · 1:35'), findsWidgets);
  });

  testWidgets('ana sayfa karti iki kulvarda kendi yerini yaziyor',
      (tester) async {
    await tester.pumpWidget(_uygulama(
        const Scaffold(body: SiralamaKarti(lang: 'tr'))));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Sıralamadaki yerini gör'), findsOneWidget);
    expect(find.text('57.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
  });

  testWidgets('sunucu hata verirse kart yine cikiyor, sayi gostermiyor',
      (tester) async {
    SiralamaServisi.rpcCagir = (fn, p) async => throw Exception('yok');
    await tester.pumpWidget(_uygulama(
        const Scaffold(body: SiralamaKarti(lang: 'tr'))));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Sıralamadaki yerini gör'), findsOneWidget);
    expect(find.text('henüz yok'), findsNWidgets(2));
  });

  test('ana sayfanin en altinda siralama karti var', () {
    final s = File('lib/screens/unified_home_screen.dart').readAsStringSync();
    final kart = s.indexOf('SiralamaKarti(lang: _lang)');
    expect(kart, greaterThan(0));
    // Ilk acilis ve normal dalin ikisinden de SONRA (en altta).
    expect(kart, greaterThan(s.indexOf('_buildMoreSection(isDark, userProgress)')));
    expect(kart, greaterThan(s.indexOf('DeviBilmeceKarti(lang: _lang)')));
  });

  test('SQL: yalnizca ad + bas harf disari cikiyor, e-posta yok', () {
    final sql = File('supabase/migrations/37_siralama.sql').readAsStringSync();
    expect(sql.contains('security definer'), isTrue);
    expect(sql.contains('_siralama_adi(u.display_name)'), isTrue);
    final govde = sql.substring(sql.indexOf('create or replace function public.siralama_genel'));
    expect(govde.contains('email'), isFalse);
    // Satranc: once zorluk (azalan), sonra sure (artan).
    expect(sql.contains('order by e.difficulty desc, e.time_seconds asc'), isTrue);
  });

  test('Etkinlikler: Pro dahil video izleyip jeton kazanma karti', () {
    final hub = File('lib/screens/activity_hub_screen.dart').readAsStringSync();
    expect(hub.contains('_VideoJetonKarti(lang: lang)'), isTrue);
    final yardimci = File('lib/widgets/jeton_videosu.dart').readAsStringSync();
    expect(yardimci.contains('showRewarded(gonullu: true)'), isTrue);
    expect(yardimci.contains('canWatchRewarded(gonullu: true)'), isTrue);
  });
}
