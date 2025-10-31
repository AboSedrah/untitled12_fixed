import 'package:flutter/material.dart';
import 'screens/azkar/azkar_menu.dart';
import 'screens/azkar/quran_duas_screen.dart';
import 'screens/calendar/calendar_home.dart';
import 'screens/home/home_screen.dart';
import 'screens/azkar/zikr_sabah.dart';
import 'screens/azkar/zikr_masaa.dart';
import 'screens/azkar/zikr_noum.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/azkar': (context) => AzkarCategoryScreen(), // تم إزالة const
        '/quran_duas': (context) => QuranDuasScreen(), // تم إزالة const
        '/calendar': (context) => CalendarHome(), // تم إزالة const
        '/zikr_sabah': (context) => ZikrSabahScreen(), // تم إزالة const
        '/zikr_masa': (context) => EveningAzkarScreen(), // تم إزالة const
        '/zikr_noum': (context) => ZikrNoumScreen(), // تم إزالة const
      },
      home: const HomeScreen(),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void handleNotificationTap(String? payload) {
  if (payload != null) {
    navigatorKey.currentState?.pushNamed('/$payload');
  }
}