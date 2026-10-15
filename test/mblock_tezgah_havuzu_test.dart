// mBlock TEZGAHI TEK WebView: her blok kurma adimi yeni bir WebView acip
// 2,1 MB'lik scratch-blocks'u bastan ayristiriyordu. Artik ders boyunca
// bir denetci paylasiliyor (TezgahHavuzu). Bu testler paylasimin
// kurallarini sahte bir nesneyle sinar; WebView gerekmiyor.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/screens/widgets/tezgah_havuzu.dart';

class _Sahte {
  _Sahte(this.no);
  final int no;
  bool kapandi = false;
}

void main() {
  late int sayac;
  late TezgahHavuzu<_Sahte> havuz;
  setUp(() {
    sayac = 0;
    havuz = TezgahHavuzu<_Sahte>(() => _Sahte(++sayac),
        kapat: (n) => n.kapandi = true);
  });

  test('ardisik adimlar ayni nesneyi kullaniyor', () {
    final a = Object(), b = Object(), c = Object();
    final n1 = havuz.al(a);
    havuz.birak(a);
    final n2 = havuz.al(b);
    havuz.birak(b);
    final n3 = havuz.al(c);
    expect(identical(n1, n2) && identical(n2, n3), isTrue);
    expect(havuz.uretimSayisi, 1);
  });

  test('isitma nesneyi onceden uretiyor; ilk adim yenisini uretmiyor', () {
    final n = havuz.isit();
    expect(havuz.bos, isTrue);
    expect(identical(havuz.al(Object()), n), isTrue);
    expect(havuz.uretimSayisi, 1);
  });

  test('yeni adim eskisi kapanmadan alirsa eskisine haber veriliyor', () {
    final eski = Object(), yeni = Object();
    var eskiBirakti = 0;
    havuz.al(eski, birakildi: () => eskiBirakti++);
    havuz.al(yeni);
    expect(eskiBirakti, 1);
    expect(identical(havuz.sahip, yeni), isTrue);
    // Gec gelen dispose yeni sahibi dusurmuyor.
    havuz.birak(eski);
    expect(identical(havuz.sahip, yeni), isTrue);
    expect(havuz.uretimSayisi, 1);
  });

  test('ayni sahip ikinci kez alinca kendine haber vermiyor', () {
    final a = Object();
    var haber = 0;
    havuz.al(a, birakildi: () => haber++);
    havuz.al(a, birakildi: () => haber++);
    expect(haber, 0);
  });

  test('sayfa yuklendi bilgisi nesneyle yasiyor; sifirlama yeni nesne', () {
    final a = Object();
    final n1 = havuz.al(a);
    havuz.sayfaYuklendi = true;
    havuz.birak(a);
    havuz.al(Object());
    expect(havuz.sayfaYuklendi, isTrue,
        reason: 'ikinci adim sayfayi yeniden yuklemeden kuruluyor');
    havuz.sifirla();
    expect(n1.kapandi, isTrue);
    final n2 = havuz.al(Object());
    expect(identical(n1, n2), isFalse);
    expect(havuz.sayfaYuklendi, isFalse);
    expect(havuz.uretimSayisi, 2);
  });

  test('tezgah widget\'i havuzu kullaniyor ve ders isitiyor/birakiyor', () {
    String oku(String yol) => File(yol)
        .readAsLinesSync()
        .where((s) => !s.trimLeft().startsWith('//'))
        .join('\n');
    final tezgah = oku('lib/courses/screens/widgets/mblock_tezgahi.dart');
    expect(tezgah, contains('havuz.al(this'));
    expect(RegExp(r'WebViewController\(\)').allMatches(tezgah).length, 1,
        reason: 'denetci yalnizca havuzun ureticisinde kuruluyor');
    final ders = oku('lib/courses/screens/interactive_lesson_screen.dart');
    expect(ders, contains('MBlockWebHavuzu.isit()'));
    expect(ders, contains('MBlockWebHavuzu.serbestBirak()'));
  });

  test('tezgah.js: boyut dinleyicisi bir kez, bloklar dil basina bir kez', () {
    final js = File('assets/mblock/tezgah.js').readAsStringSync();
    expect(js, contains('if (!boyutDinleniyor)'));
    expect("addEventListener('resize'".allMatches(js).length, 1);
    expect(js, contains('if (tanimliDil !== dil)'));
  });
}
