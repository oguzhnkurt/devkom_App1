import 'package:flutter_test/flutter_test.dart';

import 'package:devkom_app/services/child_link_service.dart';

/// Eslestirme kodunun bicimi.
///
/// Kodun kendisi sunucuda uretilip dogrulaniyor; burada sinanan sey
/// kodun INSAN TARAFINDAN aktarilabilir olmasi. Bir ebeveyn kodu
/// telefondan telefona okuyarak giriyor; karistirilabilir bir karakter
/// ya da tutarsiz bir bicim, akisin tek zayif halkasi.
void main() {
  group('kod bicimi', () {
    test('alti karakter uc-uc bolunuyor', () {
      expect(ChildLinkService.pretty('ABC234'), 'ABC-234');
    });

    test('beklenmedik uzunlukta bozmadan geciriyor', () {
      // Sunucu her zaman alti karakter donuyor; yine de kisa bir deger
      // gelirse ekran cokmemeli.
      expect(ChildLinkService.pretty('AB'), 'AB');
      expect(ChildLinkService.pretty(''), '');
    });
  });

  group('ChildLink', () {
    test('ad olmadan da kurulabiliyor', () {
      // Cocugun adi okunamazsa bag yine gecerli; ekran isimsiz gosterir.
      const link = ChildLink(childId: 'abc');
      expect(link.childId, 'abc');
      expect(link.childName, isNull);
    });
  });
}
