// MARKET VAATLERI — satilan sey gercekten var mi?
//
// Market "karakterini giydir" diyordu: sapka, gozluk, kolye. Maskot tek
// bir 3B render olunca giydirme imkansiz hale geldi ve o urunler
// katalogdan kalkti. Geriye avatar cercevesi kaldi ve cerceve HICBIR
// YERDE gorunmuyordu: cocuk jetonunu veriyor, ekranda hicbir sey
// degismiyordu. Karsiligi olmayan bir vaat, magazanin kendisini
// anlamsiz kilar.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final market = File('lib/screens/market_screen.dart').readAsStringSync();
  final profil = File('lib/screens/auth/profile_screen.dart').readAsStringSync();
  final anaSayfa =
      File('lib/screens/unified_home_screen.dart').readAsStringSync();

  String kodu(String s) => s
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//'))
      .join('\n');

  test('giydirme vaadi kalmadi', () {
    final k = kodu(market);
    for (final vaat in [
      'karakterinde dene',
      'Bir ürüne dokun',
      'üzerinde nasıl duruyor',
      'CharacterStage',
    ]) {
      expect(k.contains(vaat), isFalse, reason: 'market hala "$vaat" diyor');
    }
  });

  test('ana sayfa da giydirme vaat etmiyor', () {
    // Market temizlendi ama ana sayfadaki Etkinlikler karti hala
    // "Karakterini giydir, jeton harca, yarış" diyordu. Vaat nerede
    // yaziyorsa orada yanlis; tek bir ekrani temizlemek yetmiyor.
    final k = kodu(anaSayfa);
    for (final vaat in [
      'Karakterini giydir',
      'Dress your buddy',
      'Kleide deinen Buddy',
      'Viste a tu personaje',
    ]) {
      expect(k.contains(vaat), isFalse,
          reason: 'ana sayfa hala "$vaat" diyor');
    }
  });

  test('satin alinan cerceve GERCEKTEN gorunuyor', () {
    // Onizleme ve profil ayni bileseni kullanmali: market, satin
    // almadan once tam olarak ne alacagini gostersin.
    expect(market.contains('AvatarCercevesi('), isTrue,
        reason: 'Markette cerceve onizlemesi yok.');
    expect(profil.contains('AvatarCercevesi('), isTrue,
        reason: 'Profil avatari cerceveyi cizmiyor — vaat yine bos.');
    expect(profil.contains('StoreItemCategory.avatarFrame'), isTrue,
        reason: 'Profil kusanilmis cerceveyi okumuyor.');
  });

  test('kaldirilan kategoriler markette gorunmuyor', () {
    final servis = File('lib/services/store_service.dart').readAsStringSync();
    expect(servis.contains('kaldirilanKategoriler'), isTrue);
    expect(market.contains('satilanKategoriler'), isTrue);
  });

  test('marketteki yazilar dort dilde', () {
    // Ekran tamamen Turkce sabitlerle yazilmisti. Kalan tek dilli
    // dugme yazisi olmamali.
    // `_t(context, 'Ücretsiz', 'Free', ...)` gibi dort dilli cagrilar
    // serbest; aranan sey TEK BASINA duran Turkce sabitler.
    for (final tekDil in const [
      "'✓ Kuşanıldı'",
      "'Kuşan'",
      "const Text('🛍️ Market')",
      "'Kuşanma başarısız oldu.'",
    ]) {
      expect(market.contains(tekDil), isFalse, reason: 'tek dilde: $tekDil');
    }
  });

  test('dev asistani da cerceveden bahsediyor', () {
    final bilgi =
        File('lib/data/dev_assistant_knowledge.dart').readAsStringSync();
    expect(bilgi.contains('robot kılıfları, çerçeveler ve karakterler'), isFalse,
        reason: 'Asistan hala olmayan urunleri sayiyor.');
    expect(bilgi.contains('profil çerçevesi'), isTrue);
  });
}
