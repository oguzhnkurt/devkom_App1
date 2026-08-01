/// Market (Store) modelleri.
/// Bkz. supabase/migrations/23_store_and_jeton_economy.sql

enum StoreItemCategory { robotSkin, avatarFrame, character }

StoreItemCategory _parseCategory(String value) {
  switch (value) {
    case 'avatar_frame':
      return StoreItemCategory.avatarFrame;
    case 'character':
      return StoreItemCategory.character;
    default:
      return StoreItemCategory.robotSkin;
  }
}

String storeCategoryDisplayName(StoreItemCategory category) {
  switch (category) {
    case StoreItemCategory.robotSkin:
      return 'Robot Kılıfları';
    case StoreItemCategory.avatarFrame:
      return 'Avatar Çerçeveleri';
    case StoreItemCategory.character:
      return 'Karakterler';
  }
}

/// Mağaza kataloğundaki tek bir ürün (store_items tablosu).
class StoreItem {
  final String id;
  final String itemKey;
  final StoreItemCategory category;
  final String name;
  final String? description;
  final int priceJeton;
  final String iconEmoji;
  final String colorHex;
  final bool requiresPro;
  final int sortOrder;

  StoreItem({
    required this.id,
    required this.itemKey,
    required this.category,
    required this.name,
    this.description,
    required this.priceJeton,
    required this.iconEmoji,
    required this.colorHex,
    this.requiresPro = false,
    this.sortOrder = 0,
  });

  bool get isFree => priceJeton == 0;

  factory StoreItem.fromMap(Map<String, dynamic> map) {
    return StoreItem(
      id: map['id'],
      itemKey: map['item_key'],
      category: _parseCategory(map['category']),
      name: map['name'] ?? '',
      description: map['description'],
      priceJeton: map['price_jeton'] ?? 0,
      iconEmoji: map['icon_emoji'] ?? '🤖',
      colorHex: map['color_hex'] ?? '#4F8EF7',
      requiresPro: map['requires_pro'] ?? false,
      sortOrder: map['sort_order'] ?? 0,
    );
  }
}

/// Bir kullanıcının satın aldığı ürün (user_inventory tablosu),
/// StoreItem ile birleştirilmiş haliyle.
class OwnedStoreItem {
  final String inventoryId;
  final StoreItem item;
  final bool equipped;
  final DateTime purchasedAt;

  OwnedStoreItem({
    required this.inventoryId,
    required this.item,
    required this.equipped,
    required this.purchasedAt,
  });

  factory OwnedStoreItem.fromMap(Map<String, dynamic> map) {
    return OwnedStoreItem(
      inventoryId: map['id'],
      item: StoreItem.fromMap(map['store_items']),
      equipped: map['equipped'] ?? false,
      purchasedAt: DateTime.parse(map['purchased_at']),
    );
  }
}
