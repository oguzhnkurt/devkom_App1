# Devkom — 3D Karakter Sistemi Planı

Bu doküman, "Karakterim" ekranındaki emoji tabanlı karakteri, yüze/ele/ayakkabıya
zoom yapılabilen 3D insansı bir karaktere dönüştürmek için gereken işi çıkarır.

Amaç: sen bu planla bir 3D sanatçısıyla/geliştiriciyle konuşabil, işin gerçek
boyutunu ve maliyetini görebilesin.

---

## 1. Bugün ne var?

Mevcut sistem tamamen **2D ve emoji tabanlı**:

- `lib/widgets/character_stage.dart` — karakteri bir emoji olarak çiziyor
  (`static const String defaultEmoji = '👾'`), etrafına renk gradyanı ve
  "nefes alma" animasyonu koyuyor.
- `lib/models/store_item_model.dart` — mağaza ürünleri **emoji + renk kodu**
  olarak tutuluyor.
- Supabase `store_items` tablosu (migration 25 ve 26) — ürünlerin emoji ve hex
  renk değerlerini saklıyor.
- `pubspec.yaml` — **hiçbir 3D paketi yok**. Projede tek bir `.glb` / `.gltf` /
  `.fbx` / `.obj` dosyası da yok.

Yani 3D karakter "mevcut sistemi biraz geliştirme" değil, **sıfırdan yeni bir
alt sistem** kurmak demek.

---

## 2. Gereken 3D varlıklar (bunlar kodla üretilemez)

Bir 3D sanatçısının modellemesi gereken minimum set:

| Varlık | Açıklama | Tahmini adet |
|---|---|---|
| Ana karakter gövdesi | Rigged (iskeletli), çocuk dostu insansı model, düşük poligon | 1–2 (kız/erkek) |
| Yüz | Ayrı mesh ya da blend shape'ler (göz/ağız ifadeleri) | 1 set |
| Şapkalar | Kafa kemiğine bağlanabilir ayrı mesh | mevcut mağaza sayısı kadar |
| Gözlükler | Yüz hizasına oturan ayrı mesh | 3+ |
| Kolyeler | Boyun hizasına oturan ayrı mesh | 3+ |
| Ayakkabılar | Ayak kemiğine bağlanabilir ayrı mesh | 3+ |
| Kıyafetler | Gövdeye giydirilebilir mesh | ileride |

Teknik şartlar:

- Format: **glTF 2.0 (.glb)** — Flutter tarafında en iyi desteklenen format.
- Poligon bütçesi: karakter başına **10–20k üçgen** (hedef kitle 4–12 yaş,
  cihazlar genelde orta/düşük segment).
- Doku boyutu: 1024×1024 veya daha küçük, sıkıştırılmış (KTX2/Basis tercih).
- Aksesuarlar **ayrı dosya** olmalı ki tek tek takılıp çıkarılabilsin;
  karakterle aynı iskelete bağlanmalı (attachment point / bone socket).
- Toplam paket boyutu hedefi: **< 25 MB** (App Store indirme boyutunu ciddi
  büyütmemek için; şu an uygulamada 3D varlık yok).

> Bu varlıklar olmadan hiçbir kod çalışmaz. İşin kritik yolu burası.

---

## 3. Teknik seçenekler (Flutter tarafı)

### Seçenek A — `model_viewer_plus` (en hızlı yol)
- Google'ın `<model-viewer>` web bileşenini bir WebView içinde çalıştırır.
- Artı: kurulumu kolay, glTF/GLB desteği hazır, kamera kontrolü (orbit, zoom)
  built-in, AR desteği bonus.
- Eksi: WebView demek — bellek tüketimi yüksek, Flutter widget'larıyla
  karışması sınırlı, düşük donanımda tıkanabilir. Aksesuar takıp çıkarmak için
  JS köprüsü yazmak gerekir.
- Uygun olduğu durum: "karakteri döndür ve yakınlaştır" seviyesinde bir vitrin.

### Seçenek B — `flutter_scene` (Impeller tabanlı, native)
- Flutter ekibinin yeni 3D render katmanı.
- Artı: gerçek native performans, Flutter widget ağacıyla düzgün entegre.
- Eksi: görece yeni, ekosistem küçük, iskelet animasyonu/attachment için
  daha fazla el emeği gerekir.

### Seçenek C — `three_dart` / `flutter_cube`
- `flutter_cube` basit .obj gösterimi için yeterli ama **rigging ve aksesuar
  sistemi yok** — bu proje için yetersiz.
