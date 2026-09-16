// Sag-Sol oyunu icin kaynak okuyan koruma testleri.
//
// Bu dosyadaki kontroller gorsel ya da davranissal: widget testiyle
// yakalanmalari zor, sessizce geri gelmeleri kolay. Bu yuzden dogrudan
// kaynagi okuyup degismez kurallari dogruluyoruz.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const yol = 'lib/screens/games/left_right_coding_game_screen.dart';
  late String kaynak;

  setUpAll(() {
    kaynak = File(yol).readAsStringSync();
  });

  test('yon tuslari tek renk ve tek boyut', () {
    // Eskiden dort dikdortgen vardi ve her biri BASKA renkteydi: yukari
    // mavi, sol turuncu, asagi KIRMIZI, sag yesil. Kirmizi bir "asagi"
    // tusu cocuga tehlike diye okunuyor, yesil "sag" ise dogru cevap
    // gibi — halbuki dordu de ayni seyin dort yonu. Yon pedi tek renk.
    final panel = kaynak.substring(
      kaynak.indexOf('Widget _yonPaneli()'),
      kaynak.indexOf('Widget _yonTusu('),
    );
    for (final renk in ['Colors.red', 'Colors.orange', 'Colors.green']) {
      expect(panel.contains(renk), isFalse,
          reason: 'yon tuslarinda $renk — yon bir deger yargisi degil');
    }

    final tus = kaynak.substring(kaynak.indexOf('Widget _yonTusu('));
    expect(tus.contains('AppTheme.primaryBlue'), isTrue);
    // 64x64: Apple'in 44pt alt sinirinin belirgin ustunde.
    expect(RegExp(r'width: 64,\s*height: 64,').hasMatch(tus), isTrue,
        reason: 'yon tusu 64x64 degil');
  });

  test('yon tuslarinda tasabilecek metin yok', () {
    // Eski tasarimda her tusun icinde buyuk harfli bir etiket vardi
    // ("IZQUIERDA") ve dar telefonlarda tasiyordu. Etiket artik
    // Semantics'e tasindi: ekran okuyucu duyuyor, piksel tasmiyor.
    final tus = kaynak.substring(kaynak.indexOf('Widget _yonTusu('));
    final govde = tus.substring(0, tus.indexOf('\n  }'));
    expect(govde.contains('Text('), isFalse,
        reason: 'yon tusunun icinde metin var; tasma geri gelebilir');
    expect(govde.contains('Semantics('), isTrue,
        reason: 'etiket erisilebilirlik icin Semantics ile verilmeli');
  });

  test('kukla secimi oyundaki cizimin aynisini gosteriyor', () {
    // Eskiden emoji vardi: cocuk 🦊 secip tahtada bambaska cizilmis bir
    // tilki goruyordu. Secilen sey ile oynanan sey ayni olmali.
    final secim = kaynak.substring(
      kaynak.indexOf('_showPuppetSelectionDialog'),
      kaynak.indexOf('void _handleGameStart('),
    );
    expect(secim.contains('KuklaOnizleme('), isTrue);
    expect(secim.contains('puppet.emoji'), isFalse,
        reason: 'secim ekrani hala emoji gosteriyor');
  });

  test('tahta cizgileri zeminin altinda kalmiyor', () {
    // GridBackground once cizgileri, SONRA damali zemini ciziyordu;
    // zemin cizgilerin ustunu kapattigi icin cizgiler hicbir zaman
    // gorunmedi. Olu cizim silindi, izgara hissi bosluktan geliyor.
    final zemin = kaynak.substring(
      kaynak.indexOf('class GridBackground'),
      kaynak.indexOf('/// Robot Player Component'),
    );
    expect(zemin.contains('drawLine'), isFalse,
        reason: 'gorunmeyen izgara cizgileri geri gelmis');
    expect(zemin.contains('drawRRect'), isTrue);
  });

  test('olu "Siralama Gor" tusu yok', () {
    // Arkasindaki liderlik tablosu Supabase gecisinde kaldirilmisti;
    // tus cocugu oyundan disari atiyordu.
    expect(kaynak.contains('Sıralama Gör'), isFalse);
    expect(kaynak.contains('_showRankDisplay'), isFalse);
    expect(kaynak.contains('Tekrar Oyna'), isTrue);
  });

  test('yanlis cevapta puan kesilmiyor', () {
    expect(RegExp(r'_totalScore\s*=\s*\(_totalScore\s*-').hasMatch(kaynak),
        isFalse,
        reason: 'Ceza puani cocugu denemekten cekindirir.');
    expect(kaynak.contains(r'-$points'), isFalse);
  });

  test('soru bankasi dort dilde', () {
    final en = RegExp(r"'questionEn':").allMatches(kaynak).length;
    final de = RegExp(r"'questionDe':").allMatches(kaynak).length;
    final es = RegExp(r"'questionEs':").allMatches(kaynak).length;
    expect(en, greaterThan(0));
    expect(de, en, reason: 'Her sorunun Almancasi olmali.');
    expect(es, en, reason: 'Her sorunun Ispanyolcasi olmali.');

    final oEn = RegExp(r"'optionsEn':").allMatches(kaynak).length;
    expect(RegExp(r"'optionsDe':").allMatches(kaynak).length, oEn);
    expect(RegExp(r"'optionsEs':").allMatches(kaynak).length, oEn);
    expect(oEn, en, reason: 'Soru sayisi ile secenek sayisi tutmuyor.');
  });

  test('oyun motoruna dil kodu gidiyor, iki dillik bayrak degil', () {
    expect(kaynak.contains('isEnglish'), isFalse,
        reason: 'bool isEnglish Almanca/Ispanyolca oyuncuya Ingilizce gosterir.');
    expect(kaynak.contains('lang: _lang'), isTrue);
    expect(kaynak.contains("{String lang = 'tr'}"), isTrue);
  });
}
