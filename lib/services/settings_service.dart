// lib/services/settings_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MuezzinOption {
  final String key; // اسم الملف داخل res/raw بدون الامتداد
  final String display; // الاسم الظاهر للمستخدم
  const MuezzinOption(this.key, this.display);
}

class SettingsService extends ChangeNotifier {
  // Keys
  static const _kPrayerSound = 'prayer_sound';
  static const _kPrayerNotifs = 'prayer_notifs_enabled';
  static const _kAzkarNotifs = 'azkar_notifs_enabled';

  static const _kUiTheme = 'ui.theme'; // light | dark | system
  static const _kUiPrimary = 'ui.primaryColor'; // token name
  static const _kUiFontFamily = 'ui.font.family'; // Amiri | Hafs | System
  static const _kUiFontSize = 'ui.font.size'; // 0.85 .. 1.25
  static const _kLocale = 'i18n.locale'; // ar | en

  static const _kNotifEnabled = 'notif.enabled';
  static const _kNotifAdhkarEnabled = 'notif.adhkar.enabled';
  static const _kNotifAdhkarTime = 'notif.adhkar.time'; // HH:mm
  // أوقات الأذكار الفردية
  static const _kNotifSabahEnabled = 'notif.adhkar.sabah.enabled';
  static const _kNotifSabahTime = 'notif.adhkar.sabah.time';
  static const _kNotifMasaEnabled = 'notif.adhkar.masa.enabled';
  static const _kNotifMasaTime = 'notif.adhkar.masa.time';
  static const _kNotifNoumEnabled = 'notif.adhkar.noum.enabled';
  static const _kNotifNoumTime = 'notif.adhkar.noum.time';
  static const _kNotifAdhan = 'notif.types.adhan.enabled';
  static const _kNotifDaily = 'notif.types.daily.enabled';
  static const _kNotifAppUpdates = 'notif.types.app_updates.enabled';
  static const _kNotifVibrate = 'notif.vibration';
  static const _kNotifRespectDnd = 'notif.respectSystemDnd';
  static const _kQuietEnabled = 'notif.quietHours.enabled';
  static const _kQuietStart = 'notif.quietHours.start'; // HH:mm
  static const _kQuietEnd = 'notif.quietHours.end'; // HH:mm

  static const _kAdhanVoice = 'adhan.voice.selected';
  static const _kAdhanVolume = 'adhan.voice.volume'; // 0..1
  static const _kPrayersUseAdhanVoice = 'notif.prayers.useAdhanVoice';
  static const _kPrayerFajr = 'notif.prayers.fajr.enabled';
  static const _kPrayerDhuhr = 'notif.prayers.dhuhr.enabled';
  static const _kPrayerAsr = 'notif.prayers.asr.enabled';
  static const _kPrayerMaghrib = 'notif.prayers.maghrib.enabled';
  static const _kPrayerIsha = 'notif.prayers.isha.enabled';

  // Manual location for prayer times
  static const _kManualLocEnabled = 'prayers.manual.enabled';
  static const _kManualLat = 'prayers.manual.lat';
  static const _kManualLng = 'prayers.manual.lng';

  static const _kCacheLastUpdated = 'cache.lastUpdated'; // ISO datetime
  static const _kCacheTtlHours = 'cache.ttlHours';
  static const _kUseCachedOffline = 'cache.useCachedOffline';
  static const _kStatsEnabled = 'stats.enabled';
  static const _kStatsPinEnabled = 'stats.pin.enabled';
  static const _kStatsPinCode = 'stats.pin.code';
  // Quran overlay
  static const _kQuranOverlayEnabled = 'quran.overlay.enabled';
  static const _kQuranOverlayColor = 'quran.overlay.color'; // ARGB int
  // static const _kQuranReciterId = 7; // المنشاوي مثلًا (unused const removed)
  // Quran goals
  static const JUZ_PER_KHATMA = 30;
  static const DAYS_IN_MONTH_FOR_GOALS = 30; // For goal calculation consistency
  static const DAYS_IN_YEAR_FOR_GOALS = 365; // For goal calculation consistency
  static const _kQuranDailyJuz = 'quran.daily.juz';
  static const _kQuranMonthlyJuz = 'quran.monthly.juz';
  static const _kQuranMonthlyKhatmas = 'quran.monthly.khatmas';
  static const _kQuranYearlyJuz = 'quran.yearly.juz';

