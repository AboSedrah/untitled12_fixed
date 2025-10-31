import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../models/calendar_day.dart';
import '../../models/hijri_date.dart';
import '../settings/calendar_api.dart';
import '../../widgets/calendar_month_view.dart';
import 'day_details_screen.dart';
import '../../services/geo_api.dart';
import '../../repositories/calendar_repository.dart';
import '../../repositories/weather_repository.dart';
import '../../repositories/holidays_repository.dart';
import '../../repositories/events_repository.dart';
import '../../services/hijri_api.dart';
import 'location_selector_screen.dart';
import '../../services/prayer_times_service.dart';

const List<String> gregorianMonthsAr = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر'
];

const List<String> hijriMonthsAr = [
  'مُحَرَّم',
  'صَفَر',
  'رَبِيع ٱلْأَوَّل',
  'رَبِيع ٱلْآخِر',
  'جُمَادَىٰ ٱلْأُولَىٰ',
  'جُمَادَىٰ ٱلْآخِرَة',
  'رَجَب',
  'شَعْبَان',
  'رَمَضَان',
  'شَوَّال',
  'ذُو ٱلْقَعْدَة',
  'ذُو ٱلْحِجَّة'
];

class CalendarHome extends StatefulWidget {
  const CalendarHome({super.key});

  @override
  State<CalendarHome> createState() => _CalendarHomeState();
}

class _CalendarHomeState extends State<CalendarHome> {
  late DateTime _currentMonth;
  late CalendarApiFacade api;
  final GeoApi _geo = const GeoApi();

  double? userLat;
  double? userLon;
  String? cityName;

  Future<List<CalendarDay>>? _monthFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);

    api = CalendarApiFacade(
      calendarRepo: CalendarRepository(
        hijriApi: HijriApi(),
        weatherRepo: WeatherRepository(),
        holidaysRepo: HolidaysRepository(),
        eventsRepo: EventsRepository(),
      ),
      weatherRepo: WeatherRepository(),
    );

    _loadSavedLocation();
    _monthFuture = _loadMonth();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('savedCity');
    final savedLat = prefs.getDouble('savedLat');
    final savedLon = prefs.getDouble('savedLon');

    if (savedCity != null && savedLat != null && savedLon != null) {
      setState(() {
        cityName = savedCity;
        userLat = savedLat;
        userLon = savedLon;
      });
      if (mounted) {
        context.read<PrayerTimesService>().updateLocation(savedLat, savedLon);
      }
    } else {
      _tryAutoLocation();
    }
  }

  Future<void> _tryAutoLocation() async {
    try {
      final position = await _determinePosition();
      final res = await _geo.reverseGeocode(position.latitude, position.longitude);

      final city = res?.locality ?? 'غير معروف';
      await _saveLocation(city, position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        cityName = city;
        userLat = position.latitude;
        userLon = position.longitude;
        _monthFuture = _loadMonth();
      });

      context.read<PrayerTimesService>().updateLocation(position.latitude, position.longitude);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحصول على الموقع: $e')),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'خدمة الموقع غير مفعلة';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'تم رفض الأذونات';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'تم رفض الأذونات بشكل دائم';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _saveLocation(String city, double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedCity', city);
    await prefs.setDouble('savedLat', lat);
    await prefs.setDouble('savedLon', lon);
  }

  Future<List<CalendarDay>> _loadMonth() {
    return api.fetchGregorianMonth(
      year: _currentMonth.year,
      month: _currentMonth.month,
      lat: userLat,
      lon: userLon,
    );
  }

  void _shiftMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta, 1);
      _monthFuture = _loadMonth();
    });
  }

  void _resetToToday() {
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month, 1);
      _monthFuture = _loadMonth();
    });
  }

  Future<void> _refresh() async {
    setState(() => _monthFuture = _loadMonth());
    await _monthFuture;
  }

  Future<void> _selectLocation() async {
    final location = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSelectorScreen()),
    );

    if (location != null) {
      await _saveLocation(location['city'], location['lat'], location['lon']);
      if (!mounted) return;
      setState(() {
        cityName = location['city'];
        userLat = location['lat'];
        userLon = location['lon'];
        _monthFuture = _loadMonth();
      });
      context.read<PrayerTimesService>().updateLocation(location['lat'], location['lon']);
    }
  }

  void _clearCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedCity');
    await prefs.remove('savedLat');
    await prefs.remove('savedLon');

    setState(() {
      userLat = null;
      userLon = null;
      cityName = null;
      _monthFuture = _loadMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = gregorianMonthsAr[_currentMonth.month - 1];
    final hijriDate = HijriDate.fromGregorian(_currentMonth);
    final hijriMonthName = hijriMonthsAr[hijriDate.month - 1];
    final hijriYear = hijriDate.year;

    final ym = '$monthName ${_currentMonth.year}';
    final hijriLabel = '$hijriMonthName $hijriYear هـ';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(ym, style: const TextStyle(fontSize: 18)),
              Text(hijriLabel, style: const TextStyle(fontSize: 14)),
            ],
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(onPressed: _resetToToday, icon: const Icon(Icons.today), tooltip: 'اليوم'),
          ],
        ),
        body: Column(
          children: [
            // ✅ هذه الدالة معرّفة بالأسفل
            _buildTopControlBar(context, ym, hijriLabel),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<CalendarDay>>(
                  future: _monthFuture,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return _buildSkeletonLoader();
                    }

                    if (snap.hasError) {
                      return _buildErrorState(snap.error.toString());
                    }

                    final days = snap.data ?? const <CalendarDay>[];
                    if (days.isEmpty) {
                      return _buildEmptyState();
                    }

                    return CalendarMonthView(
                      currentMonth: _currentMonth,
                      days: days,
                      onDaySelected: (day) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DayDetailsScreen(day: day)),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // الدوال المساعدة (كانت ناقصة)
  // -------------------------

  Widget _buildTopControlBar(BuildContext context, String monthLabel, String hijriLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            spreadRadius: 1,
            blurRadius: 3,
          )
        ],
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          // معلومات التاريخ + أسهم التنقل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shiftMonth(-1),
                tooltip: 'الشهر السابق',
              ),
              Column(
                children: [
                  Text(
                    monthLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    hijriLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _shiftMonth(1),
                tooltip: 'الشهر التالي',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // معلومات/اختيار الموقع
          if (cityName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 8),
                  Text(cityName!),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _clearCity,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: _selectLocation,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('تحديد الموقع'),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[200]!,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('حدث خطأ: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          const Text('لا توجد بيانات لهذا الشهر', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _resetToToday,
            icon: const Icon(Icons.today),
            label: const Text('العودة للشهر الحالي'),
          ),
        ],
      ),
    );
  }
}