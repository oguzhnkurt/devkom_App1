import '../models/interactive_lesson_model.dart';
import '../yurutme/mblock_cozum.dart';
import 'mblock_palette.dart';

/// mBlock kursu — Modül 5: Projeler.
///
/// NE İŞE YARIYOR
/// --------------
/// Kurstaki dersler tek bir fikri öğretiyor: bir blok, bir döngü, bir
/// sensör. Proje bunun tersi — çocuk öğrendiği parçaları BİRLEŞTİRİYOR
/// ve ortaya bitmiş, gösterilebilir bir şey çıkıyor. Çocuk için fark
/// şu: ders "yapabilirsin" der, proje "yaptım" dedirtir.
///
/// NEREDE YAPILIYOR
/// ----------------
/// Proje gerçek mBlock 5'te kuruluyor, uygulama yanında rehber duruyor:
/// hangi kukla, hangi bloklar, hangi sayılar. Uygulamada akvaryumu
/// çalıştıracak bir sahne motoru (kukla, kıyafet, çarpışma) YOK ve
/// varmış gibi yapmıyoruz — tezgah yalnızca tek bir scripti kurup
/// kontrol etmek için.
///
/// SAYILAR NEREDEN GELİYOR
/// -----------------------
/// Uydurulmadı: `tool/mblock_projeleri/akvaryum.mblock` dosyasından
/// birebir okundu (balık 5 adım, denizanası ve ikinci balık 2 adım,
/// deniz yıldızı 0.1 adım; yönler 35 ve 55 derece). O dosya projenin
/// kaynağı ve `test/mblock_proje_test.dart` ders metnindeki sayıların
/// dosyayla aynı kaldığını denetliyor — proje değişirse ders de
/// değişmek zorunda.
///
/// BLOK YAZILARI Scratch'in kendi Türkçe dil dosyasından:
/// "%1 yönüne dön", "kenara geldiyse sek", "dönüş stilini %1 yap",
/// "%1 sesini bitene kadar çal".
///
/// ELMA TOPLAMA (3. proje) ilk OYUN: sayılar
/// `tool/mblock_projeleri/elma_toplama.mblock` dosyasından; ikiz
/// ("clone") blok yazıları Scratch'in kendi dil dosyasından.
class MBlockProjeLessonsData {
  MBlockProjeLessonsData._();

