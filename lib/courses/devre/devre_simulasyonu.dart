import 'package:flutter/foundation.dart';

import '../../services/sound_service.dart';
import '../yurutme/mblock_uno.dart';
import 'devre_modeli.dart';

/// Devre + sanal Uno + cocugun girdileri: canli simulasyon.
///
/// Uno programi pinlere yazdikca ([UnoKarti] bildirdikce) ve cocuk
/// butona bastikca, potansiyometreyi cevirdikce sonuc yeniden
/// hesaplaniyor (tembel: biri [sonuc]u okuyunca). Kartin girisleri
/// (dijital oku, analog oku, mesafe) DEVREDEN okunuyor: kablo yanlissa
/// buton okunmaz, sensor gucsuzse 0 gelir — gercek kartta oldugu gibi.
class DevreSimulasyonu extends ChangeNotifier {
  DevreSimulasyonu({required this.kart, Devre devre = Devre.bos, this.ses = true})
      : _devre = devre {
    kart.addListener(_kartDegisti);
    kart.dijitalGiris = (pin) => sonuc.dijitalOku(pin);
    kart.analogGiris = (pin) => sonuc.analogOku(pin);
    kart.mesafeGiris = (t, e) => sonuc.mesafe(t, e);
  }

  final UnoKarti kart;

  /// Buzzer sesi calinsin mi (ders adimlarinda da evet; testlerde ses
  /// servisi zaten kapali).
  final bool ses;

  Devre _devre;
  DevreGirdileri _girdiler = const DevreGirdileri();
  DevreSonucu? _sonuc;
  bool _atildi = false;

  Devre get devre => _devre;
  set devre(Devre d) {
    if (identical(d, _devre)) return;
    _devre = d;
    _gecersiz();
  }

  DevreGirdileri get girdiler => _girdiler;

  DevreSonucu get sonuc => _sonuc ??= devreyiCoz(
        _devre,
        cikislar: DevreCikislari(
          dijital: kart.dijital,
          pwm: kart.pwm,
          servo: kart.servo,
          ton: kart.ton,
        ),
        girdiler: _girdiler,
      );

  void _girdi(DevreGirdileri g) {
    _girdiler = g;
    _gecersiz();
  }

  void butonBas(String id, bool basili) {
    final s = Set<String>.of(_girdiler.basililar);
    if (basili ? !s.add(id) : !s.remove(id)) return;
    _girdi(DevreGirdileri(
        basililar: s,
        potlar: _girdiler.potlar,
        isik: _girdiler.isik,
        sicaklik: _girdiler.sicaklik,
        mesafe: _girdiler.mesafe));
  }

  bool basili(String id) => _girdiler.basililar.contains(id);

  void potAyarla(String id, double k) => _girdi(DevreGirdileri(
      basililar: _girdiler.basililar,
      potlar: {..._girdiler.potlar, id: k.clamp(0.0, 1.0)},
      isik: _girdiler.isik,
      sicaklik: _girdiler.sicaklik,
      mesafe: _girdiler.mesafe));

  set isik(double v) => _girdi(DevreGirdileri(
      basililar: _girdiler.basililar,
      potlar: _girdiler.potlar,
      isik: v.clamp(0, 100),
      sicaklik: _girdiler.sicaklik,
      mesafe: _girdiler.mesafe));

  set sicaklik(double v) => _girdi(DevreGirdileri(
      basililar: _girdiler.basililar,
      potlar: _girdiler.potlar,
      isik: _girdiler.isik,
      sicaklik: v.clamp(-10, 50),
      mesafe: _girdiler.mesafe));

  set mesafe(int v) => _girdi(DevreGirdileri(
      basililar: _girdiler.basililar,
      potlar: _girdiler.potlar,
      isik: _girdiler.isik,
      sicaklik: _girdiler.sicaklik,
      mesafe: v.clamp(2, 200)));

  void _kartDegisti() => _gecersiz();

  void _gecersiz() {
    if (_atildi) return;
    _sonuc = null;
    if (ses) {
      var hz = 0;
      for (final f in sonuc.buzzerlar.values) {
        if (f > hz) hz = f;
      }
      SoundService.buzzer(hz);
    }
    notifyListeners();
  }

  /// Program durdu: buzzer sussun.
  void sustur() {
    if (ses) SoundService.buzzer(0);
  }

  @override
  void dispose() {
    _atildi = true;
    kart.removeListener(_kartDegisti);
    kart.dijitalGiris = null;
    kart.analogGiris = null;
    kart.mesafeGiris = null;
    if (ses) SoundService.buzzer(0);
    super.dispose();
  }
}
