import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ders metinlerindeki Scratch blok adlari, Scratch'in KENDI Turkce dil
/// dosyasiyla ayni mi?
///
/// Kural: cocuk uygulamada okudugu blogu Scratch'i acinca birebir ayni
/// yaziyla bulmali. "Neredeyse ayni" bir etiket, cocugun aradigini
/// bulamamasi demek — 8 yasindaki biri "klon olarak basladiginda"
/// yazan bir blogu "ikiz olarak basladigimda" diye aramaz.
///
/// Derslerde Ingilizce, Almanca ve Ispanyolca etiketler zaten resmiydi;
/// bozuk olan yalnizca Turkceydi. Bu test o farki geri getirmeyi
/// engelliyor.
///
/// Kaynak repoda duruyor: `tool/bloklar/scratch_tr.json`
/// (scratch-l10n, `editor/blocks/tr.json`). Uydurma etiket yok.
void main() {
  final kaynak = File('tool/bloklar/scratch_tr.json');

  test('resmi Turkce blok sozlugu repoda', () {
    expect(kaynak.existsSync(), isTrue,
        reason: 'tool/bloklar/scratch_tr.json olmadan etiketler '
            'dogrulanamaz; blok adi uydurmak yasak.');
    final s = jsonDecode(kaynak.readAsStringSync()) as Map<String, dynamic>;
    // Degistirdigimiz etiketlerin anahtarlari gercekten burada mi?
    for (final k in [
      'EVENT_BROADCAST',
      'EVENT_WHENBROADCASTRECEIVED',
      'CONTROL_CREATECLONEOF',
      'CONTROL_STARTASCLONE',
      'CONTROL_DELETETHISCLONE',
      'CONTROL_REPEAT',
      'MOTION_GOTOXY',
      'MOTION_CHANGEXBY',
      'MOTION_CHANGEYBY',
      'DATA_SETVARIABLETO',
      'DATA_CHANGEVARIABLEBY',
      'SENSING_TOUCHINGOBJECT',
      'SENSING_KEYPRESSED',
      'SOUND_PLAY',
      'EVENT_WHENTHISSPRITECLICKED',
    ]) {
      expect(s[k], isNotNull, reason: '$k sozlukte yok');
    }
  });

  test('ders verisinde eski (resmi olmayan) Turkce etiketler yok', () {
    // Yorum satirlari atiliyor: yoklugu sinayan bir kural, o yoklugu
    // ACIKLAYAN yorumla eslesip bosuna patliyordu.
    final kod = File('lib/courses/data/scratch_lessons_data.dart')
        .readAsLinesSync()
        .where((s) => !s.trimLeft().startsWith('//'))
        .join('\n');

    // (eski yazim, Scratch'teki dogrusu)
    const yasak = <List<String>>[
      ['klonunu oluştur', 'kendim in ikizini yarat'],
      ['klon olarak başladığında', 'ikiz olarak başladığımda'],
      ['bu klonu sil', 'bu ikizi sil'],
      ['mesajını yayınla', '… haberini sal'],
      ['mesajı alındığında', '… haberini aldığımda'],
      ['kere tekrarla', '… defa tekrarla'],
      ['Meow sesini çal', 'Meow sesini başlat'],
      ['bu kukla tıklandığında', 'bu kuklaya tıklandığında'],
    ];

    final hatalar = <String>[];
    for (final ciftler in yasak) {
      // Yalnizca ETIKET alanlarinda ariyoruz. Anlatim cumlelerinde
      // "klon" ve "mesaj" kavram olarak gecebilir; blok adi olarak
      // gecemez.
      final desen = RegExp(
        "(?:label|content): '[^']*" + RegExp.escape(ciftler[0]),
      );
      if (desen.hasMatch(kod)) {
        hatalar.add('"${ciftler[0]}" → Scratch\'te "${ciftler[1]}"');
      }
    }
    expect(hatalar, isEmpty, reason: hatalar.join('\n'));
  });

  test('resmi etiketler ders verisinde gercekten kullanilmis', () {
    final kod = File('lib/courses/data/scratch_lessons_data.dart')
        .readAsStringSync();
    for (final dogru in [
      'kendim in ikizini yarat',
      'ikiz olarak başladığımda',
      'bu ikizi sil',
      'haberini sal',
      'haberini aldığımda',
    ]) {
      expect(kod.contains(dogru), isTrue, reason: '"$dogru" hic gecmiyor');
    }
  });
}
