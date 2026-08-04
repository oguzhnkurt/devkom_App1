import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Oyun sesleri için merkezi servis
///
/// Kullanım:
/// - SoundService.playCorrect() - Doğru cevap sesi
/// - SoundService.playWrong() - Yanlış cevap sesi
/// - SoundService.playLevelComplete() - Seviye tamamlama sesi
/// - SoundService.playGameOver() - Oyun bitti sesi
/// - SoundService.playClick() - Tıklama sesi
///
class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isEnabled = true;
  static double _volume = 0.5;

  /// Sesleri etkinleştir/devre dışı bırak
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Ses seviyesini ayarla (0.0 - 1.0)
  static void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// Doğru cevap sesi (Başarı tonu - yüksek pitch)
  static Future<void> playCorrect() async {
    if (!_isEnabled) return;

    try {
      await _player.stop();
      // Sistem sesini kullan veya gelecekte asset eklenebilir
      await SystemSound.play(SystemSoundType.click);

      // Asset varsa kullan
      // await _player.play(AssetSource('sounds/correct.mp3'), volume: _volume);
    } catch (e) {
      // Sessiz başarısızlık - ses çalmasa da uygulama çalışmaya devam eder
      debugPrint('Sound play error: $e');
    }
  }

  /// Yanlış cevap sesi (Hata tonu - düşük pitch)
  static Future<void> playWrong() async {
    if (!_isEnabled) return;

    try {
      await _player.stop();
      // Sistem sesini kullan
      await HapticFeedback.vibrate();

      // Asset varsa kullan
      // await _player.play(AssetSource('sounds/wrong.mp3'), volume: _volume);
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  /// Seviye tamamlama sesi (Zafer müziği)
  static Future<void> playLevelComplete() async {
    if (!_isEnabled) return;

    try {
      await _player.stop();
      // Başarı için hafif titreşim
      await HapticFeedback.mediumImpact();

      // Asset varsa kullan
      // await _player.play(AssetSource('sounds/level_complete.mp3'), volume: _volume);
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  /// Oyun bitti sesi (Game Over)
  static Future<void> playGameOver() async {
    if (!_isEnabled) return;

    try {
      await _player.stop();
      // Ağır titreşim
      await HapticFeedback.heavyImpact();

      // Asset varsa kullan
      // await _player.play(AssetSource('sounds/game_over.mp3'), volume: _volume);
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }


  /// Doğru cevap sesi (alias)
  static Future<void> playCorrectSound() async {
    return playCorrect();
  }

  /// Yanlış cevap sesi (alias)
  static Future<void> playWrongSound() async {
    return playWrong();
  }

  /// Başarı sesi (alias)
  static Future<void> playSuccessSound() async {
    return playLevelComplete();
  }

  /// Buton tıklama sesi
  static Future<void> playClick() async {
    if (!_isEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  /// Puan kazanma sesi (Coin collect)
  static Future<void> playScore() async {
    if (!_isEnabled) return;

    try {
      await _player.stop();
      await HapticFeedback.selectionClick();

      // Asset varsa kullan
      // await _player.play(AssetSource('sounds/score.mp3'), volume: _volume);
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  /// Özel ses çal (asset path ile)
  static Future<void> playCustom(String assetPath) async {
    if (!_isEnabled) return;

    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath), volume: _volume);
    } catch (e) {
      debugPrint('Sound play error: $e');
    }
  }

  /// Tüm sesleri durdur
  static Future<void> stopAll() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Sound stop error: $e');
    }
  }

  /// Servis temizleme
  static void dispose() {
    _player.dispose();
  }
}
