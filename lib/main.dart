// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/quran_ui/views/quran_sura_list.dart';
import 'models/quran_audio/player_bar_bloc.dart';
import 'models/quran_audio/player_bloc_bloc.dart';
import 'models/quran_audio/quran_page_player_bloc.dart';
import 'simple_todo.dart';

// الخدمات
import 'services/prayer_times_service.dart';
import 'services/notification_service.dart';
import 'services/prayer_notification_service.dart';
import 'services/settings_service.dart';
import 'core/hive_helper.dart';
import 'screens/settings/settings_screen.dart';
import 'services/settings_controller.dart';
import 'services/quran_progress_service.dart';
import 'services/stats_controller.dart';
import 'services/quran_data_service.dart';

// الشاشات الأساسية
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/prayer/prayer_times_screen.dart';
import 'screens/prayer/qibla_screen.dart';
import 'screens/hajj/hajj_umrah_screen.dart';
import 'screens/stats/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar_SA', null);
  // تأكد من تهيئة Hive والمناطق الزمنية قبل إنشاء أي خدمة قد تستخدمهما
  await initializeHive();

  // Hide system navigation bars and make them transparent by default.
  // Use immersiveSticky so the system bars remain hidden and appear
  // transiently when the user swipes from the edge (closest to "show on press").
  // This applies app-wide; if you prefer to enable per-screen, move to that screen's initState.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    // Keep icons visible; adjust brightness if needed.
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // تهيئة الخدمات
  final settings = SettingsService();
  final prayerTimes = PrayerTimesService();
  final notifications = NotificationService();
  final quranDataService = QuranDataService();

  // تهيئة NotificationService (يشمل تهيئة المناطق الزمنية)
  await notifications.init();
  final prayerNotifications =
      PrayerNotificationService(notifications.notificationsPlugin);
  final quranProgress = QuranProgressService();
  final stats = StatsController();
  final settingsController = SettingsController();

  settingsController.bind(
      settings: settings,
      notifications: notifications,
      plugin: notifications.notificationsPlugin);

  runApp(MyApp(
    settings: settings,
    prayerTimes: prayerTimes,
    notifications: notifications,
    prayerNotifications: prayerNotifications,
    quranProgress: quranProgress,
    stats: stats,
    settingsController: settingsController,
    quranDataService: quranDataService,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settings,
    required this.prayerTimes,
    required this.notifications,
    required this.prayerNotifications,
    required this.quranProgress,
    required this.stats,
    required this.settingsController,
    required this.quranDataService,
  });

  final SettingsService settings;
  final PrayerTimesService prayerTimes;
  final NotificationService notifications;
  final PrayerNotificationService prayerNotifications;
  final QuranProgressService quranProgress;
  final StatsController stats;
  final SettingsController settingsController;
  final QuranDataService quranDataService;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settings),
            ChangeNotifierProvider.value(value: prayerTimes),
            ChangeNotifierProvider.value(value: quranProgress),
            ChangeNotifierProvider.value(value: stats),
            Provider.value(value: notifications),
            Provider.value(value: prayerNotifications),
            Provider.value(value: settingsController),
            Provider.value(value: quranDataService),
            // Player related blocs provided at app level so Quran pages can read them
            Provider(create: (_) => PlayerBarBloc()),
            Provider(
                create: (context) => PlayerBlocBloc(
                    playerBarBloc:
                        Provider.of<PlayerBarBloc>(context, listen: false))),
            Provider(create: (_) => QuranPagePlayerBloc()),
          ],
          child: MaterialApp(
            title: 'Fazkorony',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar', 'SA')],
            locale: const Locale('ar', 'SA'),
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/prayer_times': (context) => const PrayerTimesScreen(),
              '/qibla': (context) => const QiblaScreen(),
              '/hajj': (context) => const HajjUmrahScreen(),
              '/quran': (context) => SurahListPage(quranDataService: quranDataService),
              '/stats': (context) => const StatsScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/todo': (context) => const SimpleTodoScreen(),
            },
          ),
        );
      },
    );
  }
}
