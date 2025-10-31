import 'package:flutter/material.dart';
import '../models/calendar_day.dart';
import 'weather_icon.dart';

class DayCell extends StatelessWidget {
  final CalendarDay day;
  final bool isSelected;
  final bool isCurrentMonth;
  final VoidCallback onTap;

  const DayCell({
    super.key,
    required this.day,
    this.isSelected = false,
    required this.isCurrentMonth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = day.isToday();
    final isHoliday = day.isHoliday;
    final hasEvents = day.hasEvents;
    final hasWeather = day.weather != null;

    // تحديد الألوان حسب الحالة
    final baseColor = isCurrentMonth
        ? (isToday
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface)
        : Theme.of(context).disabledColor;

    final holidayColor = Theme.of(context).colorScheme.error;
    final backgroundColor = isSelected
        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          )
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // خلفية العطلة
            if (isHoliday)
              Container(
                decoration: BoxDecoration(
                  color: holidayColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

            // التاريخ الميلادي
            Positioned(
              top: 4,
              right: 4,
              child: Text(
                '${day.gregorian.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: baseColor,
                ),
              ),
            ),

            // التاريخ الهجري
            Positioned(
              bottom: 4,
              left: 4,
              child: Text(
                '${day.hijri.day}',
                style: TextStyle(
                  fontSize: 12,
                  color: baseColor.withOpacity(0.8),
                ),
              ),
            ),

            // أيقونة الطقس (أعلى اليسار)
            if (hasWeather)
              Positioned(
                top: 4,
                left: 4,
                child: WeatherIcon(
                  code: day.weather!.code,
                  size: 16,
                ),
              ),

            // مؤشر الأحداث (أسفل اليمين)
            if (hasEvents)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // رمز العطلة (مركز الخلية)
            if (isHoliday)
              const Center(
                child: Icon(
                  Icons.celebration,
                  size: 18,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}