// lib/services/prayer_notification_service.dart
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show PlatformException;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart' as adhan;
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة تنبيهات مواقيت الصلاة + تكبيرات ذي الحجة.
/// متوافقة مع flutter_local_notifications 17.x و timezone ^0.9.4.
/// تحتوي على fallback تلقائي إذا رُفضت exact alarms.
class PrayerNotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin;
  PrayerNotificationService(this.notificationsPlugin);

  static Future<void> initTimeZone() async {
    tz_data.initializeTimeZones();
    try {
      final String localTz =
          (await FlutterTimezone.getLocalTimezone()).toString();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {}
  }

  /// Defensive helper to guarantee tz.local is ready. Falls back to UTC on error.
  static Future<void> ensureLocalTz() async {
    try {
      final _ = tz.local;
    } catch (_) {
      try {
        final String localTz =
            (await FlutterTimezone.getLocalTimezone()).toString();
        tz.setLocalLocation(tz.getLocation(localTz));
      } catch (_) {
        try {
          tz.setLocalLocation(tz.getLocation('UTC'));
        } catch (_) {}
      }
    }
  }

  /// جدولة تنبيهات الصلوات الخمس يوميًا بحسب الموقع الحالي.
  Future<void> schedulePrayerNotifications() async {
    // لا تطلب أذونات هنا، طُلبت أثناء التهيئة الأولى

    // حمّل إعدادات الإشعارات وساعات الهدوء
    final prefs = await SharedPreferences.getInstance();
    final masterEnabled = prefs.getBool('notif.enabled') ?? true;
    final adhanEnabled = prefs.getBool('notif.types.adhan.enabled') ?? true;
    final useAdhanVoice = prefs.getBool('notif.prayers.useAdhanVoice') ?? true;
    final prayerSwitches = <String, bool>{
      'الفجر': prefs.getBool('notif.prayers.fajr.enabled') ?? true,
      'الظهر': prefs.getBool('notif.prayers.dhuhr.enabled') ?? true,
      'العصر': prefs.getBool('notif.prayers.asr.enabled') ?? true,
      'المغرب': prefs.getBool('notif.prayers.maghrib.enabled') ?? true,
      'العشاء': prefs.getBool('notif.prayers.isha.enabled') ?? true,
    };
    final quietEnabled = prefs.getBool('notif.quietHours.enabled') ?? false;
    final quietStart = prefs.getString('notif.quietHours.start') ?? '22:30';
    final quietEnd = prefs.getString('notif.quietHours.end') ?? '05:30';
    if (!masterEnabled || !adhanEnabled) {
      // إذا كانت الإشعارات أو الأذان متوقفين، لا نُجدول
      return;
    }

    // صلاحيات وموقع
    // ترتيب التفضيل: موقع محفوظ من التقويم -> موقع يدوي من الإعدادات -> GPS
    double? lat;
    double? lng;
    try {
      final p = await SharedPreferences.getInstance();
      // 1) من التقويم إن وُجد
      lat = p.getDouble('savedLat');
      lng = p.getDouble('savedLon');
      // 2) من الإعدادات اليدوية
      if (lat == null || lng == null) {
        final manualOn = p.getBool('prayers.manual.enabled') ?? false;
        if (manualOn) {
          lat = p.getDouble('prayers.manual.lat');
          lng = p.getDouble('prayers.manual.lng');
        }
      }
    } catch (_) {}

    if (lat == null || lng == null) {
      // إن لم توجد قيمة يدوية نحاول الموقع الحقيقي، وإلا نتوقف بهدوء
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      lat = pos.latitude;
      lng = pos.longitude;
    }

    // حساب المواقيت
    final coords = adhan.Coordinates(lat, lng);
    final params = adhan.CalculationMethod.umm_al_qura.getParameters()
      ..madhab = adhan.Madhab.shafi;
    // ألغِ أي تنبيهات صلاة قديمة قيد الانتظار لتجنّب التكرار
    try {
      final pending = await notificationsPlugin.pendingNotificationRequests();
      for (final r in pending) {
        if ((r.payload ?? '').startsWith('prayer:')) {
          await notificationsPlugin.cancel(r.id);
        }
      }
    } catch (_) {}

    // جدولة لعدة أيام قادمة (للاستمرارية حتى لو لم يُفتح التطبيق)
    final nowLocal = tz.TZDateTime.now(tz.local);
    const horizonDays = 8; // اليوم + أسبوع
    final details = useAdhanVoice
        ? await _buildPrayerDetails()
        : _buildPrayerDetailsNoSound();

    for (int offset = 0; offset < horizonDays; offset++) {
      final d = nowLocal.add(Duration(days: offset));
      final comps = adhan.DateComponents.from(DateTime(d.year, d.month, d.day));
      final pt = adhan.PrayerTimes(coords, comps, params);

      final Map<String, DateTime> times = {
        'الفجر': pt.fajr,
        'الظهر': pt.dhuhr,
        'العصر': pt.asr,
        'المغرب': pt.maghrib,
        'العشاء': pt.isha,
      };

      for (final e in times.entries) {
        final name = e.key;
        if (prayerSwitches[name] == false) continue;
        final dt = e.value;

        var when =
            tz.TZDateTime.local(dt.year, dt.month, dt.day, dt.hour, dt.minute);
        if (when.isBefore(nowLocal)) continue; // لا نُجدول الماضي

        if (quietEnabled && _isWithinQuietHours(when, quietStart, quietEnd)) {
          final eh = int.parse(quietEnd.split(':')[0]);
          final em = int.parse(quietEnd.split(':')[1]);
          var endToday = tz.TZDateTime(
              when.location, when.year, when.month, when.day, eh, em);
          if (!endToday.isAfter(when)) {
            endToday = endToday.add(const Duration(days: 1));
          }
          when = endToday;
        }

        final id = _stableId(
            'prayer:$name:${when.year}${when.month.toString().padLeft(2, '0')}${when.day.toString().padLeft(2, '0')}');
        await _tryZonedSchedule(
          id: id,
          title: 'موعد الصلاة',
          body: 'حان وقت صلاة $name',
          when: when,
          details: details,
          payload: 'prayer:$name',
        );
      }
    }
  }

  /// تكبيرات بعد كل صلاة خلال أيام ذي الحجة (1–13) بعد الصلاة بدقيقتين.
  Future<void> scheduleTakbeerAfterPrayersDuringDhulHijjah() async {
    await _ensureNotificationsPermission();

    final hijriNow = HijriCalendar.now();
    final withinRange =
        (hijriNow.hMonth == 12) && (hijriNow.hDay >= 1 && hijriNow.hDay <= 13);
    if (!withinRange) return;

    if (!await Geolocator.isLocationServiceEnabled()) return;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    final coords = adhan.Coordinates(pos.latitude, pos.longitude);
    final params = adhan.CalculationMethod.umm_al_qura.getParameters()
      ..madhab = adhan.Madhab.shafi;
    final today = adhan.DateComponents.from(DateTime.now());
    final pt = adhan.PrayerTimes(coords, today, params);

    const offset = Duration(minutes: 2);
    final List<MapEntry<String, DateTime>> afterTimes = [
      MapEntry('الفجر', pt.fajr.add(offset)),
      MapEntry('الظهر', pt.dhuhr.add(offset)),
      MapEntry('العصر', pt.asr.add(offset)),
      MapEntry('المغرب', pt.maghrib.add(offset)),
      MapEntry('العشاء', pt.isha.add(offset)),
    ];

    final now = tz.TZDateTime.now(tz.local);
    for (final e in afterTimes) {
      final name = e.key;
      var when = e.value;
      var tzWhen = tz.TZDateTime.local(
          when.year, when.month, when.day, when.hour, when.minute);
      if (tzWhen.isBefore(now)) tzWhen = tzWhen.add(const Duration(days: 1));

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'takbeer_channel',
          'تكبيرات الحج',
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

      await _tryZonedSchedule(
        id: ('takbeer_$name').hashCode,
        title: 'التكبير بعد الصلاة',
        body: 'كبّر بعد صلاة $name',
        when: tzWhen,
        details: details,
        payload: 'takbeer:$name',
      );
    }
  }

  // -------------------------
  // اختبارات سريعة
  // -------------------------

  /// اختبار تنبيه صلاة بعد N ثوانٍ.
  Future<void> scheduleTestPrayer({
    String name = 'الفجر',
    int inSeconds = 5,
  }) async {
    await _ensureNotificationsPermission();

    // مسار اختبار سريع: استخدم show بعد تأخير قصير لضمان عمل الإشعار حتى لو مُنعت exact alarms
    if (inSeconds <= 15) {
      await Future.delayed(Duration(seconds: inSeconds));
      try {
        final details = await _buildPrayerDetails();
        await notificationsPlugin.show(
          99001 + inSeconds,
          'موعد الصلاة (اختبار)',
          'اختبار: حان وقت صلاة $name',
          details,
          payload: 'prayer:$name',
        );
      } on PlatformException catch (e) {
        // عند غياب الصوت المخصص، استخدم التفاصيل بدون صوت
        if (e.code == 'invalid_sound') {
          final fallback = _buildPrayerDetailsNoSound();
          await notificationsPlugin.show(
            99001 + inSeconds,
            'موعد الصلاة (اختبار)',
            'اختبار: حان وقت صلاة $name',
            fallback,
            payload: 'prayer:$name',
          );
        } else {
          rethrow;
        }
      }
      return;
    }

    final when = tz.TZDateTime.now(tz.local).add(Duration(seconds: inSeconds));
    final details = await _buildPrayerDetails();

    await _tryZonedSchedule(
      id: 99001 + inSeconds,
      title: 'موعد الصلاة (اختبار)',
      body: 'اختبار: حان وقت صلاة $name',
      when: when,
      details: details,
      payload: 'prayer:$name',
    );
  }

  /// اختبار تكبيرات بعد N ثوانٍ.
  Future<void> scheduleTestTakbeer({int inSeconds = 5}) async {
    await _ensureNotificationsPermission();

    // مسار اختبار سريع: show بعد تأخير قصير
    if (inSeconds <= 15) {
      await Future.delayed(Duration(seconds: inSeconds));
      try {
        final details = NotificationDetails(
          android: AndroidNotificationDetails(
            'takbeer_channel',
            'تكبيرات الحج',
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
        await notificationsPlugin.show(
          99051 + inSeconds,
          'تكبيرات (اختبار)',
          'اختبار: كبّر الآن',
          details,
          payload: 'takbeer:test',
        );
      } on PlatformException catch (e) {
        if (e.code == 'invalid_sound') {
          final fallback = NotificationDetails(
            android: AndroidNotificationDetails(
              'takbeer_channel',
              'تكبيرات الحج',
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
            99051 + inSeconds,
            'تكبيرات (اختبار)',
            'اختبار: كبّر الآن',
            fallback,
            payload: 'takbeer:test',
          );
        } else {
          rethrow;
        }
      }
      return;
    }

    final when = tz.TZDateTime.now(tz.local).add(Duration(seconds: inSeconds));
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'takbeer_channel',
        'تكبيرات الحج',
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

    await _tryZonedSchedule(
      id: 99051 + inSeconds,
      title: 'تكبيرات (اختبار)',
      body: 'اختبار: كبّر الآن',
      when: when,
      details: details,
      payload: 'takbeer:test',
    );
  }

  // -------------------------
  // Quiet Hours helper
  // -------------------------
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
      // إذا كان الوقت قبل منتصف الليل قبل start، أضف يوماً للوقت المقارن
      if (t.isBefore(start)) {
        t = t.add(const Duration(days: 1));
      }
    }
    return (t.isAtSameMomentAs(start) || t.isAfter(start)) && t.isBefore(end);
  }

  // -------------------------
  // Fallback helper (exact -> inexact)
  // -------------------------
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
    } on PlatformException catch (e) {
      // في بعض الأجهزة يُرمى هذا الكود عند رفض Exact Alarms
      if (e.code == 'invalid_sound') {
        // جرّب بدون صوت مخصص
        final fallback = _buildPrayerDetailsNoSound();
        await notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          when,
          fallback,
          payload: payload,
          matchDateTimeComponents: matchDateTimeComponents,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else if (e.code == 'exact_alarms_not_permitted' || e.code == 'error') {
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
      } else {
        rethrow;
      }
    }
  }

  // مُعرّف ثابت من النص لضمان نفس القيم عبر التشغيلات (لا تعتمد على hashCode)
  int _stableId(String s) {
    int h = 2166136261; // FNV-1a 32-bit offset basis
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 16777619) & 0x7fffffff; // أبقِه موجبًا ضمن 31-بت
    }
    return 200000 + h; // حجز نطاق للصلاة
  }

  // -------------------------
  // صلاحيات أندرويد
  // -------------------------
  Future<void> _ensureNotificationsPermission() async {
    if (!Platform.isAndroid) return;
    final androidImpl =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  Future<NotificationDetails> _buildPrayerDetails() async {
    String? key;
    try {
      final p = await SharedPreferences.getInstance();
      // استخدم الصوت المختار من الإعدادات الجديدة أولاً، ثم ارجع للمفتاح القديم للتوافق
      key = p.getString('adhan.voice.selected') ?? p.getString('prayer_sound');
    } catch (_) {}

    // أنشئ قناة فريدة مرتبطة بالصوت المختار كي يطبّق الصوت فعليًا (قنوات أندرويد ثابتة بعد إنشائها)
    final channelId = await _preparePrayerChannel(key);

    final android = AndroidNotificationDetails(
      channelId,
      'تنبيهات الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      sound: (Platform.isAndroid && key != null && key.isNotEmpty)
          ? RawResourceAndroidNotificationSound(key)
          : null,
    );
    final ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound:
          (Platform.isIOS && key != null && key.isNotEmpty) ? '$key.caf' : null,
    );
    return NotificationDetails(android: android, iOS: ios);
  }

  /// تأكد من إنشاء قناة أندرويد بالصوت الصحيح. إرجاع المعرّف المستخدم.
  Future<String> _preparePrayerChannel(String? key) async {
    final androidImpl =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    // إن لم يوجد صوت مخصص، استخدم قناة افتراضية واحدة
    final channelId = (key != null && key.isNotEmpty)
        ? 'prayer_channel_$key'
        : 'prayer_channel_default';
    await androidImpl?.createNotificationChannel(AndroidNotificationChannel(
      channelId,
      'تنبيهات الصلاة',
      description: 'قناة تنبيهات الصلاة مع صوت المؤذن',
      importance: Importance.max,
      sound: (key != null && key.isNotEmpty)
          ? RawResourceAndroidNotificationSound(key)
          : null,
      playSound: true,
    ));
    return channelId;
  }

  NotificationDetails _buildPrayerDetailsNoSound() {
    final android = AndroidNotificationDetails(
      'prayer_channel',
      'تنبيهات الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(android: android, iOS: ios);
  }
}
