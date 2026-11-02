import 'package:flutter/material.dart';

import 'ceviri.dart';
import 'lang.dart';

/// Simple localization helper for the app
/// Priority: Turkish (tr) is the primary language
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Common translations
  String get appName =>
      _v('app_name') ?? 'DevEducation';
  String get welcome =>
      _v('welcome') ?? 'Hoşgeldiniz';
  String get settings =>
      _v('settings') ?? 'Ayarlar';

  /// Yan menüdeki "Video Dersler" başlığı.
  ///
  /// Bu iki anahtar sonradan eklendi: yan menüde bu iki yazı SABİT
  /// Türkçeydi, yani İngilizce/Almanca/İspanyolca seçen kullanıcı
  /// menüyü açtığında "Video Dersler" ve "Seviye 1" görüyordu.
  String get videoLessons =>
      _v('videoLessons') ??
      'Video Dersler';

  String get level =>
      _v('level') ?? 'Seviye';
  String get profile =>
      _v('profile') ?? 'Profil';
  String get home =>
      _v('home') ?? 'Ana Sayfa';
  String get messages =>
      _v('messages') ?? 'Mesajlar';
  String get socialFeed =>
      _v('social_feed') ?? 'DevSocial';
  String get writeYourMessage =>
      _v('write_your_message') ??
      'Mesajınızı yazın...';

  // Settings screen
  String get languageAndRegion =>
      _v('language_region') ??
      'Dil ve Bölge';
  String get language =>
      _v('language') ?? 'Dil';
  String get notifications =>
      _v('notifications') ?? 'Bildirimler';
  String get enableNotifications =>
      _v('enable_notifications') ??
      'Bildirimleri Aç';
  String get appNotifications =>
      _v('app_notifications') ??
      'Uygulama bildirimlerini al';
  String get sound => _v('sound') ?? 'Ses';
  String get notificationSounds =>
      _v('notification_sounds') ??
      'Bildirim sesleri';
  String get vibration =>
      _v('vibration') ?? 'Titreşim';
  String get notificationVibration =>
      _v('notification_vibration') ??
      'Bildirimde titreşim';
  String get accessibility =>
      _v('accessibility') ??
      'Erişilebilirlik';
  String get textSize =>
      _v('text_size') ?? 'Yazı Boyutu';
  String get highContrast =>
      _v('high_contrast') ??
      'Yüksek Kontrast';
  String get makeColorsBolder =>
      _v('make_colors_bolder') ??
      'Renkleri daha belirgin yap';
  String get privacy =>
      _v('privacy') ?? 'Gizlilik';
  String get dataSharing =>
      _v('data_sharing') ??
      'Veri Paylaşımı';
  String get shareAnonymousData =>
      _v('share_anonymous_data') ??
      'Uygulamayı geliştirmek için anonim veri paylaş';
  String get about =>
      _v('about') ?? 'Hakkında';
  String get aboutApp =>
      _v('about_app') ??
      'Uygulama Hakkında';
  String get version =>
      _v('version') ?? 'Versiyon';
  String get resetSettings =>
      _v('reset_settings') ??
      'Ayarları Sıfırla';
  String get selectLanguage =>
      _v('select_language') ?? 'Dil Seçin';
  String get turkish =>
      _v('turkish') ?? 'Türkçe';
  String get english =>
      _v('english') ?? 'English';
  String get cancel =>
      _v('cancel') ?? 'İptal';
  String get resetConfirmation =>
      _v('reset_confirmation') ??
      'Tüm ayarlar varsayılan değerlere sıfırlanacak. Emin misiniz?';
  String get reset =>
      _v('reset') ?? 'Sıfırla';
  String get settingsResetSuccess =>
      _v('settings_reset_success') ??
      'Ayarlar varsayılan değerlere sıfırlandı';
  String get appDescription =>
      _v('app_description') ??
      'Robotik ve kodlama eğitimi için geliştirilmiş bir platformdur.';
  String get ok => _v('ok') ?? 'Tamam';
  String get appExperience =>
      _v('app_experience') ??
      'Uygulama Deneyimi';
  String get showOnboardingAgain =>
      _v('show_onboarding_again') ??
      'Tanıtımı Tekrar Göster';
  String get onboardingWillShow =>
      _v('onboarding_will_show') ??
      'Uygulama yeniden başlatıldığında tanıtım ekranı gösterilecek';
  String get onboardingReset =>
      _v('onboarding_reset') ??
      'Tanıtım sıfırlandı';
  String get onboardingResetMessage =>
      _v('onboarding_reset_message') ??
      'Uygulama bir sonraki açılışta tanıtım ekranını gösterecektir.';

  // Language change loading
  String get languageChanging =>
      _v('language_changing') ??
      'Dil Değiştiriliyor...';
  String get languageChangedTo =>
      _v('language_changed_to') ??
      'Dil değiştirildi';
  String get languageChangedToTurkish => 'Dil Türkçe olarak değiştirildi';
  String get languageChangedToEnglish =>
      'The language has been changed to English';

  // Student Home
  String get todaysGoals =>
      _v('todays_goals') ??
      'Bugünkü Hedefler';
  String get activities =>
      _v('activities') ?? 'Aktivite';
  String get games =>
      _v('games') ?? 'Oyunlar';
  String get homework =>
      _v('homework') ?? 'Ödevler';
  String get points =>
      _v('points') ?? 'Puan';
  String get achievements =>
      _v('achievements') ?? 'Başarı';
  String get popularActivities =>
      _v('popular_activities') ??
      'Popüler Aktiviteler';
  String get robotMovementGame =>
      _v('robot_movement_game') ??
      'Robot Hareket Oyunu';
  String get educationalGame =>
      _v('educational_game') ??
      'Eğitici oyun';
  String get arduinoSimulator =>
      _v('arduino_simulator') ??
      'Arduino Simülatör';
  String get circuitDesign =>
      _v('circuit_design') ??
      'Devre tasarımı';
  String get myHomework =>
      _v('my_homework') ?? 'Ödevlerim';
  String get currentHomework =>
      _v('current_homework') ??
      'Güncel ödevler';
  String get devAiChat =>
      _v('dev_ai_chat') ?? 'DevAI';

  /// Alt gezinme cubugundaki kurslar sekmesi.
  String get courses =>
      _v('courses') ?? 'Kurslar';
  String get aiAssistant =>
      _v('ai_assistant') ??
      'Yapay zeka asistan';
  String get millionaireGame =>
      _v('millionaire_game') ??
      'Kim Milyoner Olmak İster?';
  String get quizGame =>
      _v('quiz_game') ?? 'Bilgi yarışması';
  String get worksheets =>
      _v('worksheets') ??
      'Çalışma Kağıtları';
  String get aiRoboticsCoding =>
      _v('ai_robotics_coding') ??
      'AI, Robotik, Kodlama';
  String get learningScore =>
      _v('learning_score') ??
      'Öğrenme Skoru';
  String get greatProgress =>
      _v('great_progress') ??
      'Harika gidiyorsun! Hedefine ulaşmak için devam et.';

  // Profile Screen
  String get inactive =>
      _v('inactive') ?? 'Pasif';
  String get active =>
      _v('active') ?? 'Aktif';
  String get visitor =>
      _v('visitor') ?? 'Ziyaretçi';
  String get student =>
      _v('student') ?? 'Öğrenci';
  String get teacher =>
      _v('teacher') ?? 'Öğretmen';
  String get parent =>
      _v('parent') ?? 'Veli';
  String get admin =>
      _v('admin') ?? 'Admin';
  String get login =>
      _v('login') ?? 'Giriş Yap';
  String get logout =>
      _v('logout') ?? 'Çıkış Yap';
  String get register =>
      _v('register') ?? 'Kayıt Ol';
  String get loggingOut =>
      _v('logging_out') ??
      'Çıkış yapılıyor...';
  String get logoutConfirmation =>
      _v('logout_confirmation') ??
      'Çıkış yapmak istediğinizden emin misiniz?';
  String get loginToAccessFeatures =>
      _v('login_to_access_features') ??
      'Tüm özelliklere erişmek için giriş yapın';
  String get howWouldYouLikeToUseDevkom =>
      _v('how_would_you_like_to_use_devkom') ??
      'DevEducation\'ı nasıl kullanmak istiyorsun?';
  String get selectYourPurpose =>
      _v('select_your_purpose') ??
      'Amacınızı seçin';
  String get toLearn =>
      _v('to_learn') ?? 'Öğrenmek için';
  String get toLearnDescription =>
      _v('to_learn_description') ??
      'Kodlama, robotik ve yapay zeka öğrenmek istiyorum';
  String get trackMyChild =>
      _v('track_my_child') ??
      'Çocuğumun gelişimini takip etmek için';
  String get trackMyChildDescription =>
      _v('track_my_child_description') ??
      'Çocuğumun eğitim sürecini takip etmek istiyorum';
  String get fullAccessContinues =>
      _v('full_access_continues') ??
      'Tüm içeriklere erişim devam eder';
  String get canChangeInSettings =>
      _v('can_change_in_settings') ??
      'Daha sonra profil ayarlarından değiştirebilirsiniz';

  // Drawer menu items
  String get schedule =>
      _v('schedule') ?? 'Ders Programı';
  String get attendance =>
      _v('attendance') ?? 'Devamsızlık';
  String get curriculum =>
      _v('curriculum') ?? 'Müfredat';
  String get agenda =>
      _v('agenda') ?? 'Ajanda';
  String get achievementAnalysis =>
      _v('achievement_analysis') ??
      'Kazanım Analizleri';
  String get surveys =>
      _v('surveys') ?? 'Anketler';
  String get logoutError =>
      _v('logout_error') ??
      'Çıkış yapılırken hata oluştu';

  // Onboarding
  String get alreadyHaveAccount =>
      _v('already_have_account') ??
      'Zaten hesabım var';
  String get skip => _v('skip') ?? 'Atla';
  String get createFreeAccount =>
      _v('create_free_account') ??
      'Ücretsiz Hesap Oluştur';
  String get freeSignUp =>
      _v('free_sign_up') ??
      'Ücretsiz Kayıt Ol';
  String get saveProgressMessage =>
      _v('save_progress_message') ??
      'İlerlemenizi kaydedin ve tüm özelliklere erişin';
  String get letsGetStarted =>
      _v('lets_get_started') ??
      'Başlayalım';

  // Profile Screen - Additional
  String get email =>
      _v('email') ?? 'E-posta';
  String get role => _v('role') ?? 'Rol';
  String get liveCameraAccess =>
      _v('live_camera_access') ??
      'Canlı Kamera Erişimi';
  String get accountInfo =>
      _v('account_info') ??
      'Hesap Bilgileri';
  String get accessInfo =>
      _v('access_info') ??
      'Erişim Bilgileri';
  String get fullName =>
      _v('full_name') ?? 'Ad Soyad';
  String get status =>
      _v('status') ?? 'Durum';
  String get memberSince =>
      _v('member_since') ?? 'Üyelik Tarihi';

  // Schedule Screen
  String get weeklySchedule =>
      _v('weekly_schedule') ??
      'Haftalık ders programınız burada görüntülenecek';

  // Attendance Screen
  String get attendanceTracking =>
      _v('attendance_tracking') ??
      'Devamsızlık Takibi';
  String get attendanceInfo =>
      _v('attendance_info') ??
      'Devamsızlık bilgileriniz burada görüntülenecek';

  // Curriculum Screen
  String get curriculumInfo =>
      _v('curriculum_info') ??
      'Ders müfredatı ve konular burada görüntülenecek';

  // Agenda Screen
  String get pleaseLogin =>
      _v('please_login') ??
      'Lütfen giriş yapın';
  String get error => _v('error') ?? 'Hata';
  String get noEventsOnThisDate =>
      _v('no_events_on_this_date') ??
      'Bu tarihte etkinlik yok';
  String get deleteEvent =>
      _v('delete_event') ?? 'Etkinliği Sil';
  String get deleteEventConfirmation =>
      _v('delete_event_confirmation') ??
      'etkinliğini silmek istediğinizden emin misiniz?';
  String get delete =>
      _v('delete') ?? 'Sil';
  String get deleted =>
      _v('deleted') ?? 'silindi';
  String get addEvent =>
      _v('add_event') ?? 'Etkinlik Ekle';
  String get title =>
      _v('title') ?? 'Başlık';
  String get description =>
      _v('description') ?? 'Açıklama';
  String get descriptionOptional =>
      _v('description_optional') ??
      'Açıklama (Opsiyonel)';
  String get type => _v('type') ?? 'Tür';
  String get note => _v('note') ?? 'Not';
  String get reminder =>
      _v('reminder') ?? 'Hatırlatıcı';
  String get task => _v('task') ?? 'Görev';
  String get add => _v('add') ?? 'Ekle';
  String get pleasEnterTitle =>
      _v('please_enter_title') ??
      'Lütfen bir başlık girin';
  String get eventAdded =>
      _v('event_added') ??
      'Etkinlik eklendi!';

  // Day names (short)
  String get monday =>
      _v('monday') ?? 'Pzt';
  String get tuesday =>
      _v('tuesday') ?? 'Sal';
  String get wednesday =>
      _v('wednesday') ?? 'Çar';
  String get thursday =>
      _v('thursday') ?? 'Per';
  String get friday =>
      _v('friday') ?? 'Cum';
  String get saturday =>
      _v('saturday') ?? 'Cmt';
  String get sunday =>
      _v('sunday') ?? 'Paz';

  // Achievement Analysis Screen
  String get noGamesPlayed =>
      _v('no_games_played') ??
      'Henüz Oyun Oynamamışsınız';
  String get playGamesMessage =>
      _v('play_games_message') ??
      'Oyunlar bölümünden oyun oynayarak\nistatistiklerinizi görüntüleyebilirsiniz';
  String get overallSuccess =>
      _v('overall_success') ??
      'Genel Başarı Durumu';
  String get totalGames =>
      _v('total_games') ?? 'Toplam Oyun';
  String get correct =>
      _v('correct') ?? 'Doğru';
  String get wrong =>
      _v('wrong') ?? 'Yanlış';
  String get gameBasedPerformance =>
      _v('game_based_performance') ??
      'Oyun Bazlı Performans';
  String get timesPlayed =>
      _v('times_played') ?? 'kez oynandı';
  String get loadingDataError =>
      _v('loading_data_error') ??
      'Veri yüklenirken hata oluştu';

  // Surveys Screen
  String get surveysInfo =>
      _v('surveys_info') ??
      'Katılabileceğiniz anketler burada görüntülenecek';

  // SwipeWelcomeScreen
  String get swipeToStart =>
      _v('swipe_to_start') ??
      'Başlamak için kaydır';
  String get smartEducationPlatform =>
      _v('smart_education_platform') ??
      'AI • Robotik • Kodlama • Yazılım';

  // WelcomeScreen
  String get softwareRoboticsEducation =>
      _v('software_robotics_education') ??
      'Yazılım ve Robotik\nEğitim Platformu';
  String get explore =>
      _v('explore') ?? 'Keşfet';
  String get continueWithLogin =>
      _v('continue_with_login') ??
      'Giriş Yaparak Devam Et';
  String get robotics =>
      _v('robotics') ?? 'Robotik';
  String get coding =>
      _v('coding') ?? 'Kodlama';
  String get chess =>
      _v('chess') ?? 'Satranç';

  // LoginScreen
  String get password =>
      _v('password') ?? 'Şifre';
  String get emailHint =>
      _v('email_hint') ?? 'ornek@email.com';
  String get pleaseEnterEmail =>
      _v('please_enter_email') ??
      'Lütfen e-posta adresinizi girin';
  String get enterValidEmail =>
      _v('enter_valid_email') ??
      'Geçerli bir e-posta adresi girin';
  String get pleaseEnterPassword =>
      _v('please_enter_password') ??
      'Lütfen şifrenizi girin';
  String get passwordMinLength =>
      _v('password_min_length') ??
      'Şifre en az 6 karakter olmalıdır';
  String get noAccount =>
      _v('no_account') ??
      'Hesabınız yok mu?';

  // RegisterScreen
  String get createNewAccount =>
      _v('create_new_account') ??
      'Yeni Hesap Oluştur';
  String get nameHint =>
      _v('name_hint') ??
      'Adınız ve Soyadınız';
  String get pleaseEnterName =>
      _v('please_enter_name') ??
      'Lütfen adınızı ve soyadınızı girin';
  String get nameMinLength =>
      _v('name_min_length') ??
      'Ad en az 3 karakter olmalıdır';
  String get passwordConfirm =>
      _v('password_confirm') ??
      'Şifre Tekrar';
  String get pleaseConfirmPassword =>
      _v('please_confirm_password') ??
      'Lütfen şifrenizi tekrar girin';
  String get passwordsDoNotMatch =>
      _v('passwords_do_not_match') ??
      'Şifreler eşleşmiyor';
  String get accountType =>
      _v('account_type') ?? 'Hesap Tipi';
  String get parentWithCamera =>
      _v('parent_with_camera') ??
      'Canlı kamera erişimi dahil';
  String get studentAccess =>
      _v('student_access') ??
      'Oyunlar ve ödevlere erişim';
  String get teacherAccess =>
      _v('teacher_access') ??
      'Müfredat ve ödev yönetimi';
  String get visitorAccess =>
      _v('visitor_access') ??
      'Genel içerik erişimi';
  String get registrationSuccess =>
      _v('registration_success') ??
      'Kayıt başarılı! Hoş geldiniz.';
  String get alreadyHaveAccountQuestion =>
      _v('already_have_account_question') ??
      'Zaten hesabınız var mı?';

  // OnboardingScreen
  String get onboarding1Title =>
      _v('onboarding1_title') ??
      'Güvenilir Eğitim Platformu';
  String get onboarding1Description =>
      _v('onboarding1_description') ??
      'DevEducation ile öğrenciler güvenli bir ortamda, uzman eğitmenler eşliğinde robotik ve yazılım öğrenir. Her adımı takip edin, gelişimi izleyin.';
  String get onboarding2Title =>
      _v('onboarding2_title') ??
      'Kapsamlı Müfredat';
  String get onboarding2Description =>
      _v('onboarding2_description') ??
      'MEB onaylı müfredat ile uyumlu, yaş gruplarına özel tasarlanmış eğitim programları. Arduino, Python, Scratch ve daha fazlası profesyonel eğitmenlerle.';
  String get onboarding3Title =>
      _v('onboarding3_title') ??
      'Gelişimi Anlık Takip';
  String get onboarding3Description =>
      _v('onboarding3_description') ??
      'Öğrenci ilerleme raporları, başarı rozetleri ve detaylı analizlerle çocuğunuzun gelişimini her an izleyin. Veli paneli ile tam kontrol.';

  // ProfileScreen
  String get userInfoLoadError =>
      _v('user_info_load_error') ??
      'Kullanıcı bilgileri yüklenemedi';
  String get lastLogin =>
      _v('last_login') ?? 'Son Giriş';
  String get alreadyHaveAccountLogin =>
      _v('already_have_account_login') ??
      'Zaten Hesabım Var';
  String get logoutErrorMessage =>
      _v('logout_error_message') ??
      'Çıkış yapılırken hata oluştu';

  // Social Feed Strings
  String get createPost =>
      _v('create_post') ??
      'Gönderi Oluştur';
  String get addImages =>
      _v('add_images') ?? 'Resim Ekle';
  String get addPDF =>
      _v('add_pdf') ?? 'PDF Ekle';
  String get addLink =>
      _v('add_link') ?? 'Link Ekle';
  String get whatOnYourMind =>
      _v('what_on_your_mind') ??
      'Aklında ne var?';
  String get postsRemaining =>
      _v('posts_remaining') ??
      'gönderi hakkı kaldı';
  String get unlimitedPosts =>
      _v('unlimited_posts') ??
      'Sınırsız gönderi';
  String get dailyLimitReached =>
      _v('daily_limit_reached') ??
      'Günlük gönderi limitine ulaşıldı';
  String get like => _v('like') ?? 'Beğen';
  String get comment =>
      _v('comment') ?? 'Yorum';
  String get share =>
      _v('share') ?? 'Paylaş';
  String get report =>
      _v('report') ?? 'Bildir';
  String get viewingAsGuest =>
      _v('viewing_as_guest') ??
      'Misafir olarak görüntüleniyor';
  String get loginToComment =>
      _v('login_to_comment') ??
      'Yorum yapmak için giriş yapın';
  String get postCreatedSuccessfully =>
      _v('post_created_successfully') ??
      'Gönderi başarıyla oluşturuldu';
  String get postDeleted =>
      _v('post_deleted') ??
      'Gönderi silindi';
  String get confirmDelete =>
      _v('confirm_delete') ??
      'Silmek istediğinizden emin misiniz?';
  String get noPostsYet =>
      _v('no_posts_yet') ??
      'Henüz gönderi yok';
  String get beFirstToPost =>
      _v('be_first_to_post') ??
      'İlk gönderiyi siz paylaşın!';
  String get trending =>
      _v('trending') ?? 'Trendler';
  String get aiAndRobotics =>
      _v('ai_and_robotics') ??
      'AI & Robotik';
  String get funny =>
      _v('funny') ?? 'Eğlenceli';
  String get all => _v('all') ?? 'Tümü';
  String get comments =>
      _v('comments') ?? 'Yorumlar';
  String get noCommentsYet =>
      _v('no_comments_yet') ??
      'Henüz yorum yok';
  String get addComment =>
      _v('add_comment') ?? 'Yorum ekle...';
  String get postDetails =>
      _v('post_details') ??
      'Gönderi Detayları';
  String get postNotFound =>
      _v('post_not_found') ??
      'Gönderi bulunamadı';

  // Enhanced Feed Screen
  String get filterTrending =>
      _v('filter_trending') ?? 'Trendler';
  String get filterAiRobotics =>
      _v('filter_ai_robotics') ??
      'AI & Robotik';
  String get filterCoding =>
      _v('filter_coding') ?? 'Kodlama';
  String get filterFunny =>
      _v('filter_funny') ?? 'Eğlenceli';
  String get filterAll =>
      _v('filter_all') ?? 'Tümü';
  String get viewingAsGuestLogin =>
      _v('viewing_as_guest_login') ??
      'Misafir olarak görüntüleniyor - Etkileşim için giriş yapın';
  String get errorLoadingPosts =>
      _v('error_loading_posts') ??
      'Gönderiler yüklenirken hata oluştu';
  String get beFirstToShareAmazing =>
      _v('be_first_to_share_amazing') ??
      'İlk harika paylaşımı siz yapın!';
  String get loginToCommentLock =>
      _v('login_to_comment_lock') ??
      '🔒 Yorum yapmak için giriş yapın';
  String get shareFunctionalityComingSoon =>
      _v('share_functionality_coming_soon') ??
      'Paylaşım özelliği yakında geliyor!';
  String get deletePost =>
      _v('delete_post') ?? 'Gönderiyi Sil';
  String get deletePostConfirmation =>
      _v('delete_post_confirmation') ??
      'Bu gönderiyi silmek istediğinizden emin misiniz?';
  String get postDeletedSuccessfully =>
      _v('post_deleted_successfully') ??
      'Gönderi başarıyla silindi';
  String get errorDeletingPost =>
      _v('error_deleting_post') ??
      'Gönderi silinirken hata oluştu';
  String get pdfDocument =>
      _v('pdf_document') ?? 'PDF Belgesi';
  String get tapToView =>
      _v('tap_to_view') ??
      'Görüntülemek için dokun';
  String get likes =>
      _v('likes') ?? 'beğeni';

  // Create Post Screen
  String get dailyLimitReachedUpgrade =>
      _v('daily_limit_reached_upgrade') ??
      'Günlük gönderi limitine ulaşıldı. Sınırsız gönderi için Pro sürüme geçin!';
  String get failedToCreatePost =>
      _v('failed_to_create_post') ??
      'Gönderi oluşturulamadı';
  String get postsRemainingToday =>
      _v('posts_remaining_today') ??
      'bugün gönderi hakkı kaldı';
  String get dailyLimitReachedUpgradePro =>
      _v('daily_limit_reached_upgrade_pro') ??
      'Günlük limit doldu! Sınırsız gönderi için Pro\'ya geçin';
  String get proUnlimitedPosts =>
      _v('pro_unlimited_posts') ??
      'PRO: Sınırsız gönderi';
  String get whatOnYourMindRocket =>
      _v('what_on_your_mind_rocket') ??
      'Aklında ne var? 🚀';
  String get addLinkOptional =>
      _v('add_link_optional') ??
      '🔗 Link ekle (opsiyonel)';
  String get selectedImages =>
      _v('selected_images') ??
      '📸 Seçilen Resimler';
  String get pdfAttached =>
      _v('pdf_attached') ?? 'PDF Eklendi';
  String get images =>
      _v('images') ?? 'Resimler';
  String get pdf => _v('pdf') ?? 'PDF';
  String get post => _v('post') ?? 'Paylaş';

  // Post Detail Screen
  String get pleaseLoginToComment =>
      _v('please_login_to_comment') ??
      'Yorum yapmak için lütfen giriş yapın';
  String get errorPostingComment =>
      _v('error_posting_comment') ??
      'Yorum gönderilirken hata oluştu';
  String get beFirstToComment =>
      _v('be_first_to_comment') ??
      'İlk yorumu siz yapın!';
  String get addCommentEllipsis =>
      _v('add_comment_ellipsis') ??
      'Yorum ekle...';
  String get loginToCommentLockDetail =>
      _v('login_to_comment_lock_detail') ??
      '🔒 Yorum yapmak için giriş yapın';

  /// Testlerin ceviri tablosuna erisebilmesi icin.
  ///
  /// Bir dilde eksik kalan anahtar, uygulamada Turkce varsayilana
  /// duserek Alman kullaniciya Turkce bir cumle gosterir — hicbir sey
  /// kirilmadan. Bunu ancak tabloya disaridan bakan bir test yakalar.
  /// Anahtarin bu dildeki karsiligi.
  ///
  /// Elle yazilan dort dilde dogrudan tablo. Diger 47 dilde Ingilizce
  /// deger ceviri tablosundan cevriliyor (bkz. `ceviri.dart`); yoksa
  /// Ingilizce. ONCEDEN bilinmeyen bir dilde her getter'in sonundaki
  /// Turkce varsayilan gorunuyordu.
  String? _v(String anahtar) {
    final dil = locale.languageCode;
    final dogrudan = _localizedValues[dil]?[anahtar];
    if (dogrudan != null) return dogrudan;
    final en = _localizedValues['en']?[anahtar];
    if (en == null) return null;
    return Ceviri.bul(dil, en) ?? en;
  }

  static Map<String, Map<String, String>> get debugValues => _localizedValues;

  static const Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      'app_name': 'DevEducation',
      'welcome': 'Hoşgeldiniz',
      'settings': 'Ayarlar',
      'videoLessons': 'Video Dersler',
      'level': 'Seviye',
      'profile': 'Profil',
      'home': 'Ana Sayfa',
      'messages': 'Mesajlar',
      'social_feed': 'DevSocial',
      'write_your_message': 'Mesajınızı yazın...',
      'language_region': 'Dil ve Bölge',
      'language': 'Dil',
      'notifications': 'Bildirimler',
      'enable_notifications': 'Bildirimleri Aç',
      'app_notifications': 'Uygulama bildirimlerini al',
      'sound': 'Ses',
      'notification_sounds': 'Bildirim sesleri',
      'vibration': 'Titreşim',
      'notification_vibration': 'Bildirimde titreşim',
      'accessibility': 'Erişilebilirlik',
      'text_size': 'Yazı Boyutu',
      'high_contrast': 'Yüksek Kontrast',
      'make_colors_bolder': 'Renkleri daha belirgin yap',
      'privacy': 'Gizlilik',
      'data_sharing': 'Veri Paylaşımı',
      'share_anonymous_data': 'Uygulamayı geliştirmek için anonim veri paylaş',
      'about': 'Hakkında',
      'about_app': 'Uygulama Hakkında',
      'version': 'Versiyon',
      'reset_settings': 'Ayarları Sıfırla',
      'select_language': 'Dil Seçin',
      'turkish': 'Türkçe',
      'english': 'English',
      'cancel': 'İptal',
      'reset_confirmation':
          'Tüm ayarlar varsayılan değerlere sıfırlanacak. Emin misiniz?',
      'reset': 'Sıfırla',
      'settings_reset_success': 'Ayarlar varsayılan değerlere sıfırlandı',
      'app_description':
          'Robotik ve kodlama eğitimi için geliştirilmiş bir platformdur.',
      'ok': 'Tamam',
      'app_experience': 'Uygulama Deneyimi',
      'show_onboarding_again': 'Tanıtımı Tekrar Göster',
      'onboarding_will_show':
          'Uygulama yeniden başlatıldığında tanıtım ekranı gösterilecek',
      'onboarding_reset': 'Tanıtım Sıfırlandı',
      'onboarding_reset_message':
          'Uygulama bir sonraki açılışta tanıtım ekranını gösterecektir.',
      'language_changing': 'Dil Değiştiriliyor...',
      'language_changed_to': 'Dil değiştirildi',
      'todays_goals': 'Bugünkü Hedefler',
      'activities': 'Aktivite',
      'games': 'Oyunlar',
      'homework': 'Ödevler',
      'points': 'Puan',
      'achievements': 'Başarı',
      'popular_activities': 'Popüler Aktiviteler',
      'robot_movement_game': 'Robot Hareket Oyunu',
      'educational_game': 'Eğitici oyun',
      'arduino_simulator': 'Arduino Simülatör',
      'circuit_design': 'Devre tasarımı',
      'my_homework': 'Ödevlerim',
      'current_homework': 'Güncel ödevler',
      'dev_ai_chat': 'DevAI',
      'courses': 'Kurslar',
      'ai_assistant': 'Yapay zeka asistan',
      'millionaire_game': 'Kim Milyoner Olmak İster?',
      'quiz_game': 'Bilgi yarışması',
      'worksheets': 'Çalışma Kağıtları',
      'ai_robotics_coding': 'AI, Robotik, Kodlama',
      'learning_score': 'Öğrenme Skoru',
      'great_progress': 'Harika gidiyorsun! Hedefine ulaşmak için devam et.',
      'inactive': 'Pasif',
      'active': 'Aktif',
      'visitor': 'Ziyaretçi',
      'student': 'Öğrenci',
      'teacher': 'Öğretmen',
      'parent': 'Veli',
      'admin': 'Admin',
      'login': 'Giriş Yap',
      'logout': 'Çıkış Yap',
      'register': 'Kayıt Ol',
      'logging_out': 'Çıkış yapılıyor...',
      'login_to_access_features': 'Tüm özelliklere erişmek için giriş yapın',
      'how_would_you_like_to_use_devkom':
          'DevEducation\'ı nasıl kullanmak istiyorsun?',
      'select_your_purpose': 'Amacınızı seçin',
      'to_learn': 'Öğrenmek için',
      'to_learn_description':
          'Kodlama, robotik ve yapay zeka öğrenmek istiyorum',
      'track_my_child': 'Çocuğumun gelişimini takip etmek için',
      'track_my_child_description':
          'Çocuğumun eğitim sürecini takip etmek istiyorum',
      'full_access_continues': 'Tüm içeriklere erişim devam eder',
      'can_change_in_settings':
          'Daha sonra profil ayarlarından değiştirebilirsiniz',
      'logout_confirmation': 'Çıkış yapmak istediğinizden emin misiniz?',
      'schedule': 'Ders Programı',
      'attendance': 'Devamsızlık',
      'curriculum': 'Müfredat',
      'agenda': 'Ajanda',
      'achievement_analysis': 'Kazanım Analizleri',
      'surveys': 'Anketler',
      'logout_error': 'Çıkış yapılırken hata oluştu',
      'already_have_account': 'Zaten hesabım var',
      'skip': 'Atla',
      'create_free_account': 'Ücretsiz Hesap Oluştur',
      'free_sign_up': 'Ücretsiz Kayıt Ol',
      'save_progress_message':
          'İlerlemenizi kaydedin ve tüm özelliklere erişin',
      'lets_get_started': 'Başlayalım',
      'email': 'E-posta',
      'role': 'Rol',
      'live_camera_access': 'Canlı Kamera Erişimi',
      'account_info': 'Hesap Bilgileri',
      'access_info': 'Erişim Bilgileri',
      'full_name': 'Ad Soyad',
      'status': 'Durum',
      'member_since': 'Üyelik Tarihi',
      'weekly_schedule': 'Haftalık ders programınız burada görüntülenecek',
      'attendance_tracking': 'Devamsızlık Takibi',
      'attendance_info': 'Devamsızlık bilgileriniz burada görüntülenecek',
      'curriculum_info': 'Ders müfredatı ve konular burada görüntülenecek',
      'please_login': 'Lütfen giriş yapın',
      'error': 'Hata',
      'no_events_on_this_date': 'Bu tarihte etkinlik yok',
      'delete_event': 'Etkinliği Sil',
      'delete_event_confirmation':
          'etkinliğini silmek istediğinizden emin misiniz?',
      'delete': 'Sil',
      'deleted': 'silindi',
      'add_event': 'Etkinlik Ekle',
      'title': 'Başlık',
      'description': 'Açıklama',
      'description_optional': 'Açıklama (Opsiyonel)',
      'type': 'Tür',
      'note': 'Not',
      'reminder': 'Hatırlatıcı',
      'task': 'Görev',
      'add': 'Ekle',
      'please_enter_title': 'Lütfen bir başlık girin',
      'event_added': 'Etkinlik eklendi!',
      'monday': 'Pzt',
      'tuesday': 'Sal',
      'wednesday': 'Çar',
      'thursday': 'Per',
      'friday': 'Cum',
      'saturday': 'Cmt',
      'sunday': 'Paz',
      'no_games_played': 'Henüz Oyun Oynamamışsınız',
      'play_games_message':
          'Oyunlar bölümünden oyun oynayarak\nistatistiklerinizi görüntüleyebilirsiniz',
      'overall_success': 'Genel Başarı Durumu',
      'total_games': 'Toplam Oyun',
      'correct': 'Doğru',
      'wrong': 'Yanlış',
      'game_based_performance': 'Oyun Bazlı Performans',
      'times_played': 'kez oynandı',
      'loading_data_error': 'Veri yüklenirken hata oluştu',
      'surveys_info': 'Katılabileceğiniz anketler burada görüntülenecek',
      'swipe_to_start': 'Başlamak için kaydır',
      'smart_education_platform': 'AI • Robotik • Kodlama • Yazılım',
      'software_robotics_education': 'Yazılım ve Robotik\nEğitim Platformu',
      'explore': 'Keşfet',
      'continue_with_login': 'Giriş Yaparak Devam Et',
      'robotics': '🤖 Robotik',
      'coding': '💻 Kodlama',
      'chess': '♟️ Satranç',
      'password': 'Şifre',
      'email_hint': 'ornek@email.com',
      'please_enter_email': 'Lütfen e-posta adresinizi girin',
      'enter_valid_email': 'Geçerli bir e-posta adresi girin',
      'please_enter_password': 'Lütfen şifrenizi girin',
      'password_min_length': 'Şifre en az 6 karakter olmalıdır',
      'no_account': 'Hesabınız yok mu?',
      'create_new_account': 'Yeni Hesap Oluştur',
      'name_hint': 'Adınız ve Soyadınız',
      'please_enter_name': 'Lütfen adınızı ve soyadınızı girin',
      'name_min_length': 'Ad en az 3 karakter olmalıdır',
      'password_confirm': 'Şifre Tekrar',
      'please_confirm_password': 'Lütfen şifrenizi tekrar girin',
      'passwords_do_not_match': 'Şifreler eşleşmiyor',
      'account_type': 'Hesap Tipi',
      'parent_with_camera': 'Canlı kamera erişimi dahil',
      'student_access': 'Oyunlar ve ödevlere erişim',
      'teacher_access': 'Müfredat ve ödev yönetimi',
      'visitor_access': 'Genel içerik erişimi',
      'registration_success': 'Kayıt başarılı! Hoş geldiniz.',
      'already_have_account_question': 'Zaten hesabınız var mı?',
      'onboarding1_title': 'Güvenilir Eğitim Platformu',
      'onboarding1_description':
          'DevEducation ile öğrenciler güvenli bir ortamda, uzman eğitmenler eşliğinde robotik ve yazılım öğrenir. Her adımı takip edin, gelişimi izleyin.',
      'onboarding2_title': 'Kapsamlı Müfredat',
      'onboarding2_description':
          'MEB onaylı müfredat ile uyumlu, yaş gruplarına özel tasarlanmış eğitim programları. Arduino, Python, Scratch ve daha fazlası profesyonel eğitmenlerle.',
      'onboarding3_title': 'Gelişimi Anlık Takip',
      'onboarding3_description':
          'Öğrenci ilerleme raporları, başarı rozetleri ve detaylı analizlerle öğrencinizin gelişimini her an izleyin. Veli paneli ile tam kontrol.',
      'user_info_load_error': 'Kullanıcı bilgileri yüklenemedi',
      'last_login': 'Son Giriş',
      'already_have_account_login': 'Zaten Hesabım Var',
      'logout_error_message': 'Çıkış yapılırken hata oluştu',

      // Social Feed
      'create_post': 'Gönderi Oluştur',
      'add_images': 'Resim Ekle',
      'add_pdf': 'PDF Ekle',
      'add_link': 'Link Ekle',
      'what_on_your_mind': 'Aklında ne var? 🚀',
      'posts_remaining': 'gönderi hakkı kaldı',
      'unlimited_posts': 'Sınırsız gönderi',
      'daily_limit_reached': 'Günlük gönderi limitine ulaşıldı',
      'like': 'Beğen',
      'comment': 'Yorum',
      'share': 'Paylaş',
      'report': 'Bildir',
      'viewing_as_guest': 'Misafir olarak görüntüleniyor',
      'login_to_comment': 'Yorum yapmak için giriş yapın',
      'post_created_successfully': 'Gönderi başarıyla oluşturuldu!',
      'post_deleted': 'Gönderi silindi',
      'confirm_delete': 'Silmek istediğinizden emin misiniz?',
      'no_posts_yet': 'Henüz gönderi yok',
      'be_first_to_post': 'İlk gönderiyi siz paylaşın!',
      'trending': 'Trendler',
      'ai_and_robotics': 'AI & Robotik',
      'funny': 'Eğlenceli',
      'all': 'Tümü',
      'comments': 'Yorumlar',
      'no_comments_yet': 'Henüz yorum yok',
      'add_comment': 'Yorum ekle...',
      'post_details': 'Gönderi Detayları',
      'post_not_found': 'Gönderi bulunamadı',

      // Enhanced Feed Screen
      'filter_trending': 'Trendler',
      'filter_ai_robotics': 'AI & Robotik',
      'filter_coding': 'Kodlama',
      'filter_funny': 'Eğlenceli',
      'filter_all': 'Tümü',
      'viewing_as_guest_login':
          'Misafir olarak görüntüleniyor - Etkileşim için giriş yapın',
      'error_loading_posts': 'Gönderiler yüklenirken hata oluştu',
      'be_first_to_share_amazing': 'İlk harika paylaşımı siz yapın!',
      'login_to_comment_lock': '🔒 Yorum yapmak için giriş yapın',
      'share_functionality_coming_soon': 'Paylaşım özelliği yakında geliyor!',
      'delete_post': 'Gönderiyi Sil',
      'delete_post_confirmation':
          'Bu gönderiyi silmek istediğinizden emin misiniz?',
      'post_deleted_successfully': 'Gönderi başarıyla silindi',
      'error_deleting_post': 'Gönderi silinirken hata oluştu',
      'pdf_document': 'PDF Belgesi',
      'tap_to_view': 'Görüntülemek için dokun',
      'likes': 'beğeni',

      // Create Post Screen
      'daily_limit_reached_upgrade':
          'Günlük gönderi limitine ulaşıldı. Sınırsız gönderi için Pro sürüme geçin!',
      'failed_to_create_post': 'Gönderi oluşturulamadı',
      'posts_remaining_today': 'bugün gönderi hakkı kaldı',
      'daily_limit_reached_upgrade_pro':
          'Günlük limit doldu! Sınırsız gönderi için Pro\'ya geçin',
      'pro_unlimited_posts': 'PRO: Sınırsız gönderi',
      'what_on_your_mind_rocket': 'Aklında ne var? 🚀',
      'add_link_optional': '🔗 Link ekle (opsiyonel)',
      'selected_images': '📸 Seçilen Resimler',
      'pdf_attached': 'PDF Eklendi',
      'images': 'Resimler',
      'pdf': 'PDF',
      'post': 'Paylaş',

      // Post Detail Screen
      'please_login_to_comment': 'Yorum yapmak için lütfen giriş yapın',
      'error_posting_comment': 'Yorum gönderilirken hata oluştu',
      'be_first_to_comment': 'İlk yorumu siz yapın!',
      'add_comment_ellipsis': 'Yorum ekle...',
      'login_to_comment_lock_detail': '🔒 Yorum yapmak için giriş yapın',
    },
    'en': {
      'app_name': 'DevEducation',
      'welcome': 'Welcome',
      'settings': 'Settings',
      'videoLessons': 'Video Lessons',
      'level': 'Level',
      'profile': 'Profile',
      'home': 'Home',
      'messages': 'Messages',
      'social_feed': 'DevSocial',
      'write_your_message': 'Write your message...',
      'language_region': 'Language & Region',
      'language': 'Language',
      'notifications': 'Notifications',
      'enable_notifications': 'Enable Notifications',
      'app_notifications': 'Receive app notifications',
      'sound': 'Sound',
      'notification_sounds': 'Notification sounds',
      'vibration': 'Vibration',
      'notification_vibration': 'Vibrate on notification',
      'accessibility': 'Accessibility',
      'text_size': 'Text Size',
      'high_contrast': 'High Contrast',
      'make_colors_bolder': 'Make colors more distinct',
      'privacy': 'Privacy',
      'data_sharing': 'Data Sharing',
      'share_anonymous_data': 'Share anonymous data to improve the app',
      'about': 'About',
      'about_app': 'About App',
      'version': 'Version',
      'reset_settings': 'Reset Settings',
      'select_language': 'Select Language',
      'turkish': 'Türkçe',
      'english': 'English',
      'cancel': 'Cancel',
      'reset_confirmation':
          'All settings will be reset to default values. Are you sure?',
      'reset': 'Reset',
      'settings_reset_success': 'Settings have been reset to default values',
      'app_description':
          'A platform developed for robotics and coding education.',
      'ok': 'OK',
      'app_experience': 'App Experience',
      'show_onboarding_again': 'Show Onboarding Again',
      'onboarding_will_show':
          'Onboarding screen will be shown when app restarts',
      'onboarding_reset': 'Onboarding Reset',
      'onboarding_reset_message':
          'Onboarding screen will be shown on next app launch.',
      'language_changing': 'Changing Language...',
      'language_changed_to': 'Language changed to',
      'todays_goals': "Today's Goals",
      'activities': 'Activities',
      'games': 'Games',
      'homework': 'Homework',
      'points': 'Points',
      'achievements': 'Achievements',
      'popular_activities': 'Popular Activities',
      'robot_movement_game': 'Robot Movement Game',
      'educational_game': 'Educational game',
      'arduino_simulator': 'Arduino Simulator',
      'circuit_design': 'Circuit design',
      'my_homework': 'My Homework',
      'current_homework': 'Current homework',
      'dev_ai_chat': 'DevAI',
      'courses': 'Courses',
      'ai_assistant': 'AI assistant',
      'millionaire_game': 'Who Wants to Be a Millionaire?',
      'quiz_game': 'Quiz game',
      'worksheets': 'Worksheets',
      'ai_robotics_coding': 'AI, Robotics, Coding',
      'learning_score': 'Learning Score',
      'great_progress': "Great job! Keep it up to reach your goal.",
      'inactive': 'Inactive',
      'active': 'Active',
      'visitor': 'Visitor',
      'student': 'Student',
      'teacher': 'Teacher',
      'parent': 'Parent',
      'admin': 'Admin',
      'login': 'Login',
      'logout': 'Logout',
      'register': 'Register',
      'logging_out': 'Logging out...',
      'login_to_access_features': 'Login to access all features',
      'how_would_you_like_to_use_devkom':
          'How would you like to use DevEducation?',
      'select_your_purpose': 'Select your purpose',
      'to_learn': 'To Learn',
      'to_learn_description': 'I want to learn coding, robotics and AI',
      'track_my_child': 'Track My Child\'s Progress',
      'track_my_child_description':
          'I want to follow my child\'s educational journey',
      'full_access_continues': 'Access to all content continues',
      'can_change_in_settings': 'You can change this later in profile settings',
      'logout_confirmation': 'Are you sure you want to logout?',
      'schedule': 'Class Schedule',
      'attendance': 'Attendance',
      'curriculum': 'Curriculum',
      'agenda': 'Agenda',
      'achievement_analysis': 'Achievement Analysis',
      'surveys': 'Surveys',
      'logout_error': 'Error occurred while logging out',
      'already_have_account': 'Already have an account',
      'skip': 'Skip',
      'create_free_account': 'Create Free Account',
      'free_sign_up': 'Free Sign Up',
      'save_progress_message': 'Save your progress and access all features',
      'lets_get_started': 'Let\'s Get Started',
      'email': 'Email',
      'role': 'Role',
      'live_camera_access': 'Live Camera Access',
      'account_info': 'Account Information',
      'access_info': 'Access Information',
      'full_name': 'Full Name',
      'status': 'Status',
      'member_since': 'Member Since',
      'weekly_schedule': 'Your weekly class schedule will be displayed here',
      'attendance_tracking': 'Attendance Tracking',
      'attendance_info': 'Your attendance information will be displayed here',
      'curriculum_info': 'Course curriculum and topics will be displayed here',
      'please_login': 'Please login',
      'error': 'Error',
      'no_events_on_this_date': 'No events on this date',
      'delete_event': 'Delete Event',
      'delete_event_confirmation': 'are you sure you want to delete?',
      'delete': 'Delete',
      'deleted': 'deleted',
      'add_event': 'Add Event',
      'title': 'Title',
      'description': 'Description',
      'description_optional': 'Description (Optional)',
      'type': 'Type',
      'note': 'Note',
      'reminder': 'Reminder',
      'task': 'Task',
      'add': 'Add',
      'please_enter_title': 'Please enter a title',
      'event_added': 'Event added!',
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
      'no_games_played': 'No Games Played Yet',
      'play_games_message':
          'Play games from the Games section\nto view your statistics',
      'overall_success': 'Overall Success Status',
      'total_games': 'Total Games',
      'correct': 'Correct',
      'wrong': 'Wrong',
      'game_based_performance': 'Game Based Performance',
      'times_played': 'times played',
      'loading_data_error': 'Error occurred while loading data',
      'surveys_info': 'Surveys you can participate in will be displayed here',
      'swipe_to_start': 'Swipe to start',
      'smart_education_platform': 'AI • Robotics • Coding • Software',
      'software_robotics_education': 'Smart Education Platform\nWith AI',
      'explore': 'Explore',
      'continue_with_login': 'Continue with Login',
      'robotics': '🤖 Robotics',
      'coding': '💻 Coding',
      'chess': '♟️ Chess',
      'password': 'Password',
      'email_hint': 'example@email.com',
      'please_enter_email': 'Please enter your email address',
      'enter_valid_email': 'Please enter a valid email address',
      'please_enter_password': 'Please enter your password',
      'password_min_length': 'Password must be at least 6 characters',
      'no_account': "Don't have an account?",
      'create_new_account': 'Create New Account',
      'name_hint': 'Your Full Name',
      'please_enter_name': 'Please enter your full name',
      'name_min_length': 'Name must be at least 3 characters',
      'password_confirm': 'Confirm Password',
      'please_confirm_password': 'Please confirm your password',
      'passwords_do_not_match': 'Passwords do not match',
      'account_type': 'Account Type',
      'parent_with_camera': 'Live camera access included',
      'student_access': 'Games and homework access',
      'teacher_access': 'Curriculum and homework management',
      'visitor_access': 'General content access',
      'registration_success': 'Registration successful! Welcome.',
      'already_have_account_question': 'Already have an account?',
      'onboarding1_title': 'Trusted Education Platform',
      'onboarding1_description':
          'With DevEducation, students learn robotics and software in a safe environment with expert instructors. Track every step and monitor their progress.',
      'onboarding2_title': 'Comprehensive Curriculum',
      'onboarding2_description':
          'Education programs compatible with approved curriculum, specially designed for age groups. Arduino, Python, Scratch and more with professional instructors.',
      'onboarding3_title': 'Real-Time Progress Tracking',
      'onboarding3_description':
          'Track your student\'s progress at all times with progress reports, achievement badges and detailed analyses. Full control with parent panel.',
      'user_info_load_error': 'Failed to load user information',
      'last_login': 'Last Login',
      'already_have_account_login': 'Already Have an Account',
      'logout_error_message': 'An error occurred while logging out',

      // Social Feed
      'create_post': 'Create Post',
      'add_images': 'Add Images',
      'add_pdf': 'Add PDF',
      'add_link': 'Add Link',
      'what_on_your_mind': "What's on your mind? 🚀",
      'posts_remaining': 'posts remaining',
      'unlimited_posts': 'Unlimited posts',
      'daily_limit_reached': 'Daily post limit reached',
      'like': 'Like',
      'comment': 'Comment',
      'share': 'Share',
      'report': 'Report',
      'viewing_as_guest': 'Viewing as Guest',
      'login_to_comment': 'Login to comment',
      'post_created_successfully': 'Post created successfully!',
      'post_deleted': 'Post deleted',
      'confirm_delete': 'Are you sure you want to delete?',
      'no_posts_yet': 'No posts yet',
      'be_first_to_post': 'Be the first to post!',
      'trending': 'Trending',
      'ai_and_robotics': 'AI & Robotics',
      'funny': 'Funny',
      'all': 'All',
      'comments': 'Comments',
      'no_comments_yet': 'No comments yet',
      'add_comment': 'Add a comment...',
      'post_details': 'Post Details',
      'post_not_found': 'Post not found',

      // Enhanced Feed Screen
      'filter_trending': 'Trending',
      'filter_ai_robotics': 'AI & Robotics',
      'filter_coding': 'Coding',
      'filter_funny': 'Funny',
      'filter_all': 'All',
      'viewing_as_guest_login': 'Viewing as Guest - Login to interact',
      'error_loading_posts': 'Error loading posts',
      'be_first_to_share_amazing': 'Be the first to share something amazing!',
      'login_to_comment_lock': '🔒 Login to comment',
      'share_functionality_coming_soon': 'Share functionality coming soon!',
      'delete_post': 'Delete Post',
      'delete_post_confirmation': 'Are you sure you want to delete this post?',
      'post_deleted_successfully': 'Post deleted successfully',
      'error_deleting_post': 'Error deleting post',
      'pdf_document': 'PDF Document',
      'tap_to_view': 'Tap to view',
      'likes': 'likes',

      // Create Post Screen
      'daily_limit_reached_upgrade':
          'Daily post limit reached. Upgrade to Pro for unlimited posts!',
      'failed_to_create_post': 'Failed to create post',
      'posts_remaining_today': 'posts remaining today',
      'daily_limit_reached_upgrade_pro':
          'Daily limit reached! Upgrade to Pro for unlimited posts',
      'pro_unlimited_posts': 'PRO: Unlimited posts',
      'what_on_your_mind_rocket': "What's on your mind? 🚀",
      'add_link_optional': '🔗 Add a link (optional)',
      'selected_images': '📸 Selected Images',
      'pdf_attached': 'PDF Attached',
      'images': 'Images',
      'pdf': 'PDF',
      'post': 'Post',

      // Post Detail Screen
      'please_login_to_comment': 'Please login to comment',
      'error_posting_comment': 'Error posting comment',
      'be_first_to_comment': 'Be the first to comment!',
      'add_comment_ellipsis': 'Add a comment...',
      'login_to_comment_lock_detail': '🔒 Login to comment',
    },
    // Almanca. Cocuk uygulamasi oldugu icin her yerde 'du' — 'Sie' degil.
    'de': {
      'todays_goals': 'Heutige Ziele',
      'great_progress':
          'Das läuft super! Mach weiter, bis du dein Ziel erreichst.',
      'no_account': 'Noch kein Konto?',
      'what_on_your_mind': 'Was beschäftigt dich? 🚀',
      'what_on_your_mind_rocket': 'Was beschäftigt dich? 🚀',
      'app_name': 'DevEducation',
      'welcome': 'Willkommen',
      'settings': 'Einstellungen',
      'videoLessons': 'Video-Lektionen',
      'level': 'Level',
      'profile': 'Profil',
      'home': 'Start',
      'messages': 'Nachrichten',
      'social_feed': 'DevSocial',
      'write_your_message': 'Schreib deine Nachricht ...',
      'language_region': 'Sprache & Region',
      'language': 'Sprache',
      'notifications': 'Benachrichtigungen',
      'enable_notifications': 'Benachrichtigungen aktivieren',
      'app_notifications': 'App-Benachrichtigungen erhalten',
      'sound': 'Ton',
      'notification_sounds': 'Benachrichtigungstöne',
      'vibration': 'Vibration',
      'notification_vibration': 'Bei Benachrichtigung vibrieren',
      'accessibility': 'Barrierefreiheit',
      'text_size': 'Schriftgröße',
      'high_contrast': 'Hoher Kontrast',
      'make_colors_bolder': 'Farben deutlicher darstellen',
      'privacy': 'Datenschutz',
      'data_sharing': 'Datenfreigabe',
      'share_anonymous_data': 'Anonyme Daten teilen, um die App zu verbessern',
      'about': 'Über',
      'about_app': 'Über die App',
      'version': 'Version',
      'reset_settings': 'Einstellungen zurücksetzen',
      'select_language': 'Sprache wählen',
      'turkish': 'Türkçe',
      'english': 'English',
      'cancel': 'Abbrechen',
      'reset_confirmation':
          'Alle Einstellungen werden auf die Standardwerte zurückgesetzt. Bist du sicher?',
      'reset': 'Zurücksetzen',
      'settings_reset_success': 'Die Einstellungen wurden zurückgesetzt',
      'app_description':
          'Eine Plattform für Robotik- und Programmierunterricht.',
      'ok': 'OK',
      'app_experience': 'App-Erlebnis',
      'show_onboarding_again': 'Einführung erneut anzeigen',
      'onboarding_will_show': 'Die Einführung wird beim nächsten Start gezeigt',
      'onboarding_reset': 'Einführung zurückgesetzt',
      'onboarding_reset_message':
          'Die Einführung wird beim nächsten Start der App gezeigt.',
      'language_changing': 'Sprache wird geändert ...',
      'language_changed_to': 'Sprache geändert auf',
      'activities': 'Aktivitäten',
      'games': 'Spiele',
      'homework': 'Hausaufgaben',
      'points': 'Punkte',
      'achievements': 'Erfolge',
      'popular_activities': 'Beliebte Aktivitäten',
      'robot_movement_game': 'Roboter-Bewegungsspiel',
      'educational_game': 'Lernspiel',
      'arduino_simulator': 'Arduino-Simulator',
      'circuit_design': 'Schaltungsentwurf',
      'my_homework': 'Meine Hausaufgaben',
      'current_homework': 'Aktuelle Hausaufgaben',
      'dev_ai_chat': 'DevAI',
      'courses': 'Kurse',
      'ai_assistant': 'KI-Assistent',
      'millionaire_game': 'Wer wird Millionär?',
      'quiz_game': 'Quizspiel',
      'worksheets': 'Arbeitsblätter',
      'ai_robotics_coding': 'KI, Robotik, Programmieren',
      'learning_score': 'Lernpunktzahl',
      'inactive': 'Inaktiv',
      'active': 'Aktiv',
      'visitor': 'Gast',
      'student': 'Schüler:in',
      'teacher': 'Lehrkraft',
      'parent': 'Elternteil',
      'admin': 'Admin',
      'login': 'Anmelden',
      'logout': 'Abmelden',
      'register': 'Registrieren',
      'logging_out': 'Du wirst abgemeldet ...',
      'login_to_access_features': 'Melde dich an, um alle Funktionen zu nutzen',
      'how_would_you_like_to_use_devkom':
          'Wie möchtest du DevEducation nutzen?',
      'select_your_purpose': 'Wähle deinen Zweck',
      'to_learn': 'Zum Lernen',
      'to_learn_description': 'Ich möchte Programmieren, Robotik und KI lernen',
      'track_my_child': 'Fortschritt meines Kindes verfolgen',
      'track_my_child_description':
          'Ich möchte den Lernweg meines Kindes verfolgen',
      'full_access_continues': 'Der Zugang zu allen Inhalten bleibt bestehen',
      'can_change_in_settings':
          'Du kannst das später in den Profileinstellungen ändern',
      'logout_confirmation': 'Möchtest du dich wirklich abmelden?',
      'schedule': 'Stundenplan',
      'attendance': 'Anwesenheit',
      'curriculum': 'Lehrplan',
      'agenda': 'Kalender',
      'achievement_analysis': 'Leistungsanalyse',
      'surveys': 'Umfragen',
      'logout_error': 'Beim Abmelden ist ein Fehler aufgetreten',
      'already_have_account': 'Du hast schon ein Konto',
      'skip': 'Überspringen',
      'create_free_account': 'Kostenloses Konto erstellen',
      'free_sign_up': 'Kostenlos registrieren',
      'save_progress_message':
          'Sichere deinen Fortschritt und nutze alle Funktionen',
      'lets_get_started': 'Los geht\'s',
      'email': 'E-Mail',
      'role': 'Rolle',
      'live_camera_access': 'Live-Kamerazugriff',
      'account_info': 'Kontoinformationen',
      'access_info': 'Zugriffsinformationen',
      'full_name': 'Vollständiger Name',
      'status': 'Status',
      'member_since': 'Mitglied seit',
      'weekly_schedule': 'Hier wird dein Wochenstundenplan angezeigt',
      'attendance_tracking': 'Anwesenheitsverfolgung',
      'attendance_info': 'Hier werden deine Anwesenheitsdaten angezeigt',
      'curriculum_info': 'Hier werden Lehrplan und Themen angezeigt',
      'please_login': 'Bitte melde dich an',
      'error': 'Fehler',
      'no_events_on_this_date': 'Keine Termine an diesem Tag',
      'delete_event': 'Termin löschen',
      'delete_event_confirmation': 'wirklich löschen?',
      'delete': 'Löschen',
      'deleted': 'gelöscht',
      'add_event': 'Termin hinzufügen',
      'title': 'Titel',
      'description': 'Beschreibung',
      'description_optional': 'Beschreibung (optional)',
      'type': 'Art',
      'note': 'Notiz',
      'reminder': 'Erinnerung',
      'task': 'Aufgabe',
      'add': 'Hinzufügen',
      'please_enter_title': 'Bitte gib einen Titel ein',
      'event_added': 'Termin hinzugefügt!',
      'monday': 'Mo',
      'tuesday': 'Di',
      'wednesday': 'Mi',
      'thursday': 'Do',
      'friday': 'Fr',
      'saturday': 'Sa',
      'sunday': 'So',
      'no_games_played': 'Noch keine Spiele gespielt',
      'play_games_message':
          'Spiele etwas im Bereich Spiele,\num deine Statistiken zu sehen',
      'overall_success': 'Gesamterfolg',
      'total_games': 'Spiele insgesamt',
      'correct': 'Richtig',
      'wrong': 'Falsch',
      'game_based_performance': 'Leistung nach Spiel',
      'times_played': 'mal gespielt',
      'loading_data_error': 'Beim Laden der Daten ist ein Fehler aufgetreten',
      'surveys_info':
          'Hier werden Umfragen angezeigt, an denen du teilnehmen kannst',
      'swipe_to_start': 'Wischen zum Starten',
      'smart_education_platform': 'KI • Robotik • Programmieren • Software',
      'software_robotics_education': 'Intelligente Lernplattform\nmit KI',
      'explore': 'Entdecken',
      'continue_with_login': 'Mit Anmeldung fortfahren',
      'robotics': '🤖 Robotik',
      'coding': '💻 Programmieren',
      'chess': '♟️ Schach',
      'password': 'Passwort',
      'email_hint': 'beispiel@email.com',
      'please_enter_email': 'Bitte gib deine E-Mail-Adresse ein',
      'enter_valid_email': 'Bitte gib eine gültige E-Mail-Adresse ein',
      'please_enter_password': 'Bitte gib dein Passwort ein',
      'password_min_length': 'Das Passwort muss mindestens 6 Zeichen haben',
      'create_new_account': 'Neues Konto erstellen',
      'name_hint': 'Dein vollständiger Name',
      'please_enter_name': 'Bitte gib deinen vollständigen Namen ein',
      'name_min_length': 'Der Name muss mindestens 3 Zeichen haben',
      'password_confirm': 'Passwort bestätigen',
      'please_confirm_password': 'Bitte bestätige dein Passwort',
      'passwords_do_not_match': 'Die Passwörter stimmen nicht überein',
      'account_type': 'Kontotyp',
      'parent_with_camera': 'Live-Kamerazugriff inklusive',
      'student_access': 'Zugang zu Spielen und Hausaufgaben',
      'teacher_access': 'Verwaltung von Lehrplan und Hausaufgaben',
      'visitor_access': 'Zugang zu allgemeinen Inhalten',
      'registration_success': 'Registrierung erfolgreich! Willkommen.',
      'already_have_account_question': 'Hast du schon ein Konto?',
      'onboarding1_title': 'Vertrauenswürdige Lernplattform',
      'onboarding1_description':
          'Mit DevEducation lernen Kinder Robotik und Software in einer sicheren Umgebung mit erfahrenen Lehrkräften. Verfolge jeden Schritt und behalte den Fortschritt im Blick.',
      'onboarding2_title': 'Umfassender Lehrplan',
      'onboarding2_description':
          'Lernprogramme nach geprüftem Lehrplan, eigens für Altersgruppen entwickelt. Arduino, Python, Scratch und mehr — mit erfahrenen Lehrkräften.',
      'onboarding3_title': 'Fortschritt in Echtzeit',
      'onboarding3_description':
          'Verfolge den Fortschritt jederzeit mit Berichten, Erfolgsabzeichen und ausführlichen Auswertungen. Eltern sehen alles bequem im Profil.',
      'user_info_load_error':
          'Benutzerinformationen konnten nicht geladen werden',
      'last_login': 'Letzte Anmeldung',
      'already_have_account_login': 'Du hast schon ein Konto',
      'logout_error_message': 'Beim Abmelden ist ein Fehler aufgetreten',
      'create_post': 'Beitrag erstellen',
      'add_images': 'Bilder hinzufügen',
      'add_pdf': 'PDF hinzufügen',
      'add_link': 'Link hinzufügen',
      'posts_remaining': 'Beiträge übrig',
      'unlimited_posts': 'Unbegrenzte Beiträge',
      'daily_limit_reached': 'Tageslimit für Beiträge erreicht',
      'like': 'Gefällt mir',
      'comment': 'Kommentieren',
      'share': 'Teilen',
      'report': 'Melden',
      'viewing_as_guest': 'Du siehst dies als Gast',
      'login_to_comment': 'Melde dich an, um zu kommentieren',
      'post_created_successfully': 'Beitrag erstellt!',
      'post_deleted': 'Beitrag gelöscht',
      'confirm_delete': 'Möchtest du das wirklich löschen?',
      'no_posts_yet': 'Noch keine Beiträge',
      'be_first_to_post': 'Sei die erste Person, die etwas postet!',
      'trending': 'Beliebt',
      'ai_and_robotics': 'KI & Robotik',
      'funny': 'Lustig',
      'all': 'Alle',
      'comments': 'Kommentare',
      'no_comments_yet': 'Noch keine Kommentare',
      'add_comment': 'Kommentar schreiben ...',
      'post_details': 'Beitragsdetails',
      'post_not_found': 'Beitrag nicht gefunden',
      'filter_trending': 'Beliebt',
      'filter_ai_robotics': 'KI & Robotik',
      'filter_coding': 'Programmieren',
      'filter_funny': 'Lustig',
      'filter_all': 'Alle',
      'viewing_as_guest_login': 'Als Gast — melde dich an, um mitzumachen',
      'error_loading_posts': 'Beiträge konnten nicht geladen werden',
      'be_first_to_share_amazing': 'Teile als Erste:r etwas Tolles!',
      'login_to_comment_lock': '🔒 Melde dich an, um zu kommentieren',
      'share_functionality_coming_soon': 'Teilen kommt bald!',
      'delete_post': 'Beitrag löschen',
      'delete_post_confirmation':
          'Möchtest du diesen Beitrag wirklich löschen?',
      'post_deleted_successfully': 'Beitrag gelöscht',
      'error_deleting_post': 'Beitrag konnte nicht gelöscht werden',
      'pdf_document': 'PDF-Dokument',
      'tap_to_view': 'Zum Ansehen tippen',
      'likes': 'Gefällt-mir-Angaben',
      'daily_limit_reached_upgrade':
          'Tageslimit erreicht. Mit Pro postest du unbegrenzt!',
      'failed_to_create_post': 'Beitrag konnte nicht erstellt werden',
      'posts_remaining_today': 'Beiträge heute übrig',
      'daily_limit_reached_upgrade_pro':
          'Tageslimit erreicht! Mit Pro postest du unbegrenzt',
      'pro_unlimited_posts': 'PRO: Unbegrenzte Beiträge',
      'add_link_optional': '🔗 Link hinzufügen (optional)',
      'selected_images': '📸 Ausgewählte Bilder',
      'pdf_attached': 'PDF angehängt',
      'images': 'Bilder',
      'pdf': 'PDF',
      'post': 'Posten',
      'please_login_to_comment': 'Bitte melde dich an, um zu kommentieren',
      'error_posting_comment': 'Kommentar konnte nicht gesendet werden',
      'be_first_to_comment': 'Schreib den ersten Kommentar!',
      'add_comment_ellipsis': 'Kommentar schreiben ...',
      'login_to_comment_lock_detail': '🔒 Melde dich an, um zu kommentieren',
    },
    // Ispanyolca. Her yerde 'tu' — 'usted' degil. Latin Amerika'da da
    // okunabilsin diye 'vosotros' kullanilmiyor.
    'es': {
      'todays_goals': 'Metas de hoy',
      'great_progress': '¡Vas muy bien! Sigue así hasta llegar a tu meta.',
      'no_account': '¿Todavía no tienes cuenta?',
      'what_on_your_mind': '¿Qué se te ocurre? 🚀',
      'what_on_your_mind_rocket': '¿Qué se te ocurre? 🚀',
      'app_name': 'DevEducation',
      'welcome': 'Bienvenido',
      'settings': 'Ajustes',
      'videoLessons': 'Videolecciones',
      'level': 'Nivel',
      'profile': 'Perfil',
      'home': 'Inicio',
      'messages': 'Mensajes',
      'social_feed': 'DevSocial',
      'write_your_message': 'Escribe tu mensaje...',
      'language_region': 'Idioma y región',
      'language': 'Idioma',
      'notifications': 'Notificaciones',
      'enable_notifications': 'Activar notificaciones',
      'app_notifications': 'Recibir notificaciones de la app',
      'sound': 'Sonido',
      'notification_sounds': 'Sonidos de notificación',
      'vibration': 'Vibración',
      'notification_vibration': 'Vibrar al recibir una notificación',
      'accessibility': 'Accesibilidad',
      'text_size': 'Tamaño del texto',
      'high_contrast': 'Alto contraste',
      'make_colors_bolder': 'Hacer los colores más marcados',
      'privacy': 'Privacidad',
      'data_sharing': 'Compartir datos',
      'share_anonymous_data': 'Compartir datos anónimos para mejorar la app',
      'about': 'Acerca de',
      'about_app': 'Acerca de la app',
      'version': 'Versión',
      'reset_settings': 'Restablecer ajustes',
      'select_language': 'Elige un idioma',
      'turkish': 'Türkçe',
      'english': 'English',
      'cancel': 'Cancelar',
      'reset_confirmation':
          'Se restablecerán todos los ajustes a sus valores por defecto. ¿Seguro?',
      'reset': 'Restablecer',
      'settings_reset_success': 'Los ajustes se han restablecido',
      'app_description':
          'Una plataforma de enseñanza de robótica y programación.',
      'ok': 'Aceptar',
      'app_experience': 'Experiencia de la app',
      'show_onboarding_again': 'Volver a ver la introducción',
      'onboarding_will_show': 'La introducción aparecerá al reiniciar la app',
      'onboarding_reset': 'Introducción restablecida',
      'onboarding_reset_message':
          'La introducción aparecerá la próxima vez que abras la app.',
      'language_changing': 'Cambiando de idioma...',
      'language_changed_to': 'Idioma cambiado a',
      'activities': 'Actividades',
      'games': 'Juegos',
      'homework': 'Tareas',
      'points': 'Puntos',
      'achievements': 'Logros',
      'popular_activities': 'Actividades populares',
      'robot_movement_game': 'Juego de movimiento del robot',
      'educational_game': 'Juego educativo',
      'arduino_simulator': 'Simulador de Arduino',
      'circuit_design': 'Diseño de circuitos',
      'my_homework': 'Mis tareas',
      'current_homework': 'Tareas actuales',
      'dev_ai_chat': 'DevAI',
      'courses': 'Cursos',
      'ai_assistant': 'Asistente de IA',
      'millionaire_game': '¿Quién quiere ser millonario?',
      'quiz_game': 'Juego de preguntas',
      'worksheets': 'Fichas de trabajo',
      'ai_robotics_coding': 'IA, robótica y programación',
      'learning_score': 'Puntuación de aprendizaje',
      'inactive': 'Inactivo',
      'active': 'Activo',
      'visitor': 'Invitado',
      'student': 'Estudiante',
      'teacher': 'Profesor/a',
      'parent': 'Madre o padre',
      'admin': 'Administrador',
      'login': 'Iniciar sesión',
      'logout': 'Cerrar sesión',
      'register': 'Crear cuenta',
      'logging_out': 'Cerrando sesión...',
      'login_to_access_features': 'Inicia sesión para usar todas las funciones',
      'how_would_you_like_to_use_devkom': '¿Cómo quieres usar DevEducation?',
      'select_your_purpose': 'Elige para qué lo quieres',
      'to_learn': 'Para aprender',
      'to_learn_description': 'Quiero aprender programación, robótica e IA',
      'track_my_child': 'Seguir el progreso de mi hijo/a',
      'track_my_child_description': 'Quiero seguir el aprendizaje de mi hijo/a',
      'full_access_continues': 'El acceso a todo el contenido se mantiene',
      'can_change_in_settings':
          'Puedes cambiarlo más tarde en los ajustes del perfil',
      'logout_confirmation': '¿Seguro que quieres cerrar sesión?',
      'schedule': 'Horario de clases',
      'attendance': 'Asistencia',
      'curriculum': 'Plan de estudios',
      'agenda': 'Agenda',
      'achievement_analysis': 'Análisis de rendimiento',
      'surveys': 'Encuestas',
      'logout_error': 'Se ha producido un error al cerrar sesión',
      'already_have_account': 'Ya tienes una cuenta',
      'skip': 'Saltar',
      'create_free_account': 'Crear cuenta gratis',
      'free_sign_up': 'Registro gratuito',
      'save_progress_message': 'Guarda tu progreso y usa todas las funciones',
      'lets_get_started': 'Vamos a empezar',
      'email': 'Correo electrónico',
      'role': 'Rol',
      'live_camera_access': 'Acceso a la cámara en directo',
      'account_info': 'Información de la cuenta',
      'access_info': 'Información de acceso',
      'full_name': 'Nombre completo',
      'status': 'Estado',
      'member_since': 'Miembro desde',
      'weekly_schedule': 'Aquí aparecerá tu horario semanal de clases',
      'attendance_tracking': 'Seguimiento de asistencia',
      'attendance_info': 'Aquí aparecerá tu información de asistencia',
      'curriculum_info': 'Aquí aparecerán el plan de estudios y los temas',
      'please_login': 'Inicia sesión, por favor',
      'error': 'Error',
      'no_events_on_this_date': 'No hay eventos en esta fecha',
      'delete_event': 'Eliminar evento',
      'delete_event_confirmation': '¿seguro que quieres eliminarlo?',
      'delete': 'Eliminar',
      'deleted': 'eliminado',
      'add_event': 'Añadir evento',
      'title': 'Título',
      'description': 'Descripción',
      'description_optional': 'Descripción (opcional)',
      'type': 'Tipo',
      'note': 'Nota',
      'reminder': 'Recordatorio',
      'task': 'Tarea',
      'add': 'Añadir',
      'please_enter_title': 'Escribe un título',
      'event_added': '¡Evento añadido!',
      'monday': 'Lun',
      'tuesday': 'Mar',
      'wednesday': 'Mié',
      'thursday': 'Jue',
      'friday': 'Vie',
      'saturday': 'Sáb',
      'sunday': 'Dom',
      'no_games_played': 'Todavía no has jugado a nada',
      'play_games_message':
          'Juega desde la sección Juegos\npara ver tus estadísticas',
      'overall_success': 'Rendimiento general',
      'total_games': 'Partidas totales',
      'correct': 'Aciertos',
      'wrong': 'Fallos',
      'game_based_performance': 'Rendimiento por juego',
      'times_played': 'veces jugado',
      'loading_data_error': 'Se ha producido un error al cargar los datos',
      'surveys_info':
          'Aquí aparecerán las encuestas en las que puedes participar',
      'swipe_to_start': 'Desliza para empezar',
      'smart_education_platform': 'IA • Robótica • Programación • Software',
      'software_robotics_education': 'Plataforma de aprendizaje\ncon IA',
      'explore': 'Explorar',
      'continue_with_login': 'Continuar iniciando sesión',
      'robotics': '🤖 Robótica',
      'coding': '💻 Programación',
      'chess': '♟️ Ajedrez',
      'password': 'Contraseña',
      'email_hint': 'ejemplo@email.com',
      'please_enter_email': 'Escribe tu correo electrónico',
      'enter_valid_email': 'Escribe un correo electrónico válido',
      'please_enter_password': 'Escribe tu contraseña',
      'password_min_length': 'La contraseña debe tener al menos 6 caracteres',
      'create_new_account': 'Crear una cuenta nueva',
      'name_hint': 'Tu nombre completo',
      'please_enter_name': 'Escribe tu nombre completo',
      'name_min_length': 'El nombre debe tener al menos 3 caracteres',
      'password_confirm': 'Confirmar contraseña',
      'please_confirm_password': 'Confirma tu contraseña',
      'passwords_do_not_match': 'Las contraseñas no coinciden',
      'account_type': 'Tipo de cuenta',
      'parent_with_camera': 'Incluye acceso a la cámara en directo',
      'student_access': 'Acceso a juegos y tareas',
      'teacher_access': 'Gestión del plan de estudios y las tareas',
      'visitor_access': 'Acceso al contenido general',
      'registration_success': '¡Cuenta creada! Te damos la bienvenida.',
      'already_have_account_question': '¿Ya tienes una cuenta?',
      'onboarding1_title': 'Una plataforma de confianza',
      'onboarding1_description':
          'Con DevEducation los niños aprenden robótica y software en un entorno seguro y con profesorado experto. Sigue cada paso y consulta su progreso.',
      'onboarding2_title': 'Plan de estudios completo',
      'onboarding2_description':
          'Programas basados en un plan de estudios aprobado y diseñados para cada edad. Arduino, Python, Scratch y mucho más, con profesorado experto.',
      'onboarding3_title': 'Progreso en tiempo real',
      'onboarding3_description':
          'Consulta el progreso cuando quieras con informes, insignias de logro y análisis detallados. Control total desde el área para familias.',
      'user_info_load_error':
          'No se ha podido cargar la información del usuario',
      'last_login': 'Última sesión',
      'already_have_account_login': 'Ya tienes una cuenta',
      'logout_error_message': 'Se ha producido un error al cerrar sesión',
      'create_post': 'Crear publicación',
      'add_images': 'Añadir imágenes',
      'add_pdf': 'Añadir PDF',
      'add_link': 'Añadir enlace',
      'posts_remaining': 'publicaciones restantes',
      'unlimited_posts': 'Publicaciones ilimitadas',
      'daily_limit_reached': 'Has alcanzado el límite diario de publicaciones',
      'like': 'Me gusta',
      'comment': 'Comentar',
      'share': 'Compartir',
      'report': 'Denunciar',
      'viewing_as_guest': 'Estás viendo esto como invitado',
      'login_to_comment': 'Inicia sesión para comentar',
      'post_created_successfully': '¡Publicación creada!',
      'post_deleted': 'Publicación eliminada',
      'confirm_delete': '¿Seguro que quieres eliminarlo?',
      'no_posts_yet': 'Todavía no hay publicaciones',
      'be_first_to_post': '¡Sé la primera persona en publicar!',
      'trending': 'Tendencias',
      'ai_and_robotics': 'IA y robótica',
      'funny': 'Divertido',
      'all': 'Todo',
      'comments': 'Comentarios',
      'no_comments_yet': 'Todavía no hay comentarios',
      'add_comment': 'Escribe un comentario...',
      'post_details': 'Detalles de la publicación',
      'post_not_found': 'Publicación no encontrada',
      'filter_trending': 'Tendencias',
      'filter_ai_robotics': 'IA y robótica',
      'filter_coding': 'Programación',
      'filter_funny': 'Divertido',
      'filter_all': 'Todo',
      'viewing_as_guest_login':
          'Estás como invitado: inicia sesión para participar',
      'error_loading_posts': 'No se han podido cargar las publicaciones',
      'be_first_to_share_amazing':
          '¡Sé la primera persona en compartir algo genial!',
      'login_to_comment_lock': '🔒 Inicia sesión para comentar',
      'share_functionality_coming_soon': '¡Compartir llegará pronto!',
      'delete_post': 'Eliminar publicación',
      'delete_post_confirmation':
          '¿Seguro que quieres eliminar esta publicación?',
      'post_deleted_successfully': 'Publicación eliminada',
      'error_deleting_post': 'No se ha podido eliminar la publicación',
      'pdf_document': 'Documento PDF',
      'tap_to_view': 'Toca para ver',
      'likes': 'me gusta',
      'daily_limit_reached_upgrade':
          'Límite diario alcanzado. ¡Con Pro publicas sin límite!',
      'failed_to_create_post': 'No se ha podido crear la publicación',
      'posts_remaining_today': 'publicaciones restantes hoy',
      'daily_limit_reached_upgrade_pro':
          '¡Límite diario alcanzado! Con Pro publicas sin límite',
      'pro_unlimited_posts': 'PRO: publicaciones ilimitadas',
      'add_link_optional': '🔗 Añadir un enlace (opcional)',
      'selected_images': '📸 Imágenes elegidas',
      'pdf_attached': 'PDF adjunto',
      'images': 'Imágenes',
      'pdf': 'PDF',
      'post': 'Publicar',
      'please_login_to_comment': 'Inicia sesión para comentar',
      'error_posting_comment': 'No se ha podido enviar el comentario',
      'be_first_to_comment': '¡Escribe el primer comentario!',
      'add_comment_ellipsis': 'Escribe un comentario...',
      'login_to_comment_lock_detail': '🔒 Inicia sesión para comentar',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Desteklenen diller tek yerde tanimli; burada elle bir liste
    // tutmak, dil eklendiginde bu satirin unutulmasi demekti.
    return AppLang.isSupported(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
