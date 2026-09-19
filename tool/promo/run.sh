#!/usr/bin/env bash
# Tanitim videosunu uretir: TR/EN x 9:16/1:1, dort MP4.
#
# Depo kokunden calistirin:   tool/promo/run.sh
#
# Gereken hazirlik icin tool/promo/README.md'ye bakin.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STAGE="$ROOT/outputs/promo/stage"
MODEL="$ROOT/outputs/promo/models/pro1.glb"
OUT="$ROOT/outputs/promo"
PORT="${PORT:-8777}"

[ -f "$MODEL" ] || { echo "HATA: $MODEL yok. README'ye bakin."; exit 1; }
[ -d "$ROOT/outputs/appstore/ekranlar" ] || {
  echo "HATA: outputs/appstore/ekranlar yok."
  echo "Once: flutter test --run-skipped --tags shots test/appstore_shots_test.dart"
  exit 1; }

# --- sahne klasorunu kur ------------------------------------------------
rm -rf "$STAGE"
mkdir -p "$STAGE"/{models,fonts,shots/tr,shots/en,games/tr,games/en,lib}
cp "$ROOT/tool/promo/render.html" "$STAGE/"
cp "$MODEL" "$STAGE/models/pro1.glb"
cp "$ROOT/assets/fonts/Nunito-"*.ttf "$STAGE/fonts/"
cp "$ROOT/assets/images/app_icon.png" "$STAGE/"

# Telefon maketine giren ekranlar (widget testinden).
for f in 09_home 02_lesson 04_blocks 14_html_code 08_path; do
  cp "$ROOT/outputs/appstore/ekranlar_tr/$f.png" "$STAGE/shots/tr/"
  cp "$ROOT/outputs/appstore/ekranlar/$f.png"    "$STAGE/shots/en/"
done

# Cercevesiz gosterilen oyun ekranlari. "gN" adi render.html'deki GAMES
# dizisiyle ayni olmali. Once outputs/promo/oyun/ altindaki gercek cihaz
# kaydina bakilir (durum cubugu oldugu icin cercevesizde daha dogal
# duruyor), yoksa widget testinin ciktisi kullanilir.
oyun() {  # oyun <hedef_ad> <ekranlar_dosya_adi>
  local dst="$1" src="$2" L D
  for L in tr en; do
    D="$ROOT/outputs/appstore/ekranlar"; [ "$L" = tr ] && D="${D}_tr"
    if [ -f "$ROOT/outputs/promo/oyun/$L/$dst.png" ]; then
      cp "$ROOT/outputs/promo/oyun/$L/$dst.png" "$STAGE/games/$L/$dst.png"
    elif [ -f "$D/$src.png" ]; then
      cp "$D/$src.png" "$STAGE/games/$L/$dst.png"
    else
      echo "UYARI: $L/$dst icin gorsel yok ($D/$src.png) - atlaniyor."
    fi
  done
}
oyun g1_chess       12_chess
oyun g2_millionaire 21_millionaire
oyun g3_word_match  11_word_match
oyun g4_matching    07_matching

NODE_MODULES="$(cd "$ROOT/tool/promo" && npm root)"
cp -r "$NODE_MODULES/three" "$STAGE/lib/three"

# --- ses tasarimi (sifirdan sentez, telifsiz) ---------------------------
python3 "$ROOT/tool/promo/sfx.py" tr "$STAGE/sfx_tr.wav"
python3 "$ROOT/tool/promo/sfx.py" en "$STAGE/sfx_en.wav"

# --- yerel sunucu -------------------------------------------------------
( cd "$STAGE" && python3 -m http.server "$PORT" >/dev/null 2>&1 & echo $! > "$STAGE/.httpd" )
trap 'kill "$(cat "$STAGE/.httpd")" 2>/dev/null || true' EXIT
sleep 1

# --- render + kodlama ---------------------------------------------------
export STAGE PORT
mkdir -p "$OUT"
for job in "tr 916" "en 916" "tr 11" "en 11"; do
  set -- $job; L=$1; F=$2
  echo "=== $L $F  $(date +%T) ==="
  node "$ROOT/tool/promo/shoot.js" "$L" "$F"
  ffmpeg -v error -y -framerate 30 -i "$STAGE/frames/${L}_${F}/%04d.jpg" \
    -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -movflags +faststart \
    "$STAGE/sessiz_${L}_${F}.mp4"
  ffmpeg -v error -y -i "$STAGE/sessiz_${L}_${F}.mp4" -i "$STAGE/sfx_${L}.wav" \
    -c:v copy -c:a aac -b:a 192k -shortest "$OUT/deveducation_${L}_${F}.mp4"
  echo "--> $OUT/deveducation_${L}_${F}.mp4"
done
echo "bitti $(date +%T)"
