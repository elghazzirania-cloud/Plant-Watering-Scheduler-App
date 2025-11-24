import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'plant.dart';


class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize Timezones for scheduling future notifications
    tz.initializeTimeZones();
    // Use the device's current timezone
    tz.setLocalLocation(tz.getLocation(tz.local.name));

    // 2. Setup Platform-specific settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 3. Schedule the notification for a specific plant
  Future<void> scheduleWateringNotification(Plant plant) async {
    final now = tz.TZDateTime.now(tz.local);
    // Schedule for the next watering date, at 10:00 AM local time
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      plant.nextWateringDate.year,
      plant.nextWateringDate.month,
      plant.nextWateringDate.day,
      10, // Hour: 10 AM
      0,  // Minute: 00
    );

    // If the scheduled date is in the past (e.g., app was off for days),
    // schedule it for the next minute from now to alert the user immediately.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = now.add(const Duration(minutes: 1));
    }

    // A unique ID is required for each notification.
    // We use a hash of the plant name to create a consistent ID.
    final int notificationId = plant.name.hashCode.abs();

    // Cancel any existing notification for this plant before scheduling a new one
    await flutterLocalNotificationsPlugin.cancel(notificationId);


    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'watering_schedule_channel', // Channel ID
        'Watering Reminders',       // Channel Name
        channelDescription: 'Reminders for when your plants need water.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      '💧 Time to Water ${plant.name}',
      'Your ${plant.type} needs watering today!',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  // Helper to clear notification for a deleted plant
  Future<void> cancelNotification(Plant plant) async {
    final int notificationId = plant.name.hashCode.abs();
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}