import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Gomulu web sayfalarinin cocugu uygulamanin disina cikarmamasini
/// kilitleyen testler.
///
/// NEDEN
/// -----
/// `lib/screens/games/maze_planet_game_screen.dart` (Daily Maze, HTMLGames
/// uzerinde barinan bir oyun) silindi. Ekrana hicbir yerden gidilmiyordu
/// ama icinde uc ayri sorun vardi:
///
/// 1. `onNavigationRequest` kosulsuz `NavigationDecision.navigate`
///    donuyordu. WebView icindeki HERHANGI bir baglantiya - bir reklamin
///    acilis sayfasina, App Store'a, `tel:`e - gidilebiliyordu. Ebeveyn
///    kapisi yalnizca UYGULAMANIN KENDI baglantilarini koruyor; gomulu
///    bir sayfanin baglantilarini korumuyor.
/// 2. Sayfa her saniye `[class*="play"]` gibi cok genis secicilerle
///    otomatik tiklaniyordu. Bir reklam baglantisina denk gelirse cocuk
///    hicbir sey yapmadan disari cikabiliyordu.
/// 3. Ucuncu tarafin reklamlari JavaScript ile siliniyordu - kullanim
///    sartlarina aykiri, ve kendi AdMob reklamimizi gosterirken
///    tutarsiz.
///
/// Bu testler dosyayi degil KURALI koruyor: ileride biri gomulu bir web
/// oyunu eklerse ayni aciklar sessizce geri gelmesin.
///
/// KURALIN KAPSAMI: "JavaScript enjekte etme" yasagi UCUNCU TARAFIN
/// sayfasina mudahale etmeyi yasakliyor. Uygulamanin kendi paketinden
/// gelen bir sayfa (bkz. lib/courses/screens/widgets/kod_tezgahi.dart)
/// baska bir seydir; orada da `runJavaScript` kullanilmiyor ama sebebi
/// baska: cocugun yazdigi HTML'de betik hic calismasin diye
/// JavaScript tamamen KAPALI.
void main() {
  final webViewDosyalari = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      // YORUM SATIRLARI ATILIYOR.
      //
      // Bu testler "su cagri YOK" diye sinar; aciklama yorumu da o
      // cagrinin adini gecirdigi icin kural kendi gerekcesine takilip
      // bosuna dusuyordu. (Ayni hata bu depoda uc kez yapildi:
      // quiz_lesson_match, student_drawer ve kod_tezgahi.)
      .map((f) => MapEntry(
          f.path,
          f
              .readAsLinesSync()
              .where((s) => !s.trimLeft().startsWith('//'))
              .join('\n')))
      .where((e) => e.value.contains('WebViewController'))
      .toList();

  test('silinen Daily Maze ekrani geri gelmedi', () {
    expect(File('lib/screens/games/maze_planet_game_screen.dart').existsSync(),
        isFalse,
        reason: 'Ekran silindi: kataloga bagli degildi ve icinde '
            'sinirsiz gezinme + otomatik tiklama vardi. Gomulu oyun '
            'yeniden istenirse asagidaki kurallara uyarak yazilmali.');
  });

  test('gomulu WebView kosulsuz gezinmeye izin vermiyor', () {
    for (final dosya in webViewDosyalari) {
      final kaynak = dosya.value;
      if (!kaynak.contains('onNavigationRequest')) {
        fail('${dosya.key}: WebView var ama gezinme denetimi yok. '
            'Cocuk bir baglantiyla uygulamanin disina cikabilir.');
      }
      expect(kaynak.contains('NavigationDecision.prevent'), isTrue,
          reason: '${dosya.key}: gezinme denetimi hicbir seyi '
              'engellemiyor. En az bir izin listesi olmali - ebeveyn '
              'kapisi gomulu sayfanin baglantilarini korumuyor.');
    }
  });

  test('UZAK bir sayfaya JavaScript enjekte edilmiyor', () {
    // KURALIN KAPSAMI DARALTILDI — sebebi asagida.
    //
    // Yasak bastan beri UCUNCU TARAFIN sayfasina mudahale etmekle
    // ilgiliydi: reklam silmek kullanim sartlarina aykiri, otomatik
    // tiklamak cocugu reklama tiklatabiliyor. Ama kural "hicbir yerde
    // runJavaScript yok" diye yazilmisti ve bu, kendi paketimizden
    // gelen bir sayfayi kurmayi da yasakliyordu.
    //
    // mBlock tezgahi (lib/courses/screens/widgets/mblock_tezgahi.dart)
    // tam olarak boyle bir sayfa: scratch-blocks uygulamanin icinde,
    // `loadFlutterAsset` ile aciliyor, hicbir adrese gidilmiyor ve
    // sayfanin kendi Icerik Guvenligi Politikasi disariyi tamamen
    // kapatiyor. Tezgaha hangi bloklarin verilecegini soylemek icin
    // sayfayla konusmak sart.
    //
    // Yeni kural: runJavaScript YALNIZCA yerelden yuklenen sayfalarda
    // serbest. Dosya `loadRequest` ile bir adrese gidiyorsa — yani
    // sayfa bizim degilse — yasak aynen duruyor.
    for (final dosya in webViewDosyalari) {
      final kaynak = dosya.value;
      if (!kaynak.contains('runJavaScript')) continue;

      final yerelden = kaynak.contains('loadFlutterAsset') ||
          kaynak.contains('loadHtmlString');
      expect(yerelden, isTrue,
          reason: '${dosya.key}: runJavaScript kullaniyor ama sayfayi '
              'yerelden yuklemiyor. Ucuncu tarafin sayfasina mudahale '
              'edilemez.');

      expect(kaynak.contains('loadRequest'), isFalse,
          reason: '${dosya.key}: hem bir adrese gidiyor hem de '
              'JavaScript calistiriyor. Yerel sayfa istisnasi yalnizca '
              'uygulamanin KENDI sayfasi icin gecerli.');
    }
  });

  test('yerel sayfa istisnasini kullanan dosya paketten yukluyor', () {
    // Tezgah bu istisnanin tek kullanicisi. Ileride biri
    // `loadFlutterAsset`i silip adresten yuklemeye gecerse yukaridaki
    // kural bunu yakalar; burasi dosyanin yerinde durdugunu ve
    // gezinmeyi engelledigini ayrica sabitliyor.
    final tezgah =
        File('lib/courses/screens/widgets/mblock_tezgahi.dart');
    expect(tezgah.existsSync(), isTrue);
    final kaynak = tezgah
        .readAsLinesSync()
        .where((s) => !s.trimLeft().startsWith('//'))
        .join('\n');
    expect(kaynak.contains('loadFlutterAsset'), isTrue);
    expect(kaynak.contains('NavigationDecision.prevent'), isTrue);
    expect(kaynak.contains('loadRequest'), isFalse);
  });
}
