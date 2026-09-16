import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/learner_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme.dart';
import '../../utils/nickname_generator.dart';
import 'auth_wrapper.dart';
import 'intro_art.dart';
import 'intro_carousel.dart';
import '../../utils/lang.dart';
import '../../services/placement_service.dart';
import '../../widgets/first_task.dart';
import '../../widgets/mascot.dart';
import '../../widgets/mascot_mood.dart';
import '../../widgets/mascot_species.dart';
import '../character_screen.dart' show MascotPicker;

/// Uygulamanın ilk açılışındaki kurulum akışı.
///
/// Burası bilerek bir ürün turu DEĞİL. Önceki sürümde dört sayfa boyunca
/// "şunu yapıyoruz, bunu yapıyoruz" deniyor, çocuğa tek bir şey sorulmuyordu;
/// sonunda 7 yaşındaki yeni başlayanla 12 yaşındaki Python bilen aynı ekrana
/// düşüyordu. Artık üç şey soruyoruz — yaş aralığı, deneyim, hedef — ve
/// cevaplar gerçekten kurs sırasını belirliyor (bkz. LearningPathService).
///
/// Bilerek sormadıklarımız: doğum tarihi, cinsiyet, "seni ne zorluyor" tarzı
/// duygusal sorular. Uygulama 4+ yaş derecelendirmeli bir çocuk uygulaması;
/// gereksiz kişisel veri toplamak da çocuğa acı noktası pazarlaması yapmak da
/// bizim işimiz değil.
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late final TextEditingController _nameController =
      TextEditingController(
          text: NicknameGenerator.generate(
              AppLang.resolve(
                  PlatformDispatcher.instance.locale.languageCode)));

  /// Maskota verilen ad. Baslangicta bos: cocuk ad vermezse karakterin
  /// kendi adi (Puf, Mia, ...) kullaniliyor.
  final TextEditingController _mascotNameController = TextEditingController();

  bool _busy = false;

  /// Hazirlama aninin baslangici; en az 1,1 saniye gorunsun diye.
  DateTime _basladi = DateTime.now();

  /// Karşılama ekranı geçildi mi?
  ///
  /// Karşılama sayfası bilerek PageView'in DIŞINDA tutuluyor. Önce içerideydi
  /// ve ilerleyince üst/alt çubuklar belirdiği için PageView'in görünüm alanı
  /// değişiyordu; bu da sayfa geçişini bozup karşılama ekranını ikinci kez,
  /// bu sefer küçülmüş hâlde gösteriyordu. Ayrı ekran olunca yerleşim hiç
  /// değişmiyor ve karşılama bir daha görünmüyor.

  /// Arayuz dili. `watch` kullaniyoruz: acilis ekranindaki TR/EN dugmesine
  /// basildiginda tum akis aninda o dile geciyor.
  ///
  /// ONCEDEN bu ekranin tamami Turkce sabitti. Uygulama App Store'da
  /// Ingilizce konusan bir kullaniciya da aciliyor ve o kullanici ilk
  /// karsilastigi ekrandan itibaren hicbir seyi anlamiyordu.
  ///
  /// DIKKAT: bu bir getter DEGIL, build sirasinda tazelenen bir alan.
  /// Onceden `context.watch<SettingsProvider>()` doner bir getter'di ve
  /// build disindan — dugmelerin onPressed'inden, _finish() icindeki
  /// async akistan — cagrilinca provider assertion atiyordu:
  /// "Tried to listen to a value exposed with provider, from outside of
  /// the widget tree." Sonuc sessiz bir cokme oluyordu: "Baska bir tane
  /// oner" dugmesi hicbir sey yapmiyor, _finish() ise try/catch'e
  /// dusup takma adi, ogrenci profilini ve onboarding isaretini hic
  /// kaydetmiyordu. Simdi build icinde bir kez okunuyor.
  String _lang = AppLang.tr;

  /// Metin secici.
  ///
  /// [de] ve [es] verilmemisse Ingilizcesi gosteriliyor. Boylece bir
  /// cumlenin Almancasi henuz yazilmamis olsa bile ekran dogru
  /// calisiyor ve ceviri sonradan tek bir arguman eklenerek
  /// tamamlanabiliyor — 500'den fazla cagri yerini bir anda cevirmek
  /// zorunda kalmadan.
  String _t(String tr, String en, [String? de, String? es]) =>
      AppLang.pick(_lang, tr: tr, en: en, de: de, es: es);

  LearnerAgeBand? _ageBand;
  SkillLevel? _skillLevel;
  LearningGoal? _goal;

  /// Yerlestirme gorevlerinin sonuclari.
  ///
  /// Cocuga "daha once kod yazdin mi" diye SORMAK yerine olcuyoruz.
  /// 9 yasindaki bir cocuk "kod yazmak" ile "Scratch'te blok
  /// suruklemek" arasindaki farki bilmiyor ve kendi seviyesini
  /// oldugundan yuksek ya da dusuk soyluyor; cevap yanlissa yol da
  /// yanlis kuruluyor. bkz. PlacementService.
  final List<PlacementAttempt> _placement = [];

  /// Ilk gorev tamamlandi mi? Tamamlanana kadar ileri tusu pasif —
  /// ama gorev de tek hareketlik.
  bool _firstTaskDone = false;

  LearnerProfile get _profile => LearnerProfile(
        ageBand: _ageBand,
        // Seviye artik SORULMUYOR, OLCULUYOR. Yas bir tavan koyuyor:
        // 7 yasindaki bir cocuk gorevlerin hepsini yapsa bile Python'a
        // atilmiyor (bkz. PlacementService.ceilingFor).
        skillLevel: _skillLevel ??
            PlacementService.levelFrom(_placement, ageBand: _ageBand),
        goal: _goal,
      );

  @override
  void dispose() {
    _nameController.dispose();
    _mascotNameController.dispose();
    super.dispose();
  }

  /// Soru sayfalarinin ust panelinde duran maskot.
  ///
  /// NEDEN IKON DEGIL MASKOT
  /// -----------------------
  /// Onceden her soru sayfasinin ustunde bir simge vardi (pasta, el
  /// sallama, bayrak) ve soruyu UYGULAMA soruyordu. Maskot orada
  /// durunca soruyu o soruyor: cocuk icin form doldurmak ile birinin
  /// merak edip sormasi ayni sey degil. Karakter zaten uygulamanin her
  /// yerinde; kurulumda da olmasi, tanisma anini oraya tasiyor.
  Widget _mascotArt(MascotMood mood) => Center(
        child: Mascot(mood: mood, size: 128),
      );

  /// Maskotun o anki adi (cocuk ad verdiyse o, vermediyse karakterin adi).
  String get _mascotName {
    final yazilan = _mascotNameController.text.trim();
    if (yazilan.isNotEmpty) return yazilan;
    return specOf(context.read<SettingsProvider>().mascot).name;
  }

  final GlobalKey<IntroCarouselState> _carouselKey =
      GlobalKey<IntroCarouselState>();

  /// Bir secenek secilince otomatik ilerlet: cocuk icin iki dokunus
  /// yerine bir.
  ///
  /// ONCEDEN buradan `_next()` cagriliyordu ve o da bir `PageController`
  /// kullaniyordu. Sayfa yapisi karusele tasindiginda o denetleyici
  /// artik hicbir seye bagli degildi: secenege dokunmak SESSIZCE hicbir
  /// sey yapmiyor, cocuk ileri tusuna basmak zorunda kaliyordu. Kod
  /// derleniyor, analiz temiz — sadece davranis kaybolmustu.
  void _select(VoidCallback apply) {
    setState(apply);
    HapticFeedback.selectionClick();
    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted) _carouselKey.currentState?.advance();
    });
  }

  Future<void> _finish() async {
    if (_busy) return;
    _basladi = DateTime.now();
    setState(() => _busy = true);

    final authProvider = context.read<AuthProvider>();
    final settings = context.read<SettingsProvider>();

    final name = _nameController.text.trim();
    try {
      // Maskotun adi cihazda tutuluyor (sunucuya gitmesi gereken bir
      // bilgi degil). Bos birakilmissa karakterin kendi adi kaliyor.
      await settings.setMascotName(_mascotNameController.text);
      // Oturumun hazir olmasini bekliyoruz. Splash 2.5 saniyede tanitimi
      // aciyor ama oturum (ozellikle kayitli kullanicida refresh_token ile)
      // daha gec hazir olabiliyor; beklemezsek cevaplar hicbir yere
      // yazilmiyordu. Sure dolarsa da kaybetmiyoruz: AuthProvider cevaplari
      // cihazda bekletip oturum acilinca yaziyor.
      await authProvider.waitForSession();

      if (name.isNotEmpty &&
          NicknameGenerator.validate(name, _lang) == null) {
        await authProvider.updateDisplayName(name);
      }
      await authProvider.saveLearnerProfile(_profile);
      await settings.markOnboardingAsSeen();
    } catch (e) {
      // Kayıt başarısız olsa bile kullanıcıyı kapıda tutmuyoruz.
      debugPrint('Onboarding kaydı tamamlanamadı: $e');
    }

    // "SENIN ICIN HAZIRLIYORUM" ANI.
    //
    // Yukaridaki is (oturum bekleme, profil kaydi, yolun kurulmasi)
    // genelde bir saniyeden kisa suruyor ve ekranda hicbir sey
    // olmuyordu: cocuk son tusa basiyor, bir an takiliyor, sonra
    // birden ana sayfa aciliyordu. Kisa bir hazirlama ani hem o bosluga
    // bir anlam veriyor hem de kisisellestirmeyi gercek hissettiriyor.
    // Is zaten bittigi icin bu SAHTE bir bekleme degil; yalnizca
    // sonucun gorunmesini birkac yuz milisaniye geciktiriyor.
    if (!mounted) return;
    final kalan = const Duration(milliseconds: 1100) -
        DateTime.now().difference(_basladi);
    if (kalan > Duration.zero) await Future.delayed(kalan);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthWrapper(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dili burada, build icinde dinliyoruz; olay isleyicileri alani okuyor.
    _lang = context.watch<SettingsProvider>().locale.languageCode;

    // TEK BIR AKIS.
    //
    // Onceden tanitim ile sorular iki ayri ekrandi ve sorulara gecince
    // her sey degisiyordu: renkli panel kayboluyor, zemin beyazlasiyor,
    // tipografi ve ilerleme gostergesi baskalasiyordu. Kullanici
    // acisindan bu, ortasinda baska bir uygulamaya gecen bir akis.
    //
    // Simdi hepsi ayni kabukta ve BIR BILGI, BIR SORU diye ilerliyor:
    // once ne yapacagini gosteriyoruz, hemen ardindan onunla ilgili tek
    // bir sey soruyoruz. Her bilgi-soru cifti kendi rengini paylasiyor,
    // renkler de yesilden maviye dogru ilerliyor.
    // Son tustan sonra kisa bir hazirlama ani; bkz. _finish().
    if (_busy) return _hazirlamaEkrani();

    return IntroCarousel(
      key: _carouselKey,
      slides: _steps(),
      trailing: _buildLanguageToggle(),
      onFinish: _finish,
    );
  }

  /// Kurulum bitince gorunen kisa hazirlama ekrani.
  ///
  /// Maskot cocuga adiyla sesleniyor: bu ekranin isi bir yukleme
  /// gostergesi olmak degil, az once verilen cevaplarin bir ise
  /// yaradigini soylemek.
  Widget _hazirlamaEkrani() {
    final ad = _nameController.text.trim();
    final renk = specOf(context.watch<SettingsProvider>().mascot).defaultColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Mascot(mood: MascotMood.cheering, size: 140),
                const SizedBox(height: 26),
                Text(
                  ad.isEmpty
                      ? _t('Sana özel bir yol hazırlıyorum...',
                          'Building a path just for you...',
                          'Ich baue dir einen eigenen Weg...',
                          'Estoy creando un camino para ti...')
                      : _t('$ad, sana özel bir yol hazırlıyorum...',
                          '$ad, building a path just for you...',
                          '$ad, ich baue dir einen eigenen Weg...',
                          '$ad, estoy creando un camino para ti...'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkGray,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: renk.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(renk),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tanitim sayfalari.
  ///
  /// Uc sayfa, cunku dorduncude birakma orani belirgin sekilde artiyor
  /// ve zaten hemen ardindan dort soru daha var. Her sayfanin kendi
  /// rengi var: ilerleme, sayilardan once renkten anlasiliyor.
  /// Akisin tamami: bilgi, soru, bilgi, soru ...
  ///
  /// Renkler yesilden maviye ilerliyor ve her bilgi kendi sorusuyla
  /// ayni rengi paylasiyor — cocuk hangi bilginin hangi soruya ait
  /// oldugunu okumadan once renkten anliyor.
  List<IntroSlide> _steps() {
    // Renk sirasi: yesil -> turuncu -> turkuaz -> indigo.
    //
    // Her bilgi sayfasi kendi sorusuyla ayni rengi paylasiyor. Onceden
    // sira yesil-yesil-turkuaz-turkuaz-mavi-mavi-indigo-indigo idi;
    // turkuaz ile mavi ve mavi ile indigo yan yana gelince adimlar
    // birbirinden ayirt edilemiyordu. Turuncu araya girince her cift
    // gercekten farkli bir renk oluyor — ve rozet sayfasi (oyunlar,
    // odul) sicak renge gecmis oluyor.
    const green = Color(0xFF2E9E5B);
    const orange = Color(0xFFF57C00);
    const teal = Color(0xFF00ACC1);
    const indigo = Color(0xFF3949AB);

    return [
      // 0 — TANISMA. Once kim oldugunu secsin.
      //
      // Akis eskiden dogrudan bir gorevle basliyordu. Karakter secimi
      // one alindi cunku sonraki her ekranda o karakter konusuyor:
      // once kiminle yola cikacagini secmeden, konusan bir maskot
      // "uygulamanin maskotu" olarak kaliyor, "senin arkadasin"
      // olmuyor. Bes karakter zaten var; kurulumda secilmemesi icin
      // bir sebep yoktu.
      IntroSlide(
        eyebrow: _t('TANIŞALIM', 'SAY HELLO', 'HALLO SAGEN', 'DI HOLA'),
        title: _t('Sana kim\neşlik etsin?', 'Who should\ncome along?',
            'Wer soll dich\nbegleiten?', '¿Quién te\nacompaña?'),
        subtitle: _t(
          'Sonradan da değiştirebilirsin.',
          'You can change this later.',
          'Du kannst das später ändern.',
          'Puedes cambiarlo más tarde.',
        ),
        accent: green,
        art: _mascotArt(MascotMood.happy),
        body: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: MascotPicker(),
        ),
      ),

      // 1 — Maskota ad ver.
      //
      // Adini kendi koydugu bir karakter, kendisine verilen bir
      // karakterden baska bir sey. "Rastgele" dugmesi bilerek var:
      // alti yasindaki bir cocuga klavyeyi mecbur kilmak, akisin en
      // kolay birakildigi yeri yaratmak demek.
      IntroSlide(
        eyebrow: _t('ONA BİR AD', 'NAME YOUR BUDDY', 'GIB IHM EINEN NAMEN',
            'PONLE NOMBRE'),
        title: _t('Ona ne ad\nkoyalım?', 'What shall we\ncall them?',
            'Wie sollen wir\nihn nennen?', '¿Cómo lo\nllamamos?'),
        subtitle: _t(
          'Beni uyandırdığın için sağ ol! Artık buradayım.',
          'Thanks for waking me up! I am here now.',
          'Danke, dass du mich geweckt hast! Jetzt bin ich da.',
          '¡Gracias por despertarme! Ya estoy aquí.',
        ),
        accent: green,
        art: _mascotArt(MascotMood.idle),
        body: _mascotNamePageBody(),
      ),

      // 2 — GOREV. Soru degil, is.
      //
      // Onceden akis sekiz sayfa soruyla basliyordu; cocuk uygulamanin
      // ne oldugunu gormeden dort soru cevapliyordu. Simdi ilk ekranda
      // tek bir hareket var: iki blogu birlestir. Bes saniye, gorunur
      // bir sonuc. Duolingo kayit ekranini akisin birkac adim gerisine
      // aldiginda gunluk aktif kullanici %20 artmisti — insan once
      // urunu gormek istiyor.
      IntroSlide(
        eyebrow: _t('BAŞLAYALIM', 'LET\'S GO', 'LOS GEHT\'S', 'EMPECEMOS'),
        title: _t('Hadi bir şey\nyapalım', 'Let us make\nsomething',
            'Machen wir\netwas', 'Vamos a hacer\nalgo'),
        accent: green,
        art: _mascotArt(MascotMood.curious),
        body: FirstTask(
          accent: green,
          lang: _lang,
          onSolved: (tries) {
            // Ilk gorev ayni zamanda ilk YERLESTIRME olcumu.
            _placement.add(PlacementAttempt(
              taskId: 'snap_blocks',
              solved: true,
              tries: tries,
            ));
            setState(() => _firstTaskDone = true);
            HapticFeedback.mediumImpact();
            Future.delayed(const Duration(milliseconds: 260), () {
              if (mounted) _carouselKey.currentState?.advance();
            });
          },
        ),
        canAdvance: () => _firstTaskDone,
      ),

      // 1 — Bilgi: ne ogrenecek
      IntroSlide(
        eyebrow: _t(
            'ADIM ADIM', 'STEP BY STEP', 'SCHRITT FÜR SCHRITT', 'PASO A PASO'),
        title: _t(
          'Kod yazmayı\nsıfırdan öğren',
          'Learn to code\nfrom zero',
          'Programmieren\nvon Grund auf',
          'Aprende a programar\ndesde cero',
        ),
        subtitle: _t(
          'Scratch bloklarından Python\'a, sana göre bir sırayla.',
          'From Scratch blocks to Python, in an order built for you.',
          'Von Scratch-Blöcken bis Python — in deiner Reihenfolge.',
          'De los bloques de Scratch a Python, en tu propio orden.',
        ),
        accent: green,
        art: IntroArt.lesson(green),
      ),

      // 2 — Soru: isim
      //
      // Maskot KENDI adiyla soruyor: bir onceki adimda konulan ad
      // burada karsiligini buluyor. Yoksa ad verme adimi "bir alan
      // daha doldur"dan ibaret kalirdi.
      IntroSlide(
        eyebrow: _t('TANIŞALIM', 'HELLO', 'HALLO', 'HOLA'),
        title: _t('Sana nasıl\nseslenelim?', 'What should we\ncall you?',
            'Wie sollen wir\ndich nennen?', '¿Cómo te\nllamamos?'),
        subtitle: _t(
          'Ben $_mascotName. Gerçek adın olmak zorunda değil.',
          'I am $_mascotName. It does not have to be your real name.',
          'Ich bin $_mascotName. Es muss nicht dein echter Name sein.',
          'Soy $_mascotName. No tiene que ser tu nombre real.',
        ),
        accent: green,
        art: _mascotArt(MascotMood.happy),
        body: _namePageBody(),
      ),

      // 3 — Bilgi: oyunlar
      IntroSlide(
        eyebrow: _t('OYNA VE KAZAN', 'PLAY AND EARN', 'SPIELEN UND SAMMELN',
            'JUEGA Y GANA'),
        title: _t(
          'Oyunlarla dene,\nrozetleri topla',
          'Practise in games,\ncollect the badges',
          'Übe in Spielen,\nsammle Abzeichen',
          'Practica jugando,\nconsigue insignias',
        ),
        subtitle: _t(
          'Öğrendiğini 16 mini oyunda dene, rozetleri kap.',
          'Practise across 16 mini games and collect the badges.',
          'Übe in 16 Minispielen und sammle die Abzeichen.',
          'Practica en 16 minijuegos y consigue las insignias.',
        ),
        accent: orange,
        art: IntroArt.badge(orange),
      ),

      // 4 — Soru: yas
      IntroSlide(
        eyebrow: _t('SENİ TANIYALIM', 'ABOUT YOU', 'ÜBER DICH', 'SOBRE TI'),
        title: _t('Kaç yaşındasın?', 'How old are you?', 'Wie alt bist du?',
            '¿Cuántos años\ntienes?'),
        subtitle: _t(
          'Derslerin dilini ve zorluğunu buna göre ayarlıyoruz.',
          'We tune the wording and difficulty to your age.',
          'Wir passen Sprache und Schwierigkeit daran an.',
          'Ajustamos el lenguaje y la dificultad a tu edad.',
        ),
        accent: orange,
        art: _mascotArt(MascotMood.curious),
        body: Column(
          children: LearnerAgeBand.values
              .map((band) => _OptionCard(
                    title: band.labelFor(_lang),
                    selected: _ageBand == band,
                    accent: orange,
                    onTap: () => _select(() => _ageBand = band),
                  ))
              .toList(),
        ),
        // ATLANABILIR — bilerek.
        //
        // Apple'in 5.1.4(a) maddesi cocuk uygulamalari icin acik: yas
        // yalnizca mevzuata uymak icin sorulabilir ve uygulama
        // "kisinin yasindan bagimsiz olarak" ise yarar bir islev
        // sunmalidir. Yasi zorunlu tutmak, tum uygulamayi bir soruya
        // kilitlemek demek olurdu. Cevaplanmazsa yol makul bir
        // varsayilanla kuruluyor ve cocuk ilerledikce zaten gercek
        // performans devreye giriyor.
      ),

      // 5 — Bilgi: siralama
      IntroSlide(
        eyebrow: _t('SIRALAMA', 'RANKING', 'RANGLISTE', 'CLASIFICACIÓN'),
        title: _t(
          'Arkadaşlarınla\nyarış',
          'Race against\nyour friends',
          'Miss dich mit\ndeinen Freunden',
          'Compite con\ntus amigos',
        ),
        subtitle: _t(
          'Puanını yükselt, kurs bitince sertifikanı al.',
          'Raise your score and earn a certificate for each course.',
          'Sammle Punkte und hol dir für jeden Kurs ein Zertifikat.',
          'Sube tu puntuación y consigue un certificado por cada curso.',
        ),
        accent: teal,
        art: IntroArt.leaderboard(teal),
      ),

      // 6 — Soru KALDIRILDI.
      //
      // Burada "Daha once kod yazdin mi?" diye soruluyordu ve cocuk uc
      // secenekten birini seciyordu. Iki sorunu vardi: 9 yasindaki bir
      // cocuk "kod yazmak" ile "Scratch'te blok suruklemek" arasindaki
      // farki bilmiyor, ve kendi seviyesini oldugundan yuksek ya da
      // dusuk soyluyor. Cevap yanlissa yol da yanlis kuruluyordu.
      //
      // Yerine olcum geldi: ilk gorev (blok birlestirme) ve dersin
      // kendi ilk adimlari sessizce puanlaniyor, yas da bir tavan
      // koyuyor. bkz. PlacementService. Cocuk bir sinav verdigini
      // bilmiyor cunku bir sinav vermiyor.

      // 7 — Bilgi: sertifika
      IntroSlide(
        eyebrow: _t('BİTİRİNCE', 'WHEN YOU FINISH', 'WENN DU FERTIG BIST',
            'AL TERMINAR'),
        title: _t('Sertifikanı\nal', 'Take your\ncertificate',
            'Hol dir dein\nZertifikat', 'Consigue tu\ncertificado'),
        subtitle: _t(
          'Bir kursun tüm derslerini bitirince adına sertifika açılıyor.',
          'Finish every lesson in a course and a certificate opens in '
              'your name.',
          'Wenn du alle Lektionen eines Kurses schaffst, gibt es ein '
              'Zertifikat auf deinen Namen.',
          'Al terminar todas las lecciones de un curso se abre un '
              'certificado a tu nombre.',
        ),
        accent: indigo,
        art: IntroArt.certificate(indigo),
      ),

      // 8 — Soru: hedef
      IntroSlide(
        eyebrow: _t('HEDEFİN', 'YOUR GOAL', 'DEIN ZIEL', 'TU META'),
        title: _t('Ne yapmak\nistiyorsun?', 'What do you\nwant to make?',
            'Was möchtest\ndu bauen?', '¿Qué quieres\ncrear?'),
        subtitle: _t(
          'Hedefine giden dersler yolun başına geçecek.',
          'Lessons that lead to your goal move to the front.',
          'Lektionen zu deinem Ziel rücken nach vorn.',
          'Las lecciones que llevan a tu meta pasan al principio.',
        ),
        accent: indigo,
        art: _mascotArt(MascotMood.cheering),
        body: Column(
          children: LearningGoal.values
              .map((goal) => _OptionCard(
                    title: goal.labelFor(_lang),
                    leading: goal.emoji,
                    selected: _goal == goal,
                    accent: indigo,
                    onTap: () => _select(() => _goal = goal),
                  ))
              .toList(),
        ),
        canAdvance: () => _goal != null,
      ),
    ];
  }

  /// Maskota ad verme govdesi.
  ///
  /// Cocugun kendi takma adiyla AYNI gorunuyor ama ayri bir denetleyici
  /// kullaniyor; ikisi ayni olsaydi maskota yazilan ad cocugun adini
  /// eziyordu.
  Widget _mascotNamePageBody() {
    final tur = context.watch<SettingsProvider>().mascot;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _mascotNameController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          textAlign: TextAlign.center,
          maxLength: 16,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkGray,
          ),
          decoration: InputDecoration(
            // Ipucu olarak karakterin kendi adi duruyor: cocuk hicbir sey
            // yazmazsa da gecerli bir ad var, bos kalan bir alan yok.
            hintText: specOf(tur).name,
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() {
            _mascotNameController.text = NicknameGenerator.generate(_lang);
          }),
          icon: const Icon(Icons.casino_rounded, size: 18),
          label: Text(_t('Rastgele bir ad', 'A random name',
              'Ein zufälliger Name', 'Un nombre al azar')),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2E9E5B),
            textStyle: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// Isim sorusunun govdesi.
  Widget _namePageBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          textAlign: TextAlign.center,
          maxLength: 20,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkGray,
          ),
          decoration: InputDecoration(
            hintText:
                _t('Takma adın', 'Your nickname', 'Dein Spitzname', 'Tu apodo'),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF4F6F9),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() {
            _nameController.text = NicknameGenerator.generate(_lang);
          }),
          icon: const Icon(Icons.casino_rounded, size: 18),
          label: Text(_t('Başka bir tane öner', 'Suggest another',
              'Noch einen vorschlagen', 'Sugerir otro')),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2E9E5B),
            textStyle: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ header

  // ------------------------------------------------------------------- pages

  /// Dil secici. Tanitim karuselinin sag ustunde duruyor.
  ///
  /// Cihaz dili zaten otomatik seciliyor ama sistem dili Turkce olan bir
  /// cihazda Ingilizce calismak isteyen kullanici da var; ilk ekranda
  /// tek dokunusla degistirebilsin.
  Widget _buildLanguageToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langButton('TR', 'tr'),
          _langButton('EN', 'en'),
        ],
      ),
    );
  }

  Widget _langButton(String label, String code) {
    final selected = _lang == code;
    return GestureDetector(
      onTap: () {
        if (selected) return;
        HapticFeedback.selectionClick();
        // Bolge kodu vermiyoruz: 'de' + 'US' gibi anlamsiz bir eslesme
        // cikiyordu. Ayarlar ekrani da Locale(code) kullaniyor ve
        // main.dart'taki supportedLocales listesi Almanca/Ispanyolcayi
        // bolgesiz tutuyor.
        context.read<SettingsProvider>().setLocale(Locale(code));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: selected
                ? const Color(0xFF1B3A8C)
                : Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ footer
}

/// Onboarding sorularındaki seçenek kartı.
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.selected,
    required this.onTap,
    required this.accent,
    this.leading,
  });

  final String title;
  final String? leading;
  final bool selected;
  final VoidCallback onTap;

  /// Adimin rengi. Secenek kartlari da sayfanin rengini kullaniyor;
  /// sabit mavi kalsalardi soru sayfalari akistan kopardi.
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.09) : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? accent : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  Text(leading!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: selected ? accent : AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: selected ? 1 : 0,
                  child: Icon(Icons.check_circle_rounded, color: accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
