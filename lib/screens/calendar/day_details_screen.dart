import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/date_utils.dart' as date_utils;
import '../../models/calendar_day.dart';
import '../../widgets/info_row.dart';
import '../../widgets/weather_icon.dart';
import 'conversion_panel.dart';
import '../../services/hijri_api.dart';

class DayDetailsScreen extends StatelessWidget {
  final CalendarDay day;

  const DayDetailsScreen({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final hijri = day.hijri;
    final weather = day.weather;
    final events = day.events;
    final holiday = day.holiday;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEEE, d MMMM y', 'ar').format(day.gregorian)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // التاريخ الهجري
            InfoRow(
              icon: Icons.calendar_month,
              text: 'التاريخ الهجري: ${date_utils.DateUtils.formatHijriDate(hijri)}',
            ),
            const SizedBox(height: 16),

            // الطقس
            if (weather != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حالة الطقس', // تم التصحيح
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      WeatherIcon(code: weather.code, size: 48),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weather.temperature.toStringAsFixed(1)}°C',
                            style: const TextStyle(fontSize: 24),
                          ),
                          Text(
                            weather.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // العطلة الرسمية
            if (holiday != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'عطلة رسمية', // تم التصحيح
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50], // تم التصحيح
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.celebration, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            holiday.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // الأحداث
            if (events.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الأحداث والمناسبات', // تم التصحيح
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...events.map((event) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (event.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(event.description),
                            ),
                        ],
                      ),
                    ),
                  )), // تم إزالة toList()
                  const SizedBox(height: 16),
                ],
              ),

            // لوحة التحويل
            ConversionPanel(
              api: HijriApi(),
              initialG: day.gregorian,
            ),
          ],
        ),
      ),
    );
  }
}