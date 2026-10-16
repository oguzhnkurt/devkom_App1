import '../models/interactive_lesson_model.dart';
import '../yurutme/atolye_hedefleri.dart';
import '../yurutme/blok_yorumlayici.dart';
import 'kod_bloklari_seviyeleri.dart';
import 'scratch_atolye_bloklari.dart';

/// Scratch kursunun PROJE ATOLYELERI.
///
/// Eskiden 2.1, 3.1, 4.2, 5.1, 6.1 ve 7.1'deki projeler "bilgisayarinda
/// yap, sonra isaretle" diyordu; 8-11. modullerin hic projesi yoktu.
/// Her atolye uygulamanin kendi yorumlayicisiyla CALISAN bir proje:
/// hedefler blok sirasina degil sonuca bakiyor (bkz. AtolyeHedefi).
///
/// 3.1 ve 5.1 GERCEK OYUNLAR (proje motoru, bkz. proje_motoru.dart):
/// sahnede hazir kodlu ikinci bir kukla var (kacan Fare, oklarla giden
/// Kase), betikler ayni anda calisiyor, "degiyor mu?" olculuyor, 5.1'de
/// elmalar ikiz.
///
/// Her atolyenin [ProjeAtolyesiStep.ornekCozum]u test edildi: o kod
/// calisinca butun hedefler sagliyor (test/proje_atolyesi_test.dart).
class ScratchAtolyeleri {
  ScratchAtolyeleri._();


