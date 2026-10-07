import '../utils/lang.dart';

/// Market ürünlerinin dört dildeki adı ve açıklaması.
///
/// NEDEN VERİTABANINDA DEĞİL
/// -------------------------
/// `store_items` tablosunda `name` ve `description` tek birer sütun ve
/// içleri Türkçe. Uygulama dört dilli; İngilizce seçen bir çocuk kendi
/// dilindeki bir arayüzün ortasında "Alev Çerçevesi" görüyordu. Dilden
/// dile geçişi test eden dört dil denetimleri de katalog metinlerini hiç
/// görmüyordu, çünkü o metinler kodda değil veritabanındaydı.
///
/// Çeviriler bu yüzden koda alındı:
///
///   * Dört dil denetimi artık bu haritayı da tarayabiliyor — eksik bir
///     çeviri derlemeden önce testte düşüyor.
///   * Veritabanına şema değişikliği gerekmiyor; yayındaki satırlar
///     olduğu gibi kalıyor.
///   * Katalogda kodun bilmediği bir ürün belirirse uygulama çökmüyor:
///     veritabanındaki Türkçe ada düşüyor. Bu bilinçli bir geri çekilme,
///     bir çözüm değil — testi de o yüzden yazdık.
class StoreUrunMetni {
  const StoreUrunMetni(
    this.adTr,
    this.adEn,
    this.adDe,
    this.adEs,
    this.aciklamaTr,
    this.aciklamaEn,
    this.aciklamaDe,
    this.aciklamaEs,
  );

  final String adTr, adEn, adDe, adEs;
  final String aciklamaTr, aciklamaEn, aciklamaDe, aciklamaEs;

  String ad(String lang) =>
      AppLang.pick(lang, tr: adTr, en: adEn, de: adDe, es: adEs);

  String aciklama(String lang) => AppLang.pick(lang,
      tr: aciklamaTr, en: aciklamaEn, de: aciklamaDe, es: aciklamaEs);
}

