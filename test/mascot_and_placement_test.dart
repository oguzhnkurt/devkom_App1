import 'dart:io';

// Devi (maskot) ve yerleştirme kuralları.
//
// Buradaki testlerin çoğu "çizim doğru mu" değil, "çocuğa ne
// söylüyoruz" sorusunu koruyor. Maskotun üzgün bir hâli olmaması ya da
// yerleştirmenin puan göstermemesi estetik tercih değil — ikisi de
// gerekçesi yazılı kararlar ve kazara geri alınmamalı.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/models/learner_profile.dart';
import 'package:devkom_app/services/placement_service.dart';
import 'package:devkom_app/widgets/mascot.dart';
import 'package:devkom_app/widgets/first_task.dart';

void main() {
  _tekMaskotTestleri();
  group('Devi', () {
    test('üzgün ya da kızgın bir hâli yok', () {
      // Suçluluk temelli maskot davranışının öğrenmeye yaradığına dair
      // yayımlanmış bir kanıt yok; Duolingo'nun kendi A/B testinde
      // kazanan şey "gelişim zihniyeti" diliydi (D14 +%7,2). ICO
      // Çocuklara Uygun Tasarım Kuralları'nın 5. ve 13. maddeleri de
      // çocuğun duygusuna yönelen dürtme tekniklerine bakıyor.
      final names = MascotMood.values.map((m) => m.name.toLowerCase());
      for (final banned in ['sad', 'angry', 'upset', 'disappointed', 'cry']) {
        expect(names.any((n) => n.contains(banned)), isFalse,
            reason: '"$banned" hâli eklenmiş — bu bilerek yoktu');
      }
      // "Olmadı" durumunun karşılığı cesaret veren yüz.
      expect(MascotMood.values, contains(MascotMood.encouraging));
    });

    testWidgets('altı hâlin hepsi küçük boyutta da çiziliyor',
        (tester) async {
      for (final mood in MascotMood.values) {
        for (final size in [28.0, 96.0]) {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(body: Center(child: Mascot(mood: mood, size: size))),
          ));
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull,
              reason: '${mood.name} @ $size');
        }
      }
    });

    testWidgets('hareket azaltılmışken denetleyici çalışmıyor',
        (tester) async {
      await tester.pumpWidget(const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(body: Center(child: Mascot(size: 96))),
        ),
      ));
      // Hicbir animasyon donmuyorsa agac durulabiliyor demektir.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('dokunma geri çağrısı çalışıyor', (tester) async {
      var taps = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(child: Mascot(size: 96, onTap: () => taps++)),
        ),
      ));
      await tester.tap(find.byType(Mascot));
      await tester.pump(const Duration(milliseconds: 600));
      expect(taps, 1);
    });
  });

  group('Yerleştirme', () {
    test('hiç görev yapılmazsa uygulama yine de çalışıyor', () {
      // Apple 5.1.4(a): uygulama "kişinin yaşından bağımsız olarak" işe
      // yarar olmalı. Ölçüm yoksa da bir seviye çıkmalı.
      expect(PlacementService.levelFrom(const []), SkillLevel.beginner);
      expect(
        PlacementService.levelFrom(const [], ageBand: LearnerAgeBand.age13plus),
        SkillLevel.beginner,
      );
    });

    test('yaş bir TAVAN koyuyor, performans tek başına yetmiyor', () {
      final hepsiDogru = List.generate(
        3,
        (i) => PlacementAttempt(taskId: 't$i', solved: true),
      );
      // Kucuk yasta hepsini dogru yapmak Python'a atlamak degil.
      expect(
        PlacementService.levelFrom(hepsiDogru,
            ageBand: LearnerAgeBand.age4to6),
        SkillLevel.beginner,
      );
      expect(
        PlacementService.levelFrom(hepsiDogru,
            ageBand: LearnerAgeBand.age7to9),
        SkillLevel.someBlocks,
      );
      expect(
        PlacementService.levelFrom(hepsiDogru,
            ageBand: LearnerAgeBand.age10to12),
        SkillLevel.someCode,
      );
    });

    test('ipucu alan çocuk cezalandırılmıyor, sadece yarım puan alıyor', () {
      final ipucuyla = List.generate(
        3,
        (i) => PlacementAttempt(taskId: 't$i', solved: true, usedHint: true),
      );
      // Yarim puan -> orta seviye; sifir degil.
      expect(
        PlacementService.levelFrom(ipucuyla,
            ageBand: LearnerAgeBand.age10to12),
        SkillLevel.someBlocks,
      );
    });

    test('çözememek eksi puan değil, sadece puansız', () {
      const a = PlacementAttempt(taskId: 'x', solved: false, tries: 4);
      expect(a.score, 0);
      expect(a.score, isNonNegative);
    });

    test('kapanış cümlesi puan, yüzde ya da doğru sayısı içermiyor', () {
      // Cocuk kac tanesini dogru yaptigini ogrenmemeli — ogrenirse bu
      // bir sinav olur ve olcmek istedigimiz seyi bozar.
      final cases = [
        <PlacementAttempt>[],
        [const PlacementAttempt(taskId: 'a', solved: true)],
        [const PlacementAttempt(taskId: 'a', solved: false)],
      ];
      for (final lang in ['tr', 'en']) {
        for (final attempts in cases) {
          final line = PlacementService.closingLine(attempts, lang);
          expect(line, isNotEmpty);
          expect(RegExp(r'\d').hasMatch(line), isFalse,
              reason: 'Kapanışta sayı var: "$line"');
          for (final banned in ['%', 'puan', 'score', 'doğru', 'correct',
              'yanlış', 'wrong']) {
            expect(line.toLowerCase().contains(banned), isFalse,
                reason: '"$banned" geçiyor: "$line"');
          }
        }
      }
    });
  });

  group('İlk görev', () {
    testWidgets('blok yuvaya bırakılınca tamamlanıyor', (tester) async {
      var solvedWith = -1;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FirstTask(onSolved: (tries) => solvedWith = tries),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final drag = find.byType(Draggable<String>);
      final target = find.byType(DragTarget<String>);
      expect(drag, findsOneWidget);
      expect(target, findsOneWidget);

      await tester.drag(
        drag,
        tester.getCenter(target) - tester.getCenter(drag),
      );
      await tester.pump(const Duration(milliseconds: 1400));

      expect(solvedWith, 1, reason: 'ilk denemede çözüldü sayılmalı');
    });

    testWidgets('yanlış yere bırakmak ekranda hata göstermiyor',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: FirstTask(onSolved: (_) {})),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Bosluga birak.
      await tester.drag(find.byType(Draggable<String>), const Offset(140, 120));
      await tester.pump(const Duration(milliseconds: 600));

      // "Yanlis" gibi bir kelime hicbir yerde gorunmemeli.
      for (final banned in ['Yanlış', 'Hata', 'Wrong', 'Error', 'Tekrar dene']) {
        expect(find.text(banned), findsNothing, reason: banned);
      }
      expect(tester.takeException(), isNull);
    });
  });
}

