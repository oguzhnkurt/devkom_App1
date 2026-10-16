/// SANAL DEVRE — Arduino Uno, breadboard, parcalar ve kablolar.
///
/// Arduino kursunun devre kurma adimlari ve Arduino Atolyesi bu modeli
/// kullaniyor. Saf Dart: cizim (`devre_cizimi.dart`) ve duzenleyici
/// (`devre_duzenleyici.dart`) yalnizca bunu gosteriyor ve degistiriyor;
/// "LED yanar mi, buton okunur mu" sorusunun cevabi burada ve
/// WebView'siz, ekransiz sinanabiliyor.
///
/// UCLAR
/// -----
/// Bir kablonun takilabildigi her yer bir "uc" ve bir dizeyle aniliyor:
///
///  * breadboard deligi: `a1` .. `j30` (satir harfi + sutun),
///  * guc hatlari: `U-3`, `U+3` (ustteki eksi/arti), `L-3`, `L+3`
///    (alttaki); her altinci sutunda delik yok (5'li gruplar),
///  * Uno pinleri: `D0`..`D13`, `A0`..`A5`, `5V`, `3V3`, `VIN`,
///    `GND` (dijital basligin yanindaki), `GND1`, `GND2` (guc basligi),
///  * kart disindaki parcalarin (servo) uclari: `<parca>.<bacak>`.
///
/// BAGLANTI
/// --------
/// Gercek breadboard gibi: a-e satirlari bir sutunda birbirine bagli,
/// f-j satirlari da; ortadaki kanal ikisini ayiriyor. Guc hatlari
/// boydan boya bagli. Butun GND pinleri ayni.
///
/// ANALIZ
/// ------
/// Bir SPICE degil; cocugun yapacagi hatalari dogru yakalayan kucuk bir
/// cozumleyici ([devreyiCoz]):
///  * Dogrudan suruculer: 5V/3V3 (guc), GND, cikis pinleri (yuksek /
///    dusuk / PWM / ton), calisan sicaklik sensorunun cikisi.
///  * Surulmeyen bir dugum, direnc (direnc, LDR, potansiyometre) ile
///    surulen dugumlere bagliysa gerilim bolucu gibi cozuluyor: cekme
///    direnci, LDR + direnc, potansiyometrenin orta ucu.
///  * LED ve buzzer ileri yonde (+ yuksek, - dusuk) calisiyor; arada
///    direnc yoksa uyari, ters takilmissa uyari.
///  * 5V ile GND ayni dugumdeyse KISA DEVRE.
library;

import 'dart:convert';
import 'dart:math' as math;

// ---------------------------------------------------------------------
// Uclar
// ---------------------------------------------------------------------

/// Breadboard satir harfleri; indeks 0 = `a` (en altta), 9 = `j`.
const String devreSatirlari = 'abcdefghij';

/// Breadboard sutun sayisi.
const int devreSutunSayisi = 30;

/// Guc hattinda bu sutunda delik var mi (her 6. sutunda bosluk).
bool rayDeligiVar(int sutun) => sutun % 6 != 0;

/// Breadboard deliginin kimligi: `satirHarfi + sutun`.
String delik(String satir, int sutun) => '$satir$sutun';

/// Uno'nun kablo takilabilen pinleri (cizim sirasi onemli degil).
const List<String> unoPinleri = [
  'D0', 'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', //
  'D8', 'D9', 'D10', 'D11', 'D12', 'D13', //
  'A0', 'A1', 'A2', 'A3', 'A4', 'A5', //
  '5V', '3V3', 'VIN', 'GND', 'GND1', 'GND2',
];

final RegExp _delikDeseni = RegExp(r'^([a-j])([0-9]{1,2})$');
final RegExp _rayDeseni = RegExp(r'^([UL])([+-])([0-9]{1,2})$');

/// Bir delik ucunun (satir indeksi, sutun) cifti; delik degilse null.
(int, int)? delikCoz(String uc) {
  final m = _delikDeseni.firstMatch(uc);
  if (m == null) return null;
  final s = int.parse(m.group(2)!);
  if (s < 1 || s > devreSutunSayisi) return null;
  return (devreSatirlari.indexOf(m.group(1)!), s);
}

/// Ray ucunun (ust mu, arti mi, sutun) ucluleri; ray degilse null.
(bool, bool, int)? rayCoz(String uc) {
  final m = _rayDeseni.firstMatch(uc);
  if (m == null) return null;
  final s = int.parse(m.group(3)!);
  if (s < 1 || s > devreSutunSayisi || !rayDeligiVar(s)) return null;
  return (m.group(1) == 'U', m.group(2) == '+', s);
}

bool unoPiniMi(String uc) => unoPinleri.contains(uc);

/// Uc gecerli mi (delik, ray deligi, Uno pini ya da parca ucu).
bool gecerliUc(String uc) =>
    delikCoz(uc) != null ||
    rayCoz(uc) != null ||
    unoPiniMi(uc) ||
    uc.contains('.');