  // ------------------------------------------------------------- 2.1
  static final tuslarlaDevi = ProjeAtolyesiStep(
    id: 's2_1_atolye',
    title: 'Proje: Tuşlarla Devi',
    titleEn: 'Project: Devi on the Keys',
    titleDe: 'Projekt: Devi mit Tasten',
    titleEs: 'Proyecto: Devi con teclas',
    description: 'Bir oyunun ilk adımı: Devi bayrakla selam versin, '
        'sağ ok tuşu onu yürütsün, boşluk tuşu zıplatsın. Her olay için '
        'ayrı bir şapka bloğu kullan.',
    descriptionEn: 'The first step of a game: Devi says hi on the flag, the '
        'right arrow walks him, the space key makes him jump. Use a separate '
        'hat block for each event.',
    descriptionDe: 'Der erste Schritt eines Spiels: Devi grüßt bei der Flagge, '
        'Pfeil nach rechts lässt ihn laufen, die Leertaste lässt ihn springen. '
        'Nimm für jedes Ereignis einen eigenen Hutblock.',
    descriptionEs: 'El primer paso de un juego: Devi saluda con la bandera, la '
        'flecha derecha lo hace andar y la barra espaciadora lo hace saltar. '
        'Usa un bloque de sombrero distinto para cada evento.',
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.sagTus,
      AtolyeBloklari.bosluktaTus,
      AtolyeBloklari.ortayaGit,
      AtolyeBloklari.merhabaDe,
      AtolyeBloklari.xDegistir,
      AtolyeBloklari.yYukari,
      AtolyeBloklari.tekrarla('10'),
      AtolyeBloklari.bekle1,
    ],
    sayiDuzenlenebilir: {'change_x', 'change_y_up', 'repeat_10'},
    hedefler: const [
      SoylediHedefi(
        metin: 'Yeşil bayrağa basınca Devi "Merhaba!" desin',
        metinEn: 'When the green flag is pressed, Devi says "Hello!"',
        metinDe: 'Bei der grünen Flagge sagt Devi „Hallo!“',
        metinEs: 'Al pulsar la bandera verde, Devi dice "¡Hola!"',
        bloklar: {'say_hello'},
      ),
      OlayHedefi(
        metin: 'Sağ ok tuşu Devi\'yi sağa yürütsün',
        metinEn: 'The right arrow key walks Devi to the right',
        metinDe: 'Pfeil nach rechts lässt Devi nach rechts laufen',
        metinEs: 'La flecha derecha lleva a Devi a la derecha',
        olay: 'tus:right',
        bloklar: {'change_x'},
      ),
      KonumHedefi(
        metin: 'Devi sonunda sahnenin sağında olsun (x en az 50)',
        metinEn: 'Devi ends on the right of the stage (x at least 50)',
        metinDe: 'Devi steht am Ende rechts auf der Bühne (x mindestens 50)',
        metinEs: 'Devi termina a la derecha del escenario (x al menos 50)',
        xEnAz: 50,
      ),
      OlayHedefi(
        metin: 'Boşluk tuşu Devi\'yi zıplatsın',
        metinEn: 'The space key makes Devi jump',
        metinDe: 'Die Leertaste lässt Devi springen',
        metinEs: 'La barra espaciadora hace saltar a Devi',
        olay: 'tus:space',
        bloklar: {'change_y_up'},
      ),
    ],
    ornekCozum: 'green_flag goto_center say_hello '
        'when_key_right repeat_10=5 change_x } '
        'when_key_space change_y_up=50',
    ipucu: 'Her tuşun kendi şapka bloğu var: "sağ ok tuşuna basılınca" '
        'bloğunun ALTINA x\'i değiştiren bloğu tak. Sarı halkalı sayıya '
        'dokunup büyütebilirsin.',
    ipucuEn: 'Every key has its own hat block: attach the block that changes '
        'x UNDER "when right arrow key pressed". Tap a number with a yellow '
        'ring to make it bigger.',
    ipucuDe: 'Jede Taste hat ihren eigenen Hutblock: Häng den Block, der x '
        'ändert, UNTER „Wenn Taste Pfeil nach rechts gedrückt wird“. Tippe '
        'auf eine Zahl mit gelbem Ring, um sie zu vergrößern.',
    ipucuEs: 'Cada tecla tiene su propio bloque de sombrero: engancha el '
        'bloque que cambia x DEBAJO de "al presionar tecla flecha derecha". '
        'Toca un número con anillo amarillo para hacerlo más grande.',
    bilgisayarNotu: 'Scratch\'te sol ve aşağı ok için de birer betik ekle; '
        'Devi dört yönde gezsin.',
    bilgisayarNotuEn: 'In Scratch, add scripts for the left and down arrows '
        'too, so Devi can walk in all four directions.',
    bilgisayarNotuDe: 'Füge in Scratch auch Skripte für Pfeil nach links und '
        'nach unten hinzu, damit Devi in alle vier Richtungen läuft.',
    bilgisayarNotuEs: 'En Scratch, añade también guiones para las flechas '
        'izquierda y abajo, para que Devi ande en las cuatro direcciones.',
    xpReward: 30,
  );

  // ------------------------------------------------------------- 3.1
  /// Kacan fare: hazir kodu var, cocuk degistirmiyor. Capraz gidiyor,
  /// kenarlardan sekiyor; Devi'ye degince rastgele bir yere kaciyor.
  static final fare = KuklaTanimi(
    ad: 'Fare',
    adEn: 'Mouse',
    adDe: 'Maus',
    adEs: 'Ratón',
    gorunum: KuklaGorunumu.fare,
    x: 100,
    y: 50,
    yaricap: 18,
    donusStili: DonusStili.solSag,
    kod: 'green_flag goto_100_50 point_55 forever move_10=3 edge_bounce '
        'if_touching_cat goto_random } }',
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.git100_50,
      AtolyeBloklari.yon55,
      AtolyeBloklari.surekli,
      AtolyeBloklari.git10,
      AtolyeBloklari.kenardaSek,
      AtolyeBloklari.egerDeviyeDegiyor,
      AtolyeBloklari.rastgeleGit,
    ],
  );

  static final yakalaOyunu = ProjeAtolyesiStep(
    id: 's3_1_atolye',
    title: 'Proje: Yakala!',
    titleEn: 'Project: Catch!',
    titleDe: 'Projekt: Fang!',
    titleEs: 'Proyecto: ¡Atrápalo!',
    description: 'Sahnede kaçan bir Fare var. Devi onu kovalasın: sürekli '
        'Fare\'ye doğru dönüp yürüsün. Her dokunuşta puan bir artsın; puan '
        '5 olunca Devi puanı söylesin ve oyun dursun.',
    descriptionEn: 'A Mouse is running around the stage. Devi chases it: '
        'forever turning towards the Mouse and walking. Every touch adds a '
        'point; at 5 points Devi says the score and the game stops.',
    descriptionDe: 'Auf der Bühne läuft eine Maus herum. Devi jagt sie: '
        'immer wieder zur Maus drehen und laufen. Jede Berührung gibt einen '
        'Punkt; bei 5 Punkten sagt Devi die Punktzahl und das Spiel stoppt.',
    descriptionEs: 'Un Ratón corre por el escenario. Devi lo persigue: '
        'siempre gira hacia el Ratón y camina. Cada toque suma un punto; con '
        '5 puntos Devi dice la puntuación y el juego se detiene.',
    anaKukla: const KuklaTanimi(
        ad: 'Devi', x: -120, y: -40, donusStili: DonusStili.solSag),
    kuklalar: [fare],
    sureSiniri: 40,
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.puanSifir,
      AtolyeBloklari.ortayaGit,
      AtolyeBloklari.surekli,
      AtolyeBloklari.fareyeYonel,
      AtolyeBloklari.git10,
      AtolyeBloklari.egerDokunuyor,
      AtolyeBloklari.puanArtir,
      AtolyeBloklari.egerPuan5,
      AtolyeBloklari.puaniDe,
      AtolyeBloklari.hepsiniDurdur,
      AtolyeBloklari.rastgeleGit,
    ],
    sayiDuzenlenebilir: {'move_10', 'change_score'},
    hedefler: const [
      CalistiHedefi(
        metin: 'Oyun başlarken puanı sıfırla',
        metinEn: 'Reset the score when the game starts',
        metinDe: 'Setze die Punkte beim Spielstart auf null',
        metinEs: 'Pon los puntos a cero al empezar',
        bloklar: {'set_score_0'},
      ),
      VeHedefi(
        metin: 'Devi sürekli Fare\'ye dönüp onu kovalasın',
        metinEn: 'Devi keeps turning towards the Mouse and chasing it',
        metinDe: 'Devi dreht sich immer wieder zur Maus und jagt sie',
        metinEs: 'Devi gira siempre hacia el Ratón y lo persigue',
        hepsi: [
          BlokHedefi(
              metin: '',
              metinEn: '',
              metinDe: '',
              metinEs: '',
              bloklar: {'forever'}),
          CalistiHedefi(
              metin: '',
              metinEn: '',
              metinDe: '',
              metinEs: '',
              bloklar: {'point_towards_mouse'},
              enAz: 10),
        ],
      ),
      DegiskenHedefi(
        metin: 'Fare\'yi 5 kez yakala: puan 5 olsun',
        metinEn: 'Catch the Mouse 5 times: the score reaches 5',
        metinDe: 'Fang die Maus 5-mal: es werden 5 Punkte',
        metinEs: 'Atrapa al Ratón 5 veces: llega a 5 puntos',
        ad: 'Puan',
        islem: '>=',
        deger: 5,
      ),
      VeHedefi(
        metin: 'Puan 5 olunca Devi puanı söylesin ve oyun dursun',
        metinEn: 'At 5 points Devi says the score and the game stops',
        metinDe: 'Bei 5 Punkten sagt Devi die Punktzahl und das Spiel stoppt',
        metinEs: 'Con 5 puntos Devi dice la puntuación y el juego se detiene',
        hepsi: [
          SoylediHedefi(
              metin: '',
              metinEn: '',
              metinDe: '',
              metinEs: '',
              bloklar: {'say_score'}),
          DurduHedefi(metin: '', metinEn: '', metinDe: '', metinEs: ''),
        ],
      ),
    ],
    ornekCozum: 'green_flag set_score_0 goto_center forever '
        'point_towards_mouse move_10=6 if_touching change_score } '
        'if_score_5 say_score stop_all } }',
    ipucu: 'Kovalamak "sürekli tekrarla"nın İÇİNDE: Fare\'ye doğru yönel, '
        'birkaç adım git, Fare\'ye değiyorsa puanı artır. Puan 5 olunca puanı '
        'söyle ve tümünü durdur. Devi Fare\'den hızlı olsun: adım sayısını '
        'büyüt.',
    ipucuEn: 'The chase goes INSIDE "forever": point towards the Mouse, move '
        'a few steps, and if touching the Mouse add a point. At 5 points say '
        'the score and stop all. Devi must be faster than the Mouse: make the '
        'steps bigger.',
    ipucuDe: 'Die Jagd gehört IN „wiederhole fortlaufend“: zur Maus drehen, '
        'ein paar Schritte gehen, und wenn die Maus berührt wird, einen Punkt '
        'dazu. Bei 5 Punkten die Punkte sagen und alles stoppen. Devi muss '
        'schneller sein als die Maus: mach die Schritte größer.',
    ipucuEs: 'La persecución va DENTRO de "por siempre": apunta hacia el '
        'Ratón, mueve unos pasos y, si tocas al Ratón, suma un punto. Con 5 '
        'puntos di la puntuación y detén todo. Devi debe ser más rápido que '
        'el Ratón: haz los pasos más grandes.',
    bilgisayarNotu: 'Scratch\'te bir süre sayacı ekle: 30 saniyede Fare\'yi '
        'kaç kez yakalayabiliyorsun?',
    bilgisayarNotuEn: 'In Scratch, add a timer: how many times can you catch '
        'the Mouse in 30 seconds?',
    bilgisayarNotuDe: 'Füge in Scratch einen Timer hinzu: Wie oft fängst du '
        'die Maus in 30 Sekunden?',
    bilgisayarNotuEs: 'En Scratch, añade un temporizador: ¿cuántas veces '
        'atrapas al Ratón en 30 segundos?',
    xpReward: 50,
  );

  // ------------------------------------------------------------- 4.2
  static final yildizToplayici = ProjeAtolyesiStep(
    id: 's4_2_atolye',
    title: 'Proje: Yıldız Toplayıcı',
    titleEn: 'Project: Star Collector',
    titleDe: 'Projekt: Sternensammler',
    titleEs: 'Proyecto: Recolector de estrellas',
    description: 'Devi beş yıldız topluyor ve her yıldız 10 puan '
        'getiriyor. Puan 50 olunca Devi "Kazandın!" desin.',
    descriptionEn: 'Devi collects five stars and every star is worth 10 '
        'points. When the score is 50, Devi says "You win!".',
    descriptionDe: 'Devi sammelt fünf Sterne, jeder Stern bringt 10 Punkte. '
        'Bei 50 Punkten sagt Devi „Gewonnen!“.',
    descriptionEs: 'Devi recoge cinco estrellas y cada una vale 10 puntos. '
        'Cuando hay 50 puntos, Devi dice "¡Ganaste!".',
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.puanSifir,
      AtolyeBloklari.tekrarla('5'),
      AtolyeBloklari.puanArtir,
      AtolyeBloklari.egerPuan50,
      AtolyeBloklari.kazandinDe,
      AtolyeBloklari.puaniDe,
      AtolyeBloklari.bekle1,
    ],
    sayiDuzenlenebilir: {'change_score', 'repeat_5'},
    hedefler: const [
      BlokHedefi(
        metin: 'Yıldız toplamayı bir döngüyle tekrarla',
        metinEn: 'Repeat the star collecting with a loop',
        metinDe: 'Wiederhole das Sternesammeln mit einer Schleife',
        metinEs: 'Repite la recogida de estrellas con un bucle',
        bloklar: {'repeat_5'},
      ),
      DegiskenHedefi(
        metin: 'Her yıldız 10 puan versin: puan 50 olsun',
        metinEn: 'Each star gives 10 points: the score reaches 50',
        metinDe: 'Jeder Stern gibt 10 Punkte: es werden 50 Punkte',
        metinEs: 'Cada estrella da 10 puntos: se llega a 50',
        ad: 'Puan',
        islem: '=',
        deger: 50,
      ),
      SoylediHedefi(
        metin: 'Puan 50 olunca Devi "Kazandın!" desin',
        metinEn: 'At 50 points Devi says "You win!"',
        metinDe: 'Bei 50 Punkten sagt Devi „Gewonnen!“',
        metinEs: 'Con 50 puntos Devi dice "¡Ganaste!"',
        bloklar: {'say_win'},
      ),
    ],
    ornekCozum: 'green_flag set_score_0 repeat_5 change_score=10 } '
        'if_score_50 say_win }',
    ipucu: 'Puanı artıran bloğun sayısına dokun. "eğer" bloğunu döngünün '
        'ALTINA koy, içine değil: önce bütün yıldızlar toplanmalı.',
    ipucuEn: 'Tap the number on the block that adds points. Put the "if" '
        'block UNDER the loop, not inside it: all the stars come first.',
    ipucuDe: 'Tippe auf die Zahl im Block, der Punkte dazuzählt. Setz den '
        '„falls“-Block UNTER die Schleife, nicht hinein: erst alle Sterne.',
    ipucuEs: 'Toca el número del bloque que suma puntos. Pon el bloque "si" '
        'DEBAJO del bucle, no dentro: primero todas las estrellas.',
    bilgisayarNotu: 'Scratch\'te yıldızı ayrı bir kukla yap; Devi ona '
        'değince puan artsın.',
    bilgisayarNotuEn: 'In Scratch, make the star its own sprite; touching it '
        'adds to the score.',
    bilgisayarNotuDe: 'Mach in Scratch den Stern zu einer eigenen Figur; '
        'berührt Devi ihn, steigen die Punkte.',
    bilgisayarNotuEs: 'En Scratch, haz de la estrella un objeto; si Devi la '
        'toca, suben los puntos.',
    xpReward: 40,
  );

  // ------------------------------------------------------------- 5.1
  /// Elmalari tutan kase: hazir kodu var; oklarla sola-saga gidiyor.
  static final kase = KuklaTanimi(
    ad: 'Kase',
    adEn: 'Bowl',
    adDe: 'Schüssel',
    adEs: 'Cuenco',
    gorunum: KuklaGorunumu.kase,
    x: 0,
    y: -125,
    yaricap: 28,
    renk: 'kase',
    kod: 'green_flag goto_bottom forever if_right change_x=8 } '
        'if_left change_x=-8 } }',
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.asagiyaGit,
      AtolyeBloklari.surekli,
      AtolyeBloklari.egerSag,
      AtolyeBloklari.egerSol,
      AtolyeBloklari.xDegistir,
    ],
  );

  static final elmaYagmuru = ProjeAtolyesiStep(
    id: 's5_1_atolye',
    title: 'Proje: Elma Yağmuru',
    titleEn: 'Project: Apple Rain',
    titleDe: 'Projekt: Apfelregen',
    titleEs: 'Proyecto: Lluvia de manzanas',
    description: 'Gökten elmalar yağsın! Elma kuklası kendinin ikizlerini '
        'yaratsın; her ikiz tepeden düşsün. Kaseye düşen elma puan '
        'kazandırsın, yeşil yere düşen kaybolsun. Kaseyi ok tuşlarıyla sen '
        'yönet.',
    descriptionEn: 'Apples rain from the sky! The Apple sprite creates clones '
        'of itself and each clone falls from the top. An apple in the Bowl '
        'scores a point; one that hits the green ground disappears. You steer '
        'the Bowl with the arrow keys.',
    descriptionDe: 'Es regnet Äpfel! Die Apfel-Figur erzeugt Klone von sich '
        'selbst, und jeder Klon fällt von oben. Ein Apfel in der Schüssel '
        'gibt einen Punkt; einer, der den grünen Boden berührt, verschwindet. '
        'Du steuerst die Schüssel mit den Pfeiltasten.',
    descriptionEs: '¡Llueven manzanas! El objeto Manzana crea clones de sí '
        'mismo y cada clon cae desde arriba. Una manzana en el Cuenco suma un '
        'punto; la que toca el suelo verde desaparece. Tú mueves el Cuenco '
        'con las flechas.',
    anaKukla: const KuklaTanimi(
      ad: 'Elma',
      adEn: 'Apple',
      adDe: 'Apfel',
      adEs: 'Manzana',
      gorunum: KuklaGorunumu.elma,
      x: 0,
      y: 170,
      yaricap: 14,
    ),
    kuklalar: [kase],
    oyuncu: const OtomatikOyuncu(takipEden: 'Kase', hedef: 'Elma'),
    sureSiniri: 20,
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.gizle,
      AtolyeBloklari.puanSifir,
      AtolyeBloklari.tekrarla('10'),
      AtolyeBloklari.ikizYarat,
      AtolyeBloklari.bekle1,
      AtolyeBloklari.ikizOlarak,
      AtolyeBloklari.rastgeleGit,
      AtolyeBloklari.yTepe,
      AtolyeBloklari.goster,
      AtolyeBloklari.surekli,
      AtolyeBloklari.yAsagi,
      AtolyeBloklari.egerKaseyeDegiyor,
      AtolyeBloklari.puanArtir,
      AtolyeBloklari.ikiziSil,
      AtolyeBloklari.egerZemineDegiyor,
    ],
    sayiDuzenlenebilir: {'repeat_10', 'change_y_down'},
    hedefler: const [
      KlonHedefi(
        metin: 'En az 10 elma ikizi yarat',
        metinEn: 'Create at least 10 apple clones',
        metinDe: 'Erzeuge mindestens 10 Apfel-Klone',
        metinEs: 'Crea al menos 10 clones de manzana',
        enAz: 10,
      ),
      VeHedefi(
        metin: 'Her ikiz tepeden başlasın ve aşağı düşsün',
        metinEn: 'Each clone starts at the top and falls down',
        metinDe: 'Jeder Klon startet oben und fällt nach unten',
        metinEs: 'Cada clon empieza arriba y cae',
        hepsi: [
          OlayHedefi(
              metin: '',
              metinEn: '',
              metinDe: '',
              metinEs: '',
              olay: 'ikiz',
              bloklar: {'set_y_170'}),
          OlayHedefi(
              metin: '',
              metinEn: '',
              metinDe: '',
              metinEs: '',
              olay: 'ikiz',
              bloklar: {'change_y_down'}),
        ],
      ),
      DegiskenHedefi(
        metin: 'Kaseyle en az 5 elma yakala',
        metinEn: 'Catch at least 5 apples with the Bowl',
        metinDe: 'Fang mindestens 5 Äpfel mit der Schüssel',
        metinEs: 'Atrapa al menos 5 manzanas con el Cuenco',
        ad: 'Puan',
        islem: '>=',
        deger: 5,
      ),
      KlonHedefi(
        metin: 'Yakalanan ya da yere düşen her elma kendini silsin',
        metinEn: 'Every apple that is caught or hits the ground deletes itself',
        metinDe: 'Jeder gefangene oder gelandete Apfel löscht sich selbst',
        metinEs: 'Cada manzana atrapada o que toca el suelo se borra',
        enAz: 10,
        enAzSilinen: 10,
      ),
    ],
    ornekCozum: 'green_flag hide set_score_0 repeat_10 create_clone wait_1s } '
        'when_clone goto_random set_y_170 show forever change_y_down=-6 '
        'if_touching_bowl change_score delete_clone } '
        'if_touching_ground delete_clone } }',
    ipucu: 'İki betik gerekiyor. Bayrak betiği asıl elmayı gizler ve bir '
        'döngüyle ikizler yaratır. "İkiz olarak başladığımda" betiği ikizi '
        'tepeye koyar, gösterir ve sürekli aşağı indirir: kaseye ya da '
        'yeşile değince ikizi sil.',
    ipucuEn: 'You need two scripts. The flag script hides the real apple and '
        'creates clones in a loop. The "when I start as a clone" script puts '
        'the clone at the top, shows it and keeps moving it down: when it '
        'touches the Bowl or the green, delete the clone.',
    ipucuDe: 'Du brauchst zwei Skripte. Das Flaggen-Skript versteckt den '
        'echten Apfel und erzeugt in einer Schleife Klone. Das Skript „Wenn '
        'ich als Klon entstehe“ setzt den Klon nach oben, zeigt ihn und lässt '
        'ihn fallen: Berührt er die Schüssel oder das Grün, lösch den Klon.',
    ipucuEs: 'Necesitas dos guiones. El de la bandera esconde la manzana real '
        'y crea clones en un bucle. El de "al comenzar como clon" pone el '
        'clon arriba, lo muestra y lo hace bajar: si toca el Cuenco o el '
        'verde, borra el clon.',
    bilgisayarNotu: 'Scratch\'te oyunu zorlaştır: her yakalayışta elmalar '
        'biraz daha hızlı düşsün.',
    bilgisayarNotuEn: 'In Scratch, make it harder: the apples fall a little '
        'faster after every catch.',
    bilgisayarNotuDe: 'Mach es in Scratch schwerer: Nach jedem Fang fallen '
        'die Äpfel etwas schneller.',
    bilgisayarNotuEs: 'En Scratch, hazlo más difícil: tras cada captura las '
        'manzanas caen un poco más rápido.',
    xpReward: 50,
  );

  // ------------------------------------------------------------- 6.1
  static final dansPartisi = ProjeAtolyesiStep(
    id: 's6_1_atolye',
    title: 'Proje: Dans Partisi',
    titleEn: 'Project: Dance Party',
    titleDe: 'Projekt: Tanzparty',
    titleEs: 'Proyecto: Fiesta de baile',
    description: 'Bayrağa basınca Devi "dans" haberini salsın. Haberi '
        'alan betik dansı başlatsın: kostüm değiştirsin ve dönsün.',
    descriptionEn: 'On the green flag, Devi broadcasts "dance". The script '
        'that receives it starts the dance: switch costumes and spin.',
    descriptionDe: 'Bei der grünen Flagge sendet Devi „Tanz“. Das Skript, das '
        'die Nachricht empfängt, startet den Tanz: Kostüme wechseln und '
        'drehen.',
    descriptionEs: 'Con la bandera verde, Devi envía "baile". El guion que lo '
        'recibe empieza el baile: cambiar de disfraz y girar.',
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.dansSal,
      AtolyeBloklari.dansAl,
      AtolyeBloklari.tekrarla('4'),
      AtolyeBloklari.sonrakiKostum,
      AtolyeBloklari.don90,
      AtolyeBloklari.merhabaDe,
      AtolyeBloklari.bekle1,
    ],
    sayiDuzenlenebilir: {'repeat_4', 'turn_90'},
    hedefler: const [
      HaberHedefi(
        metin: 'Devi "dans" haberini salsın ve haber alınsın',
        metinEn: 'Devi broadcasts "dance" and someone receives it',
        metinDe: 'Devi sendet „Tanz“ und jemand empfängt es',
        metinEs: 'Devi envía "baile" y alguien lo recibe',
        haber: 'dans',
      ),
      KostumHedefi(
        metin: 'Dans ederken en az 4 kez kostüm değiştirsin',
        metinEn: 'While dancing, switch costumes at least 4 times',
        metinDe: 'Beim Tanzen mindestens 4-mal das Kostüm wechseln',
        metinEs: 'Al bailar, cambia de disfraz al menos 4 veces',
        enAz: 4,
      ),
      OlayHedefi(
        metin: 'Haberi alan betik Devi\'yi döndürsün',
        metinEn: 'The receiving script makes Devi spin',
        metinDe: 'Das empfangende Skript lässt Devi sich drehen',
        metinEs: 'El guion que recibe hace girar a Devi',
        olay: 'haber:dans',
        bloklar: {'turn_90'},
      ),
    ],
    ornekCozum: 'green_flag broadcast_dance receive_dance repeat_4 '
        'next_costume turn_90 }',
    ipucu: 'İki ayrı betik gerekiyor: biri bayrakla başlar ve haberi salar, '
        'öteki "dans haberini aldığımda" ile başlar.',
    ipucuEn: 'You need two scripts: one starts with the flag and broadcasts, '
        'the other starts with "when I receive dance".',
    ipucuDe: 'Du brauchst zwei Skripte: Eines beginnt mit der Flagge und '
        'sendet, das andere beginnt mit „Wenn ich Tanz empfange“.',
    ipucuEs: 'Necesitas dos guiones: uno empieza con la bandera y envía, el '
        'otro empieza con "al recibir baile".',
    bilgisayarNotu: 'Scratch\'te üç kukla ekle; hepsi aynı haberi alıp '
        'farklı bir dans yapsın.',
    bilgisayarNotuEn: 'In Scratch, add three sprites; they all receive the '
        'same message and dance differently.',
    bilgisayarNotuDe: 'Füge in Scratch drei Figuren hinzu; alle empfangen '
        'dieselbe Nachricht und tanzen anders.',
    bilgisayarNotuEs: 'En Scratch, añade tres objetos; todos reciben el mismo '
        'mensaje y bailan distinto.',
    xpReward: 40,
  );

  // ------------------------------------------------------------- 7.1
  static const _notalar = {'play_note_60', 'play_note_62', 'play_note_64'};

  static final melodiKutusu = ProjeAtolyesiStep(
    id: 's7_1_atolye',
    title: 'Proje: Melodi Kutusu',
    titleEn: 'Project: Melody Box',
    titleDe: 'Projekt: Melodiebox',
    titleEs: 'Proyecto: Caja de melodías',
    description: 'Bayrakla küçük bir melodi çalsın ve iki kez tekrarlansın. '
        'Boşluk tuşu da bir nota çalsın — klavyeden piyano!',
    descriptionEn: 'On the flag, play a short melody twice. The space key '
        'plays a note too — a keyboard piano!',
    descriptionDe: 'Bei der Flagge spielt eine kleine Melodie zweimal. Die '
        'Leertaste spielt auch einen Ton — ein Tastenklavier!',
    descriptionEs: 'Con la bandera suena una melodía corta dos veces. La '
        'barra espaciadora también toca una nota: ¡un piano de teclado!',
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.bosluktaTus,
      AtolyeBloklari.nota('60'),
      AtolyeBloklari.nota('62'),
      AtolyeBloklari.nota('64'),
      AtolyeBloklari.tekrarla('2'),
      AtolyeBloklari.bekle1,
    ],
    sayiDuzenlenebilir: {'repeat_2'},
    hedefler: const [
      CalistiHedefi(
        metin: 'Melodide en az 3 farklı nota olsun',
        metinEn: 'The melody has at least 3 different notes',
        metinDe: 'Die Melodie hat mindestens 3 verschiedene Töne',
        metinEs: 'La melodía tiene al menos 3 notas distintas',
        bloklar: _notalar,
        enAz: 3,
        farkli: true,
      ),
      CalistiHedefi(
        metin: 'Melodi iki kez çalsın: toplam en az 6 nota',
        metinEn: 'The melody plays twice: at least 6 notes in total',
        metinDe: 'Die Melodie spielt zweimal: insgesamt mindestens 6 Töne',
        metinEs: 'La melodía suena dos veces: al menos 6 notas en total',
        bloklar: _notalar,
        enAz: 6,
      ),
      OlayHedefi(
        metin: 'Boşluk tuşuna basınca bir nota çalsın',
        metinEn: 'Pressing the space key plays a note',
        metinDe: 'Die Leertaste spielt einen Ton',
        metinEs: 'La barra espaciadora toca una nota',
        olay: 'tus:space',
        bloklar: _notalar,
      ),
    ],
    ornekCozum: 'green_flag repeat_2 play_note_60 play_note_62 play_note_64 '
        '} when_key_space play_note_64',
    ipucu: 'Üç notayı bir "tekrarla" bloğunun İÇİNE koy. Boşluk tuşu için '
        'ayrı bir şapka bloğu kullan.',
    ipucuEn: 'Put the three notes INSIDE a "repeat" block. Use a separate hat '
        'block for the space key.',
    ipucuDe: 'Setz die drei Töne IN einen „wiederhole“-Block. Für die '
        'Leertaste nimmst du einen eigenen Hutblock.',
    ipucuEs: 'Pon las tres notas DENTRO de un bloque "repetir". Usa otro '
        'bloque de sombrero para la barra espaciadora.',
    bilgisayarNotu: 'Scratch\'te A, S, D, F, G tuşlarına beş ayrı nota ver; '
        'gerçek bir piyano olsun.',
    bilgisayarNotuEn: 'In Scratch, give the keys A, S, D, F and G five '
        'different notes for a real piano.',
    bilgisayarNotuDe: 'Gib in Scratch den Tasten A, S, D, F und G fünf '
        'verschiedene Töne — ein echtes Klavier.',
    bilgisayarNotuEs: 'En Scratch, da a las teclas A, S, D, F y G cinco notas '
        'distintas: un piano de verdad.',
    xpReward: 40,
  );

  // ------------------------------------------------------------- 8
  static final yildizCiz = ProjeAtolyesiStep(
    id: 's8_2_atolye',
    title: 'Modül Projesi: Yıldız Çiz',
    titleEn: 'Module Project: Draw a Star',
    titleDe: 'Modulprojekt: Zeichne einen Stern',
    titleEs: 'Proyecto del módulo: Dibuja una estrella',
    description: 'Kalemle beş köşeli bir yıldız çiz. Döngüyü kaç kez '
        'döndüreceğini ve köşede kaç derece döneceğini sen bul.',
    descriptionEn: 'Draw a five-pointed star with the pen. You work out how '
        'many times the loop runs and how far to turn at each point.',
    descriptionDe: 'Zeichne mit dem Stift einen fünfzackigen Stern. Du '
        'findest heraus, wie oft die Schleife läuft und wie weit du an jeder '
        'Spitze drehst.',
    descriptionEs: 'Dibuja con el lápiz una estrella de cinco puntas. Tú '
        'decides cuántas veces da vueltas el bucle y cuánto girar en cada '
        'punta.',
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.sil,
      AtolyeBloklari.kalemIndir,
      AtolyeBloklari.kalemKaldir,
      AtolyeBloklari.tekrarla('4'),
      AtolyeBloklari.git100,
      AtolyeBloklari.don90,
    ],
    sayiDuzenlenebilir: {'repeat_4', 'move_100', 'turn_90'},
    hedefler: const [
      CizgiHedefi(
        metin: 'Kalemle en az 5 çizgi çiz',
        metinEn: 'Draw at least 5 lines with the pen',
        metinDe: 'Zeichne mit dem Stift mindestens 5 Linien',
        metinEs: 'Dibuja al menos 5 líneas con el lápiz',
        enAz: 5,
      ),
      KapaliSekilHedefi(
        metin: 'Çizim kapansın: kalem başladığı yere dönsün',
        metinEn: 'Close the drawing: the pen ends where it started',
        metinDe: 'Schließ die Zeichnung: Der Stift endet, wo er begann',
        metinEs: 'Cierra el dibujo: el lápiz acaba donde empezó',
        enAzKenar: 5,
      ),
      BlokHedefi(
        metin: 'Bir döngü kullan',
        metinEn: 'Use a loop',
        metinDe: 'Benutze eine Schleife',
        metinEs: 'Usa un bucle',
        bloklar: {'repeat_4'},
      ),
    ],
    ornekCozum: 'green_flag pen_clear pen_down repeat_4=5 move_100 '
        'turn_90=144 }',
    ipucu: 'Yıldızın 5 ucu var: döngü 5 kez dönsün. 90 derece kare '
        'yapıyordu; yıldızın uçları için çok daha keskin dönmelisin (100\'den '
        'büyük bir açı).',
    ipucuEn: 'A star has 5 points: the loop runs 5 times. 90 degrees made a '
        'square; the points of a star need a much sharper turn (more than '
        '100).',
    ipucuDe: 'Ein Stern hat 5 Spitzen: Die Schleife läuft 5-mal. 90 Grad '
        'ergaben ein Quadrat; für die Spitzen brauchst du eine viel schärfere '
        'Drehung (mehr als 100).',
    ipucuEs: 'Una estrella tiene 5 puntas: el bucle da 5 vueltas. Con 90 '
        'grados salía un cuadrado; las puntas necesitan un giro mucho más '
        'cerrado (más de 100).',
    bilgisayarNotu: 'Scratch\'te kalemin rengini her kenarda değiştir; '
        'gökkuşağı yıldızı çiz.',
    bilgisayarNotuEn: 'In Scratch, change the pen colour on every side for a '
        'rainbow star.',
    bilgisayarNotuDe: 'Ändere in Scratch an jeder Seite die Stiftfarbe — ein '
        'Regenbogenstern.',
    bilgisayarNotuEs: 'En Scratch, cambia el color del lápiz en cada lado: '
        'una estrella arcoíris.',
    xpReward: 60,
  );

  // ------------------------------------------------------------- 9
  static final zarOyunu = ProjeAtolyesiStep(
    id: 's9_2_atolye',
    title: 'Modül Projesi: Zar Oyunu',
    titleEn: 'Module Project: Dice Game',
    titleDe: 'Modulprojekt: Würfelspiel',
    titleEs: 'Proyecto del módulo: Juego de dados',
    description: 'Üç tur zar at. Her turda zar 3\'ten büyükse Devi '
        '"Kazandın!", değilse "Tekrar dene!" desin.',
    descriptionEn: 'Roll the dice for three rounds. Each round, if the dice '
        'is bigger than 3 Devi says "You win!", otherwise "Try again!".',
    descriptionDe: 'Würfle drei Runden. Ist der Würfel größer als 3, sagt '
        'Devi „Gewonnen!“, sonst „Versuch es nochmal!“.',
    descriptionEs: 'Tira el dado tres rondas. Si sale más de 3, Devi dice '
        '"¡Ganaste!"; si no, "¡Inténtalo otra vez!".',
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.zarAt,
      AtolyeBloklari.zariDe,
      AtolyeBloklari.egerZarBuyuk3,
      AtolyeBloklari.kazandinDe,
      AtolyeBloklari.tekrarDeneDe,
      AtolyeBloklari.tekrarla('3'),
      AtolyeBloklari.bekle1,
      AtolyeBloklari.rastgeleGit,
    ],
    sayiDuzenlenebilir: {'repeat_3'},
    hedefler: const [
      SoylediHedefi(
        metin: 'Zarı at ve çıkan sayıyı söyle',
        metinEn: 'Roll the dice and say the number',
        metinDe: 'Würfle und sag die Zahl',
        metinEs: 'Tira el dado y di el número',
        sayi: true,
        alt: 1,
        ust: 6,
      ),
      VeHedefi(
        metin: 'Eğer-değilse ile kazandın mı, kaybettin mi söyle',
        metinEn: 'Use if-else to say whether you won or lost',
        metinDe: 'Sag mit falls-sonst, ob du gewonnen oder verloren hast',
        metinEs: 'Usa si-si no para decir si ganaste o perdiste',
        hepsi: [
          BlokHedefi(
              metin: '',
              metinEn: '',
              metinDe: '',
              metinEs: '',
              bloklar: {'ifelse_dice_gt_3'}),
          CalistiHedefi(
              metin: '',
              metinEn: '',
              metinDe: '',
              metinEs: '',
              bloklar: {'say_win', 'say_try_again'}),
        ],
      ),
      CalistiHedefi(
        metin: 'Oyun 3 tur sürsün',
        metinEn: 'The game lasts 3 rounds',
        metinDe: 'Das Spiel dauert 3 Runden',
        metinEs: 'El juego dura 3 rondas',
        bloklar: {'set_dice_random'},
        enAz: 3,
      ),
    ],
    ornekCozum: 'green_flag repeat_3 set_dice_random say_dice '
        'ifelse_dice_gt_3 say_win | say_try_again } wait_1s }',
    ipucu: 'Eğer-değilse bloğunun iki ağzı var: üstteki zar büyükken, '
        'alttaki değilken çalışır. Bütün turu tekrarla bloğunun içine koy.',
    ipucuEn: 'The if-else block has two mouths: the top one runs when the '
        'dice is big, the bottom one when it is not. Put the whole round '
        'inside the repeat block.',
    ipucuDe: 'Der falls-sonst-Block hat zwei Mäuler: Das obere läuft bei '
        'großem Würfel, das untere sonst. Setz die ganze Runde in den '
        'wiederhole-Block.',
    ipucuEs: 'El bloque si-si no tiene dos bocas: la de arriba funciona si el '
        'dado es grande, la de abajo si no. Pon toda la ronda dentro del '
        'bloque repetir.',
    bilgisayarNotu: 'Scratch\'te kazanılan turları bir değişkende say ve '
        'oyun sonunda söyle.',
    bilgisayarNotuEn: 'In Scratch, count the rounds you win in a variable '
        'and say it at the end.',
    bilgisayarNotuDe: 'Zähle in Scratch die gewonnenen Runden in einer '
        'Variable und sag sie am Ende.',
    bilgisayarNotuEs: 'En Scratch, cuenta las rondas ganadas en una variable '
        'y dilas al final.',
    xpReward: 60,
  );

  // ------------------------------------------------------------- 10
  static final alisverisListesi = ProjeAtolyesiStep(
    id: 's10_2_atolye',
    title: 'Modül Projesi: Alışveriş Listesi',
    titleEn: 'Module Project: Shopping List',
    titleDe: 'Modulprojekt: Einkaufsliste',
    titleEs: 'Proyecto del módulo: Lista de la compra',
    description: 'Bir alışveriş listesi kur. Listeye en az üç şey kalsın; '
        'aldığın ilk şeyi listeden sil ve Devi listede kaç şey kaldığını '
        'söylesin.',
    descriptionEn: 'Build a shopping list. Keep at least three things on it; '
        'delete the first thing you bought and let Devi say how many are '
        'left.',
    descriptionDe: 'Bau eine Einkaufsliste. Mindestens drei Dinge bleiben '
        'darauf; lösch das Erste, das du gekauft hast, und Devi sagt, wie '
        'viele übrig sind.',
    descriptionEs: 'Crea una lista de la compra. Que queden al menos tres '
        'cosas; borra lo primero que compraste y que Devi diga cuántas '
        'quedan.',
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.elmaEkle,
      AtolyeBloklari.muzEkle,
      AtolyeBloklari.sutEkle,
      AtolyeBloklari.ilkiniSil,
      AtolyeBloklari.listeUzunluguDe,
      AtolyeBloklari.tekrarla('2'),
      AtolyeBloklari.merhabaDe,
    ],
    sayiDuzenlenebilir: {'repeat_2'},
    hedefler: const [
      ListeHedefi(
        metin: 'Listede en az 3 şey olsun',
        metinEn: 'The list has at least 3 things',
        metinDe: 'Auf der Liste stehen mindestens 3 Dinge',
        metinEs: 'La lista tiene al menos 3 cosas',
        liste: 'alışveriş',
        enAz: 3,
      ),
      CalistiHedefi(
        metin: 'Aldığın ilk şeyi listeden sil',
        metinEn: 'Delete the first thing you bought',
        metinDe: 'Lösch das Erste, das du gekauft hast',
        metinEs: 'Borra lo primero que compraste',
        bloklar: {'delete_first'},
      ),
      SoylediHedefi(
        metin: 'Devi listede kaç şey kaldığını söylesin',
        metinEn: 'Devi says how many things are left',
        metinDe: 'Devi sagt, wie viele Dinge übrig sind',
        metinEs: 'Devi dice cuántas cosas quedan',
        bloklar: {'say_len_shopping'},
      ),
    ],
    ornekCozum: 'green_flag add_apple add_banana add_milk add_apple '
        'delete_first say_len_shopping',
    ipucu: 'Silmeden ÖNCE listeye dört şey ekle; silince üç kalır. '
        'Uzunluğu en sonda söyle.',
    ipucuEn: 'Add four things BEFORE you delete one; then three are left. Say '
        'the length at the very end.',
    ipucuDe: 'Füg VOR dem Löschen vier Dinge hinzu; dann bleiben drei. Sag '
        'die Länge ganz am Ende.',
    ipucuEs: 'Añade cuatro cosas ANTES de borrar una; quedan tres. Di la '
        'longitud al final.',
    bilgisayarNotu: 'Scratch\'te "sor ve bekle" ile listeye ne ekleneceğini '
        'oyuncuya sor.',
    bilgisayarNotuEn: 'In Scratch, use "ask and wait" so the player chooses '
        'what goes on the list.',
    bilgisayarNotuDe: 'Nutze in Scratch „frage und warte“, damit der Spieler '
        'bestimmt, was auf die Liste kommt.',
    bilgisayarNotuEs: 'En Scratch, usa "preguntar y esperar" para que el '
        'jugador elija qué va a la lista.',
    xpReward: 60,
  );

  // ------------------------------------------------------------- 11
  static final cokgenCicegi = ProjeAtolyesiStep(
    id: 's11_2_atolye',
    title: 'Modül Projesi: Çokgen Çiçeği',
    titleEn: 'Module Project: Polygon Flower',
    titleDe: 'Modulprojekt: Vieleck-Blume',
    titleEs: 'Proyecto del módulo: Flor de polígonos',
    description: 'Kendi "çokgen" bloğunu tanımla ve onu döngüyle tekrar '
        'tekrar çağırarak bir çiçek çiz. Kaç kenarlı yaprak olacağını sen '
        'seç.',
    descriptionEn: 'Define your own "polygon" block and call it again and '
        'again in a loop to draw a flower. You choose how many sides the '
        'petals have.',
    descriptionDe: 'Definiere deinen eigenen „Vieleck“-Block und ruf ihn in '
        'einer Schleife immer wieder auf, um eine Blume zu zeichnen. Du '
        'wählst, wie viele Seiten die Blätter haben.',
    descriptionEs: 'Define tu propio bloque "polígono" y llámalo una y otra '
        'vez en un bucle para dibujar una flor. Tú eliges cuántos lados '
        'tienen los pétalos.',
    palet: [
      AtolyeBloklari.bayrak,
      AtolyeBloklari.sil,
      AtolyeBloklari.kalemIndir,
      AtolyeBloklari.cokgenTanimla,
      AtolyeBloklari.kenarKereTekrarla,
      AtolyeBloklari.cokgenGit,
      AtolyeBloklari.kenaraGoreDon,
      AtolyeBloklari.cokgen6,
      AtolyeBloklari.tekrarla('4'),
      AtolyeBloklari.don90,
    ],
    sayiDuzenlenebilir: {
      'call_polygon_6',
      'repeat_4',
      'turn_90',
      'move_100_poly',
    },
    hedefler: const [
      BlokHedefi(
        metin: 'Kendi "çokgen" bloğunu tanımla',
        metinEn: 'Define your own "polygon" block',
        metinDe: 'Definiere deinen eigenen „Vieleck“-Block',
        metinEs: 'Define tu propio bloque "polígono"',
        bloklar: {'define_polygon'},
      ),
      CagriHedefi(
        metin: 'Bloğunu bir döngüyle en az 4 kez çağır',
        metinEn: 'Call your block at least 4 times with a loop',
        metinDe: 'Ruf deinen Block mit einer Schleife mindestens 4-mal auf',
        metinEs: 'Llama a tu bloque al menos 4 veces con un bucle',
        yordam: cokgenYordami,
        enAzCagri: 4,
      ),
      CizgiHedefi(
        metin: 'Yapraklar için en az 16 çizgi çiz',
        metinEn: 'Draw at least 16 lines for the petals',
        metinDe: 'Zeichne mindestens 16 Linien für die Blätter',
        metinEs: 'Dibuja al menos 16 líneas para los pétalos',
        enAz: 16,
      ),
    ],
    ornekCozum: 'define_polygon repeat_sides move_100_poly=50 '
        'turn_360_over_sides } green_flag pen_clear pen_down repeat_4=6 '
        'call_polygon_6=5 turn_90=60 }',
    ipucu: 'Tanım ayrı bir betik: "çokgen i tanımla"nın altına kenar kadar '
        'dönen bir döngü koy. Bayrak betiğinde çağrıyı ve bir dönüşü bir '
        'döngünün içine koy.',
    ipucuEn: 'The definition is its own script: under "define polygon" put a '
        'loop that repeats sides times. In the flag script, put the call and '
        'a turn inside a loop.',
    ipucuDe: 'Die Definition ist ein eigenes Skript: Unter „Definiere '
        'Vieleck“ kommt eine Schleife, die Seiten-mal läuft. Im '
        'Flaggen-Skript kommen Aufruf und Drehung in eine Schleife.',
    ipucuEs: 'La definición es un guion aparte: bajo "definir polígono" va un '
        'bucle que se repite lados veces. En el guion de la bandera, pon la '
        'llamada y un giro dentro de un bucle.',
    bilgisayarNotu: 'Scratch\'te bloğuna ikinci bir girdi (boy) ekle; '
        'yapraklar büyüyüp küçülsün.',
    bilgisayarNotuEn: 'In Scratch, give your block a second input (size) so '
        'the petals grow and shrink.',
    bilgisayarNotuDe: 'Gib deinem Block in Scratch eine zweite Eingabe '
        '(Größe), damit die Blätter wachsen und schrumpfen.',
    bilgisayarNotuEs: 'En Scratch, dale a tu bloque una segunda entrada '
        '(tamaño) para que los pétalos crezcan y encojan.',
    xpReward: 60,
  );

  /// Butun atolyeler (testler ve Projelerim icin).
  static List<ProjeAtolyesiStep> get hepsi => [
        tuslarlaDevi,
        yakalaOyunu,
        yildizToplayici,
        elmaYagmuru,
        dansPartisi,
        melodiKutusu,
        yildizCiz,
        zarOyunu,
        alisverisListesi,
        cokgenCicegi,
      ];

  /// Kimligiyle atolye (Projelerim'den yeniden acmak icin).
  static ProjeAtolyesiStep? bul(String? id) {
    if (id == null) return null;
    for (final a in hepsi) {
      if (a.id == id) return a;
    }
    // Kod Bloklari oyununda kaydedilen cizimler de Projelerim'de.
    return KodBloklariSeviyeleri.bul(id);
  }

  /// "Projelerim"deki bos atolye: butun atolyelerin bloklari, hedefsiz.
  static final ProjeAtolyesiStep serbest = () {
    final gorulen = <String>{};
    final palet = [
      for (final a in hepsi)
        for (final b in a.palet)
          if (gorulen.add(b.id)) b,
    ];
    final duzenlenebilir = {for (final a in hepsi) ...a.sayiDuzenlenebilir};
    return ProjeAtolyesiStep(
      id: 'scratch_serbest_atolye',
      title: 'Serbest Atölye',
      titleEn: 'Free Workshop',
      titleDe: 'Freie Werkstatt',
      titleEs: 'Taller libre',
      description: 'Bütün atölye blokları burada. Ne istersen kur, çalıştır '
          've kaydet.',
      descriptionEn: 'All the workshop blocks are here. Build whatever you '
          'like, run it and save it.',
      descriptionDe: 'Hier sind alle Werkstatt-Blöcke. Bau, was du willst, '
          'lass es laufen und speichere es.',
      descriptionEs: 'Aquí están todos los bloques del taller. Construye lo '
          'que quieras, ejecútalo y guárdalo.',
      palet: palet,
      hedefler: const [],
      ornekCozum: 'green_flag say_hello',
      ipucu: '',
      sayiDuzenlenebilir: duzenlenebilir,
      xpReward: 0,
    );
  }();
}
