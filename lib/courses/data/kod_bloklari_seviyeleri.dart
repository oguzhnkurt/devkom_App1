import '../models/interactive_lesson_model.dart';
import '../yurutme/atolye_hedefleri.dart';
import 'scratch_atolye_bloklari.dart';

/// KOD BLOKLARI oyununun seviyeleri: "Çizim Ustası".
///
/// Eskiden Kod Bloklari da Robot Simulatoru gibi izgarada robot
/// yuruten bir oyundu; ikisi ayni oyundu. Artik GERCEK Scratch
/// bloklariyla (bayrak, kalem, tekrarla, git, don) Devi'nin kalemine
/// sekil cizdiren on seviye: cizgi -> kose -> kare -> donguyle kare ->
/// ucgen -> altigen -> besgen -> yildiz -> iki kare (kalem kaldir) ->
/// ic ice dongulerle kare cicegi. Her seviye bir [ProjeAtolyesiStep];
/// hedefler blok sirasina degil CIZIME bakiyor ve her seviyenin ornek
/// cozumu testte calistiriliyor (test/kod_bloklari_test.dart).
class KodBloklariSeviyeleri {
  KodBloklariSeviyeleri._();

  static final _temel = [
    AtolyeBloklari.bayrak,
    AtolyeBloklari.sil,
    AtolyeBloklari.kalemIndir,
    AtolyeBloklari.git100,
  ];

  static ProjeAtolyesiStep _seviye({
    required int no,
    required List<String> baslik,
    required List<String> anlatim,
    required List<String> ipucu,
    required List<ScratchBlock> palet,
    required List<AtolyeHedefi> hedefler,
    required String cozum,
    Set<String> sayi = const {},
  }) =>
      ProjeAtolyesiStep(
        id: 'kod_bloklari_$no',
        title: baslik[0],
        titleEn: baslik[1],
        titleDe: baslik[2],
        titleEs: baslik[3],
        description: anlatim[0],
        descriptionEn: anlatim[1],
        descriptionDe: anlatim[2],
        descriptionEs: anlatim[3],
        ipucu: ipucu[0],
        ipucuEn: ipucu[1],
        ipucuDe: ipucu[2],
        ipucuEs: ipucu[3],
        palet: palet,
        hedefler: hedefler,
        ornekCozum: cozum,
        sayiDuzenlenebilir: sayi,
        xpReward: 20 + no * 2,
      );

  static const _sil = BlokHedefi(
    metin: 'Başta tahtayı sil',
    metinEn: 'Clear the board first',
    metinDe: 'Lösche zuerst die Tafel',
    metinEs: 'Primero borra la pizarra',
    bloklar: {'pen_clear'},
  );

  static const _dongu = BlokHedefi(
    metin: 'Bir döngü kullan',
    metinEn: 'Use a loop',
    metinDe: 'Benutze eine Schleife',
    metinEs: 'Usa un bucle',
    bloklar: {'repeat_4'},
  );

  static KapaliSekilHedefi _kapali(int n, List<String> m) => KapaliSekilHedefi(
        metin: m[0],
        metinEn: m[1],
        metinDe: m[2],
        metinEs: m[3],
        kenar: n,
      );

