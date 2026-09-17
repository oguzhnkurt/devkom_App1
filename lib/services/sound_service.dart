import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Oyun sesleri ve dokunsal geri bildirim.
///
/// Bu servis daha once hicbir ses CALMIYORDU: her cagri ya
/// `SystemSound.play(click)` ya da bir titresim yapiyordu, gercek ses
/// dosyalarini kullanan satirlar yorum icinde bekliyordu ve
/// `assets/sounds/` klasoru bostu. Cocuk dogru cevabi verdiginde duydugu
/// sey klavye tikirtisiydi.
///
/// Artik klasorde gercek sesler var (uygulama icin uretildi, lisans
/// sorunu yok): Do majorde yumusak sinus tonlari. "Dogru" yukselen bir
/// ucluyu (do-mi-sol), "yanlis" kisa ve alcak inen bir ikiliyi calar —
/// yanlis sesi bilerek cezalandirici degil, cunku yanlis denemek
/// ogrenmenin parcasi.
///
/// Ses ve titresim ayrı ayrı kapatilabilir; ikisi de ayarlardaki
/// anahtarlara bagli ([configure] ile guncelleniyor).
/// Bir oyunun ses rengi.
///
/// Butun oyunlarda ayni "dogru" sesini calmak, oyunlari birbirinden
/// ayirt edilemez kiliyordu — cocuk hangi oyunda oldugunu sesten
/// anlamiyor, ve ayni ton gun boyu tekrarlaninca yipraniyor.
///
/// Sesler AILE olarak tasarlandi: hepsi ayni muzikal fikir (yukselen
/// bir uclu), ama farkli kok perde ve farkli ton rengi. Yani "bu
/// uygulamanin sesi" hissi bozulmadan her oyun kendi sesini aliyor.
enum SfxVoice {
  /// Parlak, cok harmonikli. Kelime/dil oyunlari.
  bright('bright'),

  /// Yumusak ve bir perde alttan. Eslestirme, siralama.
  warm('warm'),

  /// Neredeyse saf sinus, en sakini. Renk, desen, koordinat.
  soft('soft'),

  /// Kalin ve biraz daha uzun. Robotik, devre, blok kodlama.
  deep('deep');

  const SfxVoice(this.suffix);
  final String suffix;
}

class SoundService {
  SoundService._();

  /// Ekranlar her cagrida ses rengini gecmek zorunda kalmasin diye,
  /// oyun acilirken bir kere ayarlaniyor.
  static SfxVoice _voice = SfxVoice.bright;

  /// Bu ekranin ses rengini secer. Oyun ekranlari `initState` icinde
  /// cagiriyor.
  static void useVoice(SfxVoice voice) => _voice = voice;

  static SfxVoice get voice => _voice;

  /// Kisa efektler ust uste binebilsin diye tek oynatici yerine kucuk bir
  /// havuz kullaniyoruz. Tek oynatici olsaydi hizli eslestirmede ikinci ses
  /// birinciyi kesecekti.
  static final List<AudioPlayer> _pool =
      List.generate(3, (_) => AudioPlayer(playerId: 'sfx_$_'));
  static int _next = 0;

  static bool _soundEnabled = true;
  static bool _vibrationEnabled = true;
  static double _volume = 0.6;

  /// Ayarlar ekranindaki anahtarlari servise baglar.
  static void configure({bool? sound, bool? vibration, double? volume}) {
    if (sound != null) _soundEnabled = sound;
    if (vibration != null) _vibrationEnabled = vibration;
    if (volume != null) _volume = volume.clamp(0.0, 1.0);
  }

  static void setEnabled(bool enabled) => _soundEnabled = enabled;
  static void setVibrationEnabled(bool enabled) => _vibrationEnabled = enabled;
  static void setVolume(double volume) => _volume = volume.clamp(0.0, 1.0);

  static bool get soundEnabled => _soundEnabled;
  static bool get vibrationEnabled => _vibrationEnabled;

  static Future<void> _play(String file, {double gain = 1.0}) async {
    if (!_soundEnabled) return;
    try {
      final player = _pool[_next];
      _next = (_next + 1) % _pool.length;
      await player.stop();
      await player.play(
        AssetSource('sounds/$file.wav'),
        volume: (_volume * gain).clamp(0.0, 1.0),
      );
    } catch (e) {
      // Ses cikmamasi oyunu durdurmamali: simulatorde ve sessiz moddaki
      // cihazlarda burasi normal olarak hata veriyor.
      debugPrint('SoundService play error ($file): $e');
    }
  }

  static Future<void> _haptic(Future<void> Function() f) async {
    if (!_vibrationEnabled) return;
    try {
      await f();
    } catch (e) {
      debugPrint('SoundService haptic error: $e');
    }
  }

