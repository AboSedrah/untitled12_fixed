import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static final StatsService _i = StatsService._internal();
  factory StatsService() => _i;
  StatsService._internal();

  Future<String> _todayKey() async {
    final now = DateTime.now();
    final ds = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return 'dhikr.stats.$ds';
  }

  Future<void> incrementToday() async {
    final p = await SharedPreferences.getInstance();
    final k = await _todayKey();
    final count = p.getInt('$k.count') ?? 0;
    await p.setInt('$k.count', count + 1);
    await p.setString('$k.status', 'regular');
    // تحديث أطول سلسلة مبسّط
    final streak = (p.getInt('dhikr.streak.current') ?? 0) + (count == 0 ? 1 : 0);
    await p.setInt('dhikr.streak.current', streak);
    final longest = p.getInt('dhikr.streak.longest') ?? 0;
    if (streak > longest) await p.setInt('dhikr.streak.longest', streak);
  }

  Future<void> midnightRollover() async {
    final p = await SharedPreferences.getInstance();
    final k = await _todayKey();
    final count = p.getInt('$k.count') ?? 0;
    if (count == 0) {
      await p.setString('$k.status', 'missed');
      await p.setInt('dhikr.streak.current', 0);
    }
  }

  Future<Map<String, dynamic>> readSummary() async {
    final p = await SharedPreferences.getInstance();
    final longest = p.getInt('dhikr.streak.longest') ?? 0;
    final current = p.getInt('dhikr.streak.current') ?? 0;
    return {
      'longestStreak': longest,
      'currentStreak': current,
    };
  }
}


