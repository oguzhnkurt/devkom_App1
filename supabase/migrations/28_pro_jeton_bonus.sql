-- 28_pro_jeton_bonus.sql
--
-- Pro uyelere jeton veriyoruz: satin alinca bir kerelik "hos geldin" paketi
-- (1000 jeton), sonrasinda Pro kaldigi surece her takvim ayinda 300 jeton.
--
-- Neden ayri tablo ve SECURITY DEFINER: istemci "bana jeton ver" cagrisini
-- tekrar tekrar yapabilir. Ayni (user_id, period) icin unique kisit koyduk,
-- yazma yetkisini yalnizca fonksiyona verdik; boylece ayni donem icin ikinci
-- kez jeton verilemiyor.
create table if not exists public.pro_jeton_grants (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  -- 'welcome' ya da 'YYYY-MM'
  period text not null,
  amount integer not null,
  granted_at timestamptz not null default now(),
  unique (user_id, period)
);

alter table public.pro_jeton_grants enable row level security;

-- Kullanici yalnizca kendi kayitlarini gorebilir. Insert/update/delete icin
-- policy YOK: yazma islemi sadece asagidaki fonksiyon uzerinden yapiliyor.
drop policy if exists "pro_jeton_grants_select_own" on public.pro_jeton_grants;
create policy "pro_jeton_grants_select_own"
  on public.pro_jeton_grants for select
  using (auth.uid() = user_id);

create index if not exists pro_jeton_grants_user_idx
  on public.pro_jeton_grants (user_id);

create or replace function public.claim_pro_jeton()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_is_pro boolean;
  v_period text := to_char(now() at time zone 'utc', 'YYYY-MM');
  v_welcome integer := 1000;
  v_monthly integer := 300;
  v_granted integer := 0;
  v_gave_welcome boolean := false;
  v_gave_monthly boolean := false;
  v_balance integer := 0;
begin
  if v_user_id is null then
    return jsonb_build_object('granted', 0, 'reason', 'no_session');
  end if;

  select coalesce(is_pro, false) into v_is_pro
  from public.users where id = v_user_id;

  if not coalesce(v_is_pro, false) then
    return jsonb_build_object('granted', 0, 'reason', 'not_pro');
  end if;

  -- Bir kerelik hos geldin paketi
  insert into public.pro_jeton_grants (user_id, period, amount)
  values (v_user_id, 'welcome', v_welcome)
  on conflict (user_id, period) do nothing;
  if found then
    v_granted := v_granted + v_welcome;
    v_gave_welcome := true;
  end if;

  -- Icinde bulunulan ayin jetonu. Hos geldin paketini aldigi ay ikisini
  -- birden vermiyoruz; o ay 0 tutarli bir isaret satiri yaziliyor.
  if not v_gave_welcome then
    insert into public.pro_jeton_grants (user_id, period, amount)
    values (v_user_id, v_period, v_monthly)
    on conflict (user_id, period) do nothing;
    if found then
      v_granted := v_granted + v_monthly;
      v_gave_monthly := true;
    end if;
  else
    insert into public.pro_jeton_grants (user_id, period, amount)
    values (v_user_id, v_period, 0)
    on conflict (user_id, period) do nothing;
  end if;

  if v_granted > 0 then
    insert into public.user_progress (user_id, jeton_balance)
    values (v_user_id, v_granted)
    on conflict (user_id) do update
      set jeton_balance = public.user_progress.jeton_balance + v_granted,
          updated_at = now();
  end if;

  select coalesce(jeton_balance, 0) into v_balance
  from public.user_progress where user_id = v_user_id;

  return jsonb_build_object(
    'granted', v_granted,
    'welcome', v_gave_welcome,
    'monthly', v_gave_monthly,
    'balance', coalesce(v_balance, 0)
  );
end;
$$;

revoke all on function public.claim_pro_jeton() from public;
grant execute on function public.claim_pro_jeton() to authenticated;
