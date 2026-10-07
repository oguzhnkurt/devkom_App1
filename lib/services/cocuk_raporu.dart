import '../courses/data/course_modules.dart';
import '../courses/data/courses_data.dart';
import '../courses/models/course_model.dart';
import '../models/user_progress_model.dart';
import '../utils/lang.dart';
import 'progress_report_service.dart' show DayActivity;

/// Bir kursta nerede olundugu.
class KursDurumu {
  const KursDurumu({
    required this.kurs,
    required this.biten,
    required this.toplam,
    this.siradakiDers,
  });

  final Course kurs;

  /// Bu kursun derslerinden kac tanesi bitti. Yalnizca kursta GERCEKTEN
  /// var olan dersler sayiliyor; listedeki eski/silinmis kimlikler ve ayni
  /// dersin tekrarlari sayiyi sisirmiyor.
  final int biten;

  /// Kurstaki gercek ders sayisi (modullerdeki derslerin toplami).
  final int toplam;

  /// Kursta bitmemis ilk dersin kimligi; kurs bittiyse null.
  final String? siradakiDers;

  double get oran => toplam == 0 ? 0 : biten / toplam;
  bool get basladi => biten > 0;
  bool get bitti => toplam > 0 && biten >= toplam;
}

/// Iki haftalik pencerenin bir yarisi.
class HaftaOzeti {
  const HaftaOzeti(this.gunler);

  final List<DayActivity> gunler;

  int get aktifGun => gunler.where((d) => !d.isEmpty).length;
  int get xp => gunler.fold(0, (a, d) => a + d.xp);
  int get yeniDers => gunler.fold(0, (a, d) => a + d.lessons);
  int get quiz => gunler.fold(0, (a, d) => a + d.quizzes);
  int get video => gunler.fold(0, (a, d) => a + d.videos);
}

/// Ebeveynin gordugu cocuk raporu — SAF hesap, ag yok.
///
/// Ekrandan ayri tutuldu ki her sayi test edilebilsin. Kurallar:
///
/// * Her mesaj OLUMLU ama her mesaj DOGRU. Olmayan bir seyi ovmuyoruz;
///   iyi giden bir sey yoksa o cumle hic yazilmiyor. Kotu giden seyi
///   de yazmiyoruz (cocugu ebeveyne sikayet eden bir rapor olmamali).
/// * "Son 7 gun" takvim haftasi degil: bugun dahil son yedi gun. Takvim
///   haftasiyla pazartesi gunu "bu hafta 0 gun" yazip yanlis bir alarm
///   veriyorduk; kayan pencere her gun ayni olcude.
/// * Toplam ders = farkli derslerin sayisi. Haftalik "yeni ders" de
///   yalnizca ilk kez bitirilen dersleri sayiyor (bkz.
///   UserProgressService.dersiKaydet), boylece ikisi celismiyor.
/// * Seri, gunluk kayitlardan hesaplaniyor: depodaki `streak_days`
///   cocuk uygulamayi acana kadar guncellenmiyor ve gunlerce eski bir
///   seriyi "devam ediyor" gibi gosterebiliyordu.
class CocukRaporu {
  CocukRaporu({
    required this.ad,
    required this.ilerleme,
    required this.gunler,
    this.izlenenVideo = 0,
    this.bitenGorev = 0,
    List<Course>? kurslar,
  })  : assert(gunler.length == 14, '14 gunluk pencere bekleniyor'),
        _kurslar = kurslar ?? CoursesData.learningPath;

  /// Cocugun adi; bilinmiyorsa null.
  final String? ad;

  /// Cocugun ilerleme satiri. Veritabani ebeveyne okutmadiysa null.
  final UserProgress? ilerleme;

  /// En eskiden bugune 14 gun.
  final List<DayActivity> gunler;

  final int izlenenVideo;
  final int bitenGorev;
  final List<Course> _kurslar;

  bool get ilerlemeVar => ilerleme != null;

  HaftaOzeti get son7 => HaftaOzeti(gunler.sublist(7));
  HaftaOzeti get onceki7 => HaftaOzeti(gunler.sublist(0, 7));

