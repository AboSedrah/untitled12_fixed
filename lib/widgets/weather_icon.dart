import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String? code; // كود الطقس (إن توفر)
  final double size;

  const WeatherIcon({
    super.key,
    required this.code,
    this.size = 28
  });

  @override
  Widget build(BuildContext context) {
    final icon = _mapCodeToIcon(code);
    return Icon(icon, size: size);
  }

  IconData _mapCodeToIcon(String? c) {
    if (c == null) return Icons.help_outline;

    // تحويل الكود إلى رقم إن أمكن
    int? code = int.tryParse(c);
    if (code == null) return Icons.help_outline;

    // أمثلة بسيطة: عدّل التعيين حسب API اللي تستخدمه
    // أكواد Open-Meteo (WMO) الشائعة:
    if (code == 0) return Icons.wb_sunny;                       // صافٍ
    if (code == 1 || code == 2) return Icons.wb_sunny_outlined; // غالبًا صافٍ/قليل السحب
    if (code == 3) return Icons.cloud;                          // غائم
    if (code == 45 || code == 48) return Icons.foggy;           // ضباب
    if (code == 51 || code == 53 || code == 55) return Icons.grain; // رذاذ
    if (code == 61 || code == 63 || code == 65) return Icons.umbrella; // مطر
    if (code == 71 || code == 73 || code == 75) return Icons.ac_unit; // ثلج
    if (code == 80 || code == 81 || code == 82) return Icons.grain;   // زخات مطر
    if (code == 95 || code == 96 || code == 99) return Icons.thunderstorm; // عواصف
    return Icons.cloud_queue;
  }
}