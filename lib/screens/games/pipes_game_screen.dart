import 'dart:math';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import '../../theme.dart';
import '../../ui/count_up.dart';
import '../../ui/motion.dart';
import '../../ui/press_button.dart';
import '../../utils/lang.dart';
import '../../utils/score_calculator.dart';
import '../../widgets/oyun_basligi.dart';
import '../../widgets/oyun_cipleri.dart';
import '../../widgets/oyun_kimligi.dart';

/// Boru Bulmacasi: borulari dondurerek suyu kaynaktan cicege ulastir.
///
/// NEDEN FLAME DEGIL
/// -----------------
/// Oyun once bir Flame tuvaliydi: siyah zemin, ince gri cizgiler, tuvalin
/// ustune duz metinle yazilmis "Seviye/Skor/Hamle" ve bir "Yeni Oyun"
/// kutusu. Diger oyunlarin (Komut Dizilimi, Kod Bloklari) yuvarlak
/// kartlari, renkli cipleri ve dokunma animasyonlariyla yan yana baska
/// bir uygulamadan gelmis gibi duruyordu. Flame'in TextPaint'i temayi
/// devralmadigi icin yazi tipi bile elle verilmek zorundaydi.
///
/// Oyunun butun kurallari (izgara boyutu, sahte boru yogunlugu, BFS ile
/// baglanti, puan hesabi) [PipesBoard] icinde aynen duruyor; yalnizca
/// cizim Flutter widget'larina tasindi. Boylece boru donerken yumusakca
/// donuyor, baglanan borularda su akiyor ve seviye sonu tahtanin ustunde
/// bir kartla kutlaniyor.
class PipesGameScreen extends StatefulWidget {
  const PipesGameScreen({super.key, this.baslangicSeviyesi = 1});

  /// Testlerde buyuk izgarayi (8x8) dogrudan acmak icin. Oyunda hep 1.
  @visibleForTesting
  final int baslangicSeviyesi;

  @override
  State<PipesGameScreen> createState() => _PipesGameScreenState();
}

enum PipeType {
  empty,
  straight, // Düz boru (─ veya │)
  corner, // Köşe boru (└ ┌ ┐ ┘)
  source, // Başlangıç noktası (su deposu)
  sink, // Bitiş noktası (çiçek)
}

class PipeTile {
  PipeType type;
  int rotation; // 0, 1, 2, 3 (0, 90, 180, 270 derece)
  bool isConnected;

  /// Baslangictan beri toplam ceyrek tur. Cizimde [rotation] yerine bu
  /// kullaniliyor: 3'ten 0'a gecerken animasyon geriye, uc ceyrek tur
  /// boyunca donmesin, hep saat yonunde bir ceyrek ilerlesin.
  int turns;

  PipeTile({
    required this.type,
    this.rotation = 0,
    this.isConnected = false,
  }) : turns = rotation;

  void rotate() {
    if (type != PipeType.source && type != PipeType.sink) {
      rotation = (rotation + 1) % 4;
      turns++;
    }
  }

  /// Karistirma sirasinda yonu dogrudan atamak icin; [turns] da esitlenir.
  void setRotation(int r) {
    rotation = r % 4;
    turns = rotation;
  }

  /// Bağlantı noktalarını döndürme açısına göre al
  /// Direction mapping: 0=Sol, 1=Üst, 2=Sağ, 3=Alt
  List<int> getConnections() {
    switch (type) {
      case PipeType.straight:
        return rotation % 2 == 0
            ? [0, 2] // Yatay: sol-sağ
            : [1, 3]; // Dikey: üst-alt
      case PipeType.corner:
        // Saat yönünde rotation
        switch (rotation) {
          case 0:
            return [3, 0]; // Alt-Sol (└)
          case 1:
            return [0, 1]; // Sol-Üst (┌)
          case 2:
            return [1, 2]; // Üst-Sağ (┐)
          case 3:
            return [2, 3]; // Sağ-Alt (┘)
          default:
            return [];
        }
      case PipeType.source:
      case PipeType.sink:
        // Kaynak ve hedef tüm yönlere bağlanabilir
        return [0, 1, 2, 3];
      case PipeType.empty:
        return [];
    }
  }
}

/// Oyunun kurallari: izgarayi uretir, baglantiyi BFS ile hesaplar.
///
/// Ekrandan ayri tutuldu ki kurallar cizimden bagimsiz okunabilsin ve
/// test edilebilsin.
class PipesBoard {
  PipesBoard(this.gridSize);

