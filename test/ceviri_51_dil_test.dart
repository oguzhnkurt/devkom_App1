// 51 dil (2 Kasim 2026): ceviri tablosu ve AppLang.pick baglantisi.
import 'dart:convert';
import 'dart:io';

import 'package:devkom_app/utils/ceviri.dart';
import 'package:devkom_app/utils/lang.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('51 dil, hepsi benzersiz ve her birinin yerel adi var', () {
    expect(AppLang.supported.length, 51);
    expect(AppLang.supported.toSet().length, 51);
    for (final d in AppLang.supported) {
      expect(AppLang.nativeName[d], isNotNull, reason: d);
    }
  });

  test('elle yazilmayan her dilin tablosu var ve kaynagi kapsiyor', () {
    final kaynak = (jsonDecode(
            File('assets/l10n/_kaynak.json').readAsStringSync()) as List)
        .cast<String>();
    expect(kaynak.length, greaterThan(1000));
    for (final d in AppLang.supported) {
      if (AppLang.elleYazilan.contains(d)) continue;
      final f = File('assets/l10n/$d.json');
      expect(f.existsSync(), isTrue, reason: d);
      final t = (jsonDecode(f.readAsStringSync()) as Map).cast<String, String>();
      final eksik = kaynak.where((k) => !t.containsKey(k)).toList();
      expect(eksik, isEmpty, reason: '$d eksik: ${eksik.take(3)}');
    }
  });

  test('cihaz dili esanlamlilari', () {
    expect(AppLang.resolve('no'), 'nb');
    expect(AppLang.resolve('iw'), 'he');
    expect(AppLang.resolve('in'), 'id');
    expect(AppLang.resolve('tl'), 'fil');
    expect(AppLang.resolve('xx'), 'en');
    expect(AppLang.resolve('fr'), 'fr');
  });

  test('pick: tablo varsa ceviri, yoksa Ingilizce; dort dil degismedi', () {
    Ceviri.tabloyuAyarla('fr', {
      'Cancel': 'Annuler',
      '+{0} coins': '+{0} pièces',
      'Level {0} of {1}': 'Niveau {0} sur {1}',
    });
    expect(AppLang.pick('fr', tr: 'İptal', en: 'Cancel'), 'Annuler');
    expect(AppLang.pick('fr', tr: 'x', en: 'Unknown text'), 'Unknown text');
    expect(AppLang.pick('fr', tr: 'x', en: '+25 coins'), '+25 pièces');
    expect(AppLang.pick('fr', tr: 'x', en: 'Level 3 of 10'), 'Niveau 3 sur 10');
    // Elle yazilan diller tabloya hic bakmaz.
    expect(AppLang.pick('tr', tr: 'İptal', en: 'Cancel'), 'İptal');
    expect(AppLang.pick('de', tr: 'İptal', en: 'Cancel', de: 'Abbrechen'),
        'Abbrechen');
    expect(AppLang.pick('en', tr: 'İptal', en: 'Cancel'), 'Cancel');
    // Baska bir dilin tablosu yukluyken o dil Ingilizce'ye duser.
    expect(AppLang.pick('it', tr: 'İptal', en: 'Cancel'), 'Cancel');
  });

  test('gercek Fransizca tablo yuklenebiliyor', () {
    final t = (jsonDecode(File('assets/l10n/fr.json').readAsStringSync())
            as Map)
        .cast<String, String>();
    Ceviri.tabloyuAyarla('fr', t);
    expect(AppLang.pick('fr', tr: 'İptal', en: 'Cancel'), isNot('Cancel'));
  });
}
