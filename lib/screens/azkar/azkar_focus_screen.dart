/*import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:android_intent_plus/android_intent.dart';

/// شاشة تركيز:
/// - إخفاء واجهة النظام (Immersive)
/// - منع انطفاء الشاشة (Wakelock)
/// - زر اختياري لفتح إعدادات "عدم الإزعاج" (DND) في النظام
class AzkarFocusScreen extends StatefulWidget {
  final String title;
  const AzkarFocusScreen({super.key, required this.title});

  @override
  State<AzkarFocusScreen> createState() => _AzkarFocusScreenState();
}

class _AzkarFocusScreenState extends State<AzkarFocusScreen> {
  @override
  void initState() {
    super.initState();
    _enterFocusMode();
  }

  @override
  void dispose() {
    _exitFocusMode();
    super.dispose();
  }

  Future<void> _enterFocusMode() async {
    // 1) إخفاء واجهة النظام
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // 2) منع انطفاء الشاشة
    await WakelockPlus.enable();

    // 3) (اختياري) فتح صفحة إعدادات DND للمستخدم لو حاب يفعّلها
    // لا نفتحها تلقائيًا حتى لا نفاجئ المستخدم — نخليها بزر واضح داخل الصفحة.
  }

  Future<void> _exitFocusMode() async {
    // إعادة واجهة النظام
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // السماح بانطفاء الشاشة
    await WakelockPlus.disable();
  }

  Future<void> _openDndSettings() async {
    if (!Platform.isAndroid) return;
    // يفتح صفحة عدم الإزعاج في إعدادات النظام
    // بعض الأجهزة قد تفتح صفحة الإشعارات العامة — السلوك يعتمد على نسخة أندرويد والشركة
    const intent = AndroidIntent(
      action: 'android.settings.ZEN_MODE_SETTINGS',
    );
    await intent.launch();
  }

  Future<void> _finish() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إنهاء الأذكار'),
        content: const Text('هل أكملت قراءة الأذكار؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لا')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('نعم')),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      Navigator.pop(context); // سيستدعي dispose ويعيد الوضع كما كان
    }
  }

  @override
  Widget build(BuildContext context) {
    // ضع نص الأذكار الحقيقي لديك
    const demoContent =
        'ضع هنا نص الأذكار...\nيمكنك استبداله بمصدر بياناتك/ويدجت جاهزة للأذكار.';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    demoContent,
                    style: TextStyle(fontSize: 20, height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // زر اختياري لفتح صفحة DND
              if (Platform.isAndroid)
                TextButton.icon(
                  onPressed: _openDndSettings,
                  icon: const Icon(Icons.notifications_off),
                  label: const Text('فتح إعدادات "عدم الإزعاج"'),
                ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _finish, child: const Text('إنهاء القراءة')),
            ],
          ),
        ),
      ),
    );
  }
}
*/