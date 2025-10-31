import 'dart:async';
import 'dart:collection';
import '../models/calendar_day.dart';
import '../models/hijri_date.dart';
import '../services/hijri_api.dart';
import '../repositories/weather_repository.dart';
import '../repositories/holidays_repository.dart';
import '../repositories/events_repository.dart';

class CalendarRepository {
  final HijriApi hijriApi;
  final WeatherRepository weatherRepo;
  final HolidaysRepository holidaysRepo;
  final EventsRepository eventsRepo;

  final Map<String, List<CalendarDay>> _monthCache = HashMap();

  CalendarRepository({
    required this.hijriApi, // تم التصحيح
    required this.weatherRepo,
    required this.holidaysRepo,
    required this.eventsRepo,
  });

  Future<List<CalendarDay>> loadGregorianMonth(int year, int month) async {
    final key = 'G-$year-$month';
    final cached = _monthCache[key];
    if (cached != null) return cached;

    final baseDays = await hijriApi.gMonth(year, month);
    final days = await Future.wait(
      baseDays.map((day) => _enrichDayData(day)),
    );

    _monthCache[key] = days;
    return days;
  }

  Future<CalendarDay> _enrichDayData(CalendarDay baseDay) async {
    final date = baseDay.gregorian;

    final weather = await weatherRepo.getWeatherForDate(date);
    final holiday = await holidaysRepo.getHolidayForDate(date);
    final events = await eventsRepo.getEventsForDate(date);

    return CalendarDay(
      gregorian: date,
      hijri: baseDay.hijri,
      weather: weather,
      holiday: holiday,
      events: events,
    );
  }

  Future<HijriDate> convertGToH(DateTime g) => hijriApi.gToH(g);
  Future<DateTime> convertHToG(HijriDate h) => hijriApi.hToG(h);

  Future<List<CalendarDay>> navigateToMonth(DateTime monthStart) async {
    return loadGregorianMonth(monthStart.year, monthStart.month);
  }

  void clearCache() {
    _monthCache.clear();
  }
}