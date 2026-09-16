import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/ad_config.dart';
import '../../services/ads_service.dart';

/// Reklamları denemek için tanı ekranı — YALNIZCA hata ayıklama derlemesi.
///
/// NEDEN VAR
/// ---------
/// "Reklamı test ettim, hiçbir şey çıkmadı" cümlesinin on tane sebebi
/// olabiliyor ve hepsi SESSİZ:
///
///  * Hesap **Pro** — Pro üye hiç reklam görmüyor (en sık düşülen tuzak).
///  * **Isınma payı** — ilk 3 ders/oyun bitişinde geçiş reklamı yok.
///  * **Günlük tavan** — ödüllüde 5, geçişte 6.
///  * **Dört dakikalık ara** — iki geçiş reklamı arasında.
///  * Kimlik `.env`'de yok (yayın derlemesinde).
///  * Platform desteklemiyor (masaüstü/web).
///
/// Bu ekran bunların hangisinin geçerli olduğunu tek bakışta söylüyor ve
/// reklamı kurallara takılmadan zorla açmayı sağlıyor.
///
/// GÜVENLİK: `kDebugMode` değilse ekran kendini açmıyor ve
/// `AdsService`in `debug*` çağrıları da sessizce hiçbir şey yapmıyor.
/// Yani yayın derlemesinde ulaşılsa bile bir işe yaramaz.
class AdTestScreen extends StatefulWidget {
  const AdTestScreen({super.key});

  @override
  State<AdTestScreen> createState() => _AdTestScreenState();
}

class _AdTestScreenState extends State<AdTestScreen> {
  final _ads = AdsService.instance;
  final List<String> _kayit = [];
  int _odulluBugun = 0;
  int _gecisBugun = 0;
  bool _mesgul = false;

  @override
  void initState() {
    super.initState();
    _tazele();
  }

  Future<void> _tazele() async {
    final o = await _ads.debugRewardedCountToday();
    final g = await _ads.debugInterstitialCountToday();
    if (!mounted) return;
    setState(() {
      _odulluBugun = o;
      _gecisBugun = g;
    });
  }

  void _yaz(String satir) {
    final t = TimeOfDay.now();
    setState(() => _kayit.insert(
        0, '${t.hour.toString().padLeft(2, '0')}:'
            '${t.minute.toString().padLeft(2, '0')}  $satir'));
  }

