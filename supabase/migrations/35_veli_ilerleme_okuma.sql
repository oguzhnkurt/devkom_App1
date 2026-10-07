-- 35_veli_ilerleme_okuma.sql
--
-- VELI TAKIBI — bagli velinin cocugun `user_progress` satirini OKUMASI.
--
-- NEDEN: 32_child_link.sql uretimdeki dort okuma politikasini belgeliyor
-- (users, user_daily_activity, user_video_progress, user_quests). Velinin
-- raporundaki ders, XP, seviye ve kurs ilerlemesi ise `user_progress`'ten
-- geliyor ve orada bir okuma politikasi BELGELENMEMIS. Politika yoksa
-- RLS satiri gizliyor ve veli raporunda bu bolumler bos kaliyor
-- (uygulama o durumda "kurs ilerlemesi su an alinamadi" diyor).
--
-- URETIM KONTROLU (7 Ekim 2026, SQL Editor, salt okuma):
--   user_progress uzerinde "linked parent reads progress" (SELECT,
--   is_linked_parent(user_id)) ZATEN VAR. Bu dosya uretimde calistirilmadi;
--   calistirilsa da asagidaki kontrol yuzunden hicbir sey degismez.
--   Ayrica: log_daily_activity gunu `current_date` ile yaziyor ve
--   veritabani saat dilimi UTC. Turkiye saatiyle 00:00-03:00 arasi
--   calisma bir onceki gune yaziliyor (bilinen, kucuk etki).
--
-- Ders (32'den): repoda olmamasi veritabaninda olmadigi anlamina gelmiyor.
-- Bu yuzden once KONTROL, sonra gerekirse kurulum:
--
--   1) Supabase → SQL Editor'de once bunu calistirin:
--
--      select policyname, cmd, qual
--      from pg_policies
--      where schemaname = 'public' and tablename = 'user_progress';
--
--      Sonucta `is_linked_parent(user_id)` iceren bir SELECT politikasi
--      zaten varsa BU DOSYAYI CALISTIRMAYIN; hicbir sey gerekmez.
--
--   2) Yoksa asagidaki blogu calistirin. Blok kendisi de ayni kontrolu
--      yapiyor: is_linked_parent kullanan bir SELECT politikasi varsa
--      hicbir sey eklemiyor, yani iki kez calistirmak zarar vermez.
--
-- Yalnizca SELECT. Veli cocugun satirina YAZAMAZ (bag tek yonlu).

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'user_progress'
      and cmd in ('SELECT', 'ALL')
      and qual ilike '%is_linked_parent%'
  ) then
    execute $p$
      create policy "linked parent reads progress"
        on public.user_progress
        for select
        using (public.is_linked_parent(user_id))
    $p$;
  end if;
end
$$;
