import 'dart:async';

import 'package:flutter/foundation.dart';

import 'mblock_cozum.dart';

/// SANAL ARDUINO UNO — kartin o anki hali.
///
/// Cikislar (pinlerin yuksek/dusuk hali, PWM parlakligi, servo acisi,
/// seri port satirlari) programdan; girisler (buton, potansiyometre,
/// mesafe) cocugun parmagindan geliyor. Ekran (UnoKartiGorunumu) bunu
/// dinliyor; yorumlayici ([UnoYorumlayici]) bunu degistiriyor.
///
/// Gercek bir kartin taklidi DEGIL, dersin anlattigi davranisin
/// kendisi: "pin 9 yuksek" LED'i yakar, "PWM 128" yari parlaklik,
/// "dijital oku pin 2" butona basili mi.
class UnoKarti extends ChangeNotifier {
  /// Butonun bagli oldugu pin (derslerde 2).
  static const int butonPini = 2;

  /// Buzzer'in bagli oldugu pin. Katalogda nota blogu yok; buzzer
  /// "dijital ayarla pin 8 yuksek" ile otuyor.
  static const int buzzerPini = 8;

  /// Yuksek olan dijital cikislar.
  final Map<int, bool> dijital = {};

  /// PWM cikislari (0-255).
  final Map<int, int> pwm = {};

  /// Servo acilari (0-180).
  final Map<int, int> servo = {};

  /// Seri port monitorunun son satirlari (en fazla [seriSinir]).
  final List<String> seri = [];
  static const int seriSinir = 30;

  /// Programin degiskenleri (`parlaklik`).
  final Map<String, num> degiskenler = {};

  bool _buton = false;
  int _pot = 512;
  int _mesafe = 30;

  /// Buton basili mi (dijital oku pin 2).
  bool get butonBasili => _buton;
  set butonBasili(bool v) {
    if (_buton == v) return;
    _buton = v;
    notifyListeners();
  }

  /// Potansiyometre, analog pin A0 (0-1023).
  int get pot => _pot;
  set pot(int v) {
    final d = v.clamp(0, 1023);
    if (_pot == d) return;
    _pot = d;
    notifyListeners();
  }

  /// Mesafe sensoru (cm, 2-200).
  int get mesafe => _mesafe;
  set mesafe(int v) {
    final d = v.clamp(2, 200);
    if (_mesafe == d) return;
    _mesafe = d;
    notifyListeners();
  }

  /// Bir pindeki LED'in parlakligi 0..1: PWM yazildiysa ondan, yoksa
  /// dijital halinden.
  double parlaklik(int pin) {
    final p = pwm[pin];
    if (p != null) return p / 255;
    return dijital[pin] == true ? 1 : 0;
  }

  void dijitalYaz(int pin, bool yuksek) {
    pwm.remove(pin);
    if (dijital[pin] == yuksek) return;
    dijital[pin] = yuksek;
    notifyListeners();
  }

  void pwmYaz(int pin, int deger) {
    final d = deger.clamp(0, 255);
    dijital.remove(pin);
    if (pwm[pin] == d) return;
    pwm[pin] = d;
    notifyListeners();
  }

  void servoYaz(int pin, int aci) {
    final d = aci.clamp(0, 180);
    if (servo[pin] == d) return;
    servo[pin] = d;
    notifyListeners();
  }

  void seriYaz(String satir) {
    seri.add(satir);
    while (seri.length > seriSinir) {
      seri.removeAt(0);
    }
    notifyListeners();
  }

  /// Bir pin okunuyor: buton pini butondan, digerleri cikisin kendisinden.
  bool dijitalOku(int pin) =>
      pin == butonPini ? _buton : (dijital[pin] ?? false);

  /// Analog okuma: A0 potansiyometre; bos pinler 0.
  int analogOku(int pin) => pin == 0 ? _pot : 0;

  /// Program yeniden baslarken cikislar sifirlaniyor; girisler (cocugun
  /// ayarladigi pot, mesafe) yerinde kaliyor.
  void sifirla() {
    dijital.clear();
    pwm.clear();
    servo.clear();
    seri.clear();
    degiskenler.clear();
    notifyListeners();
  }
}

