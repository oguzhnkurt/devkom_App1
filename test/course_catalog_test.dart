// Kurs katalogu icin kaynak okuyan koruma testleri.
//
// Katalogun ustunde yatay kayan bir kategori filtresi vardi: Tumu,
// Baslangic, Web, Mobil, Sistem, Robotik, Veri/AI, Script. Cocuga hitap
// eden bir ayrim degildi ("Sistem", "Script"), ustelik katalog zaten
// kolaydan zora siralanmis bir OGRENME YOLU olarak gosteriliyor; serit o
// yolu bolen ikinci bir gezinme bicimiydi.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _ekran = 'lib/courses/screens/course_catalog_screen.dart';

void main() {
  late String kaynak;
  setUpAll(() => kaynak = File(_ekran).readAsStringSync());

  test('kategori seridi geri gelmemis', () {
    expect(kaynak.contains('_buildCategoryFilter'), isFalse);
    expect(kaynak.contains('_selectedCategory'), isFalse);
    expect(kaynak.contains('FilterChip'), isFalse);
    expect(kaynak.contains('CourseCategory'), isFalse);
    expect(kaynak.contains('scrollDirection: Axis.horizontal'), isFalse,
        reason: 'Katalogun ustunde yatay kayan bir serit kalmamali.');
  });

  test('arama duruyor', () {
    // Kategori gitti ama kursu adiyla aramak hala mumkun olmali.
    expect(kaynak.contains('_buildSearchBar'), isTrue);
    expect(kaynak.contains('CoursesData.search(_searchQuery)'), isTrue);
    expect(kaynak.contains('bool get _isBrowsingPath => _searchQuery.isEmpty'),
        isTrue);
  });

  test('sayac ve temizle yazilari dort dilde', () {
    // Ikisi de Turkce sabitti.
    expect(kaynak.contains('cursos encontrados'), isTrue);
    expect(kaynak.contains('Kurse gefunden'), isTrue);
    expect(kaynak.contains("'Temizle', 'Clear', 'Löschen'"), isTrue);
  });

  test('olu categoryText getter\'i kaldirildi', () {
    final model =
        File('lib/courses/models/course_model.dart').readAsStringSync();
    expect(model.contains('String get categoryText'), isFalse);
  });
}
