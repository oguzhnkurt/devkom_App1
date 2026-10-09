import 'package:flutter/material.dart';
import '../../widgets/oyun_basligi.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/millionaire_question.dart';
import '../../services/millionaire_questions_service.dart';
import '../../services/millionaire_firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import '../../services/user_progress_service.dart';
import '../../widgets/pro_paywall.dart';
import '../../utils/lang.dart';
import '../../models/game_model.dart';
import '../../theme.dart';
import '../../ui/answer_feedback.dart';
import '../../ui/motion.dart';
import '../../ui/press_button.dart';
import '../../widgets/oyun_cipleri.dart';
import '../../widgets/oyun_kimligi.dart';

/// Ücretsiz kullanıcıların Pro'ya geçmeden oynayabileceği soru sayısı.
/// Bu sayıya ulaşınca (doğru cevapladıktan sonra) oyunu devam ettirmek
/// için Pro paywall gösterilir.
const int kMillionaireFreeQuestionLimit = 3;

class MillionaireGameScreen extends StatefulWidget {
  const MillionaireGameScreen({super.key});

  @override
  State<MillionaireGameScreen> createState() => _MillionaireGameScreenState();
}

class _MillionaireGameScreenState extends State<MillionaireGameScreen> {
  final MillionaireFirestoreService _firestoreService =
      MillionaireFirestoreService();
  List<MillionaireQuestion> _questions = [];
  final List<int> _prizeTree = MillionaireQuestionsService.getPrizeTree();
  final JokerState _jokerState = JokerState();
  final ScrollController _prizeScrollController = ScrollController();

  bool _isLoading = true;
  String? _errorMessage;

  int _currentQuestionIndex = 0;

  /// Kac soruyu DOGRU bildi. Odul merdiveni buna gore yukseliyor.
  ///
  /// Onceki surumde merdiven `_currentQuestionIndex`'e bakiyordu: yanlis
  /// cevaplayan cocuk da bir basamak yukari cikiyor, sonraki soruyu
  /// bilince bilemedigi basamagin parasini da almis oluyordu. Yani
  /// "yanlis cevapladigim halde para kazanmaya devam ediyorum".
  int _correctCount = 0;

  int? _selectedAnswer;
  bool _showingResult = false;
  bool _gameOver = false;
  int _currentPrize = 0;
  Set<int> _hiddenOptions = {};
  Map<int, int>? _audienceVotes;
  String? _phoneAnswer;

  MillionaireQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  /// Uygulamanın o an ayarlı dili ('tr' veya 'en').
  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  ///
  /// Onceki surumde her yerde `_isEn ? ingilizce : turkce` vardi; almanca
  /// ya da ispanyolca secen cocuk oyunun tamamini turkce goruyordu.
  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (bilgi yarismasi). Sesler oyundan oyuna
    // degisiyor; ayni tonu her yerde calmak oyunlari birbirinden
    // ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.bright);
    _loadQuestions();
  }

  @override
  void dispose() {
    _prizeScrollController.dispose();
    super.dispose();
  }

  /// Odul merdiveninde bir basamagin genisligi (ListView itemExtent).
  static const double _basamakGenisligi = 104;

  void _scrollToPrize() {
    if (_prizeScrollController.hasClients) {
      // Basamaklar sabit genislikte; siradaki basamak soldan ikinci
      // sirada dursun ki cocuk bir onceki (kazandigi) basamagi da gorsun.
      final pos = _prizeScrollController.position;
      final offset = ((_correctCount - 1) * _basamakGenisligi)
          .clamp(0.0, pos.maxScrollExtent);
      _prizeScrollController.animateTo(
        offset,
        duration: Motion.adapt(context, Motion.long2),
        curve: Motion.emphasized,
      );
    }
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Rastgele soru çek (uzak sunucu boşsa yerel soru bankasını kullan)
      final questions = await _firestoreService.getRandomQuestions();

      setState(() {
        _questions = questions.isNotEmpty
            ? questions.cast<MillionaireQuestion>()
            : MillionaireQuestionsService.getGameQuestions();
        _isLoading = false;
      });
    } catch (e) {
      // Cocuga ham istisna metni gosterilmiyor: ekranda
      // "Exception: ... SocketException ..." yaziyordu. Ayrinti gelistirici
      // gunlugune gidiyor, cocuk ne yapacagini anlatan bir cumle goruyor.
      debugPrint('Millionaire question load failed: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = _tl('Sorular yüklenemedi. İnternet bağlantını kontrol edip '
                'tekrar dene.', 'Questions could not be loaded. Check your internet '
                'connection and try again.', 'Die Fragen konnten nicht geladen werden. Prüfe deine Internetverbindung und versuch es noch mal.', 'No se pudieron cargar las preguntas. Revisa tu conexión a internet e inténtalo de nuevo.');
      });
    }
  }

  /// Bilgi Yarismasi'nin kimlik rengi (oyunlar sekmesindeki kartla ayni).
  static final Color _renk = OyunKimligi.renk(GameType.quiz);

  /// Siklarin renkleri: oyunlardaki cevap kartlariyla (OyunCevapKarti)
  /// ayni sira. Eskiden dort sik da ayni lacivert kutuydu; cocuk hangisine
  /// bastigini ayirt etmekte zorlaniyordu.
  static const List<Color> _sikRenkleri = [
    Color(0xFFFF6B6B),
    Color(0xFF4D96FF),
    Color(0xFFFFA726),
    Color(0xFF26C6A6),
  ];

  static const Color _dogruRenk = Color(0xFF43A047);
  static const Color _yanlisRenk = Color(0xFFE53935);

  /// Her sorunun sonucu (dogru/yanlis), ust taraftaki noktalar icin.
  final List<bool> _sonuclar = [];

  Widget _iskele(Widget govde) {
    // Eskiden koyu lacivert bir "TV yarismasi" ekraniydi ve OyunBasligi'ni
    // kimlik rengi yerine elle verilen koyu bir renkle ciziyordu: oyunlar
    // sekmesinde turuncu karta dokunan cocuk siyah bir ekrana dusuyordu.
    return Scaffold(
      backgroundColor: OyunZemini.ustRenk(_renk),
      appBar: OyunBasligi.oyun(
        GameType.quiz,
        baslikWidget: Text(_tl('Bilgi Yarışması', 'Knowledge Quiz',
            'Wissensquiz', 'Concurso de conocimiento')),
      ),
      body: OyunZemini(renk: _renk, child: govde),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _iskele(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _renk),
              const SizedBox(height: 20),
              Text(
                _tl('Sorular yükleniyor...', 'Loading questions...', 'Fragen werden geladen ...', 'Cargando las preguntas...'),
                style: const TextStyle(
                    color: AppTheme.darkGray, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return _iskele(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, color: _yanlisRenk, size: 80),
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                      color: AppTheme.darkGray, fontSize: 16, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                PressButton(
                  label: _tl('Tekrar Dene', 'Try Again', 'Noch mal versuchen', 'Intentar de nuevo'),
                  icon: Icons.refresh_rounded,
                  color: _renk,
                  onPressed: _loadQuestions,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return _iskele(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_rounded, color: _renk, size: 80),
                const SizedBox(height: 20),
                Text(
                  _tl('Henüz soru eklenmemiş', 'No questions added yet', 'Es wurden noch keine Fragen hinzugefügt', 'Todavía no hay preguntas'),
                  style: const TextStyle(
                      color: AppTheme.darkGray, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                PressButton(
                  label: _tl('Geri Dön', 'Go Back', 'Zurück', 'Volver'),
                  icon: Icons.arrow_back_rounded,
                  color: _renk,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _iskele(
      SafeArea(
        top: false,
        child: _gameOver ? _buildGameOverScreen() : _buildGameScreen(),
      ),
    );
  }

  /// Ust serit: soru noktalari ve o anki odul.
  Widget _ilerlemeSeridi() {
    final toplam = _questions.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: OyunCipi(
              key: const ValueKey('yarisma_cip_soru'),
              simge: Icons.help_rounded,
              etiket: _tl('Soru', 'Question', 'Frage', 'Pregunta'),
              deger: Text('${_currentQuestionIndex + 1}/$toplam'),
              renk: _renk,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OyunCipi(
              key: const ValueKey('yarisma_cip_dogru'),
              simge: Icons.check_rounded,
              etiket: _tl('Doğru', 'Correct', 'Richtig', 'Aciertos'),
              deger: Text('$_correctCount'),
              renk: _dogruRenk,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OyunCipi(
              key: const ValueKey('yarisma_cip_odul'),
              simge: Icons.emoji_events_rounded,
              etiket: _tl('Ödül', 'Prize', 'Gewinn', 'Premio'),
              deger: Text(MillionaireQuestionsService.formatPrize(_currentPrize, lang: _lang)),
              renk: const Color(0xFFFFA000),
            ),
          ),
        ],
      ),
    );
  }

  /// Soru noktalari: yesil dogru, kirmizi yanlis, turuncu halka siradaki.
  Widget _soruNoktalari() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: List.generate(_questions.length, (i) {
        final cevaplandi = i < _sonuclar.length;
        final simdiki = i == _currentQuestionIndex && !cevaplandi;
        final renk = cevaplandi
            ? (_sonuclar[i] ? _dogruRenk : _yanlisRenk)
            : Colors.white;
        return AnimatedContainer(
          duration: Motion.adapt(context, Motion.medium2),
          width: simdiki ? 26 : 18,
          height: 18,
          decoration: BoxDecoration(
            color: renk,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: simdiki
                  ? _renk
                  : cevaplandi
                      ? renk
                      : _renk.withValues(alpha: 0.25),
              width: simdiki ? 2.5 : 1.5,
            ),
          ),
          child: cevaplandi
              ? Icon(_sonuclar[i] ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white, size: 12)
              : null,
        );
      }),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        _ilerlemeSeridi(),
        const SizedBox(height: 10),

        // Para Ağacı: soldan saga tirmanan basamaklar.
        SizedBox(
          height: 46,
          child: ListView.builder(
            controller: _prizeScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemExtent: _basamakGenisligi,
            itemCount: _prizeTree.length,
            itemBuilder: (context, index) {
              final isPast = index < _correctCount;
              final isCurrent = index == _correctCount;
              final prize = _prizeTree[index];

              return AnimatedContainer(
                duration: Motion.adapt(context, Motion.medium2),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  gradient: isCurrent
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFFA000)])
                      : null,
                  color: isCurrent
                      ? null
                      : isPast
                          ? _dogruRenk.withValues(alpha: 0.14)
                          : Colors.white.withValues(alpha: 0.85),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFFFFA000)
                        : isPast
                            ? _dogruRenk.withValues(alpha: 0.5)
                            : _renk.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFFA000).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPast)
                        const Padding(
                          padding: EdgeInsets.only(right: 3),
                          child: Icon(Icons.check_rounded, size: 14, color: _dogruRenk),
                        ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            MillionaireQuestionsService.formatPrize(prize, lang: _lang),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              // Sari zeminde beyaz yazi okunmuyordu.
                              color: isCurrent
                                  ? const Color(0xFF5D3A00)
                                  : isPast
                                      ? const Color(0xFF2E7D32)
                                      : AppTheme.darkGray,
                              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Soru
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _soruNoktalari(),
                const SizedBox(height: 12),
                // Soru Numarası ve Metni
                Container(
                  key: const ValueKey('yarisma_soru_karti'),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: _renk.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: _renk.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _tl('Soru ${_currentQuestionIndex + 1}', 'Question ${_currentQuestionIndex + 1}', 'Frage ${_currentQuestionIndex + 1}', 'Pregunta ${_currentQuestionIndex + 1}'),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Color.lerp(_renk, Colors.black, 0.2),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentQuestion.questionFor(_lang),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Color(0xFF26233A),
                          fontSize: 21,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Soru Görseli
                      if (_currentQuestion.imageUrl != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: _currentQuestion.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: _renk.withValues(alpha: 0.08),
                              child: Center(
                                child: CircularProgressIndicator(color: _renk),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: _renk.withValues(alpha: 0.08),
                              child: const Icon(Icons.image_not_supported,
                                  color: AppTheme.mediumGray),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Telefon Joker Cevabı
                // Telefon jokerinin cevabi da siklari asagi itiyordu.
                // Bunu kaldiramayiz (kutu gercekten yer kapliyor) ama
                // ani sicrama yerine yumusak bir acilisa cevirebiliriz.
                AnimatedSize(
                  duration: Motion.adapt(context, Motion.medium1),
                  curve: Motion.emphasized,
                  alignment: Alignment.topCenter,
                  child: _phoneAnswer == null
                      ? const SizedBox(width: double.infinity)
                      : Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: const Color(0xFF4D96FF).withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_in_talk_rounded,
                                  color: Color(0xFF1E88E5)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _phoneAnswer!,
                                  style: const TextStyle(
                                    color: Color(0xFF0D47A1),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                // Seçenekler
                ...List.generate(4, (index) => _sikKarti(index)),

                const SizedBox(height: 14),

                // FINAL CEVAP TUSU VE KAYMA:
                //
                // Bu tus daha once yalnizca bir sik secilince agaca
                // EKLENIYORDU. Eklendigi anda altindaki joker satiri ve
                // odul agaci bir tus boyu asagi kayiyordu; cocuk sikka
                // dokunup parmagini kaldirdiginda ekran yerinden
                // oynuyordu. Simdi tus her zaman ekranda: sik
                // secilmeden once sonuk ve basilamaz, secilince
                // canlaniyor. Hem kayma yok, hem de cocuk bir sonraki
                // adimin ne oldugunu bastan goruyor.
                //
                // Cevap acilinca ayni yerde (ayni yukseklikte) sonuc
                // seridi duruyor: dogru mu, yanlissa dogrusu hangisi.
                SizedBox(
                  height: 62,
                  child: AnimatedSwitcher(
                    duration: Motion.adapt(context, Motion.medium2),
                    child: _showingResult
                        ? _sonucSeridi()
                        : PressButton(
                            key: const ValueKey('yarisma_final'),
                            label: _selectedAnswer == null
                                ? (_tl('BİR ŞIK SEÇ', 'PICK AN ANSWER', 'WÄHLE EINE ANTWORT', 'ELIGE UNA RESPUESTA'))
                                : (_tl('FİNAL CEVAP', 'FINAL ANSWER', 'ENDGÜLTIGE ANTWORT', 'RESPUESTA FINAL')),
                            icon: Icons.check_circle_rounded,
                            color: _renk,
                            onPressed: _selectedAnswer != null && !_showingResult
                                ? _confirmAnswer
                                : null,
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Joker Butonları
                Row(
                  children: [
                    Expanded(
                      child: _buildJokerButton(
                        JokerType.fiftyFifty,
                        '50:50',
                        Icons.pie_chart_rounded,
                        const Color(0xFFFF8F00),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildJokerButton(
                        JokerType.phone,
                        _tl('Telefon', 'Phone', 'Telefon', 'Teléfono'),
                        Icons.phone_rounded,
                        const Color(0xFF1E88E5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildJokerButton(
                        JokerType.audience,
                        _tl('Seyirci', 'Audience', 'Publikum', 'Público'),
                        Icons.people_rounded,
                        const Color(0xFF8E24AA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tek bir sik. Renkli harf rozeti, beyaz kart; secilince sikkin
  /// renginde dolar, cevap acilinca yesil/kirmizi olur.
  Widget _sikKarti(int index) {
    final option = _currentQuestion.optionsFor(_lang)[index];
    final letter = String.fromCharCode(65 + index); // A, B, C, D
    final isHidden = _hiddenOptions.contains(index);
    final isSelected = _selectedAnswer == index;
    final sikRengi = _sikRenkleri[index];

    // 50:50 JOKERI VE KAYMA:
    //
    // Gizlenen sik burada 60 piksellik bos bir kutuya
    // donusuyordu; gercek sik ise ic dolgusu ve kenar
    // bosluklariyla bunun epey uzerinde. Yani joker
    // kullanildigi anda altindaki iki sik yukari
    // kayiyordu — cocuk parmagini indirirken sik yerinden
    // oynuyor. Artik sik AYNI widget olarak kaliyor,
    // sadece gorunmez ve dokunulamaz oluyor; boylece
    // kapladigi yer piksel piksel ayni.

    // DOGRU SIK HIC GOSTERILMIYORDU.
    //
    // Yalnizca secilen sik yesile ya da kirmiziya donuyordu;
    // yanlis cevaplayan cocuk dogrunun hangisi oldugunu
    // ogrenemiyordu. Artik cevap acildiginda dogru sik her
    // zaman yesil, secilen yanlis sik kirmizi oluyor.
    final isCorrectOption = index == _currentQuestion.correctAnswerIndex;
    Color buttonColor = Colors.white;
    if (_showingResult && isCorrectOption) {
      buttonColor = _dogruRenk;
    } else if (_showingResult && isSelected) {
      buttonColor = _yanlisRenk;
    } else if (isSelected) {
      buttonColor = sikRengi;
    }
    final dolu = buttonColor != Colors.white;
    final yanlisSecim = _showingResult && isSelected && !isCorrectOption;
    // Cevap acilinca ilgisiz siklar soluyor: goz dogruya ve yanlisa gitsin.
    final soluk = _showingResult && !isCorrectOption && !isSelected;

    return IgnorePointer(
      ignoring: isHidden,
      child: AnimatedOpacity(
        opacity: isHidden ? 0 : (soluk ? 0.45 : 1),
        duration: Motion.adapt(context, Motion.short4),
        child: ShakeOnChange(
          // Yanlis secilen sik "hayir" der gibi sallaniyor.
          trigger: yanlisSecim ? _currentQuestionIndex : null,
          child: AnimatedScale(
            scale: _showingResult && isCorrectOption
                ? 1.03
                : isSelected && !_showingResult
                    ? 1.02
                    : 1,
            duration: Motion.adapt(context, Motion.medium2),
            curve: Motion.overshoot,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey('yarisma_sik_$index'),
                  onTap: _showingResult ? null : () => _selectAnswer(index),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: Motion.adapt(context, Motion.medium1),
                    constraints: const BoxConstraints(minHeight: 64),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: dolu
                            ? Color.lerp(buttonColor, Colors.black, 0.15)!
                            : sikRengi.withValues(alpha: 0.35),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (dolu ? buttonColor : sikRengi)
                              .withValues(alpha: dolu ? 0.35 : 0.14),
                          blurRadius: dolu ? 14 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Harf
                        AnimatedContainer(
                          duration: Motion.adapt(context, Motion.medium1),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: dolu ? Colors.white : sikRengi,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                color: dolu ? buttonColor : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Seçenek
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: dolu ? Colors.white : const Color(0xFF26233A),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        // SEYIRCI OYU VE KAYMA:
                        //
                        // Yuzde rozeti joker kullanilinca sikkin
                        // satirina EKLENIYORDU. Sik metni tek
                        // satirla sinirli degil; rozet gelince
                        // metin daralip iki satira tasiyor ve
                        // altindaki butun sikler asagi kayiyordu.
                        // Rozetin yeri artik bastan ayrilmis:
                        // gorunmezken de ayni genisligi kapliyor.
                        Opacity(
                          opacity: _audienceVotes?.containsKey(index) ?? false ? 1 : 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8E24AA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '%${_audienceVotes?[index] ?? 0}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        // Renk tek basina yeterli degil: renk
                        // korlugu olan cocuk yesil ile kirmiziyi
                        // ayirt edemez. Isaret de koyuluyor.
                        // Yeri bastan ayrildigi icin kayma yok.
                        Opacity(
                          opacity: _showingResult && (isCorrectOption || isSelected) ? 1 : 0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              isCorrectOption
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Cevap acilinca final tusunun yerinde duran serit.
  Widget _sonucSeridi() {
    final dogru = _selectedAnswer == _currentQuestion.correctAnswerIndex;
    final dogruHarf =
        String.fromCharCode(65 + _currentQuestion.correctAnswerIndex);
    final renk = dogru ? _dogruRenk : _yanlisRenk;
    return Container(
      key: ValueKey('yarisma_sonuc_$dogru'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color.lerp(renk, Colors.white, 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: renk.withValues(alpha: 0.6), width: 2),
      ),
      child: Row(
        children: [
          Icon(dogru ? Icons.celebration_rounded : Icons.lightbulb_rounded,
              color: renk, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              dogru
                  ? _tl('Doğru! Bir basamak yükseldin.', 'Correct! You climbed one step.',
                      'Richtig! Du bist eine Stufe höher.', '¡Correcto! Subiste un escalón.')
                  : _tl('Doğru cevap: $dogruHarf', 'The right answer: $dogruHarf',
                      'Die richtige Antwort: $dogruHarf', 'La respuesta correcta: $dogruHarf'),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color.lerp(renk, Colors.black, 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJokerButton(
      JokerType type, String label, IconData icon, Color color) {
    final isUsed = _jokerState.isUsed(type);

    return AnimatedOpacity(
      duration: Motion.adapt(context, Motion.short4),
      opacity: isUsed ? 0.45 : 1.0,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: isUsed || _showingResult ? null : () => _useJoker(type),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: (isUsed ? AppTheme.mediumGray : color).withValues(alpha: 0.35),
                  width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUsed ? AppTheme.mediumGray : color,
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    // Kullanilan joker carpi ile isaretli: soluk renk tek
                    // basina "kullanildi" demiyor.
                    if (isUsed)
                      const Icon(Icons.close_rounded, color: Colors.white, size: 40),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: isUsed ? AppTheme.mediumGray : AppTheme.darkGray,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Butun sorular dogru bilindi mi?
  bool get _hepsiDogru =>
      _questions.isNotEmpty && _correctCount >= _questions.length;

  Widget _buildGameOverScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _renk.withValues(alpha: 0.22),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Esik 10.000.000'du; odul merdiveninin tepesi 1.000.000.
              // Yani kupa ve "TEBRIKLER" dali hic calismiyordu: her soruyu
              // dogru bilen cocuk da "OYUN BITTI" goruyordu. Olcut artik
              // butun sorulari dogru bilmek.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1),
                duration: Motion.adapt(context, Motion.extraLong2),
                curve: Curves.elasticOut,
                builder: (context, s, child) =>
                    Transform.scale(scale: s, child: child),
                child: Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFFE082), Color(0xFFFFA000)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFA000).withValues(alpha: 0.45),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _hepsiDogru
                        ? Icons.emoji_events_rounded
                        : Icons.star_rounded,
                    color: Colors.white,
                    size: 72,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _hepsiDogru
                    ? (_tl('TEBRİKLER!', 'CONGRATULATIONS!', 'GLÜCKWUNSCH!', '¡FELICIDADES!'))
                    : (_tl('OYUN BİTTİ', 'GAME OVER', 'SPIEL VORBEI', 'FIN DEL JUEGO')),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: Color.lerp(_renk, Colors.black, 0.2),
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              // Paranin nereden geldigi gorunsun: odul dogru sayisina bagli.
              Text(
                _tl(
                    '${_questions.length} sorudan $_correctCount tanesini doğru bildin.',
                    'You answered $_correctCount of ${_questions.length} questions correctly.',
                    'Du hast $_correctCount von ${_questions.length} Fragen richtig beantwortet.',
                    'Acertaste $_correctCount de ${_questions.length} preguntas.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.darkGray, fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _soruNoktalari(),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFCA28), width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      _tl('Kazandığınız Para:', 'Prize Won:', 'Dein Gewinn:', 'Premio ganado:'),
                      style: const TextStyle(
                        color: AppTheme.darkGray,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      MillionaireQuestionsService.formatPrize(_currentPrize,
                          lang: _lang),
                      style: AppTheme.number(fontSize: 34, color: const Color(0xFFE65100)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PressButton(
                label: _tl('Yeniden Oyna', 'Play Again', 'Noch mal spielen', 'Jugar otra vez'),
                icon: Icons.refresh_rounded,
                color: _renk,
                onPressed: _restartGame,
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.exit_to_app_rounded),
                label: Text(_tl('Çıkış', 'Exit', 'Beenden', 'Salir')),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.darkGray,
                  minimumSize: const Size(120, 48),
                  textStyle: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAnswer(int index) {
    if (_showingResult) return;
    setState(() {
      _selectedAnswer = index;
    });
  }

  void _confirmAnswer() {
    final isCorrect = _selectedAnswer == _currentQuestion.correctAnswerIndex;

    setState(() {
      _showingResult = true;
      _sonuclar.add(isCorrect);
      if (isCorrect) {
        _correctCount++;
        // Odul, dogru bilinen soru sayisina gore merdivende bir basamak
        // yukari cikiyor; sorunun kendi degeri degil. Aradaki bir soruyu
        // kacirmis cocuk o basamagin parasini almiyor.
        _currentPrize =
            _prizeTree[(_correctCount - 1).clamp(0, _prizeTree.length - 1)];
      }
    });
    // Ekran tamamen sessizdi.
    if (isCorrect) {
      SoundService.playCorrect();
    } else {
      SoundService.playWrong();
    }
    AnswerFeedbackBar.haptic(
        isCorrect ? AnswerResult.correct : AnswerResult.wrong);

    // Yanlis cevapta dogru sik ekranda yesile donuyor; cocugun okumasi
    // icin biraz daha uzun bekliyoruz.
    Future.delayed(Duration(milliseconds: isCorrect ? 1800 : 3200), () {
      if (!mounted) return;

      // TEK YANLIS CEVAP OYUNU BITIRIYORDU.
      //
      // Bu yas grubu icin alinmis karara aykiriydi: yanlislarin buyuk
      // kismi bilgi hatasi degil parmak hatasi. Yanlis cevap oyunu
      // bitirmiyor, sadece odul merdiveninde basamak kazandirmiyor.
      //
      // Ucretsiz soru siniri eskiden YALNIZCA dogru cevap dalinda
      // kontrol ediliyordu: soruyu bilen cocuk 3. soruda duruyor,
      // bilemeyen 12 soru birden oynuyordu. Kullanicinin "bazen 3 bazen
      // 10 soru cevaplayabiliyorum" dedigi sey buydu. Kontrol artik
      // cevabin dogrulugundan bagimsiz.
      final sonSoru = _currentQuestionIndex >= _questions.length - 1;
      final ucretsizSinir =
          !_isPro && _currentQuestionIndex >= kMillionaireFreeQuestionLimit - 1;

      if (sonSoru) {
        setState(() => _gameOver = true);
        _awardProgress();
        return;
      }

      if (ucretsizSinir) {
        setState(() => _gameOver = true);
        _awardProgress();
        _showFreeLimitPaywall();
        return;
      }

      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showingResult = false;
        _hiddenOptions.clear();
        _audienceVotes = null;
        _phoneAnswer = null;
      });

      // Para agacini otomatik olarak kaydir.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToPrize();
      });
    });
  }

  bool get _isPro =>
      Provider.of<AuthProvider>(context, listen: false).currentUser?.isPro ??
      false;

  void _showFreeLimitPaywall() {
    ProPaywall.show(
      context: context,
      title: _tl('🎉 İlk $kMillionaireFreeQuestionLimit Soruyu Tamamladın!', '🎉 You completed the first $kMillionaireFreeQuestionLimit questions!', '🎉 Du hast die ersten $kMillionaireFreeQuestionLimit Fragen geschafft!', '🎉 ¡Completaste las primeras $kMillionaireFreeQuestionLimit preguntas!'),
      message: _tl('Bilgi Yarışması\'na devam etmek ve daha büyük ödülleri kazanmak için Pro\'ya geç.', 'Go Pro to continue the Knowledge Quiz and win bigger prizes.', 'Hol dir Pro, um im Wissensquiz weiterzuspielen und größere Preise zu gewinnen.', 'Hazte Pro para seguir en el concurso y ganar premios más grandes.'),
      featureDescription: _tl('Pro ile Bilgi Yarışması\'nda sınırsız soru, tüm oyunlarda tam erişim ve daha fazlası seni bekliyor!', 'With Pro you get unlimited questions in the Knowledge Quiz, full access to all games, and more!', 'Mit Pro warten unbegrenzte Fragen im Wissensquiz, voller Zugriff auf alle Spiele und mehr auf dich!', 'Con Pro te esperan preguntas ilimitadas en el concurso, acceso completo a todos los juegos y mucho más.'),
    );
  }

  /// Oyun bitince (kazanma/kaybetme/ücretsiz limit) ulaşılan seviyeye göre
  /// kalıcı XP ve jeton kazandırır (Market'te harcanabilir). Bilgi Yarışması
  /// skoru önceden hiç kaydedilmiyordu.
  Future<void> _awardProgress() async {
    // Eskiden CEVAPLANAN soru sayisi kullaniliyordu: hepsini yanlis
    // bilen cocuk da XP ve jeton aliyordu. Artik yalnizca dogrular.
    final dogruSayisi = _correctCount;
    if (dogruSayisi <= 0) return;
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.currentUser?.uid;
      if (userId == null) return;
      final jeton = dogruSayisi * 5;
      await auth.addXP(dogruSayisi * 8);
      await UserProgressService()
          .addJeton(userId, jeton, source: 'millionaire_quiz');
      await auth.refreshProgress();
    } catch (e) {
      debugPrint('❌ Bilgi Yarışması ödül hatası: $e');
    }
  }

  void _useJoker(JokerType type) {
    if (_jokerState.isUsed(type)) return;

    setState(() {
      _jokerState.use(type);
    });

    switch (type) {
      case JokerType.fiftyFifty:
        _useFiftyFifty();
        break;
      case JokerType.phone:
        _usePhone();
        break;
      case JokerType.audience:
        _useAudience();
        break;
    }
  }

  void _useFiftyFifty() {
    // 2 yanlış şıkkı gizle
    final correctIndex = _currentQuestion.correctAnswerIndex;
    final wrongOptions =
        List.generate(4, (i) => i).where((i) => i != correctIndex).toList();

    wrongOptions.shuffle();

    setState(() {
      _hiddenOptions = {wrongOptions[0], wrongOptions[1]};
    });
  }

  void _usePhone() {
    // Random bir arkadaş tahmini (çoğunlukla doğru)
    final random = Random();
    final correctIndex = _currentQuestion.correctAnswerIndex;

    // %80 ihtimalle doğru cevabı söyler
    final willBeCorrect = random.nextInt(100) < 80;
    // Yanilan arkadas eskiden dort siktan rastgele birini soyluyordu: bu
    // bazen dogru sikkin kendisi (o zaman "%50 eminim" yalan oluyordu),
    // bazen de 50:50 ile GIZLENMIS bir sikti. Artik ekranda gorunen
    // yanlis siklardan biri.
    final yanlislar = List.generate(4, (i) => i)
        .where((i) => i != correctIndex && !_hiddenOptions.contains(i))
        .toList();
    final suggestedIndex = willBeCorrect || yanlislar.isEmpty
        ? correctIndex
        : yanlislar[random.nextInt(yanlislar.length)];

    final letter = String.fromCharCode(65 + suggestedIndex);

    setState(() {
      _phoneAnswer = _tl('Arkadaşınız: "Bence cevap $letter şıkkı olmalı, %${willBeCorrect ? 80 : 50} eminim."', 'Your friend: "I think the answer is $letter, I\'m ${willBeCorrect ? 80 : 50}% sure."', 'Deine Freundin: "Ich glaube, die Antwort ist $letter, ich bin mir zu ${willBeCorrect ? 80 : 50}% sicher."', 'Tu amigo: "Creo que la respuesta es $letter, estoy ${willBeCorrect ? 80 : 50}% seguro."');
    });
  }

  void _useAudience() {
    // Seyirci oylaması - çoğunluk doğru cevaba yönelir
    final random = Random();
    final correctIndex = _currentQuestion.correctAnswerIndex;

    // Doğru cevaba %50-70 arası oy
    final correctVotes = 50 + random.nextInt(21);
    final remainingVotes = 100 - correctVotes;

    final votes = <int, int>{};
    votes[correctIndex] = correctVotes;

    // Kalan oyları diğer şıklara dağıt
    final otherIndices =
        List.generate(4, (i) => i).where((i) => i != correctIndex).toList();

    var remaining = remainingVotes;
    for (int i = 0; i < otherIndices.length - 1; i++) {
      final vote = random.nextInt(remaining + 1);
      votes[otherIndices[i]] = vote;
      remaining -= vote;
    }
    votes[otherIndices.last] = remaining;

    setState(() {
      _audienceVotes = votes;
    });
  }

  void _restartGame() {
    setState(() {
      _currentQuestionIndex = 0;
      _correctCount = 0;
      _sonuclar.clear();
      _selectedAnswer = null;
      _showingResult = false;
      _gameOver = false;
      _currentPrize = 0;
      _hiddenOptions.clear();
      _audienceVotes = null;
      _phoneAnswer = null;
      _jokerState.fiftyFiftyUsed = false;
      _jokerState.phoneUsed = false;
      _jokerState.audienceUsed = false;
    });
  }
}
