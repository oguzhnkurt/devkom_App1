import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/game_model.dart';
import '../providers/settings_provider.dart';
import '../services/embedded_games_service.dart';
import '../services/games_service.dart';
import '../theme.dart';
import '../ui/appear_in.dart';
import '../ui/motion.dart';
import '../utils/lang.dart';
import '../utils/pro_gate.dart';
import '../widgets/playful_background.dart';
import 'game_play_screen.dart';

/// Oyunlar ekranı.
///
/// Önceki hâlinde üstte dört sekmelik bir kategori şeridi vardı ve kartlar
/// pastel zeminler, parlama efektleri, yıldız sıraları, kupa simgeleri ve
/// kategori etiketleriyle doluydu — bir kartta beş ayrı rozet birden
/// duruyordu ve göz nereye bakacağını bilmiyordu. Şimdi tek bir düzenli
/// ızgara var: her kart bir görsel, bir başlık ve iki bilgi (süre, zorluk).
/// Kilitli oyunlarda görselin köşesinde tek bir Pro rozeti çıkıyor.
class RoboticsGamesScreen extends StatefulWidget {
  const RoboticsGamesScreen({super.key});

  @override
  State<RoboticsGamesScreen> createState() => _RoboticsGamesScreenState();
}

class _RoboticsGamesScreenState extends State<RoboticsGamesScreen> {
  final GamesService _gamesService = GamesService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;

  @override
  Widget build(BuildContext context) {
    // Zemin artik duz gri degil: konuyla ilgili semboller (kod blogu, disli,
    // yon oku, devre dugumu, kod parantezi) cok soluk ve cok yavas suzuluyor.
    // Kartlarin okunurlugu bozulmuyor ama sayfa "liste" degil "oyun alani"
    // gibi duruyor.
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      appBar: _buildAppBar(),
      body: PlayfulBackground(
        baseColor: AppTheme.lightGray,
        tint: const Color(0xFF7E57C2),
        child: SafeArea(top: false, child: _buildGamesGrid()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // GERI TUSU HAKKINDA: burada bir sure `Navigator.of(context).canPop()`
    // ile elle bir `leading` kuruyorduk. Bu bir gerilemeydi — ekran alt
    // sekmenin govdesi olarak da cizilebildigi icin o kontrol yanlis yerde
    // false donuyor ve geri tusu HIC gorunmuyordu. Flutter'in kendi kontrolu
    // (`automaticallyImplyLeading`) rotayi soruyor, navigator'i degil:
    // itilmis bir rotada tusu koyuyor, sekme govdesinde koymuyor. Dogru
    // davranis zaten buydu; elle yazilan surumu kaldirdik.
    // GERI TUSU GORUNMUYORDU. Baslik cubugu sayfanin zemin rengiyle
    // (lightGray) AYNI renkteydi; koyu gri ok acik gri zeminin uzerinde
    // yuzuyor, bir "dugme" gibi durmuyordu. Simdi cubuk sayfanin mor
    // vurgusunu tasiyor ve ok beyaz.
    const mor = Color(0xFF7E57C2);
    return AppBar(
      title: Text(AppLang.pick(_lang,
          tr: 'Oyunlar', en: 'Games', de: 'Spiele', es: 'Juegos')),
      centerTitle: false,
      backgroundColor: mor,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      actions: [
        IconButton(
          tooltip: AppLang.pick(_lang,
              tr: 'Oyun ara',
              en: 'Search games',
              de: 'Spiele suchen',
              es: 'Buscar juegos'),
          icon: Icon(_searchQuery.isEmpty
              ? Icons.search_rounded
              : Icons.search_off_rounded),
          onPressed: _searchQuery.isEmpty
              ? _showSearchDialog
              : () => setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  }),
        ),
      ],
    );
  }

  Widget _buildGamesGrid() {
    return FutureBuilder<List<dynamic>>(
      future: _gamesService.getAllGames(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBlue),
          );
        }

        var games = List<GameModel>.from(snapshot.data!.cast<GameModel>());

        // Satrançtan yalnızca gömülü sürüm gösteriliyor; eski kayıtlar
        // katalogda mükerrer satranç oluşturuyordu.
        games = games
            .where((g) => g.type != GameType.chess || g.id == 'embedded_chess')
            .toList();

