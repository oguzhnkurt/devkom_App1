import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Veli takibinin kaynak ve şema denetimi.
///
/// Uygulama tarafı (`ChildLinkService` + Ebeveyn Alanı) yazılmıştı ama
/// veritabanı tarafı hiç yoktu: bütün çağrılar `catch`'e düşüp sessizce
/// `null` dönüyordu. Yani ekranlar vardı, özellik yoktu. Bu test hem o
/// boşluğun geri gelmesini hem de tasarımın sessizce gevşemesini
/// engelliyor.
void main() {
  final migration =
      File('supabase/migrations/32_child_link.sql').readAsStringSync();
  final servis =
      File('lib/services/child_link_service.dart').readAsStringSync();
  final kodEkrani =
      File('lib/screens/parent/takip_kodu_screen.dart').readAsStringSync();

  group('şema — üretimdeki hâlini belgeliyor', () {
    // NOT: bu şema Supabase panelinden elle uygulanmıştı ve repoda
    // karşılığı yoktu. "Dosya yok, demek ki veritabanı da yok" diye
    // çıkarım yapmak yanlıştı; dosya artık üretimde gerçekten duranı,
    // onun kendi policy adlarıyla yazıyor.

    test('uygulamanın beklediği üç nesne de belgelenmiş', () {
      for (final ad in [
        'child_link_codes',
        'child_links',
        'redeem_child_code',
      ]) {
        expect(migration.contains(ad), isTrue, reason: '$ad dosyada yok');
      }
    });

    test('kod tek kullanımlık ve süreli', () {
      expect(migration.contains("interval '24 hours'"), isTrue);
      expect(migration.contains('expires_at > now()'), isTrue);
      expect(
        migration.contains('delete from public.child_link_codes where code'),
        isTrue,
        reason: 'kod kullanıldıktan sonra silinmiyor',
      );
    });

    test('bağ yalnızca RPC ile kurulabiliyor', () {
      // child_links üzerinde INSERT policy'si olmamalı — ne üretimde ne
      // de burada. Dosya bunu açıkça yazıyor.
      expect(migration.contains('INSERT policy\'si BILEREK YOK'), isTrue);
      expect(migration.contains('create policy'), isFalse,
          reason: 'bu dosya policy KURMAMALI, yalnızca belgelemeli');
    });

    test('çocuk kendi kodunu kullanamıyor', () {
      expect(migration.contains('v_child = v_parent'), isTrue,
          reason: 'çocuk kendi kodunu girip takipçi sayısını şişirebilir');
    });

    test('ebeveyne YAZMA yetkisi verilmiyor', () {
      expect(migration.contains('hepsi yalnizca SELECT'), isTrue);
      expect(migration.contains('bag tek yonlu'), isTrue);
      // Dört okuma politikasının dördü de adıyla belgelenmiş olmalı.
      for (final ad in [
        'linked parent reads child user',
        'linked parent reads activity',
        'linked parent reads videos',
        'linked parent reads quests',
      ]) {
        expect(migration.contains(ad), isTrue, reason: '$ad belgelenmemiş');
      }
    });
  });

  group('kod ekranı — kapının ÖNÜNDE olduğu için', () {
    test('ne olduğunu açıkça söyleyen bir uyarı var', () {
      expect(kodEkrani.contains('sadece annene ya da babana ver'), isTrue);
      expect(kodEkrani.contains('tanımadığın birine verme'), isTrue);
    });

    test('uyarı dört dilde', () {
      // Uyarı yalnızca Türkçe olursa, kodu paylaşma riskini yalnızca
      // Türkçe okuyan çocuk öğrenmiş olur.
      expect(kodEkrani.contains('do not give it to'), isTrue);
      expect(kodEkrani.contains('den du nicht kennst'), isTrue);
      expect(kodEkrani.contains('no se lo'), isTrue);
    });

    test('çocuk takibi kapatabiliyor', () {
      // Özelliği çocuğun eline veriyorsak kapatmayı da vermeliyiz.
      expect(kodEkrani.contains('unlinkAllWatchers'), isTrue);
      expect(servis.contains('static Future<void> unlinkAllWatchers()'), isTrue);
    });

    test('kod yenilenebiliyor', () {
      expect(kodEkrani.contains('revokeCode'), isTrue);
    });
  });

  group('tek giris noktasi', () {
    // Ekim 2026: veli takibi uc yerden aciliyordu (Ayarlar > Ebeveyn
    // Alani, Ayarlar > "Etkinliklerimi velimle paylas", Hesap > Paylasim).
    // Artik tek yer Profil'deki veli takibi karti; cocugun kendi kodu da
    // o kartin altindaki "Velin icin kodunu goster" satirinda.
    test('Ayarlar ve Hesap ekraninda veli takibi girisi yok', () {
      for (final f in [
        'lib/screens/settings/settings_screen.dart',
        'lib/screens/auth/hesap_ekrani.dart',
      ]) {
        final s = File(f).readAsStringSync();
        expect(s.contains('TakipKoduScreen'), isFalse, reason: f);
        expect(s.contains('ParentAreaScreen'), isFalse, reason: f);
        expect(s.contains('velimle paylaş'), isFalse, reason: f);
      }
      expect(File('lib/screens/parent/parent_area_screen.dart').existsSync(),
          isFalse);
    });

    test('cocugun kodu Profil kartindan aciliyor', () {
      final k = File('lib/widgets/veli_takip_karti.dart').readAsStringSync();
      expect(k.contains("ValueKey('kodumu_goster')"), isTrue);
      expect(k.contains('TakipKoduScreen()'), isTrue);
    });
  });
}
