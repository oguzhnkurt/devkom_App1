import '../models/interactive_lesson_model.dart';
import 'arduino/modul1.dart';
import 'arduino/modul2.dart';
import 'arduino/modul3.dart';
import 'arduino/modul4.dart';
import 'arduino/modul5.dart';
import 'arduino/modul6.dart';

/// ARDUINO ILE ROBOTIK — yeni kurs (Ekim 2026).
///
/// Alti modul, on sekiz ders. Her derste once devre (breadboard'da
/// rehberli kurulum), sonra mBlock bloklariyla kod; kod sahnede o
/// devrenin uzerinde calisiyor. Basitten karmasiga:
///  1. Uno ve breadboard   2. LED'ler   3. Butonlar
///  4. PWM ve potansiyometre   5. Buzzer, LDR, sicaklik
///  6. Mesafe sensoru, servo ve final projesi.
///
/// Eski kursun (10 ders, kart dizme) ayni konudaki derslerinin
/// kimlikleri korundu (arduino_1_1, arduino_2_1 ...): onlari bitiren
/// cocugun ilerlemesi kaybolmuyor. Yeni dersler `arduino_rM_N`.
/// `arduino_6_*` on eki Arduino IDE kursuna ait; burada kullanilmiyor.
abstract final class ArduinoRobotikDersleri {
  static List<InteractiveLesson> get module1 => arduinoModul1;
  static List<InteractiveLesson> get module2 => arduinoModul2;
  static List<InteractiveLesson> get module3 => arduinoModul3;
  static List<InteractiveLesson> get module4 => arduinoModul4;
  static List<InteractiveLesson> get module5 => arduinoModul5;
  static List<InteractiveLesson> get module6 => arduinoModul6;

  static List<InteractiveLesson> get allLessons => [
        ...module1,
        ...module2,
        ...module3,
        ...module4,
        ...module5,
        ...module6,
      ];
}
