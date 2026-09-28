import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/courses/data/courses_data.dart';

/// Kursun simgesi TEK yerde tanimli olsun.
///
/// GERCEK OLAY: "mBlock ile Kodlama" basliginin yaninda KITAP simgesi
/// cikiyordu. Sebep, simgelerin ikinci kez — ders ekraninda, elle
/// yazilmis bir listede — tutulmasiydi; mBlock o listeye hic
/// yazilmamis ve varsayilan '📚' devreye girmisti.
///
/// Blok kodlama ve robotik anlatan bir kursun basinda kitap durmasi
/// yanlis bir isaret veriyor: uygulama ders kitabi degil, atolye.
///
/// Kural: ekran kursun KENDI simgesini okur, kopya liste tutmaz.
void main() {
  group('kurs simgeleri', () {
    test('her kursun simgesi var', () {
      for (final kurs in CoursesData.allCourses) {
        expect(kurs.icon.trim(), isNotEmpty,
            reason: '${kurs.id} kursunun simgesi yok.');
      }
    });

    test('iki kurs ayni simgeyi kullanmiyor', () {
      // Listede yan yana duran iki kurs birbirinin aynisi gorunmemeli:
      // Scratch ile mBlock bir sure ayni 🧩 ile duruyordu.
      final gorulen = <String, String>{};
      for (final kurs in CoursesData.allCourses) {
        final onceki = gorulen[kurs.icon];
        expect(onceki, isNull,
            reason: '${kurs.id} ile $onceki ayni simgeyi (${kurs.icon}) '
                'kullaniyor.');
        gorulen[kurs.icon] = kurs.id;
      }
    });

    test('ders ekrani kopya simge listesi tutmuyor', () {
      final kaynak =
          File('lib/courses/screens/interactive_course_screen.dart')
              .readAsStringSync();
      expect(kaynak.contains('_getCourseEmoji'), isFalse,
          reason: 'Simgeler ikinci kez elle listelenmis; bir kurs '
              'unutulunca varsayilana dusuyor.');
      expect(kaynak.contains('📚'), isFalse,
          reason: 'Kitap simgesi geri gelmis.');
      expect(kaynak.contains('widget.course.icon'), isTrue,
          reason: 'Ekran kursun kendi simgesini okumali.');
    });

    test('baslik arkasindaki semboller konuya ait', () {
      // Once beyaz, rastgele dondurulmus dikdortgenler vardi ve
      // hicbir sey anlatmiyordu.
      final kaynak =
          File('lib/courses/screens/interactive_course_screen.dart')
              .readAsStringSync();
      expect(kaynak.contains('_kursSembolleri'), isTrue);
      for (final simge in [
        'Icons.view_module_rounded',
        'Icons.settings_rounded',
        'Icons.hub_rounded',
        'Icons.data_object_rounded',
        'Icons.memory_rounded',
      ]) {
        expect(kaynak.contains(simge), isTrue, reason: '$simge yok.');
      }
    });
  });
}
