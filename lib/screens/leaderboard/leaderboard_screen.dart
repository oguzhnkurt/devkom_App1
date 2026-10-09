import 'package:flutter/material.dart';

import '../../models/chess_game_model.dart';
import '../../models/game_model.dart';
import '../../services/siralama_servisi.dart';
import '../../utils/lang.dart';
import '../../widgets/avatar_cercevesi.dart';
import '../../widgets/mascot.dart';

/// Yarışma tablosu — iki kulvar (Ekim 2026).
///
/// 1. **Genel**: toplam XP. Her satırda çocuğun marketten alıp taktığı
///    çerçeve, rozet ve etiket görünüyor; jetonu harcamanın bir anlamı
///    da bu: herkes görüyor.
/// 2. **Satranç**: en zor seviyeyi en hızlı yenen üstte. Önce
///    İmkânsız'ı yenenler süreye göre, sonra Zor, sonra Orta, Kolay.
///
/// Eskiden oyun oyun skor listesiydi (quiz, koordinat...); çoğu boştu ve
/// hiçbiri çocuğun "ben kaçıncıyım" sorusuna cevap vermiyordu. Veri iki
/// SECURITY DEFINER fonksiyondan geliyor (`37_siralama.sql`); dışarı
/// yalnızca ilk ad + soyadın baş harfi çıkıyor.
///
/// Çocuk ilk 50'de değilse kendi satırı listenin altında ayrıca
/// gösteriliyor: "senin yerin".
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, this.initialGameType});

  /// Satranç ekranından açılırsa satranç sekmesiyle başlıyor. Başka
  /// oyunlar artık ayrı tablo tutmuyor; genel sekmeye düşüyor.
  final GameType? initialGameType;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String get _lang => Localizations.localeOf(context).languageCode;
  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  @override
  Widget build(BuildContext context) {
    final ilk = widget.initialGameType == GameType.chess ? 1 : 0;
    return DefaultTabController(
      length: 2,
      initialIndex: ilk,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F3FF),
        appBar: AppBar(
          title: Text(_t('Yarışma tablosu', 'Leaderboard', 'Bestenliste',
              'Clasificación')),
          backgroundColor: const Color(0xFF6C3CE0),
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: const Color(0xFFFFC94D),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800),
            tabs: [
              Tab(
                  key: const ValueKey('siralama_sekme_genel'),
                  text: _t('⭐ Genel', '⭐ Overall', '⭐ Gesamt', '⭐ General')),
              Tab(
                  key: const ValueKey('siralama_sekme_satranc'),
                  text: _t('♞ Satranç', '♞ Chess', '♞ Schach', '♞ Ajedrez')),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _Kulvar(kulvar: SiralamaKulvari.genel),
            _Kulvar(kulvar: SiralamaKulvari.satranc),
          ],
        ),
      ),
    );
  }
}

class _Kulvar extends StatefulWidget {
  const _Kulvar({required this.kulvar});
  final SiralamaKulvari kulvar;

  @override
  State<_Kulvar> createState() => _KulvarState();
}

class _KulvarState extends State<_Kulvar>
    with AutomaticKeepAliveClientMixin {
  late Future<List<SiralamaSatiri>> _gelecek;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _gelecek = SiralamaServisi.getir(widget.kulvar);
  }

  Future<void> _yenile() async {
    final f = SiralamaServisi.getir(widget.kulvar);
    setState(() => _gelecek = f);
    await f.catchError((_) => <SiralamaSatiri>[]);
  }

  String get _lang => Localizations.localeOf(context).languageCode;
  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  bool get _satranc => widget.kulvar == SiralamaKulvari.satranc;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<SiralamaSatiri>>(
      future: _gelecek,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _Bos(
            emoji: '📡',
            yazi: _t('Sıralama şu an yüklenemedi. Aşağı çekip yenile.',
                "Couldn't load the ranking. Pull down to retry.",
                'Rangliste konnte nicht geladen werden. Zum Neuladen ziehen.',
                'No se pudo cargar. Desliza hacia abajo para reintentar.'),
            onYenile: _yenile,
          );
        }
        final liste = snap.data ?? const <SiralamaSatiri>[];
        if (liste.isEmpty) {
          return _Bos(
            emoji: _satranc ? '♞' : '⭐',
            yazi: _satranc
                ? _t('Henüz kimse satrançta kazanmadı. İlk sen ol!',
                    'Nobody has won at chess yet. Be the first!',
                    'Noch hat niemand im Schach gewonnen. Sei der Erste!',
                    'Nadie ha ganado al ajedrez todavía. ¡Sé el primero!')
                : _t('Sıralama ders bitirdikçe dolacak.',
                    'The ranking fills up as lessons are finished.',
                    'Die Rangliste füllt sich mit jeder Lektion.',
                    'El ranking se llena al terminar lecciones.'),
            onYenile: _yenile,
          );
        }

        final ben = SiralamaServisi.benimSatirim(liste);
        final ust = liste.where((s) => !(s.ben && s.sira > SiralamaServisi.varsayilanLimit)).toList();
        final altta = ben != null && ben.sira > SiralamaServisi.varsayilanLimit;

        return RefreshIndicator(
          onRefresh: _yenile,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
            children: [
              _aciklama(),
              const SizedBox(height: 12),
              if (ben != null) ...[
                _BenimYerim(satir: ben, satranc: _satranc, lang: _lang),
                const SizedBox(height: 14),
              ],
              for (final s in ust) _Satir(satir: s, satranc: _satranc, lang: _lang),
              if (altta) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                      child: Text('⋯', style: TextStyle(fontSize: 20, color: Colors.black38))),
                ),
                _Satir(satir: ben, satranc: _satranc, lang: _lang),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _aciklama() {
    final yazi = _satranc
        ? _t('İmkânsız\'ı en hızlı yenen en üstte. Kimse yenemediyse Zor\'u en hızlı yenen.',
            'Fastest to beat Impossible is on top, then the fastest Hard wins.',
            'Wer „Unmöglich“ am schnellsten schlägt, steht oben, danach „Schwer“.',
            'Arriba quien gana más rápido en Imposible; luego, en Difícil.')
        : _t('Ders ve oyunlarla kazandığın XP\'ye göre. Markette aldığın çerçeve, rozet ve etiketler burada görünür.',
            'Ranked by the XP you earn in lessons and games. Frames, badges and labels from the Store show here.',
            'Nach XP aus Lektionen und Spielen. Rahmen, Abzeichen und Etiketten aus dem Laden siehst du hier.',
            'Según el XP de lecciones y juegos. Aquí se ven los marcos, insignias y etiquetas de la Tienda.');
    return Text(yazi,
        style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B6785), height: 1.35));
  }
}

