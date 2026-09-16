import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// iPad desteği kapalı kalmalı.
///
/// Uygulama uzun süre `TARGETED_DEVICE_FAMILY = "1,2"` ile yayınlandı,
/// yani iPad'e kurulabiliyordu — ama kodda **hiçbir yerde tablet
/// farkındalığı yoktu**. `EkranOlcusu` yalnızca küçük telefonlar için
/// aralık daraltıyor; 1024pt genişlikte ne olacağını düşünen tek satır
/// yok. Sonuç: iPad'de tablet genişliğine gerilmiş bir telefon düzeni.
/// Hiç tasarlanmamış, hiç denenmemişti.
///
/// Ayrıca App Store bu yüzden her dil için ayrı iPad ekran görüntüsü
/// istiyordu ve bu, birincil dili İngilizce yapmayı bloke ediyordu.
///
/// Destek geri açılabilir — ama **önce tablet düzeni tasarlanarak**.
/// Bu test, ayarın sessizce geri gelmesini engelliyor.
void main() {
  test('TARGETED_DEVICE_FAMILY yalnizca iPhone', () {
    final proje =
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    expect(proje.contains('TARGETED_DEVICE_FAMILY = "1,2"'), isFalse,
        reason: 'iPad desteği geri açılmış; önce tablet düzeni gerekiyor');
    expect(proje.contains('TARGETED_DEVICE_FAMILY = "1"'), isTrue);
  });

  test('plist iPad yonelimlerini tasimiyor', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist.contains('UISupportedInterfaceOrientations~ipad'), isFalse);
  });

  test('tablet duzeni eklendiyse bu test guncellenmeli', () {
    // İleride gerçek bir tablet düzeni gelirse ilk işaret bu olur:
    // genişliğe bakan bir eşik. O gün bu testler kaldırılacak.
    final ekranOlcusu = File('lib/ui/ekran_olcusu.dart').readAsStringSync();
    expect(ekranOlcusu.contains('width'), isFalse,
        reason: 'EkranOlcusu genişliğe bakmaya başlamış — tablet düzeni '
            'geliyorsa iPad desteği yeniden değerlendirilmeli');
  });
}
