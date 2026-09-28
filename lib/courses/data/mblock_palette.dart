import 'package:flutter/material.dart';

import '../models/interactive_lesson_model.dart';

/// mBlock 5'in GERÇEK blok paleti.
///
/// Buradaki her renk, etiket ve şekil uydurma değil: Makeblock'un canlı
/// yayındaki Arduino Uno cihaz paketinden (`arduino_uno v0.5.6`) ve
/// mBlock'un kendi Türkçe dil dosyasından
/// (`res-cdn.makeblock.com/i18n-upload/mblock/web/tr/arduino_uno.json`)
/// alındı. Sebep basit: çocuk uygulamada gördüğü bloğu mBlock'u açınca
/// birebir aynı renkte, aynı şekilde ve aynı yazıyla bulmalı. Yakın
/// olması yetmez — "neredeyse aynı" olan bir blok, çocuğun aradığını
/// bulamaması demek.
///
/// ÖNEMLİ FARKLAR (Arduino Uno cihazı seçiliyken):
///
///  * Palette **Hareket, Görünüm, Ses ve Algılama kategorileri YOKTUR**.
///    Onlar kuklaya (sprite) aittir. Cihaz paletinde dokuz kategori var:
///    Pin, seri port, Veri, Sensör, Olaylar, Kontrol, İşlemler,
///    Değişkenler, Bloklarım.
///  * **Pin mavisi (#4A90E2), Scratch'in Hareket mavisi (#4C97FF)
///    DEĞİLDİR.** Yakın ama başka bir renk.
///  * "Veri" (mor #BD10E0) donanım matematiği; "Değişkenler" (turuncu
///    #FF8C1A) Scratch'in değişkenleri. İki ayrı kategori.
///  * `dijital oku` bir **altıgen** (boolean) bloktur, düz blok değil.
class MBlockPalette {
  MBlockPalette._();

  // --- Cihaz (donanım) kategorileri ---

  /// Pin — dijital/analog/PWM/servo/nota blokları.
  static const Color pin = Color(0xFF4A90E2);

  /// seri port — bilgisayara yazı gönderme, okuma.
  static const Color serialPort = Color(0xFF7ED321);

  /// Veri — harita (map), kısıtlama, tip dönüşümü. Değişkenler DEĞİL.
  static const Color data = Color(0xFFBD10E0);

  /// Sensör — mesafe algılayıcı, zamanlayıcı.
  static const Color sensor = Color(0xFF4CBFE6);

  // --- Scratch'ten gelen kategoriler ---

  /// Olaylar.
  static const Color events = Color(0xFFFFBF00);

  /// Kontrol — sürekli tekrarla, eğer/ise, bekle.
  static const Color control = Color(0xFFFFAB19);

  /// İşlemler — toplama, karşılaştırma, ve/veya.
  static const Color operators = Color(0xFF59C059);

  /// Değişkenler.
  static const Color variables = Color(0xFFFF8C1A);

  /// Bloklarım (kendi bloğunu tanımla).
  static const Color myBlocks = Color(0xFFFF6680);

  /// Paletteki sıra — mBlock'ta kategoriler bu sırada görünüyor.
  static const List<(String, String, Color)> categories = [
    ('Pin', 'Pin', pin),
    ('serial port', 'seri port', serialPort),
    ('Data', 'Veri', data),
    ('Sensor', 'Sensör', sensor),
    ('Events', 'Olaylar', events),
    ('Control', 'Kontrol', control),
    ('Operators', 'İşlemler', operators),
    ('Variables', 'Değişkenler', variables),
    ('My Blocks', 'Bloklarım', myBlocks),
  ];
}

/// Sık kullanılan mBlock blokları, gerçek etiketleriyle.
///
/// Etiketler mBlock'un Türkçe dosyasından birebir alındı — kelime sırası
/// garip gelse bile değiştirilmedi, çünkü çocuk ekranda tam olarak bunu
/// görecek. Örneğin mesafe bloğunun Türkçesinde kutular yazılardan ÖNCE
/// geliyor: "mesafe algılayıcı [trig] trig pin [echo] echo pin".
class MBlockBlocks {
  MBlockBlocks._();

  // ---------------------------------------------------------------- Olaylar

