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
  'when_clone': BlokAnlami(BlokKomutu.baslat),
  'when_clicked_sprite': BlokAnlami(BlokKomutu.baslat),
  'receive_jump': BlokAnlami(BlokKomutu.baslat),
  'broadcast': BlokAnlami(BlokKomutu.etkisiz),

  // --- Hareket -----------------------------------------------------
  'move_10': BlokAnlami(BlokKomutu.ilerle, sayi: 10),
  'change_x': BlokAnlami(BlokKomutu.xDegistir, sayi: 10),
  'change_y': BlokAnlami(BlokKomutu.yDegistir, sayi: 50),
  'change_y_up': BlokAnlami(BlokKomutu.yDegistir, sayi: 10),
  'goto_corner': BlokAnlami(BlokKomutu.gitXY, sayi: 200, sayi2: 150),
  'goto_center': BlokAnlami(BlokKomutu.gitXY, sayi: 0, sayi2: 0),
  'goto_random': BlokAnlami(BlokKomutu.etkisiz),

  // --- Gorunum -----------------------------------------------------
  'say_hello': BlokAnlami(BlokKomutu.soyle, metin: 'Merhaba'),
  'say_meow': BlokAnlami(BlokKomutu.soyle, metin: 'Miyav!'),
  'say_jump': BlokAnlami(BlokKomutu.soyle, metin: 'Zıpladın!'),

  // --- Kontrol -----------------------------------------------------
  'repeat_4': BlokAnlami(BlokKomutu.tekrarla, sayi: 4),
  'forever': BlokAnlami(BlokKomutu.surekli),
  'wait_2': BlokAnlami(BlokKomutu.bekle, sayi: 2),
  'if_space': BlokAnlami(BlokKomutu.eger),
  'if_right': BlokAnlami(BlokKomutu.eger),
  'if_up': BlokAnlami(BlokKomutu.eger),
  'if_touching': BlokAnlami(BlokKomutu.eger),
  'create_clone': BlokAnlami(BlokKomutu.etkisiz),
  'delete_clone': BlokAnlami(BlokKomutu.etkisiz),

  // --- Degiskenler -------------------------------------------------
  'set_score_0': BlokAnlami(BlokKomutu.degiskenAta, degisken: 'Puan', sayi: 0),
  'change_score':
      BlokAnlami(BlokKomutu.degiskenArtir, degisken: 'Puan', sayi: 1),

  // --- Ses ---------------------------------------------------------
  'play_sound': BlokAnlami(BlokKomutu.etkisiz),
  'play_note_60': BlokAnlami(BlokKomutu.etkisiz),
  'play_note_62': BlokAnlami(BlokKomutu.etkisiz),
  'play_note_64': BlokAnlami(BlokKomutu.etkisiz),

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
  'if_score_low': BlokAnlami(BlokKomutu.eger),
  'lt_score_5': BlokAnlami(BlokKomutu.etkisiz),
  'lt_5_score': BlokAnlami(BlokKomutu.etkisiz),
  'say_keep_going': BlokAnlami(BlokKomutu.soyle, metin: 'Devam et!'),

  // --- Listeler (10.1) ---------------------------------------------
  'add_apple':
      BlokAnlami(BlokKomutu.listeyeEkle, liste: 'alışveriş', metin: 'elma'),
  'add_banana':
      BlokAnlami(BlokKomutu.listeyeEkle, liste: 'alışveriş', metin: 'muz'),
  'delete_first':
      BlokAnlami(BlokKomutu.listedenSil, liste: 'alışveriş', sayi: 1),
  // 10.2: soylenen sey listenin rastgele bir ogesi. Liste o adimda bos
  // oldugu icin uydurma bir soru yazmiyoruz — blok akista gorunuyor,
  // sahne degismiyor.
  'say_random_question': BlokAnlami(BlokKomutu.etkisiz),
  'len_questions': BlokAnlami(BlokKomutu.etkisiz),
  'item_1_questions': BlokAnlami(BlokKomutu.etkisiz),

  // --- Kalem ve cizim (8.1 / 8.2) ----------------------------------
  'pen_down': BlokAnlami(BlokKomutu.kalemIndir),
  'pen_up': BlokAnlami(BlokKomutu.kalemKaldir),
  'pen_clear': BlokAnlami(BlokKomutu.kalemSil),
  'move_100': BlokAnlami(BlokKomutu.ilerle, sayi: 100),
  'move_100_poly': BlokAnlami(BlokKomutu.ilerle, sayi: 100),
  'turn_90': BlokAnlami(BlokKomutu.don, sayi: 90),
  'turn_120': BlokAnlami(BlokKomutu.don, sayi: 120),
  'turn_60_extra': BlokAnlami(BlokKomutu.don, sayi: 60),
  'turn_90_fixed': BlokAnlami(BlokKomutu.don, sayi: 90),
  // 360/kenar: kenar bir girdi, degeri cagri aninda belli oluyor.
  // Yorumlayici cagri yapmiyor, bu yuzden aciyi hesaplayamiyor.
  'turn_360_over_sides': BlokAnlami(BlokKomutu.etkisiz),
  'repeat_3': BlokAnlami(BlokKomutu.tekrarla, sayi: 3),
  // 11.2: "kenar kere tekrarla" — tekrar sayisi bir girdi.
  'repeat_sides': BlokAnlami(BlokKomutu.etkisiz),

  // --- Kendi blogun (11) -------------------------------------------
  // Tanim bir tarif: kendi basina calismaz. Cagri ise tanimin govdesini
  // calistirir — yorumlayici henuz yordam cagrisi yapmiyor, o yuzden
  // ikisi de akista gorunuyor ama sahneyi degistirmiyor.
  'define_square': BlokAnlami(BlokKomutu.etkisiz),
  'define_square_2': BlokAnlami(BlokKomutu.etkisiz),
  'define_polygon': BlokAnlami(BlokKomutu.etkisiz),
  'call_square': BlokAnlami(BlokKomutu.etkisiz),
  'call_polygon_6': BlokAnlami(BlokKomutu.etkisiz),
  'call_polygon_4': BlokAnlami(BlokKomutu.etkisiz),

  // --- Akvaryum projesi (mBlock 5. modul) --------------------------
  // Sayilar tool/mblock_projeleri/akvaryum.mblock dosyasindan.
  'point_55': BlokAnlami(BlokKomutu.yonAyarla, sayi: 55),
  'move_2_fish': BlokAnlami(BlokKomutu.ilerle, sayi: 2),
  'repeat_10_fish': BlokAnlami(BlokKomutu.tekrarla, sayi: 10),
  // Sahnenin kenari modellenmedigi icin sekme sahneyi degistirmiyor;
  // uydurmak yerine "gorunur etkisi yok" diyoruz.
  'edge_bounce': BlokAnlami(BlokKomutu.etkisiz),
  'rot_left_right': BlokAnlami(BlokKomutu.etkisiz),
  'rot_all_around': BlokAnlami(BlokKomutu.etkisiz),
  'sound_bubbles': BlokAnlami(BlokKomutu.etkisiz),
  'wait_1_ses': BlokAnlami(BlokKomutu.bekle, sayi: 1),

  // --- Dans Partisi projesi ----------------------------------------
  'next_costume': BlokAnlami(BlokKomutu.sonrakiKostum),
  'wait_02': BlokAnlami(BlokKomutu.bekle, sayi: 0.2),
  'wait_05': BlokAnlami(BlokKomutu.bekle, sayi: 0.5),
  'sound_hiphop': BlokAnlami(BlokKomutu.etkisiz),
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
  'show': BlokAnlami(BlokKomutu.etkisiz),
  'hide': BlokAnlami(BlokKomutu.etkisiz),
  'if_touching_kase': BlokAnlami(BlokKomutu.etkisiz),
  // 'change_score' ve 'delete_clone' Scratch kursunda zaten var;
  // puan blogu burada kendi kimligiyle, silme ayni anlamla paylasiliyor.
  'change_toplananelma': BlokAnlami(BlokKomutu.degiskenArtir,
      degisken: 'toplananelma', sayi: 1),
};
