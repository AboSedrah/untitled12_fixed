import 'hijri_date.dart';
import 'weather.dart';
import 'event.dart';
import 'holiday.dart';

class CalendarDay {
  final DateTime gregorian;
  final HijriDate hijri;
  final Weather? weather;
  final List<Event> events;
  final Holiday? holiday;

  CalendarDay({
    required this.gregorian,
    required this.hijri,
    this.weather,
    this.events = const [],
    this.holiday,
  });

  bool get hasEvents => events.isNotEmpty;
  bool get isHoliday => holiday != null;
  bool get isWeekend => gregorian.weekday == DateTime.friday || gregorian.weekday == DateTime.saturday;

  bool isToday() {
    final now = DateTime.now();
    return gregorian.year == now.year &&
        gregorian.month == now.month &&
        gregorian.day == now.day;
  }

  @override
  String toString() {
    return '${gregorian.day}/${gregorian.month}/${gregorian.year} (${hijri.day}/${hijri.month}/${hijri.year})';
  }
}