import '../courses/data/courses_data.dart';
import '../models/user_progress_model.dart';
import '../utils/lang.dart';
import 'progress_report_service.dart';

/// Bir sertifikanin tanimi ve kazanilma durumu.
class Certificate {
  const Certificate({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.requirement,
    required this.requirementEn,
    required this.completed,
    required this.total,
    this.titleDe,
    this.titleEs,
    this.requirementDe,
    this.requirementEs,
  });

  final String id;
  final String title;
  final String titleEn;
  final String? titleDe;
  final String? titleEs;

  /// Kazanma kosulunun okunabilir hali. Sertifikanin degeri, KOSULUN
  /// acik olmasindan geliyor: "bir seyler yapti" degil, "su kursun tum
  /// derslerini bitirdi".
  final String requirement;
  final String requirementEn;
  final String? requirementDe;
  final String? requirementEs;

  final int completed;
  final int total;

  bool get earned => total > 0 && completed >= total;
  double get ratio => total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);

  String titleFor(String lang) =>
      AppLang.pick(lang, tr: title, en: titleEn, de: titleDe, es: titleEs);

  String requirementFor(String lang) => AppLang.pick(lang,
      tr: requirement, en: requirementEn, de: requirementDe, es: requirementEs);
}

/// Sertifikalar.
///
/// NEDEN VAR:
///
/// Bir abonelik urununun en buyuk yapisal sorunu, BITMEMESI. Cocuk
/// ilerliyor ama hicbir zaman "bitirdim" demiyor; ebeveyn de parasinin
/// karsiligini gosteren somut bir sey gormuyor. Rakiplerin
/// degerlendirmelerinde en cok tekrar eden iptal gerekcesi "cocuk
/// ilgisini kaybetti" (%36) ve hemen ardindan "seviyeyi asti" (%24) —
/// ikisi de "burada bir sey bitti" duygusunun hic olusmamasiyla ilgili.
///
/// Sertifika bunu cozen en ucuz sey: adi yazan, indirilebilir,
/// paylasilabilir bir belge. Kodlama icin bu bir mantik bulmacasindan
/// daha da anlamli, cunku kodlamanin zaten bir belge kulturu var.
///
/// DURUSTLUK NOTU: sertifikalar TAMAMLAMAYA gore veriliyor, dogruluk
/// oranina gore degil — cunku su an ders bazinda dogruluk verisi
/// tutmuyoruz. Kosul metinleri de bunu boyle yaziyor ("tum derslerini
/// tamamla"), "ustalasti" demiyor. Dogruluk takibi eklendiginde
/// seviyeli sertifikalar (Baslangic/Pro/Uzman) buraya eklenebilir.
class CertificateService {
  CertificateService._();

  /// Yol uzerindeki her kurs icin bir sertifika, ve hepsini bitirene
  /// bir de kapanis sertifikasi.
  static List<Certificate> build(
    UserProgress? progress,
    ProgressReport? report,
  ) {
    final completedIds = progress?.completedLessonIds ?? const <String>[];

    // Kurs basina tamamlanan ders sayisi. Rapor varsa oradan, yoksa
    // ders kimliklerinin on ekinden.
    final byCourse = <String, int>{};
    if (report != null) {
      for (final c in report.courses) {
        byCourse[c.course.id] = c.completed;
      }
    } else {
      for (final id in completedIds) {
        for (final course in CoursesData.allCourses) {
          if (id.startsWith('${course.id}_')) {
            byCourse[course.id] = (byCourse[course.id] ?? 0) + 1;
            break;
          }
        }
      }
    }

    final list = <Certificate>[];
    for (final course in CoursesData.learningPath) {
      final done = byCourse[course.id] ?? 0;
      list.add(Certificate(
        id: 'course_${course.id}',
        title: '${course.nameFor('tr')} Sertifikası',
        titleEn: '${course.nameFor('en')} Certificate',
        titleDe: '${course.nameFor('de')}-Zertifikat',
        titleEs: 'Certificado de ${course.nameFor('es')}',
        requirement: '${course.nameFor('tr')} kursundaki tüm dersleri tamamla',
        requirementEn:
            'Complete every lesson in the ${course.nameFor('en')} course',
        requirementDe:
            'Alle Lektionen im Kurs ${course.nameFor('de')} abschließen',
        requirementEs:
            'Completa todas las lecciones del curso ${course.nameFor('es')}',
        completed: done.clamp(0, course.totalLessons),
        total: course.totalLessons,
      ));
    }

    final pathTotal =
        CoursesData.learningPath.fold<int>(0, (a, c) => a + c.totalLessons);
    final pathDone = CoursesData.learningPath.fold<int>(
        0, (a, c) => a + (byCourse[c.id] ?? 0).clamp(0, c.totalLessons));

    list.add(Certificate(
      id: 'path_complete',
      title: 'Yazılım Yolculuğu Sertifikası',
      titleEn: 'Coding Journey Certificate',
      titleDe: 'Zertifikat: Programmier-Reise',
      titleEs: 'Certificado de Viaje de Programación',
      requirement: 'Öğrenme yolundaki tüm kursları tamamla',
      requirementEn: 'Complete every course on the learning path',
      requirementDe: 'Alle Kurse auf dem Lernweg abschließen',
      requirementEs: 'Completa todos los cursos de la ruta de aprendizaje',
      completed: pathDone,
      total: pathTotal,
    ));

    return list;
  }

  static int earnedCount(List<Certificate> all) =>
      all.where((c) => c.earned).length;

  /// Kazanilmaya en yakin, henuz alinmamis sertifika.
  ///
  /// Ebeveyn ekraninda "siradaki hedef" olarak gosteriliyor: bitmemis
  /// bir urune bir sonraki bitis noktasini vermek icin.
  static Certificate? nextUp(List<Certificate> all) {
    final pending = all.where((c) => !c.earned && c.total > 0).toList()
      ..sort((a, b) => b.ratio.compareTo(a.ratio));
    return pending.isEmpty ? null : pending.first;
  }
}
