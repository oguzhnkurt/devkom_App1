import 'package:flutter/material.dart';
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
import '../../ui/motion.dart';

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

  void _scrollToPrize() {
    if (_prizeScrollController.hasClients) {
      // Her öğe yaklaşık 120 piksel genişliğinde (margin + padding dahil)
      final offset = _correctCount * 120.0;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          title: Text(_tl('Bilgi Yarışması 🎯', 'Knowledge Quiz 🎯', 'Wissensquiz 🎯', 'Concurso de conocimiento 🎯')),
          centerTitle: true,
          backgroundColor: const Color(0xFF1B263B),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.amber),
              const SizedBox(height: 20),
              Text(
                _tl('Sorular yükleniyor...', 'Loading questions...', 'Fragen werden geladen ...', 'Cargando las preguntas...'),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          title: Text(_tl('Bilgi Yarışması 🎯', 'Knowledge Quiz 🎯', 'Wissensquiz 🎯', 'Concurso de conocimiento 🎯')),
          centerTitle: true,
          backgroundColor: const Color(0xFF1B263B),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.red, size: 80),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadQuestions,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: Text(_tl('Tekrar Dene', 'Try Again', 'Noch mal versuchen', 'Intentar de nuevo'),
                    style: const TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          title: Text(_tl('Bilgi Yarışması 🎯', 'Knowledge Quiz 🎯', 'Wissensquiz 🎯', 'Concurso de conocimiento 🎯')),
          centerTitle: true,
          backgroundColor: const Color(0xFF1B263B),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz_rounded, color: Colors.amber, size: 80),
              const SizedBox(height: 20),
              Text(
                _tl('Henüz soru eklenmemiş', 'No questions added yet', 'Es wurden noch keine Fragen hinzugefügt', 'Todavía no hay preguntas'),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: Text(_tl('Geri Dön', 'Go Back', 'Zurück', 'Volver'),
                    style: const TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(_tl('Bilgi Yarışması 🎯', 'Knowledge Quiz 🎯', 'Wissensquiz 🎯', 'Concurso de conocimiento 🎯')),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B263B),
      ),
      body: SafeArea(
        child: _gameOver ? _buildGameOverScreen() : _buildGameScreen(),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        // Para Ağacı
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B263B), Color(0xFF0D1B2A)],
            ),
          ),
          child: ListView.builder(
            controller: _prizeScrollController,
            reverse: true,
            scrollDirection: Axis.horizontal,
            itemCount: _prizeTree.length,
            itemBuilder: (context, index) {
              final isPast = index < _correctCount;
              final isCurrent = index == _correctCount;
              final prize = _prizeTree[index];

              return Container(
                margin: const EdgeInsets.all(8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.amber
                      : isPast
                          ? Colors.grey[700]
                          : Colors.transparent,
                  border: Border.all(
                    color: isCurrent ? Colors.amber : Colors.grey[600]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    MillionaireQuestionsService.formatPrize(prize, lang: _lang),
                    style: TextStyle(
                      color: isCurrent ? Colors.black : Colors.white,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      fontSize: isCurrent ? 16 : 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Soru
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Soru Numarası ve Metni
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B263B),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _tl('Soru ${_currentQuestionIndex + 1}', 'Question ${_currentQuestionIndex + 1}', 'Frage ${_currentQuestionIndex + 1}', 'Pregunta ${_currentQuestionIndex + 1}'),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentQuestion.questionFor(_lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Soru Görseli
                      if (_currentQuestion.imageUrl != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: _currentQuestion.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.amber),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: Colors.grey[800],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_rounded,
                                  color: Colors.white),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _phoneAnswer!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                const SizedBox(height: 10),

                // Seçenekler
                ...List.generate(4, (index) {
                  final option = _currentQuestion.optionsFor(_lang)[index];
                  final letter = String.fromCharCode(65 + index); // A, B, C, D
                  final isHidden = _hiddenOptions.contains(index);
                  final isSelected = _selectedAnswer == index;

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
                  final isCorrectOption =
                      index == _currentQuestion.correctAnswerIndex;
                  Color buttonColor = const Color(0xFF1B263B);
                  if (_showingResult && isCorrectOption) {
                    buttonColor = Colors.green;
                  } else if (_showingResult && isSelected) {
                    buttonColor = Colors.red;
                  } else if (isSelected) {
                    buttonColor = Colors.amber[800]!;
                  }

                  return IgnorePointer(
                    ignoring: isHidden,
                    child: AnimatedOpacity(
                      opacity: isHidden ? 0 : 1,
                      duration: Motion.adapt(context, Motion.short4),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Material(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            onTap: _showingResult
                                ? null
                                : () => _selectAnswer(index),
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.amber
                                      : Colors.grey[600]!,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Harf
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.amber
                                          : Colors.grey[800],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        letter,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Seçenek
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
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
                                    opacity:
                                        _audienceVotes?.containsKey(index) ??
                                                false
                                            ? 1
                                            : 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        '%${_audienceVotes?[index] ?? 0}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Renk tek basina yeterli degil: renk
                                  // korlugu olan cocuk yesil ile kirmiziyi
                                  // ayirt edemez. Isaret de koyuluyor.
                                  // Yeri bastan ayrildigi icin kayma yok.
                                  Opacity(
                                    opacity: _showingResult &&
                                            (isCorrectOption || isSelected)
                                        ? 1
                                        : 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Icon(
                                        isCorrectOption
                                            ? Icons.check_circle_rounded
                                            : Icons.cancel_rounded,
                                        color: Colors.white,
                                        size: 22,
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
                  );
                }),

                const SizedBox(height: 20),

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedOpacity(
                    opacity:
                        _selectedAnswer != null && !_showingResult ? 1 : 0.35,
                    duration: Motion.adapt(context, Motion.short4),
                    child: ElevatedButton(
                      onPressed: _selectedAnswer != null && !_showingResult
                          ? _confirmAnswer
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        disabledBackgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            _selectedAnswer == null
                                ? (_tl('BİR ŞIK SEÇ', 'PICK AN ANSWER', 'WÄHLE EINE ANTWORT', 'ELIGE UNA RESPUESTA'))
                                : (_tl('FİNAL CEVAP', 'FINAL ANSWER', 'ENDGÜLTIGE ANTWORT', 'RESPUESTA FINAL')),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Joker Butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildJokerButton(
                      JokerType.fiftyFifty,
                      '50:50',
                      Icons.pie_chart_rounded,
                      Colors.orange,
                    ),
                    _buildJokerButton(
                      JokerType.phone,
                      _tl('Telefon', 'Phone', 'Telefon', 'Teléfono'),
                      Icons.phone_rounded,
                      Colors.blue,
                    ),
                    _buildJokerButton(
                      JokerType.audience,
                      _tl('Seyirci', 'Audience', 'Publikum', 'Público'),
                      Icons.people_rounded,
                      Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJokerButton(
      JokerType type, String label, IconData icon, Color color) {
    final isUsed = _jokerState.isUsed(type);

    return Opacity(
      opacity: isUsed ? 0.3 : 1.0,
      child: Column(
        children: [
          Material(
            color: isUsed ? Colors.grey : color,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: isUsed || _showingResult ? null : () => _useJoker(type),
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isUsed ? Colors.grey : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Butun sorular dogru bilindi mi?
  bool get _hepsiDogru =>
      _questions.isNotEmpty && _correctCount >= _questions.length;

  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Esik 10.000.000'du; odul merdiveninin tepesi 1.000.000.
            // Yani kupa ve "TEBRIKLER" dali hic calismiyordu: her soruyu
            // dogru bilen cocuk da "OYUN BITTI" goruyordu. Olcut artik
            // butun sorulari dogru bilmek.
            Icon(
              _hepsiDogru
                  ? Icons.emoji_events_rounded
                  : Icons.star_rounded,
              color: Colors.amber,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              _hepsiDogru
                  ? (_tl('TEBRİKLER!', 'CONGRATULATIONS!', 'GLÜCKWUNSCH!', '¡FELICIDADES!'))
                  : (_tl('OYUN BİTTİ', 'GAME OVER', 'SPIEL VORBEI', 'FIN DEL JUEGO')),
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Paranin nereden geldigi gorunsun: odul dogru sayisina bagli.
            Text(
              _tl(
                  '${_questions.length} sorudan $_correctCount tanesini doğru bildin.',
                  'You answered $_correctCount of ${_questions.length} questions correctly.',
                  'Du hast $_correctCount von ${_questions.length} Fragen richtig beantwortet.',
                  'Acertaste $_correctCount de ${_questions.length} preguntas.'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Text(
              _tl('Kazandığınız Para:', 'Prize Won:', 'Dein Gewinn:', 'Premio ganado:'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              MillionaireQuestionsService.formatPrize(_currentPrize,
                  lang: _lang),
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _restartGame,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(_tl('Yeniden Oyna', 'Play Again', 'Noch mal spielen', 'Jugar otra vez')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.exit_to_app_rounded),
                  label: Text(_tl('Çıkış', 'Exit', 'Beenden', 'Salir')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
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
    final suggestedIndex = willBeCorrect ? correctIndex : random.nextInt(4);

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
