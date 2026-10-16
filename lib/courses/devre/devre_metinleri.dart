import '../../utils/lang.dart';
import 'devre_modeli.dart';

/// Devre ekranlarinin dort dildeki yazilari.
String devreT(String lang, String tr, String en, String de, String es) =>
    AppLang.pick(lang, tr: tr, en: en, de: de, es: es);

String ledRengiAdi(LedRengi r, String lang) => switch (r) {
      LedRengi.kirmizi => devreT(lang, 'kırmızı', 'red', 'rot', 'roja'),
      LedRengi.sari => devreT(lang, 'sarı', 'yellow', 'gelb', 'amarilla'),
      LedRengi.yesil => devreT(lang, 'yeşil', 'green', 'grün', 'verde'),
      LedRengi.mavi => devreT(lang, 'mavi', 'blue', 'blau', 'azul'),
      LedRengi.beyaz => devreT(lang, 'beyaz', 'white', 'weiß', 'blanca'),
    };

String ohmYazisi(int ohm) =>
    ohm >= 1000 ? '${ohm ~/ 1000}${ohm % 1000 == 0 ? '' : '.${(ohm % 1000) ~/ 100}'}kΩ' : '$ohmΩ';

String parcaTuruAdi(ParcaTuru t, String lang) => switch (t) {
      ParcaTuru.led => 'LED',
      ParcaTuru.direnc => devreT(lang, 'Direnç', 'Resistor', 'Widerstand', 'Resistencia'),
      ParcaTuru.buton => devreT(lang, 'Buton', 'Push button', 'Taster', 'Pulsador'),
      ParcaTuru.pot => devreT(lang, 'Potansiyometre', 'Potentiometer', 'Potentiometer', 'Potenciómetro'),
      ParcaTuru.buzzer => 'Buzzer',
      ParcaTuru.ldr => devreT(lang, 'Işık sensörü (LDR)', 'Light sensor (LDR)', 'Lichtsensor (LDR)', 'Sensor de luz (LDR)'),
      ParcaTuru.sicaklik => devreT(lang, 'Sıcaklık sensörü', 'Temperature sensor', 'Temperatursensor', 'Sensor de temperatura'),
      ParcaTuru.mesafe => devreT(lang, 'Mesafe sensörü', 'Distance sensor', 'Abstandssensor', 'Sensor de distancia'),
      ParcaTuru.servo => devreT(lang, 'Servo motor', 'Servo motor', 'Servomotor', 'Servomotor'),
    };

/// Parcanin ekrandaki adi: "kırmızı LED", "Direnç 220Ω".
String parcaAdi(Parca p, String lang) => switch (p.tur) {
      ParcaTuru.led => devreT(lang, '${ledRengiAdi(p.renk, lang)} LED',
          '${ledRengiAdi(p.renk, lang)} LED', '${ledRengiAdi(p.renk, lang)}e LED',
          'LED ${ledRengiAdi(p.renk, lang)}'),
      ParcaTuru.direnc => '${parcaTuruAdi(p.tur, lang)} ${ohmYazisi(p.ohm)}',
      _ => parcaTuruAdi(p.tur, lang),
    };

/// Bacak adi: "uzun bacak (+)".
String bacakAdi(ParcaTuru t, String bacak, String lang) => switch ((t, bacak)) {
      (ParcaTuru.led, 'anot') => devreT(lang, 'uzun bacak (+)', 'long leg (+)', 'langes Bein (+)', 'pata larga (+)'),
      (ParcaTuru.led, 'katot') => devreT(lang, 'kısa bacak (−)', 'short leg (−)', 'kurzes Bein (−)', 'pata corta (−)'),
      (ParcaTuru.buzzer, 'arti') => devreT(lang, 'artı bacak (+)', 'plus leg (+)', 'Plus-Bein (+)', 'pata positiva (+)'),
      (ParcaTuru.buzzer, 'eksi') => devreT(lang, 'eksi bacak (−)', 'minus leg (−)', 'Minus-Bein (−)', 'pata negativa (−)'),
      (ParcaTuru.pot, 'orta') => devreT(lang, 'orta bacak', 'middle leg', 'mittleres Bein', 'pata central'),
      (_, 'vcc') => 'VCC (+5V)',
      (_, 'gnd') => 'GND',
      (_, 'cikis') => devreT(lang, 'çıkış', 'output', 'Ausgang', 'salida'),
      (_, 'trig') => 'TRIG',
      (_, 'echo') => 'ECHO',
      (_, 'sinyal') => devreT(lang, 'sinyal', 'signal', 'Signal', 'señal'),
      _ => devreT(lang, 'bacak', 'leg', 'Bein', 'pata'),
    };

/// Bir ucun okunur adi: "pin 13", "c12 deliği", "üstteki − hattı".
String ucAdi(String uc, String lang, [Devre? devre]) {
  final d = delikCoz(uc);
  if (d != null) {
    return devreT(lang, '$uc deliği', 'hole $uc', 'Loch $uc', 'agujero $uc');
  }
  final r = rayCoz(uc);
  if (r != null) {
    final isaret = r.$2 ? '+' : '−';
    return r.$1
        ? devreT(lang, 'üstteki $isaret hattı', 'top $isaret rail', 'obere $isaret-Schiene', 'línea $isaret superior')
        : devreT(lang, 'alttaki $isaret hattı', 'bottom $isaret rail', 'untere $isaret-Schiene', 'línea $isaret inferior');
  }
  if (uc.startsWith('GND')) return 'GND';
  final dp = dijitalPinNo(uc);
  if (dp != null) return devreT(lang, 'pin $dp', 'pin $dp', 'Pin $dp', 'pin $dp');
  if (analogPinNo(uc) != null) return devreT(lang, 'pin $uc', 'pin $uc', 'Pin $uc', 'pin $uc');
  if (uc == '5V' || uc == '3V3' || uc == 'VIN') return uc;
  final nokta = uc.indexOf('.');
  if (nokta > 0) {
    final p = devre?.parca(uc.substring(0, nokta));
    final b = uc.substring(nokta + 1);
    if (p != null) return '${parcaAdi(p, lang)} · ${bacakAdi(p.tur, b, lang)}';
  }
  return uc;
}

