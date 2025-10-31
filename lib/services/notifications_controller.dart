import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationsController {
  final FlutterLocalNotificationsPlugin plugin;
  NotificationsController(this.plugin);

  Future<void> sendCongrats(
      {required String title, required String body}) async {
    final prefs = await SharedPreferences.getInstance();
    final master = prefs.getBool('notif.enabled') ?? true;
    if (!master) return;

    // Note: DND respect preference is stored but not explicitly checked here because
    // detecting system-wide DND requires platform-specific handling.

    final quiet = prefs.getBool('notif.quietHours.enabled') ?? false;
    final qs = prefs.getString('notif.quietHours.start') ?? '22:30';
    final qe = prefs.getString('notif.quietHours.end') ?? '05:30';

    final now = tz.TZDateTime.now(tz.local);
    if (quiet && _within(now, qs, qe)) {
      // لا نرسل أثناء الهدوء
      return;
    }

    final lastKey = 'stats.notify.lastCongrats';
    final last = prefs.getString(lastKey);
    if (last != null) {
      final lastDt = DateTime.tryParse(last);
      if (lastDt != null && now.difference(lastDt).inHours < 20)
        return; // بحد أقصى إشعار تهنئة واحد/يوم
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'stats_congrats',
        'تهنئة الإنجاز',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: prefs.getBool('notif.vibration') ?? true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await plugin.show(88001, title, body, details, payload: 'stats:congrats');
    await prefs.setString(lastKey, DateTime.now().toIso8601String());
  }

  bool _within(tz.TZDateTime t, String start, String end) {
    int h(String s) => int.parse(s.split(':')[0]);
    int m(String s) => int.parse(s.split(':')[1]);
    final s =
        tz.TZDateTime(t.location, t.year, t.month, t.day, h(start), m(start));
    var e = tz.TZDateTime(t.location, t.year, t.month, t.day, h(end), m(end));
    final wrap = e.isBefore(s) || e.isAtSameMomentAs(s);
    var time = t;
    if (wrap) {
      e = e.add(const Duration(days: 1));
      if (t.isBefore(s)) time = t.add(const Duration(days: 1));
    }
    return (time.isAtSameMomentAs(s) || time.isAfter(s)) && time.isBefore(e);
  }
}
