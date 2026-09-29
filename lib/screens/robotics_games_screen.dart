import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/game_model.dart';
import '../models/user_progress_model.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/embedded_games_service.dart';
import '../services/games_service.dart';
import '../theme.dart';
import '../ui/appear_in.dart';
import '../ui/motion.dart';
import '../utils/lang.dart';
import '../utils/pro_gate.dart';
import '../widgets/avatar_cercevesi.dart';
import '../widgets/mascot.dart';
import '../widgets/playful_background.dart';
import 'game_play_screen.dart';

/// Oyunlar ekranı.
///
/// NEDEN IZGARA KALKTI
/// -------------------
/// Ekran 2 sütunlu bir `GridView`'dı: her kart bir görsel, bir başlık, iki
/// satır açıklama ve "8 dk · Orta" yazısı taşıyordu. Düzenliydi ama bir
/// oyun rafı değil, bir tablo gibi duruyordu — on dört oyun aynı ağırlıkta,
/// aynı boyutta, aynı sırayla. Çocuk nereden başlayacağını bilmiyordu ve
/// açıklama metinlerini kimse okumuyordu.
///
/// Şimdi ekranın bir GİRİŞİ var: en üstte tek bir "Günün Görevi" kartı
/// (bugün ne oynayacağına karar vermek zorunda değilsin), altında konuya
/// göre yatay raflar. Yatay raf, ızgaranın yapamadığı iki şeyi yapıyor:
/// bir rafta sekiz oyun olsa bile ekranda üç tanesi görünüyor (seçim
/// bunaltmıyor) ve kaydırmanın kendisi "burada daha çok şey var" diyor.
///
/// KARTLARDAKİ YAZI NEDEN AZALDI
/// -----------------------------
/// Açıklama metinleri silindi. Bu ekranın okuma yazması daha zayıf bir
/// çocuğa da hizmet etmesi gerekiyor: kartta oyunun görseli, adı ve
/// zorluğu (üç yıldız) var, gerisi oyunun kendi ekranında. "8 dk" yazısı
/// da kalktı — süre bir vaat değildi, tahmindi.
///
/// GÖRSELLER
/// ---------
/// Başlıktaki jeton, Günün Görevi'ndeki sandık ve Pro tacı satın alınan
/// oyun arayüzü ikon paketinden (`assets/images/ui/`, bkz. o klasördeki
/// NASIL_HAZIRLANDI.md). Jetonun üstündeki dolar işareti kaldırılıp
/// yerine yıldız konuldu: burası para değil, oyun içi jeton.
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PlayfulBackground(
        baseColor: const Color(0xFFF4F2FB),
        tint: const Color(0xFF7C4DFF),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // BASLIK
  // ===========================================================

  /// Gradyanlı başlık: solda avatar, sağda seri/jeton kapsülü.
  ///
  /// GERİ TUŞU: bu ekran hem alt sekmenin gövdesi olarak hem de itilmiş
  /// bir rota olarak çiziliyor. `Navigator.canPop()` burada yanlış cevap
  /// veriyordu (sekme gövdesinde bile true dönüyor, çünkü altta başka
  /// rotalar var). Doğru soru rotaya sorulur: `ModalRoute.canPop` —
  /// Flutter'ın `automaticallyImplyLeading`'i de tam olarak buna bakıyor.
  Widget _buildHeader() {
    final geriVar = ModalRoute.of(context)?.canPop ?? false;
    // Durum cubugu simgeleri: mor gradyanin uzerinde beyaz olmali.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C4DFF), Color(0xFF2979FF)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x332979FF),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
          child: Column(
            children: [
              Row(
                children: [
                  if (geriVar)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    )
                  else
                    const _Avatar(),
                  const SizedBox(width: 10),
                  Expanded(child: _selamlama()),
                  _SayacKapsulu(lang: _lang),
                  IconButton(
                    tooltip: AppLang.pick(_lang,
                        tr: 'Oyun ara',
                        en: 'Search games',
                        de: 'Spiele suchen',
                        es: 'Buscar juegos'),
                    icon: Icon(
                      _searchQuery.isEmpty
                          ? Icons.search_rounded
                          : Icons.search_off_rounded,
                      color: Colors.white,
                    ),
                    onPressed: _searchQuery.isEmpty
                        ? _showSearchDialog
                        : () => setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            }),
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

  Widget _selamlama() {
    final ad = context.watch<AuthProvider>().currentUser?.displayName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLang.pick(_lang,
              tr: 'Oyunlar', en: 'Games', de: 'Spiele', es: 'Juegos'),
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        Text(
          ad == null || ad.isEmpty
              ? AppLang.pick(_lang,
                  tr: 'Hadi oynayalım!',
                  en: "Let's play!",
                  de: 'Auf geht\'s!',
                  es: '¡A jugar!')
              : AppLang.pick(_lang,
                  tr: 'Hazır mısın $ad?',
                  en: 'Ready, $ad?',
                  de: 'Bereit, $ad?',
                  es: '¿Listo, $ad?'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }

  // ===========================================================
  // GOVDE
  // ===========================================================

  Widget _buildBody() {
    return FutureBuilder<List<dynamic>>(
      future: _gamesService.getAllGames(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
          );
        }

        var games = List<GameModel>.from(snapshot.data!.cast<GameModel>());

        // Satrançtan yalnızca gömülü sürüm gösteriliyor; eski kayıtlar
        // katalogda mükerrer satranç oluşturuyordu.
        games = games
            .where((g) => g.type != GameType.chess || g.id == 'embedded_chess')
            .toList();

        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          games = games.where((game) {
            return game.title.toLowerCase().contains(q) ||
                game.description.toLowerCase().contains(q) ||
                (game.titleEn?.toLowerCase().contains(q) ?? false) ||
                (game.descriptionEn?.toLowerCase().contains(q) ?? false);
          }).toList();
        }

        if (games.isEmpty) return _buildEmptyState();

        // Arama sonuçlarında raf mantığı anlamsız: çocuk zaten ne
        // aradığını biliyor, tek bir liste veriyoruz.
        if (_searchQuery.isNotEmpty) return _aramaSonuclari(games);

        return _raflar(games);
      },
    );
  }

  Widget _aramaSonuclari(List<GameModel> games) {
    games.sort((a, b) => a.difficulty.compareTo(b.difficulty));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      itemCount: games.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => AppearIn(
        delay: AppearIn.stagger(i),
        child: _oyunKarti(games[i], genislik: double.infinity, yatay: true),
      ),
    );
  }

  Widget _raflar(List<GameModel> games) {
    final gunun = _gununGorevi(games);
    final bolumler = _Bolumler.ayir(games);

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const SizedBox(height: 16),
        if (gunun != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppearIn(child: _GununGoreviKarti(
              game: gunun,
              lang: _lang,
              onTap: () => _openGame(gunun, ProGames.isProGame(gunun.type)),
            )),
          ),
        for (final bolum in bolumler) ...[
          const SizedBox(height: 22),
          _bolumBasligi(bolum),
          const SizedBox(height: 12),
          SizedBox(
            height: 208,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: bolum.games.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => AppearIn(
                delay: AppearIn.stagger(i),
                child: _oyunKarti(bolum.games[i], genislik: 158),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _bolumBasligi(_Bolum bolum) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bolum.renk.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(bolum.simge, size: 19, color: bolum.renk),
          ),
          const SizedBox(width: 10),
          Text(
            bolum.ad(_lang),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF241C3B),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bolum.renk.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${bolum.games.length}',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: bolum.renk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _oyunKarti(GameModel game,
      {required double genislik, bool yatay = false}) {
    // Rozet yalnızca kilit gerçekten geçerliyse: Pro üyeye her kartta
    // asma kilit göstermek satın aldığı şeyi kilitli hissettiriyor.
    final needsPro = ProGames.isProGame(game.type);
    final locked = needsPro && !ProGate.watchIsPro(context);
    return _JelKart(
      game: game,
      lang: _lang,
      genislik: genislik,
      yatay: yatay,
      isProLocked: locked,
      onTap: () => _openGame(game, needsPro),
    );
  }

  /// Günün görevi: her gün başka bir oyun, ama aynı gün herkeste aynı.
  ///
  /// Rastgele seçmiyoruz — ekran her açılışta başka bir oyun önerseydi
  /// "günün görevi" olmazdı. Yılın kaçıncı günü olduğuna bakıyoruz, yani
  /// seçim gece yarısı değişiyor ve gün boyu sabit kalıyor.
  ///
  /// Kilitli oyunlar listeye girmiyor: çocuğu bir kilide davet etmek
  /// görevden çok reklam olurdu.
  GameModel? _gununGorevi(List<GameModel> games) {
    final acik = games.where((g) => !ProGames.isProGame(g.type)).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (acik.isEmpty) return null;
    final bugun = DateTime.now();
    final gun = bugun.difference(DateTime(bugun.year)).inDays;
    return acik[gun % acik.length];
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
                  ? AppLang.pick(_lang,
                      tr: 'Henüz oyun eklenmemiş',
                      en: 'No games yet',
                      de: 'Noch keine Spiele',
                      es: 'Aún no hay juegos')
                  : AppLang.pick(_lang,
                      tr: '"$_searchQuery" için sonuç yok',
                      en: 'No results for "$_searchQuery"',
                      de: 'Keine Treffer für "$_searchQuery"',
                      es: 'Sin resultados para "$_searchQuery"'),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
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
                child: Text(AppLang.pick(_lang,
                    tr: 'Tüm oyunları göster',
                    en: 'Show all games',
                    de: 'Alle Spiele zeigen',
                    es: 'Ver todos los juegos')),
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
        title: Text(
          AppLang.pick(_lang,
              tr: 'Oyun ara',
              en: 'Search games',
              de: 'Spiele suchen',
              es: 'Buscar juegos'),
          style: const TextStyle(
              color: AppTheme.darkGray, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          // Metin rengi bilerek koyu: bu alan eskiden beyazdı (koyu tema
          // artığı) ve beyaz zeminde yazılan hiçbir şey görünmüyordu.
          style: const TextStyle(color: AppTheme.darkGray),
          decoration: InputDecoration(
            hintText: AppLang.pick(_lang,
                tr: 'Oyun adı',
                en: 'Game name',
                de: 'Spielname',
                es: 'Nombre del juego'),
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
              borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.6),
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
            child: Text(
                AppLang.pick(_lang,
                    tr: 'Temizle',
                    en: 'Clear',
                    de: 'Löschen',
                    es: 'Borrar'),
                style: const TextStyle(color: AppTheme.mediumGray)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _searchQuery = _searchController.text.trim());
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLang.pick(_lang,
                tr: 'Ara', en: 'Search', de: 'Suchen', es: 'Buscar')),
          ),
        ],
      ),
    );
  }
}

