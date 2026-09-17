import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store_item_model.dart';

/// Market (Store) servisi: katalog okuma, satın alma ve kuşanma (equip).
/// Satın alma/kuşanma işlemleri atomik olması için Postgres RPC
/// fonksiyonları (purchase_store_item / equip_store_item) üzerinden yapılır
/// — bakiye kontrolü ve düşme aynı transaction'da gerçekleşir, yarış
/// koşulu (race condition) oluşmaz. Bkz.
/// supabase/migrations/23_store_and_jeton_economy.sql
class StoreService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Aktif mağaza kataloğunu kategoriye göre sıralı getirir.
  Future<List<StoreItem>> getCatalog() async {
    final data = await _supabase
        .from('store_items')
        .select()
        .eq('is_active', true)
        .order('category')
        .order('sort_order');
    // Giyilebilir urunler katalogdan cikti (tek maskot, render). Sunucu
    // tarafinda da pasiflestirildi ama istemci eski bir veritabanina
    // baglanirsa yine gostermesin.
    return (data as List)
        .map((m) => StoreItem.fromMap(m))
        .where((i) => !kaldirilanKategoriler.contains(i.category))
        .toList();
  }

  /// Kullanıcının sahip olduğu ürünleri (StoreItem ile birleşik) getirir.
  Future<List<OwnedStoreItem>> getInventory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await _supabase
        .from('user_inventory')
        .select('id, equipped, purchased_at, store_items(*)')
        .eq('user_id', userId);
    return (data as List).map((m) => OwnedStoreItem.fromMap(m)).toList();
  }

  /// Bir ürünü satın alır. Dönüş: {'success': bool, 'error': String?,
  /// 'newBalance': int?}. Hata kodları: not_authenticated, item_not_found,
  /// already_owned, requires_pro, insufficient_balance, no_progress_record.
  Future<Map<String, dynamic>> purchaseItem(String itemId) async {
    try {
      final result = await _supabase.rpc('purchase_store_item', params: {'p_item_id': itemId});
      final map = Map<String, dynamic>.from(result as Map);
      return {
        'success': map['success'] == true,
        'error': map['error'],
        'newBalance': map['new_balance'],
        'balance': map['balance'],
        'price': map['price'],
      };
    } catch (e) {
      debugPrint('❌ Satın alma hatası: $e');
      return {'success': false, 'error': 'unknown'};
    }
  }

  /// Sahip olunan bir ürünü kuşanır (aynı kategorideki diğerini otomatik çıkarır).
  Future<bool> equipItem(String itemId) async {
    try {
      final result = await _supabase.rpc('equip_store_item', params: {'p_item_id': itemId});
      final map = Map<String, dynamic>.from(result as Map);
      return map['success'] == true;
    } catch (e) {
      debugPrint('❌ Kuşanma hatası: $e');
      return false;
    }
  }

  /// Kullanıcının belirli bir kategoride kuşandığı ürünü getirir (yoksa null
  /// — arayan taraf varsayılan/klasik görünüme düşer).
  Future<StoreItem?> getEquippedItem(StoreItemCategory category) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await _supabase
        .from('user_inventory')
        .select('store_items!inner(*)')
        .eq('user_id', userId)
        .eq('equipped', true)
        .eq('store_items.category', storeCategoryKey(category))
        .maybeSingle();
    if (data == null) return null;
    return StoreItem.fromMap(data['store_items']);
  }

  /// Tüm kategorilerde kuşanılan ürünleri tek sorguda getirir (ör. Karakterim
  /// ekranındaki kompozit önizleme için). Kuşanılmamış kategoriler map'te yer
  /// almaz.
  Future<Map<StoreItemCategory, StoreItem>> getAllEquipped() async {
    final inventory = await getInventory();
    final equipped = <StoreItemCategory, StoreItem>{};
    for (final owned in inventory.where((o) => o.equipped)) {
      equipped[owned.item.category] = owned.item;
    }
    return equipped;
  }

  /// Kullanıcının güncel jeton bakiyesi.
  Future<int> getJetonBalance() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;
    final data = await _supabase
        .from('user_progress')
        .select('jeton_balance')
        .eq('user_id', userId)
        .maybeSingle();
    return data?['jeton_balance'] ?? 0;
  }
}
