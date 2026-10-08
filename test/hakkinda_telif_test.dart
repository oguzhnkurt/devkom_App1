// Hakkında penceresindeki telif satırı şirket unvanını taşır
// (docs/privacy-policy.html: "Devkom Yazılım"), uygulama adını değil.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Hakkında telif satırı Devkom Yazılım', () {
    final s = File('lib/screens/settings/settings_screen.dart').readAsStringSync();
    expect(s.contains("'© 2026 Devkom Yazılım'"), isTrue);
    expect(s.contains('© 2025 DevEducation'), isFalse);
  });
}
