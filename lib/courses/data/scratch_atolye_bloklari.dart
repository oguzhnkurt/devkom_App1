import 'package:flutter/material.dart';

import '../models/interactive_lesson_model.dart';

/// Proje Atolyesi'nin ve ic ice blok adimlarinin bloklari.
///
/// Gorunum Scratch 3'un kendisi (bkz. ScratchBlokKatalogu); burada
/// yalnizca kimlik, sekil ve dort dilde duz etiket var (ekran okuyucu,
/// eski cizim ve testler icin). Anlamlari blok_sozlugu.dart'ta.
class AtolyeBloklari {
  AtolyeBloklari._();

  static const Color _olaylar = Color(0xFFFFBF00);
  static const Color _hareket = Color(0xFF4C97FF);
  static const Color _gorunum = Color(0xFF9966FF);
  static const Color _kontrol = Color(0xFFFFAB19);
  static const Color _degisken = Color(0xFFFF8C1A);
  static const Color _liste = Color(0xFFFF661A);
  static const Color _kalem = Color(0xFF0FBD8C);
  static const Color _bloklarim = Color(0xFFFF6680);

  static ScratchBlock _y(String id, ScratchBlockType tur, Color renk,
          String tr, String en, String de, String es,
          {ScratchBlockShape sekil = ScratchBlockShape.stack}) =>
      ScratchBlock(
        id: id,
        blockType: tur,
        shape: sekil,
        label: tr,
        labelEn: en,
        labelDe: de,
        labelEs: es,
        color: renk,
      );

  // --- Olaylar -------------------------------------------------------
  static final bayrak = _y(
      'green_flag',
      ScratchBlockType.events,
      _olaylar,
      'yeşil bayrağa tıklandığında',
      'when green flag clicked',
      'Wenn die grüne Flagge angeklickt wird',
      'al hacer clic en la bandera verde',
      sekil: ScratchBlockShape.cap);
  static final bosluktaTus = _y(
      'when_key_space',
      ScratchBlockType.events,
      _olaylar,
      'boşluk tuşuna basılınca',
      'when space key pressed',
      'Wenn Taste Leertaste gedrückt wird',
      'al presionar tecla espacio',
      sekil: ScratchBlockShape.cap);
  static final sagTus = _y(
      'when_key_right',
      ScratchBlockType.events,
      _olaylar,
      'sağ ok tuşuna basılınca',
      'when right arrow key pressed',
      'Wenn Taste Pfeil nach rechts gedrückt wird',
      'al presionar tecla flecha derecha',
      sekil: ScratchBlockShape.cap);
  static final kuklayaTiklama = _y(
      'when_clicked_sprite',
      ScratchBlockType.events,
      _olaylar,
      'bu kuklaya tıklandığında',
      'when this sprite clicked',
      'Wenn diese Figur angeklickt wird',
      'al hacer clic en este objeto',
      sekil: ScratchBlockShape.cap);
  static final dansSal = _y('broadcast_dance', ScratchBlockType.events,
      _olaylar, 'dans haberini sal', 'broadcast dance', 'sende Tanz an alle',
      'enviar baile');
  static final dansAl = _y(
      'receive_dance',
      ScratchBlockType.events,
      _olaylar,
      'dans haberini aldığımda',
      'when I receive dance',
      'Wenn ich Tanz empfange',
      'al recibir baile',
      sekil: ScratchBlockShape.cap);

  // --- Hareket -------------------------------------------------------
  static final git10 = _y('move_10', ScratchBlockType.motion, _hareket,
      '10 adım git', 'move 10 steps', 'gehe 10 er Schritt', 'mover 10 pasos');
  static final git100 = _y('move_100', ScratchBlockType.motion, _hareket,
      '100 adım git', 'move 100 steps', 'gehe 100 er Schritt',
      'mover 100 pasos');
  static final don90 = _y('turn_90', ScratchBlockType.motion, _hareket,
      '↻ 90 derece dön', 'turn ↻ 90 degrees', 'drehe dich ↻ um 90 Grad',
      'girar ↻ 90 grados');
  static final xDegistir = _y('change_x', ScratchBlockType.motion, _hareket,
      'x konumunu 10 değiştir', 'change x by 10', 'ändere x um 10',
      'cambiar x por 10');
  static final yYukari = _y('change_y_up', ScratchBlockType.motion, _hareket,
      'y konumunu 10 değiştir', 'change y by 10', 'ändere y um 10',
      'cambiar y por 10');
  static final yAsagi = _y('change_y_down', ScratchBlockType.motion,
      _hareket, 'y konumunu -10 değiştir', 'change y by -10',
      'ändere y um -10', 'cambiar y por -10');
  static final ortayaGit = _y('goto_center', ScratchBlockType.motion,
      _hareket, 'x: 0 y: 0 konumuna git', 'go to x: 0 y: 0',
      'gehe zu x: 0 y: 0', 'ir a x: 0 y: 0');
  static final tepeyeGit = _y('goto_top', ScratchBlockType.motion, _hareket,
      'x: 0 y: 150 konumuna git', 'go to x: 0 y: 150',
      'gehe zu x: 0 y: 150', 'ir a x: 0 y: 150');
  static final rastgeleGit = _y('goto_random', ScratchBlockType.motion,
      _hareket, 'rastgele konuma git', 'go to random position',
      'gehe zu Zufallsposition', 'ir a posición aleatoria');

