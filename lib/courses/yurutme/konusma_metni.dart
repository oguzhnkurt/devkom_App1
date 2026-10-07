import '../models/interactive_lesson_model.dart';

/// "Merhaba de" / "say Hello!" / "sage Hallo!" / "di ¡Hola!" bloklarinin
/// kuklaya SOYLETTIGI metin, cocugun dilinde.
///
/// Blok sozlugundeki `metin` Turkce (say_hello -> 'Merhaba'). Sahne
/// oynaticisi metni coktandir blogun kendi etiketinden cikariyordu; ama
/// "Kodun ne yapti" izi sozlukteki Turkce metni yaziyordu: Ispanyolca
/// derste bloklar "di ¡Hola!" derken iz `"Merhaba"` diyordu (Ekim 2026,
/// magaza slaytinda fark edildi). Ikisi artik bu tek fonksiyonu kullaniyor.
String konusmaMetni(ScratchBlock blok, String lang) {
  final etiket = blok.labelFor(lang);
  final temiz = etiket
      .replaceAll(
          RegExp(r'^\s*(say|sage|decir|di)\s+', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+(de|sagen)\s*$', caseSensitive: false), '')
      .trim();
  return temiz.isEmpty ? etiket : temiz;
}
