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
import '../widgets/oyun_bilgi_sayfasi.dart';
import '../widgets/oyun_kimligi.dart';
import '../widgets/oyun_sahnesi.dart';
import '../models/learner_profile.dart';
import '../services/next_lesson_service.dart';
import '../services/user_progress_service.dart';
import '../widgets/playful_background.dart';
import 'game_play_screen.dart';

/// Oyunlar ekranı.
///
/// DUZEN (Ekim 2026)
/// -----------------
/// Ustte kategori filtreleri (Algoritma, Mantik, Veri, Robotik, Kelime —
/// cocugun ne ogrendigine gore), altinda "Senin icin" karti (okudugu
/// kursa uyan oyun, Gunun Gorevi olarak) ve kolaydan zora iki sutunlu
/// tum oyunlar.
///
/// Onceki iki surum ve neden birakildi:
///  * 2 sutunlu GridView, her kartta aciklama ve "8 dk": tablo gibi
///    duruyordu, aciklamalari kimse okumuyordu.
///  * Konu konu yatay raflar: ucuncu kart yarim kaliyor, rafin
///    sonundaki oyunlar kesfedilmiyordu; raf adlari keyfiydi.
///
/// KARTLAR
/// -------
/// Kartta oyunun canli kapagi (`OyunSahnesi`: oyunun ana hareketi kodla
/// ciziliyor ve donguyle oynuyor), adi ve zorlugu (Kolay/Orta/Zor). Yildiz
/// ve tac yok: cocuk yildizi kazandigi yildiz sandi, taci anlamadi. Pro
/// oyuna dokununca oyunun kapagiyla acilan bilgi sayfasi (`OyunBilgiSayfasi`)
/// "kisa bir video izle, bir tur ucretsiz oyna" secenegini anlatiyor.
class RoboticsGamesScreen extends StatefulWidget {
  const RoboticsGamesScreen({super.key});

  @override
  State<RoboticsGamesScreen> createState() => _RoboticsGamesScreenState();
}

