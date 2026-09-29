/*
 * mBlock blok katalogu — dort dilde, mBlock'un KENDI etiketleriyle.
 *
 * NEDEN BURADA
 * ------------
 * scratch-blocks'un kendi hazir Scratch bloklari (control_wait,
 * motion_movesteps...) iki sebeple kullanilmiyor:
 *
 *  1. Etiketleri Scratch'in etiketleri. mBlock'un donanim bloklari
 *     (dijital ayarla, seri port, mesafe algilayici) zaten orada yok;
 *     olanlarin da Turkcesi mBlock'taki yazinin birebir ayni olmayabilir.
 *  2. Renklerini temadan aliyorlar ve tema kurulmadan SIYAH ciziliyorlar.
 *     Kendi tanimimizda renk blogun icinde duruyor.
 *
 * Buradaki her etiket ve renk `lib/courses/data/mblock_palette.dart`
 * ile birebir ayni olmali; o dosya da mBlock'un kendi Arduino Uno cihaz
 * paketinden ve Turkce dil dosyasindan alinmisti. Ikisi ayrisirsa
 * test/mblock_blok_katalogu_test.dart duser.
 */
(function (global) {
  'use strict';

  // Renkler: [ana, orta, koyu]. Orta ve koyu tonlar bloklarin kenarligi
  // ve girinti golgesi icin; Scratch bunlari ayri ayri istiyor.
  var R = {
    pin:      ['#4A90E2', '#3F7CC4', '#33639E'],
    seriPort: ['#7ED321', '#6BB41C', '#569117'],
    veri:     ['#BD10E0', '#A00EBE', '#800B98'],
    sensor:   ['#4CBFE6', '#40A2C4', '#33829D'],
    olaylar:  ['#FFBF00', '#E6AC00', '#CC9900'],
    kontrol:  ['#FFAB19', '#E69B16', '#CF8B17'],
    islemler: ['#59C059', '#46B946', '#389438'],
    degisken: ['#FF8C1A', '#DB7615', '#B45F11'],
    hareket:  ['#4C97FF', '#4280D7', '#3373CC'],
    gorunum:  ['#9966FF', '#855CD6', '#774DCB'],
    // Ses kategorisi kukla tarafinda; mBlock'un kendi pembesi.
    ses:      ['#CF63CF', '#B14FB1', '#8F3F8F'],
    // Kukla tarafinin Algilama'si. Cihazin "sensor" mavisiyle ayni
    // DEGIL (#4CBFE6): bu Scratch 3.0'in kendi Algilama rengi.
    algilama: ['#5CB1D6', '#47A6CE', '#2E8EB8']
  };

  // Yuva tipleri.
  //  sayi   → oval sayi kutusu (golge blok: math_number)
  //  tamsayi→ yalnizca tam sayi (math_whole_number)
  //  pozitif→ 0'dan buyuk (math_positive_number)
  //  metin  → oval metin kutusu (text)
  //  secim  → acilir liste (field_dropdown, golge blok DEGIL)
  //  kosul  → altigen yuva (input_value, check: 'Boolean')
  function yuva(ad, tip, varsayilan, secenekler) {
    return { ad: ad, tip: tip, varsayilan: varsayilan, secenekler: secenekler };
  }

  /*
   * Etiketler: %1, %2 ... yuvalarin yerini tutuyor. Sira dile gore
   * degisebilir — Almanca "digitalen Pin von Ausgang %1 als %2 setzen"
   * gibi. Bu yuzden her dil ayri bir dize, cevrilmis bir sablon degil.
   */
  var BLOKLAR = [
    // ---------------------------------------------------------- Olaylar
    {
      id: 'dev_bayrak', kategori: 'olaylar', sekil: 'sapka', yuvalar: [],
      tr: '%1 tıklandığında', en: 'when %1 clicked',
      de: 'wenn %1 angeklickt', es: 'al hacer clic en %1',
      bayrakSimgesi: true
    },
    {
      // DIKKAT: bu blogun Turkcesi YOK. mBlock'un Turkce dil dosyasinda
      // deger Ingilizce metnin aynisi; uydurma bir Turkce isim koymuyoruz.
      id: 'dev_kart_acilis', kategori: 'olaylar', sekil: 'sapka', yuvalar: [],
      tr: 'when Arduino Uno starts up', en: 'when Arduino Uno starts up',
      de: 'wenn Arduino Uno startet', es: 'cuando Arduino Uno se inicia'
    },

    // ---------------------------------------------------------- Kontrol
    {
      id: 'dev_surekli', kategori: 'kontrol', sekil: 'cson', yuvalar: [],
      tr: 'sürekli tekrarla', en: 'forever',
      de: 'wiederhole fortlaufend', es: 'por siempre'
    },
    {
      id: 'dev_tekrarla', kategori: 'kontrol', sekil: 'c',
      yuvalar: [yuva('KERE', 'tamsayi', 10)],
      tr: '%1 defa tekrarla', en: 'repeat %1',
      de: 'wiederhole %1 mal', es: 'repetir %1'
    },
    {
      id: 'dev_bekle', kategori: 'kontrol', sekil: 'duz',
      yuvalar: [yuva('SANIYE', 'pozitif', 1)],
      tr: '%1 saniye bekle', en: 'wait %1 seconds',
      de: 'warte %1 Sekunden', es: 'esperar %1 segundos'
    },
    {
      id: 'dev_eger', kategori: 'kontrol', sekil: 'c',
      yuvalar: [yuva('KOSUL', 'kosul')],
      tr: 'eğer %1 ise', en: 'if %1 then',
      de: 'falls %1, dann', es: 'si %1 entonces'
    },

    // -------------------------------------------------------------- Pin
    {
      id: 'dev_dijital_yaz', kategori: 'pin', sekil: 'duz',
      yuvalar: [
        yuva('PIN', 'secim', '9', [['0','0'],['1','1'],['2','2'],['3','3'],
          ['4','4'],['5','5'],['6','6'],['7','7'],['8','8'],['9','9'],
          ['10','10'],['11','11'],['12','12'],['13','13']]),
        yuva('SEVIYE', 'secim', 'HIGH', {
          tr: [['yüksek','HIGH'],['düşük','LOW']],
          en: [['high','HIGH'],['low','LOW']],
          de: [['hoch','HIGH'],['niedrig','LOW']],
          es: [['alto','HIGH'],['bajo','LOW']]
        })
      ],
      tr: 'dijital ayarla pin %1 çıkış %2',
      en: 'set digital pin %1 output as %2',
      de: 'digitalen Pin von Ausgang %1 als %2 setzen',
      es: 'pon el pin digital %1 a %2'
    },
    {
      id: 'dev_pwm_yaz', kategori: 'pin', sekil: 'duz',
      yuvalar: [
        // PWM yalnizca bu pinlerde var — mBlock'ta da liste bu.
        yuva('PIN', 'secim', '5', [['3','3'],['5','5'],['6','6'],
          ['9','9'],['10','10'],['11','11']]),
        yuva('GUC', 'tamsayi', 128)
      ],
      tr: 'PWM ayarla pin%1 çıkış %2', en: 'set PWM %1 output as %2',
      de: 'PWM-Ausgang %1 als %2 festlegen', es: 'pon la salida PWM %1 a %2'
    },
    {
      id: 'dev_dijital_oku', kategori: 'pin', sekil: 'altigen',
      yuvalar: [yuva('PIN', 'secim', '2', [['2','2'],['3','3'],['4','4'],
        ['5','5'],['6','6'],['7','7'],['8','8'],['9','9'],['10','10'],
        ['11','11'],['12','12'],['13','13']])],
      tr: 'dijital oku pin %1', en: 'read digital pin %1',
      de: 'Digitalpin lesen %1', es: 'lee pin digital %1'
    },
    {
      id: 'dev_analog_oku', kategori: 'pin', sekil: 'oval',
      yuvalar: [yuva('PIN', 'secim', '0', [['0','0'],['1','1'],['2','2'],
        ['3','3'],['4','4'],['5','5']])],
      tr: 'analog oku pin (A) %1', en: 'read analog pin (A) %1',
      de: 'analogen Pin（A）%1 lesen', es: 'lee pin analógico %1'
    },
    {
      id: 'dev_servo', kategori: 'pin', sekil: 'duz',
      yuvalar: [
        yuva('PIN', 'secim', '9', [['3','3'],['5','5'],['6','6'],
          ['9','9'],['10','10'],['11','11']]),
        yuva('ACI', 'tamsayi', 90)
      ],
      tr: 'servo pin %1 açı %2', en: 'set servo pin %1 angle as %2',
      de: 'setze Servo an Anschluss %1 auf Winkel %2',
      es: 'mueve el servo en pin %1 al ángulo %2'
    },

    // -------------------------------------------------------- seri port
    {
      id: 'dev_seri_yaz', kategori: 'seriPort', sekil: 'duz',
      yuvalar: [yuva('METIN', 'metin', 'merhaba')],
      tr: 'seri port %1 yaz', en: 'serial write %1',
      de: 'serieller Port schreibt %1', es: 'puerto serie escribe %1'
    },

    // ----------------------------------------------------------- Sensör
    {
      // Turkce etiketteki kutu/yazi sirasi mBlock'ta gercekten boyle:
      // once sayi kutusu, sonra "trig pin" yazisi geliyor.
      id: 'dev_mesafe', kategori: 'sensor', sekil: 'oval',
      yuvalar: [yuva('TRIG', 'tamsayi', 13), yuva('ECHO', 'tamsayi', 12)],
      tr: 'mesafe algılayıcı %1 trig pin %2 echo pin',
      en: 'read ultrasonic sensor trig pin %1 echo pin %2',
      de: 'Ultraschallsensor Trig-Pin %1 Echo-Pin %2 lesen',
      es: 'lee el sensor de distancia pin trig %1 pin echo %2'
    },

    // ------------------------------------------------------------- Veri
    {
      id: 'dev_harita', kategori: 'veri', sekil: 'oval',
      yuvalar: [yuva('DEGER', 'sayi', 0), yuva('A', 'sayi', 0),
        yuva('B', 'sayi', 1023), yuva('C', 'sayi', 0), yuva('D', 'sayi', 255)],
      tr: 'harita %1 den [%2 , %3] e [%4 , %5]',
      en: 'map %1 from [%2 , %3] to [%4 , %5]',
      de: 'ordne %1 von [%2 , %3] zu [%4 , %5]',
      es: 'mapea %1 de [%2 , %3] a [%4 , %5]'
    },

    // --------------------------------------------------------- Islemler
    {
      // mBlock'ta ve Scratch'te bu blok bir ALTIGEN ve icine baska bir
      // altigen alir: <<dijital oku pin 2> değil>.
      id: 'dev_degil', kategori: 'islemler', sekil: 'altigen',
      yuvalar: [yuva('KOSUL', 'kosul')],
      tr: '%1 değil', en: 'not %1', de: 'nicht %1', es: 'no %1'
    },

    // ------------------------------------------------------ Degiskenler
    {
      id: 'dev_degisken_yap', kategori: 'degisken', sekil: 'duz',
      yuvalar: [
        yuva('AD', 'secim', 'parlaklik', [['parlaklik', 'parlaklik']]),
        yuva('DEGER', 'sayi', 0)
      ],
      tr: '%1 değişkenini %2 yap', en: 'set %1 to %2',
      de: 'setze %1 auf %2', es: 'dar a %1 el valor %2'
    },
    {
      // Degiskenin kendisi: oval, bir deger soyler.
      id: 'dev_degisken_oku', kategori: 'degisken', sekil: 'oval',
      yuvalar: [],
      tr: 'parlaklik', en: 'brightness', de: 'helligkeit', es: 'brillo'
    },

    // ------------------------------------------- Kukla tarafi (modül 0)
    {
      id: 'dev_git', kategori: 'hareket', sekil: 'duz',
      yuvalar: [yuva('ADIM', 'sayi', 10)],
      tr: '%1 adım git', en: 'move %1 steps',
      de: 'gehe %1 er Schritt', es: 'mover %1 pasos'
    },
    {
      id: 'dev_don', kategori: 'hareket', sekil: 'duz',
      yuvalar: [yuva('ACI', 'sayi', 15)],
      tr: '↻ %1 derece dön', en: 'turn ↻ %1 degrees',
      de: 'drehe dich ↻ um %1 Grad', es: 'girar ↻ %1 grados'
    },
    {
      id: 'dev_de', kategori: 'gorunum', sekil: 'duz',
      yuvalar: [yuva('METIN', 'metin', 'Merhaba!')],
      tr: '%1 de', en: 'say %1', de: 'sage %1', es: 'decir %1'
    },
    {
      id: 'dev_boyut', kategori: 'gorunum', sekil: 'duz',
      yuvalar: [yuva('MIKTAR', 'sayi', 10)],
      tr: 'boyutu %1 değiştir', en: 'change size by %1',
      de: 'ändere Größe um %1', es: 'cambiar tamaño por %1'
    },

    // ------------------------------------------- Proje bloklari (5. modul)
    // Akvaryum ve Dans Partisi projeleri bu dortlusu olmadan tezgahta
    // kurulamiyordu. Etiketler yine mBlock'un kendi dil dosyasindan.
    {
      id: 'dev_yonune_don', kategori: 'hareket', sekil: 'duz',
      yuvalar: [yuva('YON', 'sayi', 90)],
      tr: '%1 yönüne dön', en: 'point in direction %1',
      de: 'setze Richtung auf %1 Grad', es: 'apuntar en dirección %1'
    },
    {
      id: 'dev_sek', kategori: 'hareket', sekil: 'duz', yuvalar: [],
      tr: 'kenara geldiyse sek', en: 'if on edge, bounce',
      de: 'pralle vom Rand ab', es: 'si toca un borde, rebotar'
    },
    {
      id: 'dev_kostum', kategori: 'gorunum', sekil: 'duz', yuvalar: [],
      tr: 'sonraki kostüm', en: 'next costume',
      de: 'wechsle zum nächsten Kostüm', es: 'siguiente disfraz'
    },
    {
      id: 'dev_ses_bitene', kategori: 'ses', sekil: 'duz',
      yuvalar: [yuva('SES', 'metin', 'Bubbles')],
      tr: '%1 sesini bitene kadar çal', en: 'play sound %1 until done',
      de: 'spiele Klang %1 ganz', es: 'tocar sonido %1 hasta que termine'
    },

    // ------------------------------------ Elma Toplama projesi (5. modul)
    // Ilk OYUN projesi: oyuncunun yonettigi kase, gokten dusen ikiz
    // elmalar, puan. Etiketler Scratch'in kendi dil dosyalarindan
    // (scratch-l10n editor/blocks): mBlock kukla bloklarini oradan
    // devraliyor. Turkcede "clone" = "ikiz" — mBlock'ta da yazan bu.
    {
      id: 'dev_x_yap', kategori: 'hareket', sekil: 'duz',
      yuvalar: [yuva('X', 'sayi', 0)],
      tr: 'x konumunu %1 yap', en: 'set x to %1',
      de: 'setze x auf %1', es: 'dar a x el valor %1'
    },
    {
      id: 'dev_y_yap', kategori: 'hareket', sekil: 'duz',
      yuvalar: [yuva('Y', 'sayi', 0)],
      tr: 'y konumunu %1 yap', en: 'set y to %1',
      de: 'setze y auf %1', es: 'dar a y el valor %1'
    },
    {
      id: 'dev_y_degistir', kategori: 'hareket', sekil: 'duz',
      yuvalar: [yuva('DY', 'sayi', 10)],
      tr: 'y konumunu %1 değiştir', en: 'change y by %1',
      de: 'ändere y um %1', es: 'sumar a y %1'
    },
    {
      id: 'dev_fare_x', kategori: 'algilama', sekil: 'oval', yuvalar: [],
      tr: 'farenin x i', en: 'mouse x',
      de: 'Maus x-Position', es: 'posición x del ratón'
    },
    {
      id: 'dev_dokunuyor', kategori: 'algilama', sekil: 'altigen',
      // Gorunen ad dile gore, DEGER hep 'Kase' (cozum onu bekliyor).
      yuvalar: [yuva('NESNE', 'secim', 'Kase', {
        tr: [['Kase', 'Kase']], en: [['Bowl', 'Kase']],
        de: [['Schüssel', 'Kase']], es: [['Cuenco', 'Kase']]
      })],
      tr: '%1 e değiyor mu?', en: 'touching %1?',
      de: 'wird %1 berührt?', es: '¿tocando %1?'
    },
    {
      id: 'dev_ikiz_basla', kategori: 'kontrol', sekil: 'sapka', yuvalar: [],
      tr: 'ikiz olarak başladığımda', en: 'when I start as a clone',
      de: 'Wenn ich als Klon entstehe', es: 'al comenzar como clon'
    },
    {
      // Scratch'te bu blok bir SON blok: altina bir sey takilmaz, cunku
      // ikiz silindikten sonra calisacak kimse kalmiyor.
      id: 'dev_ikizi_sil', kategori: 'kontrol', sekil: 'son', yuvalar: [],
      tr: 'bu ikizi sil', en: 'delete this clone',
      de: 'lösche diesen Klon', es: 'eliminar este clon'
    },
    {
      id: 'dev_goster', kategori: 'gorunum', sekil: 'duz', yuvalar: [],
      tr: 'göster', en: 'show', de: 'zeige dich', es: 'mostrar'
    },
    {
      id: 'dev_gizle', kategori: 'gorunum', sekil: 'duz', yuvalar: [],
      tr: 'gizle', en: 'hide', de: 'verstecke dich', es: 'esconder'
    },
    {
      // Degisken adi projedeki gibi: "toplananelma". Cocuk mBlock'ta
      // hangi adi yazdiysa listede o gorunur; burada dosyadakini
      // kullaniyoruz.
      id: 'dev_degisken_degistir', kategori: 'degisken', sekil: 'duz',
      yuvalar: [
        yuva('AD', 'secim', 'toplananelma', {
          tr: [['toplananelma', 'toplananelma']],
          en: [['score', 'toplananelma']],
          de: [['punkte', 'toplananelma']],
          es: [['puntos', 'toplananelma']]
        }),
        yuva('DEGER', 'sayi', 1)
      ],
      tr: '%1 i %2 kadar değiştir', en: 'change %1 by %2',
      de: 'ändere %1 um %2', es: 'sumar a %1 %2'
    }
  ];

  global.MBlockKatalog = { RENKLER: R, BLOKLAR: BLOKLAR };
})(this);