  late final Set<String> _bitenler =
      (ilerleme?.completedLessonIds ?? const <String>[]).toSet();

  late final List<KursDurumu> kurslar = [
    for (final k in _kurslar)
      () {
        final dersler = CourseModules.allLessons(k.id);
        final biten = dersler.where((l) => _bitenler.contains(l.id)).length;
        String? siradaki;
        for (final l in dersler) {
          if (!_bitenler.contains(l.id)) {
            siradaki = l.id;
            break;
          }
        }
        return KursDurumu(
          kurs: k,
          biten: biten,
          toplam: dersler.length,
          siradakiDers: siradaki,
        );
      }(),
  ].where((k) => k.toplam > 0).toList();

  /// Farkli ve uygulamada gercekten var olan biten derslerin sayisi.
  int get toplamDers => kurslar.fold(0, (a, k) => a + k.biten);

  List<KursDurumu> get bitenKurslar => kurslar.where((k) => k.bitti).toList();

  /// Su an uzerinde calisilan kurs: ogrenme yolunda baslanmis ama
  /// bitmemis ilk kurs. Hic baslanmadiysa null.
  KursDurumu? get suAnkiKurs {
    for (final k in kurslar) {
      if (k.basladi && !k.bitti) return k;
    }
    return null;
  }

  /// Bugunden (bugun bos ise dunden) geriye, ara vermeden calisilan gun
  /// sayisi. Pencere 14 gun; hepsi doluysa 14 doner ("14+" gosterilir).
  int get seri {
    var i = gunler.length - 1;
    if (gunler[i].isEmpty) i--;
    var n = 0;
    while (i >= 0 && !gunler[i].isEmpty) {
      n++;
      i--;
    }
    return n;
  }

  /// En son calisilan gun; 14 gunde hic yoksa null.
  DateTime? get sonCalisma {
    for (var i = gunler.length - 1; i >= 0; i--) {
      if (!gunler[i].isEmpty) return gunler[i].day;
    }
    return null;
  }

  /// Daha once hic iz birakmis mi (ders, XP ya da son iki hafta)?
  bool get gecmisiVar =>
      toplamDers > 0 ||
      (ilerleme?.totalXP ?? 0) > 0 ||
      gunler.any((d) => !d.isEmpty);

  // ------------------------------------------------------------ metinler

  String _ad(String lang) =>
      (ad != null && ad!.trim().isNotEmpty)
          ? ad!.trim()
          : AppLang.pick(lang,
              tr: 'Çocuğunuz', en: 'Your child', de: 'Ihr Kind', es: 'Su hijo/a');

  /// Raporun en ustundeki olumlu baslik.
  String baslik(String lang) {
    final g = son7.aktifGun;
    if (g >= 5) {
      return AppLang.pick(lang,
          tr: 'Harika bir hafta! 🌟',
          en: 'A fantastic week! 🌟',
          de: 'Eine fantastische Woche! 🌟',
          es: '¡Una semana fantástica! 🌟');
    }
    if (g >= 3) {
      return AppLang.pick(lang,
          tr: 'Güzel bir tempo! 👏',
          en: 'A great rhythm! 👏',
          de: 'Ein toller Rhythmus! 👏',
          es: '¡Muy buen ritmo! 👏');
    }
    if (g >= 1) {
      return AppLang.pick(lang,
          tr: 'İyi gidiyor! 🌱',
          en: 'Off to a good start! 🌱',
          de: 'Ein guter Anfang! 🌱',
          es: '¡Va por buen camino! 🌱');
    }
    if (gecmisiVar) {
      return AppLang.pick(lang,
          tr: 'Yeni bir hafta, yeni bir fırsat ✨',
          en: 'A new week, a new chance ✨',
          de: 'Neue Woche, neue Chance ✨',
          es: 'Nueva semana, nueva oportunidad ✨');
    }
    return AppLang.pick(lang,
        tr: 'Yolculuk başlamak üzere 🚀',
        en: 'The journey is about to begin 🚀',
        de: 'Die Reise beginnt gleich 🚀',
        es: 'El viaje está a punto de empezar 🚀');
  }

