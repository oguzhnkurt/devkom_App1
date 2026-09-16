-- 29_learner_profile.sql
--
-- Onboarding artik bir urun turu degil: cocuga yas araligini, deneyim
-- seviyesini ve hedefini soruyoruz, kisisel ogrenme yolu bu uc cevaptan
-- uretiliyor (bkz. lib/services/learning_path_service.dart).
--
-- Bilerek EKLENMEYENLER: dogum tarihi ve cinsiyet. Uygulama 4+ derecelendirmeli
-- bir cocuk uygulamasi; gereksiz kisisel veri hem App Privacy beyanini
-- degistirir hem de KVKK/GDPR acisindan yuk getirir. Yas, tarih olarak degil
-- kaba bir kova olarak tutuluyor.
do $$
begin
  if not exists (select 1 from pg_type where typname = 'learner_age_band') then
    create type learner_age_band as enum ('age_4_6', 'age_7_9', 'age_10_12', 'age_13_plus');
  end if;
  if not exists (select 1 from pg_type where typname = 'learner_skill_level') then
    create type learner_skill_level as enum ('beginner', 'some_blocks', 'some_code');
  end if;
  if not exists (select 1 from pg_type where typname = 'learner_goal') then
    create type learner_goal as enum ('games', 'robotics', 'websites', 'ai', 'explore');
  end if;
end $$;

alter table public.users
  add column if not exists age_band learner_age_band,
  add column if not exists skill_level learner_skill_level,
  add column if not exists learning_goal learner_goal,
  add column if not exists onboarding_completed_at timestamptz;

comment on column public.users.age_band is
  'Kaba yas kovasi. Ders zorlugunu ve dilini ayarlamak icin; dogum tarihi tutmuyoruz.';
comment on column public.users.skill_level is
  'Onboarding''de sorulan deneyim seviyesi. Ogrenme yolunun baslangic noktasini belirler.';
comment on column public.users.learning_goal is
  'Cocugun ne yapmak istedigi. Yolun sirasini belirler (oyun/robotik/web/yapay zeka).';

-- Eski age_group alani bozuk: kovalari (6-9/10-14/15-18) uygulamadaki AgeGroup
-- enum ile (4-6/7-9/10-12/13+) ortusmuyor, yazarken 4-6 ile 7-9 ayni degere
-- cokuyor ve okurken _parseAgeGroup bu degeri tanimadigi icin hep null donuyor.
-- Odev filtreleme oradan tasinana kadar duruyor.
comment on column public.users.age_group is
  'ESKI ALAN - kullanmayin, yeni kod age_band kullaniyor.';
