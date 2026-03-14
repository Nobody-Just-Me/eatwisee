import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    print('🔔 Initializing NotificationService...');

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    print('   ✓ Timezone set to Asia/Jakarta');

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('🔔 Notification tapped: ${details.payload}');
      },
    );
    print('   ✓ Notification plugin initialized');

    // Request permission for Android 13+
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      print('   ✓ Notification permission: ${granted ?? false}');

      // Also request exact alarm permission
      final exactAlarmGranted =
          await androidPlugin.requestExactAlarmsPermission();
      print('   ✓ Exact alarm permission: ${exactAlarmGranted ?? false}');
    }

    print('✅ NotificationService initialization complete');
  }

  /// Schedule daily notification at specific time
  static Future<void> scheduleMealNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      final scheduledTime = _nextInstanceOfTime(hour, minute);

      print('📅 Scheduling notification:');
      print('   ID: $id');
      print('   Title: $title');
      print('   Time: $hour:${minute.toString().padLeft(2, '0')}');
      print('   Next trigger: $scheduledTime');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminder',
            'Meal Reminders',
            channelDescription: 'Notifications for meal times',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('   ✅ Notification ID $id scheduled successfully');
    } catch (e) {
      print('   ❌ Error scheduling notification ID $id: $e');
      rethrow;
    }
  }

  /// Get next instance of specific time
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('❌ Cancelled notification ID $id');
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('❌ Cancelled all notifications');
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted =
        await androidImplementation?.areNotificationsEnabled();
    return granted ?? false;
  }

  /// Show immediate notification (for testing)
  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    print('🔔 Showing immediate notification: $title');
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
    print('   ✅ Notification shown');
  }

  /// Get pending notifications (untuk debugging)
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Print all pending notifications
  static Future<void> printPendingNotifications() async {
    final pending = await getPendingNotifications();
    print('📋 Pending notifications: ${pending.length}');
    for (var notif in pending) {
      print('   - ID: ${notif.id}, Title: ${notif.title}');
    }
  }
}
