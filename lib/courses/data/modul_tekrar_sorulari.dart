import '../models/interactive_lesson_model.dart';

/// MODUL TEKRAR SORULARI.
///
/// Modul sinavi derslerin icindeki coktan secmeli sorulari topluyordu ve
/// en az uc soru isteniyordu: Scratch'in on bir modulunden yalnizca
/// ikisinde, mBlock'un altisindan dordunde sinav cikiyordu. Bu sorular
/// dersteki sorularin kopyasi DEGIL; modulun konusunu baska bir acidan
/// soruyor (tahmin et, hesapla, hatayi gor). Ders icinde gorunmuyorlar,
/// yalnizca modul sinavinda.
class ModulTekrarSorulari {
  ModulTekrarSorulari._();

  static const List<MultipleChoiceStep> scratch2 = [
    MultipleChoiceStep(
      id: 'tq_s2_1',
      question:
          'Devi x: 0, y: 0 noktasında. \'x konumunu 10 değiştir\' bloğu üç kez çalışırsa Devi nerede olur?',
      questionEn:
          'Devi is at x: 0, y: 0. If \'change x by 10\' runs three times, where is Devi?',
      questionDe:
          'Devi steht bei x: 0, y: 0. Wo ist Devi, wenn „ändere x um 10“ dreimal läuft?',
      questionEs:
          'Devi está en x: 0, y: 0. Si \'cambiar x por 10\' se ejecuta tres veces, ¿dónde está Devi?',
      options: [
        ChoiceOption(
            text: 'x: 30, y: 0',
            textEn: 'x: 30, y: 0',
            textDe: 'x: 30, y: 0',
            textEs: 'x: 30, y: 0'),
        ChoiceOption(
            text: 'x: 10, y: 0',
            textEn: 'x: 10, y: 0',
            textDe: 'x: 10, y: 0',
            textEs: 'x: 10, y: 0'),
        ChoiceOption(
            text: 'x: 0, y: 30',
            textEn: 'x: 0, y: 30',
            textDe: 'x: 0, y: 30',
            textEs: 'x: 0, y: 30'),
        ChoiceOption(
            text: 'x: 30, y: 30',
            textEn: 'x: 30, y: 30',
            textDe: 'x: 30, y: 30',
            textEs: 'x: 30, y: 30'),
      ],
      correctIndex: 0,
      explanation:
          'Her çalışma x\'e 10 ekliyor: 10 + 10 + 10 = 30. y değişmiyor.',
      explanationEn:
          'Each run adds 10 to x: 10 + 10 + 10 = 30. y does not change.',
      explanationDe:
          'Jeder Durchlauf zählt 10 zu x dazu: 10 + 10 + 10 = 30. y bleibt gleich.',
      explanationEs: 'Cada vez suma 10 a x: 10 + 10 + 10 = 30. y no cambia.',
    ),
    MultipleChoiceStep(
      id: 'tq_s2_2',
      question: 'Hangi blok Devi\'yi sahnenin tam ortasına götürür?',
      questionEn: 'Which block takes Devi to the exact centre of the stage?',
      questionDe: 'Welcher Block bringt Devi genau in die Mitte der Bühne?',
      questionEs: '¿Qué bloque lleva a Devi justo al centro del escenario?',
      options: [
        ChoiceOption(
            text: 'rastgele konuma git',
            textEn: 'go to random position',
            textDe: 'gehe zu Zufallsposition',
            textEs: 'ir a posición aleatoria'),
        ChoiceOption(
            text: 'x: 0 y: 0 konumuna git',
            textEn: 'go to x: 0 y: 0',
            textDe: 'gehe zu x: 0 y: 0',
            textEs: 'ir a x: 0 y: 0'),
        ChoiceOption(
            text: 'x: 200 y: 150 konumuna git',
            textEn: 'go to x: 200 y: 150',
            textDe: 'gehe zu x: 200 y: 150',
            textEs: 'ir a x: 200 y: 150'),
        ChoiceOption(
            text: 'y konumunu 0 değiştir',
            textEn: 'change y by 0',
            textDe: 'ändere y um 0',
            textEs: 'cambiar y por 0'),
      ],
      correctIndex: 1,
      explanation:
          'Sahnenin ortası x: 0, y: 0. x: 200 y: 150 sağ üst köşe; \'y\'yi 0 değiştir\' Devi\'yi hiç oynatmaz.',
      explanationEn:
          'The centre of the stage is x: 0, y: 0. x: 200 y: 150 is the top-right corner; \'change y by 0\' does not move Devi at all.',
      explanationDe:
          'Die Mitte der Bühne ist x: 0, y: 0. x: 200 y: 150 ist die Ecke oben rechts; „ändere y um 0“ bewegt Devi gar nicht.',
      explanationEs:
          'El centro del escenario es x: 0, y: 0. x: 200 y: 150 es la esquina de arriba a la derecha; \'cambiar y por 0\' no mueve a Devi.',
    ),
  ];

