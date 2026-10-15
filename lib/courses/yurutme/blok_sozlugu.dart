import 'blok_anlami.dart';

/// Ders verisindeki blok kimliklerinin ANLAMI.
///
/// Sozluk, tahmin yerine yazili bilgi. Bir kimlik burada yoksa
/// yorumlayici onu `etkisiz` sayar: adini soyler, sahneyi degistirmez.
/// `test/blok_yorumlayici_test.dart` hangi kimliklerin hala sozluge
/// girmedigini listeliyor, yani bosluk sessiz degil OLCULU kaliyor.
///
/// DIKKAT: buradaki sayilar bloklarin ETIKETINDEN geliyor ("10 adim
/// git" -> 10). Etiket degisirse sayi da degismeli; blok etiketleri
/// Scratch'in kendi dil dosyasindan aliniyor (bkz. tool/bloklar/).
const Map<String, BlokAnlami> blokSozlugu = {
  // --- Olaylar -----------------------------------------------------
  'green_flag': BlokAnlami(BlokKomutu.baslat),
  // Ikiz sapkasi: proje motorunda yalnizca yeni ikizde calisiyor; tek
  // yiginli izde (ders adimlari) diger sapkalar gibi.
  'when_clone': BlokAnlami(BlokKomutu.baslat, metin: 'ikiz'),
  // Kuklaya tiklama sapkasi: atolyede cocuk kuklaya bir kez "tiklamis"
  // sayiliyor.
  'when_clicked_sprite': BlokAnlami(BlokKomutu.baslat, metin: 'tikla'),
  // Haber sapkasi ve haber salma. Tek yiginli blok adimlarinda haber
  // salmanin etkisi yok; Proje Atolyesi'nde alicilar O ANDA calisiyor.
  'receive_jump': BlokAnlami(BlokKomutu.baslat, haber: 'zıpla'),
  'broadcast': BlokAnlami(BlokKomutu.haberSal, haber: 'zıpla'),
  'receive_dance': BlokAnlami(BlokKomutu.baslat, haber: 'dans'),
  'broadcast_dance': BlokAnlami(BlokKomutu.haberSal, haber: 'dans'),
  'broadcast_dance_wait': BlokAnlami(BlokKomutu.haberSalBekle, haber: 'dans'),
  // Tus sapkalari: atolyede her tusa bir kez basilmis sayiliyor.
  'when_key_space': BlokAnlami(BlokKomutu.baslat, tus: 'space'),
  'when_key_right': BlokAnlami(BlokKomutu.baslat, tus: 'right'),
  'when_key_left': BlokAnlami(BlokKomutu.baslat, tus: 'left'),

  // --- Hareket -----------------------------------------------------
  'move_10': BlokAnlami(BlokKomutu.ilerle, sayi: 10),
  'change_x': BlokAnlami(BlokKomutu.xDegistir, sayi: 10),
  'change_y': BlokAnlami(BlokKomutu.yDegistir, sayi: 50),
  'change_y_up': BlokAnlami(BlokKomutu.yDegistir, sayi: 10),
  'goto_corner': BlokAnlami(BlokKomutu.gitXY, sayi: 200, sayi2: 150),
  'goto_center': BlokAnlami(BlokKomutu.gitXY, sayi: 0, sayi2: 0),
  // Sahnede rastgele bir yer (yorumlayici seciyor; sahne ve iz ayni
  // yeri gosteriyor).
  'goto_random': BlokAnlami(BlokKomutu.rastgeleKonum),
  'goto_top': BlokAnlami(BlokKomutu.gitXY, sayi: 0, sayi2: 150),
  'change_y_down': BlokAnlami(BlokKomutu.yDegistir, sayi: -10),
  'goto_100_50': BlokAnlami(BlokKomutu.gitXY, sayi: 100, sayi2: 50),
  // Kasenin yeri: zemin seridinin hemen ustu.
  'goto_bottom': BlokAnlami(BlokKomutu.gitXY, sayi: 0, sayi2: -125),
  'set_x_0': BlokAnlami(BlokKomutu.xAyarla, sayi: 0),
  'set_y_170': BlokAnlami(BlokKomutu.yAyarla, sayi: 170),
  'glide_1_0_0':
      BlokAnlami(BlokKomutu.kaydir, sayi: 0, sayi2: 0, saniye: 1),
  'point_90': BlokAnlami(BlokKomutu.yonAyarla, sayi: 90),
  'point_towards_mouse': BlokAnlami(BlokKomutu.yoneDogru, kukla: 'Fare'),
  
  // --- Gorunum -----------------------------------------------------
  'say_hello': BlokAnlami(BlokKomutu.soyle, metin: 'Merhaba'),
  'say_meow': BlokAnlami(BlokKomutu.soyle, metin: 'Miyav!'),
  'say_jump': BlokAnlami(BlokKomutu.soyle, metin: 'Zıpladın!'),
  'say_win': BlokAnlami(BlokKomutu.soyle, metin: 'Kazandın!'),
  'say_try_again': BlokAnlami(BlokKomutu.soyle, metin: 'Tekrar dene!'),
  'say_time_up': BlokAnlami(BlokKomutu.soyle, metin: 'Süre bitti!'),
  // Degiskenin DEGERINI soyleyen bloklar ("Puan", "zar").
  'say_score': BlokAnlami(BlokKomutu.soyle, degisken: 'Puan'),
  'say_dice': BlokAnlami(BlokKomutu.soyle, degisken: 'zar'),
  // Listenin uzunlugunu soyle.
  'say_len_shopping': BlokAnlami(BlokKomutu.soyle, liste: 'alışveriş'),

  // --- Kontrol -----------------------------------------------------
  'repeat_4': BlokAnlami(BlokKomutu.tekrarla, sayi: 4),
  'forever': BlokAnlami(BlokKomutu.surekli),
  'wait_2': BlokAnlami(BlokKomutu.bekle, sayi: 2),
  'wait_1s': BlokAnlami(BlokKomutu.bekle, sayi: 1),
  'repeat_2': BlokAnlami(BlokKomutu.tekrarla, sayi: 2),
  'repeat_5': BlokAnlami(BlokKomutu.tekrarla, sayi: 5),
  'repeat_10': BlokAnlami(BlokKomutu.tekrarla, sayi: 10),
  // Eger-degilse: kosul yanlissa ikinci kol calisiyor.
  'ifelse_dice_gt_3': BlokAnlami(BlokKomutu.eger,
      kosulDegisken: 'zar', kosulIslem: '>', kosulDeger: 3),
  'if_score_50': BlokAnlami(BlokKomutu.eger,
      kosulDegisken: 'Puan', kosulIslem: '=', kosulDeger: 50),
  'if_time_0': BlokAnlami(BlokKomutu.eger,
      kosulDegisken: 'süre', kosulIslem: '=', kosulDeger: 0),
  // Algilama kosullari: proje motoru OLCUYOR (tus basili mi, kuklalar
  // degiyor mu); tek yiginli izde DOGRU sayiliyorlar.
  'if_space': BlokAnlami(BlokKomutu.eger, algi: 'tus:space'),
  'if_right': BlokAnlami(BlokKomutu.eger, algi: 'tus:right'),
  'if_left': BlokAnlami(BlokKomutu.eger, algi: 'tus:left'),
  'if_up': BlokAnlami(BlokKomutu.eger, algi: 'tus:up'),
  'if_touching': BlokAnlami(BlokKomutu.eger, algi: 'degiyor:Fare'),
  'if_touching_cat': BlokAnlami(BlokKomutu.eger, algi: 'degiyor:Devi'),
  'if_touching_bowl': BlokAnlami(BlokKomutu.eger, algi: 'degiyor:Kase'),
  'if_touching_edge': BlokAnlami(BlokKomutu.eger, algi: 'degiyor:kenar'),
  'if_touching_ground': BlokAnlami(BlokKomutu.eger, algi: 'renk:zemin'),
  'if_score_5': BlokAnlami(BlokKomutu.eger,
      kosulDegisken: 'Puan', kosulIslem: '=', kosulDeger: 5),
  'create_clone': BlokAnlami(BlokKomutu.ikizYarat),
  'delete_clone': BlokAnlami(BlokKomutu.ikizSil),
  'stop_all': BlokAnlami(BlokKomutu.durdurHepsi),

  // --- Degiskenler -------------------------------------------------
  'set_score_0': BlokAnlami(BlokKomutu.degiskenAta, degisken: 'Puan', sayi: 0),
  'change_score':
      BlokAnlami(BlokKomutu.degiskenArtir, degisken: 'Puan', sayi: 1),
  'set_dice_random': BlokAnlami(BlokKomutu.degiskenAta,
      degisken: 'zar', rastgeleAlt: 1, rastgeleUst: 6),
  'set_time_5': BlokAnlami(BlokKomutu.degiskenAta, degisken: 'süre', sayi: 5),
  'change_time_down':
      BlokAnlami(BlokKomutu.degiskenArtir, degisken: 'süre', sayi: -1),
  'change_time_up':
      BlokAnlami(BlokKomutu.degiskenArtir, degisken: 'süre', sayi: 1),

  // --- Ses ---------------------------------------------------------
  // Sahnede kuklanin yaninda ♪. Scratch'in varsayilan temposu 60
  // vurus/dakika: "0.5 vurus cal" 0.5 saniye; betik o kadar bekliyor.
  'play_sound': BlokAnlami(BlokKomutu.ses),
  'play_note_60': BlokAnlami(BlokKomutu.ses, saniye: 0.5),
  'play_note_62': BlokAnlami(BlokKomutu.ses, saniye: 0.5),
  'play_note_64': BlokAnlami(BlokKomutu.ses, saniye: 0.5),
  'play_drum': BlokAnlami(BlokKomutu.ses, saniye: 0.25),

  // =================================================================
  // 8-11. MODULLER — kalem, sans, listeler, kendi blogun
  // =================================================================
  // Bu bloklar sozlukte yoktu: hepsi `etkisiz` sayiliyordu ve cocuk
  // "KODU CALISTIR"a bastiginda "Sahnede degisen bir sey olmadi"
  // yaziyordu. Ozellikle 9.1'de bu dersin kendisini yalanliyordu:
  // rastgele sayi sececek bir kod calistiriliyor ve ekranda hicbir
  // sayi cikmiyordu.

  // --- Rastgele (9.1) ----------------------------------------------
  // Sinirlar dahil, her calistirmada yeni sayi.
  'say_random_die':
      BlokAnlami(BlokKomutu.soyle, rastgeleAlt: 1, rastgeleUst: 6),
  'random_1_6': BlokAnlami(BlokKomutu.etkisiz),
  'random_1_10': BlokAnlami(BlokKomutu.etkisiz),

  // --- Karsilastirma (9.2) -----------------------------------------
  // Altigen bloklar tek baslarina calismaz; `eger`in icine girerler.
  // Kosul gercekten degerlendiriliyor: puan 5'ten kucuk degilse govde
  // calismiyor.
  'if_score_low': BlokAnlami(BlokKomutu.eger,
      kosulDegisken: 'Puan', kosulIslem: '<', kosulDeger: 5),
  'lt_score_5': BlokAnlami(BlokKomutu.etkisiz),
  'lt_5_score': BlokAnlami(BlokKomutu.etkisiz),
  'say_keep_going': BlokAnlami(BlokKomutu.soyle, metin: 'Devam et!'),

  // --- Listeler (10.1) ---------------------------------------------
  'add_apple':
      BlokAnlami(BlokKomutu.listeyeEkle, liste: 'alışveriş', metin: 'elma'),
  'add_banana':
      BlokAnlami(BlokKomutu.listeyeEkle, liste: 'alışveriş', metin: 'muz'),
  'add_milk':
      BlokAnlami(BlokKomutu.listeyeEkle, liste: 'alışveriş', metin: 'süt'),
  'delete_first':
      BlokAnlami(BlokKomutu.listedenSil, liste: 'alışveriş', sayi: 1),
  // 10.2: soylenen sey listenin rastgele bir ogesi. Adimda listeyi
  // dolduran blok yok; liste bossa yorumlayici dersin anlattigi gibi
  // bes soruluk ornek bir liste kullaniyor (cocugun dilinde).
  'say_random_question':
      BlokAnlami(BlokKomutu.soyle, listeRastgele: 'sorular'),
  'len_questions': BlokAnlami(BlokKomutu.etkisiz),
  'item_1_questions': BlokAnlami(BlokKomutu.etkisiz),

  // --- Kalem ve cizim (8.1 / 8.2) ----------------------------------
  'pen_down': BlokAnlami(BlokKomutu.kalemIndir),
  'pen_up': BlokAnlami(BlokKomutu.kalemKaldir),
  'pen_clear': BlokAnlami(BlokKomutu.kalemSil),
  // 8.1'in cizgi kodu: sozlukte yoktu, iz bu blogu "etkisiz" sayip
  // kalemin cizdigi cizgiyi hic gostermiyordu.
  'move_150': BlokAnlami(BlokKomutu.ilerle, sayi: 150),
  'move_100': BlokAnlami(BlokKomutu.ilerle, sayi: 100),
  'move_100_poly': BlokAnlami(BlokKomutu.ilerle, sayi: 100),
  'turn_90': BlokAnlami(BlokKomutu.don, sayi: 90),
  'turn_120': BlokAnlami(BlokKomutu.don, sayi: 120),
  'turn_60_extra': BlokAnlami(BlokKomutu.don, sayi: 60),
  'turn_90_fixed': BlokAnlami(BlokKomutu.don, sayi: 90),
  // 360/kenar: kenar bir girdi, degeri cagri aninda belli oluyor.
  'turn_360_over_sides':
      BlokAnlami(BlokKomutu.don, sayi: 360, girdi: 'kenar'),
  'repeat_3': BlokAnlami(BlokKomutu.tekrarla, sayi: 3),
  // 11.2: "kenar kere tekrarla" — tekrar sayisi bir girdi. Eskiden
  // etkisiz sayiliyor, C bicimi yuzunden "eger" gibi BIR KEZ calisiyordu.
  'repeat_sides': BlokAnlami(BlokKomutu.tekrarla, girdi: 'kenar'),

  // --- Kendi blogun (11) -------------------------------------------
  // Tanim bir tarif: kendi basina calismaz (11.1'in sorusu tam olarak
  // bu). Cagri tanimin govdesini calistirir; kod alaninda tanim yoksa
  // (11.1'in ikinci adimi gibi) bir onceki adimda kurulan tanim
  // kullaniliyor (bkz. BlokYorumlayici.kutuphane).
  'define_square': BlokAnlami(BlokKomutu.tanimla, yordam: 'kare'),
  'define_square_2': BlokAnlami(BlokKomutu.tanimla, yordam: 'kare'),
  'define_polygon':
      BlokAnlami(BlokKomutu.tanimla, yordam: 'cokgen', girdi: 'kenar'),
  'call_square': BlokAnlami(BlokKomutu.cagir, yordam: 'kare'),
  'call_polygon_6': BlokAnlami(BlokKomutu.cagir, yordam: 'cokgen', sayi: 6),
  'call_polygon_4': BlokAnlami(BlokKomutu.cagir, yordam: 'cokgen', sayi: 4),

  // --- Akvaryum projesi (mBlock 5. modul) --------------------------
  // Sayilar tool/mblock_projeleri/akvaryum.mblock dosyasindan.
  'point_55': BlokAnlami(BlokKomutu.yonAyarla, sayi: 55),
  'move_2_fish': BlokAnlami(BlokKomutu.ilerle, sayi: 2),
  'repeat_10_fish': BlokAnlami(BlokKomutu.tekrarla, sayi: 10),
  // Sahnenin kenari 480 x 360: kenara degen kukla sekiyor.
  'edge_bounce': BlokAnlami(BlokKomutu.kenardaSek),
  'rot_left_right': BlokAnlami(BlokKomutu.etkisiz),
  'rot_all_around': BlokAnlami(BlokKomutu.etkisiz),
  'sound_bubbles': BlokAnlami(BlokKomutu.ses),
  'wait_1_ses': BlokAnlami(BlokKomutu.bekle, sayi: 1),

  // --- Dans Partisi projesi ----------------------------------------
  'next_costume': BlokAnlami(BlokKomutu.sonrakiKostum),
  'wait_02': BlokAnlami(BlokKomutu.bekle, sayi: 0.2),
  'wait_05': BlokAnlami(BlokKomutu.bekle, sayi: 0.5),
  'sound_hiphop': BlokAnlami(BlokKomutu.ses),
  'backdrop_spotlight': BlokAnlami(BlokKomutu.etkisiz),

  // --- Elma Toplama projesi ----------------------------------------
  // Sayilar tool/mblock_projeleri/elma_toplama.mblock dosyasindan.
  // Mutlak y ve fareyi izleme yorumlayicida yok; uydurmak yerine
  // "gorunur etkisi yok" diyoruz. Dusus (y -8) ve puan gercek.
  'set_y_kase': BlokAnlami(BlokKomutu.etkisiz),
  'set_x_mouse': BlokAnlami(BlokKomutu.etkisiz),
  'change_y_kase': BlokAnlami(BlokKomutu.yDegistir, sayi: -8),
  'change_y_elma': BlokAnlami(BlokKomutu.yDegistir, sayi: -8),
  'start_as_clone': BlokAnlami(BlokKomutu.etkisiz),
  'show': BlokAnlami(BlokKomutu.goster),
  'hide': BlokAnlami(BlokKomutu.gizle),
  'if_touching_kase': BlokAnlami(BlokKomutu.etkisiz),
  // 'change_score' ve 'delete_clone' Scratch kursunda zaten var;
  // puan blogu burada kendi kimligiyle, silme ayni anlamla paylasiliyor.
  'change_toplananelma': BlokAnlami(BlokKomutu.degiskenArtir,
      degisken: 'toplananelma', sayi: 1),
};