  static final List<InteractiveLesson> module5 = [
    InteractiveLesson(
      id: 'mblock_5_1',
      courseId: 'mblock',
      title: 'Proje: Akvaryum Dünyası',
      subtitle: 'Sekiz kukla, dört satır kod, canlı bir akvaryum',
      titleEn: 'Project: Aquarium World',
      titleDe: 'Projekt: Aquarium-Welt',
      titleEs: 'Proyecto: Mundo acuario',
      subtitleEn: 'Eight sprites, four lines of code, a living aquarium',
      subtitleDe: 'Acht Figuren, vier Zeilen Code, ein lebendes Aquarium',
      subtitleEs: 'Ocho objetos, cuatro líneas de código, un acuario vivo',
      order: 12,
      xpReward: 120,
      badge: 'aquarium_maker',
      steps: [
        IntroStep(
          id: 'p1_intro',
          mascotEmoji: '🐠',
          mascotMessage:
              'Bu sefer tek bir blok öğrenmiyoruz — bir PROJE kuruyoruz. '
              'Sonunda ekranında balıkların yüzdüğü, denizanasının '
              'süzüldüğü, baloncuk sesleri gelen bir akvaryum olacak.\n\n'
              'İşin güzel tarafı: her balığın kodu yalnızca ÜÇ blok. Aynı '
              'üç blok, farklı sayılarla. Projeyi büyük yapan şey zor kod '
              'değil, aynı basit kodun sekiz kuklaya dağılması.',
          mascotMessageEn:
              'This time we are not learning a single block — we are '
              'building a PROJECT. At the end you will have an aquarium on '
              'your screen: fish swimming, a jellyfish drifting, bubbles '
              'in the background.\n\n'
              'The good part: each fish needs only THREE blocks. The same '
              'three blocks with different numbers. What makes a project '
              'big is not hard code — it is simple code spread across '
              'eight sprites.',
          mascotMessageDe:
              'Diesmal lernen wir keinen einzelnen Block — wir bauen ein '
              'PROJEKT. Am Ende hast du ein Aquarium auf dem Bildschirm: '
              'schwimmende Fische, eine treibende Qualle, Blasen im '
              'Hintergrund.\n\n'
              'Das Schöne daran: jeder Fisch braucht nur DREI Blöcke. '
              'Dieselben drei Blöcke mit anderen Zahlen. Ein Projekt wird '
              'nicht durch schweren Code groß, sondern durch einfachen '
              'Code auf acht Figuren.',
          mascotMessageEs:
              'Esta vez no aprendemos un bloque suelto: construimos un '
              'PROYECTO. Al final tendrás un acuario en la pantalla: peces '
              'nadando, una medusa flotando, burbujas de fondo.\n\n'
              'Lo bueno: cada pez necesita solo TRES bloques. Los mismos '
              'tres bloques con números distintos. Lo que hace grande a un '
              'proyecto no es el código difícil, sino el código simple '
              'repartido en ocho objetos.',
          highlights: [
            'Sekiz kukla, tek desen',
            'Aynı kod, farklı sayılar',
            'mBlock 5\'te kuruyorsun',
          ],
          highlightsEn: [
            'Eight sprites, one pattern',
            'Same code, different numbers',
            'You build it in mBlock 5',
          ],
          highlightsDe: [
            'Acht Figuren, ein Muster',
            'Gleicher Code, andere Zahlen',
            'Du baust es in mBlock 5',
          ],
          highlightsEs: [
            'Ocho objetos, un patrón',
            'Mismo código, otros números',
            'Lo construyes en mBlock 5',
          ],
        ),

        ExplanationStep(
          id: 'p1_kurulum',
          title: 'Sahneyi Hazırla',
          titleEn: 'Set Up the Stage',
          titleDe: 'Die Bühne vorbereiten',
          titleEs: 'Prepara el escenario',
          content:
              'mBlock 5\'i aç ve Sahne (Stage) sekmesinden su arka planını '
              'seç: "water1". Sonra sağ alttaki kukla ekleme düğmesinden '
              'şunları getir:\n\n'
              '• 2 balık (Fish2, Fish23)\n'
              '• 1 denizanası (Jellyfish1)\n'
              '• 1 deniz yıldızı (Starfish)\n'
              '• 2 yosun (Grass10, Grass12)\n'
              '• 1 çapa (Anchor1)\n\n'
              'Yosun, çapa ve arka plan hiç kod almayacak — onlar '
              'dekor. Akvaryumu canlı gösteren şey birkaç kuklanın '
              'hareketi; her şeyin kıpırdaması gerekmiyor.',
          contentEn:
              'Open mBlock 5 and pick the water backdrop on the Stage tab: '
              '"water1". Then add these sprites with the button at the '
              'bottom right:\n\n'
              '• 2 fish (Fish2, Fish23)\n'
              '• 1 jellyfish (Jellyfish1)\n'
              '• 1 starfish (Starfish)\n'
              '• 2 seaweed (Grass10, Grass12)\n'
              '• 1 anchor (Anchor1)\n\n'
              'The seaweed, the anchor and the backdrop get no code at '
              'all — they are scenery. What makes an aquarium look alive '
              'is a few sprites moving; not everything has to move.',
          contentDe:
              'Öffne mBlock 5 und wähle im Reiter Bühne das '
              'Wasser-Bühnenbild: «water1». Dann hol dir unten rechts '
              'diese Figuren:\n\n'
              '• 2 Fische (Fish2, Fish23)\n'
              '• 1 Qualle (Jellyfish1)\n'
              '• 1 Seestern (Starfish)\n'
              '• 2 Algen (Grass10, Grass12)\n'
              '• 1 Anker (Anchor1)\n\n'
              'Algen, Anker und Hintergrund bekommen gar keinen Code — sie '
              'sind Kulisse. Lebendig wirkt ein Aquarium durch ein paar '
              'bewegte Figuren; nicht alles muss sich bewegen.',
          contentEs:
              'Abre mBlock 5 y elige el fondo de agua en la pestaña '
              'Escenario: «water1». Luego añade estos objetos con el botón '
              'de abajo a la derecha:\n\n'
              '• 2 peces (Fish2, Fish23)\n'
              '• 1 medusa (Jellyfish1)\n'
              '• 1 estrella de mar (Starfish)\n'
              '• 2 algas (Grass10, Grass12)\n'
              '• 1 ancla (Anchor1)\n\n'
              'Las algas, el ancla y el fondo no llevan código: son '
              'decorado. Lo que da vida a un acuario son unos pocos '
              'objetos en movimiento; no tiene que moverse todo.',
          tipEmoji: '🧭',
          tip: 'Kukla adları mBlock kütüphanesinde İngilizce. Aramaya '
              '"fish" yazman yeter.',
          tipEn: 'Sprite names are English in the mBlock library. Typing '
              '"fish" in the search is enough.',
          tipDe: 'Die Figurennamen sind in der mBlock-Bibliothek '
              'englisch. Tippe einfach «fish» in die Suche.',
          tipEs: 'Los nombres están en inglés en la biblioteca de mBlock. '
              'Basta con escribir «fish» en la búsqueda.',
        ),

        ExplanationStep(
          id: 'p1_desen',
          title: 'Bir Balığın Üç Bloğu',
          titleEn: 'A Fish in Three Blocks',
          titleDe: 'Ein Fisch in drei Blöcken',
          titleEs: 'Un pez en tres bloques',
          content:
              'Bütün balıkların kodu aynı desende:\n\n'
              '   tıklandığında\n'
              '   55 yönüne dön\n'
              '   sürekli tekrarla\n'
              '     2 adım git\n'
              '     kenara geldiyse sek\n\n'
              'Üç fikir var burada:\n\n'
              '1. YÖN — balık düz sağa (90) değil, hafif eğik yüzsün diye '
              'başta bir yön veriyoruz.\n'
              '2. SÜREKLİ — akvaryum durmaz. Döngü olmasa balık bir kez 2 '
              'adım gider ve donar.\n'
              '3. SEK — sahnenin kenarına gelince geri döner. Bu blok '
              'olmasa balık kenarda sıkışıp kalır.',
          contentEn:
              'Every fish follows the same pattern:\n\n'
              '   when clicked\n'
              '   point in direction 55\n'
              '   forever\n'
              '     move 2 steps\n'
              '     if on edge, bounce\n\n'
              'Three ideas live here:\n\n'
              '1. DIRECTION — we set one at the start so the fish swims at '
              'a slight angle instead of straight right (90).\n'
              '2. FOREVER — an aquarium never stops. Without the loop the '
              'fish moves 2 steps once and freezes.\n'
              '3. BOUNCE — it turns back at the edge of the stage. Without '
              'this block the fish gets stuck against the edge.',
          contentDe:
              'Alle Fische folgen demselben Muster:\n\n'
              '   Wenn angeklickt\n'
              '   setze Richtung auf 55 Grad\n'
              '   wiederhole fortlaufend\n'
              '     gehe 2 er Schritt\n'
              '     pralle vom Rand ab\n\n'
              'Darin stecken drei Ideen:\n\n'
              '1. RICHTUNG — am Anfang gesetzt, damit der Fisch schräg '
              'schwimmt statt genau nach rechts (90).\n'
              '2. FORTLAUFEND — ein Aquarium hört nie auf. Ohne Schleife '
              'geht der Fisch einmal 2 Schritte und bleibt stehen.\n'
              '3. ABPRALLEN — am Bühnenrand dreht er um. Ohne diesen Block '
              'klebt der Fisch am Rand fest.',
          contentEs:
              'Todos los peces siguen el mismo patrón:\n\n'
              '   al hacer clic\n'
              '   apuntar en dirección 55\n'
              '   por siempre\n'
              '     mover 2 pasos\n'
              '     si toca un borde, rebotar\n\n'
              'Aquí hay tres ideas:\n\n'
              '1. DIRECCIÓN — la fijamos al principio para que el pez nade '
              'algo inclinado en vez de recto a la derecha (90).\n'
              '2. POR SIEMPRE — un acuario no para. Sin el bucle el pez da '
              '2 pasos una vez y se queda quieto.\n'
              '3. REBOTAR — da la vuelta al llegar al borde. Sin este '
              'bloque el pez se queda pegado al borde.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'kenara geldiyse sek',
              contentEn: 'if on edge, bounce',
              contentDe: 'pralle vom Rand ab',
              contentEs: 'si toca un borde, rebotar',
              color: MBlockKuklaPalette.motion,
              label: 'Hareket',
              labelEn: 'Motion',
              labelDe: 'Bewegung',
              labelEs: 'Movimiento',
            ),
          ],
        ),

        BlockBuilderStep(
          id: 'p1_build_balik',
          instruction: 'Denizanasının kodunu kur.',
          instructionEn: "Build the jellyfish's code.",
          instructionDe: 'Baue den Code der Qualle.',
          instructionEs: 'Construye el código de la medusa.',
          goal: 'Tıklandığında → 55 yönüne dön → sürekli { 2 adım git, '
              'kenara geldiyse sek }',
          goalEn: 'When clicked → point in direction 55 → forever { move 2, '
              'if on edge bounce }',
          goalDe: 'Wenn angeklickt → Richtung 55 → fortlaufend { gehe 2, '
              'pralle vom Rand ab }',
          goalEs: 'Al hacer clic → dirección 55 → por siempre { mover 2, '
              'si toca un borde rebotar }',
          availableBlocks: [
            MBlockKuklaBlocks.greenFlag(),
            MBlockKuklaBlocks.pointInDirection('55', id: 'point_55'),
            MBlockKuklaBlocks.forever(),
            MBlockKuklaBlocks.move('2', id: 'move_2_fish'),
            MBlockKuklaBlocks.ifOnEdgeBounce(),
            MBlockKuklaBlocks.repeat('10', id: 'repeat_10_fish'),
          ],
          correctSequence: [
            'green_flag',
            'point_55',
            'k_forever',
            'move_2_fish',
            'edge_bounce',
          ],
          // Gercek tezgah: cocuk blogu mBlock'takiyle ayni goruntude
          // surukluyor. Arac kutusu kasten dar.
          mblock: MBlockTezgahAyari(
            bloklar: [
              'dev_bayrak',
              'dev_yonune_don',
              'dev_surekli',
              'dev_git',
              'dev_sek',
            ],
            cozum: [
              MBlockBeklenen('dev_bayrak'),
              MBlockBeklenen('dev_yonune_don', alanlar: {'YON': '55'}),
              MBlockBeklenen('dev_surekli', icerik: [
                MBlockBeklenen('dev_git', alanlar: {'ADIM': '2'}),
                MBlockBeklenen('dev_sek'),
              ]),
            ],
          ),
          xpReward: 40,
        ),

        ExplanationStep(
          id: 'p1_sayilar',
          title: 'Aynı Kod, Başka Hız',
          titleEn: 'Same Code, Different Speed',
          titleDe: 'Gleicher Code, andere Geschwindigkeit',
          titleEs: 'Mismo código, otra velocidad',
          content:
              'Şimdi aynı üç bloğu diğer kuklalara da koy — ama sayıları '
              'değiştir:\n\n'
              '• Fish2 → yön 35, 5 adım (hızlı balık)\n'
              '• Fish23 → yön 55, 2 adım\n'
              '• Jellyfish1 → yön 55, 2 adım\n'
              '• Starfish → yön 55, 0.1 adım\n\n'
              'Deniz yıldızının 0.1 adımı yazım hatası değil: yıldız '
              'neredeyse duruyor, çok yavaş sürükleniyor. Aynı kodun '
              'sayısını değiştirerek bambaşka bir canlı elde ediyorsun. '
              'Akvaryumu inandırıcı yapan da bu — hepsi aynı hızda '
              'yüzseydi ekran bir tören alayına benzerdi.',
          contentEn:
              'Now give the same three blocks to the other sprites — with '
              'different numbers:\n\n'
              '• Fish2 → direction 35, 5 steps (the fast one)\n'
              '• Fish23 → direction 55, 2 steps\n'
              '• Jellyfish1 → direction 55, 2 steps\n'
              '• Starfish → direction 55, 0.1 steps\n\n'
              "The starfish's 0.1 is not a typo: it barely moves, it "
              'drifts. By changing one number in the same code you get a '
              'completely different creature. That is what makes the '
              'aquarium believable — if everything swam at the same speed '
              'the screen would look like a parade.',
          contentDe:
              'Gib jetzt denselben drei Blöcken den anderen Figuren — mit '
              'anderen Zahlen:\n\n'
              '• Fish2 → Richtung 35, 5 Schritte (der schnelle)\n'
              '• Fish23 → Richtung 55, 2 Schritte\n'
              '• Jellyfish1 → Richtung 55, 2 Schritte\n'
              '• Starfish → Richtung 55, 0.1 Schritte\n\n'
              'Die 0.1 beim Seestern ist kein Tippfehler: er bewegt sich '
              'kaum, er treibt. Eine geänderte Zahl im selben Code ergibt '
              'ein ganz anderes Lebewesen. Genau das macht das Aquarium '
              'glaubwürdig — bei gleicher Geschwindigkeit sähe es aus wie '
              'eine Parade.',
          contentEs:
              'Ahora pon los mismos tres bloques en los demás objetos, '
              'pero con otros números:\n\n'
              '• Fish2 → dirección 35, 5 pasos (el rápido)\n'
              '• Fish23 → dirección 55, 2 pasos\n'
              '• Jellyfish1 → dirección 55, 2 pasos\n'
              '• Starfish → dirección 55, 0.1 pasos\n\n'
              'El 0.1 de la estrella no es una errata: apenas se mueve, se '
              'deja llevar. Cambiando un número del mismo código sale una '
              'criatura totalmente distinta. Eso hace creíble el acuario: '
              'si todo nadara igual de rápido parecería un desfile.',
          tipEmoji: '🧪',
          tip: 'Bir kuklanın kodunu kurduktan sonra sürükleyip başka bir '
              'kuklanın üstüne bırakırsan kod oraya kopyalanır. Sonra '
              'yalnızca sayıları değiştirirsin.',
          tipEn: 'Drag a finished script onto another sprite and it gets '
              'copied there. Then you only change the numbers.',
          tipDe: 'Zieh ein fertiges Skript auf eine andere Figur, dann '
              'wird es dorthin kopiert. Danach änderst du nur die Zahlen.',
          tipEs: 'Arrastra un script terminado sobre otro objeto y se '
              'copia allí. Después solo cambias los números.',
        ),

        MultipleChoiceStep(
          id: 'p1_q1',
          question: 'Deniz yıldızına 0.1 adım yazdın. Ne olur?',
          questionEn: 'You gave the starfish 0.1 steps. What happens?',
          questionDe: 'Du gibst dem Seestern 0.1 Schritte. Was passiert?',
          questionEs: 'Le das 0.1 pasos a la estrella. ¿Qué pasa?',
          options: [
            ChoiceOption(
              text: 'Çok yavaş sürüklenir — bakınca fark edilir ama '
                  'acelesi yoktur',
              textEn: 'It drifts very slowly — you notice it, but it is in '
                  'no hurry',
              textDe: 'Er treibt sehr langsam — man sieht es, aber er hat '
                  'es nicht eilig',
              textEs: 'Se mueve muy despacio: se nota, pero sin prisa',
            ),
            ChoiceOption(
              text: 'Hiç hareket etmez, 0.1 sıfır sayılır',
              textEn: 'It never moves, 0.1 counts as zero',
              textDe: 'Er bewegt sich nie, 0.1 gilt als null',
              textEs: 'No se mueve nada, 0.1 cuenta como cero',
            ),
            ChoiceOption(
              text: 'On kat hızlanır',
              textEn: 'It goes ten times faster',
              textDe: 'Er wird zehnmal schneller',
              textEs: 'Va diez veces más rápido',
            ),
            ChoiceOption(
              text: 'mBlock ondalık sayı kabul etmez, hata verir',
              textEn: 'mBlock rejects decimals and shows an error',
              textDe: 'mBlock nimmt keine Kommazahlen und meldet Fehler',
              textEs: 'mBlock no acepta decimales y da error',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Döngü saniyede onlarca kez dönüyor; her turda 0.1 adım '
              'demek, saniyede birkaç adım demek. Yani yıldız gerçekten '
              'ilerliyor, sadece çok ağır. Ondalık sayılar kabul edilir — '
              'hız ayarının en kolay yolu budur.',
          explanationEn:
              'The loop runs dozens of times a second; 0.1 steps per turn '
              'still adds up to a few steps a second. So it really does '
              'move, just very slowly. Decimals are allowed — they are the '
              'easiest way to tune speed.',
          explanationDe:
              'Die Schleife läuft dutzende Male pro Sekunde; 0.1 Schritte '
              'pro Durchlauf ergeben trotzdem ein paar Schritte pro '
              'Sekunde. Er bewegt sich also wirklich, nur sehr langsam. '
              'Kommazahlen sind erlaubt — der einfachste Weg, Tempo zu '
              'regeln.',
          explanationEs:
              'El bucle corre decenas de veces por segundo; 0.1 pasos por '
              'vuelta suman varios pasos por segundo. Sí se mueve, solo '
              'que muy despacio. Los decimales valen: son la forma más '
              'fácil de ajustar la velocidad.',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'p1_ters_balik',
          title: 'Balık Ters Yüzüyor!',
          titleEn: 'The Fish is Upside Down!',
          titleDe: 'Der Fisch schwimmt kopfüber!',
          titleEs: '¡El pez nada al revés!',
          content:
              'Projeyi çalıştırınca şunu göreceksin: balık sola dönünce '
              'ters, karnı yukarıda yüzüyor. Kod yanlış değil — kukla '
              'dönerken GÖRSELİ de dönüyor.\n\n'
              'Çözüm tek blok:\n\n'
              '   dönüş stilini sol-sağ yap\n\n'
              'Bu blok "dön ama görüntüyü sadece aynala" demek. '
              'Denizanası, ikinci balık ve deniz yıldızında bunu kullan.\n\n'
              'Birinci balıkta (Fish2) bilerek "tüm yönlere dönebilir" '
              'bırakabilirsin: o balık gerçekten takla atarak yüzsün, '
              'aradaki farkı gözünle gör. Bir hatayı düzeltmenin en iyi '
              'yolu, düzeltilmemiş hâlini yanında görmektir.',
          contentEn:
              'Run the project and you will see it: when the fish turns '
              'left it swims belly-up. The code is not wrong — turning a '
              'sprite turns its PICTURE too.\n\n'
              'One block fixes it:\n\n'
              '   set rotation style left-right\n\n'
              'It means "turn, but only mirror the picture". Use it on the '
              'jellyfish, the second fish and the starfish.\n\n'
              'On the first fish (Fish2) you can leave "all around" on '
              'purpose: let that one really tumble, and see the difference '
              'with your own eyes. The best way to understand a fix is to '
              'keep the unfixed version next to it.',
          contentDe:
              'Starte das Projekt und du siehst es: dreht der Fisch nach '
              'links, schwimmt er auf dem Rücken. Der Code ist nicht '
              'falsch — mit der Figur dreht sich auch ihr BILD.\n\n'
              'Ein Block behebt das:\n\n'
              '   setze Drehtyp auf links-rechts\n\n'
              'Das heißt «dreh dich, spiegle aber nur das Bild». Nimm ihn '
              'für Qualle, zweiten Fisch und Seestern.\n\n'
              'Beim ersten Fisch (Fish2) kannst du «rundherum» absichtlich '
              'lassen: der soll wirklich purzeln, damit du den Unterschied '
              'siehst. Einen Fehler versteht man am besten, wenn die '
              'unkorrigierte Fassung daneben steht.',
          contentEs:
              'Ejecuta el proyecto y lo verás: al girar a la izquierda, el '
              'pez nada panza arriba. El código no está mal: al girar el '
              'objeto gira también su IMAGEN.\n\n'
              'Un bloque lo arregla:\n\n'
              '   fijar estilo de rotación a izquierda-derecha\n\n'
              'Significa «gira, pero solo refleja la imagen». Úsalo en la '
              'medusa, el segundo pez y la estrella.\n\n'
              'En el primer pez (Fish2) puedes dejar «en todas '
              'direcciones» a propósito: que ese dé volteretas y veas la '
              'diferencia. La mejor forma de entender un arreglo es tener '
              'al lado la versión sin arreglar.',
          tipEmoji: '🔁',
          tip: 'Bu blok bir kez çalışır, döngünün içine koymana gerek yok '
              '— başa, yön bloğunun yanına koy.',
          tipEn: 'This block runs once; it does not belong inside the '
              'loop — put it at the top, next to the direction block.',
          tipDe: 'Dieser Block läuft einmal; er gehört nicht in die '
              'Schleife — setz ihn oben neben den Richtungsblock.',
          tipEs: 'Este bloque se ejecuta una vez; no va dentro del bucle: '
              'ponlo arriba, junto al bloque de dirección.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'dönüş stilini sol-sağ yap',
              contentEn: 'set rotation style left-right',
              contentDe: 'setze Drehtyp auf links-rechts',
              contentEs: 'fijar estilo de rotación a izquierda-derecha',
              color: MBlockKuklaPalette.motion,
              label: 'Hareket',
              labelEn: 'Motion',
              labelDe: 'Bewegung',
              labelEs: 'Movimiento',
            ),
          ],
        ),

        BlockBuilderStep(
          id: 'p1_build_ses',
          instruction: 'Yosuna baloncuk sesini kur (akvaryumun fon sesi).',
          instructionEn: 'Give the seaweed the bubble sound (the ambience).',
          instructionDe: 'Gib der Alge den Blasen-Klang (die Kulisse).',
          instructionEs: 'Dale a las algas el sonido de burbujas (el fondo).',
          goal: 'Tıklandığında → sürekli { Bubbles sesini bitene kadar çal }',
          goalEn: 'When clicked → forever { play sound Bubbles until done }',
          goalDe: 'Wenn angeklickt → fortlaufend { spiele Klang Bubbles ganz }',
          goalEs: 'Al hacer clic → por siempre { tocar sonido Bubbles hasta '
              'que termine }',
          availableBlocks: [
            MBlockKuklaBlocks.greenFlag(),
            MBlockKuklaBlocks.forever(),
            MBlockKuklaBlocks.playSoundUntilDone('Bubbles', id: 'sound_bubbles'),
            MBlockKuklaBlocks.wait('1', id: 'wait_1_ses'),
          ],
          correctSequence: [
            'green_flag',
            'k_forever',
            'sound_bubbles',
          ],
          mblock: MBlockTezgahAyari(
            bloklar: ['dev_bayrak', 'dev_surekli', 'dev_ses_bitene', 'dev_bekle'],
            cozum: [
              MBlockBeklenen('dev_bayrak'),
              MBlockBeklenen('dev_surekli', icerik: [
                MBlockBeklenen('dev_ses_bitene', alanlar: {'SES': 'Bubbles'}),
              ]),
            ],
          ),
          xpReward: 30,
        ),

        ExplanationStep(
          id: 'p1_ses_neden',
          title: 'Neden "Bitene Kadar Çal"?',
          titleEn: 'Why "Until Done"?',
          titleDe: 'Warum «ganz spielen»?',
          titleEs: '¿Por qué «hasta que termine»?',
          content:
              'Ses bloklarının ikisi de ses çalar ama farkları büyük:\n\n'
              '• "sesini çal" → sesi başlatır ve HEMEN alttaki bloğa geçer. '
              'Döngünün içinde bu, saniyede onlarca kez yeniden başlayan '
              'bir ses demektir: çıtırtı gibi bir gürültü.\n'
              '• "sesini bitene kadar çal" → ses bitene kadar bekler. '
              'Döngü ancak o zaman başa döner. Baloncuklar üst üste '
              'binmeden, düzgün bir fon sesi olur.\n\n'
              'Bu fark yalnızca ses için değil: programlama boyunca '
              '"başlat ve devam et" ile "bitmesini bekle" ayrımıyla '
              'karşılaşacaksın.',
          contentEn:
              'Both sound blocks play a sound, but the difference is big:\n\n'
              '• "start sound" → starts it and moves on to the next block '
              'IMMEDIATELY. Inside a loop that means a sound restarting '
              'dozens of times a second: a crackling noise.\n'
              '• "play sound until done" → waits for the sound to finish. '
              'Only then does the loop go round again. The bubbles do not '
              'overlap and you get a proper ambience.\n\n'
              'This difference is not just about sound: all through '
              'programming you will meet "start and carry on" versus "wait '
              'until it is finished".',
          contentDe:
              'Beide Klangblöcke spielen einen Klang, aber der Unterschied '
              'ist groß:\n\n'
              '• «spiele Klang» → startet ihn und geht SOFORT zum nächsten '
              'Block. In einer Schleife heißt das: ein Klang, der dutzende '
              'Male pro Sekunde neu startet — ein Knistern.\n'
              '• «spiele Klang ganz» → wartet, bis der Klang fertig ist. '
              'Erst dann dreht die Schleife weiter. Die Blasen '
              'überlagern sich nicht, es entsteht eine saubere Kulisse.\n\n'
              'Dieser Unterschied gilt nicht nur für Klänge: «starten und '
              'weitermachen» gegen «warten, bis es fertig ist» begegnet '
              'dir überall beim Programmieren.',
          contentEs:
              'Los dos bloques de sonido suenan, pero la diferencia es '
              'grande:\n\n'
              '• «iniciar sonido» → lo lanza y pasa al siguiente bloque '
              'INMEDIATAMENTE. Dentro de un bucle eso es un sonido que se '
              'reinicia decenas de veces por segundo: un chisporroteo.\n'
              '• «tocar sonido hasta que termine» → espera a que acabe. '
              'Solo entonces el bucle vuelve a empezar. Las burbujas no se '
              'solapan y queda un fondo limpio.\n\n'
              'Esta diferencia no es solo de sonido: en programación verás '
              'siempre «lanzar y seguir» frente a «esperar a que termine».',
        ),

        MatchingStep(
          id: 'p1_match',
          instruction: 'Her kuklayı işiyle eşleştir.',
          instructionEn: 'Match each sprite with its job.',
          instructionDe: 'Ordne jeder Figur ihre Aufgabe zu.',
          instructionEs: 'Une cada objeto con su tarea.',
          pairs: [
            MatchPair(
              id: 'a1',
              left: 'Fish2',
              right: '5 adım — akvaryumun hızlısı',
              leftEn: 'Fish2',
              rightEn: '5 steps — the fast one',
              leftDe: 'Fish2',
              rightDe: '5 Schritte — der Schnelle',
              leftEs: 'Fish2',
              rightEs: '5 pasos: el rápido',
            ),
            MatchPair(
              id: 'a2',
              left: 'Starfish',
              right: '0.1 adım — neredeyse duruyor',
              leftEn: 'Starfish',
              rightEn: '0.1 steps — barely moving',
              leftDe: 'Starfish',
              rightDe: '0.1 Schritte — kaum in Bewegung',
              leftEs: 'Starfish',
              rightEs: '0.1 pasos: casi quieta',
            ),
            MatchPair(
              id: 'a3',
              left: 'Grass12',
              right: 'Baloncuk sesi döngüsü',
              leftEn: 'Grass12',
              rightEn: 'The bubble sound loop',
              leftDe: 'Grass12',
              rightDe: 'Die Blasen-Klangschleife',
              leftEs: 'Grass12',
              rightEs: 'El bucle de burbujas',
            ),
            MatchPair(
              id: 'a4',
              left: 'Anchor1',
              right: 'Kod yok — dekor',
              leftEn: 'Anchor1',
              rightEn: 'No code — scenery',
              leftDe: 'Anchor1',
              rightDe: 'Kein Code — Kulisse',
              leftEs: 'Anchor1',
              rightEs: 'Sin código: decorado',
            ),
          ],
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'p1_ozet',
          title: 'Akvaryumun Hazır!',
          titleEn: 'Your Aquarium is Ready!',
          titleDe: 'Dein Aquarium ist fertig!',
          titleEs: '¡Tu acuario está listo!',
          content: '🐠 Kontrol listesi:\n\n'
              '✓ Su arka planı seçili\n'
              '✓ Dört canlının da kodu var (yön + sürekli + git + sek)\n'
              '✓ Hızlar farklı: 5 / 2 / 2 / 0.1\n'
              '✓ Ters yüzen balık düzeltildi (dönüş stili sol-sağ)\n'
              '✓ Yosunda baloncuk sesi dönüyor\n\n'
              'Şimdi sen büyüt: bir balık daha ekle, arka plana kabarcık '
              'çiz, bir kuklaya tıklayınca "Merhaba!" dedirt. Proje '
              'bitmez — bitti dediğin yerde biter.',
          contentEn: '🐠 Checklist:\n\n'
              '✓ Water backdrop selected\n'
              '✓ All four creatures have code (direction + forever + move '
              '+ bounce)\n'
              '✓ Different speeds: 5 / 2 / 2 / 0.1\n'
              '✓ The upside-down fish is fixed (rotation style left-right)\n'
              '✓ The bubble sound loops on the seaweed\n\n'
              'Now make it yours: add another fish, draw bubbles on the '
              'backdrop, make a sprite say "Hello!" when clicked. A '
              'project is never finished — it ends where you say it ends.',
          contentDe: '🐠 Checkliste:\n\n'
              '✓ Wasser-Bühnenbild gewählt\n'
              '✓ Alle vier Tiere haben Code (Richtung + fortlaufend + '
              'gehen + abprallen)\n'
              '✓ Verschiedene Geschwindigkeiten: 5 / 2 / 2 / 0.1\n'
              '✓ Der kopfüber schwimmende Fisch ist korrigiert (Drehtyp '
              'links-rechts)\n'
              '✓ Der Blasen-Klang läuft in der Alge\n\n'
              'Jetzt mach es zu deinem: noch ein Fisch, gemalte Blasen im '
              'Hintergrund, eine Figur, die beim Anklicken «Hallo!» sagt. '
              'Ein Projekt ist nie fertig — es endet, wo du sagst.',
          contentEs: '🐠 Lista de control:\n\n'
              '✓ Fondo de agua elegido\n'
              '✓ Los cuatro animales tienen código (dirección + por '
              'siempre + mover + rebotar)\n'
              '✓ Velocidades distintas: 5 / 2 / 2 / 0.1\n'
              '✓ El pez del revés está arreglado (rotación '
              'izquierda-derecha)\n'
              '✓ El sonido de burbujas gira en las algas\n\n'
              'Ahora hazlo tuyo: añade otro pez, dibuja burbujas en el '
              'fondo, haz que un objeto diga «¡Hola!» al hacer clic. Un '
              'proyecto nunca se acaba: termina donde tú digas.',
          tipEmoji: '🏆',
          tip: 'Akvaryumcu rozetini kazandın!',
          tipEn: 'You earned the Aquarium badge!',
          tipDe: 'Du hast das Aquarium-Abzeichen verdient!',
          tipEs: '¡Has ganado la insignia del Acuario!',
        ),
      ],
    ),

    // ------------------------------------------------------- Proje 2
    InteractiveLesson(
      id: 'mblock_5_2',
      courseId: 'mblock',
      title: 'Proje: Dans Partisi',
      subtitle: 'Kostüm değiştirerek hareket, beklemeyle ritim',
      titleEn: 'Project: Dance Party',
      titleDe: 'Projekt: Tanzparty',
      titleEs: 'Proyecto: Fiesta de baile',
      subtitleEn: 'Motion from costumes, rhythm from waiting',
      subtitleDe: 'Bewegung durch Kostüme, Rhythmus durch Warten',
      subtitleEs: 'Movimiento con disfraces, ritmo con esperas',
      order: 13,
      xpReward: 120,
      badge: 'dance_maker',
      steps: [
        IntroStep(
          id: 'p2_intro',
          mascotEmoji: '💃',
          mascotMessage:
              'Akvaryumda kuklalar yer değiştirerek hareket ediyordu. '
              'Burada kimse bir yere gitmiyor — yine de üç karakter dans '
              'ediyor.\n\n'
              'Sır şu: Casey\'nin dört farklı KOSTÜMÜ var, dördü de aynı '
              'karakterin farklı duruşu. Onları hızlıca sırayla '
              'gösterirsen göz bunu hareket sanıyor. Çizgi film de tam '
              'olarak böyle çalışıyor.',
          mascotMessageEn:
              'In the aquarium the sprites moved by changing place. Here '
              'nobody goes anywhere — and yet three characters dance.\n\n'
              "The secret: Casey has four COSTUMES, four poses of the same "
              'character. Show them quickly one after another and your eye '
              'reads it as movement. Cartoons work exactly like this.',
          mascotMessageDe:
              'Im Aquarium bewegten sich die Figuren, indem sie den Platz '
              'wechselten. Hier geht niemand irgendwohin — und trotzdem '
              'tanzen drei Figuren.\n\n'
              'Das Geheimnis: Casey hat vier KOSTÜME, vier Posen derselben '
              'Figur. Zeig sie schnell nacheinander, und dein Auge sieht '
              'Bewegung. Genau so funktionieren Zeichentrickfilme.',
          mascotMessageEs:
              'En el acuario los objetos se movían cambiando de sitio. '
              'Aquí nadie va a ninguna parte y, aun así, tres personajes '
              'bailan.\n\n'
              'El secreto: Casey tiene cuatro DISFRACES, cuatro posturas '
              'del mismo personaje. Muéstralos rápido uno tras otro y tu '
              'ojo ve movimiento. Los dibujos animados funcionan así.',
          highlights: [
            'Kostüm = karakterin bir duruşu',
            'Hızlı sıra = hareket',
            'Bekleme süresi = dansın hızı',
          ],
          highlightsEn: [
            'A costume is one pose',
            'Quick order = movement',
            'The wait sets the speed',
          ],
          highlightsDe: [
            'Ein Kostüm ist eine Pose',
            'Schnelle Folge = Bewegung',
            'Die Wartezeit bestimmt das Tempo',
          ],
          highlightsEs: [
            'Un disfraz es una postura',
            'Secuencia rápida = movimiento',
            'La espera marca la velocidad',
          ],
        ),

        ExplanationStep(
          id: 'p2_kurulum',
          title: 'Sahneyi ve Dansçıları Getir',
          titleEn: 'Bring the Stage and the Dancers',
          titleDe: 'Bühne und Tänzer holen',
          titleEs: 'Trae el escenario y los bailarines',
          content:
              'mBlock 5\'te yeni bir proje aç.\n\n'
              '• Sahne → arka plan: "Spotlight-stage2" (spot ışıklı sahne)\n'
              '• Kuklalar: Casey, Dorian, Jordyn (üçü de dansçı)\n'
              '• İki hoparlör: Loudspeaker, Loudspeaker3\n\n'
              'Kukla kütüphanesinde bir dansçıyı seçtiğinde KOSTÜMLER '
              'sekmesine bak: casey-a, casey-b, casey-c, casey-d. Dördü '
              'de hazır geliyor, çizmen gerekmiyor.\n\n'
              'Hoparlörlerden yalnızca biri kod alacak — müziği çalan o. '
              'Diğeri dekor.',
          contentEn:
              'Open a new project in mBlock 5.\n\n'
              '• Stage → backdrop: "Spotlight-stage2"\n'
              '• Sprites: Casey, Dorian, Jordyn (all three are dancers)\n'
              '• Two loudspeakers: Loudspeaker, Loudspeaker3\n\n'
              'Pick a dancer in the library and open the COSTUMES tab: '
              'casey-a, casey-b, casey-c, casey-d. All four come with the '
              'sprite; you do not have to draw anything.\n\n'
              'Only one loudspeaker gets code — the one playing the music. '
              'The other is scenery.',
          contentDe:
              'Öffne ein neues Projekt in mBlock 5.\n\n'
              '• Bühne → Bühnenbild: «Spotlight-stage2»\n'
              '• Figuren: Casey, Dorian, Jordyn (alle drei tanzen)\n'
              '• Zwei Lautsprecher: Loudspeaker, Loudspeaker3\n\n'
              'Wähle einen Tänzer und öffne den Reiter KOSTÜME: casey-a, '
              'casey-b, casey-c, casey-d. Alle vier sind schon dabei, du '
              'musst nichts zeichnen.\n\n'
              'Nur ein Lautsprecher bekommt Code — der mit der Musik. Der '
              'andere ist Kulisse.',
          contentEs:
              'Abre un proyecto nuevo en mBlock 5.\n\n'
              '• Escenario → fondo: «Spotlight-stage2»\n'
              '• Objetos: Casey, Dorian, Jordyn (los tres bailan)\n'
              '• Dos altavoces: Loudspeaker, Loudspeaker3\n\n'
              'Elige un bailarín en la biblioteca y abre la pestaña '
              'DISFRACES: casey-a, casey-b, casey-c, casey-d. Los cuatro '
              'vienen incluidos, no tienes que dibujar nada.\n\n'
              'Solo un altavoz lleva código: el que pone la música. El '
              'otro es decorado.',
          tipEmoji: '👗',
          tip: 'Kostümler sekmesi kukla seçiliyken açılıyor; sahne '
              'seçiliyken oranın adı "Dekorlar" olur.',
          tipEn: 'The Costumes tab appears when a sprite is selected; with '
              'the stage selected it is called Backdrops.',
          tipDe: 'Der Reiter Kostüme erscheint bei ausgewählter Figur; bei '
              'der Bühne heißt er Bühnenbilder.',
          tipEs: 'La pestaña Disfraces aparece con un objeto seleccionado; '
              'con el escenario se llama Fondos.',
        ),

        ExplanationStep(
          id: 'p2_desen',
          title: 'Dansın İki Bloğu',
          titleEn: 'A Dance in Two Blocks',
          titleDe: 'Ein Tanz in zwei Blöcken',
          titleEs: 'Un baile en dos bloques',
          content:
              'Her dansçının kodu şu:\n\n'
              '   tıklandığında\n'
              '   sürekli tekrarla\n'
              '     sonraki kostüm\n'
              '     0.2 saniye bekle\n\n'
              '"Sonraki kostüm" bloğu sırayı bir ilerletiyor: a → b → c → '
              'd → sonra başa dönüyor. Yani dört resim bir döngüde sonsuza '
              'kadar dönüyor.\n\n'
              'Beklemenin işi ne? Onsuz döngü saniyede otuz kez dönerdi; '
              'karakter dans etmez, TİTRERDİ. 0.2 saniye demek, saniyede '
              'beş kostüm demek — göz bunu rahat rahat takip ediyor.',
          contentEn:
              "Every dancer's code is this:\n\n"
              '   when clicked\n'
              '   forever\n'
              '     next costume\n'
              '     wait 0.2 seconds\n\n'
              'The "next costume" block steps the order forward: a → b → c '
              '→ d → back to the start. Four pictures looping forever.\n\n'
              'What is the wait for? Without it the loop would run thirty '
              'times a second; the character would not dance, it would '
              'FLICKER. 0.2 seconds means five costumes a second — your '
              'eye can follow that comfortably.',
          contentDe:
              'Der Code jedes Tänzers ist dieser:\n\n'
              '   Wenn angeklickt\n'
              '   wiederhole fortlaufend\n'
              '     wechsle zum nächsten Kostüm\n'
              '     warte 0.2 Sekunden\n\n'
              'Der Block «nächstes Kostüm» schaltet weiter: a → b → c → d '
              '→ wieder von vorn. Vier Bilder in einer Endlosschleife.\n\n'
              'Wozu das Warten? Ohne es liefe die Schleife dreißigmal pro '
              'Sekunde; die Figur würde nicht tanzen, sondern FLIMMERN. '
              '0.2 Sekunden heißt fünf Kostüme pro Sekunde — dem kann das '
              'Auge gut folgen.',
          contentEs:
              'El código de cada bailarín es este:\n\n'
              '   al hacer clic\n'
              '   por siempre\n'
              '     siguiente disfraz\n'
              '     esperar 0.2 segundos\n\n'
              'El bloque «siguiente disfraz» avanza el orden: a → b → c → '
              'd → vuelta al principio. Cuatro imágenes en bucle '
              'infinito.\n\n'
              '¿Y la espera? Sin ella el bucle correría treinta veces por '
              'segundo; el personaje no bailaría, PARPADEARÍA. 0.2 '
              'segundos son cinco disfraces por segundo: el ojo lo sigue '
              'sin esfuerzo.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'sonraki kostüm',
              contentEn: 'next costume',
              contentDe: 'wechsle zum nächsten Kostüm',
              contentEs: 'siguiente disfraz',
              color: MBlockKuklaPalette.looks,
              label: 'Görünüm',
              labelEn: 'Looks',
              labelDe: 'Aussehen',
              labelEs: 'Apariencia',
            ),
          ],
        ),

        BlockBuilderStep(
          id: 'p2_build_dans',
          instruction: 'Casey\'yi dans ettir.',
          instructionEn: 'Make Casey dance.',
          instructionDe: 'Lass Casey tanzen.',
          instructionEs: 'Haz bailar a Casey.',
          goal: 'Tıklandığında → sürekli { sonraki kostüm, 0.2 saniye bekle }',
          goalEn: 'When clicked → forever { next costume, wait 0.2 seconds }',
          goalDe: 'Wenn angeklickt → fortlaufend { nächstes Kostüm, warte '
              '0.2 Sekunden }',
          goalEs: 'Al hacer clic → por siempre { siguiente disfraz, esperar '
              '0.2 segundos }',
          availableBlocks: [
            MBlockKuklaBlocks.greenFlag(),
            MBlockKuklaBlocks.forever(),
            MBlockKuklaBlocks.nextCostume(),
            MBlockKuklaBlocks.wait('0.2', id: 'wait_02'),
            MBlockKuklaBlocks.wait('0.5', id: 'wait_05'),
          ],
          correctSequence: [
            'green_flag',
            'k_forever',
            'next_costume',
            'wait_02',
          ],
          mblock: MBlockTezgahAyari(
            bloklar: ['dev_bayrak', 'dev_surekli', 'dev_kostum', 'dev_bekle'],
            cozum: [
              MBlockBeklenen('dev_bayrak'),
              MBlockBeklenen('dev_surekli', icerik: [
                MBlockBeklenen('dev_kostum'),
                MBlockBeklenen('dev_bekle', alanlar: {'SANIYE': '0.2'}),
              ]),
            ],
          ),
          xpReward: 40,
        ),

        MultipleChoiceStep(
          id: 'p2_q1',
          question: '"0.2 saniye bekle" bloğunu silersen ne olur?',
          questionEn: 'What happens if you delete the "wait 0.2 seconds" '
              'block?',
          questionDe: 'Was passiert, wenn du «warte 0.2 Sekunden» löschst?',
          questionEs: '¿Qué pasa si borras «esperar 0.2 segundos»?',
          options: [
            ChoiceOption(
              text: 'Kostümler o kadar hızlı değişir ki dans değil '
                  'titreme görünür',
              textEn: 'Costumes change so fast it looks like flickering, '
                  'not dancing',
              textDe: 'Die Kostüme wechseln so schnell, dass es flimmert '
                  'statt zu tanzen',
              textEs: 'Los disfraces cambian tan rápido que parpadea en '
                  'vez de bailar',
            ),
            ChoiceOption(
              text: 'Hiçbir şey değişmez',
              textEn: 'Nothing changes',
              textDe: 'Es ändert sich nichts',
              textEs: 'No cambia nada',
            ),
            ChoiceOption(
              text: 'Karakter tek kostümde donar',
              textEn: 'The character freezes on one costume',
              textDe: 'Die Figur bleibt auf einem Kostüm stehen',
              textEs: 'El personaje se queda en un disfraz',
            ),
            ChoiceOption(
              text: 'Program hata verip durur',
              textEn: 'The program errors out and stops',
              textDe: 'Das Programm bricht mit einem Fehler ab',
              textEs: 'El programa da error y se detiene',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Döngü bilgisayarın gidebildiği hızda döner — saniyede '
              'onlarca kostüm. Göz bunu ayrı duruşlar olarak göremez, '
              'karakter titriyormuş gibi görünür. Beklemeyi büyütüp '
              'küçültmek dansın hızını ayarlamanın tek yolu.',
          explanationEn:
              'The loop runs as fast as the computer can — dozens of '
              'costumes a second. Your eye cannot separate the poses, so '
              'the character looks like it is vibrating. Changing the wait '
              'is how you set the speed of the dance.',
          explanationDe:
              'Die Schleife läuft so schnell wie der Rechner kann — '
              'dutzende Kostüme pro Sekunde. Das Auge kann die Posen nicht '
              'trennen, die Figur wirkt wie am Zittern. Über die Wartezeit '
              'regelst du das Tempo des Tanzes.',
          explanationEs:
              'El bucle corre tan rápido como puede el ordenador: decenas '
              'de disfraces por segundo. El ojo no separa las posturas y '
              'el personaje parece vibrar. Cambiar la espera es la forma '
              'de ajustar la velocidad del baile.',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'p2_uc_dansci',
          title: 'Üç Dansçı, Aynı Kod',
          titleEn: 'Three Dancers, One Code',
          titleDe: 'Drei Tänzer, ein Code',
          titleEs: 'Tres bailarines, un código',
          content:
              'Aynı iki bloğu Dorian ve Jordyn\'e de ver. Üçü birden dans '
              'etmeye başlıyor.\n\n'
              'Ama bir şey dikkatini çekecek: üçü de aynı anda, aynı '
              'ritimde kıpırdıyor — tek bir dansçının üç kopyası gibi. '
              'Gerçek bir parti böyle görünmez.\n\n'
              'İki basit çözüm:\n\n'
              '• Bekleme sürelerini ayır: 0.2 / 0.25 / 0.15. Artık herkes '
              'kendi hızında.\n'
              '• Ya da birinin başına "0.1 saniye bekle" koy: aynı hızda '
              'ama geriden başlar, adımlar kayar.\n\n'
              'Küçük farklar bir topluluğu kalabalık gibi gösteriyor. Bu, '
              'oyun yapımcılarının sürekli kullandığı bir numara.',
          contentEn:
              'Give the same two blocks to Dorian and Jordyn. All three '
              'start dancing.\n\n'
              'But you will notice something: they all move at the same '
              'time, in the same rhythm — like three copies of one dancer. '
              'A real party does not look like that.\n\n'
              'Two simple fixes:\n\n'
              '• Use different waits: 0.2 / 0.25 / 0.15. Now everyone has '
              'their own speed.\n'
              '• Or put "wait 0.1 seconds" at the top of one of them: same '
              'speed, but it starts late and the steps shift.\n\n'
              'Small differences make a group look like a crowd. Game '
              'makers use this trick all the time.',
          contentDe:
              'Gib dieselben zwei Blöcke an Dorian und Jordyn. Alle drei '
              'fangen an zu tanzen.\n\n'
              'Aber dir fällt etwas auf: alle bewegen sich gleichzeitig im '
              'selben Rhythmus — wie drei Kopien eines Tänzers. So sieht '
              'keine echte Party aus.\n\n'
              'Zwei einfache Lösungen:\n\n'
              '• Verschiedene Wartezeiten: 0.2 / 0.25 / 0.15. Jetzt hat '
              'jeder sein Tempo.\n'
              '• Oder setz bei einem oben «warte 0.1 Sekunden»: gleiches '
              'Tempo, aber späterer Start, die Schritte verschieben '
              'sich.\n\n'
              'Kleine Unterschiede lassen eine Gruppe wie eine Menge '
              'wirken. Spieleentwickler nutzen diesen Trick ständig.',
          contentEs:
              'Dale los mismos dos bloques a Dorian y a Jordyn. Los tres '
              'empiezan a bailar.\n\n'
              'Pero notarás algo: se mueven a la vez, con el mismo ritmo, '
              'como tres copias del mismo bailarín. Una fiesta de verdad '
              'no es así.\n\n'
              'Dos soluciones simples:\n\n'
              '• Esperas distintas: 0.2 / 0.25 / 0.15. Cada uno con su '
              'velocidad.\n'
              '• O pon «esperar 0.1 segundos» al principio de uno: misma '
              'velocidad, pero empieza más tarde y los pasos se '
              'desfasan.\n\n'
              'Las pequeñas diferencias hacen que un grupo parezca una '
              'multitud. Los creadores de juegos usan este truco siempre.',
          tipEmoji: '🎛️',
          tip: 'Orijinal projede üçü de 0.2 saniyeyle dans ediyor. '
              'Değiştirip ikisini yan yana izle — hangisi daha canlı?',
          tipEn: 'In the original project all three use 0.2 seconds. '
              'Change it and watch both versions — which feels more alive?',
          tipDe: 'Im Originalprojekt tanzen alle drei mit 0.2 Sekunden. '
              'Ändere es und vergleiche — was wirkt lebendiger?',
          tipEs: 'En el proyecto original los tres usan 0.2 segundos. '
              'Cámbialo y compara: ¿cuál parece más vivo?',
        ),

        MatchingStep(
          id: 'p2_match',
          instruction: 'Her parçayı işiyle eşleştir.',
          instructionEn: 'Match each piece with its job.',
          instructionDe: 'Ordne jedes Teil seiner Aufgabe zu.',
          instructionEs: 'Une cada pieza con su tarea.',
          pairs: [
            MatchPair(
              id: 'd1',
              left: 'sonraki kostüm',
              right: 'Dört duruşu sırayla gösterir',
              leftEn: 'next costume',
              rightEn: 'Shows the four poses in order',
              leftDe: 'nächstes Kostüm',
              rightDe: 'Zeigt die vier Posen der Reihe nach',
              leftEs: 'siguiente disfraz',
              rightEs: 'Muestra las cuatro posturas en orden',
            ),
            MatchPair(
              id: 'd2',
              left: '0.2 saniye bekle',
              right: 'Dansın hızını belirler',
              leftEn: 'wait 0.2 seconds',
              rightEn: 'Sets the speed of the dance',
              leftDe: 'warte 0.2 Sekunden',
              rightDe: 'Bestimmt das Tempo des Tanzes',
              leftEs: 'esperar 0.2 segundos',
              rightEs: 'Marca la velocidad del baile',
            ),
            MatchPair(
              id: 'd3',
              left: 'Loudspeaker3',
              right: 'Hip Hop müziğini döngüde çalar',
              leftEn: 'Loudspeaker3',
              rightEn: 'Loops the Hip Hop track',
              leftDe: 'Loudspeaker3',
              rightDe: 'Spielt Hip Hop in der Schleife',
              leftEs: 'Loudspeaker3',
              rightEs: 'Repite la música Hip Hop',
            ),
            MatchPair(
              id: 'd4',
              left: 'Spotlight-stage2',
              right: 'Sahne dekoru — kod almaz',
              leftEn: 'Spotlight-stage2',
              rightEn: 'The backdrop — no code',
              leftDe: 'Spotlight-stage2',
              rightDe: 'Das Bühnenbild — ohne Code',
              leftEs: 'Spotlight-stage2',
              rightEs: 'El fondo: sin código',
            ),
          ],
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'p2_ozet',
          title: 'Parti Başlasın!',
          titleEn: 'Let the Party Start!',
          titleDe: 'Die Party kann beginnen!',
          titleEs: '¡Que empiece la fiesta!',
          content: '💃 Kontrol listesi:\n\n'
              '✓ Spot ışıklı sahne seçili\n'
              '✓ Üç dansçının da kodu var (sürekli { sonraki kostüm, bekle })\n'
              '✓ Hoparlörde Hip Hop döngüde çalıyor\n'
              '✓ Bekleme sürelerini oynayıp kendi ritmini kurdun\n\n'
              'İki proje, iki ayrı hareket yolu öğrendin: akvaryumda kukla '
              'YER değiştiriyordu, burada KOSTÜM değişiyor. Üçüncüsünü '
              'kendin dene: dans eden karakteri aynı anda sahnede '
              'yürüt — iki bloğu birleştirmen yeterli.',
          contentEn: '💃 Checklist:\n\n'
              '✓ Spotlight backdrop selected\n'
              '✓ All three dancers have code (forever { next costume, '
              'wait })\n'
              '✓ The Hip Hop track loops on the loudspeaker\n'
              '✓ You played with the waits and found your own rhythm\n\n'
              'Two projects, two ways to move: in the aquarium the sprite '
              'changed PLACE, here it changes COSTUME. Try a third '
              'yourself: make a dancing character walk across the stage at '
              'the same time — you only need to combine the two.',
          contentDe: '💃 Checkliste:\n\n'
              '✓ Spotlight-Bühnenbild gewählt\n'
              '✓ Alle drei Tänzer haben Code (fortlaufend { nächstes '
              'Kostüm, warten })\n'
              '✓ Der Hip-Hop-Track läuft in der Schleife\n'
              '✓ Du hast mit den Wartezeiten deinen Rhythmus gefunden\n\n'
              'Zwei Projekte, zwei Wege zur Bewegung: im Aquarium '
              'wechselte die Figur den ORT, hier das KOSTÜM. Probier ein '
              'drittes: lass eine tanzende Figur gleichzeitig über die '
              'Bühne laufen — du musst nur beides verbinden.',
          contentEs: '💃 Lista de control:\n\n'
              '✓ Fondo con focos elegido\n'
              '✓ Los tres bailarines tienen código (por siempre { '
              'siguiente disfraz, esperar })\n'
              '✓ La música Hip Hop suena en bucle\n'
              '✓ Jugaste con las esperas y encontraste tu ritmo\n\n'
              'Dos proyectos, dos formas de moverse: en el acuario el '
              'objeto cambiaba de SITIO, aquí cambia de DISFRAZ. Prueba '
              'un tercero: que un personaje baile y camine por el '
              'escenario a la vez; solo tienes que juntar las dos cosas.',
          tipEmoji: '🏆',
          tip: 'Dans Ustası rozetini kazandın!',
          tipEn: 'You earned the Dance badge!',
          tipDe: 'Du hast das Tanz-Abzeichen verdient!',
          tipEs: '¡Has ganado la insignia del Baile!',
        ),
      ],
    ),

    // ------------------------------------------------------- Proje 3
    // Sayilar tool/mblock_projeleri/elma_toplama.mblock dosyasindan:
    // elma x -201..155 arasi rastgele, y 197; 0.3 saniyede bir ikiz;
    // ikiz her adimda y -8; kase y -122 ve fareyi izliyor; sure 30.
    // Kahverengi (#663b00) Blue Sky arka planinin en altindaki toprak
    // seridi — kacirilan elma oraya degince siliniyor.
    InteractiveLesson(
      id: 'mblock_5_3',
      courseId: 'mblock',
      title: 'Proje: Elma Toplama Oyunu',
      subtitle: 'İlk oyunun: puan, süre ve gökten yağan ikizler',
      titleEn: 'Project: Apple Catcher',
      titleDe: 'Projekt: Äpfel fangen',
      titleEs: 'Proyecto: Atrapa manzanas',
      subtitleEn: 'Your first game: score, timer and raining clones',
      subtitleDe: 'Dein erstes Spiel: Punkte, Zeit und fallende Klone',
      subtitleEs: 'Tu primer juego: puntos, tiempo y clones que caen',
      order: 14,
      xpReward: 150,
      badge: 'apple_catcher',
      steps: [
        IntroStep(
          id: 'p3_intro',
          mascotEmoji: '🍎',
          mascotMessage:
              'Akvaryumu izledin, dans partisini izledin. Bu sefer '
              'izlemeyeceksin — OYNAYACAKSIN.\n\n'
              'Gökten elmalar yağıyor, sen fareyle kaseyi sağa sola '
              'kaydırıp onları topluyorsun. Her elma bir puan, elinde 30 '
              'saniye var.\n\n'
              'Bir oyunu oyun yapan üç şey burada: oyuncunun yönettiği '
              'bir şey (kase), tutulan bir puan ve biten bir süre.',
          mascotMessageEn:
              'You watched the aquarium, you watched the dance party. '
              'This time you will not watch — you will PLAY.\n\n'
              'Apples rain from the sky and you slide a bowl left and '
              'right with the mouse to catch them. Every apple is one '
              'point, and you have 30 seconds.\n\n'
              'Three things turn a program into a game, and all three are '
              'here: something the player controls (the bowl), a score '
              'and a timer that runs out.',
          mascotMessageDe:
              'Du hast das Aquarium angeschaut, die Tanzparty auch. '
              'Diesmal schaust du nicht zu — du SPIELST.\n\n'
              'Äpfel fallen vom Himmel, und du schiebst mit der Maus eine '
              'Schüssel hin und her, um sie zu fangen. Jeder Apfel ist '
              'ein Punkt, du hast 30 Sekunden.\n\n'
              'Drei Dinge machen aus einem Programm ein Spiel, und alle '
              'drei sind hier: etwas, das der Spieler steuert (die '
              'Schüssel), ein Punktestand und eine ablaufende Zeit.',
          mascotMessageEs:
              'Viste el acuario, viste la fiesta de baile. Esta vez no '
              'vas a mirar: vas a JUGAR.\n\n'
              'Llueven manzanas del cielo y tú mueves un cuenco a '
              'izquierda y derecha con el ratón para atraparlas. Cada '
              'manzana es un punto y tienes 30 segundos.\n\n'
              'Tres cosas convierten un programa en un juego, y las tres '
              'están aquí: algo que controla el jugador (el cuenco), una '
              'puntuación y un tiempo que se acaba.',
          highlights: [
            'Kaseyi fare yönetiyor',
            'Elmalar ikiz olarak doğuyor',
            'Puan ve 30 saniyelik süre',
          ],
          highlightsEn: [
            'The mouse steers the bowl',
            'Apples are born as clones',
            'A score and a 30-second timer',
          ],
          highlightsDe: [
            'Die Maus steuert die Schüssel',
            'Äpfel entstehen als Klone',
            'Punkte und 30 Sekunden Zeit',
          ],
          highlightsEs: [
            'El ratón guía el cuenco',
            'Las manzanas nacen como clones',
            'Puntos y 30 segundos',
          ],
        ),

        ExplanationStep(
          id: 'p3_kurulum',
          title: 'Sahne, İki Kukla, İki Değişken',
          titleEn: 'A Stage, Two Sprites, Two Variables',
          titleDe: 'Eine Bühne, zwei Figuren, zwei Variablen',
          titleEs: 'Un escenario, dos objetos, dos variables',
          content:
              'mBlock 5\'te yeni bir proje aç.\n\n'
              '• Sahne → arka plan: "Blue Sky" (mavi gök, altta '
              'kahverengi toprak şeridi)\n'
              '• Kukla: "Apple" → adını "Elma" yap\n'
              '• Kukla: "Fruit Bowl" → adını "Kase" yap\n\n'
              'Sonra Değişkenler kategorisinde "Bir Değişken Oluştur" ile '
              'iki değişken aç, ikisi de "tüm kuklalar için" olsun:\n\n'
              '• toplananelma — puan\n'
              '• süre — kalan saniye\n\n'
              'Değişkenin yanındaki kutu işaretliyse sahnenin köşesinde '
              'bir gösterge çıkar. Oyuncu puanı ve süreyi oradan görüyor; '
              'ayrıca bir yazı kuklası yapmana gerek yok.',
          contentEn:
              'Open a new project in mBlock 5.\n\n'
              '• Stage → backdrop: "Blue Sky" (blue sky, a brown strip '
              'of ground at the bottom)\n'
              '• Sprite: "Apple" → rename it "Elma"\n'
              '• Sprite: "Fruit Bowl" → rename it "Kase"\n\n'
              'Then, in the Variables category, use "Make a Variable" to '
              'create two variables, both "for all sprites":\n\n'
              '• toplananelma — the score\n'
              '• süre — seconds left\n\n'
              'If the box next to a variable is ticked, a display appears '
              'in the corner of the stage. The player sees score and time '
              'there; you do not need an extra text sprite.',
          contentDe:
              'Öffne ein neues Projekt in mBlock 5.\n\n'
              '• Bühne → Bühnenbild: «Blue Sky» (blauer Himmel, unten ein '
              'brauner Erdstreifen)\n'
              '• Figur: «Apple» → umbenennen in «Elma»\n'
              '• Figur: «Fruit Bowl» → umbenennen in «Kase»\n\n'
              'Dann legst du unter Variablen mit «Neue Variable» zwei '
              'Variablen an, beide «für alle Figuren»:\n\n'
              '• toplananelma — der Punktestand\n'
              '• süre — die restlichen Sekunden\n\n'
              'Ist das Kästchen neben einer Variable angehakt, erscheint '
              'in der Bühnenecke eine Anzeige. Dort sieht der Spieler '
              'Punkte und Zeit; eine extra Textfigur brauchst du nicht.',
          contentEs:
              'Abre un proyecto nuevo en mBlock 5.\n\n'
              '• Escenario → fondo: «Blue Sky» (cielo azul, abajo una '
              'franja marrón de tierra)\n'
              '• Objeto: «Apple» → cámbiale el nombre a «Elma»\n'
              '• Objeto: «Fruit Bowl» → cámbiale el nombre a «Kase»\n\n'
              'Después, en Variables, usa «Crear una variable» para hacer '
              'dos variables, las dos «para todos los objetos»:\n\n'
              '• toplananelma: la puntuación\n'
              '• süre: los segundos que quedan\n\n'
              'Si la casilla junto a la variable está marcada, aparece un '
              'marcador en la esquina del escenario. Ahí el jugador ve '
              'puntos y tiempo; no hace falta otro objeto de texto.',
          tipEmoji: '🏷️',
          tip: 'Adları dosyadaki gibi bıraktık: Elma, Kase, toplananelma, '
              'süre. Sen istediğin adı verebilirsin — yeter ki bloklarda '
              'aynısını seç.',
          tipEn: 'We kept the names from the project file: Elma (apple), '
              'Kase (bowl), toplananelma, süre. You can pick your own — '
              'just choose the same ones in the blocks.',
          tipDe: 'Wir haben die Namen aus der Projektdatei behalten: Elma '
              '(Apfel), Kase (Schüssel), toplananelma, süre. Du kannst '
              'eigene wählen — nimm sie dann auch in den Blöcken.',
          tipEs: 'Dejamos los nombres del archivo del proyecto: Elma '
              '(manzana), Kase (cuenco), toplananelma, süre. Puedes usar '
              'otros; elige los mismos en los bloques.',
        ),

        ExplanationStep(
          id: 'p3_kase',
          title: 'Kase Fareyi İzliyor',
          titleEn: 'The Bowl Follows the Mouse',
          titleDe: 'Die Schüssel folgt der Maus',
          titleEs: 'El cuenco sigue al ratón',
          content:
              'Kase kuklasının kodu:\n\n'
              '   tıklandığında\n'
              '   y konumunu -122 yap\n'
              '   sürekli tekrarla\n'
              '     x konumunu (farenin x i) yap\n\n'
              'Sahnede x sağ-sol, y yukarı-aşağı demek.\n\n'
              '• y -122 → kase sahnenin alt kısmına, toprağın hemen '
              'üstüne yerleşiyor ve orada kalıyor.\n'
              '• "farenin x i" bir DEĞER bloğu: farenin o an sahnede '
              'nerede olduğunu söylüyor. Kasenin x\'ini sürekli ona '
              'eşitlersen kase fareyi yatayda izliyor ama asla yukarı '
              'kalkmıyor.\n\n'
              'Oval "farenin x i" bloğu Algılama kategorisinde; onu "x '
              'konumunu … yap" bloğunun beyaz kutusuna sürükleyip bırak.',
          contentEn:
              "The Kase (bowl) sprite's code:\n\n"
              '   when clicked\n'
              '   set y to -122\n'
              '   forever\n'
              '     set x to (mouse x)\n\n'
              'On the stage, x means left-right and y means up-down.\n\n'
              '• y -122 → the bowl sits near the bottom, just above the '
              'ground, and stays there.\n'
              '• "mouse x" is a VALUE block: it tells you where the mouse '
              'is on the stage right now. Keep setting the bowl\'s x to '
              'it and the bowl follows the mouse sideways but never '
              'lifts off.\n\n'
              'The round "mouse x" block is in Sensing; drag it into the '
              'white slot of "set x to …".',
          contentDe:
              'Der Code der Figur Kase (Schüssel):\n\n'
              '   Wenn angeklickt\n'
              '   setze y auf -122\n'
              '   wiederhole fortlaufend\n'
              '     setze x auf (Maus x-Position)\n\n'
              'Auf der Bühne heißt x links-rechts und y oben-unten.\n\n'
              '• y -122 → die Schüssel steht unten, knapp über der Erde, '
              'und bleibt dort.\n'
              '• «Maus x-Position» ist ein WERT-Block: er sagt, wo die '
              'Maus gerade auf der Bühne ist. Setzt du das x der '
              'Schüssel ständig darauf, folgt sie der Maus seitlich, '
              'hebt aber nie ab.\n\n'
              'Der runde Block «Maus x-Position» steht unter Fühlen; zieh '
              'ihn in das weiße Feld von «setze x auf …».',
          contentEs:
              'El código del objeto Kase (cuenco):\n\n'
              '   al hacer clic\n'
              '   dar a y el valor -122\n'
              '   por siempre\n'
              '     dar a x el valor (posición x del ratón)\n\n'
              'En el escenario, x es izquierda-derecha e y es '
              'arriba-abajo.\n\n'
              '• y -122 → el cuenco queda abajo, justo encima de la '
              'tierra, y no se mueve de ahí.\n'
              '• «posición x del ratón» es un bloque de VALOR: dice dónde '
              'está el ratón ahora mismo. Si igualas la x del cuenco a '
              'ella todo el rato, el cuenco sigue al ratón de lado pero '
              'nunca sube.\n\n'
              'El bloque redondo «posición x del ratón» está en Sensores; '
              'arrástralo al hueco blanco de «dar a x el valor …».',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'farenin x i',
              contentEn: 'mouse x',
              contentDe: 'Maus x-Position',
              contentEs: 'posición x del ratón',
              color: MBlockKuklaPalette.sensing,
              label: 'Algılama',
              labelEn: 'Sensing',
              labelDe: 'Fühlen',
              labelEs: 'Sensores',
            ),
          ],
        ),

        BlockBuilderStep(
          id: 'p3_build_kase',
          instruction: 'Kaseyi fareye bağla.',
          instructionEn: 'Hook the bowl to the mouse.',
          instructionDe: 'Verbinde die Schüssel mit der Maus.',
          instructionEs: 'Engancha el cuenco al ratón.',
          goal: 'Tıklandığında → y konumunu -122 yap → sürekli { x '
              'konumunu (farenin x i) yap }',
          goalEn: 'When clicked → set y to -122 → forever { set x to '
              '(mouse x) }',
          goalDe: 'Wenn angeklickt → setze y auf -122 → fortlaufend { '
              'setze x auf (Maus x-Position) }',
          goalEs: 'Al hacer clic → dar a y el valor -122 → por siempre { '
              'dar a x el valor (posición x del ratón) }',
          availableBlocks: [
            MBlockKuklaBlocks.greenFlag(),
            MBlockKuklaBlocks.setY('-122', id: 'set_y_kase'),
            MBlockKuklaBlocks.forever(),
            MBlockKuklaBlocks.setXToMouseX(),
            MBlockKuklaBlocks.changeY('-8', id: 'change_y_kase'),
          ],
          correctSequence: [
            'green_flag',
            'set_y_kase',
            'k_forever',
            'set_x_mouse',
          ],
          mblock: MBlockTezgahAyari(
            bloklar: [
              'dev_bayrak',
              'dev_y_yap',
              'dev_surekli',
              'dev_x_yap',
              'dev_fare_x',
              'dev_y_degistir',
            ],
            cozum: [
              MBlockBeklenen('dev_bayrak'),
              MBlockBeklenen('dev_y_yap', alanlar: {'Y': '-122'}),
              MBlockBeklenen('dev_surekli', icerik: [
                MBlockBeklenen('dev_x_yap', girdiler: {
                  'X': MBlockBeklenen('dev_fare_x'),
                }),
              ]),
            ],
          ),
          xpReward: 40,
        ),

        ExplanationStep(
          id: 'p3_ikiz',
          title: 'Tek Elma, Sonsuz İkiz',
          titleEn: 'One Apple, Endless Clones',
          titleDe: 'Ein Apfel, endlos viele Klone',
          titleEs: 'Una manzana, clones sin fin',
          content:
              'Gökten yüzlerce elma yağacak ama projede yalnızca BİR elma '
              'kuklası var. Gerisi onun İKİZLERİ.\n\n'
              'Elma kuklasının ilk kodu bir elma fabrikası:\n\n'
              '   tıklandığında\n'
              '   toplananelma değişkenini 0 yap\n'
              '   gizle\n'
              '   sürekli tekrarla\n'
              '     x: (-201 ile 155 arasında rastgele bir sayı seç) y: 197 konumuna git\n'
              '     0.3 saniye bekle\n'
              '     kendim in ikizini yarat\n\n'
              '• Puan her oyunun başında sıfırlanıyor.\n'
              '• Asıl elma GİZLENİYOR: o sadece fabrika, kendisi '
              'düşmüyor.\n'
              '• y 197 sahnenin tepesi; x her seferinde rastgele, yani '
              'elmalar hep farklı yerden düşüyor.\n'
              '• 0.3 saniyede bir yeni ikiz: saniyede üç elmadan biraz '
              'fazla.',
          contentEn:
              'Hundreds of apples will fall, but the project has only ONE '
              'apple sprite. The rest are its CLONES.\n\n'
              "The apple's first script is an apple factory:\n\n"
              '   when clicked\n'
              '   set toplananelma to 0\n'
              '   hide\n'
              '   forever\n'
              '     go to x: (pick random -201 to 155) y: 197\n'
              '     wait 0.3 seconds\n'
              '     create clone of myself\n\n'
              '• The score goes back to zero at the start of every game.\n'
              '• The original apple HIDES: it is only the factory, it '
              'never falls itself.\n'
              '• y 197 is the top of the stage; x is random each time, so '
              'apples fall from different places.\n'
              '• A new clone every 0.3 seconds: a little over three '
              'apples a second.',
          contentDe:
              'Hunderte Äpfel werden fallen, aber im Projekt gibt es nur '
              'EINE Apfelfigur. Der Rest sind ihre KLONE.\n\n'
              'Das erste Skript des Apfels ist eine Apfelfabrik:\n\n'
              '   Wenn angeklickt\n'
              '   setze toplananelma auf 0\n'
              '   verstecke dich\n'
              '   wiederhole fortlaufend\n'
              '     gehe zu x: (Zufallszahl von -201 bis 155) y: 197\n'
              '     warte 0.3 Sekunden\n'
              '     erzeuge Klon von mir selbst\n\n'
              '• Der Punktestand startet jedes Spiel bei null.\n'
              '• Der Original-Apfel VERSTECKT sich: er ist nur die '
              'Fabrik und fällt selbst nie.\n'
              '• y 197 ist der obere Bühnenrand; x ist jedes Mal zufällig, '
              'also fallen die Äpfel an verschiedenen Stellen.\n'
              '• Alle 0.3 Sekunden ein neuer Klon: gut drei Äpfel pro '
              'Sekunde.',
          contentEs:
              'Caerán cientos de manzanas, pero el proyecto solo tiene UN '
              'objeto manzana. El resto son sus CLONES.\n\n'
              'El primer programa de la manzana es una fábrica de '
              'manzanas:\n\n'
              '   al hacer clic\n'
              '   dar a toplananelma el valor 0\n'
              '   esconder\n'
              '   por siempre\n'
              '     ir a x: (número aleatorio entre -201 y 155) y: 197\n'
              '     esperar 0.3 segundos\n'
              '     crear clon de mí mismo\n\n'
              '• La puntuación vuelve a cero al empezar cada partida.\n'
              '• La manzana original se ESCONDE: solo es la fábrica, '
              'nunca cae.\n'
              '• y 197 es la parte de arriba del escenario; x es '
              'aleatoria cada vez, así que caen desde sitios distintos.\n'
              '• Un clon nuevo cada 0.3 segundos: algo más de tres '
              'manzanas por segundo.',
          tipEmoji: '🧬',
          tip: 'Scratch ve mBlock Türkçede "clone" kelimesine "ikiz" '
              'diyor. Kontrol kategorisinde üç ikiz bloğu var: ikizini '
              'yarat, ikiz olarak başladığımda, bu ikizi sil.',
          tipEn: 'The Control category has three clone blocks: create '
              'clone of, when I start as a clone, delete this clone.',
          tipDe: 'In der Kategorie Steuerung gibt es drei Klon-Blöcke: '
              'erzeuge Klon von, Wenn ich als Klon entstehe, lösche '
              'diesen Klon.',
          tipEs: 'En la categoría Control hay tres bloques de clones: '
              'crear clon de, al comenzar como clon, eliminar este clon.',
        ),

        MultipleChoiceStep(
          id: 'p3_q1',
          question: 'Asıl elma neden en başta "gizle" bloğunu çalıştırıyor?',
          questionEn: 'Why does the original apple run "hide" at the '
              'start?',
          questionDe: 'Warum führt der Original-Apfel am Anfang '
              '«verstecke dich» aus?',
          questionEs: '¿Por qué la manzana original ejecuta «esconder» al '
              'principio?',
          options: [
            ChoiceOption(
              text: 'O sadece ikiz üretiyor; gizlenmezse tepede kıpırdayan '
                  'ama hiç düşmeyen bir elma görünür',
              textEn: 'It only makes clones; if it stayed visible you would '
                  'see an apple jumping around at the top that never falls',
              textDe: 'Er erzeugt nur Klone; sichtbar würde oben ein '
                  'springender Apfel bleiben, der nie fällt',
              textEs: 'Solo fabrica clones; si se viera, habría una '
                  'manzana saltando arriba que nunca cae',
            ),
            ChoiceOption(
              text: 'Gizlenmezse ikiz yaratamaz',
              textEn: 'It cannot create clones unless it is hidden',
              textDe: 'Ohne Verstecken kann er keine Klone erzeugen',
              textEs: 'Si no se esconde no puede crear clones',
            ),
            ChoiceOption(
              text: 'Puanı sıfırlamak için',
              textEn: 'To reset the score',
              textDe: 'Um die Punkte zurückzusetzen',
              textEs: 'Para poner los puntos a cero',
            ),
            ChoiceOption(
              text: 'Oyunu yavaşlatmak için',
              textEn: 'To slow the game down',
              textDe: 'Um das Spiel langsamer zu machen',
              textEs: 'Para hacer el juego más lento',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Asıl elma her 0.3 saniyede rastgele bir yere ışınlanıyor '
              've orada ikiz bırakıyor. Görünür kalsaydı tepede sürekli '
              'yer değiştiren tuhaf bir elma olurdu. Gizli bir kuklanın '
              'ikizi de gizli doğar — bu yüzden ikiz kendi kodunda ilk iş '
              '"göster" diyor.',
          explanationEn:
              'The original apple jumps to a random spot every 0.3 '
              'seconds and leaves a clone there. If it were visible, a '
              'strange apple would keep hopping around at the top. A '
              'clone of a hidden sprite is born hidden too — that is why '
              'the clone says "show" first thing.',
          explanationDe:
              'Der Original-Apfel springt alle 0.3 Sekunden an eine '
              'zufällige Stelle und hinterlässt dort einen Klon. Wäre er '
              'sichtbar, hüpfte oben ständig ein seltsamer Apfel herum. '
              'Der Klon einer versteckten Figur ist auch versteckt — '
              'darum sagt der Klon als Erstes «zeige dich».',
          explanationEs:
              'La manzana original salta a un sitio aleatorio cada 0.3 '
              'segundos y deja allí un clon. Si se viera, habría una '
              'manzana rara saltando arriba sin parar. El clon de un '
              'objeto escondido también nace escondido: por eso lo '
              'primero que hace el clon es «mostrar».',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'p3_dusus',
          title: 'Bir İkizin Hayatı',
          titleEn: 'The Life of a Clone',
          titleDe: 'Das Leben eines Klons',
          titleEs: 'La vida de un clon',
          content:
              'Her ikiz doğduğu an kendi kodunu çalıştırıyor:\n\n'
              '   ikiz olarak başladığımda\n'
              '   göster\n'
              '   sürekli tekrarla\n'
              '     y konumunu -8 değiştir\n'
              '     eğer <Kase e değiyor mu?> ise\n'
              '       toplananelma i 1 kadar değiştir\n'
              '       bu ikizi sil\n'
              '     eğer <rengine değiyor mu?> ise   (kahverengi)\n'
              '       bu ikizi sil\n\n'
              '• y -8: her turda 8 adım aşağı. Düşmek bu kadar.\n'
              '• Kaseye değerse puan bir artıyor ve elma yok oluyor — '
              'kaseye girmiş gibi.\n'
              '• Kaçırırsa en alttaki kahverengi toprağa değiyor ve yine '
              'siliniyor.\n\n'
              'Silmek neden şart? Silinmeyen ikizler ekranın dışında '
              'birikir; mBlock bir süre sonra yeni ikiz yaratmayı '
              'bırakır ve yağmur durur.',
          contentEn:
              'Every clone runs its own code the moment it is born:\n\n'
              '   when I start as a clone\n'
              '   show\n'
              '   forever\n'
              '     change y by -8\n'
              '     if <touching Kase?> then\n'
              '       change toplananelma by 1\n'
              '       delete this clone\n'
              '     if <touching color ?> then   (brown)\n'
              '       delete this clone\n\n'
              '• y -8: eight steps down every round. That is all falling '
              'is.\n'
              '• If it touches the bowl the score goes up by one and the '
              'apple disappears — as if it dropped in.\n'
              '• If it is missed, it touches the brown ground at the '
              'bottom and is deleted too.\n\n'
              'Why delete at all? Clones that are never deleted pile up '
              'off screen; after a while mBlock stops making new clones '
              'and the rain stops.',
          contentDe:
              'Jeder Klon startet seinen eigenen Code, sobald er '
              'entsteht:\n\n'
              '   Wenn ich als Klon entstehe\n'
              '   zeige dich\n'
              '   wiederhole fortlaufend\n'
              '     ändere y um -8\n'
              '     falls <wird Kase berührt?>, dann\n'
              '       ändere toplananelma um 1\n'
              '       lösche diesen Klon\n'
              '     falls <wird Farbe berührt?>, dann   (braun)\n'
              '       lösche diesen Klon\n\n'
              '• y -8: jede Runde acht Schritte nach unten. Mehr ist '
              'Fallen nicht.\n'
              '• Berührt er die Schüssel, gibt es einen Punkt und der '
              'Apfel verschwindet — als wäre er hineingefallen.\n'
              '• Wird er verpasst, berührt er unten die braune Erde und '
              'wird ebenfalls gelöscht.\n\n'
              'Warum überhaupt löschen? Nie gelöschte Klone sammeln sich '
              'außerhalb des Bildschirms; irgendwann erzeugt mBlock keine '
              'neuen mehr, und der Regen hört auf.',
          contentEs:
              'Cada clon ejecuta su propio código en cuanto nace:\n\n'
              '   al comenzar como clon\n'
              '   mostrar\n'
              '   por siempre\n'
              '     sumar a y -8\n'
              '     si <¿tocando Kase?> entonces\n'
              '       sumar a toplananelma 1\n'
              '       eliminar este clon\n'
              '     si <¿tocando el color ?> entonces   (marrón)\n'
              '       eliminar este clon\n\n'
              '• y -8: ocho pasos hacia abajo en cada vuelta. Caer es '
              'solo eso.\n'
              '• Si toca el cuenco, suma un punto y la manzana '
              'desaparece, como si hubiera caído dentro.\n'
              '• Si se escapa, toca la tierra marrón de abajo y también '
              'se elimina.\n\n'
              '¿Por qué eliminar? Los clones que nunca se borran se '
              'acumulan fuera de la pantalla; al rato mBlock deja de '
              'crear clones nuevos y la lluvia se para.',
          tipEmoji: '🎨',
          tip: 'Renk kutusuna tıklayınca damlalık çıkıyor; sahnedeki '
              'kahverengi toprağa tıkla, renk kendiliğinden seçilsin.',
          tipEn: 'Click the colour box and an eyedropper appears; click '
              'the brown ground on the stage to pick the exact colour.',
          tipDe: 'Klick auf das Farbfeld, dann erscheint eine Pipette; '
              'klick auf die braune Erde auf der Bühne.',
          tipEs: 'Pulsa el cuadro de color y aparece un cuentagotas; pulsa '
              'la tierra marrón del escenario para elegir el color.',
        ),

        BlockBuilderStep(
          id: 'p3_build_ikiz',
          instruction: 'İkize düşmeyi ve kaseye girmeyi öğret.',
          instructionEn: 'Teach the clone to fall and land in the bowl.',
          instructionDe: 'Bring dem Klon bei, zu fallen und in der '
              'Schüssel zu landen.',
          instructionEs: 'Enseña al clon a caer y a entrar en el cuenco.',
          goal: 'İkiz olarak başladığımda → göster → sürekli { y -8 '
              'değiştir, eğer Kase e değiyorsa { puan +1, bu ikizi sil } }',
          goalEn: 'When I start as a clone → show → forever { change y by '
              '-8, if touching Kase { score +1, delete this clone } }',
          goalDe: 'Wenn ich als Klon entstehe → zeige dich → fortlaufend { '
              'ändere y um -8, falls Kase berührt { Punkte +1, lösche '
              'diesen Klon } }',
          goalEs: 'Al comenzar como clon → mostrar → por siempre { sumar '
              'a y -8, si toca Kase { puntos +1, eliminar este clon } }',
          availableBlocks: [
            MBlockKuklaBlocks.whenIStartAsClone(),
            MBlockKuklaBlocks.show(),
            MBlockKuklaBlocks.hide(),
            MBlockKuklaBlocks.forever(),
            MBlockKuklaBlocks.changeY('-8', id: 'change_y_elma'),
            MBlockKuklaBlocks.ifTouching('Kase', id: 'if_touching_kase'),
            MBlockKuklaBlocks.changeVariable('toplananelma', '1',
                id: 'change_toplananelma'),
            MBlockKuklaBlocks.deleteThisClone(),
          ],
          correctSequence: [
            'start_as_clone',
            'show',
            'k_forever',
            'change_y_elma',
            'if_touching_kase',
            'change_toplananelma',
            'delete_clone',
          ],
          mblock: MBlockTezgahAyari(
            bloklar: [
              'dev_ikiz_basla',
              'dev_goster',
              'dev_gizle',
              'dev_surekli',
              'dev_y_degistir',
              'dev_eger',
              'dev_dokunuyor',
              'dev_degisken_degistir',
              'dev_ikizi_sil',
            ],
            cozum: [
              MBlockBeklenen('dev_ikiz_basla'),
              MBlockBeklenen('dev_goster'),
              MBlockBeklenen('dev_surekli', icerik: [
                MBlockBeklenen('dev_y_degistir', alanlar: {'DY': '-8'}),
                MBlockBeklenen('dev_eger', girdiler: {
                  'KOSUL': MBlockBeklenen('dev_dokunuyor',
                      alanlar: {'NESNE': 'Kase'}),
                }, icerik: [
                  MBlockBeklenen('dev_degisken_degistir',
                      alanlar: {'AD': 'toplananelma', 'DEGER': '1'}),
                  MBlockBeklenen('dev_ikizi_sil'),
                ]),
              ]),
            ],
          ),
          xpReward: 50,
        ),

        ExplanationStep(
          id: 'p3_sure',
          title: '30 Saniye Geri Sayım',
          titleEn: 'A 30-Second Countdown',
          titleDe: 'Ein 30-Sekunden-Countdown',
          titleEs: 'Cuenta atrás de 30 segundos',
          content:
              'Oyun sonsuza kadar sürerse bir oyun değil. Kase kuklasına '
              'ikinci bir kod ekle:\n\n'
              '   tıklandığında\n'
              '   süre değişkenini 30 yap\n'
              '   <(süre) = 0> olana kadar tekrarla\n'
              '     süre i -1 kadar değiştir\n'
              '     1 saniye bekle\n'
              '   durdur tümü\n\n'
              '• Döngü her turda süreden bir çıkarıp bir saniye '
              'bekliyor: 30, 29, 28… gösterge köşede geri sayıyor.\n'
              '• Süre 0 olunca döngü bitiyor ve "durdur tümü" bütün '
              'kodları — elma fabrikasını, düşen ikizleri, kaseyi — aynı '
              'anda durduruyor.\n\n'
              'Bir kuklanın iki kodu olabilir; ikisi de bayrakla aynı anda '
              'başlar ve yan yana çalışır. Kase bir yandan fareyi '
              'izliyor, bir yandan saati tutuyor.',
          contentEn:
              'A game that never ends is not a game. Add a second script '
              'to the Kase sprite:\n\n'
              '   when clicked\n'
              '   set süre to 30\n'
              '   repeat until <(süre) = 0>\n'
              '     change süre by -1\n'
              '     wait 1 seconds\n'
              '   stop all\n\n'
              '• Each round the loop takes one off the time and waits a '
              'second: 30, 29, 28… the display counts down in the '
              'corner.\n'
              '• When the time reaches 0 the loop ends and "stop all" '
              'halts every script — the apple factory, the falling '
              'clones, the bowl — at once.\n\n'
              'A sprite can have two scripts; both start with the flag '
              'and run side by side. The bowl follows the mouse and keeps '
              'the clock at the same time.',
          contentDe:
              'Ein Spiel, das nie endet, ist kein Spiel. Gib der Figur '
              'Kase ein zweites Skript:\n\n'
              '   Wenn angeklickt\n'
              '   setze süre auf 30\n'
              '   wiederhole bis <(süre) = 0>\n'
              '     ändere süre um -1\n'
              '     warte 1 Sekunden\n'
              '   stoppe alles\n\n'
              '• Jede Runde zieht die Schleife eins von der Zeit ab und '
              'wartet eine Sekunde: 30, 29, 28 … die Anzeige zählt in '
              'der Ecke herunter.\n'
              '• Bei 0 endet die Schleife, und «stoppe alles» hält alle '
              'Skripte — Apfelfabrik, fallende Klone, Schüssel — '
              'gleichzeitig an.\n\n'
              'Eine Figur kann zwei Skripte haben; beide starten mit der '
              'Flagge und laufen nebeneinander. Die Schüssel folgt der '
              'Maus und führt gleichzeitig die Uhr.',
          contentEs:
              'Un juego que nunca acaba no es un juego. Añade un segundo '
              'programa al objeto Kase:\n\n'
              '   al hacer clic\n'
              '   dar a süre el valor 30\n'
              '   repetir hasta que <(süre) = 0>\n'
              '     sumar a süre -1\n'
              '     esperar 1 segundos\n'
              '   detener todos\n\n'
              '• En cada vuelta el bucle resta uno al tiempo y espera un '
              'segundo: 30, 29, 28… el marcador cuenta hacia atrás en la '
              'esquina.\n'
              '• Al llegar a 0 el bucle termina y «detener todos» para '
              'todos los programas —la fábrica de manzanas, los clones, '
              'el cuenco— a la vez.\n\n'
              'Un objeto puede tener dos programas; los dos empiezan con '
              'la bandera y funcionan a la par. El cuenco sigue al ratón '
              'y lleva el reloj al mismo tiempo.',
          tipEmoji: '⏱️',
          tip: '"(süre) = 0" bloğu İşlemler kategorisinde; içine '
              'Değişkenler\'den oval "süre" bloğunu koyuyorsun.',
          tipEn: 'The "( ) = 0" block is in Operators; put the round '
              '"süre" block from Variables inside it.',
          tipDe: 'Der Block «( ) = 0» steht unter Operatoren; setz den '
              'runden «süre»-Block aus Variablen hinein.',
          tipEs: 'El bloque «( ) = 0» está en Operadores; mete dentro el '
              'bloque redondo «süre» de Variables.',
        ),

        MultipleChoiceStep(
          id: 'p3_q2',
          question: 'Geri sayımdaki "1 saniye bekle" bloğunu silersen ne '
              'olur?',
          questionEn: 'What happens if you delete "wait 1 seconds" from '
              'the countdown?',
          questionDe: 'Was passiert, wenn du «warte 1 Sekunden» aus dem '
              'Countdown löschst?',
          questionEs: '¿Qué pasa si quitas «esperar 1 segundos» de la '
              'cuenta atrás?',
          options: [
            ChoiceOption(
              text: 'Süre bir anda 0\'a iner, oyun başlar başlamaz biter',
              textEn: 'The time drops to 0 at once; the game ends as soon '
                  'as it starts',
              textDe: 'Die Zeit fällt sofort auf 0; das Spiel endet, '
                  'kaum dass es beginnt',
              textEs: 'El tiempo cae a 0 de golpe; el juego acaba nada '
                  'más empezar',
            ),
            ChoiceOption(
              text: 'Oyun sonsuza kadar sürer',
              textEn: 'The game goes on forever',
              textDe: 'Das Spiel läuft ewig',
              textEs: 'El juego dura para siempre',
            ),
            ChoiceOption(
              text: 'Elmalar daha hızlı düşer',
              textEn: 'The apples fall faster',
              textDe: 'Die Äpfel fallen schneller',
              textEs: 'Las manzanas caen más rápido',
            ),
            ChoiceOption(
              text: 'Hiçbir şey değişmez',
              textEn: 'Nothing changes',
              textDe: 'Es ändert sich nichts',
              textEs: 'No cambia nada',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Bekleme olmadan döngü 30 turu göz açıp kapayıncaya kadar '
              'bitirir; süre hemen 0 olur ve "durdur tümü" oyunu '
              'kapatır. Saati saat yapan şey her turdaki o bir saniye.',
          explanationEn:
              'Without the wait the loop finishes all 30 rounds in the '
              'blink of an eye; the time hits 0 and "stop all" ends the '
              'game. The one second in every round is what makes the '
              'clock a clock.',
          explanationDe:
              'Ohne Warten schafft die Schleife alle 30 Runden im '
              'Handumdrehen; die Zeit steht sofort auf 0 und «stoppe '
              'alles» beendet das Spiel. Erst die eine Sekunde pro Runde '
              'macht die Uhr zur Uhr.',
          explanationEs:
              'Sin la espera el bucle hace las 30 vueltas en un '
              'parpadeo; el tiempo llega a 0 y «detener todos» termina '
              'el juego. El segundo de cada vuelta es lo que convierte '
              'el bucle en un reloj.',
          xpReward: 20,
        ),

        MatchingStep(
          id: 'p3_match',
          instruction: 'Her bloğu oyundaki işiyle eşleştir.',
          instructionEn: 'Match each block with its job in the game.',
          instructionDe: 'Ordne jeden Block seiner Aufgabe im Spiel zu.',
          instructionEs: 'Une cada bloque con su tarea en el juego.',
          pairs: [
            MatchPair(
              id: 'e1',
              left: 'kendim in ikizini yarat',
              right: 'Gökten yeni bir elma bırakır',
              leftEn: 'create clone of myself',
              rightEn: 'Drops a new apple from the sky',
              leftDe: 'erzeuge Klon von mir selbst',
              rightDe: 'Lässt einen neuen Apfel fallen',
              leftEs: 'crear clon de mí mismo',
              rightEs: 'Suelta una manzana nueva',
            ),
            MatchPair(
              id: 'e2',
              left: 'farenin x i',
              right: 'Kaseyi oyuncunun eline verir',
              leftEn: 'mouse x',
              rightEn: 'Puts the bowl in the player\'s hand',
              leftDe: 'Maus x-Position',
              rightDe: 'Gibt dem Spieler die Schüssel in die Hand',
              leftEs: 'posición x del ratón',
              rightEs: 'Pone el cuenco en manos del jugador',
            ),
            MatchPair(
              id: 'e3',
              left: 'bu ikizi sil',
              right: 'Tutulan ya da kaçan elmayı ortadan kaldırır',
              leftEn: 'delete this clone',
              rightEn: 'Removes a caught or missed apple',
              leftDe: 'lösche diesen Klon',
              rightDe: 'Entfernt einen gefangenen oder verpassten Apfel',
              leftEs: 'eliminar este clon',
              rightEs: 'Quita una manzana atrapada o perdida',
            ),
            MatchPair(
              id: 'e4',
              left: 'durdur tümü',
              right: 'Süre bitince oyunu bitirir',
              leftEn: 'stop all',
              rightEn: 'Ends the game when time is up',
              leftDe: 'stoppe alles',
              rightDe: 'Beendet das Spiel, wenn die Zeit um ist',
              leftEs: 'detener todos',
              rightEs: 'Termina el juego cuando se acaba el tiempo',
            ),
          ],
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'p3_ozet',
          title: 'Oyun Hazır!',
          titleEn: 'Game Ready!',
          titleDe: 'Das Spiel ist fertig!',
          titleEs: '¡Juego listo!',
          content: '🍎 Kontrol listesi:\n\n'
              '✓ Blue Sky arka planı, Elma ve Kase kuklaları\n'
              '✓ toplananelma ve süre değişkenleri köşede görünüyor\n'
              '✓ Kase fareyi izliyor, geri sayımı tutuyor\n'
              '✓ Asıl elma gizli, 0.3 saniyede bir ikiz bırakıyor\n'
              '✓ İkizler düşüyor, kaseye girince puan veriyor, toprağa '
              'değince siliniyor\n\n'
              'Kendi oyununu yap — birkaç fikir:\n\n'
              '• -8 yerine -12 yaz: elmalar hızlanır, oyun zorlaşır.\n'
              '• 0.3 yerine 0.6 yaz: yağmur seyrekleşir.\n'
              '• Kaseye değince "pop" sesi çal — Elma kuklasında zaten '
              'hazır.\n'
              '• İkinci bir kukla ekle, çürük elma: tutarsan puan '
              'düşsün.',
          contentEn: '🍎 Checklist:\n\n'
              '✓ Blue Sky backdrop, Elma and Kase sprites\n'
              '✓ toplananelma and süre show in the corner\n'
              '✓ The bowl follows the mouse and keeps the countdown\n'
              '✓ The original apple is hidden and drops a clone every 0.3 '
              'seconds\n'
              '✓ Clones fall, score when they land in the bowl, vanish on '
              'the ground\n\n'
              'Make it your own game — a few ideas:\n\n'
              '• Write -12 instead of -8: apples fall faster, the game '
              'gets harder.\n'
              '• Write 0.6 instead of 0.3: fewer apples.\n'
              '• Play the "pop" sound when an apple lands — the apple '
              'sprite already has it.\n'
              '• Add a second sprite, a rotten apple: catching it takes a '
              'point away.',
          contentDe: '🍎 Checkliste:\n\n'
              '✓ Bühnenbild Blue Sky, Figuren Elma und Kase\n'
              '✓ toplananelma und süre stehen in der Ecke\n'
              '✓ Die Schüssel folgt der Maus und zählt die Zeit herunter\n'
              '✓ Der Original-Apfel ist versteckt und lässt alle 0.3 '
              'Sekunden einen Klon fallen\n'
              '✓ Klone fallen, geben in der Schüssel Punkte und '
              'verschwinden auf der Erde\n\n'
              'Mach es zu deinem Spiel — ein paar Ideen:\n\n'
              '• Schreib -12 statt -8: die Äpfel fallen schneller.\n'
              '• Schreib 0.6 statt 0.3: es regnet weniger Äpfel.\n'
              '• Spiel beim Fangen den Klang «pop» — der Apfel hat ihn '
              'schon.\n'
              '• Füge einen faulen Apfel hinzu: wer ihn fängt, verliert '
              'einen Punkt.',
          contentEs: '🍎 Lista de control:\n\n'
              '✓ Fondo Blue Sky, objetos Elma y Kase\n'
              '✓ toplananelma y süre se ven en la esquina\n'
              '✓ El cuenco sigue al ratón y lleva la cuenta atrás\n'
              '✓ La manzana original está escondida y suelta un clon cada '
              '0.3 segundos\n'
              '✓ Los clones caen, puntúan en el cuenco y desaparecen en '
              'la tierra\n\n'
              'Hazlo tu juego — algunas ideas:\n\n'
              '• Escribe -12 en vez de -8: las manzanas caen más rápido.\n'
              '• Escribe 0.6 en vez de 0.3: llueven menos manzanas.\n'
              '• Toca el sonido «pop» al atrapar una — la manzana ya lo '
              'tiene.\n'
              '• Añade una manzana podrida: si la atrapas, pierdes un '
              'punto.',
          tipEmoji: '🏆',
          tip: 'Elma Avcısı rozetini kazandın!',
          tipEn: 'You earned the Apple Catcher badge!',
          tipDe: 'Du hast das Apfelfänger-Abzeichen verdient!',
          tipEs: '¡Has ganado la insignia de Atrapamanzanas!',
        ),
      ],
    ),
  ];
}