/// Başlıktaki yuvarlak avatar: maskot.
///
/// Profil ekranıyla aynı bileşen kullanılıyor (kuşanılmış çerçeve orada
/// da burada da aynı görünsün diye). Rozet küçük boyutta kapalı.
class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
      ),
      child: const AvatarCercevesi(
        boyut: 46,
        rozetGoster: false,
        child: Mascot(size: 34, showShadow: false),
      ),
    );
  }
}

/// Seri (streak) ve jeton sayacı.
///
/// SAYILAR GERÇEK. Uydurma bir "7 🔥" koymak, ekranı şenlendirirdi ama
/// çocuğa kazanmadığı bir şeyi gösterirdi; ilerleme kaydı yüklenmemişse
/// (giriş yapılmamışsa) kapsül hiç çizilmiyor. Seri sıfırsa alev de
/// gösterilmiyor — "0 gün" bir başarı değil, bir uyarı gibi duruyor.
class _SayacKapsulu extends StatelessWidget {
  const _SayacKapsulu({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    final UserProgress? ilerleme =
        context.watch<AuthProvider>().userProgress;
    if (ilerleme == null) return const SizedBox.shrink();

    final seri = ilerleme.streakDays;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (seri > 0) ...[
            const Icon(Icons.local_fire_department_rounded,
                size: 17, color: Color(0xFFFFB300)),
            const SizedBox(width: 3),
            _sayi('$seri'),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 15,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 8),
          ],
          Image.asset('assets/images/ui/jeton.png',
              width: 17, height: 17, filterQuality: FilterQuality.medium),
          const SizedBox(width: 4),
          _sayi('${ilerleme.jetonBalance}'),
        ],
      ),
    );
  }

  Widget _sayi(String s) => Text(
        s,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
}

