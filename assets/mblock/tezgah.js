/*
 * mBlock tezgahi — katalogu scratch-blocks'a ceviren ve Flutter ile
 * konusan tutkal.
 *
 * FLUTTER ILE KONUSMA
 * -------------------
 *   Flutter → sayfa : `MBlockTezgah.kur(ayarJson)`
 *   sayfa  → Flutter: `TezgahKanali.postMessage(json)`
 *
 * Sayfa uygulamanin KENDI paketinden geliyor (`loadFlutterAsset`),
 * hicbir adrese cikilmiyor. Ucuncu tarafin sayfasina mudahale
 * yasagiyla ilgisi yok; bkz. test/embedded_webview_safety_test.dart.
 */
(function (global) {
  'use strict';

  var S = global.ScratchBlocks;
  var K = global.MBlockKatalog;
  var ws = null;
  var dil = 'tr';

  function bildir(tur, veri) {
    try {
      if (global.TezgahKanali && global.TezgahKanali.postMessage) {
        global.TezgahKanali.postMessage(
          JSON.stringify({ tur: tur, veri: veri === undefined ? null : veri }));
      }
    } catch (e) { /* kanal yoksa sessiz */ }
  }

  function etiket(b) { return b[dil] || b.en || b.tr; }

  /// Katalog girdisini scratch-blocks'un JSON tanimina cevirir.
  function tanim(b) {
    var renk = K.RENKLER[b.kategori];
    var t = {
      type: b.id,
      colour: renk[0], colourSecondary: renk[1], colourTertiary: renk[2],
      message0: etiket(b),
      args0: []
    };

    b.yuvalar.forEach(function (y) {
      if (y.tip === 'secim') {
        var ops = y.secenekler;
        // Secenek yazilari da dile gore degisebilir ("yüksek" / "high").
        if (ops && !Array.isArray(ops)) ops = ops[dil] || ops.en;
        t.args0.push({ type: 'field_dropdown', name: y.ad, options: ops });
      } else if (y.tip === 'kosul') {
        t.args0.push({ type: 'input_value', name: y.ad, check: 'Boolean' });
      } else {
        // Sayi ve metin girisleri ALAN degil, YUVA. Gercek Scratch'te de
        // oyle: icine baska bir blok (mesela "analog oku") takilabilsin
        // diye. Alan yapilirsa kutular bos goruluyor.
        t.args0.push({ type: 'input_value', name: y.ad });
      }
    });

    if (b.bayrakSimgesi) {
      // Yesil bayrak bir resim; metin icinde "%1" olarak duruyor.
      t.args0.unshift({
        type: 'field_image', src: 'media/green-flag.svg',
        width: 24, height: 24, alt: 'bayrak', flip_rtl: false
      });
      // Yuvalarin numaralari bir kaydi; etiketi yeniden yazmiyoruz
      // cunku bayrak bloklarinda baska yuva yok.
    }

    if (t.args0.length === 0) delete t.args0;

    switch (b.sekil) {
      case 'sapka':
        t.nextStatement = null;
        break;
      case 'duz':
        t.previousStatement = null; t.nextStatement = null;
        break;
      case 'c':
        t.previousStatement = null; t.nextStatement = null;
        t.message1 = '%1';
        t.args1 = [{ type: 'input_statement', name: 'ICERIK' }];
        break;
      case 'cson':
        // "sürekli tekrarla": ALTINA blok takilmaz, cunku program o
        // kutudan hic cikmaz.
        t.previousStatement = null;
        t.message1 = '%1';
        t.args1 = [{ type: 'input_statement', name: 'ICERIK' }];
        break;
      case 'oval':
        t.output = null; t.outputShape = 2;
        break;
      case 'altigen':
        t.output = 'Boolean'; t.outputShape = 1;
        break;
    }
    return t;
  }

  function golge(y) {
    switch (y.tip) {
      case 'tamsayi':
        return '<shadow type="math_whole_number"><field name="NUM">' +
          y.varsayilan + '</field></shadow>';
      case 'pozitif':
        return '<shadow type="math_positive_number"><field name="NUM">' +
          y.varsayilan + '</field></shadow>';
      case 'sayi':
        return '<shadow type="math_number"><field name="NUM">' +
          y.varsayilan + '</field></shadow>';
      case 'metin':
        return '<shadow type="text"><field name="TEXT">' +
          kacir(String(y.varsayilan)) + '</field></shadow>';
      default:
        return null; // secim ve kosul yuvalarinin golgesi yok
    }
  }

  function kacir(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  function aracKutusuXml(idler) {
    var parcalar = ['<xml>'];
    K.BLOKLAR.forEach(function (b) {
      if (idler && idler.indexOf(b.id) < 0) return;
      parcalar.push('<block type="' + b.id + '">');
      b.yuvalar.forEach(function (y) {
        if (y.tip === 'secim') {
          // Acilir listenin BASLANGIC degeri. Yazilmazsa Blockly listenin
          // ilk secenegini secer ve "dijital ayarla pin 0" gibi
          // ogretilenden baska bir blok cikar.
          if (y.varsayilan !== undefined && y.varsayilan !== null) {
            parcalar.push('<field name="' + y.ad + '">' +
              kacir(String(y.varsayilan)) + '</field>');
          }
          return;
        }
        var g = golge(y);
        if (g) parcalar.push('<value name="' + y.ad + '">' + g + '</value>');
      });
      parcalar.push('</block>');
    });
    parcalar.push('</xml>');
    return parcalar.join('');
  }

  /// Calisma alanindaki yigini duz bir listeye cevirir.
  ///
  /// Sira, cocugun gozuyle ayni: blok, sonra C kutusunun ICI, sonra
  /// altindaki blok. Dart tarafi beklenen cozumle bunu karsilastiriyor.
  function yiginiOku(blok, cikti) {
    while (blok) {
      if (!blok.isShadow()) {
        var alanlar = {};
        blok.inputList.forEach(function (girdi) {
          girdi.fieldRow.forEach(function (alan) {
            if (alan.name) alanlar[alan.name] = String(alan.getValue());
          });
        });
        // Golge bloklarin (sayi/metin kutulari) degerleri de blogun
        // parcasi: "9 numarali pin" ile "13 numarali pin" ayni blok
        // degil.
        blok.inputList.forEach(function (girdi) {
          var hedef = girdi.connection && girdi.connection.targetBlock();
          if (hedef && hedef.isShadow()) {
            hedef.inputList.forEach(function (g) {
              g.fieldRow.forEach(function (alan) {
                if (alan.name) alanlar[girdi.name] = String(alan.getValue());
              });
            });
          }
        });

        var kayit = { tip: blok.type, alanlar: alanlar };
        cikti.push(kayit);

        var icerik = blok.getInput('ICERIK');
        var ilk = icerik && icerik.connection &&
          icerik.connection.targetBlock();
        if (ilk) {
          kayit.icerik = [];
          yiginiOku(ilk, kayit.icerik);
        }
      }
      blok = blok.getNextBlock();
    }
    return cikti;
  }

  function durumuBildir() {
    if (!ws) return;
    var kokler = ws.getTopBlocks(true).filter(function (b) {
      return !b.isShadow();
    });
    var yiginlar = kokler.map(function (k) { return yiginiOku(k, []); });
    bildir('durum', {
      yiginlar: yiginlar,
      toplamBlok: ws.getAllBlocks().filter(function (b) {
        return !b.isShadow();
      }).length
    });
  }

  // Blok editorunun kendi tikirti sesleri pakete alinmadi (uygulamanin
  // kendi SoundService'i var). scratch-blocks onlari yine de `fetch`
  // ile ariyor; Icerik Guvenligi Politikasi istegi kesiyor ve geriye
  // sahipsiz bir soz reddi kaliyor. Burasi o reddi isaretliyor ki
  // konsola hata diye dusmesin. Yalnizca "Failed to fetch" yakalaniyor;
  // baska hicbir hata gizlenmiyor. (Cocuk bu konsolu zaten gormuyor;
  // amac gercek bir hatayi ararken gurultuye bogulmamak.)
  global.addEventListener('unhandledrejection', function (o) {
    var m = o && o.reason && String(o.reason.message || o.reason);
    if (m && m.indexOf('Failed to fetch') >= 0) o.preventDefault();
  });

  var API = {
    /// Flutter'dan cagriliyor.
    ///
    /// ayar = {
    ///   dil: 'tr'|'en'|'de'|'es',
    ///   bloklar: ['dev_bayrak', ...] | null (hepsi),
    ///   baslangic: '<xml>...</xml>' | null,
    ///   saltOkunur: bool
    /// }
    kur: function (ayarJson) {
      try {
        var ayar = typeof ayarJson === 'string'
          ? JSON.parse(ayarJson) : (ayarJson || {});
        dil = ayar.dil || 'tr';

        S.defineBlocksWithJsonArray(K.BLOKLAR.map(tanim));

        if (ws) { ws.dispose(); ws = null; }
        ws = S.inject('tezgah', {
          media: 'media/',
          theme: S.ScratchBlocksTheme,
          toolbox: aracKutusuXml(ayar.bloklar || null),
          readOnly: !!ayar.saltOkunur,
          scrollbars: true,
          trashcan: true,
          zoom: { controls: true, startScale: ayar.olcek || 0.675 }
        });

        if (ayar.baslangic) {
          S.Xml.domToWorkspace(S.utils.xml.textToDom(ayar.baslangic), ws);
          // Hazir program arac kutusunun altinda kalmasin.
          if (ws.scrollCenter) ws.scrollCenter();
        }

        ws.addChangeListener(function (olay) {
          if (olay && olay.isUiEvent) return;
          durumuBildir();
        });

        bildir('hazir', { blokSayisi: K.BLOKLAR.length, dil: dil });
        durumuBildir();
      } catch (e) {
        bildir('hata', String((e && e.stack) || e));
      }
    },

    /// Tahtayi bosaltir (cocuk "bastan basla" derse).
    temizle: function () {
      if (ws) { ws.clear(); durumuBildir(); }
    },

    /// Testlerin ve Flutter'in okuyabilmesi icin.
    durum: function () {
      if (!ws) return null;
      return ws.getTopBlocks(true)
        .filter(function (b) { return !b.isShadow(); })
        .map(function (k) { return yiginiOku(k, []); });
    }
  };

  global.MBlockTezgah = API;
  bildir('yuklendi');
})(this);
