// lib/services/quran_progress_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayProgress {
  final String date; // YYYY-MM-DD
  final int targetJuzCount;
  final Set<int> readJuzIndices;
  final int actualCount;
  final String status; // pending|partial|done
  final int lastSurah;
  final int lastAyah;

  DayProgress({
    required this.date,
    required this.targetJuzCount,
    required this.readJuzIndices,
    required this.actualCount,
    required this.status,
    required this.lastSurah,
    required this.lastAyah,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'targetJuzCount': targetJuzCount,
        'readJuzIndices': readJuzIndices.toList(),
        'actualCount': actualCount,
        'status': status,
        'lastPosition': {'surah': lastSurah, 'ayah': lastAyah},
      };

  static DayProgress fromJson(Map<String, dynamic> j) => DayProgress(
        date: j['date'] as String,
        targetJuzCount: j['targetJuzCount'] as int,
        readJuzIndices:
            Set<int>.from((j['readJuzIndices'] as List).map((e) => e as int)),
        actualCount: j['actualCount'] as int,
        status: j['status'] as String,
        lastSurah: (j['lastPosition']?['surah'] as int?) ?? 1,
        lastAyah: (j['lastPosition']?['ayah'] as int?) ?? 1,
      );
}

class QuranProgressService extends ChangeNotifier {
  static const _kKeyPrefix = 'quran.progress.'; // + YYYY-MM-DD
  static const _kLongestStreak = 'quran.progress._streak.longest';
  static const _kKhatamProgress =
      'quran.khatam.progress'; // Set<int> of juz indices
  static const _kKhatamCount = 'quran.khatam.count'; // int

  DayProgress? _today;

  DayProgress? get today => _today;