  final int gridSize;
  late List<List<PipeTile>> grid;
  int sourceX = 0, sourceY = 0, sinkX = 0, sinkY = 0;

  /// Yön vektörleri: 0 sol, 1 üst, 2 sağ, 3 alt.
  static const List<Point<int>> yonler = [
    Point(-1, 0),
    Point(0, -1),
    Point(1, 0),
    Point(0, 1),
  ];

  bool _icinde(int x, int y) =>
      x >= 0 && x < gridSize && y >= 0 && y < gridSize;

  void generate({required double decoyFillRate, Random? random}) {
    final r = random ?? Random();
    grid = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) => PipeTile(type: PipeType.empty)),
    );

    // Kaynak ve hedef noktaları farklı kenarlarda yerleştir
    sourceY = 0;
    sinkY = gridSize - 1;
    sourceX = r.nextInt(gridSize);
    sinkX = r.nextInt(gridSize);

    grid[sourceY][sourceX] = PipeTile(type: PipeType.source);
    grid[sinkY][sinkX] = PipeTile(type: PipeType.sink);

    // Çözülebilir yol oluştur
    _createPath(sourceX, sourceY, sinkX, sinkY);

    // Rastgele pipe'lar ekle — seviyeye göre yoğunluk artar
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].type == PipeType.empty &&
            r.nextDouble() < decoyFillRate) {
          grid[i][j] = PipeTile(
            type: r.nextBool() ? PipeType.straight : PipeType.corner,
          );
        }
      }
    }

    // Tüm pipe'ları rastgele döndür (zorlaştırma için).
    //
    // HAZIR COZULMUS TAHTA: rastgele dondurme yolu bazen tesaduf eseri
    // dogru yone getiriyordu (4x4'te ~%6). O zaman seviye cocuk tek bir
    // boruya dokunmadan "Tebrikler" deyip geciyordu. Tahta cozulmus
    // ciktikca yeniden karistiriyoruz.
    for (var deneme = 0; deneme < 30; deneme++) {
      for (final satir in grid) {
        for (final t in satir) {
          if (t.type == PipeType.straight || t.type == PipeType.corner) {
            t.setRotation(r.nextInt(4));
          }
        }
      }
      if (!checkConnections()) break;
    }
  }

  void _createPath(int startX, int startY, int endX, int endY) {
    int currentX = startX;
    int currentY = startY;

    // Aşağıya doğru git
    while (currentY < endY) {
      currentY++;
      if (currentY < endY && grid[currentY][currentX].type == PipeType.empty) {
        grid[currentY][currentX] = PipeTile(
          type: PipeType.straight,
          rotation: 1, // Dikey
        );
      }
    }

    // Yatay hareket gerekiyorsa
    if (currentX != endX) {
      // Köşe koy: üstten gelen su sağa (┐, 2) ya da sola (┌, 1) döner.
      if (grid[currentY][currentX].type == PipeType.empty) {
        grid[currentY][currentX] = PipeTile(
          type: PipeType.corner,
          rotation: currentX < endX ? 2 : 1,
        );
      }

      // Yatay hareketi tamamla
      while (currentX != endX) {
        currentX += currentX < endX ? 1 : -1;
        if (currentX != endX &&
            grid[currentY][currentX].type == PipeType.empty) {
          grid[currentY][currentX] = PipeTile(
            type: PipeType.straight,
            rotation: 0, // Yatay
          );
        }
      }
    }
  }

  /// Kaynaktan BFS ile bagli kareleri isaretler. Hedef bagliysa true.
  bool checkConnections() {
    for (final row in grid) {
      for (final tile in row) {
        tile.isConnected = false;
      }
    }

    final visited = <Point<int>>{Point(sourceX, sourceY)};
    final queue = <Point<int>>[Point(sourceX, sourceY)];
    grid[sourceY][sourceX].isConnected = true;

    while (queue.isNotEmpty) {
      final pos = queue.removeAt(0);
      for (final dir in grid[pos.y][pos.x].getConnections()) {
        final n = pos + yonler[dir];
        if (!_icinde(n.x, n.y) || visited.contains(n)) continue;
        // Komşu bu yönden (karşı yönden) bağlanabiliyorsa su geçer.
        if (grid[n.y][n.x].getConnections().contains((dir + 2) % 4)) {
          visited.add(n);
          grid[n.y][n.x].isConnected = true;
          queue.add(n);
        }
      }
    }
    return grid[sinkY][sinkX].isConnected;
  }

  /// Bu kareye boru ucuyla degen komsularin yonleri. Depo ve cicek her
  /// yone baglanabiliyor; cizimde yalnizca gercekten bir boru degen
  /// yonlere kisa bir baglanti agzi ciziliyor.
  List<int> komsuYonleri(int x, int y) {
    final sonuc = <int>[];
    for (var dir = 0; dir < 4; dir++) {
      final n = Point(x, y) + yonler[dir];
      if (!_icinde(n.x, n.y)) continue;
      if (grid[n.y][n.x].getConnections().contains((dir + 2) % 4)) {
        sonuc.add(dir);
      }
    }
    return sonuc;
  }

  /// Suyun cicege ne kadar yaklastigi, 0..1.
  ///
  /// Bagli karelerden hedefe en kisa kare mesafesi, kaynakla hedef
  /// arasindaki mesafeye bolunuyor. Cocuk her dogru donusle cubugun
  /// ilerledigini goruyor; seviye "ya hep ya hic" hissettirmiyor.
  double get yakinlik {
    final bas = (sourceX - sinkX).abs() + (sourceY - sinkY).abs();
    if (bas == 0) return 1;
    var enAz = bas;
    for (var y = 0; y < gridSize; y++) {
      for (var x = 0; x < gridSize; x++) {
        if (!grid[y][x].isConnected) continue;
        final d = (x - sinkX).abs() + (y - sinkY).abs();
        if (d < enAz) enAz = d;
      }
    }
    return (1 - enAz / bas).clamp(0.0, 1.0);
  }
}

