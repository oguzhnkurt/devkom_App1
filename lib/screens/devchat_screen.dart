import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../ui/motion.dart';
import '../utils/lang.dart';
import '../widgets/devi_gokyuzu.dart';
import '../widgets/mascot.dart';
import 'devai/devi_yz_dersi.dart';

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

  /// Ekran acilinca otomatik sorulacak soru (ana sayfadaki "Devi'ye sor"
  /// karti). Null ise sohbet bos baslar.
  final String? ilkSoru;

  /// Ilk giriste Devi'nin yapay zeka dersini kendiliginden ac. Yalnizca
  /// alt cubuktaki DevAI sekmesi veriyor (AnaSekmeler); "Devi'ye sor"
  /// kartindan soru ile gelen cocugu derse sokmuyoruz, cevabini bekliyor.
  final bool dersiOtomatikAc;

  const DevAiChatScreen({
    super.key,
    this.showBackButton = true,
    this.ilkSoru,
    this.dersiOtomatikAc = false,
  });

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
    // Yeni sohbet, yeni oneri gecmisi. Servis bir tekil (singleton) ve
    // hangi onerileri gosterdigini hatirliyor; ekran her acildiginda
    // sifirlanmazsa cocuk bir sonraki sohbete "az once gordugum uclu
    // yine mi" diye basliyor.
    _assistant.sohbetiSifirla();
    _logger.info('DevAiChat screen initialized', tag: 'DEVAICHAT');
    WidgetsBinding.instance.addPostFrameCallback((_) => _dersDurumu());
  }

  /// Yapay zeka dersinin rozeti alindi mi?
  bool _rozet = false;

  Future<void> _dersDurumu() async {
    final bitti = await DeviYzDersi.bitti();
    if (!mounted) return;
    if (bitti != _rozet) setState(() => _rozet = bitti);
    final ilk = widget.ilkSoru;
    if (widget.dersiOtomatikAc &&
        (ilk == null || ilk.trim().isEmpty) &&
        !await DeviYzDersi.goruldu() &&
        mounted) {
      _dersiAc();
    }
  }

  /// Devi'nin yapay zeka dersi. Bitince sohbete bir "esinti" birakiyor:
  /// tebrik mesaji ve yapay zeka sorulari.
  Future<void> _dersiAc() async {
    FocusScope.of(context).unfocus();
    final sonuc = await DeviYzDersi.ac(context);
    if (!mounted) return;
    final bitti = await DeviYzDersi.bitti();
    if (!mounted) return;
    final ilkKez = bitti && !_rozet;
    setState(() => _rozet = bitti);
    if (ilkKez) {
      _addMessage(ChatMessage(
        text: AppLang.pick(_lang,
            tr: 'Tebrikler, Yapay Zekâ Kâşifi! 🏅 Artık yapay zekânın örneklerden '
                'öğrendiğini biliyorsun. Merak ettiğin her şeyi bana sorabilirsin!',
            en: 'Congrats, AI Explorer! 🏅 Now you know AI learns from examples. '
                'Ask me anything you are curious about!',
            de: 'Glückwunsch, KI-Entdecker! 🏅 Jetzt weißt du, dass KI aus '
                'Beispielen lernt. Frag mich alles, was dich interessiert!',
            es: '¡Enhorabuena, Explorador de IA! 🏅 Ya sabes que la IA aprende de '
                'ejemplos. ¡Pregúntame lo que quieras!'),
        isUser: false,
        timestamp: DateTime.now(),
      ));
      setState(() => _suggestions = [
            for (final id in [
              'ai_ogrenme',
              'ai_nerede',
              'ai_hata',
              'ai_guvenlik'
            ])
              if (_assistant.etiket(id, _lang) case final e?) e,
          ]);
    }
    if (sonuc != null && sonuc.trim().isNotEmpty) {
      _sendMessage(preset: sonuc);
    }
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
      final ilk = widget.ilkSoru;
      if (ilk != null && ilk.trim().isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _sendMessage(preset: ilk);
        });
      }
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
    // KLAVYE ACIK KALIYORDU. Cocuk once yazi kutusuna dokunup sonra
    // hazir bir soruya basinca klavye ekranda kaliyor, alttaki menu
    // cubugunu ortuyordu; kapatmanin bir yolu da yoktu, ana sayfaya
    // donemiyordu. Hazir soruya basmak "yazmayi birakti" demek.
    if (preset != null) FocusScope.of(context).unfocus();
    final userMessage = (preset ?? _messageController.text).trim();

    final validationError = _validator.validateMessage(userMessage);
    if (validationError != null) {
      _logger.warning('Message validation failed: $validationError',
          tag: 'DEVAICHAT');
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
    // ZEMIN: Devi'nin gokyuzu. Eskiden duz bir mor gecisin ustunde soluk
    // kod simgeleri vardi; simdi yavasca nefes alan bir "sinir agi
    // takimyildizi" — yapay zeka fikrini gorsel olarak tasiyor, yaziyi
    // bastirmayacak kadar soluk.
    return DeviGokyuzu(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
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
          titleSpacing: widget.showBackButton ? 0 : 16,
          title: Row(
            children: [
              // Asistanin yuzu uygulamanin maskotu: cocuk burada
              // yabanci bir robot ikonuyla degil, tanidigi arkadasiyla
              // konusuyor.
              const Mascot(size: 34, showShadow: false),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'DevAI',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        if (_rozet)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text('🏅', style: TextStyle(fontSize: 15)),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _StatusDot(),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            AppLang.pick(_lang,
                                tr: 'Devi burada',
                                en: 'Devi is here',
                                de: 'Devi ist da',
                                es: 'Devi está aquí'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _CamHap(
                key: const ValueKey('yz_dersi_dugmesi'),
                onTap: _dersiAc,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎓', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 5),
                    Text(
                      AppLang.pick(_lang,
                          tr: 'YZ dersi',
                          en: 'AI lesson',
                          de: 'KI-Lektion',
                          es: 'Clase IA'),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              // Mesajlara dokunmak ya da kaydirmak klavyeyi kapatiyor:
              // iOS klavyesinde "kapat" tusu yok.
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.translucent,
                child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: _messages.length + 1,
                  itemBuilder: (context, index) => index == 0
                      ? _buildKarsilama()
                      : AppearIn(
                          key: ObjectKey(_messages[index - 1]),
                          offset: 14,
                          child: _buildMessageBubble(_messages[index - 1]),
                        ),
                ),
              ),
            ),
            if (_isTyping) _buildTypingIndicator(),
            if (_suggestions.isNotEmpty && !_isTyping) _buildSuggestions(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  /// Sohbetin en ustundeki tanisma karti: buyuk Devi ve uc kisa soz.
  /// Dokununca Devi zipliyor; "Yapay zeka dersi" hapi dersi aciyor.
  Widget _buildKarsilama() {
    String t(String tr, String en, String de, String es) =>
        AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.20),
              Colors.white.withValues(alpha: 0.07),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Mascot(
              size: 86,
              onTap: () => HapticFeedback.lightImpact(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(
                        'Kodlama arkadaşın Devi',
                        'Devi, your coding buddy',
                        'Devi, dein Coding-Kumpel',
                        'Devi, tu compañero de código'),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _ozellik(t('💬 Sınırsız soru', '💬 Unlimited questions',
                          '💬 Unbegrenzt fragen', '💬 Preguntas sin límite')),
                      _ozellik(t(
                          '🔒 Telefonunda kalır',
                          '🔒 Stays on your phone',
                          '🔒 Bleibt auf dem Handy',
                          '🔒 Se queda en tu móvil')),
                      GestureDetector(
                        key: const ValueKey('yz_dersi_hapi'),
                        onTap: _dersiAc,
                        child: _ozellik(
                          _rozet
                              ? t('🏅 YZ Kâşifi', '🏅 AI Explorer',
                                  '🏅 KI-Entdecker', '🏅 Explorador IA')
                              : t('🎓 Yapay zekâ dersi', '🎓 AI lesson',
                                  '🎓 KI-Lektion', '🎓 Clase de IA'),
                          vurgu: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ozellik(String yazi, {bool vurgu = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: vurgu
              ? const Color(0xFFFFD54F)
              : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          yazi,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: vurgu ? const Color(0xFF4A2A00) : Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _buildSuggestions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                fontFamily: AppTheme.fontFamily,
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w800,
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
    final ben = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            ben ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!ben) ...[
            const _AssistantAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  ben ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    // Cocugun balonu Devi'nin turuncusundan pembeye; Devi'nin
                    // balonu beyaz. Kim konusuyor, renkten belli.
                    gradient: ben
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF9A3D), Color(0xFFFF5E8A)],
                          )
                        : null,
                    color: ben ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(ben ? 20 : 6),
                      bottomRight: Radius.circular(ben ? 6 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (ben ? const Color(0xFFFF5E8A) : Colors.black)
                            .withValues(alpha: ben ? 0.35 : 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: ben ? Colors.white : const Color(0xFF2A2346),
                      fontSize: 15,
                      height: 1.42,
                      fontWeight: ben ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  // Gri, mor zeminde okunmuyordu.
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          const _AssistantAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const _YaziyorNoktalari(),
          ),
        ],
      ),
    );
  }

  /// Rastgele bir hazir soru. Ne soracagini bilmeyen cocuk icin zar.
  void _zarAt() {
    HapticFeedback.selectionClick();
    final liste = List<String>.from(kSuggestedQuestionsFor(_lang))..shuffle();
    if (liste.isNotEmpty) _sendMessage(preset: liste.first);
  }

  Widget _buildMessageInput() {
    final loc = AppLocalizations.of(context);
    // Yazi kutusu artik ekranin altina yapisik beyaz bir serit degil:
    // gokyuzunun ustunde yuzen yuvarlak bir kapsul.
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                key: const ValueKey('devi_zar'),
                tooltip: AppLang.pick(_lang,
                    tr: 'Sürpriz soru',
                    en: 'Surprise question',
                    de: 'Überraschungsfrage',
                    es: 'Pregunta sorpresa'),
                onPressed: _isTyping ? null : _zarAt,
                icon:
                    const Icon(Icons.casino_rounded, color: Color(0xFF7C4DFF)),
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: loc.writeYourMessage,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 4),
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
                              colors: [Color(0xFFFF9A3D), Color(0xFFFF5E8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: dolu ? null : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: AppLang.pick(_lang,
                          tr: 'Gönder', en: 'Send', de: 'Senden', es: 'Enviar'),
                      icon: Icon(Icons.send,
                          color: dolu ? Colors.white : Colors.grey.shade400),
                      onPressed: dolu ? () => _sendMessage() : null,
                    ),
                  );
                },
              ),
            ],
          ),
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
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Baslikta yari saydam, dokunulabilir hap.
class _CamHap extends StatelessWidget {
  const _CamHap({super.key, required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withValues(alpha: 0.16),
        shape: StadiumBorder(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.35))),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: child,
          ),
        ),
      );
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withValues(alpha: 0.8),
            blurRadius: 6,
            spreadRadius: 1,
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      // Balonun yanindaki yuz de Devi: sohbetin kiminle oldugu her
      // satirda belli.
      child: const Center(child: Mascot(size: 30, showShadow: false)),
    );
  }
}

/// "Devi yaziyor" noktalari. Eskiden bir kez belirip duruyordu; artik
/// sirayla ziplayarak donuyor.
class _YaziyorNoktalari extends StatefulWidget {
  const _YaziyorNoktalari();

  @override
  State<_YaziyorNoktalari> createState() => _YaziyorNoktalariState();
}

class _YaziyorNoktalariState extends State<_YaziyorNoktalari>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 5),
              Transform.translate(
                offset: Offset(
                    0,
                    -5 *
                        math.max(0.0,
                            math.sin((_c.value - i * 0.18) * math.pi * 2))),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C4DFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
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
