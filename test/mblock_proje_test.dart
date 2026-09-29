import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/courses/data/mblock_lessons_data.dart';
import 'package:devkom_app/courses/models/interactive_lesson_model.dart';

/// Akvaryum projesi dersi ile GERCEK proje dosyasi ayni seyi mi
/// soyluyor?
///
/// NEDEN BU TEST VAR
/// -----------------
/// Ders metnindeki sayilar (balik 5 adim, deniz yildizi 0.1 adim, yon
/// 35 ve 55 derece) uydurulmadi: `tool/mblock_projeleri/akvaryum.mblock`
/// dosyasindan okundu. Proje dosyasi bir gun degisirse ders metni
/// sessizce yanlis olur — cocuk uygulamada "5 adim" okur, ogretmenin
/// actigi projede baska bir sayi gorur. Bu test o sessiz kaymayi
/// engelliyor: sayilari dosyadan tekrar okuyup ders metninde ariyor.
///
/// Dosya UYGULAMA PAKETINDE DEGIL (`tool/` altinda): telefonda
/// acilamayacak 100 KB'lik bir dosyayi pakete koymanin anlami yok.
/// Proje mBlock 5'te kuruluyor, uygulama rehber.
void main() {
  /// Proje dosyasindan okunan gercek degerler: kukla adi -> (yon, adim).
  late Map<String, ({num yon, num adim})> gercek;

  setUpAll(() {
    final dosya = File('tool/mblock_projeleri/akvaryum.mblock');
    expect(dosya.existsSync(), isTrue,
        reason: 'Projenin kaynak dosyasi silinmis.');

    // .mblock bir zip; icindeki project.json Scratch 3 bicimi.
    final arsiv = ZipDecoder().decodeBytes(dosya.readAsBytesSync());
    final json = arsiv.files.firstWhere((f) => f.name == 'project.json');
    final proje = jsonDecode(utf8.decode(json.content as List<int>))
        as Map<String, dynamic>;

    num? sayi(Map<String, dynamic> girdiler, String ad) {
      final g = girdiler[ad];
      if (g is! List || g.length < 2) return null;
      final d = g[1];
      if (d is List && d.length > 1) return num.tryParse('${d[1]}');
      return null;
    }

    gercek = {};
    for (final hedef in (proje['targets'] as List).cast<Map<String, dynamic>>()) {
      final bloklar = (hedef['blocks'] as Map).values
          .whereType<Map<String, dynamic>>()
          .toList();
      num? yon;
      num? adim;
      for (final b in bloklar) {
        final girdiler = (b['inputs'] as Map).cast<String, dynamic>();
        if (b['opcode'] == 'motion_pointindirection') {
          yon = sayi(girdiler, 'DIRECTION');
        } else if (b['opcode'] == 'motion_movesteps') {
          adim = sayi(girdiler, 'STEPS');
        }
      }
      if (yon != null && adim != null) {
        gercek['${hedef['name']}'] = (yon: yon, adim: adim);
      }
    }

    expect(gercek.keys.toSet(),
        {'Fish2', 'Fish23', 'Jellyfish1', 'Starfish'},
        reason: 'Projedeki yuzen kuklalar degismis.');
  });

  // main() icinde getter tanimlanamaz; sade bir fonksiyon.
  InteractiveLesson ders() => MBlockLessonsData.module5.first;
  InteractiveLesson dans() => MBlockLessonsData.module5[1];
  InteractiveLesson elma() => MBlockLessonsData.module5[2];

  test('proje dersi mBlock kursunun son modulunde', () {
    final moduller = CourseModules.forCourse('mblock');
    expect(moduller.last.title, 'Projeler');
    expect(moduller.last.lessons, isNotEmpty);
    expect(moduller.last.lessons.first.id, 'mblock_5_1');
    expect(moduller.last.lessons[1].id, 'mblock_5_2');
    expect(moduller.last.lessons[2].id, 'mblock_5_3');
  });

  test('dersler dort dilde', () {
    for (final d in MBlockLessonsData.module5) {
    expect(d.titleEn, isNotNull);
    expect(d.titleDe, isNotNull);
    expect(d.titleEs, isNotNull);
    for (final adim in d.steps) {
      if (adim is ExplanationStep) {
        expect(adim.contentEn, isNotNull, reason: '${adim.id} EN eksik');
        expect(adim.contentDe, isNotNull, reason: '${adim.id} DE eksik');
        expect(adim.contentEs, isNotNull, reason: '${adim.id} ES eksik');
      }
    }
    }
  });

  test('katalog ders sayisi gercek ders sayisiyla ayni', () {
    final kurs = CoursesData.allCourses.firstWhere((k) => k.id == 'mblock');
    expect(kurs.totalLessons, MBlockLessonsData.allLessons.length);
  });

  test('ders sirasi benzersiz', () {
    final siralar = MBlockLessonsData.allLessons.map((l) => l.order).toList();
    expect(siralar.toSet().length, siralar.length,
        reason: 'Iki ders ayni siraya sahip.');
  });

  group('ders metni proje dosyasiyla tutarli', () {
    // Dosyadan okunan gercek degerler (bkz. project.json):
    //   Fish2       yon 35, 5 adim,   donus stili "all around"
    //   Fish23      yon 55, 2 adim,   "left-right"
    //   Jellyfish1  yon 55, 2 adim,   "left-right"
    //   Starfish    yon 55, 0.1 adim, "left-right"
    //   Grass12     surekli { Bubbles sesini bitene kadar cal }
    late String metin;
    setUpAll(() {
      metin = File('lib/courses/data/mblock_proje_lessons_data.dart')
          .readAsStringSync();
    });

    test('hizlar ve yonler DOSYADAN okunup derste araniyor', () {
      // Beklenen satirlar elle yazilmadi: proje dosyasindan uretildi.
      // Dosyadaki bir sayi degisirse bu test kirilir ve ders metninin
      // guncellenmesi gerektigini soyler.
      String yaz(num n) => n % 1 == 0 ? '${n.toInt()}' : '$n';
      gercek.forEach((kukla, d) {
        final beklenen =
            '$kukla → yön ${yaz(d.yon)}, ${yaz(d.adim)} adım';
        expect(metin.contains(beklenen), isTrue,
            reason: 'Proje dosyasindaki deger derste yok: $beklenen');
      });
    });

    test('kurma adimindaki sayilar da dosyadan', () {
      // Denizanasinin scripti: yon 55, 2 adim.
      final denizanasi = gercek['Jellyfish1']!;
      expect(denizanasi.yon, 55);
      expect(denizanasi.adim, 2);
      expect(metin.contains("pointInDirection('55'"), isTrue);
      expect(metin.contains("move('2'"), isTrue);
    });

    test('kod kuran adimlar projedeki blok dizisini istiyor', () {
      final adimlar =
          ders().steps.whereType<BlockBuilderStep>().toList();
      expect(adimlar.length, 2, reason: 'Iki kurma adimi olmaliydi.');

      final balik = adimlar.first;
      expect(balik.correctSequence,
          ['green_flag', 'point_55', 'k_forever', 'move_2_fish', 'edge_bounce'],
          reason: 'Balik scripti projedeki sirayla ayni olmali.');
      // Celdirici sart: dogru blogu SECMEK diye bir sey kalsin.
      expect(balik.availableBlocks.length,
          greaterThan(balik.correctSequence.length));

      final ses = adimlar.last;
      expect(ses.correctSequence, ['green_flag', 'k_forever', 'sound_bubbles']);
    });

    test('kaynak dosya derste anlatiliyor', () {
      // Cocuk/ogretmen projenin nereden geldigini bilmeli.
      expect(metin.contains('tool/mblock_projeleri/akvaryum.mblock'), isTrue);
    });
  });

  group('Dans Partisi dersi proje dosyasiyla tutarli', () {
    late String metin;
    late Map<String, dynamic> proje;

    setUpAll(() {
      metin = File('lib/courses/data/mblock_proje_lessons_data.dart')
          .readAsStringSync();
      final dosya = File('tool/mblock_projeleri/dans_partisi.mblock');
      expect(dosya.existsSync(), isTrue,
          reason: 'Dans Partisi kaynak dosyasi yok.');
      final arsiv = ZipDecoder().decodeBytes(dosya.readAsBytesSync());
      final json = arsiv.files.firstWhere((f) => f.name == 'project.json');
      proje = jsonDecode(utf8.decode(json.content as List<int>))
          as Map<String, dynamic>;
    });

    test('dansciların dordu de dort kostumlu', () {
      final dansci = <String, int>{};
      for (final t in (proje['targets'] as List).cast<Map<String, dynamic>>()) {
        final bloklar = (t['blocks'] as Map).values
            .whereType<Map<String, dynamic>>()
            .map((b) => b['opcode'])
            .toSet();
        if (bloklar.contains('looks_nextcostume')) {
          dansci['${t['name']}'] = (t['costumes'] as List).length;
        }
      }
      expect(dansci.keys.toSet(), {'Casey', 'Dorian', 'Jordyn'});
      for (final e in dansci.entries) {
        expect(e.value, 4,
            reason: '${e.key} artik dort kostumlu degil; ders "dört '
                'kostüm" diyor.');
      }
      expect(metin.contains('casey-a, casey-b, casey-c, casey-d'), isTrue);
    });

    test('bekleme suresi dosyadaki ile ayni', () {
      final sureler = <String>{};
      for (final t in (proje['targets'] as List).cast<Map<String, dynamic>>()) {
        for (final b
            in (t['blocks'] as Map).values.whereType<Map<String, dynamic>>()) {
          if (b['opcode'] != 'control_wait') continue;
          final g = (b['inputs'] as Map)['DURATION'];
          if (g is List && g.length > 1 && g[1] is List) {
            sureler.add('${(g[1] as List)[1]}');
          }
        }
      }
      expect(sureler, {'0.2'},
          reason: 'Projedeki bekleme suresi degismis: $sureler');
      expect(metin.contains('0.2 saniye bekle'), isTrue);
      expect(metin.contains("wait('0.2'"), isTrue);
    });

    test('kurma adimi projedeki blok dizisini istiyor', () {
      final adim = dans().steps.whereType<BlockBuilderStep>().first;
      expect(adim.correctSequence,
          ['green_flag', 'k_forever', 'next_costume', 'wait_02']);
      expect(adim.availableBlocks.length,
          greaterThan(adim.correctSequence.length),
          reason: 'Celdirici yok; dogru blogu SECMEK diye bir sey kalmiyor.');
    });
  });


  group('Elma Toplama dersi proje dosyasiyla tutarli', () {
    // Ders metnindeki her sayi (rastgele -201..155, y 197, 0.3 saniye,
    // y -8, kase y -122, sure 30) dosyadan okunuyor. Dosya degisirse
    // ders de degismek zorunda.
    late String metin;
    late Map<String, Map<String, dynamic>> kukla;

    setUpAll(() {
      metin = File('lib/courses/data/mblock_proje_lessons_data.dart')
          .readAsStringSync();
      final dosya = File('tool/mblock_projeleri/elma_toplama.mblock');
      expect(dosya.existsSync(), isTrue,
          reason: 'Elma Toplama kaynak dosyasi yok.');
      final arsiv = ZipDecoder().decodeBytes(dosya.readAsBytesSync());
      final json = arsiv.files.firstWhere((f) => f.name == 'project.json');
      final proje = jsonDecode(utf8.decode(json.content as List<int>))
          as Map<String, dynamic>;
      kukla = {
        for (final t in (proje['targets'] as List).cast<Map<String, dynamic>>())
          '${t['name']}': t,
      };
      expect(kukla.keys, containsAll(['Stage', 'Elma', 'Kase']));
    });

    List<Map<String, dynamic>> bloklari(String ad) =>
        (kukla[ad]!['blocks'] as Map)
            .values
            .whereType<Map<String, dynamic>>()
            .toList();

    /// Bir blogun sayi girdisini metin olarak okur ([4, '-8'] gibi).
    String? girdi(Map<String, dynamic> b, String ad) {
      final g = (b['inputs'] as Map)[ad];
      if (g is! List || g.length < 2) return null;
      final d = g.last;
      if (d is List && d.length > 1) return '${d[1]}';
      return null;
    }

    Map<String, dynamic> tek(String ad, String opcode) =>
        bloklari(ad).singleWhere((b) => b['opcode'] == opcode);

    test('elma rastgele x ve y 197 den dusuyor', () {
      final rastgele = tek('Elma', 'operator_random');
      expect(girdi(rastgele, 'FROM'), '-201');
      expect(girdi(rastgele, 'TO'), '155');
      expect(girdi(tek('Elma', 'motion_gotoxy'), 'Y'), '197');
      expect(metin.contains('-201 ile 155 arasında rastgele bir sayı seç'),
          isTrue);
      expect(metin.contains('y: 197 konumuna git'), isTrue);
    });

    test('ikiz 0.3 saniyede bir, her turda y -8', () {
      expect(girdi(tek('Elma', 'control_wait'), 'DURATION'), '0.3');
      expect(girdi(tek('Elma', 'motion_changeyby'), 'DY'), '-8');
      expect(metin.contains('0.3 saniye bekle'), isTrue);
      expect(metin.contains('y konumunu -8 değiştir'), isTrue);
      expect(metin.contains("changeY('-8', id: 'change_y_elma')"), isTrue);
    });

    test('ikiz kaseye ve kahverengi topraga degince siliniyor', () {
      final menu = tek('Elma', 'sensing_touchingobjectmenu');
      expect((menu['fields'] as Map)['TOUCHINGOBJECTMENU'][0], 'Kase');
      final renk = tek('Elma', 'sensing_touchingcolor');
      final g = (renk['inputs'] as Map)['COLOR'] as List;
      expect('${(g[1] as List)[1]}'.toLowerCase(), '#663b00');
      expect(
          bloklari('Elma')
              .where((b) => b['opcode'] == 'control_delete_this_clone')
              .length,
          2);
    });

    test('kase y -122 de duruyor ve fareyi izliyor', () {
      expect(girdi(tek('Kase', 'motion_sety'), 'Y'), '-122');
      final opcodes = bloklari('Kase').map((b) => b['opcode']).toSet();
      expect(opcodes, containsAll(['motion_setx', 'sensing_mousex']));
      expect(metin.contains('y konumunu -122 yap'), isTrue);
    });

    test('sure 30 saniye ve sonunda her sey duruyor', () {
      final ata = bloklari('Kase')
          .where((b) => b['opcode'] == 'data_setvariableto')
          .single;
      expect((ata['fields'] as Map)['VARIABLE'][0], 'süre');
      expect(girdi(ata, 'VALUE'), '30');
      expect(
          (tek('Kase', 'control_stop')['fields'] as Map)['STOP_OPTION'][0],
          'all');
      expect(metin.contains('süre değişkenini 30 yap'), isTrue);
    });

    test('degisken ve kukla adlari dosyadakiyle ayni', () {
      final degiskenler = ((kukla['Stage']!['variables'] as Map).values)
          .map((v) => '${(v as List)[0]}')
          .toSet();
      expect(degiskenler, {'toplananelma', 'süre'});
      expect(
          (kukla['Stage']!['costumes'] as List)
              .map((c) => (c as Map)['name']),
          contains('Blue Sky'));
      expect(metin.contains('"Blue Sky"'), isTrue);
    });

    test('kurma adimlari projedeki blok dizisini istiyor', () {
      final adimlar = elma().steps.whereType<BlockBuilderStep>().toList();
      expect(adimlar.length, 2);
      expect(adimlar[0].correctSequence,
          ['green_flag', 'set_y_kase', 'k_forever', 'set_x_mouse']);
      expect(adimlar[1].correctSequence, [
        'start_as_clone',
        'show',
        'k_forever',
        'change_y_elma',
        'if_touching_kase',
        'change_toplananelma',
        'delete_clone',
      ]);
      for (final a in adimlar) {
        expect(a.availableBlocks.length, greaterThan(a.correctSequence.length),
            reason: '${a.id}: celdirici yok.');
        expect(a.mblock, isNotNull);
      }
    });
  });
}