/// Uyari metni.
String uyariMetni(DevreUyarisi u, String lang, Devre devre) {
  final p = u.parca == null ? null : devre.parca(u.parca!);
  final ad = p == null ? '' : parcaAdi(p, lang);
  switch (u.tur) {
    case DevreUyariTuru.kisaDevre:
      return devreT(lang,
          'Kısa devre! 5V (ya da yüksek bir pin) doğrudan GND\'ye bağlı. Gerçek kart kendini kapatır.',
          'Short circuit! 5V (or a HIGH pin) goes straight to GND. A real board would shut down.',
          'Kurzschluss! 5V (oder ein HIGH-Pin) geht direkt an GND. Eine echte Platine schaltet ab.',
          '¡Cortocircuito! 5V (o un pin en alto) va directo a GND. Una placa real se apagaría.');
    case DevreUyariTuru.ledAyniDugum:
      return devreT(lang,
          '$ad: iki bacağı aynı sırada, akım LED\'e uğramadan geçiyor. Bacakları farklı sütunlara koy.',
          '$ad: both legs are in the same row strip, so current skips the LED. Put the legs in different columns.',
          '$ad: Beide Beine stecken im selben Streifen, der Strom umgeht die LED. Setz sie in verschiedene Spalten.',
          '$ad: las dos patas están en la misma tira y la corriente no pasa por el LED. Ponlas en columnas distintas.');
    case DevreUyariTuru.ledTers:
      return devreT(lang,
          '$ad ters takılı: uzun bacak (+) pine, kısa bacak (−) GND\'ye gitmeli. Seçip "Döndür"e bas.',
          '$ad is backwards: the long leg (+) goes to the pin, the short leg (−) to GND. Select it and tap "Flip".',
          '$ad ist verkehrt herum: langes Bein (+) zum Pin, kurzes (−) zu GND. Auswählen und „Drehen“ tippen.',
          '$ad está al revés: la pata larga (+) va al pin y la corta (−) a GND. Selecciónalo y pulsa «Girar».');
    case DevreUyariTuru.ledDirencsiz:
      return devreT(lang,
          '$ad dirençsiz bağlı. Şimdilik yanıyor ama gerçekte fazla akım LED\'i yakar. Araya 220Ω direnç koy.',
          '$ad has no resistor. It lights up here, but in real life too much current burns it. Add a 220Ω resistor.',
          '$ad hat keinen Widerstand. Hier leuchtet sie, in echt brennt sie durch. Setz einen 220Ω-Widerstand dazwischen.',
          '$ad no tiene resistencia. Aquí se enciende, pero en la realidad se quemaría. Añade una resistencia de 220Ω.');
    case DevreUyariTuru.buzzerTers:
      return devreT(lang,
          'Buzzer ters: artı (+) bacak pine, eksi (−) bacak GND\'ye.',
          'The buzzer is backwards: plus (+) to the pin, minus (−) to GND.',
          'Der Summer ist verkehrt: Plus (+) zum Pin, Minus (−) zu GND.',
          'El zumbador está al revés: positivo (+) al pin y negativo (−) a GND.');
    case DevreUyariTuru.servoGucsuz:
      return devreT(lang,
          'Servonun gücü yok: kahverengi kablo GND\'ye, kırmızı 5V\'a gitmeli.',
          'The servo has no power: brown wire to GND, red wire to 5V.',
          'Der Servo hat keinen Strom: braunes Kabel an GND, rotes an 5V.',
          'El servo no tiene energía: cable marrón a GND y rojo a 5V.');
    case DevreUyariTuru.sensorGucsuz:
      return devreT(lang,
          '$ad çalışmıyor: VCC 5V\'a, GND GND\'ye bağlı olmalı.',
          '$ad is not powered: VCC must go to 5V and GND to GND.',
          '$ad hat keinen Strom: VCC an 5V, GND an GND.',
          '$ad no tiene energía: VCC a 5V y GND a GND.');
    case DevreUyariTuru.pinBosta:
      return devreT(lang,
          '${u.pin} hiçbir yere bağlı değil; okunan değer rastgele olur.',
          '${u.pin} is not connected to anything, so the reading is random.',
          '${u.pin} ist nirgends angeschlossen; der Wert ist zufällig.',
          '${u.pin} no está conectado; la lectura es aleatoria.');
    case DevreUyariTuru.mesafePinleri:
      return devreT(lang,
          'Mesafe sensörünün TRIG ve ECHO uçları koddaki pinlere bağlı değil.',
          'The distance sensor\'s TRIG and ECHO are not wired to the pins in your code.',
          'TRIG und ECHO des Abstandssensors hängen nicht an den Pins aus deinem Code.',
          'TRIG y ECHO del sensor de distancia no van a los pines de tu código.');
  }
}
