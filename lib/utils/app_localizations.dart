import 'package:flutter/material.dart';

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
  String get appName => _localizedValues[locale.languageCode]?['app_name'] ?? 'Devkom App';
  String get welcome => _localizedValues[locale.languageCode]?['welcome'] ?? 'Hoşgeldiniz';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Ayarlar';
  String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Profil';
  String get home => _localizedValues[locale.languageCode]?['home'] ?? 'Ana Sayfa';
  String get messages => _localizedValues[locale.languageCode]?['messages'] ?? 'Mesajlar';
  String get socialFeed => _localizedValues[locale.languageCode]?['social_feed'] ?? 'DevSocial';
  String get writeYourMessage => _localizedValues[locale.languageCode]?['write_your_message'] ?? 'Mesajınızı yazın...';

  // Settings screen
  String get languageAndRegion => _localizedValues[locale.languageCode]?['language_region'] ?? 'Dil ve Bölge';
  String get language => _localizedValues[locale.languageCode]?['language'] ?? 'Dil';
  String get notifications => _localizedValues[locale.languageCode]?['notifications'] ?? 'Bildirimler';
  String get enableNotifications => _localizedValues[locale.languageCode]?['enable_notifications'] ?? 'Bildirimleri Aç';
  String get appNotifications => _localizedValues[locale.languageCode]?['app_notifications'] ?? 'Uygulama bildirimlerini al';
  String get sound => _localizedValues[locale.languageCode]?['sound'] ?? 'Ses';
  String get notificationSounds => _localizedValues[locale.languageCode]?['notification_sounds'] ?? 'Bildirim sesleri';
  String get vibration => _localizedValues[locale.languageCode]?['vibration'] ?? 'Titreşim';
  String get notificationVibration => _localizedValues[locale.languageCode]?['notification_vibration'] ?? 'Bildirimde titreşim';
  String get accessibility => _localizedValues[locale.languageCode]?['accessibility'] ?? 'Erişilebilirlik';
  String get textSize => _localizedValues[locale.languageCode]?['text_size'] ?? 'Yazı Boyutu';
  String get highContrast => _localizedValues[locale.languageCode]?['high_contrast'] ?? 'Yüksek Kontrast';
  String get makeColorsBolder => _localizedValues[locale.languageCode]?['make_colors_bolder'] ?? 'Renkleri daha belirgin yap';
  String get privacy => _localizedValues[locale.languageCode]?['privacy'] ?? 'Gizlilik';
  String get dataSharing => _localizedValues[locale.languageCode]?['data_sharing'] ?? 'Veri Paylaşımı';
  String get shareAnonymousData => _localizedValues[locale.languageCode]?['share_anonymous_data'] ?? 'Uygulamayı geliştirmek için anonim veri paylaş';
  String get about => _localizedValues[locale.languageCode]?['about'] ?? 'Hakkında';
  String get aboutApp => _localizedValues[locale.languageCode]?['about_app'] ?? 'Uygulama Hakkında';
  String get version => _localizedValues[locale.languageCode]?['version'] ?? 'Versiyon';
  String get resetSettings => _localizedValues[locale.languageCode]?['reset_settings'] ?? 'Ayarları Sıfırla';
  String get selectLanguage => _localizedValues[locale.languageCode]?['select_language'] ?? 'Dil Seçin';
  String get turkish => _localizedValues[locale.languageCode]?['turkish'] ?? 'Türkçe';
  String get english => _localizedValues[locale.languageCode]?['english'] ?? 'English';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'İptal';
  String get resetConfirmation => _localizedValues[locale.languageCode]?['reset_confirmation'] ?? 'Tüm ayarlar varsayılan değerlere sıfırlanacak. Emin misiniz?';
  String get reset => _localizedValues[locale.languageCode]?['reset'] ?? 'Sıfırla';
  String get settingsResetSuccess => _localizedValues[locale.languageCode]?['settings_reset_success'] ?? 'Ayarlar varsayılan değerlere sıfırlandı';
  String get appDescription => _localizedValues[locale.languageCode]?['app_description'] ?? 'Robotik ve kodlama eğitimi için geliştirilmiş bir platformdur.';
  String get ok => _localizedValues[locale.languageCode]?['ok'] ?? 'Tamam';
  String get appExperience => _localizedValues[locale.languageCode]?['app_experience'] ?? 'Uygulama Deneyimi';
  String get showOnboardingAgain => _localizedValues[locale.languageCode]?['show_onboarding_again'] ?? 'Tanıtımı Tekrar Göster';
  String get onboardingWillShow => _localizedValues[locale.languageCode]?['onboarding_will_show'] ?? 'Uygulama yeniden başlatıldığında tanıtım ekranı gösterilecek';
  String get onboardingReset => _localizedValues[locale.languageCode]?['onboarding_reset'] ?? 'Tanıtım sıfırlandı';
  String get onboardingResetMessage => _localizedValues[locale.languageCode]?['onboarding_reset_message'] ?? 'Uygulama bir sonraki açılışta tanıtım ekranını gösterecektir.';

  // Language change loading
  String get languageChanging => _localizedValues[locale.languageCode]?['language_changing'] ?? 'Dil Değiştiriliyor...';
  String get languageChangedTo => _localizedValues[locale.languageCode]?['language_changed_to'] ?? 'Dil değiştirildi';
  String get languageChangedToTurkish => 'Dil Türkçe olarak değiştirildi';
  String get languageChangedToEnglish => 'The language has been changed to English';

  // Student Home
  String get todaysGoals => _localizedValues[locale.languageCode]?['todays_goals'] ?? 'Bugünkü Hedefler';
  String get activities => _localizedValues[locale.languageCode]?['activities'] ?? 'Aktivite';
  String get games => _localizedValues[locale.languageCode]?['games'] ?? 'Oyunlar';
  String get homework => _localizedValues[locale.languageCode]?['homework'] ?? 'Ödevler';
  String get points => _localizedValues[locale.languageCode]?['points'] ?? 'Puan';
  String get achievements => _localizedValues[locale.languageCode]?['achievements'] ?? 'Başarı';
  String get popularActivities => _localizedValues[locale.languageCode]?['popular_activities'] ?? 'Popüler Aktiviteler';
  String get robotMovementGame => _localizedValues[locale.languageCode]?['robot_movement_game'] ?? 'Robot Hareket Oyunu';
  String get educationalGame => _localizedValues[locale.languageCode]?['educational_game'] ?? 'Eğitici oyun';
  String get arduinoSimulator => _localizedValues[locale.languageCode]?['arduino_simulator'] ?? 'Arduino Simülatör';
  String get circuitDesign => _localizedValues[locale.languageCode]?['circuit_design'] ?? 'Devre tasarımı';
  String get myHomework => _localizedValues[locale.languageCode]?['my_homework'] ?? 'Ödevlerim';
  String get currentHomework => _localizedValues[locale.languageCode]?['current_homework'] ?? 'Güncel ödevler';
  String get devAiChat => _localizedValues[locale.languageCode]?['dev_ai_chat'] ?? 'DevAiChat';
  String get aiAssistant => _localizedValues[locale.languageCode]?['ai_assistant'] ?? 'Yapay zeka asistan';
  String get millionaireGame => _localizedValues[locale.languageCode]?['millionaire_game'] ?? 'Kim Milyoner Olmak İster?';
  String get quizGame => _localizedValues[locale.languageCode]?['quiz_game'] ?? 'Bilgi yarışması';
  String get worksheets => _localizedValues[locale.languageCode]?['worksheets'] ?? 'Çalışma Kağıtları';
  String get aiRoboticsCoding => _localizedValues[locale.languageCode]?['ai_robotics_coding'] ?? 'AI, Robotik, Kodlama';
  String get learningScore => _localizedValues[locale.languageCode]?['learning_score'] ?? 'Öğrenme Skoru';
  String get greatProgress => _localizedValues[locale.languageCode]?['great_progress'] ?? 'Harika gidiyorsun! Hedefine ulaşmak için devam et.';

  // Profile Screen
  String get inactive => _localizedValues[locale.languageCode]?['inactive'] ?? 'Pasif';
  String get active => _localizedValues[locale.languageCode]?['active'] ?? 'Aktif';
  String get visitor => _localizedValues[locale.languageCode]?['visitor'] ?? 'Ziyaretçi';
  String get student => _localizedValues[locale.languageCode]?['student'] ?? 'Öğrenci';
  String get teacher => _localizedValues[locale.languageCode]?['teacher'] ?? 'Öğretmen';
  String get parent => _localizedValues[locale.languageCode]?['parent'] ?? 'Veli';
  String get admin => _localizedValues[locale.languageCode]?['admin'] ?? 'Admin';
  String get login => _localizedValues[locale.languageCode]?['login'] ?? 'Giriş Yap';
  String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Çıkış Yap';
  String get register => _localizedValues[locale.languageCode]?['register'] ?? 'Kayıt Ol';
  String get loggingOut => _localizedValues[locale.languageCode]?['logging_out'] ?? 'Çıkış yapılıyor...';
  String get logoutConfirmation => _localizedValues[locale.languageCode]?['logout_confirmation'] ?? 'Çıkış yapmak istediğinizden emin misiniz?';
  String get loginToAccessFeatures => _localizedValues[locale.languageCode]?['login_to_access_features'] ?? 'Tüm özelliklere erişmek için giriş yapın';
  String get howWouldYouLikeToUseDevkom => _localizedValues[locale.languageCode]?['how_would_you_like_to_use_devkom'] ?? 'DEVKOM\'u nasıl kullanmak istiyorsunuz?';
  String get selectYourPurpose => _localizedValues[locale.languageCode]?['select_your_purpose'] ?? 'Amacınızı seçin';
  String get toLearn => _localizedValues[locale.languageCode]?['to_learn'] ?? 'Öğrenmek için';
  String get toLearnDescription => _localizedValues[locale.languageCode]?['to_learn_description'] ?? 'Kodlama, robotik ve yapay zeka öğrenmek istiyorum';
  String get trackMyChild => _localizedValues[locale.languageCode]?['track_my_child'] ?? 'Çocuğumun gelişimini takip etmek için';
  String get trackMyChildDescription => _localizedValues[locale.languageCode]?['track_my_child_description'] ?? 'Çocuğumun eğitim sürecini takip etmek istiyorum';
  String get fullAccessContinues => _localizedValues[locale.languageCode]?['full_access_continues'] ?? 'Tüm içeriklere erişim devam eder';
  String get canChangeInSettings => _localizedValues[locale.languageCode]?['can_change_in_settings'] ?? 'Daha sonra profil ayarlarından değiştirebilirsiniz';

  // Drawer menu items
  String get schedule => _localizedValues[locale.languageCode]?['schedule'] ?? 'Ders Programı';
  String get attendance => _localizedValues[locale.languageCode]?['attendance'] ?? 'Devamsızlık';
  String get curriculum => _localizedValues[locale.languageCode]?['curriculum'] ?? 'Müfredat';
  String get agenda => _localizedValues[locale.languageCode]?['agenda'] ?? 'Ajanda';
  String get achievementAnalysis => _localizedValues[locale.languageCode]?['achievement_analysis'] ?? 'Kazanım Analizleri';
  String get surveys => _localizedValues[locale.languageCode]?['surveys'] ?? 'Anketler';
  String get logoutError => _localizedValues[locale.languageCode]?['logout_error'] ?? 'Çıkış yapılırken hata oluştu';

  // Onboarding
  String get alreadyHaveAccount => _localizedValues[locale.languageCode]?['already_have_account'] ?? 'Zaten hesabım var';
  String get skip => _localizedValues[locale.languageCode]?['skip'] ?? 'Atla';
  String get createFreeAccount => _localizedValues[locale.languageCode]?['create_free_account'] ?? 'Ücretsiz Hesap Oluştur';
  String get freeSignUp => _localizedValues[locale.languageCode]?['free_sign_up'] ?? 'Ücretsiz Kayıt Ol';
  String get saveProgressMessage => _localizedValues[locale.languageCode]?['save_progress_message'] ?? 'İlerlemenizi kaydedin ve tüm özelliklere erişin';
  String get letsGetStarted => _localizedValues[locale.languageCode]?['lets_get_started'] ?? 'Başlayalım';

  // Profile Screen - Additional
  String get email => _localizedValues[locale.languageCode]?['email'] ?? 'E-posta';
  String get role => _localizedValues[locale.languageCode]?['role'] ?? 'Rol';
  String get liveCameraAccess => _localizedValues[locale.languageCode]?['live_camera_access'] ?? 'Canlı Kamera Erişimi';
  String get accountInfo => _localizedValues[locale.languageCode]?['account_info'] ?? 'Hesap Bilgileri';
  String get accessInfo => _localizedValues[locale.languageCode]?['access_info'] ?? 'Erişim Bilgileri';
  String get fullName => _localizedValues[locale.languageCode]?['full_name'] ?? 'Ad Soyad';
  String get status => _localizedValues[locale.languageCode]?['status'] ?? 'Durum';
  String get memberSince => _localizedValues[locale.languageCode]?['member_since'] ?? 'Üyelik Tarihi';

  // Schedule Screen
  String get weeklySchedule => _localizedValues[locale.languageCode]?['weekly_schedule'] ?? 'Haftalık ders programınız burada görüntülenecek';

  // Attendance Screen
  String get attendanceTracking => _localizedValues[locale.languageCode]?['attendance_tracking'] ?? 'Devamsızlık Takibi';
  String get attendanceInfo => _localizedValues[locale.languageCode]?['attendance_info'] ?? 'Devamsızlık bilgileriniz burada görüntülenecek';

  // Curriculum Screen
  String get curriculumInfo => _localizedValues[locale.languageCode]?['curriculum_info'] ?? 'Ders müfredatı ve konular burada görüntülenecek';

  // Agenda Screen
  String get pleaseLogin => _localizedValues[locale.languageCode]?['please_login'] ?? 'Lütfen giriş yapın';
  String get error => _localizedValues[locale.languageCode]?['error'] ?? 'Hata';
  String get noEventsOnThisDate => _localizedValues[locale.languageCode]?['no_events_on_this_date'] ?? 'Bu tarihte etkinlik yok';
  String get deleteEvent => _localizedValues[locale.languageCode]?['delete_event'] ?? 'Etkinliği Sil';
  String get deleteEventConfirmation => _localizedValues[locale.languageCode]?['delete_event_confirmation'] ?? 'etkinliğini silmek istediğinizden emin misiniz?';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'Sil';
  String get deleted => _localizedValues[locale.languageCode]?['deleted'] ?? 'silindi';
  String get addEvent => _localizedValues[locale.languageCode]?['add_event'] ?? 'Etkinlik Ekle';
  String get title => _localizedValues[locale.languageCode]?['title'] ?? 'Başlık';
  String get description => _localizedValues[locale.languageCode]?['description'] ?? 'Açıklama';
  String get descriptionOptional => _localizedValues[locale.languageCode]?['description_optional'] ?? 'Açıklama (Opsiyonel)';
  String get type => _localizedValues[locale.languageCode]?['type'] ?? 'Tür';
  String get note => _localizedValues[locale.languageCode]?['note'] ?? 'Not';
  String get reminder => _localizedValues[locale.languageCode]?['reminder'] ?? 'Hatırlatıcı';
  String get task => _localizedValues[locale.languageCode]?['task'] ?? 'Görev';
  String get add => _localizedValues[locale.languageCode]?['add'] ?? 'Ekle';
  String get pleasEnterTitle => _localizedValues[locale.languageCode]?['please_enter_title'] ?? 'Lütfen bir başlık girin';
  String get eventAdded => _localizedValues[locale.languageCode]?['event_added'] ?? 'Etkinlik eklendi!';

  // Day names (short)
  String get monday => _localizedValues[locale.languageCode]?['monday'] ?? 'Pzt';
  String get tuesday => _localizedValues[locale.languageCode]?['tuesday'] ?? 'Sal';
  String get wednesday => _localizedValues[locale.languageCode]?['wednesday'] ?? 'Çar';
  String get thursday => _localizedValues[locale.languageCode]?['thursday'] ?? 'Per';
  String get friday => _localizedValues[locale.languageCode]?['friday'] ?? 'Cum';
  String get saturday => _localizedValues[locale.languageCode]?['saturday'] ?? 'Cmt';
  String get sunday => _localizedValues[locale.languageCode]?['sunday'] ?? 'Paz';

  // Achievement Analysis Screen
  String get noGamesPlayed => _localizedValues[locale.languageCode]?['no_games_played'] ?? 'Henüz Oyun Oynamamışsınız';
  String get playGamesMessage => _localizedValues[locale.languageCode]?['play_games_message'] ?? 'Oyunlar bölümünden oyun oynayarak\nistatistiklerinizi görüntüleyebilirsiniz';
  String get overallSuccess => _localizedValues[locale.languageCode]?['overall_success'] ?? 'Genel Başarı Durumu';
  String get totalGames => _localizedValues[locale.languageCode]?['total_games'] ?? 'Toplam Oyun';
  String get correct => _localizedValues[locale.languageCode]?['correct'] ?? 'Doğru';
  String get wrong => _localizedValues[locale.languageCode]?['wrong'] ?? 'Yanlış';
  String get gameBasedPerformance => _localizedValues[locale.languageCode]?['game_based_performance'] ?? 'Oyun Bazlı Performans';
  String get timesPlayed => _localizedValues[locale.languageCode]?['times_played'] ?? 'kez oynandı';
  String get loadingDataError => _localizedValues[locale.languageCode]?['loading_data_error'] ?? 'Veri yüklenirken hata oluştu';

  // Surveys Screen
  String get surveysInfo => _localizedValues[locale.languageCode]?['surveys_info'] ?? 'Katılabileceğiniz anketler burada görüntülenecek';

  // SwipeWelcomeScreen
  String get swipeToStart => _localizedValues[locale.languageCode]?['swipe_to_start'] ?? 'Başlamak için kaydır';
  String get smartEducationPlatform => _localizedValues[locale.languageCode]?['smart_education_platform'] ?? 'AI • Robotik • Kodlama • Yazılım';

  // WelcomeScreen
  String get softwareRoboticsEducation => _localizedValues[locale.languageCode]?['software_robotics_education'] ?? 'Yazılım ve Robotik\nEğitim Platformu';
  String get explore => _localizedValues[locale.languageCode]?['explore'] ?? 'Keşfet';
  String get continueWithLogin => _localizedValues[locale.languageCode]?['continue_with_login'] ?? 'Giriş Yaparak Devam Et';
  String get robotics => _localizedValues[locale.languageCode]?['robotics'] ?? 'Robotik';
  String get coding => _localizedValues[locale.languageCode]?['coding'] ?? 'Kodlama';
  String get chess => _localizedValues[locale.languageCode]?['chess'] ?? 'Satranç';

  // LoginScreen
  String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Şifre';
  String get emailHint => _localizedValues[locale.languageCode]?['email_hint'] ?? 'ornek@email.com';
  String get pleaseEnterEmail => _localizedValues[locale.languageCode]?['please_enter_email'] ?? 'Lütfen e-posta adresinizi girin';
  String get enterValidEmail => _localizedValues[locale.languageCode]?['enter_valid_email'] ?? 'Geçerli bir e-posta adresi girin';
  String get pleaseEnterPassword => _localizedValues[locale.languageCode]?['please_enter_password'] ?? 'Lütfen şifrenizi girin';
  String get passwordMinLength => _localizedValues[locale.languageCode]?['password_min_length'] ?? 'Şifre en az 6 karakter olmalıdır';
  String get noAccount => _localizedValues[locale.languageCode]?['no_account'] ?? 'Hesabınız yok mu?';

  // RegisterScreen
  String get createNewAccount => _localizedValues[locale.languageCode]?['create_new_account'] ?? 'Yeni Hesap Oluştur';
  String get nameHint => _localizedValues[locale.languageCode]?['name_hint'] ?? 'Adınız ve Soyadınız';
  String get pleaseEnterName => _localizedValues[locale.languageCode]?['please_enter_name'] ?? 'Lütfen adınızı ve soyadınızı girin';
  String get nameMinLength => _localizedValues[locale.languageCode]?['name_min_length'] ?? 'Ad en az 3 karakter olmalıdır';
  String get passwordConfirm => _localizedValues[locale.languageCode]?['password_confirm'] ?? 'Şifre Tekrar';
  String get pleaseConfirmPassword => _localizedValues[locale.languageCode]?['please_confirm_password'] ?? 'Lütfen şifrenizi tekrar girin';
  String get passwordsDoNotMatch => _localizedValues[locale.languageCode]?['passwords_do_not_match'] ?? 'Şifreler eşleşmiyor';
  String get accountType => _localizedValues[locale.languageCode]?['account_type'] ?? 'Hesap Tipi';
  String get parentWithCamera => _localizedValues[locale.languageCode]?['parent_with_camera'] ?? 'Canlı kamera erişimi dahil';
  String get studentAccess => _localizedValues[locale.languageCode]?['student_access'] ?? 'Oyunlar ve ödevlere erişim';
  String get teacherAccess => _localizedValues[locale.languageCode]?['teacher_access'] ?? 'Müfredat ve ödev yönetimi';
  String get visitorAccess => _localizedValues[locale.languageCode]?['visitor_access'] ?? 'Genel içerik erişimi';
  String get registrationSuccess => _localizedValues[locale.languageCode]?['registration_success'] ?? 'Kayıt başarılı! Hoş geldiniz.';
  String get alreadyHaveAccountQuestion => _localizedValues[locale.languageCode]?['already_have_account_question'] ?? 'Zaten hesabınız var mı?';

  // OnboardingScreen
  String get onboarding1Title => _localizedValues[locale.languageCode]?['onboarding1_title'] ?? 'Güvenilir Eğitim Platformu';
  String get onboarding1Description => _localizedValues[locale.languageCode]?['onboarding1_description'] ?? 'DEVKOM ile çocuklarınız güvenli bir ortamda, uzman eğitmenler eşliğinde robotik ve yazılım öğrenir. Her adımı takip edin, gelişimlerini izleyin.';
  String get onboarding2Title => _localizedValues[locale.languageCode]?['onboarding2_title'] ?? 'Kapsamlı Müfredat';
  String get onboarding2Description => _localizedValues[locale.languageCode]?['onboarding2_description'] ?? 'MEB onaylı müfredat ile uyumlu, yaş gruplarına özel tasarlanmış eğitim programları. Arduino, Python, Scratch ve daha fazlası profesyonel eğitmenlerle.';
  String get onboarding3Title => _localizedValues[locale.languageCode]?['onboarding3_title'] ?? 'Gelişimi Anlık Takip';
  String get onboarding3Description => _localizedValues[locale.languageCode]?['onboarding3_description'] ?? 'Öğrenci ilerleme raporları, başarı rozetleri ve detaylı analizlerle çocuğunuzun gelişimini her an izleyin. Veli paneli ile tam kontrol.';

  // ProfileScreen
  String get userInfoLoadError => _localizedValues[locale.languageCode]?['user_info_load_error'] ?? 'Kullanıcı bilgileri yüklenemedi';
  String get lastLogin => _localizedValues[locale.languageCode]?['last_login'] ?? 'Son Giriş';
  String get alreadyHaveAccountLogin => _localizedValues[locale.languageCode]?['already_have_account_login'] ?? 'Zaten Hesabım Var';
  String get logoutErrorMessage => _localizedValues[locale.languageCode]?['logout_error_message'] ?? 'Çıkış yapılırken hata oluştu';

  // Social Feed Strings
  String get createPost => _localizedValues[locale.languageCode]?['create_post'] ?? 'Gönderi Oluştur';
  String get addImages => _localizedValues[locale.languageCode]?['add_images'] ?? 'Resim Ekle';
  String get addPDF => _localizedValues[locale.languageCode]?['add_pdf'] ?? 'PDF Ekle';
  String get addLink => _localizedValues[locale.languageCode]?['add_link'] ?? 'Link Ekle';
  String get whatOnYourMind => _localizedValues[locale.languageCode]?['what_on_your_mind'] ?? 'Aklında ne var?';
  String get postsRemaining => _localizedValues[locale.languageCode]?['posts_remaining'] ?? 'gönderi hakkı kaldı';
  String get unlimitedPosts => _localizedValues[locale.languageCode]?['unlimited_posts'] ?? 'Sınırsız gönderi';
  String get dailyLimitReached => _localizedValues[locale.languageCode]?['daily_limit_reached'] ?? 'Günlük gönderi limitine ulaşıldı';
  String get like => _localizedValues[locale.languageCode]?['like'] ?? 'Beğen';
  String get comment => _localizedValues[locale.languageCode]?['comment'] ?? 'Yorum';
  String get share => _localizedValues[locale.languageCode]?['share'] ?? 'Paylaş';
  String get report => _localizedValues[locale.languageCode]?['report'] ?? 'Bildir';
  String get viewingAsGuest => _localizedValues[locale.languageCode]?['viewing_as_guest'] ?? 'Misafir olarak görüntüleniyor';
  String get loginToComment => _localizedValues[locale.languageCode]?['login_to_comment'] ?? 'Yorum yapmak için giriş yapın';
  String get postCreatedSuccessfully => _localizedValues[locale.languageCode]?['post_created_successfully'] ?? 'Gönderi başarıyla oluşturuldu';
  String get postDeleted => _localizedValues[locale.languageCode]?['post_deleted'] ?? 'Gönderi silindi';
  String get confirmDelete => _localizedValues[locale.languageCode]?['confirm_delete'] ?? 'Silmek istediğinizden emin misiniz?';
  String get noPostsYet => _localizedValues[locale.languageCode]?['no_posts_yet'] ?? 'Henüz gönderi yok';
  String get beFirstToPost => _localizedValues[locale.languageCode]?['be_first_to_post'] ?? 'İlk gönderiyi siz paylaşın!';
  String get trending => _localizedValues[locale.languageCode]?['trending'] ?? 'Trendler';
  String get aiAndRobotics => _localizedValues[locale.languageCode]?['ai_and_robotics'] ?? 'AI & Robotik';
  String get funny => _localizedValues[locale.languageCode]?['funny'] ?? 'Eğlenceli';
  String get all => _localizedValues[locale.languageCode]?['all'] ?? 'Tümü';
  String get comments => _localizedValues[locale.languageCode]?['comments'] ?? 'Yorumlar';
  String get noCommentsYet => _localizedValues[locale.languageCode]?['no_comments_yet'] ?? 'Henüz yorum yok';
  String get addComment => _localizedValues[locale.languageCode]?['add_comment'] ?? 'Yorum ekle...';
  String get postDetails => _localizedValues[locale.languageCode]?['post_details'] ?? 'Gönderi Detayları';
  String get postNotFound => _localizedValues[locale.languageCode]?['post_not_found'] ?? 'Gönderi bulunamadı';

  // Enhanced Feed Screen
  String get filterTrending => _localizedValues[locale.languageCode]?['filter_trending'] ?? 'Trendler';
  String get filterAiRobotics => _localizedValues[locale.languageCode]?['filter_ai_robotics'] ?? 'AI & Robotik';
  String get filterCoding => _localizedValues[locale.languageCode]?['filter_coding'] ?? 'Kodlama';
  String get filterFunny => _localizedValues[locale.languageCode]?['filter_funny'] ?? 'Eğlenceli';
  String get filterAll => _localizedValues[locale.languageCode]?['filter_all'] ?? 'Tümü';
  String get viewingAsGuestLogin => _localizedValues[locale.languageCode]?['viewing_as_guest_login'] ?? 'Misafir olarak görüntüleniyor - Etkileşim için giriş yapın';
  String get errorLoadingPosts => _localizedValues[locale.languageCode]?['error_loading_posts'] ?? 'Gönderiler yüklenirken hata oluştu';
  String get beFirstToShareAmazing => _localizedValues[locale.languageCode]?['be_first_to_share_amazing'] ?? 'İlk harika paylaşımı siz yapın!';
  String get loginToCommentLock => _localizedValues[locale.languageCode]?['login_to_comment_lock'] ?? '🔒 Yorum yapmak için giriş yapın';
  String get shareFunctionalityComingSoon => _localizedValues[locale.languageCode]?['share_functionality_coming_soon'] ?? 'Paylaşım özelliği yakında geliyor!';
  String get deletePost => _localizedValues[locale.languageCode]?['delete_post'] ?? 'Gönderiyi Sil';
  String get deletePostConfirmation => _localizedValues[locale.languageCode]?['delete_post_confirmation'] ?? 'Bu gönderiyi silmek istediğinizden emin misiniz?';
  String get postDeletedSuccessfully => _localizedValues[locale.languageCode]?['post_deleted_successfully'] ?? 'Gönderi başarıyla silindi';
  String get errorDeletingPost => _localizedValues[locale.languageCode]?['error_deleting_post'] ?? 'Gönderi silinirken hata oluştu';
  String get pdfDocument => _localizedValues[locale.languageCode]?['pdf_document'] ?? 'PDF Belgesi';
  String get tapToView => _localizedValues[locale.languageCode]?['tap_to_view'] ?? 'Görüntülemek için dokun';
  String get likes => _localizedValues[locale.languageCode]?['likes'] ?? 'beğeni';

  // Create Post Screen
  String get dailyLimitReachedUpgrade => _localizedValues[locale.languageCode]?['daily_limit_reached_upgrade'] ?? 'Günlük gönderi limitine ulaşıldı. Sınırsız gönderi için Pro sürüme geçin!';
  String get failedToCreatePost => _localizedValues[locale.languageCode]?['failed_to_create_post'] ?? 'Gönderi oluşturulamadı';
  String get postsRemainingToday => _localizedValues[locale.languageCode]?['posts_remaining_today'] ?? 'bugün gönderi hakkı kaldı';
  String get dailyLimitReachedUpgradePro => _localizedValues[locale.languageCode]?['daily_limit_reached_upgrade_pro'] ?? 'Günlük limit doldu! Sınırsız gönderi için Pro\'ya geçin';
  String get proUnlimitedPosts => _localizedValues[locale.languageCode]?['pro_unlimited_posts'] ?? 'PRO: Sınırsız gönderi';
  String get whatOnYourMindRocket => _localizedValues[locale.languageCode]?['what_on_your_mind_rocket'] ?? 'Aklında ne var? 🚀';
  String get addLinkOptional => _localizedValues[locale.languageCode]?['add_link_optional'] ?? '🔗 Link ekle (opsiyonel)';
  String get selectedImages => _localizedValues[locale.languageCode]?['selected_images'] ?? '📸 Seçilen Resimler';
  String get pdfAttached => _localizedValues[locale.languageCode]?['pdf_attached'] ?? 'PDF Eklendi';
  String get images => _localizedValues[locale.languageCode]?['images'] ?? 'Resimler';
  String get pdf => _localizedValues[locale.languageCode]?['pdf'] ?? 'PDF';
  String get post => _localizedValues[locale.languageCode]?['post'] ?? 'Paylaş';

  // Post Detail Screen
  String get pleaseLoginToComment => _localizedValues[locale.languageCode]?['please_login_to_comment'] ?? 'Yorum yapmak için lütfen giriş yapın';
  String get errorPostingComment => _localizedValues[locale.languageCode]?['error_posting_comment'] ?? 'Yorum gönderilirken hata oluştu';
  String get beFirstToComment => _localizedValues[locale.languageCode]?['be_first_to_comment'] ?? 'İlk yorumu siz yapın!';
  String get addCommentEllipsis => _localizedValues[locale.languageCode]?['add_comment_ellipsis'] ?? 'Yorum ekle...';
  String get loginToCommentLockDetail => _localizedValues[locale.languageCode]?['login_to_comment_lock_detail'] ?? '🔒 Yorum yapmak için giriş yapın';

  static const Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      'app_name': 'Devkom App',
      'welcome': 'Hoşgeldiniz',
      'settings': 'Ayarlar',
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
      'reset_confirmation': 'Tüm ayarlar varsayılan değerlere sıfırlanacak. Emin misiniz?',
      'reset': 'Sıfırla',
      'settings_reset_success': 'Ayarlar varsayılan değerlere sıfırlandı',
      'app_description': 'Robotik ve kodlama eğitimi için geliştirilmiş bir platformdur.',
      'ok': 'Tamam',
      'app_experience': 'Uygulama Deneyimi',
      'show_onboarding_again': 'Tanıtımı Tekrar Göster',
      'onboarding_will_show': 'Uygulama yeniden başlatıldığında tanıtım ekranı gösterilecek',
      'onboarding_reset': 'Tanıtım Sıfırlandı',
      'onboarding_reset_message': 'Uygulama bir sonraki açılışta tanıtım ekranını gösterecektir.',
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
      'dev_ai_chat': 'DevAiChat',
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
      'how_would_you_like_to_use_devkom': 'DEVKOM\'u nasıl kullanmak istiyorsunuz?',
      'select_your_purpose': 'Amacınızı seçin',
      'to_learn': 'Öğrenmek için',
      'to_learn_description': 'Kodlama, robotik ve yapay zeka öğrenmek istiyorum',
      'track_my_child': 'Çocuğumun gelişimini takip etmek için',
      'track_my_child_description': 'Çocuğumun eğitim sürecini takip etmek istiyorum',
      'full_access_continues': 'Tüm içeriklere erişim devam eder',
      'can_change_in_settings': 'Daha sonra profil ayarlarından değiştirebilirsiniz',
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
      'save_progress_message': 'İlerlemenizi kaydedin ve tüm özelliklere erişin',
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
      'delete_event_confirmation': 'etkinliğini silmek istediğinizden emin misiniz?',
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
      'play_games_message': 'Oyunlar bölümünden oyun oynayarak\nistatistiklerinizi görüntüleyebilirsiniz',
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
      'onboarding1_description': 'DEVKOM ile çocuklarınız güvenli bir ortamda, uzman eğitmenler eşliğinde robotik ve yazılım öğrenir. Her adımı takip edin, gelişimlerini izleyin.',
      'onboarding2_title': 'Kapsamlı Müfredat',
      'onboarding2_description': 'MEB onaylı müfredat ile uyumlu, yaş gruplarına özel tasarlanmış eğitim programları. Arduino, Python, Scratch ve daha fazlası profesyonel eğitmenlerle.',
      'onboarding3_title': 'Gelişimi Anlık Takip',
      'onboarding3_description': 'Öğrenci ilerleme raporları, başarı rozetleri ve detaylı analizlerle çocuğunuzun gelişimini her an izleyin. Veli paneli ile tam kontrol.',
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
      'viewing_as_guest_login': 'Misafir olarak görüntüleniyor - Etkileşim için giriş yapın',
      'error_loading_posts': 'Gönderiler yüklenirken hata oluştu',
      'be_first_to_share_amazing': 'İlk harika paylaşımı siz yapın!',
      'login_to_comment_lock': '🔒 Yorum yapmak için giriş yapın',
      'share_functionality_coming_soon': 'Paylaşım özelliği yakında geliyor!',
      'delete_post': 'Gönderiyi Sil',
      'delete_post_confirmation': 'Bu gönderiyi silmek istediğinizden emin misiniz?',
      'post_deleted_successfully': 'Gönderi başarıyla silindi',
      'error_deleting_post': 'Gönderi silinirken hata oluştu',
      'pdf_document': 'PDF Belgesi',
      'tap_to_view': 'Görüntülemek için dokun',
      'likes': 'beğeni',

      // Create Post Screen
      'daily_limit_reached_upgrade': 'Günlük gönderi limitine ulaşıldı. Sınırsız gönderi için Pro sürüme geçin!',
      'failed_to_create_post': 'Gönderi oluşturulamadı',
      'posts_remaining_today': 'bugün gönderi hakkı kaldı',
      'daily_limit_reached_upgrade_pro': 'Günlük limit doldu! Sınırsız gönderi için Pro\'ya geçin',
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
      'app_name': 'Devkom App',
      'welcome': 'Welcome',
      'settings': 'Settings',
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
      'reset_confirmation': 'All settings will be reset to default values. Are you sure?',
      'reset': 'Reset',
      'settings_reset_success': 'Settings have been reset to default values',
      'app_description': 'A platform developed for robotics and coding education.',
      'ok': 'OK',
      'app_experience': 'App Experience',
      'show_onboarding_again': 'Show Onboarding Again',
      'onboarding_will_show': 'Onboarding screen will be shown when app restarts',
      'onboarding_reset': 'Onboarding Reset',
      'onboarding_reset_message': 'Onboarding screen will be shown on next app launch.',
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
      'dev_ai_chat': 'DevAiChat',
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
      'how_would_you_like_to_use_devkom': 'How would you like to use DEVKOM?',
      'select_your_purpose': 'Select your purpose',
      'to_learn': 'To Learn',
      'to_learn_description': 'I want to learn coding, robotics and AI',
      'track_my_child': 'Track My Child\'s Progress',
      'track_my_child_description': 'I want to follow my child\'s educational journey',
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
      'play_games_message': 'Play games from the Games section\nto view your statistics',
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
      'onboarding1_description': 'With DEVKOM, your children learn robotics and software in a safe environment with expert instructors. Track every step and monitor their progress.',
      'onboarding2_title': 'Comprehensive Curriculum',
      'onboarding2_description': 'Education programs compatible with approved curriculum, specially designed for age groups. Arduino, Python, Scratch and more with professional instructors.',
      'onboarding3_title': 'Real-Time Progress Tracking',
      'onboarding3_description': 'Track your child\'s progress at all times with student progress reports, achievement badges and detailed analyses. Full control with parent panel.',
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
      'daily_limit_reached_upgrade': 'Daily post limit reached. Upgrade to Pro for unlimited posts!',
      'failed_to_create_post': 'Failed to create post',
      'posts_remaining_today': 'posts remaining today',
      'daily_limit_reached_upgrade_pro': 'Daily limit reached! Upgrade to Pro for unlimited posts',
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
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['tr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