        // NOT: Burada eskiden elle yazılmış bir `availableGameTypes` beyaz
        // listesi vardı ve listeye eklenen yeni oyunlar (Kod Dedektifi,
        // Değişken Ustası, Hata Avcısı) o listede olmadıkları için ekranda
        // hiç görünmüyordu. Beyaz liste kaldırıldı: hangi oyunun oynanabilir
        // olduğunu test/games_catalog_test.dart doğruluyor.

        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          games = games.where((game) {
            return game.title.toLowerCase().contains(q) ||
                game.description.toLowerCase().contains(q) ||
                (game.titleEn?.toLowerCase().contains(q) ?? false) ||
                (game.descriptionEn?.toLowerCase().contains(q) ?? false);
          }).toList();
        }

        // Sıralama: önce ücretsiz oyunlar (çocuk kilide çarpmadan oynasın),
        // sonra kolaydan zora, en sonda alfabetik — liste her açılışta aynı
        // sırada çıksın diye.
        games.sort((a, b) {
          final aPro = ProGames.isProGame(a.type) ? 1 : 0;
          final bPro = ProGames.isProGame(b.type) ? 1 : 0;
          if (aPro != bPro) return aPro.compareTo(bPro);
          if (a.difficulty != b.difficulty) {
            return a.difficulty.compareTo(b.difficulty);
          }
          return a.title.compareTo(b.title);
        });

        if (games.isEmpty) return _buildEmptyState();

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            // Rozet yalnızca kilit gerçekten geçerliyse: Pro üyeye her kartta
            // asma kilit göstermek satın aldığı şeyi kilitli hissettiriyor.
            final needsPro = ProGames.isProGame(game.type);
            final locked = needsPro && !ProGate.watchIsPro(context);

            // Kartlar hep birlikte "zipliyordu"; simdi soldan saga, yukaridan
            // asagi 45 ms arayla giriyorlar. Gecikme 360 ms'de tavan yapiyor
            // ki listenin sonundaki kart bekletilmesin.
            return AppearIn(
              delay: AppearIn.stagger(index),
              child: _GameCard(
                game: game,
                lang: _lang,
                isProLocked: locked,
                onTap: () => _openGame(game, needsPro),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openGame(GameModel game, bool needsPro) async {
    if (needsPro) {
      // Kilitli oyunda iki yol var: Pro almak ya da bir reklam izleyip
      // TEK TUR oynamak. Tek tur bilerek: cocuk oyunu gercekten gorsun
      // diye, ama oyun reklamla sinirsiz acilmasin diye.
      final sonuc = await ProGate.ensureOrAd(
        context,
        featureName: game.title,
        explanation: 'Bu oyun Pro üyelikte. Blok kodlama, sıralama, sağ-sol, '
            'koordinat, renk kodlama ve kelime eşleştirme oyunları herkese '
            'açık kalıyor.',
        reklamEtiketi: (lang) => AppLang.pick(
          lang,
          tr: 'Reklam izle, bir tur oyna',
          en: 'Watch an ad, play one round',
          de: 'Werbung ansehen, eine Runde spielen',
          es: 'Ver un anuncio y jugar una ronda',
        ),
      );
      if (sonuc == ProUnlock.kapali || !mounted) return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GamePlayScreen(game: game)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videogame_asset_off_rounded,
                size: 56, color: AppTheme.mediumGray),
            const SizedBox(height: 14),
            Text(
              _searchQuery.isEmpty
                  ? 'Henüz oyun eklenmemiş'
                  : '"$_searchQuery" için sonuç yok',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                }),
                child: const Text('Tüm oyunları göster'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Oyun ara',
          style:
              TextStyle(color: AppTheme.darkGray, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          // Metin rengi bilerek koyu: bu alan eskiden beyazdı (koyu tema
          // artığı) ve beyaz zeminde yazılan hiçbir şey görünmüyordu.
          style: const TextStyle(color: AppTheme.darkGray),
          decoration: InputDecoration(
            hintText: 'Oyun adı',
            filled: true,
            fillColor: AppTheme.lightGray,
            prefixIcon: const Icon(Icons.search, color: AppTheme.mediumGray),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryBlue, width: 1.6),
            ),
          ),
          onSubmitted: (value) {
            setState(() => _searchQuery = value.trim());
            Navigator.pop(dialogContext);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
              Navigator.pop(dialogContext);
            },
            child: const Text('Temizle',
                style: TextStyle(color: AppTheme.mediumGray)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _searchQuery = _searchController.text.trim());
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }
}

/// Hangi oyunlar Pro üyelik ister.
class ProGames {
  ProGames._();

  static const Set<GameType> free = {
    GameType.quiz,
    GameType.blockCoding,
    GameType.sequencing,
    GameType.leftRightCoding,
    GameType.coordinates,
    GameType.colorCoding,
    GameType.wordMatch,
  };

  static bool isProGame(GameType type) => !free.contains(type);

  /// Pro'nun açtığı oyun sayısı — paywall'da yazan rakam buradan geliyor.
  ///
  /// Elle yazılmış bir sayı zamanla yalan oluyor: oyun eklenip
  /// çıkarıldıkça kimse paywall'ı güncellemiyor. Paywall "13 ek oyun"
  /// derken gerçek sayı 9'du.
  static int get lockedGameCount => EmbeddedGamesService.getAllEmbeddedGames()
      .where((g) => isProGame(g.type))
      .length;
}

