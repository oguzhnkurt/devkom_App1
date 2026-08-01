import 'package:flutter/material.dart';
import '../models/interactive_lesson_model.dart';

/// CSS Course - Interactive lessons for web design
/// Modern, adim adim, Scratch/HTML dersleriyle ayni kalite ve formatta
class CssLessonsData {
  // ==========================================
  // MODULE 1: CSS'E GİRİŞ
  // ==========================================
  static final List<InteractiveLesson> module1 = [
    // LESSON 1.1: CSS Nedir?
    InteractiveLesson(
      id: 'css_1_1',
      courseId: 'css',
      title: 'CSS\'e Hos Geldin!',
      subtitle: 'Web sayfalarini guzellestir',
      order: 1,
      xpReward: 50,
      badge: 'css_starter',
      steps: [
        IntroStep(
          id: 'c1_1_intro',
          mascotEmoji: '🎨',
          mascotMessage: 'Merhaba! Ben CSS ile tanisacaksin. HTML iskeleti olustursun, CSS de ona renk ve guzellik katsin!',
          highlights: [
            'Renkler ve fontlar',
            'Boyut ve yerlesim',
            'Sayfayi guzellestir',
          ],
        ),

        ExplanationStep(
          id: 'c1_1_exp1',
          title: 'CSS Nedir?',
          content: 'CSS (Cascading Style Sheets), HTML elemanlarinin GORUNUMUNU degistiren dildir.\n\nHTML: Iskelet (yapiyi olusturur)\nCSS: Kiyafet (guzel gosterir)\n\nRenkler, fontlar, boyutlar, aralar - hepsi CSS ile yapilir!',
          tipEmoji: '💡',
          tip: 'CSS olmasaydi tum web siteleri siyah yazi beyaz arka plan olurdu!',
        ),

        MultipleChoiceStep(
          id: 'c1_1_q1',
          question: 'CSS ne ise yarar?',
          options: [
            ChoiceOption(text: 'Sayfanin gorunumunu degistirir', emoji: '✅'),
            ChoiceOption(text: 'Sayfanin yapisini olusturur', emoji: '❌'),
            ChoiceOption(text: 'Veritabanina baglanir', emoji: '❌'),
            ChoiceOption(text: 'Sunucu calistirir', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'CSS, HTML elemanlarinin renk, boyut, yerlesim gibi gorsel ozelliklerini belirler!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c1_1_exp2',
          title: 'CSS Sozdizimi (Syntax)',
          content: 'CSS kurallari boyle yazilir:\n\nsecici {\n  ozellik: deger;\n}\n\nOrnek:\nh1 {\n  color: blue;\n}\n\nBu kural: "Tum h1 basliklarini mavi yap" demek!',
          visuals: [
            VisualElement(
              type: VisualType.codeSnippet,
              content: 'h1 {\n  color: blue;\n}',
              label: 'Secici + Ozellik + Deger',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'c1_1_q2',
          question: '"color: red;" satirinin sonunda ne olmali?',
          options: [
            ChoiceOption(text: 'Noktali virgul (;)', emoji: '✅'),
            ChoiceOption(text: 'Nokta (.)', emoji: '❌'),
            ChoiceOption(text: 'Virgul (,)', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Her CSS ozelligi noktali virgul (;) ile bitmelidir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c1_1_exp3',
          title: 'CSS Nereye Yazilir?',
          content: 'CSS\'i 3 yerde yazabilirsin:\n\n1. <style> etiketi icinde (sayfanin icinde)\n2. Ayri bir .css dosyasinda (en yaygin!)\n3. Etiketin icinde style="..." (inline)\n\nEn temiz yontem: ayri .css dosyasi kullanmak!',
        ),

        DragDropStep(
          id: 'c1_1_dd1',
          instruction: 'CSS ozelliklerini ne ise yaradiklarina gore eslestir!',
          items: [
            DraggableItem(id: 'color', content: 'color', color: Color(0xFF264DE4)),
            DraggableItem(id: 'font-size', content: 'font-size', color: Color(0xFF2965F1)),
            DraggableItem(id: 'background-color', content: 'background-color', color: Color(0xFF264DE4)),
            DraggableItem(id: 'width', content: 'width', color: Color(0xFF2965F1)),
          ],
          dropZones: [
            DropZone(id: 'text', label: 'Yazi ile ilgili', hint: 'Renk, boyut...'),
            DropZone(id: 'box', label: 'Kutu ile ilgili', hint: 'Genislik, arka plan...'),
          ],
          correctMapping: {
            'color': 'text',
            'font-size': 'text',
            'background-color': 'box',
            'width': 'box',
          },
          successMessage: 'Harika! CSS ozelliklerini ayirt edebiliyorsun!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c1_1_summary',
          title: 'CSS Baslangic!',
          content: '🎉 CSS dunyasina ilk adimi attin!\n\n✓ CSS\'in ne oldugunu ogrendin\n✓ Sozdizimini tandin\n✓ Ozellik turlerini kesfettin\n\nSonraki ders: Renkler ve yazi tipleri!',
          tipEmoji: '🏆',
          tip: 'CSS Baslangic rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.2: Renkler ve Yazi Tipleri
    InteractiveLesson(
      id: 'css_1_2',
      courseId: 'css',
      title: 'Renkler ve Yazi Tipleri',
      subtitle: 'Sayfani renklendir',
      order: 2,
      xpReward: 60,
      badge: 'color_master',
      steps: [
        IntroStep(
          id: 'c1_2_intro',
          mascotEmoji: '🌈',
          mascotMessage: 'Simdi sayfana renk katacagiz! Yazilari renklendirelim, arka planlar ekleyelim!',
        ),

        ExplanationStep(
          id: 'c1_2_exp1',
          title: 'Renk Belirtme Yontemleri',
          content: 'CSS\'te renk vermenin 3 yolu var:\n\n1. Isim ile: color: red;\n2. Hex kod ile: color: #FF0000;\n3. RGB ile: color: rgb(255, 0, 0);\n\nUcu de ayni kirmizi rengi verir!',
          tipEmoji: '🎨',
          tip: 'Hex kodlar # ile baslar ve 6 karakterden olusur!',
        ),

        MultipleChoiceStep(
          id: 'c1_2_q1',
          question: 'Hangisi gecerli bir hex renk kodu?',
          options: [
            ChoiceOption(text: '#3498DB', emoji: '✅', isCode: true),
            ChoiceOption(text: 'hex-blue', emoji: '❌'),
            ChoiceOption(text: 'color-45', emoji: '❌'),
            ChoiceOption(text: '3498DB#', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Hex kodlar # isareti ile baslar ve 6 rakam/harften olusur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c1_2_exp2',
          title: 'Yazi Ozellikleri',
          content: 'Yazilarla ilgili temel ozellikler:\n\ncolor: Yazi rengi\nfont-size: Yazi boyutu (16px, 1.5em...)\nfont-family: Yazi tipi (Arial, Georgia...)\nfont-weight: Kalinlik (normal, bold)\ntext-align: Hizalama (left, center, right)',
          visuals: [
            VisualElement(
              type: VisualType.codeSnippet,
              content: 'p {\n  color: #333;\n  font-size: 18px;\n  font-family: Arial;\n  font-weight: bold;\n}',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'c1_2_q2',
          question: 'Yaziyi kalin yapmak icin ne yazmaliyiz?',
          options: [
            ChoiceOption(text: 'font-weight: bold;', emoji: '✅', isCode: true),
            ChoiceOption(text: 'text-style: bold;', emoji: '❌'),
            ChoiceOption(text: 'font-bold: true;', emoji: '❌'),
            ChoiceOption(text: 'weight: heavy;', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'font-weight: bold; yaziyi kalinlastirir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c1_2_exp3',
          title: 'Arka Plan Rengi',
          content: 'background-color ozelligi bir elemanin arka planini boyar:\n\ndiv {\n  background-color: yellow;\n}\n\nbody\'ye uygularsan tum sayfanin arka plani degisir!',
        ),

        OrderingStep(
          id: 'c1_2_order',
          instruction: 'Asagidaki CSS kuralinin dogru siralamasini bul',
          items: [
            OrderItem(id: 'selector', content: 'h1', isCode: true),
            OrderItem(id: 'open', content: '{', isCode: true),
            OrderItem(id: 'prop', content: 'color: purple;', isCode: true),
            OrderItem(id: 'close', content: '}', isCode: true),
          ],
          correctOrder: ['selector', 'open', 'prop', 'close'],
          context: 'Gecerli bir CSS kurali olusturmak icin dogru sirala',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c1_2_summary',
          title: 'Renk Ustasi!',
          content: '🌈 Artik sayfani renklendirebilirsin!\n\n✓ 3 renk belirtme yontemi\n✓ Yazi ozellikleri\n✓ Arka plan rengi\n\nSonraki: Secicileri (selectors) ogrenecegiz!',
          tipEmoji: '🏆',
          tip: 'Renk Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.3: Seciciler (Selectors)
    InteractiveLesson(
      id: 'css_1_3',
      courseId: 'css',
      title: 'Seciciler (Selectors)',
      subtitle: 'Dogru elemani hedefle',
      order: 3,
      xpReward: 70,
      badge: 'selector_expert',
      steps: [
        IntroStep(
          id: 'c1_3_intro',
          mascotEmoji: '🎯',
          mascotMessage: 'Bir sayfada 100 eleman olabilir. Peki hangisine stil verecegini nasil belirtirsin? SECICILER ile!',
        ),

        ExplanationStep(
          id: 'c1_3_exp1',
          title: 'Etiket Secici (Element Selector)',
          content: 'En basit secici, HTML etiketinin adidir:\n\np {\n  color: gray;\n}\n\nBu, sayfadaki TUM <p> etiketlerini etkiler!',
          tipEmoji: '🏷️',
          tip: 'Etiket secici sayfadaki her ornegi etkiler, dikkatli kullan!',
        ),

        ExplanationStep(
          id: 'c1_3_exp2',
          title: 'Sinif Secici (Class Selector)',
          content: 'Sadece belirli elemanlari secmek icin CLASS kullanilir. Nokta (.) ile baslar:\n\nHTML: <p class="uyari">Dikkat!</p>\n\nCSS:\n.uyari {\n  color: red;\n}\n\nSadece class="uyari" olan elemanlar kirmizi olur!',
          visuals: [
            VisualElement(
              type: VisualType.codeSnippet,
              content: '.uyari {\n  color: red;\n}',
              label: 'Nokta ile baslar',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'c1_3_q1',
          question: 'Class secici nasil yazilir?',
          options: [
            ChoiceOption(text: '.sinif-adi', emoji: '✅', isCode: true),
            ChoiceOption(text: '#sinif-adi', emoji: '❌', isCode: true),
            ChoiceOption(text: '@sinif-adi', emoji: '❌', isCode: true),
            ChoiceOption(text: 'sinif-adi', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'Class seciciler nokta (.) ile baslar!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c1_3_exp3',
          title: 'ID Secici',
          content: 'ID, TEK BIR elemani secmek icindir. Diyez (#) ile baslar:\n\nHTML: <div id="baslik-alani">...</div>\n\nCSS:\n#baslik-alani {\n  background-color: navy;\n}\n\nBir sayfada ayni ID sadece BIR KEZ kullanilmalidir!',
          tipEmoji: '🆔',
          tip: 'Class\'i defalarca, ID\'yi sadece bir kez kullan!',
        ),

        MultipleChoiceStep(
          id: 'c1_3_q2',
          question: 'Bir sayfada ayni ID kac kez kullanilabilir?',
          options: [
            ChoiceOption(text: 'Sadece 1 kez', emoji: '✅'),
            ChoiceOption(text: '2 kez', emoji: '❌'),
            ChoiceOption(text: 'Istedigin kadar', emoji: '❌'),
            ChoiceOption(text: 'Hic kullanilamaz', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'ID benzersiz olmalidir - her sayfada sadece bir kez kullanilir. Tekrar eden elemanlar icin class kullanilir!',
          xpReward: 10,
        ),

        DragDropStep(
          id: 'c1_3_dd1',
          instruction: 'Seciciyi dogru turune surukle!',
          items: [
            DraggableItem(id: 's1', content: 'h2', color: Color(0xFFE44D26)),
            DraggableItem(id: 's2', content: '.kart', color: Color(0xFF264DE4)),
            DraggableItem(id: 's3', content: '#anasayfa', color: Color(0xFF2965F1)),
            DraggableItem(id: 's4', content: '.buton', color: Color(0xFF264DE4)),
            DraggableItem(id: 's5', content: 'span', color: Color(0xFFE44D26)),
          ],
          dropZones: [
            DropZone(id: 'element', label: 'Etiket Secici', hint: 'Isim ile'),
            DropZone(id: 'class', label: 'Sinif Secici', hint: 'Nokta ile'),
            DropZone(id: 'id', label: 'ID Secici', hint: 'Diyez ile'),
          ],
          correctMapping: {
            's1': 'element',
            's5': 'element',
            's2': 'class',
            's4': 'class',
            's3': 'id',
          },
          successMessage: 'Mukemmel! Uc secici turunu de ayirt ediyorsun!',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'c1_3_summary',
          title: 'Secici Ustasi!',
          content: '🎯 Artik dogru elemani hedefleyebilirsin!\n\n✓ Etiket secici\n✓ Class secici (.)\n✓ ID secici (#)\n\nSonraki modul: Kutu modeli!',
          tipEmoji: '🏆',
          tip: 'Secici Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 2: KUTU MODELİ
  // ==========================================
  static final List<InteractiveLesson> module2 = [
    // LESSON 2.1: Kutu Modeli Nedir?
    InteractiveLesson(
      id: 'css_2_1',
      courseId: 'css',
      title: 'Kutu Modeli Nedir?',
      subtitle: 'Her eleman bir kutudur',
      order: 4,
      xpReward: 70,
      badge: 'box_model_master',
      steps: [
        IntroStep(
          id: 'c2_1_intro',
          mascotEmoji: '📦',
          mascotMessage: 'Buyuk bir sir vereyim: Bir web sayfasindaki HER SEY aslinda bir kutudur! Buna Kutu Modeli (Box Model) denir.',
        ),

        ExplanationStep(
          id: 'c2_1_exp1',
          title: 'Kutu Modelinin 4 Katmani',
          content: 'Her elemanin 4 katmani vardir (icten disa):\n\n1. Content: Icerik (yazi, resim)\n2. Padding: Icerik ile kenarlik arasi bosluk\n3. Border: Kenarlik\n4. Margin: Kutunun disindaki bosluk\n\nContent > Padding > Border > Margin!',
          visuals: [
            VisualElement(
              type: VisualType.diagram,
              content: 'box_model_diagram',
              label: 'Margin > Border > Padding > Content',
            ),
          ],
          tipEmoji: '📐',
          tip: 'Bunu bir hediye kutusu gibi dusun: Icindeki hediye (content), kutunun ic yastigi (padding), kutunun kendisi (border), kutunun etrafindaki bosluk (margin)!',
        ),

        MultipleChoiceStep(
          id: 'c2_1_q1',
          question: 'Icerik ile kenarlik (border) arasindaki bosluga ne denir?',
          options: [
            ChoiceOption(text: 'Padding', emoji: '✅'),
            ChoiceOption(text: 'Margin', emoji: '❌'),
            ChoiceOption(text: 'Content', emoji: '❌'),
            ChoiceOption(text: 'Border', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Padding, icerik ile kenarlik arasindaki ic bosluktur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c2_1_exp2',
          title: 'Margin vs Padding',
          content: 'Bu ikisi cok karistirilir:\n\nPadding: Kutunun ICINDEKI bosluk (icerik ile kenar arasi)\nMargin: Kutunun DISINDAKI bosluk (diger elemanlarla arasi)\n\nOrnek:\ndiv {\n  padding: 20px;\n  margin: 10px;\n}',
        ),

        MultipleChoiceStep(
          id: 'c2_1_q2',
          question: 'Iki kutu arasindaki mesafeyi hangi ozellik ayarlar?',
          options: [
            ChoiceOption(text: 'margin', emoji: '✅', isCode: true),
            ChoiceOption(text: 'padding', emoji: '❌', isCode: true),
            ChoiceOption(text: 'border', emoji: '❌', isCode: true),
            ChoiceOption(text: 'content', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'Margin, elemanin DISINDAKI boslugu ayarlar - digger elemanlarla arayi acar!',
          xpReward: 10,
        ),

        DragDropStep(
          id: 'c2_1_dd1',
          instruction: 'Kutu modeli katmanlarini icten disa dogru surukle!',
          items: [
            DraggableItem(id: 'content', content: 'Content (icerik)', color: Color(0xFF4CAF50)),
            DraggableItem(id: 'padding', content: 'Padding', color: Color(0xFF2196F3)),
            DraggableItem(id: 'border', content: 'Border', color: Color(0xFFFF9800)),
            DraggableItem(id: 'margin', content: 'Margin', color: Color(0xFF9C27B0)),
          ],
          dropZones: [
            DropZone(id: 'inner', label: 'En Ic Katman', hint: 'Yaziyi/resmi barindiran'),
            DropZone(id: 'outer', label: 'En Dis Katman', hint: 'Diger kutularla arayi acan'),
          ],
          correctMapping: {
            'content': 'inner',
            'margin': 'outer',
          },
          successMessage: 'Icten disa dogru katmanlari ogrendin!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c2_1_summary',
          title: 'Kutu Modeli Ustasi!',
          content: '📦 Artik her elemanin bir kutu oldugunu biliyorsun!\n\n✓ 4 katmani ogrendin\n✓ Margin ve padding farkini kavradin\n\nSonraki: Genislik ve yukseklik ayarlama!',
          tipEmoji: '🏆',
          tip: 'Kutu Modeli rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 2.2: Genislik ve Yukseklik
    InteractiveLesson(
      id: 'css_2_2',
      courseId: 'css',
      title: 'Genislik ve Yukseklik',
      subtitle: 'Kutularin boyutunu ayarla',
      order: 5,
      xpReward: 70,
      badge: 'sizing_master',
      steps: [
        IntroStep(
          id: 'c2_2_intro',
          mascotEmoji: '📏',
          mascotMessage: 'Kutularin boyutunu kontrol etmeyi ogrenelim! width ve height ile her seyi olceklendirebilirsin.',
        ),

        ExplanationStep(
          id: 'c2_2_exp1',
          title: 'width ve height',
          content: 'Bir elemanin boyutunu belirlemek icin:\n\ndiv {\n  width: 300px;\n  height: 150px;\n}\n\nBirimler:\npx: Sabit piksel\n%: Ust elemana gore yuzde\nem/rem: Yazi boyutuna gore',
          tipEmoji: '📐',
          tip: '% kullanirsan eleman ekrana gore otomatik buyur kuculur!',
        ),

        MultipleChoiceStep(
          id: 'c2_2_q1',
          question: 'Bir kutuyu 200 piksel genislikte yapmak icin ne yazariz?',
          options: [
            ChoiceOption(text: 'width: 200px;', emoji: '✅', isCode: true),
            ChoiceOption(text: 'size: 200px;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'wide: 200;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'width: 200;', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'width: 200px; - birimi (px) yazmayi unutma!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c2_2_exp2',
          title: 'box-sizing: border-box',
          content: 'Onemli bir sorun: padding ve border normalde toplam genisligi ARTIRIR!\n\nBunu onlemek icin:\ndiv {\n  box-sizing: border-box;\n}\n\nBoylece width, padding ve border\'i da icine alir - hesaplama kolaylasir!',
          tipEmoji: '⚠️',
          tip: 'Profesyoneller genelde tum sayfaya box-sizing: border-box; uygular!',
        ),

        MultipleChoiceStep(
          id: 'c2_2_q2',
          question: 'width: 100px; padding: 20px olan bir kutunun gercek genisligi (box-sizing olmadan) nedir?',
          options: [
            ChoiceOption(text: '140px (100 + 20 + 20)', emoji: '✅'),
            ChoiceOption(text: '100px', emoji: '❌'),
            ChoiceOption(text: '120px', emoji: '❌'),
            ChoiceOption(text: '80px', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Padding her iki tarafa da eklenir: 100 + 20 (sol) + 20 (sag) = 140px!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c2_2_exp3',
          title: 'min-width ve max-width',
          content: 'Esnek tasarimlar icin:\n\nmin-width: Kutunun kucule bilecegi en kucuk boyut\nmax-width: Kutunun buyu bilecegi en buyuk boyut\n\nOrnek:\ndiv {\n  width: 100%;\n  max-width: 600px;\n}\n\nBu, kutuyu esnek ama 600px\'i gecmeyecek sekilde ayarlar!',
        ),

        OrderingStep(
          id: 'c2_2_order',
          instruction: 'Bu CSS kuralini dogru sirala',
          items: [
            OrderItem(id: 'sel', content: '.kutu', isCode: true),
            OrderItem(id: 'o1', content: '{', isCode: true),
            OrderItem(id: 'w', content: 'width: 300px;', isCode: true),
            OrderItem(id: 'h', content: 'height: 150px;', isCode: true),
            OrderItem(id: 'o2', content: '}', isCode: true),
          ],
          correctOrder: ['sel', 'o1', 'w', 'h', 'o2'],
          context: '.kutu sinifina 300x150 boyut veren kurali sirala',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c2_2_summary',
          title: 'Boyutlandirma Ustasi!',
          content: '📏 Artik kutularin boyutunu tam kontrol ediyorsun!\n\n✓ width ve height\n✓ box-sizing: border-box\n✓ min/max-width\n\nSonraki: Kenarliklar ve kose yuvarlama!',
          tipEmoji: '🏆',
          tip: 'Boyutlandirma Ustasi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 2.3: Kenarliklar ve Koseler
    InteractiveLesson(
      id: 'css_2_3',
      courseId: 'css',
      title: 'Kenarliklar ve Koseler',
      subtitle: 'Kutulari sekillendirmen',
      order: 6,
      xpReward: 75,
      badge: 'border_artist',
      steps: [
        IntroStep(
          id: 'c2_3_intro',
          mascotEmoji: '🖼️',
          mascotMessage: 'Kutularimizi guzellestirelim! Kenarliklar ekleyecek, koseleri yuvarlayacak ve golgeler verecegiz!',
        ),

        ExplanationStep(
          id: 'c2_3_exp1',
          title: 'Border (Kenarlik)',
          content: 'Bir kenarlik 3 parcadan olusur:\n\nborder: 2px solid black;\n       (kalinlik) (stil) (renk)\n\nStiller: solid, dashed, dotted, double',
          visuals: [
            VisualElement(
              type: VisualType.codeSnippet,
              content: 'div {\n  border: 3px solid #2196F3;\n}',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 'c2_3_q1',
          question: '"border: 2px dashed red;" nasil bir kenarlik olusturur?',
          options: [
            ChoiceOption(text: '2 piksel kalinliginda, kesikli, kirmizi', emoji: '✅'),
            ChoiceOption(text: 'Duz siyah cizgi', emoji: '❌'),
            ChoiceOption(text: 'Golgeli mavi cizgi', emoji: '❌'),
            ChoiceOption(text: 'Gorunmez kenarlik', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: '2px = kalinlik, dashed = kesik kesik stil, red = renk!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c2_3_exp2',
          title: 'border-radius: Kose Yuvarlama',
          content: 'Kosleri yuvarlamak icin border-radius kullanilir:\n\ndiv {\n  border-radius: 12px;\n}\n\nBuyuk deger verirsen (orn: 50%) kutuyu TAM YUVARLAK yapabilirsin!',
          tipEmoji: '⭕',
          tip: 'border-radius: 50%; kare bir kutuyu daireye cevirir!',
        ),

        MultipleChoiceStep(
          id: 'c2_3_q2',
          question: 'Kare bir kutuyu tam daire yapmak icin border-radius ne olmali?',
          options: [
            ChoiceOption(text: '50%', emoji: '✅'),
            ChoiceOption(text: '0px', emoji: '❌'),
            ChoiceOption(text: '100px', emoji: '❌'),
            ChoiceOption(text: '10%', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'border-radius: 50% bir kareyi mukemmel daireye donusturur!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c2_3_exp3',
          title: 'box-shadow: Golge Efekti',
          content: 'Kutulara derinlik katmak icin golge eklenir:\n\ndiv {\n  box-shadow: 0px 4px 10px rgba(0,0,0,0.2);\n}\n\nDegerler: yatay-kayma dikey-kayma bulaniklik renk\n\nModern kartlarda cok kullanilir!',
        ),

        ProjectStep(
          id: 'c2_3_project',
          title: 'Mini Proje: Guzel Kart Tasarimi',
          description: 'Ogrendigin her seyi birlestirerek guzel bir kart kutusu tasarla!',
          requirements: [
            'width ve height ile boyut ver',
            'padding ile ic bosluk ekle',
            'border-radius ile koseleri yuvarla',
            'box-shadow ile golge ekle',
          ],
          hints: [
            '.kart { width: 250px; padding: 20px; }',
            'border-radius: 16px; deneyebilirsin',
            'box-shadow: 0px 4px 12px rgba(0,0,0,0.15);',
          ],
          starterCode: '.kart {\n  /* buraya stillerini yaz */\n}',
          language: 'css',
          validation: ProjectValidation(
            mustContain: ['border-radius', 'box-shadow', 'padding'],
          ),
          xpReward: 40,
        ),

        ExplanationStep(
          id: 'c2_3_summary',
          title: 'Kenarlik Sanatcisi!',
          content: '🖼️ Artik kutulari sanat eserine cevirebilirsin!\n\n✓ border ile kenarlik\n✓ border-radius ile yuvarlak kose\n✓ box-shadow ile golge\n\nSonraki modul: Yerlesim (Layout)!',
          tipEmoji: '🏆',
          tip: 'Kenarlik Sanatcisi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 3: YERLEŞİM (LAYOUT)
  // ==========================================
  static final List<InteractiveLesson> module3 = [
    // LESSON 3.1: Display ve Position
    InteractiveLesson(
      id: 'css_3_1',
      courseId: 'css',
      title: 'Display ve Position',
      subtitle: 'Elemanlarin davranisini yonet',
      order: 7,
      xpReward: 75,
      badge: 'layout_starter',
      steps: [
        IntroStep(
          id: 'c3_1_intro',
          mascotEmoji: '📐',
          mascotMessage: 'Elemanlarin sayfada NASIL yerlestigini kontrol etmeyi ogrenelim. display ve position ile her seyi istedigin yere koyabilirsin!',
        ),

        ExplanationStep(
          id: 'c3_1_exp1',
          title: 'display: block vs inline',
          content: 'Her HTML etiketinin varsayilan bir "display" degeri vardir:\n\nblock: Tam satiri kaplar, alt alta dizilir (div, p, h1)\ninline: Sadece icerigi kadar yer kaplar, yan yana dizilir (span, a)\nnone: Elemani tamamen gizler!',
          tipEmoji: '👁️',
          tip: 'display: none; bir elemani sayfadan tamamen kaldirir, sanki hic yokmus gibi!',
        ),

        MultipleChoiceStep(
          id: 'c3_1_q1',
          question: 'Bir elemani sayfadan tamamen gizlemek icin ne yazariz?',
          options: [
            ChoiceOption(text: 'display: none;', emoji: '✅', isCode: true),
            ChoiceOption(text: 'display: hidden;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'visible: false;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'show: no;', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'display: none; elemani tamamen gizler ve yer kaplamasini engeller!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c3_1_exp2',
          title: 'Position: relative ve absolute',
          content: 'position ozelligi elemanin nasil konumlandirilacagini belirler:\n\nstatic: Varsayilan, normal akis\nrelative: Kendi normal konumuna gore kaydirilir\nabsolute: En yakin "relative" ebeveyne gore konumlanir\nfixed: Ekrana sabitlenir (scroll etsen de yerinde kalir)',
        ),

        MultipleChoiceStep(
          id: 'c3_1_q2',
          question: 'Scroll yapsan bile ekranda hep ayni yerde duran bir menu icin hangi position kullanilir?',
          options: [
            ChoiceOption(text: 'fixed', emoji: '✅', isCode: true),
            ChoiceOption(text: 'static', emoji: '❌', isCode: true),
            ChoiceOption(text: 'relative', emoji: '❌', isCode: true),
            ChoiceOption(text: 'none', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'position: fixed; elemani ekrana sabitler, sayfa kaydirilsa bile yerinde kalir!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c3_1_exp3',
          title: 'top, left, right, bottom',
          content: 'position: relative/absolute/fixed kullaninca, konumu bu ozelliklerle ayarlarsin:\n\ndiv {\n  position: absolute;\n  top: 10px;\n  right: 20px;\n}\n\nBu, elemani ustten 10px, sagdan 20px konumlar!',
        ),

        DragDropStep(
          id: 'c3_1_dd1',
          instruction: 'Position degerini dogru senaryoya surukle!',
          items: [
            DraggableItem(id: 'fixed', content: 'fixed'),
            DraggableItem(id: 'static', content: 'static'),
            DraggableItem(id: 'absolute', content: 'absolute'),
          ],
          dropZones: [
            DropZone(id: 'sticky_menu', label: 'Sabit ust menu', hint: 'Her zaman gorunur'),
            DropZone(id: 'normal', label: 'Normal akis', hint: 'Varsayilan davranis'),
            DropZone(id: 'badge', label: 'Kart kosesindeki rozet', hint: 'Ebeveyne gore konumlu'),
          ],
          correctMapping: {
            'fixed': 'sticky_menu',
            'static': 'normal',
            'absolute': 'badge',
          },
          successMessage: 'Position degerlerini dogru senaryolarla eslestirdin!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c3_1_summary',
          title: 'Yerlesim Kasifi!',
          content: '📐 Elemanlarin davranisini kontrol edebiliyorsun!\n\n✓ display: block/inline/none\n✓ position: relative/absolute/fixed\n\nSonraki: Flexbox ile modern yerlesim!',
          tipEmoji: '🏆',
          tip: 'Yerlesim Kasifi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 3.2: Flexbox'a Giris
    InteractiveLesson(
      id: 'css_3_2',
      courseId: 'css',
      title: 'Flexbox\'a Giris',
      subtitle: 'Modern yerlesimin gucu',
      order: 8,
      xpReward: 80,
      badge: 'flexbox_beginner',
      steps: [
        IntroStep(
          id: 'c3_2_intro',
          mascotEmoji: '🧲',
          mascotMessage: 'Flexbox, elemanlari kolayca yan yana veya ortalayarak dizmeni saglayan SIHIRLI bir arac! Haydi ogrenelim!',
        ),

        ExplanationStep(
          id: 'c3_2_exp1',
          title: 'display: flex',
          content: 'Bir kutuyu flex konteynerine cevirmek icin:\n\n.kapsayici {\n  display: flex;\n}\n\nBu tek satir, icindeki tum elemanlari otomatik olarak YAN YANA dizer!',
          tipEmoji: '✨',
          tip: 'Eskiden yan yana dizmek icin float kullanilirdi - flexbox cok daha kolay!',
        ),

        MultipleChoiceStep(
          id: 'c3_2_q1',
          question: 'Bir div\'i flex konteynerine cevirmek icin ne yazariz?',
          options: [
            ChoiceOption(text: 'display: flex;', emoji: '✅', isCode: true),
            ChoiceOption(text: 'layout: flex;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'flex: true;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'display: row;', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'display: flex; bir elemani flex konteynerine cevirir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c3_2_exp2',
          title: 'justify-content: Yatay Hizalama',
          content: 'Elemanlari yatayda hizalamak icin:\n\n.kapsayici {\n  display: flex;\n  justify-content: center;\n}\n\nDegerler:\ncenter: Ortala\nspace-between: Aralarina esit bosluk\nflex-end: Saga yasla',
        ),

        MultipleChoiceStep(
          id: 'c3_2_q2',
          question: 'Elemanlari yatayda TAM ORTAYA almak icin ne yazariz?',
          options: [
            ChoiceOption(text: 'justify-content: center;', emoji: '✅', isCode: true),
            ChoiceOption(text: 'align: center;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'text-align: middle;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'center: true;', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'justify-content: center; elemanlari yatay eksende ortalar!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c3_2_exp3',
          title: 'align-items: Dikey Hizalama',
          content: 'Elemanlari dikeyde hizalamak icin:\n\n.kapsayici {\n  display: flex;\n  align-items: center;\n}\n\nBu, elemanlari kapsayicinin dikey ortasina hizalar. justify-content (yatay) + align-items (dikey) = TAM ORTALAMA!',
          tipEmoji: '🎯',
          tip: 'justify-content: center + align-items: center = bir elemani her yonden mukemmel ortalar!',
        ),

        OrderingStep(
          id: 'c3_2_order',
          instruction: 'Bir kutuyu tam ortalayan CSS kuralini sirala',
          items: [
            OrderItem(id: 's1', content: '.kapsayici {', isCode: true),
            OrderItem(id: 's2', content: 'display: flex;', isCode: true),
            OrderItem(id: 's3', content: 'justify-content: center;', isCode: true),
            OrderItem(id: 's4', content: 'align-items: center;', isCode: true),
            OrderItem(id: 's5', content: '}', isCode: true),
          ],
          correctOrder: ['s1', 's2', 's3', 's4', 's5'],
          context: 'Icerigi hem yatay hem dikey ortalayan flex kurali',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'c3_2_summary',
          title: 'Flexbox Kasifi!',
          content: '🧲 Flexbox\'in temelini ogrendin!\n\n✓ display: flex\n✓ justify-content (yatay)\n✓ align-items (dikey)\n\nSonraki: Flexbox ile daha fazla sıralama secenegi!',
          tipEmoji: '🏆',
          tip: 'Flexbox Kasifi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 3.3: Flexbox ile Siralama
    InteractiveLesson(
      id: 'css_3_3',
      courseId: 'css',
      title: 'Flexbox ile Siralama',
      subtitle: 'Yon, satir atlama ve bosluk',
      order: 9,
      xpReward: 80,
      badge: 'flexbox_master',
      steps: [
        IntroStep(
          id: 'c3_3_intro',
          mascotEmoji: '🔄',
          mascotMessage: 'Flexbox\'in daha fazla gucunu kesfedelim: yon degistirme, satir atlama ve elemanlar arasi bosluk!',
        ),

        ExplanationStep(
          id: 'c3_3_exp1',
          title: 'flex-direction: Yon Degistirme',
          content: 'Flexbox varsayilan olarak elemanlari YATAYDA dizer. Dikeyde dizmek icin:\n\n.kapsayici {\n  display: flex;\n  flex-direction: column;\n}\n\nDegerler: row (varsayilan), column, row-reverse, column-reverse',
          tipEmoji: '↕️',
          tip: 'flex-direction: column; elemanlari alt alta bir liste gibi dizer!',
        ),

        MultipleChoiceStep(
          id: 'c3_3_q1',
          question: 'Elemanlari alt alta (dikey) dizmek icin ne yazariz?',
          options: [
            ChoiceOption(text: 'flex-direction: column;', emoji: '✅', isCode: true),
            ChoiceOption(text: 'flex-direction: row;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'display: column;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'direction: vertical;', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'flex-direction: column; elemanlari dikey eksende, alt alta dizer!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c3_3_exp2',
          title: 'flex-wrap: Satir Atlama',
          content: 'Cok fazla eleman varsa ve sigmiyorsa:\n\n.kapsayici {\n  display: flex;\n  flex-wrap: wrap;\n}\n\nBu, sigmayan elemanlarin alt satira gecmesini saglar - tipki bir metin gibi!',
        ),

        MultipleChoiceStep(
          id: 'c3_3_q2',
          question: 'Ekrana sigmayan flex elemanlarinin alt satira gecmesini neye borcluyuz?',
          options: [
            ChoiceOption(text: 'flex-wrap: wrap;', emoji: '✅', isCode: true),
            ChoiceOption(text: 'flex-direction: wrap;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'overflow: wrap;', emoji: '❌', isCode: true),
            ChoiceOption(text: 'display: wrap;', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: 'flex-wrap: wrap; sigmayan elemanlarin yeni satira gecmesini saglar!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c3_3_exp3',
          title: 'gap: Elemanlar Arasi Bosluk',
          content: 'Flex elemanlari arasina esit bosluk koymak icin margin yerine artik gap kullanilir:\n\n.kapsayici {\n  display: flex;\n  gap: 16px;\n}\n\nCok daha temiz ve kolay - her elemana ayri ayri margin vermene gerek yok!',
          tipEmoji: '💎',
          tip: 'gap, hem flexbox hem de grid ile calisir!',
        ),

        DragDropStep(
          id: 'c3_3_dd1',
          instruction: 'Ozelligi dogru amacla eslestir!',
          items: [
            DraggableItem(id: 'p1', content: 'flex-direction: column'),
            DraggableItem(id: 'p2', content: 'flex-wrap: wrap'),
            DraggableItem(id: 'p3', content: 'gap: 12px'),
          ],
          dropZones: [
            DropZone(id: 'z1', label: 'Alt alta dizmek', hint: 'Yon degistirme'),
            DropZone(id: 'z2', label: 'Satir atlatmak', hint: 'Tasma durumu'),
            DropZone(id: 'z3', label: 'Elemanlar arasi bosluk', hint: 'Duzenli aralik'),
          ],
          correctMapping: {
            'p1': 'z1',
            'p2': 'z2',
            'p3': 'z3',
          },
          successMessage: 'Flexbox ozelliklerini tam kavradin!',
          xpReward: 20,
        ),

        ProjectStep(
          id: 'c3_3_project',
          title: 'Mini Proje: Kart Galerisi',
          description: 'Flexbox kullanarak yan yana dizilen, satir atlayan bir kart galerisi olustur!',
          requirements: [
            'display: flex kullan',
            'flex-wrap: wrap ile satir atlamayi saglа',
            'gap ile kartlar arasina bosluk koy',
            'justify-content ile hizala',
          ],
          hints: [
            '.galeri { display: flex; flex-wrap: wrap; gap: 16px; }',
            'justify-content: center; ile ortalayabilirsin',
          ],
          starterCode: '.galeri {\n  /* flexbox stillerini yaz */\n}',
          language: 'css',
          validation: ProjectValidation(
            mustContain: ['display: flex', 'flex-wrap', 'gap'],
          ),
          xpReward: 45,
        ),

        ExplanationStep(
          id: 'c3_3_summary',
          title: 'Flexbox Ustasi!',
          content: '🔄 Flexbox\'i tam kontrol ediyorsun!\n\n✓ flex-direction\n✓ flex-wrap\n✓ gap\n\nSonraki modul: Etkilesim ve final proje!',
          tipEmoji: '🏆',
          tip: 'Flexbox Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 4: TASARIM VE PROJE
  // ==========================================
  static final List<InteractiveLesson> module4 = [
    // LESSON 4.1: Hover ve Gecisler
    InteractiveLesson(
      id: 'css_4_1',
      courseId: 'css',
      title: 'Hover ve Gecisler',
      subtitle: 'Sayfani canlandir',
      order: 10,
      xpReward: 80,
      badge: 'interaction_designer',
      steps: [
        IntroStep(
          id: 'c4_1_intro',
          mascotEmoji: '✨',
          mascotMessage: 'Fare bir butonun uzerine geldiginde bir seyler degisiyor mu hic fark ettin mi? Buna hover efekti denir. Simdi biz de yapacagiz!',
        ),

        ExplanationStep(
          id: 'c4_1_exp1',
          title: ':hover Sozde Sinifi (Pseudo-class)',
          content: 'Fare bir elemanin uzerine geldiginde stil degistirmek icin:\n\nbutton:hover {\n  background-color: darkblue;\n}\n\nBu, SADECE fare uzerindeyken bu stili uygular!',
          tipEmoji: '🖱️',
          tip: ':hover butonlarda, linklerde ve kartlarda cok kullanilir!',
        ),

        MultipleChoiceStep(
          id: 'c4_1_q1',
          question: 'Fare bir buton uzerine geldiginde stil degistirmek icin ne kullanilir?',
          options: [
            ChoiceOption(text: ':hover', emoji: '✅', isCode: true),
            ChoiceOption(text: ':mouse', emoji: '❌', isCode: true),
            ChoiceOption(text: ':over', emoji: '❌', isCode: true),
            ChoiceOption(text: ':active-mouse', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: ':hover, fare bir elemanin uzerindeyken devreye giren ozel bir secicidir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c4_1_exp2',
          title: 'transition: Yumusak Gecis',
          content: 'Renk aniden degisince goze kotu gorunur. transition ile yumusatabiliriz:\n\nbutton {\n  background-color: blue;\n  transition: background-color 0.3s;\n}\nbutton:hover {\n  background-color: darkblue;\n}\n\nBu, renk degisimini 0.3 saniyede yumusakca yapar!',
        ),

        MultipleChoiceStep(
          id: 'c4_1_q2',
          question: '"transition: all 0.5s;" ne anlama gelir?',
          options: [
            ChoiceOption(text: 'Tum ozellik degisimleri 0.5 saniyede yumusak gecer', emoji: '✅'),
            ChoiceOption(text: 'Eleman 0.5 saniye sonra kaybolur', emoji: '❌'),
            ChoiceOption(text: 'Eleman 0.5 saniyede yuklenir', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey, gecersiz kod', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'transition: all 0.5s; - "all" tum ozellikleri kapsar, 0.5s de gecis suresidir!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c4_1_exp3',
          title: 'transform: scale ile Buyutme',
          content: 'Hover\'da bir elemani buyutmek cok sik kullanilan bir efekttir:\n\n.kart:hover {\n  transform: scale(1.05);\n}\n\nBu, kart uzerine gelince onu %5 buyutur - kullaniciya "tiklanabilir" hissi verir!',
          tipEmoji: '🔍',
          tip: 'transform: scale(1.05) + transition = profesyonel gorunumlu kartlar!',
        ),

        DragDropStep(
          id: 'c4_1_dd1',
          instruction: 'Ozelligi dogru aciklamasina surukle',
          items: [
            DraggableItem(id: 'p1', content: ':hover'),
            DraggableItem(id: 'p2', content: 'transition'),
            DraggableItem(id: 'p3', content: 'transform: scale()'),
          ],
          dropZones: [
            DropZone(id: 'z1', label: 'Fare uzerine gelince tetiklenir'),
            DropZone(id: 'z2', label: 'Degisimi yumusatir'),
            DropZone(id: 'z3', label: 'Elemani buyutur/kucultur'),
          ],
          correctMapping: {'p1': 'z1', 'p2': 'z2', 'p3': 'z3'},
          successMessage: 'Etkilesim ozelliklerini tam kavradin!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c4_1_summary',
          title: 'Etkilesim Tasarimcisi!',
          content: '✨ Sayfani canlandirmayi ogrendin!\n\n✓ :hover ile tepki verme\n✓ transition ile yumusak gecis\n✓ transform: scale ile buyutme\n\nSonraki: Basit animasyonlar!',
          tipEmoji: '🏆',
          tip: 'Etkilesim Tasarimcisi rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 4.2: Basit Animasyonlar
    InteractiveLesson(
      id: 'css_4_2',
      courseId: 'css',
      title: 'Basit Animasyonlar',
      subtitle: '@keyframes ile hareket',
      order: 11,
      xpReward: 85,
      badge: 'animation_wizard',
      steps: [
        IntroStep(
          id: 'c4_2_intro',
          mascotEmoji: '🎬',
          mascotMessage: 'Hover\'dan daha fazlasini yapabiliriz: kendi kendine calisan animasyonlar! @keyframes ile sihir yapacagiz.',
        ),

        ExplanationStep(
          id: 'c4_2_exp1',
          title: '@keyframes Nedir?',
          content: '@keyframes, bir animasyonun adimlarini tanimlar:\n\n@keyframes donme {\n  from { transform: rotate(0deg); }\n  to { transform: rotate(360deg); }\n}\n\nBu, "donme" adinda bir animasyon tanimlar: 0 dereceden 360 dereceye donus!',
          tipEmoji: '🎞️',
          tip: 'from/to yerine 0%, 50%, 100% gibi yuzdeler de kullanabilirsin!',
        ),

        MultipleChoiceStep(
          id: 'c4_2_q1',
          question: 'Bir animasyonun adimlarini tanimlamak icin ne kullanilir?',
          options: [
            ChoiceOption(text: '@keyframes', emoji: '✅', isCode: true),
            ChoiceOption(text: '@animation', emoji: '❌', isCode: true),
            ChoiceOption(text: '@frames', emoji: '❌', isCode: true),
            ChoiceOption(text: '@steps', emoji: '❌', isCode: true),
          ],
          correctIndex: 0,
          explanation: '@keyframes ile animasyonun basindan sonuna kadarki adimlarini tanimlarsin!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 'c4_2_exp2',
          title: 'animation Ozelligi ile Baglama',
          content: 'Tanimladigin @keyframes\'i bir elemana baglamak icin:\n\n.dondur {\n  animation: donme 2s linear infinite;\n}\n\nDegerler: isim, sure (2s), hiz (linear), tekrar (infinite = sonsuz)',
        ),

        MultipleChoiceStep(
          id: 'c4_2_q2',
          question: '"animation: donme 2s linear infinite;" - "infinite" ne demek?',
          options: [
            ChoiceOption(text: 'Animasyon sonsuza kadar tekrar eder', emoji: '✅'),
            ChoiceOption(text: 'Animasyon sadece 1 kez calisir', emoji: '❌'),
            ChoiceOption(text: 'Animasyon 2 saniye surer', emoji: '❌'),
            ChoiceOption(text: 'Animasyon durur', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'infinite, animasyonun hic durmadan surekli tekrar etmesini saglar!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c4_2_exp3',
          title: 'Yuzdelerle Cok Adimli Animasyon',
          content: 'Daha karmasik animasyonlar icin yuzde kullanilir:\n\n@keyframes zipla {\n  0%   { transform: translateY(0); }\n  50%  { transform: translateY(-20px); }\n  100% { transform: translateY(0); }\n}\n\nBu, elemani yukari zipla-tip geri indirir!',
          tipEmoji: '🦘',
          tip: 'Yuzdeler ile istedigin kadar ara adim ekleyebilirsin (0%, 25%, 50%, 75%, 100%)!',
        ),

        OrderingStep(
          id: 'c4_2_order',
          instruction: 'Basit bir donme animasyonunu dogru sirala',
          items: [
            OrderItem(id: 's1', content: '@keyframes donme {', isCode: true),
            OrderItem(id: 's2', content: 'from { transform: rotate(0deg); }', isCode: true),
            OrderItem(id: 's3', content: 'to { transform: rotate(360deg); }', isCode: true),
            OrderItem(id: 's4', content: '}', isCode: true),
          ],
          correctOrder: ['s1', 's2', 's3', 's4'],
          context: 'donme adli keyframes animasyonunu tanimla',
          xpReward: 20,
        ),

        ExplanationStep(
          id: 'c4_2_summary',
          title: 'Animasyon Buyucusu!',
          content: '🎬 Kendi animasyonlarini yaratabiliyorsun!\n\n✓ @keyframes tanimlama\n✓ animation ozelligi ile baglama\n✓ Yuzdelerle cok adimli hareket\n\nSonraki: Her seyi birlestiren final proje!',
          tipEmoji: '🏆',
          tip: 'Animasyon Buyucusu rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 4.3: Final Proje - Profil Karti
    InteractiveLesson(
      id: 'css_4_3',
      courseId: 'css',
      title: 'Final Proje: Profil Karti',
      subtitle: 'Ogrendigin her seyi birlestir!',
      order: 12,
      xpReward: 120,
      badge: 'css_graduate',
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 'c4_3_intro',
          mascotEmoji: '🎓',
          mascotMessage: 'Tebrikler, buraya kadar geldin! Simdi ogrendigin HER SEYI kullanarak guzel bir profil karti tasarlayacagiz!',
        ),

        ExplanationStep(
          id: 'c4_3_exp1',
          title: 'Proje Plani',
          content: '🎯 Hedef: Sik bir profil karti\n\n📦 Kutu modeli: padding, border-radius\n🧲 Flexbox: Iceriği ortala\n✨ Hover: Karta uzerine gelince buyusun\n🎬 Gecis: Yumusak animasyon\n\nHepsini birlestirecegiz!',
        ),

        ExplanationStep(
          id: 'c4_3_exp2',
          title: 'Adim 1: Kart Yapisi',
          content: 'Once temel kart kutusunu olusturalim:\n\n.profil-karti {\n  width: 280px;\n  padding: 24px;\n  border-radius: 16px;\n  background-color: white;\n  box-shadow: 0px 4px 20px rgba(0,0,0,0.1);\n}',
          visuals: [
            VisualElement(
              type: VisualType.codeSnippet,
              content: '.profil-karti {\n  width: 280px;\n  padding: 24px;\n  border-radius: 16px;\n}',
            ),
          ],
        ),

        ExplanationStep(
          id: 'c4_3_exp3',
          title: 'Adim 2: Icerigi Ortala',
          content: 'Flexbox ile kart icindeki resim ve yaziyi ortalayalim:\n\n.profil-karti {\n  display: flex;\n  flex-direction: column;\n  align-items: center;\n  text-align: center;\n}',
        ),

        MultipleChoiceStep(
          id: 'c4_3_q1',
          question: 'Karttaki elemanlari dikeyde alt alta ve ortali dizmek icin hangi ikisini birlikte kullanmaliyiz?',
          options: [
            ChoiceOption(text: 'flex-direction: column; + align-items: center;', emoji: '✅'),
            ChoiceOption(text: 'display: block; + text-align: left;', emoji: '❌'),
            ChoiceOption(text: 'position: fixed; + top: 0;', emoji: '❌'),
            ChoiceOption(text: 'width: 100%; + height: 100%;', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'flex-direction: column ile alt alta diz, align-items: center ile ortala!',
          xpReward: 15,
        ),

        ExplanationStep(
          id: 'c4_3_exp4',
          title: 'Adim 3: Hover Efekti Ekle',
          content: 'Son olarak karta hayat katalim:\n\n.profil-karti {\n  transition: transform 0.3s;\n}\n.profil-karti:hover {\n  transform: scale(1.03);\n  box-shadow: 0px 8px 30px rgba(0,0,0,0.15);\n}\n\nSimdi kart, uzerine gelince yumusakca buyuyecek!',
          tipEmoji: '✨',
          tip: 'Gercek dunyada bircok site (Instagram, Airbnb, Twitter) tam olarak bunu yapiyor!',
        ),

        ProjectStep(
          id: 'c4_3_project',
          title: 'Final Proje: Tam Profil Karti',
          description: 'Ogrendigin her CSS konusunu birlestirerek eksiksiz bir profil karti yap!',
          requirements: [
            'Kutu modeli: width, padding, border-radius kullan',
            'box-shadow ile golge ekle',
            'Flexbox ile iceriği ortala (display: flex, align-items)',
            'Hover efekti ekle (:hover, transform: scale)',
            'transition ile yumusak gecis sagla',
          ],
          hints: [
            '.profil-karti { width: 280px; padding: 24px; border-radius: 16px; }',
            'display: flex; flex-direction: column; align-items: center;',
            '.profil-karti:hover { transform: scale(1.03); }',
            'transition: transform 0.3s; unutma!',
          ],
          starterCode: '.profil-karti {\n  /* Kutu modeli */\n\n  /* Flexbox ortalama */\n\n  /* Gecis */\n}\n\n.profil-karti:hover {\n  /* Hover efekti */\n}',
          language: 'css',
          validation: ProjectValidation(
            mustContain: ['border-radius', 'display: flex', ':hover', 'transition'],
          ),
          xpReward: 60,
        ),

        ExplanationStep(
          id: 'c4_3_summary',
          title: '🎓 CSS MEZUNU OLDUN!',
          content: '🎉🎨🎉 CSS KURSUNU TAMAMLADIN!\n\n✓ Seciciler ve ozellikler\n✓ Kutu modeli (box model)\n✓ Flexbox ile modern yerlesim\n✓ Hover, transition ve animasyonlar\n✓ Gercek bir profil karti tasarladin\n\nArtik herhangi bir web sayfasini guzellestirebilirsin!',
          tipEmoji: '🏆',
          tip: 'CSS Mezunu rozetini kazandin! Simdi bu becerilerini gercek projelerde kullanabilirsin.',
        ),
      ],
    ),
  ];

  /// Get all CSS lessons
  static List<InteractiveLesson> getCssInteractiveLessons() {
    return [
      ...module1,
      ...module2,
      ...module3,
      ...module4,
    ];
  }

  /// Get lessons for a specific module
  static List<InteractiveLesson> getLessonsForModule(int moduleNumber) {
    switch (moduleNumber) {
      case 1:
        return module1;
      case 2:
        return module2;
      case 3:
        return module3;
      case 4:
        return module4;
      default:
        return [];
    }
  }
}

/// CSS badges
class CssBadges {
  static const List<LessonBadge> all = [
    LessonBadge(
      id: 'css_starter',
      name: 'CSS Baslangic',
      description: 'CSS dunyasina adim attin!',
      emoji: '🎨',
      rarity: BadgeRarity.common,
      category: BadgeCategory.lesson,
    ),
    LessonBadge(
      id: 'color_master',
      name: 'Renk Ustasi',
      description: 'Renkleri ve yazi tiplerini ogrendin!',
      emoji: '🌈',
      rarity: BadgeRarity.common,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'selector_expert',
      name: 'Secici Ustasi',
      description: 'Etiket, class ve ID secicilerinde uzmanlaştin!',
      emoji: '🎯',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'box_model_master',
      name: 'Kutu Modeli Ustasi',
      description: 'Kutu modelini tam kavradin!',
      emoji: '📦',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'sizing_master',
      name: 'Boyutlandirma Ustasi',
      description: 'width, height ve box-sizing uzmani oldun!',
      emoji: '📏',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'border_artist',
      name: 'Kenarlik Sanatcisi',
      description: 'border-radius ve box-shadow ile kart tasarladin!',
      emoji: '🖼️',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'layout_starter',
      name: 'Yerlesim Kasifi',
      description: 'display ve position kavramlarini ogrendin!',
      emoji: '📐',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'flexbox_beginner',
      name: 'Flexbox Kasifi',
      description: 'Flexbox ile ilk adimlarini attin!',
      emoji: '🧲',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'flexbox_master',
      name: 'Flexbox Ustasi',
      description: 'Flexbox ile her turlu yerlesimi yapabiliyorsun!',
      emoji: '🔄',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'interaction_designer',
      name: 'Etkilesim Tasarimcisi',
      description: 'Hover ve gecis efektleri ekledin!',
      emoji: '✨',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'animation_wizard',
      name: 'Animasyon Buyucusu',
      description: '@keyframes ile kendi animasyonunu yarattin!',
      emoji: '🎬',
      rarity: BadgeRarity.epic,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'css_graduate',
      name: 'CSS Mezunu',
      description: 'Tum CSS kursunu tamamladin ve final projeyi bitirdin!',
      emoji: '🎓',
      rarity: BadgeRarity.legendary,
      category: BadgeCategory.course,
    ),
  ];
}
