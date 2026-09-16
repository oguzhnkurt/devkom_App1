import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_model.dart';
import '../../models/leaderboard_model.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/settings_provider.dart';
import '../../services/leaderboard_service.dart';
import '../../services/score_cache_service.dart';
import '../../services/sound_service.dart';
import '../../theme.dart';
import '../../ui/press_button.dart';
import '../../widgets/animated_rank_display.dart';
import '../../widgets/learning/how_to_play_demo.dart';
import '../../widgets/learning/match_board.dart';
import '../../widgets/learning/success_burst.dart';
import '../../widgets/playful_background.dart';
import '../../utils/lang.dart';
import 'word_match_words.dart';

/// Kelime eslestirme oyunu.
///
/// Bu ekran bastan yazildi. Onceki halinde her seviyede 8 cift vardi ve
/// liste ekrana sigmadigi icin kaydiriliyordu; kutular 32 piksellik
/// yuvarlaklardan tutuluyordu; yanlis eslestirme 3 puan goturuyordu;
/// eslesen satirlar listeden silinip liste yeniden diziliyordu.
/// Dordu de bu yas grubu icin yanlis kararlardi — gerekcesi
/// [MatchBoard] icinde kaynaklariyla yazili.
///
/// Ozetle degisenler:
///  * Seviye basina 5 cift, kaydirma yok.
///  * Kutunun tamami hem dokunulabilir hem suruklenebilir.
///  * Yanlisin puan bedeli yok; sadece kisa bir sarsinti.
///  * Eslesen kutular yerinde kaliyor, aralarinda cizgi duruyor.
class WordMatchGameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const WordMatchGameScreen({super.key, required this.gameData});

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  /// Bir tahtada kac cift.
  ///
  /// Eskiden 8'di ve ekrana sigmiyordu. Duolingo 5 satir, Quizlet 6 cift
  /// gosteriyor ve buyuk setleri boluyor. Calisma bellegi verileri de
  /// ayni yone isaret ediyor: 7 yasinda ortalama ~3, 11 yasinda ~4
  /// birim. Kaydirma gereken bir eslestirme ekrani, cocugu ekran disinda
  /// kalan kutulari akilda tutmaya zorluyor — tam da kapasitesi
  /// olmayan sey.
  static const int _pairsPerBoard = 5;

  List<MatchPair> _pairs = [];
  List<String> _rightOrder = [];

  int _score = 0;
  int _currentLevel = 1;
  final int _totalLevels = 5;
  DateTime? _startTime;

  final GlobalKey<MatchBoardState> _boardKey = GlobalKey<MatchBoardState>();

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Metin secici.
  ///
  /// [de] ve [es] verilmemisse Ingilizcesi gosteriliyor. Boylece bir
  /// cumlenin Almancasi henuz yazilmamis olsa bile ekran dogru
  /// calisiyor ve ceviri sonradan tek bir arguman eklenerek
  /// tamamlanabiliyor — 500'den fazla cagri yerini bir anda cevirmek
  /// zorunda kalmadan.
  String _t(String tr, String en, [String? de, String? es]) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (Kelime/dil oyunu). Butun oyunlarda ayni tonu
    // calmak oyunlari birbirinden ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.bright);
    _startTime = DateTime.now();
    _loadWords();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHowToPlay());
  }

  void _loadWords() {
    final words = [..._getWordsFor(_currentLevel)]..shuffle();
    final chosen = words.take(_pairsPerBoard).toList();

    // Sag taraf her zaman cocugun kendi dilinde. Onceki surumde arayuz
    // almanca olsa bile eslestirme ingilizce-turkce kaliyordu.
    final lang = _lang;
    _pairs = [
      for (var i = 0; i < chosen.length; i++)
        MatchPair(
          id: 'p$i',
          left: chosen[i]['term']!,
          right: chosen[i][lang] ?? chosen[i]['en']!,
        ),
    ];
    _rightOrder = _pairs.map((p) => p.id).toList()..shuffle();
    setState(() {});
  }

  Future<void> _showHowToPlay({bool force = false}) async {
    if (!mounted) return;
    await HowToPlayDemo.maybeShow(
      context,
      gameKey: 'word_match',
      force: force,
      demo: HowToPlayDemo(
        title: _t('Nasıl oynanır?', 'How to play', 'Wie wird gespielt?', '¿Cómo se juega?'),
        hint: _t(
          'Soldaki kelimeye dokun, sonra sağdaki doğru karşılığına dokun. '
              'İstersen sürükleyerek de bağlayabilirsin.',
          'Tap a word on the left, then its match on the right. '
              'You can also drag from one to the other.',
        ),
        sourceLabel: 'Robot',
        targetLabel: 'Robot',
        decoyLabel: _t('Sensör', 'Sensor', 'Sensor', 'Sensor'),
        startLabel: _t('Başla', 'Start', 'Start', 'Empezar'),
        color: const Color(0xFF7E57C2),
      ),
    );
  }

  void _onCorrect(MatchPair pair) {
    setState(() => _score += 10);
    SoundService.playCorrect();
    _burstAt(_boardKey.currentState?.rightTileCenter(pair.id));
  }

  /// Yanlis eslestirme.
  ///
  /// PUAN KIRMIYORUZ. Bu yas grubunda yanlis eslestirmelerin buyuk
  /// kismi bilgi hatasi degil parmak hatasi; parmak hatasini
  /// cezalandirmak ogrenmeyi caydirir. Tahta zaten kisa bir sarsinti
  /// ve yumusak bir ses veriyor, o yeter.
  void _onWrong(MatchPair left, MatchPair right) => SoundService.playWrong();

  void _onCompleted() {
    SoundService.playLevelComplete();
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _showCompletionDialog();
    });
  }

  /// Dogru eslesmenin oldugu yerde patlayan efekt.
  void _burstAt(Offset? center) {
    if (center == null) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: SuccessBurst(
          center: center,
          color: const Color(0xFF2E7D32),
          onDone: () => entry.remove(),
        ),
      ),
    );
    overlay.insert(entry);
  }

  void _resetBoard() {
    _loadWords();
  }

  void _nextLevel() {
    if (_currentLevel < _totalLevels) {
      _currentLevel++;
      _loadWords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppTheme.lightGray,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppTheme.darkGray,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _t('Kelime Eşleştirme', 'Word Match', 'Wörter zuordnen', 'Empareja palabras'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkGray,
              ),
            ),
            Text(
              '${_getLevelName(_currentLevel)} · $_currentLevel/$_totalLevels',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _t('Nasıl oynanır', 'How to play', 'Wie wird gespielt', 'Cómo se juega'),
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => _showHowToPlay(force: true),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text(
                '$_score',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
        ],
      ),
      body: PlayfulBackground(
        baseColor: AppTheme.lightGray,
        tint: const Color(0xFF7E57C2),
        child: SafeArea(
          top: false,
          child: _pairs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight - 34),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MatchBoard(
                            key: _boardKey,
                            pairs: _pairs,
                            rightOrder: _rightOrder,
                            onCorrect: _onCorrect,
                            onWrong: _onWrong,
                            onCompleted: _onCompleted,
                          ),
                          const SizedBox(height: 22),
                          TextButton.icon(
                            onPressed: _resetBoard,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(_t('Karıştır', 'Shuffle', 'Mischen', 'Mezclar')),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.mediumGray,
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
  }

  void _showCompletionDialog() {
    final isLast = _currentLevel >= _totalLevels;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          isLast
              ? _t('Oyunu tamamladın!', 'Game complete!', 'Spiel geschafft!', '¡Completaste el juego!')
              : _t('Seviye tamamlandı!', 'Level complete!', 'Level geschafft!', '¡Nivel completado!'),
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLast
                  ? _t('Tüm seviyeleri bitirdin.', 'You finished every level.', 'Du hast alle Level geschafft.', 'Terminaste todos los niveles.')
                  : _t(
                      '${_getLevelName(_currentLevel)} seviyesini bitirdin.',
                      'You finished the ${_getLevelName(_currentLevel)} level.',
                    ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            const SizedBox(height: 14),
            Text(
              '$_score',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2E7D32),
              ),
            ),
            Text(
              _t('puan', 'points', 'Punkte', 'puntos'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _resetBoard();
            },
            child: Text(_t('Tekrar oyna', 'Play again', 'Nochmal spielen', 'Jugar otra vez')),
          ),
          if (!isLast)
            PressButton(
              label: _t('Sonraki seviye', 'Next level', 'Nächstes Level', 'Siguiente nivel'),
              expand: false,
              onPressed: () {
                Navigator.pop(dialogContext);
                _nextLevel();
              },
            )
          else
            PressButton(
              label: _t('Skoru kaydet', 'Save score', 'Punktzahl speichern', 'Guardar puntuación'),
              expand: false,
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _saveScoreAndShowRank();
              },
            ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getWordsFor(int level) =>
      wordMatchWords[level] ?? wordMatchWords[1]!;

  String _getLevelName(int level) {
    switch (level) {
      case 1:
        return _t('Robotik', 'Robotics', 'Robotik', 'Robótica');
      case 2:
        return 'Scratch';
      case 3:
        return 'Arduino';
      default:
        return _t('Seviye $level', 'Level $level', 'Level $level',
            'Nivel $level');
    }
  }

  Future<void> _saveScoreAndShowRank() async {
    try {
      final authProvider =
          Provider.of<app_auth.AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        return;
      }

      final totalDuration = DateTime.now().difference(_startTime!).inSeconds;

      final entry = LeaderboardEntry(
        id: '',
        userId: user.id,
        userName: user.name,
        userPhotoUrl: user.profilePictureUrl,
        gameType: GameType.wordMatch,
        score: _score,
        timeSeconds: totalDuration,
        correctCount: _pairsPerBoard * _totalLevels,
        totalQuestions: _pairsPerBoard * _totalLevels,
        difficulty: _totalLevels,
        completedAt: DateTime.now(),
        metadata: {
          'levelsCompleted': _currentLevel,
        },
      );

      // Save to leaderboard
      await ScoreCacheService().saveScore(entry);

      // Get user rank
      final leaderboardService = LeaderboardService();
      final topEntries = await leaderboardService.getTopEntries(
        gameType: GameType.wordMatch,
        limit: 100,
      );

      final userRank = topEntries.indexWhere((e) => e.userId == user.id) + 1;

      if (mounted && userRank > 0) {
        // Show animated rank display
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AnimatedRankDisplay(
            rank: userRank,
            totalScore: _score,
            userName: user.name,
            isNewRecord: false,
            onClose: () {
              Navigator.pop(context);
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving score: $e');
    }
  }
}