  // --- Gorunum -------------------------------------------------------
  static final merhabaDe = _y('say_hello', ScratchBlockType.looks, _gorunum,
      'Merhaba! de', 'say Hello!', 'sage Hallo!', 'decir ¡Hola!');
  static final zipladinDe = _y('say_jump', ScratchBlockType.looks, _gorunum,
      'Zıpladın! de', 'say You jumped!', 'sage Du bist gesprungen!',
      'decir ¡Saltaste!');
  static final kazandinDe = _y('say_win', ScratchBlockType.looks, _gorunum,
      'Kazandın! de', 'say You win!', 'sage Gewonnen!', 'decir ¡Ganaste!');
  static final tekrarDeneDe = _y('say_try_again', ScratchBlockType.looks,
      _gorunum, 'Tekrar dene! de', 'say Try again!',
      'sage Versuch es nochmal!', 'decir ¡Inténtalo otra vez!');
  static final sureBittiDe = _y('say_time_up', ScratchBlockType.looks,
      _gorunum, 'Süre bitti! de', 'say Time is up!',
      'sage Die Zeit ist um!', 'decir ¡Se acabó el tiempo!');
  static final puaniDe = _y('say_score', ScratchBlockType.looks, _gorunum,
      'Puan de', 'say Score', 'sage Punkte', 'decir Puntos');
  static final zariDe = _y('say_dice', ScratchBlockType.looks, _gorunum,
      'zar de', 'say dice', 'sage Würfel', 'decir dado');
  static final listeUzunluguDe = _y(
      'say_len_shopping',
      ScratchBlockType.looks,
      _gorunum,
      'alışveriş in uzunluğu de',
      'say length of shopping',
      'sage Länge von Einkauf',
      'decir longitud de compra');
  static final sonrakiKostum = _y('next_costume', ScratchBlockType.looks,
      _gorunum, 'sonraki kostüm', 'next costume',
      'wechsle zum nächsten Kostüm', 'siguiente disfraz');

  // --- Kontrol -------------------------------------------------------
  static ScratchBlock tekrarla(String n) => _y(
      'repeat_$n',
      ScratchBlockType.control,
      _kontrol,
      '$n defa tekrarla',
      'repeat $n',
      'wiederhole $n mal',
      'repetir $n',
      sekil: ScratchBlockShape.cBlock);
  static final surekli = _y('forever', ScratchBlockType.control, _kontrol,
      'sürekli tekrarla', 'forever', 'wiederhole fortlaufend', 'por siempre',
      sekil: ScratchBlockShape.cBlock);
  static final bekle1 = _y('wait_1s', ScratchBlockType.control, _kontrol,
      '1 saniye bekle', 'wait 1 seconds', 'warte 1 Sekunden',
      'esperar 1 segundos');
  static final bekle2 = _y('wait_2', ScratchBlockType.control, _kontrol,
      '2 saniye bekle', 'wait 2 seconds', 'warte 2 Sekunden',
      'esperar 2 segundos');
  static final egerZarBuyuk3 = _y(
      'ifelse_dice_gt_3',
      ScratchBlockType.control,
      _kontrol,
      'eğer zar > 3 ise / değilse',
      'if dice > 3 then / else',
      'falls Würfel > 3, dann / sonst',
      'si dado > 3 entonces / si no',
      sekil: ScratchBlockShape.cBlock);
  static final egerPuan50 = _y(
      'if_score_50',
      ScratchBlockType.control,
      _kontrol,
      'eğer puan = 50 ise',
      'if score = 50 then',
      'falls Punkte = 50, dann',
      'si puntos = 50 entonces',
      sekil: ScratchBlockShape.cBlock);
  static final egerSure0 = _y(
      'if_time_0',
      ScratchBlockType.control,
      _kontrol,
      'eğer süre = 0 ise',
      'if time = 0 then',
      'falls Zeit = 0, dann',
      'si tiempo = 0 entonces',
      sekil: ScratchBlockShape.cBlock);
  static final egerDokunuyor = _y(
      'if_touching',
      ScratchBlockType.control,
      _kontrol,
      'eğer Fare e değiyor mu? ise',
      'if touching Mouse? then',
      'falls wird Maus berührt?, dann',
      'si ¿tocando Ratón? entonces',
      sekil: ScratchBlockShape.cBlock);