/// Yatay raflardan biri.
class _Bolum {
  const _Bolum({
    required this.tr,
    required this.en,
    required this.de,
    required this.es,
    required this.simge,
    required this.renk,
    required this.games,
  });

  final String tr;
  final String en;
  final String de;
  final String es;
  final IconData simge;
  final Color renk;
  final List<GameModel> games;

  String ad(String lang) => AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
}

/// Oyunları raflara ayırır.
///
/// Ayrım oyunun TÜRÜNE göre, katalogdaki `GameCategory` alanına göre
/// değil: kategori alanı yaş grubu ve platform karışımı taşıyor
/// (age4to6, arduino, software) ve çocuğa "hangi oyun bu" sorusunda
/// yardımcı olmuyor. Rafın adı çocuğun yapacağı şeyi söylüyor.
class _Bolumler {
  _Bolumler._();

  static const _robot = {
    GameType.robotSimulator,
    GameType.arduinoSimulator,
    GameType.leftRightCoding,
    GameType.mazeExplorer,
  };

  static const _bulmaca = {
    GameType.blockCoding,
    GameType.sequencing,
    GameType.patternDetective,
    GameType.variableMaster,
    GameType.bugHunter,
    GameType.pipesPuzzle,
    GameType.puzzle,
  };

  static List<_Bolum> ayir(List<GameModel> games) {
    // Her rafın içinde: önce kolay, sonra alfabetik. Çocuk rafa baktığında
    // ilk gördüğü kart en kolayı olsun.
    List<GameModel> sec(bool Function(GameModel) kosul) {
      final l = games.where(kosul).toList()
        ..sort((a, b) {
          if (a.difficulty != b.difficulty) {
            return a.difficulty.compareTo(b.difficulty);
          }
          return a.title.compareTo(b.title);
        });
      return l;
    }

    final raflar = <_Bolum>[
      _Bolum(
        tr: 'Robot Görevleri',
        en: 'Robot Missions',
        de: 'Roboter-Missionen',
        es: 'Misiones robot',
        simge: Icons.smart_toy_rounded,
        renk: const Color(0xFF2E7D32),
        games: sec((g) => _robot.contains(g.type)),
      ),
      _Bolum(
        tr: 'Kod Bulmacaları',
        en: 'Code Puzzles',
        de: 'Code-Rätsel',
        es: 'Puzles de código',
        simge: Icons.extension_rounded,
        renk: const Color(0xFF7C4DFF),
        games: sec((g) => _bulmaca.contains(g.type)),
      ),
      _Bolum(
        tr: 'Zeka ve Kelime',
        en: 'Brain & Words',
        de: 'Köpfchen & Wörter',
        es: 'Ingenio y palabras',
        simge: Icons.psychology_rounded,
        renk: const Color(0xFFF57C00),
        games: sec((g) =>
            !_robot.contains(g.type) && !_bulmaca.contains(g.type)),
      ),
    ];
    // Boş raf çizilmiyor: başlığı olup altı boş bir şerit, oyunun
    // silindiğini değil ekranın bozulduğunu düşündürüyor.
    return raflar.where((r) => r.games.isNotEmpty).toList();
  }
}