  /// Basligin altindaki cumle.
  String altBaslik(String lang) {
    final ad = _ad(lang);
    final g = son7.aktifGun;
    if (g >= 1) {
      return AppLang.pick(lang,
          tr: '$ad son 7 günde $g gün çalıştı.',
          en: '$ad studied on $g of the last 7 days.',
          de: '$ad hat an $g der letzten 7 Tage gelernt.',
          es: '$ad estudió $g de los últimos 7 días.');
    }
    if (gecmisiVar) {
      return AppLang.pick(lang,
          tr: 'Birlikte kısa bir ders açmak için güzel bir zaman. '
              'On dakika bile yeter.',
          en: 'A nice moment to open a short lesson together. '
              'Ten minutes is enough.',
          de: 'Ein schöner Moment für eine kurze gemeinsame Lektion. '
              'Zehn Minuten reichen.',
          es: 'Buen momento para abrir juntos una lección corta. '
              'Bastan diez minutos.');
    }
    return AppLang.pick(lang,
        tr: 'İlk ders Scratch ile başlıyor; birlikte açabilirsiniz.',
        en: 'The first lesson starts with Scratch; you can open it together.',
        de: 'Die erste Lektion beginnt mit Scratch – öffnen Sie sie gemeinsam.',
        es: 'La primera lección empieza con Scratch; pueden abrirla juntos.');
  }

  /// Iyi giden seyler. Her madde verinin kendisinden; olmayani yazmiyoruz.
  List<String> guzelHaberler(String lang) {
    final out = <String>[];
    final s = son7, o = onceki7;

    if (s.yeniDers > 0) {
      out.add(AppLang.pick(lang,
          tr: 'Son 7 günde ${s.yeniDers} yeni ders bitirdi.',
          en: 'Finished ${s.yeniDers} new lesson${s.yeniDers == 1 ? '' : 's'} in the last 7 days.',
          de: 'Hat in den letzten 7 Tagen ${s.yeniDers} neue Lektion${s.yeniDers == 1 ? '' : 'en'} abgeschlossen.',
          es: 'Terminó ${s.yeniDers} lección${s.yeniDers == 1 ? '' : 'es'} nueva${s.yeniDers == 1 ? '' : 's'} en los últimos 7 días.'));
    }
    if (o.aktifGun > 0 && s.aktifGun > o.aktifGun) {
      final fark = s.aktifGun - o.aktifGun;
      out.add(AppLang.pick(lang,
          tr: 'Önceki 7 güne göre $fark gün daha fazla çalıştı.',
          en: 'Studied $fark more day${fark == 1 ? '' : 's'} than the 7 days before.',
          de: 'Hat an $fark Tag${fark == 1 ? '' : 'en'} mehr gelernt als in den 7 Tagen davor.',
          es: 'Estudió $fark día${fark == 1 ? '' : 's'} más que los 7 días anteriores.'));
    } else if (s.aktifGun > 0 && s.aktifGun == o.aktifGun) {
      out.add(AppLang.pick(lang,
          tr: 'Düzenini koruyor: iki haftadır haftada ${s.aktifGun} gün.',
          en: 'Keeping a steady habit: ${s.aktifGun} days a week for two weeks.',
          de: 'Bleibt dran: seit zwei Wochen ${s.aktifGun} Tage pro Woche.',
          es: 'Mantiene el hábito: ${s.aktifGun} días por semana desde hace dos semanas.'));
    }
    final seri = this.seri;
    if (seri >= 2) {
      final sayi = seri >= gunler.length ? '${gunler.length}+' : '$seri';
      out.add(AppLang.pick(lang,
          tr: '$sayi gündür ara vermeden çalışıyor 🔥',
          en: 'Studying $sayi days in a row 🔥',
          de: 'Lernt seit $sayi Tagen am Stück 🔥',
          es: 'Lleva $sayi días seguidos estudiando 🔥'));
    }
    if (s.quiz > 0) {
      out.add(AppLang.pick(lang,
          tr: 'Son 7 günde ${s.quiz} quiz çözdü.',
          en: 'Solved ${s.quiz} quiz${s.quiz == 1 ? '' : 'zes'} in the last 7 days.',
          de: 'Hat in den letzten 7 Tagen ${s.quiz} Quiz gelöst.',
          es: 'Resolvió ${s.quiz} cuestionario${s.quiz == 1 ? '' : 's'} en los últimos 7 días.'));
    }
    if (s.video > 0) {
      out.add(AppLang.pick(lang,
          tr: 'Son 7 günde ${s.video} ders videosu izledi.',
          en: 'Watched ${s.video} lesson video${s.video == 1 ? '' : 's'} in the last 7 days.',
          de: 'Hat in den letzten 7 Tagen ${s.video} Lernvideo${s.video == 1 ? '' : 's'} angesehen.',
          es: 'Vio ${s.video} vídeo${s.video == 1 ? '' : 's'} de lecciones en los últimos 7 días.'));
    }
    for (final k in bitenKurslar) {
      final n = k.kurs.nameFor(lang);
      out.add(AppLang.pick(lang,
          tr: '$n kursunu baştan sona tamamladı 🏆',
          en: 'Completed the whole $n course 🏆',
          de: 'Hat den ganzen Kurs $n abgeschlossen 🏆',
          es: 'Completó todo el curso de $n 🏆'));
    }
    final su = suAnkiKurs;
    if (su != null) {
      final n = su.kurs.nameFor(lang);
      out.add(AppLang.pick(lang,
          tr: '$n kursunda ${su.toplam} dersin ${su.biten} tanesini bitirdi.',
          en: 'Has finished ${su.biten} of ${su.toplam} lessons in $n.',
          de: 'Hat ${su.biten} von ${su.toplam} Lektionen in $n geschafft.',
          es: 'Ha terminado ${su.biten} de ${su.toplam} lecciones de $n.'));
    }
    return out;
  }

