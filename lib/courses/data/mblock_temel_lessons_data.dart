import '../models/interactive_lesson_model.dart';
import '../yurutme/mblock_cozum.dart';
import 'mblock_palette.dart';

/// mBlock kursunun SIFIR modülü — hiç kart takmadan bloklarla başlangıç.
///
/// NEDEN BU MODÜL VAR
/// ------------------
/// Kurs eskiden ilk dersinde "cihaz mı kukla mı seçili", "yükleme modu mu
/// canlı mod mu" diye soruyordu. İkisi de doğru bilgi ama çocuk henüz tek
/// bir blok sürüklememişken ikisi de havada kalıyor: ekranda hiçbir şey
/// olmuyor, karşılığı görünmüyor, ders ayar menüsü anlatımına dönüyor.
///
/// mBlock'un asıl kolaylığı şu: Scratch 3.0 üzerine kurulu, yani ilk gün
/// kukla sekmesinde tek bir kablo olmadan blok kurup SONUCU ANINDA
/// görebiliyorsun. Bu modül tam olarak orada geçiyor — palet, blok
/// şekilleri, sıra, tekrar ve bekleme. Kart, kablo, pin ve mod bilgisi
/// buradan sonra geliyor; o zaman da "bildiğim bloklar şimdi gerçek bir
/// karta gidiyor" diye anlam kazanıyor.
///
/// KURAL
/// -----
/// Bu modülde donanım kelimesi geçmez: pin yok, LED yok, direnç yok.
/// Tek istisna, son dersin kapanışındaki bir cümlelik köprü.
class MBlockTemelLessonsData {
  MBlockTemelLessonsData._();

