import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme.dart';
import '../constants/app_constants.dart';
import '../data/dev_assistant_knowledge.dart';
import '../services/dev_assistant_service.dart';
import '../services/input_validator.dart';
import '../services/logger_service.dart';
import '../utils/app_localizations.dart';
import '../ui/appear_in.dart';
import '../ui/kod_akintisi.dart';
import '../ui/motion.dart';
import '../utils/lang.dart';
import '../widgets/mascot.dart';

/// Devkom yardim asistani.
///
/// Bu ekran daha once Google Gemini'ye bagliydi. Uygulama 4-12 yas araligindaki
/// cocuklara yonelik ve App Store'da 4+ derecelendirmesiyle listeleniyor; serbest
/// metinli bir dil modeli hem ciktisi onceden bilinemeyen icerik hem de cocugun
/// yazdigi metnin ucuncu tarafa gonderilmesi anlamina geliyordu. Bu yuzden
/// asistan, elle yazilmis ve gozden gecirilmis cevaplardan olusan sabit bir bilgi
/// tabanina baglandi (bkz. data/dev_assistant_knowledge.dart).
///
/// Cevaplar cihazda uretildigi icin ag istegi, API anahtari ve gunluk soru
/// limiti yok - kullanici istedigi kadar soru sorabilir.
class DevAiChatScreen extends StatefulWidget {
  /// Ekran bir sekme icinde gomulu kullanildiginda geri butonu gizlenir.
  ///
  /// 1) Navigator.push ile ayri bir sayfa olarak acildiginda (showBackButton: true,
  ///    varsayilan) geri oku gosterilir.
  /// 2) Alt sekme cubugunun icinde gosterildiginde (showBackButton: false) ekranin
  ///    kendi route'u yoktur, geri oku basilirsa ana ekran kapanir.
  final bool showBackButton;

  const DevAiChatScreen({super.key, this.showBackButton = true});

  @override
  State<DevAiChatScreen> createState() => _DevAiChatScreenState();
}

class _DevAiChatScreenState extends State<DevAiChatScreen> {
  final _logger = LoggerService.instance;
  final _validator = InputValidator.instance;
  final _assistant = DevAssistantService.instance;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isTyping = false;