/// Izgaradaki tek oyun kartı.
///
/// Bilerek fotoğraf kullanmıyoruz. Kartlarda daha önce stok fotoğraflar
/// vardı — matematik defterine tutulmuş bir kalem, sahnede duran biri,
/// teleskoplu bir adam — ve hiçbiri oyunla ilgili değildi; ekran gazete
/// küpürü gibi duruyordu. Her oyunun kendi simgesi ve rengi olunca hem
/// tutarlı bir görsel dil çıkıyor hem de okuma yazması zayıf bir çocuk
/// oyunu simgesinden tanıyabiliyor.
class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.lang,
    required this.isProLocked,
    required this.onTap,
  });

  final GameModel game;
  final String lang;
  final bool isProLocked;
  final VoidCallback onTap;

  static const _difficultyLabels = ['', 'Kolay', 'Kolay', 'Orta', 'Zor', 'Zor'];

  /// Oyun türüne göre simge. Çocuk kartı okumadan da ne olduğunu anlasın.
  static IconData _iconFor(GameType type) => switch (type) {
        GameType.chess => Icons.castle_rounded,
        GameType.quiz => Icons.emoji_events_rounded,
        GameType.blockCoding => Icons.widgets_rounded,
        GameType.wordMatch => Icons.abc_rounded,
        GameType.sequencing => Icons.reorder_rounded,
        GameType.coordinates => Icons.grid_4x4_rounded,
        GameType.mazeExplorer => Icons.route_rounded,
        GameType.colorCoding => Icons.palette_rounded,
        GameType.robotSimulator => Icons.smart_toy_rounded,
        GameType.leftRightCoding => Icons.turn_right_rounded,
        GameType.arduinoSimulator => Icons.memory_rounded,
        GameType.pipesPuzzle => Icons.water_drop_rounded,
        GameType.patternDetective => Icons.pattern_rounded,
        GameType.variableMaster => Icons.inventory_2_rounded,
        GameType.bugHunter => Icons.pest_control_rounded,
        GameType.matchingGame => Icons.join_inner_rounded,
        GameType.puzzle => Icons.extension_rounded,
        GameType.simulation => Icons.science_rounded,
      };

  /// Oyunun gerçek oynanış görüntüsü. Dosya yoksa renkli simgeye düşüyoruz,
  /// böylece görüntüsü henüz alınmamış bir oyun kartı boş kalmıyor.
  static String _shotFor(GameType type) =>
      'assets/images/games/${type.name}.png';

  /// Oyun türüne göre renk. Aynı aileden oyunlar aynı rengi paylaşıyor:
  /// mavi = mantık/algoritma, mor = bloklar, turuncu = quiz, yeşil = robotik.
  static Color _colorFor(GameType type) => switch (type) {
        GameType.chess => const Color(0xFF3F51B5),
        GameType.quiz => const Color(0xFFF57C00),
        GameType.blockCoding => const Color(0xFF7E57C2),
        GameType.sequencing => const Color(0xFF7E57C2),
        GameType.wordMatch => const Color(0xFF00897B),
        GameType.matchingGame => const Color(0xFF00897B),
        GameType.coordinates => const Color(0xFF1E88E5),
        GameType.mazeExplorer => const Color(0xFF1E88E5),
        GameType.leftRightCoding => const Color(0xFF1E88E5),
        GameType.patternDetective => const Color(0xFF5E35B1),
        GameType.variableMaster => const Color(0xFF5E35B1),
        GameType.bugHunter => const Color(0xFFD81B60),
        GameType.colorCoding => const Color(0xFFEC407A),
        GameType.robotSimulator => const Color(0xFF2E7D32),
        GameType.arduinoSimulator => const Color(0xFF00796B),
        GameType.pipesPuzzle => const Color(0xFF0097A7),
        GameType.puzzle => AppTheme.mediumGray,
        GameType.simulation => AppTheme.mediumGray,
      };

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(game.type);
    final difficulty = _difficultyLabels[game.difficulty.clamp(1, 5)];

    return _PressScale(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Image.asset(
                          _shotFor(game.type),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: color.withValues(alpha: 0.12),
                            alignment: Alignment.center,
                            child: Icon(_iconFor(game.type),
                                color: color, size: 34),
                          ),
                        ),
                      ),
                    ),
                    if (isProLocked)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF1B1B1B).withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded,
                                  size: 10, color: AppTheme.accentYellow),
                              SizedBox(width: 3),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  color: AppTheme.accentYellow,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  game.titleFor(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGray,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    game.descriptionFor(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mediumGray,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 13, color: AppTheme.mediumGray),
                    const SizedBox(width: 4),
                    Text(
                      '${game.estimatedMinutes} dk',
                      style: const TextStyle(
                          fontSize: 11.5, color: AppTheme.mediumGray),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppTheme.mediumGray,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        difficulty,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppTheme.mediumGray),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Basildiginda hafifce kuculen sarmalayici.
///
/// Cocuklarda dokunmanin "islendigini" gosteren en hizli geri bildirim bu;
/// InkWell'in dalgasi acik zeminde neredeyse gorunmuyor. `Listener`
/// kullaniyoruz cunku bir `GestureDetector` icerideki InkWell'in dokunusunu
/// yutabilirdi.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});

  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return widget.child;
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: _down ? Motion.short4 : Motion.medium2,
        curve: Motion.emphasized,
        child: widget.child,
      ),
    );
  }
}
