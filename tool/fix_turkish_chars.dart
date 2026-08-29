// Devkom — Türkçe karakter onarım aracı
//
// Uygulamadaki metinler ASCII'ye indirgenmiş halde yazılmış
// ("Hosgeldin", "Gunluk Hedef", "Odev", "Ozellestir" ...). Bu araç,
// SADECE string literal'lerin içinde, sözlükteki tam kelimeleri
// Türkçe karşılıklarıyla değiştirir.
//
// Çalıştırma (proje kökünden):
//   dart run tool/fix_turkish_chars.dart            # önizleme (dosya yazmaz)
//   dart run tool/fix_turkish_chars.dart --apply    # değişiklikleri yazar
//
// ÖNEMLİ: --apply'dan ÖNCE `git commit` yap. Sonra `git diff` ile gözden geçir.
//
// Güvenlik katmanları (yanlışlıkla kodu bozmamak için):
//   * Sadece string literal içi değiştirilir; değişken/sınıf/metot adlarına
//     ve import yollarına dokunulmaz.
//   * Kod örneği gibi görünen literal'ler atlanır (Arduino/Java/Python/HTML
//     içerikleri ders materyallerinde string olarak tutuluyor).
//   * snake_case anahtarlar, dosya yolları, URL'ler ve asset yolları atlanır.
//   * Atlanan ama sözlük kelimesi içeren literal'ler rapora yazılır ki elle
//     gözden geçirilebilsin: tool/turkish_fix_report.txt

import 'dart:io';

/// ASCII -> Türkçe tam kelime sözlüğü.
/// Sadece kesin/tek anlamlı karşılıkları koy. Şüpheli olanı ekleme.
const Map<String, String> kDictionary = {
  // Selamlama / ana ekran
  'Hosgeldin': 'Hoşgeldin',
  'Hosgeldiniz': 'Hoşgeldiniz',
  'Merhaba': 'Merhaba',
  'Kasif': 'Kaşif',
  'Kasifi': 'Kaşifi',
  'Gunluk': 'Günlük',
  'gunluk': 'günlük',
  'Gunluk_Hedef': 'Günlük Hedef',
  'Hedef': 'Hedef',

  // Navigasyon / kartlar
  'Odev': 'Ödev',
  'odev': 'ödev',
  'Odevler': 'Ödevler',
  'odevler': 'ödevler',
  'Gorev': 'Görev',
  'gorev': 'görev',
  'Gorevler': 'Görevler',
  'gorevler': 'görevler',
  'Ogren': 'Öğren',
  'ogren': 'öğren',
  'Eglen': 'Eğlen',
  'eglen': 'eğlen',
  'Ozellestir': 'Özelleştir',
  'ozellestir': 'özelleştir',
  'Ozellik': 'Özellik',
  'ozellik': 'özellik',
  'Ozellikler': 'Özellikler',
  'ozellikler': 'özellikler',
  'ozelliklere': 'özelliklere',
  'Magaza': 'Mağaza',
  'magaza': 'mağaza',

  // Kullanıcı / hesap
  'Ogrenci': 'Öğrenci',
  'ogrenci': 'öğrenci',
  'Ogrenciler': 'Öğrenciler',
  'ogrenciler': 'öğrenciler',
  'Ogretmen': 'Öğretmen',
  'ogretmen': 'öğretmen',
  'Ogretmenler': 'Öğretmenler',
  'Uyelik': 'Üyelik',
  'uyelik': 'üyelik',
  'Cikis': 'Çıkış',
  'cikis': 'çıkış',
  'Giris': 'Giriş',
  'giris': 'giriş',
  'Sifre': 'Şifre',
  'sifre': 'şifre',
  'Kayit': 'Kayıt',
  'kayit': 'kayıt',
  'Guvenlik': 'Güvenlik',
  'guvenlik': 'güvenlik',
  'Yardim': 'Yardım',
  'yardim': 'yardım',
  'Hakkinda': 'Hakkında',
  'hakkinda': 'hakkında',
  'Surum': 'Sürüm',
  'surum': 'sürüm',

  // Aksiyonlar
  'Basla': 'Başla',
  'basla': 'başla',
  'Baslat': 'Başlat',
  'baslat': 'başlat',
  'Baslayalim': 'Başlayalım',
  'baslayalim': 'başlayalım',
  'Yukselt': 'Yükselt',
  'yukselt': 'yükselt',
  'Yukle': 'Yükle',
  'yukle': 'yükle',
  'Yukleniyor': 'Yükleniyor',
  'yukleniyor': 'yükleniyor',
  'Indir': 'İndir',
  'Paylas': 'Paylaş',
  'paylas': 'paylaş',
  'Begen': 'Beğen',
  'begen': 'beğen',
  'Duzenle': 'Düzenle',
  'duzenle': 'düzenle',
  'Guncelle': 'Güncelle',
  'guncelle': 'güncelle',
  'Guncelleme': 'Güncelleme',
  'Sirala': 'Sırala',
  'Siralama': 'Sıralama',
  'siralama': 'sıralama',
  'Secim': 'Seçim',
  'secim': 'seçim',
  'Secili': 'Seçili',
  'secili': 'seçili',
  'Iptal': 'İptal',
  'Ileri': 'İleri',
  'Istatistik': 'İstatistik',
  'Istatistikler': 'İstatistikler',
  'Islem': 'İşlem',
  'Islemler': 'İşlemler',
  'islem': 'işlem',
  'islemler': 'işlemler',

  // Durum / geri bildirim
  'Basari': 'Başarı',
  'basari': 'başarı',
  'Basarili': 'Başarılı',
  'basarili': 'başarılı',
  'Basarisiz': 'Başarısız',
  'basarisiz': 'başarısız',
  'Basarilar': 'Başarılar',
  'basarilar': 'başarılar',
  'Tamamlandi': 'Tamamlandı',
  'tamamlandi': 'tamamlandı',
  'Tamamladin': 'Tamamladın',
  'tamamladin': 'tamamladın',
  'Uyari': 'Uyarı',
  'uyari': 'uyarı',
  'Dogru': 'Doğru',
  'dogru': 'doğru',
  'Yanlis': 'Yanlış',
  'yanlis': 'yanlış',
  'Calisiyor': 'Çalışıyor',
  'calisiyor': 'çalışıyor',
  'Hazir': 'Hazır',
  'hazir': 'hazır',
  'Acik': 'Açık',
  'acik': 'açık',
  'Kapali': 'Kapalı',
  'kapali': 'kapalı',
  'Kilitli': 'Kilitli',

  // Ölçü / zaman
  'Gun': 'Gün',
  'Yil': 'Yıl',
  'Yarin': 'Yarın',
  'Bugun': 'Bugün',
  'bugun': 'bugün',
  'Dun': 'Dün',
  'Sure': 'Süre',
  'sure': 'süre',
  'Yuksek': 'Yüksek',
  'yuksek': 'yüksek',
  'Dusuk': 'Düşük',
  'dusuk': 'düşük',
  'Toplam': 'Toplam',

  // Abonelik / ödeme
  'Ucretsiz': 'Ücretsiz',
  'ucretsiz': 'ücretsiz',
  'Satin': 'Satın',
  'satin': 'satın',
  'Odul': 'Ödül',
  'odul': 'ödül',
  'Oduller': 'Ödüller',
  'sinirsiz': 'sınırsız',
  'Sinirsiz': 'Sınırsız',
  'erisim': 'erişim',
  'Erisim': 'Erişim',
  'Tum': 'Tüm',
  'tum': 'tüm',

  // Genel
  'Cocuk': 'Çocuk',
  'cocuk': 'çocuk',
  'Cocuklar': 'Çocuklar',
  'Karanlik': 'Karanlık',
  'Aydinlik': 'Aydınlık',
  'Titresim': 'Titreşim',
  'Gecmis': 'Geçmiş',
  'gecmis': 'geçmiş',
  'Ayrintilar': 'Ayrıntılar',
  'Aciklama': 'Açıklama',
  'aciklama': 'açıklama',
  'Yerlesim': 'Yerleşim',
  'yerlesim': 'yerleşim',
  'Ipucu': 'İpucu',
  'ipucu': 'ipucu',
  'Bilgini': 'Bilgini',
  'kazandin': 'kazandın',
  'Kazandin': 'Kazandın',
  'kazanim': 'kazanım',
  'Kazanim': 'Kazanım',
  'Kazanimlar': 'Kazanımlar',
};

