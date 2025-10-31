import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/audio_service.dart';
import '../../services/voice_assets_service.dart';
import '../../services/stats_export_service.dart';
import '../../services/notification_service.dart';
import '../../services/prayer_notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsService>();
    final isAr = s.locale.languageCode == 'ar';
    final dir = isAr ? TextDirection.rtl : TextDirection.ltr;
    final muezzinsSorted = [...SettingsService.muezzins]
      ..sort((a, b) => a.display.compareTo(b.display));

    final primarySwatches = <String, MaterialColor>{
      'indigo': Colors.indigo,
      'red': Colors.red,
      'teal': Colors.teal,
      'blue': Colors.blue,
      'purple': Colors.purple,
      'green': Colors.green,
      'orange': Colors.orange,
    };

    final dailyCtrl = TextEditingController(text: s.quranDailyJuzCount.toString());
    final monthlyJuzCtrl = TextEditingController(text: s.quranMonthlyJuzTarget.toString());
    final monthlyKhatmasCtrl = TextEditingController(text: s.quranMonthlyKhatmasTarget.toString());
    final yearlyCtrl = TextEditingController(text: s.quranYearlyJuzTarget.toString());

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات / Settings'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Section(
              title: 'القرآن / Quran',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('أدخل أي هدف، وسنحسب البقية تلقائيًا (يومي/شهري/سنوي).'),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: yearlyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الهدف السنوي (أجزاء)', border: OutlineInputBorder()),
                        onSubmitted: (v) async {
                          final n = int.tryParse(v.trim());
                          if (n != null) {
                            await s.setQuranAnnualJuzGoal(n);
                            yearlyCtrl.text = s.quranYearlyJuzTarget.toString();
                            monthlyJuzCtrl.text = s.quranMonthlyJuzTarget.toString();
                            dailyCtrl.text = s.quranDailyJuzCount.toString();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الأهداف وفق السنوي')));
                          }
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: monthlyJuzCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الهدف الشهري (أجزاء)', border: OutlineInputBorder()),
                        onSubmitted: (v) async {
                          final n = int.tryParse(v.trim());
                          if (n != null) {
                            await s.setQuranMonthlyJuzGoal(n);
                            yearlyCtrl.text = s.quranYearlyJuzTarget.toString();
                            monthlyJuzCtrl.text = s.quranMonthlyJuzTarget.toString();
                            monthlyKhatmasCtrl.text = s.quranMonthlyKhatmasTarget.toString();
                            dailyCtrl.text = s.quranDailyJuzCount.toString();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الأهداف وفق الشهري (أجزاء)')));
                          }
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: monthlyKhatmasCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الهدف الشهري (ختمات)', border: OutlineInputBorder()),
                        onSubmitted: (v) async {
                          final n = int.tryParse(v.trim());
                          if (n != null) {
                            await s.setQuranMonthlyKhatmasGoal(n);
                            yearlyCtrl.text = s.quranYearlyJuzTarget.toString();
                            monthlyJuzCtrl.text = s.quranMonthlyJuzTarget.toString();
                            monthlyKhatmasCtrl.text = s.quranMonthlyKhatmasTarget.toString();
                            dailyCtrl.text = s.quranDailyJuzCount.toString();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الأهداف وفق الشهري (ختمات)')));
                          }
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: dailyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الهدف اليومي (أجزاء/اليوم)', border: OutlineInputBorder()),
                        onSubmitted: (v) async {
                          final n = int.tryParse(v.trim());
                          if (n != null) {
                            await s.setQuranDailyJuzGoal(n);
                            yearlyCtrl.text = s.quranYearlyJuzTarget.toString();
                            monthlyJuzCtrl.text = s.quranMonthlyJuzTarget.toString();
                            dailyCtrl.text = s.quranDailyJuzCount.toString();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الأهداف وفق اليومي')));
                          }
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'محسوب الآن: يومي ${s.quranDailyJuzCount} جزء '
                    '/ شهري ${s.quranMonthlyJuzTarget} جزء (${s.formatKhatmasDisplay(s.quranMonthlyJuzTarget)} ختمة) '
                    '/ شهري ختمات ${s.quranMonthlyKhatmasTarget} '
                    '/ سنوي ${s.quranYearlyJuzTarget} جزء (${s.formatKhatmasDisplay(s.quranYearlyJuzTarget)} ختمة)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed('/quran_stats'),
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('إحصاءات القرآن'),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'المظهر / Appearance',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الثيم'),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.light, label: Text('فاتح')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('داكن')),
                      ButtonSegment(value: ThemeMode.system, label: Text('النظام')),
                    ],
                    selected: {s.themeMode},
                    onSelectionChanged: (v) => s.setThemeMode(v.first),
                  ),
                  const SizedBox(height: 16),
                  const Text('اللون الأساسي'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: primarySwatches.entries.map((e) {
                      final selected = s.primaryToken == e.key;
                      return ChoiceChip(
                        label: Text(e.key),
                        selected: selected,
                        onSelected: (_) => s.setPrimaryToken(e.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('الخط'),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: s.fontFamily,
                    items: const [
                      DropdownMenuItem(value: 'Amiri', child: Text('Amiri')),
                      DropdownMenuItem(value: 'Hafs', child: Text('Hafs')),
                      DropdownMenuItem(value: 'System', child: Text('System')),
                    ],
                    onChanged: (v) => s.setFontFamily(v ?? 'Amiri'),
                  ),
                  const SizedBox(height: 8),
                  const Text('حجم الخط'),
                  Slider(
                    value: s.fontScale,
                    min: 0.9,
                    max: 1.2,
                    divisions: 6,
                    label: s.fontScale.toStringAsFixed(2),
                    onChanged: (v) => s.setFontScale(v),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('عنوان تجريبي', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          const Text('نص معاينة يُظهر تأثير الخط واللون والحجم.'),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(onPressed: (){}, child: const Text('زر تجريبي')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'اللغة / Language',
              child: Column(
                children: [
                  RadioListTile<Locale>(
                    value: const Locale('ar'),
                    groupValue: s.locale,
                    onChanged: (v) => s.setLocale(v!),
                    title: const Text('Arabic (العربية)'),
                  ),
                  RadioListTile<Locale>(
                    value: const Locale('en'),
                    groupValue: s.locale,
                    onChanged: (v) => s.setLocale(v!),
                    title: const Text('English'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'الأذان / Adhan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الصوت (المؤذن)'),
                  const SizedBox(height: 8),
                  ...muezzinsSorted.map((m) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: const CircleAvatar(child: Icon(Icons.music_note)),
                        title: Text(m.display, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          VoiceAssetsService().isDownloaded(m.key) ? 'محمل محليًا' : 'سيتم التشغيل من الأصول',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          await AudioService().init();
                          String? local;
                          if (VoiceAssetsService().isDownloaded(m.key)) {
                            local = await VoiceAssetsService().localPathFor(m.key);
                          }
                          await AudioService().playPreview(voiceId: m.key, localPath: local);
                        },
                        trailing: Wrap(
                          spacing: 4,
                          children: <Widget>[
                            IconButton(
                              tooltip: 'معاينة',
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () async {
                                await AudioService().init();
                                String? local;
                                if (VoiceAssetsService().isDownloaded(m.key)) {
                                  local = await VoiceAssetsService().localPathFor(m.key);
                                }
                                await AudioService().playPreview(voiceId: m.key, localPath: local);
                              },
                            ),
                            IconButton(
                              tooltip: 'إيقاف',
                              icon: const Icon(Icons.stop),
                              onPressed: () => AudioService().stopPreview(),
                            ),
                            IconButton(
                              tooltip: 'تنزيل',
                              icon: const Icon(Icons.download),
                              onPressed: () async {
                                await VoiceAssetsService().downloadVoice(m.key);
                                // إعادة بناء بسيطة
                                (context as Element).markNeedsBuild();
                              },
                            ),
                            IconButton(
                              tooltip: 'اعتماد للصلاة',
                              icon: const Icon(Icons.check_circle),
                              onPressed: () async {
                                await s.setAdhanVoice(m.key);
                                await s.setPrayersUseAdhanVoice(true);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('تم اعتماد ${m.display} لتنبيهات الصلاة')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              tooltip: 'تعيين افتراضي',
                              icon: const Icon(Icons.check),
                              onPressed: () async {
                                await s.setAdhanVoice(m.key);
                                await AudioService().init();
                                String? local;
                                if (VoiceAssetsService().isDownloaded(m.key)) {
                                  local = await VoiceAssetsService().localPathFor(m.key);
                                }
                                await AudioService().playPreview(voiceId: m.key, localPath: local);
                              },
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  const Text('مستوى الصوت'),
                  Slider(
                    value: s.adhanVolume,
                    onChanged: (v) => s.setAdhanVolume(v),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => AudioService().setVolumePolicy(useSystemVolume: true),
                        child: const Text('استخدم مستوى النظام'),
                      ),
                      ElevatedButton(
                        onPressed: () => AudioService().setVolumePolicy(useSystemVolume: false, level: s.adhanVolume),
                        child: const Text('استخدم هذا المستوى'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'الإشعارات / Notifications',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('تفعيل الإشعارات'),
                    value: s.notifEnabled,
                    onChanged: (v) => s.setNotifEnabled(v),
                  ),
                  const Divider(),
                  const Text('الموقع لتنبيهات الصلاة'),
                  SwitchListTile(
                    title: const Text('استخدام موقع يدوي (بدون GPS)' ) ,
                    value: s.manualLocEnabled,
                    onChanged: (v) => s.setManualLocationEnabled(v),
                  ),
                  if (s.manualLocEnabled)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Text('Latitude')),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: s.manualLat?.toString() ?? '',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                  decoration: const InputDecoration(hintText: 'e.g. 24.7136'),
                                  onFieldSubmitted: (v) {
                                    final d = double.tryParse(v);
                                    s.setManualLat(d);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(child: Text('Longitude')),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: s.manualLng?.toString() ?? '',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                  decoration: const InputDecoration(hintText: 'e.g. 46.6753'),
                                  onFieldSubmitted: (v) {
                                    final d = double.tryParse(v);
                                    s.setManualLng(d);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const Divider(),
                  Opacity(
                    opacity: s.notifEnabled ? 1.0 : 0.5,
                    child: IgnorePointer(
                      ignoring: !s.notifEnabled,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final notif = context.read<NotificationService>();
                                  await notif.scheduleTestAzkar(payload: 'zikr_sabah', inSeconds: 3);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم إرسال اختبار أذكار بعد 3 ثوانٍ')),
                                  );
                                },
                                child: const Text('اختبار أذكار الآن'),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () async {
                                  final notif = context.read<NotificationService>();
                                  final prayer = PrayerNotificationService(notif.notificationsPlugin);
                                  await prayer.scheduleTestPrayer(name: 'الظهر', inSeconds: 3);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم إرسال اختبار الصلاة بعد 3 ثوانٍ')),
                                  );
                                },
                                child: const Text('اختبار الصلاة الآن'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            title: const Text('تذكير الأذكار اليومي'),
                            trailing: Switch(
                              value: s.notifAdhkarEnabled,
                              onChanged: (v) => s.setNotifAdhkarEnabled(v),
                            ),
                          ),
                          if (s.notifAdhkarEnabled)
                            _TimeRow(
                              label: 'وقت التذكير',
                              time: s.notifAdhkarTime,
                              onPick: (t) async {
                                await s.setNotifAdhkarTime(t);
                                await NotificationService().scheduleAdhkarFromSettings();
                              },
                            ),
                          const SizedBox(height: 8),
                          const Text('أوقات الأذكار الفردية'),
                          SwitchListTile(
                            title: const Text('أذكار الصباح'),
                            value: s.notifSabahEnabled,
                            onChanged: (v) => s.setNotifSabahEnabled(v),
                          ),
                          if (s.notifSabahEnabled)
                            _TimeRow(
                              label: 'وقت أذكار الصباح',
                              time: s.notifSabahTime,
                              onPick: (t) async {
                                await s.setNotifSabahTime(t);
                                await NotificationService().scheduleAdhkarFromSettings();
                              },
                            ),
                          SwitchListTile(
                            title: const Text('أذكار المساء'),
                            value: s.notifMasaEnabled,
                            onChanged: (v) => s.setNotifMasaEnabled(v),
                          ),
                          if (s.notifMasaEnabled)
                            _TimeRow(
                              label: 'وقت أذكار المساء',
                              time: s.notifMasaTime,
                              onPick: (t) async {
                                await s.setNotifMasaTime(t);
                                await NotificationService().scheduleAdhkarFromSettings();
                              },
                            ),
                          SwitchListTile(
                            title: const Text('أذكار النوم'),
                            value: s.notifNoumEnabled,
                            onChanged: (v) => s.setNotifNoumEnabled(v),
                          ),
                          if (s.notifNoumEnabled)
                            _TimeRow(
                              label: 'وقت أذكار النوم',
                              time: s.notifNoumTime,
                              onPick: (t) async {
                                await s.setNotifNoumTime(t);
                                await NotificationService().scheduleAdhkarFromSettings();
                              },
                            ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('استخدم صوت المؤذّن لتنبيهات الصلاة'),
                            value: s.prayersUseAdhanVoice,
                            onChanged: (v) => s.setPrayersUseAdhanVoice(v),
                          ),
                          const SizedBox(height: 8),
                          const Text('الصلاة المُفعّلة'),
                          CheckboxListTile(
                            title: const Text('الفجر'),
                            value: s.prayerFajrEnabled,
                            onChanged: (v) => s.setPrayerEnabled(name: 'الفجر', enabled: v ?? true),
                          ),
                          CheckboxListTile(
                            title: const Text('الظهر'),
                            value: s.prayerDhuhrEnabled,
                            onChanged: (v) => s.setPrayerEnabled(name: 'الظهر', enabled: v ?? true),
                          ),
                          CheckboxListTile(
                            title: const Text('العصر'),
                            value: s.prayerAsrEnabled,
                            onChanged: (v) => s.setPrayerEnabled(name: 'العصر', enabled: v ?? true),
                          ),
                          CheckboxListTile(
                            title: const Text('المغرب'),
                            value: s.prayerMaghribEnabled,
                            onChanged: (v) => s.setPrayerEnabled(name: 'المغرب', enabled: v ?? true),
                          ),
                          CheckboxListTile(
                            title: const Text('العشاء'),
                            value: s.prayerIshaEnabled,
                            onChanged: (v) => s.setPrayerEnabled(name: 'العشاء', enabled: v ?? true),
                          ),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('إشعارات الأذان'),
                            value: s.notifAdhanEnabled,
                            onChanged: (v) => s.setNotifAdhanEnabled(v),
                          ),
                          SwitchListTile(
                            title: const Text('الملخص اليومي'),
                            value: s.notifDailyEnabled,
                            onChanged: (v) => s.setNotifDailyEnabled(v),
                          ),
                          SwitchListTile(
                            title: const Text('الاهتزاز'),
                            value: s.notifVibration,
                            onChanged: (v) => s.setNotifVibration(v),
                          ),
                          SwitchListTile(
                            title: const Text('احترام وضع عدم الإزعاج'),
                            value: s.notifRespectDnd,
                            onChanged: (v) => s.setNotifRespectDnd(v),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            title: const Text('ساعات الهدوء'),
                            value: s.quietEnabled,
                            onChanged: (v) => s.setQuietEnabled(v),
                          ),
                          if (s.quietEnabled) ...[
                            _TimeRow(
                              label: 'البداية',
                              time: s.quietStart,
                              onPick: (t) => s.setQuietStart(t),
                            ),
                            _TimeRow(
                              label: 'النهاية',
                              time: s.quietEnd,
                              onPick: (t) => s.setQuietEnd(t),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'التخزين المؤقت / Data & Caching',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    ElevatedButton(onPressed: (){}, child: const Text('تحديث البيانات')),
                    const SizedBox(width: 12),
                    Text('آخر تحديث: ${s.cacheLastUpdatedIso ?? '-'}'),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Text('TTL (ساعات): '),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: s.cacheTtlHours,
                      items: const [12, 24, 48, 72]
                          .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                          .toList(),
                      onChanged: (v) => s.setCacheTtlHours(v ?? 24),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'الإحصاءات / Statistics',
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('تفعيل تتبّع الإحصاءات'),
                    value: s.statsEnabled,
                    onChanged: (v) => s.setStatsEnabled(v),
                  ),
                  Row(children: [
                    ElevatedButton(
                      onPressed: () async {
                        await StatsExportService().exportJson();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تصدير الإحصاءات')),
                        );
                      },
                      child: const Text('تصدير JSON'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () async {
                        await StatsExportService().importJson();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم استيراد الإحصاءات')),
                        );
                      },
                      child: const Text('استيراد JSON'),
                    ),
                  ]),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('قفل الصفحة برمز PIN'),
                    value: s.statsPinEnabled,
                    onChanged: (v) async {
                      if (v) {
                        final pin = await _askForPin(context);
                        if (pin != null && pin.length >= 4) {
                          await s.setStatsPinCode(pin);
                          await s.setStatsPinEnabled(true);
                        }
                      } else {
                        await s.setStatsPinEnabled(false);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('إعادة ضبط الإحصاءات'),
                    trailing: const Icon(Icons.restore),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('تأكيد'),
                          content: const Text('سيتم مسح إحصاءات الأذكار نهائيًا.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('مسح')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تمت إعادة الضبط')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => s.resetAll(),
                child: const Text('إعادة ضبط الإعدادات'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(child: Padding(padding: const EdgeInsets.all(12.0), child: child)),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.time, required this.onPick});
  final String label;
  final String time;
  final Future<void> Function(String) onPick;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(time),
      trailing: const Icon(Icons.schedule),
      onTap: () async {
        final parts = time.split(':');
        final init = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        final picked = await showTimePicker(context: context, initialTime: init);
        if (picked != null) {
          final hh = picked.hour.toString().padLeft(2, '0');
          final mm = picked.minute.toString().padLeft(2, '0');
          await onPick('$hh:$mm');
        }
      },
    );
  }
}

Future<String?> _askForPin(BuildContext context) async {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('أدخل رمز PIN (4 أرقام على الأقل)'),
      content: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 8,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('حفظ')),
      ],
    ),
  );
}