  /// Yükleme modunun başlangıç bloğu.
  ///
  /// DİKKAT: bu bloğun Türkçesi YOK. mBlock'un Türkçe dil dosyasında bu
  /// anahtarın değeri İngilizce metnin aynısı, yani Türkçe arayüzde bile
  /// blok "when Arduino Uno starts up" yazıyor. Uydurma bir Türkçe isim
  /// koymuyoruz; çocuk bloğu ekranda bu haliyle arayacak.
  static ScratchBlock boardLaunch({String id = 'board_launch'}) => ScratchBlock(
        id: id,
        blockType: ScratchBlockType.events,
        shape: ScratchBlockShape.cap,
        label: 'when Arduino Uno starts up',
        labelEn: 'when Arduino Uno starts up',
        labelDe: 'wenn Arduino Uno startet',
        labelEs: 'cuando Arduino Uno se inicia',
        color: MBlockPalette.events,
      );

  // ---------------------------------------------------------------- Kontrol

  static ScratchBlock forever({String id = 'forever'}) => ScratchBlock(
        id: id,
        blockType: ScratchBlockType.control,
        shape: ScratchBlockShape.cBlock,
        label: 'sürekli tekrarla',
        labelEn: 'forever',
        labelDe: 'wiederhole fortlaufend',
        labelEs: 'por siempre',
        color: MBlockPalette.control,
      );