/// Bu ipuçlarından biri literal içinde geçiyorsa "kod örneği" sayılır ve
/// literal hiç değiştirilmez. Ders materyallerinde Arduino/Java/Python/HTML
/// kodu string olarak tutuluyor; oradaki tanımlayıcılar ASCII kalmalı.
const List<String> kCodeMarkers = [
  '#include', 'void setup', 'void loop', 'digitalWrite', 'digitalRead',
  'pinMode', 'analogWrite', 'analogRead', 'Serial.', 'delay(',
  'System.out', 'public class', 'public static', 'private ', 'protected ',
  'def ', 'import ', 'from ', 'print(', 'console.log', 'function ',
  'return ', 'if (', 'for (', 'while (', 'class ', 'new ',
  '<html', '<head', '<body', '<div', '<span', '<p>', '<h1', '<style',
  'int ', 'float ', 'double ', 'char ', 'bool ', 'const ', 'var ', 'let ',
  '();', ' = ', '==', '&&', '||', '+=', '{}',
];

final RegExp _snakeCaseKey = RegExp(r'^[a-z0-9_]+$');
final RegExp _wordChars = RegExp(r'[A-Za-z0-9_]');

bool _looksLikeCode(String literal) {
  for (final marker in kCodeMarkers) {
    if (literal.contains(marker)) return true;
  }
  return false;
}

bool _shouldSkip(String literal) {
  final trimmed = literal.trim();
  if (trimmed.isEmpty) return true;
  // snake_case anahtar / enum adı / kanal id'si
  if (_snakeCaseKey.hasMatch(trimmed)) return true;
  // yol, URL, asset, paket
  if (trimmed.contains('/') || trimmed.contains('http') || trimmed.contains('\\')) {
    return true;
  }
  if (_looksLikeCode(literal)) return true;
  return false;
}