/// `store_items.item_key` → dört dildeki metin.
const Map<String, StoreUrunMetni> kStoreUrunMetinleri = {
  // ------------------------------------------------- avatar çerçeveleri
  'frame_simple': StoreUrunMetni(
      'Basit Çerçeve', 'Simple Frame', 'Einfacher Rahmen', 'Marco simple',
      'Varsayılan sade çerçeve', 'The plain default frame',
      'Der schlichte Standardrahmen', 'El marco sencillo por defecto'),
  'frame_star': StoreUrunMetni(
      'Yıldızlı Çerçeve', 'Starry Frame', 'Sternenrahmen', 'Marco estrellado',
      'Etrafında parlayan yıldızlar', 'Stars glowing around you',
      'Sterne, die um dich leuchten', 'Estrellas que brillan a tu alrededor'),
  'frame_fire': StoreUrunMetni(
      'Alev Çerçeve', 'Fire Frame', 'Feuerrahmen', 'Marco de fuego',
      'Ateşten bir çerçeve', 'A frame made of fire', 'Ein Rahmen aus Feuer',
      'Un marco hecho de fuego'),
  'frame_diamond': StoreUrunMetni(
      'Elmas Çerçeve', 'Diamond Frame', 'Diamantrahmen', 'Marco de diamante',
      'Parıldayan elmas çerçeve, Pro’ya özel',
      'A sparkling diamond frame, Pro only',
      'Ein funkelnder Diamantrahmen, nur für Pro',
      'Un marco de diamante brillante, solo Pro'),
  'frame_flame': StoreUrunMetni(
      'Alev Çerçevesi', 'Flame Frame', 'Flammenrahmen', 'Marco de llamas',
      'Dalgalanan turuncu alevler', 'Flickering orange flames',
      'Züngelnde orange Flammen', 'Llamas naranjas ondulantes'),
  'frame_galaxy': StoreUrunMetni(
      'Galaksi Çerçevesi', 'Galaxy Frame', 'Galaxienrahmen', 'Marco galaxia',
      'Dönen mor yıldızlar', 'Purple stars in orbit', 'Kreisende lila Sterne',
      'Estrellas moradas en órbita'),
  'frame_circuit': StoreUrunMetni(
      'Devre Çerçevesi', 'Circuit Frame', 'Schaltkreis-Rahmen',
      'Marco de circuito', 'Halkada dolaşan sinyal',
      'A signal running around the ring', 'Ein Signal läuft um den Ring',
      'Una señal recorre el anillo'),
  'frame_gold': StoreUrunMetni(
      'Altın Çerçeve', 'Gold Frame', 'Goldrahmen', 'Marco dorado',
      'Dönen altın parıltısı', 'A turning golden shine',
      'Ein wandernder Goldglanz', 'Un brillo dorado giratorio'),
  'frame_ice': StoreUrunMetni(
      'Buz Çerçevesi', 'Ice Frame', 'Eisrahmen', 'Marco de hielo',
      'Işıldayan buz kristalleri', 'Glittering ice crystals',
      'Glitzernde Eiskristalle', 'Cristales de hielo brillantes'),
  'frame_forest': StoreUrunMetni(
      'Orman Çerçevesi', 'Forest Frame', 'Waldrahmen', 'Marco de bosque',
      'Rüzgârda sallanan yapraklar', 'Leaves swaying in the wind',
      'Blätter, die im Wind wiegen', 'Hojas que se mecen con el viento'),
  'frame_candy': StoreUrunMetni(
      'Şeker Çerçevesi', 'Candy Frame', 'Bonbonrahmen', 'Marco de caramelo',
      'Dönen pembe şeker şeritleri', 'Spinning pink candy stripes',
      'Drehende rosa Zuckerstreifen', 'Rayas de caramelo rosas girando'),
  'frame_robot': StoreUrunMetni(
      'Robot Çerçevesi', 'Robot Frame', 'Roboterrahmen', 'Marco robot',
      'Cıvatalı metal ve tarayıcı', 'Bolted metal with a scanner',
      'Verschraubtes Metall mit Scanner', 'Metal con tornillos y escáner'),
  'frame_bronze': StoreUrunMetni(
      'Bronz Çerçeve', 'Bronze Frame', 'Bronzerahmen', 'Marco de bronce',
      'İlk madalyan', 'Your first medal', 'Deine erste Medaille',
      'Tu primera medalla'),
  'frame_ocean': StoreUrunMetni(
      'Okyanus Çerçevesi', 'Ocean Frame', 'Ozeanrahmen', 'Marco océano',
      'Salınan deniz yosunları', 'Swaying seaweed', 'Wiegender Seetang',
      'Algas que se mecen'),
  'frame_sakura': StoreUrunMetni(
      'Kiraz Çiçeği', 'Cherry Blossom', 'Kirschblüte', 'Flor de cerezo',
      'Sallanan pembe yapraklar', 'Swaying pink petals',
      'Wiegende rosa Blütenblätter', 'Pétalos rosas que se mecen'),
  'frame_neon': StoreUrunMetni(
      'Neon Çerçevesi', 'Neon Frame', 'Neonrahmen', 'Marco neón',
      'Halkada koşan neon ışık', 'Neon light racing around',
      'Neonlicht rast im Kreis', 'Luz de neón que corre'),
  'frame_thunder': StoreUrunMetni(
      'Şimşek Çerçevesi', 'Thunder Frame', 'Blitzrahmen', 'Marco de rayo',
      'Çakan sarı enerji', 'Crackling yellow energy',
      'Knisternde gelbe Energie', 'Energía amarilla crepitante'),
  'frame_lava': StoreUrunMetni(
      'Lav Çerçevesi', 'Lava Frame', 'Lavarahmen', 'Marco de lava',
      'Kızgın kırmızı diller', 'Red-hot tongues of lava',
      'Glühend rote Zungen', 'Lenguas de lava al rojo vivo'),
  'frame_rainbow': StoreUrunMetni(
      'Gökkuşağı', 'Rainbow', 'Regenbogen', 'Arcoíris',
      'Dönen renk şeritleri', 'Spinning bands of colour',
      'Drehende Farbbänder', 'Bandas de color girando'),
  'frame_pixel': StoreUrunMetni(
      'Piksel Çerçevesi', 'Pixel Frame', 'Pixelrahmen', 'Marco pixel',
      '8-bit cıvatalar', '8-bit bolts', '8-Bit-Schrauben',
      'Tornillos de 8 bits'),
  'frame_comet': StoreUrunMetni(
      'Kuyruklu Yıldız', 'Comet', 'Komet', 'Cometa',
      'Etrafında koşan kuyruklar', 'Tails racing around you',
      'Schweife, die um dich rasen', 'Colas que corren a tu alrededor'),
  'frame_crystal': StoreUrunMetni(
      'Kristal Çerçeve', 'Crystal Frame', 'Kristallrahmen',
      'Marco de cristal', 'Keskin ışık kırılmaları', 'Sharp shards of light',
      'Scharfe Lichtsplitter', 'Destellos de luz afilados'),
  'frame_aurora': StoreUrunMetni(
      'Kuzey Işıkları', 'Northern Lights', 'Nordlichter', 'Auroras boreales',
      'Süzülen yeşil-mor ışıklar', 'Drifting green and purple lights',
      'Treibende grün-violette Lichter',
      'Luces verdes y moradas a la deriva'),
  'frame_royal': StoreUrunMetni(
      'Kraliyet Çerçevesi', 'Royal Frame', 'Königsrahmen', 'Marco real',
      'Mor kadife ve altın', 'Purple velvet and gold', 'Lila Samt und Gold',
      'Terciopelo morado y oro'),

  // ---------------------------------------------------- profil afişleri
  'banner_night': StoreUrunMetni(
      'Gece Gökyüzü', 'Night Sky', 'Nachthimmel', 'Cielo nocturno',
      'Yıldızlı mor gece', 'A starry purple night',
      'Eine sternklare lila Nacht', 'Una noche morada estrellada'),
  'banner_circuit': StoreUrunMetni(
      'Devre Kartı', 'Circuit Board', 'Platine', 'Placa de circuito',
      'Yeşil devre deseni', 'A green circuit pattern',
      'Ein grünes Platinenmuster', 'Un patrón de circuito verde'),
  'banner_sunset': StoreUrunMetni(
      'Gün Batımı', 'Sunset', 'Sonnenuntergang', 'Atardecer',
      'Turuncu-pembe geçiş', 'An orange-to-pink fade',
      'Ein Verlauf von Orange zu Rosa', 'Un degradado de naranja a rosa'),
  'banner_ocean': StoreUrunMetni(
      'Okyanus', 'Ocean', 'Ozean', 'Océano', 'Mavi derinlik',
      'Deep blue water', 'Tiefblaues Wasser', 'Aguas azules profundas'),
  'banner_pixel': StoreUrunMetni(
      'Piksel Manzara', 'Pixel Landscape', 'Pixellandschaft',
      'Paisaje pixelado', '8-bit tepeler', '8-bit hills', '8-Bit-Hügel',
      'Colinas de 8 bits'),
  'banner_lab': StoreUrunMetni(
      'Robot Atölyesi', 'Robot Workshop', 'Roboterwerkstatt',
      'Taller de robots', 'Gri atölye, kıvılcımlar',
      'A grey workshop with sparks', 'Graue Werkstatt mit Funken',
      'Taller gris con chispas'),

  // ----------------------------------------------------- isim rozetleri
  'badge_rocket': StoreUrunMetni(
      'Roket Rozeti', 'Rocket Badge', 'Raketenabzeichen', 'Insignia cohete',
      'Adının yanında roket', 'A rocket beside your name',
      'Eine Rakete neben deinem Namen', 'Un cohete junto a tu nombre'),
  'badge_bug': StoreUrunMetni(
      'Böcek Avcısı', 'Bug Hunter', 'Bug-Jäger', 'Cazador de errores',
      'Hata avcılarına', 'For the bug hunters', 'Für die Fehlerjäger',
      'Para los cazadores de errores'),
  'badge_brain': StoreUrunMetni(
      'Düşünen Kafa', 'Big Thinker', 'Denkerkopf', 'Gran pensador',
      'Bulmaca çözenlere', 'For puzzle solvers', 'Für Rätsellöser',
      'Para quienes resuelven acertijos'),
  'badge_star': StoreUrunMetni('Yıldız', 'Star', 'Stern', 'Estrella',
      'Klasik yıldız', 'The classic star', 'Der klassische Stern',
      'La estrella clásica'),
  'badge_bolt': StoreUrunMetni('Şimşek', 'Lightning', 'Blitz', 'Rayo',
      'Hızlı çözenlere', 'For the quick ones', 'Für die Schnellen',
      'Para los rápidos'),
  'badge_crown': StoreUrunMetni('Taç', 'Crown', 'Krone', 'Corona',
      'Sıralamanın tepesi için', 'For the top of the leaderboard',
      'Für die Spitze der Rangliste', 'Para la cima de la clasificación'),
  // ------------------------------------------- yeni rozetler (Ekim 2026)
  'badge_cat': StoreUrunMetni('Kedi Rozeti', 'Cat Badge', 'Katzen-Abzeichen',
      'Insignia de gato', 'Blok kodlamanın dostu', 'A friend of block coding',
      'Ein Freund des Blockcodings', 'Amiga de la programación por bloques'),
  'badge_gear': StoreUrunMetni('Dişli', 'Gear', 'Zahnrad', 'Engranaje',
      'Robot yapanlara', 'For robot builders', 'Für Roboterbauer',
      'Para quienes construyen robots'),
  'badge_fire': StoreUrunMetni('Ateş Serisi', 'On Fire', 'Feuerserie',
      'En racha', 'Her gün çalışanlara', 'For those who study every day',
      'Für alle, die jeden Tag lernen', 'Para quienes estudian cada día'),
  'badge_unicorn': StoreUrunMetni('Tek Boynuz', 'Unicorn', 'Einhorn',
      'Unicornio', 'Hayal gücü sınırsız', 'Limitless imagination',
      'Grenzenlose Fantasie', 'Imaginación sin límites'),
  'badge_trophy': StoreUrunMetni('Kupa', 'Trophy', 'Pokal', 'Trofeo',
      'Şampiyonlara özel', 'For champions only', 'Nur für Champions',
      'Solo para campeones'),
  'badge_diamond': StoreUrunMetni('Elmas Rozet', 'Diamond Badge',
      'Diamant-Abzeichen', 'Insignia de diamante', 'En nadir rozet',
      'The rarest badge', 'Das seltenste Abzeichen', 'La insignia más rara'),

  // -------------------------------------------------- etiketler (Ekim 2026)
  // Etiketin ADI kurdelede yazan yazi; kisa tutuluyor.
  'tag_coder': StoreUrunMetni('Kod Ustası', 'Code Master', 'Code-Meister',
      'Maestro del código', 'Kod yazmayı sevenlere',
      'For those who love writing code', 'Für alle, die gern coden',
      'Para quienes aman programar'),
  'tag_scratch': StoreUrunMetni('Scratch Yıldızı', 'Scratch Star',
      'Scratch-Star', 'Estrella de Scratch', 'Scratch projelerinin yıldızı',
      'The star of Scratch projects', 'Der Star der Scratch-Projekte',
      'La estrella de los proyectos Scratch'),
  'tag_robot': StoreUrunMetni('Robot Kâşifi', 'Robot Explorer',
      'Roboter-Entdecker', 'Explorador robot', 'Robotlarla oynayanlara',
      'For robot players', 'Für Roboter-Fans', 'Para fans de los robots'),
  'tag_bug': StoreUrunMetni('Hata Avcısı', 'Bug Hunter', 'Fehlerjäger',
      'Cazador de bugs', 'Hiçbir hata kaçamaz', 'No bug gets away',
      'Kein Fehler entkommt', 'Ningún error se escapa'),
  'tag_inventor': StoreUrunMetni('Küçük Mucit', 'Little Inventor',
      'Kleiner Erfinder', 'Pequeño inventor', 'Fikirleri hiç bitmeyenlere',
      'For endless ideas', 'Für endlose Ideen', 'Para ideas sin fin'),
  'tag_ninja': StoreUrunMetni('Algoritma Ninjası', 'Algorithm Ninja',
      'Algorithmus-Ninja', 'Ninja del algoritmo', 'Adım adım düşünenlere',
      'For step-by-step thinkers', 'Für Schritt-für-Schritt-Denker',
      'Para quienes piensan paso a paso'),
  'tag_circuit': StoreUrunMetni('Devre Sihirbazı', 'Circuit Wizard',
      'Schaltkreis-Zauberer', 'Mago de circuitos', 'Arduino ustalarına',
      'For Arduino masters', 'Für Arduino-Profis', 'Para expertos en Arduino'),
  'tag_designer': StoreUrunMetni('Oyun Tasarımcısı', 'Game Designer',
      'Spieldesigner', 'Diseñador de juegos', 'Kendi oyununu yapanlara',
      'For those who make their own games', 'Für alle, die eigene Spiele bauen',
      'Para quienes crean sus propios juegos'),
  'tag_ai': StoreUrunMetni('YZ Kâşifi', 'AI Explorer', 'KI-Entdecker',
      'Explorador de IA', 'Yapay zekâyı merak edenlere', 'For the AI-curious',
      'Für KI-Neugierige', 'Para curiosos de la IA'),
  'tag_legend': StoreUrunMetni('Efsane Kodcu', 'Legend Coder',
      'Legendärer Coder', 'Programador legendario', 'Herkesin konuştuğu',
      'The one everyone talks about', 'Über den alle reden',
      'Del que todos hablan'),

  // ---------------------------------------- pahali çerçeveler (Ekim 2026)
  'frame_cosmic': StoreUrunMetni('Kozmik Çerçeve', 'Cosmic Frame',
      'Kosmischer Rahmen', 'Marco cósmico', 'Dönen halkalar ve kıvılcımlar',
      'Spinning rings and sparks', 'Kreisende Ringe und Funken',
      'Anillos giratorios y chispas'),
  'frame_dragon': StoreUrunMetni('Ejderha Kanatları', 'Dragon Wings',
      'Drachenflügel', 'Alas de dragón', 'Çırpan kızıl kanatlar',
      'Flapping crimson wings', 'Schlagende rote Flügel',
      'Alas carmesí que aletean'),
  'frame_angel': StoreUrunMetni('Melek Kanatları', 'Angel Wings',
      'Engelsflügel', 'Alas de ángel', 'Bembeyaz tüylü kanatlar',
      'Snow-white feathered wings', 'Schneeweiße Federflügel',
      'Alas de plumas blancas'),
  'frame_legend': StoreUrunMetni('Efsane Çerçeve', 'Legend Frame',
      'Legendenrahmen', 'Marco legendario', 'Gökkuşağı ışıltısı',
      'A rainbow shimmer', 'Ein Regenbogenschimmer', 'Un brillo arcoíris'),
  'frame_emperor': StoreUrunMetni('İmparator Tacı', 'Emperor Crown',
      'Kaiserkrone', 'Corona imperial', 'Taçlı, mücevherli altın halka',
      'A crowned, jewelled gold ring', 'Ein gekrönter Goldring mit Juwelen',
      'Un anillo de oro con corona y joyas'),
};
