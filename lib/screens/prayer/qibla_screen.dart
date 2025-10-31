import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _bearingDeg; // اتجاه القبلة من موقع المستخدم
  String? _error;
  AccelerometerEvent? _acc;
  MagnetometerEvent? _mag;
  double _headingDeg = 0.0; // الشمال = 0°
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  @override
  void initState() {
    super.initState();
    _loadBearing();
    _accSub = accelerometerEvents.listen((e) {
      _acc = e;
      _updateHeading();
    });
    _magSub = magnetometerEvents.listen((e) {
      _mag = e;
      _updateHeading();
    });
  }

  @override
  void dispose() {
    _accSub?.cancel();
    _magSub?.cancel();
    super.dispose();
  }

  Future<void> _loadBearing() async {
    try {
      final p = await SharedPreferences.getInstance();
      // أولاً: جرّب الموقع المحفوظ من صفحة التقويم
      double? lat = p.getDouble('savedLat');
      double? lng = p.getDouble('savedLon');
      // ثانياً: إن لم يوجد، استخدم الموقع اليدوي من الإعدادات
      if (lat == null || lng == null) {
        final manual = p.getBool('prayers.manual.enabled') ?? false;
        if (manual) {
          lat = p.getDouble('prayers.manual.lat');
          lng = p.getDouble('prayers.manual.lng');
        }
      }
      if (lat == null || lng == null) {
        setState(() => _error = 'لم يتم العثور على إحداثيات. افتح التقويم وحدد الموقع، أو فعّل الموقع اليدوي من الإعدادات.');
        return;
      }
      // حساب زاوية القبلة (من الشمال باتجاه الشرق)
      _bearingDeg = _qiblaBearing(lat, lng);
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _error = 'تعذّر تحميل الاتجاه');
    }
  }

  // معادلة اتجاه القبلة من الإحداثيات إلى مكة (21.4225, 39.8262)
  double _qiblaBearing(double lat, double lng) {
    const kaabaLat = 21.4225 * math.pi / 180.0;
    const kaabaLng = 39.8262 * math.pi / 180.0;
    final phi = lat * math.pi / 180.0;
    final lam = lng * math.pi / 180.0;
    final dLam = kaabaLng - lam;
    final y = math.sin(dLam);
    final x = math.cos(phi) * math.tan(kaabaLat) - math.sin(phi) * math.cos(dLam);
    var brng = math.atan2(y, x) * 180.0 / math.pi; // -180..180
    brng = (brng + 360.0) % 360.0; // 0..360 من الشمال باتجاه عقارب الساعة
    return brng;
  }

  void _updateHeading() {
    if (_acc == null || _mag == null) return;
    // تطبيع المتجهات
    double ax = _acc!.x, ay = _acc!.y, az = _acc!.z;
    double ex = _mag!.x, ey = _mag!.y, ez = _mag!.z;
    final an = math.sqrt(ax * ax + ay * ay + az * az);
    final mn = math.sqrt(ex * ex + ey * ey + ez * ez);
    if (an == 0 || mn == 0) return;
    ax /= an; ay /= an; az /= an;
    ex /= mn; ey /= mn; ez /= mn;

    // East = m x g
    double hx = ey * az - ez * ay;
    double hy = ez * ax - ex * az;
    double hz = ex * ay - ey * ax;
    final hn = math.sqrt(hx * hx + hy * hy + hz * hz);
    if (hn == 0) return;
    hx /= hn; hy /= hn; hz /= hn;

    // North = g x East
    final mx = ay * hz - az * hy; // North.x
    final my = az * hx - ax * hz; // North.y
    // زاوية الجهاز بالنسبة للشمال: 0 عندما يشير أعلى الجهاز (المحور Y) إلى الشمال
    double hd = (math.atan2(mx, my) * 180.0 / math.pi);
    hd = (hd + 360.0) % 360.0;
    // تنعيم القراءة لتقليل الاهتزاز
    final alpha = 0.15;
    final smoothed = (1 - alpha) * _headingDeg + alpha * hd;
    if ((smoothed - _headingDeg).abs() > 0.2) {
      setState(() => _headingDeg = smoothed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اتجاه القبلة')),
      body: _error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!)))
          : (_bearingDeg == null)
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade400, width: 2),
                              ),
                            ),
                            Transform.rotate(
                              angle: (((_bearingDeg! - _headingDeg) + 360.0) % 360.0) * math.pi / 180.0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.navigation, size: 80, color: Colors.teal.shade700),
                                  const SizedBox(height: 8),
                                  const Text('القبلة')
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('زاوية القبلة: ${_bearingDeg!.toStringAsFixed(0)}° | البوصلة: ${_headingDeg.toStringAsFixed(0)}°')
                    ],
                  ),
                ),
    );
  }
}