class _RoboticsGamesScreenState extends State<RoboticsGamesScreen> {
  final GamesService _gamesService = GamesService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// Secili kategori filtresi; null = Tumu.
  _Kategori? _kategori;

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
    games.sort(_kolaydanZora);
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 28),
      children: [_izgara(games)],
    );
  }

  /// Kolaydan zora; esitse ucretsiz oyun once, sonra ada gore.
  static int _kolaydanZora(GameModel a, GameModel b) {
    if (a.difficulty != b.difficulty) return a.difficulty.compareTo(b.difficulty);
    final pa = ProGames.isProGame(a.type) ? 1 : 0;
    final pb = ProGames.isProGame(b.type) ? 1 : 0;
    if (pa != pb) return pa.compareTo(pb);
    return a.title.compareTo(b.title);
  }

  /// Ekranin govdesi: kategori filtreleri, "Senin icin" karti ve
  /// kolaydan zora tum oyunlar.
  ///
  /// NEDEN BOYLE (Ekim 2026)
  /// -----------------------
  /// Yatay raflarda ucuncu kart yarim kaliyor, rafin sonundaki oyunlar
  /// kesfedilmiyordu; raf adlari da ("Robot Gorevleri", "Zeka ve Kelime")
  /// keyfiydi — Arduino iki rafta birden geciyordu. Simdi oyunlar cocugun
  /// NE OGRENDIGINE gore gruplu ve ustte dokunulan filtrelerde; liste tek,
  /// iki sutun, kolaydan zora.
  Widget _raflar(List<GameModel> games) {
    final kategoriler = _Kategoriler.hepsi;
    final secili = _kategori == null
        ? (List<GameModel>.from(games)..sort(_kolaydanZora))
        : (games.where((g) => _kategori!.turler.contains(g.type)).toList()
          ..sort(_kolaydanZora));
    final oneri = _seninIcin(games);

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        const SizedBox(height: 14),
        // Filtre cipleri (yana kayan tek satir).
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _cip(null, AppLang.pick(_lang, tr: 'Tümü', en: 'All', de: 'Alle', es: 'Todos'), null),
              for (final k in kategoriler) _cip(k, k.ad(_lang), k.simge),
            ],
          ),
        ),
        if (oneri != null && _kategori == null) ...[
          _bolumBasligi(
            AppLang.pick(_lang, tr: 'Senin için', en: 'For you', de: 'Für dich', es: 'Para ti'),
            oneri.kursAdi == null
                ? null
                : AppLang.pick(_lang,
                    tr: '${oneri.kursAdi} kursuna uygun',
                    en: 'Fits your ${oneri.kursAdi} course',
                    de: 'Passt zu deinem ${oneri.kursAdi}-Kurs',
                    es: 'Para tu curso de ${oneri.kursAdi}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppearIn(
              child: _GununGoreviKarti(
                game: oneri.game,
                lang: _lang,
                onTap: () => _openGame(oneri.game, ProGames.isProGame(oneri.game.type)),
              ),
            ),
          ),
        ],
        _bolumBasligi(
          _kategori == null
              ? AppLang.pick(_lang, tr: 'Tüm oyunlar', en: 'All games', de: 'Alle Spiele', es: 'Todos los juegos')
              : _kategori!.ad(_lang),
          AppLang.pick(_lang, tr: 'Kolaydan zora', en: 'Easy to hard', de: 'Leicht bis schwer', es: 'De fácil a difícil'),
        ),
        _izgara(secili),
      ],
    );
  }

  /// Iki sutunlu oyun izgarasi (Wrap: kartlar kendi yuksekliginde).
  Widget _izgara(List<GameModel> games) {
    return LayoutBuilder(builder: (context, c) {
      const ara = 12.0;
      final gen = (c.maxWidth - 32 - ara) / 2;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: ara,
          runSpacing: ara + 4,
          children: [
            for (var i = 0; i < games.length; i++)
              AppearIn(
                delay: AppearIn.stagger(i),
                child: _oyunKarti(games[i], genislik: gen),
              ),
          ],
        ),
      );
    });
  }

  Widget _cip(_Kategori? k, String ad, IconData? simge) {
    final secili = _kategori == k;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _kategori = k),
        child: AnimatedContainer(
          duration: Motion.short4,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: secili ? const Color(0xFF241C3B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (simge != null) ...[
                Icon(simge, size: 17, color: secili ? Colors.white : k!.renk),
                const SizedBox(width: 5),
              ],
              Text(
                ad,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: secili ? Colors.white : const Color(0xFF241C3B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bolumBasligi(String ad, String? sag) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              ad,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF241C3B),
              ),
            ),
          ),
          if (sag != null)
            Text(
              sag,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7C4DFF),
              ),
            ),
        ],
      ),
    );
  }

  Widget _oyunKarti(GameModel game, {required double genislik}) {
    // Pro etiketi yalnizca kilit gercekten gecerliyse: Pro uyeye her
    // kartta "reklamla" yazmak satin aldigi seyi kilitli hissettiriyor.
    final needsPro = ProGames.isProGame(game.type);
    final locked = needsPro && !ProGate.watchIsPro(context);
    return _OyunKarti(
      game: game,
      lang: _lang,
      genislik: genislik,
      isProLocked: locked,
      onTap: () => _openGame(game, needsPro),
    );
  }

  /// "Senin icin": cocugun su an okudugu kursa uyan oyunlardan biri.
  ///
  /// Her gun baska bir oyun, ama ayni gun herkeste ayni (yilin gunune
  /// gore). Ucretsiz oyunlar once: cocugu gunun ilk onerisinde bir
  /// kilide davet etmek gorevden cok reklam olurdu. Kursa uygun ucretsiz
  /// oyun yoksa kursa uygun herhangi biri.
  ({GameModel game, String? kursAdi})? _seninIcin(List<GameModel> games) {
    String? kursId;
    String? kursAdi;
    try {
      final auth = context.read<AuthProvider>();
      final ilerleme = auth.userProgress ?? UserProgressService().getVisitorProgress();
      final profil = auth.currentUser?.learnerProfile ?? const LearnerProfile();
      final adim = NextLessonService.resolve(profil, ilerleme.completedLessonIds.toSet());
      kursId = adim?.course.id;
      kursAdi = adim?.course.nameFor(_lang);
    } catch (_) {
      // Ilerleme okunamazsa kursa ozel oneri yok; genel oneri yeter.
    }
    final uygun = _Kategoriler.kursaUygun[kursId] ?? const <GameType>[];
    List<GameModel> aday = games.where((g) => uygun.contains(g.type)).toList();
    final acik = aday.where((g) => !ProGames.isProGame(g.type)).toList();
    if (acik.isNotEmpty) aday = acik;
    if (aday.isEmpty) {
      aday = games.where((g) => !ProGames.isProGame(g.type)).toList();
      kursAdi = null;
    }
    if (aday.isEmpty) return null;
    aday.sort((a, b) => a.id.compareTo(b.id));
    final bugun = DateTime.now();
    final gun = bugun.difference(DateTime(bugun.year)).inDays;
    return (game: aday[gun % aday.length], kursAdi: kursAdi);
  }

  Future<void> _openGame(GameModel game, bool needsPro) async {
    if (needsPro) {
      // Kilitli oyunda iki yol var: Pro almak ya da bir reklam izleyip
      // TEK TUR oynamak. Tek tur bilerek: cocuk oyunu gercekten gorsun
      // diye, ama oyun reklamla sinirsiz acilmasin diye.
      final sonuc = await ProGate.ensureOrAd(
        context,
        featureName: game.title,
        reklamEtiketi: (lang) => AppLang.pick(
          lang,
          tr: 'Reklam izle, bir tur oyna',
          en: 'Watch an ad, play one round',
          de: 'Werbung ansehen, eine Runde spielen',
          es: 'Ver un anuncio y jugar una ronda',
        ),
        // Oyunun kendi kapagiyla acilan bilgi sayfasi.
        sayfa: (_, reklamVar) => OyunBilgiSayfasi(
          game: game,
          lang: _lang,
          reklamVar: reklamVar,
          kategori: _Kategoriler.oyununKategorisi(game.type)?.ad(_lang) ?? '',
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

/// Bir kategori: cocugun ne ogrendigi.
class _Kategori {
  const _Kategori({
    required this.tr,
    required this.en,
    required this.de,
    required this.es,
    required this.simge,
    required this.renk,
    required this.turler,
  });

  final String tr;
  final String en;
  final String de;
  final String es;
  final IconData simge;
  final Color renk;
  final Set<GameType> turler;

  String ad(String lang) => AppLang.pick(lang, tr: tr, en: en, de: de, es: es);
}

/// Oyunlarin kategorileri ve kurslarla eslesmesi.
///
/// Ayrim oyunun TURUNE gore, katalogdaki `GameCategory` alanina gore
/// degil: o alan yas grubu ve platform karisimi tasiyor.
class _Kategoriler {
  _Kategoriler._();

  static const hepsi = <_Kategori>[
    _Kategori(
      tr: 'Algoritma', en: 'Algorithms', de: 'Algorithmen', es: 'Algoritmos',
      simge: Icons.extension_rounded,
      renk: Color(0xFFFF8C1A),
      turler: {GameType.sequencing, GameType.blockCoding, GameType.mazeExplorer},
    ),
    _Kategori(
      tr: 'Mantık', en: 'Logic', de: 'Logik', es: 'Lógica',
      simge: Icons.search_rounded,
      renk: Color(0xFFD81B60),
      turler: {GameType.bugHunter, GameType.patternDetective, GameType.pipesPuzzle, GameType.chess},
    ),
    _Kategori(
      tr: 'Veri', en: 'Data', de: 'Daten', es: 'Datos',
      simge: Icons.inventory_2_rounded,
      renk: Color(0xFF3949AB),
      turler: {GameType.variableMaster, GameType.coordinates, GameType.colorCoding},
    ),
    _Kategori(
      tr: 'Robotik', en: 'Robotics', de: 'Robotik', es: 'Robótica',
      simge: Icons.smart_toy_rounded,
      renk: Color(0xFF00897B),
      turler: {GameType.arduinoSimulator, GameType.robotSimulator, GameType.matchingGame},
    ),
    _Kategori(
      tr: 'Kelime', en: 'Words', de: 'Wörter', es: 'Palabras',
      simge: Icons.abc_rounded,
      renk: Color(0xFFF57C00),
      turler: {GameType.wordMatch, GameType.quiz},
    ),
  ];

  static _Kategori? oyununKategorisi(GameType t) {
    for (final k in hepsi) {
      if (k.turler.contains(t)) return k;
    }
    return null;
  }

  /// Kursa gore "Senin icin" adaylari (oncelik sirasiyla).
  static const kursaUygun = <String, List<GameType>>{
    'scratch': [GameType.sequencing, GameType.blockCoding, GameType.coordinates, GameType.colorCoding],
    'mblock': [GameType.blockCoding, GameType.sequencing, GameType.robotSimulator, GameType.arduinoSimulator],
    'arduino': [GameType.arduinoSimulator, GameType.matchingGame, GameType.blockCoding],
    'arduino_ide': [GameType.matchingGame, GameType.arduinoSimulator],
    'html': [GameType.wordMatch, GameType.quiz],
    'css': [GameType.wordMatch, GameType.colorCoding],
    'python': [GameType.bugHunter, GameType.variableMaster, GameType.patternDetective, GameType.quiz],
    'java': [GameType.bugHunter, GameType.variableMaster, GameType.wordMatch],
    'csharp': [GameType.bugHunter, GameType.variableMaster, GameType.wordMatch],
  };
}

/// Oyunun gorsel kimligi: simge, renk.
class _OyunGorseli {
  _OyunGorseli._();

  static Color renk(GameType type) => OyunKimligi.renk(type);

  /// Rengin koyu tonu: jole kartin alt kenari ve golgesi.
  static Color koyu(Color c) =>
      Color.lerp(c, const Color(0xFF14102B), 0.34) ?? c;
}

/// "Senin icin" / Gunun Gorevi karti: solda davet, sagda oyunun canli
/// kapagi.
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
        height: 168,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: renk,
        ),
        child: Stack(
          children: [
            // Kapak sag yarida; sola dogru oyunun rengine eriyor.
            // Sahnenin kendi en-boy orani (5:3) korunuyor; sol kismi
            // renge eriyen gecisin altinda kaliyor.
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 168 * 5 / 3,
              child: OyunSahnesi(tur: game.type, lang: lang),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [renk, renk, renk.withValues(alpha: 0)],
                    stops: const [0, 0.42, 0.68],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 150, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLang.pick(lang,
                        tr: 'GÜNÜN GÖREVİ!',
                        en: "TODAY'S MISSION!",
                        de: 'MISSION DES TAGES!',
                        es: '¡MISIÓN DEL DÍA!'),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    game.titleFor(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    oyunDaveti(game.type, lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.25,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 19, color: koyu),
                        const SizedBox(width: 2),
                        Text(
                          AppLang.pick(lang, tr: 'Oyna', en: 'Play', de: 'Spielen', es: 'Jugar'),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Oyun karti: ustte oyunun canli kapagi, altta adi ve zorlugu.
///
/// Yildiz yok (cocuk yildizi "kazandigim" diye okuyordu), tac yok (ne
/// demek oldugu anlasilmiyordu). Pro oyunda kapagin kosesinde kucuk bir
/// "Reklamla" etiketi; dokununca bilgi sayfasi her seyi anlatiyor.
class _OyunKarti extends StatelessWidget {
  const _OyunKarti({
    required this.game,
    required this.lang,
    required this.genislik,
    required this.isProLocked,
    required this.onTap,
  });

  final GameModel game;
  final String lang;
  final double genislik;
  final bool isProLocked;
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: genislik * 0.62,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  OyunSahnesi(tur: game.type, lang: lang),
                  if (isProLocked)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 2, 8, 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                            Text(
                              AppLang.pick(lang,
                                  tr: 'Reklamla', en: 'With ad', de: 'Mit Werbung', es: 'Con anuncio'),
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 10, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        game.titleFor(lang),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF241C3B),
                          height: 1.15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: renk.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      zorlukEtiketi(game.difficulty, lang),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: koyu,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
