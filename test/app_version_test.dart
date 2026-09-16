import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:devkom_app/app_version.dart';

/// Sürüm sabiti pubspec ile aynı kalmalı.
///
/// Bu testin varlık sebebi gerçek bir hata: ayarlar ekranı aylarca
/// `1.0.0` gösterdi, pubspec `1.0.6+10` idi. Elle yazılmış sürüm
/// numarası er geç kayar; kaymayı yakalayacak tek şey bir test.
void main() {
  test('AppVersion pubspec.yaml ile aynı', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match =
        RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
                multiLine: true)
            .firstMatch(pubspec);

    expect(match, isNotNull,
        reason: 'pubspec.yaml içinde "version: x.y.z+n" satırı bulunamadı');

    expect(AppVersion.name, match!.group(1),
        reason: 'pubspec sürümü değişmiş ama lib/app_version.dart '
            'güncellenmemiş. AppVersion.name düzeltilmeli.');
    expect(AppVersion.build, match.group(2),
        reason: 'pubspec derleme numarası değişmiş ama '
            'lib/app_version.dart güncellenmemiş.');
  });

  test('ekranda gösterilen sürüm elle yazılmamış', () {
    final settings =
        File('lib/screens/settings/settings_screen.dart').readAsStringSync();
    expect(settings.contains("1.0.0"), isFalse,
        reason: 'Ayarlar ekranında sabit sürüm numarası kalmış; '
            'AppVersion kullanılmalı.');
  });
}