  static const List<MultipleChoiceStep> scratch3 = [
    MultipleChoiceStep(
      id: 'tq_s3_1',
      question: 'Bir oyunda \'sürekli tekrarla\' bloğu neden kullanılır?',
      questionEn: 'Why does a game use the \'forever\' block?',
      questionDe: 'Warum benutzt ein Spiel den Block „wiederhole fortlaufend“?',
      questionEs: '¿Por qué un juego usa el bloque \'por siempre\'?',
      options: [
        ChoiceOption(
            text:
                'Oyun boyunca tuşları ve dokunmaları tekrar tekrar kontrol etmek için',
            textEn:
                'To check keys and touches again and again while the game runs',
            textDe:
                'Um während des Spiels immer wieder Tasten und Berührungen zu prüfen',
            textEs:
                'Para comprobar teclas y toques una y otra vez mientras dura el juego'),
        ChoiceOption(
            text: 'Oyunu bir kez çalıştırıp durdurmak için',
            textEn: 'To run the game once and stop',
            textDe: 'Um das Spiel einmal laufen zu lassen und anzuhalten',
            textEs: 'Para ejecutar el juego una vez y parar'),
        ChoiceOption(
            text: 'Devi\'nin kostümünü seçmek için',
            textEn: 'To choose Devi\'s costume',
            textDe: 'Um Devis Kostüm auszuwählen',
            textEs: 'Para elegir el disfraz de Devi'),
        ChoiceOption(
            text: 'Sahnenin rengini değiştirmek için',
            textEn: 'To change the colour of the stage',
            textDe: 'Um die Farbe der Bühne zu ändern',
            textEs: 'Para cambiar el color del escenario'),
      ],
      correctIndex: 0,
      explanation:
          'Oyuncu her an bir tuşa basabilir; kontrol bir kez yapılırsa sonraki basışlar kaçar. Döngü kontrolü oyun boyunca sürdürür.',
      explanationEn:
          'The player can press a key at any moment; checking only once would miss later presses. The loop keeps checking for the whole game.',
      explanationDe:
          'Der Spieler kann jederzeit eine Taste drücken; prüft man nur einmal, verpasst man spätere Drücke. Die Schleife prüft das ganze Spiel lang.',
      explanationEs:
          'El jugador puede pulsar una tecla en cualquier momento; si solo se comprueba una vez, se pierden las siguientes. El bucle sigue comprobando todo el juego.',
    ),
    MultipleChoiceStep(
      id: 'tq_s3_2',
      question:
          'Geri sayımda süre 5\'ten başlıyor ve her saniye 1 azalıyor. 3 saniye sonra süre kaçtır?',
      questionEn:
          'In a countdown the time starts at 5 and drops by 1 every second. What is the time after 3 seconds?',
      questionDe:
          'Beim Countdown beginnt die Zeit bei 5 und sinkt jede Sekunde um 1. Wie viel Zeit ist nach 3 Sekunden übrig?',
      questionEs:
          'En una cuenta atrás el tiempo empieza en 5 y baja 1 cada segundo. ¿Cuánto tiempo queda tras 3 segundos?',
      options: [
        ChoiceOption(text: '3', textEn: '3', textDe: '3', textEs: '3'),
        ChoiceOption(text: '8', textEn: '8', textDe: '8', textEs: '8'),
        ChoiceOption(text: '2', textEn: '2', textDe: '2', textEs: '2'),
        ChoiceOption(text: '0', textEn: '0', textDe: '0', textEs: '0'),
      ],
      correctIndex: 2,
      explanation:
          '5 − 1 − 1 − 1 = 2. \'değiştir\' bloğu her seferinde mevcut değere −1 ekliyor.',
      explanationEn:
          '5 − 1 − 1 − 1 = 2. The \'change\' block adds −1 to the current value each time.',
      explanationDe:
          '5 − 1 − 1 − 1 = 2. Der „ändere“-Block zählt jedes Mal −1 zum aktuellen Wert dazu.',
      explanationEs:
          '5 − 1 − 1 − 1 = 2. El bloque \'sumar\' añade −1 al valor actual cada vez.',
    ),
  ];

  static const List<MultipleChoiceStep> scratch5 = [
    MultipleChoiceStep(
      id: 'tq_s5_1',
      question:
          '\'kendimin ikizini yarat\' bloğu 3 kez çalışırsa sahneye kaç yeni ikiz gelir?',
      questionEn:
          'If \'create clone of myself\' runs 3 times, how many new clones appear?',
      questionDe:
          'Wenn „erzeuge Klon von mir selbst“ dreimal läuft, wie viele neue Klone erscheinen?',
      questionEs:
          'Si \'crear clon de mí mismo\' se ejecuta 3 veces, ¿cuántos clones nuevos aparecen?',
      options: [
        ChoiceOption(text: '1', textEn: '1', textDe: '1', textEs: '1'),
        ChoiceOption(text: '3', textEn: '3', textDe: '3', textEs: '3'),
        ChoiceOption(text: '0', textEn: '0', textDe: '0', textEs: '0'),
        ChoiceOption(text: '6', textEn: '6', textDe: '6', textEs: '6'),
      ],
      correctIndex: 1,
      explanation:
          'Blok her çalıştığında bir ikiz yaratıyor: üç kez, üç ikiz. Asıl kukla da sahnede kalıyor.',
      explanationEn:
          'Each run makes one clone: three runs, three clones. The original sprite stays on the stage too.',
      explanationDe:
          'Jeder Durchlauf erzeugt einen Klon: dreimal, drei Klone. Die Originalfigur bleibt auch auf der Bühne.',
      explanationEs:
          'Cada ejecución crea un clon: tres veces, tres clones. El objeto original también se queda.',
    ),
    MultipleChoiceStep(
      id: 'tq_s5_2',
      question: 'Bir ikiz hangi şapka bloğunun altındaki kodu çalıştırır?',
      questionEn: 'Which hat block\'s code does a clone run?',
      questionDe: 'Den Code unter welchem Hutblock führt ein Klon aus?',
      questionEs: '¿El código de qué bloque de sombrero ejecuta un clon?',
      options: [
        ChoiceOption(
            text: 'yeşil bayrağa tıklandığında',
            textEn: 'when green flag clicked',
            textDe: 'Wenn die grüne Flagge angeklickt wird',
            textEs: 'al hacer clic en la bandera verde'),
        ChoiceOption(
            text: 'bu kuklaya tıklandığında',
            textEn: 'when this sprite clicked',
            textDe: 'Wenn diese Figur angeklickt wird',
            textEs: 'al hacer clic en este objeto'),
        ChoiceOption(
            text: 'ikiz olarak başladığımda',
            textEn: 'when I start as a clone',
            textDe: 'Wenn ich als Klon entstehe',
            textEs: 'al comenzar como clon'),
        ChoiceOption(
            text: 'zıpla haberini aldığımda',
            textEn: 'when I receive jump',
            textDe: 'Wenn ich springen empfange',
            textEs: 'al recibir saltar'),
      ],
      correctIndex: 2,
      explanation:
          'İkiz doğduğu anda \'ikiz olarak başladığımda\' altındaki kod çalışır. Bayrak kodu bir kez, oyunun başında çalışmıştı.',
      explanationEn:
          'The moment a clone is born, the code under \'when I start as a clone\' runs. The flag code already ran once at the start.',
      explanationDe:
          'Sobald ein Klon entsteht, läuft der Code unter „Wenn ich als Klon entstehe“. Der Flaggen-Code lief schon einmal am Anfang.',
      explanationEs:
          'En cuanto nace un clon se ejecuta el código bajo \'al comenzar como clon\'. El de la bandera ya se ejecutó al principio.',
    ),
    MultipleChoiceStep(
      id: 'tq_s5_3',
      question: 'Yere düşen yıldız ikizleri neden silinmeli?',
      questionEn: 'Why should fallen star clones be deleted?',
      questionDe: 'Warum sollte man heruntergefallene Stern-Klone löschen?',
      questionEs:
          '¿Por qué hay que borrar los clones de estrellas que han caído?',
      options: [
        ChoiceOption(
            text: 'Puan sıfırlansın diye',
            textEn: 'So the score resets',
            textDe: 'Damit die Punkte zurückgesetzt werden',
            textEs: 'Para que los puntos vuelvan a cero'),
        ChoiceOption(
            text: 'Asıl kukla da silinsin diye',
            textEn: 'So the original sprite is deleted too',
            textDe: 'Damit auch die Originalfigur gelöscht wird',
            textEs: 'Para que también se borre el objeto original'),
        ChoiceOption(
            text: 'Oyun baştan başlasın diye',
            textEn: 'So the game restarts',
            textDe: 'Damit das Spiel neu startet',
            textEs: 'Para que el juego empiece de nuevo'),
        ChoiceOption(
            text: 'Sahne gereksiz ikizlerle dolup oyun yavaşlamasın diye',
            textEn:
                'So the stage does not fill up with clones and slow the game down',
            textDe:
                'Damit sich die Bühne nicht mit Klonen füllt und das Spiel langsam wird',
            textEs:
                'Para que el escenario no se llene de clones y el juego no se vuelva lento'),
      ],
      correctIndex: 3,
      explanation:
          'İşi biten ikiz silinmezse görünmese bile sahnede kalır. Yüzlerce ikiz birikince oyun yavaşlar; Scratch\'te ikiz sayısının bir sınırı da var.',
      explanationEn:
          'A finished clone that is not deleted stays on the stage even if you cannot see it. Hundreds of them slow the game down, and Scratch has a clone limit too.',
      explanationDe:
          'Ein fertiger Klon, der nicht gelöscht wird, bleibt auf der Bühne, auch wenn man ihn nicht sieht. Hunderte davon machen das Spiel langsam, und Scratch hat auch eine Klon-Grenze.',
      explanationEs:
          'Un clon que ha terminado y no se borra se queda en el escenario aunque no se vea. Cientos de ellos hacen lento el juego, y Scratch también tiene un límite de clones.',
    ),
  ];

