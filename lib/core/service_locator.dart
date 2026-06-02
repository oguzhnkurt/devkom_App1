import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_service_supabase.dart';
import '../services/messaging_service_supabase.dart';
import '../services/social_feed_service_supabase.dart';
import '../services/feed_service_supabase.dart';
import '../services/homework_service_supabase.dart';
import '../services/games_service_supabase.dart';
import '../services/leaderboard_service_supabase.dart';
import '../services/daily_quest_service_supabase.dart';
import '../services/presence_service.dart';
import 'error_handler.dart';
import 'cache_manager.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton(() => ErrorHandler());
  getIt.registerLazySingleton(() => CacheManager());
  getIt.registerLazySingleton(() => AuthServiceSupabase());
  getIt.registerLazySingleton(() => MessagingServiceSupabase());
  getIt.registerLazySingleton(() => SocialFeedServiceSupabase());
  getIt.registerLazySingleton(() => FeedServiceSupabase());
  getIt.registerLazySingleton(() => HomeworkServiceSupabase());
  getIt.registerLazySingleton(() => GamesServiceSupabase());
  getIt.registerLazySingleton(() => LeaderboardServiceSupabase());
  getIt.registerLazySingleton(() => DailyQuestServiceSupabase());
  getIt.registerLazySingleton(() => PresenceService());
  debugPrint('✅ Service locator initialized with all services');
}

AuthServiceSupabase get authService => getIt<AuthServiceSupabase>();
MessagingServiceSupabase get messagingService => getIt<MessagingServiceSupabase>();
SocialFeedServiceSupabase get socialFeedService => getIt<SocialFeedServiceSupabase>();
FeedServiceSupabase get feedService => getIt<FeedServiceSupabase>();
HomeworkServiceSupabase get homeworkService => getIt<HomeworkServiceSupabase>();
GamesServiceSupabase get gamesService => getIt<GamesServiceSupabase>();
LeaderboardServiceSupabase get leaderboardService => getIt<LeaderboardServiceSupabase>();
DailyQuestServiceSupabase get dailyQuestService => getIt<DailyQuestServiceSupabase>();
PresenceService get presenceService => getIt<PresenceService>();
ErrorHandler get errorHandler => getIt<ErrorHandler>();
CacheManager get cacheManager => getIt<CacheManager>();
