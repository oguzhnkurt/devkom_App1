import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Türkçe harfi düşmüş kelimeler — **ikizi olmasa bile**.
///
/// NEDEN AYRI BİR TEST
/// -------------------
/// `ders_metni_turkce_test.dart` sözlüksüz çalışıyor: bir kelimeyi
/// ancak DOĞRU yazımı verinin başka bir yerinde de geçiyorsa yakalıyor.
/// Bu güçlü bir kural ama bir kör noktası var — hiçbir yerde doğru
/// yazılmamış bir kelime denetimden geçiyor.
///
/// Gerçek olay: CSS dersindeki bir şıkta "Veritabanina bağlanır"
/// yazıyordu. "veritabanı" kelimesi veride başka hiçbir yerde doğru
/// yazılmadığı için eski test bunu göremedi; kullanıcı ekranda gördü.
/// Aynı taramada 16 kelime daha çıktı (calisabilir, secenegin,
/// olusturulmustur, Dongusuz…).
///
/// Buradaki liste KÜÇÜK ve KESİN tutulmalı: yalnızca ASCII hâli
/// Türkçede hiçbir anlama gelmeyen kelimeler. "yani", "iste", "menu"
/// gibi ASCII hâli de doğru olan kelimeler buraya GİRMEZ.
void main() {
  /// ASCII hâli Türkçede yanlış olan kelimeler ve doğrusu.
  const yanlisDogru = <String, String>{
    'calisabilir': 'çalışabilir',
    'calisir': 'çalışır',
    'calisma': 'çalışma',
    'secenegi': 'seçeneği',
    'secenegin': 'seçeneğin',
    'secenek': 'seçenek',
    'degisince': 'değişince',
    'degismezdir': 'değişmezdir',
    'degisken': 'değişken',
    'olusturulur': 'oluşturulur',
    'olusturulmustur': 'oluşturulmuştur',
    'olustur': 'oluştur',
    'gorur': 'görür',
    'gorunur': 'görünür',
    'dongusuz': 'döngüsüz',
    'dongu': 'döngü',
    'veritabani': 'veritabanı',
    'veritabanina': 'veritabanına',
    'veritabanindan': 'veritabanından',
    'veritabanlarindaki': 'veritabanlarındaki',
    'kotu': 'kötü',
    'yapidir': 'yapıdır',
    'baglanir': 'bağlanır',
    'ogrenci': 'öğrenci',
  };

  /// Alan adı Türkçe metin mi taşıyor?
  ///
  /// `*En` / `*De` / `*Es` başka dillerin metni. `id`, `targetCode`,
  /// `mustContain` ise kod ya da eşleşme anahtarı — Türkçeleştirilirse
  /// ders bozulur.
  bool turkceAlan(String ad) =>
      !ad.endsWith('En') &&
      !ad.endsWith('De') &&
      !ad.endsWith('Es') &&
      !const {'id', 'type', 'language', 'targetCode', 'mustContain'}
          .contains(ad);

  /// Ders metnine gömülü kod parçası.
  ///
  /// Kod örneklerindeki tanıtıcılar ASCII KALMALI: `class Ogrenci`
  /// içindeki "Ogrenci" bir hata değil, derlenebilir bir isim.
  final kodGorunumu = RegExp(r'[;{}=<>\[\]]|\w+\(|\.[A-Za-z]');

  final alan = RegExp(
    r"(?<f>[A-Za-z_][A-Za-z0-9_]*)\s*:\s*'(?<s>(?:[^'\\\n]|\\.)*)'",
  );

  test('ders metinlerinde Turkce harfi dusmus kelime yok (kara liste)', () {
    final bulgular = <String>[];

    final dosyalar = <File>[];
    for (final klasor in ['lib/courses/data', 'lib/data']) {
      final dizin = Directory(klasor);
      if (!dizin.existsSync()) continue;
      dosyalar.addAll(dizin
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')));
    }
    expect(dosyalar, isNotEmpty);

    for (final dosya in dosyalar) {
      final kaynak = dosya.readAsStringSync();
      for (final m in alan.allMatches(kaynak)) {
        final alanAdi = m.namedGroup('f')!;
        if (!turkceAlan(alanAdi)) continue;
        final metin = m.namedGroup('s')!;

        for (final kelimeM in RegExp(r'[A-Za-z]+').allMatches(metin)) {
          final kelime = kelimeM.group(0)!.toLowerCase();
          final dogru = yanlisDogru[kelime];
          if (dogru == null) continue;

          // Cevresi koda benziyorsa dokunma.
          final bas = (kelimeM.start - 30).clamp(0, metin.length);
          final son = (kelimeM.end + 30).clamp(0, metin.length);
          if (kodGorunumu.hasMatch(metin.substring(bas, son))) continue;

          final satir = '\n'.allMatches(kaynak.substring(0, m.start)).length + 1;
          bulgular.add('${dosya.path.split('/').last}:$satir  '
              '"${kelimeM.group(0)}" -> "$dogru"\n      $metin');
        }
      }
    }

    expect(bulgular, isEmpty,
        reason: 'Bu kelimelerin ASCII yazimi Turkcede yanlis. Cocuklar bu '
            'metinleri okuyarak Turkce de ogreniyor.\n${bulgular.join('\n')}');
  });
}