  // --- Degiskenler ve listeler ----------------------------------------
  static final puanSifir = _y('set_score_0', ScratchBlockType.variables,
      _degisken, 'Puan değişkenini 0 yap', 'set Score to 0',
      'setze Punkte auf 0', 'dar a Puntos el valor 0');
  static final puanArtir = _y('change_score', ScratchBlockType.variables,
      _degisken, 'Puan i 1 kadar değiştir', 'change Score by 1',
      'ändere Punkte um 1', 'sumar a Puntos 1');
  static final zarAt = _y(
      'set_dice_random',
      ScratchBlockType.variables,
      _degisken,
      'zar değişkenini 1 ile 6 arasında rastgele bir sayı seç yap',
      'set dice to pick random 1 to 6',
      'setze Würfel auf Zufallszahl von 1 bis 6',
      'dar a dado el valor número aleatorio entre 1 y 6');
  static final sure5 = _y('set_time_5', ScratchBlockType.variables, _degisken,
      'süre değişkenini 5 yap', 'set time to 5', 'setze Zeit auf 5',
      'dar a tiempo el valor 5');
  static final sureAzalt = _y('change_time_down', ScratchBlockType.variables,
      _degisken, 'süre i -1 kadar değiştir', 'change time by -1',
      'ändere Zeit um -1', 'sumar a tiempo -1');
  static final sureArtir = _y('change_time_up', ScratchBlockType.variables,
      _degisken, 'süre i 1 kadar değiştir', 'change time by 1',
      'ändere Zeit um 1', 'sumar a tiempo 1');
  static final elmaEkle = _y('add_apple', ScratchBlockType.variables, _liste,
      'elma i alışveriş ye ekle', 'add apple to shopping',
      'füge Apfel zu Einkauf hinzu', 'añadir manzana a compra');
  static final muzEkle = _y('add_banana', ScratchBlockType.variables, _liste,
      'muz i alışveriş ye ekle', 'add banana to shopping',
      'füge Banane zu Einkauf hinzu', 'añadir plátano a compra');
  static final sutEkle = _y('add_milk', ScratchBlockType.variables, _liste,
      'süt i alışveriş ye ekle', 'add milk to shopping',
      'füge Milch zu Einkauf hinzu', 'añadir leche a compra');
  static final ilkiniSil = _y('delete_first', ScratchBlockType.variables,
      _liste, 'alışveriş in 1 ini sil', 'delete 1 of shopping',
      'lösche 1 von Einkauf', 'borrar 1 de compra');

  // --- Kalem ---------------------------------------------------------
  static final sil = _y('pen_clear', ScratchBlockType.looks, _kalem, 'sil',
      'erase all', 'lösche alles', 'borrar todo');
  static final kalemIndir = _y('pen_down', ScratchBlockType.looks, _kalem,
      'kalem indir', 'pen down', 'schalte Stift ein', 'bajar lápiz');
  static final kalemKaldir = _y('pen_up', ScratchBlockType.looks, _kalem,
      'kalem kaldır', 'pen up', 'schalte Stift aus', 'subir lápiz');

  // --- Muzik ---------------------------------------------------------
  static ScratchBlock nota(String n) => _y(
      'play_note_$n',
      ScratchBlockType.sound,
      _kalem,
      '$n notasını 0.5 vuruş çal',
      'play note $n for 0.5 beats',
      'spiele Ton $n für 0.5 Schläge',
      'tocar nota $n durante 0.5 pulsos');

  // --- Bloklarim -----------------------------------------------------
  static final cokgenTanimla = _y(
      'define_polygon',
      ScratchBlockType.myBlocks,
      _bloklarim,
      'çokgen (kenar) i tanımla',
      'define polygon (sides)',
      'Definiere Vieleck (Seiten)',
      'definir polígono (lados)',
      sekil: ScratchBlockShape.cap);
  static final kenarKereTekrarla = _y(
      'repeat_sides',
      ScratchBlockType.control,
      _kontrol,
      'kenar defa tekrarla',
      'repeat sides',
      'wiederhole Seiten mal',
      'repetir lados',
      sekil: ScratchBlockShape.cBlock);
  static final cokgenGit = _y('move_100_poly', ScratchBlockType.motion,
      _hareket, '100 adım git', 'move 100 steps', 'gehe 100 er Schritt',
      'mover 100 pasos');
  static final kenaraGoreDon = _y(
      'turn_360_over_sides',
      ScratchBlockType.motion,
      _hareket,
      '↻ 360 / kenar derece dön',
      'turn ↻ 360 / sides degrees',
      'drehe dich ↻ um 360 / Seiten Grad',
      'girar ↻ 360 / lados grados');
  static final cokgen6 = _y('call_polygon_6', ScratchBlockType.myBlocks,
      _bloklarim, 'çokgen 6', 'polygon 6', 'Vieleck 6', 'polígono 6');
}