  static const List<MultipleChoiceStep> scratch6 = [
    MultipleChoiceStep(
      id: 'tq_s6_1',
      question:
          'Devi \'dans\' haberini salıyor ama hiçbir yerde \'dans haberini aldığımda\' bloğu yok. Ne olur?',
      questionEn:
          'Devi broadcasts \'dance\', but there is no \'when I receive dance\' block anywhere. What happens?',
      questionDe:
          'Devi sendet „Tanz“, aber nirgends gibt es einen Block „Wenn ich Tanz empfange“. Was passiert?',
      questionEs:
          'Devi envía \'baile\', pero no hay ningún bloque \'al recibir baile\'. ¿Qué pasa?',
      options: [
        ChoiceOption(
            text: 'Bütün kuklalar dans eder',
            textEn: 'Every sprite dances',
            textDe: 'Alle Figuren tanzen',
            textEs: 'Todos los objetos bailan'),
        ChoiceOption(
            text: 'Hiçbir şey olmaz; haberi dinleyen yok',
            textEn: 'Nothing happens; nobody is listening',
            textDe: 'Nichts passiert; niemand hört zu',
            textEs: 'No pasa nada; nadie está escuchando'),
        ChoiceOption(
            text: 'Program hata verip durur',
            textEn: 'The program stops with an error',
            textDe: 'Das Programm hält mit einem Fehler an',
            textEs: 'El programa se para con un error'),
        ChoiceOption(
            text: 'Devi kendisi dans etmeye başlar',
            textEn: 'Devi starts dancing by himself',
            textDe: 'Devi fängt selbst an zu tanzen',
            textEs: 'Devi empieza a bailar solo'),
      ],
      correctIndex: 1,
      explanation:
          'Haber salmak bir duyuru gibidir: dinleyen yoksa kimse bir şey yapmaz. Hata da olmaz.',
      explanationEn:
          'A broadcast is like an announcement: if nobody listens, nobody does anything. There is no error either.',
      explanationDe:
          'Eine Nachricht ist wie eine Durchsage: Wenn niemand zuhört, tut niemand etwas. Einen Fehler gibt es auch nicht.',
      explanationEs:
          'Enviar un mensaje es como un anuncio: si nadie escucha, nadie hace nada. Tampoco hay error.',
    ),
    MultipleChoiceStep(
      id: 'tq_s6_2',
      question:
          'Aynı haberi üç kukla dinliyor. Haber salınınca kaç kukla tepki verir?',
      questionEn:
          'Three sprites listen for the same message. How many react when it is broadcast?',
      questionDe:
          'Drei Figuren warten auf dieselbe Nachricht. Wie viele reagieren, wenn sie gesendet wird?',
      questionEs:
          'Tres objetos escuchan el mismo mensaje. ¿Cuántos reaccionan cuando se envía?',
      options: [
        ChoiceOption(text: '1', textEn: '1', textDe: '1', textEs: '1'),
        ChoiceOption(text: '0', textEn: '0', textDe: '0', textEs: '0'),
        ChoiceOption(text: '3', textEn: '3', textDe: '3', textEs: '3'),
        ChoiceOption(
            text: 'Yalnızca haberi salan',
            textEn: 'Only the one that broadcast it',
            textDe: 'Nur die Figur, die gesendet hat',
            textEs: 'Solo el que lo envió'),
      ],
      correctIndex: 2,
      explanation:
          'Haber herkese gider: dinleyen her kukla kendi kodunu aynı anda çalıştırır.',
      explanationEn:
          'A broadcast goes to everyone: every listening sprite runs its own code at the same time.',
      explanationDe:
          'Eine Nachricht geht an alle: Jede Figur, die zuhört, führt gleichzeitig ihren eigenen Code aus.',
      explanationEs:
          'El mensaje llega a todos: cada objeto que escucha ejecuta su propio código a la vez.',
    ),
    MultipleChoiceStep(
      id: 'tq_s6_3',
      question: 'Haber salmak en çok hangi işe yarar?',
      questionEn: 'What is broadcasting mostly used for?',
      questionDe: 'Wofür benutzt man das Senden von Nachrichten vor allem?',
      questionEs: '¿Para qué sirve sobre todo enviar mensajes?',
      options: [
        ChoiceOption(
            text: 'Kuklaların birbirine \'şimdi başla\' demesine',
            textEn: 'Letting sprites tell each other \'start now\'',
            textDe: 'Damit Figuren einander „jetzt los“ sagen',
            textEs: 'Para que los objetos se digan \'empieza ahora\''),
        ChoiceOption(
            text: 'Kuklanın rengini değiştirmeye',
            textEn: 'Changing a sprite\'s colour',
            textDe: 'Die Farbe einer Figur zu ändern',
            textEs: 'Cambiar el color de un objeto'),
        ChoiceOption(
            text: 'Puanı saklamaya',
            textEn: 'Storing the score',
            textDe: 'Die Punkte zu speichern',
            textEs: 'Guardar la puntuación'),
        ChoiceOption(
            text: 'Sesi kısmaya',
            textEn: 'Turning the sound down',
            textDe: 'Den Ton leiser zu machen',
            textEs: 'Bajar el volumen'),
      ],
      correctIndex: 0,
      explanation:
          'Haberler kuklaları birbirine bağlar: biri \'oyun bitti\' der, ötekiler durur. Puanı değişkenler, rengi görünüm blokları tutar.',
      explanationEn:
          'Messages connect sprites: one says \'game over\', the others stop. Variables keep the score; looks blocks change colours.',
      explanationDe:
          'Nachrichten verbinden Figuren: Eine sagt „Spiel vorbei“, die anderen halten an. Punkte speichern Variablen, Farben ändern Aussehen-Blöcke.',
      explanationEs:
          'Los mensajes conectan objetos: uno dice \'fin del juego\' y los demás paran. Los puntos se guardan en variables y el color se cambia con bloques de apariencia.',
    ),
  ];

