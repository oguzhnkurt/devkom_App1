import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Meta SDK kurulumu bozulmasın ve yarım hâliyle yayınlanmasın.
void main() {
  final plist = File('ios/Runner/Info.plist').readAsStringSync();

  test('Meta App ID ve URL şeması yerinde', () {
    expect(plist, contains('<string>1644718090391447</string>'));
    expect(plist, contains('<string>fb1644718090391447</string>'));
  });

  test('client token yer tutucu olarak kalmamış', () {
    expect(plist.contains('META_CLIENT_TOKEN_BURAYA'), isFalse,
        reason: 'Info.plist > FacebookClientToken hâlâ yer tutucu. '
            'Meta for Developers > DevEducation > Uygulama ayarları > '
            'Gelişmiş > İstemci tokeni değeri girilmeli.');
  });

  test('reklam kimliği toplanmıyor, ATT izni yok', () {
    final i = plist.indexOf('<key>FacebookAdvertiserIDCollectionEnabled</key>');
    expect(i, isNot(-1));
    expect(plist.substring(i, i + 80), contains('<false/>'));
    expect(plist.contains('<key>NSUserTrackingUsageDescription</key>'),
        isFalse);
  });

  test('main.dart Meta servisini başlatıyor', () {
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('MetaInstallService.initialize()'));
  });
}
