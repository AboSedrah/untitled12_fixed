// lib/screens/calendar/holidays_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/holiday.dart'; // Added missing import

class HolidaysScreen extends StatefulWidget {
  final String countryCode;
  final int year;

  const HolidaysScreen({
    super.key,
    required this.countryCode,
    required this.year,
  });

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  late Future<List<Holiday>> _holidaysFuture; // Declared the future

  Future<List<Holiday>> fetchPublicHolidays() async {
    // Implementation here
    return [];
  }

  @override
  void initState() {
    super.initState();
    _holidaysFuture = fetchPublicHolidays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('العطل الرسمية ${widget.countryCode} - ${widget.year}'),
      ),
      body: FutureBuilder<List<Holiday>>(
        future: _holidaysFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final holidays = snapshot.data ?? [];
          if (holidays.isEmpty) {
            return const Center(child: Text('لا توجد عطل رسمية لهذا العام'));
          }

          return ListView.builder(
            itemCount: holidays.length,
            itemBuilder: (context, index) {
              final holiday = holidays[index];
              return ListTile(
                title: Text(holiday.name),
                subtitle: Text(DateFormat.yMMMMd('ar').format(holiday.date)),
                leading: const Icon(Icons.celebration, color: Colors.red),
              );
            },
          );
        },
      ),
    );
  }
}
