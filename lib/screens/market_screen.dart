import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/lang.dart';
import '../providers/settings_provider.dart';
import '../models/store_item_model.dart';
import '../providers/auth_provider.dart';
import '../config/ad_config.dart';
import '../services/ads_service.dart';
import '../services/user_progress_service.dart';
import '../core/service_locator.dart';
import '../services/store_service.dart';
import 'subscription_screen.dart';
import '../widgets/avatar_cercevesi.dart';
import '../widgets/mascot.dart';

/// Market ekranı: derslerde ve oyunlarda kazanılan jetonların harcandığı yer.
///
/// NE SATILDIĞI DEĞİŞTİ
///
/// Burada eskiden şapka, gözlük, kolye, ayakkabı, robot kılıfı ve
/// "karakterler" vardı; hepsi maskotun üstüne giydiriliyordu. Maskot tek
/// bir 3B render olunca giydirme imkânsız hâle geldi ve o ürünler
/// katalogdan kalktı (satın alanlara jetonları iade edildi —
/// bkz. supabase/migrations/32_tek_maskot_ve_jeton_iadesi.sql).
///
/// Geriye avatar çerçeveleri kaldı ve çerçeve artık GERÇEKTEN görünüyor:
/// profil avatarının etrafında, buradaki önizlemenin birebir aynısı
/// (bkz. widgets/avatar_cercevesi.dart). Karşılığı olmayan bir vaat
/// mağazanın kendisini anlamsız kılar — çocuk jetonunu verip hiçbir şeyin
/// değişmediğini bir kez görürse bir daha jeton biriktirmez.
///
/// Bkz. supabase/migrations/23_store_and_jeton_economy.sql
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final StoreService _storeService = StoreService();

  bool _isLoading = true;
  bool _isProcessing = false;
  List<StoreItem> _catalog = [];
  Set<String> _ownedItemIds = {};
  Set<String> _equippedItemIds = {};
  Map<StoreItemCategory, StoreItem> _equipped = {};
  StoreItemCategory _selectedCategory = satilanKategoriler.first;

  /// Dokunulan (henüz alınmamış) çerçeve: önizlemede onu gösteriyoruz.
  /// Birkaç saniye sonra kuşanılmış olana geri dönüyor.
  StoreItem? _previewItem;
  Timer? _previewTimer;

  /// Önizlemede gösterilecek çerçeve: dokunulan, yoksa kuşanılan.
  StoreItem? get _onizlenen =>
      _previewItem ?? _equipped[StoreItemCategory.avatarFrame];

  void _onizle(StoreItem item) {
    _previewTimer?.cancel();
    setState(() => _previewItem = item);
    _previewTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _previewItem = null);
    });
  }

  /// Ödüllü video düğmesi gösterilsin mi? Pro üyede, kimlik
  /// tanımlanmamışsa ve günlük hak dolduğunda gizleniyor.
  bool _canWatchAd = false;
  bool _watchingAd = false;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshAdAvailability();
  }

  Future<void> _refreshAdAvailability() async {
    final can = await AdsService.instance.canWatchRewarded();
    if (!mounted) return;
    setState(() => _canWatchAd = can);
  }

  /// "Reklam izle, jeton kazan".
  ///
  /// Ödül yalnızca kullanıcı videoyu sonuna kadar izlediğinde veriliyor;
  /// kararı [AdsService] veriyor, jetonu bu ekran ekliyor. Yarıda
  /// kapatıldığında hiçbir şey verilmiyor ama kullanıcı suçlanmıyor —
  /// nötr bir mesaj gösteriliyor.
  Future<void> _watchAdForJeton() async {
    if (_watchingAd) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser == null) return;

    setState(() => _watchingAd = true);
    final result = await AdsService.instance.showRewarded();
    if (!mounted) return;

    if (result.earned) {
      await auth.addJeton(AdConfig.rewardedJeton, source: 'rewarded_ad');
      if (!mounted) return;
      _showSnack(_t(
        context,
        '+${AdConfig.rewardedJeton} jeton kazandın!',
        'You earned ${AdConfig.rewardedJeton} coins!',
        '+${AdConfig.rewardedJeton} Münzen verdient!',
        '¡Ganaste ${AdConfig.rewardedJeton} monedas!',
      ));
    } else {
      switch (result.reason) {
        case RewardedAdFailure.dailyCapReached:
          _showSnack(_t(context, 'Bugünlük bu kadar. Yarın yeniden dene.',
              "That's it for today. Try again tomorrow.",
              'Für heute reicht es. Versuch es morgen wieder.',
              'Por hoy es suficiente. Inténtalo mañana.'));
          break;
        case RewardedAdFailure.dismissedEarly:
          _showSnack(_t(context, 'Video tamamlanmadı, jeton verilmedi.',
              'The video was not finished, so no coins this time.',
              'Das Video wurde nicht zu Ende geschaut, keine Münzen.',
              'El vídeo no terminó, esta vez no hay monedas.'));
          break;
        default:
          _showSnack(_t(context, 'Şu an gösterilecek video yok.',
              'No video available right now.',
              'Gerade ist kein Video verfügbar.',
              'Ahora mismo no hay ningún vídeo.'));
      }
    }

    if (!mounted) return;
    setState(() => _watchingAd = false);
    await _refreshAdAvailability();
  }

  /// Jeton kazanma şeridi. Pro üyeye hiç gösterilmiyor — paywall'da
  /// "Reklamsız kullanım" yazıyor.
  /// SERI KALKANI — tuketilebilir, markette kendi seridinde.
  ///
  /// Neden kartlarin arasinda degil: cerceve ya da afis bir kez alinip
  /// kusaniliyor, kalkan ise HARCANIYOR. Ikisini ayni izgarada gostermek
  /// "aldim, takayim" beklentisi yaratirdi.
  Widget _buildKalkanSeridi() {
    final progress =
        Provider.of<AuthProvider>(context, listen: true).userProgress;
    final kalkan = progress?.streakShields ?? 0;
    final seri = progress?.streakDays ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Material(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _isProcessing ? null : _kalkanAl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(context, 'Seri kalkanı', 'Streak shield',
                            'Serien-Schild', 'Escudo de racha'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF143C6B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        // VAAT TAM OLARAK OLANI SOYLUYOR: bir gunluk
                        // aksamayi affediyor, seriyi satin almiyor.
                        _t(
                          context,
                          'Bir gün ara verirsen $seri günlük serin kırılmaz. '
                              'Elinde: $kalkan',
                          'If you miss one day, your $seri-day streak '
                              'survives. You have: $kalkan',
                          'Wenn du einen Tag aussetzt, bleibt deine '
                              '$seri-Tage-Serie. Du hast: $kalkan',
                          'Si te saltas un día, tu racha de $seri días se '
                              'mantiene. Tienes: $kalkan',
                        ),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF3A5A80)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('60 🪙',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _kalkanAl() async {
    setState(() => _isProcessing = true);
    final sonuc = await UserProgressService().seriKalkaniAl(1);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (sonuc['success'] == true) {
      await Provider.of<AuthProvider>(context, listen: false).refreshProgress();
      if (!mounted) return;
      _showSnack(_t(context, 'Seri kalkanı senin oldu! 🛡️',
          'The streak shield is yours! 🛡️', 'Das Serien-Schild gehört dir! 🛡️',
          '¡El escudo de racha es tuyo! 🛡️'));
      return;
    }

    switch (sonuc['error']) {
      case 'insufficient_balance':
        _showSnack(
            _t(context, '60 🪙 gerekiyor. Biraz daha ders bitir!',
                'You need 60 🪙. Finish a few more lessons!',
                'Du brauchst 60 🪙. Mach noch ein paar Lektionen!',
                'Necesitas 60 🪙. ¡Termina algunas lecciones más!'),
            isError: true);
        break;
      case 'shield_limit':
        // Sinirsiz biriktirme seriyi "her gun biraz calismak" olmaktan
        // cikarirdi; sinir 3.
        _showSnack(
            _t(context, 'En fazla 3 kalkan taşıyabilirsin.',
                'You can carry at most 3 shields.',
                'Du kannst höchstens 3 Schilde tragen.',
                'Puedes llevar como máximo 3 escudos.'),
            isError: true);
        break;
      default:
        _showSnack(
            _t(context, 'Alınamadı, tekrar dene.',
                'Could not buy it. Try again.',
                'Kauf fehlgeschlagen. Versuch es erneut.',
                'No se pudo comprar. Inténtalo de nuevo.'),
            isError: true);
    }
  }

  Widget _buildRewardedStrip() {
    if (!_canWatchAd) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Material(
        color: const Color(0xFFFFF3DA),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _watchingAd ? null : _watchAdForJeton,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Text('🎬', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _t(
                      context,
                      'Kısa bir video izle, ${AdConfig.rewardedJeton} jeton kazan',
                      'Watch a short video, earn ${AdConfig.rewardedJeton} coins',
                      'Kurzes Video ansehen, ${AdConfig.rewardedJeton} Münzen verdienen',
                      'Mira un vídeo corto y gana ${AdConfig.rewardedJeton} monedas',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B4A00),
                    ),
                  ),
                ),
                if (_watchingAd)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.play_circle_fill_rounded,
                      color: Color(0xFFE8A317)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final catalog = await _storeService.getCatalog();
      final inventory = await _storeService.getInventory();
      final equipped = await _storeService.getAllEquipped();
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _ownedItemIds = inventory.map((o) => o.item.id).toSet();
        _equippedItemIds = inventory.where((o) => o.equipped).map((o) => o.item.id).toSet();
        _equipped = equipped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  int get _jetonBalance =>
      Provider.of<AuthProvider>(context, listen: false).userProgress?.jetonBalance ?? 0;

  Future<void> _handleTap(StoreItem item) async {
    final owned = _ownedItemIds.contains(item.id);
    final equipped = _equippedItemIds.contains(item.id);
    if (equipped || _isProcessing) return;

    setState(() => _isProcessing = true);

    if (owned) {
      final ok = await _storeService.equipItem(item.id);
      if (!mounted) return;
      if (ok) {
        setState(() {
          _equippedItemIds
            ..removeWhere((id) => _catalog.firstWhere((i) => i.id == id).category == item.category)
            ..add(item.id);
          _equipped[item.category] = item;
          // Isim rozeti degistiyse siralamaya YENISI yazilsin: servis
          // rozeti bir kez okuyup akilda tutuyor.
          if (item.category == StoreItemCategory.nameBadge) {
            leaderboardService.rozetiUnut();
          }
          _previewTimer?.cancel();
          _previewItem = null;
        });
        _showSnack(_t(context, '${item.name} takıldı!', '${item.name} is on!',
            '${item.name} ist an!', '¡${item.name} puesto!'));
      } else {
        _showSnack(
            _t(context, 'Takılamadı, tekrar dene.', 'Could not apply it. Try again.',
                'Konnte nicht angelegt werden. Versuch es erneut.',
                'No se pudo poner. Inténtalo de nuevo.'),
            isError: true);
      }
    } else {
      final result = await _storeService.purchaseItem(item.id);
      if (!mounted) return;
      if (result['success'] == true) {
        await Provider.of<AuthProvider>(context, listen: false)
            .refreshProgress();
        if (!mounted) return;
        setState(() => _ownedItemIds.add(item.id));
        _showSnack(_t(context, '${item.name} senin oldu! ${item.iconEmoji}',
            '${item.name} is yours! ${item.iconEmoji}',
            '${item.name} gehört dir! ${item.iconEmoji}',
            '¡${item.name} es tuyo! ${item.iconEmoji}'));
      } else {
        _handlePurchaseError(result['error'], item);
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  void _handlePurchaseError(String? error, StoreItem item) {
    switch (error) {
      case 'requires_pro':
        _showProRequiredDialog(item);
        break;
      case 'insufficient_balance':
        _showSnack(
            _t(context,
                '${item.priceJeton} 🪙 gerekiyor. Biraz daha ders bitir!',
                'You need ${item.priceJeton} 🪙. Finish a few more lessons!',
                'Du brauchst ${item.priceJeton} 🪙. Mach noch ein paar Lektionen!',
                'Necesitas ${item.priceJeton} 🪙. ¡Termina algunas lecciones más!'),
            isError: true);
        break;
      case 'already_owned':
        _showSnack(
            _t(context, 'Bu zaten sende var.', 'You already have this.',
                'Das hast du schon.', 'Ya lo tienes.'),
            isError: true);
        break;
      default:
        _showSnack(
            _t(context, 'Satın alınamadı, tekrar dene.',
                'Purchase failed. Try again.',
                'Kauf fehlgeschlagen. Versuch es erneut.',
                'No se pudo comprar. Inténtalo de nuevo.'),
            isError: true);
    }
  }

  void _showProRequiredDialog(StoreItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_t(context, 'Pro Üyelik Gerekli', 'Pro membership needed', 'Pro-Mitgliedschaft nötig', 'Necesitas Pro')),
        content: Text(_t(
            context,
            '${item.name} yalnızca Pro üyelerde.',
            '${item.name} is only for Pro members.',
            '${item.name} gibt es nur für Pro-Mitglieder.',
            '${item.name} es solo para miembros Pro.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t(context, 'Vazgeç', 'Cancel', 'Abbrechen', 'Cancelar'))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
            },
            child: Text(_t(context, 'Pro\'ya Geç', 'Get Pro', 'Pro holen', 'Consigue Pro')),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jetonBalance = authProvider.userProgress?.jetonBalance ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C3CE0),
        foregroundColor: Colors.white,
        title: Text(_t(context, '🛍️ Market', '🛍️ Store', '🛍️ Laden',
            '🛍️ Tienda')),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '$jetonBalance',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStagePreview(),
                _buildRewardedStrip(),
                _buildKalkanSeridi(),
                _buildCategoryTabs(),
                Expanded(child: _buildGrid()),
              ],
            ),
    );
  }

  /// Marketin üstündeki önizleme: çerçeve, profilde görüneceği gibi.
  ///
  /// Burada önce giydirme sahnesi vardı ("bir ürüne dokun, karakterinde
  /// dene"). Giydirme kalktı. Onun yerine artık satılan ŞEYİ gösteriyor:
  /// Devi'nin etrafındaki çerçeve, profil ekranındakinin birebir aynısı.
  Widget _buildStagePreview() {
    final c = _onizlenen;
    final accent =
        c == null ? Mascot.tone : AvatarCercevesi.renk(c.colorHex);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.12), Colors.white],
        ),
      ),
      child: Column(
        children: [
          AvatarCercevesi(
            boyut: 104,
            cerceve: c,
            child: const Mascot(size: 74, showShadow: false),
          ),
          const SizedBox(height: 8),
          Text(
            // VAAT TAM OLARAK OLANI SOYLUYOR: cerceve profilde gorunur.
            // Once "bir urune dokun, karakterinde dene!" yaziyordu ve
            // denenecek bir sey yoktu.
            c == null
                ? _t(
                    context,
                    'Çerçeven profilinde görünür.',
                    'Your frame shows on your profile.',
                    'Dein Rahmen erscheint in deinem Profil.',
                    'Tu marco aparece en tu perfil.')
                : c.name,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = satilanKategoriler;
    // TEK KATEGORI VARKEN SEKME CUBUGU YOK: secilecek bir sey yokken
    // sekme gostermek, olmayan bir bolumu varmis gibi gosteriyor.
    if (categories.length < 2) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((c) {
            final selected = c == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = c),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF6C3CE0) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  storeCategoryDisplayName(c),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final items = _catalog.where((i) => i.category == _selectedCategory).toList();
    if (items.isEmpty) {
      return Center(child: Text(_t(context, 'Bu kategoride henüz ürün yok.', 'Nothing in this category yet.', 'In dieser Kategorie gibt es noch nichts.', 'Todavía no hay nada en esta categoría.')));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildItemCard(items[index]),
    );
  }

  Widget _buildItemCard(StoreItem item) {
    final owned = _ownedItemIds.contains(item.id);
    final equipped = _equippedItemIds.contains(item.id);
    final canAfford = _jetonBalance >= item.priceJeton;
    final color = Color(int.parse(item.colorHex.replaceFirst('#', '0xFF')));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: equipped ? color : Colors.grey.shade200, width: equipped ? 2 : 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: item.category == StoreItemCategory.avatarFrame
                  ? () => _onizle(item)
                  : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      boxShadow: item.requiresPro
                          ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 14, spreadRadius: 2)]
                          : null,
                    ),
                    child: Center(child: Text(item.iconEmoji, style: const TextStyle(fontSize: 34))),
                  ),
                  if (item.requiresPro)
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: Text('👑', style: TextStyle(fontSize: 18)),
                    ),
                  if (item.category == StoreItemCategory.avatarFrame)
                    Positioned(
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.visibility,
                                color: Colors.white, size: 10),
                            const SizedBox(width: 3),
                            Text(
                                _t(context, 'Gör', 'View', 'Ansehen', 'Ver'),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing || equipped ? null : () => _handleTap(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: equipped
                      ? Colors.green.shade500
                      : owned
                          ? const Color(0xFF6C3CE0)
                          : (canAfford ? color : Colors.grey.shade300),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  equipped
                      ? _t(context, '✓ Takılı', '✓ On', '✓ An', '✓ Puesto')
                      : owned
                          ? _t(context, 'Tak', 'Use it', 'Anlegen', 'Ponerlo')
                          : (item.isFree
                              ? _t(context, 'Ücretsiz', 'Free', 'Gratis',
                                  'Gratis')
                              : '${item.priceJeton} 🪙'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ekrandaki kısa arayüz yazıları için dört dilli yardımcı.
///
/// Bu ekran tamamen Türkçe sabit yazılarla yazılmıştı; İngilizce,
/// Almanca ya da İspanyolca seçen çocuk uygulamanın geri kalanı
/// çevrilmişken burada Türkçe görüyordu.
String _t(BuildContext context, String tr, String en, String de, String es) =>
    AppLang.pick(
      Provider.of<SettingsProvider>(context).locale.languageCode,
      tr: tr,
      en: en,
      de: de,
      es: es,
    );