class _PipesGameScreenState extends State<PipesGameScreen>
    with SingleTickerProviderStateMixin {
  static const Color _renk = Color(0xFF0097A7);
  static const Color _su = Color(0xFF29B6F6);

  int currentLevel = 1;
  int score = 0;
  int moveCount = 0;
  bool gameWon = false;
  int _sonKazanc = 0;
  late PipesBoard _board;

  /// Suyun akis animasyonu. Hareketi azalt acikken durgun.
  late final AnimationController _akis = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  /// Dort dilli kisa yazi yardimcisi.
  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  // Kademeli grid boyutu: seviye arttıkça yavaşça büyür
  int get gridSize {
    if (currentLevel <= 2) return 4;
    if (currentLevel <= 5) return 5;
    if (currentLevel <= 8) return 6;
    if (currentLevel <= 12) return 7;
    return 8;
  }

  // Seviyeye göre sahte boru yoğunluğu
  double get _decoyFillRate {
    return (0.15 + currentLevel * 0.04).clamp(0.15, 0.60);
  }

  @override
  void initState() {
    super.initState();
    // Bu ekranin ses rengi (devre/boru). Butun oyunlarda ayni tonu
    // calmak oyunlari birbirinden ayirt edilemez kiliyordu.
    SoundService.useVoice(SfxVoice.deep);
    if (!Motion.reducedRaw) _akis.repeat();
    currentLevel = widget.baslangicSeviyesi;
    _resetLevel();
  }

  @override
  void dispose() {
    _akis.dispose();
    super.dispose();
  }

  void _newGame() {
    // Tüm oyunu sıfırla (seviye 1'den başla)
    setState(() {
      currentLevel = 1;
      score = 0;
      _resetLevel();
    });
  }

  void _resetLevel() {
    moveCount = 0;
    gameWon = false;
    _board = PipesBoard(gridSize)..generate(decoyFillRate: _decoyFillRate);
  }

  void _nextLevel() {
    setState(() {
      currentLevel++;
      _resetLevel();
    });
  }

  void _onTileTapped(int x, int y) {
    if (gameWon) return;
    final tile = _board.grid[y][x];
    if (tile.type == PipeType.empty ||
        tile.type == PipeType.source ||
        tile.type == PipeType.sink) {
      return;
    }

    SoundService.playClick();
    setState(() {
      tile.rotate();
      moveCount++;
      if (_board.checkConnections()) _kazan();
    });
  }

  void _kazan() {
    gameWon = true;
    // Standardize edilmiş skor hesapla
    _sonKazanc = ScoreCalculator.calculatePipesScore(
      level: currentLevel,
      moves: moveCount,
      gridSize: gridSize,
    );
    score += _sonKazanc;
    SoundService.playLevelComplete();
    SoundService.playScore();
    // Eskiden 2 saniye sonra kendiliginden sonraki seviyeye geciliyordu
    // ve bu Future ekran kapansa da calisiyordu. Artik cocuk kutlama
    // kartindaki dugmeyle geciyor.
  }

  // Ust ciplerdeki yazilar. "Punkte/Puntos/Nivel/Züge/Movimientos" dort
  // dil testinde araniyor: Almanca/Ispanyolca kullanici Turkce
  // "Seviye/Skor" gormesin.
  String get _seviyeEtiketi => _t('Seviye', 'Level', 'Level', 'Nivel');
  String get _skorEtiketi => _t('Skor', 'Score', 'Punkte', 'Puntos');
  String get _hamleEtiketi => _t('Hamle', 'Moves', 'Züge', 'Movimientos');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OyunZemini.ustRenk(_renk),
      appBar: OyunBasligi.oyun(
        GameType.pipesPuzzle,
        baslikWidget: Text(_t('Boru Bulmacası', 'Pipes Puzzle', 'Rohr-Rätsel',
            'Rompecabezas de tuberías')),
        eylemler: [
          IconButton(
            tooltip: _t('Yeni Oyun', 'New Game', 'Neues Spiel', 'Nuevo juego'),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _newGame,
          ),
          IconButton(
            tooltip: _t('Nasıl Oynanır?', 'How to Play?', 'Wie spielt man?',
                '¿Cómo se juega?'),
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: _showGameInfo,
          ),
        ],
      ),
      body: OyunZemini(
        renk: OyunKimligi.renk(GameType.pipesPuzzle),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ciplerSatiri(),
                const SizedBox(height: 14),
                _yakinlikCubugu(),
                const SizedBox(height: 14),
                Expanded(child: _tahtaAlani()),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: Motion.adapt(context, Motion.medium2),
                  child: gameWon ? _kutlama() : _ipucuSatiri(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ciplerSatiri() {
    return Row(
      children: [
        Expanded(
          child: OyunCipi(
            key: const ValueKey('boru_cip_seviye'),
            simge: Icons.flag_rounded,
            etiket: _seviyeEtiketi,
            deger: Text('$currentLevel'),
            renk: const Color(0xFF7E57C2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OyunCipi(
            key: const ValueKey('boru_cip_hamle'),
            simge: Icons.rotate_right_rounded,
            etiket: _hamleEtiketi,
            deger: Text('$moveCount'),
            renk: _renk,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OyunCipi(
            key: const ValueKey('boru_cip_skor'),
            simge: Icons.star_rounded,
            etiket: _skorEtiketi,
            deger: CountUpText(
              value: score,
              fontSize: 18,
              color: const Color(0xFFE65100),
            ),
            renk: const Color(0xFFFFA000),
          ),
        ),
      ],
    );
  }

  /// "Su cicege ne kadar yaklasti" cubugu: solda damla, sagda cicek.
  Widget _yakinlikCubugu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _renk.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop_rounded, color: _su, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: ProgressTrack(
              value: _board.yakinlik,
              color: _su,
              background: const Color(0xFFE1F5FE),
              height: 12,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.local_florist_rounded,
            color: gameWon ? const Color(0xFFEC407A) : const Color(0xFFBDBDBD),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _tahtaAlani() {
    return LayoutBuilder(builder: (context, c) {
      final n = gridSize;
      // DOKUNMA HEDEFI: 8x8 tahtada her piksel kareye gitsin diye buyuk
      // izgarada aralik ve dolgu daraliyor (390 puntoluk telefonda kare
      // ~41 punto; eski Flame tahtasiyla ayni).
      final bosluk = n >= 7 ? 3.0 : 6.0;
      final dolgu = n >= 7 ? 6.0 : 10.0;
      final kenar = min(c.maxWidth, c.maxHeight) - 2 * dolgu - 4;
      final kare = min((kenar - bosluk * (n - 1)) / n, 88.0).floorToDouble();
      final tahta = kare * n + bosluk * (n - 1);

      return Center(
        child: Container(
          padding: EdgeInsets.all(dolgu),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: _renk.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: _renk.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            key: const ValueKey('boru_tahtasi'),
            width: tahta,
            height: tahta,
            child: Column(
              children: [
                for (var y = 0; y < n; y++) ...[
                  if (y > 0) SizedBox(height: bosluk),
                  Row(
                    children: [
                      for (var x = 0; x < n; x++) ...[
                        if (x > 0) SizedBox(width: bosluk),
                        _BoruKaresi(
                          key: ValueKey('boru_kare_${x}_$y'),
                          tile: _board.grid[y][x],
                          boyut: kare,
                          agizlar: _board.grid[y][x].type == PipeType.source ||
                                  _board.grid[y][x].type == PipeType.sink
                              ? _board.komsuYonleri(x, y)
                              : const [],
                          akis: _akis,
                          onTap: () => _onTileTapped(x, y),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Seviye sonu: tahtanin altinda kutlama karti ve "Sonraki seviye".
  Widget _kutlama() {
    return SeviyeKutlamaKarti(
      key: const ValueKey('boru_kutlama'),
      simge: Icons.local_florist_rounded,
      renk: const Color(0xFFEC407A),
      baslik: _t('Çiçek sulandı!', 'The flower is watered!',
          'Die Blume ist gegossen!', '¡La flor está regada!'),
      altYazi: _t(
          '+$_sonKazanc puan · $moveCount hamle',
          '+$_sonKazanc points · $moveCount moves',
          '+$_sonKazanc Punkte · $moveCount Züge',
          '+$_sonKazanc puntos · $moveCount movimientos'),
      eylem: PressButton(
        label: _t('Sonraki seviye', 'Next level', 'Nächstes Level',
            'Siguiente nivel'),
        icon: Icons.arrow_forward_rounded,
        color: _renk,
        onPressed: _nextLevel,
        height: 52,
      ),
    );
  }

  Widget _ipucuSatiri() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.touch_app_rounded, color: _renk, size: 20),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            _t(
                'Borulara dokun, çevir; suyu çiçeğe ulaştır!',
                'Tap the pipes to turn them and bring water to the flower!',
                'Tippe auf die Rohre, um sie zu drehen, und bring Wasser zur Blume!',
                '¡Toca las tuberías para girarlas y lleva agua a la flor!'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color.lerp(_renk, Colors.black, 0.35),
            ),
          ),
        ),
      ],
    );
  }

  void _showGameInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(_t('Boru Bulmacası', 'Pipes Puzzle', 'Rohr-Rätsel',
            'Rompecabezas de tuberías')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t('Nasıl Oynanır?', 'How to Play?', 'Wie spielt man?',
                    '¿Cómo se juega?'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                _t(
                    '• Mavi depodaki suyu çiçeğe ulaştıracak bir boru hattı kur\n'
                        '• Boru parçalarına dokunarak döndür\n'
                        '• Su geçen borular maviye boyanır\n'
                        '• En az hamleyle tamamlamaya çalış!',
                    '• Build a pipeline that carries water from the blue tank to the flower\n'
                        '• Tap pipe pieces to rotate them\n'
                        '• Pipes with water in them turn blue\n'
                        '• Try to finish with as few moves as possible!',
                    '• Baue eine Leitung, die Wasser vom blauen Tank zur Blume bringt\n'
                        '• Tippe auf Rohrteile, um sie zu drehen\n'
                        '• Rohre mit Wasser werden blau\n'
                        '• Versuche, mit möglichst wenigen Zügen fertig zu werden!',
                    '• Construye una tubería que lleve el agua del tanque azul a la flor\n'
                        '• Toca las piezas para girarlas\n'
                        '• Las tuberías con agua se vuelven azules\n'
                        '• ¡Intenta terminar con los menos movimientos posibles!'),
              ),
              const SizedBox(height: 16),
              Text(
                _t('Boru Türleri', 'Pipe Types', 'Rohrarten',
                    'Tipos de tubería'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                _t(
                    '💧 Depo: suyun çıktığı yer\n'
                        '🌸 Çiçek: suyun ulaşacağı yer\n'
                        '━ Düz boru: iki yönlü bağlantı\n'
                        '┛ Köşe boru: 90 derece dönüş',
                    '💧 Tank: where the water comes from\n'
                        '🌸 Flower: where the water must go\n'
                        '━ Straight pipe: two-way connection\n'
                        '┛ Corner pipe: 90 degree turn',
                    '💧 Tank: hier kommt das Wasser her\n'
                        '🌸 Blume: hierhin soll das Wasser\n'
                        '━ Gerades Rohr: Verbindung in zwei Richtungen\n'
                        '┛ Eckrohr: 90-Grad-Drehung',
                    '💧 Tanque: de donde sale el agua\n'
                        '🌸 Flor: adonde debe llegar el agua\n'
                        '━ Tubo recto: conexión en dos sentidos\n'
                        '┛ Tubo de esquina: giro de 90 grados'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('Tamam', 'OK', 'OK', 'Vale')),
          ),
        ],
      ),
    );
  }
}

/// Izgaradaki tek kare: yuvarlak kart, ustunde boru, depo ya da cicek.
class _BoruKaresi extends StatelessWidget {
  const _BoruKaresi({
    super.key,
    required this.tile,
    required this.boyut,
    required this.agizlar,
    required this.akis,
    required this.onTap,
  });

  final PipeTile tile;
  final double boyut;
  final List<int> agizlar;
  final Animation<double> akis;
  final VoidCallback onTap;

  static const Color _su = Color(0xFF29B6F6);

  @override
  Widget build(BuildContext context) {
    final bos = tile.type == PipeType.empty;
    final dolu = tile.isConnected;
    final kose = BorderRadius.circular(boyut * 0.22);

    final zemin = bos
        ? Colors.white.withValues(alpha: 0.35)
        : dolu
            ? const Color(0xFFE1F5FE)
            : Colors.white;

    Widget icerik;
    switch (tile.type) {
      case PipeType.empty:
        icerik = const SizedBox.expand();
      case PipeType.straight:
      case PipeType.corner:
        // Boru 0 yonunde ciziliyor, kart ceyrek turlarla donduruluyor.
        icerik = AnimatedRotation(
          turns: tile.turns / 4,
          duration: Motion.adapt(context, Motion.medium2),
          curve: Motion.overshoot,
          child: CustomPaint(
            size: Size.square(boyut),
            painter: _BoruRessami(
              kose: tile.type == PipeType.corner,
              dolu: dolu,
              akis: akis,
            ),
          ),
        );
      case PipeType.source:
      case PipeType.sink:
        icerik = Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(boyut),
              painter: _AgizRessami(
                yonler: agizlar,
                dolu: dolu,
                akis: akis,
              ),
            ),
            tile.type == PipeType.source
                ? _Depo(boyut: boyut)
                : _Cicek(boyut: boyut, sulandi: dolu),
          ],
        );
    }

    return GestureDetector(
      onTap: bos ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: Motion.adapt(context, Motion.medium2),
        width: boyut,
        height: boyut,
        decoration: BoxDecoration(
          color: zemin,
          borderRadius: kose,
          border: Border.all(
            color: bos
                ? Colors.white.withValues(alpha: 0.6)
                : dolu
                    ? _su.withValues(alpha: 0.55)
                    : const Color(0xFFCFD8DC),
            width: dolu ? 2 : 1.2,
          ),
          boxShadow: bos
              ? null
              : [
                  BoxShadow(
                    color: (dolu ? _su : const Color(0xFF607D8B))
                        .withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: ClipRRect(borderRadius: kose, child: icerik),
      ),
    );
  }
}

/// Mavi su deposu: kaynagin yerine.
class _Depo extends StatelessWidget {
  const _Depo({required this.boyut});
  final double boyut;

  @override
  Widget build(BuildContext context) {
    final r = boyut * 0.62;
    return Container(
      width: r,
      height: r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFF81D4FA), Color(0xFF0288D1)],
        ),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0288D1).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child:
          Icon(Icons.water_drop_rounded, color: Colors.white, size: r * 0.55),
    );
  }
}

/// Hedef cicek: su gelene kadar saksida filiz, gelince acan pembe cicek.
class _Cicek extends StatelessWidget {
  const _Cicek({required this.boyut, required this.sulandi});
  final double boyut;
  final bool sulandi;

  @override
  Widget build(BuildContext context) {
    final r = boyut * 0.62;
    return AnimatedScale(
      scale: sulandi ? 1.12 : 1,
      duration: Motion.adapt(context, Motion.long2),
      curve: Motion.overshoot,
      child: AnimatedContainer(
        duration: Motion.adapt(context, Motion.medium2),
        width: r,
        height: r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: sulandi
                ? const [Color(0xFFF8BBD0), Color(0xFFEC407A)]
                : const [Color(0xFFFFE0B2), Color(0xFFFFB74D)],
          ),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color:
                  (sulandi ? const Color(0xFFEC407A) : const Color(0xFFFB8C00))
                      .withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          sulandi ? Icons.local_florist_rounded : Icons.spa_rounded,
          color: Colors.white,
          size: r * 0.58,
        ),
      ),
    );
  }
}

/// Boru cizimi. 0 yonunde: duz boru soldan saga, kose boru soldan asagi.
///
/// Eskiden 6 piksellik ince bir cizgiydi; cocuk hangi parcanin nereye
/// baktigini zor seciyordu. Simdi kalin, uclari yuvarlak, kenarli bir
/// boru; su gectiginde maviye donuyor ve icinde beyaz dalgalar akiyor.
class _BoruRessami extends CustomPainter {
  _BoruRessami({required this.kose, required this.dolu, required this.akis})
      : super(repaint: dolu ? akis : null);

  final bool kose;
  final bool dolu;
  final Animation<double> akis;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = s / 2;
    final path = Path()..moveTo(0, c);
    if (kose) {
      final r = s * 0.22;
      path
        ..lineTo(c - r, c)
        ..quadraticBezierTo(c, c, c, c + r)
        ..lineTo(c, s);
    } else {
      path.lineTo(s, c);
    }
    _boruCiz(canvas, s, path, dolu, akis.value);

    // Uclardaki baglanti bilezikleri: borunun bir sonraki kareye
    // "takildigi" yer. Parcanin hangi kenarlara acildigini netlestiriyor.
    final bilezik = Paint()
      ..color = dolu ? const Color(0xFF0277BD) : const Color(0xFF78909C);
    final w = s * 0.34, h = s * 0.1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, c - w / 2, h, w), Radius.circular(h * 0.4)),
        bilezik);
    if (kose) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(c - w / 2, s - h, w, h), Radius.circular(h * 0.4)),
          bilezik);
    } else {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(s - h, c - w / 2, h, w), Radius.circular(h * 0.4)),
          bilezik);
    }
  }

  @override
  bool shouldRepaint(covariant _BoruRessami old) =>
      old.kose != kose || old.dolu != dolu;
}