/// Ucun "kendiliginden" bagli oldugu grup: ayni serit, ayni ray, GND.
String temelDugum(String uc) {
  final d = delikCoz(uc);
  if (d != null) return 'S${d.$2}${d.$1 < 5 ? 'a' : 'f'}';
  final r = rayCoz(uc);
  if (r != null) return '${r.$1 ? 'U' : 'L'}${r.$2 ? '+' : '-'}';
  if (uc.startsWith('GND')) return 'GND';
  return uc;
}

/// Pin ucundan dijital pin numarasi (`D7` -> 7).
int? dijitalPinNo(String uc) =>
    uc.startsWith('D') ? int.tryParse(uc.substring(1)) : null;

/// Pin ucundan analog pin numarasi (`A2` -> 2).
int? analogPinNo(String uc) =>
    uc.startsWith('A') && uc.length == 2 ? int.tryParse(uc.substring(1)) : null;

// ---------------------------------------------------------------------
// Parcalar
// ---------------------------------------------------------------------

enum ParcaTuru {
  led,
  direnc,
  buton,
  pot,
  buzzer,
  ldr,
  sicaklik,
  mesafe,
  servo;

  /// Breadboard'a takilmiyor; uclari kendi ustunde (servo).
  bool get kartDisi => this == servo;

  /// Bacak adlari.
  List<String> get bacaklar => switch (this) {
        led => const ['anot', 'katot'],
        direnc => const ['u1', 'u2'],
        buton => const ['a1', 'a2', 'b1', 'b2'],
        pot => const ['u1', 'orta', 'u2'],
        buzzer => const ['arti', 'eksi'],
        ldr => const ['u1', 'u2'],
        sicaklik => const ['vcc', 'cikis', 'gnd'],
        mesafe => const ['vcc', 'trig', 'echo', 'gnd'],
        servo => const ['gnd', 'vcc', 'sinyal'],
      };
}

/// LED renkleri.
enum LedRengi { kirmizi, sari, yesil, mavi, beyaz }

/// Breadboard'a ya da yanina konmus bir parca.
///
/// Konum bir CAPA delik: [sutun] ve [satir] (0 = `a`). Bacaklar capaya
/// gore sabit araliklarla diziliyor ([bacakUclari]); [ters] bacaklari
/// tersine ceviriyor (LED'i ters takmak boyle), [dikey] direnci kanalin
/// ustunden dik koyuyor.
class Parca {
  const Parca({
    required this.id,
    required this.tur,
    this.sutun = 1,
    this.satir = 0,
    this.ters = false,
    this.dikey = false,
    this.renk = LedRengi.kirmizi,
    this.ohm = 220,
  });

  final String id;
  final ParcaTuru tur;
  final int sutun;
  final int satir;
  final bool ters;
  final bool dikey;
  final LedRengi renk;
  final int ohm;

  /// Kolay yazim: `Parca.led('L1', 'b12')`.
  factory Parca.led(String id, String capa,
          {LedRengi renk = LedRengi.kirmizi, bool ters = false}) =>
      _capali(id, ParcaTuru.led, capa, renk: renk, ters: ters);
  factory Parca.direnc(String id, String capa,
          {int ohm = 220, bool dikey = false}) =>
      _capali(id, ParcaTuru.direnc, capa, ohm: ohm, dikey: dikey);
  factory Parca.buton(String id, String capa) =>
      _capali(id, ParcaTuru.buton, capa);
  factory Parca.pot(String id, String capa) => _capali(id, ParcaTuru.pot, capa);
  factory Parca.buzzer(String id, String capa) =>
      _capali(id, ParcaTuru.buzzer, capa);
  factory Parca.ldr(String id, String capa) => _capali(id, ParcaTuru.ldr, capa);
  factory Parca.sicaklik(String id, String capa) =>
      _capali(id, ParcaTuru.sicaklik, capa);
  factory Parca.mesafe(String id, String capa) =>
      _capali(id, ParcaTuru.mesafe, capa);

  /// Servo kartin altindaki alanda; [yer] kacinci servo yuvasi.
  factory Parca.servo(String id, {int yer = 0}) =>
      Parca(id: id, tur: ParcaTuru.servo, sutun: yer);

  static Parca _capali(String id, ParcaTuru tur, String capa,
      {LedRengi renk = LedRengi.kirmizi,
      bool ters = false,
      bool dikey = false,
      int ohm = 220}) {
    final d = delikCoz(capa);
    if (d == null) throw ArgumentError('Gecersiz capa: $capa');
    return Parca(
        id: id,
        tur: tur,
        satir: d.$1,
        sutun: d.$2,
        renk: renk,
        ters: ters,
        dikey: dikey,
        ohm: ohm);
  }

  Parca kopya({
    int? sutun,
    int? satir,
    bool? ters,
    bool? dikey,
    LedRengi? renk,
    int? ohm,
    String? id,
  }) =>
      Parca(
        id: id ?? this.id,
        tur: tur,
        sutun: sutun ?? this.sutun,
        satir: satir ?? this.satir,
        ters: ters ?? this.ters,
        dikey: dikey ?? this.dikey,
        renk: renk ?? this.renk,
        ohm: ohm ?? this.ohm,
      );

