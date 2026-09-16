-- 32_child_link.sql
--
-- VELI TAKIBI — eslestirme kodu ve baglanti.
--
-- BU DOSYA GECMISI KAYDEDIYOR, YENI BIR SEY KURMUYOR.
--
-- Sema Supabase panelinden ELLE uygulanmisti ve repoda karsiligi yoktu.
-- Ben "migration dosyasi yok, demek ki veritabani da yok" diye cikarim
-- yapip yeniden kurdum; hepsinin esdegeri zaten baska adla vardi ve
-- ortaya yedi tane kopya policy cikti. Kopyalar geri alindi. Bu dosya
-- artik uretimde GERCEKTEN duran seyi, onun kendi policy adlariyla
-- yaziyor; bastan sona calistirilirsa hicbir sey degismez.
--
-- Ders: semanin repoda olmamasi, veritabaninda olmadigi anlamina
-- gelmiyor. Once veritabanina sorulacak.
--
-- TASARIM
--
-- * Kimse "veli misin" diye BEYAN ETMIYOR. Ebeveyn, cocugun cihazindan
--   aldigi alti karakterlik kodu giriyor. Kodu gormek icin telefona
--   fiziksel erisim gerekiyor; bu beyandan daha guclu bir ispat.
-- * Kod 24 saat gecerli ve TEK KULLANIMLIK.
-- * Kod tablosunu istemci BASKASI ICIN OKUYAMIYOR; okuyabilseydi alti
--   karakterlik kodlar tek tek denenerek baska cocuklarin hesabina
--   baglanilabilirdi. Bag yalnizca SECURITY DEFINER olan
--   redeem_child_code uzerinden kuruluyor.
-- * Bag TEK YONLU: ebeveyn OKUR, yazmaz.
-- * Cocuk kac kisinin izledigini gorur ve bagi kendisi koparabilir.

-- ---------------------------------------------------------------- kodlar

create table if not exists public.child_link_codes (
  code text primary key,
  child_id uuid not null unique references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '24 hours'
);

-- child_id UNIQUE: ayni anda tek kod. Istemci de once var olani ariyor,
-- boylece ebeveyn kodu okurken cocuk ekrani yenilediginde kod degismiyor.

alter table public.child_link_codes enable row level security;

-- Uretimdeki ad: "child manages own code" (ALL, child_id = auth.uid()).

-- ------------------------------------------------------------------ bag

create table if not exists public.child_links (
  parent_id uuid not null references auth.users(id) on delete cascade,
  child_id  uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (parent_id, child_id)
);

alter table public.child_links enable row level security;

-- Uretimdeki adlar:
--   "link visible to both sides"  (SELECT, parent_id = uid or child_id = uid)
--   "either side can unlink"      (DELETE, parent_id = uid or child_id = uid)
--
-- INSERT policy'si BILEREK YOK: bag yalnizca redeem_child_code ile kurulur.

-- -------------------------------------------------------------- kullanim

create or replace function public.redeem_child_code(p_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_parent uuid := auth.uid();
  v_child  uuid;
begin
  if v_parent is null then
    raise exception 'oturum yok';
  end if;

  select child_id into v_child
  from public.child_link_codes
  where code = upper(p_code)
    and expires_at > now();

  if v_child is null then
    return null;
  end if;

  -- Kendine baglanmak anlamsiz; cocugun kendi kodunu girip "takipci"
  -- gostermesini de engelliyor.
  if v_child = v_parent then
    return null;
  end if;

  insert into public.child_links (parent_id, child_id)
  values (v_parent, v_child)
  on conflict do nothing;

  -- Tek kullanimlik.
  delete from public.child_link_codes where code = upper(p_code);

  return v_child;
end;
$$;

revoke all on function public.redeem_child_code(text) from public;
grant execute on function public.redeem_child_code(text) to authenticated, anon;

create or replace function public.is_linked_parent(p_child uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.child_links
    where parent_id = auth.uid() and child_id = p_child
  );
$$;

revoke all on function public.is_linked_parent(uuid) from public;
grant execute on function public.is_linked_parent(uuid) to authenticated, anon;

-- ------------------------------------------------- ebeveynin OKUMA hakki
--
-- Bag kurmak tek basina yetmiyor: rapor ekrani cocugun satirlarini
-- okuyor ve bu tablolarin RLS'i "yalnizca kendi satirin" diyor. Asagidaki
-- policy'ler uretimde SU ADLARLA duruyor ve hepsi yalnizca SELECT:
--
--   users                 "linked parent reads child user"  is_linked_parent(id)
--   user_daily_activity   "linked parent reads activity"    is_linked_parent(user_id)
--   user_video_progress   "linked parent reads videos"      is_linked_parent(user_id)
--   user_quests           "linked parent reads quests"      is_linked_parent(user_id)
--
-- Hicbirinde INSERT/UPDATE/DELETE yok: bag tek yonlu.
