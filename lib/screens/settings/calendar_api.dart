import '../../models/calendar_day.dart';
import '../../models/hijri_date.dart';
import '../../models/weather.dart';
import '../../repositories/calendar_repository.dart';
import '../../repositories/weather_repository.dart';

class CalendarApiFacade {
  final CalendarRepository calendarRepo;
  final WeatherRepository weatherRepo;

  CalendarApiFacade({
    required this.calendarRepo,
    required this.weatherRepo,
  });

  Future<List<CalendarDay>> fetchGregorianMonth({
    required int year,
    required int month,
    double? lat,
    double? lon,
  }) async {
    return calendarRepo.loadGregorianMonth(year, month);
  }

  Future<HijriDate> convertGregorianToHijri(DateTime g) {
    return calendarRepo.convertGToH(g);
  }

  Future<DateTime> convertHijriToGregorian(HijriDate h) {
    return calendarRepo.convertHToG(h);
  }

  Future<Weather?> fetchDayWeather({
    required DateTime day,
    required double lat,
    required double lon,
  }) {
    return weatherRepo.getWeatherForDate(day);
  }
}