/// Oyunun görsel kimliği: simge, renk, ekran görüntüsü.
///
/// Bilerek stok fotoğraf kullanmıyoruz. Kartlarda daha önce stok
/// fotoğraflar vardı — matematik defterine tutulmuş bir kalem, sahnede
/// duran biri — ve hiçbiri oyunla ilgili değildi. Her oyunun kendi
/// simgesi ve rengi olunca hem tutarlı bir görsel dil çıkıyor hem de
/// okuma yazması zayıf bir çocuk oyunu simgesinden tanıyabiliyor.
class _OyunGorseli {
  _OyunGorseli._();

  /// Oyunun gerçek oynanış görüntüsü. Dosya yoksa renkli simgeye
  /// düşülüyor, böylece görüntüsü henüz alınmamış bir oyun kartı boş
  /// kalmıyor.
  static String shot(GameType type) => 'assets/images/games/${type.name}.png';

  static IconData simge(GameType type) => switch (type) {
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

  /// Aynı aileden oyunlar aynı rengi paylaşıyor: mavi = mantık/algoritma,
  /// mor = bloklar, turuncu = quiz, yeşil = robotik.
  static Color renk(GameType type) => switch (type) {
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

  /// Rengin koyu tonu: jöle kartın alt kenarı ve gölgesi.
  static Color koyu(Color c) =>
      Color.lerp(c, const Color(0xFF14102B), 0.34) ?? c;

  /// Zorluk 1–5, yıldız 3. Üç yıldız beş kademeden daha okunaklı:
  /// çocuk "4/5 zor" ile "5/5 zor" arasındaki farkı zaten yaşamıyor.
  static int yildiz(int difficulty) {
    if (difficulty <= 2) return 1;
    if (difficulty == 3) return 2;
    return 3;
  }
}

/// Üç yıldızlı zorluk göstergesi.
class _Yildizlar extends StatelessWidget {
  const _Yildizlar({required this.dolu, required this.renk, this.boyut = 15});

  final int dolu;
  final Color renk;
  final double boyut;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              i < dolu ? Icons.star_rounded : Icons.star_outline_rounded,
              size: boyut,
              color: i < dolu ? renk : renk.withValues(alpha: 0.32),
            ),
          ),
      ],
    );
  }
}

