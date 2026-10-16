// KOD BLOKLARI — "Cizim Ustasi".
//
// Eskiden bu oyun da Robot Simulatoru gibi 5x5 izgarada robot yurutuyordu;
// oyunlar sekmesinde ayni oyun iki kez vardi. Artik adina uygun: GERCEK
// Scratch bloklariyla (bayrak, sil, kalem indir/kaldir, N defa
// tekrarla, git, don) Devi'nin kalemine sekil cizdiren on seviye.
// Cizgi -> kose -> kare -> donguyle kare -> ucgen -> altigen -> besgen
// -> yildiz -> iki kare -> ic ice dongulerle kare cicegi.
//
// Her seviye kursun proje atolyesiyle (ProjeAtolyesiWidget) oynaniyor:
// ayni tezgah, ayni sahne, ayni hedef denetimi. Seviyeler sirayla
// aciliyor; cozulenler cihazda tutuluyor, ilk cozumde XP + jeton.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../courses/data/courses_data.dart';
import '../../courses/data/kod_bloklari_seviyeleri.dart';
import '../../courses/models/interactive_lesson_model.dart';
import '../../courses/screens/widgets/proje_atolyesi.dart';
import '../../courses/yurutme/atolye_hedefleri.dart';
import '../../courses/yurutme/blok_yorumlayici.dart' show KalemCizgisi;
import '../../courses/yurutme/kod_yapisi.dart';
import '../../models/game_model.dart';
import '../../models/leaderboard_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/score_cache_service.dart';
import '../../services/sound_service.dart';
import '../../utils/lang.dart';
import '../../widgets/learning/how_to_play_demo.dart';
import '../../widgets/oyun_basligi.dart';
import '../../widgets/oyun_kimligi.dart';

class BlockCodingGameScreen extends StatefulWidget {
  final Map<String, dynamic>? gameData;

  const BlockCodingGameScreen({super.key, this.gameData});

  /// Cozulen seviyelerin kimlikleri (cihazda).
  static const String cozulenAnahtari = 'kod_bloklari_cozulen';

  @override
  State<BlockCodingGameScreen> createState() => _BlockCodingGameScreenState();
}

class _BlockCodingGameScreenState extends State<BlockCodingGameScreen> {
  final List<ProjeAtolyesiStep> _seviyeler = KodBloklariSeviyeleri.hepsi;
  final Set<String> _cozulen = {};

