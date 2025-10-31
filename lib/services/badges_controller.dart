import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BadgesController {
  static const List<String> allBadges = [
    'badge_week_full_regular',
    'badge_streak_7',
    'badge_streak_14',
    'badge_streak_30',
    'badge_month_target_met',
  ];

  Future<Set<String>> _earned() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('dhikr.badges.earned');
    if (raw == null) return {};
    try {
      final List list = json.decode(raw) as List;
      return list.cast<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<Set<String>> getEarned() async {
    return _earned();
  }

  Future<void> _save(Set<String> earned) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('dhikr.badges.earned', json.encode(earned.toList()));
  }

  Future<List<String>> awardIfEligible({required int currentStreak, required int monthlyRegularDays, required int monthlyTotal}) async {
    final earned = await _earned();
    final newly = <String>[];
    if (currentStreak >= 7 && !earned.contains('badge_streak_7')) { earned.add('badge_streak_7'); newly.add('badge_streak_7'); }
    if (currentStreak >= 14 && !earned.contains('badge_streak_14')) { earned.add('badge_streak_14'); newly.add('badge_streak_14'); }
    if (currentStreak >= 30 && !earned.contains('badge_streak_30')) { earned.add('badge_streak_30'); newly.add('badge_streak_30'); }
    if (monthlyTotal > 0 && (monthlyRegularDays / monthlyTotal) >= 0.7 && !earned.contains('badge_month_target_met')) {
      earned.add('badge_month_target_met'); newly.add('badge_month_target_met');
    }
    await _save(earned);
    return newly;
  }
}