  /// Ebeveynin cocuga sorabilecegi bir soru. Su anki kursa gore.
  String sohbetSorusu(String lang) {
    final id = suAnkiKurs?.kurs.id ??
        (bitenKurslar.isNotEmpty ? bitenKurslar.last.kurs.id : '');
    if (id == 'scratch') {
      return AppLang.pick(lang,
          tr: '“Scratch’te yaptığın son projeyi bana gösterir misin?”',
          en: '“Can you show me the last thing you made in Scratch?”',
          de: '„Zeigst du mir, was du zuletzt in Scratch gebaut hast?“',
          es: '«¿Me enseñas lo último que hiciste en Scratch?»');
    }
    if (id == 'mblock') {
      return AppLang.pick(lang,
          tr: '“Robotuna neler yaptırabiliyorsun, bana anlatır mısın?”',
          en: '“What can you make your robot do? Tell me!”',
          de: '„Was kann dein Roboter schon? Erzähl mal!“',
          es: '«¿Qué sabes hacer que haga tu robot? ¡Cuéntame!»');
    }
    if (id.startsWith('arduino')) {
      return AppLang.pick(lang,
          tr: '“Arduino’da en son hangi devreyi kurdun?”',
          en: '“Which circuit did you build last with Arduino?”',
          de: '„Welche Schaltung hast du zuletzt mit Arduino gebaut?“',
          es: '«¿Qué circuito montaste por última vez con Arduino?»');
    }
    if (id == 'html' || id == 'css') {
      return AppLang.pick(lang,
          tr: '“Yaptığın web sayfasını birlikte açalım mı?”',
          en: '“Shall we open the web page you made together?”',
          de: '„Wollen wir deine Webseite zusammen anschauen?“',
          es: '«¿Abrimos juntos la página web que hiciste?»');
    }
    if (id.isNotEmpty) {
      return AppLang.pick(lang,
          tr: '“Yazdığın son kodu bana anlatır mısın?”',
          en: '“Can you explain the last code you wrote?”',
          de: '„Erklärst du mir deinen letzten Code?“',
          es: '«¿Me explicas el último código que escribiste?»');
    }
    return AppLang.pick(lang,
        tr: '“İlk dersini birlikte açalım mı?”',
        en: '“Shall we open your first lesson together?”',
        de: '„Wollen wir deine erste Lektion zusammen öffnen?“',
        es: '«¿Abrimos juntos tu primera lección?»');
  }
}