  /// Bacaklarin capaya gore (sutun, satir) kaymalari, bacak sirasiyla.
  List<(int, int)> get _kaymalar {
    switch (tur) {
      case ParcaTuru.led:
        return ters ? const [(1, 0), (0, 0)] : const [(0, 0), (1, 0)];
      case ParcaTuru.direnc:
        return dikey ? const [(0, 0), (0, 3)] : const [(0, 0), (3, 0)];
      case ParcaTuru.buton:
        return const [(0, 0), (0, 1), (2, 0), (2, 1)];
      case ParcaTuru.pot:
        return ters ? const [(2, 0), (1, 0), (0, 0)] : const [(0, 0), (1, 0), (2, 0)];
      case ParcaTuru.buzzer:
        return ters ? const [(3, 0), (0, 0)] : const [(0, 0), (3, 0)];
      case ParcaTuru.ldr:
        return const [(0, 0), (2, 0)];
      case ParcaTuru.sicaklik:
        return ters ? const [(2, 0), (1, 0), (0, 0)] : const [(0, 0), (1, 0), (2, 0)];
      case ParcaTuru.mesafe:
        return const [(0, 0), (1, 0), (2, 0), (3, 0)];
      case ParcaTuru.servo:
        return const [];
    }
  }

  /// Bacak adi -> uc. Kart disi parcalarda uc `<id>.<bacak>`.
  /// Breadboard disina tasan bacak null.
  Map<String, String?> get bacakUclari {
    if (tur.kartDisi) {
      return {for (final b in tur.bacaklar) b: '$id.$b'};
    }
    final k = _kaymalar;
    final m = <String, String?>{};
    for (var i = 0; i < tur.bacaklar.length; i++) {
      final s = sutun + k[i].$1;
      final r = satir + k[i].$2;
      m[tur.bacaklar[i]] =
          s >= 1 && s <= devreSutunSayisi && r >= 0 && r < 10
              ? delik(devreSatirlari[r], s)
              : null;
    }
    return m;
  }

  /// Butun bacaklar breadboard'un icinde mi.
  bool get yerlesimGecerli =>
      tur.kartDisi || bacakUclari.values.every((u) => u != null);

  Map<String, dynamic> toJson() => {
        'id': id,
        'tur': tur.name,
        's': sutun,
        'r': satir,
        if (ters) 't': true,
        if (dikey) 'd': true,
        if (tur == ParcaTuru.led) 'renk': renk.name,
        if (tur == ParcaTuru.direnc) 'ohm': ohm,
      };

  static Parca? fromJson(Map<String, dynamic> j) {
    final tur = ParcaTuru.values.where((t) => t.name == j['tur']).firstOrNull;
    if (tur == null) return null;
    return Parca(
      id: '${j['id']}',
      tur: tur,
      sutun: (j['s'] as num?)?.toInt() ?? 1,
      satir: (j['r'] as num?)?.toInt() ?? 0,
      ters: j['t'] == true,
      dikey: j['d'] == true,
      renk: LedRengi.values.where((r) => r.name == j['renk']).firstOrNull ??
          LedRengi.kirmizi,
      ohm: (j['ohm'] as num?)?.toInt() ?? 220,
    );
  }

  @override
  String toString() => '$tur($id @${devreSatirlari[satir.clamp(0, 9)]}$sutun)';
}

/// Iki ucu birlestiren kablo.
class Kablo {
  const Kablo(this.a, this.b, {this.renk});

  final String a;
  final String b;

  /// Kablo rengi (ARGB); null ise uclardan secilir ([kabloRengi]).
  final int? renk;

  Map<String, dynamic> toJson() => {
        'a': a,
        'b': b,
        if (renk != null) 'renk': renk,
      };

  static Kablo? fromJson(Map<String, dynamic> j) {
    final a = j['a'], b = j['b'];
    if (a is! String || b is! String) return null;
    return Kablo(a, b, renk: (j['renk'] as num?)?.toInt());
  }

  @override
  bool operator ==(Object other) =>
      other is Kablo &&
      ((other.a == a && other.b == b) || (other.a == b && other.b == a));

  @override
  int get hashCode => a.hashCode ^ b.hashCode;

  @override
  String toString() => 'Kablo($a-$b)';
}

/// Kablonun ilk rengi: GND/eksi siyah, 5V/arti kirmizi, digerleri
/// sirayla sari, yesil, turuncu, mavi, mor.
int kabloRengi(Kablo k, int sira) {
  bool eksi(String u) => temelDugum(u) == 'GND' || u.contains('-');
  bool arti(String u) => u == '5V' || u == '3V3' || u.contains('+');
  if (eksi(k.a) || eksi(k.b)) return 0xFF2B2D31;
  if (arti(k.a) || arti(k.b)) return 0xFFE53935;
  const r = [0xFFF9A825, 0xFF2E9E4F, 0xFFF57C00, 0xFF1E6FD9, 0xFF8E44AD];
  return r[sira % r.length];
}

