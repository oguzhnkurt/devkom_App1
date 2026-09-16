// Magaza slaytlarinin uydurma ya da bayat olmamasi.
//
// Slayt araci (`appstore_shots_test.dart`) bir TEST degil, arac —
// normal kosuda calismiyor. O yuzden onun uretim kurallarini burada
// kilitliyoruz; ikisi de gercekten yasanmis hata:
//
//  1. Slaytta uzun sure 'Devi' yaziyordu. Uygulama coktan bes karaktere
//     gecmis, acilis karakteri Puf olmustu. Magazada olmayan bir
//     karakter gostermek indiren cocuga verilmis yanlis bir soz.
//  2. Aractaki `lang == 'en' ? ingilizce : turkce` ikilisi yuzunden
//     Almanca ve Ispanyolca slaytlarda maskotun repligi TURKCE
//     cikiyordu.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/widgets/mascot.dart';

void main() {
  final arac = File('test/appstore_shots_test.dart').readAsStringSync();
  final kurgu = File('tool/store_slides.py').readAsStringSync();

  // Yalnizca SLIDES listesi — yani slaytta GORUNEN metin. Dosyanin
  // aciklama satirlari bu kurallari anlatirken ayni kelimeleri
  // kullaniyor; onlari taramak yanlis alarm veriyor.
  final slaytMetni = kurgu.substring(
    kurgu.indexOf('SLIDES = ['),
    kurgu.indexOf('def font('),
  );

  test('ekran araci dort dili de uretiyor', () {
    // Ekranlar dort dilde uretilmeye devam ediyor; slayta dokulen
    // dil sayisi ayri bir karar (bkz. SLIDES).
    expect(arac.contains("['en', 'tr', 'de', 'es']"), isTrue,
        reason: 'Slayt araci dort dili birden uretmeli; eksik dil, o '
            'ulkenin magazasina baska dilde slayt gitmesi demek.');
  });

  test('aracta iki dilli lang ikilisi kalmadi', () {
    final ikili = RegExp(r"\ben \?").allMatches(arac).length;
    expect(ikili, 0,
        reason: 'Aracta `en ? ... : ...` kalmis. Bu kalip Almanca ve '
            'Ispanyolcayi Turkceye dusuruyor.');
  });

  test('karakter slayti elle yazilmis ad kullanmiyor', () {
    expect(arac.contains("Text('Devi'"), isFalse,
        reason: 'Slaytta eski maskot adi elle yazilmis.');
    expect(arac.contains('_slideMascot.name'), isTrue,
        reason: 'Slayttaki ad MascotSpec\'ten okunmali ki karakter '
            'degisince slayt kendiliginden duzelsin.');
  });

  test('yedi slayt, dogru sirada', () {
    // Slaytlar tek bir cumlenin adimlari: ne ogretiyoruz -> hangi
    // sirayla -> oyunla pekistirir -> bir dersin ici -> gercek Arduino
    // -> satrancla dusunur -> ogrendigini sinar. Sira degisirse cumle
    // bozulur.
    //
    // ILK UCU EN ONEMLISI: magaza aramasinda yalnizca onlar gorunuyor,
    // o yuzden kodlama anlatimi ilk uc slaytta bitmeli. Satranc ve quiz
    // YAN ozellikler; one alinirsa uygulama "kodlama ogreten uygulama"
    // gibi durmaz.
    //
    // Hepsi UYGULAMANIN DOLU ekranlari. Once acik gri, yarisi bos
    // ekranlar konmustu ve slaytlar magazada hicbir sey soylemeden
    // duruyordu.
    final sira = [
      "('09_home'",
      "('08_path'",
      "('07_matching'",
      "('02_lesson'",
      "('04_blocks'",
      "('12_chess'",
      "('13_slide_to_start'",
    ];
    var onceki = -1;
    for (final ad in sira) {
      final yer = slaytMetni.indexOf(ad);
      expect(yer, greaterThan(onceki),
          reason: '\$ad yanlis sirada — uc slaytin anlatimi bozulur.');
      onceki = yer;
    }
  });

  test('hap etiketlerin hepsi gercekten var olan kurslar', () {
    // Ilk slayttaki etiketler "bu dilleri ogretiyoruz" diyor.
    // Katalogda karsiligi olmayan bir dil yazmak, indiren veliye
    // verilmis tutulmayacak bir soz.
    final kurslar =
        CoursesData.allCourses.map((c) => c.name.toLowerCase()).join(' | ');
    final hapBolumu = kurgu.substring(
      kurgu.indexOf('PILLS = ['),
      kurgu.indexOf('SLIDES = ['),
    );
    for (final ad in const [
      'Scratch',
      'Python',
      'HTML',
      'Arduino',
      'mBlock',
      'C#',
    ]) {
      if (!hapBolumu.contains("'\$ad'")) continue;
      expect(kurslar.contains(ad.toLowerCase()), isTrue,
          reason: '"\$ad" hap etiketi var ama katalogda boyle bir kurs '
              'yok. Slayt olmayan bir kurs vaat ediyor.');
    }
  });

  test('her slaytin kendi rengi var', () {
    // Bes slayt yan yana duracak; hepsi ayni zeminde olursa liste
    // tekduze gorunuyor. Her slaytin kendi yumusak rengi ve vurgu
    // rengi var (THEME).
    for (final ad in const [
      '09_home',
      '08_path',
      '07_matching',
      '02_lesson',
      '04_blocks',
    ]) {
      final tema = kurgu.substring(
          kurgu.indexOf('THEME = {'), kurgu.indexOf('# TELEFONUN DISINA'));
      expect(tema.contains("'" + ad + "':"), isTrue,
          reason: '\$ad icin THEME rengi tanimlanmamis.');
    }
  });

  test('basliklarda vurgulanan kelime var', () {
    // Referans tasarimlarda basligin bir kelimesi renkli kutuda ya da
    // renkli yazi. Duz tek renk baslik magazada goze carpmiyor.
    final kutulu = '['.allMatches(slaytMetni).length;
    expect(kutulu, greaterThan(4),
        reason: 'Basliklarda vurgu isareti kalmamis.');
  });

  test('slaytlarda yas araligi ya da "cocuklar icin" ifadesi yok', () {
    // Uygulama EDUCATION kategorisinde, Kids Category'de degil.
    // 1.0.5'te aciklamadaki "4-12 yas arasi cocuklar icin" ifadesi
    // Kural 5.1.4(b) gerekcesiyle cikarilmisti; slayt metni de
    // magaza meta verisi, ayni kural buraya da isliyor.
    const yasakYas = [
      'yaş',
      'yas ',
      'ages ',
      'jahre',
      'años',
      'çocuklar için',
      'cocuklar icin',
      'for kids',
      'for children',
      'für kinder',
      'para niños',
    ];
    for (final k in yasakYas) {
      expect(slaytMetni.toLowerCase().contains(k.toLowerCase()), isFalse,
          reason: 'Slayt metninde yas/cocuk hedefi: "\$k". Kategori '
              'Education oldugu surece bu ifadeler metinde olmamali.');
    }
  });

  test('slaytlarda odul rozeti ya da puan iddiasi yok', () {
    // Ornek aldigimiz duzende "Apple Trend of the Year",
    // "Editor's Choice" gibi rozetler vardi. Onlar bize verilmedi;
    // slayta konulamaz.
    // Puanlar gercek deneyimden birikir; slaytta uydurulmaz
    // (App Store Kural 2.3.1).
    const yasak = [
      'yıldız',
      'puan ortalama',
      '5 üzerinden',
      'yorum',
      'ödüllü',
      'rating',
      'review',
      'award',
      'No. 1',
      '#1',
      'Sterne',
      'Bewertung',
      'estrellas',
      'valoración',
      'milyonlarca',
      'millions of users',
      'Millionen Nutzer',
    ];
    for (final k in yasak) {
      expect(slaytMetni.toLowerCase().contains(k.toLowerCase()), isFalse,
          reason: 'Slayt metninde dogrulanamaz iddia: "$k"');
    }
  });

  test('uzun baslik sessizce tasmiyor', () {
    // Uzun bir ceviri satiri asarsa slaytin dengesi bozuluyor.
    // Aracin kendisi durup hangi dil/slayt oldugunu soyluyor;
    // burasi o kontrolun silinmedigini kilitliyor.
    expect(kurgu.contains('baslik satiri cok uzun'), isTrue,
        reason: 'Baslik genisligi kontrolu aractan kaldirilmis. Uzun bir '
            'ceviri sessizce tasarsa slayt bozuluyor.');
  });

  test('her slaytin iki dilde de basligi var', () {
    // Simdilik yalnizca tr ve en yayinlaniyor: Turkiye'ye Turkce,
    // disariya Ingilizce. Almanca ve Ispanyolca metinler
    // docs/MAGAZA_METNI.md icinde duruyor, o ulkeler acildiginda
    // SLIDES'a geri eklenir.
    for (final dil in ['tr', 'en']) {
      final anahtar = "'" + dil + "': (";
      final adet = dil.isEmpty ? 0 : slaytMetni.split(anahtar).length - 1;
      expect(adet, 7,
          reason: '$dil icin 7 slayt basligi bekleniyordu, $adet bulundu. '
              'Eksik dil, o ulkenin magazasina baska dilde baslik '
              'gitmesi demek.');
    }
  });

  test('slayttaki karakter uygulamanin acilis karakteri', () {
    // Aractaki `_slideMascot` bu degerden turuyor; burada sadece
    // acilis karakterinin hala tanimli oldugunu dogruluyoruz.
    expect(Mascot.defaultSpecies, isNotNull);
    expect(arac.contains('specOf(Mascot.defaultSpecies)'), isTrue,
        reason: 'Slayt, acilis karakterini gostermeli — cocugun '
            'uygulamayi ilk actiginda gordugu karakter o.');
  });
}
