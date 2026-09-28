import '../data/store_catalog_locale.dart';
import '../utils/lang.dart';

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

/// Market sekmelerinde görünen kategori adı, kullanıcının dilinde.
///
/// Önce yalnızca Türkçe dönüyordu: İngilizce seçmiş bir çocuk, dili
/// İngilizce olan bir ekranın ortasında "Avatar Çerçeveleri" sekmesini
/// görüyordu.
String storeCategoryDisplayName(StoreItemCategory category, String lang) {
  switch (category) {
    case StoreItemCategory.profileBanner:
      return AppLang.pick(lang,
          tr: 'Profil Afişleri',
          en: 'Profile Banners',
          de: 'Profilbanner',
          es: 'Carteles de perfil');
    case StoreItemCategory.nameBadge:
      return AppLang.pick(lang,
          tr: 'İsim Rozetleri',
          en: 'Name Badges',
          de: 'Namensabzeichen',
          es: 'Insignias de nombre');
    case StoreItemCategory.robotSkin:
      return AppLang.pick(lang,
          tr: 'Robot Kılıfları',
          en: 'Robot Skins',
          de: 'Roboter-Skins',
          es: 'Aspectos de robot');
    case StoreItemCategory.avatarFrame:
      return AppLang.pick(lang,
          tr: 'Avatar Çerçeveleri',
          en: 'Avatar Frames',
          de: 'Avatar-Rahmen',
          es: 'Marcos de avatar');
    case StoreItemCategory.character:
      return AppLang.pick(lang,
          tr: 'Karakterler',
          en: 'Characters',
          de: 'Figuren',
          es: 'Personajes');
    case StoreItemCategory.necklace:
      return AppLang.pick(lang,
          tr: 'Kolyeler', en: 'Necklaces', de: 'Halsketten', es: 'Collares');
    case StoreItemCategory.hat:
      return AppLang.pick(lang,
          tr: 'Şapkalar', en: 'Hats', de: 'Hüte', es: 'Sombreros');
    case StoreItemCategory.glasses:
      return AppLang.pick(lang,
          tr: 'Gözlükler', en: 'Glasses', de: 'Brillen', es: 'Gafas');
    case StoreItemCategory.shoes:
      return AppLang.pick(lang,
          tr: 'Ayakkabılar', en: 'Shoes', de: 'Schuhe', es: 'Zapatos');
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

  /// Ürünün kullanıcının dilindeki adı.
  ///
  /// `name` sütunu veritabanında tek ve Türkçe. Çeviriler kodda
  /// (`kStoreUrunMetinleri`) tutuluyor; sebebi o dosyada anlatılıyor.
  /// Kodun bilmediği bir ürün gelirse veritabanındaki ada düşüyor —
  /// ekranda boşluk görünmesindense yanlış dilde bir kelime yeğ.
  String adFor(String lang) =>
      kStoreUrunMetinleri[itemKey]?.ad(lang) ?? name;

  /// Ürünün kullanıcının dilindeki açıklaması. Yoksa boş metin.
  String aciklamaFor(String lang) =>
      kStoreUrunMetinleri[itemKey]?.aciklama(lang) ?? (description ?? '');

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