  /// Dogru cevap: yukselen uclu + hafif titresim.
  ///
  /// [voice] verilmezse ekranin [useVoice] ile sectigi renk kullanilir.
  static Future<void> playCorrect({SfxVoice? voice}) async {
    await Future.wait([
      _play('correct_${(voice ?? _voice).suffix}'),
      _haptic(HapticFeedback.lightImpact),
    ]);
  }

  /// Yanlis cevap.
  ///
  /// Ayni ses ailesinin alt bolgesinde, kisa ve inen. Bilerek
  /// cezalandirici degil: yanlis denemek ogrenmenin parcasi, ve bu yas
  /// grubunda yanlislarin buyuk kismi bilgi degil parmak hatasi.
  /// Titresim de en hafifi.
  static Future<void> playWrong({SfxVoice? voice}) async {
    await Future.wait([
      _play('wrong_${(voice ?? _voice).suffix}', gain: 0.8),
      _haptic(HapticFeedback.selectionClick),
    ]);
  }

  /// DERS SORUSUNU DOGRU BILDIGINDE.
  ///
  /// Oyunlardaki `playCorrect` sentezlenmis sinus ailesini calıyor ve her
  /// oyunun kendi ton rengi var. Ders sorulari icin ise gercek kayit
  /// kullaniliyor (uygulama icin satin alindi): kisa, parlak bir
  /// "toplama" sesi. Cok soru pes pese cevaplandigi icin kasitli olarak
  /// yarim saniyenin altinda — uzun bir jingle ucuncu soruda yoruyor.
  static Future<void> playSoruDogru() async {
    await Future.wait([
      _play('dogru_cevap'),
      _haptic(HapticFeedback.lightImpact),
    ]);
  }

  /// Bir bolumun tamami dogru bitince (ders sonu, quiz sonu).
  ///
  /// Soru sesinin buyugu: tek tek dogrularin ustune binmesin diye
  /// yalnizca BITIS anlarinda caliyor.
  static Future<void> playOdul() async {
    await Future.wait([
      _play('odul'),
      _haptic(HapticFeedback.mediumImpact),
    ]);
  }

  /// Uygulamadaki ILK basari: acilistaki ilk surukle-birak gorevi.
  ///
  /// Bir kere duyuluyor ve o yuzden digerlerinden farkli: cocugun
  /// uygulamada yaptigi ilk is bu, ve "oldu" demenin en dogrudan yolu.
  static Future<void> playIlkBasari() async {
    await Future.wait([
      _play('ilk_basari'),
      _haptic(HapticFeedback.mediumImpact),
    ]);
  }

  /// Bir parca yerine oturdugunda (surukle-birak).
  static Future<void> playDrop() async {
    await Future.wait([
      _play('drop', gain: 0.9),
      _haptic(HapticFeedback.selectionClick),
    ]);
  }

  /// Seviye/bolum tamamlandi: ayni renkte kucuk fanfar.
  static Future<void> playLevelComplete({SfxVoice? voice}) async {
    await Future.wait([
      _play('complete_${(voice ?? _voice).suffix}'),
      _haptic(HapticFeedback.mediumImpact),
    ]);
  }

  /// Oyun bitti.
  static Future<void> playGameOver() async {
    await Future.wait([
      _play('wrong_${_voice.suffix}', gain: 0.9),
      // Burada da agir degil orta siddet: oyunun bitmesi bir kaza degil.
      _haptic(HapticFeedback.mediumImpact),
    ]);
  }

  /// Buton/kart dokunusu.
  static Future<void> playClick() async {
    await Future.wait([
      _play('tap', gain: 0.7),
      _haptic(HapticFeedback.selectionClick),
    ]);
  }

  /// Puan kazanma.
  static Future<void> playScore() => playDrop();

  // Eski cagri adlari — ekranlarda hala kullaniliyor.
  static Future<void> playCorrectSound() => playCorrect();
  static Future<void> playWrongSound() => playWrong();
  static Future<void> playSuccessSound() => playLevelComplete();

  /// Ozel bir ses dosyasi (assets/ altindaki yol).
  static Future<void> playCustom(String assetPath) async {
    if (!_soundEnabled) return;
    try {
      final player = _pool[_next];
      _next = (_next + 1) % _pool.length;
      await player.stop();
      await player.play(AssetSource(assetPath), volume: _volume);
    } catch (e) {
      debugPrint('SoundService play error ($assetPath): $e');
    }
  }

  static Future<void> stopAll() async {
    for (final p in _pool) {
      try {
        await p.stop();
      } catch (e) {
        debugPrint('SoundService stop error: $e');
      }
    }
  }

  static void dispose() {
    for (final p in _pool) {
      p.dispose();
    }
  }
}
