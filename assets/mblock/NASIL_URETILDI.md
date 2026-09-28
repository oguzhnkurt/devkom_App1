# scratch-blocks paketi nasil uretildi

`scratch_blocks.min.js` elle yazilmadi ve degistirilmedi. mBlock'un ve
Scratch'in kullandigi **scratch-blocks** kutuphanesinin npm surumunden
uretildi. Guncellemek gerekirse ayni uc komut yeterli.

```bash
curl -sSL -o sb.tgz https://registry.npmjs.org/scratch-blocks/-/scratch-blocks-2.1.20.tgz
tar xzf sb.tgz
npm i -D esbuild
./node_modules/.bin/esbuild package/dist/main.mjs \
  --bundle --minify --format=iife --global-name=ScratchBlocks \
  --outfile=assets/mblock/scratch_blocks.min.js
cp package/LICENSE assets/mblock/SCRATCH_BLOCKS_LICENSE
cp package/media/*.svg package/media/*.gif package/media/*.png \
   package/media/*.cur assets/mblock/media/
```

## Neden paketleme adimi var

npm'deki `dist/main.mjs` bir **ES modulu**. `<script type="module">` ile
yuklenmesi gerekirdi; `file://` uzerinden acilan bir sayfada modul
yukleme CORS'a takiliyor. esbuild ayni dosyayi tek bir IIFE'ye cevirip
`window.ScratchBlocks` altina koyuyor, boylece duz bir `<script src>`
yetiyor. Paket disaridan hicbir sey cekmiyor: blockly,
@blockly/field-colour ve @blockly/continuous-toolbox zaten icine
gomulu.

Bu bir **vendor** dosyasi: depoda Node derleme adimi YOK. Surum
yukseltilecegi zaman yukaridaki komutlar bir kez elle calistirilir ve
cikan dosya depoya konur.

## Neden bazi dosyalar atildi

* `media/*.mp3 *.ogg *.wav` — blok editorunun kendi tikirti sesleri.
  Uygulamanin kendi `SoundService`'i var; iki ses sistemi ust uste
  binmesin diye alinmadi. (Sayfa bunlari `fetch` ile ariyor ve
  bulamayinca sessizce devam ediyor.)
* `media/icons/`, `media/extensions/` — Scratch'in hazir bloklarina ait
  simgeler (micro:bit, WeDo, kalem...). Bizim blok tanimlarimiz bu
  simgelerin hicbirine referans vermiyor. Ileride hazir bir Scratch
  blogu kullanilirsa ilgili klasor geri eklenmeli.

## Surum ve lisans

* scratch-blocks **2.1.20**, Apache-2.0 (bkz. `SCRATCH_BLOCKS_LICENSE`).
* 2.0'dan itibaren scratch-blocks Blockly'nin catallanmis hali degil;
  Blockly 12'yi kutuphane olarak kullaniyor.
* Makeblock/Scratch markalari kullanilmiyor; yalnizca kod.

## Calistigi dogrulanan ayarlar

Asagidaki iki nokta deneyerek bulundu, tahmin degil:

* `ScratchBlocks.inject(div, {media: 'media/', theme: ScratchBlocks.ScratchBlocksTheme, ...})`
* Sayisal ve metin girisleri **alan (field) degil, golge blok (shadow)**
  olmali — gercek Scratch'te oldugu gibi:
  `<value name="ADIM"><shadow type="math_number"><field name="NUM">10</field></shadow></value>`
  Alan olarak verilince kutular bos goruluyor.
* Kendi bloklarimizi `defineBlocksWithJsonArray` ile ve `colour` /
  `colourSecondary` / `colourTertiary` vererek tanimliyoruz. Scratch'in
  hazir bloklari (control_wait gibi) renklerini temadan aliyor ve
  tema kurulmadan siyah cikiyor; bizim bloklarimizin rengi kendi
  tanimindan geldigi icin bu sorun yok. Renkler `mblock_palette.dart`
  ile birebir ayni olmali.