  /// Acik seviye; null ise seviye haritasi.
  int? _secili;

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  String _tl(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  Color get _renk => OyunKimligi.renk(GameType.blockCoding);

  @override
  void initState() {
    super.initState();
    SoundService.useVoice(SfxVoice.deep);
    _yukle();
    WidgetsBinding.instance.addPostFrameCallback((_) => _nasilOynanir());
  }

  Future<void> _yukle() async {
    try {
      final p = await SharedPreferences.getInstance();
      final l = p.getStringList(BlockCodingGameScreen.cozulenAnahtari) ?? [];
      if (mounted) setState(() => _cozulen.addAll(l));
    } catch (_) {}
  }

  Future<void> _nasilOynanir({bool force = false}) async {
    if (!mounted) return;
    await HowToPlayDemo.maybeShow(
      context,
      gameKey: 'block_coding',
      force: force,
      demo: HowToPlayDemo(
        scene: DemoScene.dragIntoArea,
        title: _tl('Nasıl oynanır?', 'How to play', 'So wird gespielt',
            'Cómo se juega'),
        hint: _tl(
            'Scratch bloklarını kod alanına diz, bayrağa bas ve Devi\'nin '
                'kalemiyle şekli çiz.',
            'Line up Scratch blocks in the code area, press the flag and draw '
                'the shape with Devi\'s pen.',
            'Reih Scratch-Blöcke im Codebereich auf, drück die Fahne und '
                'zeichne die Form mit Devis Stift.',
            'Coloca bloques de Scratch en el área de código, pulsa la bandera '
                'y dibuja la figura con el lápiz de Devi.'),
        sourceLabel:
            _tl('kalem indir', 'pen down', 'schalte Stift ein', 'bajar lápiz'),
        decoyLabel: _tl('90 derece dön', 'turn 90 degrees', 'drehe dich um 90 Grad',
            'girar 90 grados'),
        targetLabel: _tl('Kod alanı', 'Code area', 'Codebereich',
            'Área de código'),
        startLabel: _tl('Başla', 'Start', 'Start', 'Empezar'),
        color: _renk,
      ),
    );
  }

  bool _acikMi(int i) => i == 0 || _cozulen.contains(_seviyeler[i - 1].id);

  int get _puan => _cozulen.length * 100;

  Future<void> _cozuldu(ProjeAtolyesiStep s) async {
    if (_cozulen.contains(s.id)) return;
    setState(() => _cozulen.add(s.id));
    SoundService.playJeton();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          BlockCodingGameScreen.cozulenAnahtari, _cozulen.toList());
    } catch (_) {}
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;
    try {
      await auth.addXP(s.xpReward, source: 'kod_bloklari');
      await auth.addJeton(5, source: 'kod_bloklari');
      await ScoreCacheService().saveScore(LeaderboardEntry(
        id: '',
        userId: user.id,
        userName: user.name,
        userPhotoUrl: user.profilePictureUrl,
        gameType: GameType.blockCoding,
        score: _puan,
        timeSeconds: 0,
        correctCount: _cozulen.length,
        totalQuestions: _seviyeler.length,
        difficulty: _cozulen.length,
        completedAt: DateTime.now(),
        metadata: {'levelsCompleted': _cozulen.length},
      ));
    } catch (e) {
      debugPrint('Kod Blokları ödül hatası: $e');
    }
  }

  void _ac(int i) {
    if (!_acikMi(i)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_tl(
            'Önce $i. seviyeyi çöz.',
            'Solve level $i first.',
            'Löse zuerst Level $i.',
            'Primero resuelve el nivel $i.')),
        duration: const Duration(seconds: 2),
      ));
      return;
    }
    SoundService.playClick();
    setState(() => _secili = i);
  }

  void _sonraki() {
    final i = _secili;
    if (i == null) return;
    setState(() => _secili = i + 1 < _seviyeler.length ? i + 1 : null);
  }

  @override
  Widget build(BuildContext context) {
    final secili = _secili;
    return PopScope(
      canPop: secili == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _secili = null);
      },
      child: Scaffold(
        backgroundColor: OyunZemini.ustRenk(_renk),
        appBar: OyunBasligi.oyun(
          GameType.blockCoding,
          baslikWidget: Text(secili == null
              ? _tl('Kod Blokları', 'Code Blocks', 'Code-Blöcke',
                  'Bloques de código')
              : '${secili + 1}. ${_seviyeler[secili].titleFor(_lang)}'),
          eylemler: [
            IconButton(
              tooltip: _tl('Nasıl oynanır?', 'How to play', 'So wird gespielt',
                  'Cómo se juega'),
              icon: const Icon(Icons.help_outline_rounded),
              onPressed: () => _nasilOynanir(force: true),
            ),
          ],
        ),
        body: OyunZemini(
          renk: _renk,
          child: SafeArea(
            top: false,
            child: secili == null ? _harita() : _seviye(secili),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- harita

  Widget _harita() {
    final koyu = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(builder: (context, c) {
      final sutun = c.maxWidth > 700 ? 5 : (c.maxWidth > 460 ? 3 : 2);
      return CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(child: _ustKart(koyu)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: sutun,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.92,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _seviyeKarti(i, koyu),
              childCount: _seviyeler.length,
            ),
          ),
        ),
      ]);
    });
  }

  Widget _ustKart(bool koyu) {
    final n = _cozulen.length;
    return Container(
      key: const ValueKey('kod_bloklari_ust'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: koyu ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: _renk.withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('✏️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _tl('Çizim Ustası', 'Drawing Master', 'Zeichenmeister',
                    'Maestro del dibujo'),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: koyu ? Colors.white : const Color(0xFF1F2937)),
              ),
            ),
            Text(
              '$n/${_seviyeler.length}',
              key: const ValueKey('kod_bloklari_ilerleme'),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: _renk),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            _tl(
                'Gerçek Scratch bloklarıyla Devi\'nin kalemini programla: '
                    'çizgiden başla, döngülerle yıldız ve çiçek çiz.',
                'Program Devi\'s pen with real Scratch blocks: start with a '
                    'line, then use loops to draw stars and flowers.',
                'Programmiere Devis Stift mit echten Scratch-Blöcken: Fang mit '
                    'einer Linie an und zeichne mit Schleifen Sterne und Blumen.',
                'Programa el lápiz de Devi con bloques de Scratch de verdad: '
                    'empieza con una línea y dibuja estrellas y flores con '
                    'bucles.'),
            style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: koyu ? Colors.white70 : const Color(0xFF475569)),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: n / _seviyeler.length,
              minHeight: 8,
              color: _renk,
              backgroundColor: _renk.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seviyeKarti(int i, bool koyu) {
    final s = _seviyeler[i];
    final acik = _acikMi(i);
    final cozuldu = _cozulen.contains(s.id);
    return Material(
      color: koyu ? const Color(0xFF1E1E2E) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: acik ? 2 : 0,
      shadowColor: _renk.withValues(alpha: 0.3),
      child: InkWell(
        key: ValueKey('kod_bloklari_seviye_$i'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => _ac(i),
        child: Opacity(
          opacity: acik ? 1 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: cozuldu ? const Color(0xFF0FBD8C) : _renk,
                      shape: BoxShape.circle),
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13)),
                ),
                const Spacer(),
                Icon(
                  cozuldu
                      ? Icons.check_circle_rounded
                      : (acik ? Icons.play_circle_fill_rounded : Icons.lock_rounded),
                  size: 22,
                  color: cozuldu
                      ? const Color(0xFF0FBD8C)
                      : (acik ? _renk : Colors.grey),
                ),
              ]),
              const SizedBox(height: 6),
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _SekilOnizleme(
                    _SekilOnizleme.cizgiler(s),
                    acik ? (cozuldu ? const Color(0xFF0FBD8C) : _renk) : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.titleFor(_lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: koyu ? Colors.white : const Color(0xFF1F2937)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- seviye

  Widget _seviye(int i) {
    final s = _seviyeler[i];
    final koyu = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      key: ValueKey('kod_bloklari_sayfa_$i'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            TextButton.icon(
              key: const ValueKey('kod_bloklari_harita'),
              onPressed: () => setState(() => _secili = null),
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: Text(_tl('Seviyeler', 'Levels', 'Level', 'Niveles')),
              style: TextButton.styleFrom(foregroundColor: _renk),
            ),
            const Spacer(),
            Text(
              _tl('Seviye ${i + 1}/${_seviyeler.length}',
                  'Level ${i + 1}/${_seviyeler.length}',
                  'Level ${i + 1}/${_seviyeler.length}',
                  'Nivel ${i + 1}/${_seviyeler.length}'),
              style: TextStyle(fontWeight: FontWeight.w800, color: _renk),
            ),
          ]),
          const SizedBox(height: 6),
          ProjeAtolyesiWidget(
            key: ValueKey(s.id),
            step: s,
            course: CoursesData.byId('scratch')!,
            isDark: koyu,
            lang: _lang,
            onComplete: (tamam) {
              if (tamam) _cozuldu(s);
            },
            onDevam: _sonraki,
          ),
        ],
      ),
    );
  }
}