/// Bir calistirmanin nasil bittigi.
enum UnoBitis {
  /// Program sonuna geldi.
  bitti,

  /// Durdur'a basildi ya da ekran kapandi.
  durduruldu,

  /// Komut butcesi doldu: "surekli tekrarla" bitmez, biz durdurduk.
  butceBitti,

  /// Tahtada "Arduino Uno baslatildiginda" ile baslayan yigin yok.
  baslangicYok,
}

/// mBlock tezgahindaki programi sanal Uno'da GERCEKTEN calistirir.
///
/// Program `mblock_cozum.dart`'in okudugu yapi ([MBlockBlok] agaci):
/// C bloklarinin ici `icerik`, yuvaya takili bloklar `girdiler`. Yani
/// denetim neyi okuyorsa calisan da o.
///
/// ZAMAN: "1 saniye bekle" gercekten bekliyor ([zamanOlcegi] ile
/// olceklenebilir). Bekleme kesilebilir: [durdur] bekleyen zamanlayiciyi
/// iptal ediyor, ekran kapaninca asili zamanlayici kalmiyor.
///
/// SONSUZ DONGU: her donguk turu en az bir kare ([enAzTur]) bekliyor,
/// yani beklemesiz "surekli tekrarla" uygulamayi dondurmuyor. Toplam
/// komut sayisi [butce] ile sinirli; dolunca [UnoBitis.butceBitti].
///
/// Testler [uyku] ile sahte bir saat verebiliyor: o zaman hicbir sey
/// gercekten beklemiyor ve calistirma aninda (butceye kadar) bitiyor.
class UnoYorumlayici {
  UnoYorumlayici({
    required this.kart,
    this.zamanOlcegi = 1.0,
    this.butce = 20000,
    this.enAzTur = const Duration(milliseconds: 16),
    this.enUzunBekleme = const Duration(seconds: 5),
    Future<void> Function(Duration)? uyku,
    this.onBlok,
  }) : _disUyku = uyku;

  final UnoKarti kart;

  /// 1 = gercek zaman; 0.5 = iki kat hizli.
  final double zamanOlcegi;

  /// En fazla kac blok calistirilir.
  final int butce;

  /// Bir dongu turunun en kisa suresi (beklemesiz dongu de nefes alsin).
  final Duration enAzTur;

  /// Tek bir "bekle" en fazla bu kadar surer (cocuk 1000 yazdiysa ekran
  /// 16 dakika donmasin).
  final Duration enUzunBekleme;

  final Future<void> Function(Duration)? _disUyku;

  /// Calisan her blokta (ekran o blogu gosterebilsin).
  final void Function(MBlockBlok blok)? onBlok;

  bool _durdu = false;
  int _adim = 0;
  Timer? _zamanlayici;
  Completer<void>? _bekleyen;

  /// Kac blok calisti.
  int get adimSayisi => _adim;

  bool get durduruldu => _durdu;

  /// Calistirmayi keser (bekleyen zamanlayici dahil).
  void durdur() {
    _durdu = true;
    _zamanlayici?.cancel();
    _zamanlayici = null;
    final b = _bekleyen;
    _bekleyen = null;
    if (b != null && !b.isCompleted) b.complete();
  }

  Future<void> _uyu(Duration d) {
    final dis = _disUyku;
    if (dis != null) return dis(d);
    final c = Completer<void>();
    _bekleyen = c;
    _zamanlayici = Timer(d, () {
      if (!c.isCompleted) c.complete();
    });
    return c.future;
  }

  /// Programi calistirir. Yalnizca "Arduino Uno baslatildiginda" ile
  /// baslayan yigin(lar) calisiyor; mBlock'ta da kopuk bloklar calismaz.
  Future<UnoBitis> calistir(List<List<MBlockBlok>> yiginlar) async {
    final baslayanlar = yiginlar
        .where((y) => y.isNotEmpty && y.first.tip == 'dev_kart_acilis')
        .toList();
    if (baslayanlar.isEmpty) return UnoBitis.baslangicYok;
    kart.sifirla();
    try {
      // Birden fazla baslangic yigini sirayla calisiyor (mBlock'ta
      // ayni anda; derslerde tek yigin var).
      for (final y in baslayanlar) {
        await _dizi(y);
      }
    } on _Dur catch (d) {
      return d.butce ? UnoBitis.butceBitti : UnoBitis.durduruldu;
    }
    return _durdu ? UnoBitis.durduruldu : UnoBitis.bitti;
  }

