import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'core/service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/modern_splash_screen.dart';
import 'services/local_notification_service.dart';
import 'services/connectivity_service.dart';
import 'services/score_cache_service.dart';
import 'services/subscription_service.dart';
import 'services/analytics_service.dart';
import 'theme.dart';
import 'utils/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ Environment variables loaded');
  } catch (e) {
    debugPrint('⚠️ Environment variables loading failed: $e');
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      // Production-ready Supabase configuration
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Supabase initialization failed: $e');
    // Critical error - show error screen instead of a blank screen
    runApp(const _StartupErrorApp());
    return;
  }

  // Initialize Service Locator (Dependency Injection)
  try {
    await setupServiceLocator();
    debugPrint('✅ Service locator initialized successfully');
  } catch (e) {
    debugPrint('❌ Service locator initialization failed: $e');
    runApp(const _StartupErrorApp());
    return;
  }

  // Initialize core services
  try {
    // Initialize local notification service
    final localNotificationService = LocalNotificationService();
    await localNotificationService.initialize();
    debugPrint('✅ Local notification service initialized');

    // Initialize connectivity service
    final connectivityService = ConnectivityService();
    await connectivityService.initialize();
    debugPrint('✅ Connectivity service initialized');

    // Initialize score cache service
    final scoreCacheService = ScoreCacheService();
    await scoreCacheService.initialize();
    debugPrint('✅ Score cache service initialized');

    // Initialize subscription service
    final subscriptionService = SubscriptionService();
    await subscriptionService.initialize();
    debugPrint('✅ Subscription service initialized');

    // Initialize analytics service
    final analyticsService = AnalyticsService();
    await analyticsService.initialize();
    debugPrint('✅ Analytics service initialized');
  } catch (e) {
    debugPrint('⚠️ Some services failed to initialize: $e');
    debugPrint('App will continue with limited functionality');
  }

  runApp(const DevkomApp());
}

// Global Supabase accessor
final supabase = Supabase.instance.client;

/// Başlatma hatasında boş ekran yerine gösterilen basit hata ekranı
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Bağlantı kurulamadı',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'İnternet bağlantınızı kontrol edip uygulamayı yeniden başlatın.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DevkomApp extends StatelessWidget {
  const DevkomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Devkom App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            locale: settingsProvider.locale,
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const ModernSplashScreen(),
          );
        },
      ),
    );
  }
}
