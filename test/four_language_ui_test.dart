import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Arayuzdeki her ceviri cagrisinin DORT dile birden karsilik vermesini
/// kilitler.
///
/// NEDEN
/// -----
/// Ekranlardaki kisa yardimci `_t(tr, en, [de, es])` seklinde tanimli.
/// `de` ve `es` istege bagli oldugu icin iki argumanla cagirmak sessizce
/// derleniyor ve o metin Almanca/Ispanyolca kullaniciya INGILIZCE
/// gidiyor. Ana sayfada 26, giris ekraninda 13, kelime oyununda 13 ve
/// ilk gorevde 2 boyle cagri birikmisti - yani uygulamayla ilk temas
/// eden ekranlarin tamami yari cevrilmisti.
///
/// Bu ayni zamanda MAGAZA sorunuydu: magaza slaytlari gercek Flutter
/// motoruyla cekildigi icin Almanca slaytlar yari Ingilizce cikiyordu.
///
/// `lib/widgets/first_task.dart` ayrica kendi `_t`'sini
/// `lang == 'tr' ? tr : en` diye yazmisti; dort dil destegi olan bir
/// uygulamada bu bastan iki dilli demekti. Asagidaki ikinci test bu
/// kaliba karsi tariyor.
void main() {
  /// `_t(` / `_tl(` cagrisinin argumanlarini ayirir (cok satirli
  /// cagrilar ve ic ice parantezler dahil).
  List<String> _argumanlar(String src, int acilis) {
    var derinlik = 0, baslangic = acilis + 1;
    String? tirnak;
    var kacis = false;
    final parcalar = <String>[];
    for (var i = acilis; i < src.length; i++) {
      final c = src[i];
      if (tirnak != null) {
        if (kacis) {
          kacis = false;
        } else if (c == r'\') {
          kacis = true;
        } else if (c == tirnak) {
          tirnak = null;
        }
        continue;
      }
      if (c == "'" || c == '"') {
        tirnak = c;
      } else if (c == '(' || c == '[' || c == '{') {
        derinlik++;
      } else if (c == ')' || c == ']' || c == '}') {
        derinlik--;
        if (derinlik == 0) {
          parcalar.add(src.substring(baslangic, i));
          return parcalar;
        }
      } else if (c == ',' && derinlik == 1) {
        parcalar.add(src.substring(baslangic, i));
        baslangic = i + 1;
      }
    }
    return parcalar;
  }

  final dartDosyalari = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  /// Yorum satirlarini bosaltir.
  ///
  /// Aksi halde bir kaliba KARSI uyaran aciklama satiri, o kalibin
  /// kendisi sanilip testi dusuruyor - bu testin ilk halinde tam olarak
  /// oyle oldu.
  String kodu(String src) => src
      .split('\n')
      .map((satir) {
        final t = satir.trimLeft();
        return (t.startsWith('//') || t.startsWith('///')) ? '' : satir;
      })
      .join('\n');

  test('hicbir ceviri cagrisi iki dilde kalmadi', () {
    final eksik = <String>[];

    for (final f in dartDosyalari) {
      final src = kodu(f.readAsStringSync());
      for (final m in RegExp(r'(?<![A-Za-z0-9_])_tl?\(').allMatches(src)) {
        final acilis = m.end - 1;
        final parcalar = _argumanlar(src, acilis);
        if (parcalar.length != 2) continue;
        // Fonksiyonun KENDI tanimi: _t(String tr, String en)
        if (parcalar.first.trim().startsWith('String ')) continue;
        final satir = '\n'.allMatches(src.substring(0, m.start)).length + 1;
        eksik.add('${f.path}:$satir  ${parcalar.first.trim()}');
      }
    }

    expect(eksik, isEmpty,
        reason: 'Bu cagrilar yalnizca tr ve en veriyor; Almanca ve '
            'Ispanyolca kullanici Ingilizce goruyor:\n${eksik.join('\n')}');
  });

  test('hicbir ekran dili tr/en ikilisine indirgemiyor', () {
    final suclu = <String>[];
    // `lang == 'tr' ? tr : en` ve benzerleri.
    final kalip = RegExp(r"lang\s*==\s*'tr'\s*\?");

    for (final f in dartDosyalari) {
      if (kalip.hasMatch(kodu(f.readAsStringSync()))) suclu.add(f.path);
    }

    expect(suclu, isEmpty,
        reason: 'Dil secimi ikiye indirgenmis. Dort dil icin '
            'AppLang.pick kullanilmali:\n${suclu.join('\n')}');
  });
}
