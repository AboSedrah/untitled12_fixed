import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/hijri_date.dart';
import '../models/calendar_day.dart';

class HijriApi {
  final Duration timeout;
  const HijriApi({
    this.timeout = const Duration(seconds: 12),
  });

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }

  Future<HijriDate> gToH(DateTime g) async {
    final url = Uri.parse('$aladhanBase/gToH?date=${_formatDate(g)}');
    final res = await http.get(url).timeout(timeout);
    if (res.statusCode != 200) {
      throw Exception('gToH HTTP ${res.statusCode}');
    }
    final j = json.decode(res.body);
    final h = j['data']['hijri'];
    return _parseHijri(h);
  }

  Future<DateTime> hToG(HijriDate h) async {
    final url = Uri.parse('$aladhanBase/hToG?date=${h.day}-${h.month}-${h.year}');
    final res = await http.get(url).timeout(timeout);
    if (res.statusCode != 200) {
      throw Exception('hToG HTTP ${res.statusCode}');
    }
    final j = json.decode(res.body);
    final g = j['data']['gregorian']['date'] as String;
    final p = g.split('-').map(int.parse).toList();
    return DateTime(p[2], p[1], p[0]);
  }

  Future<List<CalendarDay>> gMonth(int year, int month) async {
    final url = Uri.parse('$aladhanBase/gToHCalendar/$month/$year');
    final res = await http.get(url).timeout(timeout);
    if (res.statusCode != 200) {
      throw Exception('gMonth HTTP ${res.statusCode}');
    }
    final List data = (json.decode(res.body))['data'];
    return data.map<CalendarDay>((d) {
      final gStr = d['gregorian']['date'] as String;
      final p = gStr.split('-').map(int.parse).toList();
      final g = DateTime(p[2], p[1], p[0]);
      final h = _parseHijri(d['hijri']);
      return CalendarDay(gregorian: g, hijri: h);
    }).toList();
  }

  HijriDate _parseHijri(Map h) => HijriDate(
    year: int.parse(h['year']),
    month: int.parse(h['month']['number'].toString()),
    day: int.parse(h['day']),
    monthAr: h['month']['ar'] ?? '',
    weekdayAr: h['weekday']['ar'] ?? '',
  );
}