  /// عدّل/أضف حسب ملفاتك المعروضة في الصورة
  static const List<MuezzinOption> muezzins = [
    MuezzinOption('azan_hamd_ful', 'الحمد – كامل'),
    MuezzinOption('azan_hamd_frst', 'الحمد – بداية'),
    MuezzinOption('azan_hamd_end', 'الحمد – نهاية'),
    MuezzinOption('azan_molah_frst', 'المُلا – بداية'),
    MuezzinOption('azan_molah_end', 'المُلا – نهاية'),
    MuezzinOption('azan_hakem_frst', 'الحاكم – بداية'),
    MuezzinOption('azan_hakem_end', 'الحاكم – نهاية'),
    MuezzinOption('azan_fazaz_frst', 'الفزاز – بداية'),
    MuezzinOption('azan_fazaz_end', 'الفزاز – نهاية'),
    MuezzinOption('azan_efase_frst', 'الإفاسي – بداية'),
    MuezzinOption('azan_efase_end', 'الإفاسي – نهاية'),
    // لو تبغى تضيف iqama لاحقًا: MuezzinOption('eqmh', 'الإقامة')
  ];

  // Appearance
  ThemeMode _themeMode = ThemeMode.system;
  String _primaryToken = 'indigo';
  String _fontFamily = 'Amiri';
  double _fontScale = 1.0; // 0.85..1.25

  // Language
  Locale _locale = const Locale('ar');

  // Notifications (legacy & new)
  String _prayerSound = 'azan_hamd_ful'; // kept for backward compatibility
  bool _prayerNotifsEnabled = true; // legacy
  bool _azkarNotifsEnabled = true; // legacy

  bool _notifEnabled = true;
  bool _notifAdhkarEnabled = true;
  String _notifAdhkarTime = '09:00';
  bool _notifSabahEnabled = true;
  String _notifSabahTime = '05:30';
  bool _notifMasaEnabled = true;
  String _notifMasaTime = '17:30';
  bool _notifNoumEnabled = true;
  String _notifNoumTime = '23:00';
  bool _notifAdhanEnabled = true;
  bool _notifDailyEnabled = true;
  bool _notifAppUpdatesEnabled = false;
  bool _notifVibration = true;
  bool _notifRespectDnd = true;
  bool _quietEnabled = false;
  String _quietStart = '22:30';
  String _quietEnd = '05:30';

  // Adhan
  String _adhanVoice = 'azan_hamd_ful';
  double _adhanVolume = 1.0;
  bool _prayersUseAdhanVoice = true;
  bool _prayerFajr = true;
  bool _prayerDhuhr = true;
  bool _prayerAsr = true;
  bool _prayerMaghrib = true;
  bool _prayerIsha = true;

  // Manual location (optional)
  bool _manualLocEnabled = false;
  double? _manualLat;
  double? _manualLng;

  // Caching
  String? _cacheLastUpdatedIso;
  int _cacheTtlHours = 24;
  bool _useCachedOffline = true;
  bool _statsEnabled = true;
  bool _statsPinEnabled = false;
  String? _statsPinCode;
  // Quran overlay defaults
  bool _quranOverlayEnabled = true;
  int _quranOverlayColor = const Color(0x2DFFC107).value; // amber with opacity
  int _quranReciterId = 7; // المنشاوي مثلًا
  // Quran goals defaults
  int _quranDailyJuzCount = 1;
  int _quranMonthlyJuzTarget = 30;
  int _quranMonthlyKhatmasTarget = 1; // New: monthly khatmas target
  int _quranYearlyJuzTarget = 365;

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get primaryToken => _primaryToken;
  String get fontFamily => _fontFamily;
  double get fontScale => _fontScale;

  Locale get locale => _locale;

  String get prayerSound => _prayerSound;
  bool get prayerNotifsEnabled => _prayerNotifsEnabled;
  bool get azkarNotifsEnabled => _azkarNotifsEnabled;

