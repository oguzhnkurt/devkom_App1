// Cam gezinme çubuğunun altında içerik kaybolmamalı.
//
// SORUN NEYDİ
// -----------
// Ana sayfayı barındıran Scaffold `extendBody: true` veriyor — gövde,
// yarı saydam cam çubuğun ARKASINA kadar uzanıyor. Çubuğun altından
// geçen kartların rengi cama vursun diye bilerek böyle.
//
// Ama ana sayfanın kaydırma alanı alt boşluk olarak sabit 24 piksel
// bırakıyordu. Çubuk ise ~85 piksel. Aradaki fark sayfanın SON kısmını
// yutuyordu ve oraya kaydırmak mümkün değildi: içerik bitiyor, çubuk
// üstünde duruyordu.
//
// Oraya denk gelen şey Pro kartının "Planları gör" düğmesiydi. Yani
// uygulamadaki tek satın alma çağrısı hiç görünmüyordu ve kimse fark
// etmemişti — kart görünüyordu, sadece dibi kesikti.
//
// Doğru alt boşluk sabit bir sayı değil; `extendBody` açıkken Flutter
// çubuğun yüksekliğini gövdenin `MediaQuery.padding.bottom` değerine
// kendisi ekliyor. Bu test hem o mekanizmanın hâlâ çalıştığını hem de
// çubuğu kullanan ekranların onu hesaba kattığını doğruluyor.
import 'dart:io';

import 'package:devkom_app/widgets/cam_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('extendBody acikken govde, cubugun yuksekligini MediaQuery ile aliyor',
      (tester) async {
    double? altBosluk;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        extendBody: true,
        body: Builder(builder: (c) {
          altBosluk = MediaQuery.paddingOf(c).bottom;
          return const SizedBox.expand();
        }),
        bottomNavigationBar: CamNavBar(
          secili: 0,
          onSec: (_) {},
          maddeler: const [
            CamNavMaddesi(
                icon: Icons.home_outlined,
                seciliIcon: Icons.home_rounded,
                etiket: 'Bir',
                renk: Colors.blue),
            CamNavMaddesi(
                icon: Icons.star_outline,
                seciliIcon: Icons.star_rounded,
                etiket: 'Iki',
                renk: Colors.green),
            CamNavMaddesi(
                icon: Icons.person_outline,
                seciliIcon: Icons.person_rounded,
                etiket: 'Uc',
                renk: Colors.orange),
          ],
        ),
      ),
    ));

    expect(altBosluk, isNotNull);
    expect(altBosluk, greaterThanOrEqualTo(CamNavBar.yukseklik),
        reason: 'extendBody acikken govdenin alt boslugu cubugun '
            'yuksekligini icermeli. Icermiyorsa ekranlarin bu degere '
            'guvenen alt bosluk hesabi bozulur ve icerik camin altinda '
            'kalir.');
  });

  // NEDEN DOSYADA "SafeArea VAR MI" DIYE BAKMIYORUZ
  //
  // Ilk yazilan surum tam da bunu yapiyordu: ekranin dosyasinda
  // `SafeArea` ya da `padding.bottom` geciyor mu. Ise yaramadi --
  // `unified_home_screen.dart` 2000 satir ve icinde alakasiz bir
  // widget'ta zaten `SafeArea` geciyor. Yani test, hatanin TAM OLARAK
  // bulundugu dosyada bile yesil yanardi.
  //
  // Bunun yerine duzeltmenin kendisi kilitleniyor: ana sayfanin govde
  // dolgusu sabit bir sayi olmamali, MediaQuery'nin alt boslugunu
  // icermeli.
  test('ana sayfanin govde dolgusu alt boslugu ekliyor', () {
    final src = File('lib/screens/unified_home_screen.dart').readAsStringSync();

    // Hero'dan sonraki ana icerik dolgusu.
    final dolgu = RegExp(
            r'padding:\s*EdgeInsets\.fromLTRB\(\s*20,\s*18,\s*20,\s*([^)]*)\)')
        .firstMatch(src)
        ?.group(1);

    expect(dolgu, isNotNull,
        reason: 'Ana sayfanin govde dolgusu bulunamadi; bicimi degismis '
            'olabilir, test guncellenmeli.');
    expect(dolgu, contains('MediaQuery'),
        reason: 'Alt bosluk yine sabit bir sayi: "$dolgu". Cam cubugun '
            'altinda kalan icerige kaydirilamaz -- Pro kartinin '
            '"Planlari gor" dugmesi boyle gorunmez olmustu.');

    // Sabit dolgu geri gelmis mi?
    expect(src.contains('EdgeInsets.fromLTRB(20, 18, 20, 24)'), isFalse,
        reason: 'Sabit 24 piksellik alt bosluk geri gelmis.');
  });
}
