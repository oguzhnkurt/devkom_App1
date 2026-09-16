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
import 'package:devkom_app/widgets/character_stage.dart';
import 'package:devkom_app/models/store_item_model.dart';

void main() {
  _characterUnityTests();
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
void _characterUnityTests() {
  StoreItem item(String key, String emoji, String hex, StoreItemCategory c) =>
      StoreItem(
        id: key,
        itemKey: key,
        name: key,
        iconEmoji: emoji,
        colorHex: hex,
        category: c,
        priceJeton: 0,
      );

  testWidgets('mağaza sahnesi Devi çiziyor, ayrı bir figür değil',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: CharacterStage(size: 160, interactive: false),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(Mascot), findsOneWidget,
        reason: 'CharacterStage kendi figürünü çizmemeli, Devi\'yi '
            'kullanmalı — yoksa iki ayrı karakter olur');
  });

  // Ekipman cipalari BES KARAKTERIN HEPSINDE dogru olmali. Karakter
  // secilebilir hale gelince bu testin tek bir figure bakmasi yetmez:
  // magazadan alinan sapka Mia'da kafaya, Bug'da kabuga oturuyorsa
  // cocuk parasini verdigi seyi yanlis yerde goruyor.
  for (final species in MascotSpecies.values) {
    final spec = specOf(species);
    testWidgets('${spec.name}: ekipmanlar çıpalara oturuyor', (tester) async {
      const size = 200.0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: CharacterStage(
              species: species,
              size: size,
              interactive: false,
              hat: item('h', 'H', '#333', StoreItemCategory.hat),
              glasses: item('g', 'G', '#333', StoreItemCategory.glasses),
              necklace: item('n', 'N', '#333', StoreItemCategory.necklace),
              shoes: item('s', 'S', '#333', StoreItemCategory.shoes),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      final stage = tester.getRect(find.byType(Mascot));
      final a = spec.anchors;

      /// Bir ekipmanın merkezinin, figürün üstünden kaç `size` birim
      /// aşağıda olduğunu verir.
      double centerYOf(String label) {
        final r = tester.getRect(find.text(label).first);
        return (r.center.dy - stage.top) / size;
      }

      expect(centerYOf('H'), closeTo(a.hatY, 0.02));
      expect(centerYOf('G'), closeTo(a.eyeLineY, 0.02));
      expect(centerYOf('N'), closeTo(a.necklaceY, 0.02));
      expect(find.text('S'), findsNWidgets(2));
      expect(centerYOf('S'), closeTo(a.feetY, 0.03));

      // Sira dogru: sapka < gozluk < kolye < ayakkabi.
      expect(centerYOf('H'), lessThan(centerYOf('G')));
      expect(centerYOf('G'), lessThan(centerYOf('N')));
      expect(centerYOf('N'), lessThan(centerYOf('S')));
    });
  }

  testWidgets('karakter ürünü Devi\'nin yerine geçmiyor, rengini veriyor',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: CharacterStage(
            size: 160,
            interactive: false,
            character:
                item('devkom_x', '🍌', '#2E9E5B', StoreItemCategory.character),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    // Hala tek bir Devi var.
    expect(find.byType(Mascot), findsOneWidget);
    final mascot = tester.widget<Mascot>(find.byType(Mascot));
    // Urunun rengi Devi'nin govde rengi olmus.
    expect(mascot.color, const Color(0xFF2E9E5B));
    // Urunun simgesi gogus ekraninda.
    expect(mascot.chestEmoji, '🍌');
  });

  test('çıpalar figürün içinde kalıyor', () {
    // Cipalar her turun boyacisindaki geometriden turetildi; boyaci
    // degisirse bu test ayrismayi yakalar.
    for (final species in MascotSpecies.values) {
      final spec = specOf(species);
      final a = spec.anchors;
      final why = spec.name;

      expect(a.headTopY, greaterThanOrEqualTo(a.topY), reason: why);
      expect(a.hatY, greaterThan(a.topY - 0.10),
          reason: '$why: şapka silüetin tepesinden çok yukarıda');
      expect(a.eyeLineY, greaterThan(a.headTopY), reason: why);
      expect(a.eyeLineY, lessThan(a.bodyTopY), reason: why);
      expect(a.necklaceY, greaterThan(a.bodyTopY), reason: why);
      expect(a.chestY, greaterThan(a.necklaceY), reason: why);
      expect(a.feetY, greaterThan(a.chestY), reason: why);
      expect(a.feetY, lessThanOrEqualTo(a.stageHeight), reason: why);
    }
  });

  test('her karakterin adı ve tanıtımı dört dilde var', () {
    for (final species in MascotSpecies.values) {
      final spec = specOf(species);
      expect(spec.name.trim(), isNotEmpty);
      for (final lang in ['tr', 'en', 'de', 'es']) {
        expect(spec.taglineFor(lang).trim(), isNotEmpty,
            reason: '${spec.name}: $lang tanıtımı boş');
      }
      // Almanca/ispanyolca tanitim turkcenin kopyasi olmamali.
      for (final lang in ['de', 'es']) {
        expect(RegExp(r'[ğĞıİşŞ]').hasMatch(spec.taglineFor(lang)), isFalse,
            reason: '${spec.name}: $lang tanıtımı türkçe kalmış');
      }
    }
  });

  test('açılıştaki karakter Puf', () {
    expect(Mascot.defaultSpecies, MascotSpecies.puf);
  });
}
