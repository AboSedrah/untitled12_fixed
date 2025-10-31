import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DailyDhikrRecord {
  final String date;
  final int count;
  final String status;
  final String updatedAt;
  final int sabah;
  final int masa;
  final int noum;
  final int prayers;
  const DailyDhikrRecord({
    required this.date,
    required this.count,
    required this.status,
    required this.updatedAt,
    this.sabah = 0,
    this.masa = 0,
    this.noum = 0,
    this.prayers = 0,
  });
  Map<String, dynamic> toJson() => {
        'date': date,
        'count': count,
        'status': status,
        'updatedAt': updatedAt,
        'sabah': sabah,
        'masa': masa,
        'noum': noum,
        'prayers': prayers,
      };
  static DailyDhikrRecord fromJson(Map<String, dynamic> j) => DailyDhikrRecord(
        date: j['date'] as String,
        count: j['count'] as int,
        status: j['status'] as String,
        updatedAt: j['updatedAt'] as String,
        sabah: (j['sabah'] as int?) ?? 0,
        masa: (j['masa'] as int?) ?? 0,
        noum: (j['noum'] as int?) ?? 0,
        prayers: (j['prayers'] as int?) ?? 0,
      );
}

class StatsController extends ChangeNotifier {
  String _yyyyMMdd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  Future<String> _todayKey() async =>
      'dhikr.stats.${_yyyyMMdd(DateTime.now())}';

  Future<void> ensureTodayInitialized() async {
    final p = await SharedPreferences.getInstance();
    final k = await _todayKey();
    if (!(p.containsKey('$k.count'))) {
      await p.setInt('$k.count', 0);
      await p.setString('$k.status', 'missed');
      await p.setString('$k.updatedAt', DateTime.now().toIso8601String());
    }
  }

  Future<void> onDhikrRead(
      {int countIncrement = 1, DateTime? timestamp, String? category}) async {
    final p = await SharedPreferences.getInstance();
    await ensureTodayInitialized();
    final k = await _todayKey();
    final count = p.getInt('$k.count') ?? 0;
    if (!(await p.setInt('$k.count', count + countIncrement))) {
      print('ERROR: Failed to write dhikr count to SharedPreferences');
    }
    if (!(await p.setString('$k.status', 'regular'))) {
      print('ERROR: Failed to write dhikr status to SharedPreferences');
    }
    if (!(await p.setString(
        '$k.updatedAt', (timestamp ?? DateTime.now()).toIso8601String()))) {
      print('ERROR: Failed to write dhikr updatedAt to SharedPreferences');
    }

    if (category != null) {
      final catKey = '$k.cat.$category';
      final c = p.getInt(catKey) ?? 0;
      await p.setInt(catKey, c + countIncrement);
    }

    final wasFirstRead = count == 0;
    final current = p.getInt('dhikr.streak.current') ?? 0;
    final newCurrent = wasFirstRead ? current + 1 : current;
    await p.setInt('dhikr.streak.current', newCurrent);
    final longest = p.getInt('dhikr.streak.longest') ?? 0;
    if (newCurrent > longest)
      await p.setInt('dhikr.streak.longest', newCurrent);

    await recomputeMonthlyRollup(DateTime.now());
    notifyListeners();
  }

