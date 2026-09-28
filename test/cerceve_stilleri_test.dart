// Katalogdaki her çerçevenin bir çizim stili olmalı.
//
// NEDEN BU TEST VAR
// -----------------
// `cerceveStili` bilinmeyen bir `item_key` gördüğünde sessizce `sweep`e
// düşüyor. Bu bilinçli bir karar: katalogda yeni bir çerçeve belirirse
// uygulama çökmesin, sade görünsün. Ama aynı sessizlik bir tuzak —
// katalogda "Kuzey Işıkları" diye 230 jetonluk bir ürün satarken
// çocuğun aldığı şey varsayılan halka olabilir ve kimse fark etmez.
//
// Bu test o sessizliği bozuyor: SQL göçlerinde tanımlı her avatar
// çerçevesi anahtarı, Dart tarafındaki eşlemede de geçmek zorunda.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late final Set<String> katalogAnahtarlari;
  late final String eslemeKaynagi;

  setUpAll(() {
    // Gocleri tara: ('frame_xxx', 'avatar_frame', ...)
    final desen = RegExp(
        r"\(\s*'(frame_[a-z0-9_]+)'\s*,\s*'avatar_frame'", multiLine: true);
    final anahtarlar = <String>{};
    for (final e in Directory('supabase/migrations').listSync()) {
      if (e is! File || !e.path.endsWith('.sql')) continue;
      for (final m in desen.allMatches(e.readAsStringSync())) {
        anahtarlar.add(m.group(1)!);
      }
    }
    katalogAnahtarlari = anahtarlar;

    final src = File('lib/widgets/avatar_cercevesi.dart').readAsStringSync();
    final basla = src.indexOf('CerceveStili cerceveStili(');
    expect(basla, greaterThan(0), reason: 'cerceveStili eslemesi bulunamadi.');
    eslemeKaynagi = src.substring(basla);
  });

  test('gocteki her cerceve anahtari Dart eslemesinde var', () {
    expect(katalogAnahtarlari, isNotEmpty,
        reason: 'Gocler taranamadi; testin deseni bozulmus olabilir.');

    final eksik = katalogAnahtarlari
        .where((k) => !eslemeKaynagi.contains("'$k'"))
        .toList()
      ..sort();

    expect(eksik, isEmpty,
        reason: 'Bu cerceveler katalogda satiliyor ama cizim stilleri yok; '
            'varsayilan halka olarak gorunurler: $eksik');
  });

  test('tanimli her stil en az bir cerceve tarafindan kullaniliyor', () {
    final src = File('lib/widgets/avatar_cercevesi.dart').readAsStringSync();
    final govde = src.substring(src.indexOf('enum CerceveStili'));
    final enumBlogu =
        govde.substring(0, govde.indexOf('}') + 1);

    final stiller = RegExp(r'^\s*([a-z][a-zA-Z]*),', multiLine: true)
        .allMatches(enumBlogu)
        .map((m) => m.group(1)!)
        .toList();

    expect(stiller.length, greaterThanOrEqualTo(5),
        reason: 'Stil listesi okunamadi: $stiller');

    // `duz` disindaki her stil en az bir anahtardan donulmeli. Kullanilmayan
    // bir stil, yazilmis ama hicbir urune baglanmamis cizim demek.
    final kullanilmayan = <String>[];
    for (final s in stiller) {
      if (!eslemeKaynagi.contains('CerceveStili.$s')) kullanilmayan.add(s);
    }
    expect(kullanilmayan, isEmpty,
        reason: 'Bu stiller hicbir cerceveye bagli degil: $kullanilmayan');
  });
}
