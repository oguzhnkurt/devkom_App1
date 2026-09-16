import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'core/service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth/modern_splash_screen.dart';
import 'services/local_notification_service.dart';
import 'services/connectivity_service.dart';
import 'services/score_cache_service.dart';
import 'services/ad_navigator_observer.dart';
import 'services/ads_service.dart';
import 'services/subscription_service.dart';
import 'theme.dart';
import 'utils/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tarih adlarini (ay/gun) tum desteklenen dillerde yukle. Bu yapilmazsa
  // DateFormat yalnizca en_US biliyor ve 'tr'/'de'/'es' istegi hata atiyor.
  await initializeDateFormatting();

  // Uygulama yalnizca dikey calisir. Cocuklara yonelik ekranlarin tamami
  // dikey tasarlandi; yatay modda kartlar ve karakter sahnesi bozuluyordu.
  // Video oynaticinin tam ekran butonu da cihazi yatira birakip geri
  // dondurmedigi icin uygulama yan kaliyordu - bkz. YouTubePlayerWidget.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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

  } catch (e) {
    debugPrint('⚠️ Some services failed to initialize: $e');
    debugPrint('App will continue with limited functionality');
  }

  // REKLAM SERVISI KENDI TRY'INDA.
  //
  // Eskiden yukaridaki blogun EN SONUNDAYDI: ondan once calisan
  // bildirim, baglanti, skor onbellegi ya da abonelik servislerinden
  // biri hata firlatirsa reklam servisi HIC baslatilmiyordu. Yani
  // yayinda reklamlarin gelmemesi, reklamla ilgisi olmayan bir hataya
  // bagli olabiliyordu — ustelik gunlukte yalnizca "Some services
  // failed" yaziyordu.
  //
  // Kimlikler .env'de yoksa servis zaten sessizce kapali kaliyor.
  try {
    await AdsService.instance.initialize();
  } catch (e) {
    debugPrint('⚠️ Reklam servisi baslatilamadi: $e');
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
            title: 'DevEducation',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            locale: settingsProvider.locale,
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
              // Almanca ve Ispanyolca. Bolge kodu VERILMIYOR: 'de_DE'
              // yazsaydik Avusturya ya da Isvicre'deki bir cihaz
              // eslesemez ve Ingilizce'ye duserdi. Ayni sekilde 'es',
              // Ispanya ile Latin Amerika'nin tamamini kapsiyor.
              Locale('de'),
              Locale('es'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Gecis reklami ekran degisiminde gosteriliyor; nedeni
            // AdNavigatorObserver aciklamasinda.
            navigatorObservers: [AdNavigatorObserver()],
            home: const ModernSplashScreen(),
          );
        },
      ),
    );
  }
}
