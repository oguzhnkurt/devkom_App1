import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../widgets/oyun_basligi.dart';
import '../../widgets/oyun_kimligi.dart';
import '../../utils/lang.dart';
import 'word_match_levels.dart';
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
///
/// Ekim 2026: 24 seviye, 6 dunya; cift sayisi, can ve geri sayimla
/// yavas yavas zorlasiyor (bkz. word_match_levels.dart). Yildizlar ve
/// acilan seviyeler cihazda saklaniyor, seviye haritasindan secilebiliyor.
class WordMatchGameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const WordMatchGameScreen({super.key, required this.gameData});

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  List<MatchPair> _pairs = [];
  List<String> _rightOrder = [];

  int _score = 0;
  int _seviyeNo = 1;
  int _acikSeviye = 1;
  Map<int, int> _yildizlar = const {};
  KelimeSeviyesi get _seviye => KelimeSeviyeleri.seviye(_seviyeNo);

  /// Bu tahtadaki hata sayisi (yildiz hesabi).
  int _hata = 0;
  int? _kalanCan;
  int? _kalanSure;
  Timer? _saat;
  bool _bitti = false;

  int _toplamDogru = 0;
  int _toplamHata = 0;
  DateTime? _startTime;

  final GlobalKey<MatchBoardState> _boardKey = GlobalKey<MatchBoardState>();

  static const _dunyaRenkleri = [
    Color(0xFF7E57C2),
    Color(0xFFFF8F00),
    Color(0xFF00897B),
    Color(0xFF1E88E5),
    Color(0xFFD81B60),
    Color(0xFF6D4C41),
  ];
  Color get _renk => _dunyaRenkleri[(_seviye.dunya - 1) % _dunyaRenkleri.length];

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Metin secici. [de] ve [es] verilmemisse Ingilizcesi gosteriliyor.
  String _t(String tr, String en, [String? de, String? es]) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (Kelime/dil oyunu).
    SoundService.useVoice(SfxVoice.bright);
    _startTime = DateTime.now();
    _ilerlemeyiYukle();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showHowToPlay());
  }

  @override
  void dispose() {
    _saat?.cancel();
    super.dispose();
  }

  Future<void> _ilerlemeyiYukle() async {
    final acik = await KelimeIlerlemesi.acik();
    final yildiz = await KelimeIlerlemesi.yildizlar();
    if (!mounted) return;
    _acikSeviye = acik;
    _yildizlar = yildiz;
    _seviyeyeGec(acik);
  }

  void _seviyeyeGec(int no) {
    _seviyeNo = no.clamp(1, KelimeSeviyeleri.toplam);
    _loadWords();
  }

  void _loadWords() {
    final sv = _seviye;
    // Havuzlar birlestiriliyor; ayni terim iki havuzda varsa (Sensor)
    // bir kez sayiliyor, yoksa ayni kelime iki kez cikabilirdi.
    final gorulen = <String>{};
    final havuz = <Map<String, String>>[
      for (final t in sv.temalar)
        for (final w in wordMatchWords[t] ?? const <Map<String, String>>[])
          if (gorulen.add(w['term']!)) w,
    ]..shuffle();
    final chosen = havuz.take(sv.cift).toList();

    // Sag taraf her zaman cocugun kendi dilinde.
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
    _hata = 0;
    _bitti = false;
    _kalanCan = sv.can;
    _kalanSure = sv.sure;
    _saat?.cancel();
    if (sv.sure != null) {
      _saat = Timer.periodic(const Duration(seconds: 1), (_) => _tik());
    }
    setState(() {});
  }

  void _tik() {
    if (!mounted || _bitti) return;
    final k = (_kalanSure ?? 0) - 1;
    setState(() => _kalanSure = k);
    if (k <= 5 && k > 0) HapticFeedback.selectionClick();
    if (k <= 0) {
      _kaybet(sure: true);
    }
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
    setState(() {
      _score += 10;
      _toplamDogru++;
    });
    SoundService.playCorrect();
    _burstAt(_boardKey.currentState?.rightTileCenter(pair.id));
  }

  /// Yanlis eslestirme.
  ///
  /// Ilk on seviyede PUAN da CAN da kirmiyoruz: bu yas grubunda yanlislarin
  /// cogu parmak hatasi. Can, cocuk oyunu ogrendikten sonra (11. seviye)
  /// geliyor; o zaman bile puan kirilmiyor, yalnizca can ve yildiz.
  void _onWrong(MatchPair left, MatchPair right) {
    SoundService.playWrong();
    setState(() {
      _hata++;
      _toplamHata++;
      if (_kalanCan != null) _kalanCan = _kalanCan! - 1;
    });
    if (_kalanCan != null) {
      HapticFeedback.mediumImpact();
      if (_kalanCan! <= 0) _kaybet(sure: false);
    }
  }

  void _onCompleted() {
    if (_bitti) return;
    _bitti = true;
    _saat?.cancel();
    final bonus = (_kalanSure ?? 0) * 2;
    final yildiz = KelimeSeviyeleri.yildiz(_hata);
    setState(() => _score += bonus);
    SoundService.playLevelComplete();
    KelimeIlerlemesi.bitti(_seviyeNo, yildiz);
    setState(() {
      _yildizlar = {..._yildizlar, _seviyeNo: (_yildizlar[_seviyeNo] ?? 0) > yildiz ? _yildizlar[_seviyeNo]! : yildiz};
      if (_seviyeNo + 1 > _acikSeviye) {
        _acikSeviye = (_seviyeNo + 1).clamp(1, KelimeSeviyeleri.toplam);
      }
    });
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _showCompletionDialog(yildiz, bonus);
    });
  }

  void _kaybet({required bool sure}) {
    if (_bitti) return;
    _bitti = true;
    _saat?.cancel();
    SoundService.playGameOver();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (d) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          sure
              ? _t('Süre doldu! ⏰', 'Time’s up! ⏰', 'Zeit um! ⏰', '¡Se acabó el tiempo! ⏰')
              : _t('Canların bitti 💔', 'Out of hearts 💔', 'Keine Herzen mehr 💔', 'Sin corazones 💔'),
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800),
        ),
        content: Text(
          _t('Az kaldı! Bu seviye zor ama sen de güçleniyorsun. Bir daha dene!',
              'So close! This level is tough, but so are you. Try again!',
              'Fast geschafft! Das Level ist schwer, aber du wirst stärker. Nochmal!',
              '¡Casi! Este nivel es difícil, pero tú también. ¡Otra vez!'),
          style: const TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(d);
              _seviyeHaritasi();
            },
            child: Text(_t('Seviyeler', 'Levels', 'Level', 'Niveles')),
          ),
          PressButton(
            label: _t('Tekrar dene', 'Try again', 'Nochmal', 'Reintentar'),
            expand: false,
            color: _renk,
            onPressed: () {
              Navigator.pop(d);
              _loadWords();
            },
          ),
        ],
      ),
    );
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

  void _nextLevel() {
    if (_seviyeNo < KelimeSeviyeleri.toplam) _seviyeyeGec(_seviyeNo + 1);
  }

  /// Alti dunya, yirmi dort balon. Kilitli olanlar asma kilitli.
  Future<void> _seviyeHaritasi() async {
    _saat?.cancel();
    final secilen = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (c) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _t('Seviye haritası', 'Level map', 'Levelkarte', 'Mapa de niveles'),
                style: const TextStyle(
                    fontFamily: AppTheme.fontFamily, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              Text(
                '${_yildizlar.values.fold(0, (a, b) => a + b)} / ${KelimeSeviyeleri.toplam * 3} ⭐',
                style: const TextStyle(
                    fontFamily: AppTheme.fontFamily, color: AppTheme.mediumGray, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              for (var d = 1; d <= 6; d++) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Text(
                    '${_t('Dünya', 'World', 'Welt', 'Mundo')} $d · ${KelimeSeviyeleri.dunyaAdi(d, _lang)}',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w900,
                      color: _dunyaRenkleri[d - 1],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final sv in KelimeSeviyeleri.hepsi.where((x) => x.dunya == d))
                      Expanded(child: _haritaBalonu(c, sv)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (secilen != null) {
      _seviyeyeGec(secilen);
    } else if (!_bitti && _seviye.sure != null) {
      _saat = Timer.periodic(const Duration(seconds: 1), (_) => _tik());
    }
  }

  Widget _haritaBalonu(BuildContext c, KelimeSeviyesi sv) {
    final acik = sv.no <= _acikSeviye;
    final yildiz = _yildizlar[sv.no] ?? 0;
    final renk = _dunyaRenkleri[sv.dunya - 1];
    final simdi = sv.no == _seviyeNo;
    return GestureDetector(
      key: ValueKey('kelime_seviye_${sv.no}'),
      onTap: acik ? () => Navigator.pop(c, sv.no) : null,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: acik ? renk : Colors.grey.shade200,
              border: simdi ? Border.all(color: Colors.black87, width: 3) : null,
              boxShadow: acik
                  ? [BoxShadow(color: Color.lerp(renk, Colors.black, 0.35)!, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Center(
              child: acik
                  ? Text('${sv.no}',
                      style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900))
                  : Icon(Icons.lock_rounded, color: Colors.grey.shade500, size: 20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            acik ? '${'★' * yildiz}${'☆' * (3 - yildiz)}' : ' ',
            style: const TextStyle(color: Color(0xFFFFB300), fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sv = _seviye;
    // Oyunlarin ortak kabugu: OyunBasligi + OyunZemini, Oyunlar
    // sekmesindeki kartla ayni renk ve simge. Dunya rengi (_renk) oyun
    // icindeki rozet, sayac ve tahta vurgularinda kaliyor.
    final kimlik = OyunKimligi.renk(GameType.wordMatch);
    final dar = MediaQuery.sizeOf(context).width < 400;
    return Scaffold(
      backgroundColor: OyunZemini.ustRenk(kimlik),
      appBar: OyunBasligi(
        renk: kimlik,
        // Dar telefonda (320) simge basligin yerini yiyor.
        simge: dar ? null : OyunKimligi.simge(GameType.wordMatch),
        baslikWidget: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(_t('Kelime Eşleştirme', 'Word Match', 'Wörter zuordnen',
              'Empareja palabras')),
        ),
        altBaslik: '${KelimeSeviyeleri.dunyaAdi(sv.dunya, _lang)} · '
            '${_t('Seviye', 'Level', 'Level', 'Nivel')} $_seviyeNo/${KelimeSeviyeleri.toplam}',
        eylemler: [
          IconButton(
            key: const ValueKey('kelime_harita'),
            tooltip: _t('Seviyeler', 'Levels', 'Level', 'Niveles'),
            icon: const Icon(Icons.map_rounded),
            onPressed: _seviyeHaritasi,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              key: const ValueKey('kelime_puan'),
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    size: 18, color: Color(0xFFFFE082)),
                const SizedBox(width: 3),
                Text('$_score'),
              ],
            ),
          ),
        ],
      ),
      body: OyunZemini(
        renk: kimlik,
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
                          _durumSeridi(sv),
                          const SizedBox(height: 14),
                          MatchBoard(
                            key: _boardKey,
                            pairs: _pairs,
                            rightOrder: _rightOrder,
                            onCorrect: _onCorrect,
                            onWrong: _onWrong,
                            onCompleted: _onCompleted,
                            leftColor: _renk,
                            cevapKartlari: true,
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 4,
                            children: [
                              TextButton.icon(
                                onPressed: _loadWords,
                                icon: const Icon(Icons.refresh_rounded,
                                    size: 18),
                                label: Text(_t('Yeniden başla', 'Restart',
                                    'Neu starten', 'Reiniciar')),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.mediumGray,
                                ),
                              ),
                              TextButton.icon(
                                key: const ValueKey('kelime_nasil'),
                                onPressed: () => _showHowToPlay(force: true),
                                icon: const Icon(Icons.help_outline_rounded,
                                    size: 18),
                                label: Text(_t('Nasıl oynanır', 'How to play',
                                    'Wie wird gespielt', 'Cómo se juega')),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.mediumGray,
                                ),
                              ),
                            ],
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

  /// Seviye karti: dunya, can ve geri sayim.
  Widget _durumSeridi(KelimeSeviyesi sv) {
    final sure = sv.sure;
    final kalan = _kalanSure ?? 0;
    final kritik = sure != null && kalan <= 10;
    return Container(
      key: const ValueKey('kelime_durum'),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _renk.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [BoxShadow(color: _renk.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _renk, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '${_t('Dünya', 'World', 'Welt', 'Mundo')} ${sv.dunya}',
                  style: const TextStyle(
                      fontFamily: AppTheme.fontFamily, color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              // 320 genislikte ve uzun dillerde (es: "10 parejas",
              // "Intentos ilimitados") satir tasiyordu: iki yan da
              // esnek, sigmayan kucultuluyor.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${sv.cift} ${_t('çift', 'pairs', 'Paare', 'parejas')}',
                    style: const TextStyle(
                        fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800, color: AppTheme.darkGray),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: sv.can != null
                        ? Row(
                            key: const ValueKey('kelime_canlar'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < sv.can!; i++)
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 300),
                                  scale: i < (_kalanCan ?? 0) ? 1 : 0.8,
                                  child: Text(i < (_kalanCan ?? 0) ? '❤️' : '🤍',
                                      style: const TextStyle(fontSize: 18)),
                                ),
                            ],
                          )
                        : Text(
                            _t('Sınırsız deneme', 'Unlimited tries', 'Unbegrenzt', 'Intentos ilimitados'),
                            style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                color: AppTheme.mediumGray,
                                fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (sure != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_rounded, size: 18, color: kritik ? Colors.red : _renk),
                const SizedBox(width: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (kalan / sure).clamp(0.0, 1.0),
                      minHeight: 9,
                      backgroundColor: _renk.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(kritik ? Colors.red : _renk),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${kalan.clamp(0, 999)} ${_t('sn', 's', 's', 's')}',
                  key: const ValueKey('kelime_sure'),
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w900,
                      color: kritik ? Colors.red : AppTheme.darkGray),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showCompletionDialog(int yildiz, int bonus) {
    final isLast = _seviyeNo >= KelimeSeviyeleri.toplam;
    final yeniDunya = !isLast && KelimeSeviyeleri.seviye(_seviyeNo + 1).dunya != _seviye.dunya;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          isLast
              ? _t('Efsane oldun! 🏆', 'You are a legend! 🏆', 'Du bist eine Legende! 🏆', '¡Eres una leyenda! 🏆')
              : _t('Seviye $_seviyeNo tamam!', 'Level $_seviyeNo done!', 'Level $_seviyeNo geschafft!', '¡Nivel $_seviyeNo completado!'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              key: const ValueKey('kelime_yildizlar'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + i * 250),
                    curve: Curves.elasticOut,
                    builder: (_, v, __) => Transform.scale(
                      scale: i < yildiz ? v : 0.8,
                      child: Icon(Icons.star_rounded,
                          size: 46, color: i < yildiz ? const Color(0xFFFFB300) : Colors.grey.shade300),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              yildiz == 3
                  ? _t('Hiç hata yapmadın!', 'No mistakes at all!', 'Kein einziger Fehler!', '¡Ni un error!')
                  : _t('$_hata hata · 3 yıldız için hatasız dene', '$_hata mistakes · go flawless for 3 stars',
                      '$_hata Fehler · fehlerfrei für 3 Sterne', '$_hata errores · sin errores para 3 estrellas'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: AppTheme.fontFamily, color: AppTheme.mediumGray),
            ),
            const SizedBox(height: 10),
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
              bonus > 0
                  ? _t('puan · +$bonus süre bonusu', 'points · +$bonus time bonus', 'Punkte · +$bonus Zeitbonus', 'puntos · +$bonus por tiempo')
                  : _t('puan', 'points', 'Punkte', 'puntos'),
              style: const TextStyle(fontFamily: AppTheme.fontFamily, color: AppTheme.mediumGray),
            ),
            if (yeniDunya) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _dunyaRenkleri[_seviye.dunya % 6].withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '🔓 ${_t('Yeni dünya açıldı', 'New world unlocked', 'Neue Welt frei', 'Nuevo mundo')}: '
                  '${KelimeSeviyeleri.dunyaAdi(_seviye.dunya + 1, _lang)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w900,
                      color: _dunyaRenkleri[_seviye.dunya % 6]),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _loadWords();
            },
            child: Text(_t('Tekrar oyna', 'Play again', 'Nochmal spielen', 'Jugar otra vez')),
          ),
          if (!isLast)
            PressButton(
              label: _t('Sonraki seviye', 'Next level', 'Nächstes Level', 'Siguiente nivel'),
              expand: false,
              color: _renk,
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
        correctCount: _toplamDogru,
        totalQuestions: _toplamDogru + _toplamHata,
        difficulty: _seviye.dunya,
        completedAt: DateTime.now(),
        metadata: {
          'levelsCompleted': _seviyeNo,
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