  void _say() {
    if (_durdu) throw const _Dur(false);
    if (++_adim > butce) throw const _Dur(true);
  }

  Future<void> _dizi(List<MBlockBlok> bloklar) async {
    for (final b in bloklar) {
      await _blok(b);
    }
  }

  Future<void> _tur(List<MBlockBlok> govde) async {
    // Tur da bir adim sayiliyor: bos govdeli "surekli tekrarla" da
    // butceye takiliyor.
    _say();
    await _dizi(govde);
    // Her tur bir kare bekliyor: beklemesiz dongu ekrani dondurmasin.
    await _uyu(_olcekli(enAzTur));
    if (_durdu) throw const _Dur(false);
  }

  Duration _olcekli(Duration d) =>
      Duration(microseconds: (d.inMicroseconds * zamanOlcegi).round());

  Future<void> _blok(MBlockBlok b) async {
    _say();
    onBlok?.call(b);
    switch (b.tip) {
      case 'dev_dijital_yaz':
        kart.dijitalYaz(_tam(b, 'PIN', 13), b.alanlar['SEVIYE'] != 'LOW');
      case 'dev_pwm_yaz':
        kart.pwmYaz(_tam(b, 'PIN', 5), _sayi(b, 'GUC').round());
      case 'dev_servo':
        kart.servoYaz(_tam(b, 'PIN', 9), _sayi(b, 'ACI').round());
      case 'dev_seri_yaz':
        kart.seriYaz(_metin(b, 'METIN'));
      case 'dev_degisken_yap':
        kart.degiskenler[b.alanlar['AD'] ?? 'parlaklik'] = _sayi(b, 'DEGER');
      case 'dev_degisken_degistir':
        final ad = b.alanlar['AD'] ?? '?';
        kart.degiskenler[ad] = (kart.degiskenler[ad] ?? 0) + _sayi(b, 'DEGER');
      case 'dev_bekle':
        final sn = _sayi(b, 'SANIYE').toDouble();
        final d = Duration(microseconds: (sn * 1e6).round());
        await _uyu(_olcekli(d > enUzunBekleme ? enUzunBekleme : d));
        if (_durdu) throw const _Dur(false);
      case 'dev_tekrarla':
        final n = _sayi(b, 'KERE').round();
        for (var i = 0; i < n; i++) {
          await _tur(b.icerik);
        }
      case 'dev_surekli':
        while (true) {
          await _tur(b.icerik);
        }
      case 'dev_eger':
        if (_kosul(b.girdiler['KOSUL'])) await _dizi(b.icerik);
      default:
        // Kukla bloklari ve olaylar kartta bir sey yapmiyor.
        break;
    }
  }

  int _tam(MBlockBlok b, String yuva, int varsayilan) =>
      int.tryParse(b.alanlar[yuva] ?? '') ?? varsayilan;

  /// Bir yuvanin sayi degeri: takili blok varsa onun degeri, yoksa
  /// kutudaki sayi.
  num _sayi(MBlockBlok b, String yuva) {
    final ic = b.girdiler[yuva];
    if (ic != null) return _deger(ic);
    return num.tryParse(b.alanlar[yuva] ?? '') ??
        num.tryParse(mblockVarsayilanAlanlar[b.tip]?[yuva] ?? '') ??
        0;
  }

  String _metin(MBlockBlok b, String yuva) {
    final ic = b.girdiler[yuva];
    if (ic != null) {
      final v = _deger(ic);
      return v % 1 == 0 ? '${v.toInt()}' : v.toStringAsFixed(2);
    }
    return b.alanlar[yuva] ?? '';
  }

  /// Oval (deger) bloklarin degeri.
  num _deger(MBlockBlok b) {
    switch (b.tip) {
      case 'dev_analog_oku':
        return kart.analogOku(_tam(b, 'PIN', 0));
      case 'dev_mesafe':
        return kart.mesafe;
      case 'dev_degisken_oku':
        return kart.degiskenler['parlaklik'] ?? 0;
      case 'dev_dijital_oku':
        return kart.dijitalOku(_tam(b, 'PIN', 2)) ? 1 : 0;
      case 'dev_harita':
        return harita(_sayi(b, 'DEGER'), _sayi(b, 'A'), _sayi(b, 'B'),
            _sayi(b, 'C'), _sayi(b, 'D'));
      default:
        return 0;
    }
  }

