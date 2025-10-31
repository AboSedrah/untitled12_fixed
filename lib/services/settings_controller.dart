import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fazkorony/services/notification_service.dart';
import 'package:fazkorony/services/prayer_notification_service.dart';
import 'package:fazkorony/services/settings_service.dart';

class SettingsController {
  Timer? _debounce;
  void bind({
    required SettingsService settings,
    required NotificationService notifications,
    required FlutterLocalNotificationsPlugin plugin,
  }) {
    void reschedule() async {
      await notifications.scheduleAdhkarFromSettings();
      await PrayerNotificationService(plugin).schedulePrayerNotifications();
    }

    // أول ربط: جدولة بحسب الإعدادات الحالية
    reschedule();

    settings.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), reschedule);
    });
  }
}


