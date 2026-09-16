import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Yan menünün iki değişmezi.
void main() {
  final tamKaynak = File('lib/widgets/student_drawer.dart').readAsStringSync();

  /// Yorum satırları olmadan kaynak.
  ///
  /// "Şu artık yok" biçimindeki denetimler ham metne bakarsa, o şeyin
  /// NEDEN kaldırıldığını anlatan açıklama satırının kendisine takılıyor.
  /// Bu testin ilk sürümü tam olarak böyle kaldı: yorumda geçen
  /// `DrawerHeader` kelimesi ve 🪙 emojisi yüzünden.
  final kaynak = tamKaynak
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//'))
      .join('\n');

  group('görünüm', () {
    test('genel insan simgesi degil MASKOT cizilir', () {
      // Uygulamanın beş çizilmiş maskotu var ve çocuk kurulumda birini
      // seçip ona ad veriyor. Menü genel bir `Icons.person` gösteriyordu.
      expect(kaynak.contains('Mascot('), isTrue);
      expect(RegExp(r'Icon\(\s*Icons\.person\b').hasMatch(kaynak), isFalse,
          reason: 'genel avatar geri gelmiş');
    });

    test('jeton emoji ile degil ikonla gosteriliyor', () {
      // 🪙 bazı cihazlarda emoji yedeği bulunamayıp boş kare ya da
      // alakasız bir glif olarak çiziliyordu.
      expect(kaynak.contains('🪙'), isFalse);
      expect(kaynak.contains('Icons.monetization_on_rounded'), isTrue);
    });

    test('DrawerHeader gradyani kalkti', () {
      expect(kaynak.contains('DrawerHeader'), isFalse,
          reason: 'uygulamanın geri kalanı beyaz kart + yumuşak zemin');
    });
  });

  group('çıkış', () {
    test('anonim kullaniciya cikis GOSTERILMIYOR', () {
      // Anonim oturumda "çıkış" geri dönüşü olmayan bir veri kaybı:
      // oturum gider, yerine yeni bir anonim kullanıcı gelir, XP ve
      // jeton eski satırda öksüz kalır. Karşılığında hiçbir şey
      // kazanılmaz — giriş yapılacak bir hesap zaten yoktur.
      expect(kaynak.contains('if (!auth.isAnonymous)'), isTrue,
          reason: 'çıkış düğmesi anonim kullanıcıya da gösteriliyor');
    });

    test('cikis onay soruyor', () {
      expect(kaynak.contains('logoutConfirmation'), isTrue);
      expect(kaynak.contains('barrierDismissible: false'), isTrue);
    });
  });
}
