#!/usr/bin/env bash
# "App Promo" surumu: koyu lacivert, 2B telefon maketleri.
# TR/EN x 16:9 ve 9:16, dort MP4.
#
# Depo kokunden:  tool/promo2/run.sh
# Hazirlik icin tool/promo2/README.md.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STAGE="$ROOT/outputs/promo2/stage"
MAKET="$ROOT/outputs/promo2/maket"
OUT="$ROOT/outputs/promo2"
PORT="${PORT:-8788}"

for n in 1 2 3 4 5; do
  [ -f "$MAKET/Phone Mockup $n.png" ] && [ -f "$MAKET/Phone Mockup Placeholder $n.png" ] || {
    echo "HATA: $MAKET/Phone Mockup $n.png (ve Placeholder) yok. README'ye bakin."; exit 1; }
done
[ -d "$ROOT/outputs/appstore/ekranlar" ] || {
  echo "HATA: outputs/appstore/ekranlar yok."
  echo "Once: flutter test --run-skipped --tags shots test/appstore_shots_test.dart"
  exit 1; }

# --- sahne klasoru ------------------------------------------------------
rm -rf "$STAGE"
mkdir -p "$STAGE"/{fonts,shots/tr,shots/en,games/tr,games/en,phones}
cp "$ROOT/tool/promo2/render.html" "$STAGE/"
cp "$ROOT/assets/fonts/Nunito-"*.ttf "$STAGE/fonts/"
cp "$ROOT/assets/images/app_icon.png" "$STAGE/"

for f in 09_home 02_lesson 04_blocks 14_html_code 08_path; do
  cp "$ROOT/outputs/appstore/ekranlar_tr/$f.png" "$STAGE/shots/tr/"
  cp "$ROOT/outputs/appstore/ekranlar/$f.png"    "$STAGE/shots/en/"
done

oyun() {  # oyun <hedef_ad> <ekranlar_dosya_adi>
  local dst="$1" src="$2" L D
  for L in tr en; do
    D="$ROOT/outputs/appstore/ekranlar"; [ "$L" = tr ] && D="${D}_tr"
    [ -f "$D/$src.png" ] && cp "$D/$src.png" "$STAGE/games/$L/$dst.png" \
      || echo "UYARI: $L/$dst icin gorsel yok ($D/$src.png)"
  done
}
oyun g1_chess       12_chess
oyun g2_millionaire 21_millionaire
oyun g3_word_match  11_word_match
oyun g4_matching    07_matching
oyun g5_bug_hunter  15_bug_hunter
oyun g6_coordinates 20_coordinates
oyun g7_robot       24_robot
oyun g8_arduino     25_arduino_blocks

# --- telefon karelerini onceden uret ------------------------------------
echo "=== maketlere ekranlar oturtuluyor ==="
ROOT="$ROOT" STAGE="$STAGE" MAKET="$MAKET" python3 "$ROOT/tool/promo2/uret.py"

# --- ses ----------------------------------------------------------------
python3 "$ROOT/tool/promo2/sfx.py" tr "$STAGE/sfx_tr.wav"
python3 "$ROOT/tool/promo2/sfx.py" en "$STAGE/sfx_en.wav"

# --- yerel sunucu -------------------------------------------------------
( cd "$STAGE" && python3 -m http.server "$PORT" >/dev/null 2>&1 & echo $! > "$STAGE/.httpd" )
trap 'kill "$(cat "$STAGE/.httpd")" 2>/dev/null || true' EXIT
sleep 1

# --- render + kodlama ---------------------------------------------------
export STAGE PORT
mkdir -p "$OUT"
for job in "tr 169" "en 169" "tr 916" "en 916"; do
  set -- $job; L=$1; F=$2
  echo "=== $L $F  $(date +%T) ==="
  node "$ROOT/tool/promo2/shoot.js" "$L" "$F"
  ffmpeg -v error -y -framerate 30 -i "$STAGE/frames/${L}_${F}/%04d.jpg" \
    -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -movflags +faststart \
    "$STAGE/sessiz_${L}_${F}.mp4"
  ffmpeg -v error -y -i "$STAGE/sessiz_${L}_${F}.mp4" -i "$STAGE/sfx_${L}.wav" \
    -c:v copy -c:a aac -b:a 192k -shortest "$OUT/deveducation_promo_${L}_${F}.mp4"
  echo "--> $OUT/deveducation_promo_${L}_${F}.mp4"
done
echo "bitti $(date +%T)"
