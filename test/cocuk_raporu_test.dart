import 'package:devkom_app/courses/data/course_modules.dart';
import 'package:devkom_app/courses/data/courses_data.dart';
import 'package:devkom_app/models/user_progress_model.dart';
import 'package:devkom_app/services/certificate_service.dart';
import 'package:devkom_app/services/cocuk_raporu.dart';
import 'package:devkom_app/services/progress_report_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Veli raporunun hesaplari. Ekrandaki her sayi buradan geliyor; veli
/// "dogru mu" diye sorarsa cevap bu dosyada.

final _bugun = DateTime(2026, 10, 7); // carsamba

/// 14 gun; [aktif] -> gun indeksi (0 = 13 gun once, 13 = bugun) ve o
/// gunun (xp, ders, quiz, video) degerleri.
List<DayActivity> _gunler(Map<int, (int, int, int, int)> aktif) => [
      for (var i = 0; i < 14; i++)
        () {
          final v = aktif[i] ?? (0, 0, 0, 0);
          return DayActivity(
            day: _bugun.subtract(Duration(days: 13 - i)),
            xp: v.$1,
            lessons: v.$2,
            quizzes: v.$3,
            videos: v.$4,
          );
        }(),
    ];

UserProgress _ilerleme(List<String> dersler, {int xp = 0, int level = 1}) =>
    UserProgress.empty('cocuk')
        .copyWith(completedLessonIds: dersler, totalXP: xp, level: level);

List<String> _ilkDersler(String kurs, int n) =>
    CourseModules.allLessons(kurs).take(n).map((l) => l.id).toList();

