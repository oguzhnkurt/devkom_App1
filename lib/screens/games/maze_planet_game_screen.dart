import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

/// Daily Maze - Günlük labirent bulmacası
/// Her gün yeni labirent seviyeleri çöz
class MazePlanetGameScreen extends StatefulWidget {
  const MazePlanetGameScreen({super.key});

  @override
  State<MazePlanetGameScreen> createState() => _MazePlanetGameScreenState();
}

class _MazePlanetGameScreenState extends State<MazePlanetGameScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isSkippingAd = false;
  int _adSkipCountdown = 20;
  Timer? _adSkipTimer;

  String get _lang => Provider.of<SettingsProvider>(context, listen: false).locale.languageCode;
  bool get _isEn => _lang == 'en';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _adSkipTimer?.cancel();
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Yükleme ilerlemesi
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Hemen reklamları engelle
            _blockAdsImmediately();
            // Reklam atlatma mekanizmasını başlat
            _startAdSkipMechanism();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = error.description;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Tüm navigasyonlara izin ver
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://cdn.htmlgames.com/DailyMaze/index.html?npa=1'));
  }

  void _blockAdsImmediately() {
    // Sayfa yüklendiğinde hemen reklamları engelle
    _controller.runJavaScript('''
      (function() {
        // Mutation Observer ile dinamik reklam elementlerini de engelle
        const observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            mutation.addedNodes.forEach(function(node) {
              if (node.nodeType === 1) {
                // Reklam iframe'i eklendiyse sil
                if (node.tagName === 'IFRAME' &&
                    (node.src.includes('doubleclick') ||
                     node.src.includes('google') ||
                     node.src.includes('ads') ||
                     node.className.includes('ad') ||
                     node.id.includes('ad'))) {
                  node.remove();
                  console.log('Dynamic ad iframe blocked');
                }
                // Reklam overlay eklenirse sil
                if (node.className.includes('ad-') ||
                    node.className.includes('advertisement') ||
                    node.id.includes('ad-')) {
                  node.style.display = 'none';
                  node.remove();
                  console.log('Dynamic ad overlay blocked');
                }
              }
            });
          });
        });

        // Tüm body'yi gözle
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });

        // Mevcut reklamları temizle
        const adElements = document.querySelectorAll(
          'iframe[src*="doubleclick"],' +
          'iframe[src*="google"],' +
          'iframe[src*="ads"],' +
          'iframe[id*="ad"],' +
          'iframe[class*="ad"],' +
          '[class*="ad-overlay"],' +
          '[class*="ad-container"],' +
          '[class*="advertisement"]'
        );

        adElements.forEach(el => {
          el.remove();
          console.log('Initial ad element removed');
        });

        console.log('Ad blocker initialized');
      })();
    ''');
  }

  void _startAdSkipMechanism() {
    // Reklam atlatma sayacını başlat
    setState(() {
      _isSkippingAd = true;
      _adSkipCountdown = 20;
    });

    // 20 saniye boyunca her saniye sayacı güncelle
    _adSkipTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_adSkipCountdown > 0) {
        setState(() {
          _adSkipCountdown--;
        });
        // Reklam atla butonunu ara ve tıkla
        _trySkipAd();
      } else {
        // 20 saniye sonra sayacı durdur
        timer.cancel();
        setState(() {
          _isSkippingAd = false;
        });
        // Son bir kez daha reklam atlatmayı dene
        _trySkipAd();
      }
    });
  }

  void _trySkipAd() {
    // JavaScript ile reklamları engelle ve oyunu başlat
    _controller.runJavaScript('''
      (function() {
        // 1. Tüm reklam iframe'lerini kaldır
        const adIframes = document.querySelectorAll('iframe[src*="doubleclick"], iframe[src*="google"], iframe[src*="ads"], iframe[src*="ad."], iframe[id*="ad"], iframe[class*="ad"]');
        adIframes.forEach(iframe => {
          iframe.remove();
          console.log('Ad iframe removed');
        });

        // 2. Reklam overlay'lerini kaldır
        const adOverlays = document.querySelectorAll(
          '[class*="ad-overlay"],' +
          '[id*="ad-overlay"],' +
          '[class*="ad-container"],' +
          '[id*="ad-container"],' +
          '[class*="advertisement"],' +
          '[id*="advertisement"],' +
          '.afs_ads,' +
          '[class*="preroll"],' +
          '[id*="preroll"]'
        );
        adOverlays.forEach(overlay => {
          overlay.style.display = 'none';
          overlay.remove();
          console.log('Ad overlay removed');
        });

        // 3. Skip butonlarını ara ve tıkla
        const skipSelectors = [
          '[class*="skip"]',
          '[id*="skip"]',
          'button:contains("Skip")',
          'div:contains("Skip Ad")',
          '.skip-ad',
          '.skip-button',
          '#skip-button',
          '[aria-label*="Skip"]'
        ];

        skipSelectors.forEach(selector => {
          try {
            const skipButton = document.querySelector(selector);
            if (skipButton && skipButton.offsetParent !== null) {
              skipButton.click();
              console.log('Skip button clicked:', selector);
            }
          } catch(e) {}
        });

        // 4. Play butonunu ara ve tıkla
        const playSelectors = [
          '.play-button',
          '#play-button',
          'button[class*="play"]',
          'div[class*="play"]',
          '[aria-label*="Play"]',
          'canvas + button',
          'canvas + div[role="button"]'
        ];

        playSelectors.forEach(selector => {
          try {
            const playButton = document.querySelector(selector);
            if (playButton && playButton.offsetParent !== null) {
              playButton.click();
              console.log('Play button clicked:', selector);
            }
          } catch(e) {}
        });

        // 5. Canvas'ı tıkla (oyun başlatma için)
        const canvas = document.querySelector('canvas');
        if (canvas) {
          const clickEvent = new MouseEvent('click', {
            view: window,
            bubbles: true,
            cancelable: true
          });
          canvas.dispatchEvent(clickEvent);
          console.log('Canvas clicked to start game');
        }

        // 6. Reklam scriptlerini engelle
        const adScripts = document.querySelectorAll('script[src*="doubleclick"], script[src*="googlesyndication"], script[src*="adservice"]');
        adScripts.forEach(script => {
          script.remove();
          console.log('Ad script removed');
        });

        // 7. Oyun yükleme durumunu kontrol et
        const gameLoaded = document.querySelector('.game-container, #game, canvas, [id*="game"]');
        if (gameLoaded) {
          console.log('Game loaded successfully');
        }
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Maze',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _isEn ? 'Daily Maze Puzzle' : 'Günlük Labirent Bulmacası',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Yenile butonu
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            },
            tooltip: _isEn ? 'Refresh' : 'Yenile',
          ),
          // Bilgi butonu
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showGameInfo(context);
            },
            tooltip: _isEn ? 'Game Info' : 'Oyun Bilgisi',
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          if (!_hasError)
            WebViewWidget(controller: _controller)
          else
            _buildErrorWidget(),

          // Yükleme göstergesi
          if (_isLoading)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isEn ? 'Loading game...' : 'Oyun yükleniyor...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEn ? 'This may take a moment' : 'Bu biraz zaman alabilir',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Reklam atlama göstergesi
          if (_isSkippingAd && !_isLoading)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: (_adSkipCountdown / 20),
                            strokeWidth: 6,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        Text(
                          _adSkipCountdown.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _isEn ? 'Skipping ad...' : 'Reklam atlanıyor...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isEn
                          ? 'Game will start in $_adSkipCountdown seconds'
                          : 'Oyun ${_adSkipCountdown} saniye içinde başlayacak',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        _adSkipTimer?.cancel();
                        setState(() {
                          _isSkippingAd = false;
                        });
                        _trySkipAd();
                      },
                      icon: const Icon(Icons.skip_next),
                      label: Text(_isEn ? 'Skip Now' : 'Hemen Atla'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                _isEn ? 'Failed to Load Game' : 'Oyun Yüklenemedi',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : (_isEn ? 'Check your internet connection' : 'İnternet bağlantınızı kontrol edin'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  _controller.reload();
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: Text(_isEn ? 'Try Again' : 'Tekrar Dene'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎮 Daily Maze'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isEn ? 'About the Game' : 'Oyun Hakkında',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isEn
                    ? 'Solve new maze puzzles every day! Find the path from the start point to the finish point. A fun experience with new levels and challenges daily.'
                    : 'Her gün yeni labirent bulmacaları çöz! '
                        'Başlangıç noktasından bitiş noktasına kadar yolu bul. '
                        'Günlük yeni seviyeler ve zorluklarla eğlenceli bir deneyim.',
              ),
              const SizedBox(height: 16),
              Text(
                _isEn ? 'How to Play?' : 'Nasıl Oynanır?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.touch_app, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_isEn ? 'Draw the path by touching the screen' : 'Ekrana dokunarak yol çizin'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_isEn ? 'New maze levels every day' : 'Her gün yeni labirent seviyeleri'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _isEn ? 'Features' : 'Özellikler',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('📅', _isEn ? 'New Levels Daily' : 'Günlük Yeni Seviyeler'),
              _buildFeatureItem('🧩', _isEn ? 'Mind and Strategy' : 'Akıl ve Strateji'),
              _buildFeatureItem('📱', _isEn ? 'Mobile Friendly' : 'Mobil Uyumlu'),
              _buildFeatureItem('⭐', _isEn ? 'Fun Puzzles' : 'Eğlenceli Bulmacalar'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_isEn ? 'OK' : 'Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