  static const List<MultipleChoiceStep> scratch7 = [
    MultipleChoiceStep(
      id: 'tq_s7_1',
      question:
          '\'60 notasını çal\' ile \'72 notasını çal\' arasındaki fark nedir?',
      questionEn:
          'What is the difference between \'play note 60\' and \'play note 72\'?',
      questionDe:
          'Was ist der Unterschied zwischen „spiele Ton 60“ und „spiele Ton 72“?',
      questionEs:
          '¿Qué diferencia hay entre \'tocar nota 60\' y \'tocar nota 72\'?',
      options: [
        ChoiceOption(
            text: '72 daha uzun çalar',
            textEn: '72 plays longer',
            textDe: '72 klingt länger',
            textEs: '72 suena más tiempo'),
        ChoiceOption(
            text: '72 daha gür (sesli) çalar',
            textEn: '72 plays louder',
            textDe: '72 klingt lauter',
            textEs: '72 suena más fuerte'),
        ChoiceOption(
            text: 'Hiçbir fark yoktur',
            textEn: 'There is no difference',
            textDe: 'Es gibt keinen Unterschied',
            textEs: 'No hay diferencia'),
        ChoiceOption(
            text: '72 daha ince (yüksek perdeden) bir sestir',
            textEn: '72 is a higher-pitched sound',
            textDe: '72 ist ein höherer Ton',
            textEs: '72 es un sonido más agudo'),
      ],
      correctIndex: 3,
      explanation:
          'Nota numarası sesin perdesini söyler: sayı büyüdükçe ses incelir. 72, 60\'tan tam bir oktav yüksek. Süreyi \'vuruş\' kutusu belirler.',
      explanationEn:
          'The note number sets the pitch: the bigger the number, the higher the sound. 72 is exactly one octave above 60. The \'beats\' box sets the length.',
      explanationDe:
          'Die Tonnummer bestimmt die Tonhöhe: Je größer die Zahl, desto höher der Ton. 72 liegt genau eine Oktave über 60. Die Länge bestimmt das Feld „Schläge“.',
      explanationEs:
          'El número de nota marca la altura: cuanto mayor, más agudo. 72 está justo una octava por encima de 60. La duración la marca la casilla de \'pulsos\'.',
    ),
    MultipleChoiceStep(
      id: 'tq_s7_2',
      question:
          'Üç notalık bir melodiyi iki kez çalmanın en kısa yolu hangisi?',
      questionEn: 'What is the shortest way to play a three-note melody twice?',
      questionDe:
          'Was ist der kürzeste Weg, eine Melodie aus drei Tönen zweimal zu spielen?',
      questionEs:
          '¿Cuál es la forma más corta de tocar dos veces una melodía de tres notas?',
      options: [
        ChoiceOption(
            text: 'Notaları \'2 defa tekrarla\' bloğunun içine koymak',
            textEn: 'Put the notes inside a \'repeat 2\' block',
            textDe: 'Die Töne in einen Block „wiederhole 2 mal“ setzen',
            textEs: 'Poner las notas dentro de un bloque \'repetir 2\''),
        ChoiceOption(
            text: 'Notaları \'sürekli tekrarla\' içine koymak',
            textEn: 'Put the notes inside \'forever\'',
            textDe: 'Die Töne in „wiederhole fortlaufend“ setzen',
            textEs: 'Poner las notas dentro de \'por siempre\''),
        ChoiceOption(
            text: 'Müzik eklentisini iki kez eklemek',
            textEn: 'Add the Music extension twice',
            textDe: 'Die Musik-Erweiterung zweimal hinzufügen',
            textEs: 'Añadir la extensión Música dos veces'),
        ChoiceOption(
            text: 'Yeşil bayrağa iki kez basmak',
            textEn: 'Press the green flag twice',
            textDe: 'Zweimal auf die grüne Flagge drücken',
            textEs: 'Pulsar dos veces la bandera verde'),
      ],
      correctIndex: 0,
      explanation:
          'Tekrarla bloğu notaları iki kez çalıp durur. \'sürekli tekrarla\' hiç durmaz; eklentiyi iki kez eklemek bir şey değiştirmez.',
      explanationEn:
          'The repeat block plays the notes twice and stops. \'forever\' never stops; adding the extension twice changes nothing.',
      explanationDe:
          'Der wiederhole-Block spielt die Töne zweimal und hört auf. „wiederhole fortlaufend“ hört nie auf; die Erweiterung zweimal hinzuzufügen ändert nichts.',
      explanationEs:
          'El bloque repetir toca las notas dos veces y para. \'por siempre\' nunca para; añadir la extensión dos veces no cambia nada.',
    ),
    MultipleChoiceStep(
      id: 'tq_s7_3',
      question: 'Scratch\'te müzik bloklarını görmek için ne yapmalısın?',
      questionEn: 'What do you need to do to see the music blocks in Scratch?',
      questionDe: 'Was musst du tun, um in Scratch die Musik-Blöcke zu sehen?',
      questionEs:
          '¿Qué tienes que hacer para ver los bloques de música en Scratch?',
      options: [
        ChoiceOption(
            text: 'Sahneye çift tıklamak',
            textEn: 'Double-click the stage',
            textDe: 'Doppelt auf die Bühne klicken',
            textEs: 'Hacer doble clic en el escenario'),
        ChoiceOption(
            text: 'Sol alttaki \'Eklenti ekle\' düğmesinden Müzik\'i seçmek',
            textEn:
                'Choose Music with the \'Add Extension\' button in the bottom left',
            textDe: 'Unten links mit „Erweiterung hinzufügen“ Musik auswählen',
            textEs:
                'Elegir Música con el botón \'Añadir extensión\' de abajo a la izquierda'),
        ChoiceOption(
            text: 'Yeni bir kukla eklemek',
            textEn: 'Add a new sprite',
            textDe: 'Eine neue Figur hinzufügen',
            textEs: 'Añadir un objeto nuevo'),
        ChoiceOption(
            text: 'Projeyi kaydetmek',
            textEn: 'Save the project',
            textDe: 'Das Projekt speichern',
            textEs: 'Guardar el proyecto'),
      ],
      correctIndex: 1,
      explanation:
          'Müzik, kalem gibi bir eklenti: palette baştan yok. Eklentiyi ekleyince yeşil Müzik kategorisi gelir.',
      explanationEn:
          'Music is an extension, like the pen: it is not in the palette at first. Add it and the green Music category appears.',
      explanationDe:
          'Musik ist wie der Stift eine Erweiterung: Sie ist nicht von Anfang an in der Palette. Füge sie hinzu, dann erscheint die grüne Kategorie Musik.',
      explanationEs:
          'Música es una extensión, como el lápiz: al principio no está en la paleta. Añádela y aparece la categoría verde Música.',
    ),
  ];

