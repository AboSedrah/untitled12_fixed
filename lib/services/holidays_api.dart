import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/holiday.dart';

class HolidaysApi {
  final Duration timeout;
  const HolidaysApi({
    this.timeout = const Duration(seconds: 10),
  });

  Future<List<Holiday>> publicHolidays(int year, String countryCode) async {
    final u = Uri.parse('$nagerBase/PublicHolidays/$year/$countryCode');
    final res = await http.get(u).timeout(timeout);
    if (res.statusCode != 200) return [];
    final List data = json.decode(res.body);
    return data.map<Holiday>((e) {
      final date = DateTime.parse(e['date']);
      return Holiday(
        name: e['localName'] ?? e['name'] ?? '',
        date: date,
      );
    }).toList();
  }
}