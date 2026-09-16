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

  test('gomulu sayfaya JavaScript enjekte edilmiyor', () {
    for (final dosya in webViewDosyalari) {
      expect(dosya.value.contains('runJavaScript'), isFalse,
          reason: '${dosya.key}: ucuncu tarafin sayfasina mudahale '
              'ediyor. Reklam silmek kullanim sartlarina aykiri, '
              'otomatik tiklamak ise cocugu reklama tiklatabiliyor.');
    }
  });
}