  static const List<MultipleChoiceStep> scratch8 = [
    MultipleChoiceStep(
      id: 'tq_s8_1',
      question:
          'Kalem inikken Devi \'x: 0 y: 0 konumuna git\' bloğuyla ortaya gidiyor. Ne olur?',
      questionEn:
          'With the pen down, Devi uses \'go to x: 0 y: 0\' to reach the centre. What happens?',
      questionDe:
          'Mit eingeschaltetem Stift geht Devi mit „gehe zu x: 0 y: 0“ in die Mitte. Was passiert?',
      questionEs:
          'Con el lápiz bajado, Devi usa \'ir a x: 0 y: 0\' para ir al centro. ¿Qué pasa?',
      options: [
        ChoiceOption(
            text: 'Kalem kendiliğinden kalkar, çizgi olmaz',
            textEn: 'The pen lifts by itself, no line',
            textDe: 'Der Stift geht von selbst aus, keine Linie',
            textEs: 'El lápiz se levanta solo, no hay línea'),
        ChoiceOption(
            text: 'Bütün çizimler silinir',
            textEn: 'All drawings are erased',
            textDe: 'Alle Zeichnungen werden gelöscht',
            textEs: 'Se borran todos los dibujos'),
        ChoiceOption(
            text: 'Bulunduğu yerden ortaya kadar düz bir çizgi çizer',
            textEn: 'It draws a straight line from where it was to the centre',
            textDe:
                'Er zeichnet eine gerade Linie von seinem Platz bis zur Mitte',
            textEs:
                'Dibuja una línea recta desde donde estaba hasta el centro'),
        ChoiceOption(
            text: 'Devi yerinden kıpırdamaz',
            textEn: 'Devi does not move',
            textDe: 'Devi bewegt sich nicht',
            textEs: 'Devi no se mueve'),
      ],
      correctIndex: 2,
      explanation:
          'İnik kalem her harekette iz bırakır; \'konuma git\' de bir hareket. İz bırakmadan gitmek için önce kalemi kaldır.',
      explanationEn:
          'A pen that is down leaves a trail on every move, and \'go to\' is a move too. To travel without a trail, lift the pen first.',
      explanationDe:
          'Ein eingeschalteter Stift hinterlässt bei jeder Bewegung eine Spur, und „gehe zu“ ist auch eine Bewegung. Ohne Spur geht es nur mit ausgeschaltetem Stift.',
      explanationEs:
          'Un lápiz bajado deja rastro en cada movimiento, y \'ir a\' también es un movimiento. Para ir sin rastro, sube antes el lápiz.',
    ),
    MultipleChoiceStep(
      id: 'tq_s8_2',
      question:
          'Altıgen çizmek için döngü kaç kez dönmeli ve her köşede kaç derece dönülmeli?',
      questionEn:
          'To draw a hexagon, how many times does the loop run and how far do you turn at each corner?',
      questionDe:
          'Wie oft läuft die Schleife für ein Sechseck, und wie weit drehst du dich an jeder Ecke?',
      questionEs:
          'Para dibujar un hexágono, ¿cuántas veces da vueltas el bucle y cuánto giras en cada esquina?',
      options: [
        ChoiceOption(
            text: '6 kez, 90 derece',
            textEn: '6 times, 90 degrees',
            textDe: '6-mal, 90 Grad',
            textEs: '6 veces, 90 grados'),
        ChoiceOption(
            text: '4 kez, 60 derece',
            textEn: '4 times, 60 degrees',
            textDe: '4-mal, 60 Grad',
            textEs: '4 veces, 60 grados'),
        ChoiceOption(
            text: '6 kez, 360 derece',
            textEn: '6 times, 360 degrees',
            textDe: '6-mal, 360 Grad',
            textEs: '6 veces, 360 grados'),
        ChoiceOption(
            text: '6 kez, 60 derece',
            textEn: '6 times, 60 degrees',
            textDe: '6-mal, 60 Grad',
            textEs: '6 veces, 60 grados'),
      ],
      correctIndex: 3,
      explanation:
          'Altıgenin 6 kenarı var ve dönüşler toplam 360 eder: 360 ÷ 6 = 60.',
      explanationEn:
          'A hexagon has 6 sides and the turns add up to 360: 360 ÷ 6 = 60.',
      explanationDe:
          'Ein Sechseck hat 6 Seiten, und die Drehungen ergeben zusammen 360: 360 ÷ 6 = 60.',
      explanationEs:
          'Un hexágono tiene 6 lados y los giros suman 360: 360 ÷ 6 = 60.',
    ),
  ];

