import 'package:flutter/material.dart';

import '../models/interactive_lesson_model.dart';

/// Scratch kursu — Modül 8: Kalem ve Çizim.
///
/// NEDEN BU MODÜL
/// --------------
/// Kursta döngü vardı, hareket vardı, ama ikisinin BİRLEŞİMİ yoktu.
/// "10 kere tekrarla" çocuğa bir şey öğretiyordu ama sonucu ekranda
/// kalmıyordu: kukla gidiyor, geliyor, geriye iz kalmıyordu. Kalem
/// bunu değiştiriyor — döngünün çıktısı ekranda DURUYOR. Kare çizilince
/// "90 derece" artık soyut bir sayı değil, gözle görülen bir köşe.
///
/// Müfredat sırası Code Club'ın Scratch merdiveninden alındı (Paint Box
/// ve Turtle Power projelerinin öğrettiği kavram sırası). Metinler
/// bizim; Raspberry Pi Vakfı'nın kaynakları CC BY-SA 4.0 ve o metni
/// uyarlamak kendi ders metnimizi de aynı lisansa sokardı.
///
/// BLOK YAZILARI
/// -------------
/// Etiketler Scratch 3.0'ın Türkçe arayüzünden: "kalem indir",
/// "kalem kaldır", "sil", "kalem kalınlığını [] yap". Kalem
/// kategorisinin rengi #0FBD8C. Çocuk Scratch'i açınca bloğu aynı
/// yazıyla ve aynı renkte bulmalı.
class ScratchKalemLessonsData {
  ScratchKalemLessonsData._();

  /// Kalem kategorisinin Scratch'teki rengi.
  static const Color kalemRengi = Color(0xFF0FBD8C);
  static const Color hareketRengi = Color(0xFF4C97FF);
  static const Color kontrolRengi = Color(0xFFFFAB19);
  static const Color olaylarRengi = Color(0xFFFFBF00);

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

  static ScratchBlock _sil() => const ScratchBlock(
        id: 'pen_clear',
        blockType: ScratchBlockType.looks,
        shape: ScratchBlockShape.stack,
        label: 'sil',
        labelEn: 'erase all',
        labelDe: 'lösche alles',
        labelEs: 'borrar todo',
        color: kalemRengi,
      );

  static ScratchBlock _kalemIndir() => const ScratchBlock(
        id: 'pen_down',
        blockType: ScratchBlockType.looks,
        shape: ScratchBlockShape.stack,
        label: 'kalem indir',
        labelEn: 'pen down',
        labelDe: 'schalte Stift ein',
        labelEs: 'bajar lápiz',
        color: kalemRengi,
      );