  bool get notifEnabled => _notifEnabled;
  bool get notifAdhkarEnabled => _notifAdhkarEnabled;
  String get notifAdhkarTime => _notifAdhkarTime;
  bool get notifSabahEnabled => _notifSabahEnabled;
  String get notifSabahTime => _notifSabahTime;
  bool get notifMasaEnabled => _notifMasaEnabled;
  String get notifMasaTime => _notifMasaTime;
  bool get notifNoumEnabled => _notifNoumEnabled;
  String get notifNoumTime => _notifNoumTime;
  bool get notifAdhanEnabled => _notifAdhanEnabled;
  bool get notifDailyEnabled => _notifDailyEnabled;
  bool get notifAppUpdatesEnabled => _notifAppUpdatesEnabled;
  bool get notifVibration => _notifVibration;
  bool get notifRespectDnd => _notifRespectDnd;
  bool get quietEnabled => _quietEnabled;
  String get quietStart => _quietStart;
  String get quietEnd => _quietEnd;

  String get adhanVoice => _adhanVoice;
  double get adhanVolume => _adhanVolume;
  bool get prayersUseAdhanVoice => _prayersUseAdhanVoice;
  bool get prayerFajrEnabled => _prayerFajr;
  bool get prayerDhuhrEnabled => _prayerDhuhr;
  bool get prayerAsrEnabled => _prayerAsr;
  bool get prayerMaghribEnabled => _prayerMaghrib;
  bool get prayerIshaEnabled => _prayerIsha;

  bool get manualLocEnabled => _manualLocEnabled;
  double? get manualLat => _manualLat;
  double? get manualLng => _manualLng;

  String? get cacheLastUpdatedIso => _cacheLastUpdatedIso;
  int get cacheTtlHours => _cacheTtlHours;
  bool get useCachedOffline => _useCachedOffline;
  bool get statsEnabled => _statsEnabled;
  bool get statsPinEnabled => _statsPinEnabled;
  String? get statsPinCode => _statsPinCode;
  bool get quranOverlayEnabled => _quranOverlayEnabled;
  Color get quranOverlayColor => Color(_quranOverlayColor);
  int get quranReciterId => _quranReciterId;
  int get quranDailyJuzCount => _quranDailyJuzCount;
  int get quranMonthlyJuzTarget => _quranMonthlyJuzTarget;
  int get quranMonthlyKhatmasTarget => _quranMonthlyKhatmasTarget;
  int get quranYearlyJuzTarget => _quranYearlyJuzTarget;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    // Appearance
    final themeStr = p.getString(_kUiTheme);
    _themeMode = themeStr == 'light'
        ? ThemeMode.light
        : themeStr == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;
    _primaryToken = p.getString(_kUiPrimary) ?? _primaryToken;
    _fontFamily = p.getString(_kUiFontFamily) ?? _fontFamily;
    _fontScale = p.getDouble(_kUiFontSize) ?? _fontScale;

    // Language
    final loc = p.getString(_kLocale);
    _locale = (loc == 'en') ? const Locale('en') : const Locale('ar');

    // Notifications
    _prayerSound = p.getString(_kPrayerSound) ?? _prayerSound;
    _prayerNotifsEnabled = p.getBool(_kPrayerNotifs) ?? _prayerNotifsEnabled;
    _azkarNotifsEnabled = p.getBool(_kAzkarNotifs) ?? _azkarNotifsEnabled;
    _notifEnabled = p.getBool(_kNotifEnabled) ?? _notifEnabled;
    _notifAdhkarEnabled =
        p.getBool(_kNotifAdhkarEnabled) ?? _notifAdhkarEnabled;
    _notifAdhkarTime = p.getString(_kNotifAdhkarTime) ?? _notifAdhkarTime;
    // الفردية: fallback إلى القيم القديمة إن لم تكن موجودة
    _notifSabahEnabled = p.getBool(_kNotifSabahEnabled) ?? _notifAdhkarEnabled;
    _notifSabahTime = p.getString(_kNotifSabahTime) ?? '05:30';
    _notifMasaEnabled = p.getBool(_kNotifMasaEnabled) ?? _notifAdhkarEnabled;
    _notifMasaTime = p.getString(_kNotifMasaTime) ?? '17:30';
    _notifNoumEnabled = p.getBool(_kNotifNoumEnabled) ?? _notifAdhkarEnabled;
    _notifNoumTime = p.getString(_kNotifNoumTime) ?? '23:00';
    _notifAdhanEnabled = p.getBool(_kNotifAdhan) ?? _notifAdhanEnabled;
    _notifDailyEnabled = p.getBool(_kNotifDaily) ?? _notifDailyEnabled;
    _notifAppUpdatesEnabled =
        p.getBool(_kNotifAppUpdates) ?? _notifAppUpdatesEnabled;
    _notifVibration = p.getBool(_kNotifVibrate) ?? _notifVibration;
    _notifRespectDnd = p.getBool(_kNotifRespectDnd) ?? _notifRespectDnd;
    _quietEnabled = p.getBool(_kQuietEnabled) ?? _quietEnabled;
    _quietStart = p.getString(_kQuietStart) ?? _quietStart;
    _quietEnd = p.getString(_kQuietEnd) ?? _quietEnd;

