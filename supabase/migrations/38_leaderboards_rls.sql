-- 38. leaderboards: herkes yalnızca KENDİ kaydını yazabilir (9 Ekim 2026)
--
-- Üretimde "System can update leaderboards" politikası FOR ALL USING (true)
-- idi: oturum açmış herkes başkasının satırını değiştirebiliyor ya da
-- silebiliyordu. Satranç sıralaması (37) görünür olunca bu bir açığa
-- dönüştü.
--
-- Yeni kurallar:
--   * okuma: herkese açık (değişmedi — "Users can view leaderboards")
--   * ekleme / güncelleme / silme: yalnızca user_id = auth.uid()
--
-- Uygulama yalnızca kendi kaydını ekliyor (LeaderboardServiceSupabase
-- .addEntry). game_results üzerindeki update_leaderboard tetikleyicisi
-- de çağıranın kendi user_id'siyle yazdığı için kendi-satır kuralına uyuyor.

begin;

drop policy if exists "System can update leaderboards" on public.leaderboards;

drop policy if exists "leaderboards kendi kaydini ekler" on public.leaderboards;
create policy "leaderboards kendi kaydini ekler" on public.leaderboards
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "leaderboards kendi kaydini gunceller" on public.leaderboards;
create policy "leaderboards kendi kaydini gunceller" on public.leaderboards
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "leaderboards kendi kaydini siler" on public.leaderboards;
create policy "leaderboards kendi kaydini siler" on public.leaderboards
  for delete to authenticated
  using (auth.uid() = user_id);

commit;
