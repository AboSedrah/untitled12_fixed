import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fazkorony/services/stats_controller.dart';
import 'package:fazkorony/services/goals_controller.dart';
import 'package:fazkorony/services/badges_controller.dart';
import 'package:fazkorony/services/notifications_controller.dart';
import 'package:fazkorony/services/notification_service.dart';
import 'package:fazkorony/services/settings_service.dart';

class DhikrEvents {
  static Future<void> recordRead(BuildContext context,
      {String? category}) async {
    final settings = Provider.of<SettingsService>(context, listen: false);
    if (!settings.statsEnabled) return;

    await StatsController().onDhikrRead(category: category);

    // Gather aggregates
    final roll = await StatsController().recomputeMonthlyRollup(DateTime.now());
    final p = await SharedPreferences.getInstance();
    final currentStreak = p.getInt('dhikr.streak.current') ?? 0;
    final monthlyRegular = (roll['regularDays'] as int?) ?? 0;
    final monthlyTotal = (roll['totalDays'] as int?) ?? 30;

    // Evaluate goals and badges
    final goals = await GoalsController().evaluateAfterRead(
      currentStreak: currentStreak,
      monthlyRegularDays: monthlyRegular,
      monthlyTotal: monthlyTotal,
    );
    final awarded = await BadgesController().awardIfEligible(
      currentStreak: currentStreak,
      monthlyRegularDays: monthlyRegular,
      monthlyTotal: monthlyTotal,
    );

    // Send congrats if any
    if (goals.completedGoals.isNotEmpty || awarded.isNotEmpty) {
      final notif = Provider.of<NotificationService>(context, listen: false);
      await NotificationsController(notif.notificationsPlugin).sendCongrats(
          title: 'أحسنت!',
          body: goals.completedGoals.isNotEmpty
              ? 'حققت هدفًا جديدًا في الأذكار.'
              : 'نلت وسامًا جديدًا في الاستمرار.');
    }
  }
}
