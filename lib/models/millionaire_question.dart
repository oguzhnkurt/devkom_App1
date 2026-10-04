import '../utils/lang.dart';

class MillionaireQuestion {
  final String? id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final int difficulty; // 1-15 arası soru seviyesi
  final int prize; // Bu sorunun para ödülü
  final String? imageUrl; // Soru görseli (varsa)
  // İngilizce çeviri (varsa) - uygulama dili İngilizce'yken kullanılır.
  // correctAnswerIndex her iki dil için de aynı sırayı korur.
  final String? questionEn;
  final List<String>? optionsEn;
  // Almanca ve Ispanyolca. Yoksa AppLang'in zinciri gecerli: once
  // Ingilizce, o da yoksa Turkce. Eskiden yalnizca 'en' biliniyordu ve
  // Almanca/Ispanyolca secen cocuk soruyu Turkce goruyordu.
  final String? questionDe;
  final List<String>? optionsDe;
  final String? questionEs;
  final List<String>? optionsEs;

  MillionaireQuestion({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.difficulty,
    required this.prize,
    this.imageUrl,
    this.questionEn,
    this.optionsEn,
    this.questionDe,
    this.optionsDe,
    this.questionEs,
    this.optionsEs,
  });

  /// Dile göre soru metnini döndürür (İngilizce çeviri yoksa Türkçe'ye düşer).
  String questionFor(String languageCode) {
    String? dolu(String? s) => (s != null && s.isNotEmpty) ? s : null;
    return AppLang.pick(languageCode,
        tr: question,
        en: dolu(questionEn) ?? question,
        de: dolu(questionDe),
        es: dolu(questionEs));
  }

  /// Dile göre şık listesini döndürür (İngilizce çeviri yoksa Türkçe'ye düşer).
  List<String> optionsFor(String languageCode) {
    // Sik sayisi Turkceyle ayni olmayan ceviri kullanilmiyor: dogru cevap
    // `correctAnswerIndex` ile bulunuyor, sira kayarsa yanlis sik dogru sayilir.
    List<String>? uygun(List<String>? l) =>
        (l != null && l.length == options.length) ? l : null;
    final en = uygun(optionsEn) ?? options;
    switch (languageCode) {
      case AppLang.tr:
        return options;
      case AppLang.de:
        return uygun(optionsDe) ?? en;
      case AppLang.es:
        return uygun(optionsEs) ?? en;
      default:
        return en;
    }
  }

  factory MillionaireQuestion.fromMap(Map<String, dynamic> map) {
    return MillionaireQuestion(
      id: map['id'],
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
      difficulty: map['difficulty'] ?? 1,
      prize: map['prize'] ?? 0,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'difficulty': difficulty,
      'prize': prize,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

enum JokerType {
  fiftyFifty, // 50:50
  phone, // Telefon
  audience, // Seyirci
}

class JokerState {
  bool fiftyFiftyUsed = false;
  bool phoneUsed = false;
  bool audienceUsed = false;

  bool isUsed(JokerType type) {
    switch (type) {
      case JokerType.fiftyFifty:
        return fiftyFiftyUsed;
      case JokerType.phone:
        return phoneUsed;
      case JokerType.audience:
        return audienceUsed;
    }
  }

  void use(JokerType type) {
    switch (type) {
      case JokerType.fiftyFifty:
        fiftyFiftyUsed = true;
        break;
      case JokerType.phone:
        phoneUsed = true;
        break;
      case JokerType.audience:
        audienceUsed = true;
        break;
    }
  }
}