  static ScratchBlock _kalemKaldir() => const ScratchBlock(
        id: 'pen_up',
        blockType: ScratchBlockType.looks,
        shape: ScratchBlockShape.stack,
        label: 'kalem kaldır',
        labelEn: 'pen up',
        labelDe: 'schalte Stift aus',
        labelEs: 'subir lápiz',
        color: kalemRengi,
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

  static ScratchBlock _don(String aci, {required String id}) => ScratchBlock(
        id: id,
        blockType: ScratchBlockType.motion,
        shape: ScratchBlockShape.stack,
        label: '↻ $aci derece dön',
        labelEn: 'turn ↻ $aci degrees',
        labelDe: 'drehe dich ↻ um $aci Grad',
        labelEs: 'girar ↻ $aci grados',
        color: hareketRengi,
      );

  static ScratchBlock _tekrarla(String kere, {required String id}) =>
      ScratchBlock(
        id: id,
        blockType: ScratchBlockType.control,
        shape: ScratchBlockShape.cBlock,
        label: '$kere kere tekrarla',
        labelEn: 'repeat $kere',
        labelDe: 'wiederhole $kere mal',
        labelEs: 'repetir $kere veces',
        color: kontrolRengi,
      );

  // ==========================================
  // MODÜL 8 — KALEM VE ÇİZİM
  // ==========================================

  static final List<InteractiveLesson> module8 = [
    // ---------------------------------------------------------- Ders 8.1
    InteractiveLesson(
      id: 'scratch_8_1',
      courseId: 'scratch',
      title: 'Kalem: Kukla İz Bırakıyor',
      subtitle: 'kalem indir, kalem kaldır, sil',
      titleEn: 'The Pen: Your Sprite Leaves a Trail',
      titleDe: 'Der Stift: Deine Figur hinterlässt eine Spur',
      titleEs: 'El lápiz: tu objeto deja un rastro',
      subtitleEn: 'pen down, pen up, erase all',
      subtitleDe: 'Stift ein, Stift aus, alles löschen',
      subtitleEs: 'bajar lápiz, subir lápiz, borrar todo',
      order: 13,
      xpReward: 70,
      badge: 'pen_starter',
      steps: [
        IntroStep(
          id: 's8_1_intro',
          mascotEmoji: '✏️',
          mascotMessage:
              'Şimdiye kadar kukla hareket ediyordu ama geriye hiçbir şey '
              'kalmıyordu. Kaleme bir dokunuş yetiyor: kukla nereye '
              'giderse orada bir çizgi bırakıyor. Programın çalıştıktan '
              'sonra da ekranda DURUYOR.',
          mascotMessageEn:
              'Until now your sprite moved but left nothing behind. One '
              'block changes that: with the pen down, wherever the sprite '
              'goes it draws a line. Your program STAYS on the screen '
              'after it finishes.',
          mascotMessageDe:
              'Bisher hat sich deine Figur bewegt, aber nichts '
              'hinterlassen. Ein Block ändert das: Mit eingeschaltetem '
              'Stift zeichnet die Figur überall dort eine Linie, wo sie '
              'hingeht. Dein Programm BLEIBT auf dem Bildschirm.',
          mascotMessageEs:
              'Hasta ahora tu objeto se movía pero no dejaba nada. Un '
              'bloque lo cambia: con el lápiz bajado, el objeto dibuja una '
              'línea por donde pasa. Tu programa SE QUEDA en la pantalla.',
          highlights: [
            'Kukla gittiği yere çiziyor',
            'Kalem indir / kalem kaldır',
            'Sonuç ekranda kalıyor',
          ],
          highlightsEn: [
            'The sprite draws where it goes',
            'Pen down / pen up',
            'The result stays on screen',
          ],
          highlightsDe: [
            'Die Figur zeichnet, wohin sie geht',
            'Stift ein / Stift aus',
            'Das Ergebnis bleibt sichtbar',
          ],
          highlightsEs: [
            'El objeto dibuja por donde va',
            'Bajar lápiz / subir lápiz',
            'El resultado se queda en pantalla',
          ],
        ),

        ExplanationStep(
          id: 's8_1_exp1',
          title: 'Kalem Bloklarını Getir',
          titleEn: 'Bring in the Pen Blocks',
          titleDe: 'Hol die Stift-Blöcke',
          titleEs: 'Trae los bloques de lápiz',
          content:
              'Kalem blokları Scratch\'te baştan açık DEĞİL. Sol alt '
              'köşedeki mavi düğmeye bas ("Eklenti ekle") ve listeden '
              'KALEM\'i seç.\n\n'
              'Seçtiğin anda palete yeni bir kategori geliyor: yeşile '
              'çalan bir renk ve içinde "kalem indir", "kalem kaldır", '
              '"sil" gibi bloklar.',
          contentEn:
              'The pen blocks are NOT there by default. Press the blue '
              'button in the bottom-left corner ("Add Extension") and pick '
              'PEN from the list.\n\n'
              'A new category appears in the palette right away: a '
              'green-teal colour holding "pen down", "pen up" and '
              '"erase all".',
          contentDe:
              'Die Stift-Blöcke sind NICHT von Anfang an da. Drücke unten '
              'links den blauen Knopf («Erweiterung hinzufügen») und wähle '
              'STIFT aus der Liste.\n\n'
              'Sofort erscheint eine neue Kategorie in der Palette: ein '
              'Grünton mit «schalte Stift ein», «schalte Stift aus» und '
              '«lösche alles».',
          contentEs:
              'Los bloques de lápiz NO están desde el principio. Pulsa el '
              'botón azul de abajo a la izquierda («Añadir extensión») y '
              'elige LÁPIZ de la lista.\n\n'
              'Aparece enseguida una categoría nueva en la paleta: un '
              'verde azulado con «bajar lápiz», «subir lápiz» y '
              '«borrar todo».',
          tipEmoji: '🧩',
          tip: 'Eklentiyi eklemeyi unutursan blokları palette ararsın ve '
              'bulamazsın — blok yok değil, kategori kapalı.',
          tipEn: 'If you forget the extension you will hunt for the blocks '
              'and not find them — they are not missing, the category is '
              'just closed.',
          tipDe: 'Wenn du die Erweiterung vergisst, suchst du die Blöcke '
              'vergeblich — sie fehlen nicht, die Kategorie ist nur zu.',
          tipEs: 'Si olvidas la extensión buscarás los bloques y no los '
              'encontrarás: no faltan, la categoría está cerrada.',
        ),

        ExplanationStep(
          id: 's8_1_exp2',
          title: 'İndir, Kaldır, Sil',
          titleEn: 'Down, Up, Erase',
          titleDe: 'Ein, aus, löschen',
          titleEs: 'Bajar, subir, borrar',
          content:
              'Üç blok her şeyi anlatıyor:\n\n'
              '• kalem indir → bundan sonra kukla nereye giderse çizer\n'
              '• kalem kaldır → artık çizmez, sadece hareket eder\n'
              '• sil → ekrandaki BÜTÜN çizimleri temizler\n\n'
              'Kalemi bir kez indirdin mi, sen kaldırana kadar inik kalır. '
              'Programın başına "sil" koymak iyi bir alışkanlık: yoksa her '
              'çalıştırışta eski çizimin üstüne çizersin.',
          contentEn:
              'Three blocks say it all:\n\n'
              '• pen down → from now on the sprite draws wherever it goes\n'
              '• pen up → it stops drawing and just moves\n'
              '• erase all → clears EVERY drawing from the stage\n\n'
              'Once the pen is down it stays down until you lift it. '
              'Putting "erase all" at the top of your program is a good '
              'habit: otherwise each run draws over the last one.',
          contentDe:
              'Drei Blöcke sagen alles:\n\n'
              '• schalte Stift ein → ab jetzt zeichnet die Figur überall\n'
              '• schalte Stift aus → sie bewegt sich nur noch\n'
              '• lösche alles → räumt ALLE Zeichnungen von der Bühne\n\n'
              'Einmal eingeschaltet bleibt der Stift ein, bis du ihn '
              'ausschaltest. «lösche alles» an den Anfang zu setzen ist '
              'eine gute Gewohnheit: sonst zeichnet jeder Durchlauf über '
              'den letzten.',
          contentEs:
              'Tres bloques lo dicen todo:\n\n'
              '• bajar lápiz → a partir de ahora el objeto dibuja\n'
              '• subir lápiz → deja de dibujar y solo se mueve\n'
              '• borrar todo → limpia TODOS los dibujos del escenario\n\n'
              'Una vez bajado, el lápiz sigue bajado hasta que lo subas. '
              'Poner «borrar todo» al principio es buena costumbre: si no, '
              'cada ejecución dibuja encima de la anterior.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'kalem indir',
              contentEn: 'pen down',
              contentDe: 'schalte Stift ein',
              contentEs: 'bajar lápiz',
              color: kalemRengi,
              label: 'Kalem',
              labelEn: 'Pen',
              labelDe: 'Stift',
              labelEs: 'Lápiz',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'sil',
              contentEn: 'erase all',
              contentDe: 'lösche alles',
              contentEs: 'borrar todo',
              color: kalemRengi,
              label: 'Kalem',
              labelEn: 'Pen',
              labelDe: 'Stift',
              labelEs: 'Lápiz',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 's8_1_q1',
          question:
              'Kalem KALDIRILMIŞKEN kuklayı 100 adım yürüttün. Ekranda ne '
              'olur?',
          questionEn:
              'You move the sprite 100 steps with the pen UP. What happens '
              'on the stage?',
          questionDe:
              'Du bewegst die Figur 100 Schritte, während der Stift AUS '
              'ist. Was passiert auf der Bühne?',
          questionEs:
              'Mueves el objeto 100 pasos con el lápiz SUBIDO. ¿Qué pasa '
              'en el escenario?',
          options: [
            ChoiceOption(
              text: 'Kukla yürür ama çizgi çıkmaz',
              textEn: 'The sprite moves but draws nothing',
              textDe: 'Die Figur bewegt sich, zeichnet aber nichts',
              textEs: 'El objeto se mueve pero no dibuja',
            ),
            ChoiceOption(
              text: 'Yine çizer, kalem hep çizer',
              textEn: 'It still draws, the pen always draws',
              textDe: 'Sie zeichnet trotzdem, der Stift zeichnet immer',
              textEs: 'Dibuja igual, el lápiz siempre dibuja',
            ),
            ChoiceOption(
              text: 'Ekran tamamen silinir',
              textEn: 'The stage is erased',
              textDe: 'Die Bühne wird gelöscht',
              textEs: 'El escenario se borra',
            ),
            ChoiceOption(
              text: 'Kukla hareket etmez',
              textEn: 'The sprite does not move',
              textDe: 'Die Figur bewegt sich nicht',
              textEs: 'El objeto no se mueve',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Kalem kaldırıldığında hareket devam eder, iz kalmaz. '
              'Çizimin ortasında bir yere "atlamak" için tam olarak bunu '
              'kullanırsın: kalem kaldır, git, kalem indir.',
          explanationEn:
              'With the pen up the sprite still moves, it just leaves no '
              'trail. That is exactly how you "jump" to another spot in '
              'the middle of a drawing: pen up, move, pen down.',
          explanationDe:
              'Mit ausgeschaltetem Stift bewegt sich die Figur weiter, '
              'hinterlässt aber keine Spur. Genau so springst du mitten in '
              'einer Zeichnung woanders hin: Stift aus, gehen, Stift ein.',
          explanationEs:
              'Con el lápiz subido el objeto se mueve igual, solo que sin '
              'rastro. Así es como «saltas» a otro sitio en medio de un '
              'dibujo: subir lápiz, mover, bajar lápiz.',
          xpReward: 15,
        ),

        BlockBuilderStep(
          id: 's8_1_build1',
          instruction: 'Ekranı temizleyip düz bir çizgi çiz.',
          instructionEn: 'Clear the stage and draw one straight line.',
          instructionDe: 'Räume die Bühne und zeichne eine gerade Linie.',
          instructionEs: 'Limpia el escenario y dibuja una línea recta.',
          goal: 'Bayrak → sil → kalem indir → 150 adım git',
          goalEn: 'Flag → erase all → pen down → move 150 steps',
          goalDe: 'Flagge → lösche alles → Stift ein → gehe 150 er Schritt',
          goalEs: 'Bandera → borrar todo → bajar lápiz → mover 150 pasos',
          availableBlocks: [
            _bayrak(),
            _sil(),
            _kalemIndir(),
            _git('150', id: 'move_150'),
            _kalemKaldir(),
          ],
          correctSequence: ['green_flag', 'pen_clear', 'pen_down', 'move_150'],
          xpReward: 30,
        ),

        ExplanationStep(
          id: 's8_1_summary',
          title: 'Kalemi Tanıdın!',
          titleEn: 'You Know the Pen!',
          titleDe: 'Du kennst den Stift!',
          titleEs: '¡Ya conoces el lápiz!',
          content: '✏️ Artık kuklan iz bırakıyor.\n\n'
              '✓ Kalem eklentisini ekledin\n'
              '✓ indir / kaldır / sil bloklarını öğrendin\n'
              '✓ İlk çizgini çizdin\n\n'
              'Sıradaki ders: aynı iki bloğu tekrarlayıp ŞEKİL çizmek.',
          contentEn: '✏️ Your sprite leaves a trail now.\n\n'
              '✓ You added the Pen extension\n'
              '✓ You learned pen down / pen up / erase all\n'
              '✓ You drew your first line\n\n'
              'Next lesson: repeating two blocks to draw a SHAPE.',
          contentDe: '✏️ Deine Figur hinterlässt jetzt eine Spur.\n\n'
              '✓ Du hast die Stift-Erweiterung hinzugefügt\n'
              '✓ Du kennst Stift ein / Stift aus / lösche alles\n'
              '✓ Du hast deine erste Linie gezeichnet\n\n'
              'Nächste Lektion: zwei Blöcke wiederholen und eine FORM '
              'zeichnen.',
          contentEs: '✏️ Tu objeto ya deja rastro.\n\n'
              '✓ Añadiste la extensión Lápiz\n'
              '✓ Aprendiste bajar / subir / borrar todo\n'
              '✓ Dibujaste tu primera línea\n\n'
              'Siguiente lección: repetir dos bloques para dibujar una '
              'FIGURA.',
          tipEmoji: '🏆',
          tip: 'Kalem rozetini kazandın!',
          tipEn: 'You earned the Pen badge!',
          tipDe: 'Du hast das Stift-Abzeichen verdient!',
          tipEs: '¡Has ganado la insignia del Lápiz!',
        ),
      ],
    ),
    // ---------------------------------------------------------- Ders 8.2
    InteractiveLesson(
      id: 'scratch_8_2',
      courseId: 'scratch',
      title: 'Döngüyle Şekil Çiz',
      subtitle: 'Kare, üçgen ve 360 kuralı',
      titleEn: 'Draw Shapes with a Loop',
      titleDe: 'Formen mit einer Schleife zeichnen',
      titleEs: 'Dibuja figuras con un bucle',
      subtitleEn: 'Square, triangle and the rule of 360',
      subtitleDe: 'Quadrat, Dreieck und die 360-Regel',
      subtitleEs: 'Cuadrado, triángulo y la regla del 360',
      order: 14,
      xpReward: 85,
      badge: 'shape_drawer',
      steps: [
        IntroStep(
          id: 's8_2_intro',
          mascotEmoji: '🔷',
          mascotMessage:
              'Bir kare çizmek için dört kez aynı şeyi yaparsın: bir '
              'kenar çiz, köşeden dön. Dört kez.\n\n'
              'Döngüyü zaten biliyorsun. Kalemi de biliyorsun. İkisini '
              'birleştirince ortaya geometri çıkıyor — ve "90 derece" '
              'artık bir sayı değil, gözünle gördüğün bir köşe.',
          mascotMessageEn:
              'To draw a square you do the same thing four times: draw a '
              'side, turn the corner. Four times.\n\n'
              'You already know loops. You know the pen. Put them '
              'together and you get geometry — and "90 degrees" stops '
              'being a number and becomes a corner you can see.',
          mascotMessageDe:
              'Für ein Quadrat machst du viermal dasselbe: eine Seite '
              'zeichnen, um die Ecke drehen. Viermal.\n\n'
              'Schleifen kennst du schon. Den Stift auch. Zusammen ergibt '
              'das Geometrie — und «90 Grad» ist keine Zahl mehr, sondern '
              'eine Ecke, die du siehst.',
          mascotMessageEs:
              'Para dibujar un cuadrado haces lo mismo cuatro veces: traza '
              'un lado, gira la esquina. Cuatro veces.\n\n'
              'Ya conoces los bucles. Y el lápiz. Júntalos y sale '
              'geometría: «90 grados» deja de ser un número y pasa a ser '
              'una esquina que ves.',
          highlights: [
            'Kare = 4 kere (git + dön)',
            '360 ÷ kenar sayısı',
            'Matematiği gözle görüyorsun',
          ],
          highlightsEn: [
            'Square = 4 × (move + turn)',
            '360 ÷ number of sides',
            'You can see the maths',
          ],
          highlightsDe: [
            'Quadrat = 4 × (gehen + drehen)',
            '360 ÷ Anzahl der Seiten',
            'Du siehst die Mathematik',
          ],
          highlightsEs: [
            'Cuadrado = 4 × (mover + girar)',
            '360 ÷ número de lados',
            'Ves las matemáticas',
          ],
        ),

        ExplanationStep(
          id: 's8_2_exp1',
          title: 'Kare: Dört Kenar, Dört Köşe',
          titleEn: 'A Square: Four Sides, Four Corners',
          titleDe: 'Ein Quadrat: vier Seiten, vier Ecken',
          titleEs: 'Un cuadrado: cuatro lados, cuatro esquinas',
          content:
              'Kareyi elle çizseydin şunu yapardın:\n\n'
              '   100 adım git → 90 derece dön\n'
              '   100 adım git → 90 derece dön\n'
              '   100 adım git → 90 derece dön\n'
              '   100 adım git → 90 derece dön\n\n'
              'Sekiz blok. Oysa aynı ikili dört kez tekrarlanıyor. '
              'Döngüye koyunca üç blok kalıyor:\n\n'
              '   4 kere tekrarla\n'
              '     100 adım git\n'
              '     ↻ 90 derece dön',
          contentEn:
              'If you drew a square by hand you would do this:\n\n'
              '   move 100 → turn 90\n'
              '   move 100 → turn 90\n'
              '   move 100 → turn 90\n'
              '   move 100 → turn 90\n\n'
              'Eight blocks. But the same pair repeats four times. Put it '
              'in a loop and three blocks are enough:\n\n'
              '   repeat 4\n'
              '     move 100 steps\n'
              '     turn ↻ 90 degrees',
          contentDe:
              'Von Hand würdest du das machen:\n\n'
              '   gehe 100 → drehe 90\n'
              '   gehe 100 → drehe 90\n'
              '   gehe 100 → drehe 90\n'
              '   gehe 100 → drehe 90\n\n'
              'Acht Blöcke. Dabei wiederholt sich dasselbe Paar viermal. '
              'In einer Schleife reichen drei:\n\n'
              '   wiederhole 4 mal\n'
              '     gehe 100 er Schritt\n'
              '     drehe dich ↻ um 90 Grad',
          contentEs:
              'A mano harías esto:\n\n'
              '   mover 100 → girar 90\n'
              '   mover 100 → girar 90\n'
              '   mover 100 → girar 90\n'
              '   mover 100 → girar 90\n\n'
              'Ocho bloques. Pero la misma pareja se repite cuatro veces. '
              'En un bucle bastan tres:\n\n'
              '   repetir 4 veces\n'
              '     mover 100 pasos\n'
              '     girar ↻ 90 grados',
          tipEmoji: '📐',
          tip: 'Dönüş açısı karenin İÇ açısı değil, kuklanın köşede '
              'yaptığı dönüştür. Dışarıdan bakınca 90 derece.',
          tipEn: 'The turn is not the inside angle of the square; it is '
              'how far the sprite swings at the corner. From outside, 90 '
              'degrees.',
          tipDe: 'Der Drehwinkel ist nicht der Innenwinkel des Quadrats, '
              'sondern wie weit sich die Figur an der Ecke dreht. Von '
              'außen 90 Grad.',
          tipEs: 'El giro no es el ángulo interior del cuadrado, sino '
              'cuánto rota el objeto en la esquina. Desde fuera, 90 '
              'grados.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '4 kere tekrarla',
              contentEn: 'repeat 4',
              contentDe: 'wiederhole 4 mal',
              contentEs: 'repetir 4 veces',
              color: kontrolRengi,
              label: 'Kontrol · C bloğu',
              labelEn: 'Control · C block',
              labelDe: 'Steuerung · C-Block',
              labelEs: 'Control · bloque C',
            ),
          ],
        ),

        BlockBuilderStep(
          id: 's8_2_build1',
          instruction: 'Bir kare çiz.',
          instructionEn: 'Draw a square.',
          instructionDe: 'Zeichne ein Quadrat.',
          instructionEs: 'Dibuja un cuadrado.',
          goal: 'Bayrak → sil → kalem indir → 4 kere { 100 adım git, 90 '
              'derece dön }',
          goalEn: 'Flag → erase all → pen down → repeat 4 { move 100, turn '
              '90 }',
          goalDe: 'Flagge → lösche alles → Stift ein → wiederhole 4 mal '
              '{ gehe 100, drehe 90 }',
          goalEs: 'Bandera → borrar todo → bajar lápiz → repetir 4 { mover '
              '100, girar 90 }',
          availableBlocks: [
            _bayrak(),
            _sil(),
            _kalemIndir(),
            _tekrarla('4', id: 'repeat_4'),
            _git('100', id: 'move_100'),
            _don('90', id: 'turn_90'),
            _don('120', id: 'turn_120'),
          ],
          correctSequence: [
            'green_flag',
            'pen_clear',
            'pen_down',
            'repeat_4',
            'move_100',
            'turn_90',
          ],
          xpReward: 35,
        ),

        ExplanationStep(
          id: 's8_2_exp2',
          title: '360 Kuralı',
          titleEn: 'The Rule of 360',
          titleDe: 'Die 360-Regel',
          titleEs: 'La regla del 360',
          content:
              'Kukla şeklin etrafını dolaşıp başladığı yöne dönüyor. Yani '
              'bütün dönüşlerin toplamı hep 360 derece.\n\n'
              'Buradan tek bir kural çıkıyor:\n\n'
              '   dönüş açısı = 360 ÷ kenar sayısı\n\n'
              '• Üçgen → 360 ÷ 3 = 120\n'
              '• Kare → 360 ÷ 4 = 90\n'
              '• Beşgen → 360 ÷ 5 = 72\n'
              '• Altıgen → 360 ÷ 6 = 60\n\n'
              'Kenar sayısını büyüttükçe şekil daireye benzemeye başlıyor.',
          contentEn:
              'The sprite goes all the way around the shape and ends up '
              'facing its starting direction. So all the turns add up to '
              '360 degrees.\n\n'
              'That gives you one rule:\n\n'
              '   turn = 360 ÷ number of sides\n\n'
              '• Triangle → 360 ÷ 3 = 120\n'
              '• Square → 360 ÷ 4 = 90\n'
              '• Pentagon → 360 ÷ 5 = 72\n'
              '• Hexagon → 360 ÷ 6 = 60\n\n'
              'The more sides you add, the more it looks like a circle.',
          contentDe:
              'Die Figur läuft einmal um die Form herum und schaut am Ende '
              'wieder in die Startrichtung. Alle Drehungen ergeben also '
              'zusammen 360 Grad.\n\n'
              'Daraus folgt eine Regel:\n\n'
              '   Drehwinkel = 360 ÷ Anzahl der Seiten\n\n'
              '• Dreieck → 360 ÷ 3 = 120\n'
              '• Quadrat → 360 ÷ 4 = 90\n'
              '• Fünfeck → 360 ÷ 5 = 72\n'
              '• Sechseck → 360 ÷ 6 = 60\n\n'
              'Je mehr Seiten, desto runder wird es.',
          contentEs:
              'El objeto rodea la figura y acaba mirando hacia donde '
              'empezó. Así que todos los giros suman 360 grados.\n\n'
              'De ahí sale una regla:\n\n'
              '   giro = 360 ÷ número de lados\n\n'
              '• Triángulo → 360 ÷ 3 = 120\n'
              '• Cuadrado → 360 ÷ 4 = 90\n'
              '• Pentágono → 360 ÷ 5 = 72\n'
              '• Hexágono → 360 ÷ 6 = 60\n\n'
              'Cuantos más lados, más se parece a un círculo.',
        ),

        MatchingStep(
          id: 's8_2_match1',
          instruction: 'Şekli, dönüş açısıyla eşleştir.',
          instructionEn: 'Match each shape with its turn.',
          instructionDe: 'Ordne jeder Form ihren Drehwinkel zu.',
          instructionEs: 'Une cada figura con su giro.',
          pairs: [
            MatchPair(
              id: 'p3',
              left: 'Üçgen',
              right: '120 derece',
              leftEn: 'Triangle',
              rightEn: '120 degrees',
              leftDe: 'Dreieck',
              rightDe: '120 Grad',
              leftEs: 'Triángulo',
              rightEs: '120 grados',
            ),
            MatchPair(
              id: 'p4',
              left: 'Kare',
              right: '90 derece',
              leftEn: 'Square',
              rightEn: '90 degrees',
              leftDe: 'Quadrat',
              rightDe: '90 Grad',
              leftEs: 'Cuadrado',
              rightEs: '90 grados',
            ),
            MatchPair(
              id: 'p5',
              left: 'Beşgen',
              right: '72 derece',
              leftEn: 'Pentagon',
              rightEn: '72 degrees',
              leftDe: 'Fünfeck',
              rightDe: '72 Grad',
              leftEs: 'Pentágono',
              rightEs: '72 grados',
            ),
            MatchPair(
              id: 'p6',
              left: 'Altıgen',
              right: '60 derece',
              leftEn: 'Hexagon',
              rightEn: '60 degrees',
              leftDe: 'Sechseck',
              rightDe: '60 Grad',
              leftEs: 'Hexágono',
              rightEs: '60 grados',
            ),
          ],
          xpReward: 20,
        ),

        MultipleChoiceStep(
          id: 's8_2_q1',
          question: '36 dereceyi 10 kere tekrarlarsan ne çizilir?',
          questionEn: 'What do you get if you repeat a 36 degree turn ten '
              'times?',
          questionDe: 'Was entsteht, wenn du eine 36-Grad-Drehung zehnmal '
              'wiederholst?',
          questionEs: '¿Qué sale si repites un giro de 36 grados diez '
              'veces?',
          options: [
            ChoiceOption(
              text: 'On kenarlı bir şekil — neredeyse daire',
              textEn: 'A ten-sided shape — almost a circle',
              textDe: 'Eine Form mit zehn Seiten — fast ein Kreis',
              textEs: 'Una figura de diez lados: casi un círculo',
            ),
            ChoiceOption(
              text: 'Bir üçgen',
              textEn: 'A triangle',
              textDe: 'Ein Dreieck',
              textEs: 'Un triángulo',
            ),
            ChoiceOption(
              text: 'Düz bir çizgi',
              textEn: 'A straight line',
              textDe: 'Eine gerade Linie',
              textEs: 'Una línea recta',
            ),
            ChoiceOption(
              text: 'Hiçbir şey, 36 bölünmüyor',
              textEn: 'Nothing, 36 does not divide',
              textDe: 'Nichts, 36 geht nicht auf',
              textEs: 'Nada, 36 no divide',
            ),
          ],
          correctIndex: 0,
          explanation:
              '36 × 10 = 360, yani tam tur. On kenar demek; kenarlar kısa '
              'olduğunda göz bunu daire olarak görüyor. Daire çizmenin '
              'yolu budur: çok kenarlı bir şekil.',
          explanationEn:
              '36 × 10 = 360, a full turn — so ten sides. When the sides '
              'are short your eye reads it as a circle. That is how you '
              'draw a circle: a shape with many sides.',
          explanationDe:
              '36 × 10 = 360, eine ganze Runde — also zehn Seiten. Sind '
              'die Seiten kurz, sieht das Auge einen Kreis. Genau so '
              'zeichnet man einen Kreis: eine Form mit vielen Seiten.',
          explanationEs:
              '36 × 10 = 360, una vuelta completa: diez lados. Si los '
              'lados son cortos, el ojo ve un círculo. Así se dibuja un '
              'círculo: una figura con muchos lados.',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 's8_2_summary',
          title: 'Şekil Çizmeyi Öğrendin!',
          titleEn: 'You Can Draw Shapes!',
          titleDe: 'Du kannst Formen zeichnen!',
          titleEs: '¡Ya sabes dibujar figuras!',
          content: '🔷 Döngü ile kalem bir araya geldi.\n\n'
              '✓ Kare çizdin: 4 kere (git + dön)\n'
              '✓ 360 ÷ kenar sayısı kuralını öğrendin\n'
              '✓ Çok kenarlı şeklin daireye benzediğini gördün\n\n'
              'Denemelik: kenar sayısını 12 yap, açıyı 30 yap. Ne '
              'çıkıyor?',
          contentEn: '🔷 The loop and the pen came together.\n\n'
              '✓ You drew a square: 4 × (move + turn)\n'
              '✓ You learned turn = 360 ÷ sides\n'
              '✓ You saw many sides look like a circle\n\n'
              'Try it: 12 sides, 30 degrees. What do you get?',
          contentDe: '🔷 Schleife und Stift kamen zusammen.\n\n'
              '✓ Du hast ein Quadrat gezeichnet: 4 × (gehen + drehen)\n'
              '✓ Du kennst Drehwinkel = 360 ÷ Seiten\n'
              '✓ Du hast gesehen: viele Seiten sehen aus wie ein Kreis\n\n'
              'Probier es: 12 Seiten, 30 Grad. Was kommt heraus?',
          contentEs: '🔷 El bucle y el lápiz se juntaron.\n\n'
              '✓ Dibujaste un cuadrado: 4 × (mover + girar)\n'
              '✓ Aprendiste giro = 360 ÷ lados\n'
              '✓ Viste que muchos lados parecen un círculo\n\n'
              'Pruébalo: 12 lados, 30 grados. ¿Qué sale?',
          tipEmoji: '🏆',
          tip: 'Şekil Ustası rozetini kazandın!',
          tipEn: 'You earned the Shape Maker badge!',
          tipDe: 'Du hast das Abzeichen «Formenmeister» verdient!',
          tipEs: '¡Has ganado la insignia Maestro de Figuras!',
        ),
      ],
    ),
  ];
}
