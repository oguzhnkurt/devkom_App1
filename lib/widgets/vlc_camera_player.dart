import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/camera_model.dart';
import '../theme.dart';

/// VLC Camera Player Widget
///
/// This widget uses the flutter_vlc_player package to stream RTSP video feeds.
/// VLC is a powerful media player that supports various streaming protocols including RTSP.
///
/// Setup Instructions:
/// 1. Add flutter_vlc_player to pubspec.yaml (already added)
/// 2. For Android: Add permissions to AndroidManifest.xml:
///    `<uses-permission android:name="android.permission.INTERNET"/>`
///    `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>`
/// 3. For iOS: Add permissions to Info.plist:
///    `<key>NSAppTransportSecurity</key>`
///    `<dict>`
///      `<key>NSAllowsArbitraryLoads</key>`
///      `<true/>`
///    `</dict>`
///
/// RTSP URL Format:
/// - Standard: rtsp://username:password@ip:port/path
/// - Example: rtsp://admin:admin@192.168.1.100:554/stream1
///
/// Performance Tips:
/// - Use lower quality for slower connections
/// - Enable hardware acceleration in VLC controller options
/// - Consider buffering settings for smooth playback
class VlcCameraPlayer extends StatefulWidget {
  final CameraModel camera;
  final CameraConnectionStatus connectionStatus;
  final VoidCallback onConnect;

  const VlcCameraPlayer({
    super.key,
    required this.camera,
    required this.connectionStatus,
    required this.onConnect,
  });

  @override
  State<VlcCameraPlayer> createState() => _VlcCameraPlayerState();
}

class _VlcCameraPlayerState extends State<VlcCameraPlayer> {
  late VlcPlayerController _vlcController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isBuffering = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _vlcController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VlcCameraPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinitialize if camera changed
    if (oldWidget.camera.id != widget.camera.id ||
        oldWidget.camera.rtspUrl != widget.camera.rtspUrl) {
      _vlcController.dispose();
      _initializePlayer();
    }
  }

  /// Initialize VLC Player with RTSP stream
  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isInitialized = false;
        _hasError = false;
        _errorMessage = null;
      });

      // Create VLC controller with RTSP URL
      _vlcController = VlcPlayerController.network(
        widget.camera.rtspUrl,
        hwAcc: HwAcc.full, // Enable hardware acceleration
        autoPlay: false, // Don't auto-play, wait for manual connection
        options: VlcPlayerOptions(
          // Advanced VLC options for RTSP streaming
          advanced: VlcAdvancedOptions([
            // Network caching (in milliseconds) - adjust based on network quality
            VlcAdvancedOptions.networkCaching(2000),
            // RTSP timeout settings
            VlcAdvancedOptions.clockJitter(0),
          ]),
          // HTTP options (if using HTTP stream as fallback)
          http: VlcHttpOptions([
            VlcHttpOptions.httpReconnect(true),
          ]),
          // Real-time streaming protocol options
          rtp: VlcRtpOptions([
            // Add RTSP specific options here
          ]),
          // Video output settings
          video: VlcVideoOptions([
            // Maintain aspect ratio
            VlcVideoOptions.dropLateFrames(true),
            VlcVideoOptions.skipFrames(true),
          ]),
        ),
      );

      // Listen to player state changes
      _vlcController.addListener(() {
        if (!mounted) return;

        setState(() {
          _isPlaying = _vlcController.value.isPlaying;
          _isBuffering = _vlcController.value.isBuffering;
        });

        // Check for errors
        if (_vlcController.value.hasError) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Video akışı hatası. Lütfen yeniden deneyin.';
          });
        }
      });

      await _vlcController.initialize();

      setState(() {
        _isInitialized = true;
      });

      // Auto-connect if status is connected
      if (widget.connectionStatus == CameraConnectionStatus.connected) {
        _play();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Oynatıcı başlatılamadı: ${e.toString()}';
      });
    }
  }

  /// Play the RTSP stream
  Future<void> _play() async {
    try {
      await _vlcController.play();
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Oynatma hatası: ${e.toString()}';
      });
    }
  }

  /// Pause the stream
  Future<void> _pause() async {
    try {
      await _vlcController.pause();
    } catch (e) {
      debugPrint('Pause error: $e');
    }
  }

  /// Retry connection
  Future<void> _retry() async {
    await _vlcController.stop();
    await Future.delayed(const Duration(milliseconds: 500));
    await _play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // VLC Player View
        if (_isInitialized && !_hasError)
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9, // Standard camera aspect ratio
              child: VlcPlayer(
                controller: _vlcController,
                aspectRatio: 16 / 9,
                placeholder: _buildPlaceholder(),
              ),
            ),
          ),

        // Error State
        if (_hasError) _buildErrorView(),

        // Loading State
        if (!_isInitialized && !_hasError) _buildLoadingView(),

        // Buffering Indicator
        if (_isBuffering && _isInitialized && !_hasError)
          _buildBufferingIndicator(),

        // Play/Pause Controls Overlay
        if (_isInitialized && !_hasError) _buildControlsOverlay(),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam,
              size: 64,
              color: AppTheme.lightGray,
            ),
            SizedBox(height: 16),
            Text(
              'Kamera görüntüsü bekleniyor...',
              style: TextStyle(
                color: AppTheme.lightGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
            ),
            SizedBox(height: 16),
            Text(
              'Oynatıcı hazırlanıyor...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBufferingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTeal),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Yükleniyor...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Bağlantı Hatası',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Bilinmeyen hata oluştu',
                style: const TextStyle(
                  color: AppTheme.lightGray,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Yeniden Dene'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentTeal,
                  foregroundColor: AppTheme.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    // Show controls when not connected
    if (widget.connectionStatus != CameraConnectionStatus.connected) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: () {
            widget.onConnect();
            _play();
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Bağlan ve Oynat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentTeal,
            foregroundColor: AppTheme.darkBlue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      );
    }

    // Play/Pause button when connected
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        onPressed: _isPlaying ? _pause : _play,
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        child: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: AppTheme.accentTeal,
        ),
      ),
    );
  }
}