/// Tam kelime eşleşmesiyle değiştirir (kelimenin öncesi/sonrası harf/rakam
/// olmamalı). Böylece "Gun" kelimesi "Gunes" içinde değişmez.
String _replaceWholeWords(String input) {
  var out = input;
  kDictionary.forEach((from, to) {
    if (from == to) return;
    var index = 0;
    final buffer = StringBuffer();
    while (true) {
      final found = out.indexOf(from, index);
      if (found == -1) {
        buffer.write(out.substring(index));
        break;
      }
      final beforeOk =
          found == 0 || !_wordChars.hasMatch(out[found - 1]);
      final afterIndex = found + from.length;
      final afterOk = afterIndex >= out.length ||
          !_wordChars.hasMatch(out[afterIndex]);
      buffer.write(out.substring(index, found));
      if (beforeOk && afterOk) {
        buffer.write(to);
      } else {
        buffer.write(from);
      }
      index = afterIndex;
    }
    out = buffer.toString();
  });
  return out;
}

bool _containsDictionaryWord(String s) {
  for (final key in kDictionary.keys) {
    if (kDictionary[key] == key) continue;
    if (s.contains(key)) return true;
  }
  return false;
}

// Dart string literal'lerini yakalar: '...', "...", '''...''', """..."""
final RegExp _stringLiteral = RegExp(
  r"'''(?:[\s\S]*?)'''"
  r'|"""(?:[\s\S]*?)"""'
  r"|'(?:\\.|[^'\\\n])*'"
  r'|"(?:\\.|[^"\\\n])*"',
);

void main(List<String> args) {
  final apply = args.contains('--apply');
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('HATA: lib/ bulunamadi. Bu araci proje kokunden calistir.');
    exitCode = 1;
    return;
  }

  final report = StringBuffer()
    ..writeln('Devkom - Turkce karakter onarim raporu')
    ..writeln('Mod: ${apply ? "UYGULANDI" : "ONIZLEME"}')
    ..writeln('=' * 60)
    ..writeln();

  var filesChanged = 0;
  var replacements = 0;
  var skippedCodeLiterals = 0;

  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final original = file.readAsStringSync();
    var fileReplacements = 0;
    final skippedInFile = <String>[];

    final updated = original.replaceAllMapped(_stringLiteral, (match) {
      final literal = match.group(0)!;
      // Tırnakları ayır: içerik üzerinde çalış, sınırlayıcıyı koru.
      String open, inner, close;
      if (literal.startsWith("'''") || literal.startsWith('"""')) {
        open = literal.substring(0, 3);
        close = literal.substring(literal.length - 3);
        inner = literal.substring(3, literal.length - 3);
      } else {
        open = literal.substring(0, 1);
        close = literal.substring(literal.length - 1);
        inner = literal.substring(1, literal.length - 1);
      }

      if (_shouldSkip(inner)) {
        if (_containsDictionaryWord(inner)) {
          skippedInFile.add(inner.length > 120
              ? '${inner.substring(0, 120)}...'
              : inner);
        }
        return literal;
      }

      final replaced = _replaceWholeWords(inner);
      if (replaced != inner) fileReplacements++;
      return '$open$replaced$close';
    });

    if (skippedInFile.isNotEmpty) {
      skippedCodeLiterals += skippedInFile.length;
      report
        ..writeln('ELLE GOZDEN GECIR -> ${file.path}')
        ..writeln('  (kod gibi gorundugu icin atlandi ama Turkce kelime iceriyor)');
      for (final s in skippedInFile.take(10)) {
        report.writeln('    - $s');
      }
      if (skippedInFile.length > 10) {
        report.writeln('    ... (+${skippedInFile.length - 10} tane daha)');
      }
      report.writeln();
    }

    if (updated != original) {
      filesChanged++;
      replacements += fileReplacements;
      stdout.writeln('${apply ? "YAZILDI " : "DEGISECEK"}  ${file.path}  ($fileReplacements literal)');
      if (apply) file.writeAsStringSync(updated);
    }
  }

  report
    ..writeln('=' * 60)
    ..writeln('Degisen dosya : $filesChanged')
    ..writeln('Degisen metin : $replacements')
    ..writeln('Elle bakilacak: $skippedCodeLiterals');

  File('tool/turkish_fix_report.txt').writeAsStringSync(report.toString());

  stdout
    ..writeln()
    ..writeln('-' * 60)
    ..writeln('Degisen dosya : $filesChanged')
    ..writeln('Degisen metin : $replacements')
    ..writeln('Elle bakilacak: $skippedCodeLiterals  -> tool/turkish_fix_report.txt')
    ..writeln();
  if (!apply) {
    stdout.writeln('Bu bir ONIZLEME idi. Uygulamak icin:');
    stdout.writeln('  git commit -am "wip"   # once yedekle!');
    stdout.writeln('  dart run tool/fix_turkish_chars.dart --apply');
  } else {
    stdout.writeln('Simdi kontrol et:');
    stdout.writeln('  git diff');
    stdout.writeln('  flutter analyze --no-fatal-infos');
  }
}