  static final List<ProjeAtolyesiStep> hepsi = [
    // 1 ------------------------------------------------------------
    _seviye(
      no: 1,
      baslik: ['İlk Çizgi', 'First Line', 'Erste Linie', 'Primera línea'],
      anlatim: [
        'Devi\'nin elinde bir kalem var. Bayrağa basınca tahtayı sil, '
            'kalemi indir ve ileri git: ilk çizgin hazır!',
        'Devi is holding a pen. When the flag is clicked, clear the board, '
            'put the pen down and move: your first line!',
        'Devi hält einen Stift. Wenn die Fahne angeklickt wird: Tafel '
            'löschen, Stift einschalten und gehen — deine erste Linie!',
        'Devi tiene un lápiz. Al pulsar la bandera, borra la pizarra, baja '
            'el lápiz y avanza: ¡tu primera línea!',
      ],
      ipucu: [
        'Sıra önemli: önce bayrak, sonra sil, sonra kalem indir, en son '
            'git.',
        'Order matters: flag first, then erase, then pen down, then move.',
        'Die Reihenfolge zählt: zuerst Fahne, dann löschen, dann Stift ein, '
            'dann gehen.',
        'El orden importa: primero la bandera, luego borrar, luego bajar el '
            'lápiz y al final avanzar.',
      ],
      palet: _temel,
      hedefler: const [
        CizgiHedefi(
          metin: 'Kalemle bir çizgi çiz',
          metinEn: 'Draw a line with the pen',
          metinDe: 'Zeichne mit dem Stift eine Linie',
          metinEs: 'Dibuja una línea con el lápiz',
          enAz: 1,
        ),
        _sil,
      ],
      cozum: 'green_flag pen_clear pen_down move_100',
    ),
    // 2 ------------------------------------------------------------
    _seviye(
      no: 2,
      baslik: ['Köşe', 'Corner', 'Ecke', 'Esquina'],
      anlatim: [
        'Bir çizgi çiz, sonra 90 derece dön ve bir çizgi daha çiz. '
            'Bir köşe olacak!',
        'Draw a line, turn 90 degrees and draw another line. That makes a '
            'corner!',
        'Zeichne eine Linie, drehe dich um 90 Grad und zeichne noch eine. '
            'Das gibt eine Ecke!',
        'Dibuja una línea, gira 90 grados y dibuja otra. ¡Eso es una '
            'esquina!',
      ],
      ipucu: [
        'git → dön → git. Dönmeden iki kez gidersen tek uzun çizgi olur.',
        'move → turn → move. Two moves without a turn make one long line.',
        'gehen → drehen → gehen. Zweimal gehen ohne Drehung ergibt eine '
            'lange Linie.',
        'avanzar → girar → avanzar. Dos avances sin girar hacen una sola '
            'línea larga.',
      ],
      palet: [..._temel, AtolyeBloklari.don90],
      hedefler: const [
        CizgiHedefi(
          metin: 'İki ayrı çizgi çiz',
          metinEn: 'Draw two separate lines',
          metinDe: 'Zeichne zwei verschiedene Linien',
          metinEs: 'Dibuja dos líneas distintas',
          enAz: 2,
        ),
        BlokHedefi(
          metin: 'Bir kez dön',
          metinEn: 'Turn once',
          metinDe: 'Dreh dich einmal',
          metinEs: 'Gira una vez',
          bloklar: {'turn_90'},
        ),
      ],
      cozum: 'green_flag pen_clear pen_down move_100 turn_90 move_100',
    ),
    // 3 ------------------------------------------------------------
    _seviye(
      no: 3,
      baslik: ['Kare', 'Square', 'Quadrat', 'Cuadrado'],
      anlatim: [
        'Dört kenar, dört köşe: Devi başladığı yere dönsün. Bu seviyede '
            'döngü yok, blokları tek tek diz.',
        'Four sides, four corners: Devi ends where it started. No loop here: '
            'line the blocks up one by one.',
        'Vier Seiten, vier Ecken: Devi endet, wo es begann. Hier gibt es '
            'keine Schleife — reih die Blöcke einzeln auf.',
        'Cuatro lados, cuatro esquinas: Devi acaba donde empezó. Aquí no hay '
            'bucle: pon los bloques uno a uno.',
      ],
      ipucu: [
        '"git" ve "dön" bloklarını dört kez art arda koy.',
        'Put "move" and "turn" one after the other, four times.',
        'Setz „gehen“ und „drehen“ viermal hintereinander.',
        'Pon "avanzar" y "girar" uno tras otro, cuatro veces.',
      ],
      palet: [..._temel, AtolyeBloklari.don90],
      hedefler: [
        _kapali(4, const [
          '4 kenarlı kapalı bir şekil çiz',
          'Draw a closed shape with 4 sides',
          'Zeichne eine geschlossene Form mit 4 Seiten',
          'Dibuja una figura cerrada de 4 lados',
        ]),
        _sil,
      ],
      cozum: 'green_flag pen_clear pen_down move_100 turn_90 move_100 '
          'turn_90 move_100 turn_90 move_100 turn_90',
    ),
    // 4 ------------------------------------------------------------
    _seviye(
      no: 4,
      baslik: [
        'Döngüyle Kare',
        'Square with a Loop',
        'Quadrat mit Schleife',
        'Cuadrado con bucle',
      ],
      anlatim: [
        'Aynı kareyi bu kez çok daha kısa kodla çiz: "4 defa tekrarla" '
            'bloğunun içine bir git ve bir dön koy.',
        'Draw the same square with much shorter code: put one move and one '
            'turn inside "repeat 4".',
        'Zeichne dasselbe Quadrat mit viel kürzerem Code: Leg ein Gehen und '
            'ein Drehen in „wiederhole 4 mal“.',
        'Dibuja el mismo cuadrado con un código mucho más corto: mete un '
            'avanzar y un girar dentro de "repetir 4".',
      ],
      ipucu: [
        'Tekrarla bloğu bir ağız gibi: git ve dön onun İÇİNE girsin.',
        'The repeat block is like a mouth: move and turn go INSIDE it.',
        'Der Wiederhole-Block ist wie ein Maul: Gehen und Drehen kommen '
            'HINEIN.',
        'El bloque repetir es como una boca: avanzar y girar van DENTRO.',
      ],
      palet: [
        ..._temel,
        AtolyeBloklari.tekrarla('4'),
        AtolyeBloklari.don90,
      ],
      hedefler: [
        _kapali(4, const [
          'Kapalı bir kare çiz',
          'Draw a closed square',
          'Zeichne ein geschlossenes Quadrat',
          'Dibuja un cuadrado cerrado',
        ]),
        _dongu,
      ],
      cozum: 'green_flag pen_clear pen_down repeat_4 move_100 turn_90 }',
    ),
    // 5 ------------------------------------------------------------
    _seviye(
      no: 5,
      baslik: ['Üçgen', 'Triangle', 'Dreieck', 'Triángulo'],
      anlatim: [
        'Üç kenarlı kapalı bir şekil. Döngü kaç kez dönmeli, köşelerde kaç '
            'derece dönmelisin? Sayılara dokunup değiştir.',
        'A closed shape with three sides. How many times does the loop run, '
            'and how far do you turn at each corner? Tap the numbers to '
            'change them.',
        'Eine geschlossene Form mit drei Seiten. Wie oft läuft die Schleife, '
            'und wie weit drehst du an jeder Ecke? Tippe auf die Zahlen.',
        'Una figura cerrada de tres lados. ¿Cuántas veces da vueltas el '
            'bucle y cuánto giras en cada esquina? Toca los números.',
      ],
      ipucu: [
        'Bir tam tur 360 derece. 3 köşeye bölünce her köşede kaç derece?',
        'A full turn is 360 degrees. Split it over 3 corners: how much at '
            'each one?',
        'Eine ganze Drehung sind 360 Grad. Auf 3 Ecken verteilt: wie viel '
            'pro Ecke?',
        'Una vuelta entera son 360 grados. Repártelos en 3 esquinas: ¿cuánto '
            'en cada una?',
      ],
      palet: [
        ..._temel,
        AtolyeBloklari.tekrarla('4'),
        AtolyeBloklari.don90,
      ],
      sayi: {'repeat_4', 'turn_90', 'move_100'},
      hedefler: [
        _kapali(3, const [
          '3 kenarlı kapalı bir şekil çiz',
          'Draw a closed shape with 3 sides',
          'Zeichne eine geschlossene Form mit 3 Seiten',
          'Dibuja una figura cerrada de 3 lados',
        ]),
        _dongu,
      ],
      cozum: 'green_flag pen_clear pen_down repeat_4=3 move_100 '
          'turn_90=120 }',
    ),
    // 6 ------------------------------------------------------------
    _seviye(
      no: 6,
      baslik: ['Altıgen', 'Hexagon', 'Sechseck', 'Hexágono'],
      anlatim: [
        'Bal peteğindeki gibi altı kenarlı bir şekil çiz. Tahtaya sığsın '
            'diye kenarları biraz kısalt.',
        'Draw a six-sided shape like a honeycomb cell. Make the sides a bit '
            'shorter so it fits on the board.',
        'Zeichne eine sechseckige Form wie eine Bienenwabe. Mach die Seiten '
            'etwas kürzer, damit sie auf die Tafel passt.',
        'Dibuja una figura de seis lados como una celda de panal. Acorta un '
            'poco los lados para que quepa en la pizarra.',
      ],
      ipucu: [
        '6 kenar: döngü 6 kez. 360 ÷ 6 = ? Kenar için 100 yerine 80 dene.',
        '6 sides: the loop runs 6 times. 360 ÷ 6 = ? Try 80 instead of 100 '
            'for the side.',
        '6 Seiten: Die Schleife läuft 6-mal. 360 ÷ 6 = ? Probier 80 statt '
            '100 für die Seite.',
        '6 lados: el bucle da 6 vueltas. 360 ÷ 6 = ? Prueba 80 en vez de '
            '100 para el lado.',
      ],
      palet: [
        ..._temel,
        AtolyeBloklari.tekrarla('4'),
        AtolyeBloklari.don90,
      ],
      sayi: {'repeat_4', 'turn_90', 'move_100'},
      hedefler: [
        _kapali(6, const [
          '6 kenarlı kapalı bir şekil çiz',
          'Draw a closed shape with 6 sides',
          'Zeichne eine geschlossene Form mit 6 Seiten',
          'Dibuja una figura cerrada de 6 lados',
        ]),
        _dongu,
      ],
      cozum: 'green_flag pen_clear pen_down repeat_4=6 move_100=80 '
          'turn_90=60 }',
    ),
    // 7 ------------------------------------------------------------
    _seviye(
      no: 7,
      baslik: ['Beşgen', 'Pentagon', 'Fünfeck', 'Pentágono'],
      anlatim: [
        'Beş kenarlı bir şekil. Artık kuralı biliyorsun: 360\'ı kenar '
            'sayısına böl.',
        'A five-sided shape. You know the rule now: divide 360 by the number '
            'of sides.',
        'Eine Form mit fünf Seiten. Du kennst die Regel: 360 durch die Zahl '
            'der Seiten.',
        'Una figura de cinco lados. Ya sabes la regla: divide 360 entre el '
            'número de lados.',
      ],
      ipucu: [
        '360 ÷ 5 = 72. Döngü 5 kez, her köşede 72 derece.',
        '360 ÷ 5 = 72. Loop 5 times, turn 72 degrees at each corner.',
        '360 ÷ 5 = 72. Schleife 5-mal, an jeder Ecke 72 Grad drehen.',
        '360 ÷ 5 = 72. Bucle 5 veces, gira 72 grados en cada esquina.',
      ],
      palet: [
        ..._temel,
        AtolyeBloklari.tekrarla('4'),
        AtolyeBloklari.don90,
      ],
      sayi: {'repeat_4', 'turn_90', 'move_100'},
      hedefler: [
        _kapali(5, const [
          '5 kenarlı kapalı bir şekil çiz',
          'Draw a closed shape with 5 sides',
          'Zeichne eine geschlossene Form mit 5 Seiten',
          'Dibuja una figura cerrada de 5 lados',
        ]),
        _dongu,
      ],
      cozum: 'green_flag pen_clear pen_down repeat_4=5 move_100=80 '
          'turn_90=72 }',
    ),
    // 8 ------------------------------------------------------------
    _seviye(
      no: 8,
      baslik: ['Yıldız', 'Star', 'Stern', 'Estrella'],
      anlatim: [
        'Beşgenle aynı kod, tek farkla: köşelerde çok daha keskin dön. '
            'Çizgiler birbirini kesecek ve bir yıldız çıkacak!',
        'Same code as the pentagon with one change: turn much more sharply '
            'at each point. The lines cross and a star appears!',
        'Derselbe Code wie beim Fünfeck, nur eine Änderung: Dreh dich an '
            'jeder Spitze viel schärfer. Die Linien kreuzen sich — ein Stern!',
        'El mismo código que el pentágono con un cambio: gira mucho más en '
            'cada punta. ¡Las líneas se cruzan y sale una estrella!',
      ],
      ipucu: [
        'Beşgende 72 dönüyordun. Yıldızda iki katı: 144.',
        'The pentagon turned 72. The star turns twice as much: 144.',
        'Beim Fünfeck waren es 72. Der Stern dreht doppelt so viel: 144.',
        'El pentágono giraba 72. La estrella gira el doble: 144.',
      ],
      palet: [
        ..._temel,
        AtolyeBloklari.tekrarla('4'),
        AtolyeBloklari.don90,
      ],
      sayi: {'repeat_4', 'turn_90', 'move_100'},
      hedefler: [
        _kapali(5, const [
          '5 kenarlı kapalı bir çizim yap',
          'Make a closed drawing with 5 sides',
          'Mach eine geschlossene Zeichnung mit 5 Seiten',
          'Haz un dibujo cerrado de 5 lados',
        ]),
        const KonumHedefi(
          metin: 'Yıldızın bir ucu başladığın yerin yukarısına çıksın',
          metinEn: 'One point of the star goes above where you started',
          metinDe: 'Eine Sternspitze reicht über deinen Startpunkt hinaus',
          metinEs: 'Una punta de la estrella sube por encima del inicio',
          yEnAz: 20,
          herhangiAn: true,
        ),
      ],
      cozum: 'green_flag pen_clear pen_down repeat_4=5 move_100 '
          'turn_90=144 }',
    ),
    // 9 ------------------------------------------------------------
    _seviye(
      no: 9,
      baslik: ['İki Kare', 'Two Squares', 'Zwei Quadrate', 'Dos cuadrados'],
      anlatim: [
        'Yan yana iki ayrı kare çiz. Aralarında çizgi olmasın: ilerlerken '
            'kalemi kaldır, sonra yeniden indir.',
        'Draw two separate squares side by side with no line between them: '
            'lift the pen while moving, then put it down again.',
        'Zeichne zwei getrennte Quadrate nebeneinander, ohne Linie dazwischen: '
            'Stift aus beim Gehen, dann wieder ein.',
        'Dibuja dos cuadrados separados, uno al lado del otro, sin línea entre '
            'ellos: sube el lápiz al moverte y luego bájalo otra vez.',
      ],
      ipucu: [
        'Kare → kalem kaldır → git → kalem indir → kare. Kareleri 60 '
            'adımlık yap, aradaki boşluk 100 olsun.',
        'Square → pen up → move → pen down → square. Make the squares 60 '
            'steps, with a gap of 100.',
        'Quadrat → Stift aus → gehen → Stift ein → Quadrat. Mach die Quadrate '
            '60 Schritte groß, mit 100 Abstand.',
        'Cuadrado → subir lápiz → avanzar → bajar lápiz → cuadrado. Haz los '
            'cuadrados de 60 pasos y deja 100 de espacio.',
      ],
      palet: [
        ..._temel,
        AtolyeBloklari.kalemKaldir,
        AtolyeBloklari.tekrarla('4'),
        AtolyeBloklari.don90,
      ],
      sayi: {'repeat_4', 'turn_90', 'move_100'},
      hedefler: const [
        CizgiHedefi(
          metin: 'En az 8 kenar çiz (iki kare)',
          metinEn: 'Draw at least 8 sides (two squares)',
          metinDe: 'Zeichne mindestens 8 Seiten (zwei Quadrate)',
          metinEs: 'Dibuja al menos 8 lados (dos cuadrados)',
          enAz: 8,
        ),
        BlokHedefi(
          metin: 'Kalemi bir kez kaldır',
          metinEn: 'Lift the pen once',
          metinDe: 'Schalte den Stift einmal aus',
          metinEs: 'Sube el lápiz una vez',
          bloklar: {'pen_up'},
        ),
        _dongu,
      ],
      cozum: 'green_flag pen_clear pen_down repeat_4 move_100=60 turn_90 } '
          'pen_up move_100 pen_down repeat_4 move_100=60 turn_90 }',
    ),
    // 10 -----------------------------------------------------------
    _seviye(
      no: 10,
      baslik: [
        'Kare Çiçeği',
        'Square Flower',
        'Quadratblume',
        'Flor de cuadrados',
      ],
      anlatim: [
        'Usta seviyesi: bir döngünün İÇİNE başka bir döngü koy. İçteki '
            'döngü kare çizsin, dıştaki her kareden sonra biraz dönüp 6 kez '
            'tekrar etsin.',
        'Master level: put a loop INSIDE another loop. The inner loop draws '
            'a square; the outer one turns a little after each square and '
            'repeats 6 times.',
        'Meisterlevel: Leg eine Schleife IN eine andere. Die innere zeichnet '
            'ein Quadrat, die äußere dreht sich nach jedem Quadrat ein Stück '
            'und läuft 6-mal.',
        'Nivel maestro: mete un bucle DENTRO de otro. El de dentro dibuja un '
            'cuadrado; el de fuera gira un poco tras cada cuadrado y se '
            'repite 6 veces.',
      ],
      ipucu: [
        'Dış döngü 6 kez: içinde kare döngüsü ve "60 derece dön". Kareler '
            '60 adım olsun.',
        'Outer loop 6 times: inside it the square loop and "turn 60". Make '
            'the squares 60 steps.',
        'Äußere Schleife 6-mal: darin die Quadrat-Schleife und „drehe 60“. '
            'Quadrate mit 60 Schritten.',
        'Bucle exterior 6 veces: dentro, el bucle del cuadrado y "girar 60". '
            'Cuadrados de 60 pasos.',
      ],
      palet: [
        ..._temel,
        AtolyeBloklari.tekrarla('4'),
        AtolyeBloklari.don90,
      ],
      sayi: {'repeat_4', 'turn_90', 'move_100'},
      hedefler: const [
        CizgiHedefi(
          metin: 'En az 24 kenar çiz (6 kare)',
          metinEn: 'Draw at least 24 sides (6 squares)',
          metinDe: 'Zeichne mindestens 24 Seiten (6 Quadrate)',
          metinEs: 'Dibuja al menos 24 lados (6 cuadrados)',
          enAz: 24,
        ),
        BlokHedefi(
          metin: 'İç içe iki döngü kullan',
          metinEn: 'Use two loops, one inside the other',
          metinDe: 'Benutze zwei verschachtelte Schleifen',
          metinEs: 'Usa dos bucles, uno dentro del otro',
          bloklar: {'repeat_4'},
          enAz: 2,
        ),
      ],
      cozum: 'green_flag pen_clear pen_down repeat_4=6 repeat_4 '
          'move_100=60 turn_90 } turn_90=60 }',
    ),
  ];

  static int get sayi => hepsi.length;

  /// Kimligiyle seviye (Projelerim'de kayitli cizimi yeniden acmak icin).
  static ProjeAtolyesiStep? bul(String? id) {
    if (id == null) return null;
    for (final s in hepsi) {
      if (s.id == id) return s;
    }
    return null;
  }
}