  /// En son cevabin altinda gosterilecek oneri butonlari.
  List<String> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _logger.info('DevAiChat screen initialized', tag: 'DEVAICHAT');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_messages.isEmpty) {
      final lang = _lang;
      _addMessage(
        ChatMessage(
          text: AppConstants.aiWelcomeMessageFor(lang),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      // Karsilama onerileri her acilista ayni dort soru olmasin diye
      // karistiriliyor; liste 32 soru iceriyor.
      final oneriler = List<String>.from(kSuggestedQuestionsFor(lang))
        ..shuffle();
      _suggestions = oneriler.take(4).toList();
    }
  }

  /// Ekranin dili. Bilgi tabani tr, en, de ve es destekliyor.
  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage({String? preset}) async {
    final userMessage = (preset ?? _messageController.text).trim();

    final validationError = _validator.validateMessage(userMessage);
    if (validationError != null) {
      _logger.warning('Message validation failed: $validationError', tag: 'DEVAICHAT');
      _showErrorSnackBar(validationError);
      return;
    }

    final securityError = _validator.performSecurityCheck(userMessage);
    if (securityError != null) {
      _logger.warning('Security check failed for message', tag: 'DEVAICHAT');
      _showErrorSnackBar(securityError);
      return;
    }

    final sanitizedMessage = _validator.sanitizeInput(userMessage);
    _logger.userAction('Send message',
        metadata: {'messageLength': sanitizedMessage.length});

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
      _suggestions = const [];
    });

    final reply = _assistant.reply(sanitizedMessage, lang: _lang);

    // Cevap aninda hazir; yazma animasyonunu gostermek icin kisa bir gecikme
    // birakiyoruz, aksi halde balon aniden beliriyor ve sohbet hissi kayboluyor.
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() {
      _isTyping = false;
    });

    _logger.info(
      'Assistant reply (matched: ${reply.matched})',
      tag: 'DEVAICHAT',
    );

    _addMessage(
      ChatMessage(
        text: reply.text,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    setState(() {
      _suggestions = reply.suggestions;
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      // Zemin duz bir mor gecisti. Arkada cok soluk kod simgeleri
      // suzuluyor: sohbet bir "kutu" degil, uygulamanin icinde bir yer
      // gibi duruyor (ayni desen ana sayfadaki kartlarda da var).
      child: KodAkintisi(
        kose: 0,
        opaklik: 0.07,
        yogunluk: 14,
        child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: widget.showBackButton,
          leading: widget.showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    // Ekstra guvenlik: pop edilebilecek bir route yoksa hicbir sey
                    // yapma; ana ekranin kapanip siyah ekran kalmasini engeller.
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                )
              : null,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Asistanin yuzu uygulamanin maskotu: cocuk burada
                    // yabanci bir robot ikonuyla degil, tanidigi
                    // arkadasiyla konusuyor.
                    const Mascot(size: 26, showShadow: false),
                    const SizedBox(width: 8),
                    const Text(
                      'DevAI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    _StatusDot(),
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
                itemBuilder: (context, index) =>
                    _buildMessageBubble(_messages[index]),
              ),
            ),
            if (_isTyping) _buildTypingIndicator(),
            if (_suggestions.isNotEmpty && !_isTyping) _buildSuggestions(),
            _buildMessageInput(),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ONERILERIN NE OLDUGU YAZMIYORDU.
          //
          // Dort gri kutucuk alt alta duruyordu; cocuk bunlarin
          // dokunulabilir SORULAR oldugunu anlamak zorunda kaliyordu.
          // Tek satirlik baslik bunu soyluyor.
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Text(
              AppLang.pick(_lang,
                  tr: 'Şunu sorabilirsin',
                  en: 'You could ask',
                  de: 'Du könntest fragen',
                  es: 'Puedes preguntar'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _suggestions.length; i++)
                AppearIn(
                  delay: Duration(milliseconds: 60 * i),
                  offset: 10,
                  child: _SuggestionChip(
                    label: _suggestions[i],
                    onTap: () => _sendMessage(preset: _suggestions[i]),
                  ),
                ),
            ],
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
            const _AssistantAvatar(),
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
                    color: message.isUser ? AppTheme.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
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
          const _AssistantAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                _TypingDot(0),
                SizedBox(width: 4),
                _TypingDot(1),
                SizedBox(width: 4),
                _TypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
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
            // BOS MESAJDA TUS PASIF.
            //
            // Once her zaman renkliydi ve bos kutuyla basildiginda
            // dogrulama hatasi olarak kirmizi bir serit cikiyordu —
            // cocuga hata gostermek yerine tusu kapatmak dogru olan.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _messageController,
              builder: (context, value, _) {
                final dolu = value.text.trim().isNotEmpty;
                return AnimatedContainer(
                  duration: Motion.short4,
                  decoration: BoxDecoration(
                    gradient: dolu
                        ? const LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.accentTeal
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: dolu ? null : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: AppLang.pick(_lang,
                        tr: 'Gönder',
                        en: 'Send',
                        de: 'Senden',
                        es: 'Enviar'),
                    icon: Icon(Icons.send,
                        color: dolu ? Colors.white : Colors.grey.shade500),
                    onPressed: dolu ? () => _sendMessage() : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Mesaj saati. ONCE TAMAMEN TURKCEYDI: Almanca secen bir cocuk
  /// balonun altinda "5 dk önce" goruyordu.
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppLang.pick(_lang,
          tr: 'Şimdi', en: 'Just now', de: 'Gerade eben', es: 'Ahora mismo');
    } else if (difference.inHours < 1) {
      final d = difference.inMinutes;
      return AppLang.pick(_lang,
          tr: '$d dk önce',
          en: '$d min ago',
          de: 'vor $d Min.',
          es: 'hace $d min');
    } else if (difference.inDays < 1) {
      final h = difference.inHours;
      return AppLang.pick(_lang,
          tr: '$h saat önce',
          en: '$h h ago',
          de: 'vor $h Std.',
          es: 'hace $h h');
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Baslikta asistanin hazir oldugunu gosteren nokta.
///
/// Cevaplar cihazda uretildigi icin asistan her zaman hazir; eskiden burada
/// API anahtarinin gecerli olup olmadigina gore renk degisiyordu.
/// Oneri butonu.
///
/// ActionChip yerine elle yazildi: Material 3 ChipTheme'i uygulamanin acik
/// temasinda zemini beyaza cekiyor ve beyaz etiketle birlesince yazi
/// okunamiyordu. Burada zemin ve yazi rengi dogrudan kontrol ediliyor.
class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withValues(alpha: 0.8),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      // Balonun yanindaki yuz de Devi: sohbetin kiminle oldugu her
      // satirda belli.
      child: const Center(child: Mascot(size: 30, showShadow: false)),
    );
  }
}

class _TypingDot extends StatelessWidget {
  final int index;

  const _TypingDot(this.index);

  @override
  Widget build(BuildContext context) {
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
