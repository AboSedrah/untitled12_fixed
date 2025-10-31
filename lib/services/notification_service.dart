// lib/services/notification_service.dart

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:fazkorony/services/stats_controller.dart';

// (اختياري) لفتح إعدادات القناة على أندرويد
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

/// خدمة إشعارات الأذكار (صباح/مساء/نوم) + تكبيرات بداية ذي الحجة.
/// متوافقة مع flutter_local_notifications 17.x و timezone ^0.9.4.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? _navKey;
  void attachNavigatorKey(GlobalKey<NavigatorState> key) => _navKey = key;

  /// التهيئة العامة
  Future<void> init() async {
    // تهيئة المناطق الزمنية
    tz_data.initializeTimeZones();
    try {
      final String localTz =
          (await FlutterTimezone.getLocalTimezone()).toString();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      // لم نتمكن من الحصول على المنطقة الزمنية من النظام — عيّن UTC كافتراضي
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {
        // آخر حل: استخدم كائن UTC المتوفّر
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }
    // Defensive: ensure tz.local is usable. If it wasn't initialized above for
    // any reason, set it to UTC to avoid LateInitializationError when other
    // code calls tz.local synchronously during startup.
    try {
      // Access tz.local to force initialization check
      final _ = tz.local;
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    // طلب الصلاحيات مرة واحدة فقط بعد التثبيت
    final prefs = await SharedPreferences.getInstance();
    final permsRequested = prefs.getBool('notif.perms.requested') ?? false;
    if (!permsRequested) {
      await _ensureNotificationsPermission();
      await requestExactAlarmsPermission();
      // اطلب تجاهل تحسينات البطارية للسماح بالخلفية
      try {
        if (Platform.isAndroid) {
          // طلب إذن التجاهل إن كان النظام يقيّد التطبيق
          final isIgnoring =
              await perm.Permission.ignoreBatteryOptimizations.isGranted;
          if (!isIgnoring) {
            await perm.openAppSettings();
          }
        }
      } catch (_) {}
      await prefs.setBool('notif.perms.requested', true);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse resp) {
        _openAzkarOrPrayerScreenByPayload(resp.payload);
      },
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

    // إنشاء قناة أذكار افتراضية بصوت النظام إن لم تكن موجودة (يؤثر على موثوقية التسليم)
    final androidImpl =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl
        ?.createNotificationChannel(const AndroidNotificationChannel(
      'azkar_default_channel',
      'تنبيهات الأذكار (افتراضي)',
      description: 'قناة لإشعارات الأذكار بنغمة النظام',
      importance: Importance.max,
    ));

    // إن كان التطبيق فُتح عبر إشعار
    final launch = await notificationsPlugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      _openAzkarOrPrayerScreenByPayload(
        launch!.notificationResponse?.payload,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // دوال اختبار/مساعدة
  // ---------------------------------------------------------------------------

  /// يطلب إذن الإشعارات (Android 13+) ثم يرسل إشعارًا فوريًا (بدون جدولة).
  Future<void> debugShowNow() async {
    final androidImpl =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_instant_channel',
        'اختبار فوري',
        channelDescription: 'قناة لاختبارات الإشعارات الفورية',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await notificationsPlugin.show(
      9999,
      'اختبار إشعار',
      'هذا إشعار فوري (بدون جدولة)',
      details,
      payload: 'debug_instant',
    );
  }

  /// يطلب صلاحية Exact alarms (قد تُطلب على بعض الأجهزة/الرومات).
  Future<void> requestExactAlarmsPermission() async {
    final androidImpl =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestExactAlarmsPermission();
  }

  /// يفتح إعدادات قناة الأذكار (مفيد على أجهزة سامسونج/أندرويد عامة).
  Future<void> openDefaultChannelSettings() async {
    if (!Platform.isAndroid) return;
    final intent = AndroidIntent(
      action: 'android.settings.CHANNEL_NOTIFICATION_SETTINGS',
      arguments: <String, dynamic>{
        'android.provider.extra.APP_PACKAGE': 'com.example.untitled12',
        'android.provider.extra.CHANNEL_ID': 'azkar_default_channel',
      },
    );
    await intent.launch();
  }

  // ---------------------------------------------------------------------------
  // جدولة أذكار يومية (صباح/مساء/نوم) بنغمة النظام الافتراضية
  // ---------------------------------------------------------------------------

  Future<void> scheduleDailyNotifications() async {
    // تُستخدم عند أول تشغيل كتذكير افتراضي ثم لاحقًا نعتمد إعدادات المستخدم المفصلة
    await scheduleAdhkarFromSettings();
  }

  Future<void> cancelZikrNotifications() async {
    await notificationsPlugin.cancel(1001);
    await notificationsPlugin.cancel(1002);
    await notificationsPlugin.cancel(1003);
  }

  // جدولة أذكار حسب إعداد المستخدم (تذكير يومي واحد)
  Future<void> scheduleAdhkarFromSettings() async {
    final p = await SharedPreferences.getInstance();
    final enabled = p.getBool('notif.adhkar.enabled') ?? true;
    final sabahEnabled = p.getBool('notif.adhkar.sabah.enabled') ?? enabled;
    final masaEnabled = p.getBool('notif.adhkar.masa.enabled') ?? enabled;
    final noumEnabled = p.getBool('notif.adhkar.noum.enabled') ?? enabled;
    final dailyHhmm = p.getString('notif.adhkar.time') ?? '09:00';
    final sabahHhmm = p.getString('notif.adhkar.sabah.time') ?? '05:30';
    final masaHhmm = p.getString('notif.adhkar.masa.time') ?? '17:30';
    final noumHhmm = p.getString('notif.adhkar.noum.time') ?? '23:00';
    final quietEnabled = p.getBool('notif.quietHours.enabled') ?? false;
    final quietStart = p.getString('notif.quietHours.start') ?? '22:30';
    final quietEnd = p.getString('notif.quietHours.end') ?? '05:30';

    NotificationDetails details() => NotificationDetails(
          android: AndroidNotificationDetails(
            'azkar_default_channel',
            'تنبيهات الأذكار (افتراضي)',
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            fullScreenIntent: true,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

    tz.TZDateTime nextFromHHmm(String hhmm) {
      final parts = hhmm.split(':');
      final nowLocal = tz.TZDateTime.now(tz.local);
      var t = tz.TZDateTime(
        tz.local,
        nowLocal.year,
        nowLocal.month,
        nowLocal.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      if (t.isBefore(nowLocal)) t = t.add(const Duration(days: 1));

      if (quietEnabled) {
        // ادفع الوقت إلى خارج ساعات الهدوء بشكل آمن عبر التوجّه مباشرة لنهاية فترة الهدوء
        int guard = 0;
        while (_isWithinQuietHours(t, quietStart, quietEnd) && guard < 3) {
          final eh = int.parse(quietEnd.split(':')[0]);
          final em = int.parse(quietEnd.split(':')[1]);
          var endToday =
              tz.TZDateTime(t.location, t.year, t.month, t.day, eh, em);
          if (!endToday.isAfter(t)) {
            endToday = endToday.add(const Duration(days: 1));
          }
          t = endToday;
          if (t.isBefore(nowLocal)) {
            t = t.add(const Duration(days: 1));
          }
          guard++;
        }
      }
      return t;
    }

    // ألغِ أي أذكار قديمة قيد الانتظار لتجنّب التكرارات
    try {
      final pending = await notificationsPlugin.pendingNotificationRequests();
      for (final r in pending) {
        final p = r.payload ?? '';
        if (p == 'zikr_daily' ||
            p == 'zikr_sabah' ||
            p == 'zikr_masa' ||
            p == 'zikr_noum') {
          await notificationsPlugin.cancel(r.id);
        }
      }
    } catch (_) {}

    if (enabled) {
      await _tryZonedSchedule(
        id: 1100,
        title: 'تذكير الأذكار',
        body: 'لا تنسَ وردك اليومي من الأذكار',
        when: nextFromHHmm(dailyHhmm),
        details: details(),
        payload: 'zikr_daily',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    if (sabahEnabled) {
      await _tryZonedSchedule(
        id: 1101,
        title: 'أذكار الصباح',
        body: 'حان وقت قراءة أذكار الصباح',
        when: nextFromHHmm(sabahHhmm),
        details: details(),
        payload: 'zikr_sabah',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    if (masaEnabled) {
      await _tryZonedSchedule(
        id: 1102,
        title: 'أذكار المساء',
        body: 'حان وقت قراءة أذكار المساء',
        when: nextFromHHmm(masaHhmm),
        details: details(),
        payload: 'zikr_masa',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    if (noumEnabled) {
      await _tryZonedSchedule(
        id: 1103,
        title: 'أذكار النوم',
        body: 'حان وقت قراءة أذكار النوم',
        when: nextFromHHmm(noumHhmm),
        details: details(),
        payload: 'zikr_noum',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  bool _isWithinQuietHours(tz.TZDateTime t, String startHHmm, String endHHmm) {
    int parseH(String s) => int.parse(s.split(':')[0]);
    int parseM(String s) => int.parse(s.split(':')[1]);
    final sh = parseH(startHHmm);
    final sm = parseM(startHHmm);
    final eh = parseH(endHHmm);
    final em = parseM(endHHmm);
    final start = tz.TZDateTime(t.location, t.year, t.month, t.day, sh, sm);
    var end = tz.TZDateTime(t.location, t.year, t.month, t.day, eh, em);
    final crossesMidnight = end.isBefore(start) || end.isAtSameMomentAs(start);
    if (crossesMidnight) {
      end = end.add(const Duration(days: 1));
      if (t.isBefore(start)) {
        t = t.add(const Duration(days: 1));
      }
    }
    return (t.isAtSameMomentAs(start) || t.isAfter(start)) && t.isBefore(end);
  }

  /// اختبار: يرسل إشعار أذكار بعد N ثوانٍ
  Future<void> scheduleTestAzkar({
    required String payload,
    int inSeconds = 5,
  }) async {
    // مسار اختبار سريع: استخدم show بعد تأخير قصير لضمان ظهور الإشعار فورًا بلا اعتماد على exact alarms
    if (inSeconds <= 15) {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_default_channel',
          'تنبيهات الأذكار (افتراضي)',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await Future.delayed(Duration(seconds: inSeconds));

      String title, body;
      switch (payload) {
        case 'zikr_sabah':
          title = 'أذكار الصباح';
          body = 'اختبار: حان وقت أذكار الصباح';
          break;
        case 'zikr_masa':
          title = 'أذكار المساء';
          body = 'اختبار: حان وقت أذكار المساء';
          break;
        case 'zikr_noum':
          title = 'أذكار النوم';
          body = 'اختبار: حان وقت أذكار النوم';
          break;
        default:
          title = 'أذكار';
          body = 'اختبار إشعار الأذكار';
      }

      await notificationsPlugin.show(8000 + inSeconds, title, body, details,
          payload: payload);
      return;
    }

    final when = tz.TZDateTime.now(tz.local).add(Duration(seconds: inSeconds));

    String title, body;
    switch (payload) {
      case 'zikr_sabah':
        title = 'أذكار الصباح';
        body = 'اختبار: حان وقت أذكار الصباح';
        break;
      case 'zikr_masa':
        title = 'أذكار المساء';
        body = 'اختبار: حان وقت أذكار المساء';
        break;
      case 'zikr_noum':
        title = 'أذكار النوم';
        body = 'اختبار: حان وقت أذكار النوم';
        break;
      default:
        title = 'أذكار';
        body = 'اختبار إشعار الأذكار';
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'azkar_default_channel',
        'تنبيهات الأذكار (افتراضي)',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _tryZonedSchedule(
      id: 8000 + inSeconds,
      title: title,
      body: body,
      when: when,
      details: details,
      payload: payload,
    );
  }

  // ---------------------------------------------------------------------------
  // تكبيرات بداية ذي الحجة (مرة واحدة)
  // ---------------------------------------------------------------------------

  /// (اختياري) تشغيل إشعار تكبيرات عند **بداية** العشر (1 ذو الحجة) مرة واحدة.
  /// يستخدم صوت `res/raw/haj_takbeer.(mp3|ogg)`.
  Future<void> maybePlayTakbeerAtStartOfDhulHijjah() async {
    final today = DateTime.now();
    final h = HijriCalendar.fromDate(today);
    if (h.hMonth == 12 && h.hDay == 1) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'takbeer_started_${h.hYear}';
      final played = prefs.getBool(key) ?? false;
      if (played) return;

      await notificationsPlugin.show(
        555001, // أي رقم ثابت
        'تكبيرات العشر',
        'الله أكبر.. بداية عشر ذي الحجة المباركة',
        _takbeerNotificationDetails(),
        payload: 'takbeer_start',
      );

      await prefs.setBool(key, true);
    }
  }

  NotificationDetails _takbeerNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'takbeer_oneoff_channel',
        'تكبيرات (مرة واحدة)',
        channelDescription: 'تشغيل تكبيرات عند بداية العشر.',
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound('haj_takbeer'),
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ملاحة حسب الـ payload
  // ---------------------------------------------------------------------------

  void _openAzkarOrPrayerScreenByPayload(String? payload) {
    final nav = _navKey?.currentState;
    if (nav == null || payload == null) return;

    if (payload.startsWith('prayer:')) {
      // عدّ كقراءة بعد الصلاة عند فتح الإشعار
      StatsController().onDhikrRead(category: 'prayers');
      final name = payload.split(':').last;
      nav.pushNamed('/prayer_times', arguments: {'highlight': name});
      return;
    }
    // /zikr_sabah | /zikr_masa | /zikr_noum
    if (payload == 'zikr_sabah') {
      StatsController().onDhikrRead(category: 'sabah');
    } else if (payload == 'zikr_masa') {
      StatsController().onDhikrRead(category: 'masa');
    } else if (payload == 'zikr_noum') {
      StatsController().onDhikrRead(category: 'noum');
    }
    nav.pushNamed('/$payload');
  }

  // ---------------------------------------------------------------------------
  // صلاحيات إشعارات أندرويد 13+
  // ---------------------------------------------------------------------------

  Future<void> _ensureNotificationsPermission() async {
    if (!Platform.isAndroid) return;
    final androidImpl =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  /// مطلوب لمعالجات الخلفية في الحزمة
  @pragma('vm:entry-point')
  static void _notificationTapBackground(NotificationResponse resp) {}
}

extension _ExactAlarmFallback on NotificationService {
  Future<void> _tryZonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required NotificationDetails details,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        when,
        details,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException catch (_) {
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        when,
        details,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