/// Devi ile mağazadaki figürün TEK karakter olduğunu koruyan testler.
///
/// Eskiden ikisi ayrı çizimdi: uygulamanın maskotu Devi, mağazada
/// giydirilen ise başka bir insansı figür. Çocuğun aldığı şapka
/// maskotun kafasına oturmuyordu çünkü giydirilen "kişi" başkasıydı.
/// Kıyafet planı maskot üzerinden yürüdüğü için bu, planın temelindeki
/// çatlaktı.
/// TEK MASKOT.
///
/// Burada once "karakter birligi" testleri vardi: magaza sahnesinin
/// ayri bir figur cizmedigini ve bes karakterin HEPSINDE sapka/gozluk
/// cipalarinin dogru yerde oldugunu koruyorlardi. Karakter secimi ve
/// giydirme kaldirildi (tek maskot artik 3B render), o yuzden korunacak
/// sey de degisti: uygulamada tek bir maskot oldugu ve o maskotun
/// gorselinin gercekten pakette bulundugu.
void _tekMaskotTestleri() {
  test('tek karakter var ve adi sabit', () {
    expect(Mascot.ad, isNotEmpty);
    // Tur secimi geri gelmis olmamali.
    final kaynak =
        File('lib/widgets/mascot.dart').readAsStringSync();
    expect(kaynak.contains('MascotSpecies'), isFalse,
        reason: 'Karakter turu geri gelmis.');
    expect(kaynak.contains('specOf('), isFalse);
  });

  test('maskot gorselleri pakette', () {
    for (final yol in [Mascot.durgunGorsel, Mascot.kutlamaGorseli]) {
      final f = File(yol);
      expect(f.existsSync(), isTrue, reason: '$yol yok');
      expect(f.lengthSync(), greaterThan(2000), reason: '$yol bos');
    }
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('assets/maskot/'), isTrue,
        reason: 'Maskot klasoru pubspec ile paketlenmiyor — uygulamada '
            'gorsel bulunamaz ve maskot yerine yedek ikon cikar.');
  });

  testWidgets('kutlama aninda animasyon, diger hallerde tek kare',
      (tester) async {
    for (final giris in {
      MascotMood.idle: Mascot.durgunGorsel,
      MascotMood.happy: Mascot.durgunGorsel,
      MascotMood.cheering: Mascot.kutlamaGorseli,
    }.entries) {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Center(child: Mascot(mood: giris.key))),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      final img = tester.widget<Image>(find.byType(Image).first);
      expect((img.image as AssetImage).assetName, giris.value,
          reason: '${giris.key} icin yanlis gorsel');
    }
  });
}
