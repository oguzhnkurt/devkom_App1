import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
// TODO: Migrate to Supabase - import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../theme.dart';
import '../constants/app_constants.dart';
import '../services/input_validator.dart';
import '../services/logger_service.dart';
import '../utils/app_localizations.dart';
import 'auth/register_screen.dart';

/// DevAiChat - AI Chatbot Screen with Google Gemini AI
/// Following Clean Code principles with proper validation and logging
class DevAiChatScreen extends StatefulWidget {
  const DevAiChatScreen({super.key});

  @override
  State<DevAiChatScreen> createState() => _DevAiChatScreenState();
}

class _DevAiChatScreenState extends State<DevAiChatScreen> {
  final _logger = LoggerService.instance;
  final _validator = InputValidator.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  GenerativeModel? _model;
  ChatSession? _chat;

  // Misafir (giriş yapmamış) kullanıcılar için günlük soru hakkı.
  // Misafirlerin backend'de kullanıcı kaydı olmadığından bu sayaç cihazda
  // (SharedPreferences) tutulur ve her gün sıfırlanır.
  static const int _visitorDailyLimit = 3;
  static const String _visitorCountKey = 'visitor_ai_question_count';
  static const String _visitorDateKey = 'visitor_ai_question_date';

  @override
  void initState() {
    super.initState();
    _logger.info('DevAiChat screen initialized', tag: 'DEVAICHAT');

    // Initialize AI will be called in didChangeDependencies after we can access context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize AI with the current language
    if (_messages.isEmpty) {
      _initializeAI();

      // Get current language
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final isEnglish = settingsProvider.locale.languageCode == 'en';

      // Welcome message based on language
      _addMessage(
        ChatMessage(
          text: isEnglish
              ? AppConstants.aiWelcomeMessageEn
              : AppConstants.aiWelcomeMessageTr,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// Initialize Google Gemini AI with proper error handling
  void _initializeAI() {
    try {
      final apiKey = dotenv.env[AppConstants.envGeminiApiKey] ?? '';

      if (apiKey.isEmpty || apiKey == 'your_api_key_here') {
        _logger.warning(AppConstants.errorApiKeyNotFound, tag: 'DEVAICHAT');
        return;
      }

      // Get current language
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      final isEnglish = settingsProvider.locale.languageCode == 'en';

      _model = GenerativeModel(
        model: AppConstants.geminiModelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: AppConstants.aiTemperature,
          topK: AppConstants.aiTopK,
          topP: AppConstants.aiTopP,
          maxOutputTokens: AppConstants.aiMaxOutputTokens,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        ],
      );

      // System prompt ile chat başlat - dile göre farklı prompt kullan
      _chat = _model?.startChat(history: [
        Content.text(isEnglish
            ? AppConstants.aiSystemPromptEn
            : AppConstants.aiSystemPromptTr),
        Content.model([
          TextPart(isEnglish
              ? AppConstants.aiInitialResponseEn
              : AppConstants.aiInitialResponseTr)
        ]),
      ]);

      _logger.success('Gemini AI başarıyla başlatıldı', tag: 'DEVAICHAT');
    } catch (e, stackTrace) {
      _logger.error('Gemini AI başlatılamadı', tag: 'DEVAICHAT', error: e, stackTrace: stackTrace);
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Send message with validation and security checks
  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();

    // Input validation
    final validationError = _validator.validateMessage(userMessage);
    if (validationError != null) {
      _logger.warning('Message validation failed: $validationError', tag: 'DEVAICHAT');
      _showErrorSnackBar(validationError);
      return;
    }

    // Security check for malicious input
    final securityError = _validator.performSecurityCheck(userMessage);
    if (securityError != null) {
      _logger.warning('Security check failed for message', tag: 'DEVAICHAT');
      _showErrorSnackBar(securityError);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      // Misafir modu: hesabı olmayan kullanıcılar günde 3 soru sorabilir.
      final guestCount = await _getGuestQuestionCountToday();
      if (guestCount >= _visitorDailyLimit) {
        _logger.info('Guest daily limit exceeded ($guestCount/$_visitorDailyLimit)', tag: 'DEVAICHAT');
        _showGuestLimitDialog();
        return;
      }
      await _incrementGuestQuestionCount();
      if (mounted) setState(() {});
      _logger.info('Guest question count incremented', tag: 'DEVAICHAT');
    } else if (!user.isPro) {
      // Günlük soru limiti kontrolü ve sayaç artırma
      final canAsk = await _checkDailyLimit(user.uid);
      if (!canAsk) {
        _logger.info('Daily limit exceeded for user: ${user.uid}', tag: 'DEVAICHAT');
        _showProDialog();
        return;
      }

      // Sayacı HEMEN artır (mesaj başarılı olmasa bile)
      await _incrementDailyQuestionCount(user.uid);
      _logger.info('Daily question count incremented', tag: 'DEVAICHAT');
    }

    // Sanitize input before sending
    final sanitizedMessage = _validator.sanitizeInput(userMessage);
    _logger.userAction('Send message', metadata: {'messageLength': sanitizedMessage.length});
    _addMessage(
      ChatMessage(
        text: sanitizedMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    _messageController.clear();

    setState(() {
      _isTyping = true;
    });

    try {
      final startTime = DateTime.now();
      String response;

      if (_chat != null && _model != null) {
        // Google Gemini AI'dan gerçek cevap al (retry ile)
        _logger.apiRequest('Gemini AI', params: {'messageLength': sanitizedMessage.length});
        response = await _sendMessageWithRetry(sanitizedMessage);

        final duration = DateTime.now().difference(startTime);
        _logger.performance('AI Response', duration);
        _logger.apiResponse('Gemini AI', statusCode: 200);
      } else {
        // Fallback: API key yoksa basit yanıtlar
        response = _generateFallbackResponse(sanitizedMessage.toLowerCase());
      }

      setState(() {
        _isTyping = false;
      });

      _addMessage(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e, stackTrace) {
      setState(() {
        _isTyping = false;
      });

      _logger.error('Mesaj gönderme hatası', tag: 'DEVAICHAT', error: e, stackTrace: stackTrace);

      _addMessage(
        ChatMessage(
          text: e.toString().contains('overloaded')
              ? AppConstants.errorApiOverloaded
              : AppConstants.errorGenericApi,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// Show error message to user
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Send message with exponential backoff retry logic
  /// Implements retry pattern for API resilience
  Future<String> _sendMessageWithRetry(String message) async {
    int retryCount = 0;

    while (retryCount < AppConstants.maxRetryAttempts) {
      try {
        final content = Content.text(message);
        final aiResponse = await _chat!.sendMessage(content);
        return aiResponse.text ?? 'Üzgünüm, yanıt oluşturamadım.';
      } catch (e) {
        retryCount++;

        if (e.toString().contains('overloaded') && retryCount < AppConstants.maxRetryAttempts) {
          // Sunucu yoğun, bekle ve tekrar dene (Exponential backoff)
          final delaySeconds = AppConstants.baseRetryDelaySeconds * retryCount;
          _logger.warning(
            'API yoğun, ${retryCount}. deneme başarısız. ${AppConstants.maxRetryAttempts - retryCount} deneme kaldı. ${delaySeconds}s bekleniyor...',
            tag: 'DEVAICHAT',
          );
          await Future.delayed(Duration(seconds: delaySeconds));
          continue;
        }

        // Diğer hatalar veya son deneme başarısız
        _logger.apiError('Gemini AI', e);
        rethrow;
      }
    }

    throw Exception(AppConstants.errorApiOverloaded);
  }

  /// Check if user has reached daily question limit
  /// Returns true if user can ask more questions
  /// TODO: Migrate to Supabase
  Future<bool> _checkDailyLimit(String userId) async {
    try {
      _logger.info('Daily limit check - stub (Firebase disabled)', tag: 'DEVAICHAT');
      // Always return true during migration to avoid blocking users
      return true;

      // TODO: Migrate to Supabase
      // _logger.dbOperation('Check daily limit', collection: AppConstants.collectionUsers);
      //
      // final userDoc = await FirebaseFirestore.instance
      //     .collection(AppConstants.collectionUsers)
      //     .doc(userId)
      //     .get();
      //
      // if (!userDoc.exists) {
      //   _logger.info('User document not found, allowing question', tag: 'DEVAICHAT');
      //   return true;
      // }
      //
      // final data = userDoc.data()!;
      // final dailyCount = data[AppConstants.fieldDailyQuestionCount] ?? 0;
      // final lastQuestionDate = data[AppConstants.fieldLastQuestionDate] as Timestamp?;
      //
      // _logger.debug(
      //   'Current daily question count: $dailyCount / ${AppConstants.dailyFreeQuestionLimit}',
      //   tag: 'DEVAICHAT',
      // );
      //
      // // Günlük limiti sıfırla (yeni gün başlamışsa)
      // if (lastQuestionDate != null) {
      //   final lastDate = lastQuestionDate.toDate();
      //   final today = DateTime.now();
      //
      //   if (lastDate.day != today.day ||
      //       lastDate.month != today.month ||
      //       lastDate.year != today.year) {
      //     // Yeni gün başladı, sayacı sıfırla
      //     _logger.info('New day started, resetting counter', tag: 'DEVAICHAT');
      //     await FirebaseFirestore.instance
      //         .collection(AppConstants.collectionUsers)
      //         .doc(userId)
      //         .set({
      //       AppConstants.fieldDailyQuestionCount: 0,
      //       AppConstants.fieldLastQuestionDate: Timestamp.now(),
      //     }, SetOptions(merge: true));
      //     return true;
      //   }
      // }
      //
      // // Günlük limit kontrolü
      // final canAsk = dailyCount < AppConstants.dailyFreeQuestionLimit;
      // if (!canAsk) {
      //   _logger.info(
      //     'Daily limit exceeded: $dailyCount / ${AppConstants.dailyFreeQuestionLimit}',
      //     tag: 'DEVAICHAT',
      //   );
      // }
      // return canAsk;
    } catch (e, stackTrace) {
      _logger.error('Limit check error', tag: 'DEVAICHAT', error: e, stackTrace: stackTrace);
      return true; // Hata durumunda kullanıcıyı engellemiyoruz
    }
  }

  /// Increment daily question count for user
  /// TODO: Migrate to Supabase
  Future<void> _incrementDailyQuestionCount(String userId) async {
    try {
      _logger.info('Increment question count - stub (Firebase disabled)', tag: 'DEVAICHAT');
      // Stub implementation during migration

      // TODO: Migrate to Supabase
      // _logger.dbOperation('Increment question count', collection: AppConstants.collectionUsers);
      //
      // final userDoc = await FirebaseFirestore.instance
      //     .collection(AppConstants.collectionUsers)
      //     .doc(userId)
      //     .get();
      //
      // if (userDoc.exists) {
      //   // Document exists, use update
      //   await FirebaseFirestore.instance
      //       .collection(AppConstants.collectionUsers)
      //       .doc(userId)
      //       .update({
      //     AppConstants.fieldDailyQuestionCount: FieldValue.increment(1),
      //     AppConstants.fieldLastQuestionDate: Timestamp.now(),
      //   });
      //   _logger.debug('Question counter updated (update)', tag: 'DEVAICHAT');
      // } else {
      //   // Document doesn't exist, create it with initial values
      //   await FirebaseFirestore.instance
      //       .collection(AppConstants.collectionUsers)
      //       .doc(userId)
      //       .set({
      //     AppConstants.fieldDailyQuestionCount: 1,
      //     AppConstants.fieldLastQuestionDate: Timestamp.now(),
      //   }, SetOptions(merge: true));
      //   _logger.debug('Question counter created (set with merge)', tag: 'DEVAICHAT');
      // }
    } catch (e, stackTrace) {
      _logger.error('Question counter update error', tag: 'DEVAICHAT', error: e, stackTrace: stackTrace);
    }
  }

  /// Misafir kullanıcının bugün kaç soru sorduğunu döndürür.
  /// Gün değiştiyse sayaç otomatik olarak sıfırlanır.
  Future<int> _getGuestQuestionCountToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _todayKey();
      final storedDate = prefs.getString(_visitorDateKey);

      if (storedDate != todayKey) {
        // Yeni gün: sayaç sıfırlanır
        await prefs.setString(_visitorDateKey, todayKey);
        await prefs.setInt(_visitorCountKey, 0);
        return 0;
      }

      return prefs.getInt(_visitorCountKey) ?? 0;
    } catch (e) {
      _logger.error('Guest limit read error', tag: 'DEVAICHAT', error: e);
      return 0;
    }
  }

  /// Misafir soru sayacını 1 artırır.
  Future<void> _incrementGuestQuestionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await _getGuestQuestionCountToday();
      await prefs.setString(_visitorDateKey, _todayKey());
      await prefs.setInt(_visitorCountKey, current + 1);
    } catch (e) {
      _logger.error('Guest limit increment error', tag: 'DEVAICHAT', error: e);
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  void _showGuestLimitDialog() {
    _logger.userAction('Show guest limit dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.amber[700]),
            const SizedBox(width: 8),
            const Text('Günlük Misafir Limiti Doldu'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Misafir olarak günde $_visitorDailyLimit soru sorabilirsiniz.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              '✨ Ücretsiz hesap oluşturarak:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('• Daha fazla günlük soru hakkı'),
            const Text('• İlerlemeni kaydet'),
            const Text('• Oyunlara ve ödevlere eriş'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Hesap Oluştur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showProDialog() {
    _logger.userAction('Show Pro upgrade dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber[700]),
            const SizedBox(width: 8),
            const Text('Günlük Limit Aşıldı'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ücretsiz kullanıcılar günde ${AppConstants.dailyFreeQuestionLimit} soru sorabilir.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              '✨ Pro üyelik ile:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('• Sınırsız soru'),
            const Text('• Daha hızlı yanıtlar'),
            const Text('• Öncelikli destek'),
            const Text('• Özel özellikler'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _logger.userAction('Dismiss Pro dialog');
              Navigator.pop(context);
            },
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _logger.userAction('Click Pro upgrade button');
              Navigator.pop(context);
              _navigateToProPurchase();
            },
            icon: const Icon(Icons.workspace_premium, color: Colors.white),
            label: const Text('Pro Üyelik Al'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProPurchase() {
    // TODO: Pro üyelik sayfasına yönlendir
    _logger.userAction('Navigate to Pro purchase');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pro üyelik sistemi yakında aktif olacak!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Generate fallback response when API key is not available
  String _generateFallbackResponse(String message) {
    _logger.info('Using fallback response (no API key)', tag: 'DEVAICHAT');

    // API key olmadan basit yanıtlar
    if (message.contains('merhaba') || message.contains('selam')) {
      return 'Merhaba! Size nasıl yardımcı olabilirim? Robotik, kodlama veya ödevlerinizle ilgili sorularınızı cevaplayabilirim.\n\n💡 İpucu: Daha iyi yanıtlar için .env dosyasına Gemini API key ekleyin.';
    } else if (message.contains('arduino')) {
      return 'Arduino ile ilgili sorularınızı cevaplayabilirim! Arduino, elektronik projeler için harika bir platformdur. Sensörler, motorlar ve LED\'ler gibi birçok komponenti kontrol edebilirsiniz.\n\n💡 Gerçek AI yanıtları için API key gerekli.';
    } else if (message.contains('robot')) {
      return 'Robotik çok heyecan verici! Robot yapımında sensörler, motorlar ve programlama çok önemlidir.\n\n💡 Detaylı yardım için API key ekleyin.';
    } else {
      return 'İlginç bir soru! Daha detaylı cevaplar için .env dosyasına Google Gemini API key eklemelisiniz.\n\nÜcretsiz API key için: https://makersuite.google.com/app/apikey';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'DevAI Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _model != null ? Colors.greenAccent : Colors.orangeAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_model != null ? Colors.greenAccent : Colors.orangeAccent).withOpacity(0.8),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            if (_isTyping) _buildTypingIndicator(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text('Gemini AI Nasıl Aktifleştirilir?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '1. Google AI Studio\'ya gidin:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('https://makersuite.google.com/app/apikey'),
              const SizedBox(height: 16),
              const Text(
                '2. "Create API Key" butonuna tıklayın',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '3. API key\'i kopyalayın',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '4. .env dosyasını açın:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[200],
                child: const Text(
                  'GEMINI_API_KEY=buraya_yapıştırın',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '5. Uygulamayı yeniden başlatın',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gemini API tamamen ÜCRETSIZ!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.accentTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppTheme.primaryBlue
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryBlue,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.accentTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value * 3 - index).clamp(0.0, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      // Misafir modu: hesabı olmayan kullanıcılar için günlük 3 soru hakkı.
      // (Eskiden burada input tamamen gizleniyordu, misafirler hiç soru
      // soramıyordu - bu artık düzeltildi.)
      return FutureBuilder<int>(
        future: _getGuestQuestionCountToday(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildNormalMessageInput();
          }

          final guestCount = snapshot.data ?? 0;
          final remaining = _visitorDailyLimit - guestCount;

          if (remaining <= 0) {
            return _buildGuestLimitReachedButton();
          }
          return _buildNormalMessageInput(guestRemaining: remaining);
        },
      );
    }

    // Pro kullanıcılar için direkt mesaj girişi göster
    if (user.isPro) {
      return _buildNormalMessageInput();
    }

    // Ücretsiz kullanıcılar için limit kontrolü yap
    return FutureBuilder<bool>(
      future: _checkDailyLimit(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildNormalMessageInput(); // Loading sırasında normal input göster
        }

        final canAsk = snapshot.data ?? true;

        if (canAsk) {
          return _buildNormalMessageInput();
        } else {
          return _buildProUpgradeButton();
        }
      },
    );
  }

  Widget _buildNormalMessageInput({int? guestRemaining}) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (guestRemaining != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Misafir modu: bugün $guestRemaining soru hakkınız kaldı',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: loc.writeYourMessage,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.accentTeal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestLimitReachedButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[900], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Misafir olarak günlük $_visitorDailyLimit soru hakkınızı kullandınız',
                    style: TextStyle(
                      color: Colors.amber[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text(
                  'Hesap Oluştur - Devam Et',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProUpgradeButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[900], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Günlük soru limitiniz doldu',
                    style: TextStyle(
                      color: Colors.amber[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToProPurchase,
                icon: Icon(Icons.workspace_premium, color: Colors.white),
                label: const Text(
                  'Pro Üyelik Al - Sınırsız Soru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