/// Bir devre: parcalar ve kablolar. Degismez; duzenleyici her
/// degisiklikte yeni bir [Devre] uretiyor.
class Devre {
  const Devre({this.parcalar = const [], this.kablolar = const []});

  final List<Parca> parcalar;
  final List<Kablo> kablolar;

  static const Devre bos = Devre();

  bool get bosMu => parcalar.isEmpty && kablolar.isEmpty;

  Parca? parca(String id) => parcalar.where((p) => p.id == id).firstOrNull;

  Devre parcaEkle(Parca p) => Devre(parcalar: [...parcalar, p], kablolar: kablolar);

  Devre parcaDegistir(Parca p) => Devre(
      parcalar: [for (final x in parcalar) x.id == p.id ? p : x],
      kablolar: kablolar);

  /// Parcayi ve (kart disi parcaysa) uclarina takili kablolari siler.
  Devre parcaSil(String id) => Devre(
        parcalar: parcalar.where((p) => p.id != id).toList(),
        kablolar: kablolar
            .where((k) => !k.a.startsWith('$id.') && !k.b.startsWith('$id.'))
            .toList(),
      );

  Devre kabloEkle(Kablo k) => Devre(parcalar: parcalar, kablolar: [...kablolar, k]);

  Devre kabloSil(int i) => Devre(
      parcalar: parcalar,
      kablolar: [for (var j = 0; j < kablolar.length; j++) if (j != i) kablolar[j]]);

  Devre kabloDegistir(int i, Kablo k) => Devre(
      parcalar: parcalar,
      kablolar: [for (var j = 0; j < kablolar.length; j++) j == i ? k : kablolar[j]]);

  /// Yeni bir parca kimligi: `<onek><n>`.
  String yeniKimlik(String onek) {
    var n = 1;
    while (parcalar.any((p) => p.id == '$onek$n')) {
      n++;
    }
    return '$onek$n';
  }

  /// Breadboard deliklerinden hangisi kimde (parca bacagi ya da kablo).
  Map<String, String> get doluDelikler {
    final m = <String, String>{};
    for (final p in parcalar) {
      for (final u in p.bacakUclari.values) {
        if (u != null) m[u] = p.id;
      }
    }
    for (var i = 0; i < kablolar.length; i++) {
      for (final u in [kablolar[i].a, kablolar[i].b]) {
        if (delikCoz(u) != null || rayCoz(u) != null) m[u] = 'k$i';
      }
    }
    return m;
  }

  /// Parca [p] (yeni ya da tasinan) buraya konabilir mi: butun bacaklar
  /// breadboard'da ve hicbiri baskasinin deliginde degil.
  bool yerlesebilir(Parca p) {
    if (!p.yerlesimGecerli) return false;
    if (p.tur.kartDisi) return true;
    final dolu = doluDelikler;
    for (final u in p.bacakUclari.values) {
      final kim = dolu[u!];
      if (kim != null && kim != p.id) return false;
    }
    return true;
  }

  /// Bir uca kablo takilabilir mi (delik bossa; Uno pinleri ve parca
  /// uclari birden fazla kablo alabiliyor).
  bool kabloTakilabilir(String uc) {
    if (!gecerliUc(uc)) return false;
    if (delikCoz(uc) == null && rayCoz(uc) == null) return true;
    return !doluDelikler.containsKey(uc);
  }

  Map<String, dynamic> toJson() => {
        'parcalar': [for (final p in parcalar) p.toJson()],
        'kablolar': [for (final k in kablolar) k.toJson()],
      };

  String kodla() => jsonEncode(toJson());

  static Devre fromJson(Map<String, dynamic> j) => Devre(
        parcalar: [
          for (final p in (j['parcalar'] as List? ?? const []))
            if (p is Map) Parca.fromJson(p.cast<String, dynamic>()),
        ].whereType<Parca>().toList(),
        kablolar: [
          for (final k in (j['kablolar'] as List? ?? const []))
            if (k is Map) Kablo.fromJson(k.cast<String, dynamic>()),
        ].whereType<Kablo>().toList(),
      );

  static Devre coz(String s) {
    try {
      final j = jsonDecode(s);
      if (j is Map) return fromJson(j.cast<String, dynamic>());
    } catch (_) {}
    return bos;
  }

  @override
  String toString() => 'Devre($parcalar, $kablolar)';
}

// ---------------------------------------------------------------------
// Baglanti (union-find)
// ---------------------------------------------------------------------

/// Uclarin hangi dugume (elektriksel olarak ayni noktaya) ait oldugu.
class DevreDugumleri {
  DevreDugumleri._();

  final Map<String, String> _ata = {};

  String bul(String x) {
    var k = _ata[x] ?? x;
    if (k == x) return x;
    k = bul(k);
    _ata[x] = k;
    return k;
  }

  void birlestir(String a, String b) {
    final x = bul(a), y = bul(b);
    if (x != y) _ata[x] = y;
  }