- `three_dart` daha yetenekli ama bakımı zayıf.

**Öneri:** Prototip için A, ürünleşince B.

---

## 4. Kodda değişmesi gerekenler

1. **Veri modeli** — `StoreItem` şu an `emoji` + `colorHex` tutuyor.
   `modelPath` (glb dosyası), `attachmentPoint` (head/face/neck/foot),
   `scale`, `offset` alanları eklenmeli.
2. **Supabase migration** — `store_items` tablosuna yukarıdaki kolonlar,
   ve mevcut emoji ürünlerinin 3D karşılıklarına migrate edilmesi.
   (Geriye dönük uyumluluk: `modelPath` null ise emoji moduna düş.)
3. **`CharacterStage` yeniden yazımı** — emoji çizen widget yerine 3D sahne;
   emoji modu fallback olarak korunmalı (varlık indirilemezse / eski cihazda).
4. **Zoom hedefleri** — "yüze zoom", "ayakkabıya zoom", "ele zoom" için
   modelde adlandırılmış kamera hedef noktaları (bone ya da empty object)
   tanımlanmalı; kod bu noktalara kamerayı yumuşak geçişle taşımalı.
5. **Market ekranı önizlemesi** — 3 saniyelik "Dene" özelliği 3D sahnede
   aksesuarı anlık takıp çıkarabilmeli.
6. **Varlık yönetimi** — tüm modeller uygulamaya gömülürse boyut şişer;
   Supabase Storage'dan indirip cache'lemek daha doğru (ilk açılışta indir,
   yerelde sakla).

---

## 5. Riskler

- **Uygulama boyutu**: 3D varlıklar App Store indirme boyutunu kolayca 30–60 MB
  büyütür. Aileler için indirme engeli olabilir.
- **Performans**: hedef kitle çocuk; ellerindeki cihazlar genelde eski/giriş
  seviye. 3D sahne pil ve ısınma sorunu çıkarabilir. Mutlaka düşük donanım
  için emoji/2D fallback kalmalı.
- **Yaş uygunluğu**: insansı avatar + özelleştirme, App Store'un çocuk
  kategorisi kurallarında ek dikkat gerektirir (özellikle sosyal özelliklerle
  birleşirse).
- **Bakım**: her yeni mağaza ürünü artık bir 3D model demek — içerik üretim
  maliyeti kalıcı olarak artar (şu an sadece bir emoji seçmek yetiyor).

---

## 6. Kademeli yol haritası (önerilen)

| Aşama | İş | Kimden |
|---|---|---|
| 0 | Bu planın onayı, bütçe/kapsam kararı | sen |
| 1 | 1 adet test karakteri + 1 şapka .glb üretimi | 3D sanatçı |
| 2 | `model_viewer_plus` ile prototip: karakteri göster, döndür, zoom yap | geliştirme |
| 3 | Gerçek cihazda performans/boyut ölçümü, karar noktası | sen + geliştirme |
| 4 | Veri modeli + migration + aksesuar takma sistemi | geliştirme |
| 5 | Tüm mağaza ürünlerinin 3D karşılıklarının üretimi | 3D sanatçı |
| 6 | Zoom hedefleri, animasyonlar, cilalama | geliştirme |

Aşama 1–3 bir "karar prototipi"dir: az maliyetle gerçekten işe yarayıp
yaramayacağını görürsün. Oradan gelen ölçümlere göre devam kararı verilmeli.

---

## 7. Ara çözüm (3D'ye girmeden)

3D'ye yatırım yapmadan görsel kaliteyi ciddi artıracak, çok daha ucuz alternatif:

**Katmanlı 2D karakter.** Karakter; gövde, saç, yüz, kıyafet, ayakkabı,
aksesuar olarak ayrı PNG/SVG katmanlarından oluşur. Kod bunları üst üste
bindirir. Zoom, yalnızca ölçek + kırpma ile yapılır (yüze zoom = yüz
bölgesine kırp ve büyüt).

- Varlık üretimi çok daha ucuz ve hızlı (2D illüstratör).
- Uygulama boyutu ihmal edilebilir.
- Her cihazda akıcı çalışır.
- Mevcut `CharacterStage` yapısı büyük ölçüde korunur.

İstediğin "yüze/ayakkabıya zoom" hissinin büyük kısmı bu yolla da elde
edilebilir. 3D'ye ancak bu yeterli gelmezse geçmeni öneririm.
