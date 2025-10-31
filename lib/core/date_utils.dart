import 'package:intl/intl.dart';
import '../models/hijri_date.dart';

class DateUtils {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime firstDayOfMonth(DateTime anchor) {
    return DateTime(anchor.year, anchor.month, 1);
  }

  static DateTime lastDayOfMonth(DateTime anchor) {
    return DateTime(anchor.year, anchor.month + 1, 0);
  }

  static int weekdayIndexFromSunday(DateTime d) {
    return d.weekday % 7;
  }

  static String ddMmYyyy(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  static String formatGDateLongAr(DateTime d) {
    final f = DateFormat('EEEE، d MMMM yyyy', 'ar');
    return f.format(d);
  }

  static String formatHijriDate(HijriDate date) {
    final months = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
      'جمادى الأولى', 'جمادى الآخرة', 'رجب',
      'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} هـ';
  }
}