  /// Ucun dugumu.
  String dugum(String uc) => bul(temelDugum(uc));

  bool bagli(String a, String b) => dugum(a) == dugum(b);

  /// [devre]nin dugumleri; [basililar] basili butonlar.
  static DevreDugumleri kur(Devre devre, {Set<String> basililar = const {}}) {
    final d = DevreDugumleri._();
    for (final k in devre.kablolar) {
      d.birlestir(temelDugum(k.a), temelDugum(k.b));
    }
    for (final p in devre.parcalar) {
      if (p.tur != ParcaTuru.buton) continue;
      final u = p.bacakUclari;
      if (u.values.any((x) => x == null)) continue;
      d.birlestir(temelDugum(u['a1']!), temelDugum(u['a2']!));
      d.birlestir(temelDugum(u['b1']!), temelDugum(u['b2']!));
      if (basililar.contains(p.id)) {
        d.birlestir(temelDugum(u['a1']!), temelDugum(u['b1']!));
      }
    }
    return d;
  }
}

// ---------------------------------------------------------------------
// Analiz
// ---------------------------------------------------------------------

/// Programin kart uzerindeki cikislari (sanal Uno'dan).
class DevreCikislari {
  const DevreCikislari({
    this.dijital = const {},
    this.pwm = const {},
    this.servo = const {},
    this.ton = const {},
  });

  /// Dijital cikis yapilan pinler: yuksek mi.
  final Map<int, bool> dijital;

  /// PWM cikislari (0-255).
  final Map<int, int> pwm;

  /// Servo sinyali (aci).
  final Map<int, int> servo;

  /// Ton calan pinler (Hz).
  final Map<int, int> ton;

  bool cikisMi(int pin) =>
      dijital.containsKey(pin) ||
      pwm.containsKey(pin) ||
      servo.containsKey(pin) ||
      (ton[pin] ?? 0) > 0;
}

/// Cocugun parmagindan gelen girdiler.
class DevreGirdileri {
  const DevreGirdileri({
    this.basililar = const {},
    this.potlar = const {},
    this.isik = 70,
    this.sicaklik = 24,
    this.mesafe = 40,
  });

  /// Basili butonlarin kimlikleri.
  final Set<String> basililar;

  /// Potansiyometre konumlari (0..1); yazilmayan 0.5.
  final Map<String, double> potlar;

  /// Ortam isigi, yuzde (LDR).
  final double isik;

  /// Ortam sicakligi, derece (sicaklik sensoru).
  final double sicaklik;

  /// Mesafe sensorunun onundeki engel, cm.
  final int mesafe;

  double pot(String id) => potlar[id] ?? 0.5;
}

enum DevreUyariTuru {
  /// 5V (ya da yuksek pin) ile GND ayni dugumde.
  kisaDevre,

  /// LED'in iki bacagi ayni dugumde: hic yanmaz.
  ledAyniDugum,

  /// LED ters takili: uzun bacak (+) dusuk tarafta.
  ledTers,

  /// LED direncsiz baglanmis: gercekte yanar ve bozulur.
  ledDirencsiz,

  /// Buzzer ters.
  buzzerTers,

  /// Servonun guc uclari eksik.
  servoGucsuz,

  /// Sensorun (sicaklik, mesafe) VCC / GND uclari eksik.
  sensorGucsuz,

  /// Okunan pin bos: hicbir yere bagli degil.
  pinBosta,

  /// Mesafe sensorunun trig/echo uclari koddaki pinlere bagli degil.
  mesafePinleri,
}

class DevreUyarisi {
  const DevreUyarisi(this.tur, {this.parca, this.pin});
  final DevreUyariTuru tur;
  final String? parca;
  final String? pin;

  @override
  bool operator ==(Object other) =>
      other is DevreUyarisi &&
      other.tur == tur &&
      other.parca == parca &&
      other.pin == pin;

  @override
  int get hashCode => Object.hash(tur, parca, pin);

  @override
  String toString() => 'Uyari($tur${parca == null ? '' : ' $parca'}'
      '${pin == null ? '' : ' $pin'})';
}

/// Bir dugumun dogrudan surulme hali.
class _Surucu {
  _Surucu(this.seviye, this.parlaklik, this.tur);

  /// 0..1 (5V'un kesri).
  double seviye;

  /// LED'in goreceli parlakligi (PWM, ton).
  double parlaklik;

  /// 'guc', 'gnd', 'pin', 'sensor'.
  String tur;
}

/// Direnc gibi davranan iki uclu bir baglanti.
class _Direncli {
  _Direncli(this.a, this.b, this.ohm);
  final String a; // dugum
  final String b;
  final double ohm;
}

/// Analizin sonucu.
class DevreSonucu {
  DevreSonucu._(this.dugumler);

  final DevreDugumleri dugumler;

  /// LED parcalari: parlaklik 0..1.
  final Map<String, double> ledler = {};

  /// Buzzer parcalari: calan frekans (Hz), susuyorsa 0.
  final Map<String, int> buzzerlar = {};

