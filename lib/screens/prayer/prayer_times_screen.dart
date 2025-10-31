// lib/screens/prayer/prayer_times_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/prayer_times_service.dart';
import 'package:audioplayers/audioplayers.dart';

class PrayerTimesScreen extends StatefulWidget {
  final String? highlight; // اسم الصلاة لتمييزها عندما نأتي من الإشعار
  const PrayerTimesScreen({super.key, this.highlight});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // لو فتحنا الشاشة من إشعار الصلاة، نقدر نشغّل الأذان (اختياري)
    // if (widget.highlight != null) _playAdhan();
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<PrayerTimesService>();
    final list = svc.getTodayPrayers();

    return Scaffold(
      appBar: AppBar(title: const Text('مواقيت اليوم')),
      body: ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, i) {
          final p = list[i];
          final isHL = (widget.highlight != null && widget.highlight == p.name);
          return ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(p.name),
            trailing: Text(svc.formatTime(p.time),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            tileColor: isHL ? Colors.red.withOpacity(0.1) : null,
          );
        },
      ),
    );
  }
}
