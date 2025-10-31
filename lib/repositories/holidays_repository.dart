import '../models/holiday.dart';
import '../services/holidays_api.dart';

class HolidaysRepository {
  final HolidaysApi api;

  HolidaysRepository({HolidaysApi? holidaysApi})
      : api = holidaysApi ?? const HolidaysApi();

  Future<Holiday?> getHolidayForDate(DateTime date) async {
    // في التطبيق الحقيقي: جلب العطل حسب البلد
    return null;
  }
}