  static const List<MultipleChoiceStep> scratch9 = [
    MultipleChoiceStep(
      id: 'tq_s9_1',
      question:
          '\'1 ile 10 arasında rastgele bir sayı seç\' hangi sayıyı ASLA veremez?',
      questionEn: 'Which number can \'pick random 1 to 10\' NEVER give?',
      questionDe: 'Welche Zahl kann „Zufallszahl von 1 bis 10“ NIE liefern?',
      questionEs:
          '¿Qué número NUNCA puede dar \'número aleatorio entre 1 y 10\'?',
      options: [
        ChoiceOption(text: '1', textEn: '1', textDe: '1', textEs: '1'),
        ChoiceOption(text: '10', textEn: '10', textDe: '10', textEs: '10'),
        ChoiceOption(text: '11', textEn: '11', textDe: '11', textEs: '11'),
        ChoiceOption(text: '5', textEn: '5', textDe: '5', textEs: '5'),
      ],
      correctIndex: 2,
      explanation: 'Sınırlar dahil: 1 de 10 da çıkabilir. 11 aralığın dışında.',
      explanationEn:
          'Both ends are included: 1 and 10 can come up. 11 is outside the range.',
      explanationDe:
          'Die Grenzen zählen mit: 1 und 10 sind möglich. 11 liegt außerhalb.',
      explanationEs:
          'Los extremos cuentan: pueden salir 1 y 10. 11 está fuera del rango.',
    ),
    MultipleChoiceStep(
      id: 'tq_s9_2',
      question:
          'zar = 4 iken \'eğer zar > 3 ise Kazandın! de, değilse Tekrar dene! de\' ne söyler?',
      questionEn:
          'With dice = 4, what does \'if dice > 3 then say You win!, else say Try again!\' say?',
      questionDe:
          'Bei Würfel = 4: Was sagt „falls Würfel > 3, dann sage Gewonnen!, sonst sage Versuch es nochmal!“?',
      questionEs:
          'Con dado = 4, ¿qué dice \'si dado > 3 entonces di ¡Ganaste!, si no di ¡Inténtalo otra vez!\'?',
      options: [
        ChoiceOption(
            text: 'Tekrar dene!',
            textEn: 'Try again!',
            textDe: 'Versuch es nochmal!',
            textEs: '¡Inténtalo otra vez!'),
        ChoiceOption(
            text: 'Kazandın!',
            textEn: 'You win!',
            textDe: 'Gewonnen!',
            textEs: '¡Ganaste!'),
        ChoiceOption(
            text: 'İkisini de söyler',
            textEn: 'It says both',
            textDe: 'Es sagt beides',
            textEs: 'Dice las dos cosas'),
        ChoiceOption(
            text: 'Hiçbir şey söylemez',
            textEn: 'It says nothing',
            textDe: 'Es sagt nichts',
            textEs: 'No dice nada'),
      ],
      correctIndex: 1,
      explanation:
          '4 > 3 doğru, bu yüzden yalnızca ilk kol çalışır. Eğer-değilse bloğunda iki koldan TAM OLARAK biri çalışır.',
      explanationEn:
          '4 > 3 is true, so only the first branch runs. In an if-else block EXACTLY one of the two branches runs.',
      explanationDe:
          '4 > 3 stimmt, also läuft nur der erste Zweig. Bei falls-sonst läuft GENAU einer der beiden Zweige.',
      explanationEs:
          '4 > 3 es verdad, así que solo se ejecuta la primera rama. En un si-si no se ejecuta EXACTAMENTE una de las dos.',
    ),
  ];

  static const List<MultipleChoiceStep> scratch10 = [
    MultipleChoiceStep(
      id: 'tq_s10_1',
      question:
          'Liste [elma, muz, süt]. \'alışveriş in 1 ini sil\' çalışınca liste ne olur?',
      questionEn:
          'The list is [apple, banana, milk]. After \'delete 1 of shopping\', what is the list?',
      questionDe:
          'Die Liste ist [Apfel, Banane, Milch]. Wie sieht sie nach „lösche 1 von Einkauf“ aus?',
      questionEs:
          'La lista es [manzana, plátano, leche]. Tras \'borrar 1 de compra\', ¿cómo queda?',
      options: [
        ChoiceOption(
            text: '[elma, muz]',
            textEn: '[apple, banana]',
            textDe: '[Apfel, Banane]',
            textEs: '[manzana, plátano]'),
        ChoiceOption(
            text: '[elma, süt]',
            textEn: '[apple, milk]',
            textDe: '[Apfel, Milch]',
            textEs: '[manzana, leche]'),
        ChoiceOption(text: '[ ]', textEn: '[ ]', textDe: '[ ]', textEs: '[ ]'),
        ChoiceOption(
            text: '[muz, süt]',
            textEn: '[banana, milk]',
            textDe: '[Banane, Milch]',
            textEs: '[plátano, leche]'),
      ],
      correctIndex: 3,
      explanation:
          '1, listenin İLK öğesi demek: elma çıkar, geri kalanlar bir sıra yukarı kayar.',
      explanationEn:
          '1 means the FIRST item: apple goes, and the rest move up one place.',
      explanationDe:
          '1 heißt das ERSTE Element: Apfel fliegt raus, der Rest rückt einen Platz nach vorn.',
      explanationEs:
          '1 significa el PRIMER elemento: sale manzana y los demás suben un puesto.',
    ),
    MultipleChoiceStep(
      id: 'tq_s10_2',
      question:
          'Boş bir listeye 4 şey eklenip sonra 1 tanesi silinirse listenin uzunluğu kaç olur?',
      questionEn:
          'You add 4 things to an empty list and then delete 1. What is the length of the list?',
      questionDe:
          'Du fügst einer leeren Liste 4 Dinge hinzu und löschst dann 1. Wie lang ist die Liste?',
      questionEs:
          'Añades 4 cosas a una lista vacía y luego borras 1. ¿Qué longitud tiene la lista?',
      options: [
        ChoiceOption(text: '3', textEn: '3', textDe: '3', textEs: '3'),
        ChoiceOption(text: '4', textEn: '4', textDe: '4', textEs: '4'),
        ChoiceOption(text: '5', textEn: '5', textDe: '5', textEs: '5'),
        ChoiceOption(text: '1', textEn: '1', textDe: '1', textEs: '1'),
      ],
      correctIndex: 0,
      explanation:
          '4 − 1 = 3. \'uzunluğu\' bloğu listede o an kaç öğe olduğunu söyler.',
      explanationEn:
          '4 − 1 = 3. The \'length\' block tells how many items are in the list right now.',
      explanationDe:
          '4 − 1 = 3. Der Block „Länge“ sagt, wie viele Elemente gerade in der Liste sind.',
      explanationEs:
          '4 − 1 = 3. El bloque \'longitud\' dice cuántos elementos hay ahora en la lista.',
    ),
  ];