/// Bir sıralama satırının değer metni ("1.250 XP" / "İmkânsız · 4:07").
String _deger(SiralamaSatiri s, bool satranc, String lang) {
  if (satranc) {
    final z = s.zorluk ?? 0;
    final ad = (z >= 0 && z < ChessDifficulty.values.length)
        ? ChessDifficulty.values[z].displayNameFor(lang)
        : '?';
    return '$ad · ${SiralamaServisi.sureYazisi(s.sure ?? 0)}';
  }
  final xp = s.xp ?? 0;
  final yazi = xp >= 1000
      ? '${xp ~/ 1000}.${(xp % 1000).toString().padLeft(3, '0')}'
      : '$xp';
  return '$yazi XP';
}

Color _zorlukRengi(int? z) {
  switch (z) {
    case 3:
      return const Color(0xFFD32F2F);
    case 2:
      return const Color(0xFFF57C00);
    case 1:
      return const Color(0xFF1E88E5);
    default:
      return const Color(0xFF43A047);
  }
}

class _Satir extends StatelessWidget {
  const _Satir({required this.satir, required this.satranc, required this.lang});
  final SiralamaSatiri satir;
  final bool satranc;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final s = satir;
    final madalya = switch (s.sira) { 1 => '🥇', 2 => '🥈', 3 => '🥉', _ => null };
    return Container(
      key: ValueKey('siralama_satir_${s.sira}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.fromLTRB(10, 10, 14, s.etiket != null ? 16 : 10),
      decoration: BoxDecoration(
        color: s.ben ? const Color(0xFFFFF6D8) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: s.ben ? const Color(0xFFFFC94D) : const Color(0xFFECE8FF),
            width: s.ben ? 2 : 1),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6C3CE0).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Center(
              child: madalya != null
                  ? Text(madalya, style: const TextStyle(fontSize: 24))
                  : Text('${s.sira}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFF6B6785))),
            ),
          ),
          // Etiket kurdelesi avatarin altina, ondan genis asiliyor; yanina
          // yer birakilmazsa ismin uzerine biniyordu.
          SizedBox(
            width: 84,
            child: Center(
              child: AvatarCercevesi(
                boyut: 50,
                cerceve: s.cerceve,
                rozet: s.rozet,
                etiket: s.etiket,
                child: const Mascot(size: 34, showShadow: false),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.ben
                      ? '${s.ad} · ${AppLang.pick(lang, tr: 'sen', en: 'you', de: 'du', es: 'tú')}'
                      : s.ad,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF1F1D36)),
                ),
                if (!satranc && s.seviye != null)
                  Text(
                    AppLang.pick(lang,
                        tr: 'Seviye ${s.seviye}',
                        en: 'Level ${s.seviye}',
                        de: 'Stufe ${s.seviye}',
                        es: 'Nivel ${s.seviye}'),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8A86A3)),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (satranc ? _zorlukRengi(s.zorluk) : const Color(0xFF6C3CE0))
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _deger(s, satranc, lang),
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: satranc ? _zorlukRengi(s.zorluk) : const Color(0xFF6C3CE0)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenimYerim extends StatelessWidget {
  const _BenimYerim({required this.satir, required this.satranc, required this.lang});
  final SiralamaSatiri satir;
  final bool satranc;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('siralama_benim_yerim'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF6C3CE0), Color(0xFF8E5CF7)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('🏁', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLang.pick(lang,
                  tr: 'Senin yerin: ${satir.sira}.',
                  en: 'Your place: #${satir.sira}',
                  de: 'Dein Platz: ${satir.sira}.',
                  es: 'Tu puesto: ${satir.sira}.º'),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          Text(_deger(satir, satranc, lang),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Bos extends StatelessWidget {
  const _Bos({required this.emoji, required this.yazi, required this.onYenile});
  final String emoji;
  final String yazi;
  final Future<void> Function() onYenile;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onYenile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 90, 32, 32),
        children: [
          Center(child: Text(emoji, style: const TextStyle(fontSize: 54))),
          const SizedBox(height: 14),
          Text(yazi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF6B6785), height: 1.4)),
        ],
      ),
    );
  }
}
