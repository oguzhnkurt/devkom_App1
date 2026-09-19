import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ders metinlerinde Türkçe harfi düşmüş kelime kalmasın.
///
/// GERÇEK OLAY: ders verisi uzun süre boyunca "değişken" ile "degisken",
/// "döngü" ile "dongu", "Dünya" ile "Dunya" biçimlerini yan yana taşıdı.
/// Aynı dersin bir adımında doğru, bir sonrakinde bozuk yazılıyordu.
/// Bunu okuyan kitle Türkçeyi yeni öğrenen çocuklar; uygulama onlara
/// yanlış yazımı örnek gösteriyordu. 17 Eylül 2026'da 400'ün üzerinde
/// kelime elle onaylanarak düzeltildi.
///
/// NASIL ÇALIŞIYOR — sözlük yok, tutarlılık var:
/// Türkçe bir sözlüğe bağlanmadan, verinin kendisini kaynak kabul
/// ediyoruz. Bir kelime metinde bir yerde "döngü" diye geçiyorsa, aynı
/// kelimenin "dongu" yazımı **o veride** hatadır. Denetim, Türkçe
/// harflerini ASCII'ye indirip (ç→c, ğ→g, ı→i, ö→o, ş→s, ü→u, â→a, î→i,
/// û→u) iki biçimin çakışıp çakışmadığına bakıyor. Kök eşlemesi de var:
/// "siniflarinda", "sınıf" doğru biçimi yüzünden yakalanıyor.
///
/// SINIRI: yalnızca **doğru ikizi veride bulunan** kelimeleri görür.
/// Hiçbir yerde doğru yazılmamış bir kelime (ör. tek geçen
/// "Metodlari") bu denetimden geçer. Yine de yeni eklenen metinlerin
/// eskilerle tutarsızlaşmasını engelliyor.
///
/// NEDEN BU KADAR FİLTRE VAR:
///  * `*En` / `*De` / `*Es` alanları başka dillerin metni.
///  * `id`, `keywords`, `targetCode`, `mustContain` gibi alanlar kod ya
///    da eşleştirme anahtarı; Türkçeleştirilirse ders bozulur.
///  * Ders metinlerinin içine `\n` ile kod parçaları gömülü
///    ("class Ogrenci {"). Noktalı virgül, süslü parantez, `=`, `<`, `>`,
///    `ad(` ve `.metot` içeren satır parçaları kod sayılıp atlanıyor.
///  * [_izinli] listesi, ASCII hâli de doğru olan kelimeler ("yani",
///    "iste") ile ders metninde bilerek ASCII kalan tanıtıcılar
///    ("deger", "esya", "sensor") içindir. Bu listeye kelime eklemek,
///    "bu yazım bilerek böyle" demektir — düzeltmekten kaçmak için
///    kullanılmamalı.
void main() {
  test('ders metinlerinde Turkce harfi dusmus kelime yok', () {
    final dosyalar = <File>[];
    for (final klasor in ['lib/courses/data', 'lib/data']) {
      final dizin = Directory(klasor);
      if (!dizin.existsSync()) continue;
      dosyalar.addAll(dizin
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')));
    }
    dosyalar.sort((a, b) => a.path.compareTo(b.path));
    expect(dosyalar, isNotEmpty, reason: 'ders verisi dosyalari bulunamadi');

    final gecisler = <_Gecis>[];
    for (final dosya in dosyalar) {
      final kaynak = dosya.readAsStringSync();
      var alan = '';
      for (final m in _belirtec.allMatches(kaynak)) {
        if (m.namedGroup('lc') != null) continue;
        final alanAdi = m.namedGroup('f');
        if (alanAdi != null) {
          alan = alanAdi.substring(0, alanAdi.length - 1).trim();
          continue;
        }
        final dize = m.namedGroup('s');
        if (dize == null) continue;
        if (alan.endsWith('En') || alan.endsWith('De') || alan.endsWith('Es')) {
          continue;
        }
        if (_kodAlanlari.contains(alan)) continue;

        final icerik = dize.substring(1, dize.length - 1);
        final satir = '\n'.allMatches(kaynak.substring(0, m.start)).length + 1;
        for (final parca in icerik.split(r'\n')) {
          if (_kodGorunumu.hasMatch(parca)) continue;
          for (final km in _kelime.allMatches(parca)) {
            final kelime = km.group(0)!;
            if (kelime.length < 4) continue;
            if (kelime != kelime.toLowerCase()) continue;
            final onceki = km.start > 0 ? parca[km.start - 1] : ' ';
            final sonraki = km.end < parca.length ? parca[km.end] : ' ';
            if (onceki == '.' || onceki == '_' || onceki == "'") continue;
            if (sonraki == '.' || sonraki == '_' || sonraki == '(') continue;
            gecisler.add(_Gecis(kelime, dosya.path, satir, parca));
          }
        }
      }
    }

    // Veride Turkce harfle yazilmis her kelimenin sade hali -> dogru yazim.
    final dogru = <String, String>{};
    for (final g in gecisler) {
      final sade = _sadelestir(g.kelime);
      if (sade != g.kelime) dogru.putIfAbsent(sade, () => g.kelime);
    }

    final hatalar = <String>[];
    for (final g in gecisler) {
      final kelime = g.kelime;
      if (_sadelestir(kelime) != kelime) continue; // zaten Turkce harfli
      if (_izinli.contains(kelime)) continue;

      String? beklenen = dogru[kelime];
      if (beklenen == null && kelime.length >= 5) {
        for (var boy = kelime.length; boy > 4; boy--) {
          final kok = dogru[kelime.substring(0, boy)];
          if (kok != null) {
            beklenen = kok;
            break;
          }
        }
      }
      if (beklenen == null) continue;

      final dosyaAdi = g.dosya.split('/').last;
      hatalar.add('  $dosyaAdi:${g.satir}  "$kelime" -> "$beklenen"\n'
          '      ${_kisalt(g.parca)}');
    }

    expect(hatalar, isEmpty,
        reason: 'Bu kelimeler ders metninde Turkce harfleri dusmus yaziliyor; '
            'ayni kelimenin dogru yazimi verinin baska bir yerinde zaten '
            'var. Cocuklar bu metinleri okuyarak Turkce de ogreniyor.\n'
            '${hatalar.take(40).join('\n')}'
            '${hatalar.length > 40 ? '\n  ... ve ${hatalar.length - 40} tane daha' : ''}');
  });
}

class _Gecis {
  const _Gecis(this.kelime, this.dosya, this.satir, this.parca);
  final String kelime;
  final String dosya;
  final int satir;
  final String parca;
}

String _kisalt(String s) {
  final tek = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return tek.length <= 90 ? tek : '${tek.substring(0, 90)}...';
}

const _sadeHarf = {
  'ç': 'c',
  'ğ': 'g',
  'ı': 'i',
  'ö': 'o',
  'ş': 's',
  'ü': 'u',
  'â': 'a',
  'î': 'i',
  'û': 'u',
};

String _sadelestir(String kelime) {
  final b = StringBuffer();
  for (final harf in kelime.split('')) {
    b.write(_sadeHarf[harf] ?? harf);
  }
  return b.toString();
}

/// Kod, kimlik ya da esleme anahtari tasiyan alanlar: Turkceleştirilemez.
const _kodAlanlari = <String>{
  'animationData', 'animationType', 'asset', 'badge', 'blockType', 'code',
  'codeSnippet', 'codeTemplate', 'color', 'correctAnswer', 'correctCode',
  'correctMapping', 'courseId', 'defaultValue', 'emoji', 'errorLine',
  'expectedOutput', 'gameConfig', 'gameType', 'icon', 'id', 'image',
  'keywords', 'language', 'left', 'mascotEmoji', 'mustContain', 'quizKeys',
  'rarity', 'relatedIds', 'right', 'route', 'shape', 'starterCode',
  'targetCode', 'tipEmoji', 'type',
};

/// ASCII hali de dogru olan kelimeler ve ders metnine bilerek ASCII
/// birakilmis tanitici adlari.
const _izinli = <String>{
  // Kendi başına doğru kelimeler; Türkçe harfli ikizleri de var.
  'yani', // "yani, sonuç olarak" — "yanı" (bir şeyin yanı) değil
  'iste', // "yardım iste" — "işte" değil
  // Ünsüz yumuşaması: sonuç→sonucu, direnç→direnci. Doğru yazım bunlar.
  'sonucu', 'sonucunu', 'direnci',
  // Ders metnine gömülü kod örneklerinin tanıtıcı adları. Türkçe harf
  // konursa dersteki kod derlenmez / eşleşmez:
  //   C#: `class Esya { public int deger; }`
  //   Python: `if "pizza" in menu:`
  //   mBlock paletinde blok kategorisi: 'Sensor'
  'deger', 'esya', 'menu', 'sensor',
};

final _belirtec = RegExp(
  r"""(?<lc>//[^\n]*)|(?<s>'(?:[^'\\\n]|\\.)*'|"(?:[^"\\\n]|\\.)*")|(?<f>[A-Za-z_][A-Za-z0-9_]*\s*:)""",
);

final _kelime = RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşüÂÎÛâîû]+');

/// Ders metninin icine gomulu kod parcasi: `int deger;`, `class Esya {`,
/// `Serial.println(x)`, `<Esya>` ...
final _kodGorunumu = RegExp(r'[;{}=<>]|\w+\(|\.[A-Za-z]');