  /// Altigen (kosul) bloklarin degeri. Bos yuva YANLIS (mBlock'ta da).
  bool _kosul(MBlockBlok? b) {
    if (b == null) return false;
    switch (b.tip) {
      case 'dev_dijital_oku':
        return kart.dijitalOku(_tam(b, 'PIN', 2));
      case 'dev_degil':
        return !_kosul(b.girdiler['KOSUL']);
      default:
        return false;
    }
  }

  /// Arduino'nun `map()` islevi: tam sayi aritmetigiyle (kesir atilir).
  static int harita(num x, num a, num b, num c, num d) {
    if (b == a) return c.toInt();
    return ((x - a) * (d - c) / (b - a) + c).truncate();
  }

  /// Programin kullandigi parcalar (kartin cevresinde ne cizilecek).
  static UnoParcalari parcalar(List<List<MBlockBlok>> yiginlar) {
    final ledler = <int>{};
    final servolar = <int>{};
    var buton = false, pot = false, mesafe = false, seri = false;
    void gez(MBlockBlok b) {
      switch (b.tip) {
        case 'dev_dijital_yaz':
        case 'dev_pwm_yaz':
          final p = int.tryParse(b.alanlar['PIN'] ?? '');
          if (p != null) ledler.add(p);
        case 'dev_servo':
          final p = int.tryParse(b.alanlar['PIN'] ?? '');
          if (p != null) servolar.add(p);
        case 'dev_dijital_oku':
          if (b.alanlar['PIN'] == '${UnoKarti.butonPini}') buton = true;
        case 'dev_analog_oku':
          pot = true;
        case 'dev_mesafe':
          mesafe = true;
        case 'dev_seri_yaz':
          seri = true;
      }
      b.icerik.forEach(gez);
      b.girdiler.values.forEach(gez);
    }

    for (final y in yiginlar) {
      y.forEach(gez);
    }
    return UnoParcalari(
      ledler: (ledler..remove(UnoKarti.buzzerPini)).toList()..sort(),
      buzzer: yiginlar.any((y) => y.any((b) => _pinVar(b, UnoKarti.buzzerPini))),
      servolar: servolar.toList()..sort(),
      buton: buton,
      pot: pot,
      mesafe: mesafe,
      seri: seri,
    );
  }

  static bool _pinVar(MBlockBlok b, int pin) =>
      (b.tip == 'dev_dijital_yaz' && b.alanlar['PIN'] == '$pin') ||
      b.icerik.any((x) => _pinVar(x, pin));
}

/// Kartin cevresinde cizilecek parcalar.
class UnoParcalari {
  const UnoParcalari({
    this.ledler = const [],
    this.buzzer = false,
    this.servolar = const [],
    this.buton = false,
    this.pot = false,
    this.mesafe = false,
    this.seri = false,
  });

  /// LED baglanan pinler. Pin 13 kartin uzerindeki "L" ledi; harici LED
  /// olarak da ayrica ciziliyor.
  final List<int> ledler;
  final bool buzzer;
  final List<int> servolar;
  final bool buton;
  final bool pot;
  final bool mesafe;
  final bool seri;

  int get parcaSayisi =>
      ledler.length +
      servolar.length +
      (buzzer ? 1 : 0) +
      (buton ? 1 : 0);

  @override
  String toString() =>
      'UnoParcalari(led: $ledler, servo: $servolar, buzzer: $buzzer, '
      'buton: $buton, pot: $pot, mesafe: $mesafe, seri: $seri)';
}

class _Dur implements Exception {
  const _Dur(this.butce);
  final bool butce;
}

/// Kart programlarinin "en kucuk" ornek degeri: bos tahtada, sahne bos
/// kalmasin diye gosterilecek parcalar (pin 13 ledi).
const UnoParcalari bosUnoParcalari = UnoParcalari(ledler: [13]);
