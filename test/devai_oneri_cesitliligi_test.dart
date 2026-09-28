// DevAI önerileri tekrara düşmemeli.
//
// SORUN NEYDİ
// -----------
// Öneriler yalnızca eşleşen kaydın `relatedIds` listesinden üretiliyordu
// ve o liste kayıtların çoğunda iki kişilikti. Yani "Döngü nedir?"
// sorusunun altında HER SEFERINDE aynı iki soru çıkıyordu. Çocuk birkaç
// dokunuş sonra kapalı bir halkaya giriyordu:
//
//   döngü → değişken → döngü → değişken → ...
//
// Gerçek veriyle ölçüldüğünde 12 turluk bir sohbette yalnızca 4 farklı
// soru görünüyordu ve bir tanesi 9 kez tekrarlıyordu.
//
// ŞİMDİ
// Öneriler üç halkadan toplanıyor (kaydın komşuları → komşuların
// komşuları → genel havuz), her halka karıştırılıyor ve daha önce
// gösterilenler sona atılıyor.
import 'package:devkom_app/services/dev_assistant_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final asistan = DevAssistantService.instance;

  setUp(asistan.sohbetiSifirla);

  test('ayni soru arka arkaya ayni ucluyu vermiyor', () {
    final ilk = asistan.reply('döngü nedir', lang: 'tr').suggestions;
    final ikinci = asistan.reply('döngü nedir', lang: 'tr').suggestions;

    expect(ilk, hasLength(3));
    expect(ikinci, hasLength(3));
    expect(ikinci, isNot(equals(ilk)),
        reason: 'Ayni soruya ikinci kez gelindiginde ayni uclu donuyor; '
            'sohbet ilerlemiyor.');
  });

  test('sohbet boyunca oneriler cesitleniyor', () {
    // Gercek bir gezinme: her turda ilk oneriyi soruyormus gibi ilerle.
    var soru = 'döngü nedir';
    final tumu = <String>[];
    for (var i = 0; i < 12; i++) {
      final s = asistan.reply(soru, lang: 'tr').suggestions;
      tumu.addAll(s);
      soru = s.first;
    }

    // Eski davranista bu sayi 4'tu.
    expect(tumu.toSet().length, greaterThanOrEqualTo(20),
        reason: '12 turda yalnizca ${tumu.toSet().length} farkli soru '
            'cikti; oneriler yine dar bir halkada donuyor.');

    // Hicbir soru boguculuk yapacak kadar tekrarlamamali.
    for (final q in tumu.toSet()) {
      expect(tumu.where((x) => x == q).length, lessThanOrEqualTo(3),
          reason: '"$q" 12 turda ucten fazla onerildi.');
    }
  });

  test('cevaplanan sorunun kendisi tekrar onerilmiyor', () {
    final s = asistan.reply('değişken nedir', lang: 'tr').suggestions;
    expect(s.any((x) => x.toLowerCase().contains('değişken nedir')), isFalse,
        reason: 'Az once cevaplanan soru yine oneriliyor.');
  });

  test('dort dilde de uc oneri donuyor', () {
    for (final lang in ['tr', 'en', 'de', 'es']) {
      asistan.sohbetiSifirla();
      final s = asistan.reply('loop', lang: lang).suggestions;
      expect(s, hasLength(3), reason: '$lang icin oneri sayisi: ${s.length}');
      expect(s.toSet(), hasLength(3), reason: '$lang icinde tekrar var: $s');
    }
  });

  test('eslesme olmayan mesajda da oneri geliyor', () {
    final s =
        asistan.reply('qwertyuiop asdfghjkl zxcvbnm', lang: 'tr').suggestions;
    expect(s, hasLength(3));
  });
}
