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
  ];
}
