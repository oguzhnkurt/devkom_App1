/// Application-wide constants
/// Following SOLID principles and DRY (Don't Repeat Yourself)
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ==================== DevAiChat Constants ====================

  /// AI Chat Service Name
  static const String aiChatName = 'DevAiChat';

  /// Asistan karsilama mesaji (Turkce)
  static const String aiWelcomeMessageTr =
      'Merhaba! Ben $aiChatName, DevEducation yardım asistanıyım. Scratch, Python, HTML, '
      'Arduino ve robotik konularında; ayrıca XP, jeton ve oyunlar hakkında sorularını '
      'yanıtlarım. Ne öğrenmek istersin?';

  /// Asistan karsilama mesaji (Ingilizce)
  static const String aiWelcomeMessageEn =
      'Hi! I am $aiChatName, the DevEducation help assistant. I answer questions about '
      'Scratch, Python, HTML, Arduino and robotics, plus XP, coins and games. '
      'What would you like to learn?';

  /// Asistan karsilama mesaji (Almanca)
  static const String aiWelcomeMessageDe =
      'Hallo! Ich bin $aiChatName, der Lernhelfer von DevEducation. Ich beantworte '
      'Fragen zu Scratch, Python, HTML, Arduino und Robotik sowie zu XP, Münzen und '
      'Spielen. Was möchtest du lernen?';

  /// Asistan karsilama mesaji (Ispanyolca)
  static const String aiWelcomeMessageEs =
      '¡Hola! Soy $aiChatName, el asistente de DevEducation. Respondo preguntas sobre '
      'Scratch, Python, HTML, Arduino y robótica, y también sobre XP, monedas y '
      'juegos. ¿Qué te gustaría aprender?';

  /// Karsilama mesajini dile gore secer.
  static String aiWelcomeMessageFor(String lang) {
    switch (lang) {
      case 'en':
        return aiWelcomeMessageEn;
      case 'de':
        return aiWelcomeMessageDe;
      case 'es':
        return aiWelcomeMessageEs;
      default:
        return aiWelcomeMessageTr;
    }
  }

  // ==================== Rate Limiting ====================

  /// Retry Attempts for API Failures
  static const int maxRetryAttempts = 3;

  /// Base Retry Delay in Seconds
  static const int baseRetryDelaySeconds = 2;

  // ==================== Validation ====================

  /// Minimum Message Length
  static const int minMessageLength = 1;

  /// Maximum Message Length
  static const int maxMessageLength = 2000;

  /// Maximum Messages in History
  static const int maxMessagesInHistory = 100;

  // ==================== Error Messages ====================

  /// Message Empty Error
  static const String errorMessageEmpty =
      'Lütfen bir mesaj yazın.';

  /// Message Too Long Error
  static const String errorMessageTooLong =
      'Mesajınız çok uzun. Lütfen $maxMessageLength karakterden kısa olacak şekilde yazın.';

  // ==================== UI Constants ====================

  /// Pro Membership Button Text
  static const String proMembershipButtonText =
      'Pro Üyelik Al - Sınırsız Soru';

  /// Daily Limit Warning Text
  static const String dailyLimitWarningText =
      'Günlük soru limitiniz doldu';

  // ==================== Firestore Collections ====================

  /// Users Collection Name
  static const String collectionUsers = 'users';

  /// Field: Daily Question Count
  static const String fieldDailyQuestionCount = 'dailyQuestionCount';

  /// Field: Last Question Date
  static const String fieldLastQuestionDate = 'lastQuestionDate';

  /// Field: Is Pro
  static const String fieldIsPro = 'isPro';

}