  /// Servolar: aci; gucsuz ya da sinyalsizse null.
  final Map<String, int?> servolar = {};

  final List<DevreUyarisi> uyarilar = [];

  final Map<String, double?> _seviye = {};
  final Map<String, bool> _mesafeler = {};
  final Map<String, String> _mesafeBacaklari = {};
  int _mesafeCm = 0;

  /// Bir dugumun gerilimi (0..1); bossa null.
  double? seviye(String uc) => _seviye[dugumler.dugum(uc)];

  /// Dijital okuma: pin bos ise 0 (ve [DevreUyariTuru.pinBosta]).
  bool dijitalOku(int pin) => (seviye('D$pin') ?? 0) >= 0.5;

  /// Analog okuma (0..1023); bos pin 0.
  int analogOku(int pin) =>
      ((seviye('A$pin') ?? 0).clamp(0.0, 1.0) * 1023).round();

  /// Pin bir yere bagli mi (surulen ya da direncle cozulen dugum).
  bool pinBagli(String pin) => seviye(pin) != null;

  /// Mesafe sensoru: trig/echo pinleri verilen sensor dogru bagliysa
  /// engelin uzakligi, yoksa 0 (gercek kartta zaman asimi).
  int mesafe(int trig, int echo) {
    for (final e in _mesafeler.entries) {
      if (!e.value) continue;
      final b = _mesafeBacaklari;
      final t = b['${e.key}.trig'], ec = b['${e.key}.echo'];
      if (t != null &&
          ec != null &&
          dugumler.dugum(t) == dugumler.dugum('D$trig') &&
          dugumler.dugum(ec) == dugumler.dugum('D$echo')) {
        return _mesafeCm;
      }
    }
    return 0;
  }

  bool get kisaDevre => uyarilar.any((u) => u.tur == DevreUyariTuru.kisaDevre);
}

/// LDR direnci: aydinlikta ~1 kOhm, karanlikta ~100 kOhm.
double ldrOhm(double isikYuzde) =>
    1000 * math.pow(100, (100 - isikYuzde.clamp(0, 100)) / 100).toDouble();

/// Sicaklik sensorunun cikisi (TMP36): 0.5 V + 10 mV/derece; 5V'un kesri.
double sicaklikSeviyesi(double c) => ((0.5 + c / 100) / 5).clamp(0.0, 1.0);

/// [sicaklikSeviyesi]nin tersi: analog okumadan derece.
double analogdanSicaklik(num analog) => (analog * 5 / 1023 - 0.5) * 100;