/// Günün görevi kartı: ekranın girişi.
class _GununGoreviKarti extends StatelessWidget {
  const _GununGoreviKarti({
    required this.game,
    required this.lang,
    required this.onTap,
  });

  final GameModel game;
  final String lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final renk = _OyunGorseli.renk(game.type);
    final koyu = _OyunGorseli.koyu(renk);
    return _JelBas(
      onTap: onTap,
      koyu: koyu,
      yaricap: 26,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [renk, Color.lerp(renk, Colors.white, 0.26) ?? renk],
          ),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLang.pick(lang,
                        tr: 'GÜNÜN GÖREVİ!',
                        en: "TODAY'S MISSION!",
                        de: 'MISSION DES TAGES!',
                        es: '¡MISIÓN DEL DÍA!'),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.titleFor(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                size: 19, color: koyu),
                            const SizedBox(width: 2),
                            Text(
                              AppLang.pick(lang,
                                  tr: 'Oyna',
                                  en: 'Play',
                                  de: 'Spielen',
                                  es: 'Jugar'),
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: koyu,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _Yildizlar(
                        dolu: _OyunGorseli.yildiz(game.difficulty),
                        renk: Colors.white,
                        boyut: 17,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Image.asset(
              'assets/images/ui/sandik.png',
              width: 86,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => Icon(Icons.card_giftcard_rounded,
                  size: 60, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bir oyun kartı — "jöle buton".
///
/// NEDEN GÖLGE DEĞİL DE KALIN ALT KENAR
/// ------------------------------------
/// Eski kart ince gri kenarlıklı düz bir `Card`'dı: bir liste satırı gibi
/// duruyor, basılabilir olduğunu söylemiyordu. Buradaki kart oyun
/// arayüzlerindeki fiziksel buton mantığını kullanıyor — altında kendi
/// renginin koyusuyla 6 piksellik bir "gövde" var (bulanıklık yok,
/// bilerek: bulanık gölge cam, keskin kenar plastik hissi veriyor).
/// Basınca kart o 6 pikselin üstüne oturuyor, yani gerçekten eziliyor.
class _JelKart extends StatelessWidget {
  const _JelKart({
    required this.game,
    required this.lang,
    required this.genislik,
    required this.isProLocked,
    required this.onTap,
    this.yatay = false,
  });

  final GameModel game;
  final String lang;
  final double genislik;
  final bool isProLocked;
  final bool yatay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final renk = _OyunGorseli.renk(game.type);
    final koyu = _OyunGorseli.koyu(renk);
    return _JelBas(
      onTap: onTap,
      koyu: koyu,
      yaricap: 22,
      child: Container(
        width: genislik,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: renk, width: 3),
        ),
        padding: const EdgeInsets.all(9),
        child: yatay ? _yatayIcerik(renk) : _dikeyIcerik(renk),
      ),
    );
  }

  Widget _gorsel(Color renk, {required double yukseklik}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: yukseklik,
            width: double.infinity,
            color: renk.withValues(alpha: 0.14),
            child: Image.asset(
              _OyunGorseli.shot(game.type),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(_OyunGorseli.simge(game.type),
                    color: renk, size: yukseklik * 0.42),
              ),
            ),
          ),
        ),
        if (isProLocked)
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B).withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(
                'assets/images/ui/tac.png',
                width: 18,
                height: 18,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => const Icon(Icons.lock_rounded,
                    size: 14, color: AppTheme.accentYellow),
              ),
            ),
          ),
      ],
    );
  }

  Widget _baslik(int satir) => Text(
        game.titleFor(lang),
        maxLines: satir,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF241C3B),
          height: 1.15,
        ),
      );

  Widget _dikeyIcerik(Color renk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _gorsel(renk, yukseklik: 96),
        const SizedBox(height: 9),
        SizedBox(height: 38, child: _baslik(2)),
        const SizedBox(height: 4),
        _Yildizlar(dolu: _OyunGorseli.yildiz(game.difficulty), renk: renk),
      ],
    );
  }

  Widget _yatayIcerik(Color renk) {
    return Row(
      children: [
        SizedBox(width: 92, child: _gorsel(renk, yukseklik: 66)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _baslik(2),
              const SizedBox(height: 6),
              _Yildizlar(
                  dolu: _OyunGorseli.yildiz(game.difficulty), renk: renk),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: renk.withValues(alpha: 0.7)),
      ],
    );
  }
}