void main() {
  group('pencereler', () {
    test('son 7 gun ve onceki 7 gun dogru ayriliyor', () {
      final r = CocukRaporu(
        ad: 'Ada',
        ilerleme: null,
        gunler: _gunler({
          0: (10, 1, 0, 0), // onceki
          6: (20, 0, 1, 0), // onceki (son gunu)
          7: (30, 2, 0, 1), // son 7'nin ilk gunu
          13: (40, 1, 2, 0), // bugun
        }),
      );
      expect(r.onceki7.aktifGun, 2);
      expect(r.onceki7.xp, 30);
      expect(r.son7.aktifGun, 2);
      expect(r.son7.xp, 70);
      expect(r.son7.yeniDers, 3);
      expect(r.son7.quiz, 2);
      expect(r.son7.video, 1);
    });

    test('yalnizca XP olan gun de calisilmis gun sayiliyor', () {
      final r = CocukRaporu(
          ad: null, ilerleme: null, gunler: _gunler({13: (5, 0, 0, 0)}));
      expect(r.son7.aktifGun, 1);
    });
  });

  group('seri', () {
    test('bugun bossa dunden geriye sayiliyor', () {
      final r = CocukRaporu(
        ad: null,
        ilerleme: null,
        gunler: _gunler({10: (5, 0, 0, 0), 11: (5, 0, 0, 0), 12: (5, 0, 0, 0)}),
      );
      expect(r.seri, 3);
    });

    test('bosluk seriyi kesiyor', () {
      final r = CocukRaporu(
        ad: null,
        ilerleme: null,
        gunler: _gunler({9: (5, 0, 0, 0), 11: (5, 0, 0, 0), 12: (5, 0, 0, 0), 13: (5, 0, 0, 0)}),
      );
      expect(r.seri, 3);
    });

    test('iki gun once biten seri sifir', () {
      final r = CocukRaporu(
          ad: null, ilerleme: null, gunler: _gunler({11: (5, 0, 0, 0)}));
      expect(r.seri, 0);
    });

    test('14 gunun hepsi doluysa "14+" yaziliyor', () {
      final r = CocukRaporu(
        ad: null,
        ilerleme: null,
        gunler: _gunler({for (var i = 0; i < 14; i++) i: (5, 0, 0, 0)}),
      );
      expect(r.seri, 14);
      expect(r.guzelHaberler('tr').any((h) => h.contains('14+ gündür')), isTrue);
    });
  });

  group('kurslar ve toplam ders', () {
    test('tekrar, olmayan kimlik ve yabanci kimlik sayilmiyor', () {
      final scratch5 = _ilkDersler('scratch', 5);
      final r = CocukRaporu(
        ad: null,
        ilerleme: _ilerleme([
          ...scratch5,
          scratch5.first, // tekrar
          'scratch_99_9', // artik olmayan ders
          'bilinmeyen_1', // hicbir kursa ait degil
        ]),
        gunler: _gunler({}),
      );
      final scratch = r.kurslar.firstWhere((k) => k.kurs.id == 'scratch');
      expect(scratch.biten, 5);
      expect(scratch.toplam, CourseModules.allLessons('scratch').length);
      expect(r.toplamDers, 5);
    });

    test('arduino_6_* dersleri Arduino IDE kursuna yaziliyor, Arduino\'ya degil', () {
      final ide = _ilkDersler('arduino_ide', 2);
      expect(ide.every((id) => id.startsWith('arduino_6_')), isTrue);
      final r = CocukRaporu(ad: null, ilerleme: _ilerleme(ide), gunler: _gunler({}));
      expect(r.kurslar.firstWhere((k) => k.kurs.id == 'arduino_ide').biten, 2);
      expect(r.kurslar.firstWhere((k) => k.kurs.id == 'arduino').biten, 0);
    });

    test('kurs toplami modullerdeki gercek ders sayisi', () {
      final r = CocukRaporu(ad: null, ilerleme: _ilerleme([]), gunler: _gunler({}));
      for (final k in r.kurslar) {
        expect(k.toplam, CourseModules.allLessons(k.kurs.id).length,
            reason: k.kurs.id);
      }
    });

    test('su anki kurs: baslanmis ve bitmemis ilk kurs', () {
      final tumScratch =
          CourseModules.allLessons('scratch').map((l) => l.id).toList();
      final r = CocukRaporu(
        ad: null,
        ilerleme: _ilerleme([...tumScratch, ..._ilkDersler('mblock', 3)]),
        gunler: _gunler({}),
      );
      expect(r.bitenKurslar.map((k) => k.kurs.id), ['scratch']);
      expect(r.suAnkiKurs!.kurs.id, 'mblock');
      expect(r.suAnkiKurs!.biten, 3);
      expect(r.suAnkiKurs!.siradakiDers,
          CourseModules.allLessons('mblock')[3].id);
    });

    test('ilerleme okunamadiysa kurslar sifir ve rapor bunu biliyor', () {
      final r = CocukRaporu(ad: null, ilerleme: null, gunler: _gunler({}));
      expect(r.ilerlemeVar, isFalse);
      expect(r.toplamDers, 0);
      expect(r.kurslar.every((k) => k.biten == 0), isTrue);
    });
  });

  group('olumlu ve dogru mesajlar', () {
    test('basliklar calisilan gune gore', () {
      CocukRaporu ile(int gun) => CocukRaporu(
            ad: 'Ada',
            ilerleme: null,
            gunler: _gunler({for (var i = 0; i < gun; i++) 13 - i: (5, 0, 0, 0)}),
          );
      expect(ile(5).baslik('tr'), contains('Harika'));
      expect(ile(3).baslik('tr'), contains('Güzel'));
      expect(ile(1).baslik('tr'), contains('İyi gidiyor'));
      expect(ile(4).altBaslik('tr'), 'Ada son 7 günde 4 gün çalıştı.');
    });

    test('hic veri yoksa yolculuk basliyor; uydurma haber yok', () {
      final r = CocukRaporu(ad: null, ilerleme: _ilerleme([]), gunler: _gunler({}));
      expect(r.gecmisiVar, isFalse);
      expect(r.baslik('tr'), contains('Yolculuk'));
      expect(r.guzelHaberler('tr'), isEmpty);
      expect(r.sohbetSorusu('tr'), contains('İlk dersini'));
      expect(r.altBaslik('tr'), contains('Scratch'));
    });

    test('bu hafta bos ama gecmisi varsa suclamiyor, davet ediyor', () {
      final r = CocukRaporu(
        ad: 'Ada',
        ilerleme: _ilerleme(_ilkDersler('scratch', 4), xp: 120),
        gunler: _gunler({2: (30, 1, 0, 0)}),
      );
      expect(r.son7.aktifGun, 0);
      expect(r.baslik('tr'), contains('Yeni bir hafta'));
      final hepsi = [r.baslik('tr'), r.altBaslik('tr'), ...r.guzelHaberler('tr')]
          .join(' ')
          .toLowerCase();
      for (final kotu in ['hiç çalışmadı', 'azaldı', 'düştü', 'geride', 'kötü']) {
        expect(hepsi.contains(kotu), isFalse, reason: kotu);
      }
    });

    test('dusus yazilmiyor, artis dogru farkla yaziliyor', () {
      final azaldi = CocukRaporu(
        ad: null,
        ilerleme: null,
        gunler: _gunler({0: (5, 0, 0, 0), 1: (5, 0, 0, 0), 2: (5, 0, 0, 0), 13: (5, 0, 0, 0)}),
      );
      expect(azaldi.guzelHaberler('tr').any((h) => h.contains('Önceki')), isFalse);

      final artti = CocukRaporu(
        ad: null,
        ilerleme: null,
        gunler: _gunler({0: (5, 0, 0, 0), 8: (5, 0, 0, 0), 10: (5, 0, 0, 0), 12: (5, 0, 0, 0)}),
      );
      expect(artti.guzelHaberler('tr'),
          contains('Önceki 7 güne göre 2 gün daha fazla çalıştı.'));
    });

    test('her haber verinin kendisinden', () {
      final r = CocukRaporu(
        ad: 'Ada',
        ilerleme: _ilerleme(_ilkDersler('scratch', 6)),
        gunler: _gunler({12: (40, 2, 1, 0), 13: (25, 1, 0, 3)}),
      );
      final h = r.guzelHaberler('tr');
      expect(h, contains('Son 7 günde 3 yeni ders bitirdi.'));
      expect(h, contains('Son 7 günde 1 quiz çözdü.'));
      expect(h, contains('Son 7 günde 3 ders videosu izledi.'));
      expect(h, contains('2 gündür ara vermeden çalışıyor 🔥'));
      final toplam = CourseModules.allLessons('scratch').length;
      expect(h, contains('Scratch kursunda $toplam dersin 6 tanesini bitirdi.'));
      expect(r.sohbetSorusu('tr'), contains('Scratch'));
    });

    test('dort dilde bos metin yok', () {
      final r = CocukRaporu(
        ad: 'Ada',
        ilerleme: _ilerleme(_ilkDersler('scratch', 2)),
        gunler: _gunler({13: (10, 1, 1, 1), 12: (10, 0, 0, 0), 3: (5, 0, 0, 0)}),
      );
      for (final l in ['tr', 'en', 'de', 'es']) {
        expect(r.baslik(l), isNotEmpty);
        expect(r.altBaslik(l), isNotEmpty);
        expect(r.sohbetSorusu(l), isNotEmpty);
        expect(r.guzelHaberler(l).length, r.guzelHaberler('tr').length, reason: l);
      }
      expect(r.altBaslik('en'), 'Ada studied on 2 of the last 7 days.');
    });
  });

  group('sertifikalar gercek ders sayisini kullaniyor', () {
    test('rapordaki toplam sertifikaya geciyor', () {
      final scratch = CoursesData.learningPath.firstWhere((c) => c.id == 'scratch');
      final rapor = ProgressReport(
        courses: [CourseProgress(course: scratch, completed: 3, total: 3)],
        lastDays: const [],
        videosWatched: 0,
        questsCompleted: 0,
      );
      final c = CertificateService.build(null, rapor)
          .firstWhere((c) => c.id == 'course_scratch');
      expect(c.total, 3);
      expect(c.earned, isTrue);
    });
  });
}
