import 'package:flutter/material.dart';
import '../../models/video_series_model.dart';
import '../../services/video_series_service.dart';
import 'video_series_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/lang.dart';

/// Video Dersler — seri listesi.
///
/// Drawer'daki "Video Dersler" girişinden açılır. İçerik Supabase'den
/// (video_series / video_episodes) geliyor, yani yeni seri eklemek için
/// uygulama güncellemesi gerekmiyor.
class VideoSeriesScreen extends StatefulWidget {
  const VideoSeriesScreen({super.key});

  @override
  State<VideoSeriesScreen> createState() => _VideoSeriesScreenState();
}

class _VideoSeriesScreenState extends State<VideoSeriesScreen> {
  final VideoSeriesService _service = VideoSeriesService();

  bool _isLoading = true;

  /// Cocugun kendi dilinde anlatilan seriler.
  List<VideoSeries> _kendiDilinde = [];

  /// Baska bir dilde anlatilan seriler. Listede gizlenmiyor ama ana
  /// listeye de karismiyor: altta kendi basligi altinda duruyor.
  List<VideoSeries> _baskaDilde = [];

  Set<String> _completedEpisodeIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final series = await _service.getSeries();
    final completed = await _service.getCompletedEpisodeIds();
    if (!mounted) return;
    // Onceki surumde tek liste vardi ve yalnizca siralaniyordu. Katalogda
    // 15 seri var (6 tr, 4 de, 4 es, 1 en); Ingilizce secen cocuk kendi
    // dilindeki tek serinin hemen altinda 14 yabanci seri goruyordu.
    // Artik iki ayri gruba boluyoruz; her grup kendi icinde katalog
    // sirasini koruyor.
    final lang = _lang;
    final kendi = <VideoSeries>[];
    final diger = <VideoSeries>[];
    for (final s in series) {
      (s.audioLang == lang ? kendi : diger).add(s);
    }
    int sirala(VideoSeries a, VideoSeries b) =>
        a.sortOrder.compareTo(b.sortOrder);
    kendi.sort(sirala);
    diger.sort(sirala);