/// Jöle buton davranışı: basınca aşağı iner, gövdesi kısalır.
///
/// `Listener` kullanıyoruz çünkü bir `GestureDetector` içerideki
/// dokunuşları yutabiliyordu. Cihazda "hareketi azalt" açıksa hareket
/// yok — ama gövde (alt kenar) duruyor, çünkü o bir süsleme değil,
/// kartın basılabilir olduğunu söyleyen şey.
class _JelBas extends StatefulWidget {
  const _JelBas({
    required this.child,
    required this.onTap,
    required this.koyu,
    required this.yaricap,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color koyu;
  final double yaricap;

  @override
  State<_JelBas> createState() => _JelBasState();
}

class _JelBasState extends State<_JelBas> {
  static const double _govde = 6;
  bool _basili = false;

  void _ayarla(bool v) {
    if (_basili != v && mounted) setState(() => _basili = v);
  }

  @override
  Widget build(BuildContext context) {
    final az = Motion.reduced(context);
    final inis = (_basili && !az) ? _govde - 2 : 0.0;
    return Listener(
      onPointerDown: (_) => _ayarla(true),
      onPointerUp: (_) => _ayarla(false),
      onPointerCancel: (_) => _ayarla(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.only(bottom: _govde),
          child: AnimatedContainer(
            duration: _basili ? Motion.short4 : Motion.medium2,
            curve: Motion.emphasized,
            transform: Matrix4.translationValues(0, inis, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.yaricap),
              boxShadow: [
                BoxShadow(
                  color: widget.koyu,
                  offset: Offset(0, _govde - inis),
                  blurRadius: 0,
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
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
