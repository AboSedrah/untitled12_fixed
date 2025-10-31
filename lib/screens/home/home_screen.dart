// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import '../../services/prayer_times_service.dart';
import '../../services/notification_service.dart';
import '../../services/prayer_notification_service.dart';
import '../../services/stats_controller.dart';
import '../calendar/calendar_home.dart';
import '../azkar/azkar_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  PrayerTime? _nextPrayer;
  String _nextPrayerTime = '';
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    final svc = context.read<PrayerTimesService>();
    _tickWithService(svc); // أول تحديث
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _tickWithService(svc);
    });
  }

  void _tickWithService(PrayerTimesService svc) {
    final pair = svc.tick();
    final np = pair.key;
    final rem = pair.value;
    if (np != null && rem != null) {
      setState(() {
        _nextPrayer = np;
        _nextPrayerTime = svc.formatTime(np.time);
        _timeRemaining = svc.formatDuration(rem);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.now();
    final String hijriLabel =
        '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

    final List<_MenuItem> mainItems = [
      _MenuItem(
        label: _nextPrayer != null
            ? '${_nextPrayer!.name}\n$_nextPrayerTime'
            : 'جاري التحميل...',
        subLabel: _nextPrayer != null ? 'متبقي: $_timeRemaining' : null,
        color: Colors.red.shade800,
        icon: Icons.access_time,
        onTap: () => Navigator.pushNamed(context, '/prayer_times'),
      ),
      _MenuItem(
        label: 'الأذكار',
        color: Colors.orange.shade700,
        icon: Icons.wb_sunny,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AzkarCategoryScreen())),
      ),
      _MenuItem(
        label: 'القبلة',
        color: Colors.grey,
        icon: Icons.explore,
        route: '/qibla',
      ),
      _MenuItem(
        label: 'الحج والعمرة',
        color: Colors.grey.shade400,
        icon: Icons.account_balance,
        route: '/hajj',
      ),
      _MenuItem(
        label: 'التقويم الهجري',
        subLabel: hijriLabel,
        color: Colors.red,
        icon: Icons.calendar_today,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarHome())),
      ),
      _MenuItem(
        label: 'القرآن الكريم',
        color: Colors.green.shade700,
        icon: Icons.menu_book,
        route: '/quran',
      ),
      _MenuItem(
        label: 'الإحصاءات',
        color: Colors.blueGrey,
        icon: Icons.insights,
        route: '/stats',
      ),
      _MenuItem(
        label: 'المذكرة الإسلامية',
        color: Colors.brown,
        icon: Icons.task_alt,
        route: '/todo',
      ),
      _MenuItem(
        label: 'الإعدادات',
        color: Colors.blueGrey,
        icon: Icons.settings,
        route: '/settings',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('فاذكروني'),
        actions: [
          // زر الاختبارات (يظهر فقط في Debug)
          if (kDebugMode)
            IconButton(
              tooltip: 'اختبارات الإشعار',
              icon: const Icon(Icons.science_outlined),
              onPressed: _openTestSheet,
            ),
          IconButton(
            tooltip: 'الإحصاءات',
            icon: const Icon(Icons.insights),
            onPressed: () => Navigator.pushNamed(context, '/stats'),
          ),
          IconButton(icon: const Icon(Icons.email), onPressed: () {}),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
          IconButton(
            tooltip: 'الإعدادات',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (DateTime.now().weekday == DateTime.friday)
              _WeeklyDigestCard(),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: mainItems.map((item) {
                  return GestureDetector(
                    onTap: () {
                      if (item.onTap != null) {
                        item.onTap!();
                      } else if (item.route != null) Navigator.pushNamed(context, item.route!);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.icon, size: 40, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (item.subLabel != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.subLabel!,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTestSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('اختبار سريع للإشعارات'),
                subtitle: Text('سيتم الإرسال بعد ثوانٍ قليلة'),
              ),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('أذكار الصباح بعد 5 ثوانٍ'),
                onTap: () {
                  NotificationService().scheduleTestAzkar(
                    payload: 'zikr_sabah', inSeconds: 5,
                  );
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.nightlight_round),
                title: const Text('أذكار المساء بعد 5 ثوانٍ'),
                onTap: () {
                  NotificationService().scheduleTestAzkar(
                    payload: 'zikr_masa', inSeconds: 5,
                  );
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('أذكار النوم بعد 5 ثوانٍ'),
                onTap: () {
                  NotificationService().scheduleTestAzkar(
                    payload: 'zikr_noum', inSeconds: 5,
                  );
                  Navigator.pop(ctx);
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.access_alarm),
                title: const Text('صلاة الفجر بعد 8 ثوانٍ (بصوت الأذان)'),
                onTap: () {
                  PrayerNotificationService(NotificationService().notificationsPlugin)
                      .scheduleTestPrayer(name: 'الفجر', inSeconds: 8);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('تكبيرات العشر بعد 10 ثوانٍ'),
                onTap: () {
                  PrayerNotificationService(NotificationService().notificationsPlugin)
                      .scheduleTestTakbeer(inSeconds: 10);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final String label;
  final String? subLabel;
  final Color color;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;

  _MenuItem({
    required this.label,
    this.subLabel,
    required this.color,
    required this.icon,
    this.route,
    this.onTap,
  });
}

class _WeeklyDigestCard extends StatefulWidget {
  @override
  State<_WeeklyDigestCard> createState() => _WeeklyDigestCardState();
}

class _WeeklyDigestCardState extends State<_WeeklyDigestCard> {
  String _summary = '';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final roll = await StatsController().recomputeMonthlyRollup(DateTime.now());
    setState(() {
      _summary = 'أيام منتظمة هذا الشهر: ${roll['regularDays']}/${roll['totalDays']} (${(roll['percentage'] as double).toStringAsFixed(0)}%)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade50,
      child: ListTile(
        leading: const Icon(Icons.insights, color: Colors.indigo),
        title: const Text('ملخص الجمعة'),
        subtitle: Text(_summary.isEmpty ? '...' : _summary),
        trailing: TextButton(
          onPressed: () => Navigator.pushNamed(context, '/stats'),
          child: const Text('عرض الإحصاءات'),
        ),
      ),
    );
  }
}
