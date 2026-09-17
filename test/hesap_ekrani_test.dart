// HESAP EKRANI — kimlik bilgileri ve hesap islemleri tek yerde.
//
// Once hepsi profilin icine dagilmisti ve en altta kirmizi cerceveli
// "Tehlikeli Bolge" kutusu her ziyarette goruntuleniyordu: yilda belki
// bir kez kullanilan bir islem, her gun bir korku olarak duruyordu.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final hesap = File('lib/screens/auth/hesap_ekrani.dart').readAsStringSync();
  final profil =
      File('lib/screens/auth/profile_screen.dart').readAsStringSync();

  // Aciklama satirlari kendi testini eslestirmesin (bu hata bu depoda
  // daha once UC kez yapildi).
  String kodu(String kaynak) => kaynak
      .split('\n')
      .where((l) => !l.trimLeft().startsWith('//') && !l.trimLeft().startsWith('///'))
      .join('\n');

  test('hesabi silme profilden kalkti, Hesap ekraninda', () {
    expect(kodu(profil).contains('Tehlikeli Bölge'), isFalse,
        reason: 'Profil hala her ziyarette kirmizi uyari gosteriyor.');
    expect(kodu(profil).contains('deleteAccount()'), isFalse);
    expect(hesap.contains('Tehlikeli Bölge'), isTrue);
    expect(hesap.contains('deleteAccount()'), isTrue);
  });

  test('profilde Hesap girisi var', () {
    expect(profil.contains('HesapEkrani()'), isTrue,
        reason: 'Hesap ekranina giden bir yol yok.');
  });

  test('DOGUM TARIHI SORULMUYOR', () {
    // Uygulama dogum tarihi toplamiyor: yas yalnizca ARALIK olarak
    // soruluyor, ebeveyn kapisindaki dogum yili ise hicbir yere
    // yazilmiyor. Buraya bir alan eklemek, ihtiyac duyulmayan kisisel
    // veriyi cocuktan toplamak olurdu (ICO Cocuklara Uygun Tasarim,
    // madde 8 — veri minimizasyonu).
    final k = kodu(hesap);
    for (final yasak in ['Doğum tarihi', 'Birth date', 'birthDate', 'dogumTarihi']) {
      expect(k.contains(yasak), isFalse, reason: '$yasak alani eklenmis');
    }
    expect(hesap.contains('Yaş aralığı'), isTrue,
        reason: 'Yas araligi satiri kaybolmus.');
  });

  test('veli kodu listede yazmiyor, kendi ekranini aciyor', () {
    // Kodun kendisini satirda gostermek, omzunun uzerinden bakan
    // herkese vermek demekti. Kendi ekraninda yaninda "sadece annene ya
    // da babana ver" uyarisi ve takibi kaldirma dugmesi var.
    expect(hesap.contains('TakipKoduScreen()'), isTrue);
    expect(kodu(hesap).contains('currentCode()'), isFalse,
        reason: 'Kod dogrudan hesap listesinde okunuyor.');
  });

  test('ekran dort dilde', () {
    expect(hesap.contains("_t('Hesap', 'Account', 'Konto', 'Cuenta')"), isTrue);
    // Her _t cagrisi DORT dil tasimali: iki dilde kalan bir cagri,
    // Almanca secen bir velinin ekranda Ingilizce gormesi demek.
    final eksikDilli = RegExp(r"_t\('[^']*',\s*'[^']*'\)").allMatches(hesap);
    expect(eksikDilli, isEmpty,
        reason: 'Bazi metinler yalnizca iki dilde: '
            '${eksikDilli.map((m) => m.group(0)).join(', ')}');
    // AppLang.pick dort parametreyle cagriliyor mu (iki dilde kalmis
    // cagri var mi) — _t yardimcisi dort dili zorunlu tutuyor.
    expect(hesap.contains('String _t(String tr, String en, String de, String es)'),
        isTrue);
  });

  test('satir degerleri ayni hizada bitiyor', () {
    // Ok yalnizca dokunulabilir satirlarda cizilince o satirin degeri
    // okun genisligi kadar sola kayiyordu: "BilgeEjderha" ile alttaki
    // "Bu telefonda" ayni hizada bitmiyordu.
    expect(hesap.contains('SizedBox(\n            width: 24,'), isTrue,
        reason: 'Ok icin her satirda yer ayrilmiyor — hiza yine bozulur.');
  });

  test('ad duzenleyici tek yerde', () {
    // Ayni duzenleyici iki ekrandan aciliyor; kopyalansaydi iki ayri
    // dogrulama kurali olur ve biri guncellenmeyi unuturdu.
    final duzenleyici =
        File('lib/screens/auth/ad_duzenleyici.dart').readAsStringSync();
    expect(duzenleyici.contains('NicknameGenerator.validate'), isTrue);
    expect(hesap.contains('adDuzenleyiciyiAc('), isTrue);
    expect(profil.contains('adDuzenleyiciyiAc('), isTrue);
    expect(kodu(profil).contains('NicknameGenerator.validate'), isFalse,
        reason: 'Profilde ikinci bir dogrulama kopyasi kalmis.');
  });
}