  Future<int> getKhatamCount() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kKhatamCount) ?? 0;
  }

  String _todayKey(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$_kKeyPrefix$y-$m-$d';
  }

  Future<void> startDayIfNeeded(int targetJuzCount) async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = _todayKey(now);
    final raw = p.getString(key);
    if (raw == null) {
      final dp = DayProgress(
        date: key.replaceFirst(_kKeyPrefix, ''),
        targetJuzCount: targetJuzCount,
        readJuzIndices: <int>{},
        actualCount: 0,
        status: 'pending',
        lastSurah: 1,
        lastAyah: 1,
      );
      await p.setString(key, jsonEncode(dp.toJson()));
      _today = dp;
      notifyListeners();
    } else {
      _today = DayProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      // لا نعيد كتابة target هنا؛ السجل يحتفظ بسنابشوت اليوم
    }
  }

  Future<void> updateLastPosition(int surah, int ayah) async {
    if (_today == null) return;
    _today = DayProgress(
      date: _today!.date,
      targetJuzCount: _today!.targetJuzCount,
      readJuzIndices: _today!.readJuzIndices,
      actualCount: _today!.actualCount,
      status: _today!.status,
      lastSurah: surah,
      lastAyah: ayah,
    );
    final p = await SharedPreferences.getInstance();
    await p.setString(
        '$_kKeyPrefix${_today!.date}', jsonEncode(_today!.toJson()));
    notifyListeners();
  }

  Future<void> markJuzRead(int juzIndex) async {
    if (_today == null) return;
    if (_today!.readJuzIndices.contains(juzIndex)) return;
    final newSet = {..._today!.readJuzIndices, juzIndex};
    final cnt = newSet.length;
    final status = cnt >= _today!.targetJuzCount
        ? 'done'
        : (cnt > 0 ? 'partial' : 'pending');
    _today = DayProgress(
      date: _today!.date,
      targetJuzCount: _today!.targetJuzCount,
      readJuzIndices: newSet,
      actualCount: cnt,
      status: status,
      lastSurah: _today!.lastSurah,
      lastAyah: _today!.lastAyah,
    );
    final p = await SharedPreferences.getInstance();
    if (!(await p.setString(
        '$_kKeyPrefix${_today!.date}', jsonEncode(_today!.toJson())))) {
      print('ERROR: Failed to write DayProgress to SharedPreferences');
    }
    if (status == 'done') {
      await _bumpStreaks();
    }

    // Update Khatam progress
    final rawKhatamProgress = p.getString(_kKhatamProgress);
    final Set<int> khatamProgress = rawKhatamProgress != null
        ? Set<int>.from(jsonDecode(rawKhatamProgress) as List)
        : <int>{};
    khatamProgress.add(juzIndex);
    if (!(await p.setString(
        _kKhatamProgress, jsonEncode(khatamProgress.toList())))) {
      print('ERROR: Failed to write Khatam progress to SharedPreferences');
    }

    if (khatamProgress.length >= 30) {
      int khatamCount = p.getInt(_kKhatamCount) ?? 0;
      khatamCount++;
      if (!(await p.setInt(_kKhatamCount, khatamCount))) {
        print('ERROR: Failed to write Khatam count to SharedPreferences');
      }
      if (!(await p.remove(_kKhatamProgress))) {
        // Reset for next Khatam
        print('ERROR: Failed to remove Khatam progress from SharedPreferences');
      }
    }
    notifyListeners();
  }

  Future<void> _bumpStreaks() async {
    final p = await SharedPreferences.getInstance();
    // نحسب السلسلة الحالية مباشرة من التخزين: نتراجع يومًا يومًا حتى نواجه يومًا غير مكتمل
    int streak = 0;
    DateTime cur = DateTime.now();
    while (true) {
      final y = cur.year.toString().padLeft(4, '0');
      final m = cur.month.toString().padLeft(2, '0');
      final d = cur.day.toString().padLeft(2, '0');
      final key = '$_kKeyPrefix$y-$m-$d';
      final raw = p.getString(key);
      if (raw == null) break;
      final dp = DayProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (dp.status != 'done') break;
      streak++;
      cur = cur.subtract(const Duration(days: 1));
    }
    final longest = p.getInt(_kLongestStreak) ?? 0;
    if (streak > longest) {
      await p.setInt(_kLongestStreak, streak);
    }
  }

  Future<int> currentStreak() async {
    final p = await SharedPreferences.getInstance();
    int streak = 0;
    DateTime cur = DateTime.now();
    while (true) {
      final y = cur.year.toString().padLeft(4, '0');
      final m = cur.month.toString().padLeft(2, '0');
      final d = cur.day.toString().padLeft(2, '0');
      final key = '$_kKeyPrefix$y-$m-$d';
      final raw = p.getString(key);
      if (raw == null) break;
      final dp = DayProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (dp.status != 'done') break;
      streak++;
      cur = cur.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<int> longestStreak() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kLongestStreak) ?? 0;
  }

  Future<List<Map<String, int>>> weeklyBreakdown() async {
    final p = await SharedPreferences.getInstance();
    final List<Map<String, int>> res = [];
    DateTime cur = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final y = cur.year.toString().padLeft(4, '0');
      final m = cur.month.toString().padLeft(2, '0');
      final d = cur.day.toString().padLeft(2, '0');
      final key = '$_kKeyPrefix$y-$m-$d';
      final raw = p.getString(key);
      if (raw == null) {
        res.add({'actual': 0, 'target': 0});
      } else {
        final dp =
            DayProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        res.add({'actual': dp.actualCount, 'target': dp.targetJuzCount});
      }
      cur = cur.subtract(const Duration(days: 1));
    }
    return res.reversed.toList();
  }

  Future<double> completionPercentLast7Days() async {
    final data = await weeklyBreakdown();
    int sumActual = 0, sumTarget = 0;
    for (final e in data) {
      sumActual += e['actual']!;
      sumTarget += e['target']!;
    }
    if (sumTarget == 0) return 0;
    return sumActual / sumTarget;
  }

  // ============ إحصاءات سنوية/شهرية ============
  Future<List<Map<String, int>>> monthlyTotalsForYear(int year) async {
    final p = await SharedPreferences.getInstance();
    final List<Map<String, int>> res = [];
    for (int month = 1; month <= 12; month++) {
      final last = DateTime(year, month + 1, 0);
      int sumActual = 0;
      int sumTarget = 0;
      int daysDone = 0;
      for (int day = 1; day <= last.day; day++) {
        final y = year.toString().padLeft(4, '0');
        final m = month.toString().padLeft(2, '0');
        final d = day.toString().padLeft(2, '0');
        final key = '$_kKeyPrefix$y-$m-$d';
        final raw = p.getString(key);
        if (raw == null) continue;
        final dp =
            DayProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        sumActual += dp.actualCount;
        sumTarget += dp.targetJuzCount;
        if (dp.status == 'done') daysDone++;
      }
      res.add({
        'month': month,
        'actual': sumActual,
        'target': sumTarget,
        'daysDone': daysDone,
        'daysTotal': last.day
      });
    }
    return res;
  }

  Future<Map<String, int>> yearSummary(int year) async {
    final monthly = await monthlyTotalsForYear(year);
    int totalActual = 0, totalTarget = 0, totalDaysDone = 0, totalDays = 0;
    for (final m in monthly) {
      totalActual += m['actual']!;
      totalTarget += m['target']!;
      totalDaysDone += m['daysDone']!;
      totalDays += m['daysTotal']!;
    }
    return {
      'actual': totalActual,
      'target': totalTarget,
      'daysDone': totalDaysDone,
      'daysTotal': totalDays,
    };
  }

  Future<List<Map<String, dynamic>>> dailyTotalsForMonth(
      int year, int month) async {
    final p = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> res = [];
    final last = DateTime(year, month + 1, 0);
    for (int day = 1; day <= last.day; day++) {
      final y = year.toString().padLeft(4, '0');
      final m = month.toString().padLeft(2, '0');
      final d = day.toString().padLeft(2, '0');
      final key = '$_kKeyPrefix$y-$m-$d';
      final raw = p.getString(key);
      if (raw == null) {
        res.add({'day': day, 'actual': 0, 'target': 0, 'status': 'pending'});
      } else {
        final dp =
            DayProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        res.add({
          'day': day,
          'actual': dp.actualCount,
          'target': dp.targetJuzCount,
          'status': dp.status
        });
      }
    }
    return res;
  }

  Future<DateTime?> firstProgressDate() async {
    final p = await SharedPreferences.getInstance();
    final keys = p.getKeys();
    DateTime? minDate;
    for (final k in keys) {
      if (!k.startsWith(_kKeyPrefix)) continue;
      final dateStr = k.substring(_kKeyPrefix.length);
      try {
        final parts = dateStr.split('-');
        if (parts.length != 3) continue;
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);
        final dt = DateTime(y, m, d);
        if (minDate == null || dt.isBefore(minDate)) {
          minDate = dt;
        }
      } catch (_) {}
    }
    return minDate;
  }

  Future<Map<String, int>?> lastPosition() async {
    final p = await SharedPreferences.getInstance();
    // ابدأ من اليوم وارجع للخلف حتى تجد آخر موضع محفوظ
    DateTime cur = DateTime.now();
    for (int i = 0; i < 400; i++) {
      // يغطي أكثر من سنة
      final y = cur.year.toString().padLeft(4, '0');
      final m = cur.month.toString().padLeft(2, '0');
      final d = cur.day.toString().padLeft(2, '0');
      final key = '$_kKeyPrefix$y-$m-$d';
      final raw = p.getString(key);
      if (raw != null) {
        final dp =
            DayProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        if (dp.lastSurah > 0 && dp.lastAyah > 0) {
          return {'surah': dp.lastSurah, 'ayah': dp.lastAyah};
        }
      }
      cur = cur.subtract(const Duration(days: 1));
    }
    return null;
  }
}
