// Iki gorunur kusur:
//
// 1. Ana sayfadaki "Yolun" seridinde bir OYNAT ucgeni vardi ama hicbir
//    seye goturmuyordu — cocuk basiyor, hicbir sey olmuyordu.
// 2. Oyunlar sayfasinin baslik cubugu sayfanin zemin rengiyle ayniydi;
//    sol ustteki geri oku fark edilmiyordu. Ustelik baslik tek dildi.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/models/learner_profile.dart';
import 'package:devkom_app/services/next_lesson_service.dart';

void main() {
  group('yol seridi', () {
    test('her nokta kendi kursunu tasiyor', () {
      // Kurs olmadan noktaya dokunmak dersi ACAMAZ; serit bu yuzden
      // olu bir suslemeydi.
      final nodes =
          NextLessonService.strip(const LearnerProfile(), <String>{});
      expect(nodes, isNotEmpty);
      final kursKimlikleri =
          CoursesData.allCourses.map((k) => k.id).toSet();
      for (final n in nodes) {
        expect(kursKimlikleri.contains(n.course.id), isTrue,
            reason: '${n.lesson.id} var olmayan bir kursa bagli');
      }
    });

    test('nokta dersi gercekten aciyor', () {
      final s =
          File('lib/screens/unified_home_screen.dart').readAsStringSync();
      final bas = s.indexOf('Widget _buildPathNode(');
      expect(bas, greaterThan(0));
      final govde = s.substring(bas, s.indexOf('\n  }\n', bas));
      expect(govde.contains('onTap:'), isTrue,
          reason: 'Serit noktasi hala dokunmaya tepki vermiyor.');
      expect(govde.contains('InteractiveLessonScreen('), isTrue);
      expect(govde.contains('course: node.course'), isTrue);
    });
  });

  group('oyunlar basligi', () {
    // ESKI KUSUR: baslik cubugu sayfanin zemin rengiyle ayni gri idi,
    // sol ustteki geri oku fark edilmiyordu ve baslik tek dildi.
    //
    // O AppBar artik yok: yerine gradyanli ozel bir baslik geldi. Denetim
    // ayni sorulari yeni baslika soruyor — zeminden ayrisiyor mu, geri
    // oku gorunur mu, yazilar dort dilde mi.
    late String kaynak;
    setUpAll(() {
      kaynak =
          File('lib/screens/robotics_games_screen.dart').readAsStringSync();
    });

    test('baslik zeminle ayni renkte degil', () {
      final bas = kaynak.indexOf('Widget _buildHeader()');
      expect(bas, greaterThan(0), reason: 'Ozel baslik kayboldu.');
      final govde = kaynak.substring(bas, kaynak.indexOf('\n  }\n', bas));
      expect(govde.contains('AppTheme.lightGray'), isFalse,
          reason: 'Baslik yine sayfa zemini ile ayni renkte.');
      expect(govde.contains('LinearGradient'), isTrue,
          reason: 'Baslik gradyani gitmis.');
      expect(govde.contains('SystemUiOverlayStyle.light'), isTrue,
          reason: 'Koyu gradyan uzerinde durum cubugu simgeleri koyu kalir.');
    });

    test('itilmis rotada geri oku var ve beyaz', () {
      // Bu ekran hem alt sekmenin govdesi hem de itilmis bir rota olarak
      // cizilebiliyor. Navigator.canPop() sekme govdesinde de true
      // donuyordu; dogru soru rotaya sorulur.
      final bas = kaynak.indexOf('Widget _buildHeader()');
      final govde = kaynak.substring(bas, kaynak.indexOf('\n  }\n', bas));
      expect(govde.contains('ModalRoute.of(context)?.canPop'), isTrue,
          reason: 'Geri tusu kontrolu yine navigator\'e soruluyor.');
      expect(govde.contains('Icons.arrow_back_rounded'), isTrue);
      expect(govde.contains('color: Colors.white'), isTrue,
          reason: 'Geri oku beyaz degil — koyu gradyanda gorunmez.');
    });

    test('baslik ve arama ipucu dort dilde', () {
      expect(kaynak.contains("title: const Text('Oyunlar')"), isFalse);
      for (final yazi in const [
        "tr: 'Oyunlar'",
        "en: 'Games'",
        "de: 'Spiele'",
        "es: 'Juegos'",
        "tr: 'Oyun ara'",
        "en: 'Search games'",
      ]) {
        expect(kaynak.contains(yazi), isTrue, reason: 'eksik: $yazi');
      }
    });

    test('izgara gitti, raf geldi', () {
      // 2x2 GridView bir oyun rafi degil tablo gibi duruyordu.
      //
      // Denetim YORUMLARI atliyor: dosyanin basindaki aciklama izgaranin
      // neden kaldirildigini anlatiyor ve icinde "GridView" geciyor.
      // Kodda gecmesi kusur, tarihi anlatan yorumda gecmesi degil.
      final kod = kaynak
          .split('\n')
          .where((s) => !s.trimLeft().startsWith('//'))
          .join('\n');
      expect(kod.contains('GridView'), isFalse,
          reason: 'Izgara geri gelmis.');
      expect(kaynak.contains('scrollDirection: Axis.horizontal'), isTrue,
          reason: 'Yatay raflar kayboldu.');
      expect(kaynak.contains("tr: 'GÜNÜN GÖREVİ!'"), isTrue);
      for (final yazi in const [
        "tr: 'Robot Görevleri'",
        "tr: 'Kod Bulmacaları'",
        "en: 'Robot Missions'",
        "de: 'Roboter-Missionen'",
        "es: 'Misiones robot'",
      ]) {
        expect(kaynak.contains(yazi), isTrue, reason: 'eksik: $yazi');
      }
    });

    test('kartta aciklama metni ve sure yazisi yok', () {
      // Cocuk aciklamalari okumuyordu; "8 dk" bir vaat degil tahmindi.
      expect(kaynak.contains('descriptionFor('), isFalse,
          reason: 'Kartlara aciklama metni geri gelmis.');
      expect(kaynak.contains('estimatedMinutes'), isFalse,
          reason: 'Kartta yine sure yaziyor.');
      expect(kaynak.contains('class _Yildizlar'), isTrue,
          reason: 'Zorluk yildizlari yok.');
    });

    test('sayaclar gercek ilerleme kaydindan geliyor', () {
      // Uydurma bir "7 gun seri" cocuga kazanmadigi bir seyi gosterirdi.
      final bas = kaynak.indexOf('class _SayacKapsulu');
      expect(bas, greaterThan(0));
      final govde = kaynak.substring(bas);
      expect(govde.contains('watch<AuthProvider>().userProgress'), isTrue);
      expect(govde.contains('ilerleme.jetonBalance'), isTrue);
      expect(govde.contains('ilerleme.streakDays'), isTrue);
      expect(govde.contains('if (ilerleme == null) return const SizedBox'),
          isTrue,
          reason: 'Kayit yokken sayac yine de ciziliyor.');
    });
  });
}
