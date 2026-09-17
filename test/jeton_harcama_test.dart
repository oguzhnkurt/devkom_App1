// JETON HARCAMA — jetonun gerçekten harcanacağı şeyler.
//
// Giyilebilirler kalktıktan sonra markette yalnızca 4 çerçeve kaldı ve Pro
// üyeler her ay 300 jeton alıyordu: harcanacak bir şey olmayınca jeton
// anlamsız bir sayıya dönüşür, kazanma isteği de kaybolur.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/models/leaderboard_model.dart';
import 'package:devkom_app/models/game_model.dart';
import 'package:devkom_app/models/store_item_model.dart';
import 'package:devkom_app/models/user_progress_model.dart';

void main() {
  final market = File('lib/screens/market_screen.dart').readAsStringSync();
  final progress =
      File('lib/services/user_progress_service.dart').readAsStringSync();
  final gecis = File('supabase/migrations/33_jeton_harcama_yenilikleri.sql')
      .readAsStringSync();

  group('seri kalkanı', () {
    test('ilerleme modeli kalkanı taşıyor', () {
      final p = UserProgress(
        userId: 'x',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(p.streakShields, 0, reason: 'varsayılan kalkan 0 olmalı');
      expect(p.copyWith(streakShields: 2).streakShields, 2);
    });

    test('kalkan YALNIZCA bir günlük boşluğu affediyor', () {
      // Iki gun ve fazlasi affedilseydi seri "her gun biraz calismak"
      // anlamini kaybederdi.
      final govde = progress.substring(
        progress.indexOf('_checkAndUpdateStreak'),
        progress.indexOf('Future<void> _kalkanKullan'),
      );
      expect(govde.contains('daysDifference == 2'), isTrue);
      expect(govde.contains('streakShields > 0'), isTrue);
    });

    test('kalkan kullanınca seri ARTMIYOR, sadece korunuyor', () {
      final govde = progress.substring(
        progress.indexOf('Future<void> _kalkanKullan'),
        progress.indexOf('Seri kalkani satin alir'),
      );
      // Seri gunu guncellenmiyor: yalnizca kalkan dusuyor ve son aktif
      // tarih bugune cekiliyor.
      expect(govde.contains("'streak_shields': kalan"), isTrue);
      expect(govde.contains("'streak_days'"), isFalse,
          reason: 'Çalışılmayan gün seriye eklenmiş');
    });

    test('satın alma sunucuda tek parça çalışıyor', () {
      // Iki ayri cagri arasinda kopan baglanti jetonu alip kalkani
      // vermeyebilirdi.
      expect(progress.contains("rpc('purchase_streak_shield'"), isTrue);
      expect(gecis.contains('for update'), isTrue,
          reason: 'Satır kilitlenmiyor — aynı anda iki istek jetonu iki kez '
              'düşürebilir');
      expect(gecis.contains('security definer'), isTrue);
    });

    test('kalkanda üst sınır var', () {
      expect(gecis.contains('shield_limit'), isTrue);
      expect(gecis.contains('v_shields + p_count > 3'), isTrue);
      expect(market.contains('shield_limit'), isTrue,
          reason: 'Sınıra takılan çocuğa ne olduğu söylenmiyor');
    });

    test('markette kalkanın ne yaptığı yazıyor', () {
      // Vaat tam olarak olani soylemeli: bir gunluk aksamayi affediyor,
      // seriyi satin almiyor.
      for (final yazi in const [
        'Seri kalkanı',
        'Streak shield',
        'Serien-Schild',
        'Escudo de racha',
      ]) {
        expect(market.contains(yazi), isTrue, reason: 'eksik: $yazi');
      }
    });
  });

  group('isim rozeti', () {
    test('rozet kaydın içinde taşınıyor', () {
      // Baska bir cocugun envanterini okumak gerekmiyor: rozet skor
      // kaydinin metadata alaninda.
      final e = LeaderboardEntry(
        id: '1',
        userId: 'u',
        userName: 'BilgeEjderha',
        gameType: GameType.quiz,
        score: 10,
        completedAt: DateTime.now(),
        metadata: const {'name_badge': '🚀'},
      );
      expect(e.nameBadge, '🚀');

      final bos = LeaderboardEntry(
        id: '2',
        userId: 'u',
        userName: 'X',
        gameType: GameType.quiz,
        score: 1,
        completedAt: DateTime.now(),
      );
      expect(bos.nameBadge, isNull);
    });

    test('sıralama ekranı rozeti gösteriyor', () {
      final ekran = File('lib/screens/leaderboard/leaderboard_screen.dart')
          .readAsStringSync();
      expect('entry.nameBadge'.allMatches(ekran).length, greaterThanOrEqualTo(2),
          reason: 'Hem podyumda hem listede görünmeli');
    });

    test('rozet değişince sonraki skora yenisi yazılıyor', () {
      expect(market.contains('rozetiUnut()'), isTrue);
    });
  });

  group('katalog', () {
    test('yeni kategoriler tanımlı', () {
      expect(storeCategoryKey(StoreItemCategory.profileBanner),
          'profile_banner');
      expect(storeCategoryKey(StoreItemCategory.nameBadge), 'name_badge');
      // Kaldirilanlarla karismamali.
      expect(kaldirilanKategoriler.contains(StoreItemCategory.profileBanner),
          isFalse);
      expect(satilanKategoriler.contains(StoreItemCategory.nameBadge), isTrue);
    });

    test('geçiş idempotent', () {
      expect(gecis.contains('on conflict (item_key) do nothing'), isTrue);
      expect(gecis.contains('add column if not exists streak_shields'), isTrue);
    });

    test('profil afişi gerçekten profilde görünüyor', () {
      final profil =
          File('lib/screens/auth/profile_screen.dart').readAsStringSync();
      expect(profil.contains('StoreItemCategory.profileBanner'), isTrue);
      expect(profil.contains('_afis'), isTrue);
    });
  });
}