    setState(() {
      _kendiDilinde = kendi;
      _baskaDilde = diger;
      _completedEpisodeIds = completed;
      _isLoading = false;
    });
  }

  /// Arayuz dili. Video ekranlari bugune kadar tamamen Turkce sabitti;
  /// uygulamanin dili Ingilizce olsa bile buradaki her metin Turkce
  /// geliyordu.
  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  int _completedCount(VideoSeries series) =>
      series.episodes.where((e) => _completedEpisodeIds.contains(e.id)).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_t('Video Dersler', 'Video Lessons', 'Videokurse',
            'Lecciones en vídeo')),
        backgroundColor: const Color(0xFF6C3CE0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: (_kendiDilinde.isEmpty && _baskaDilde.isEmpty)
                  ? _buildEmpty()
                  : _buildList(),
            ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        const Center(child: Text('🎬', style: TextStyle(fontSize: 48))),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _t('Henüz video serisi eklenmemiş.', 'No video series yet.',
                'Noch keine Videoreihen vorhanden.',
                'Todavía no hay series de vídeo.'),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            _t('Yakında burada olacaklar!', 'They will show up here soon!',
                'Sie erscheinen bald hier!', '¡Aparecerán aquí muy pronto!'),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    final ogeler = <Widget>[_buildCurationNote()];

    for (final seri in _kendiDilinde) {
      ogeler.add(_buildSeriesCard(seri));
    }

    if (_baskaDilde.isNotEmpty) {
      ogeler.add(_buildOtherLangHeader());
      for (final seri in _baskaDilde) {
        ogeler.add(_buildSeriesCard(seri));
      }
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      itemCount: ogeler.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => ogeler[index],
    );
  }

  /// "Baska dilde anlatiliyor" bolum basligi.
  ///
  /// Kendi dilinde hic seri yoksa (su an almanca ve ispanyolca boyle)
  /// once bunu soyluyoruz, yoksa ekran sebepsiz yere yabanci gorunuyor.
  Widget _buildOtherLangHeader() {
    final bosMu = _kendiDilinde.isEmpty;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bosMu) ...[
            Text(
              _t('Senin dilinde henüz video serisi yok.',
                  'No video series in your language yet.',
                  'Noch keine Videoreihe in deiner Sprache.',
                  'Todavía no hay series de vídeo en tu idioma.'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Icon(Icons.translate_rounded, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _t('Başka dilde anlatılıyor', 'Narrated in another language',
                      'In einer anderen Sprache erzählt',
                      'Narradas en otro idioma'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _t('Anlatım dili senin seçtiğin dil değil; yine de izleyebilirsin.',
                'The narration is not in the language you picked, but you can '
                    'still watch.',
                'Die Erzählung ist nicht in deiner gewählten Sprache, du '
                    'kannst sie trotzdem ansehen.',
                'La narración no está en el idioma que elegiste, pero puedes '
                    'verlas igualmente.'),
            style: TextStyle(fontSize: 12, height: 1.35, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Bu bölümdeki videoların üçüncü taraf kanallara ait olduğunu,
  /// bizim yalnızca seçki yaptığımızı açıkça belirtir.
  Widget _buildCurationNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF6C3CE0).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF6C3CE0)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _t(
                  'Buradaki videolar YouTube\'daki eğitmenlere ait. Biz senin için '
                      'sıralayıp derledik; her bölümde kanal adını ve orijinal videoya '
                      'giden bağlantıyı bulabilirsin.',
                  'These videos belong to their creators on YouTube. We only '
                      'curated and ordered them; every episode shows the channel '
                      'name and a link to the original video.',
                  'Diese Videos gehören ihren Urheberinnen und Urhebern auf YouTube. '
                      'Wir haben sie nur ausgewählt und sortiert; jede Folge nennt den '
                      'Kanal und verlinkt das Originalvideo.',
                  'Estos vídeos pertenecen a sus autores en YouTube. Nosotros solo los '
                      'hemos seleccionado y ordenado; cada episodio muestra el canal y '
                      'enlaza al vídeo original.'),
              style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesCard(VideoSeries series) {
    final total = series.episodes.length;
    final done = _completedCount(series);
    final progress = total == 0 ? 0.0 : done / total;
    final color = series.color;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoSeriesDetailScreen(series: series),
          ),
        );
        _load();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(series.coverEmoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                series.titleFor(_lang),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1F1D36),
                                ),
                              ),
                            ),
                            if (series.needsLangBadge(_lang)) ...[
                              _langChip(series.audioLang),
                              const SizedBox(width: 6),
                            ],
                            _levelChip(series.level),
                          ],
                        ),
                        if (series.descriptionFor(_lang) != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            series.descriptionFor(_lang)!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.3),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    total == 0
                        ? _t('Yakında', 'Coming soon', 'Demnächst', 'Muy pronto')
                        : _t('$done / $total bölüm', '$done / $total episodes',
                            '$done / $total Folgen', '$done / $total episodios'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
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

  /// Anlatim dili rozeti. Ingilizce arayuzde Turkce anlatimli bir seriye
  /// tiklayip videonun Turkce oldugunu gormek kotu bir surpriz; rozet bunu
  /// karttan once soyluyor.
  Widget _langChip(String audioLang) {
    // Almanca ve ispanyolca seriler eklenince 'en' disindaki her sey
    // "TR" rozeti aliyordu; Alman bir cocuk kendi dilindeki seriyi
    // "TR" diye goruyordu.
    final label = audioLang.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF6C3CE0).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: Color(0xFF6C3CE0),
        ),
      ),
    );
  }

  Widget _levelChip(VideoLevel level) {
    final color = videoLevelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        videoLevelLabel(level, _lang),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
