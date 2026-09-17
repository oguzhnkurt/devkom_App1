-- TEK MASKOT: giyilebilir urunler katalogdan kaldirildi, jetonlar iade edildi.
--
-- NEDEN
-- -----
-- Maskot artik Dart'ta cizilmiyor; satin alinmis bir 3B render (Devi).
-- Render'a sapka giydirilemez: eski sistemde sapka/gozluk/kolye/ayakkabi
-- cizimin geometrisindeki capalara oturuyordu. Karakter secimi ve
-- giydirme ekrani kaldirildi.
--
-- Bunun bedelini COCUK ODEMEMELI: jetonunu sapkaya harcamis bir cocuk,
-- artik goremeyecegi bir seyin parasini odemis olurdu. Bu gecis once
-- IADE ediyor, sonra siliyor.
--
-- Idempotent: iki kez calistirilsa bile ikinci kez iade yapmaz, cunku
-- iade edilen satirlar ayni islemde siliniyor ve urunler pasifleniyor.

begin;

-- Kaldirilan kategoriler. avatar_frame KALIYOR: profil cercevesi
-- maskottan bagimsiz, giyilebilir bir sey degil.
create temporary table _kaldirilan_urunler on commit drop as
select id, price_jeton
from store_items
where category in ('hat', 'glasses', 'necklace', 'shoes', 'robot_skin', 'character');

-- 1) IADE. Her kullaniciya, sahip oldugu kaldirilan urunlerin
--    ODEDIGI fiyat kadar jeton geri veriliyor. Bedava urunler (0)
--    toplama katkida bulunmaz.
with iade as (
  select i.user_id, sum(u.price_jeton)::int as tutar
  from user_inventory i
  join _kaldirilan_urunler u on u.id = i.item_id
  group by i.user_id
)
update user_progress p
set jeton_balance = coalesce(p.jeton_balance, 0) + iade.tutar,
    updated_at = now()
from iade
where p.user_id = iade.user_id
  and iade.tutar > 0;

-- 2) Envanterden sil. Iade yapildi; satirin kalmasi, uygulamada
--    gosterilemeyen bir urunu "sahipsin" diye tasimak olurdu.
delete from user_inventory
where item_id in (select id from _kaldirilan_urunler);

-- 3) Katalogdan cikar. Satir SILINMIYOR: eski siparis/olay kayitlari
--    bu kimliklere bakabiliyor. Yalnizca pasifleniyor, istemci zaten
--    is_active = true olanlari cekiyor.
update store_items
set is_active = false
where id in (select id from _kaldirilan_urunler);

commit;