  static const List<MultipleChoiceStep> scratch11 = [
    MultipleChoiceStep(
      id: 'tq_s11_1',
      question: 'Kendi bloğunu tanımlamanın en büyük faydası nedir?',
      questionEn: 'What is the biggest benefit of defining your own block?',
      questionDe:
          'Was ist der größte Vorteil, einen eigenen Block zu definieren?',
      questionEs: '¿Cuál es la mayor ventaja de definir tu propio bloque?',
      options: [
        ChoiceOption(
            text: 'Programı yavaşlatmak',
            textEn: 'Making the program slower',
            textDe: 'Das Programm langsamer zu machen',
            textEs: 'Hacer el programa más lento'),
        ChoiceOption(
            text: 'Aynı kodu tekrar yazmadan tek bir blokla kullanmak',
            textEn:
                'Using the same code with one block instead of writing it again',
            textDe:
                'Denselben Code mit einem Block zu benutzen, statt ihn neu zu schreiben',
            textEs:
                'Usar el mismo código con un solo bloque en lugar de escribirlo otra vez'),
        ChoiceOption(
            text: 'Yeşil bayrağa gerek bırakmamak',
            textEn: 'Not needing the green flag any more',
            textDe: 'Die grüne Flagge nicht mehr zu brauchen',
            textEs: 'No necesitar más la bandera verde'),
        ChoiceOption(
            text: 'Kuklanın rengini değiştirmek',
            textEn: 'Changing the sprite\'s colour',
            textDe: 'Die Farbe der Figur zu ändern',
            textEs: 'Cambiar el color del objeto'),
      ],
      correctIndex: 1,
      explanation:
          'Tarifi bir kez yazarsın, sonra adıyla istediğin kadar çağırırsın. Değiştirmen gerekirse tek bir yeri değiştirirsin.',
      explanationEn:
          'You write the recipe once and call it by name as often as you like. If it needs changing, you change one place.',
      explanationDe:
          'Du schreibst das Rezept einmal und rufst es beliebig oft beim Namen auf. Musst du etwas ändern, änderst du eine Stelle.',
      explanationEs:
          'Escribes la receta una vez y la llamas por su nombre las veces que quieras. Si hay que cambiarla, cambias un solo sitio.',
    ),
    MultipleChoiceStep(
      id: 'tq_s11_2',
      question:
          '\'çokgen (kenar)\' bloğu \'çokgen 5\' diye çağrılırsa ne çizer?',
      questionEn:
          'If the \'polygon (sides)\' block is called as \'polygon 5\', what does it draw?',
      questionDe:
          'Was zeichnet der Block „Vieleck (Seiten)“, wenn er als „Vieleck 5“ aufgerufen wird?',
      questionEs:
          'Si el bloque \'polígono (lados)\' se llama como \'polígono 5\', ¿qué dibuja?',
      options: [
        ChoiceOption(
            text: 'Kare',
            textEn: 'A square',
            textDe: 'Ein Quadrat',
            textEs: 'Un cuadrado'),
        ChoiceOption(
            text: 'Altıgen',
            textEn: 'A hexagon',
            textDe: 'Ein Sechseck',
            textEs: 'Un hexágono'),
        ChoiceOption(
            text: 'Beşgen',
            textEn: 'A pentagon',
            textDe: 'Ein Fünfeck',
            textEs: 'Un pentágono'),
        ChoiceOption(
            text: 'Hiçbir şey',
            textEn: 'Nothing',
            textDe: 'Nichts',
            textEs: 'Nada'),
      ],
      correctIndex: 2,
      explanation:
          'Çağrıdaki 5, tanımdaki \'kenar\' girdisine geçer: döngü 5 kez döner ve her köşede 360 ÷ 5 = 72 derece dönülür.',
      explanationEn:
          'The 5 in the call goes into the \'sides\' input of the definition: the loop runs 5 times and turns 360 ÷ 5 = 72 degrees at each corner.',
      explanationDe:
          'Die 5 im Aufruf landet in der Eingabe „Seiten“ der Definition: Die Schleife läuft 5-mal und dreht sich an jeder Ecke um 360 ÷ 5 = 72 Grad.',
      explanationEs:
          'El 5 de la llamada pasa a la entrada \'lados\' de la definición: el bucle da 5 vueltas y gira 360 ÷ 5 = 72 grados en cada esquina.',
    ),
  ];