/// Seviye kartindaki hedef sekli: ornek cozumun cizgileri, karta
/// sigdirilmis. Cocuk neyi cizecegini koddan once goruyor.
class _SekilOnizleme extends CustomPainter {
  _SekilOnizleme(this.cizgi, this.renk);

  final List<KalemCizgisi> cizgi;
  final Color renk;

  static final Map<String, List<KalemCizgisi>> _onbellek = {};

  static List<KalemCizgisi> cizgiler(ProjeAtolyesiStep s) =>
      _onbellek.putIfAbsent(s.id, () {
        try {
          return AtolyeDenetimi.atolyede(s, KodYapisi.coz(s.ornekCozum),
                  rastgele: math.Random(1))
              .yurutme
              .cizgiler;
        } catch (_) {
          return const [];
        }
      });

  @override
  void paint(Canvas canvas, Size size) {
    if (cizgi.isEmpty) return;
    var minX = double.infinity, maxX = -double.infinity;
    var minY = double.infinity, maxY = -double.infinity;
    for (final c in cizgi) {
      minX = math.min(minX, math.min(c.x1, c.x2));
      maxX = math.max(maxX, math.max(c.x1, c.x2));
      minY = math.min(minY, math.min(c.y1, c.y2));
      maxY = math.max(maxY, math.max(c.y1, c.y2));
    }
    final w = math.max(maxX - minX, 1.0), h = math.max(maxY - minY, 1.0);
    final olcek = math.min((size.width - 12) / w, (size.height - 12) / h);
    final ox = (size.width - w * olcek) / 2, oy = (size.height - h * olcek) / 2;
    // Scratch'te y yukari; ekranda asagi.
    Offset p(double x, double y) =>
        Offset(ox + (x - minX) * olcek, oy + (maxY - y) * olcek);
    final kalem = Paint()
      ..color = renk
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final c in cizgi) {
      canvas.drawLine(p(c.x1, c.y1), p(c.x2, c.y2), kalem);
    }
  }

  @override
  bool shouldRepaint(_SekilOnizleme o) => o.cizgi != cizgi || o.renk != renk;
}
