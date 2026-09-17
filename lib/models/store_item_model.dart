/// Market (Store) modelleri.
/// Bkz. supabase/migrations/23_store_and_jeton_economy.sql
///
/// GIYILEBILIR KATEGORILER KALDIRILDI
/// -----------------------------------
/// Maskot artik Dart'ta cizilmiyor, satin alinmis bir 3B render. Render'a
/// sapka giydirilemez: capalar (eski MascotAnchors) cizimin geometrisine
/// bagliydi. Bu yuzden sapka/gozluk/kolye/ayakkabi, robot kilifi ve
/// karakter urunleri katalogdan kalkti ve satin alanlara jetonlari
/// iade edildi — bkz. supabase/migrations/32_tek_maskot_ve_jeton_iadesi.sql
///
/// `kaldirilanKategoriler` yalnizca ESKI kayitlari okuyabilmek icin
/// duruyor: bir kullanicinin envanterinde eski bir satir kalirsa
/// uygulama cokmemeli.
enum StoreItemCategory {
  robotSkin,
  avatarFrame,
  character,
  necklace,
  hat,
  glasses,
  shoes,

  /// Profil başlığındaki renkli alan. Çocuk her profil açtığında görüyor.
  profileBanner,

  /// Sıralamada adının yanında görünen küçük rozet.
  nameBadge,
}

/// Artik satilmayan, giyilemeyen kategoriler.
const Set<StoreItemCategory> kaldirilanKategoriler = {
  StoreItemCategory.robotSkin,
  StoreItemCategory.character,
  StoreItemCategory.necklace,
  StoreItemCategory.hat,
  StoreItemCategory.glasses,
  StoreItemCategory.shoes,
};

/// Markette gorunen kategoriler.
List<StoreItemCategory> get satilanKategoriler => StoreItemCategory.values
    .where((c) => !kaldirilanKategoriler.contains(c))
    .toList();

StoreItemCategory _parseCategory(String value) {
  switch (value) {
    case 'avatar_frame':
      return StoreItemCategory.avatarFrame;
    case 'profile_banner':
      return StoreItemCategory.profileBanner;
    case 'name_badge':
      return StoreItemCategory.nameBadge;
    case 'character':
      return StoreItemCategory.character;
    case 'necklace':
      return StoreItemCategory.necklace;
    case 'hat':
      return StoreItemCategory.hat;
    case 'glasses':
      return StoreItemCategory.glasses;
    case 'shoes':
      return StoreItemCategory.shoes;
    default:
      return StoreItemCategory.robotSkin;
  }
}

String storeCategoryDisplayName(StoreItemCategory category) {
  switch (category) {
    case StoreItemCategory.profileBanner:
      return 'Profil Afişleri';
    case StoreItemCategory.nameBadge:
      return 'İsim Rozetleri';
    case StoreItemCategory.robotSkin:
      return 'Robot Kılıfları';
    case StoreItemCategory.avatarFrame:
      return 'Avatar Çerçeveleri';
    case StoreItemCategory.character:
      return 'Karakterler';
    case StoreItemCategory.necklace:
      return 'Kolyeler';
    case StoreItemCategory.hat:
      return 'Şapkalar';
    case StoreItemCategory.glasses:
      return 'Gözlükler';
    case StoreItemCategory.shoes:
      return 'Ayakkabılar';
  }
}

/// Supabase'deki store_items.category TEXT sütun değeri.
String storeCategoryKey(StoreItemCategory category) {
  switch (category) {
    case StoreItemCategory.profileBanner:
      return 'profile_banner';
    case StoreItemCategory.nameBadge:
      return 'name_badge';
    case StoreItemCategory.robotSkin:
      return 'robot_skin';
    case StoreItemCategory.avatarFrame:
      return 'avatar_frame';
    case StoreItemCategory.character:
      return 'character';
    case StoreItemCategory.necklace:
      return 'necklace';
    case StoreItemCategory.hat:
      return 'hat';
    case StoreItemCategory.glasses:
      return 'glasses';
    case StoreItemCategory.shoes:
      return 'shoes';
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
