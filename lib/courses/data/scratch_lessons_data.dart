import 'package:flutter/material.dart';
import '../models/interactive_lesson_model.dart';

/// Scratch Course - Interactive lessons for kids
/// Modern, engaging, FreeCodeCamp-inspired content
class ScratchLessonsData {
  // ==========================================
  // MODULE 1: SCRATCH'A MERHABA
  // ==========================================
  static final List<InteractiveLesson> module1 = [
    // LESSON 1.1: Scratch Nedir?
    InteractiveLesson(
      id: 'scratch_1_1',
      courseId: 'scratch',
      title: 'Scratch\'a Hos Geldin!',
      subtitle: 'Blok programlama dunyasina ilk adim',
      order: 1,
      xpReward: 50,
      badge: 'scratch_starter',
      steps: [
        // Step 1: Fun intro with mascot
        IntroStep(
          id: 's1_1_intro',
          mascotEmoji: '🐱',
          mascotMessage: 'Merhaba! Ben Scratch kedisi! Seninle birlikte harika oyunlar ve animasyonlar yapacagiz. Hazir misin?',
          highlights: [
            'Kod yazmadan programla',
            'Oyun ve animasyon yap',
            'Hayal gucunu kullan',
          ],
        ),

        // Step 2: What is Scratch - Visual explanation
        ExplanationStep(
          id: 's1_1_exp1',
          title: 'Scratch Nedir?',
          content: 'Scratch, renkli bloklari birlestirerek program yaptigin eglenceli bir arac. Lego gibi dusun - parcalari birlestir ve harika seyler yarat!',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '10 adim git',
              color: Color(0xFF4C97FF),
              label: 'Hareket Blogu',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Merhaba de',
              color: Color(0xFF9966FF),
              label: 'Gorunum Blogu',
            ),
          ],
          tipEmoji: '💡',
          tip: 'MIT universitesinde olusturuldu ve dunyada milyonlarca cocuk kullaniyor!',
        ),

        // Step 3: Interactive - What can you make?
        MultipleChoiceStep(
          id: 's1_1_q1',
          question: 'Scratch ile neler yapabilirsin?',
          options: [
            ChoiceOption(text: 'Sadece oyun', emoji: '🎮'),
            ChoiceOption(text: 'Sadece animasyon', emoji: '🎬'),
            ChoiceOption(text: 'Oyun, animasyon, hikaye ve daha fazlasi!', emoji: '🌟'),
            ChoiceOption(text: 'Hicbir sey', emoji: '❌'),
          ],
          correctIndex: 2,
          explanation: 'Dogru! Scratch ile oyun, animasyon, interaktif hikaye, muzik ve cok daha fazlasini yapabilirsin!',
          xpReward: 10,
        ),

        // Step 4: Meet the stage
        ExplanationStep(
          id: 's1_1_exp2',
          title: 'Sahne ve Kukla',
          content: 'Scratch\'ta iki onemli kavram var:\n\n🎭 Kukla (Sprite): Karakterin - hareket eden, konusan sey\n🎪 Sahne (Stage): Kuklanin oynadigi alan',
          visuals: [
            VisualElement(
              type: VisualType.diagram,
              content: 'stage_diagram',
              label: 'Sahne 480x360 piksel',
            ),
          ],
        ),

        // Step 5: Drag & Drop - Match concepts
        DragDropStep(
          id: 's1_1_dd1',
          instruction: 'Kavramlari dogru kutulara suruklе!',
          items: [
            DraggableItem(id: 'cat', content: '🐱 Kedi', color: Color(0xFF4C97FF)),
            DraggableItem(id: 'stage', content: '🎪 Arka plan', color: Color(0xFF9966FF)),
            DraggableItem(id: 'ball', content: '⚽ Top', color: Color(0xFF4C97FF)),
            DraggableItem(id: 'space', content: '🌌 Uzay', color: Color(0xFF9966FF)),
          ],
          dropZones: [
            DropZone(id: 'sprite', label: 'Kukla', hint: 'Hareket eden seyler'),
            DropZone(id: 'backdrop', label: 'Arka Plan', hint: 'Sahnenin gorunumu'),
          ],
          correctMapping: {
            'cat': 'sprite',
            'ball': 'sprite',
            'stage': 'backdrop',
            'space': 'backdrop',
          },
          successMessage: 'Harika! Artik kukla ve arka plani ayirt edebiliyorsun!',
          xpReward: 15,
        ),

        // Step 6: Block categories intro
        ExplanationStep(
          id: 's1_1_exp3',
          title: 'Blok Turleri',
          content: 'Scratch\'ta her renk farkli bir is yapar:',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Hareket',
              color: Color(0xFF4C97FF),
              label: 'Mavi - Hareket ettir',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Gorunum',
              color: Color(0xFF9966FF),
              label: 'Mor - Gorunus degistir',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Ses',
              color: Color(0xFFCF63CF),
              label: 'Pembe - Ses cal',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Olay',
              color: Color(0xFFFFBF00),
              label: 'Sari - Baslatici',
            ),
          ],
        ),

        // Step 7: Quiz - Block colors
        MultipleChoiceStep(
          id: 's1_1_q2',
          question: 'Kuklayi hareket ettirmek icin hangi renk blogu kullanirsin?',
          options: [
            ChoiceOption(text: 'Mor', emoji: '🟣'),
            ChoiceOption(text: 'Mavi', emoji: '🔵'),
            ChoiceOption(text: 'Sari', emoji: '🟡'),
            ChoiceOption(text: 'Yesil', emoji: '🟢'),
          ],
          correctIndex: 1,
          explanation: 'Mavi bloklar hareket icindir! Kuklayi yukari, asagi, saga, sola - nereye istersen gotur.',
          xpReward: 10,
        ),

        // Step 8: Mini game - Catch the blocks
        MiniGameStep(
          id: 's1_1_game',
          title: 'Blok Yakala!',
          instruction: 'Dusen bloklari dogru kategoriye koy. Mavi = Hareket, Mor = Gorunum',
          gameType: MiniGameType.catchTheBlock,
          gameConfig: {
            'duration': 30,
            'categories': ['motion', 'looks'],
            'speed': 'slow',
          },
          targetScore: 50,
          xpReward: 20,
        ),

        // Step 9: Lesson summary
        ExplanationStep(
          id: 's1_1_summary',
          title: 'Ogrendiklerin',
          content: '🎉 Tebrikler! Ilk dersini tamamladin!\n\n✓ Scratch\'in ne oldugunu ogrendin\n✓ Kukla ve sahneyi tandin\n✓ Blok renklerini kesfettin\n\nSimdi gercek kodlamaya hazirsin!',
          tipEmoji: '🏆',
          tip: 'Scratch Baslangic rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.2: Ilk Programin
    InteractiveLesson(
      id: 'scratch_1_2',
      courseId: 'scratch',
      title: 'Kediyi Yurut!',
      subtitle: 'Ilk programini yaz',
      order: 2,
      xpReward: 60,
      badge: 'first_code',
      steps: [
        IntroStep(
          id: 's1_2_intro',
          mascotEmoji: '🐱',
          mascotMessage: 'Simdi beni yuruteceksin! Hazir misin? Cok heyecanlandim!',
        ),

        // Explain green flag
        ExplanationStep(
          id: 's1_2_exp1',
          title: 'Yesil Bayrak',
          content: 'Her program bir baslangica ihtiyac duyar. Scratch\'ta bu "Yesil Bayrak"tir.\n\nYesil bayraga tiklandiginda, program baslar!',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'tıklandığında',
              color: Color(0xFFFFBF00),
              label: 'Baslatici Blok',
            ),
          ],
        ),

        // First block sequence
        ExplanationStep(
          id: 's1_2_exp2',
          title: 'Bloklari Birlestir',
          content: 'Bloklari ustuste koy - bir zincir gibi. Ustten alta sirayla calisir.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: '10 adim git',
              color: Color(0xFF4C97FF),
            ),
          ],
        ),

        // Interactive: Build your first program
        BlockBuilderStep(
          id: 's1_2_build1',
          instruction: 'Kediyi 10 adim yurutmek icin bloklari sirala!',
          goal: 'Kedi saga dogru 10 adim yurusun',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'move_10',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '10 adim git',
              color: Color(0xFF4C97FF),
              inputs: [
                BlockInput(
                  name: 'steps',
                  type: BlockInputType.number,
                  defaultValue: 10,
                ),
              ],
            ),
          ],
          correctSequence: ['green_flag', 'move_10'],
          xpReward: 20,
        ),

        // Make it say something
        ExplanationStep(
          id: 's1_2_exp3',
          title: 'Kedi Konussun!',
          content: 'Simdi kediyi konusturalim. "soyle" blogu ile kedi bir konusma balonu icinde mesaj gosterir.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Merhaba de',
              color: Color(0xFF9966FF),
            ),
          ],
          tipEmoji: '💬',
          tip: 'Scratch\'ta mor renkli bloklar "Gorunum" kategorisindedir.',
        ),

        // Build: Walk and talk
        BlockBuilderStep(
          id: 's1_2_build2',
          instruction: 'Kedi yurusun ve "Merhaba" desin',
          goal: 'Kedi 10 adim gidip sonra "Merhaba" desin',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'move_10',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: '10 adim git',
              color: Color(0xFF4C97FF),
              inputs: [
                BlockInput(
                  name: 'steps',
                  type: BlockInputType.number,
                  defaultValue: 10,
                ),
              ],
            ),
            ScratchBlock(
              id: 'say_hello',
              blockType: ScratchBlockType.looks,
              shape: ScratchBlockShape.stack,
              label: 'Merhaba de',
              color: Color(0xFF9966FF),
              inputs: [
                BlockInput(
                  name: 'message',
                  type: BlockInputType.text,
                  defaultValue: 'Merhaba',
                ),
              ],
            ),
          ],
          correctSequence: ['green_flag', 'move_10', 'say_hello'],
          xpReward: 20,
        ),

        // Quiz: Order matters
        OrderingStep(
          id: 's1_2_order',
          instruction: 'Bloklari dogru siraya koy',
          items: [
            OrderItem(id: 'move', content: '10 adim git'),
            OrderItem(id: 'flag', content: 'tıklandığında'),
            OrderItem(id: 'say', content: 'Bitti! soyle'),
          ],
          correctOrder: ['flag', 'move', 'say'],
          context: 'Kedi yuruyup sonra "Bitti!" soylesin',
          xpReward: 15,
        ),

        // Summary
        ExplanationStep(
          id: 's1_2_summary',
          title: 'Harika Is!',
          content: '🎊 Ilk programini yazdin!\n\n✓ Yesil bayragi ogrendin\n✓ Bloklari birlestirdin\n✓ Kediyi yurutup konusturdun\n\nSen artik bir programcisin!',
          tipEmoji: '🎖️',
          tip: 'Ilk Kod rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 1.3: Donguler
    InteractiveLesson(
      id: 'scratch_1_3',
      courseId: 'scratch',
      title: 'Tekrarla Tekrarla!',
      subtitle: 'Dongu ile sihir yap',
      order: 3,
      xpReward: 70,
      badge: 'loop_master',
      steps: [
        IntroStep(
          id: 's1_3_intro',
          mascotEmoji: '🔄',
          mascotMessage: 'Surekli ayni seyi yazmak yorucu! Sana bir sihir ogreteyim: DONGU!',
        ),

        // Problem without loop
        ExplanationStep(
          id: 's1_3_exp1',
          title: 'Problem: Cok Tekrar',
          content: 'Kediyi 100 adim yurUtmek istiyorsun. Tek tek yazmak lazim mi?',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '10 adim git',
              color: Color(0xFF4C97FF),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: '10 adim git',
              color: Color(0xFF4C97FF),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: '10 adim git',
              color: Color(0xFF4C97FF),
            ),
            VisualElement(
              type: VisualType.icon,
              content: '...ve 7 tane daha?! 😰',
            ),
          ],
          tipEmoji: '🤔',
          tip: 'Bu cok uzun ve sikici olur!',
        ),

        // Introduce loop
        ExplanationStep(
          id: 's1_3_exp2',
          title: 'Cozum: Dongu!',
          content: '"Tekrarla" blogu ayni isi istedigin kadar tekrarlar.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '10 kere tekrarla',
              color: Color(0xFFFFAB19),
              label: 'Kontrol Blogu',
            ),
          ],
        ),

        // Visual comparison
        AnimationStep(
          id: 's1_3_anim1',
          title: 'Karsilastir',
          description: 'Dongusuz vs Dongulu',
          animationType: AnimationType.comparison,
          animationData: {
            'before': ['10 adim git', '10 adim git', '10 adim git', '...'],
            'after': ['10 kere tekrarla { 10 adim git }'],
          },
        ),

        // Quiz: How many times?
        MultipleChoiceStep(
          id: 's1_3_q1',
          question: 'Kedi 50 adim gitmesi icin "10 adim git" kac kere tekrarlanmali?',
          options: [
            ChoiceOption(text: '10 kere', emoji: '🔟'),
            ChoiceOption(text: '5 kere', emoji: '5️⃣'),
            ChoiceOption(text: '50 kere', emoji: '5️⃣0️⃣'),
            ChoiceOption(text: '100 kere', emoji: '💯'),
          ],
          correctIndex: 1,
          explanation: '10 x 5 = 50! Yani 5 kere tekrarla yeterli.',
          xpReward: 10,
        ),

        // Build: Loop program
        BlockBuilderStep(
          id: 's1_3_build1',
          instruction: 'Kedi 4 kere "Miyav!" desin. Dongu kullan!',
          goal: 'Kedi art arda 4 kere miyavlasin',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'repeat_4',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: '4 kere tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'say_meow',
              blockType: ScratchBlockType.looks,
              shape: ScratchBlockShape.stack,
              label: 'Miyav! de',
              color: Color(0xFF9966FF),
            ),
          ],
          correctSequence: ['green_flag', 'repeat_4', 'say_meow'],
          xpReward: 20,
        ),

        // Forever loop
        ExplanationStep(
          id: 's1_3_exp3',
          title: 'Sonsuz Dongu',
          content: '"Surekli tekrarla" blogu hic durmuyor! Oyunlar icin mukemmel.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'surekli tekrarla',
              color: Color(0xFFFFAB19),
              label: 'Sonsuz Dongu',
            ),
          ],
          tipEmoji: '♾️',
          tip: 'Dikkat: Sonsuz donguyu durdurmak icin kirmizi butona bas!',
        ),

        // Drag & Drop: Loop vs No Loop
        DragDropStep(
          id: 's1_3_dd1',
          instruction: 'Hangileri dongu kullanmali? Surukle!',
          items: [
            DraggableItem(id: 'walk100', content: '100 adim yuru'),
            DraggableItem(id: 'jump1', content: '1 kere zipla'),
            DraggableItem(id: 'dance', content: 'Surekli dans et'),
            DraggableItem(id: 'say_hi', content: 'Bir kere selam ver'),
          ],
          dropZones: [
            DropZone(id: 'loop', label: 'Dongu Gerekli', hint: 'Tekrar eden isler'),
            DropZone(id: 'noloop', label: 'Dongu Gereksiz', hint: 'Tek seferlik isler'),
          ],
          correctMapping: {
            'walk100': 'loop',
            'dance': 'loop',
            'jump1': 'noloop',
            'say_hi': 'noloop',
          },
          xpReward: 15,
        ),

        // Mini game
        MiniGameStep(
          id: 's1_3_game',
          title: 'Dongu Ustasi',
          instruction: 'Dogru tekrar sayisini sec! Hedefe ulasmayi dene.',
          gameType: MiniGameType.blockPuzzle,
          gameConfig: {
            'type': 'loop_calculator',
            'levels': 5,
          },
          targetScore: 100,
          xpReward: 25,
        ),

        // Summary
        ExplanationStep(
          id: 's1_3_summary',
          title: 'Dongu Ustasi Oldun!',
          content: '🎉 Donguler artik senin aracin!\n\n✓ Tekrar eden isleri otomatiklestirdin\n✓ Sonsuz donguyu kesfettin\n✓ Kod daha kisa, daha guclu!\n\nBir sonraki derste: Kosullar!',
          tipEmoji: '🏅',
          tip: 'Dongu Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 2: ETKILEŞIM VE KONTROL
  // ==========================================
  static final List<InteractiveLesson> module2 = [
    InteractiveLesson(
      id: 'scratch_2_1',
      courseId: 'scratch',
      title: 'Eger-Ise Sihri',
      subtitle: 'Kosullar ile akilli programlar',
      order: 4,
      xpReward: 75,
      badge: 'condition_wizard',
      steps: [
        IntroStep(
          id: 's2_1_intro',
          mascotEmoji: '🧙',
          mascotMessage: 'Programlar karar verebilir mi? EVET! Sana "Eger-Ise" sihirini ogretecegim!',
        ),

        ExplanationStep(
          id: 's2_1_exp1',
          title: 'Kosul Nedir?',
          content: 'Kosul, bir sorunun cevabina gore farkli seyler yapmaktir.\n\nGercek hayat ornegi:\n"Eger hava yagmurluysa, semsiye al. Degilse, al-ma."',
          tipEmoji: '☔',
          tip: 'Bilgisayarlar surekli karar veriyor!',
        ),

        ExplanationStep(
          id: 's2_1_exp2',
          title: 'Eger Blogu',
          content: 'Scratch\'ta "eger" blogu kosul kontrol eder.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'eger <...> ise',
              color: Color(0xFFFFAB19),
              label: 'Kontrol Blogu',
            ),
          ],
        ),

        // Matching game: Real life conditions
        MatchingStep(
          id: 's2_1_match1',
          instruction: 'Kosullari sonuclariyla esle!',
          pairs: [
            MatchPair(
              id: '1',
              left: 'Eger ac isem',
              right: 'Yemek ye',
            ),
            MatchPair(
              id: '2',
              left: 'Eger yorgun isem',
              right: 'Uyu',
            ),
            MatchPair(
              id: '3',
              left: 'Eger disa cikacaksam',
              right: 'Ayakkabi giy',
            ),
            MatchPair(
              id: '4',
              left: 'Eger susuz isem',
              right: 'Su ic',
            ),
            MatchPair(
              id: '5',
              left: 'Eger soguk ise',
              right: 'Kalin giy',
            ),
            MatchPair(
              id: '6',
              left: 'Eger sicak ise',
              right: 'Sort giy',
            ),
          ],
          xpReward: 15,
        ),

        // Sensing blocks
        ExplanationStep(
          id: 's2_1_exp3',
          title: 'Algilama Bloklari',
          content: 'Kukla cevreden bilgi alir:',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '<tusa basildi mi?>',
              color: Color(0xFF5CB1D6),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: '<fareye degdi mi?>',
              color: Color(0xFF5CB1D6),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: '<kenara degdi mi?>',
              color: Color(0xFF5CB1D6),
            ),
          ],
        ),

        // Build: Key press
        BlockBuilderStep(
          id: 's2_1_build1',
          instruction: 'Bosluk tusuna basinca kedi "Zipladin!" desin',
          goal: 'Tus basimina tepki ver',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'surekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'if_space',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'eger <bosluk basildi> ise',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'say_jump',
              blockType: ScratchBlockType.looks,
              shape: ScratchBlockShape.stack,
              label: 'Zipladin! de',
              color: Color(0xFF9966FF),
            ),
          ],
          correctSequence: ['green_flag', 'forever', 'if_space', 'say_jump'],
          xpReward: 25,
        ),

        // Else block
        ExplanationStep(
          id: 's2_1_exp4',
          title: 'Eger-Degilse',
          content: 'Kosul dogru degilse ne olacak? "degilse" kismi bunu soyler.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'eger <...> ise ... degilse ...',
              color: Color(0xFFFFAB19),
            ),
          ],
        ),

        // Quiz
        MultipleChoiceStep(
          id: 's2_1_q1',
          question: '"eger <puan > 100> ise \'Kazandin!\' de" - Puan 50 ise ne olur?',
          options: [
            ChoiceOption(text: '"Kazandin!" der', emoji: '🏆'),
            ChoiceOption(text: 'Hicbir sey olmaz', emoji: '😶'),
            ChoiceOption(text: 'Hata verir', emoji: '❌'),
            ChoiceOption(text: 'Oyun biter', emoji: '🛑'),
          ],
          correctIndex: 1,
          explanation: 'Puan 50 < 100 oldugu icin kosul saglanmaz ve "degilse" kismi olmadigi icin hicbir sey olmaz.',
          xpReward: 10,
        ),

        // Mini project
        ProjectStep(
          id: 's2_1_project',
          title: 'Mini Proje: Isik Anahtari',
          description: 'Tusa basinca isik acilsin, tekrar basinca kapansin!',
          requirements: [
            'Bosluk tusuna basinca isik acilsin (parlak kostum)',
            'Tekrar basinca kapansin (karanlik kostum)',
          ],
          hints: [
            'Bir degisken kullan: isik_acik',
            'Eger isik_acik = 1 ise kapali yap',
            'Degilse acik yap',
          ],
          starterCode: '',
          language: 'scratch',
          validation: ProjectValidation(
            mustContain: ['eger', 'kostum'],
          ),
          xpReward: 30,
        ),

        ExplanationStep(
          id: 's2_1_summary',
          title: 'Kosul Buyucusu!',
          content: '🧙 Artik programlarin karar vermesini saglayabilirsin!\n\n✓ Eger-ise yapisi\n✓ Algilama bloklari\n✓ Tus kontrolleri\n\nSonraki: Hareket ve koordinatlar!',
          tipEmoji: '🏅',
          tip: 'Kosul Buyucusu rozetini kazandin!',
        ),
      ],
    ),

    // LESSON 2.2: Hareket ve Koordinatlar
    InteractiveLesson(
      id: 'scratch_2_2',
      courseId: 'scratch',
      title: 'X ve Y Macerasi',
      subtitle: 'Koordinatlarla dans et',
      order: 5,
      xpReward: 70,
      badge: 'coordinate_explorer',
      steps: [
        IntroStep(
          id: 's2_2_intro',
          mascotEmoji: '📍',
          mascotMessage: 'Her seyin bir adresi var! Scratch\'ta bu adrese X ve Y diyoruz. Haydi ogrenn!',
        ),

        ExplanationStep(
          id: 's2_2_exp1',
          title: 'Sahne Haritasi',
          content: 'Sahne bir harita gibi. Ortasi (0, 0) noktasi.',
          visuals: [
            VisualElement(
              type: VisualType.diagram,
              content: 'coordinate_grid',
              label: 'X: Sag-Sol, Y: Yukari-Asagi',
            ),
          ],
          tipEmoji: '🗺️',
          tip: 'X pozitif = sag, X negatif = sol\nY pozitif = yukari, Y negatif = asagi',
        ),

        // Interactive coordinate game
        MiniGameStep(
          id: 's2_2_game1',
          title: 'Koordinat Avcisi',
          instruction: 'Verilen koordinata kediyitasi! Ekrana dokun.',
          gameType: MiniGameType.blockPuzzle,
          gameConfig: {
            'type': 'coordinate_tap',
            'grid_size': 5,
            'targets': 10,
          },
          targetScore: 80,
          xpReward: 20,
        ),

        // Motion blocks
        ExplanationStep(
          id: 's2_2_exp2',
          title: 'Hareket Bloklari',
          content: 'Kuklayi koordinatlarla kontrol et:',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'x: 100, y: 50 konumuna git',
              color: Color(0xFF4C97FF),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'x\'i 10 degistir',
              color: Color(0xFF4C97FF),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: '1 saniyede x: 0, y: 0 konumuna kay',
              color: Color(0xFF4C97FF),
            ),
          ],
        ),

        // Build: Move to corners
        BlockBuilderStep(
          id: 's2_2_build1',
          instruction: 'Kediyi sag ust koseye tasi (x: 200, y: 150)',
          goal: 'Kedi sag ust kosede olsun',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'goto_corner',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: 'x: 200, y: 150 git',
              color: Color(0xFF4C97FF),
            ),
            ScratchBlock(
              id: 'goto_center',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: 'x: 0, y: 0 git',
              color: Color(0xFF4C97FF),
            ),
          ],
          correctSequence: ['green_flag', 'goto_corner'],
          xpReward: 15,
        ),

        // Quiz: Coordinates
        MultipleChoiceStep(
          id: 's2_2_q1',
          question: 'Kukla x: -200, y: 0 konumunda. Nerede?',
          options: [
            ChoiceOption(text: 'Sag kenarda', emoji: '➡️'),
            ChoiceOption(text: 'Sol kenarda', emoji: '⬅️'),
            ChoiceOption(text: 'Ortada', emoji: '⭕'),
            ChoiceOption(text: 'Ustte', emoji: '⬆️'),
          ],
          correctIndex: 1,
          explanation: 'X = -200 cok kucuk bir sayi, yani sol tarafta! Y = 0 oldugu icin dikey ortada.',
          xpReward: 10,
        ),

        // Arrow key movement
        ExplanationStep(
          id: 's2_2_exp3',
          title: 'Ok Tuslariyla Hareket',
          content: 'Oyunlarda ok tuslariyla hareket:',
          visuals: [
            VisualElement(
              type: VisualType.flowchart,
              content: 'arrow_movement',
              label: '⬆️ Y artir, ⬇️ Y azalt, ⬅️ X azalt, ➡️ X artir',
            ),
          ],
        ),

        // Build: Arrow controls
        BlockBuilderStep(
          id: 's2_2_build2',
          instruction: 'Sag ok tusuna basinca kedi saga gitsin',
          goal: 'Ok tusu kontrolleri',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'surekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'if_right',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'eger <sag ok basildi> ise',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'change_x',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: 'x\'i 10 degistir',
              color: Color(0xFF4C97FF),
            ),
          ],
          correctSequence: ['green_flag', 'forever', 'if_right', 'change_x'],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 's2_2_summary',
          title: 'Koordinat Kaptani!',
          content: '🧭 X ve Y artik senin elindefind!\n\n✓ Koordinat sistemi\n✓ Hareket bloklari\n✓ Ok tusu kontrolleri\n\nSonraki: Ilk oyununu yapacaksin!',
          tipEmoji: '🏅',
          tip: 'Koordinat Kaptani rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 3: ILK OYUNUNU YAP!
  // ==========================================
  static final List<InteractiveLesson> module3 = [
    InteractiveLesson(
      id: 'scratch_3_1',
      courseId: 'scratch',
      title: 'Kedi Fare Oyunu',
      subtitle: 'Ilk gercek oyunun!',
      order: 6,
      xpReward: 100,
      badge: 'game_developer',
      category: LessonCategory.project,
      steps: [
        IntroStep(
          id: 's3_1_intro',
          mascotEmoji: '🎮',
          mascotMessage: 'OYUN ZAMANI! Bir kedi-fare kovalama oyunu yapacagiz. Hazir misin?!',
        ),

        ExplanationStep(
          id: 's3_1_exp1',
          title: 'Oyun Plani',
          content: '🎯 Hedef: Kedi fareyi yakalasin!\n\n🐱 Kedi: Sen kontrol et (ok tuslari)\n🐭 Fare: Rastgele hareket etsin\n⭐ Puan: Her yakalayista +1',
        ),

        // Step by step project build
        ExplanationStep(
          id: 's3_1_exp2',
          title: 'Adim 1: Kedi Hareketi',
          content: 'Once kediyi ok tuslariyla kontrol edelim.',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'surekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'eger <yukari ok> ise y\'yi 10 degistir',
              color: Color(0xFFFFAB19),
            ),
          ],
        ),

        // Build cat movement
        BlockBuilderStep(
          id: 's3_1_build1',
          instruction: '4 yon kontrollu kedi hareketi yap',
          goal: 'Kedi tum ok tuslariyla hareket etsin',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'surekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'if_up',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'eger <yukari ok> ise',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'change_y_up',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: 'y\'yi 10 degistir',
              color: Color(0xFF4C97FF),
            ),
          ],
          correctSequence: ['green_flag', 'forever', 'if_up', 'change_y_up'],
          xpReward: 20,
        ),

        ExplanationStep(
          id: 's3_1_exp3',
          title: 'Adim 2: Fare Hareketi',
          content: 'Fare rastgele konuma ziplar!',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'rastgele konuma git',
              color: Color(0xFF4C97FF),
            ),
          ],
        ),

        ExplanationStep(
          id: 's3_1_exp4',
          title: 'Adim 3: Yakalama Kontrolu',
          content: 'Kedi fareye degdi mi kontrol et:',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'eger <Kedi\'ye degdi mi?> ise',
              color: Color(0xFFFFAB19),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'puani 1 degistir',
              color: Color(0xFFFF8C1A),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'rastgele konuma git',
              color: Color(0xFF4C97FF),
            ),
          ],
        ),

        // Final project
        ProjectStep(
          id: 's3_1_project',
          title: 'Kedi-Fare Oyunu',
          description: 'Tam oyunu tamamla!',
          requirements: [
            'Kedi 4 yon hareket etsin',
            'Fare yakalaninca rastgele kacsin',
            'Her yakalamada puan artsin',
            'Puani ekranda goster',
          ],
          hints: [
            'Puan icin degisken olustur',
            'Fare kuklasi icin ayri kod yaz',
            'Kedi kontrollerini daha once yaptik',
          ],
          starterCode: '',
          language: 'scratch',
          validation: ProjectValidation(
            mustContain: ['degisken', 'degdi', 'rastgele'],
          ),
          xpReward: 50,
        ),

        ExplanationStep(
          id: 's3_1_summary',
          title: 'OYUN GELISTIRICI!',
          content: '🎉🎮🎉 ILK OYUNUNU TAMAMLADIN!\n\n✓ Oyuncu kontrollu karakter\n✓ Rastgele hareket eden dusman\n✓ Puan sistemi\n\nSen artik bir oyun gelistiricisin!',
          tipEmoji: '🏆',
          tip: 'Oyun Gelistirici rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 4: DEĞİŞKENLER VE PUAN
  // ==========================================
  static final List<InteractiveLesson> module4 = [
    InteractiveLesson(
      id: 'scratch_4_1',
      courseId: 'scratch',
      title: 'Degiskenler',
      subtitle: 'Bilgiyi sakla, kullan',
      order: 7,
      xpReward: 80,
      badge: 'variable_master',
      steps: [
        IntroStep(
          id: 's4_1_intro',
          mascotEmoji: '📦',
          mascotMessage: 'Degiskenler kutu gibidir! Icine puan, isim, herhangi bir bilgi koyabilirsin!',
        ),

        ExplanationStep(
          id: 's4_1_exp1',
          title: 'Degisken Nedir?',
          content: 'Degisken = Bilgi Kutusu\n\nOyununda puan tutmak istiyorsun. Her kere artar:\nPuan = 0\nPuan = Puan + 1\nPuan = Puan + 10',
        ),

        MultipleChoiceStep(
          id: 's4_1_q1',
          question: 'Degisken ne ise yarar?',
          options: [
            ChoiceOption(text: 'Bilgi saklamak', emoji: '✅'),
            ChoiceOption(text: 'Kuklayi hareket ettirmek', emoji: '❌'),
            ChoiceOption(text: 'Ses calmak', emoji: '❌'),
            ChoiceOption(text: 'Renk degistirmek', emoji: '❌'),
          ],
          correctIndex: 0,
          explanation: 'Degisken bilgi saklamak icindir! Puan, isim, can, seviye...',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 's4_1_exp2',
          title: 'Degisken Olustur',
          content: 'Degiskenler bolumunde:\n\n1. "Degisken Olustur" tikla\n2. İsim ver (ornek: Puan)\n3. Tamam\'a bas\n\nSon! Artik degiskenini kullanabilirsin.',
        ),

        ExplanationStep(
          id: 's4_1_exp3',
          title: 'Degisken Bloklari',
          content: 'Degiskenler ile yapabileceklerin:\n\n• Degeri degistir (Puan = 10)\n• Arttir (Puan + 1)\n• Ekranda goster/gizle',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Puan 0 yap',
              color: Color(0xFFFF8C1A),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Puan 1 degistir',
              color: Color(0xFFFF8C1A),
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 's4_1_q2',
          question: 'Puan = 5. "Puan 3 degistir" blogu ne yapar?',
          options: [
            ChoiceOption(text: 'Puan = 3 olur', emoji: '❌'),
            ChoiceOption(text: 'Puan = 8 olur', emoji: '✅'),
            ChoiceOption(text: 'Puan = 2 olur', emoji: '❌'),
            ChoiceOption(text: 'Hicbir sey olmaz', emoji: '❌'),
          ],
          correctIndex: 1,
          explanation: '"Degistir" demek arttir demek! 5 + 3 = 8',
          xpReward: 10,
        ),

        BlockBuilderStep(
          id: 's4_1_build1',
          instruction: 'Oyun baslayinca Puan 0 olsun',
          goal: 'Yesil bayrak tiklaninca puani sifirla',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'set_score_0',
              blockType: ScratchBlockType.variables,
              shape: ScratchBlockShape.stack,
              label: 'Puan 0 yap',
              color: Color(0xFFFF8C1A),
            ),
          ],
          correctSequence: ['green_flag', 'set_score_0'],
          xpReward: 20,
        ),

        ExplanationStep(
          id: 's4_1_summary',
          title: 'Degisken Ustasi!',
          content: '📦 Artik bilgiyi saklayabilirsin!\n\n✓ Degisken olusturma\n✓ Degisken kullanimi\n✓ Puan sistemi temeli\n\nSonraki: Puan sistemi yapacagiz!',
          tipEmoji: '🏅',
          tip: 'Degisken Ustasi rozetini kazandin!',
        ),
      ],
    ),

    InteractiveLesson(
      id: 'scratch_4_2',
      courseId: 'scratch',
      title: 'Puan Sistemi',
      subtitle: 'Oyuna puan ekle',
      order: 8,
      xpReward: 90,
      badge: 'score_keeper',
      steps: [
        IntroStep(
          id: 's4_2_intro',
          mascotEmoji: '⭐',
          mascotMessage: 'Her oyunun puani vardir! Simdi kendi puan sistemini yapacaksin!',
        ),

        ExplanationStep(
          id: 's4_2_exp1',
          title: 'Puan Sistemi Plani',
          content: '1. Puan degiskeni olustur\n2. Oyun basinda sifirla\n3. Basarili olunca arttir\n4. Ekranda goster',
        ),

        BlockBuilderStep(
          id: 's4_2_build1',
          instruction: 'Fareyi yakalayinca puan +1 artsın',
          goal: 'Kedi fareye degince puan artsın',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'surekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'if_touching',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'eger <Fare\'ye degdi> ise',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'change_score',
              blockType: ScratchBlockType.variables,
              shape: ScratchBlockShape.stack,
              label: 'Puan 1 degistir',
              color: Color(0xFFFF8C1A),
            ),
          ],
          correctSequence: ['green_flag', 'forever', 'if_touching', 'change_score'],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 's4_2_exp2',
          title: 'Seviye Sistemi',
          content: 'Puana gore seviye belirle:\n\nPuan 0-10: Seviye 1\nPuan 11-20: Seviye 2\nPuan 21+: Seviye 3',
        ),

        MultipleChoiceStep(
          id: 's4_2_q1',
          question: 'Puan 25 ise hangi seviye?',
          options: [
            ChoiceOption(text: 'Seviye 1', emoji: '1️⃣'),
            ChoiceOption(text: 'Seviye 2', emoji: '2️⃣'),
            ChoiceOption(text: 'Seviye 3', emoji: '3️⃣'),
            ChoiceOption(text: 'Seviye 4', emoji: '4️⃣'),
          ],
          correctIndex: 2,
          explanation: '25 > 20 oldugu icin Seviye 3!',
          xpReward: 10,
        ),

        ProjectStep(
          id: 's4_2_project',
          title: 'Mini Proje: Yildiz Toplayici',
          description: 'Yildiz topla, puan kazan!',
          requirements: [
            'Puan degiskeni olustur',
            'Her yildiz +10 puan versin',
            'Ekranda puani goster',
            '50 puana ulasinca "Kazandin!" soyle',
          ],
          hints: [
            'Yildiz kuklasi olustur',
            'Yildiza degilirse puan arttir',
            'Puani kontrol et (eger > 50)',
          ],
          starterCode: '',
          language: 'scratch',
          validation: ProjectValidation(
            mustContain: ['degisken', 'eger', 'degdi'],
          ),
          xpReward: 40,
        ),

        ExplanationStep(
          id: 's4_2_summary',
          title: 'Puan Koruyucusu!',
          content: '⭐ Oyunlara puan sistemi ekleyebilirsin!\n\n✓ Puan arttirma\n✓ Seviye sistemi\n✓ Kosullu puanlama\n\nSonraki modul: Klonlar!',
          tipEmoji: '🏆',
          tip: 'Puan Koruyucusu rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 5: KLONLAR VE İLERİ SEVİYE
  // ==========================================
  static final List<InteractiveLesson> module5 = [
    InteractiveLesson(
      id: 'scratch_5_1',
      courseId: 'scratch',
      title: 'Klonlar',
      subtitle: 'Kuklayi cogalt!',
      order: 9,
      xpReward: 100,
      badge: 'clone_master',
      steps: [
        IntroStep(
          id: 's5_1_intro',
          mascotEmoji: '👥',
          mascotMessage: 'Klonlar = Kuklanin kopyasi! 1 kukla yerine 10, 100 kukla!',
        ),

        ExplanationStep(
          id: 's5_1_exp1',
          title: 'Klon Nedir?',
          content: 'Klon, kuklanin tam kopyasidir. Ayni gorunum, ayni kod, ama ayri hareket eder.',
          tipEmoji: '🎭',
          tip: 'Oyunlarda dusman, mermi, yildiz gibi cok nesne icin kullanilir!',
        ),

        ExplanationStep(
          id: 's5_1_exp2',
          title: 'Klon Olusturma',
          content: 'Klon bloklari (Kontrol kategorisinde):\n\n• Kendinin klonunu olustur\n• Klon olarak basladiginda\n• Bu klonu sil',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'kendimin klonunu olustur',
              color: Color(0xFFFFAB19),
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'klon olarak basladiginda',
              color: Color(0xFFFFBF00),
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 's5_1_q1',
          question: '1 kukla "10 kere tekrarla: klon olustur" yapti. Toplam kac kukla var?',
          options: [
            ChoiceOption(text: '10 kukla', emoji: '❌'),
            ChoiceOption(text: '11 kukla', emoji: '✅'),
            ChoiceOption(text: '20 kukla', emoji: '❌'),
            ChoiceOption(text: '1 kukla', emoji: '❌'),
          ],
          correctIndex: 1,
          explanation: 'Orjinal 1 + 10 klon = 11 kukla!',
          xpReward: 10,
        ),

        BlockBuilderStep(
          id: 's5_1_build1',
          instruction: 'Her 2 saniyede bir yildiz klonu olustur',
          goal: 'Surekli yildiz klonlari olusturulsun',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'forever',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.cBlock,
              label: 'surekli tekrarla',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'create_clone',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.stack,
              label: 'kendimin klonunu olustur',
              color: Color(0xFFFFAB19),
            ),
            ScratchBlock(
              id: 'wait_2',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.stack,
              label: '2 saniye bekle',
              color: Color(0xFFFFAB19),
            ),
          ],
          correctSequence: ['green_flag', 'forever', 'create_clone', 'wait_2'],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 's5_1_exp3',
          title: 'Klonlari Yonet',
          content: 'Her klon kendi baslangic kodunu calistirir:\n\nKlon olarak basladiginda:\n• Rastgele konuma git\n• Asagi hareket et\n• Kenara degince sil',
        ),

        BlockBuilderStep(
          id: 's5_1_build2',
          instruction: 'Klon olusunca rastgele konuma gitsin ve silinsin',
          goal: 'Klonlar rastgele yerden baslayip silinsin',
          availableBlocks: [
            ScratchBlock(
              id: 'when_clone',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'klon olarak basladiginda',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'goto_random',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: 'rastgele konuma git',
              color: Color(0xFF4C97FF),
            ),
            ScratchBlock(
              id: 'delete_clone',
              blockType: ScratchBlockType.control,
              shape: ScratchBlockShape.stack,
              label: 'bu klonu sil',
              color: Color(0xFFFFAB19),
            ),
          ],
          correctSequence: ['when_clone', 'goto_random', 'delete_clone'],
          xpReward: 25,
        ),

        ProjectStep(
          id: 's5_1_project',
          title: 'Mini Proje: Yildiz Yagmuru',
          description: 'Gokten yildiz yagsin!',
          requirements: [
            'Her 1 saniyede yildiz klonu olustur',
            'Klonlar ustten baslasin',
            'Asagi dusup alta gelince silinsin',
            'Kediyle degince puan +1',
          ],
          hints: [
            'Klon olusturma zamanlayici',
            'y koordinatini surekli azalt',
            'y < -180 ise klonu sil',
          ],
          starterCode: '',
          language: 'scratch',
          validation: ProjectValidation(
            mustContain: ['klon', 'surekli', 'eger'],
          ),
          xpReward: 50,
        ),

        ExplanationStep(
          id: 's5_1_summary',
          title: 'Klon Ustasi!',
          content: '👥 Artik sinirsiz kukla olusturabilirsin!\n\n✓ Klon olusturma\n✓ Klon yonetimi\n✓ Dinamik oyunlar\n\nSonraki: Ileri seviye oyun!',
          tipEmoji: '🏆',
          tip: 'Klon Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 6: MESAJLAR VE YAYINLAR
  // ==========================================
  static final List<InteractiveLesson> module6 = [
    InteractiveLesson(
      id: 'scratch_6_1',
      courseId: 'scratch',
      title: 'Mesajlar ve Yayinlar',
      subtitle: 'Kuklalar arasi iletisim',
      order: 10,
      xpReward: 90,
      badge: 'broadcaster',
      steps: [
        IntroStep(
          id: 's6_1_intro',
          mascotEmoji: '📡',
          mascotMessage: 'Kuklalar birbirleriyle nasil konusur? Mesajlar ile! Simdi haberlesme sistemini ogrenelim!',
        ),

        ExplanationStep(
          id: 's6_1_exp1',
          title: 'Mesaj Sistemi',
          content: 'Mesajlar, kukla arasi iletisimi saglar.\n\n📤 Mesaj gonder: "yayinla"\n📥 Mesaj al: "mesaj alidiginda"\n\nOrnek:\nKukla 1: "baslat" mesaji yayinla\nKukla 2: "baslat" mesaji alidiginda dans et',
          tipEmoji: '💬',
          tip: 'Mesajlar oyunlarda cok kullanilir! Seviye bitis, dusman yok etme vs.',
        ),

        MultipleChoiceStep(
          id: 's6_1_q1',
          question: 'Bir kukla diger kuklay nasil harekete gecirir?',
          options: [
            ChoiceOption(text: 'Mesaj yayinlayarak', emoji: '📡'),
            ChoiceOption(text: 'El sallayarak', emoji: '👋'),
            ChoiceOption(text: 'Bagirarak', emoji: '📢'),
            ChoiceOption(text: 'Telefon ederek', emoji: '📞'),
          ],
          correctIndex: 0,
          explanation: 'Mesaj yayinlama sistemiyle kuklalar birbirleriyle haberlesir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 's6_1_exp2',
          title: 'Yayinla Blogu',
          content: 'Mesaj gondermek icin:',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '"oyun_basladi" mesajini yayinla',
              color: Color(0xFFFFBF00),
              label: 'Olay Blogu',
            ),
          ],
        ),

        ExplanationStep(
          id: 's6_1_exp3',
          title: 'Mesaj Alma',
          content: 'Mesaj almak icin:',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: '"oyun_basladi" mesaji alidiginda',
              color: Color(0xFFFFBF00),
              label: 'Olay Blogu',
            ),
          ],
        ),

        BlockBuilderStep(
          id: 's6_1_build1',
          instruction: 'Kedi "zipla" mesaji yayinlayinca, fare ziplamalidir!',
          goal: 'Mesajla ziplama hareketi',
          availableBlocks: [
            // Kedi için (mesaj gönderen)
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: ' tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'broadcast',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.stack,
              label: '"zipla" mesajini yayinla',
              color: Color(0xFFFFBF00),
              inputs: [
                BlockInput(
                  name: 'message',
                  type: BlockInputType.dropdown,
                  defaultValue: 'zipla',
                ),
              ],
            ),
            // Fare için (mesaj alan)
            ScratchBlock(
              id: 'receive_jump',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: '"zipla" mesaji alidiginda',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'change_y',
              blockType: ScratchBlockType.motion,
              shape: ScratchBlockShape.stack,
              label: 'y\'yi 50 degistir',
              color: Color(0xFF4C97FF),
              inputs: [
                BlockInput(
                  name: 'dy',
                  type: BlockInputType.number,
                  defaultValue: 50,
                ),
              ],
            ),
          ],
          correctSequence: ['green_flag', 'broadcast', 'receive_jump', 'change_y'],
          xpReward: 25,
        ),

        ExplanationStep(
          id: 's6_1_exp4',
          title: 'Yayinla ve Bekle',
          content: '"Yayinla ve bekle" blogu, mesaj isleri bitene kadar bekler.\n\nFarklar:\n• Yayinla: Hemen devam et\n• Yayinla ve bekle: Alici bitene kadar bekle',
          visuals: [
            VisualElement(
              type: VisualType.comparison,
              content: 'broadcast_vs_wait',
              label: 'Yayinla vs Bekle',
            ),
          ],
        ),

        ProjectStep(
          id: 's6_1_project',
          title: 'Mini Proje: Dans Partisi',
          description: '3 kukla mesajlarla dans etsin!',
          requirements: [
            'Kedi "dans_basladi" mesaji yayinlasin',
            'Fare mesaji alinca donmeye baslasin',
            'Top mesaji alinca zipla-in',
            'Her kukla farkli dans yapin',
          ],
          hints: [
            '3 kukla ekle',
            'Kedi yesil bayrakta mesaji yayinla',
            'Diger kuklalar mesaj alsinda harekete gecsin',
          ],
          starterCode: '',
          language: 'scratch',
          validation: ProjectValidation(
            mustContain: ['yayinla', 'mesaj', 'alidiginda'],
          ),
          xpReward: 40,
        ),

        ExplanationStep(
          id: 's6_1_summary',
          title: 'Yayinci Oldun!',
          content: '📡 Artik kuklalar birbirleriyle konusabilir!\n\n✓ Mesaj yayinlama\n✓ Mesaj alma\n✓ Kukla arasi koordinasyon\n\nSonraki: Ses ve muzik!',
          tipEmoji: '🏆',
          tip: 'Yayinci rozetini kazandin!',
        ),
      ],
    ),
  ];

  // ==========================================
  // MODULE 7: SES VE MÜZİK
  // ==========================================
  static final List<InteractiveLesson> module7 = [
    InteractiveLesson(
      id: 'scratch_7_1',
      courseId: 'scratch',
      title: 'Ses ve Muzik',
      subtitle: 'Oyununa ses ekle',
      order: 11,
      xpReward: 85,
      badge: 'sound_master',
      steps: [
        IntroStep(
          id: 's7_1_intro',
          mascotEmoji: '🎵',
          mascotMessage: 'Oyunlar sadece goruntuyle degil, sesle de eglenceli olur! Haydi ses eklemeyi ogrenelim!',
        ),

        ExplanationStep(
          id: 's7_1_exp1',
          title: 'Ses Bloklari',
          content: 'Scratch\'ta 2 turlu ses var:\n\n🔊 Ses Efektleri: Kisa sesler (meow, boing)\n🎶 Muzik: Uzun melodiler',
          visuals: [
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Meow sesini cal',
              color: Color(0xFFCF63CF),
              label: 'Ses Blogu',
            ),
            VisualElement(
              type: VisualType.scratchBlock,
              content: 'Davul 60 notasini 0.25 vurusla cal',
              color: Color(0xFFCF63CF),
              label: 'Muzik Blogu',
            ),
          ],
        ),

        MultipleChoiceStep(
          id: 's7_1_q1',
          question: 'Ses bloklarinin rengi nedir?',
          options: [
            ChoiceOption(text: 'Mavi', emoji: '🔵'),
            ChoiceOption(text: 'Pembe', emoji: '🩷'),
            ChoiceOption(text: 'Mor', emoji: '🟣'),
            ChoiceOption(text: 'Yesil', emoji: '🟢'),
          ],
          correctIndex: 1,
          explanation: 'Ses bloklari PEMBE renktedir!',
          xpReward: 10,
        ),

        ExplanationStep(
          id: 's7_1_exp2',
          title: 'Ses Calmak',
          content: 'Ses bloklari 2 turlu:\n\n"Ses cal": Sesi baslat, devam et\n"Ses cal ve bitene kadar bekle": Ses bitene kadar bekle',
        ),

        BlockBuilderStep(
          id: 's7_1_build1',
          instruction: 'Kedi tiklandiginda "Meow" sesini cals!',
          goal: 'Tiklandiginda ses cal',
          availableBlocks: [
            ScratchBlock(
              id: 'when_clicked_sprite',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: 'bu kukla tiklandiginda',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'play_sound',
              blockType: ScratchBlockType.sound,
              shape: ScratchBlockShape.stack,
              label: 'Meow sesini cal',
              color: Color(0xFFCF63CF),
              inputs: [
                BlockInput(
                  name: 'sound',
                  type: BlockInputType.dropdown,
                  defaultValue: 'Meow',
                ),
              ],
            ),
          ],
          correctSequence: ['when_clicked_sprite', 'play_sound'],
          xpReward: 20,
        ),

        ExplanationStep(
          id: 's7_1_exp3',
          title: 'Muzik Yapmak',
          content: 'Muzik bloklariyla melodi yapabilirsin!\n\nHer nota bir sayidir:\n60 = Do (C)\n62 = Re (D)\n64 = Mi (E)\n65 = Fa (F)\n67 = Sol (G)',
          tipEmoji: '🎹',
          tip: 'Scratch\' ta piyano gibi muzik yapabilirsin!',
        ),

        BlockBuilderStep(
          id: 's7_1_build2',
          instruction: 'Do-Re-Mi melodisi cal!',
          goal: '3 nota ard arda cals',
          availableBlocks: [
            ScratchBlock(
              id: 'green_flag',
              blockType: ScratchBlockType.events,
              shape: ScratchBlockShape.cap,
              label: ' tıklandığında',
              color: Color(0xFFFFBF00),
            ),
            ScratchBlock(
              id: 'play_note_60',
              blockType: ScratchBlockType.sound,
              shape: ScratchBlockShape.stack,
              label: '60 notasini 0.5 vurusla cal',
              color: Color(0xFFCF63CF),
              inputs: [
                BlockInput(
                  name: 'note',
                  type: BlockInputType.number,
                  defaultValue: 60,
                ),
                BlockInput(
                  name: 'beats',
                  type: BlockInputType.number,
                  defaultValue: 0.5,
                ),
              ],
            ),
            ScratchBlock(
              id: 'play_note_62',
              blockType: ScratchBlockType.sound,
              shape: ScratchBlockShape.stack,
              label: '62 notasini 0.5 vurusla cal',
              color: Color(0xFFCF63CF),
              inputs: [
                BlockInput(
                  name: 'note',
                  type: BlockInputType.number,
                  defaultValue: 62,
                ),
                BlockInput(
                  name: 'beats',
                  type: BlockInputType.number,
                  defaultValue: 0.5,
                ),
              ],
            ),
            ScratchBlock(
              id: 'play_note_64',
              blockType: ScratchBlockType.sound,
              shape: ScratchBlockShape.stack,
              label: '64 notasini 0.5 vurusla cal',
              color: Color(0xFFCF63CF),
              inputs: [
                BlockInput(
                  name: 'note',
                  type: BlockInputType.number,
                  defaultValue: 64,
                ),
                BlockInput(
                  name: 'beats',
                  type: BlockInputType.number,
                  defaultValue: 0.5,
                ),
              ],
            ),
          ],
          correctSequence: ['green_flag', 'play_note_60', 'play_note_62', 'play_note_64'],
          xpReward: 25,
        ),

        ProjectStep(
          id: 's7_1_project',
          title: 'Mini Proje: Piyano',
          description: 'Klavye tuslariyla piyano cal!',
          requirements: [
            '5 tus: A, S, D, F, G',
            'Her tus farkli nota calsın (60, 62, 64, 65, 67)',
            'Tusa basildiginda nota cals',
          ],
          hints: [
            'Her tus icin "tus basildiginda" kullan',
            'Her tusun farkli notasi olsun',
            'Surekli kontrol dongusu kullan',
          ],
          starterCode: '',
          language: 'scratch',
          validation: ProjectValidation(
            mustContain: ['eger', 'basildi', 'notasini cal'],
          ),
          xpReward: 40,
        ),

        ExplanationStep(
          id: 's7_1_summary',
          title: 'Ses Ustasi!',
          content: '🎵 Artik oyunlarina ses ekleyebilirsin!\n\n✓ Ses efektleri\n✓ Muzik notalari\n✓ Melodi yaratma\n\nTebrikler! Scratch temellerini bitirdin!',
          tipEmoji: '🏆',
          tip: 'Ses Ustasi rozetini kazandin!',
        ),
      ],
    ),
  ];

  /// Get all Scratch lessons
  static List<InteractiveLesson> get allLessons => [
    ...module1,
    ...module2,
    ...module3,
    ...module4,
    ...module5,
    ...module6,
    ...module7,
  ];

  /// Get lesson by ID
  static InteractiveLesson? getLessonById(String id) {
    try {
      return allLessons.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get lessons for a module
  static List<InteractiveLesson> getLessonsForModule(int moduleNumber) {
    switch (moduleNumber) {
      case 1: return module1;
      case 2: return module2;
      case 3: return module3;
      case 4: return module4;
      case 5: return module5;
      case 6: return module6;
      case 7: return module7;
      default: return [];
    }
  }
}

/// Scratch badges
class ScratchBadges {
  static const List<LessonBadge> all = [
    LessonBadge(
      id: 'scratch_starter',
      name: 'Scratch Baslangic',
      description: 'Scratch\'a ilk adimini attin!',
      emoji: '🐱',
      rarity: BadgeRarity.common,
      category: BadgeCategory.lesson,
    ),
    LessonBadge(
      id: 'first_code',
      name: 'Ilk Kod',
      description: 'Ilk programini yazdin!',
      emoji: '💻',
      rarity: BadgeRarity.common,
      category: BadgeCategory.lesson,
    ),
    LessonBadge(
      id: 'loop_master',
      name: 'Dongu Ustasi',
      description: 'Donguleri fethettin!',
      emoji: '🔄',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'condition_wizard',
      name: 'Kosul Buyucusu',
      description: 'Eger-ise sihirini ogrendin!',
      emoji: '🧙',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'coordinate_explorer',
      name: 'Koordinat Kaptani',
      description: 'X ve Y artik dostun!',
      emoji: '🧭',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'game_developer',
      name: 'Oyun Gelistirici',
      description: 'Ilk oyununu tamamladin!',
      emoji: '🎮',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.course,
    ),
    LessonBadge(
      id: 'variable_master',
      name: 'Degisken Ustasi',
      description: 'Degiskenleri ogrendin!',
      emoji: '📦',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'score_keeper',
      name: 'Puan Koruyucusu',
      description: 'Puan sistemini kurdun!',
      emoji: '⭐',
      rarity: BadgeRarity.uncommon,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'clone_master',
      name: 'Klon Ustasi',
      description: 'Klonlarla harikalar yaratin!',
      emoji: '👥',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'broadcaster',
      name: 'Yayinci',
      description: 'Mesajlarla iletisim kurdun!',
      emoji: '📡',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
    LessonBadge(
      id: 'sound_master',
      name: 'Ses Ustasi',
      description: 'Oyunlarina ses ekledin!',
      emoji: '🎵',
      rarity: BadgeRarity.rare,
      category: BadgeCategory.skill,
    ),
  ];
}
