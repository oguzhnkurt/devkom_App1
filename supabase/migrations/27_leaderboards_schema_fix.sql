-- 27_leaderboards_schema_fix.sql
--
-- SORUN: leaderboards tablosu agregat yapidaydi
--   (game_name, total_score, best_score, games_played, average_score, rank)
-- ama uygulama kodu (lib/models/leaderboard_model.dart -> toSupabaseMap /
-- fromSupabase) per-oyun kayit bekliyordu
--   (game_type, score, time_seconds, correct_count, total_questions,
--    difficulty, completed_at, user_photo_url, metadata).
--
-- SONUC: her skor insert'i hata veriyordu (var olmayan kolonlar + game_name
-- NOT NULL), her siralama sorgusu da 'game_type' kolonu bulunamadigi icin
-- hata verip catch blogunda bos liste donuyordu. Yani Quiz, Modul Quizi,
-- Satranc, Bug Hunter, Pattern Detective, Variable Master, Word Match,
-- Block Coding ve Coordinates oyunlarinin skorlari hic kaydedilmiyordu;
-- skor tablolari da her zaman bos gorunuyordu.
--
-- Bu migration uygulandiginda tablo 0 satir iceriyordu, veri kaybi yok.
-- Eski agregat kolonlar kaldirilmadi (kodda kullanilmiyorlar, ileride
-- ozet/rapor icin degerlendirilebilirler).

alter table public.leaderboards
  add column if not exists game_type       text,
  add column if not exists score           integer not null default 0,
  add column if not exists time_seconds    integer,
  add column if not exists correct_count   integer,
  add column if not exists total_questions integer,
  add column if not exists difficulty      integer,
  add column if not exists completed_at    timestamptz not null default now(),
  add column if not exists user_photo_url  text,
  add column if not exists metadata        jsonb;

-- Kod bu alani hic gondermiyor; NOT NULL kisiti insert'i engelliyordu.
alter table public.leaderboards alter column game_name drop not null;

-- Sorgu desenleri: game_type filtresi + skor siralamasi, kullanici bazli sorgu.
create index if not exists leaderboards_game_type_score_idx
  on public.leaderboards (game_type, score desc);

create index if not exists leaderboards_user_game_idx
  on public.leaderboards (user_id, game_type);

create index if not exists leaderboards_completed_at_idx
  on public.leaderboards (completed_at desc);
