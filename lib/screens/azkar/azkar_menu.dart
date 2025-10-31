import 'package:flutter/material.dart';
import 'zikr_sabah.dart' as sabah;
import 'zikr_masaa.dart' as masaa;
import 'zikr_noum.dart' as noum;
import 'zikr_salah.dart' as salah;
import 'quran_duas_screen.dart';
import 'PropheticDuasScreen.dart';
import 'ruqya_screen.dart';
import 'GeneralDuasScreen.dart';

class AzkarCategoryScreen
    extends StatelessWidget {
  AzkarCategoryScreen({super.key});

  final List<_MenuItem> azkarItems = [
    _MenuItem(
      label: 'أذكار المساء',
      color: const Color(0xFF2C3E50),
      icon: Icons.nights_stay,
      screen:
      masaa.EveningAzkarScreen(),
      motifIcon: Icons.bedtime, // زخرفة
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF3498DB),
          Color(0xFF2C3E50)
        ],
      ),
    ),
    _MenuItem(
      label: 'أذكار الصباح',
      color: const Color(0xFFE67E22),
      icon: Icons.wb_sunny,
      screen: sabah.ZikrSabahScreen(),
      motifIcon: Icons.sunny_snowing,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFD700),
          Color(0xFFE67E22)
        ],
      ),
    ),
    _MenuItem(
      label: 'أذكار النوم',
      color: const Color(0xFF34495E),
      icon: Icons.bed,
      screen: noum.ZikrNoumScreen(),
      motifIcon: Icons.nightlight_round,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF5DADE2),
          Color(0xFF34495E)
        ],
      ),
    ),
    _MenuItem(
      label: 'أذكار متنوعة',
      color: const Color(0xFF16A085),
      icon: Icons.bubble_chart,
      screen: GeneralDuasScreen(),
      motifIcon: Icons
          .auto_awesome, // شراراة خفيفة
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1ABC9C),
          Color(0xFF16A085)
        ],
      ),
    ),
    _MenuItem(
      label: 'أدعية نبوية',
      color: const Color(0xFF8E44AD),
      icon: Icons.menu_book,
      screen: PropheticDuasScreen(),
      motifIcon:
      Icons.menu_book_outlined,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF9B59B6),
          Color(0xFF8E44AD)
        ],
      ),
    ),
    _MenuItem(
      label: 'أذكار الصلاة',
      color: const Color(0xFFC0392B),
      icon: Icons.mosque,
      screen: salah.ZikrSalahScreen(),
      motifIcon:
      Icons.circle, // نقاط زخرفية
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE74C3C),
          Color(0xFFC0392B)
        ],
      ),
    ),
    _MenuItem(
      label: 'الرقية الشرعية',
      color: const Color(0xFF2980B9),
      icon: Icons.healing,
      screen: RuqyaScreen(),
      motifIcon: Icons.spa, // ورقة/نقاء
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF3498DB),
          Color(0xFF2980B9)
        ],
      ),
    ),
    _MenuItem(
      label: 'أدعية قرآنية',
      color: const Color(0xFF27AE60),
      icon: Icons.auto_stories,
      screen: QuranDuasScreen(),
      motifIcon:
      Icons.menu_book_rounded,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2ECC71),
          Color(0xFF27AE60)
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الأذكار',
          style: TextStyle(
              fontSize: 24,
              fontWeight:
              FontWeight.bold,
              fontFamily:
              'NotoNaskhArabic'),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end:
              Alignment.bottomRight,
              colors: [
                Color(0xFF2C3E50),
                Color(0xFF3498DB)
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE4E7F4)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(
              12.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing:
            12, // ↓ تقليل المسافات
            mainAxisSpacing: 12, // ↓
            childAspectRatio:
            1.05, // ↑ امتلاء أفضل
            children: List.generate(
                azkarItems.length, (i) {
              final item =
              azkarItems[i];
              return _AnimatedAzkarCard(
                item: item,
                index: i,
                onNavigate: (tapPos) {
                  Navigator.of(context)
                      .push(
                      _FancySharedAxisRoute(
                        child: item.screen,
                        beginOffset:
                        const Offset(
                            0, 0.06),
                        backdropColor: Color.fromRGBO( // تم التعديل هنا
                            item.color.red,
                            item.color.green,
                            item.color.blue,
                            0.08
                        ),
                      ));
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final Color color;
  final IconData icon;
  final Widget screen;
  final Gradient gradient;
  final IconData
  motifIcon; // أيقونة زخرفية خفيفة

  const _MenuItem({
    required this.label,
    required this.color,
    required this.icon,
    required this.screen,
    required this.gradient,
    required this.motifIcon,
  });
}

/// انتقال Shared-Axis (Fade + Scale + Slide)
class _FancySharedAxisRoute
    extends PageRouteBuilder {
  final Widget child;
  final Offset beginOffset;
  final Color? backdropColor;

  _FancySharedAxisRoute({
    required this.child,
    this.beginOffset =
    const Offset(0.0, 0.04),
    this.backdropColor,
  }) : super(
    transitionDuration:
    const Duration(
        milliseconds: 420),
    reverseTransitionDuration:
    const Duration(
        milliseconds: 320),
    pageBuilder: (context,
        animation,
        secondaryAnimation) =>
    child,
    transitionsBuilder: (context,
        animation,
        secondaryAnimation,
        child) {
      final curve =
      CurvedAnimation(
          parent: animation,
          curve: Curves
              .easeOutCubic,
          reverseCurve: Curves
              .easeInQuad);
      final fade = Tween<double>(
          begin: 0, end: 1)
          .animate(curve);
      final scale = Tween<double>(
          begin: .985, end: 1)
          .animate(curve);
      final slide = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero)
          .animate(curve);

      Widget layered =
      FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: scale,
          child: SlideTransition(
              position: slide,
              child: child),
        ),
      );

      if (backdropColor != null) {
        layered =
            Stack(children: [
              FadeTransition(
                opacity: Tween<
                    double>(
                    begin: 0,
                    end: .8)
                    .animate(CurvedAnimation(
                    parent:
                    animation,
                    curve: Curves
                        .easeOut)),
                child: Container(
                    color:
                    backdropColor),
              ),
              layered,
            ]);
      }
      return layered;
    },
  );
}

/// بطاقة متحركة: دخول Stagger + نبضة ضغط + Pulse من موضع اللمس + شكل مُعبّر
class _AnimatedAzkarCard
    extends StatefulWidget {
  final _MenuItem item;
  final int index;
  final void Function(
      Offset tapLocalPos) onNavigate;

  const _AnimatedAzkarCard({
    required this.item,
    required this.index,
    required this.onNavigate,
  });

  @override
  State<_AnimatedAzkarCard>
  createState() =>
      _AnimatedAzkarCardState();
}

class _AnimatedAzkarCardState
    extends State<_AnimatedAzkarCard>
    with
        SingleTickerProviderStateMixin {
  AnimationController? _c;
  Animation<double> _fade =
  const AlwaysStoppedAnimation<
      double>(1.0);
  Animation<Offset> _slide =
  const AlwaysStoppedAnimation<
      Offset>(Offset.zero);
  Animation<double> _scaleIn =
  const AlwaysStoppedAnimation<
      double>(1.0);

  double _pressScale = 1.0;

  bool _showPulse = false;
  Offset _pulsePos = Offset.zero;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this,
        duration: const Duration(
            milliseconds: 680));
    _fade = CurvedAnimation(
        parent: _c!,
        curve: const Interval(0.15, 1,
            curve:
            Curves.easeOutCubic));
    _slide = Tween<Offset>(
        begin: const Offset(0, .16),
        end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _c!,
        curve: const Interval(
            0.0, .8,
            curve: Curves
                .easeOutBack)));
    _scaleIn = Tween<double>(
        begin: .95, end: 1)
        .animate(CurvedAnimation(
        parent: _c!,
        curve: const Interval(
            0.0, .8,
            curve: Curves
                .easeOutBack)));

    Future.delayed(
        Duration(
            milliseconds:
            70 * widget.index),
            () => _c?.forward());
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  void _handleTapDown(
      TapDownDetails d) {
    setState(() {
      _pressScale = .965;
      _pulsePos = d.localPosition;
      _showPulse = true;
    });
  }

  void _handleTapCancel() =>
      setState(() => _pressScale = 1);
  void _handleTapUp(TapUpDetails _) =>
      setState(() => _pressScale = 1);

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scaleIn,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapCancel:
            _handleTapCancel,
            onTapUp: _handleTapUp,
            onTap: () async {
              await Future.delayed(
                  const Duration(
                      milliseconds:
                      100));
              widget.onNavigate(
                  _pulsePos);
              Future.delayed(
                  const Duration(
                      milliseconds:
                      220), () {
                if (mounted) { // تم إضافة أقواس هنا
                  setState(() =>
                  _showPulse =
                  false);
                }
              });
            },
            child: AnimatedScale(
              scale: _pressScale,
              duration: const Duration(
                  milliseconds: 100),
              curve: Curves.easeOut,
              child: _ExpressiveCard(
                  item: item,
                  showPulse: _showPulse,
                  pulsePos: _pulsePos),
            ),
          ),
        ),
      ),
    );
  }
}

