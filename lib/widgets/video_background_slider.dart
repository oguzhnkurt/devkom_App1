import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';

/// Video Background Slider Widget
/// Displays a carousel of video backgrounds with overlay content
class VideoBackgroundSlider extends StatefulWidget {
  final List<VideoBackgroundItem> items;
  final Duration autoPlayInterval;
  final double opacity;
  final Widget? overlayWidget;

  const VideoBackgroundSlider({
    Key? key,
    required this.items,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.opacity = 0.3,
    this.overlayWidget,
  }) : super(key: key);

  @override
  State<VideoBackgroundSlider> createState() => _VideoBackgroundSliderState();
}

class _VideoBackgroundSliderState extends State<VideoBackgroundSlider> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;
  final Map<int, VideoPlayerController?> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeFirstVideo();
  }

  Future<void> _initializeFirstVideo() async {
    if (widget.items.isEmpty) return;

    final firstItem = widget.items[0];
    if (firstItem.videoAssetPath != null) {
      await _initializeVideo(0, firstItem.videoAssetPath!);
    }
  }

  Future<void> _initializeVideo(int index, String assetPath) async {
    if (_videoControllers[index] != null) return;

    try {
      final controller = VideoPlayerController.asset(assetPath);
      _videoControllers[index] = controller;

      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0); // Mute video
      if (index == _currentIndex) {
        controller.play();
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Error initializing video $assetPath: $e');
      _videoControllers[index] = null;
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      // Pause previous video
      _videoControllers[_currentIndex]?.pause();

      _currentIndex = index;

      // Play new video
      final controller = _videoControllers[index];
      if (controller != null && controller.value.isInitialized) {
        controller.play();
      } else {
        // Initialize video if not already done
        final item = widget.items[index];
        if (item.videoAssetPath != null) {
          _initializeVideo(index, item.videoAssetPath!);
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Carousel with video/image backgrounds
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: widget.items.length,
          itemBuilder: (context, index, realIndex) {
            final item = widget.items[index];
            return _buildSlideItem(item, index);
          },
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: widget.autoPlayInterval,
            onPageChanged: (index, reason) => _onPageChanged(index),
          ),
        ),

        // Overlay widget
        if (widget.overlayWidget != null)
          Positioned.fill(
            child: widget.overlayWidget!,
          ),

        // Page indicators
        if (widget.items.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.items.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_currentIndex == entry.key
                            ? Colors.white
                            : Colors.white.withOpacity(0.4))
                        .withOpacity(0.8),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSlideItem(VideoBackgroundItem item, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background (video or image)
        if (item.videoAssetPath != null)
          _buildVideoBackground(index, item.videoAssetPath!)
        else if (item.imageAssetPath != null)
          _buildImageBackground(item.imageAssetPath!)
        else
          Container(
            decoration: BoxDecoration(
              gradient: item.gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade900,
                      Colors.purple.shade900,
                    ],
                  ),
            ),
          ),

        // Semi-transparent overlay
        Container(
          color: Colors.black.withOpacity(widget.opacity),
        ),

        // Content
        if (item.content != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: item.content,
            ),
          ),
      ],
    );
  }

  Widget _buildVideoBackground(int index, String videoPath) {
    final controller = _videoControllers[index];

    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  Widget _buildImageBackground(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.black,
          child: const Icon(Icons.error, color: Colors.white),
        );
      },
    );
  }
}

/// Video Background Item
class VideoBackgroundItem {
  final String? videoAssetPath;
  final String? imageAssetPath;
  final Gradient? gradient;
  final Widget? content;

  VideoBackgroundItem({
    this.videoAssetPath,
    this.imageAssetPath,
    this.gradient,
    this.content,
  }) : assert(
          videoAssetPath != null || imageAssetPath != null || gradient != null,
          'At least one background type must be provided',
        );

  /// Create video background
  factory VideoBackgroundItem.video({
    required String videoPath,
    Widget? content,
  }) {
    return VideoBackgroundItem(
      videoAssetPath: videoPath,
      content: content,
    );
  }

  /// Create image background
  factory VideoBackgroundItem.image({
    required String imagePath,
    Widget? content,
  }) {
    return VideoBackgroundItem(
      imageAssetPath: imagePath,
      content: content,
    );
  }

  /// Create gradient background
  factory VideoBackgroundItem.gradient({
    required Gradient gradient,
    Widget? content,
  }) {
    return VideoBackgroundItem(
      gradient: gradient,
      content: content,
    );
  }
}
