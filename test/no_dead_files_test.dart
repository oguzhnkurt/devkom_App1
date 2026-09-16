import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Olu dosya taramasi.
///
/// `lib/main.dart`'tan baslayan import grafigi cikarildiginda 93 dosya
/// hicbir yerden erisilmiyordu: bitmis ya da vazgecilmis ozellikler
/// (sosyal akis, mesajlasma, canli kamera), okul/ogretmen tarafi
/// (odev, mufredat, yoklama, anket), eski acilis ekranlari ve eski
/// Arduino simulatoru. Derlenen uygulamaya zaten girmiyorlardi — mesele
/// boyut degil, her aramada ve her gozden gecirmede one cikmalariydi.
/// Hepsi git gecmisinde duruyor.
///
/// Bu test onlarin geri donmesini degil, **sessizce geri gelmesini**
/// engelliyor: bir dosya gercekten gerekiyorsa bu listeden cikarilir.
void main() {
  const silinenler = [
    'lib/courses/data/courses_data.dart.backup_25courses',
    'lib/courses/screens/scratch_course_screen.dart',
    'lib/courses/screens/widgets/catch_block_game.dart.backup',
    'lib/models/achievement_model.dart',
    'lib/models/agenda_event.dart',
    'lib/models/arduino_block_model.dart',
    'lib/models/camera_model.dart',
    'lib/models/leaderboard_entry.dart',
    'lib/models/lesson_model.dart',
    'lib/models/robotics_features.dart',
    'lib/models/student_model.dart',
    'lib/models/student_portfolio_model.dart',
    'lib/models/support_message_model.dart',
    'lib/models/survey_model.dart',
    'lib/models/team_member.dart',
    'lib/models/weekly_curriculum_model.dart',
    'lib/models/workspace_context.dart',
    'lib/screens/access_denied_screen.dart',
    'lib/screens/arduino_simulator_main_screen.dart',
    'lib/screens/auth/onboarding_screen.dart',
    'lib/screens/auth/premium_onboarding_screen.dart',
    'lib/screens/auth/purpose_selection_screen.dart',
    'lib/screens/auth/swipe_welcome_screen.dart',
    'lib/screens/auth/welcome_screen.dart',
    'lib/screens/games/block_coding_game_screen.dart.backup',
    'lib/screens/games/block_coding_game_screen.dart.broken',
    'lib/screens/homework_screen.dart',
    'lib/screens/lesson_detail_screen.dart',
    'lib/screens/live_camera_screen.dart',
    'lib/screens/math_games_screen.dart',
    'lib/screens/messaging/chat_screen.dart',
    'lib/screens/messaging/conversations_screen.dart.bak',
    'lib/screens/messaging/enhanced_chat_screen.dart',
    'lib/screens/messaging/professional_chat_screen.dart',
    'lib/screens/messaging/select_teacher_screen.dart.bak',
    'lib/screens/parent/curriculum/parent_week_detail_screen.dart',
    'lib/screens/parent/parent_games_screen.dart',
    'lib/screens/parent/update_detail_screen.dart',
    'lib/screens/roboakademi/add_workshop_child_screen.dart',
    'lib/screens/robotics_info_screen.dart',
    'lib/screens/shared/general_curriculum_screen.dart',
    'lib/screens/social/comments_screen.dart',
    'lib/screens/social/create_post_screen.dart',
    'lib/screens/social/create_post_screen_modern.dart',
    'lib/screens/social/enhanced_feed_screen.dart',
    'lib/screens/social/enhanced_feed_screen_v2.dart',
    'lib/screens/social/post_detail_screen.dart',
    'lib/screens/student/achievement_analysis_screen.dart',
    'lib/screens/student/agenda_screen.dart',
    'lib/screens/student/attendance_screen.dart',
    'lib/screens/student/curriculum_screen.dart',
    'lib/screens/student/fix_indent.py',
    'lib/screens/student/schedule_screen.dart',
    'lib/screens/student/surveys_screen.dart',
    'lib/screens/surveys/survey_create_screen.dart',
    'lib/screens/surveys/survey_results_screen.dart',
    'lib/screens/teacher/create_homework_screen.dart',
    'lib/screens/teacher/create_student_screen.dart',
    'lib/screens/worksheet_detail_screen.dart',
    'lib/screens/worksheets_screen.dart',
    'lib/screens/worksheets_screen_old.dart',
    'lib/services/achievement_badge_service.dart',
    'lib/services/agenda_service.dart',
    'lib/services/daily_quest_service.dart',
    'lib/services/feed_service.dart',
    'lib/services/file_upload_service.dart',
    'lib/services/homework_service.dart',
    'lib/services/messaging_service.dart',
    'lib/services/notification_service.dart',
    'lib/services/parent_child_service.dart',
    'lib/services/parent_report_service.dart',
    'lib/services/score_cache_service.dart.broken',
    'lib/services/social_feed_service.dart',
    'lib/services/storage_service.dart',
    'lib/services/student_portfolio_service.dart',
    'lib/services/voice_recording_service.dart',
    'lib/services/weekly_curriculum_service.dart',
    'lib/utils/pro_feature_guard.dart',
    'lib/utils/social_feed_access.dart',
    'lib/widgets/achievements_widget.dart',
    'lib/widgets/animated_gradient_background.dart',
    'lib/widgets/apple_sign_in_button.dart',
    'lib/widgets/blockly_demo_screen.dart.backup',
    'lib/widgets/card_item.dart',
    'lib/widgets/category_selector.dart',
    'lib/widgets/code_playground/command_card.dart',
    'lib/widgets/code_playground/robot_character.dart',
    'lib/widgets/code_playground_screen.dart',
    'lib/widgets/daily_quests_widget.dart',
    'lib/widgets/game_card.dart',
    'lib/widgets/homework_card.dart',
    'lib/widgets/interactive_quiz_widgets.dart',
    'lib/widgets/loading_screen.dart',
    'lib/widgets/progress_indicator_widget.dart',
    'lib/widgets/race_mode_countdown.dart',
    'lib/widgets/skeleton_loader.dart',
    'lib/widgets/slide_to_start.dart',
    'lib/widgets/video_background_slider.dart',
    'lib/widgets/visitor_cta_widget.dart',
    'lib/widgets/walking_cat_widget.dart',
    'lib/widgets/webrtc_camera_player.dart',
    'lib/widgets/xp_progress_card.dart',
  ];

  test('silinen olu dosyalar geri gelmemis', () {
    final geriGelen = silinenler.where((p) => File(p).existsSync()).toList();
    expect(geriGelen, isEmpty,
        reason: 'bu dosyalar olu oldugu icin silinmisti');
  });

  test('chess_ai_web_stub silinmedi', () {
    // Kosullu import ile geliyor (`if (dart.library.js)`), grafik
    // taramasinda olu gorunuyor ama web derlemesinde gerekli.
    expect(File('lib/services/chess_ai_web_stub.dart').existsSync(), isTrue);
  });
}
