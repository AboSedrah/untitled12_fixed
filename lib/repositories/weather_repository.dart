// ...existing code...
import '../models/weather.dart';
import '../services/weather_api.dart';

class WeatherRepository {
  final WeatherApi api;

  WeatherRepository({WeatherApi? weatherApi})
      : api = weatherApi ?? const WeatherApi();

  Future<Weather?> getWeatherForDate(DateTime date) async {
    // في التطبيق الحقيقي: استخدم الإحداثيات المخزنة
    return api.dailyBrief(
      day: date,
      lat: 21.4225, // مكة المكرمة
      lon: 39.8262,
    );
  }
}