    // Adhan
    _adhanVoice = p.getString(_kAdhanVoice) ?? _adhanVoice;
    _adhanVolume = p.getDouble(_kAdhanVolume) ?? _adhanVolume;
    _prayersUseAdhanVoice =
        p.getBool(_kPrayersUseAdhanVoice) ?? _prayersUseAdhanVoice;
    _prayerFajr = p.getBool(_kPrayerFajr) ?? _prayerFajr;
    _prayerDhuhr = p.getBool(_kPrayerDhuhr) ?? _prayerDhuhr;
    _prayerAsr = p.getBool(_kPrayerAsr) ?? _prayerAsr;
    _prayerMaghrib = p.getBool(_kPrayerMaghrib) ?? _prayerMaghrib;
    _prayerIsha = p.getBool(_kPrayerIsha) ?? _prayerIsha;

    // Manual location
    _manualLocEnabled = p.getBool(_kManualLocEnabled) ?? _manualLocEnabled;
    _manualLat = p.getDouble(_kManualLat) ?? _manualLat;
    _manualLng = p.getDouble(_kManualLng) ?? _manualLng;

    // Cache
    _cacheLastUpdatedIso = p.getString(_kCacheLastUpdated);
    _cacheTtlHours = p.getInt(_kCacheTtlHours) ?? _cacheTtlHours;
    _useCachedOffline = p.getBool(_kUseCachedOffline) ?? _useCachedOffline;
    _statsEnabled = p.getBool(_kStatsEnabled) ?? _statsEnabled;
    _statsPinEnabled = p.getBool(_kStatsPinEnabled) ?? _statsPinEnabled;
    _statsPinCode = p.getString(_kStatsPinCode);
    _quranOverlayEnabled =
        p.getBool(_kQuranOverlayEnabled) ?? _quranOverlayEnabled;
    _quranOverlayColor = p.getInt(_kQuranOverlayColor) ?? _quranOverlayColor;
    _quranReciterId = p.getInt('quran.reciter.id') ?? _quranReciterId;
    _quranDailyJuzCount =
        (p.getInt(_kQuranDailyJuz) ?? _quranDailyJuzCount).clamp(1, 30);
    _quranMonthlyJuzTarget =
        p.getInt(_kQuranMonthlyJuz) ?? _quranMonthlyJuzTarget;
    _quranMonthlyKhatmasTarget =
        p.getInt(_kQuranMonthlyKhatmas) ?? _quranMonthlyKhatmasTarget;
    _quranYearlyJuzTarget = p.getInt(_kQuranYearlyJuz) ?? _quranYearlyJuzTarget;

