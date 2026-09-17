import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// iPad desteği açık KALMALI — Apple daraltmaya izin vermiyor.
///
/// 16 Eylül'de iPad desteği kapatılmıştı: kodda hiçbir yerde tablet
/// farkındalığı yoktu (`EkranOlcusu` yalnızca küçük telefonlar için
/// aralık daraltıyor), iPad'de uygulama tablet genişliğine gerilmiş bir
/// telefon düzeniydi. Ayrıca App Store her dil için ayrı iPad ekran
/// görüntüsü istiyordu ve bu, birincil dili İngilizce yapmayı bloke
/// ediyordu.
///
/// 17 Eylül'de 1.0.8 yüklenmek istendiğinde Apple reddetti:
///
///     This bundle does not support one or more of the devices
///     supported by the previous app version. (hata 90101)
///
/// Bir **güncellemede cihaz desteği daraltılamıyor**. Canlı sürüm
/// (1.0.7) iPad'i desteklediği için 1.0.8 de desteklemek zorunda.
/// Karar bu yüzden geri alındı; ayrıntı: claude/ipad-destegi-kaldirildi.md
///
/// Bu test, ayarın sessizce yeniden daraltılmasını engelliyor: daraltan
/// bir değişiklik derlenir, arşivlenir ve ancak YÜKLEME anında Apple'ın
/// sunucusunda patlar. Hatayı burada, dakikalar önce görmek daha iyi.
void main() {
  test('TARGETED_DEVICE_FAMILY iPhone + iPad', () {
    final proje =
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

    expect(proje.contains('TARGETED_DEVICE_FAMILY = "1";'), isFalse,
        reason: 'Cihaz desteği yeniden iPhone-only yapılmış. Apple bunu '
            'yükleme sırasında 90101 ile reddediyor: bir güncelleme, '
            'önceki sürümün desteklediği cihazları desteklemeyi '
            'sürdürmek zorunda.');
    expect(proje.contains('TARGETED_DEVICE_FAMILY = "1,2";'), isTrue,
        reason: 'iPad desteği açık olmalı.');
  });

  test('plist iPad yonelimlerini tasiyor', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist.contains('UISupportedInterfaceOrientations~ipad'), isTrue,
        reason: 'iPad destekleniyorsa iPad yönelim listesi de olmalı.');
  });

  test('tablet duzeni hala borclu', () {
    // iPad desteği teknik bir zorunluluk olarak geri geldi; tablet
    // DÜZENİ hâlâ yok. `EkranOlcusu` genişliğe bakmaya başladığı gün
    // gerçek tablet yerleşimi geliyor demektir — o gün bu test
    // güncellenecek ve mağaza iPad görselleri yenilenecek.
    final ekranOlcusu = File('lib/ui/ekran_olcusu.dart').readAsStringSync();
    expect(ekranOlcusu.contains('width'), isFalse,
        reason: 'EkranOlcusu genişliğe bakmaya başlamış — tablet düzeni '
            'geliyorsa iPad görselleri ve bu test gözden geçirilmeli.');
  });
}
