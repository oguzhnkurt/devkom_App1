# App Store ürün sayfası başlık videosu (21:9)

Apple'ın başlık (header) videosu: 3840x1646, 30 fps, 5–30 sn, döngü, sessiz.
10 sn'lik kusursuz döngü; 4 dil (tr, en, de, es).

    mkdir -p /tmp/bv/stage/fonts
    cp tool/baslik_video/render.html /tmp/bv/stage/
    cp assets/fonts/{Baloo2-ExtraBold,Nunito-800,Nunito-700}.ttf /tmp/bv/stage/fonts/
    cp assets/maskot/devi.png /tmp/bv/stage/
    (cd /tmp/bv/stage && python3 -m http.server 8791 &)
    NODE_PATH=$(npm root -g) node tool/baslik_video/shoot.js tr /tmp/bv/f_tr
    ffmpeg -framerate 30 -i /tmp/bv/f_tr/%04d.png -f lavfi -i anullsrc=r=48000:cl=stereo -t 10 \
      -c:v libx264 -crf 16 -pix_fmt yuv420p -c:a aac -shortest -movflags +faststart baslik_tr.mp4

Kare başına ~1,5 sn (2x ölçek). Dört dil paralel çalıştırılırsa bellek yetmeyebilir; ffmpeg'i sırayla çalıştır.
