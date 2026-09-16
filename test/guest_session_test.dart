// CIKISTAN SONRA UYGULAMA KULLANICISIZ KALMAMALI.
//
// Kullanicinin bulduğu hata: cekmeceden "Cikis yap" -> sonra "Hesapsiz
// devam et" -> profil "Profilin yuklenemedi" diyordu. Internet sorunu
// yoktu; uygulama gercekten kullanicisiz kalmisti. Cikis oturumu
// temizliyor ama yerine yenisini ACMIYORDU, oysa uygulamanin tasarimi
// "kimlik sorma, anonim calis".
//
// NEDEN KAYNAK TARAMASI: AuthProvider dogrudan Supabase kullanan somut
// bir servise bagli; davranisi calistirmak icin gercek bir Supabase
// ornegi gerekiyor. Bu test o yuzden davranisi degil, hatanin
// duzeltildigi YERI kilitliyor — zayif ama bos degil.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String p) => File(p).readAsStringSync();

void main() {
  const provider = 'lib/providers/auth_provider.dart';
  const profile = 'lib/screens/auth/profile_screen.dart';

  test('cikis olayindan sonra misafir oturumu aciliyor', () {
    final src = _read(provider);
    final i = src.indexOf('AuthChangeEvent.signedOut');
    expect(i, greaterThan(-1), reason: 'çıkış olayı ele alınmıyor');

    // signedOut dalinin govdesi: bir sonraki `return;`e kadar.
    final body = src.substring(i, src.indexOf('return;', i));
    expect(body.contains('_ensureGuestSession'), isTrue,
        reason: 'çıkıştan sonra yeni misafir oturumu açılmıyor — '
            'uygulama kullanıcısız kalır ve profil "yüklenemedi" der');
  });

  test('signOut misafir oturumunu BEKLEYEREK açıyor', () {
    final src = _read(provider);
    final i = src.indexOf('Future<void> signOut()');
    expect(i, greaterThan(-1));
    final body = src.substring(i, i + 1600);
    expect(body.contains('await _ensureGuestSession()'), isTrue,
        reason: 'signOut dönmeden önce oturum açılmazsa, çıkıştan sonra '
            'gidilen ekran bir kare "kullanıcı yok" hâliyle çizilir');
  });

  test('kullanici yokken profilde bir CIKIS YOLU var', () {
    final src = _read(profile);
    final i = src.indexOf('if (user == null)');
    expect(i, greaterThan(-1));
    final body = src.substring(i, i + 3000);
    expect(body.contains('refreshUser'), isTrue,
        reason: 'ekranda tek bir düğme bile yoksa kullanıcının '
            'yapabileceği tek şey uygulamayı kapatmak olur');
  });

  test('hata metni internet suclamiyor', () {
    final src = _read(profile);
    final i = src.indexOf('if (user == null)');
    final body = src.substring(i, i + 3000);
    // Yorumlarda gecmesi serbest; EKRANA YAZILAN metne bakiyoruz.
    final shown = RegExp(r"'([^']{12,})'")
        .allMatches(body)
        .map((m) => m.group(1)!)
        .where((t) => !t.startsWith('//'))
        .toList();
    expect(
      shown.any((t) => t.contains('İnternet bağlantını kontrol')),
      isFalse,
      reason: 'en sık sebep ağ değil, oturumun hiç açılmamış olması — '
          'çocuk internete bakıp bir şey bulamıyor',
    );
  });
}
