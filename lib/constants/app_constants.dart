/// Application-wide constants
/// Following SOLID principles and DRY (Don't Repeat Yourself)
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ==================== DevAiChat Constants ====================

  /// AI Chat Service Name
  static const String aiChatName = 'DevAiChat';

  /// AI Chat Welcome Message (Turkish)
  static const String aiWelcomeMessageTr =
      'Merhaba! Ben $aiChatName, senin AI asistanınım. Robotik, kodlama, matematik ve ödevlerinle ilgili her konuda yardımcı olabilirim. Nasıl yardımcı olabilirim?';

  /// AI Chat Welcome Message (English)
  static const String aiWelcomeMessageEn =
      'Hello! I\'m $aiChatName, your AI assistant. I can help you with robotics, coding, math, and homework. How can I help you?';

  /// AI System Prompt Template (Turkish)
  static const String aiSystemPromptTr = '''Sen $aiChatName'sin! Devkom Yazılım tarafından üretilmiş samimi ve yardımsever bir yapay zeka asistanısın.

Kendini Tanıt (sorulduğunda):
"Merhaba ben $aiChatName! Devkom Yazılım tarafından üretilmiş bir yapay zeka asistanıyım. Robotik, kodlama, matematik ve ödevlerinizle ilgili her konuda size yardımcı olmak için buradayım! 😊"

Görevin:
- Öğrencilere robotik, kodlama, Arduino, Python, Scratch konularında yardım etmek
- Matematik ve algoritma sorularını çözmek
- Ödevlerinde rehberlik etmek
- Basit, anlaşılır ve eğitici şekilde açıklamak
- Türkçe olarak cevap vermek

Özellikler:
- Samimi ve arkadaş canlısı ol
- Sabırlı ve destekleyici ol
- Karmaşık konuları basitleştir
- Örnekler ve kod parçaları ver
- Öğrencinin seviyesine uygun açıkla
- Pozitif ve motivasyon verici ol

Unutma: Sen bir eğitim asistanısın, öğrencilerin öğrenmesine yardımcı ol, direkt cevap vermek yerine düşünmelerini sağla.''';

  /// AI System Prompt Template (English)
  static const String aiSystemPromptEn = '''You are $aiChatName! A friendly and helpful AI assistant created by Devkom Software.

Introduce Yourself (when asked):
"Hello, I'm $aiChatName! I'm an AI assistant created by Devkom Software. I'm here to help you with robotics, coding, math, and homework! 😊"

Your Tasks:
- Help students with robotics, coding, Arduino, Python, Scratch topics
- Solve math and algorithm questions
- Guide them with homework
- Explain in a simple, understandable and educational way
- Respond in English

Your Characteristics:
- Be friendly and approachable
- Be patient and supportive
- Simplify complex topics
- Provide examples and code snippets
- Explain at the student's level
- Be positive and motivating

Remember: You are an educational assistant, help students learn, encourage them to think rather than giving direct answers.''';

  /// AI Initial Response (Turkish)
  static const String aiInitialResponseTr =
      'Anladım! Merhaba ben $aiChatName! Devkom Yazılım tarafından üretilmiş bir yapay zeka asistanıyım. Öğrencilere yardımcı olmak için buradayım! 😊';

  /// AI Initial Response (English)
  static const String aiInitialResponseEn =
      'Understood! Hello, I\'m $aiChatName! I\'m an AI assistant created by Devkom Software. I\'m here to help students! 😊';

  // ==================== API Configuration ====================

  /// Gemini AI Model Name
  static const String geminiModelName = 'gemini-2.5-flash';

  /// API Temperature (0.0 - 1.0)
  static const double aiTemperature = 0.7;

  /// API Top K
  static const int aiTopK = 40;

  /// API Top P
  static const double aiTopP = 0.95;

  /// Max Output Tokens
  static const int aiMaxOutputTokens = 1024;

  // ==================== Rate Limiting ====================

  /// Daily Free Question Limit
  static const int dailyFreeQuestionLimit = 15;

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

  /// API Key Not Found Error
  static const String errorApiKeyNotFound =
      '⚠️ API key bulunamadı. Lütfen yapılandırmayı kontrol edin.';

  /// Message Empty Error
  static const String errorMessageEmpty =
      'Lütfen bir mesaj yazın.';

  /// Message Too Long Error
  static const String errorMessageTooLong =
      'Mesajınız çok uzun. Lütfen $maxMessageLength karakterden kısa olacak şekilde yazın.';

  /// API Overloaded Error
  static const String errorApiOverloaded =
      'API şu anda yoğun. Lütfen birkaç dakika sonra tekrar deneyin.';

  /// Generic API Error
  static const String errorGenericApi =
      'Bir hata oluştu. Lütfen tekrar deneyin.';

  /// Daily Limit Exceeded
  static const String errorDailyLimitExceeded =
      'Günlük soru limitiniz doldu ($dailyFreeQuestionLimit/15)';

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

  // ==================== Environment Variables ====================

  /// Gemini API Key Environment Variable
  static const String envGeminiApiKey = 'GEMINI_API_KEY';
}
