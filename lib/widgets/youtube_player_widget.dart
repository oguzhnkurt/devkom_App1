import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Gömülü YouTube oynatıcı.
///
/// NOT: Daha önce denetleyici yalnızca [initState] içinde `initialVideoId` ile
/// kuruluyordu. Ekran başka bir bölüme geçtiğinde widget aynı kaldığı için
/// `initState` tekrar çalışmıyor, dolayısıyla hangi bölüme dokunulursa
/// dokunulsun hep ilk video oynuyordu. Çözüm [didUpdateWidget]: URL
/// değiştiğinde denetleyiciyi yeniden kurmak yerine `load()` ile yeni videoyu
/// yüklüyoruz — webview yeniden yaratılmadığı için geçiş de hızlı oluyor.
class YouTubePlayerWidget extends StatefulWidget {
  final String videoUrl;

  /// Video sonuna geldiğinde tetiklenir (sıradaki bölüme geçmek için).
  final VoidCallback? onEnded;

  const YouTubePlayerWidget({
    super.key,
    required this.videoUrl,
    this.onEnded,
  });

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;

  /// Aynı video için onEnded'i bir kez tetiklemek üzere.
  bool _endedHandled = false;

  String? get _videoId => YoutubePlayer.convertUrlToId(widget.videoUrl);

  @override
  void initState() {
    super.initState();
    final id = _videoId;
    if (id == null) return;

    _controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    )..addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!mounted || !_isPlayerReady) return;

    final controller = _controller;
    if (controller != null &&
        controller.value.playerState == PlayerState.ended &&
        !_endedHandled) {
      _endedHandled = true;
      widget.onEnded?.call();
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant YouTubePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl == widget.videoUrl) return;

    final id = _videoId;
    if (id == null) return;

    _endedHandled = false;
    _controller?.load(id);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    // Oynatici herhangi bir sebeple yonelimi degistirdiyse geri al.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (controller == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Geçersiz YouTube video linki',
                style: TextStyle(color: Colors.red.shade900, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: const Color(0xFF6C63FF),
          progressColors: const ProgressBarColors(
            playedColor: Color(0xFF6C63FF),
            handleColor: Color(0xFF6C63FF),
          ),
          onReady: () {
            setState(() => _isPlayerReady = true);
          },
          onEnded: (_) {
            if (_endedHandled) return;
            _endedHandled = true;
            widget.onEnded?.call();
          },
          bottomActions: [
            CurrentPosition(),
            const SizedBox(width: 10),
            ProgressBar(
              isExpanded: true,
              colors: const ProgressBarColors(
                playedColor: Color(0xFF6C63FF),
                handleColor: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(width: 10),
            RemainingDuration(),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