  static ScratchBlock wait(String seconds, {String id = 'wait'}) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.control,
        shape: ScratchBlockShape.stack,
        label: '$seconds saniye bekle',
        labelEn: 'wait $seconds seconds',
        labelDe: 'warte $seconds Sekunden',
        labelEs: 'esperar $seconds segundos',
        color: MBlockPalette.control,
      );

  static ScratchBlock ifThen(String condition,
          {String? conditionEn,
          String? conditionDe,
          String? conditionEs,
          String id = 'if'}) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.control,
        shape: ScratchBlockShape.cBlock,
        label: 'eğer <$condition> ise',
        labelEn: 'if <${conditionEn ?? condition}> then',
        labelDe: 'falls <${conditionDe ?? conditionEn ?? condition}>, dann',
        labelEs: 'si <${conditionEs ?? conditionEn ?? condition}> entonces',
        color: MBlockPalette.control,
      );

  static ScratchBlock repeat(String times, {String id = 'repeat'}) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.control,
        shape: ScratchBlockShape.cBlock,
        label: '$times defa tekrarla',
        labelEn: 'repeat $times',
        labelDe: 'wiederhole $times mal',
        labelEs: 'repetir $times',
        color: MBlockPalette.control,
      );

  // -------------------------------------------------------------------- Pin

  /// mBlock'un Türkçesindeki kelimenin İngilizcesi.
  ///
  /// NEDEN GEREKLİ: bu yardımcıların ARGÜMANLARI da bloğun yazısının
  /// parçası. `digitalWrite('9', 'yüksek')` çağrısı İngilizce etikete
  /// de "yüksek" yazıyordu: "set digital pin 9 output as yüksek".
  /// Blok İngilizce görünüyor ama içinde Türkçe bir kelime duruyor —
  /// çocuk mBlock'ta o bloğu aradığında bulamaz.
  static String _en(String tr) => switch (tr) {
        'yüksek' => 'high',
        'düşük' => 'low',
        'parlaklik' => 'brightness',
        'açık' => 'on',
        'sayaç' => 'counter',
        'mesafe' => 'distance',
        'ldr' => 'ldr',
        'pot' => 'pot',
        _ => tr,
      };

  /// [_en] ile ayni is, Almanca icin.
  ///
  /// 'yüksek'/'düşük' mBlock'un kendi Almanca dosyasindan (hoch/niedrig).
  /// Digerleri bloklarin kutusuna cocugun yazdigi degisken adlari.
  static String _de(String tr) => switch (tr) {
        'yüksek' => 'hoch',
        'düşük' => 'niedrig',
        'parlaklik' => 'helligkeit',
        'açık' => 'an',
        'sayaç' => 'zaehler',
        'mesafe' => 'abstand',
        'ldr' => 'ldr',
        'pot' => 'poti',
        _ => tr,
      };

  /// [_en] ile ayni is, Ispanyolca icin (alto/bajo mBlock'un dosyasindan).
  static String _es(String tr) => switch (tr) {
        'yüksek' => 'alto',
        'düşük' => 'bajo',
        'parlaklik' => 'brillo',
        'açık' => 'encendido',
        'sayaç' => 'contador',
        'mesafe' => 'distancia',
        'ldr' => 'ldr',
        'pot' => 'pot',
        _ => tr,
      };

  /// "dijital ayarla pin [9] çıkış [yüksek]"
  ///
  /// [levelEn] verilmezse Türkçe kelimenin bilinen İngilizcesi
  /// kullanılıyor (bkz. [_en]).
  static ScratchBlock digitalWrite(String pin, String level,
          {String? levelEn, String? levelDe, String? levelEs, String? id}) =>
      ScratchBlock(
        id: id ?? 'digital_${pin}_$level',
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.stack,
        label: 'dijital ayarla pin $pin çıkış $level',
        labelEn: 'set digital pin $pin output as ${levelEn ?? _en(level)}',
        labelDe: 'digitalen Pin von Ausgang $pin als ${levelDe ?? _de(level)} setzen',
        labelEs: 'pon el pin digital $pin a ${levelEs ?? _es(level)}',
        color: MBlockPalette.pin,
      );

  /// "dijital oku pin [9]" — ALTIGEN blok, koşul yuvasına girer.
  static ScratchBlock digitalRead(String pin, {String? id}) => ScratchBlock(
        id: id ?? 'digital_read_$pin',
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.boolean,
        label: 'dijital oku pin $pin',
        labelEn: 'read digital pin $pin',
        labelDe: 'Digitalpin lesen $pin',
        labelEs: 'lee pin digital $pin',
        color: MBlockPalette.pin,
      );

  /// "analog oku pin (A) [0]" — OVAL blok, sayı döndürür (0-1023).
  static ScratchBlock analogRead(String pin, {String? id}) => ScratchBlock(
        id: id ?? 'analog_read_$pin',
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.reporter,
        label: 'analog oku pin (A) $pin',
        labelEn: 'read analog pin (A) $pin',
        labelDe: 'analogen Pin（A）$pin lesen',
        labelEs: 'lee pin analógico $pin',
        color: MBlockPalette.pin,
      );

  /// "PWM ayarla pin[5] çıkış [0]" — yalnızca 3, 5, 6, 9, 10, 11.
  static ScratchBlock pwmWrite(String pin, String power,
          {String? powerEn, String? powerDe, String? powerEs, String? id}) =>
      ScratchBlock(
        id: id ?? 'pwm_${pin}_$power',
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.stack,
        label: 'PWM ayarla pin$pin çıkış $power',
        labelEn: 'set PWM $pin output as ${powerEn ?? _en(power)}',
        labelDe: 'PWM-Ausgang $pin als ${powerDe ?? _de(power)} festlegen',
        labelEs: 'pon la salida PWM $pin a ${powerEs ?? _es(power)}',
        color: MBlockPalette.pin,
      );

  /// "pinde çal [9] nota [C4] ile [0.25] vuruş"
  static ScratchBlock playNote(String pin, String note, String beat,
          {String? id}) =>
      ScratchBlock(
        id: id ?? 'note_$note',
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.stack,
        label: 'pinde çal $pin nota $note ile $beat vuruş',
        labelEn: 'play pin $pin with note $note for $beat beats',
        labelDe: 'Pin$pin spielt Note $note tür $beat Schläge',
        labelEs: 'toca nota $note en pin $pin durante $beat tiempos',
        color: MBlockPalette.pin,
      );

  /// "servo pin [9] açı [90]"
  static ScratchBlock servo(String pin, String angle, {String? id}) =>
      ScratchBlock(
        id: id ?? 'servo_$angle',
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.stack,
        label: 'servo pin $pin açı $angle',
        labelEn: 'set servo pin $pin angle as $angle',
        labelDe: 'setze Servo an Anschluss $pin auf Winkel $angle',
        labelEs: 'mueve el servo en pin $pin al ángulo $angle',
        color: MBlockPalette.pin,
      );

  // ----------------------------------------------------------------- Sensör

  /// "mesafe algılayıcı [trig] trig pin [echo] echo pin" — OVAL.
  ///
  /// Türkçe etiketteki kutu/yazı sırası mBlock'ta gerçekten böyle: önce
  /// sayı kutusu, sonra "trig pin" yazısı geliyor.
  static ScratchBlock ultrasonic(String trig, String echo, {String? id}) =>
      ScratchBlock(
        id: id ?? 'ultrasonic',
        blockType: ScratchBlockType.sensing,
        shape: ScratchBlockShape.reporter,
        label: 'mesafe algılayıcı $trig trig pin $echo echo pin',
        labelEn: 'read ultrasonic sensor trig pin $trig echo pin $echo',
        labelDe: 'read ultrasonic sensor trig pin $trig echo pin $echo',
        labelEs: 'lee sensor de ultrasonidos, pin de activación $trig, pin de eco $echo',
        color: MBlockPalette.sensor,
      );

  // -------------------------------------------------------------- seri port

  /// "seri porta [merhaba] yaz"
  static ScratchBlock serialWrite(String text, {String? id}) => ScratchBlock(
        id: id ?? 'serial_write',
        blockType: ScratchBlockType.operators,
        shape: ScratchBlockShape.stack,
        label: 'seri porta $text yaz',
        labelEn: 'write $text to serial port',
        labelDe: '$text an serielle Schnittstelle schreiben',
        labelEs: 'escribe $text al puerto serie',
        color: MBlockPalette.serialPort,
      );

  // ------------------------------------------------------------------- Veri

  /// "Harita [x] konumundan (0, 1023) için (0, 255)"
  static ScratchBlock map(String value, String fromLow, String fromHigh,
          String toLow, String toHigh, {String? id}) =>
      ScratchBlock(
        id: id ?? 'map',
        blockType: ScratchBlockType.looks,
        shape: ScratchBlockShape.reporter,
        label: 'Harita $value konumundan ($fromLow, $fromHigh) '
            'için ($toLow, $toHigh)',
        labelEn: 'map $value from ($fromLow, $fromHigh) to ($toLow, $toHigh)',
        labelDe: 'Karte $value Von ( $fromLow , $fromHigh ) zu ( $toLow , $toHigh ）',
        labelEs: 'mapear $value de ($fromLow, $fromHigh) a ($toLow, $toHigh）',
        color: MBlockPalette.data,
      );

  // -------------------------------------------------------------- Değişken

  static ScratchBlock setVariable(String name, String value,
          {String? nameEn,
          String? nameDe,
          String? nameEs,
          String? valueEn,
          String? valueDe,
          String? valueEs,
          String? id}) =>
      ScratchBlock(
        id: id ?? 'set_$name',
        blockType: ScratchBlockType.variables,
        shape: ScratchBlockShape.stack,
        label: '$name değişkenini $value yap',
        labelEn: 'set ${nameEn ?? _en(name)} to ${valueEn ?? value}',
        labelDe: 'setze ${nameDe ?? _de(name)} auf ${valueDe ?? valueEn ?? value}',
        labelEs: 'dar a ${nameEs ?? _es(name)} el valor ${valueEs ?? valueEn ?? value}',
        color: MBlockPalette.variables,
      );

  // ------------------------------------------------------------- İşlemler

  static ScratchBlock lessThan(String a, String b, {String? id}) =>
      ScratchBlock(
        id: id ?? 'lt',
        blockType: ScratchBlockType.operators,
        shape: ScratchBlockShape.boolean,
        label: '$a < $b',
        labelEn: '$a < $b',
        color: MBlockPalette.operators,
      );

  static ScratchBlock greaterThan(String a, String b, {String? id}) =>
      ScratchBlock(
        id: id ?? 'gt',
        blockType: ScratchBlockType.operators,
        shape: ScratchBlockShape.boolean,
        label: '$a > $b',
        labelEn: '$a > $b',
        color: MBlockPalette.operators,
      );
}

