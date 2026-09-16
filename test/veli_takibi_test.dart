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

  group('ayarlar', () {
    final ayarlar =
        File('lib/screens/settings/settings_screen.dart').readAsStringSync();

    test('çocuğa yazılmış satır kapının önünde', () {
      final i = ayarlar.indexOf('TakipKoduScreen');
      expect(i, isNot(-1));
      // O satırın onTap'inde ebeveyn kapısı OLMAMALI.
      final blok = ayarlar.substring((i - 900).clamp(0, i), i);
      expect(blok.contains('ParentGate.verify'), isFalse,
          reason: 'kod ekranı kapının arkasına düşmüş');
    });

    test('Ebeveyn Alanı hâlâ kapının arkasında', () {
      // Sabit bir karakter penceresine bakmak kırılgan: kapının dört
      // dilli açıklama metni uzun. Bunun yerine SIRAYA bakıyoruz —
      // rapor ekranından önce gelen son şey bir kapı olmalı ve arada
      // başka bir ekran açılmamalı.
      final rapor = ayarlar.indexOf('ParentAreaScreen()');
      final kapi = ayarlar.lastIndexOf('ParentGate.verify', rapor);
      expect(kapi, isNot(-1), reason: 'rapor ekranı kapısız açılıyor');

      final arada = ayarlar.substring(kapi, rapor);
      expect(arada.contains('Navigator.push'), isTrue,
          reason: 'kapı ile rapor ekranı aynı akışta değil');
      expect(arada.contains('TakipKoduScreen'), isFalse,
          reason: 'kapı ile rapor ekranı arasına başka bir ekran girmiş');
    });
  });
}