  Future<void> _sar(Future<void> Function() is_) async {
    if (_mesgul) return;
    setState(() => _mesgul = true);
    try {
      await is_();
    } catch (e) {
      _yaz('HATA: $e');
    }
    if (mounted) setState(() => _mesgul = false);
    await _tazele();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Yalnızca hata ayıklama derlemesinde.')),
      );
    }

    final engel = _engel();

    return Scaffold(
      appBar: AppBar(title: const Text('Reklam testi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (engel != null)
            _kutu(
              renk: Colors.orange,
              simge: Icons.report_problem_rounded,
              baslik: 'Şu an reklam çıkmaz',
              govde: engel,
            )
          else
            _kutu(
              renk: Colors.green,
              simge: Icons.check_circle_rounded,
              baslik: 'Reklam çıkabilir',
              govde: 'Engel yok. Aşağıdaki düğmeler çalışmalı.',
            ),
          const SizedBox(height: 16),
          _durum(),
          const SizedBox(height: 16),
          _dugmeler(),
          const SizedBox(height: 16),
          const Text('Kayıt', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_kayit.isEmpty)
            const Text('—')
          else
            ..._kayit.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(s,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12)),
                )),
        ],
      ),
    );
  }

  /// Reklamın çıkmasını engelleyen İLK sebep.
  String? _engel() {
    if (!_ads.isSupported) {
      return 'Bu platformda AdMob eklentisi yok (masaüstü/web). '
          'iOS simülatöründe ya da telefonda dene.';
    }
    if (!_ads.debugInitialized) {
      return 'AdsService başlatılmadı. main.dart içindeki '
          'AdsService.initialize() hata vermiş olabilir — konsola bak.';
    }
    if (_ads.isProMember) {
      return 'Hesap Pro. Pro üye hiç reklam görmüyor — bu bir hata değil, '
          'verilen söz. Denemek için aşağıdan "Pro\'yu geçici kapat".';
    }
    if (_ads.debugRewardedUnitId == null &&
        _ads.debugInterstitialUnitId == null) {
      return 'Reklam birimi kimliği yok. Hata ayıklama derlemesinde '
          'Google\'ın test kimlikleri kullanılır; burada null görünüyorsa '
          'platform algılanmamış demektir.';
    }
    return null;
  }

  Widget _durum() {
    final son = _ads.debugLastInterstitialShownAt;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _satir('Derleme', kDebugMode ? 'debug (test reklamları)' : 'release'),
          _satir('Platform destekli', '${_ads.isSupported}'),
          _satir('Başlatıldı', '${_ads.debugInitialized}'),
          _satir('Pro üye', '${_ads.isProMember}'),
          const Divider(),
          _satir('Ödüllü birim', _kisalt(_ads.debugRewardedUnitId)),
          _satir('Geçiş birimi', _kisalt(_ads.debugInterstitialUnitId)),
          _satir('Geçiş hazır (önyüklü)', '${_ads.debugInterstitialLoaded}'),
          const Divider(),
          _satir('Bugün ödüllü',
              '$_odulluBugun / ${AdConfig.rewardedDailyCap}'),
          _satir('Bugün geçiş',
              '$_gecisBugun / ${AdConfig.interstitialDailyCap}'),
          _satir('Bu oturumda adım',
              '${_ads.debugMilestonesThisSession} '
              '(ısınma: ${AdConfig.interstitialWarmupMilestones})'),
          _satir('Geçiş sırada', '${_ads.interstitialPending}'),
          _satir('Son geçiş',
              son == null ? '—' : '${DateTime.now().difference(son).inSeconds} sn önce'),
        ],
      ),
    );
  }

  String _kisalt(String? id) {
    if (id == null) return '— (yok)';
    // Google'ın test kimlikleri bilinen bir yayıncıyla başlıyor.
    final test = id.startsWith('ca-app-pub-3940256099942544');
    return '${test ? 'TEST ' : 'GERÇEK '}$id';
  }

  Widget _satir(String ad, String deger) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 150,
                child: Text(ad,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(
                child: Text(deger,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
          ],
        ),
      );

  Widget _kutu({
    required Color renk,
    required IconData simge,
    required String baslik,
    required String govde,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: renk.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: renk.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(simge, color: renk),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: renk)),
                  const SizedBox(height: 4),
                  Text(govde, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _dugmeler() => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          FilledButton.icon(
            onPressed: _mesgul
                ? null
                : () => _sar(() async {
                      _yaz('showRewarded() çağrıldı…');
                      final r = await _ads.showRewarded();
                      _yaz(r.earned
                          ? 'ÖDÜL KAZANILDI (+${AdConfig.rewardedJeton} jeton hak edildi)'
                          : 'ödül yok — sebep: ${r.reason?.name ?? "bilinmiyor"}');
                    }),
            icon: const Icon(Icons.card_giftcard_rounded),
            label: const Text('Ödüllü videoyu göster'),
          ),
          FilledButton.icon(
            onPressed: _mesgul
                ? null
                : () => _sar(() async {
                      _yaz('debugForceInterstitial() çağrıldı…');
                      final ok = await _ads.debugForceInterstitial();
                      _yaz(ok ? 'geçiş reklamı gösterildi' : 'gösterilemedi');
                    }),
            icon: const Icon(Icons.fullscreen_rounded),
            label: const Text('Geçiş reklamını zorla'),
          ),
          OutlinedButton.icon(
            onPressed: _mesgul
                ? null
                : () => _sar(() async {
                      _ads.debugMarkDueNow();
                      _yaz('sırada işaretlendi — şimdi bu ekrandan çıkınca '
                          'gerçek akıştaki gibi çıkmalı');
                    }),
            icon: const Icon(Icons.schedule_rounded),
            label: const Text('Sıraya al (gerçek akış)'),
          ),
          OutlinedButton.icon(
            onPressed: _mesgul
                ? null
                : () => _sar(() async {
                      _ads.debugSetProMember(!_ads.isProMember);
                      _yaz('Pro üye artık: ${_ads.isProMember}');
                    }),
            icon: const Icon(Icons.workspace_premium_rounded),
            label: Text(_ads.isProMember
                ? 'Pro\'yu geçici kapat'
                : 'Pro\'yu geçici aç'),
          ),
          OutlinedButton.icon(
            onPressed: _mesgul
                ? null
                : () => _sar(() async {
                      await _ads.debugResetDailyCounters();
                      _yaz('günlük sayaçlar sıfırlandı');
                    }),
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Sayaçları sıfırla'),
          ),
        ],
      );
}
