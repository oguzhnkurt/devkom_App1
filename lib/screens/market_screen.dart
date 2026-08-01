import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/store_item_model.dart';
import '../providers/auth_provider.dart';
import '../services/store_service.dart';
import 'subscription_screen.dart';

/// Market ekranı: dersler ve oyunlarla kazanılan jetonlarla robot kılıfı,
/// avatar çerçevesi ve karakter satın alıp kuşanma (equip) ekranı.
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
  StoreItemCategory _selectedCategory = StoreItemCategory.robotSkin;

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
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _ownedItemIds = inventory.map((o) => o.item.id).toSet();
        _equippedItemIds = inventory.where((o) => o.equipped).map((o) => o.item.id).toSet();
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
      if (ok && mounted) {
        setState(() {
          _equippedItemIds
            ..removeWhere((id) => _catalog.firstWhere((i) => i.id == id).category == item.category)
            ..add(item.id);
        });
        _showSnack('${item.name} kuşanıldı! ${item.iconEmoji}');
      } else {
        _showSnack('Kuşanma başarısız oldu.', isError: true);
      }
    } else {
      final result = await _storeService.purchaseItem(item.id);
      if (result['success'] == true) {
        await Provider.of<AuthProvider>(context, listen: false).refreshProgress();
        if (mounted) {
          setState(() => _ownedItemIds.add(item.id));
        }
        _showSnack('${item.name} satın alındı! ${item.iconEmoji}');
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
        _showSnack('Yetersiz jeton! ${item.priceJeton} 🪙 gerekiyor.', isError: true);
        break;
      case 'already_owned':
        _showSnack('Bu ürüne zaten sahipsin.', isError: true);
        break;
      default:
        _showSnack('Satın alma başarısız oldu.', isError: true);
    }
  }

  void _showProRequiredDialog(StoreItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pro Üyelik Gerekli'),
        content: Text('${item.name} sadece Pro üyelere özel. Pro\'ya geçerek bu ürünü ve daha fazlasını açabilirsin!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
            },
            child: const Text('Pro\'ya Geç'),
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
        title: const Text('🛍️ Market'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
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
                _buildCategoryTabs(),
                Expanded(child: _buildGrid()),
              ],
            ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = StoreItemCategory.values;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: categories.map((c) {
          final selected = c == _selectedCategory;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = c),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(vertical: 10),
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
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrid() {
    final items = _catalog.where((i) => i.category == _selectedCategory).toList();
    if (items.isEmpty) {
      return const Center(child: Text('Bu kategoride henüz ürün yok.'));
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: item.requiresPro
                        ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 14, spreadRadius: 2)]
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
              ],
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
                      ? '✓ Kuşanıldı'
                      : owned
                          ? 'Kuşan'
                          : (item.isFree ? 'Ücretsiz' : '${item.priceJeton} 🪙'),
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