  static const List<MultipleChoiceStep> mblock3 = [
    MultipleChoiceStep(
      id: 'tq_m3_1',
      question: '\'dijital ayarla pin 9 çıkış yüksek\' bloğu ne yapar?',
      questionEn: 'What does \'set digital pin 9 output as high\' do?',
      questionDe: 'Was macht „digitalen Pin von Ausgang 9 als hoch setzen“?',
      questionEs: '¿Qué hace \'pon el pin digital 9 a alto\'?',
      options: [
        ChoiceOption(
            text: 'Pin 9\'daki LED\'i söndürür',
            textEn: 'Turns off the LED on pin 9',
            textDe: 'Schaltet die LED an Pin 9 aus',
            textEs: 'Apaga el LED del pin 9'),
        ChoiceOption(
            text: 'Pin 9\'u okur',
            textEn: 'Reads pin 9',
            textDe: 'Liest Pin 9',
            textEs: 'Lee el pin 9'),
        ChoiceOption(
            text: 'Pin 9\'daki LED\'i yakar',
            textEn: 'Turns on the LED on pin 9',
            textDe: 'Schaltet die LED an Pin 9 ein',
            textEs: 'Enciende el LED del pin 9'),
        ChoiceOption(
            text: 'Kartı yeniden başlatır',
            textEn: 'Restarts the board',
            textDe: 'Startet die Platine neu',
            textEs: 'Reinicia la placa'),
      ],
      correctIndex: 2,
      explanation:
          '\'Yüksek\' pine elektrik verir ve bağlı LED yanar; \'düşük\' keser. Okumak için \'dijital oku\' bloğu var.',
      explanationEn:
          '\'High\' sends power to the pin and the LED lights up; \'low\' cuts it. Reading uses the \'read digital\' block.',
      explanationDe:
          '„Hoch“ schaltet Strom auf den Pin und die LED leuchtet; „niedrig“ schaltet ihn ab. Zum Lesen gibt es „Digitalpin lesen“.',
      explanationEs:
          '\'Alto\' da corriente al pin y el LED se enciende; \'bajo\' la corta. Para leer está el bloque \'lee pin digital\'.',
    ),
    MultipleChoiceStep(
      id: 'tq_m3_2',
      question:
          'Yanıp sönen LED programından iki bekleme bloğu da silinirse ne görürsün?',
      questionEn:
          'If both wait blocks are removed from the blinking LED program, what do you see?',
      questionDe:
          'Was siehst du, wenn beide Warte-Blöcke aus dem Blink-Programm gelöscht werden?',
      questionEs:
          'Si quitas los dos bloques de esperar del programa del LED que parpadea, ¿qué ves?',
      options: [
        ChoiceOption(
            text: 'LED tamamen söner',
            textEn: 'The LED turns off completely',
            textDe: 'Die LED geht ganz aus',
            textEs: 'El LED se apaga del todo'),
        ChoiceOption(
            text: 'LED çok yavaş yanıp söner',
            textEn: 'The LED blinks very slowly',
            textDe: 'Die LED blinkt sehr langsam',
            textEs: 'El LED parpadea muy despacio'),
        ChoiceOption(
            text: 'Kart kapanır',
            textEn: 'The board switches off',
            textDe: 'Die Platine schaltet sich aus',
            textEs: 'La placa se apaga'),
        ChoiceOption(
            text:
                'LED hep yanık gibi görünür; göz bu kadar hızlı yanıp sönmeyi yakalayamaz',
            textEn:
                'The LED seems on all the time; your eye cannot catch such fast blinking',
            textDe:
                'Die LED scheint immer an; das Auge erkennt so schnelles Blinken nicht',
            textEs:
                'El LED parece encendido todo el rato; el ojo no ve un parpadeo tan rápido'),
      ],
      correctIndex: 3,
      explanation:
          'Kart saniyede binlerce kez yakıp söndürür; gözümüz bunu sürekli bir ışık olarak görür. Bekleme, yanıp sönmeyi görünür kılar.',
      explanationEn:
          'The board switches it thousands of times a second; our eyes see a steady light. The waits make the blinking visible.',
      explanationDe:
          'Die Platine schaltet tausende Male pro Sekunde; unser Auge sieht ein Dauerlicht. Erst das Warten macht das Blinken sichtbar.',
      explanationEs:
          'La placa lo enciende y apaga miles de veces por segundo; el ojo ve una luz fija. Las esperas hacen visible el parpadeo.',
    ),
  ];

  static const List<MultipleChoiceStep> mblock5 = [
    MultipleChoiceStep(
      id: 'tq_m5_1',
      question:
          'Mesafe sensörü 12 cm ölçüyor. \'<mesafe < 30>\' koşulu ne olur?',
      questionEn:
          'The distance sensor measures 12 cm. What is the condition \'<distance < 30>\'?',
      questionDe:
          'Der Abstandssensor misst 12 cm. Was ergibt die Bedingung „<Abstand < 30>“?',
      questionEs:
          'El sensor de distancia mide 12 cm. ¿Qué vale la condición \'<distancia < 30>\'?',
      options: [
        ChoiceOption(
            text: 'Yanlış', textEn: 'False', textDe: 'Falsch', textEs: 'Falso'),
        ChoiceOption(
            text: 'Doğru', textEn: 'True', textDe: 'Wahr', textEs: 'Verdadero'),
        ChoiceOption(
            text: 'Hata verir',
            textEn: 'It gives an error',
            textDe: 'Es gibt einen Fehler',
            textEs: 'Da un error'),
        ChoiceOption(
            text: '30 olur',
            textEn: 'It becomes 30',
            textDe: 'Es wird 30',
            textEs: 'Se convierte en 30'),
      ],
      correctIndex: 1,
      explanation:
          '12, 30\'dan küçük; altıgen blok \'doğru\' der ve \'eğer\'in içi çalışır.',
      explanationEn:
          '12 is less than 30, so the hexagon block says \'true\' and the inside of \'if\' runs.',
      explanationDe:
          '12 ist kleiner als 30, also sagt der Sechseck-Block „wahr“ und das Innere von „falls“ läuft.',
      explanationEs:
          '12 es menor que 30, así que el bloque hexagonal dice \'verdadero\' y se ejecuta el interior del \'si\'.',
    ),
    MultipleChoiceStep(
      id: 'tq_m5_2',
      question: 'Servo motora \'açı 180\' yazarsan ne olur?',
      questionEn: 'What happens if you set a servo to \'angle 180\'?',
      questionDe: 'Was passiert, wenn du ein Servo auf „Winkel 180“ setzt?',
      questionEs: '¿Qué pasa si pones un servo en \'ángulo 180\'?',
      options: [
        ChoiceOption(
            text: 'Durmadan döner',
            textEn: 'It spins without stopping',
            textDe: 'Es dreht sich ohne Pause',
            textEs: 'Gira sin parar'),
        ChoiceOption(
            text: 'Kol 180 dereceye döner ve orada durur',
            textEn: 'The arm turns to 180 degrees and stays there',
            textDe: 'Der Arm dreht auf 180 Grad und bleibt dort',
            textEs: 'El brazo gira hasta 180 grados y se queda ahí'),
        ChoiceOption(
            text: 'Hızlanır',
            textEn: 'It speeds up',
            textDe: 'Es wird schneller',
            textEs: 'Se acelera'),
        ChoiceOption(
            text: 'Hiç hareket etmez',
            textEn: 'It does not move at all',
            textDe: 'Es bewegt sich gar nicht',
            textEs: 'No se mueve'),
      ],
      correctIndex: 1,
      explanation:
          'Servo bir AÇIYA gider ve orada durur (0-180 arası). Sürekli dönen, normal bir motordur.',
      explanationEn:
          'A servo goes to an ANGLE and stays there (between 0 and 180). A normal motor is the one that keeps spinning.',
      explanationDe:
          'Ein Servo fährt auf einen WINKEL und bleibt dort (zwischen 0 und 180). Dauerhaft dreht sich ein normaler Motor.',
      explanationEs:
          'Un servo va a un ÁNGULO y se queda ahí (entre 0 y 180). El que gira sin parar es un motor normal.',
    ),
  ];
}
