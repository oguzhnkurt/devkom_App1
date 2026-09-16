import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/video_series_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/video_series_service.dart';
import '../../widgets/youtube_player_widget.dart';
import '../../utils/lang.dart';

/// Bir video serisinin bölüm listesi ve oynatıcısı.
///
/// Seçili bölüm üstte oynatılır, altında bölüm listesi durur. Bölümü
/// "İzledim" ile işaretleyince XP ve jeton kazanılır (ilk seferde).
class VideoSeriesDetailScreen extends StatefulWidget {
  final VideoSeries series;

  const VideoSeriesDetailScreen({super.key, required this.series});

  @override
  State<VideoSeriesDetailScreen> createState() => _VideoSeriesDetailScreenState();
}

class _VideoSeriesDetailScreenState extends State<VideoSeriesDetailScreen> {
  final VideoSeriesService _service = VideoSeriesService();

  /// Arayuz dili; baslik ve aciklamalar buna gore seciliyor.
  String get _lang =>
      Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  /// Bu ekrandaki kisa arayuz yazilari icin dort dilli yardimci.
  String _t(String tr, String en, String de, String es) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  VideoEpisode? _selected;
  Set<String> _completedIds = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.series.episodes.isNotEmpty) {
      _selected = widget.series.episodes.first;
    }
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final ids = await _service.getCompletedEpisodeIds();
    if (!mounted) return;
    setState(() => _completedIds = ids);
  }

  /// Video sonuna gelince: bolumu tamamlanmis say ve siradakine gec.
  ///
  /// Kullaniciyi "Izledim"e basmaya zorlamiyoruz — sonuna kadar izlediyse
  /// odulu zaten hak etmis demektir.
  Future<void> _onVideoEnded() async {
    final current = _selected;
    if (current == null) return;

    if (!_completedIds.contains(current.id)) {
      await _markWatched(current);
      return; // _markWatched zaten siradakine geciyor
    }
    _goToNext(current);
  }

  /// Siradaki bolume gecer; son bolumdeyse oldugu yerde kalir.
  void _goToNext(VideoEpisode episode) {
    final index = widget.series.episodes.indexOf(episode);
    if (index >= 0 && index + 1 < widget.series.episodes.length) {
      setState(() => _selected = widget.series.episodes[index + 1]);
    }
  }

  Future<void> _markWatched(VideoEpisode episode) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final rewarded = await _service.markCompleted(episode);
    if (!mounted) return;
    setState(() {
      _completedIds.add(episode.id);
      _isSaving = false;
    });

    if (rewarded) {
      await context.read<AuthProvider>().refreshUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
                'Tebrikler! +${episode.xpReward} XP, +${episode.jetonReward} 🪙',
                'Nice! +${episode.xpReward} XP, +${episode.jetonReward} 🪙',
                'Stark! +${episode.xpReward} XP, +${episode.jetonReward} 🪙',
                '¡Genial! +${episode.xpReward} XP, +${episode.jetonReward} 🪙'),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    _goToNext(episode);
  }

  @override
  Widget build(BuildContext context) {
    final series = widget.series;
    final color = series.color;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(series.titleFor(_lang)),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: series.episodes.isEmpty
          ? _buildEmpty()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                if (_selected != null) ...[
                  YouTubePlayerWidget(
                    videoUrl: _selected!.youtubeUrl,
                    onEnded: _onVideoEnded,
                  ),
                  const SizedBox(height: 14),
                  _buildCuratedTag(color),
                  const SizedBox(height: 8),
                  Text(
                    _selected!.titleFor(_lang),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F1D36),
                    ),
                  ),
                  if (_selected!.channelName != null) ...[
                    const SizedBox(height: 8),
                    _buildChannelRow(_selected!),
                  ],
                  if (_selected!.descriptionFor(_lang) != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _selected!.descriptionFor(_lang)!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _buildWatchedButton(_selected!, color),
                  const SizedBox(height: 26),
                ],
                Text(
                  _t('Bölümler', 'Episodes', 'Folgen', 'Episodios'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 10),
                ...series.episodes.asMap().entries.map(
                      (entry) => _buildEpisodeTile(entry.key, entry.value, color),
                    ),
              ],
            ),
    );
  }

  /// Bu videoların bize ait olmadığını, seçki olduğunu net söyleyen etiket.
  Widget _buildCuratedTag(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.recommend_rounded, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            _t('Önerilen video', 'Recommended video', 'Empfohlenes Video',
                'Vídeo recomendado'),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  /// Kanal adı + YouTube'da açma bağlantısı (atıf).
  Widget _buildChannelRow(VideoEpisode episode) {
    return Row(
      children: [
        Icon(Icons.person_outline_rounded, size: 15, color: Colors.grey[600]),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            episode.channelName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, color: Colors.grey[700], fontWeight: FontWeight.w600),
          ),
        ),
        TextButton.icon(
          onPressed: () => _openExternal(episode.channelUrl ?? episode.youtubeUrl),
          icon: const Icon(Icons.open_in_new_rounded, size: 15),
          label: Text(
              _t("YouTube'da aç", 'Open on YouTube', 'Auf YouTube öffnen',
                  'Abrir en YouTube'),
              style: const TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            _t(
                'Bu serinin bölümleri yakında eklenecek.',
                'Episodes for this series are coming soon.',
                'Die Folgen dieser Reihe kommen bald.',
                'Los episodios de esta serie llegarán pronto.'),
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchedButton(VideoEpisode episode, Color color) {
    final done = _completedIds.contains(episode.id);

    if (done) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle,
                color: Color(0xFF2E7D32), size: 20),
            const SizedBox(width: 8),
            Text(
              _t('Bu bölümü izledin', 'You watched this episode',
                  'Du hast diese Folge gesehen', 'Ya viste este episodio'),
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : () => _markWatched(episode),
        icon: const Icon(Icons.check_rounded),
        label: Text(_t(
            'İzledim  ·  +${episode.xpReward} XP, +${episode.jetonReward} 🪙',
            'Watched  ·  +${episode.xpReward} XP, +${episode.jetonReward} 🪙',
            'Gesehen  ·  +${episode.xpReward} XP, +${episode.jetonReward} 🪙',
            'Visto  ·  +${episode.xpReward} XP, +${episode.jetonReward} 🪙')),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildEpisodeTile(int index, VideoEpisode episode, Color color) {
    final done = _completedIds.contains(episode.id);
    final selected = _selected?.id == episode.id;

    return GestureDetector(
      onTap: () => setState(() => _selected = episode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: done ? const Color(0xFF2E7D32).withValues(alpha: 0.12) : color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, size: 18, color: Color(0xFF2E7D32))
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                episode.titleFor(_lang),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF1F1D36),
                ),
              ),
            ),
            if (episode.durationLabel != null) ...[
              const SizedBox(width: 8),
              Text(
                episode.durationLabel!,
                style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
