import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/play_time_limit_service.dart';
import '../theme.dart';

/// Oyun Süresi Kapısı Widget'ı
/// Çocukların oyun oynamadan önce süre kontrolü yapar
/// Limit aşıldıysa oyun ekranına erişimi engeller
class PlayTimeGate extends StatefulWidget {
  final Widget child;
  final String gameName;

  const PlayTimeGate({
    super.key,
    required this.child,
    required this.gameName,
  });

  @override
  State<PlayTimeGate> createState() => _PlayTimeGateState();
}

class _PlayTimeGateState extends State<PlayTimeGate> {
  final _playTimeService = PlayTimeLimitService();
  String? _activeSessionId;
  bool _isChecking = true;
  PlayTimeCheck? _checkResult;

  @override
  void initState() {
    super.initState();
    _checkLimitsAndStartSession();
  }

  @override
  void dispose() {
    _endSessionIfActive();
    super.dispose();
  }

  Future<void> _checkLimitsAndStartSession() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;

    if (userId == null) {
      setState(() => _isChecking = false);
      return;
    }

    // Limit kontrolü yap
    final checkResult = await _playTimeService.checkPlayTimeLimit(userId);

    if (!mounted) return;

    setState(() {
      _checkResult = checkResult;
      _isChecking = false;
    });

    // Eğer oyun oynayabiliyorsa, oturum başlat
    if (checkResult.canPlay) {
      final sessionId = await _playTimeService.startPlaySession(userId);
      if (mounted) {
        setState(() => _activeSessionId = sessionId);
      }
    }
  }

  Future<void> _endSessionIfActive() async {
    if (_activeSessionId != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid;

      if (userId != null) {
        await _playTimeService.endPlaySession(userId, _activeSessionId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.gameName),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Limit kontrolü sonucu
    if (_checkResult != null && !_checkResult!.canPlay) {
      return _buildLimitReachedScreen();
    }

    // Oyun oynamaya izin var
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _endSessionIfActive();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: widget.child,
    );
  }

  Widget _buildLimitReachedScreen() {
    String title;
    String message;
    IconData icon;
    Color color;

    switch (_checkResult!.limitType) {
      case 'daily':
        title = 'Günlük Limit Doldu';
        message = 'Bugün için oyun süreniz doldu. Yarın tekrar oynayabilirsiniz!';
        icon = Icons.today;
        color = AppTheme.errorRed;
        break;
      case 'weekly':
        title = 'Haftalık Limit Doldu';
        message = 'Bu hafta için oyun süreniz doldu. Önümüzdeki hafta tekrar oynayabilirsiniz!';
        icon = Icons.calendar_today;
        color = AppTheme.errorRed;
        break;
      case 'time_range':
        title = 'Şu An Oyun Oynayamazsınız';
        message = 'Veliniz bu saatte oyun oynamanızı kısıtlamış. Daha sonra tekrar deneyin!';
        icon = Icons.access_time;
        color = AppTheme.warningOrange;
        break;
      default:
        title = 'Limit Aşıldı';
        message = _checkResult!.message;
        icon = Icons.block;
        color = AppTheme.errorRed;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameName),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: color,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildUsageStats(),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Ana Menüye Dön'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageStats() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;

    if (userId == null) return const SizedBox.shrink();

    return FutureBuilder<Map<String, int>>(
      future: Future.wait([
        _playTimeService.getTodayPlayTime(userId),
        _playTimeService.getWeeklyPlayTime(userId),
      ]).then((results) => {'today': results[0], 'week': results[1]}),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final todayMinutes = snapshot.data!['today']!;
        final weekMinutes = snapshot.data!['week']!;

        final todayHours = todayMinutes ~/ 60;
        final todayMins = todayMinutes % 60;
        final weekHours = weekMinutes ~/ 60;
        final weekMins = weekMinutes % 60;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Oyun Süren',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    'Bugün',
                    '$todayHours sa $todayMins dk',
                    Icons.today,
                    AppTheme.primaryBlue,
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.grey[300],
                  ),
                  _buildStatColumn(
                    'Bu Hafta',
                    '$weekHours sa $weekMins dk',
                    Icons.calendar_today,
                    AppTheme.accentTeal,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Oyun süresi uyarı widget'ı
/// %80 limitine ulaşıldığında gösterilir
class PlayTimeWarningBanner extends StatelessWidget {
  final int remainingMinutes;
  final VoidCallback? onClose;

  const PlayTimeWarningBanner({
    super.key,
    required this.remainingMinutes,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Uyarı: Oyun süreniz dolmak üzere! Kalan: $remainingMinutes dakika',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
