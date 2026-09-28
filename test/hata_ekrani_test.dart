// Widget hatası artık gri bir duvar değil.
//
// SORUN NEYDİ
// -----------
// Bir widget'ın `build`i istisna fırlattığında Flutter onun yerine
// `ErrorWidget` çiziyor. Hata ayıklama derlemesinde bu kırmızı/sarı
// meşhur ekran; **yayın derlemesinde düz gri bir dikdörtgen**
// (`0xF0C0C0C0`) ve üstünde tek bir kelime bile yok.
//
// Kullanıcı bunu şöyle yaşadı: e-posta ve şifreyle kayıt oldu, ekran
// griye döndü ve orada kaldı. Çıkış yolu yok, açıklama yok, bize
// ulaşacak ipucu yok. Aynı hata daha önce "kırmızı ekran" diye
// bildirilmişti — ikisi aynı şeydi ama kimse eşleştirmemişti, çünkü
// ikisinin aynı mekanizma olduğu hiçbir yerde yazmıyordu.
//
// Bu test, o griliğin yerini anlaşılır bir ekranın aldığını kilitliyor.
import 'dart:io';

import 'package:devkom_app/widgets/hata_ekrani.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ErrorWidgetBuilder oncekiBuilder;

  setUp(() {
    oncekiBuilder = ErrorWidget.builder;
    hataEkraniniKur();
  });

  tearDown(() => ErrorWidget.builder = oncekiBuilder);

  testWidgets('build hatasinda gri duvar yerine anlasilir ekran cikiyor',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (_) => throw StateError('kasitli test hatasi'),
        ),
      ),
    );

    // Firlatilan istisna testi dusurmasin: onu bilerek uretttik.
    expect(tester.takeException(), isA<StateError>());

    expect(find.text('Bir şeyler ters gitti'), findsOneWidget,
        reason: 'ErrorWidget.builder baglanmamis; kullanici yine gri bir '
            'dikdortgen gorur.');
  });

  testWidgets('teknik ayrinti gizli ama kaybolmuyor', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (_) => throw StateError('gizli ayrinti testi'),
        ),
      ),
    );
    tester.takeException();

    // Kendiliginden gorunmemeli: cocugun karsisina yigin izi cikmasin.
    expect(find.textContaining('gizli ayrinti testi'), findsNothing);

    // Uzun basinca acilmali: kabloyla bagli bir Mac yokken tek tani yolu.
    await tester.longPress(find.text('Bir şeyler ters gitti'));
    await tester.pump();

    expect(find.textContaining('gizli ayrinti testi'), findsOneWidget,
        reason: 'Uzun basista hata metni acilmiyor; yayindaki bir hatayi '
            'teshis etmenin yolu kalmaz.');
  });

  testWidgets('hata ekraninin kendisi Navigator olmadan da cizilebiliyor',
      (tester) async {
    // ErrorWidget agacin her yerinde -- Navigator'un ustunde bile --
    // cizilebilir. `Navigator.of` kullanilsaydi hata ekraninin KENDISI
    // hata verirdi.
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: HataEkrani(detay: 'navigatorsuz'),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Bir şeyler ters gitti'), findsOneWidget);
  });

  test('kayit, kullanici olusmadan basari dondurmuyor', () {
    final src = File('lib/providers/auth_provider.dart').readAsStringSync();
    final basla = src.indexOf('Future<bool> register(');
    expect(basla, greaterThan(0));
    final govde = src.substring(basla, basla + 2600);

    expect(govde.contains('if (_currentUser == null)'), isTrue,
        reason: 'register() yine kosulsuz true donuyor olabilir. '
            '_currentUser null kaldiginda kayit ekrani ana sayfaya '
            'geciyor ve kullanici donen bir halkada kaliyordu.');
  });
}