/// mBlock'un KUKLA (sprite) tarafındaki palet.
///
/// NEDEN AYRI
/// ----------
/// `MBlockPalette` yukarıda Arduino Uno **cihazı** seçiliyken görünen
/// dokuz kategoriyi tarif ediyor. Ama mBlock açıldığında çocuk önce
/// kukla sekmesindedir: orada Scratch'in kendi kategorileri durur —
/// Hareket, Görünüm, Ses, Olaylar, Kontrol, Algılama, İşlemler,
/// Değişkenler, Bloklarım. Kursun ilk modülü hiç kart takmadan burada
/// geçiyor; renkler Scratch 3.0'ın kendi renkleridir, cihaz
/// paletindekilerle karıştırılmamalı (Hareket mavisi #4C97FF, Pin
/// mavisi #4A90E2 — aynı değil).
class MBlockKuklaPalette {
  MBlockKuklaPalette._();

  /// Hareket — git, dön, konuma git.
  static const Color motion = Color(0xFF4C97FF);

  /// Görünüm — de, düşün, büyüklük, göster/gizle.
  static const Color looks = Color(0xFF9966FF);

  /// Ses — sesi çal, sesi bitir.
  static const Color sound = Color(0xFFCF63CF);

  /// Algılama — fareye değiyor mu, tuşa basıldı mı.
  static const Color sensing = Color(0xFF5CB1D6);

