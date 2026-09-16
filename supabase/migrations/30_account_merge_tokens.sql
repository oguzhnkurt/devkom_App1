-- 30_account_merge_tokens.sql
--
-- Anonim hesaptan kalici hesaba (Apple ile giris) ilerleme tasima.
-- Bu dosya, Supabase'e uygulanan migration'in birebir kopyasidir.
--
-- Sorun: cocuk uygulamayi acar acmaz anonim bir oturumla basliyor; XP, jeton,
-- rozet ve satin aldigi esyalar o kullaniciya yaziliyor. "Apple ile giris"
-- dedigi anda Supabase yeni bir kullanici acabiliyor ve onlem alinmazsa tum
-- ilerleme eski satirda kaliyor.
--
-- Neden token: giristen sonra istemci artik eski kullanici degil; "su
-- kullanicinin ilerlemesini bana aktar" demesinin hicbir ispati yok. Boyle bir
-- RPC'ye herkes baskasinin id'sini gonderip ilerlemesini calabilirdi. Bu
-- yuzden anahtar HENUZ anonim kullaniciyken uretiliyor (o an auth.uid()
-- gercekten o kullanici) ve giristen sonra yalnizca o istemcinin bildigi gizli
-- anahtar ibraz ediliyor.
create table if not exists public.account_merge_tokens (
  token uuid primary key default gen_random_uuid(),
  from_user uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.account_merge_tokens enable row level security;
-- Bilerek hicbir policy yok: tabloya yalnizca asagidaki SECURITY DEFINER
-- fonksiyonlar uzerinden dokunuluyor.

create index if not exists account_merge_tokens_from_user_idx
  on public.account_merge_tokens (from_user);

create or replace function public.create_account_merge_token()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_token uuid;
begin
  if v_user is null then
    raise exception 'oturum yok';
  end if;
  delete from public.account_merge_tokens where from_user = v_user;
  insert into public.account_merge_tokens (from_user)
  values (v_user) returning token into v_token;
  return v_token;
end;
$$;

create or replace function public.claim_account_merge_token(p_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_target uuid := auth.uid();
  v_from uuid;
  v_created timestamptz;
  v_moved_xp integer := 0;
  v_moved_jeton integer := 0;
begin
  if v_target is null then
    return jsonb_build_object('ok', false, 'reason', 'no_session');
  end if;

  select from_user, created_at into v_from, v_created
  from public.account_merge_tokens where token = p_token;

  if v_from is null then
    return jsonb_build_object('ok', false, 'reason', 'unknown_token');
  end if;

  if v_created < now() - interval '30 minutes' then
    delete from public.account_merge_tokens where token = p_token;
    return jsonb_build_object('ok', false, 'reason', 'expired');
  end if;

  if v_from = v_target then
    delete from public.account_merge_tokens where token = p_token;
    return jsonb_build_object('ok', true, 'reason', 'same_user', 'moved', false);
  end if;

  -- Kaynak gercekten anonim olmali; aksi halde bu mekanizma "kayitli bir
  -- hesabin ilerlemesini baska hesaba tasima" araci olurdu.
  if not exists (
    select 1 from auth.users
    where id = v_from and coalesce(is_anonymous, false) = true
  ) then
    delete from public.account_merge_tokens where token = p_token;
    return jsonb_build_object('ok', false, 'reason', 'source_not_anonymous');
  end if;

  insert into public.user_progress (user_id) values (v_target)
  on conflict (user_id) do nothing;

  update public.user_progress t
  set total_xp = greatest(coalesce(t.total_xp,0), coalesce(s.total_xp,0)),
      level = greatest(coalesce(t.level,1), coalesce(s.level,1)),
      streak_days = greatest(coalesce(t.streak_days,0), coalesce(s.streak_days,0)),
      longest_streak = greatest(coalesce(t.longest_streak,0), coalesce(s.longest_streak,0)),
      jeton_balance = coalesce(t.jeton_balance,0) + coalesce(s.jeton_balance,0),
      total_quizzes_completed = greatest(
        coalesce(t.total_quizzes_completed,0), coalesce(s.total_quizzes_completed,0)),
      completed_lesson_ids = (
        select coalesce(array_agg(distinct x), '{}')
        from unnest(coalesce(t.completed_lesson_ids,'{}') ||
                    coalesce(s.completed_lesson_ids,'{}')) x),
      earned_badge_ids = (
        select coalesce(array_agg(distinct x), '{}')
        from unnest(coalesce(t.earned_badge_ids,'{}') ||
                    coalesce(s.earned_badge_ids,'{}')) x),
      updated_at = now()
  from public.user_progress s
  where t.user_id = v_target and s.user_id = v_from
  returning t.total_xp, t.jeton_balance into v_moved_xp, v_moved_jeton;

  delete from public.user_progress where user_id = v_from;

  -- ON CONFLICT DO NOTHING hedefsiz: hangi essiz kisit olursa olsun cakisan
  -- satir atlaniyor, hedef hesabin verisi ezilmiyor.
  insert into public.user_inventory (user_id, item_id, equipped, purchased_at)
  select v_target, item_id, equipped, purchased_at
  from public.user_inventory where user_id = v_from on conflict do nothing;
  delete from public.user_inventory where user_id = v_from;

  insert into public.user_quests (user_id, quest_id, progress, completed, completed_at, rewarded, note)
  select v_target, quest_id, progress, completed, completed_at, rewarded, note
  from public.user_quests where user_id = v_from on conflict do nothing;
  delete from public.user_quests where user_id = v_from;

  insert into public.user_video_progress (user_id, episode_id, completed, completed_at)
  select v_target, episode_id, completed, completed_at
  from public.user_video_progress where user_id = v_from on conflict do nothing;
  delete from public.user_video_progress where user_id = v_from;

  insert into public.game_progress (user_id, game_id, score, completed, time_spent_minutes, played_at, progress_data)
  select v_target, game_id, score, completed, time_spent_minutes, played_at, progress_data
  from public.game_progress where user_id = v_from on conflict do nothing;
  delete from public.game_progress where user_id = v_from;

  insert into public.achievements (user_id, badge_id, badge_name, badge_description, badge_icon_url, current_progress, required_progress, is_completed, completed_at)
  select v_target, badge_id, badge_name, badge_description, badge_icon_url, current_progress, required_progress, is_completed, completed_at
  from public.achievements where user_id = v_from on conflict do nothing;
  delete from public.achievements where user_id = v_from;

  insert into public.user_daily_activity (user_id, day, xp, lessons, quizzes, videos)
  select v_target, day, xp, lessons, quizzes, videos
  from public.user_daily_activity where user_id = v_from on conflict do nothing;
  delete from public.user_daily_activity where user_id = v_from;

  delete from public.users where id = v_from;
  delete from public.account_merge_tokens where token = p_token;

  return jsonb_build_object('ok', true, 'moved', true,
    'total_xp', coalesce(v_moved_xp,0), 'jeton_balance', coalesce(v_moved_jeton,0));
end;
$$;

revoke all on function public.create_account_merge_token() from public;
revoke all on function public.claim_account_merge_token(uuid) from public;
grant execute on function public.create_account_merge_token() to authenticated;
grant execute on function public.claim_account_merge_token(uuid) to authenticated;
