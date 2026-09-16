// ULASILABILIRLIK: bir sey VAR olmasi yetmez, BULUNABILIR olmali.
//
// Kullanici uygulamayi sifirdan kurdu ve karakterini, jeton
// harcayacagi yeri ve yarisma tablosunu bulamadi. Sebep ikisiydi:
//
//  1. Karakterim/Market/Quiz kartlari ana sayfanin en dibindeydi VE
//     `isNewUser` kosulunun arkasindaydi. Ders bitirmemis cocuk —
//     yani uygulamayi yeni kuran herkes — hicbirini gormuyordu.
//  2. Yarisma tablosu yalnizca TEK bir oyunun sonuc ekranindan
//     aciliyordu; menulerin hicbirinde yoktu.
//
// Bu test kaynak taramasi yapiyor: ekranlari cizmek Supabase istiyor,
// ama "giris noktasi var mi" sorusu kaynaktan cevaplanabiliyor.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  const home = 'lib/screens/unified_home_screen.dart';
  const hub = 'lib/screens/activity_hub_screen.dart';

  test('etkinlik alani ana sayfada ve YENI KULLANICIYA da gorunuyor', () {
    final src = _read(home);

    expect(src.contains('_buildActivityCard'), isTrue,
        reason: 'ana sayfada etkinlik kartı yok');

    // Kart, `isNewUser` kosulunun ICINDE olmamali. Kartin cagrildigi
    // satirdan geriye dogru bakip araya giren bir `if (!isNewUser)`
    // olup olmadigini kontrol ediyoruz.
    final callIndex = src.indexOf('child: _buildActivityCard(isDark)');
    expect(callIndex, greaterThan(-1),
        reason: 'etkinlik kartı ana sayfada çağrılmıyor');

    final before = src.substring(0, callIndex);
    final lastGuard = before.lastIndexOf('if (!isNewUser)');
    final lastClose = before.lastIndexOf('],');
    expect(lastGuard < lastClose, isTrue,
        reason: 'etkinlik kartı "isNewUser" koşulunun içinde kalmış — '
            'uygulamayı yeni kuran çocuk onu göremez');
  });

  test('etkinlik alani dort kapiyi da aciyor', () {
    final src = _read(hub);
    for (final screen in [
      'CharacterScreen', // karakter + maskot seçici
      'MarketScreen', // jeton harcama
      'LeaderboardScreen', // arkadaşlarınla yarış
      'QuizIntroScreen',
    ]) {
      expect(src.contains('$screen()'), isTrue,
          reason: 'etkinlik alanında $screen girişi yok');
    }
  });

  test('yarisma tablosuna oyun disindan da ulasiliyor', () {
    // Onceden TEK giris noktasi koordinat oyununun sonuc ekraniydi.
    final entries = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      if (f.path.contains('leaderboard/')) continue;
      final src = f.readAsStringSync();
      if (src.contains('LeaderboardScreen(')) entries.add(f.path);
    }
    final outsideGames =
        entries.where((p) => !p.contains('/games/')).toList();
    expect(outsideGames, isNotEmpty,
        reason: 'yarışma tablosuna yalnızca oyun ekranlarından '
            'ulaşılıyor: ${entries.join(", ")}');
  });

  test('olu ikinci yarisma tablosu ekrani geri gelmedi', () {
    // Iki ayni isimli ekran vardi; eskisi (515 satir) hicbir yerden
    // acilmiyordu ve duzeltmeler yanlis dosyaya yapilabilirdi.
    expect(File('lib/screens/leaderboard_screen.dart').existsSync(), isFalse,
        reason: 'lib/screens/leaderboard_screen.dart ölü kopya, '
            'lib/screens/leaderboard/ altındaki kullanılıyor');
  });

  test('marka imzasi SEYREK: ders ekranina geri konmadi', () {
    // Once ders ekraninin alt cubuguna, iki dugmenin ortasina
    // konmustu ve oraya ait degildi. Uygulama simgesi zaten acilis,
    // giris ve profil ekranlarinda var.
    final src = _read('lib/courses/screens/interactive_lesson_screen.dart');
    expect(src.contains('BrandMark'), isFalse,
        reason: 'ders ekranına marka imzası geri konmuş');
  });

  test('marka imzasi SIRKET logosunu degil UYGULAMA simgesini kullaniyor', () {
    final src = _read('lib/widgets/brand_mark.dart');
    // Yorumda logo.png'den NEDEN vazgecildigi anlatiliyor; o yuzden
    // dosyanin tamamina degil, gercekten yuklenen varliga bakiyoruz.
    final loaded = RegExp(r"Image\.asset\(\s*'([^']+)'")
        .allMatches(src)
        .map((m) => m.group(1))
        .toList();
    expect(loaded, contains('assets/images/app_icon.png'));
    expect(loaded, isNot(contains('assets/images/logo.png')),
        reason: 'logo.png şirket arması (DEVKOM YAZILIM); '
            'uygulamanın kendi simgesi app_icon.png');
  });
}
