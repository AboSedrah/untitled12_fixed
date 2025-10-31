import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fazkorony/core/hive_helper.dart';
import 'package:fazkorony/screens/prayer/qibla_compass.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final backgroundColor = getValue("darkMode") 
        ? const Color(0xFF1E1E1E) 
        : Colors.white;
    final appBarColor = getValue("darkMode") 
        ? const Color(0xFF2D2D2D) 
        : const Color(0xFF00695C);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: appBarColor,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'القبلة',
          style: TextStyle(
            fontFamily: "cairo",
            color: Colors.white,
          ),
        ),
      ),
      body: SizedBox(
        height: screenSize.height,
        child: Column(
          children: [
            SizedBox(height: 30.h),
            const QiblahCompassWidget(),
          ],
        ),
      ),
    );
  }
}