  Future<void> onZikrReadItem({
    required String category,
    required String itemId,
    String? itemLabel,
    int countIncrement = 1,
    DateTime? timestamp,
  }) async {
    final p = await SharedPreferences.getInstance();
    await onDhikrRead(
        countIncrement: countIncrement,
        timestamp: timestamp,
        category: category);
    final k = await _todayKey();
    final prefix = '$k.item.$category.$itemId';
    final c = p.getInt(prefix) ?? 0;
    await p.setInt(prefix, c + countIncrement);
    if (itemLabel != null && itemLabel.isNotEmpty) {
      await p.setString('$k.itemlabel.$itemId', itemLabel);
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> recomputeMonthlyRollup(DateTime month) async {
    final p = await SharedPreferences.getInstance();
    final ym = DateFormat('yyyy-MM').format(month);
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final today = DateTime.now();
    int regularDays = 0;
    int totalDaysConsidered = 0;
    for (int i = 0; i < lastDay.day; i++) {
      final d = firstDay.add(Duration(days: i));
      if (d.isAfter(today)) {
        continue;
      }
      totalDaysConsidered++;
      final s = p.getString('dhikr.stats.${_yyyyMMdd(d)}.status') ?? 'missed';
      if (s == 'regular') regularDays++;
    }
    final pct = totalDaysConsidered == 0
        ? 0.0
        : (regularDays * 100.0 / totalDaysConsidered);
    final roll = {
      'regularDays': regularDays,
      'totalDays': totalDaysConsidered,
      'percentage': pct.clamp(0.0, 100.0),
    };
    await p.setString('dhikr.stats.month.$ym', json.encode(roll));
    return roll;
  }

  Future<List<Map<String, dynamic>>> getWeeklySeries() async {
    return _series(days: 7);
  }

  Future<List<Map<String, dynamic>>> getMonthlySeries() async {
    return _series(days: 30);
  }

  Future<List<Map<String, dynamic>>> _series({required int days}) async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final List<Map<String, dynamic>> out = [];
    for (int i = days - 1; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final base = 'dhikr.stats.${_yyyyMMdd(d)}';
      final c = p.getInt('$base.count') ?? 0;
      out.add({'date': _yyyyMMdd(d), 'count': c});
    }
    return out;
  }

  Future<List<Map<String, dynamic>>> dailyTotalsForMonth(
      int year, int month) async {
    final p = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> res = [];
    final last = DateTime(year, month + 1, 0);
    for (int day = 1; day <= last.day; day++) {
      final d = DateTime(year, month, day);
      final base = 'dhikr.stats.${_yyyyMMdd(d)}';
      final count = p.getInt('$base.count') ?? 0;
      final status = p.getString('$base.status') ?? 'missed';
      res.add({'day': day, 'count': count, 'status': status});
    }
    return res;
  }

  Future<DateTime?> firstDhikrDate() async {
    final p = await SharedPreferences.getInstance();
    DateTime? minDate;
    for (final key in p.getKeys()) {
      if (!key.startsWith('dhikr.stats.')) continue;
      if (!key.endsWith('.count')) continue;
      final rest = key.substring('dhikr.stats.'.length);
      final dateStr = rest.replaceFirst('.count', '');
      try {
        final parts = dateStr.split('-');
        if (parts.length != 3) continue;
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);
        final dt = DateTime(y, m, d);
        if (minDate == null || dt.isBefore(minDate)) minDate = dt;
      } catch (_) {}
    }
    return minDate;
  }

  Future<Map<String, int>> readCategoriesFor(DateTime d) async {
    final p = await SharedPreferences.getInstance();
    final base = 'dhikr.stats.${_yyyyMMdd(d)}';
    return {
      'sabah': p.getInt('$base.cat.sabah') ?? 0,
      'masa': p.getInt('$base.cat.masa') ?? 0,
      'noum': p.getInt('$base.cat.noum') ?? 0,
      'prayers': p.getInt('$base.cat.prayers') ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> readItemsFor(
      DateTime d, String category) async {
    final p = await SharedPreferences.getInstance();
    final date = _yyyyMMdd(d);
    final prefix = 'dhikr.stats.$date.item.$category.';
    final labelsPrefix = 'dhikr.stats.$date.itemlabel.';
    final out = <Map<String, dynamic>>[];
    for (final key in p.getKeys()) {
      if (key.startsWith(prefix)) {
        final itemId = key.substring(prefix.length);
        final count = p.getInt(key) ?? 0;
        final label = p.getString('$labelsPrefix$itemId') ?? itemId;
        out.add({'id': itemId, 'label': label, 'count': count});
      }
    }
    out.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return out;
  }
}