/// الكرت المُعبِّر: إطار متدرّج + زجاج داخلي + زخارف خاصة بالقسم
class _ExpressiveCard
    extends StatelessWidget {
  final _MenuItem item;
  final bool showPulse;
  final Offset pulsePos;
  const _ExpressiveCard(
      {required this.item,
        required this.showPulse,
        required this.pulsePos});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor:
      Color.fromRGBO( // تم التعديل هنا
          item.color.red,
          item.color.green,
          item.color.blue,
          0.45
      ),
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
              18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(18),
          // إطار متدرّج
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO( // تم التعديل هنا
                  item.color.red,
                  item.color.green,
                  item.color.blue,
                  0.55
              ),
              Color.fromRGBO( // تم التعديل هنا
                  item.color.red,
                  item.color.green,
                  item.color.blue,
                  0.95
              )
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(
              2), // سمك الإطار
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
                16),
            gradient: item
                .gradient, // الخلفية الأساسية
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.12), // تم التعديل هنا
                  blurRadius: 10,
                  offset: const Offset(
                      0, 6)),
            ],
          ),
          child: Stack(
            children: [
              // طبقة "زجاج" خفيفة في الوسط
              Align(
                alignment:
                Alignment.center,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration:
                  BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.06), // تم التعديل هنا
                    borderRadius:
                    BorderRadius
                        .circular(
                        18),
                  ),
                ),
              ),
              // زخارف معبّرة لكل قسم (رموز خفيفة جدًا)
              Positioned(
                  right: -8,
                  bottom: -8,
                  child: _motif(
                      item.motifIcon,
                      120,
                      0.08)),
              Positioned(
                  left: -12,
                  top: -12,
                  child: _motif(
                      Icons
                          .blur_circular,
                      80,
                      0.06)),
              Positioned(
                  right: 10,
                  top: 18,
                  child: _motif(
                      Icons.circle,
                      12,
                      0.10)),
              Positioned(
                  right: 28,
                  top: 36,
                  child: _motif(
                      Icons.circle,
                      8,
                      0.08)),
              // Pulse من موضع اللمس
              if (showPulse)
                Positioned.fill(
                  child: _TapPulse(
                      origin: pulsePos,
                      color: Color.fromRGBO(255, 255, 255, 0.25), // تم التعديل هنا
                      duration:
                      const Duration(
                          milliseconds:
                          360)),
                ),
              // المحتوى
              Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    Container(
                      padding:
                      const EdgeInsets
                          .all(12),
                      decoration:
                      BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 0.22), // تم التعديل هنا
                        shape: BoxShape
                            .circle,
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.10), // تم التعديل هنا
                              blurRadius:
                              10,
                              offset:
                              const Offset(
                                  0,
                                  2))
                        ],
                      ),
                      child: Icon(
                          item.icon,
                          size: 44,
                          color: Colors
                              .white), // ↑ تكبير الأيقونة
                    ),
                    const SizedBox(
                        height: 12),
                    Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                          horizontal:
                          6),
                      child: Text(
                        item.label,
                        textAlign:
                        TextAlign
                            .center,
                        maxLines: 2,
                        style:
                        const TextStyle(
                          color: Colors
                              .white,
                          fontSize:
                          19, // ↑ تكبير العنوان
                          fontWeight:
                          FontWeight
                              .w800,
                          fontFamily:
                          'NotoNaskhArabic',
                          shadows: [
                            Shadow(
                                blurRadius:
                                4,
                                color: Colors
                                    .black45,
                                offset: Offset(
                                    1,
                                    1))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _motif(IconData icon,
      double size, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Icon(icon,
          size: size,
          color: Colors.white),
    );
  }
}

/// Pulse دائري من موضع اللمس
class _TapPulse extends StatefulWidget {
  final Offset origin;
  final Color color;
  final Duration duration;

  const _TapPulse({ // تم إضافة key هنا
    required this.origin,
    required this.color,
    required this.duration
  });

  @override
  State<_TapPulse> createState() =>
      _TapPulseState();
}

class _TapPulseState
    extends State<_TapPulse>
    with
        SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(
      vsync: this,
      duration: widget.duration)
    ..forward();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = Curves.easeOut
            .transform(_c.value);
        final size = 30.0 + t * 260.0;
        final opacity =
        (1 - t).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: widget.origin -
                Offset(
                    size / 2, size / 2),
            child: Container(
                width: size,
                height: size,
                decoration:
                BoxDecoration(
                    color: widget
                        .color,
                    shape: BoxShape
                        .circle)),
          ),
        );
      },
    );
  }
}