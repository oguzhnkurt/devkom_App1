// Google ile giris (Android): dugme, hata metinleri, kurulum kapisi.
import 'dart:io';

import 'package:devkom_app/config/google_config.dart';
import 'package:devkom_app/screens/auth/login_screen.dart';
import 'package:devkom_app/services/auth_service_supabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  testWidgets('dugme: G logosu + yazi, uzun dilde tasmiyor', (tester) async {
    var basildi = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            child: GoogleIleDevamDugmesi(
              yazi: 'Mit Google fortfahren',
              onPressed: () => basildi++,
            ),
          ),
        ),
      ),
    ));
    expect(find.text('Mit Google fortfahren'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.tap(find.byType(GoogleIleDevamDugmesi));
    expect(basildi, 1);
    expect(tester.takeException(), isNull);
  });

  test('hata metinleri cocuga gore; ham kod yok', () {
    for (final k in GoogleSignInExceptionCode.values) {
      final m = AuthServiceSupabase.googleHataMesaji(k);
      expect(m, isNotEmpty);
      expect(m.contains('Exception'), isFalse);
      expect(m.contains(k.name), isFalse);
    }
  });

  test('istemci kimligi yokken dugme hic gorunmuyor', () {
    final ekran = File('lib/screens/auth/login_screen.dart').readAsStringSync();
    expect(ekran.contains('if (_googleAvailable)'), isTrue);
    final servis = File('lib/services/auth_service_supabase.dart').readAsStringSync();
    expect(servis.contains('Platform.isAndroid && GoogleConfig.hazir'), isTrue);
    // Bos istemci kimligiyle "hazir" olamaz.
    if (GoogleConfig.webClientId.isEmpty) expect(GoogleConfig.hazir, isFalse);
  });

  test('Google girisi de anonim ilerlemeyi tasiyor ve cikista kapaniyor', () {
    final s = File('lib/services/auth_service_supabase.dart').readAsStringSync();
    final g = s.substring(s.indexOf('Future<UserModel?> signInWithGoogle()'));
    final govde = g.substring(0, g.indexOf('static String googleHataMesaji'));
    expect(govde.contains('create_account_merge_token'), isTrue);
    expect(govde.contains('claim_account_merge_token'), isTrue);
    expect(govde.contains('OAuthProvider.google'), isTrue);
    final cikis = s.substring(s.indexOf('Future<void> signOut()'));
    expect(cikis.substring(0, 300).contains('googleOturumunuKapat'), isTrue);
  });
}
