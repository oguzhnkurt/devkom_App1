import 'package:flutter/material.dart';

import '../models/interactive_lesson_model.dart';

/// Scratch kursu — Modül 9, 10 ve 11.
///
/// Müfredat sırası Code Club'ın Scratch merdiveninden: operatörler ve
/// rastgelelik (Boat Race, Ghostbusters), veri yapıları (Module 2'nin
/// liste projeleri), fonksiyonlar (My Blocks). METİN KOPYALANMADI —
/// Raspberry Pi Vakfı'nın kaynakları CC BY-SA 4.0 ve share-alike şartı,
/// uyarlanan metni bizim ders metnimizi de aynı lisansa sokardı. Bir
/// müfredatın konu sırası telife tabi değil, ifadesi tabi.
///
/// BLOK YAZILARI NEREDEN GELDİ
/// ---------------------------
/// Uydurulmadı ve çevrilmedi: `assets/mblock/scratch_blocks.min.js`
/// içindeki Scratch'in KENDİ dil dosyalarından dört dilde birebir
/// okundu (OPERATORS_RANDOM, DATA_ADDTOLIST, ...). Bazı Türkçe
/// yazımlar kulağa garip geliyor — "%1 i %2 ye ekle", "%2 in %1 ini
/// sil" gibi. Düzeltmiyoruz: çocuk Scratch'i açtığında bloğu tam
/// olarak bu haliyle görecek.
class ScratchIleriLessonsData {
  ScratchIleriLessonsData._();

  static const Color islemRengi = Color(0xFF59C059);
  static const Color veriRengi = Color(0xFFFF8C1A);
  static const Color listeRengi = Color(0xFFFF661A);
  static const Color kontrolRengi = Color(0xFFFFAB19);
  static const Color olaylarRengi = Color(0xFFFFBF00);
  static const Color hareketRengi = Color(0xFF4C97FF);
  static const Color gorunumRengi = Color(0xFF9966FF);
  static const Color blokRengi = Color(0xFFFF6680);

  static ScratchBlock _bayrak() => const ScratchBlock(
        id: 'green_flag',
        blockType: ScratchBlockType.events,
        shape: ScratchBlockShape.cap,
        label: 'tıklandığında',
        labelEn: 'when green flag clicked',
        labelDe: 'Wenn die grüne Flagge angeklickt',
        labelEs: 'al hacer clic en la bandera verde',
        color: olaylarRengi,
      );

