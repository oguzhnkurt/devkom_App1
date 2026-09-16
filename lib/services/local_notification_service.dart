import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _initialized = true;
      debugPrint('Local notification service initialized');
    } catch (e) {
      debugPrint('Failed to initialize local notifications: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Request notification permissions (call this when user wants notifications)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    try {
      // Android 13+
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        debugPrint('Android notification permission: $granted');
        return granted ?? false;
      }

      // For iOS, permissions are handled through DarwinInitializationSettings
      // Return true for platforms other than Android 13+
      return true;
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
      return false;
    }
  }

  /// Schedule a notification for agenda reminder
  /// Will notify 24 hours before the event
  Future<void> scheduleAgendaReminder({
    required int id,
    required String title,
    required String description,
    required DateTime eventDate,
  }) async {
    if (!_initialized) await initialize();

    try {
      // Calculate notification time (24 hours before event)
      final DateTime notificationTime = eventDate.subtract(const Duration(hours: 24));

      // Don't schedule if the time has already passed
      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint('Notification time has passed, not scheduling');
        return;
      }

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

      // Android notification details
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'agenda_reminders',
        'Ajanda Hatirlaticilari',
        channelDescription: 'Ajanda etkinlikleri için hatirlaticilar',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Yarın: $title',
        description.isEmpty ? 'Ajanda etkinliginiz yaklasiyor' : description,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'agenda_$id',
      );

      debugPrint('Scheduled agenda reminder for $eventDate at $scheduledDate');
    } catch (e) {
      debugPrint('Failed to schedule agenda reminder: $e');
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('Cancelled notification $id');
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('Cancelled all notifications');
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final List<PendingNotificationRequest> pending =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      debugPrint('Pending notifications: ${pending.length}');
      return pending;
    } catch (e) {
      debugPrint('Failed to get pending notifications: $e');
      return [];
    }
  }

  // ============================================
  // DAILY GOAL NOTIFICATION METHODS
  // ============================================

  /// Notification IDs for daily goals
  static const int _morningReminderId = 1001;
  static const int _eveningReminderId = 1002;
  static const int _lastChanceReminderId = 1003;
  static const int _streakRiskId = 1004;

  /// Schedule all daily goal reminders
  Future<void> scheduleDailyGoalReminders() async {
    if (!_initialized) await initialize();

    try {
      await cancelDailyGoalReminders();

      // Morning reminder at 08:00
      await _scheduleDailyNotification(
        id: _morningReminderId,
        hour: 8,
        minute: 0,
        title: 'Günaydın!',
        body: 'Bugünkü 3 hedefin hazir. Hadi baslayalim!',
        payload: 'daily_goals_morning',
      );

      // Evening reminder at 18:00
      await _scheduleDailyNotification(
        id: _eveningReminderId,
        hour: 18,
        minute: 0,
        title: 'Akşam Hatırlatması',
        body: 'Günlük hedeflerini tamamladın mi?',
        payload: 'daily_goals_evening',
      );

      // Last chance reminder at 21:00
      await _scheduleDailyNotification(
        id: _lastChanceReminderId,
        hour: 21,
        minute: 0,
        title: 'Son Şans!',
        body: 'Streakini kaybetme! Hedeflerin bekliyor.',
        payload: 'daily_goals_last_chance',
      );

      debugPrint('Daily goal reminders scheduled');
    } catch (e) {
      debugPrint('Failed to schedule daily goal reminders: $e');
    }
  }

  /// Schedule a daily recurring notification
  Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_goals_channel',
        'Günlük Hedefler',
        channelDescription: 'Günlük hedef hatirlatmalari',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails, iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id, title, body, scheduledDate, notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint('Scheduled daily notification at $hour:$minute');
    } catch (e) {
      debugPrint('Failed to schedule daily notification: $e');
    }
  }

  /// Cancel daily goal reminders
  Future<void> cancelDailyGoalReminders() async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(_morningReminderId);
      await _flutterLocalNotificationsPlugin.cancel(_eveningReminderId);
      await _flutterLocalNotificationsPlugin.cancel(_lastChanceReminderId);
      await _flutterLocalNotificationsPlugin.cancel(_streakRiskId);
      debugPrint('Cancelled daily goal reminders');
    } catch (e) {
      debugPrint('Failed to cancel daily goal reminders: $e');
    }
  }

  /// Send streak at risk notification
  Future<void> notifyStreakAtRisk(int currentStreak) async {
    if (!_initialized) await initialize();
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'streak_channel', 'Streak Uyarilari',
        channelDescription: 'Streak kaybetme uyarilari',
        importance: Importance.max, priority: Priority.max,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true,
      );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails, iOS: iosDetails,
      );
      await _flutterLocalNotificationsPlugin.show(
        _streakRiskId,
        '$currentStreak günlük serini kaybetme!',
        'Bugün en az 1 ders tamamla!',
        notificationDetails,
        payload: 'streak_risk',
      );
      debugPrint('Sent streak risk notification');
    } catch (e) {
      debugPrint('Failed to send streak risk notification: $e');
    }
  }

  /// Send achievement notification
  Future<void> notifyAchievement({
    required String title,
    required String description,
    String? badgeEmoji,
  }) async {
    if (!_initialized) await initialize();
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'achievements_channel', 'Başarılar',
        channelDescription: 'Başarı bildirimleri',
        importance: Importance.high, priority: Priority.high,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true,
      );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails, iOS: iosDetails,
      );
      final emoji = badgeEmoji ?? '';
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '$emoji $title',
        description,
        notificationDetails,
        payload: 'achievement',
      );
      debugPrint('Sent achievement notification: $title');
    } catch (e) {
      debugPrint('Failed to send achievement notification: $e');
    }
  }

  /// Send daily goals completed notification
  Future<void> notifyDailyGoalsCompleted() async {
    if (!_initialized) await initialize();
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_goals_channel', 'Günlük Hedefler',
        channelDescription: 'Günlük hedef bildirimleri',
        importance: Importance.high, priority: Priority.high,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true,
      );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails, iOS: iosDetails,
      );
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Tebrikler!',
        'Bugünkü tüm hedeflerini tamamladın!',
        notificationDetails,
        payload: 'daily_goals_completed',
      );
      debugPrint('Sent daily goals completed notification');
    } catch (e) {
      debugPrint('Failed to send daily goals completed notification: $e');
    }
  }
}
