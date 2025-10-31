import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GoalResult {
  final List<String> completedGoals;
  final Map<String, double> progress; // id -> 0..1
  GoalResult(this.completedGoals, this.progress);
}

class GoalsController {
  // أهداف افتراضية مبسطة
  static const List<Map<String, dynamic>> defaultGoals = [
    {'id': 'streak_3', 'type': 'streak_consecutive_days', 'target': 3},
    {'id': 'streak_7', 'type': 'streak_consecutive_days', 'target': 7},
    {'id': 'streak_30', 'type': 'streak_consecutive_days', 'target': 30},
    {'id': 'monthly_10', 'type': 'monthly_regular_days', 'target': 10},
  ];

  Future<void> setActiveGoals(List<Map<String, dynamic>> goals) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('dhikr.goal.active', json.encode(goals));
  }

  Future<List<Map<String, dynamic>>> getActiveGoals() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('dhikr.goal.active');
    if (raw == null) return defaultGoals;
    try {
      final List list = json.decode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return defaultGoals;
    }
  }

  Future<GoalResult> evaluateAfterRead({required int currentStreak, required int monthlyRegularDays, required int monthlyTotal,}) async {
    final goals = await getActiveGoals();
    final completed = <String>[];
    final progress = <String, double>{};
    for (final g in goals) {
      final id = g['id'] as String;
      final type = g['type'] as String;
      final target = (g['target'] as num).toInt();
      if (type == 'streak_consecutive_days') {
        progress[id] = (currentStreak / target).clamp(0.0, 1.0);
        if (currentStreak >= target) completed.add(id);
      } else if (type == 'monthly_regular_days') {
        progress[id] = (monthlyRegularDays / target).clamp(0.0, 1.0);
        if (monthlyRegularDays >= target) completed.add(id);
      }
    }
    return GoalResult(completed, progress);
  }
}