/// Devreyi kartin cikislari ve cocugun girdileriyle cozer.
DevreSonucu devreyiCoz(
  Devre devre, {
  DevreCikislari cikislar = const DevreCikislari(),
  DevreGirdileri girdiler = const DevreGirdileri(),
}) {
  final d = DevreDugumleri.kur(devre, basililar: girdiler.basililar);
  final s = DevreSonucu._(d);
  s._mesafeCm = girdiler.mesafe;

  // 1) Dogrudan suruculer.
  final suruculer = <String, List<_Surucu>>{};
  void sur(String uc, _Surucu x) =>
      (suruculer[d.dugum(uc)] ??= []).add(x);
  sur('5V', _Surucu(1, 1, 'guc'));
  sur('3V3', _Surucu(0.66, 1, 'guc'));
  sur('GND', _Surucu(0, 0, 'gnd'));
  for (var pin = 0; pin <= 13; pin++) {
    final ton = cikislar.ton[pin] ?? 0;
    if (ton > 0) {
      sur('D$pin', _Surucu(1, 0.5, 'pin'));
    } else if (cikislar.pwm.containsKey(pin)) {
      // PWM: pin hizla yuksek/dusuk oluyor. LED icin parlaklik orani,
      // kisa devre ve yon icin "yuksek" sayiliyor (0 ise dusuk).
      final v = cikislar.pwm[pin]! / 255;
      sur('D$pin', _Surucu(v > 0 ? 1 : 0, v, 'pin'));
    } else if (cikislar.dijital.containsKey(pin)) {
      final y = cikislar.dijital[pin]!;
      sur('D$pin', _Surucu(y ? 1 : 0, y ? 1 : 0, 'pin'));
    } else if (cikislar.servo.containsKey(pin)) {
      // Servo sinyali kisa darbeler: LED'i hafifce yakar.
      sur('D$pin', _Surucu(1, 0.08, 'pin'));
    }
  }

  // Kisa devre: ayni dugumde yuksek ve dusuk iki surucu.
  final seviye = <String, double>{};
  final parlak = <String, double>{};
  final gucluDugum = <String>{};
  for (final e in suruculer.entries) {
    final l = e.value;
    final yuksek = l.where((x) => x.seviye > 0.4).toList();
    final dusuk = l.where((x) => x.seviye < 0.1).toList();
    if (yuksek.isNotEmpty && dusuk.isNotEmpty) {
      s.uyarilar.add(const DevreUyarisi(DevreUyariTuru.kisaDevre));
    }
    // Kisa devrede GND kazanir (kart sifirlanir gibi): her sey soner.
    final x = dusuk.isNotEmpty ? dusuk.first : l.first;
    seviye[e.key] = x.seviye;
    parlak[e.key] = x.parlaklik;
    if (l.any((y) => y.tur == 'guc')) gucluDugum.add(e.key);
  }
  final gndDugum = d.dugum('GND');
  final vDugum = d.dugum('5V');

  // 2) Sensorler: guclu sicaklik sensoru cikisini suruyor.
  for (final p in devre.parcalar) {
    final u = p.bacakUclari;
    if (u.values.any((x) => x == null)) continue;
    if (p.tur == ParcaTuru.sicaklik || p.tur == ParcaTuru.mesafe) {
      final vcc = d.dugum(u['vcc']!);
      final gnd = d.dugum(u['gnd']!);
      final guclu = (seviye[vcc] ?? 0) > 0.6 &&
          gucluDugum.contains(vcc) &&
          gnd == gndDugum;
      if (!guclu && (_dokunuyor(d, u['vcc']!, devre) ||
          _dokunuyor(d, u['gnd']!, devre))) {
        s.uyarilar.add(DevreUyarisi(DevreUyariTuru.sensorGucsuz, parca: p.id));
      }
      if (p.tur == ParcaTuru.sicaklik && guclu) {
        final c = d.dugum(u['cikis']!);
        if (!seviye.containsKey(c)) {
          seviye[c] = sicaklikSeviyesi(girdiler.sicaklik);
          parlak[c] = 0;
        }
      }
      if (p.tur == ParcaTuru.mesafe) {
        s._mesafeler[p.id] = guclu;
        s._mesafeBacaklari['${p.id}.trig'] = u['trig']!;
        s._mesafeBacaklari['${p.id}.echo'] = u['echo']!;
      }
    }
  }

  // 3) Direncli baglantilar (direnc, LDR, potansiyometre).
  final direncler = <_Direncli>[];
  for (final p in devre.parcalar) {
    final u = p.bacakUclari;
    if (u.values.any((x) => x == null)) continue;
    switch (p.tur) {
      case ParcaTuru.direnc:
        direncler.add(_Direncli(d.dugum(u['u1']!), d.dugum(u['u2']!),
            p.ohm.toDouble()));
      case ParcaTuru.ldr:
        direncler.add(_Direncli(
            d.dugum(u['u1']!), d.dugum(u['u2']!), ldrOhm(girdiler.isik)));
      case ParcaTuru.pot:
        final k = girdiler.pot(p.id).clamp(0.0, 1.0);
        const r = 10000.0;
        direncler.add(_Direncli(
            d.dugum(u['u1']!), d.dugum(u['orta']!), math.max(1, r * k)));
        direncler.add(_Direncli(
            d.dugum(u['orta']!), d.dugum(u['u2']!), math.max(1, r * (1 - k))));
      default:
        break;
    }
  }

  // Surulmeyen dugumleri direnclerden coz (iki tur: zincir bolucu).
  final cozulen = Map<String, double>.of(seviye);
  for (var tur = 0; tur < 2; tur++) {
    final yeni = <String, double>{};
    final adaylar = <String>{
      for (final r in direncler) ...[r.a, r.b]
    }.where((n) => !seviye.containsKey(n));
    for (final n in adaylar) {
      var g = 0.0, gv = 0.0;
      for (final r in direncler) {
        final diger = r.a == n ? r.b : (r.b == n ? r.a : null);
        if (diger == null || diger == n) continue;
        final v = cozulen[diger];
        if (v == null) continue;
        g += 1 / r.ohm;
        gv += v / r.ohm;
      }
      if (g > 0) yeni[n] = gv / g;
    }
    cozulen.addAll(yeni);
  }
  s._seviye.addAll(cozulen);

  // 4) LED ve buzzer.
  for (final p in devre.parcalar) {
    if (p.tur != ParcaTuru.led && p.tur != ParcaTuru.buzzer) continue;
    final u = p.bacakUclari;
    final arti = u[p.tur == ParcaTuru.led ? 'anot' : 'arti'];
    final eksi = u[p.tur == ParcaTuru.led ? 'katot' : 'eksi'];
    if (arti == null || eksi == null) continue;
    final a = d.dugum(arti), k = d.dugum(eksi);
    if (p.tur == ParcaTuru.led) s.ledler[p.id] = 0;
    if (p.tur == ParcaTuru.buzzer) s.buzzerlar[p.id] = 0;
    if (a == k) {
      if (p.tur == ParcaTuru.led &&
          (_dokunuyor(d, arti, devre) || seviye.containsKey(a))) {
        s.uyarilar.add(DevreUyarisi(DevreUyariTuru.ledAyniDugum, parca: p.id));
      }
      continue;
    }
    final ust = _yol(a, seviye, parlak, direncler);
    final alt = _yol(k, seviye, parlak, direncler);
    if (ust == null || alt == null) continue;
    final (va, pa, ra) = ust;
    final (vk, _, rk) = alt;
    if (va - vk > 0.3) {
      final ohm = ra + rk;
      if (p.tur == ParcaTuru.led) {
        // 220-470 ohm tam parlak; 10k cok sonuk.
        final f = ohm <= 0 ? 1.0 : (330 / ohm).clamp(0.18, 1.0);
        s.ledler[p.id] = (pa * f).clamp(0.0, 1.0);
        if (ohm <= 0) {
          s.uyarilar
              .add(DevreUyarisi(DevreUyariTuru.ledDirencsiz, parca: p.id));
        }
      } else {
        s.buzzerlar[p.id] = _buzzerFrekansi(d, cikislar, a, pa);
      }
    } else if (vk - va > 0.3) {
      s.uyarilar.add(DevreUyarisi(
          p.tur == ParcaTuru.led
              ? DevreUyariTuru.ledTers
              : DevreUyariTuru.buzzerTers,
          parca: p.id));
    }
  }

  // 5) Servolar.
  for (final p in devre.parcalar) {
    if (p.tur != ParcaTuru.servo) continue;
    final u = p.bacakUclari;
    final guclu = d.dugum(u['vcc']!) == vDugum &&
        d.dugum(u['gnd']!) == gndDugum;
    final sinyal = d.dugum(u['sinyal']!);
    int? aci;
    for (final e in cikislar.servo.entries) {
      if (d.dugum('D${e.key}') == sinyal) aci = e.value;
    }
    s.servolar[p.id] = guclu ? aci : null;
    if (!guclu && aci != null) {
      s.uyarilar.add(DevreUyarisi(DevreUyariTuru.servoGucsuz, parca: p.id));
    }
  }

  return s;
}

