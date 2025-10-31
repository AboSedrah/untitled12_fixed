import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/weather.dart';

class WeatherApi {
  final Duration timeout;
  const WeatherApi({
    this.timeout = const Duration(seconds: 10),
  });

  Future<Weather?> dailyBrief({
    required double lat,
    required double lon,
    required DateTime day,
  }) async {
    final u = Uri.parse(
      '$openMeteoBase?latitude=$lat&longitude=$lon&timezone=auto'
          '&daily=weathercode,temperature_2m_max,temperature_2m_min'
          '&start_date=${_yyyyMmDd(day)}&end_date=${_yyyyMmDd(day)}',
    );
    final res = await http.get(u).timeout(timeout);
    if (res.statusCode != 200) return null;

    final j = json.decode(res.body);
    final daily = j['daily'];
    if (daily == null) return null;

    final code = (daily['weathercode'] as List).first;
    final tmax = (daily['temperature_2m_max'] as List).first.toDouble();
    final tmin = (daily['temperature_2m_min'] as List).first.toDouble();
    final description = _descriptionFor(code);
    return Weather(
      temperature: (tmax + tmin) / 2,
      description: description,
      code: code.toString(),
    );
  }

  String _yyyyMmDd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _descriptionFor(int code) {
    // مرجع Open-Meteo weathercode
    if ([0].contains(code)) return 'صافي';
    if ([1, 2, 3].contains(code)) return 'غائم جزئياً';
    if ([45, 48].contains(code)) return 'ضباب';
    if ([51, 53, 55, 56, 57].contains(code)) return 'رذاذ';
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'مطر';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return 'ثلج';
    if ([95, 96, 99].contains(code)) return 'عاصفة رعدية';
    return 'غائم';
  }
}