  /// Olaylar, Kontrol, İşlemler, Değişkenler kukla tarafında da
  /// cihaz tarafıyla aynı renktedir; onlar için `MBlockPalette` kullan.
}

/// Kukla tarafının sık kullanılan blokları, mBlock Türkçesiyle birebir.
///
/// Etiketler mBlock 5'in Türkçe arayüzünden alındı. Scratch'in Türkçe
/// çevirisiyle aynıdır, çünkü mBlock bu blokları Scratch 3.0'dan devralır.
class MBlockKuklaBlocks {
  MBlockKuklaBlocks._();

  /// Yeşil bayrak — kukla tarafının başlangıç bloğu.
  static ScratchBlock greenFlag({String id = 'green_flag'}) => ScratchBlock(
        id: id,
        blockType: ScratchBlockType.events,
        shape: ScratchBlockShape.cap,
        label: '🏳 tıklandığında',
        labelEn: 'when 🏳 clicked',
        labelDe: 'wenn 🏳 angeklickt',
        labelEs: 'al hacer clic en 🏳',
        color: MBlockPalette.events,
      );

  static ScratchBlock move(String steps, {String? id}) => ScratchBlock(
        id: id ?? 'move_$steps',
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.stack,
        label: '$steps adım git',
        labelEn: 'move $steps steps',
        labelDe: 'gehe $steps er Schritt',
        labelEs: 'mover $steps pasos',
        color: MBlockKuklaPalette.motion,
      );

  static ScratchBlock turn(String degrees, {String? id}) => ScratchBlock(
        id: id ?? 'turn_$degrees',
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.stack,
        label: '↻ $degrees derece dön',
        labelEn: 'turn ↻ $degrees degrees',
        labelDe: 'drehe dich ↻ um $degrees Grad',
        labelEs: 'girar ↻ $degrees grados',
        color: MBlockKuklaPalette.motion,
      );

  static ScratchBlock say(String text,
          {String? textEn, String? textDe, String? textEs, String? id}) =>
      ScratchBlock(
        id: id ?? 'say',
        blockType: ScratchBlockType.looks,
        shape: ScratchBlockShape.stack,
        label: '$text de',
        labelEn: 'say ${textEn ?? text}',
        labelDe: 'sage ${textDe ?? textEn ?? text}',
        labelEs: 'decir ${textEs ?? textEn ?? text}',
        color: MBlockKuklaPalette.looks,
      );

  static ScratchBlock changeSize(String amount, {String? id}) => ScratchBlock(
        id: id ?? 'change_size',
        blockType: ScratchBlockType.looks,
        shape: ScratchBlockShape.stack,
        label: 'boyutu $amount değiştir',
        labelEn: 'change size by $amount',
        labelDe: 'ändere Größe um $amount',
        labelEs: 'cambiar tamaño por $amount',
        color: MBlockKuklaPalette.looks,
      );

  static ScratchBlock wait(String seconds, {String? id}) => ScratchBlock(
        id: id ?? 'k_wait',
        blockType: ScratchBlockType.control,
        shape: ScratchBlockShape.stack,
        label: '$seconds saniye bekle',
        labelEn: 'wait $seconds seconds',
        labelDe: 'warte $seconds Sekunden',
        labelEs: 'esperar $seconds segundos',
        color: MBlockPalette.control,
      );

  static ScratchBlock repeat(String times, {String? id}) => ScratchBlock(
        id: id ?? 'k_repeat',
        blockType: ScratchBlockType.control,
        shape: ScratchBlockShape.cBlock,
        label: '$times kere tekrarla',
        labelEn: 'repeat $times',
        labelDe: 'wiederhole $times mal',
        labelEs: 'repetir $times veces',
        color: MBlockPalette.control,
      );

  static ScratchBlock forever({String id = 'k_forever'}) => ScratchBlock(
        id: id,
        blockType: ScratchBlockType.control,
        shape: ScratchBlockShape.cBlock,
        label: 'sürekli tekrarla',
        labelEn: 'forever',
        labelDe: 'wiederhole fortlaufend',
        labelEs: 'por siempre',
        color: MBlockPalette.control,
      );
}