/// Bir LED bacaginin dugumunden bir surucuye giden yol: (seviye,
/// parlaklik, aradaki direnc). Dogrudan surulen dugum 0 ohm; tek bir
/// direncle surulen dugume bagli dugum o direncin ohm'u.
(double, double, double)? _yol(String n, Map<String, double> seviye,
    Map<String, double> parlak, List<_Direncli> direncler) {
  final v = seviye[n];
  if (v != null) return (v, parlak[n] ?? v, 0);
  (double, double, double)? en;
  for (final r in direncler) {
    final diger = r.a == n ? r.b : (r.b == n ? r.a : null);
    if (diger == null || diger == n) continue;
    final dv = seviye[diger];
    if (dv == null) continue;
    final aday = (dv, parlak[diger] ?? dv, r.ohm);
    // En guclu yol: yuksek tarafta en yuksek, alcak tarafta en alcak;
    // ikisini de "en kucuk direnc" ile secmek yeterli.
    if (en == null || aday.$3 < en.$3) en = aday;
  }
  return en;
}

int _buzzerFrekansi(
    DevreDugumleri d, DevreCikislari c, String artiDugum, double p) {
  for (final e in c.ton.entries) {
    if (e.value > 0 && d.dugum('D${e.key}') == artiDugum) return e.value;
  }
  // Dogrudan yuksek: aktif buzzer gibi sabit bir bip.
  return 1047;
}

/// Ucun dugumune kablo ya da baska bir parca dokunuyor mu (yalniz
/// birakilmis bir bacak icin uyari vermeyelim).
bool _dokunuyor(DevreDugumleri d, String uc, Devre devre) {
  final n = d.dugum(uc);
  for (final k in devre.kablolar) {
    if (d.dugum(k.a) == n || d.dugum(k.b) == n) return true;
  }
  return false;
}

// ---------------------------------------------------------------------
// Rehberli hedefler
// ---------------------------------------------------------------------

/// Rehberli kurulumda yapilacak bir baglanti: iki uc AYNI dugumde
/// olmali. Cocuk tam o deliklere degil, ayni seritteki herhangi bir
/// delige de baglayabilir; denetim dugume bakiyor.
class HedefBaglanti {
  const HedefBaglanti(
    this.a,
    this.b, {
    required this.tr,
    required this.en,
    required this.de,
    required this.es,
  });

  final String a;
  final String b;
  final String tr;
  final String en;
  final String de;
  final String es;

  String metin(String lang) => switch (lang) {
        'tr' => tr,
        'de' => de,
        'es' => es,
        _ => en,
      };

  bool tamamMi(DevreDugumleri d) => d.bagli(a, b);
}

/// Hedeflerin hangileri tamam (butonlar basili degilken).
List<bool> hedefDurumu(Devre devre, List<HedefBaglanti> hedefler) {
  final d = DevreDugumleri.kur(devre);
  return [for (final h in hedefler) h.tamamMi(d)];
}

/// Rehberli kurulum bitti mi: her hedef tamam ve kisa devre yok.
bool devreTamamMi(Devre devre, List<HedefBaglanti> hedefler) {
  if (!hedefDurumu(devre, hedefler).every((x) => x)) return false;
  return !devreyiCoz(devre).kisaDevre;
}
