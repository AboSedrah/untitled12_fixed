import 'package:flutter/material.dart';
import '../../models/calendar_day.dart';
import 'day_cell.dart';

class CalendarMonthView extends StatelessWidget {
  const CalendarMonthView({
    super.key,
    required this.currentMonth,
    required this.days,
    required this.onDaySelected,
  });

  final DateTime currentMonth;
  final List<CalendarDay> days;
  final ValueChanged<CalendarDay> onDaySelected;

  // أسماء أيام الأسبوع كاملة
  static const _weekdaysFullAr = <String>[
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شريط أسماء الأيام (كاملة)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: List.generate(7, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    _weekdaysFullAr[i],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // شبكة الأيام
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final day = days[index];

              return DayCell(
                day: day,
                isCurrentMonth: day.gregorian.month == currentMonth.month,
                onTap: () => onDaySelected(day),
              );
            },
          ),
        ),
      ],
    );
  }
}