/// Depo ve cicekten komsu boruya uzanan kisa agizlar.
class _AgizRessami extends CustomPainter {
  _AgizRessami({required this.yonler, required this.dolu, required this.akis})
      : super(repaint: dolu ? akis : null);

  final List<int> yonler;
  final bool dolu;
  final Animation<double> akis;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = s / 2;
    for (final y in yonler) {
      final uc = switch (y) {
        0 => Offset(0, c),
        1 => Offset(c, 0),
        2 => Offset(s, c),
        _ => Offset(c, s),
      };
      // Su merkezden disari akiyor gibi gorunsun: yol merkezden uca.
      final path = Path()
        ..moveTo(c, c)
        ..lineTo(uc.dx, uc.dy);
      _boruCiz(canvas, s, path, dolu, akis.value);
    }
  }

  @override
  bool shouldRepaint(covariant _AgizRessami old) =>
      old.dolu != dolu || old.yonler.join() != yonler.join();
}

/// Ortak boru fircasi: koyu kenar, govde, parlama ve (doluysa) akan su.
void _boruCiz(Canvas canvas, double s, Path path, bool dolu, double t) {
  final kalinlik = s * 0.26;
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = kalinlik + s * 0.07
      ..strokeJoin = StrokeJoin.round
      ..color = dolu ? const Color(0xFF0277BD) : const Color(0xFF78909C),
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = kalinlik
      ..strokeJoin = StrokeJoin.round
      ..color = dolu ? const Color(0xFF29B6F6) : const Color(0xFFCFD8DC),
  );
  if (!dolu) {
    // Bos boruda ince bir parlama: metal hissi.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = kalinlik * 0.22
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    return;
  }
  // Akan su: yol boyunca kayan beyaz kisa cizgiler.
  final dalga = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = kalinlik * 0.32
    ..color = Colors.white.withValues(alpha: 0.75);
  final adim = s * 0.36;
  final parca = s * 0.14;
  for (final PathMetric m in path.computeMetrics()) {
    var d = (t * adim) - adim;
    while (d < m.length) {
      final bas = d.clamp(0.0, m.length);
      final son = (d + parca).clamp(0.0, m.length);
      if (son > bas) canvas.drawPath(m.extractPath(bas, son), dalga);
      d += adim;
    }
  }
}
