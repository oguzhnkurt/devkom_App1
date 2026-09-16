import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/lang.dart';
import '../providers/settings_provider.dart';
import '../models/store_item_model.dart';
import '../providers/auth_provider.dart';
import '../services/store_service.dart';
import '../widgets/character_stage.dart';
import '../widgets/mascot.dart';

/// Karakterim ekranı.
///
/// Herkes ücretsiz muz karakteriyle (katalogdaki `fruit_muz`) başlar; ekran
/// açıldığında kuşanılmış bir karakter yoksa muz sessizce edinilip kuşanılır.
/// Diğer karakterler hemen altında listelenir ve **buradan satın alınabilir** —
/// eskiden bunun için Market'e gitmek gerekiyordu.
///
/// Not: `equip_store_item` RPC'si envanter kaydı istiyor, bu yüzden ücretsiz
/// ürünler de bir kez `purchase_store_item` üzerinden geçmek zorunda (fiyat 0
/// olduğu için bakiyeye dokunmuyor).
class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  final StoreService _storeService = StoreService();

  bool _isLoading = true;
  bool _isProcessing = false;
  List<StoreItem> _catalog = [];
  Set<String> _ownedItemIds = {};
  Map<StoreItemCategory, StoreItem> _equipped = {};
  StoreItemCategory _accessoryTab = StoreItemCategory.hat;

  static const _accessoryCategories = [
    StoreItemCategory.hat,
    StoreItemCategory.glasses,
    StoreItemCategory.necklace,
    StoreItemCategory.shoes,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------------------------------------------------------------- veri

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final catalog = await _storeService.getCatalog();
      final inventory = await _storeService.getInventory();
      var equipped = await _storeService.getAllEquipped();

      if (!mounted) return;
      _catalog = catalog;
      _ownedItemIds = inventory.map((o) => o.item.id).toSet();
      _equipped = equipped;

      // Karakter kuşanılmamışsa varsayılan (ücretsiz muz) devreye girsin.
      if (_equipped[StoreItemCategory.character] == null) {
        final ok = await _ensureDefaultCharacter();
        if (ok && mounted) {
          equipped = await _storeService.getAllEquipped();
          final inv = await _storeService.getInventory();
          _equipped = equipped;
          _ownedItemIds = inv.map((o) => o.item.id).toSet();
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  /// Katalogdaki ücretsiz karakteri edinip kuşanır. Giriş yapmamış kullanıcıda
  /// sessizce başarısız olur; ekran yine de muzu gösterir (bkz. [_displayCharacter]).
  Future<bool> _ensureDefaultCharacter() async {
    final free = _freeCharacter;
    if (free == null) return false;
    if (!_ownedItemIds.contains(free.id)) {
      final result = await _storeService.purchaseItem(free.id);
      if (result['success'] != true && result['error'] != 'already_owned') return false;
    }
    return _storeService.equipItem(free.id);
  }

  /// Katalogdaki ücretsiz karakter (muz).
  StoreItem? get _freeCharacter {
    for (final item in _catalog) {
      if (item.category == StoreItemCategory.character && item.isFree) return item;
    }
    return null;
  }

  /// Sahnede gösterilecek karakter: kuşanılan, yoksa ücretsiz muz.
  StoreItem? get _displayCharacter =>
      _equipped[StoreItemCategory.character] ?? _freeCharacter;

  List<StoreItem> _itemsOf(StoreItemCategory category) {
    final items = _catalog.where((i) => i.category == category).toList();
    // Ücretsiz olan (varsayılan) en başta, sonra fiyata göre artan.
    items.sort((a, b) {
      if (a.isFree != b.isFree) return a.isFree ? -1 : 1;
      return a.priceJeton.compareTo(b.priceJeton);
    });
    return items;
  }

  // -------------------------------------------------------------- işlemler

  Future<void> _equip(StoreItem item) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final ok = await _storeService.equipItem(item.id);
    if (!mounted) return;
    setState(() {
      if (ok) _equipped[item.category] = item;
      _isProcessing = false;
    });
    if (!ok) _toast('Kuşanılamadı, tekrar dener misin?');
  }

  Future<void> _purchase(StoreItem item) async {
    if (_isProcessing) return;
    final confirmed = await _confirmPurchase(item);
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    final result = await _storeService.purchaseItem(item.id);
    if (!mounted) return;

    if (result['success'] == true) {
      _ownedItemIds.add(item.id);
      await _storeService.equipItem(item.id);
      if (!mounted) return;
      setState(() {
        _equipped[item.category] = item;
        _isProcessing = false;
      });
      // Jeton bakiyesi başlıkta AuthProvider'dan okunuyor, tazelenmeli.
      await context.read<AuthProvider>().refreshUser();
      if (mounted) _toast('${item.name} senin oldu!');
    } else {
      setState(() => _isProcessing = false);
      _toast(_purchaseErrorText(result['error'], item));
    }
  }

  String _purchaseErrorText(dynamic error, StoreItem item) {
    switch (error) {
      case 'insufficient_balance':
        return 'Yeterli jetonun yok. ${item.name} için ${item.priceJeton} jeton gerekiyor.';
      case 'requires_pro':
        return '${item.name} sadece Pro üyeler için.';
      case 'already_owned':
        return 'Bu ürün zaten sende.';
      case 'not_authenticated':
        return 'Satın almak için giriş yapman gerekiyor.';
      default:
        return 'Satın alma tamamlanamadı, tekrar dener misin?';
    }
  }

  Future<bool?> _confirmPurchase(StoreItem item) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(item.iconEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(child: Text(item.name, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Text(
          item.description?.isNotEmpty == true
              ? '${item.description}\n\n${item.priceJeton} jeton karşılığında alınacak.'
              : '${item.priceJeton} jeton karşılığında alınacak.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_t(context, 'Vazgeç', 'Cancel', 'Abbrechen', 'Cancelar')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C3CE0)),
            child: Text('${item.priceJeton} 🪙 ile al'),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  // ------------------------------------------------------------------ UI

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jetonBalance = authProvider.userProgress?.jetonBalance ?? 0;
    final isPro = authProvider.currentUser?.isPro ?? false;

    final character = _displayCharacter;
    final accent = character != null
        ? CharacterStage.parseColorHex(character.colorHex)
        : const Color(0xFFF6D444);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(character, accent, jetonBalance),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                              _t(context, 'Arkadaşın', 'Your buddy', 'Dein Kumpel',
                                  'Tu amigo'),
                              _t(context, 'Beşinden birini seç — hepsi ücretsiz',
                                  'Pick one of the five — all free',
                                  'Wähle eine von fünf — alle kostenlos',
                                  'Elige uno de los cinco: todos gratis')),
                          const SizedBox(height: 14),
                          const MascotPicker(),
                          const SizedBox(height: 32),
                          _buildSectionTitle(
                              _t(context, 'Karakterler', 'Characters', 'Figuren',
                                  'Personajes'),
                              _t(context, 'Beğendiğini seç, jetonla yenisini aç',
                                  'Pick a favourite, unlock more with coins',
                                  'Wähle eine Lieblingsfigur, schalte mit Münzen weitere frei',
                                  'Elige tu favorito y desbloquea más con monedas')),
                          const SizedBox(height: 14),
                          _buildItemGrid(_itemsOf(StoreItemCategory.character), isPro, jetonBalance),
                          const SizedBox(height: 32),
                          _buildSectionTitle(
                              _t(context, 'Aksesuarlar', 'Accessories', 'Zubehör',
                                  'Accesorios'),
                              _t(context, 'Karakterine stil kat', 'Give your buddy some style',
                                  'Gib deinem Kumpel Stil', 'Dale estilo a tu amigo')),
                          const SizedBox(height: 14),
                          _buildAccessoryTabs(),
                          const SizedBox(height: 14),
                          _buildItemGrid(_itemsOf(_accessoryTab), isPro, jetonBalance),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar(StoreItem? character, Color accent, int jetonBalance) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 320,
      backgroundColor: accent,
      foregroundColor: Colors.white,
      title: Text(_t(context, 'Karakterim', 'My character', 'Meine Figur',
          'Mi personaje')),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '$jetonBalance',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent,
                Color.lerp(accent, Colors.black, 0.45) ?? accent,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                CharacterStage(
                  species: context.watch<SettingsProvider>().mascot,
                  character: character,
                  hat: _equipped[StoreItemCategory.hat],
                  necklace: _equipped[StoreItemCategory.necklace],
                  glasses: _equipped[StoreItemCategory.glasses],
                  shoes: _equipped[StoreItemCategory.shoes],
                  size: 160,
                  accentColor: accent,
                ),
                const SizedBox(height: 10),
                Text(
                  Mascot.nameOf(context.watch<SettingsProvider>().mascot),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _t(context, 'Dokun, seninle oynasın', 'Tap to play with it',
                      'Tippe, damit es mitspielt', 'Toca para que juegue'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F1D36),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAccessoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _accessoryCategories.map((category) {
          final selected = category == _accessoryTab;
          return GestureDetector(
            onTap: () => setState(() => _accessoryTab = category),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF6C3CE0) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? const Color(0xFF6C3CE0) : Colors.grey.shade300,
                ),
              ),
              child: Text(
                storeCategoryDisplayName(category),
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
    );
  }

  Widget _buildItemGrid(List<StoreItem> items, bool isPro, int jetonBalance) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          'Bu kategoride henüz ürün yok.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _buildItemCard(items[index], isPro, jetonBalance),
    );
  }

  Widget _buildItemCard(StoreItem item, bool isPro, int jetonBalance) {
    final owned = _ownedItemIds.contains(item.id);
    final equipped = _equipped[item.category]?.id == item.id;
    final proLocked = item.requiresPro && !isPro;
    final color = CharacterStage.parseColorHex(item.colorHex);

    VoidCallback? onTap;
    if (!_isProcessing && !equipped) {
      if (owned) {
        onTap = () => _equip(item);
      } else if (proLocked) {
        onTap = () => _toast('${item.name} sadece Pro üyeler için.');
      } else {
        onTap = () => _purchase(item);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: equipped ? color : Colors.grey.shade200,
            width: equipped ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: equipped
                  ? color.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: equipped ? 14 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: proLocked && !owned ? 0.08 : 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: proLocked && !owned ? 0.45 : 1,
                      child: Text(item.iconEmoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                ),
                if (proLocked && !owned)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Text('👑', style: TextStyle(fontSize: 14)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            _buildStatePill(
              item: item,
              owned: owned,
              equipped: equipped,
              proLocked: proLocked,
              jetonBalance: jetonBalance,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatePill({
    required StoreItem item,
    required bool owned,
    required bool equipped,
    required bool proLocked,
    required int jetonBalance,
    required Color color,
  }) {
    late final String label;
    late final Color background;
    late final Color foreground;

    if (equipped) {
      label = 'Seçili';
      background = color.withValues(alpha: 0.16);
      foreground = Color.lerp(color, Colors.black, 0.35) ?? color;
    } else if (owned) {
      label = 'Seç';
      background = const Color(0xFF6C3CE0).withValues(alpha: 0.10);
      foreground = const Color(0xFF6C3CE0);
    } else if (proLocked) {
      label = 'Pro';
      background = const Color(0xFFFFD700).withValues(alpha: 0.22);
      foreground = const Color(0xFF8D6E00);
    } else {
      final affordable = jetonBalance >= item.priceJeton;
      label = '${item.priceJeton} 🪙';
      background = affordable
          ? const Color(0xFF2E7D32).withValues(alpha: 0.10)
          : Colors.grey.withValues(alpha: 0.14);
      foreground = affordable ? const Color(0xFF2E7D32) : Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
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


/// Beş maskottan birini seçtiren şerit.
///
/// Karakter mağazadaki ÜRÜNLERDEN ayrı: ürünler maskotun rengini ve
/// göğüs simgesini değiştiriyor, buradaki seçim ise maskotun KENDİSİNİ
/// değiştiriyor. İkisi karışmasın diye ayrı bir bölümde duruyor.
class MascotPicker extends StatelessWidget {
  const MascotPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final selected = settings.mascot;
    final lang = settings.locale.languageCode;

    return SizedBox(
      height: 152,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MascotSpecies.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final species = MascotSpecies.values[i];
          final spec = specOf(species);
          final isSelected = species == selected;
          return Semantics(
            selected: isSelected,
            button: true,
            label: '${spec.name} — ${spec.taglineFor(lang)}',
            child: GestureDetector(
              onTap: () => context.read<SettingsProvider>().setMascot(species),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 104,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? spec.defaultColor.withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? spec.defaultColor
                        : const Color(0xFFE3E8F0),
                    width: isSelected ? 2.5 : 1.4,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sabit yükseklikte kutu: ölçek düzeltmesi yüzünden
                    // figürler farklı yer kaplıyor, adlar aynı hizada
                    // kalsın diye tabana yaslanıyorlar.
                    SizedBox(
                      height: 86,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Mascot(
                          species: species,
                          // Her karakter tuvalini farklı dolduruyor;
                          // şeritte hepsi aynı büyüklükte görünsün.
                          size: 70 * spec.previewScale,
                          showShadow: false,
                          mood:
                              isSelected ? MascotMood.happy : MascotMood.idle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(spec.name,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w800)),
                    Text(
                      spec.taglineFor(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