  static final List<InteractiveLesson> module0 = [
    // ---------------------------------------------------------- Ders 0.1
    InteractiveLesson(
      id: 'mblock_0_1',
      courseId: 'mblock',
      title: 'Bloklarla Tanış',
      subtitle: 'Kablo yok, kart yok — sadece bloklar',
      titleEn: 'Meet the Blocks',
      titleDe: 'Lerne die Blöcke kennen',
      titleEs: 'Conoce los bloques',
      subtitleEn: 'No cables, no board — just blocks',
      subtitleDe: 'Keine Kabel, keine Platine – nur Blöcke',
      subtitleEs: 'Sin cables, sin placa: solo bloques',
      order: 1,
      xpReward: 40,
      badge: 'mblock_starter',
      steps: [
        IntroStep(
          id: 'm0_1_intro',
          mascotEmoji: '🧩',
          mascotMessage:
              'mBlock\'u açtın. Hiçbir şey takmadan, hiçbir ayar '
              'değiştirmeden bir şey kurabilirsin: ekranda bir karakter '
              'var ve blokları üst üste dizince yürümeye başlıyor.\n\n'
              'Bu derste kart yok, kablo yok. Sadece bloklar ve anında '
              'gördüğün sonuç.',
          mascotMessageEn:
              'You have opened mBlock. Without plugging anything in or '
              'changing any setting, you can already build something: '
              'there is a character on the screen, and when you stack '
              'blocks it starts walking.\n\n'
              'No board in this lesson, no cables. Just blocks and a '
              'result you see right away.',
          mascotMessageDe:
              'Du hast mBlock geöffnet. Ohne etwas anzustecken und ohne '
              'eine Einstellung zu ändern kannst du schon etwas bauen: Auf '
              'dem Bildschirm ist eine Figur, und wenn du Blöcke '
              'aufeinandersteckst, läuft sie los.\n\n'
              'Keine Platine in dieser Lektion, keine Kabel. Nur Blöcke '
              'und ein Ergebnis, das du sofort siehst.',
          mascotMessageEs:
              'Has abierto mBlock. Sin conectar nada y sin cambiar ningún '
              'ajuste ya puedes construir algo: hay un personaje en la '
              'pantalla y, al apilar bloques, empieza a caminar.\n\n'
              'En esta lección no hay placa ni cables. Solo bloques y un '
              'resultado que ves al instante.',
          highlights: [
            'Kurulum yok',
            'Sonuç anında ekranda',
            'Scratch\'i biliyorsan tanıdık gelecek',
          ],
          highlightsEn: [
            'Nothing to set up',
            'The result shows up instantly',
            'Familiar if you know Scratch',
          ],
          highlightsDe: [
            'Nichts einzurichten',
            'Das Ergebnis erscheint sofort',
            'Bekannt, wenn du Scratch kennst',
          ],
          highlightsEs: [
            'Nada que configurar',
            'El resultado aparece al instante',
            'Te resultará familiar si conoces Scratch',
          ],
        ),

        ExplanationStep(
          id: 'm0_1_exp1',
          title: 'Ekranda Dört Bölge',
          titleEn: 'Four Areas on the Screen',
          titleDe: 'Vier Bereiche auf dem Bildschirm',
          titleEs: 'Cuatro zonas en la pantalla',
          content:
              'mBlock ilk açıldığında ekran dörde bölünmüştür:\n\n'
              '1) PALET — solda, renkli kategoriler ve blokların listesi.\n'
              '2) KOD ALANI — ortada, blokları buraya sürüklüyorsun.\n'
              '3) SAHNE — sağ üstte, karakterin göründüğü yer.\n'
              '4) KUKLA LİSTESİ — sahnenin altında, karakterler burada.\n\n'
              'Kurduğun blok yığını kod alanında durur; çalıştırınca '
              'sonucu sahnede görürsün. Başka hiçbir yere bakmana gerek '
              'yok.',
          contentEn:
              'When mBlock first opens, the screen has four areas:\n\n'
              '1) PALETTE — on the left, the coloured categories and the '
              'list of blocks.\n'
              '2) CODE AREA — in the middle, where you drag blocks.\n'
              '3) STAGE — top right, where the character appears.\n'
              '4) SPRITE LIST — under the stage, where the characters are.\n\n'
              'Your stack of blocks sits in the code area; when you run it '
              'you see the result on the stage. You do not need to look '
              'anywhere else.',
          contentDe:
              'Wenn mBlock zum ersten Mal öffnet, hat der Bildschirm vier '
              'Bereiche:\n\n'
              '1) PALETTE – links, die farbigen Kategorien und die Liste '
              'der Blöcke.\n'
              '2) CODEBEREICH – in der Mitte, dort ziehst du Blöcke hin.\n'
              '3) BÜHNE – oben rechts, dort erscheint die Figur.\n'
              '4) FIGURENLISTE – unter der Bühne, dort sind die Figuren.\n\n'
              'Dein Blockstapel liegt im Codebereich; wenn du ihn startest, '
              'siehst du das Ergebnis auf der Bühne. Woanders musst du '
              'nicht hinschauen.',
          contentEs:
              'Cuando abres mBlock por primera vez, la pantalla tiene '
              'cuatro zonas:\n\n'
              '1) PALETA — a la izquierda, las categorías de colores y la '
              'lista de bloques.\n'
              '2) ÁREA DE CÓDIGO — en el centro, donde arrastras bloques.\n'
              '3) ESCENARIO — arriba a la derecha, donde aparece el '
              'personaje.\n'
              '4) LISTA DE OBJETOS — bajo el escenario, ahí están los '
              'personajes.\n\n'
              'Tu pila de bloques está en el área de código; al ejecutarla '
              'ves el resultado en el escenario. No necesitas mirar a '
              'ningún otro sitio.',
          tipEmoji: '👀',
          tip: 'Üstteki "Cihazlar" sekmesine şimdilik dokunma. Orası '
              'kartla çalışmak için; ona ilerideki modülde geleceğiz.',
          tipEn: 'Leave the "Devices" tab alone for now. That is for '
              'working with a board — we get there in a later module.',
          tipDe: 'Lass den Reiter «Geräte» erst einmal in Ruhe. Der ist für '
              'die Arbeit mit einer Platine – dazu kommen wir in einem '
              'späteren Modul.',
          tipEs: 'Por ahora no toques la pestaña «Dispositivos». Es para '
              'trabajar con una placa; llegaremos a eso en un módulo '
              'posterior.',
        ),

        ExplanationStep(
          id: 'm0_1_exp2',
          title: 'Her Blok Bir Yapboz Parçası',
          titleEn: 'Every Block Is a Puzzle Piece',
          titleDe: 'Jeder Block ist ein Puzzleteil',
          titleEs: 'Cada bloque es una pieza de puzle',
          content:
              'Blokların şekli, o bloğun ne işe yaradığını söyler. '
              'Beş şekil var:\n\n'
              '• ŞAPKA — üstü yuvarlak, altına blok takılır, üstüne '
              'takılmaz. Yığın buradan başlar.\n'
              '• DÜZ — üstü ve altı tırtıklı. Bir iş yapar, sonra sıradaki '
              'bloğa geçer.\n'
              '• C — içine başka blok alır. Tekrar ve koşul blokları böyle.\n'
              '• OVAL — bir DEĞER söyler (sayı, yazı). Tek başına '
              'çalışmaz, bir kutunun içine girer.\n'
              '• ALTIGEN — evet/hayır söyler. Koşul kutularına girer.\n\n'
              'Bir bloğu yanlış yere sürüklersen yerine oturmaz. Şekil '
              'zaten sana engel olur.',
          contentEn:
              'A block\'s shape tells you what it is for. There are five '
              'shapes:\n\n'
              '• HAT — rounded on top, blocks attach below but not above. '
              'A stack starts here.\n'
              '• STACK — notched top and bottom. Does one thing, then '
              'passes to the next block.\n'
              '• C — holds other blocks inside. Repeat and condition '
              'blocks look like this.\n'
              '• OVAL — reports a VALUE (a number, a word). It does not '
              'run on its own; it goes inside a slot.\n'
              '• HEXAGON — reports yes/no. It goes into condition slots.\n\n'
              'Drag a block to the wrong place and it will not click in. '
              'The shape stops you.',
          contentDe:
              'Die Form eines Blocks sagt dir, wofür er da ist. Es gibt '
              'fünf Formen:\n\n'
              '• HUT – oben rund, unten kommen Blöcke dran, oben nicht. '
              'Ein Stapel beginnt hier.\n'
              '• STAPEL – oben und unten gezackt. Macht eine Sache und gibt '
              'dann an den nächsten Block weiter.\n'
              '• C – nimmt andere Blöcke in sich auf. So sehen Wiederhol- '
              'und Bedingungsblöcke aus.\n'
              '• OVAL – meldet einen WERT (eine Zahl, ein Wort). Läuft '
              'nicht allein, sondern kommt in einen Schlitz.\n'
              '• SECHSECK – meldet ja/nein. Kommt in Bedingungsschlitze.\n\n'
              'Ziehst du einen Block an die falsche Stelle, rastet er nicht '
              'ein. Die Form hält dich auf.',
          contentEs:
              'La forma de un bloque te dice para qué sirve. Hay cinco '
              'formas:\n\n'
              '• SOMBRERO — redondeado arriba, los bloques se enganchan '
              'debajo, no encima. Una pila empieza aquí.\n'
              '• PILA — con muescas arriba y abajo. Hace una cosa y pasa '
              'al bloque siguiente.\n'
              '• C — contiene otros bloques dentro. Así son los bloques de '
              'repetición y de condición.\n'
              '• ÓVALO — informa de un VALOR (un número, una palabra). No '
              'funciona solo; va dentro de una ranura.\n'
              '• HEXÁGONO — informa sí/no. Va en las ranuras de condición.\n\n'
              'Si arrastras un bloque al lugar equivocado, no encaja. La '
              'forma te detiene.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'yeşil bayrak tıklandığında',
              contentEn: 'when green flag clicked',
              contentDe: 'wenn die grüne Flagge angeklickt',
              contentEs: 'al hacer clic en la bandera verde',
              color: MBlockPalette.events,
              label: 'Olaylar · şapka',
              labelEn: 'Events · hat',
              labelDe: 'Ereignisse · Hut',
              labelEs: 'Eventos · sombrero',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: '10 adım git',
              contentEn: 'move 10 steps',
              contentDe: 'gehe 10 er Schritt',
              contentEs: 'mover 10 pasos',
              color: MBlockKuklaPalette.motion,
              label: 'Hareket · düz',
              labelEn: 'Motion · stack',
              labelDe: 'Bewegung · Stapel',
              labelEs: 'Movimiento · pila',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: '10 kere tekrarla',
              contentEn: 'repeat 10',
              contentDe: 'wiederhole 10 mal',
              contentEs: 'repetir 10 veces',
              color: MBlockPalette.control,
              label: 'Kontrol · C bloğu',
              labelEn: 'Control · C block',
              labelDe: 'Steuerung · C-Block',
              labelEs: 'Control · bloque C',
            ),
          ],
          tipEmoji: '🧠',
          tip: 'Şekli tanıyan çocuk bloğu aramadan bulur: "değer lazım" '
              'dediğinde gözü doğrudan oval bloklara gider.',
          tipEn: 'Once you know the shapes you stop searching: when you '
              'need a value, your eye goes straight to the oval blocks.',
          tipDe: 'Wer die Formen kennt, sucht nicht mehr: Wenn du einen '
              'Wert brauchst, geht dein Blick direkt zu den ovalen Blöcken.',
          tipEs: 'Cuando conoces las formas dejas de buscar: si necesitas '
              'un valor, tu vista va directa a los bloques ovalados.',
        ),

        MultipleChoiceStep(
          id: 'm0_1_q1',
          question: 'Bir blok yığınının en üstüne hangi şekil gelir?',
          questionEn: 'Which shape goes at the very top of a stack?',
          questionDe: 'Welche Form kommt ganz oben auf einen Stapel?',
          questionEs: '¿Qué forma va en la parte de arriba de una pila?',
          options: [
            ChoiceOption(
              text: 'Şapka blok',
              emoji: '🎩',
              textEn: 'A hat block',
              textDe: 'Ein Hutblock',
              textEs: 'Un bloque de sombrero',
            ),
            ChoiceOption(
              text: 'Oval blok',
              emoji: '🥚',
              textEn: 'An oval block',
              textDe: 'Ein ovaler Block',
              textEs: 'Un bloque ovalado',
            ),
            ChoiceOption(
              text: 'Altıgen blok',
              emoji: '⬡',
              textEn: 'A hexagon block',
              textDe: 'Ein Sechseckblock',
              textEs: 'Un bloque hexagonal',
            ),
            ChoiceOption(
              text: 'C bloğu',
              emoji: '🔁',
              textEn: 'A C block',
              textDe: 'Ein C-Block',
              textEs: 'Un bloque C',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Şapka bloğun üstü yuvarlak olduğu için üstüne başka blok '
              'takılamaz. Bu yüzden yığın hep bir şapka bloğuyla başlar.',
          explanationEn:
              'A hat block is rounded on top, so nothing can attach above '
              'it. That is why a stack always starts with one.',
          explanationDe:
              'Ein Hutblock ist oben rund, darüber kann also nichts '
              'andocken. Deshalb beginnt ein Stapel immer mit einem.',
          explanationEs:
              'Un bloque de sombrero es redondeado arriba, así que nada '
              'puede engancharse encima. Por eso una pila siempre empieza '
              'con uno.',
          xpReward: 15,
        ),

        MatchingStep(
          id: 'm0_1_match1',
          instruction: 'Şekli, yaptığı işle eşleştir.',
          instructionEn: 'Match each shape with what it does.',
          instructionDe: 'Ordne jede Form ihrer Aufgabe zu.',
          instructionEs: 'Une cada forma con lo que hace.',
          pairs: [
            MatchPair(
              id: 'p1',
              left: 'Şapka',
              right: 'Yığını başlatır',
              leftEn: 'Hat',
              rightEn: 'Starts the stack',
              leftDe: 'Hut',
              rightDe: 'Startet den Stapel',
              leftEs: 'Sombrero',
              rightEs: 'Inicia la pila',
            ),
            MatchPair(
              id: 'p2',
              left: 'Düz',
              right: 'Bir iş yapar, devam eder',
              leftEn: 'Stack',
              rightEn: 'Does one thing, then continues',
              leftDe: 'Stapel',
              rightDe: 'Macht eine Sache und fährt fort',
              leftEs: 'Pila',
              rightEs: 'Hace una cosa y sigue',
            ),
            MatchPair(
              id: 'p3',
              left: 'C',
              right: 'İçine blok alır',
              leftEn: 'C',
              rightEn: 'Holds blocks inside',
              leftDe: 'C',
              rightDe: 'Nimmt Blöcke in sich auf',
              leftEs: 'C',
              rightEs: 'Contiene bloques dentro',
            ),
            MatchPair(
              id: 'p4',
              left: 'Oval',
              right: 'Bir değer söyler',
              leftEn: 'Oval',
              rightEn: 'Reports a value',
              leftDe: 'Oval',
              rightDe: 'Meldet einen Wert',
              leftEs: 'Óvalo',
              rightEs: 'Informa de un valor',
            ),
            MatchPair(
              id: 'p5',
              left: 'Altıgen',
              right: 'Evet mi hayır mı söyler',
              leftEn: 'Hexagon',
              rightEn: 'Reports yes or no',
              leftDe: 'Sechseck',
              rightDe: 'Meldet ja oder nein',
              leftEs: 'Hexágono',
              rightEs: 'Informa de sí o no',
            ),
          ],
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'm0_1_summary',
          title: 'Ekranı Tanıdın!',
          titleEn: 'You Know the Screen!',
          titleDe: 'Du kennst den Bildschirm!',
          titleEs: '¡Ya conoces la pantalla!',
          content: '🧩 İlk ders bitti, hiçbir şey takmadın.\n\n'
              '✓ Palet, kod alanı, sahne, kukla listesi\n'
              '✓ Beş blok şekli ve ne anlama geldikleri\n'
              '✓ Yanlış yere sürüklenen blok oturmaz\n\n'
              'Sıradaki ders: ilk blok yığınını kurup çalıştırmak.',
          contentEn: '🧩 First lesson done, and you plugged in nothing.\n\n'
              '✓ Palette, code area, stage, sprite list\n'
              '✓ The five block shapes and what they mean\n'
              '✓ A block in the wrong place will not click in\n\n'
              'Next lesson: building and running your first stack.',
          contentDe: '🧩 Erste Lektion fertig, und du hast nichts '
              'angesteckt.\n\n'
              '✓ Palette, Codebereich, Bühne, Figurenliste\n'
              '✓ Die fünf Blockformen und was sie bedeuten\n'
              '✓ Ein Block an der falschen Stelle rastet nicht ein\n\n'
              'Nächste Lektion: den ersten Stapel bauen und starten.',
          contentEs: '🧩 Primera lección hecha y no has conectado nada.\n\n'
              '✓ Paleta, área de código, escenario, lista de objetos\n'
              '✓ Las cinco formas de bloque y qué significan\n'
              '✓ Un bloque en el lugar equivocado no encaja\n\n'
              'Siguiente lección: construir y ejecutar tu primera pila.',
          tipEmoji: '🏆',
          tip: 'mBlock\'a Merhaba rozetini kazandın!',
          tipEn: 'You earned the Hello mBlock badge!',
          tipDe: 'Du hast das Abzeichen «Hallo mBlock» verdient!',
          tipEs: '¡Has ganado la insignia Hola mBlock!',
        ),
      ],
    ),

    // ---------------------------------------------------------- Ders 0.2
    InteractiveLesson(
      id: 'mblock_0_2',
      courseId: 'mblock',
      title: 'İlk Yığın: Çalıştır ve Gör',
      subtitle: 'Yeşil bayrak ve yukarıdan aşağıya sıra',
      titleEn: 'Your First Stack: Run and Watch',
      titleDe: 'Dein erster Stapel: starten und zusehen',
      titleEs: 'Tu primera pila: ejecutar y mirar',
      subtitleEn: 'The green flag and top-to-bottom order',
      subtitleDe: 'Die grüne Flagge und die Reihenfolge von oben nach unten',
      subtitleEs: 'La bandera verde y el orden de arriba abajo',
      order: 2,
      xpReward: 45,
      badge: 'mblock_first_stack',
      steps: [
        IntroStep(
          id: 'm0_2_intro',
          mascotEmoji: '🟢',
          mascotMessage:
              'Şimdi üç bloktan bir yığın kuracağız ve yeşil bayrağa '
              'basacağız. Karakter konuşacak, sonra yürüyecek.\n\n'
              'Buradaki tek kural şu: bloklar yukarıdan aşağıya, sırayla '
              'çalışır. Bu kuralı bugün öğrenirsen, kursun geri kalanı '
              'kolay geçer.',
          mascotMessageEn:
              'Now we build a stack of three blocks and press the green '
              'flag. The character will speak, then walk.\n\n'
              'There is one rule here: blocks run from top to bottom, in '
              'order. Learn that today and the rest of the course is easy.',
          mascotMessageDe:
              'Jetzt bauen wir einen Stapel aus drei Blöcken und drücken '
              'die grüne Flagge. Die Figur spricht und läuft dann.\n\n'
              'Es gibt hier eine Regel: Blöcke laufen von oben nach unten, '
              'der Reihe nach. Lerne das heute, und der Rest des Kurses '
              'fällt leicht.',
          mascotMessageEs:
              'Ahora construimos una pila de tres bloques y pulsamos la '
              'bandera verde. El personaje hablará y luego caminará.\n\n'
              'Aquí hay una sola regla: los bloques se ejecutan de arriba '
              'abajo, en orden. Apréndela hoy y el resto del curso será '
              'fácil.',
          highlights: [
            'Üç blok yeter',
            'Yeşil bayrak başlatır',
            'Sıra yukarıdan aşağıya',
          ],
          highlightsEn: [
            'Three blocks are enough',
            'The green flag starts it',
            'Order runs top to bottom',
          ],
          highlightsDe: [
            'Drei Blöcke genügen',
            'Die grüne Flagge startet es',
            'Die Reihenfolge läuft von oben nach unten',
          ],
          highlightsEs: [
            'Con tres bloques basta',
            'La bandera verde lo inicia',
            'El orden va de arriba abajo',
          ],
        ),

        ExplanationStep(
          id: 'm0_2_exp1',
          title: 'Yeşil Bayrak: Başlat Düğmesi',
          titleEn: 'The Green Flag: the Start Button',
          titleDe: 'Die grüne Flagge: der Startknopf',
          titleEs: 'La bandera verde: el botón de inicio',
          content:
              'Olaylar kategorisi (sarı) sadece bir soruya cevap verir: '
              '"bu yığın NE ZAMAN çalışsın?"\n\n'
              'İlk ve en çok kullanılan cevabı şudur:\n\n'
              '   yeşil bayrak tıklandığında\n\n'
              'Bu bloğu yığının en üstüne koyarsın. Sahnenin üstündeki '
              'yeşil bayrağa bastığın anda altındaki bloklar sırayla '
              'çalışmaya başlar.\n\n'
              'Bu blok olmadan da bir yığına tıklayıp çalıştırabilirsin, '
              'ama o zaman programın bir başlangıcı olmaz — her seferinde '
              'blokların üstüne tıklamak zorunda kalırsın.',
          contentEn:
              'The Events category (yellow) answers one question only: '
              '"WHEN should this stack run?"\n\n'
              'Its first and most used answer is:\n\n'
              '   when green flag clicked\n\n'
              'You put this block at the top of the stack. The moment you '
              'press the green flag above the stage, the blocks under it '
              'run in order.\n\n'
              'You can also click a stack to run it without this block, '
              'but then your program has no starting point — you have to '
              'click the blocks every time.',
          contentDe:
              'Die Kategorie Ereignisse (gelb) beantwortet nur eine Frage: '
              '«WANN soll dieser Stapel laufen?»\n\n'
              'Ihre erste und häufigste Antwort ist:\n\n'
              '   wenn die grüne Flagge angeklickt\n\n'
              'Diesen Block setzt du oben auf den Stapel. Sobald du auf die '
              'grüne Flagge über der Bühne drückst, laufen die Blöcke '
              'darunter der Reihe nach.\n\n'
              'Du kannst einen Stapel auch ohne diesen Block anklicken, '
              'aber dann hat dein Programm keinen Anfang – du musst jedes '
              'Mal auf die Blöcke klicken.',
          contentEs:
              'La categoría Eventos (amarilla) responde a una sola '
              'pregunta: «¿CUÁNDO debe ejecutarse esta pila?»\n\n'
              'Su respuesta primera y más usada es:\n\n'
              '   al hacer clic en la bandera verde\n\n'
              'Pones este bloque arriba de la pila. En el momento en que '
              'pulsas la bandera verde encima del escenario, los bloques de '
              'debajo se ejecutan en orden.\n\n'
              'También puedes hacer clic en una pila para ejecutarla sin '
              'este bloque, pero entonces tu programa no tiene un punto de '
              'partida: tendrías que hacer clic cada vez.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'yeşil bayrak tıklandığında',
              contentEn: 'when green flag clicked',
              contentDe: 'wenn die grüne Flagge angeklickt',
              contentEs: 'al hacer clic en la bandera verde',
              color: MBlockPalette.events,
              label: 'Olaylar · şapka blok',
              labelEn: 'Events · hat block',
              labelDe: 'Ereignisse · Hutblock',
              labelEs: 'Eventos · bloque de sombrero',
            ),
          ],
          tipEmoji: '🛑',
          tip: 'Yeşil bayrağın yanındaki kırmızı sekizgen her şeyi '
              'durdurur. Bir şey ters giderse oraya bas.',
          tipEn: 'The red octagon next to the flag stops everything. If '
              'something goes wrong, press that.',
          tipDe: 'Das rote Achteck neben der Flagge stoppt alles. Wenn '
              'etwas schiefgeht, drücke darauf.',
          tipEs: 'El octágono rojo junto a la bandera detiene todo. Si algo '
              'va mal, púlsalo.',
        ),

        ExplanationStep(
          id: 'm0_2_exp2',
          title: 'Sıra Yukarıdan Aşağıya',
          titleEn: 'Order Runs Top to Bottom',
          titleDe: 'Die Reihenfolge läuft von oben nach unten',
          titleEs: 'El orden va de arriba abajo',
          content:
              'İki blok kullanacağız:\n\n'
              '   Merhaba! de        (Görünüm, mor)\n'
              '   10 adım git        (Hareket, mavi)\n\n'
              'Bu ikisini şapka bloğunun altına takıp bayrağa basarsan '
              'sırayla olur: önce konuşma balonu çıkar, sonra karakter '
              'sağa doğru 10 adım kayar.\n\n'
              'Yerlerini değiştirirsen sonuç da değişir: karakter önce '
              'yürür, sonra konuşur. Bloklar aynı, sıra farklı — program '
              'başka bir program olur.',
          contentEn:
              'We will use two blocks:\n\n'
              '   say Hello!          (Looks, purple)\n'
              '   move 10 steps       (Motion, blue)\n\n'
              'Snap them under the hat block and press the flag: the speech '
              'bubble appears first, then the character slides 10 steps to '
              'the right.\n\n'
              'Swap them and the result changes: the character walks first, '
              'then speaks. Same blocks, different order — a different '
              'program.',
          contentDe:
              'Wir benutzen zwei Blöcke:\n\n'
              '   sage Hallo!          (Aussehen, violett)\n'
              '   gehe 10 er Schritt   (Bewegung, blau)\n\n'
              'Stecke sie unter den Hutblock und drücke die Flagge: Zuerst '
              'erscheint die Sprechblase, dann rutscht die Figur 10 '
              'Schritte nach rechts.\n\n'
              'Tausche sie, und das Ergebnis ändert sich: Die Figur läuft '
              'erst und spricht dann. Gleiche Blöcke, andere Reihenfolge – '
              'ein anderes Programm.',
          contentEs:
              'Usaremos dos bloques:\n\n'
              '   decir ¡Hola!        (Apariencia, morado)\n'
              '   mover 10 pasos      (Movimiento, azul)\n\n'
              'Engánchalos bajo el bloque de sombrero y pulsa la bandera: '
              'primero aparece el globo de diálogo y luego el personaje se '
              'desliza 10 pasos a la derecha.\n\n'
              'Intercámbialos y el resultado cambia: el personaje camina '
              'primero y habla después. Los mismos bloques, otro orden: '
              'otro programa.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Merhaba! de',
              contentEn: 'say Hello!',
              contentDe: 'sage Hallo!',
              contentEs: 'decir ¡Hola!',
              color: MBlockKuklaPalette.looks,
              label: 'Görünüm · düz blok',
              labelEn: 'Looks · stack block',
              labelDe: 'Aussehen · Stapelblock',
              labelEs: 'Apariencia · bloque de pila',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: '10 adım git',
              contentEn: 'move 10 steps',
              contentDe: 'gehe 10 er Schritt',
              contentEs: 'mover 10 pasos',
              color: MBlockKuklaPalette.motion,
              label: 'Hareket · düz blok',
              labelEn: 'Motion · stack block',
              labelDe: 'Bewegung · Stapelblock',
              labelEs: 'Movimiento · bloque de pila',
            ),
          ],
          tipEmoji: '📏',
          tip: '"adım" bir pikseldir. 10 adım gözle zor görülür; 50 yazınca '
              'hareket belli olur.',
          tipEn: 'A "step" is one pixel. 10 steps is hard to see; type 50 '
              'and the movement is obvious.',
          tipDe: 'Ein «Schritt» ist ein Pixel. 10 Schritte sieht man kaum; '
              'tippe 50, dann ist die Bewegung deutlich.',
          tipEs: 'Un «paso» es un píxel. 10 pasos casi no se ven; escribe '
              '50 y el movimiento se nota.',
        ),

        BlockBuilderStep(
          id: 'm0_2_build1',
          instruction:
              'Bayrağa basınca önce selam veren, sonra yürüyen yığını kur.',
          instructionEn:
              'Build the stack that greets first and then walks when the '
              'flag is pressed.',
          instructionDe:
              'Baue den Stapel, der beim Drücken der Flagge zuerst grüßt '
              'und dann läuft.',
          instructionEs:
              'Construye la pila que primero saluda y luego camina al '
              'pulsar la bandera.',
          goal: 'Bayrak → Merhaba! de → 50 adım git',
          goalEn: 'Flag → say Hello! → move 50 steps',
          goalDe: 'Flagge → sage Hallo! → gehe 50 er Schritt',
          goalEs: 'Bandera → decir ¡Hola! → mover 50 pasos',
          availableBlocks: [
            MBlockKuklaBlocks.greenFlag(),
            MBlockKuklaBlocks.say('Merhaba!',
                textEn: 'Hello!', textDe: 'Hallo!', textEs: '¡Hola!',
                id: 'say_hi'),
            MBlockKuklaBlocks.move('50', id: 'move_50'),
            MBlockKuklaBlocks.turn('15', id: 'turn_15'),
          ],
          correctSequence: ['green_flag', 'say_hi', 'move_50'],
          mblock: MBlockTezgahAyari(
            // Arac kutusu kasten DAR: on sekiz blogun tamami verilince
            // dersin sordugu soru bir arama isine donuyor.
            bloklar: ['dev_bayrak', 'dev_de', 'dev_git', 'dev_don'],
            cozum: [
              MBlockBeklenen('dev_bayrak'),
              MBlockBeklenen('dev_de', alanlar: {'METIN': 'Merhaba!'}),
              MBlockBeklenen('dev_git', alanlar: {'ADIM': '50'}),
            ],
          ),
          xpReward: 30,
        ),

        OrderingStep(
          id: 'm0_2_order1',
          instruction:
              'Karakter önce büyüsün, sonra konuşsun, sonra yürüsün. '
              'Blokları sıraya koy.',
          instructionEn:
              'The character should grow, then speak, then walk. Put the '
              'blocks in order.',
          instructionDe:
              'Die Figur soll erst größer werden, dann sprechen, dann '
              'laufen. Bringe die Blöcke in die richtige Reihenfolge.',
          instructionEs:
              'El personaje debe crecer, luego hablar y luego caminar. Pon '
              'los bloques en orden.',
          context: 'Bayrak bloğu en üstte, zaten yerinde.',
          contextEn: 'The flag block is already at the top.',
          contextDe: 'Der Flaggenblock ist schon oben.',
          contextEs: 'El bloque de la bandera ya está arriba.',
          items: [
            OrderItem(
              id: 'o_size',
              content: 'boyutu 20 değiştir',
              contentEn: 'change size by 20',
              contentDe: 'ändere Größe um 20',
              contentEs: 'cambiar tamaño por 20',
            ),
            OrderItem(
              id: 'o_say',
              content: 'Büyüdüm! de',
              contentEn: 'say I grew!',
              contentDe: 'sage Ich bin gewachsen!',
              contentEs: 'decir ¡He crecido!',
            ),
            OrderItem(
              id: 'o_move',
              content: '50 adım git',
              contentEn: 'move 50 steps',
              contentDe: 'gehe 50 er Schritt',
              contentEs: 'mover 50 pasos',
            ),
          ],
          correctOrder: ['o_size', 'o_say', 'o_move'],
          xpReward: 20,
        ),

        MultipleChoiceStep(
          id: 'm0_2_q1',
          question:
              'Yığında "10 adım git" bloğu "Merhaba! de" bloğunun ÜSTÜNDE '
              'olsa ne olurdu?',
          questionEn:
              'What if "move 10 steps" were ABOVE "say Hello!" in the '
              'stack?',
          questionDe:
              'Was wäre, wenn «gehe 10 er Schritt» im Stapel ÜBER «sage '
              'Hallo!» stünde?',
          questionEs:
              '¿Qué pasaría si «mover 10 pasos» estuviera ENCIMA de «decir '
              '¡Hola!» en la pila?',
          options: [
            ChoiceOption(
              text: 'Karakter önce yürür, sonra konuşur',
              textEn: 'The character walks first, then speaks',
              textDe: 'Die Figur läuft erst und spricht dann',
              textEs: 'El personaje camina primero y luego habla',
            ),
            ChoiceOption(
              text: 'İkisi aynı anda olur',
              textEn: 'Both happen at the same time',
              textDe: 'Beides passiert gleichzeitig',
              textEs: 'Las dos cosas pasan a la vez',
            ),
            ChoiceOption(
              text: 'Hiçbir şey olmaz, hata verir',
              textEn: 'Nothing happens, it gives an error',
              textDe: 'Nichts passiert, es gibt einen Fehler',
              textEs: 'No pasa nada, da error',
            ),
            ChoiceOption(
              text: 'Sıra fark etmez, sonuç aynıdır',
              textEn: 'Order does not matter, same result',
              textDe: 'Die Reihenfolge ist egal, gleiches Ergebnis',
              textEs: 'El orden no importa, el resultado es igual',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Bloklar yukarıdan aşağıya sırayla çalışır. Üstteki blok '
              'bitmeden alttaki başlamaz — bu yüzden sırayı değiştirmek '
              'programı değiştirir.',
          explanationEn:
              'Blocks run from top to bottom, one after another. The block '
              'below does not start until the one above finishes — so '
              'changing the order changes the program.',
          explanationDe:
              'Blöcke laufen von oben nach unten, einer nach dem anderen. '
              'Der untere Block startet erst, wenn der obere fertig ist – '
              'die Reihenfolge zu ändern ändert also das Programm.',
          explanationEs:
              'Los bloques se ejecutan de arriba abajo, uno tras otro. El '
              'bloque de abajo no empieza hasta que el de arriba termina, '
              'así que cambiar el orden cambia el programa.',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'm0_2_summary',
          title: 'İlk Yığın Çalıştı!',
          titleEn: 'Your First Stack Ran!',
          titleDe: 'Dein erster Stapel lief!',
          titleEs: '¡Tu primera pila funcionó!',
          content: '🟢 Üç blokla çalışan bir program yaptın.\n\n'
              '✓ Olaylar kategorisi "ne zaman" sorusunu cevaplıyor\n'
              '✓ Yeşil bayrak yığını başlatıyor\n'
              '✓ Bloklar yukarıdan aşağıya sırayla çalışıyor\n\n'
              'Sıradaki ders: aynı işi 10 kere yaptırmak.',
          contentEn: '🟢 Three blocks and you have a working program.\n\n'
              '✓ The Events category answers "when"\n'
              '✓ The green flag starts the stack\n'
              '✓ Blocks run top to bottom, in order\n\n'
              'Next lesson: doing the same thing ten times.',
          contentDe: '🟢 Drei Blöcke, und du hast ein laufendes '
              'Programm.\n\n'
              '✓ Die Kategorie Ereignisse beantwortet das «Wann»\n'
              '✓ Die grüne Flagge startet den Stapel\n'
              '✓ Blöcke laufen von oben nach unten, der Reihe nach\n\n'
              'Nächste Lektion: dasselbe zehnmal machen.',
          contentEs: '🟢 Tres bloques y ya tienes un programa que '
              'funciona.\n\n'
              '✓ La categoría Eventos responde al «cuándo»\n'
              '✓ La bandera verde inicia la pila\n'
              '✓ Los bloques se ejecutan de arriba abajo, en orden\n\n'
              'Siguiente lección: hacer lo mismo diez veces.',
          tipEmoji: '🏆',
          tip: 'İlk Yığın rozetini kazandın!',
          tipEn: 'You earned the First Stack badge!',
          tipDe: 'Du hast das Abzeichen «Erster Stapel» verdient!',
          tipEs: '¡Has ganado la insignia Primera Pila!',
        ),
      ],
    ),

    // ---------------------------------------------------------- Ders 0.3
    InteractiveLesson(
      id: 'mblock_0_3',
      courseId: 'mblock',
      title: 'Tekrarla ve Bekle',
      subtitle: 'C bloğu, sayaç ve zaman',
      titleEn: 'Repeat and Wait',
      titleDe: 'Wiederholen und warten',
      titleEs: 'Repetir y esperar',
      subtitleEn: 'The C block, the count and time',
      subtitleDe: 'Der C-Block, die Anzahl und die Zeit',
      subtitleEs: 'El bloque C, la cuenta y el tiempo',
      order: 3,
      xpReward: 50,
      badge: 'mblock_loop',
      steps: [
        IntroStep(
          id: 'm0_3_intro',
          mascotEmoji: '🔁',
          mascotMessage:
              'Karakteri 10 kere döndürmek için 10 tane blok koymaya '
              'gerek yok. Kontrol kategorisinde içine blok alan bir kutu '
              'var: "10 kere tekrarla".\n\n'
              'Bu ders iki şeyi öğretiyor: tekrar ve bekleme. İkisi bir '
              'arada kullanıldığında ekranda animasyon olur.',
          mascotMessageEn:
              'To turn the character ten times you do not need ten blocks. '
              'The Control category has a box that holds blocks inside: '
              '"repeat 10".\n\n'
              'This lesson teaches two things: repeating and waiting. Put '
              'them together and you get animation on the stage.',
          mascotMessageDe:
              'Um die Figur zehnmal zu drehen, brauchst du keine zehn '
              'Blöcke. Die Kategorie Steuerung hat einen Kasten, der Blöcke '
              'in sich aufnimmt: «wiederhole 10 mal».\n\n'
              'Diese Lektion lehrt zwei Dinge: Wiederholen und Warten. '
              'Zusammen ergibt das eine Animation auf der Bühne.',
          mascotMessageEs:
              'Para girar el personaje diez veces no hacen falta diez '
              'bloques. La categoría Control tiene una caja que contiene '
              'bloques dentro: «repetir 10 veces».\n\n'
              'Esta lección enseña dos cosas: repetir y esperar. Juntas dan '
              'una animación en el escenario.',
          highlights: [
            'Bir kutu, içine blok alıyor',
            'Sayıyı sen yazıyorsun',
            'Bekleme olmadan göz göremez',
          ],
          highlightsEn: [
            'One box, blocks go inside it',
            'You type the number',
            'Without a wait, the eye cannot see it',
          ],
          highlightsDe: [
            'Ein Kasten, Blöcke kommen hinein',
            'Die Zahl tippst du selbst',
            'Ohne Warten sieht das Auge nichts',
          ],
          highlightsEs: [
            'Una caja y los bloques van dentro',
            'El número lo escribes tú',
            'Sin espera, el ojo no lo ve',
          ],
        ),

        ExplanationStep(
          id: 'm0_3_exp1',
          title: '10 Kere Tekrarla',
          titleEn: 'Repeat 10 Times',
          titleDe: 'Wiederhole 10 mal',
          titleEs: 'Repetir 10 veces',
          content:
              'Kontrol kategorisi (turuncu) bir C şeklinde blok verir:\n\n'
              '   10 kere tekrarla\n'
              '     ⌐ içine koyduğun bloklar\n\n'
              'İçine ne koyarsan o, yazdığın sayı kadar tekrar eder. '
              'Kutudaki 10 sayısını değiştirebilirsin.\n\n'
              'Bir de "sürekli tekrarla" vardır: sayısı yoktur, sen '
              'durdurana kadar devam eder. Altına blok takılmaz, çünkü '
              'sonrası hiç gelmez.',
          contentEn:
              'The Control category (orange) gives you a C-shaped block:\n\n'
              '   repeat 10\n'
              '     ⌐ the blocks you put inside\n\n'
              'Whatever you put inside runs as many times as the number '
              'says. You can change the 10.\n\n'
              'There is also "forever": no number, it keeps going until you '
              'stop it. Nothing attaches below it, because there is no '
              'after.',
          contentDe:
              'Die Kategorie Steuerung (orange) gibt dir einen C-förmigen '
              'Block:\n\n'
              '   wiederhole 10 mal\n'
              '     ⌐ die Blöcke, die du hineinlegst\n\n'
              'Was du hineinlegst, läuft so oft, wie die Zahl sagt. Die 10 '
              'kannst du ändern.\n\n'
              'Es gibt auch «wiederhole fortlaufend»: keine Zahl, es läuft, '
              'bis du es stoppst. Darunter kommt nichts, denn ein Danach '
              'gibt es nicht.',
          contentEs:
              'La categoría Control (naranja) te da un bloque con forma de '
              'C:\n\n'
              '   repetir 10 veces\n'
              '     ⌐ los bloques que pones dentro\n\n'
              'Lo que pongas dentro se ejecuta tantas veces como diga el '
              'número. Puedes cambiar el 10.\n\n'
              'También existe «por siempre»: sin número, sigue hasta que lo '
              'detengas. Debajo no se engancha nada, porque no hay después.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '10 kere tekrarla',
              contentEn: 'repeat 10',
              contentDe: 'wiederhole 10 mal',
              contentEs: 'repetir 10 veces',
              color: MBlockPalette.control,
              label: 'Kontrol · C bloğu',
              labelEn: 'Control · C block',
              labelDe: 'Steuerung · C-Block',
              labelEs: 'Control · bloque C',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'sürekli tekrarla',
              contentEn: 'forever',
              contentDe: 'wiederhole fortlaufend',
              contentEs: 'por siempre',
              color: MBlockPalette.control,
              label: 'Kontrol · altı kapalı C',
              labelEn: 'Control · C block with no bottom notch',
              labelDe: 'Steuerung · C-Block ohne untere Kerbe',
              labelEs: 'Control · bloque C sin muesca inferior',
            ),
          ],
          tipEmoji: '🔍',
          tip: 'Bloğu C kutusunun İÇİNE sürüklerken kutunun ağzında gri '
              'bir gölge çıkar. O gölge "buraya girecek" demek.',
          tipEn: 'While dragging a block INTO the C box, a grey shadow '
              'appears at its mouth. That shadow means "it will go here".',
          tipDe: 'Wenn du einen Block IN den C-Kasten ziehst, erscheint an '
              'seiner Öffnung ein grauer Schatten. Der Schatten heißt '
              '«hier kommt er hinein».',
          tipEs: 'Al arrastrar un bloque DENTRO de la caja C aparece una '
              'sombra gris en su boca. Esa sombra significa «entrará aquí».',
        ),

        ExplanationStep(
          id: 'm0_3_exp2',
          title: 'Beklemeyi Koymazsan',
          titleEn: 'If You Leave Out the Wait',
          titleDe: 'Wenn du das Warten weglässt',
          titleEs: 'Si te dejas la espera',
          content:
              'Bilgisayar blokları çok hızlı çalıştırır. "10 kere '
              'tekrarla" içine sadece "36 derece dön" koyarsan karakter '
              'bir tam tur atar ama sen dönüşü GÖRMEZSİN — hepsi bir göz '
              'kırpmasında biter.\n\n'
              'Çözüm Kontrol kategorisindeki şu blok:\n\n'
              '   0.2 saniye bekle\n\n'
              'Her dönüşün arasına bir bekleme koyarsan hareket gözle '
              'takip edilebilir hâle gelir. Animasyonun sırrı budur: '
              'tekrar + bekleme.',
          contentEn:
              'A computer runs blocks very fast. If you put only "turn 36 '
              'degrees" inside "repeat 10", the character does a full turn '
              'but you do NOT see it — it is over in a blink.\n\n'
              'The fix is this block from Control:\n\n'
              '   wait 0.2 seconds\n\n'
              'Put a wait between the turns and the motion becomes '
              'watchable. That is the secret of animation: repeat + wait.',
          contentDe:
              'Ein Computer führt Blöcke sehr schnell aus. Legst du nur '
              '«drehe dich um 36 Grad» in «wiederhole 10 mal», dreht sich '
              'die Figur einmal ganz herum, aber du siehst es NICHT – es '
              'ist in einem Wimpernschlag vorbei.\n\n'
              'Die Lösung ist dieser Block aus Steuerung:\n\n'
              '   warte 0.2 Sekunden\n\n'
              'Setze zwischen die Drehungen ein Warten, und die Bewegung '
              'wird sichtbar. Das ist das Geheimnis der Animation: '
              'Wiederholen + Warten.',
          contentEs:
              'Un ordenador ejecuta los bloques muy rápido. Si dentro de '
              '«repetir 10 veces» pones solo «girar 36 grados», el '
              'personaje da una vuelta completa pero NO lo ves: acaba en un '
              'parpadeo.\n\n'
              'La solución es este bloque de Control:\n\n'
              '   esperar 0.2 segundos\n\n'
              'Pon una espera entre los giros y el movimiento se puede '
              'seguir con la vista. Ese es el secreto de la animación: '
              'repetir + esperar.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '0.2 saniye bekle',
              contentEn: 'wait 0.2 seconds',
              contentDe: 'warte 0.2 Sekunden',
              contentEs: 'esperar 0.2 segundos',
              color: MBlockPalette.control,
              label: 'Kontrol · düz blok',
              labelEn: 'Control · stack block',
              labelDe: 'Steuerung · Stapelblock',
              labelEs: 'Control · bloque de pila',
            ),
          ],
          tipEmoji: '⏱',
          tip: 'Bekleme kutusuna ondalık yazabilirsin: 0.1, 0.5, 1.5. '
              'Nokta kullan, virgül değil.',
          tipEn: 'You can type decimals in the wait slot: 0.1, 0.5, 1.5. '
              'Use a dot, not a comma.',
          tipDe: 'In den Warte-Schlitz kannst du Dezimalzahlen tippen: 0.1, '
              '0.5, 1.5. Benutze einen Punkt, kein Komma.',
          tipEs: 'En la ranura de espera puedes escribir decimales: 0.1, '
              '0.5, 1.5. Usa un punto, no una coma.',
        ),

        BlockBuilderStep(
          id: 'm0_3_build1',
          instruction:
              'Karakteri gözle görülebilecek hızda tam bir tur döndür.',
          instructionEn:
              'Turn the character a full circle, slow enough to watch.',
          instructionDe:
              'Dreh die Figur einmal ganz herum, langsam genug zum Zusehen.',
          instructionEs:
              'Gira el personaje una vuelta completa, lento para poder '
              'verlo.',
          goal: 'Bayrak → 10 kere tekrarla { 36 derece dön, 0.2 saniye bekle }',
          goalEn: 'Flag → repeat 10 { turn 36 degrees, wait 0.2 seconds }',
          goalDe:
              'Flagge → wiederhole 10 mal { drehe dich um 36 Grad, warte '
              '0.2 Sekunden }',
          goalEs:
              'Bandera → repetir 10 veces { girar 36 grados, esperar 0.2 '
              'segundos }',
          availableBlocks: [
            MBlockKuklaBlocks.greenFlag(),
            MBlockKuklaBlocks.repeat('10', id: 'repeat_10'),
            MBlockKuklaBlocks.turn('36', id: 'turn_36'),
            MBlockKuklaBlocks.wait('0.2', id: 'wait_02'),
            MBlockKuklaBlocks.move('50', id: 'move_50'),
          ],
          correctSequence: ['green_flag', 'repeat_10', 'turn_36', 'wait_02'],
          mblock: MBlockTezgahAyari(
            bloklar: [
              'dev_bayrak',
              'dev_tekrarla',
              'dev_don',
              'dev_bekle',
              'dev_git',
            ],
            cozum: [
              MBlockBeklenen('dev_bayrak'),
              MBlockBeklenen('dev_tekrarla', alanlar: {
                'KERE': '10'
              }, icerik: [
                MBlockBeklenen('dev_don', alanlar: {'ACI': '36'}),
                MBlockBeklenen('dev_bekle', alanlar: {'SANIYE': '0.2'}),
              ]),
            ],
          ),
          xpReward: 35,
        ),

        MultipleChoiceStep(
          id: 'm0_3_q1',
          question:
              '36 dereceyi 10 kere tekrarlarsan karakter kaç derece döner?',
          questionEn:
              'If you repeat 36 degrees ten times, how far does the '
              'character turn?',
          questionDe:
              'Wenn du 36 Grad zehnmal wiederholst, um wie viel dreht sich '
              'die Figur?',
          questionEs:
              'Si repites 36 grados diez veces, ¿cuánto gira el personaje?',
          options: [
            ChoiceOption(
              text: '360 derece — tam tur',
              textEn: '360 degrees — a full circle',
              textDe: '360 Grad – eine ganze Runde',
              textEs: '360 grados: una vuelta completa',
            ),
            ChoiceOption(
              text: '36 derece — tekrar fark etmez',
              textEn: '36 degrees — repeating changes nothing',
              textDe: '36 Grad – Wiederholen ändert nichts',
              textEs: '36 grados: repetir no cambia nada',
            ),
            ChoiceOption(
              text: '180 derece — yarım tur',
              textEn: '180 degrees — a half circle',
              textDe: '180 Grad – eine halbe Runde',
              textEs: '180 grados: media vuelta',
            ),
            ChoiceOption(
              text: '10 derece',
              textEn: '10 degrees',
              textDe: '10 Grad',
              textEs: '10 grados',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Her tekrarda 36 derece ekleniyor: 36 × 10 = 360. Tam tur '
              'attığı için karakter başladığı yöne geri döner.',
          explanationEn:
              'Each pass adds 36 degrees: 36 × 10 = 360. It is a full '
              'circle, so the character ends up facing where it started.',
          explanationDe:
              'Jeder Durchgang fügt 36 Grad hinzu: 36 × 10 = 360. Das ist '
              'eine ganze Runde, also schaut die Figur am Ende wieder in '
              'die Startrichtung.',
          explanationEs:
              'Cada pasada suma 36 grados: 36 × 10 = 360. Es una vuelta '
              'completa, así que el personaje acaba mirando hacia donde '
              'empezó.',
          xpReward: 15,
        ),

        MultipleChoiceStep(
          id: 'm0_3_q2',
          question:
              '"sürekli tekrarla" bloğunun ALTINA neden blok takılmıyor?',
          questionEn:
              'Why can nothing attach BELOW the "forever" block?',
          questionDe:
              'Warum kann UNTER dem Block «wiederhole fortlaufend» nichts '
              'andocken?',
          questionEs:
              '¿Por qué no se puede enganchar nada DEBAJO del bloque «por '
              'siempre»?',
          options: [
            ChoiceOption(
              text: 'Hiç bitmediği için sonrası hiç gelmez',
              textEn: 'It never ends, so there is no after',
              textDe: 'Er endet nie, also gibt es kein Danach',
              textEs: 'Nunca termina, así que no hay después',
            ),
            ChoiceOption(
              text: 'mBlock\'ta bir hata, düzeltilecek',
              textEn: 'It is a bug in mBlock, to be fixed',
              textDe: 'Das ist ein Fehler in mBlock, wird behoben',
              textEs: 'Es un error de mBlock, lo arreglarán',
            ),
            ChoiceOption(
              text: 'Yalnızca ücretli sürümde takılabiliyor',
              textEn: 'Only the paid version allows it',
              textDe: 'Nur die Bezahlversion erlaubt das',
              textEs: 'Solo la versión de pago lo permite',
            ),
            ChoiceOption(
              text: 'Takılır ama görünmez olur',
              textEn: 'It attaches but becomes invisible',
              textDe: 'Er dockt an, wird aber unsichtbar',
              textEs: 'Se engancha pero se vuelve invisible',
            ),
          ],
          correctIndex: 0,
          explanation:
              'Blok altındaki tırtığı yoktur, çünkü program o kutunun '
              'içinden hiç çıkmaz. Altına bir şey takılsa asla '
              'çalışmayacaktı — mBlock bunu şekille söylüyor.',
          explanationEn:
              'The block has no bottom notch, because the program never '
              'leaves that box. Anything attached below would never run — '
              'mBlock says so with the shape.',
          explanationDe:
              'Der Block hat unten keine Kerbe, weil das Programm diesen '
              'Kasten nie verlässt. Was darunter hinge, würde nie laufen – '
              'mBlock sagt das über die Form.',
          explanationEs:
              'El bloque no tiene muesca abajo porque el programa nunca sale '
              'de esa caja. Lo que se enganchara debajo nunca se '
              'ejecutaría; mBlock lo dice con la forma.',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'm0_3_summary',
          title: 'Temeli Bitirdin!',
          titleEn: 'You Finished the Basics!',
          titleDe: 'Du hast die Grundlagen geschafft!',
          titleEs: '¡Has terminado lo básico!',
          content: '🔁 Üç derste hiç kablo takmadan program yazdın.\n\n'
              '✓ Palet, kod alanı, sahne\n'
              '✓ Beş blok şekli\n'
              '✓ Yeşil bayrak ve yukarıdan aşağıya sıra\n'
              '✓ Tekrar ve bekleme\n\n'
              'ŞİMDİ KÖPRÜ: bu blokların tam aynısı, bilgisayara bir kart '
              'taktığında sahnedeki karakteri değil masandaki gerçek bir '
              'LED\'i çalıştırıyor. "10 kere tekrarla" aynı blok; içine '
              'koyduğun şey değişiyor.\n\n'
              'Sıradaki modül: cihaz sekmesi, kart ve palette değişen '
              'kategoriler.',
          contentEn: '🔁 Three lessons, and you wrote programs without a '
              'single cable.\n\n'
              '✓ Palette, code area, stage\n'
              '✓ The five block shapes\n'
              '✓ The green flag and top-to-bottom order\n'
              '✓ Repeating and waiting\n\n'
              'NOW THE BRIDGE: these exact same blocks, once you plug a '
              'board into the computer, drive a real LED on your desk '
              'instead of a character on the stage. "repeat 10" is the same '
              'block; what you put inside changes.\n\n'
              'Next module: the Devices tab, the board, and how the palette '
              'changes.',
          contentDe: '🔁 Drei Lektionen, und du hast Programme ohne ein '
              'einziges Kabel geschrieben.\n\n'
              '✓ Palette, Codebereich, Bühne\n'
              '✓ Die fünf Blockformen\n'
              '✓ Die grüne Flagge und die Reihenfolge von oben nach unten\n'
              '✓ Wiederholen und Warten\n\n'
              'JETZT DIE BRÜCKE: Genau dieselben Blöcke steuern, sobald du '
              'eine Platine an den Computer steckst, eine echte LED auf '
              'deinem Tisch statt einer Figur auf der Bühne. «wiederhole 10 '
              'mal» ist derselbe Block; nur der Inhalt ändert sich.\n\n'
              'Nächstes Modul: der Reiter Geräte, die Platine und wie sich '
              'die Palette ändert.',
          contentEs: '🔁 Tres lecciones y has escrito programas sin un solo '
              'cable.\n\n'
              '✓ Paleta, área de código, escenario\n'
              '✓ Las cinco formas de bloque\n'
              '✓ La bandera verde y el orden de arriba abajo\n'
              '✓ Repetir y esperar\n\n'
              'AHORA EL PUENTE: estos mismos bloques, en cuanto conectes '
              'una placa al ordenador, manejan un LED de verdad sobre tu '
              'mesa en vez de un personaje en el escenario. «repetir 10 '
              'veces» es el mismo bloque; lo que cambia es lo que pones '
              'dentro.\n\n'
              'Siguiente módulo: la pestaña Dispositivos, la placa y cómo '
              'cambia la paleta.',
          tipEmoji: '🏆',
          tip: 'Döngü rozetini kazandın! Kart bundan sonraki modülde '
              'geliyor.',
          tipEn: 'You earned the Loop badge! The board comes in the next '
              'module.',
          tipDe: 'Du hast das Schleifen-Abzeichen verdient! Die Platine '
              'kommt im nächsten Modul.',
          tipEs: '¡Has ganado la insignia Bucle! La placa llega en el '
              'siguiente módulo.',
        ),
      ],
    ),
  ];
}
