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
/// Artik klasorde gercek sesler var. Iki kaynak bir arada:
///
/// 1. SENTEZLENMIS AILE (`wrong_*`): Do majorde yumusak sinus tonlari,
///    uygulama icin uretildi. Kisa ve alcak inen bir ikili calar —
///    bilerek cezalandirici degil, cunku yanlis denemek ogrenmenin
///    parcasi. Ton rengi (bkz. [SfxVoice]) yalnizca burada yasiyor.
///
///    `correct_*` ve `complete_*` de bir sure bu ailedendi ve SILINDI:
///    kulaga ucuz geliyorlardi ve bir turda onlarca kez duyulan bir ses
///    icin bu dayanilmaz oluyordu. Yerlerini gercek kayitlar aldi.
///    Yanlis sesi neden hala sentezlenmis? Cunku satin alinan paketteki
///    basarisizlik sesleri cizgi film tarzinda ve cezalandirici; 6-12
///    yas icin yumusak bir "olmadi" tonu daha dogru.
///
/// 2. GERCEK KAYITLAR (`tap`, `drop`, `dogru_cevap`, `odul`,
///    `ilk_basari`, `jeton`, `buyuk_basari`, `oyun_bitti`,
///    `kilit_acildi`, `oyun_dogru`, `bolum_bitti`): satin alinan
///    oyun/uygulama ses paketinden
///    kirpildi. Hepsi tek kanal 44.1 kHz, RMS -18..-20 dB araliginda
///    normallendi (sentezlenmis ailenin ustune cikmasin diye) ve tepe
///    -1.5 dB'de sinirlandi. Uretim notu: `assets/sounds/NASIL_KIRPILDI.md`.
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

  /// DOGRU CEVAP.
  ///
  /// Burada bir sure sentezlenmis bir sinus ucusu (do-mi-sol) caliyordu
  /// ve her oyunun kendi ton rengi vardi. Kulaga UCUZ geliyordu: sekiz
  /// bitlik bir oyuncak sesi gibi, ve bir turda onlarca kez duyuldugu
  /// icin kisa surede itici hale geliyordu ("Sabah Rutini" gorevini
  /// bitirince gelen ses tam olarak buydu).
  ///
  /// Artik satin alinan paketten kirpilmis kisa bir onay sesi caliyor:
  /// tek ses, butun oyunlarda ayni. Ton rengi ailesi burada birakildi —
  /// dort ayri gercek kayit yok, ve "her oyunun kendi dogru sesi" fikri
  /// sesin kendisi rahatsiz ediciyse hicbir sey kazandirmiyor.
  ///
  /// Seviye de bilerek dusuk (RMS -22 dB ve ustune 0.85 kisma): bu ses
  /// bir basari fanfari degil, "evet, oldu" demenin en kisa yolu.
  ///
  /// [voice] artik yalnizca yanlis cevap sesini etkiliyor; imza
  /// bozulmasin diye duruyor.
  static Future<void> playCorrect({SfxVoice? voice}) async {
    await Future.wait([
      _play('oyun_dogru', gain: 0.85),
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

  /// Seviye/bolum tamamlandi.
  ///
  /// Dogru cevap sesiyle ayni gerekce: sentezlenmis fanfar ucuz
  /// duruyordu. Gercek kayit, dogru cevap sesinden daha dolu ama
  /// "buyuk basari"dan (modul sinavi) daha kisa — uc kademe arasinda
  /// fark kulakla duyuluyor.
  static Future<void> playLevelComplete({SfxVoice? voice}) async {
    await Future.wait([
      _play('bolum_bitti'),
      _haptic(HapticFeedback.mediumImpact),
    ]);
  }

  /// Oyun bitti.
  ///
  /// Onceden yanlis cevap sesinin kisilmis halini caliyordu: cocuk
  /// "bir soruyu kacirdim" ile "oyun bitti"yi sesten ayirt edemiyordu.
  /// Artik kendi sesi var — cizgi film tadinda, cezalandirici degil,
  /// cunku oyunun bitmesi bir kaza degil.
  static Future<void> playGameOver() async {
    await Future.wait([
      _play('oyun_bitti', gain: 0.95),
      _haptic(HapticFeedback.mediumImpact),
    ]);
  }

  /// JETON KAZANMA.
  ///
  /// Oyunda puan, gorevde jeton: ikisi de "kazandim" anlari ve ikisi de
  /// eskiden `drop` sesini caliyordu — yani bir parcanin yerine
  /// oturmasiyla ayni ses. Kazanmanin kendi sesi olmasi gerekiyordu.
  static Future<void> playJeton() async {
    await Future.wait([
      _play('jeton'),
      _haptic(HapticFeedback.lightImpact),
    ]);
  }

  /// MODUL SINAVI / BUYUK KILOMETRE TASI.
  ///
  /// [playOdul] bir dersin sonu; bu ise bir MODULUN sonu. Ikisi ayni
  /// sesi calarsa modul sinavini bitirmek siradan bir ders bitirmek
  /// gibi hissettiriyor. Bu yuzden buyuk olan burada.
  static Future<void> playBuyukBasari() async {
    await Future.wait([
      _play('buyuk_basari'),
      _haptic(HapticFeedback.heavyImpact),
    ]);
  }

  /// Reklam izlendi, ders kilidi acildi.
  static Future<void> playKilitAcildi() async {
    await Future.wait([
      _play('kilit_acildi'),
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

  /// Puan kazanma. Jeton sesiyle ayni: ikisi de "kazandim" demek.
  static Future<void> playScore() => playJeton();

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
