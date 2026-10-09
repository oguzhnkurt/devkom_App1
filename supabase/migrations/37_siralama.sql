-- 37. Sıralama: iki kulvar (genel XP ve satranç)
--
-- NEDEN (9 Ekim 2026)
-- -------------------
-- Eski yarışma tablosu oyun oyun skor listesiydi ve yalnızca
-- `leaderboards` tablosunu okuyordu. İstenen iki kulvar:
--
--   1. GENEL: toplam XP sıralaması. Her satırda çocuğun marketten alıp
--      TAKTIĞI çerçeve, rozet ve etiket görünüyor.
--   2. SATRANÇ: en zor seviyeyi en hızlı yenen üstte. Önce İmkânsız'ı
--      yenenler (süreye göre), sonra Zor'u yenenler, sonra Orta, Kolay.
--
-- Üretimde `user_progress`, `users` ve `user_inventory` yalnızca sahibine
-- açık (RLS). Bunu genişletmek yerine iki SECURITY DEFINER fonksiyon
-- yazıldı; dışarıya YALNIZCA sıralama için gereken alanlar çıkıyor:
--
--   * ad: yalnızca ilk ad + soyadın baş harfi ("Ayşe K."), e-posta yok,
--     kullanıcı kimliği yok
--   * XP / seviye ya da satranç seviyesi + süre
--   * takılı çerçeve / rozet / etiket (market ürünü, kişisel veri değil)
--   * ben: satır çağıranın kendisi mi
--
-- Çağıran ilk N'de değilse KENDİ satırı da (gerçek sırasıyla) ekleniyor:
-- "Sıralamadaki yerini gör" için.
--
-- SATRANÇ ZORLUK İNDEKSİ: 0 Kolay, 1 Orta, 2 Zor, 3 İmkânsız
-- (lib/models/chess_game_model.dart, `ChessDifficulty.index`).
-- `leaderboards`'a satranç kaydı yalnızca KAZANINCA yazılıyor.
--
-- Tekrar çalıştırmak zararsız (create or replace).

begin;

-- "Ayşe Kaya" -> "Ayşe K.", "ayse" -> "ayse", boş -> null
create or replace function public._siralama_adi(t text)
returns text
language sql
immutable
as $$
  select case
    when coalesce(btrim(t), '') = '' then null
    when split_part(btrim(t), ' ', 2) = '' then split_part(btrim(t), ' ', 1)
    else split_part(btrim(t), ' ', 1) || ' '
         || upper(left(split_part(btrim(t), ' ', 2), 1)) || '.'
  end
$$;

-- Bir kullanıcının o kategoride TAKILI ürünü (store_items satırı, jsonb)
create or replace function public._siralama_takili(p_user uuid, p_kategori text)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select to_jsonb(si)
  from user_inventory ui
  join store_items si on si.id = ui.item_id
  where ui.user_id = p_user
    and ui.equipped
    and si.category = p_kategori
  order by ui.purchased_at desc
  limit 1
$$;

create or replace function public.siralama_genel(p_limit int default 50)
returns table (
  sira bigint,
  ad text,
  xp int,
  seviye int,
  cerceve jsonb,
  rozet jsonb,
  etiket jsonb,
  ben boolean
)
language sql
stable
security definer
set search_path = public
as $$
  with puan as (
    select up.user_id, up.total_xp, up.level,
           row_number() over (order by up.total_xp desc, up.created_at asc) as sira
    from user_progress up
    where up.total_xp > 0
  ),
  secili as (
    select * from puan where sira <= greatest(1, least(coalesce(p_limit, 50), 100))
    union
    select * from puan where user_id = auth.uid()
  )
  select s.sira,
         coalesce(_siralama_adi(u.display_name), 'DevEducation'),
         s.total_xp,
         s.level,
         _siralama_takili(s.user_id, 'avatar_frame'),
         _siralama_takili(s.user_id, 'name_badge'),
         _siralama_takili(s.user_id, 'profile_tag'),
         s.user_id = auth.uid()
  from secili s
  left join users u on u.id = s.user_id
  order by s.sira
$$;

create or replace function public.siralama_satranc(p_limit int default 50)
returns table (
  sira bigint,
  ad text,
  zorluk int,
  sure int,
  cerceve jsonb,
  rozet jsonb,
  etiket jsonb,
  ben boolean
)
language sql
stable
security definer
set search_path = public
as $$
  with en_iyi as (
    -- Her çocuğun TEK en iyi galibiyeti: en zor seviye, o seviyede en kısa süre.
    select distinct on (l.user_id)
           l.user_id, l.difficulty, l.time_seconds, l.completed_at
    from leaderboards l
    where l.game_type = 'chess'
      and l.user_id is not null
      and l.difficulty is not null
      and l.time_seconds >= 5          -- 5 sn altı bir satranç galibiyeti gerçek değil
    order by l.user_id, l.difficulty desc, l.time_seconds asc, l.completed_at asc
  ),
  sirali as (
    select e.*,
           row_number() over (order by e.difficulty desc, e.time_seconds asc,
                                       e.completed_at asc) as sira
    from en_iyi e
  ),
  secili as (
    select * from sirali where sira <= greatest(1, least(coalesce(p_limit, 50), 100))
    union
    select * from sirali where user_id = auth.uid()
  )
  select s.sira,
         coalesce(_siralama_adi(u.display_name), 'DevEducation'),
         s.difficulty,
         s.time_seconds,
         _siralama_takili(s.user_id, 'avatar_frame'),
         _siralama_takili(s.user_id, 'name_badge'),
         _siralama_takili(s.user_id, 'profile_tag'),
         s.user_id = auth.uid()
  from secili s
  left join users u on u.id = s.user_id
  order by s.sira
$$;

-- Yalnızca oturum açmış kullanıcılar (uygulama anonim oturumla da açıyor)
revoke all on function public._siralama_takili(uuid, text) from public, anon, authenticated;
revoke all on function public.siralama_genel(int) from public, anon;
revoke all on function public.siralama_satranc(int) from public, anon;
grant execute on function public.siralama_genel(int) to authenticated;
grant execute on function public.siralama_satranc(int) to authenticated;

commit;