  static ScratchBlock _rastgele(String a, String b, {required String id}) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.operators,
        shape: ScratchBlockShape.reporter,
        label: '$a ile $b arasında rastgele bir sayı seç',
        labelEn: 'pick random $a to $b',
        labelDe: 'Zufallszahl von $a bis $b',
        labelEs: 'número aleatorio entre $a y $b',
        color: islemRengi,
      );

  static ScratchBlock _kucuktur(
    String a,
    String b, {
    required String id,
    String? aEn,
    String? aDe,
    String? aEs,
  }) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.operators,
        shape: ScratchBlockShape.boolean,
        label: '$a < $b',
        labelEn: '${aEn ?? a} < $b',
        labelDe: '${aDe ?? aEn ?? a} < $b',
        labelEs: '${aEs ?? aEn ?? a} < $b',
        color: islemRengi,
      );

  static ScratchBlock _eger({
    required String kosul,
    required String id,
    String? kosulEn,
    String? kosulDe,
    String? kosulEs,
  }) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.control,
        shape: ScratchBlockShape.cBlock,
        label: 'eğer $kosul ise',
        labelEn: 'if ${kosulEn ?? kosul} then',
        labelDe: 'falls ${kosulDe ?? kosulEn ?? kosul}, dann',
        labelEs: 'si ${kosulEs ?? kosulEn ?? kosul} entonces',
        color: kontrolRengi,
      );

  static ScratchBlock _de(String metin,
          {required String id,
          String? en,
          String? de,
          String? es}) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.looks,
        shape: ScratchBlockShape.stack,
        label: '$metin de',
        labelEn: 'say ${en ?? metin}',
        labelDe: 'sage ${de ?? en ?? metin}',
        labelEs: 'decir ${es ?? en ?? metin}',
        color: gorunumRengi,
      );

  static ScratchBlock _listeyeEkle(
    String oge,
    String liste, {
    required String id,
    required String ogeEn,
    required String ogeDe,
    required String ogeEs,
    required String listeEn,
    required String listeDe,
    required String listeEs,
  }) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.variables,
        shape: ScratchBlockShape.stack,
        label: '$oge i $liste ye ekle',
        labelEn: 'add $ogeEn to $listeEn',
        labelDe: 'füge $ogeDe zu $listeDe hinzu',
        labelEs: 'añadir $ogeEs a $listeEs',
        color: listeRengi,
      );

  static ScratchBlock _listedenSil(
    String sira,
    String liste, {
    required String id,
    required String listeEn,
    required String listeDe,
    required String listeEs,
  }) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.variables,
        shape: ScratchBlockShape.stack,
        label: '$liste in $sira ini sil',
        labelEn: 'delete $sira of $listeEn',
        labelDe: 'lösche $sira von $listeDe',
        labelEs: 'borrar $sira de $listeEs',
        color: listeRengi,
      );

  static ScratchBlock _listeUzunlugu(
    String liste, {
    required String id,
    required String listeEn,
    required String listeDe,
    required String listeEs,
  }) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.variables,
        shape: ScratchBlockShape.reporter,
        label: '$liste in uzunluğu',
        labelEn: 'length of $listeEn',
        labelDe: 'Länge von $listeDe',
        labelEs: 'longitud de $listeEs',
        color: listeRengi,
      );

  static ScratchBlock _listeOgesi(
    String sira,
    String liste, {
    required String id,
    required String listeEn,
    required String listeDe,
    required String listeEs,
  }) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.variables,
        shape: ScratchBlockShape.reporter,
        label: "$liste' in $sira öğesi",
        labelEn: 'item $sira of $listeEn',
        labelDe: 'Element $sira von $listeDe',
        labelEs: 'elemento $sira de $listeEs',
        color: listeRengi,
      );

  static ScratchBlock _tanimla(
    String ad, {
    required String id,
    String? en,
    String? de,
    String? es,
  }) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.myBlocks,
        shape: ScratchBlockShape.cap,
        label: '$ad i tanımla',
        labelEn: 'define ${en ?? ad}',
        labelDe: 'Definiere ${de ?? en ?? ad}',
        labelEs: 'definir ${es ?? en ?? ad}',
        color: blokRengi,
      );

  static ScratchBlock _kendiBlok(
    String ad, {
    required String id,
    String? en,
    String? de,
    String? es,
  }) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.myBlocks,
        shape: ScratchBlockShape.stack,
        label: ad,
        labelEn: en ?? ad,
        labelDe: de ?? en ?? ad,
        labelEs: es ?? en ?? ad,
        color: blokRengi,
      );

  static ScratchBlock _tekrarla(
    String kere, {
    required String id,
    String? en,
    String? de,
    String? es,
  }) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.control,
        shape: ScratchBlockShape.cBlock,
        label: '$kere kere tekrarla',
        labelEn: 'repeat ${en ?? kere}',
        labelDe: 'wiederhole ${de ?? en ?? kere} mal',
        labelEs: 'repetir ${es ?? en ?? kere} veces',
        color: kontrolRengi,
      );

  static ScratchBlock _git(String adim, {required String id}) => ScratchBlock(
        id: id,
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.stack,
        label: '$adim adım git',
        labelEn: 'move $adim steps',
        labelDe: 'gehe $adim er Schritt',
        labelEs: 'mover $adim pasos',
        color: hareketRengi,
      );

  static ScratchBlock _don(
    String aci, {
    required String id,
    String? en,
    String? de,
    String? es,
  }) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.stack,
        label: '↻ $aci derece dön',
        labelEn: 'turn ↻ ${en ?? aci} degrees',
        labelDe: 'drehe dich ↻ um ${de ?? en ?? aci} Grad',
        labelEs: 'girar ↻ ${es ?? en ?? aci} grados',
        color: hareketRengi,
      );

  // ==========================================
  // MODÜL 9 — OPERATÖRLER VE ŞANS
  // ==========================================

  static final List<InteractiveLesson> module9 = [
    // ---------------------------------------------------------- Ders 9.1
    InteractiveLesson(
      id: 'scratch_9_1',
      courseId: 'scratch',
      title: 'Rastgele: Her Seferinde Farklı',
      subtitle: 'Şansı programına sokmak',
      titleEn: 'Random: Different Every Time',
      titleDe: 'Zufall: jedes Mal anders',
      titleEs: 'Aleatorio: distinto cada vez',
      subtitleEn: 'Letting chance into your program',
      subtitleDe: 'Zufall in dein Programm holen',
      subtitleEs: 'Dejar entrar el azar en tu programa',
      order: 15,
      xpReward: 70,
      badge: 'random_maker',
      steps: [
        IntroStep(
          id: 's9_1_intro',
          mascotEmoji: '🎲',
          mascotMessage:
              'Şimdiye kadar yazdığın programlar her çalıştırışta aynı '
              'şeyi yapıyordu. Oyunlar böyle değil: zar her atışta başka '
              'bir sayı gösteriyor, düşman her seferinde başka yerden '
              'çıkıyor.\n\n'
              'Tek bir blok bunu sağlıyor. İçine bir alt sınır, bir üst '
              'sınır yazıyorsun; gerisini o hallediyor.',
          mascotMessageEn:
              'So far your programs did exactly the same thing on every '
              'run. Games are not like that: a die shows a new number '
              'each throw, an enemy appears somewhere new each time.\n\n'
              'One block gives you that. You type a lowest and a highest '
              'number; it takes care of the rest.',
          mascotMessageDe:
              'Bisher haben deine Programme bei jedem Start genau '
              'dasselbe gemacht. Spiele sind anders: ein Würfel zeigt '
              'jedes Mal eine neue Zahl, ein Gegner kommt jedes Mal von '
              'woanders.\n\n'
              'Ein einziger Block macht das möglich. Du schreibst eine '
              'kleinste und eine größte Zahl hinein, um den Rest kümmert '
              'er sich.',
          mascotMessageEs:
              'Hasta ahora tus programas hacían lo mismo en cada '
              'ejecución. Los juegos no son así: un dado saca un número '
              'nuevo en cada tirada, un enemigo aparece en otro sitio '
              'cada vez.\n\n'
              'Un solo bloque te da eso. Escribes un número mínimo y uno '
              'máximo; él hace el resto.',
          highlights: [
            'Aynı program, farklı sonuç',
            'Alt sınır ve üst sınır',
            'Oyunların can damarı',
          ],
          highlightsEn: [
            'Same program, different result',
            'A lowest and a highest number',
            'The heartbeat of games',
          ],
          highlightsDe: [
            'Gleiches Programm, anderes Ergebnis',
            'Kleinste und größte Zahl',
            'Der Herzschlag von Spielen',
          ],
          highlightsEs: [
            'Mismo programa, resultado distinto',
            'Un mínimo y un máximo',
            'El latido de los juegos',
          ],
        ),

        ExplanationStep(
          id: 's9_1_exp1',
          title: 'Rastgele Sayı Bloğu',
          titleEn: 'The Pick Random Block',
          titleDe: 'Der Zufallszahl-Block',
          titleEs: 'El bloque de número aleatorio',
          content:
              'Blok İŞLEMLER kategorisinde, yeşil renkte ve OVAL:\n\n'
              '   1 ile 10 arasında rastgele bir sayı seç\n\n'
              'Oval olması önemli. Oval bloklar tek başına çalışmaz; bir '
              'sayının yazıldığı BOŞLUĞA takılırlar. Yani bu bloğu "de" '
              'bloğunun içine, "adım git" bloğunun içine, "x\'i ... yap" '
              'bloğunun içine koyabilirsin.\n\n'
              'İki sınır da sonuca dahil: 1 ile 10 yazarsan 1 de gelebilir, '
              '10 da.',
          contentEn:
              'The block lives in OPERATORS, it is green and OVAL:\n\n'
              '   pick random 1 to 10\n\n'
              'The oval shape matters. Oval blocks never run on their own; '
              'they drop into a SLOT where a number would go. So you can '
              'put this inside "say", inside "move ... steps", inside '
              '"set x to ...".\n\n'
              'Both ends count: with 1 to 10 you can get a 1 and you can '
              'get a 10.',
          contentDe:
              'Der Block steht bei OPERATOREN, ist grün und OVAL:\n\n'
              '   Zufallszahl von 1 bis 10\n\n'
              'Die ovale Form ist wichtig. Ovale Blöcke laufen nie allein; '
              'sie kommen in eine LÜCKE, wo sonst eine Zahl steht. Du '
              'kannst ihn also in «sage», in «gehe ... er Schritt» oder in '
              '«setze x auf ...» stecken.\n\n'
              'Beide Grenzen zählen mit: bei 1 bis 10 kann eine 1 kommen '
              'und auch eine 10.',
          contentEs:
              'El bloque está en OPERADORES, es verde y OVALADO:\n\n'
              '   número aleatorio entre 1 y 10\n\n'
              'La forma ovalada importa. Los bloques ovalados nunca '
              'funcionan solos: entran en un HUECO donde iría un número. '
              'Así que puedes ponerlo dentro de «decir», de «mover ... '
              'pasos» o de «fijar x a ...».\n\n'
              'Los dos extremos cuentan: con 1 y 10 puede salir un 1 y '
              'también un 10.',
          tipEmoji: '🔢',
          tip: 'Sınırlara ondalık yazarsan sonuç da ondalık gelir: '
              '"1.0 ile 10.0" yazmak 4.73 gibi sayılar üretir.',
          tipEn: 'If you type a decimal in a slot the answer becomes '
              'decimal too: "1.0 to 10.0" can give you 4.73.',
          tipDe: 'Schreibst du eine Kommazahl hinein, kommt auch eine '
              'Kommazahl heraus: «1.0 bis 10.0» kann 4.73 ergeben.',
          tipEs: 'Si escribes un decimal, la respuesta sale decimal: '
              '«1.0 a 10.0» puede dar 4.73.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '1 ile 10 arasında rastgele bir sayı seç',
              contentEn: 'pick random 1 to 10',
              contentDe: 'Zufallszahl von 1 bis 10',
              contentEs: 'número aleatorio entre 1 y 10',
              color: islemRengi,
              label: 'İşlemler · oval blok',
              labelEn: 'Operators · oval block',
              labelDe: 'Operatoren · ovaler Block',
              labelEs: 'Operadores · bloque ovalado',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 's9_1_q1',
          question: '"1 ile 6 arasında rastgele bir sayı seç" bloğu hangi '
              'sayıları verebilir?',
          questionEn: 'Which numbers can "pick random 1 to 6" give you?',
          questionDe: 'Welche Zahlen kann «Zufallszahl von 1 bis 6» '
              'liefern?',
          questionEs: '¿Qué números puede dar «número aleatorio entre 1 y '
              '6»?',
          options: [
            ChoiceOption(
              text: '1, 2, 3, 4, 5 veya 6',
              textEn: '1, 2, 3, 4, 5 or 6',
              textDe: '1, 2, 3, 4, 5 oder 6',
              textEs: '1, 2, 3, 4, 5 o 6',
            ),
            ChoiceOption(
              text: 'Sadece 2, 3, 4 ve 5',
              textEn: 'Only 2, 3, 4 and 5',
              textDe: 'Nur 2, 3, 4 und 5',
              textEs: 'Solo 2, 3, 4 y 5',
            ),
            ChoiceOption(
              text: 'Her zaman 3',
              textEn: 'Always 3',
              textDe: 'Immer 3',
              textEs: 'Siempre 3',
            ),
            ChoiceOption(
              text: '1 ile 6 arasındaki bütün ondalık sayılar',
              textEn: 'Every decimal between 1 and 6',
              textDe: 'Alle Kommazahlen zwischen 1 und 6',
              textEs: 'Todos los decimales entre 1 y 6',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Sınırlar dahil, yani 1 de 6 da çıkabilir. Tam sayı yazdığın '
              'için sonuç da tam sayı olur. Zar tam olarak böyle çalışıyor.',
          explanationEn:
              'The ends are included, so 1 and 6 are both possible. You '
              'typed whole numbers, so you get a whole number back. That '
              'is exactly a die.',
          explanationDe:
              'Die Grenzen gehören dazu, 1 und 6 sind also möglich. Du '
              'hast ganze Zahlen eingegeben, also kommt eine ganze Zahl '
              'zurück. Genau ein Würfel.',
          explanationEs:
              'Los extremos se incluyen, así que 1 y 6 son posibles. '
              'Escribiste números enteros, así que sale un entero. Eso es '
              'un dado.',
          xpReward: 15,
        ),

        BlockBuilderStep(
          id: 's9_1_build1',
          instruction: 'Kuklayı bir zara çevir.',
          instructionEn: 'Turn your sprite into a die.',
          instructionDe: 'Mach aus deiner Figur einen Würfel.',
          instructionEs: 'Convierte tu objeto en un dado.',
          goal: 'Bayrak → "de" bloğu, içinde 1 ile 6 arasında rastgele bir '
              'sayı. Oval bloğu tek başına bırakma.',
          goalEn: 'Flag → a "say" block holding pick random 1 to 6. Do not '
              'leave the oval block on its own.',
          goalDe: 'Flagge → ein «sage»-Block mit Zufallszahl von 1 bis 6 '
              'darin. Lass den ovalen Block nicht allein stehen.',
          goalEs: 'Bandera → un bloque «decir» con número aleatorio entre '
              '1 y 6 dentro. No dejes solo el bloque ovalado.',
          availableBlocks: [
            _bayrak(),
            _de('1 ile 6 arasında rastgele bir sayı seç',
                id: 'say_random_die',
                en: 'pick random 1 to 6',
                de: 'Zufallszahl von 1 bis 6',
                es: 'número aleatorio entre 1 y 6'),
            _rastgele('1', '6', id: 'random_1_6'),
            _de('Merhaba!',
                id: 'say_hello',
                en: 'Hello!',
                de: 'Hallo!',
                es: '¡Hola!'),
          ],
          correctSequence: [
            'green_flag',
            'say_random_die',
          ],
          xpReward: 30,
        ),

        ExplanationStep(
          id: 's9_1_exp2',
          title: 'Rastgeleliği Nereye Koyarsın',
          titleEn: 'Where to Use Randomness',
          titleDe: 'Wo du Zufall einsetzt',
          titleEs: 'Dónde usar el azar',
          content:
              'Oval blok sayının gittiği her yere girer. Oyunlarda en çok '
              'şu dört yerde işine yarar:\n\n'
              '• KONUM — "x\'i -200 ile 200 arasında rastgele yap": elma '
              'her seferinde başka yerden düşer.\n'
              '• SÜRE — "1 ile 3 saniye bekle": düşman ne zaman çıkacağını '
              'kestiremezsin.\n'
              '• HIZ — "5 ile 15 adım git": her tur biraz daha zor.\n'
              '• SEÇİM — 1 ile 3 arasında bir sayı seç, hangisi gelirse o '
              'sahneye geç.\n\n'
              'Sınırları ekranın ölçüsüne göre seçmen gerekiyor: Scratch '
              'sahnesinde x, -240 ile 240 arasında; y, -180 ile 180 '
              'arasında.',
          contentEn:
              'The oval block fits anywhere a number goes. In games these '
              'four spots matter most:\n\n'
              '• POSITION — "set x to pick random -200 to 200": the apple '
              'falls somewhere new every time.\n'
              '• TIME — "wait pick random 1 to 3 seconds": you cannot '
              'guess when the enemy shows up.\n'
              '• SPEED — "move pick random 5 to 15 steps": each round is '
              'a bit harder.\n'
              '• CHOICE — pick a number from 1 to 3 and jump to that '
              'backdrop.\n\n'
              'Choose the bounds to match the stage: in Scratch x runs '
              'from -240 to 240 and y from -180 to 180.',
          contentDe:
              'Der ovale Block passt überall hin, wo eine Zahl steht. In '
              'Spielen sind diese vier Stellen die wichtigsten:\n\n'
              '• POSITION — «setze x auf Zufallszahl von -200 bis 200»: '
              'der Apfel fällt jedes Mal woanders.\n'
              '• ZEIT — «warte Zufallszahl von 1 bis 3 Sekunden»: du '
              'kannst nicht raten, wann der Gegner kommt.\n'
              '• GESCHWINDIGKEIT — «gehe Zufallszahl von 5 bis 15 er '
              'Schritt»: jede Runde wird etwas schwerer.\n'
              '• AUSWAHL — wähle eine Zahl von 1 bis 3 und wechsle zu '
              'diesem Bühnenbild.\n\n'
              'Die Grenzen richten sich nach der Bühne: in Scratch geht x '
              'von -240 bis 240 und y von -180 bis 180.',
          contentEs:
              'El bloque ovalado entra donde iría un número. En los juegos '
              'estos cuatro sitios son los más útiles:\n\n'
              '• POSICIÓN — «fijar x a número aleatorio entre -200 y 200»: '
              'la manzana cae en otro sitio cada vez.\n'
              '• TIEMPO — «esperar número aleatorio entre 1 y 3 '
              'segundos»: no adivinas cuándo sale el enemigo.\n'
              '• VELOCIDAD — «mover número aleatorio entre 5 y 15 pasos»: '
              'cada ronda es algo más difícil.\n'
              '• ELECCIÓN — saca un número de 1 a 3 y cambia a ese fondo.'
              '\n\n'
              'Elige los límites según el escenario: en Scratch x va de '
              '-240 a 240 y la y de -180 a 180.',
        ),

        MatchingStep(
          id: 's9_1_match1',
          instruction: 'Her işi, ona uygun aralıkla eşleştir.',
          instructionEn: 'Match each job with the right range.',
          instructionDe: 'Ordne jeder Aufgabe den passenden Bereich zu.',
          instructionEs: 'Une cada tarea con su rango.',
          pairs: [
            MatchPair(
              id: 'r1',
              left: 'Zar atmak',
              right: '1 – 6',
              leftEn: 'Rolling a die',
              rightEn: '1 – 6',
              leftDe: 'Würfeln',
              rightDe: '1 – 6',
              leftEs: 'Tirar un dado',
              rightEs: '1 – 6',
            ),
            MatchPair(
              id: 'r2',
              left: 'Sahnede yatay konum',
              right: '-240 – 240',
              leftEn: 'Across the stage',
              rightEn: '-240 – 240',
              leftDe: 'Waagerecht auf der Bühne',
              rightDe: '-240 – 240',
              leftEs: 'A lo ancho del escenario',
              rightEs: '-240 – 240',
            ),
            MatchPair(
              id: 'r3',
              left: 'Yön (tam tur)',
              right: '0 – 360',
              leftEn: 'Direction (full circle)',
              rightEn: '0 – 360',
              leftDe: 'Richtung (ganze Runde)',
              rightDe: '0 – 360',
              leftEs: 'Dirección (vuelta entera)',
              rightEs: '0 – 360',
            ),
            MatchPair(
              id: 'r4',
              left: 'Yazı tura',
              right: '1 – 2',
              leftEn: 'Heads or tails',
              rightEn: '1 – 2',
              leftDe: 'Kopf oder Zahl',
              rightDe: '1 – 2',
              leftEs: 'Cara o cruz',
              rightEs: '1 – 2',
            ),
          ],
          xpReward: 20,
        ),

        ExplanationStep(
          id: 's9_1_summary',
          title: 'Şansı Kullanmayı Öğrendin!',
          titleEn: 'You Can Use Chance!',
          titleDe: 'Du kannst Zufall einsetzen!',
          titleEs: '¡Ya sabes usar el azar!',
          content: '🎲 Programın artık her çalıştırışta aynı değil.\n\n'
              '✓ Rastgele sayı bloğunu tanıdın\n'
              '✓ Oval bloğun boşluğa girdiğini gördün\n'
              '✓ Sınırları işe göre seçmeyi öğrendin\n\n'
              'Sıradaki ders: sayıları karşılaştırmak. "Puan 10\'dan büyük '
              'mü?" diye sormayı öğreneceksin.',
          contentEn: '🎲 Your program is no longer the same on every run.'
              '\n\n'
              '✓ You met the pick random block\n'
              '✓ You saw an oval block drop into a slot\n'
              '✓ You learned to choose bounds to fit the job\n\n'
              'Next lesson: comparing numbers. You will learn to ask "is '
              'the score above 10?"',
          contentDe: '🎲 Dein Programm läuft nicht mehr jedes Mal gleich.'
              '\n\n'
              '✓ Du kennst den Zufallszahl-Block\n'
              '✓ Du hast gesehen, wie ein ovaler Block in eine Lücke '
              'kommt\n'
              '✓ Du wählst die Grenzen passend zur Aufgabe\n\n'
              'Nächste Lektion: Zahlen vergleichen. Du lernst zu fragen '
              '«ist die Punktzahl über 10?»',
          contentEs: '🎲 Tu programa ya no es igual en cada ejecución.\n\n'
              '✓ Conociste el bloque de número aleatorio\n'
              '✓ Viste cómo un bloque ovalado entra en un hueco\n'
              '✓ Aprendiste a elegir los límites según la tarea\n\n'
              'Siguiente lección: comparar números. Aprenderás a preguntar '
              '«¿la puntuación pasa de 10?»',
          tipEmoji: '🏆',
          tip: 'Şans Ustası rozetini kazandın!',
          tipEn: 'You earned the Chance badge!',
          tipDe: 'Du hast das Zufall-Abzeichen verdient!',
          tipEs: '¡Has ganado la insignia del Azar!',
        ),
      ],
    ),
    // ---------------------------------------------------------- Ders 9.2
    InteractiveLesson(
      id: 'scratch_9_2',
      courseId: 'scratch',
      title: 'Karşılaştırma ve Mantık',
      subtitle: 'küçüktür, eşittir, büyüktür, ve, veya',
      titleEn: 'Comparing and Logic',
      titleDe: 'Vergleichen und Logik',
      titleEs: 'Comparar y lógica',
      subtitleEn: 'less than, equals, greater than, and, or',
      subtitleDe: 'kleiner, gleich, größer, und, oder',
      subtitleEs: 'menor, igual, mayor, y, o',
      order: 16,
      xpReward: 85,
      badge: 'logic_thinker',
      steps: [
        IntroStep(
          id: 's9_2_intro',
          mascotEmoji: '⚖️',
          mascotMessage:
              'Bir oyunun "kazandın" diyebilmesi için bir şeyi ÖLÇMESİ '
              'gerekiyor: puan yeterli mi, süre bitti mi, can kaldı mı?\n\n'
              'Bunu üç küçük blok yapıyor: küçüktür, eşittir, büyüktür. '
              'Hepsi ALTIGEN — çünkü verdikleri cevap sayı değil, sadece '
              'doğru ya da yanlış.',
          mascotMessageEn:
              'Before a game can say "you win" it has to MEASURE '
              'something: is the score enough, is the time up, is there a '
              'life left?\n\n'
              'Three small blocks do that: less than, equals, greater '
              'than. All of them are HEXAGONS — because their answer is '
              'not a number, only true or false.',
          mascotMessageDe:
              'Damit ein Spiel «du hast gewonnen» sagen kann, muss es '
              'etwas MESSEN: reicht die Punktzahl, ist die Zeit um, ist '
              'noch ein Leben da?\n\n'
              'Das machen drei kleine Blöcke: kleiner, gleich, größer. '
              'Alle sind SECHSECKE — denn ihre Antwort ist keine Zahl, '
              'sondern nur wahr oder falsch.',
          mascotMessageEs:
              'Para que un juego diga «has ganado» tiene que MEDIR algo: '
              '¿llega la puntuación, se acabó el tiempo, queda una vida?'
              '\n\n'
              'Lo hacen tres bloques pequeños: menor que, igual a, mayor '
              'que. Todos son HEXÁGONOS, porque su respuesta no es un '
              'número, solo verdadero o falso.',
          highlights: [
            'Altıgen = doğru ya da yanlış',
            'eğer bloğunun içine girer',
            've / veya ile birleşir',
          ],
          highlightsEn: [
            'Hexagon = true or false',
            'It drops into an if block',
            'Join them with and / or',
          ],
          highlightsDe: [
            'Sechseck = wahr oder falsch',
            'Es kommt in einen falls-Block',
            'Mit und / oder verbinden',
          ],
          highlightsEs: [
            'Hexágono = verdadero o falso',
            'Entra en un bloque si',
            'Se unen con y / o',
          ],
        ),

        ExplanationStep(
          id: 's9_2_exp1',
          title: 'Üç Karşılaştırma Bloğu',
          titleEn: 'Three Comparison Blocks',
          titleDe: 'Drei Vergleichsblöcke',
          titleEs: 'Tres bloques de comparación',
          content:
              'İŞLEMLER kategorisinde yan yana duruyorlar:\n\n'
              '   [ ] < [ ]   soldaki küçük mü?\n'
              '   [ ] = [ ]   ikisi aynı mı?\n'
              '   [ ] > [ ]   soldaki büyük mü?\n\n'
              'Boşluklara sayı yazabilirsin, ama işin güzeli DEĞİŞKEN '
              'koymak: "puan > 10" yazdığında blok her an güncel puanı '
              'ölçüyor.\n\n'
              'Altıgen şekli bir söz veriyor: bu bloğun cevabı ya doğru ya '
              'yanlış. Bu yüzden sadece altıgen boşluklara girer — yani '
              '"eğer ... ise" ve "... olana kadar bekle" bloklarına.',
          contentEn:
              'They sit side by side in OPERATORS:\n\n'
              '   [ ] < [ ]   is the left one smaller?\n'
              '   [ ] = [ ]   are they the same?\n'
              '   [ ] > [ ]   is the left one bigger?\n\n'
              'You can type numbers in the slots, but the good part is '
              'dropping in a VARIABLE: write "score > 10" and the block '
              'measures the live score at every moment.\n\n'
              'The hexagon shape is a promise: this block answers true or '
              'false. That is why it only fits hexagon slots — "if ... '
              'then" and "wait until ...".',
          contentDe:
              'Sie liegen bei OPERATOREN nebeneinander:\n\n'
              '   [ ] < [ ]   ist der linke kleiner?\n'
              '   [ ] = [ ]   sind beide gleich?\n'
              '   [ ] > [ ]   ist der linke größer?\n\n'
              'Du kannst Zahlen eintippen, schöner ist aber eine VARIABLE: '
              'schreibst du «Punkte > 10», misst der Block jederzeit den '
              'aktuellen Punktestand.\n\n'
              'Die Sechseckform ist ein Versprechen: dieser Block '
              'antwortet wahr oder falsch. Darum passt er nur in '
              'Sechseck-Lücken — «falls ... dann» und «warte bis ...».',
          contentEs:
              'Están juntos en OPERADORES:\n\n'
              '   [ ] < [ ]   ¿es menor el de la izquierda?\n'
              '   [ ] = [ ]   ¿son iguales?\n'
              '   [ ] > [ ]   ¿es mayor el de la izquierda?\n\n'
              'Puedes escribir números en los huecos, pero lo bueno es '
              'meter una VARIABLE: si escribes «puntos > 10», el bloque '
              'mide la puntuación real en cada momento.\n\n'
              'La forma hexagonal es una promesa: este bloque responde '
              'verdadero o falso. Por eso solo entra en huecos '
              'hexagonales: «si ... entonces» y «esperar hasta ...».',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'puan > 10',
              contentEn: 'score > 10',
              contentDe: 'Punkte > 10',
              contentEs: 'puntos > 10',
              color: islemRengi,
              label: 'İşlemler · altıgen blok',
              labelEn: 'Operators · hexagon block',
              labelDe: 'Operatoren · Sechseck',
              labelEs: 'Operadores · hexágono',
            ),
          ],
        ),

        BlockBuilderStep(
          id: 's9_2_build1',
          instruction: 'Puan azken kuklayı uyar.',
          instructionEn: 'Warn the player while the score is low.',
          instructionDe: 'Warne, solange die Punktzahl niedrig ist.',
          instructionEs: 'Avisa mientras la puntuación sea baja.',
          goal: 'Bayrak → eğer (puan < 5) ise → içine "Devam et!" de',
          goalEn: 'Flag → if (score < 5) then → say "Keep going!" inside',
          goalDe: 'Flagge → falls (Punkte < 5), dann → darin sage «Weiter!»',
          goalEs: 'Bandera → si (puntos < 5) entonces → dentro, decir '
              '«¡Sigue!»',
          availableBlocks: [
            _bayrak(),
            _eger(
                kosul: 'puan < 5',
                id: 'if_score_low',
                kosulEn: 'score < 5',
                kosulDe: 'Punkte < 5',
                kosulEs: 'puntos < 5'),
            _de('Devam et!',
                id: 'say_keep_going',
                en: 'Keep going!',
                de: 'Weiter so!',
                es: '¡Sigue!'),
            _kucuktur('puan', '5',
                id: 'lt_score_5', aEn: 'score', aDe: 'Punkte', aEs: 'puntos'),
            _kucuktur('5', 'puan', id: 'lt_5_score'),
          ],
          correctSequence: [
            'green_flag',
            'if_score_low',
            'say_keep_going',
          ],
          xpReward: 35,
        ),

        ExplanationStep(
          id: 's9_2_exp2',
          title: 've ile veya',
          titleEn: 'and versus or',
          titleDe: 'und gegen oder',
          titleEs: 'y frente a o',
          content:
              'Bazen tek ölçü yetmiyor. "Kapı açılsın" demek için hem '
              'anahtar olmalı hem de puan 10\'u geçmiş olmalı. İşte o zaman '
              'iki altıgeni birleştiriyorsun:\n\n'
              '   VE  → ikisi de doğruysa doğru\n'
              '   VEYA → biri doğruysa yeter\n\n'
              'Aradaki fark oyunun zorluğunu belirliyor:\n\n'
              '• "can > 0 ve süre > 0" → oyun devam ediyor. Biri bitince '
              'oyun biter.\n'
              '• "kalkan var veya can > 3" → korunuyorsun. İkisinden biri '
              'yeter.\n\n'
              'Bir de DEĞİL bloğu var: içine koyduğun şeyin tersini verir. '
              '"değil (oyun bitti)" demek "oyun sürüyor" demektir.',
          contentEn:
              'Sometimes one measurement is not enough. To open the door '
              'you need the key AND a score above 10. That is when you '
              'join two hexagons:\n\n'
              '   AND → true only if both are true\n'
              '   OR  → one of them is enough\n\n'
              'The difference sets how hard your game is:\n\n'
              '• "lives > 0 and time > 0" → the game continues. When '
              'either runs out, it ends.\n'
              '• "has shield or lives > 3" → you are safe. Either one is '
              'enough.\n\n'
              'There is also NOT: it flips whatever you put inside. "not '
              '(game over)" means "the game is still on".',
          contentDe:
              'Manchmal reicht eine Messung nicht. Für die Tür brauchst du '
              'den Schlüssel UND mehr als 10 Punkte. Dann verbindest du '
              'zwei Sechsecke:\n\n'
              '   UND → nur wahr, wenn beides wahr ist\n'
              '   ODER → eines genügt\n\n'
              'Der Unterschied bestimmt, wie schwer dein Spiel ist:\n\n'
              '• «Leben > 0 und Zeit > 0» → das Spiel läuft weiter. Geht '
              'eines aus, ist Schluss.\n'
              '• «Schild da oder Leben > 3» → du bist geschützt. Eines '
              'genügt.\n\n'
              'Es gibt auch NICHT: es dreht um, was du hineinsteckst. '
              '«nicht (Spiel vorbei)» heißt «das Spiel läuft».',
          contentEs:
              'A veces una sola medida no basta. Para abrir la puerta '
              'necesitas la llave Y más de 10 puntos. Ahí unes dos '
              'hexágonos:\n\n'
              '   Y → verdadero solo si los dos lo son\n'
              '   O → basta con uno\n\n'
              'La diferencia marca la dificultad del juego:\n\n'
              '• «vidas > 0 y tiempo > 0» → el juego sigue. Si se acaba '
              'uno, termina.\n'
              '• «tiene escudo o vidas > 3» → estás a salvo. Basta uno.'
              '\n\n'
              'También existe NO: da la vuelta a lo que metas dentro. «no '
              '(fin del juego)» significa «el juego sigue».',
          tipEmoji: '🧠',
          tip: 'Kural: VE zorlaştırır, VEYA kolaylaştırır. Oyun fazla '
              'zorsa VE\'lerine bak.',
          tipEn: 'Rule of thumb: AND makes it harder, OR makes it easier. '
              'If your game feels too hard, look at your ANDs.',
          tipDe: 'Merksatz: UND macht es schwerer, ODER leichter. Ist dein '
              'Spiel zu schwer, schau dir die UNDs an.',
          tipEs: 'Regla: Y lo hace más difícil, O más fácil. Si tu juego '
              'es muy difícil, mira tus Y.',
        ),

        MatchingStep(
          id: 's9_2_match1',
          instruction: 'Her ifadeyi sonucuyla eşleştir.',
          instructionEn: 'Match each expression with its answer.',
          instructionDe: 'Ordne jedem Ausdruck sein Ergebnis zu.',
          instructionEs: 'Une cada expresión con su resultado.',
          pairs: [
            MatchPair(
              id: 'l1',
              left: '3 < 5',
              right: 'doğru',
              leftEn: '3 < 5',
              rightEn: 'true',
              leftDe: '3 < 5',
              rightDe: 'wahr',
              leftEs: '3 < 5',
              rightEs: 'verdadero',
            ),
            MatchPair(
              id: 'l2',
              left: '7 = 4',
              right: 'yanlış',
              leftEn: '7 = 4',
              rightEn: 'false',
              leftDe: '7 = 4',
              rightDe: 'falsch',
              leftEs: '7 = 4',
              rightEs: 'falso',
            ),
            MatchPair(
              id: 'l3',
              left: '(2 > 1) ve (5 > 9)',
              right: 'yanlış, çünkü biri yanlış',
              leftEn: '(2 > 1) and (5 > 9)',
              rightEn: 'false, one side fails',
              leftDe: '(2 > 1) und (5 > 9)',
              rightDe: 'falsch, eine Seite stimmt nicht',
              leftEs: '(2 > 1) y (5 > 9)',
              rightEs: 'falso, un lado falla',
            ),
            MatchPair(
              id: 'l4',
              left: '(2 > 1) veya (5 > 9)',
              right: 'doğru, biri yeter',
              leftEn: '(2 > 1) or (5 > 9)',
              rightEn: 'true, one side is enough',
              leftDe: '(2 > 1) oder (5 > 9)',
              rightDe: 'wahr, eine Seite genügt',
              leftEs: '(2 > 1) o (5 > 9)',
              rightEs: 'verdadero, basta un lado',
            ),
          ],
          xpReward: 20,
        ),

        MultipleChoiceStep(
          id: 's9_2_q1',
          question: 'Bir kapı sadece anahtar varken VE puan 10\'u geçmişken '
              'açılacak. Hangisini kullanırsın?',
          questionEn: 'A door should open only with the key AND a score '
              'above 10. Which block do you use?',
          questionDe: 'Eine Tür soll nur mit Schlüssel UND über 10 Punkten '
              'aufgehen. Welchen Block nimmst du?',
          questionEs: 'Una puerta se abre solo con la llave Y más de 10 '
              'puntos. ¿Qué bloque usas?',
          options: [
            ChoiceOption(
              text: 've bloğu — iki koşul da doğru olmalı',
              textEn: 'the and block — both must be true',
              textDe: 'den und-Block — beides muss wahr sein',
              textEs: 'el bloque y: los dos deben cumplirse',
            ),
            ChoiceOption(
              text: 'veya bloğu — biri yeter',
              textEn: 'the or block — one is enough',
              textDe: 'den oder-Block — eines genügt',
              textEs: 'el bloque o: basta uno',
            ),
            ChoiceOption(
              text: 'değil bloğu — tersini alır',
              textEn: 'the not block — it flips the answer',
              textDe: 'den nicht-Block — er dreht die Antwort um',
              textEs: 'el bloque no: da la vuelta',
            ),
            ChoiceOption(
              text: 'Rastgele blok — şansa bırakırım',
              textEn: 'the pick random block — leave it to luck',
              textDe: 'den Zufallszahl-Block — dem Glück überlassen',
              textEs: 'el bloque aleatorio: lo dejo a la suerte',
            ),
          ],
          correctIndex: 0,
          explanation:
              '"Hem ... hem de ..." dediğin her yerde VE kullanılır. VEYA '
              'seçseydin anahtarı olmayan ama puanı yüksek biri de kapıyı '
              'açardı — oyun bozulurdu.',
          explanationEn:
              'Wherever you say "both ... and ...", you use AND. With OR, '
              'someone with no key but a high score would walk right '
              'through — the game would break.',
          explanationDe:
              'Wo du «sowohl ... als auch ...» sagst, brauchst du UND. Mit '
              'ODER käme jemand ohne Schlüssel, aber mit vielen Punkten '
              'einfach durch — das Spiel wäre kaputt.',
          explanationEs:
              'Donde dices «tanto ... como ...», usas Y. Con O, alguien '
              'sin llave pero con muchos puntos pasaría igual: el juego se '
              'rompería.',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 's9_2_summary',
          title: 'Mantık Kurmayı Öğrendin!',
          titleEn: 'You Can Build Logic!',
          titleDe: 'Du kannst Logik bauen!',
          titleEs: '¡Ya sabes construir lógica!',
          content: '⚖️ Programın artık ölçüp karar veriyor.\n\n'
              '✓ küçüktür, eşittir, büyüktür\n'
              '✓ Altıgenin sadece altıgen boşluğa girdiğini gördün\n'
              '✓ ve / veya / değil ile koşul birleştirdin\n\n'
              'Sıradaki modül: bir değişkene bir sayı değil, KOCA BİR '
              'LİSTE sığdırmak.',
          contentEn: '⚖️ Your program measures and decides now.\n\n'
              '✓ less than, equals, greater than\n'
              '✓ You saw a hexagon only fits a hexagon slot\n'
              '✓ You joined conditions with and / or / not\n\n'
              'Next module: fitting a WHOLE LIST into your project instead '
              'of a single number.',
          contentDe: '⚖️ Dein Programm misst und entscheidet jetzt.\n\n'
              '✓ kleiner, gleich, größer\n'
              '✓ Du hast gesehen: ein Sechseck passt nur in ein Sechseck\n'
              '✓ Du hast Bedingungen mit und / oder / nicht verbunden\n\n'
              'Nächstes Modul: statt einer einzigen Zahl eine GANZE LISTE '
              'im Projekt.',
          contentEs: '⚖️ Tu programa ya mide y decide.\n\n'
              '✓ menor que, igual a, mayor que\n'
              '✓ Viste que un hexágono solo entra en un hueco hexagonal\n'
              '✓ Uniste condiciones con y / o / no\n\n'
              'Siguiente módulo: meter una LISTA ENTERA en tu proyecto en '
              'vez de un solo número.',
          tipEmoji: '🏆',
          tip: 'Mantık Ustası rozetini kazandın!',
          tipEn: 'You earned the Logic badge!',
          tipDe: 'Du hast das Logik-Abzeichen verdient!',
          tipEs: '¡Has ganado la insignia de la Lógica!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODÜL 10 — LİSTELER
  // ==========================================

  static final List<InteractiveLesson> module10 = [
    // --------------------------------------------------------- Ders 10.1
    InteractiveLesson(
      id: 'scratch_10_1',
      courseId: 'scratch',
      title: 'Liste: Tek Kutuda Çok Şey',
      subtitle: 'Liste oluştur, öğe ekle, öğe sil',
      titleEn: 'Lists: Many Things in One Box',
      titleDe: 'Listen: viele Dinge in einer Kiste',
      titleEs: 'Listas: muchas cosas en una caja',
      subtitleEn: 'Make a list, add an item, delete an item',
      subtitleDe: 'Liste anlegen, Element hinzufügen, Element löschen',
      subtitleEs: 'Crear una lista, añadir y borrar elementos',
      order: 17,
      xpReward: 75,
      badge: 'list_keeper',
      steps: [
        IntroStep(
          id: 's10_1_intro',
          mascotEmoji: '📋',
          mascotMessage:
              'Değişken bir kutudur: içine bir tek şey koyarsın. Puanı '
              'tutmak için yeter.\n\n'
              'Ama on kişinin adını tutmak istersen? On tane değişken mi '
              'yapacaksın? Liste tam bunun için var: içinde numaralı gözler '
              'olan bir kutu. Bir tanesi on değişkenin işini yapıyor.',
          mascotMessageEn:
              'A variable is a box: one thing goes inside. That is plenty '
              'for a score.\n\n'
              'But what if you want to keep ten names? Ten variables? A '
              'list exists exactly for this: one box with numbered slots '
              'inside. One list does the work of ten variables.',
          mascotMessageDe:
              'Eine Variable ist eine Kiste: ein Ding passt hinein. Für '
              'einen Punktestand reicht das.\n\n'
              'Aber wenn du zehn Namen behalten willst? Zehn Variablen? '
              'Genau dafür gibt es Listen: eine Kiste mit numerierten '
              'Fächern. Eine Liste macht die Arbeit von zehn Variablen.',
          mascotMessageEs:
              'Una variable es una caja: dentro cabe una cosa. Para una '
              'puntuación sobra.\n\n'
              'Pero ¿si quieres guardar diez nombres? ¿Diez variables? Para '
              'eso existen las listas: una caja con casillas numeradas. Una '
              'lista hace el trabajo de diez variables.',
          highlights: [
            'Değişken: bir göz',
            'Liste: numaralı çok göz',
            'Ekle, sil, say',
          ],
          highlightsEn: [
            'Variable: one slot',
            'List: many numbered slots',
            'Add, delete, count',
          ],
          highlightsDe: [
            'Variable: ein Fach',
            'Liste: viele numerierte Fächer',
            'Hinzufügen, löschen, zählen',
          ],
          highlightsEs: [
            'Variable: una casilla',
            'Lista: muchas casillas numeradas',
            'Añadir, borrar, contar',
          ],
        ),

        ExplanationStep(
          id: 's10_1_exp1',
          title: 'Liste Nasıl Oluşturulur',
          titleEn: 'How to Make a List',
          titleDe: 'So legst du eine Liste an',
          titleEs: 'Cómo crear una lista',
          content:
              'DEĞİŞKENLER kategorisine git. Değişken yap düğmesinin hemen '
              'altında "Bir liste oluştur" yazıyor.\n\n'
              'Bas, bir ad ver (mesela alışveriş) ve tamam de. İki şey '
              'oluyor:\n\n'
              '1. Palete bir sürü turuncu blok geliyor: ekle, sil, '
              'uzunluğu, öğesi...\n'
              '2. Sahnede bir pencere açılıyor. Bu pencere listenin '
              'içindekileri canlı gösteriyor — program çalışırken gözünle '
              'takip edebiliyorsun.\n\n'
              'Yeni liste boştur. Uzunluğu sıfırdır. İçine bir şey koymadan '
              'öğe istemek boşluğa bakmak gibidir.',
          contentEn:
              'Go to VARIABLES. Right under the Make a Variable button it '
              'says "Make a List".\n\n'
              'Press it, give a name (say shopping) and confirm. Two things '
              'happen:\n\n'
              '1. A pile of orange blocks appears: add, delete, length of, '
              'item of...\n'
              '2. A window opens on the stage. It shows what is inside the '
              'list live — you can watch it while the program runs.\n\n'
              'A new list is empty. Its length is zero. Asking for an item '
              'before you put anything in is like looking into thin air.',
          contentDe:
              'Geh zu VARIABLEN. Direkt unter «Neue Variable» steht «Liste '
              'anlegen».\n\n'
              'Drück darauf, gib einen Namen (etwa Einkauf) und bestätige. '
              'Zwei Dinge passieren:\n\n'
              '1. Viele orange Blöcke erscheinen: hinzufügen, löschen, '
              'Länge von, Element von...\n'
              '2. Auf der Bühne öffnet sich ein Fenster. Es zeigt live, was '
              'in der Liste steht — du kannst beim Laufen zusehen.\n\n'
              'Eine neue Liste ist leer, ihre Länge ist null. Nach einem '
              'Element zu fragen, bevor etwas drin ist, ist wie ins Leere '
              'schauen.',
          contentEs:
              'Ve a VARIABLES. Justo debajo de «Crear una variable» dice '
              '«Crear una lista».\n\n'
              'Púlsalo, ponle un nombre (por ejemplo compra) y acepta. '
              'Pasan dos cosas:\n\n'
              '1. Aparecen muchos bloques naranjas: añadir, borrar, '
              'longitud de, elemento de...\n'
              '2. Se abre una ventana en el escenario. Muestra en vivo lo '
              'que hay en la lista: puedes seguirlo mientras se ejecuta.'
              '\n\n'
              'Una lista nueva está vacía, su longitud es cero. Pedir un '
              'elemento antes de meter nada es mirar al vacío.',
          tipEmoji: '👁️',
          tip: 'Sahnedeki liste penceresi en iyi hata ayıklama aracın: '
              'bloğun ne yaptığını tahmin etmiyorsun, görüyorsun.',
          tipEn: 'The list window on the stage is your best debugging tool: '
              'you do not guess what a block did, you see it.',
          tipDe: 'Das Listenfenster auf der Bühne ist dein bestes '
              'Fehlersuch-Werkzeug: du rätst nicht, du siehst es.',
          tipEs: 'La ventana de la lista es tu mejor herramienta para '
              'depurar: no adivinas qué hizo el bloque, lo ves.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'elma i alışveriş ye ekle',
              contentEn: 'add apple to shopping',
              contentDe: 'füge Apfel zu Einkauf hinzu',
              contentEs: 'añadir manzana a compra',
              color: listeRengi,
              label: 'Değişkenler · liste bloğu',
              labelEn: 'Variables · list block',
              labelDe: 'Variablen · Listenblock',
              labelEs: 'Variables · bloque de lista',
            ),
          ],
        ),

        ExplanationStep(
          id: 's10_1_exp2',
          title: 'Dört Temel Liste Bloğu',
          titleEn: 'The Four Core List Blocks',
          titleDe: 'Die vier wichtigsten Listenblöcke',
          titleEs: 'Los cuatro bloques básicos',
          content:
              'Onlarca liste bloğu var ama işe şu dördüyle başlıyorsun:\n\n'
              '• ... i ... ye ekle → yeni öğeyi listenin SONUNA koyar.\n'
              '• ... in ... ini sil → numarasını verdiğin gözü boşaltır ve '
              'alttakiler bir yukarı kayar.\n'
              '• ... in uzunluğu → kaç öğe var? Oval blok, sayı verir.\n'
              '• ... in ... öğesi → istediğin numaradaki şeyi getirir.\n\n'
              'Numaralandırma 1\'den başlıyor: ilk öğe 1. öğedir, sıfırıncı '
              'öğe yoktur.\n\n'
              'Sıralama önemli: eklediğin sırayla duruyorlar. Liste kendini '
              'kendiliğinden sıralamıyor.',
          contentEn:
              'There are dozens of list blocks, but you start with these '
              'four:\n\n'
              '• add ... to ... → puts the new item at the END of the '
              'list.\n'
              '• delete ... of ... → empties the slot you name, and the '
              'ones below shift up one.\n'
              '• length of ... → how many items? An oval block, it gives a '
              'number.\n'
              '• item ... of ... → fetches whatever sits at that number.'
              '\n\n'
              'Counting starts at 1: the first item is item 1, there is no '
              'item zero.\n\n'
              'Order matters: items stay in the order you added them. A '
              'list does not sort itself.',
          contentDe:
              'Es gibt Dutzende Listenblöcke, du fängst mit diesen vier '
              'an:\n\n'
              '• füge ... zu ... hinzu → legt das Neue ans ENDE der '
              'Liste.\n'
              '• lösche ... von ... → leert das genannte Fach, die '
              'darunter rücken eins nach oben.\n'
              '• Länge von ... → wie viele Elemente? Ein ovaler Block, er '
              'gibt eine Zahl.\n'
              '• Element ... von ... → holt, was an dieser Nummer steht.'
              '\n\n'
              'Gezählt wird ab 1: das erste Element ist Element 1, ein '
              'Element null gibt es nicht.\n\n'
              'Die Reihenfolge zählt: die Elemente bleiben so, wie du sie '
              'hinzugefügt hast. Eine Liste sortiert sich nicht selbst.',
          contentEs:
              'Hay decenas de bloques de lista, pero empiezas con estos '
              'cuatro:\n\n'
              '• añadir ... a ... → pone lo nuevo al FINAL de la lista.\n'
              '• borrar ... de ... → vacía la casilla que indicas y las de '
              'abajo suben una.\n'
              '• longitud de ... → ¿cuántos elementos? Bloque ovalado, da '
              'un número.\n'
              '• elemento ... de ... → trae lo que está en ese número.\n\n'
              'Se cuenta desde 1: el primero es el elemento 1, no hay '
              'elemento cero.\n\n'
              'El orden importa: se quedan como los añadiste. Una lista no '
              'se ordena sola.',
        ),

        BlockBuilderStep(
          id: 's10_1_build1',
          instruction: 'Alışveriş listesine iki şey ekle.',
          instructionEn: 'Add two things to the shopping list.',
          instructionDe: 'Füge zwei Dinge zur Einkaufsliste hinzu.',
          instructionEs: 'Añade dos cosas a la lista de la compra.',
          goal: 'Bayrak → elma ekle → muz ekle. Sıra önemli: elma 1., muz '
              '2. öğe olur.',
          goalEn: 'Flag → add apple → add banana. Order matters: apple '
              'becomes item 1, banana item 2.',
          goalDe: 'Flagge → Apfel hinzufügen → Banane hinzufügen. Die '
              'Reihenfolge zählt: Apfel wird Element 1, Banane Element 2.',
          goalEs: 'Bandera → añadir manzana → añadir plátano. El orden '
              'importa: manzana es el 1, plátano el 2.',
          availableBlocks: [
            _bayrak(),
            _listeyeEkle('elma', 'alışveriş',
                id: 'add_apple',
                ogeEn: 'apple',
                ogeDe: 'Apfel',
                ogeEs: 'manzana',
                listeEn: 'shopping',
                listeDe: 'Einkauf',
                listeEs: 'compra'),
            _listeyeEkle('muz', 'alışveriş',
                id: 'add_banana',
                ogeEn: 'banana',
                ogeDe: 'Banane',
                ogeEs: 'plátano',
                listeEn: 'shopping',
                listeDe: 'Einkauf',
                listeEs: 'compra'),
            _listedenSil('1', 'alışveriş',
                id: 'delete_first',
                listeEn: 'shopping',
                listeDe: 'Einkauf',
                listeEs: 'compra'),
          ],
          correctSequence: [
            'green_flag',
            'add_apple',
            'add_banana',
          ],
          xpReward: 30,
        ),

        MultipleChoiceStep(
          id: 's10_1_q1',
          question: 'Listeye sırayla elma, muz, kiraz eklediysen 2. öğe '
              'nedir?',
          questionEn: 'You added apple, banana, cherry in that order. What '
              'is item 2?',
          questionDe: 'Du hast Apfel, Banane, Kirsche in dieser Reihenfolge '
              'hinzugefügt. Was ist Element 2?',
          questionEs: 'Añadiste manzana, plátano, cereza en ese orden. '
              '¿Cuál es el elemento 2?',
          options: [
            ChoiceOption(
              text: 'muz',
              textEn: 'banana',
              textDe: 'Banane',
              textEs: 'plátano',
            ),
            ChoiceOption(
              text: 'elma',
              textEn: 'apple',
              textDe: 'Apfel',
              textEs: 'manzana',
            ),
            ChoiceOption(
              text: 'kiraz',
              textEn: 'cherry',
              textDe: 'Kirsche',
              textEs: 'cereza',
            ),
            ChoiceOption(
              text: 'Listeler alfabetik sıralanır, elma',
              textEn: 'Lists sort alphabetically, so apple',
              textDe: 'Listen sortieren alphabetisch, also Apfel',
              textEs: 'Las listas se ordenan alfabéticamente, manzana',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Ekle bloğu her şeyi sonuna koyuyor, yani ekleme sırası = '
              'göz sırası: 1 elma, 2 muz, 3 kiraz. Liste kendini '
              'sıralamıyor.',
          explanationEn:
              'The add block always appends, so the order you added is the '
              'order of slots: 1 apple, 2 banana, 3 cherry. A list does '
              'not sort itself.',
          explanationDe:
              'Der Hinzufügen-Block hängt immer hinten an, also ist die '
              'Reihenfolge des Hinzufügens die der Fächer: 1 Apfel, 2 '
              'Banane, 3 Kirsche. Eine Liste sortiert nicht.',
          explanationEs:
              'El bloque añadir siempre va al final, así que el orden de '
              'añadido es el de las casillas: 1 manzana, 2 plátano, 3 '
              'cereza. La lista no ordena.',
          xpReward: 15,
        ),

        MatchingStep(
          id: 's10_1_match1',
          instruction: 'Her bloğu yaptığı işle eşleştir.',
          instructionEn: 'Match each block with what it does.',
          instructionDe: 'Ordne jeden Block seiner Aufgabe zu.',
          instructionEs: 'Une cada bloque con lo que hace.',
          pairs: [
            MatchPair(
              id: 'li1',
              left: 'ekle',
              right: 'Sona yeni öğe koyar',
              leftEn: 'add',
              rightEn: 'Puts a new item at the end',
              leftDe: 'hinzufügen',
              rightDe: 'Legt ein neues Element ans Ende',
              leftEs: 'añadir',
              rightEs: 'Pone un elemento al final',
            ),
            MatchPair(
              id: 'li2',
              left: 'sil',
              right: 'Numarasını verdiğin gözü boşaltır',
              leftEn: 'delete',
              rightEn: 'Empties the slot you name',
              leftDe: 'löschen',
              rightDe: 'Leert das genannte Fach',
              leftEs: 'borrar',
              rightEs: 'Vacía la casilla que indicas',
            ),
            MatchPair(
              id: 'li3',
              left: 'uzunluğu',
              right: 'Kaç öğe olduğunu söyler',
              leftEn: 'length of',
              rightEn: 'Tells you how many items',
              leftDe: 'Länge von',
              rightDe: 'Sagt, wie viele Elemente es sind',
              leftEs: 'longitud de',
              rightEs: 'Dice cuántos elementos hay',
            ),
            MatchPair(
              id: 'li4',
              left: 'öğesi',
              right: 'Numaradaki şeyi getirir',
              leftEn: 'item of',
              rightEn: 'Fetches what is at that number',
              leftDe: 'Element von',
              rightDe: 'Holt, was an der Nummer steht',
              leftEs: 'elemento de',
              rightEs: 'Trae lo que está en ese número',
            ),
          ],
          xpReward: 20,
        ),

        ExplanationStep(
          id: 's10_1_summary',
          title: 'Liste Tutmayı Öğrendin!',
          titleEn: 'You Can Keep a List!',
          titleDe: 'Du kannst Listen führen!',
          titleEs: '¡Ya sabes usar listas!',
          content: '📋 Artık tek kutuda onlarca şey tutabiliyorsun.\n\n'
              '✓ Liste oluşturdun\n'
              '✓ Ekle ve sil bloklarını kullandın\n'
              '✓ Numaralandırmanın 1\'den başladığını öğrendin\n\n'
              'Sıradaki ders: listeden RASTGELE öğe çekmek. Soru torbası '
              'oyunu böyle kuruluyor.',
          contentEn: '📋 You can keep dozens of things in one box now.\n\n'
              '✓ You made a list\n'
              '✓ You used add and delete\n'
              '✓ You learned counting starts at 1\n\n'
              'Next lesson: pulling a RANDOM item out of a list. That is '
              'how a quiz bag works.',
          contentDe: '📋 Du kannst jetzt Dutzende Dinge in einer Kiste '
              'behalten.\n\n'
              '✓ Du hast eine Liste angelegt\n'
              '✓ Du hast hinzufügen und löschen benutzt\n'
              '✓ Du weißt: gezählt wird ab 1\n\n'
              'Nächste Lektion: ein ZUFÄLLIGES Element aus der Liste '
              'ziehen. So baut man einen Fragebeutel.',
          contentEs: '📋 Ya puedes guardar decenas de cosas en una caja.'
              '\n\n'
              '✓ Creaste una lista\n'
              '✓ Usaste añadir y borrar\n'
              '✓ Aprendiste que se cuenta desde 1\n\n'
              'Siguiente lección: sacar un elemento AL AZAR de la lista. '
              'Así se hace una bolsa de preguntas.',
          tipEmoji: '🏆',
          tip: 'Liste Bekçisi rozetini kazandın!',
          tipEn: 'You earned the List Keeper badge!',
          tipDe: 'Du hast das Listen-Abzeichen verdient!',
          tipEs: '¡Has ganado la insignia de las Listas!',
        ),
      ],
    ),
    // --------------------------------------------------------- Ders 10.2
    InteractiveLesson(
      id: 'scratch_10_2',
      courseId: 'scratch',
      title: 'Soru Torbası: Listeden Rastgele Çek',
      subtitle: 'uzunluğu ve öğesi bloklarını birleştirmek',
      titleEn: 'The Question Bag: Pull a Random Item',
      titleDe: 'Der Fragebeutel: zufällig aus der Liste ziehen',
      titleEs: 'La bolsa de preguntas: saca un elemento al azar',
      subtitleEn: 'Putting length of and item of together',
      subtitleDe: 'Länge von und Element von zusammen nutzen',
      subtitleEs: 'Combinar longitud de y elemento de',
      order: 18,
      xpReward: 90,
      badge: 'quiz_builder',
      steps: [
        IntroStep(
          id: 's10_2_intro',
          mascotEmoji: '🎒',
          mascotMessage:
              'Modül 9\'da şansı öğrendin, bu modülde listeyi. İkisini '
              'birleştirince ortaya gerçek bir oyun çıkıyor: torbadan '
              'rastgele bir soru çeken bir kukla.\n\n'
              'İşin sırrı iki bloğun iç içe geçmesi: rastgele sayı, '
              '"öğesi" bloğunun numara boşluğuna giriyor.',
          mascotMessageEn:
              'In module 9 you learned chance, in this one lists. Put them '
              'together and you get a real game: a sprite that pulls a '
              'random question out of a bag.\n\n'
              'The trick is nesting two blocks: the random number goes '
              'into the number slot of "item of".',
          mascotMessageDe:
              'In Modul 9 kam der Zufall, hier die Listen. Zusammen ergibt '
              'das ein echtes Spiel: eine Figur, die eine zufällige Frage '
              'aus dem Beutel zieht.\n\n'
              'Der Trick ist das Verschachteln: die Zufallszahl kommt in '
              'die Nummer-Lücke von «Element von».',
          mascotMessageEs:
              'En el módulo 9 aprendiste el azar; en este, las listas. '
              'Júntalos y sale un juego de verdad: un objeto que saca una '
              'pregunta al azar de la bolsa.\n\n'
              'El truco es anidar dos bloques: el número aleatorio entra en '
              'el hueco de número de «elemento de».',
          highlights: [
            'Şans + liste = oyun',
            'Blok içinde blok',
            '1 ile uzunluk arasında',
          ],
          highlightsEn: [
            'Chance + list = a game',
            'A block inside a block',
            '1 to the length',
          ],
          highlightsDe: [
            'Zufall + Liste = Spiel',
            'Ein Block im Block',
            '1 bis zur Länge',
          ],
          highlightsEs: [
            'Azar + lista = juego',
            'Un bloque dentro de otro',
            'De 1 a la longitud',
          ],
        ),

        ExplanationStep(
          id: 's10_2_exp1',
          title: 'Neden "1 ile uzunluk arasında"',
          titleEn: 'Why "1 to the length"',
          titleDe: 'Warum «1 bis Länge»',
          titleEs: 'Por qué «de 1 a la longitud»',
          content:
              'Listede beş soru varsa rastgele sayı 1 ile 5 arasında '
              'olmalı. 6 dersen olmayan bir gözü istemiş olursun ve blok '
              'sana boşluk döndürür.\n\n'
              'Ama listeye yarın bir soru daha eklersen 5 yazmış olmak '
              'hataya dönüşür: yeni soru asla çıkmaz.\n\n'
              'Çözüm sayıyı elle yazmamak:\n\n'
              '   1 ile (sorular in uzunluğu) arasında rastgele bir sayı '
              'seç\n\n'
              'Artık listeye kaç soru eklersen ekle program kendini '
              'ayarlıyor. Programcılar buna "sihirli sayı kullanmamak" der.',
          contentEn:
              'If the list holds five questions the random number must be '
              '1 to 5. Say 6 and you ask for a slot that does not exist, '
              'so the block hands you an empty answer.\n\n'
              'But if you add a sixth question tomorrow, having typed 5 '
              'becomes a bug: the new question can never come up.\n\n'
              'The fix is not typing the number at all:\n\n'
              '   pick random 1 to (length of questions)\n\n'
              'Now the program adjusts itself however many questions you '
              'add. Programmers call this avoiding a magic number.',
          contentDe:
              'Hat die Liste fünf Fragen, muss die Zufallszahl 1 bis 5 '
              'sein. Sagst du 6, fragst du nach einem Fach, das es nicht '
              'gibt, und bekommst eine leere Antwort.\n\n'
              'Fügst du aber morgen eine sechste Frage hinzu, wird die '
              'getippte 5 zum Fehler: die neue Frage kommt nie.\n\n'
              'Die Lösung: die Zahl gar nicht eintippen:\n\n'
              '   Zufallszahl von 1 bis (Länge von Fragen)\n\n'
              'Jetzt passt sich das Programm an, egal wie viele Fragen du '
              'hinzufügst. Programmierer nennen das: keine magische Zahl.',
          contentEs:
              'Si la lista tiene cinco preguntas, el número aleatorio debe '
              'ir de 1 a 5. Si pones 6, pides una casilla que no existe y '
              'el bloque te da vacío.\n\n'
              'Pero si mañana añades una sexta pregunta, ese 5 escrito a '
              'mano es un error: la nueva pregunta nunca saldrá.\n\n'
              'La solución es no escribir el número:\n\n'
              '   número aleatorio entre 1 y (longitud de preguntas)\n\n'
              'Ahora el programa se ajusta solo, añadas las preguntas que '
              'quieras. Los programadores lo llaman evitar un número '
              'mágico.',
          tipEmoji: '🪄',
          tip: 'Elle yazdığın her sayı yarın değişebilecek bir sayıdır. '
              'Program kendi ölçüsünü kendi alsın.',
          tipEn: 'Every number you type by hand is a number that may '
              'change tomorrow. Let the program measure for itself.',
          tipDe: 'Jede handgetippte Zahl kann sich morgen ändern. Lass das '
              'Programm selbst messen.',
          tipEs: 'Todo número escrito a mano puede cambiar mañana. Deja que '
              'el programa mida por sí mismo.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'sorular in uzunluğu',
              contentEn: 'length of questions',
              contentDe: 'Länge von Fragen',
              contentEs: 'longitud de preguntas',
              color: listeRengi,
              label: 'Değişkenler · oval blok',
              labelEn: 'Variables · oval block',
              labelDe: 'Variablen · ovaler Block',
              labelEs: 'Variables · bloque ovalado',
            ),
          ],
        ),

        BlockBuilderStep(
          id: 's10_2_build1',
          instruction: 'Torbadan rastgele bir soru çek.',
          instructionEn: 'Pull a random question out of the bag.',
          instructionDe: 'Zieh eine zufällige Frage aus dem Beutel.',
          instructionEs: 'Saca una pregunta al azar de la bolsa.',
          goal: 'Bayrak → "de" bloğu, içinde sorular listesinin rastgele '
              'bir öğesi. Sabit numara yazan bloğu seçme.',
          goalEn: 'Flag → a "say" block holding a random item of the '
              'questions list. Do not pick the block with a fixed number.',
          goalDe: 'Flagge → ein «sage»-Block mit einem zufälligen Element '
              'der Fragenliste. Nicht den Block mit fester Nummer nehmen.',
          goalEs: 'Bandera → un bloque «decir» con un elemento al azar de '
              'la lista de preguntas. No elijas el de número fijo.',
          availableBlocks: [
            _bayrak(),
            _de('sorular in 1 ile uzunluğu arasında rastgele öğesi',
                id: 'say_random_question',
                en: 'item (pick random 1 to length of questions) of '
                    'questions',
                de: 'Element (Zufallszahl von 1 bis Länge von Fragen) von '
                    'Fragen',
                es: 'elemento (aleatorio entre 1 y longitud de preguntas) '
                    'de preguntas'),
            _listeUzunlugu('sorular',
                id: 'len_questions',
                listeEn: 'questions',
                listeDe: 'Fragen',
                listeEs: 'preguntas'),
            _listeOgesi('1', 'sorular',
                id: 'item_1_questions',
                listeEn: 'questions',
                listeDe: 'Fragen',
                listeEs: 'preguntas'),
          ],
          correctSequence: [
            'green_flag',
            'say_random_question',
          ],
          xpReward: 40,
        ),

        ExplanationStep(
          id: 's10_2_exp2',
          title: 'Aynı Soru İki Kez Çıkmasın',
          titleEn: 'Stop the Same Question Twice',
          titleDe: 'Dieselbe Frage nicht zweimal',
          titleEs: 'Que no salga la misma pregunta dos veces',
          content:
              'Rastgele seçmenin bir aksiliği var: aynı soru üst üste '
              'çıkabilir. Zar iki kere 4 gelebiliyor, liste de öyle.\n\n'
              'Çözüm basit ve zekice: soruyu sorduktan sonra onu listeden '
              'SİL.\n\n'
              '   1 → rastgele bir numara seç\n'
              '   2 → o numaradaki soruyu söyle\n'
              '   3 → o numaradaki soruyu sil\n\n'
              'Liste her turda bir kısalıyor, uzunluğu da kendiliğinden '
              'küçülüyor. Uzunluk sıfıra düştüğünde bütün sorular bitmiş '
              'demektir — oyunun sonu tam olarak burası.\n\n'
              'Ama dikkat: sildiğin soru gitti. Bir daha oynamak '
              'istiyorsan bayrağa basıldığında listeyi baştan kurman '
              'gerekiyor.',
          contentEn:
              'Random choosing has one annoyance: the same question can '
              'come up twice in a row. A die can roll 4 twice, and so can '
              'a list.\n\n'
              'The fix is simple and clever: after asking a question, '
              'DELETE it from the list.\n\n'
              '   1 → pick a random number\n'
              '   2 → say the question at that number\n'
              '   3 → delete the question at that number\n\n'
              'The list gets one shorter each round, and its length shrinks '
              'by itself. When the length hits zero every question has been '
              'asked — that is exactly where the game ends.\n\n'
              'Careful though: a deleted question is gone. To play again '
              'you must rebuild the list when the flag is clicked.',
          contentDe:
              'Zufälliges Wählen hat einen Haken: dieselbe Frage kann '
              'zweimal hintereinander kommen. Ein Würfel kann zweimal 4 '
              'zeigen, eine Liste auch.\n\n'
              'Die Lösung ist einfach und clever: LÖSCHE die Frage, '
              'nachdem du sie gestellt hast.\n\n'
              '   1 → eine Zufallszahl wählen\n'
              '   2 → die Frage an dieser Nummer sagen\n'
              '   3 → die Frage an dieser Nummer löschen\n\n'
              'Die Liste wird jede Runde kürzer, die Länge schrumpft von '
              'selbst. Bei Länge null sind alle Fragen durch — genau da '
              'endet das Spiel.\n\n'
              'Aber Achtung: eine gelöschte Frage ist weg. Zum Neustart '
              'musst du die Liste bei Klick auf die Flagge neu aufbauen.',
          contentEs:
              'Elegir al azar tiene un pero: la misma pregunta puede salir '
              'dos veces seguidas. Un dado puede sacar 4 dos veces, y una '
              'lista también.\n\n'
              'La solución es simple y lista: después de preguntar, BORRA '
              'la pregunta de la lista.\n\n'
              '   1 → saca un número al azar\n'
              '   2 → di la pregunta de ese número\n'
              '   3 → borra la pregunta de ese número\n\n'
              'La lista se acorta cada ronda y su longitud baja sola. '
              'Cuando la longitud llega a cero, todas las preguntas han '
              'salido: ahí acaba el juego.\n\n'
              'Ojo: una pregunta borrada ya no está. Para volver a jugar '
              'tienes que rehacer la lista al pulsar la bandera.',
        ),

        MultipleChoiceStep(
          id: 's10_2_q1',
          question: 'Sorduğun soruyu listeden silmenin faydası ne?',
          questionEn: 'Why delete a question from the list after asking '
              'it?',
          questionDe: 'Warum eine Frage nach dem Stellen löschen?',
          questionEs: '¿Para qué borrar la pregunta después de hacerla?',
          options: [
            ChoiceOption(
              text: 'Aynı soru bir daha çıkmaz, uzunluk da sona işaret '
                  'eder',
              textEn: 'It cannot come up again, and the length marks the '
                  'end',
              textDe: 'Sie kommt nicht wieder, und die Länge zeigt das '
                  'Ende',
              textEs: 'No vuelve a salir y la longitud marca el final',
            ),
            ChoiceOption(
              text: 'Program daha hızlı çalışır',
              textEn: 'The program runs faster',
              textDe: 'Das Programm läuft schneller',
              textEs: 'El programa va más rápido',
            ),
            ChoiceOption(
              text: 'Listeyi alfabetik sıralar',
              textEn: 'It sorts the list alphabetically',
              textDe: 'Es sortiert die Liste alphabetisch',
              textEs: 'Ordena la lista alfabéticamente',
            ),
            ChoiceOption(
              text: 'Hiçbir faydası yok, sadece süsleme',
              textEn: 'No reason, it is just decoration',
              textDe: 'Kein Grund, nur Deko',
              textEs: 'Ninguno, es solo adorno',
            ),
          ],
          correctIndex: 0,
          explanation:
              'İki kazanç birden: tekrar yok ve bitiş koşulu hazır. '
              'Uzunluk sıfıra düştüğü an bütün sorular sorulmuş olur, '
              'oyunu orada bitirebilirsin.',
          explanationEn:
              'Two wins at once: no repeats, and your ending condition is '
              'ready. The moment the length reaches zero every question '
              'has been asked and you can end the game there.',
          explanationDe:
              'Zwei Vorteile: keine Wiederholung und die Abbruchbedingung '
              'ist fertig. Sobald die Länge null ist, sind alle Fragen '
              'gestellt und du kannst das Spiel beenden.',
          explanationEs:
              'Dos ventajas: no hay repeticiones y ya tienes la condición '
              'de final. Cuando la longitud llega a cero, todas las '
              'preguntas han salido y puedes terminar.',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 's10_2_summary',
          title: 'Oyun Kurdun!',
          titleEn: 'You Built a Game!',
          titleDe: 'Du hast ein Spiel gebaut!',
          titleEs: '¡Has hecho un juego!',
          content: '🎒 Liste ile şans bir araya geldi.\n\n'
              '✓ Bloğun içine blok koydun\n'
              '✓ "1 ile uzunluk arasında" kuralını öğrendin\n'
              '✓ Sorulan soruyu silerek tekrarı engelledin\n\n'
              'Denemelik: listeye kendi sorularını ekle. Programda hiçbir '
              'şeyi değiştirmen gerekmeyecek.',
          contentEn: '🎒 Lists and chance came together.\n\n'
              '✓ You nested a block inside a block\n'
              '✓ You learned the "1 to the length" rule\n'
              '✓ You stopped repeats by deleting what was asked\n\n'
              'Try it: add your own questions to the list. You will not '
              'have to change a single block.',
          contentDe: '🎒 Listen und Zufall kamen zusammen.\n\n'
              '✓ Du hast einen Block in einen Block gesteckt\n'
              '✓ Du kennst die Regel «1 bis Länge»\n'
              '✓ Du verhinderst Wiederholungen durch Löschen\n\n'
              'Probier es: füge eigene Fragen hinzu. Du musst keinen '
              'einzigen Block ändern.',
          contentEs: '🎒 Listas y azar se juntaron.\n\n'
              '✓ Anidaste un bloque dentro de otro\n'
              '✓ Aprendiste la regla «de 1 a la longitud»\n'
              '✓ Evitaste repeticiones borrando lo ya preguntado\n\n'
              'Pruébalo: añade tus propias preguntas. No tendrás que '
              'cambiar ni un bloque.',
          tipEmoji: '🏆',
          tip: 'Oyun Kurucu rozetini kazandın!',
          tipEn: 'You earned the Game Builder badge!',
          tipDe: 'Du hast das Spielebauer-Abzeichen verdient!',
          tipEs: '¡Has ganado la insignia Creador de Juegos!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODÜL 11 — KENDİ BLOĞUN
  // ==========================================

  static final List<InteractiveLesson> module11 = [
    // --------------------------------------------------------- Ders 11.1
    InteractiveLesson(
      id: 'scratch_11_1',
      courseId: 'scratch',
      title: 'Kendi Bloğunu Yap',
      subtitle: 'Blok tanımla, sonra adıyla çağır',
      titleEn: 'Make Your Own Block',
      titleDe: 'Baue deinen eigenen Block',
      titleEs: 'Crea tu propio bloque',
      subtitleEn: 'Define a block, then call it by name',
      subtitleDe: 'Einen Block definieren und beim Namen rufen',
      subtitleEs: 'Define un bloque y llámalo por su nombre',
      order: 19,
      xpReward: 90,
      badge: 'block_builder',
      steps: [
        IntroStep(
          id: 's11_1_intro',
          mascotEmoji: '🧱',
          mascotMessage:
              'Sekizinci modülde kare çizdin: dört blok. Üç kare çizmek '
              'istersen on iki blok. Yığın öyle uzuyor ki neyin ne olduğunu '
              'göremiyorsun.\n\n'
              'Scratch buna bir çözüm veriyor: o dört bloğa bir AD koyup '
              'tek bir blok haline getirebiliyorsun. Adını "kare" koydun '
              'mu, artık paletinde kare bloğu var — Scratch\'in kendi '
              'bloklarından bir farkı kalmıyor.',
          mascotMessageEn:
              'In module 8 you drew a square: four blocks. Three squares '
              'means twelve. The stack gets so long you can no longer see '
              'what is what.\n\n'
              'Scratch has an answer: give those four blocks a NAME and '
              'they become one single block. Call it "square" and your '
              'palette now has a square block — no different from the ones '
              'Scratch ships with.',
          mascotMessageDe:
              'In Modul 8 hast du ein Quadrat gezeichnet: vier Blöcke. Drei '
              'Quadrate sind zwölf. Der Stapel wird so lang, dass du nichts '
              'mehr erkennst.\n\n'
              'Scratch hat eine Antwort: gib diesen vier Blöcken einen '
              'NAMEN, und sie werden ein einziger Block. Nenn ihn '
              '«Quadrat», und deine Palette hat einen Quadrat-Block — wie '
              'die von Scratch selbst.',
          mascotMessageEs:
              'En el módulo 8 dibujaste un cuadrado: cuatro bloques. Tres '
              'cuadrados son doce. La pila se hace tan larga que ya no '
              'distingues nada.\n\n'
              'Scratch tiene una respuesta: pon un NOMBRE a esos cuatro '
              'bloques y se convierten en uno solo. Llámalo «cuadrado» y tu '
              'paleta tendrá un bloque cuadrado, igual que los de Scratch.',
          highlights: [
            'Tanımla bir kez, kullan defalarca',
            'Uzun yığın yerine tek blok',
            'Kendi bloğun palete gelir',
          ],
          highlightsEn: [
            'Define once, use many times',
            'One block instead of a long stack',
            'Your block joins the palette',
          ],
          highlightsDe: [
            'Einmal definieren, oft benutzen',
            'Ein Block statt eines langen Stapels',
            'Dein Block kommt in die Palette',
          ],
          highlightsEs: [
            'Define una vez, usa muchas',
            'Un bloque en vez de una pila larga',
            'Tu bloque entra en la paleta',
          ],
        ),

        ExplanationStep(
          id: 's11_1_exp1',
          title: 'Tanımlamak ve Çağırmak',
          titleEn: 'Defining and Calling',
          titleDe: 'Definieren und aufrufen',
          titleEs: 'Definir y llamar',
          content:
              'Kendi bloğun iki parçadan oluşuyor ve ikisini karıştırmamak '
              'çok önemli:\n\n'
              'TANIM — pembe bir başlık bloğu: "kare i tanımla". Altına '
              'takılan bloklar, bloğun ne yaptığıdır. Bu yığın kendi '
              'kendine çalışmaz; orada durup bekler, bir tarif gibi.\n\n'
              'ÇAĞRI — palette görünen "kare" bloğu. Nereye takarsan orada '
              'tarifi uygular.\n\n'
              'Yani tanımı bir kere yazıyorsun, çağrıyı istediğin kadar. '
              'Kendi bloğunu yapmak için "Kendi Bloklarım" kategorisine '
              'gidip "Bir Blok Oluştur" düğmesine basıyorsun.',
          contentEn:
              'Your own block comes in two parts, and mixing them up is the '
              'classic beginner mistake:\n\n'
              'THE DEFINITION — a pink hat block: "define square". Whatever '
              'you attach under it is what the block does. This stack never '
              'runs on its own; it just sits there like a recipe.\n\n'
              'THE CALL — the "square" block that shows up in the palette. '
              'Wherever you attach it, it carries out the recipe.\n\n'
              'So you write the definition once and use the call as often '
              'as you like. To make one, go to "My Blocks" and press "Make '
              'a Block".',
          contentDe:
              'Dein eigener Block besteht aus zwei Teilen, und sie zu '
              'verwechseln ist der klassische Anfängerfehler:\n\n'
              'DIE DEFINITION — ein rosa Hut-Block: «Definiere Quadrat». '
              'Was du darunter hängst, ist das, was der Block tut. Dieser '
              'Stapel läuft nie von selbst; er liegt da wie ein Rezept.\n\n'
              'DER AUFRUF — der «Quadrat»-Block in der Palette. Wo du ihn '
              'anhängst, führt er das Rezept aus.\n\n'
              'Die Definition schreibst du also einmal, den Aufruf so oft '
              'du willst. Zum Anlegen gehst du zu «Meine Blöcke» und '
              'drückst «Neuer Block».',
          contentEs:
              'Tu bloque tiene dos partes, y confundirlas es el error '
              'clásico:\n\n'
              'LA DEFINICIÓN — un bloque sombrero rosa: «definir '
              'cuadrado». Lo que cuelgues debajo es lo que hace el bloque. '
              'Esa pila nunca se ejecuta sola; está ahí como una receta.'
              '\n\n'
              'LA LLAMADA — el bloque «cuadrado» que aparece en la paleta. '
              'Donde lo enganches, aplica la receta.\n\n'
              'Así que escribes la definición una vez y usas la llamada '
              'todas las que quieras. Para crearlo, ve a «Mis bloques» y '
              'pulsa «Crear un bloque».',
          tipEmoji: '📖',
          tip: 'Tanım tarif, çağrı yemek yapmaktır. Tarif mutfakta durur, '
              'bir şey olmaz; pişirmek için okunması gerekir.',
          tipEn: 'The definition is the recipe, the call is cooking. A '
              'recipe on the shelf does nothing until someone reads it.',
          tipDe: 'Die Definition ist das Rezept, der Aufruf das Kochen. Ein '
              'Rezept im Regal tut nichts, bis es jemand liest.',
          tipEs: 'La definición es la receta; la llamada, cocinar. Una '
              'receta en el estante no hace nada hasta que alguien la lee.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'kare i tanımla',
              contentEn: 'define square',
              contentDe: 'Definiere Quadrat',
              contentEs: 'definir cuadrado',
              color: blokRengi,
              label: 'Kendi Bloklarım · başlık bloğu',
              labelEn: 'My Blocks · hat block',
              labelDe: 'Meine Blöcke · Hut-Block',
              labelEs: 'Mis bloques · bloque sombrero',
            ),
          ],
        ),

        BlockBuilderStep(
          id: 's11_1_build1',
          instruction: 'Kare bloğunu TANIMLA.',
          instructionEn: 'DEFINE the square block.',
          instructionDe: 'DEFINIERE den Quadrat-Block.',
          instructionEs: 'DEFINE el bloque cuadrado.',
          goal: 'kare i tanımla → 4 kere tekrarla { 100 adım git, 90 derece '
              'dön }. Başa bayrak koyma: tanım kendi başlığıyla başlar.',
          goalEn: 'define square → repeat 4 { move 100, turn 90 }. No flag '
              'on top: a definition has its own hat.',
          goalDe: 'Definiere Quadrat → wiederhole 4 mal { gehe 100, drehe '
              '90 }. Keine Flagge oben: die Definition hat ihren eigenen '
              'Hut.',
          goalEs: 'definir cuadrado → repetir 4 { mover 100, girar 90 }. '
              'Sin bandera arriba: la definición ya tiene su sombrero.',
          availableBlocks: [
            _tanimla('kare',
                id: 'define_square',
                en: 'square',
                de: 'Quadrat',
                es: 'cuadrado'),
            _tekrarla('4', id: 'repeat_4'),
            _git('100', id: 'move_100'),
            _don('90', id: 'turn_90'),
            _bayrak(),
          ],
          correctSequence: [
            'define_square',
            'repeat_4',
            'move_100',
            'turn_90',
          ],
          xpReward: 35,
        ),

        BlockBuilderStep(
          id: 's11_1_build2',
          instruction: 'Şimdi kare bloğunu ÇAĞIR — üç kere.',
          instructionEn: 'Now CALL the square block — three times.',
          instructionDe: 'Jetzt RUFE den Quadrat-Block auf — dreimal.',
          instructionEs: 'Ahora LLAMA al bloque cuadrado, tres veces.',
          goal: 'Bayrak → 3 kere tekrarla { kare, 120 derece dön }. Dört '
              'blokla üç kare çizdin.',
          goalEn: 'Flag → repeat 3 { square, turn 120 }. Three squares out '
              'of four blocks.',
          goalDe: 'Flagge → wiederhole 3 mal { Quadrat, drehe 120 }. Drei '
              'Quadrate aus vier Blöcken.',
          goalEs: 'Bandera → repetir 3 { cuadrado, girar 120 }. Tres '
              'cuadrados con cuatro bloques.',
          availableBlocks: [
            _bayrak(),
            _tekrarla('3', id: 'repeat_3'),
            _kendiBlok('kare',
                id: 'call_square',
                en: 'square',
                de: 'Quadrat',
                es: 'cuadrado'),
            _don('120', id: 'turn_120'),
            _tanimla('kare',
                id: 'define_square_2',
                en: 'square',
                de: 'Quadrat',
                es: 'cuadrado'),
          ],
          correctSequence: [
            'green_flag',
            'repeat_3',
            'call_square',
            'turn_120',
          ],
          xpReward: 35,
        ),

        MultipleChoiceStep(
          id: 's11_1_q1',
          question: 'Kendi bloğunu yaptın ama bayrağa bastığında hiçbir şey '
              'olmuyor. En muhtemel sebep?',
          questionEn: 'You made your own block but nothing happens when you '
              'click the flag. Most likely reason?',
          questionDe: 'Du hast deinen Block gebaut, aber beim Klick auf die '
              'Flagge passiert nichts. Wahrscheinlichster Grund?',
          questionEs: 'Creaste tu bloque pero al pulsar la bandera no pasa '
              'nada. ¿Causa más probable?',
          options: [
            ChoiceOption(
              text: 'Sadece tanımı yazdın, bloğu hiç çağırmadın',
              textEn: 'You only wrote the definition, you never called the '
                  'block',
              textDe: 'Du hast nur definiert und den Block nie aufgerufen',
              textEs: 'Solo escribiste la definición, nunca llamaste al '
                  'bloque',
            ),
            ChoiceOption(
              text: 'Kendi blokları sadece ücretli hesaplarda çalışır',
              textEn: 'Custom blocks only work on paid accounts',
              textDe: 'Eigene Blöcke gehen nur mit bezahltem Konto',
              textEs: 'Los bloques propios solo van con cuenta de pago',
            ),
            ChoiceOption(
              text: 'Bloğa Türkçe ad verdin',
              textEn: 'You gave the block a name in your own language',
              textDe: 'Du hast dem Block einen Namen in deiner Sprache '
                  'gegeben',
              textEs: 'Le pusiste un nombre en tu idioma',
            ),
            ChoiceOption(
              text: 'Tanımın içinde döngü var',
              textEn: 'Your definition contains a loop',
              textDe: 'In deiner Definition steckt eine Schleife',
              textEs: 'Tu definición tiene un bucle',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Tanım bir tarif; okunmadıkça hiçbir şey pişmiyor. Bayrak '
              'yığınına kendi bloğunu takmadıysan program tanımı hiç '
              'ziyaret etmiyor.',
          explanationEn:
              'A definition is a recipe; nothing cooks until it is read. If '
              'your block is not attached under the flag, the program never '
              'visits the definition.',
          explanationDe:
              'Eine Definition ist ein Rezept; ohne Lesen wird nichts '
              'gekocht. Hängt dein Block nicht unter der Flagge, besucht '
              'das Programm die Definition nie.',
          explanationEs:
              'Una definición es una receta; si nadie la lee, no se cocina. '
              'Si tu bloque no cuelga de la bandera, el programa nunca pasa '
              'por la definición.',
          xpReward: 20,
        ),

        MatchingStep(
          id: 's11_1_match1',
          instruction: 'Hangisi tanım, hangisi çağrı?',
          instructionEn: 'Which is the definition, which is the call?',
          instructionDe: 'Was ist Definition, was Aufruf?',
          instructionEs: '¿Qué es definición y qué es llamada?',
          pairs: [
            MatchPair(
              id: 'b1',
              left: 'kare i tanımla',
              right: 'Tarif — kendi başına çalışmaz',
              leftEn: 'define square',
              rightEn: 'The recipe — never runs on its own',
              leftDe: 'Definiere Quadrat',
              rightDe: 'Das Rezept — läuft nie allein',
              leftEs: 'definir cuadrado',
              rightEs: 'La receta: no se ejecuta sola',
            ),
            MatchPair(
              id: 'b2',
              left: 'kare',
              right: 'Çağrı — takıldığı yerde çalışır',
              leftEn: 'square',
              rightEn: 'The call — runs where you attach it',
              leftDe: 'Quadrat',
              rightDe: 'Der Aufruf — läuft, wo du ihn anhängst',
              leftEs: 'cuadrado',
              rightEs: 'La llamada: se ejecuta donde la pongas',
            ),
            MatchPair(
              id: 'b3',
              left: 'Pembe başlık bloğu',
              right: 'Tanımın en üstü',
              leftEn: 'The pink hat block',
              rightEn: 'The top of the definition',
              leftDe: 'Der rosa Hut-Block',
              rightDe: 'Der Kopf der Definition',
              leftEs: 'El bloque sombrero rosa',
              rightEs: 'La cabeza de la definición',
            ),
            MatchPair(
              id: 'b4',
              left: 'Paletteki pembe blok',
              right: 'İstediğin kadar kullanabildiğin parça',
              leftEn: 'The pink block in the palette',
              rightEn: 'The piece you can use as often as you like',
              leftDe: 'Der rosa Block in der Palette',
              rightDe: 'Das Teil, das du beliebig oft nutzt',
              leftEs: 'El bloque rosa de la paleta',
              rightEs: 'La pieza que usas tantas veces como quieras',
            ),
          ],
          xpReward: 20,
        ),

        ExplanationStep(
          id: 's11_1_summary',
          title: 'Kendi Bloğunu Yaptın!',
          titleEn: 'You Made Your Own Block!',
          titleDe: 'Du hast deinen Block gebaut!',
          titleEs: '¡Has creado tu bloque!',
          content: '🧱 Artık Scratch\'e yeni bir blok ekleyebiliyorsun.\n\n'
              '✓ Tanım ile çağrı arasındaki farkı öğrendin\n'
              '✓ Dört bloğu tek isim altında topladın\n'
              '✓ Üç kareyi dört blokla çizdin\n\n'
              'Sıradaki ders: bloğuna GİRDİ vermek. Tek bir blok hem kare '
              'hem üçgen çizecek.',
          contentEn: '🧱 You can add a new block to Scratch now.\n\n'
              '✓ You learned definition versus call\n'
              '✓ You gathered four blocks under one name\n'
              '✓ You drew three squares with four blocks\n\n'
              'Next lesson: giving your block an INPUT. One block will draw '
              'both a square and a triangle.',
          contentDe: '🧱 Du kannst Scratch jetzt einen Block hinzufügen.\n\n'
              '✓ Du kennst Definition gegen Aufruf\n'
              '✓ Du hast vier Blöcke unter einem Namen gebündelt\n'
              '✓ Du hast drei Quadrate mit vier Blöcken gezeichnet\n\n'
              'Nächste Lektion: deinem Block eine EINGABE geben. Ein Block '
              'zeichnet dann Quadrat und Dreieck.',
          contentEs: '🧱 Ya puedes añadir un bloque nuevo a Scratch.\n\n'
              '✓ Aprendiste la diferencia entre definir y llamar\n'
              '✓ Juntaste cuatro bloques bajo un nombre\n'
              '✓ Dibujaste tres cuadrados con cuatro bloques\n\n'
              'Siguiente lección: dar una ENTRADA a tu bloque. Un solo '
              'bloque hará cuadrado y triángulo.',
          tipEmoji: '🏆',
          tip: 'Blok Yapımcısı rozetini kazandın!',
          tipEn: 'You earned the Block Maker badge!',
          tipDe: 'Du hast das Blockbauer-Abzeichen verdient!',
          tipEs: '¡Has ganado la insignia Creador de Bloques!',
        ),
      ],
    ),
    // --------------------------------------------------------- Ders 11.2
    InteractiveLesson(
      id: 'scratch_11_2',
      courseId: 'scratch',
      title: 'Bloğuna Girdi Ver',
      subtitle: 'Tek blok, her şekil',
      titleEn: 'Give Your Block an Input',
      titleDe: 'Gib deinem Block eine Eingabe',
      titleEs: 'Dale una entrada a tu bloque',
      subtitleEn: 'One block, every shape',
      subtitleDe: 'Ein Block, jede Form',
      subtitleEs: 'Un bloque, todas las figuras',
      order: 20,
      xpReward: 100,
      badge: 'block_master',
      steps: [
        IntroStep(
          id: 's11_2_intro',
          mascotEmoji: '🎛️',
          mascotMessage:
              'Kare bloğun güzel ama sadece kare çiziyor. Üçgen için '
              'ikinci, beşgen için üçüncü blok mu yapacaksın?\n\n'
              'Scratch\'in kendi bloklarına bak: "10 adım git" bloğunda bir '
              'boşluk var, sayıyı sen yazıyorsun. Kendi bloğuna da aynı '
              'boşluğu ekleyebilirsin. O boşluğa GİRDİ deniyor ve bir '
              'bloğu on bloğun işini yapacak hâle getiriyor.',
          mascotMessageEn:
              'Your square block is nice, but it only draws squares. Are '
              'you going to make a second one for triangles and a third for '
              'pentagons?\n\n'
              'Look at Scratch\'s own blocks: "move 10 steps" has a slot '
              'and you type the number. You can add that same slot to your '
              'own block. It is called an INPUT, and it makes one block do '
              'the work of ten.',
          mascotMessageDe:
              'Dein Quadrat-Block ist schön, zeichnet aber nur Quadrate. '
              'Baust du einen zweiten für Dreiecke und einen dritten für '
              'Fünfecke?\n\n'
              'Schau dir Scratchs eigene Blöcke an: «gehe 10 er Schritt» '
              'hat eine Lücke, die Zahl tippst du. Diese Lücke kannst du '
              'auch deinem Block geben. Sie heißt EINGABE und macht aus '
              'einem Block die Arbeit von zehn.',
          mascotMessageEs:
              'Tu bloque cuadrado está bien, pero solo dibuja cuadrados. '
              '¿Vas a hacer otro para triángulos y un tercero para '
              'pentágonos?\n\n'
              'Mira los bloques de Scratch: «mover 10 pasos» tiene un hueco '
              'y tú escribes el número. Ese mismo hueco puedes ponerlo en '
              'tu bloque. Se llama ENTRADA y hace que un bloque haga el '
              'trabajo de diez.',
          highlights: [
            'Girdi = bloğun boşluğu',
            'Aynı blok, farklı sayı',
            '360 kuralı iş başında',
          ],
          highlightsEn: [
            'An input is a slot in your block',
            'Same block, different number',
            'The rule of 360 at work',
          ],
          highlightsDe: [
            'Eine Eingabe ist eine Lücke im Block',
            'Gleicher Block, andere Zahl',
            'Die 360-Regel bei der Arbeit',
          ],
          highlightsEs: [
            'Una entrada es un hueco en tu bloque',
            'Mismo bloque, otro número',
            'La regla del 360 en acción',
          ],
        ),

        ExplanationStep(
          id: 's11_2_exp1',
          title: 'Girdi Nasıl Eklenir',
          titleEn: 'How to Add an Input',
          titleDe: 'So fügst du eine Eingabe hinzu',
          titleEs: 'Cómo añadir una entrada',
          content:
              'Blok oluşturma penceresinde, adın altında üç seçenek var: '
              '"sayı ya da metin girdisi ekle", "mantıksal girdi ekle", '
              '"etiket ekle".\n\n'
              'Birinciye basıyorsun ve girdiye bir ad veriyorsun: kenar.\n\n'
              'Şimdi tanım başlığı şöyle görünüyor:\n\n'
              '   çokgen (kenar) i tanımla\n\n'
              'O pembe "kenar" yazısı tanımın içinde SÜRÜKLENEBİLİR bir '
              'parça. Onu 100 yazan boşluklara taşıyabiliyorsun. Blok '
              'çağrıldığında içine yazdığın sayı, o parçanın bulunduğu her '
              'yere geçiyor.\n\n'
              'Yani "çokgen 5" dediğinde tanımın içindeki kenar, 5 oluyor.',
          contentEn:
              'In the Make a Block window, under the name, there are three '
              'options: "add an input number or text", "add an input '
              'boolean", "add a label".\n\n'
              'Press the first one and give the input a name: sides.\n\n'
              'Your definition hat now reads:\n\n'
              '   define polygon (sides)\n\n'
              'That pink word "sides" is a DRAGGABLE piece inside the '
              'definition. You can drop it into the slots where 100 sits. '
              'When the block is called, the number you typed lands '
              'everywhere that piece appears.\n\n'
              'So "polygon 5" makes sides equal 5 inside the definition.',
          contentDe:
              'Im Fenster «Neuer Block» stehen unter dem Namen drei '
              'Optionen: «Eingabe (Zahl oder Text) hinzufügen», «Eingabe '
              '(Wahrheitswert) hinzufügen», «Text hinzufügen».\n\n'
              'Drück die erste und nenne die Eingabe: Seiten.\n\n'
              'Der Definitionskopf liest sich nun:\n\n'
              '   Definiere Vieleck (Seiten)\n\n'
              'Das rosa Wort «Seiten» ist ein ZIEHBARES Teil in der '
              'Definition. Du kannst es in die Lücken ziehen, wo 100 steht. '
              'Beim Aufruf landet die getippte Zahl überall dort, wo das '
              'Teil steckt.\n\n'
              'Bei «Vieleck 5» ist Seiten in der Definition also 5.',
          contentEs:
              'En la ventana Crear un bloque, bajo el nombre hay tres '
              'opciones: «añadir una entrada numérica o de texto», «añadir '
              'una entrada booleana», «añadir una etiqueta».\n\n'
              'Pulsa la primera y ponle nombre a la entrada: lados.\n\n'
              'El sombrero de la definición queda así:\n\n'
              '   definir polígono (lados)\n\n'
              'Esa palabra rosa «lados» es una pieza ARRASTRABLE dentro de '
              'la definición. Puedes llevarla a los huecos donde pone 100. '
              'Al llamar al bloque, el número que escribes aparece en todos '
              'los sitios donde esté la pieza.\n\n'
              'Así que «polígono 5» hace que lados valga 5 dentro de la '
              'definición.',
          tipEmoji: '🧩',
          tip: 'Girdiyi boşluğa SÜRÜKLEMEN gerekiyor; adını elle yazarsan '
              'Scratch onu harf harf metin sanıyor ve blok çalışmıyor.',
          tipEn: 'You must DRAG the input into the slot. If you type its '
              'name by hand, Scratch reads it as plain text and the block '
              'will not work.',
          tipDe: 'Du musst die Eingabe in die Lücke ZIEHEN. Tippst du den '
              'Namen von Hand, liest Scratch ihn als Text und der Block '
              'geht nicht.',
          tipEs: 'Tienes que ARRASTRAR la entrada al hueco. Si escribes su '
              'nombre a mano, Scratch lo lee como texto y no funciona.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'çokgen (kenar) i tanımla',
              contentEn: 'define polygon (sides)',
              contentDe: 'Definiere Vieleck (Seiten)',
              contentEs: 'definir polígono (lados)',
              color: blokRengi,
              label: 'Kendi Bloklarım · girdili tanım',
              labelEn: 'My Blocks · definition with an input',
              labelDe: 'Meine Blöcke · Definition mit Eingabe',
              labelEs: 'Mis bloques · definición con entrada',
            ),
          ],
        ),

        ExplanationStep(
          id: 's11_2_exp2',
          title: 'Girdi ile 360 Kuralı',
          titleEn: 'The Input Meets the Rule of 360',
          titleDe: 'Die Eingabe trifft die 360-Regel',
          titleEs: 'La entrada y la regla del 360',
          content:
              'Sekizinci modülde öğrendiğin kuralı hatırla:\n\n'
              '   dönüş açısı = 360 ÷ kenar sayısı\n\n'
              'Bu kural şimdi çok işine yarıyor, çünkü kenar sayısı artık '
              'bir girdi. Tanımın içi şöyle oluyor:\n\n'
              '   çokgen (kenar) i tanımla\n'
              '     kenar kere tekrarla\n'
              '       100 adım git\n'
              '       ↻ (360 / kenar) derece dön\n\n'
              'Tek tanım, bütün şekiller:\n\n'
              '• çokgen 3 → üçgen (120 derece)\n'
              '• çokgen 4 → kare (90 derece)\n'
              '• çokgen 6 → altıgen (60 derece)\n'
              '• çokgen 36 → göz onu daire sanıyor\n\n'
              'Bölme bloğu İŞLEMLER kategorisinde: iki boşluklu oval bir '
              'blok. Sol boşluğa 360, sağ boşluğa kenar girdisini '
              'sürüklüyorsun.',
          contentEn:
              'Remember the rule from module 8:\n\n'
              '   turn = 360 ÷ number of sides\n\n'
              'It pays off now, because the number of sides is an input. '
              'Inside the definition:\n\n'
              '   define polygon (sides)\n'
              '     repeat (sides)\n'
              '       move 100 steps\n'
              '       turn ↻ (360 / sides) degrees\n\n'
              'One definition, every shape:\n\n'
              '• polygon 3 → triangle (120 degrees)\n'
              '• polygon 4 → square (90 degrees)\n'
              '• polygon 6 → hexagon (60 degrees)\n'
              '• polygon 36 → your eye calls it a circle\n\n'
              'The division block is in OPERATORS: an oval block with two '
              'slots. Type 360 on the left and drag the sides input into '
              'the right.',
          contentDe:
              'Erinnere dich an die Regel aus Modul 8:\n\n'
              '   Drehwinkel = 360 ÷ Anzahl der Seiten\n\n'
              'Jetzt zahlt sie sich aus, denn die Seitenzahl ist eine '
              'Eingabe. In der Definition:\n\n'
              '   Definiere Vieleck (Seiten)\n'
              '     wiederhole (Seiten) mal\n'
              '       gehe 100 er Schritt\n'
              '       drehe dich ↻ um (360 / Seiten) Grad\n\n'
              'Eine Definition, alle Formen:\n\n'
              '• Vieleck 3 → Dreieck (120 Grad)\n'
              '• Vieleck 4 → Quadrat (90 Grad)\n'
              '• Vieleck 6 → Sechseck (60 Grad)\n'
              '• Vieleck 36 → das Auge sieht einen Kreis\n\n'
              'Der Divisionsblock steht bei OPERATOREN: oval, mit zwei '
              'Lücken. Links 360 eintippen, rechts die Eingabe Seiten '
              'hineinziehen.',
          contentEs:
              'Recuerda la regla del módulo 8:\n\n'
              '   giro = 360 ÷ número de lados\n\n'
              'Ahora vale su peso en oro, porque el número de lados es una '
              'entrada. Dentro de la definición:\n\n'
              '   definir polígono (lados)\n'
              '     repetir (lados) veces\n'
              '       mover 100 pasos\n'
              '       girar ↻ (360 / lados) grados\n\n'
              'Una definición, todas las figuras:\n\n'
              '• polígono 3 → triángulo (120 grados)\n'
              '• polígono 4 → cuadrado (90 grados)\n'
              '• polígono 6 → hexágono (60 grados)\n'
              '• polígono 36 → el ojo ve un círculo\n\n'
              'El bloque de división está en OPERADORES: ovalado, con dos '
              'huecos. Escribe 360 a la izquierda y arrastra la entrada '
              'lados a la derecha.',
        ),

        BlockBuilderStep(
          id: 's11_2_build1',
          instruction: 'Girdili çokgen bloğunu tanımla.',
          instructionEn: 'Define the polygon block with an input.',
          instructionDe: 'Definiere den Vieleck-Block mit Eingabe.',
          instructionEs: 'Define el bloque polígono con entrada.',
          goal: 'çokgen (kenar) i tanımla → kenar kere tekrarla { 100 adım '
              'git, (360 / kenar) derece dön }',
          goalEn: 'define polygon (sides) → repeat (sides) { move 100, turn '
              '(360 / sides) }',
          goalDe: 'Definiere Vieleck (Seiten) → wiederhole (Seiten) mal '
              '{ gehe 100, drehe (360 / Seiten) }',
          goalEs: 'definir polígono (lados) → repetir (lados) { mover 100, '
              'girar (360 / lados) }',
          availableBlocks: [
            _tanimla('çokgen (kenar)',
                id: 'define_polygon',
                en: 'polygon (sides)',
                de: 'Vieleck (Seiten)',
                es: 'polígono (lados)'),
            _tekrarla('kenar',
                id: 'repeat_sides',
                en: 'sides',
                de: 'Seiten',
                es: 'lados'),
            _git('100', id: 'move_100_poly'),
            _don('360 / kenar',
                id: 'turn_360_over_sides',
                en: '360 / sides',
                de: '360 / Seiten',
                es: '360 / lados'),
            _don('90', id: 'turn_90_fixed'),
          ],
          correctSequence: [
            'define_polygon',
            'repeat_sides',
            'move_100_poly',
            'turn_360_over_sides',
          ],
          xpReward: 45,
        ),

        BlockBuilderStep(
          id: 's11_2_build2',
          instruction: 'Aynı blokla bir altıgen çiz.',
          instructionEn: 'Draw a hexagon with that same block.',
          instructionDe: 'Zeichne mit demselben Block ein Sechseck.',
          instructionEs: 'Dibuja un hexágono con ese mismo bloque.',
          goal: 'Bayrak → çokgen 6. Tek çağrı yetiyor; açıyı blok kendi '
              'hesaplıyor.',
          goalEn: 'Flag → polygon 6. One call is enough; the block works '
              'out the angle itself.',
          goalDe: 'Flagge → Vieleck 6. Ein Aufruf genügt; den Winkel '
              'rechnet der Block selbst.',
          goalEs: 'Bandera → polígono 6. Basta una llamada; el bloque '
              'calcula el ángulo.',
          availableBlocks: [
            _bayrak(),
            _kendiBlok('çokgen 6',
                id: 'call_polygon_6',
                en: 'polygon 6',
                de: 'Vieleck 6',
                es: 'polígono 6'),
            _kendiBlok('çokgen 4',
                id: 'call_polygon_4',
                en: 'polygon 4',
                de: 'Vieleck 4',
                es: 'polígono 4'),
            _don('60', id: 'turn_60_extra'),
          ],
          correctSequence: [
            'green_flag',
            'call_polygon_6',
          ],
          xpReward: 30,
        ),

        MultipleChoiceStep(
          id: 's11_2_q1',
          question: '"çokgen 8" dediğinde blok kaç derece dönecek?',
          questionEn: 'If you call "polygon 8", how many degrees does the '
              'block turn?',
          questionDe: 'Wenn du «Vieleck 8» aufrufst, um wie viele Grad '
              'dreht der Block?',
          questionEs: 'Si llamas «polígono 8», ¿cuántos grados gira el '
              'bloque?',
          options: [
            ChoiceOption(
              text: '45 derece, çünkü 360 ÷ 8 = 45',
              textEn: '45 degrees, because 360 ÷ 8 = 45',
              textDe: '45 Grad, denn 360 ÷ 8 = 45',
              textEs: '45 grados, porque 360 ÷ 8 = 45',
            ),
            ChoiceOption(
              text: '8 derece',
              textEn: '8 degrees',
              textDe: '8 Grad',
              textEs: '8 grados',
            ),
            ChoiceOption(
              text: '90 derece, tanımda öyle yazıyor',
              textEn: '90 degrees, that is what the definition says',
              textDe: '90 Grad, so steht es in der Definition',
              textEs: '90 grados, lo dice la definición',
            ),
            ChoiceOption(
              text: '360 derece',
              textEn: '360 degrees',
              textDe: '360 Grad',
              textEs: '360 grados',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Girdiye 8 yazdın, tanımın içindeki her "kenar" 8 oldu: '
              'döngü 8 kere döndü, açı da 360 / 8 = 45 oldu. Sekiz kenarlı '
              'bir şekil çizildi.',
          explanationEn:
              'You passed 8, so every "sides" inside the definition became '
              '8: the loop ran 8 times and the angle became 360 / 8 = 45. '
              'An eight-sided shape.',
          explanationDe:
              'Du hast 8 übergeben, also wurde jedes «Seiten» in der '
              'Definition zu 8: die Schleife lief 8 mal, der Winkel war '
              '360 / 8 = 45. Eine achtseitige Form.',
          explanationEs:
              'Pasaste 8, así que cada «lados» de la definición valió 8: el '
              'bucle dio 8 vueltas y el ángulo fue 360 / 8 = 45. Una figura '
              'de ocho lados.',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 's11_2_summary',
          title: 'Scratch Kursunu Bitirdin!',
          titleEn: 'You Finished the Scratch Course!',
          titleDe: 'Du hast den Scratch-Kurs beendet!',
          titleEs: '¡Has terminado el curso de Scratch!',
          content: '🎛️ Tek bloğunla bütün şekilleri çizebiliyorsun.\n\n'
              '✓ Bloğuna girdi ekledin\n'
              '✓ Girdiyi döngüye ve açı hesabına taşıdın\n'
              '✓ 360 kuralını girdiyle birleştirdin\n\n'
              'Buraya kadar öğrendiklerin gerçek programcılığın temel '
              'taşları: döngü, koşul, değişken, liste, rastgelelik ve '
              'fonksiyon. Python\'a geçtiğinde aynı altı fikri yeniden '
              'göreceksin — sadece blok yerine yazıyla.',
          contentEn: '🎛️ One block of yours draws every shape.\n\n'
              '✓ You added an input to your block\n'
              '✓ You carried the input into the loop and the angle\n'
              '✓ You combined the rule of 360 with an input\n\n'
              'What you have learned here are the cornerstones of real '
              'programming: loops, conditions, variables, lists, randomness '
              'and functions. When you move on to Python you will meet the '
              'same six ideas again — just typed instead of dragged.',
          contentDe: '🎛️ Ein Block von dir zeichnet jede Form.\n\n'
              '✓ Du hast deinem Block eine Eingabe gegeben\n'
              '✓ Du hast die Eingabe in Schleife und Winkel gebracht\n'
              '✓ Du hast die 360-Regel mit einer Eingabe verbunden\n\n'
              'Was du hier gelernt hast, sind die Grundsteine echten '
              'Programmierens: Schleifen, Bedingungen, Variablen, Listen, '
              'Zufall und Funktionen. In Python treffen dich die gleichen '
              'sechs Ideen wieder — nur getippt statt gezogen.',
          contentEs: '🎛️ Un solo bloque tuyo dibuja todas las figuras.\n\n'
              '✓ Añadiste una entrada a tu bloque\n'
              '✓ Llevaste la entrada al bucle y al ángulo\n'
              '✓ Uniste la regla del 360 con una entrada\n\n'
              'Lo aprendido aquí son los cimientos de la programación de '
              'verdad: bucles, condiciones, variables, listas, azar y '
              'funciones. Cuando pases a Python verás las mismas seis '
              'ideas, escritas en vez de arrastradas.',
          tipEmoji: '🏆',
          tip: 'Blok Ustası rozetini kazandın! Scratch kursu tamamlandı.',
          tipEn: 'You earned the Block Master badge! The Scratch course is '
              'complete.',
          tipDe: 'Du hast das Blockmeister-Abzeichen verdient! Der '
              'Scratch-Kurs ist abgeschlossen.',
          tipEs: '¡Has ganado la insignia Maestro de Bloques! Curso de '
              'Scratch completado.',
        ),
      ],
    ),
  ];
}
