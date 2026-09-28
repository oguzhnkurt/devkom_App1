// Market metinleri dört dilde olmalı.
//
// SORUN NEYDİ
// -----------
// `store_items` tablosunda `name` ve `description` tek birer sütun ve
// içleri Türkçe. Uygulamanın geri kalanı dört dilli ve testlerle bu
// zorlanıyor — ama o denetimler KODU tarıyor, katalog metinleri ise
// veritabanındaydı. Sonuç: İngilizce seçmiş bir çocuk, tamamen İngilizce
// bir ekranın ortasında "Alev Çerçevesi" ve "Avatar Çerçeveleri" görüyordu.
//
// Çeviriler `lib/data/store_catalog_locale.dart` içine alındı. Bu test
// o dosyayı göçlerle karşılaştırıyor: katalogda satılan her ürünün dört
// dilde adı ve açıklaması olmak zorunda.
import 'dart:io';

import 'package:devkom_app/data/store_catalog_locale.dart';
import 'package:devkom_app/models/store_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Yalnızca Türkçede bulunan harfler.
///
/// 'I' BİLEREK YOK: Türkçe'nin noktasız büyük I'si ile İngilizce'nin I'si
/// aynı kod noktası. Listeye eklenseydi "Ice Frame" Türkçe sanılırdı.
const _turkceHarfler = 'ğĞışŞçÇİ';

void main() {
  late final Map<String, String> katalog; // item_key -> category

  setUpAll(() {
    // Göçlerdeki insert satırları: ('key', 'category', 'ad', 'aciklama', fiyat
    final desen = RegExp(
        r"\(\s*'([a-z0-9_]+)'\s*,\s*'([a-z_]+)'\s*,\s*'(?:[^']|'')*'\s*,"
        r"\s*'(?:[^']|'')*'\s*,\s*\d+");
    final bulunan = <String, String>{};
    for (final e in Directory('supabase/migrations').listSync()) {
      if (e is! File || !e.path.endsWith('.sql')) continue;
      for (final m in desen.allMatches(e.readAsStringSync())) {
        bulunan.putIfAbsent(m.group(1)!, () => m.group(2)!);
      }
    }
    katalog = bulunan;
  });

  test('satilan her urunun dort dilde metni var', () {
    // Giyilebilirler katalogdan kalkti; yalnizca satilanlar denetleniyor.
    const satilan = {'avatar_frame', 'profile_banner', 'name_badge'};
    final urunler = katalog.entries
        .where((e) => satilan.contains(e.value))
        .map((e) => e.key)
        .toList()
      ..sort();

    expect(urunler.length, greaterThanOrEqualTo(30),
        reason: 'Goc taramasi calismiyor olabilir: ${urunler.length} urun.');

    final eksik =
        urunler.where((k) => !kStoreUrunMetinleri.containsKey(k)).toList();
    expect(eksik, isEmpty,
        reason: 'Bu urunler markette satiliyor ama cevirisi yok; Turkce '
            'adlariyla gorunurler: $eksik');
  });

  test('hicbir ceviri bos degil', () {
    for (final giris in kStoreUrunMetinleri.entries) {
      final m = giris.value;
      for (final metin in [
        m.adTr, m.adEn, m.adDe, m.adEs,
        m.aciklamaTr, m.aciklamaEn, m.aciklamaDe, m.aciklamaEs,
      ]) {
        expect(metin.trim(), isNotEmpty,
            reason: '${giris.key} icinde bos bir metin var.');
      }
    }
  });

  test('turkce metin ingilizce/almanca/ispanyolcaya sizmamis', () {
    final sizinti = <String>[];
    for (final giris in kStoreUrunMetinleri.entries) {
      final m = giris.value;
      final digerDiller = {
        'en': [m.adEn, m.aciklamaEn],
        'de': [m.adDe, m.aciklamaDe],
        'es': [m.adEs, m.aciklamaEs],
      };
      digerDiller.forEach((dil, metinler) {
        for (final metin in metinler) {
          if (metin.split('').any(_turkceHarfler.contains)) {
            sizinti.add('${giris.key} [$dil]: "$metin"');
          }
        }
      });
    }
    expect(sizinti, isEmpty,
        reason: 'Turkce harf iceren ceviriler (kopyalanmis olabilir):\n'
            '${sizinti.join('\n')}');
  });

  test('kategori adlari dort dilde ve birbirinden farkli', () {
    for (final kategori in satilanKategoriler) {
      final adlar = {
        for (final dil in ['tr', 'en', 'de', 'es'])
          dil: storeCategoryDisplayName(kategori, dil)
      };

      for (final giris in adlar.entries) {
        expect(giris.value.trim(), isNotEmpty,
            reason: '$kategori / ${giris.key} bos.');
      }

      // Turkce ad obur ucunde aynen tekrarlanmamali: ceviri unutulmus
      // olur ve kimse fark etmez.
      for (final dil in ['en', 'de', 'es']) {
        expect(adlar[dil], isNot(equals(adlar['tr'])),
            reason: '$kategori icin $dil adi Turkcesiyle ayni: '
                '"${adlar[dil]}"');
      }
    }
  });

  test('adFor bilinmeyen urunde veritabanindaki ada dusuyor', () {
    final bilinmeyen = StoreItem(
      id: 'x',
      itemKey: 'frame_boyle_bir_sey_yok',
      category: StoreItemCategory.avatarFrame,
      name: 'Veritabanindaki Ad',
      priceJeton: 10,
      iconEmoji: '🙂',
      colorHex: '#123456',
    );
    // Cokmemeli, bos donmemeli.
    expect(bilinmeyen.adFor('en'), 'Veritabanindaki Ad');
    expect(bilinmeyen.aciklamaFor('en'), '');
  });
}
