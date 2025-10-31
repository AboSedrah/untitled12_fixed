// lib/services/prayer_times_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart' as adhan;

class PrayerTime {
  final String name;
  final DateTime time;

  PrayerTime({required this.name, required this.time});

  Map<String, dynamic> toJson() => {
    'name': name,
    'time': time.toIso8601String(),
  };

  static PrayerTime fromJson(Map<String, dynamic> j) =>
      PrayerTime(name: j['name'] as String, time: DateTime.parse(j['time'] as String));
}

class PrayerTimesService extends ChangeNotifier {
  static final PrayerTimesService _i = PrayerTimesService._internal();
  factory PrayerTimesService() => _i;
  PrayerTimesService._internal();

  double? _lat;
  double? _lon;

  List<PrayerTime> _today = [];
  List<PrayerTime> _tomorrow = [];
  PrayerTime? _next;

  Future<void> initialize() async {
    await _ensureLocation();
    await _loadForTodayAndTomorrow();
    notifyListeners();
  }

  Future<void> updateLocation(double lat, double lon) async {
    _lat = lat;
    _lon = lon;
    final p = await SharedPreferences.getInstance();
    await p.setDouble('prayer_latitude', lat);
    await p.setDouble('prayer_longitude', lon);
    await _loadForTodayAndTomorrow();
    notifyListeners();
  }

  MapEntry<PrayerTime?, Duration?> tick() {
    if (_next == null) return const MapEntry(null, null);
    final now = DateTime.now();
    if (!_next!.time.isAfter(now)) {
      _recomputeNext();
    }
    final d = _next!.time.difference(now);
    return MapEntry(_next, d.isNegative ? Duration.zero : d);
  }

  List<PrayerTime> getTodayPrayers() => _today;
  PrayerTime? get nextPrayer => _next;

  String formatTime(DateTime t) => DateFormat('hh:mm a').format(t);

  String formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes.remainder(60)).toString().padLeft(2, '0');
    final s = (d.inSeconds.remainder(60)).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _ensureLocation() async {
    final p = await SharedPreferences.getInstance();
    _lat = p.getDouble('prayer_latitude') ?? p.getDouble('savedLat');
    _lon = p.getDouble('prayer_longitude') ?? p.getDouble('savedLon');

    if (_lat == null || _lon == null) {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw 'خدمة الموقع غير مفعّلة';

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        throw 'صلاحية الموقع مرفوضة';
      }

      final pos = await Geolocator.getCurrentPosition();
      _lat = pos.latitude;
      _lon = pos.longitude;
      await p.setDouble('prayer_latitude', _lat!);
      await p.setDouble('prayer_longitude', _lon!);
    }
  }

  String _cacheKey(DateTime d) {
    final rl = (_lat ?? 0).toStringAsFixed(4);
    final rn = (_lon ?? 0).toStringAsFixed(4);
    final ds = DateFormat('yyyy-MM-dd').format(d);
    return 'prayers_cache_v1_${ds}_${rl}_$rn';
  }

  Future<void> _loadForTodayAndTomorrow() async {
    final now = DateTime.now();
    _today = await _getForDate(now);
    _tomorrow = await _getForDate(now.add(const Duration(days: 1)));
    _recomputeNext();
  }

  Future<List<PrayerTime>> _getForDate(DateTime date) async {
    final p = await SharedPreferences.getInstance();
    final key = _cacheKey(date);

    final cached = p.getString(key);
    if (cached != null) {
      try {
        final List j = json.decode(cached) as List;
        final list =
        j.map((e) => PrayerTime.fromJson(e as Map<String, dynamic>)).toList();
        if (list.isNotEmpty &&
            list.first.time.year == date.year &&
            list.first.time.month == date.month &&
            list.first.time.day == date.day) {
          return list;
        }
      } catch (_) {}
    }

    final list = _computeForDate(date);
    await p.setString(key, json.encode(list.map((e) => e.toJson()).toList()));
    return list;
  }

  List<PrayerTime> _computeForDate(DateTime date) {
    final coords = adhan.Coordinates(_lat!, _lon!);
    final params = adhan.CalculationMethod.umm_al_qura.getParameters()
      ..madhab = adhan.Madhab.shafi;

    final dc = adhan.DateComponents.from(date);
    final pt = adhan.PrayerTimes(coords, dc, params);

    return <PrayerTime>[
      PrayerTime(name: 'الفجر', time: pt.fajr),
      PrayerTime(name: 'الظهر', time: pt.dhuhr),
      PrayerTime(name: 'العصر', time: pt.asr),
      PrayerTime(name: 'المغرب', time: pt.maghrib),
      PrayerTime(name: 'العشاء', time: pt.isha),
    ];
  }

  void _recomputeNext() {
    final now = DateTime.now();
    _next = _today.firstWhere(
          (p) => p.time.isAfter(now),
      orElse: () => _tomorrow.first,
    );
  }
}
