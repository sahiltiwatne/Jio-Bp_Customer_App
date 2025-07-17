import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationService {
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // ✅ TIMEZONE must be initialized
    tz.initializeTimeZones();
  }


  static Future<void> scheduleReminderNotification(DateTime exitTime) async {
    final logoutTime = exitTime.add(Duration(minutes: 6));
    final notifyTime = logoutTime.subtract(Duration(minutes: 5)); // 🔄 Just 1 min after exit
    final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print("🔎 Pending notifications: ${pending.length}");



    print("📤 Exit at: $exitTime");
    print("🔔 Notify at: $notifyTime");
    print("⛔ Logout at: $logoutTime");

    print("⏰ Exited at: $exitTime | Notify at: $notifyTime");

    if (notifyTime.isBefore(DateTime.now())) {
      print("⚠️ Skipping notification — notifyTime already passed");
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '⏳ Session Reminder',
      'Only 5 minutes left before logout!',
      tz.TZDateTime.from(notifyTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'session_channel',
          'Session Channel',
          channelDescription: 'Session timeout reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );



    print("✅ Notification scheduled successfully at $notifyTime");
  }



  static Future<void> cancelReminderNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
  static Future<void> showBookingNotification({
    required String fuelType,
    required String vehicleNumber,
    required String pumpAddress,
    required String bookingId,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      1, // Different ID than 0 to avoid conflict with session reminder
      'Payment Successful ✅',
      'Tap to view details',  // Collapsed content (small text)

      NotificationDetails(
        android: AndroidNotificationDetails(
          'booking_channel',
          'Booking Notifications',
          channelDescription: 'Notifications for fuel booking confirmations',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            'Fuel Type: $fuelType\n'
                'Vehicle No.: $vehicleNumber\n'
                'Pump: $pumpAddress\n'
                'Booking ID: $bookingId\n'
                'Payment Mode: Wallet 💳',

            contentTitle: 'Payment Successful ✅', // Expanded Title (optional, replaces collapsed title when expanded)
            summaryText: 'Paid via Wallet',        // Small grey text below expanded notification (optional)
          ),
        ),
      ),
    );
  }


}
