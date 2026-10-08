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

  test('Profil Pro satiri sade: "ebeveynler icin" eki yok', () {
    final p = File('lib/screens/auth/profile_screen.dart').readAsStringSync();
    expect(p.contains("'Pro üyelik'"), isTrue);
    expect(p.contains('Pro üyelik · ebeveynler için'), isFalse);
  });
}
