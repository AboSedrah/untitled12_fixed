class HijriDate {
  final int year;
  final int month;
  final int day;
  final String monthAr;
  final String weekdayAr;

  HijriDate({
    required this.year,
    required this.month,
    required this.day,
    required this.monthAr,
    required this.weekdayAr,
  });

  factory HijriDate.fromGregorian(DateTime date) {
    // هذا نموذج مبسط، في التطبيق الحقيقي سيتم التحويل عبر API
    return HijriDate(
      year: 1447,
      month: 2,
      day: 15,
      monthAr: 'شعبان',
      weekdayAr: 'الجمعة',
    );
  }

  @override
  String toString() {
    return '$year/$month/$day';
  }
}