    notifyListeners();
  }

  // Helpers
  // Note: _daysInYear and _daysInMonth were removed because they were unused.

  String formatKhatmasDisplay(int juzCount) {
    final khatmas = juzCount / JUZ_PER_KHATMA;
    if ((khatmas - khatmas.roundToDouble()).abs() < 1e-6) {
      return khatmas.toInt().toString();
    }
    return khatmas.toStringAsFixed(2);
  }

  Future<void> setPrayerSound(String key) async {
    _prayerSound = key;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kPrayerSound, key);
    notifyListeners();
  }

  Future<void> setPrayerNotifsEnabled(bool v) async {
    _prayerNotifsEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPrayerNotifs, v);
    notifyListeners();
  }

  Future<void> setAzkarNotifsEnabled(bool v) async {
    _azkarNotifsEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAzkarNotifs, v);
    notifyListeners();
  }

  MuezzinOption get selectedOption => muezzins
      .firstWhere((e) => e.key == _prayerSound, orElse: () => muezzins.first);

  // Setters
  Future<void> setThemeMode(ThemeMode m) async {
    _themeMode = m;
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _kUiTheme,
        m == ThemeMode.light
            ? 'light'
            : m == ThemeMode.dark
                ? 'dark'
                : 'system');
    notifyListeners();
  }

  Future<void> setPrimaryToken(String t) async {
    _primaryToken = t;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUiPrimary, t);
    notifyListeners();
  }

  Future<void> setFontFamily(String f) async {
    _fontFamily = f;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUiFontFamily, f);
    notifyListeners();
  }

  Future<void> setFontScale(double s) async {
    // تقييد المدى لحماية التنسيق العام
    _fontScale = s.clamp(0.9, 1.2);
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kUiFontSize, _fontScale);
    notifyListeners();
  }

  Future<void> setLocale(Locale l) async {
    _locale = l;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLocale, l.languageCode);
    notifyListeners();
  }

  Future<void> setNotifEnabled(bool v) async {
    _notifEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifEnabled, v);
    notifyListeners();
  }

  Future<void> setNotifAdhkarEnabled(bool v) async {
    _notifAdhkarEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifAdhkarEnabled, v);
    notifyListeners();
  }

  Future<void> setNotifAdhkarTime(String hhmm) async {
    _notifAdhkarTime = hhmm;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kNotifAdhkarTime, hhmm);
    notifyListeners();
  }

  // Sabah/Masa/Noum setters
  Future<void> setNotifSabahEnabled(bool v) async {
    _notifSabahEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifSabahEnabled, v);
    notifyListeners();
  }

  Future<void> setNotifSabahTime(String hhmm) async {
    _notifSabahTime = hhmm;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kNotifSabahTime, hhmm);
    notifyListeners();
  }

  Future<void> setNotifMasaEnabled(bool v) async {
    _notifMasaEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifMasaEnabled, v);
    notifyListeners();
  }

  Future<void> setNotifMasaTime(String hhmm) async {
    _notifMasaTime = hhmm;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kNotifMasaTime, hhmm);
    notifyListeners();
  }

  Future<void> setNotifNoumEnabled(bool v) async {
    _notifNoumEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifNoumEnabled, v);
    notifyListeners();
  }

  Future<void> setNotifNoumTime(String hhmm) async {
    _notifNoumTime = hhmm;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kNotifNoumTime, hhmm);
    notifyListeners();
  }

  Future<void> setNotifAdhanEnabled(bool v) async {
    _notifAdhanEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifAdhan, v);
    notifyListeners();
  }

  Future<void> setNotifDailyEnabled(bool v) async {
    _notifDailyEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifDaily, v);
    notifyListeners();
  }

  Future<void> setNotifAppUpdatesEnabled(bool v) async {
    _notifAppUpdatesEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifAppUpdates, v);
    notifyListeners();
  }

  Future<void> setNotifVibration(bool v) async {
    _notifVibration = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifVibrate, v);
    notifyListeners();
  }

  Future<void> setNotifRespectDnd(bool v) async {
    _notifRespectDnd = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifRespectDnd, v);
    notifyListeners();
  }

  Future<void> setQuietEnabled(bool v) async {
    _quietEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kQuietEnabled, v);
    notifyListeners();
  }

  Future<void> setQuietStart(String hhmm) async {
    _quietStart = hhmm;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kQuietStart, hhmm);
    notifyListeners();
  }

  Future<void> setQuietEnd(String hhmm) async {
    _quietEnd = hhmm;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kQuietEnd, hhmm);
    notifyListeners();
  }

  Future<void> setAdhanVoice(String key) async {
    _adhanVoice = key;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAdhanVoice, key);
    notifyListeners();
  }

  Future<void> setAdhanVolume(double v) async {
    _adhanVolume = v;
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kAdhanVolume, v);
    notifyListeners();
  }

  Future<void> setPrayersUseAdhanVoice(bool v) async {
    _prayersUseAdhanVoice = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPrayersUseAdhanVoice, v);
    notifyListeners();
  }

  Future<void> setManualLocationEnabled(bool v) async {
    _manualLocEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kManualLocEnabled, v);
    notifyListeners();
  }

  Future<void> setManualLat(double? v) async {
    _manualLat = v;
    final p = await SharedPreferences.getInstance();
    if (v == null) {
      await p.remove(_kManualLat);
    } else {
      await p.setDouble(_kManualLat, v);
    }
    notifyListeners();
  }

  Future<void> setManualLng(double? v) async {
    _manualLng = v;
    final p = await SharedPreferences.getInstance();
    if (v == null) {
      await p.remove(_kManualLng);
    } else {
      await p.setDouble(_kManualLng, v);
    }
    notifyListeners();
  }

  Future<void> setPrayerEnabled(
      {required String name, required bool enabled}) async {
    final p = await SharedPreferences.getInstance();
    switch (name) {
      case 'الفجر':
        _prayerFajr = enabled;
        await p.setBool(_kPrayerFajr, enabled);
        break;
      case 'الظهر':
        _prayerDhuhr = enabled;
        await p.setBool(_kPrayerDhuhr, enabled);
        break;
      case 'العصر':
        _prayerAsr = enabled;
        await p.setBool(_kPrayerAsr, enabled);
        break;
      case 'المغرب':
        _prayerMaghrib = enabled;
        await p.setBool(_kPrayerMaghrib, enabled);
        break;
      case 'العشاء':
        _prayerIsha = enabled;
        await p.setBool(_kPrayerIsha, enabled);
        break;
    }
    notifyListeners();
  }

  Future<void> markCacheUpdatedNow() async {
    final nowIso = DateTime.now().toIso8601String();
    _cacheLastUpdatedIso = nowIso;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kCacheLastUpdated, nowIso);
    notifyListeners();
  }

  Future<void> setCacheTtlHours(int h) async {
    _cacheTtlHours = h;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kCacheTtlHours, h);
    notifyListeners();
  }

  Future<void> setUseCachedOffline(bool v) async {
    _useCachedOffline = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kUseCachedOffline, v);
    notifyListeners();
  }

  Future<void> setStatsEnabled(bool v) async {
    _statsEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kStatsEnabled, v);
    notifyListeners();
  }

  Future<void> setStatsPinEnabled(bool v) async {
    _statsPinEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kStatsPinEnabled, v);
    if (!v) {
      await p.remove(_kStatsPinCode);
      _statsPinCode = null;
    }
    notifyListeners();
  }

  Future<void> setStatsPinCode(String pin) async {
    _statsPinCode = pin;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kStatsPinCode, pin);
    notifyListeners();
  }

  // Quran overlay setters
  Future<void> setQuranOverlayEnabled(bool v) async {
    _quranOverlayEnabled = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kQuranOverlayEnabled, v);
    notifyListeners();
  }

  Future<void> setQuranOverlayColor(Color c) async {
    _quranOverlayColor = c.value;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kQuranOverlayColor, _quranOverlayColor);
    notifyListeners();
  }

  Future<void> setQuranReciterId(int id) async {
    _quranReciterId = id;
    final p = await SharedPreferences.getInstance();
    await p.setInt('quran.reciter.id', id);
    notifyListeners();
  }

  // Quran goal setters
  Future<void> setQuranDailyJuzGoal(int v) async {
    _quranDailyJuzCount = v.clamp(1, 30);
    _quranMonthlyJuzTarget = _quranDailyJuzCount * DAYS_IN_MONTH_FOR_GOALS;
    _quranMonthlyKhatmasTarget =
        _quranDailyJuzCount; // As per user's rule: monthly khatmas = daily juz
    _quranYearlyJuzTarget = _quranDailyJuzCount * DAYS_IN_YEAR_FOR_GOALS;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kQuranDailyJuz, _quranDailyJuzCount);
    await p.setInt(_kQuranMonthlyJuz, _quranMonthlyJuzTarget);
    await p.setInt(_kQuranMonthlyKhatmas, _quranMonthlyKhatmasTarget);
    await p.setInt(_kQuranYearlyJuz, _quranYearlyJuzTarget);
    notifyListeners();
  }

  Future<void> setQuranMonthlyJuzGoal(int v) async {
    _quranMonthlyJuzTarget = v.clamp(1, 100000);
    _quranDailyJuzCount = (_quranMonthlyJuzTarget / DAYS_IN_MONTH_FOR_GOALS)
        .round()
        .clamp(1, 30); // Use round() for daily
    _quranMonthlyKhatmasTarget =
        _quranDailyJuzCount; // As per user's rule: monthly khatmas = daily juz
    _quranYearlyJuzTarget = _quranDailyJuzCount * DAYS_IN_YEAR_FOR_GOALS;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kQuranDailyJuz, _quranDailyJuzCount);
    await p.setInt(_kQuranMonthlyJuz, _quranMonthlyJuzTarget);
    await p.setInt(_kQuranMonthlyKhatmas, _quranMonthlyKhatmasTarget);
    await p.setInt(_kQuranYearlyJuz, _quranYearlyJuzTarget);
    notifyListeners();
  }

  Future<void> setQuranMonthlyKhatmasGoal(int v) async {
    _quranMonthlyKhatmasTarget = v.clamp(1, 100000);
    _quranDailyJuzCount =
        _quranMonthlyKhatmasTarget; // As per user's rule: daily juz = monthly khatmas
    _quranMonthlyJuzTarget = _quranMonthlyKhatmasTarget * JUZ_PER_KHATMA;
    _quranYearlyJuzTarget = _quranDailyJuzCount * DAYS_IN_YEAR_FOR_GOALS;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kQuranDailyJuz, _quranDailyJuzCount);
    await p.setInt(_kQuranMonthlyJuz, _quranMonthlyJuzTarget);
    await p.setInt(_kQuranMonthlyKhatmas, _quranMonthlyKhatmasTarget);
    await p.setInt(_kQuranYearlyJuz, _quranYearlyJuzTarget);
    notifyListeners();
  }

  Future<void> setQuranAnnualJuzGoal(int v) async {
    _quranYearlyJuzTarget = v.clamp(1, 100000);
    _quranDailyJuzCount =
        (_quranYearlyJuzTarget / DAYS_IN_YEAR_FOR_GOALS).round().clamp(1, 30);
    _quranMonthlyJuzTarget = _quranDailyJuzCount * DAYS_IN_MONTH_FOR_GOALS;
    _quranMonthlyKhatmasTarget =
        _quranDailyJuzCount; // As per user's rule: monthly khatmas = daily juz
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kQuranDailyJuz, _quranDailyJuzCount);
    await p.setInt(_kQuranMonthlyJuz, _quranMonthlyJuzTarget);
    await p.setInt(_kQuranMonthlyKhatmas, _quranMonthlyKhatmasTarget);
    await p.setInt(_kQuranYearlyJuz, _quranYearlyJuzTarget);
    notifyListeners();
  }

  Future<void> resetAll() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kUiTheme);
    await p.remove(_kUiPrimary);
    await p.remove(_kUiFontFamily);
    await p.remove(_kUiFontSize);
    await p.remove(_kLocale);
    await p.remove(_kNotifEnabled);
    await p.remove(_kNotifAdhan);
    await p.remove(_kNotifDaily);
    await p.remove(_kNotifVibrate);
    await p.remove(_kNotifRespectDnd);
    await p.remove(_kQuietEnabled);
    await p.remove(_kQuietStart);
    await p.remove(_kQuietEnd);
    await p.remove(_kAdhanVoice);
    await p.remove(_kAdhanVolume);
    await p.remove(_kCacheLastUpdated);
    await p.remove(_kCacheTtlHours);
    await p.remove(_kPrayerSound);
    await p.remove(_kPrayerNotifs);
    await p.remove(_kAzkarNotifs);
    await p.remove(_kQuranDailyJuz);
    await p.remove(_kQuranMonthlyJuz);
    await p.remove(_kQuranMonthlyKhatmas);
    await p.remove(_kQuranYearlyJuz);
    await load();
  }
}
