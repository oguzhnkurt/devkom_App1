#!/bin/bash
# DevEducation — App Store ekran goruntusu yardimcisi
#
# Calistir:  bash ekran_goruntusu_al.sh
#
# Bu script bir sey yapmadan bekler. Claude, uygulamayi simulatorde dogru
# ekrana getirdiginde shots/ klasorune bir "trigger" dosyasi birakir; script
# bunu gorunce simulatorun TAM COZUNURLUKLU ekran goruntusunu alir.
# App Store 6.9" icin 1320x2868 istiyor, iPhone 17 Pro Max tam bu boyutta.
#
# Durdurmak icin: Ctrl+C

cd "$(dirname "$0")" || exit 1
OUT="shots"
mkdir -p "$OUT"

echo "Hazir. Simulator acik ve uygulama calisiyor olmali."
echo "Goruntuler: $(pwd)/$OUT"
echo "Durdurmak icin Ctrl+C"
echo

while true; do
  shopt -s nullglob
  for f in "$OUT"/trigger_*; do
    name=$(basename "$f")
    name=${name#trigger_}
    name=${name%.txt}
    if xcrun simctl io booted screenshot "$OUT/$name.png" >/dev/null 2>&1; then
      echo "  cekildi -> $OUT/$name.png"
    else
      echo "  HATA: simulator bulunamadi ($name)"
    fi
    rm -f "$f"
  done
  sleep 1
done
