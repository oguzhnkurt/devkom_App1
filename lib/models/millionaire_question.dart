class MillionaireQuestion {
  final String? id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final int difficulty; // 1-15 arası soru seviyesi
  final int prize; // Bu sorunun para ödülü
  final String? imageUrl; // Soru görseli (varsa)

  MillionaireQuestion({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.difficulty,
    required this.prize,
    this.imageUrl,
  });

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
