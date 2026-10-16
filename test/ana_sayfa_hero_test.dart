// ANA SAYFA ÜST BANDI (hero).
//
// Ekranın ilk görüneni bir satır selamlama + bir kartı; uygulamayı açan
// çocuk "buranın bir yüzü" olduğunu hissetmiyordu. Üst bant artık tek bir
// şey söylüyor: kaçıncı gününde olduğu. Maskot orada duruyor, altında dört
// kutuluk özet ve günün görevi var.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final src = File('lib/screens/unified_home_screen.dart').readAsStringSync();

  // NOT: Bu ekran AuthProvider'i DOGRUDAN istiyor (Provider.of) ve o da
  // acilista Supabase oturumu kuruyor. Widget testinde ayaga kaldirmak
  // gercek bir ag baglantisi demek olurdu; bu yuzden ekranin kurallari
  // kaynaktan denetleniyor. Gorsel dogrulama cihazda yapiliyor.

  test('üst bant maskotu gösteriyor ve en üstte', () {
    final bas = src.indexOf('Widget build(BuildContext context)');
    final govde = src.substring(bas, src.indexOf('Widget _buildHero(', bas));
    expect(govde.contains('_buildHero('), isTrue);
    // Hero, icerik dolgusunun DISINDA: bant kenardan kenara uzaniyor.
    expect(govde.indexOf('_buildHero(') < govde.indexOf('Padding('), isTrue);

    final hero = src.substring(src.indexOf('Widget _buildHero('),
        src.indexOf('Widget _buildGenelBakis('));
    expect(hero.contains('Mascot('), isTrue);
    expect(hero.contains('KodAkintisi('), isTrue);
  });

  test('büyük sayı UYDURULMUYOR', () {
    final bas = src.indexOf('Widget _buildHero(');
    final govde = src.substring(bas, src.indexOf('Widget _buildGenelBakis(', bas));
    // Seri varsa gun sayisi, yoksa seviye, o da yoksa selamlama.
    expect(govde.contains('progress.streakDays'), isTrue);
    expect(govde.contains('progress.level'), isTrue);
    // Sabit bir "Gün 4" yazilmamis olmali.
    expect(RegExp(r"'(Gün|Day) \d").hasMatch(govde), isFalse);
  });

  test('özet kutuları gerçek veriden okuyor', () {
    final bas = src.indexOf('Widget _buildGenelBakis(');
    final govde =
        src.substring(bas, src.indexOf('Widget _buildGununGorevi(', bas));
    for (final alan in const [
      'p.totalXP',
      'p.jetonBalance',
      'p.streakDays',
      'p.completedLessonIds.length',
    ]) {
      expect(govde.contains(alan), isTrue, reason: 'eksik: $alan');
    }
  });

  test('günün görevi ceza içermiyor', () {
    final bas = src.indexOf('Widget _buildGununGorevi(');
    final govde = src.substring(bas, bas + 3000);
    expect(govde.contains('p.dailyLessonsCompleted'), isTrue);
    // Bitmediginde kirmizi/uyari rengi yok: kart bir davet, ceza degil.
    expect(govde.contains('errorRed'), isFalse);
    expect(govde.contains('Colors.red'), isFalse);
  });

  test('ana sayfada sıfırlarla dolu özet tablosu yok (tek ana sayfa)', () {
    final bas = src.indexOf('Widget build(BuildContext context)');
    final govde = src.substring(bas, src.indexOf('// ------------------------------------------------------------------ baslik', bas));
    expect(govde.contains('_buildGenelBakis('), isFalse,
        reason: 'Genel bakış panosu ana sayfaya geri döndü');
    expect(govde.contains('SurprizSandik('), isTrue);
    expect(govde.contains('DeviBilmeceKarti('), isTrue);
  });
}
