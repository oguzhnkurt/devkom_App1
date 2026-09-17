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
};
