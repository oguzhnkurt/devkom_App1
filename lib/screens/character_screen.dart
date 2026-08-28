import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/store_item_model.dart';
import '../providers/auth_provider.dart';
import '../services/store_service.dart';
import '../widgets/character_stage.dart';
import 'market_screen.dart';

/// Karakterim Ekranı - "Rozet/Başarı" yerine gelen, karakter odaklı vitrin.
///
/// Ana ekrandaki eski "Rozet" karosundan ulaşılır (artık ölü bir "yakında"
/// snackbar'ı değil, bu ekrana yönlendirir). Her kullanıcıya (satın alma
/// yapmamış olsa bile) canlı animasyonlu bir varsayılan karakter gösterir;
/// derslerden/oyunlardan kazanılan jetonla Market'ten kolye ve şapka satın
/// alıp bu karaktere giydirebilir. Pro üyeler jeton kazanımında bonus alır
/// (bkz. UserProgressService.addJeton).
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
  StoreItemCategory _selectedTab = StoreItemCategory.character;

  static const _customizableCategories = [
    StoreItemCategory.character,
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
        _equipped = equipped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _equip(StoreItem item) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final ok = await _storeService.equipItem(item.id);
    if (ok && mounted) {
      setState(() => _equipped[item.category] = item);
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  void _goToMarket() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketScreen()))
        .then((_) => _load());
  }

  void _openCloseUp() {
    final character = _equipped[StoreItemCategory.character];
    final hat = _equipped[StoreItemCategory.hat];
    final necklace = _equipped[StoreItemCategory.necklace];
    final glasses = _equipped[StoreItemCategory.glasses];
    final shoes = _equipped[StoreItemCategory.shoes];
    final accent = character != null ? CharacterStage.parseColorHex(character.colorHex) : const Color(0xFF7C4DFF);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CharacterStage(
                character: character,
                hat: hat,
                necklace: necklace,
                glasses: glasses,
                shoes: shoes,
                size: 300,
                accentColor: accent,
                interactive: false,
              ),
              const SizedBox(height: 16),
              Text(
                character?.name ?? 'Varsayılan Karakter',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Kapatmak için dokun',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jetonBalance = Provider.of<AuthProvider>(context).userProgress?.jetonBalance ?? 0;
    final character = _equipped[StoreItemCategory.character];
    final hat = _equipped[StoreItemCategory.hat];
    final necklace = _equipped[StoreItemCategory.necklace];
    final glasses = _equipped[StoreItemCategory.glasses];
    final shoes = _equipped[StoreItemCategory.shoes];
    final accent = character != null ? CharacterStage.parseColorHex(character.colorHex) : const Color(0xFF7C4DFF);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1F),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 340,
                    backgroundColor: const Color(0xFF6C3CE0),
                    foregroundColor: Colors.white,
                    title: const Text('Karakterim'),
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
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildStageHeader(character, hat, necklace, glasses, shoes, accent),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHintBanner(),
                          const SizedBox(height: 24),
                          _buildTabBar(),
                          const SizedBox(height: 16),
                          _buildCategorySection(_selectedTab),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _goToMarket,
                            icon: const Text('🛍️'),
                            label: const Text('Market\'te Daha Fazla Ürün'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: const Color(0xFF6C3CE0),
                              side: const BorderSide(color: Color(0xFF6C3CE0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStageHeader(
    StoreItem? character,
    StoreItem? hat,
    StoreItem? necklace,
    StoreItem? glasses,
    StoreItem? shoes,
    Color accent,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.9), const Color(0xFF1A1030)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative floating stars
          ...List.generate(10, (i) {
            final dx = (i * 37) % 320.0;
            final dy = 30.0 + (i * 53) % 180.0;
            return Positioned(
              left: dx,
              top: dy,
              child: Opacity(
                opacity: 0.25,
                child: Text(['✨', '⭐', '💫'][i % 3], style: const TextStyle(fontSize: 14)),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onLongPress: _openCloseUp,
                  child: CharacterStage(
                    character: character,
                    hat: hat,
                    necklace: necklace,
                    glasses: glasses,
                    shoes: shoes,
                    size: 170,
                    accentColor: accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  character?.name ?? 'Varsayılan Karakter',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _openCloseUp,
                  icon: const Icon(Icons.zoom_in, color: Colors.white70, size: 16),
                  label: const Text('Yakından Bak', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF6C3CE0).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6C3CE0).withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Text('🎁', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ders ve oyunlardan kazandığın jetonla kolye, şapka ve yeni karakterler aç, ona kendine has bir stil kat!',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF4A3C6E), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    // 5 kategori (Karakter/Şapka/Gözlük/Kolye/Ayakkabı) dar ekranlarda
    // sıkışabileceği için yatay kaydırılabilir çip listesi kullanılıyor
    // (Market'teki kategori sekmeleriyle aynı desen).
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _customizableCategories.map((category) {
          final selected = category == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = category),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF6C3CE0) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? const Color(0xFF6C3CE0) : Colors.grey.shade300),
              ),
              child: Text(
                storeCategoryDisplayName(category),
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
    );
  }

  Widget _buildCategorySection(StoreItemCategory category) {
    final ownedInCategory =
        _catalog.where((i) => i.category == category && (_ownedItemIds.contains(i.id) || i.isFree)).toList();
    final equippedId = _equipped[category]?.id;

    if (ownedInCategory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            const Text('🔒', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              'Henüz bu kategoride bir ürünün yok.\nMarket\'ten satın alabilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
            ),
          ],
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
        childAspectRatio: 0.85,
      ),
      itemCount: ownedInCategory.length,
      itemBuilder: (context, index) {
        final item = ownedInCategory[index];
        final isEquipped = item.id == equippedId;
        final color = CharacterStage.parseColorHex(item.colorHex);
        return GestureDetector(
          onTap: _isProcessing || isEquipped ? null : () => _equip(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isEquipped ? color : Colors.grey.shade200, width: isEquipped ? 2 : 1),
              boxShadow: isEquipped
                  ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.iconEmoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                if (isEquipped)
                  const Icon(Icons.check_circle, color: Colors.green, size: 16)
                else
                  Text('Kuşan', style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
              ],
            ),
          ),
        );
      },
    );
  }
}
