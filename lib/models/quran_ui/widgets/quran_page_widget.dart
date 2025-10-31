import 'package:flutter/material.dart';
import 'package:fazkorony/services/quran_data_service.dart';
import 'dart:ui' as ui;
import 'package:fazkorony/core/constants.dart';
import 'package:fazkorony/core/hive_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;

class QuranPageWidget extends StatefulWidget {
  final int pageNumber;
  final QuranDataService quranDataService;

  const QuranPageWidget({
    super.key,
    required this.pageNumber,
    required this.quranDataService,
  });

  @override
  _QuranPageWidgetState createState() => _QuranPageWidgetState();
}

class _QuranPageWidgetState extends State<QuranPageWidget> {
  List<dynamic> _layout = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    final layout = await widget.quranDataService.getPageLayout(widget.pageNumber);
    setState(() {
      _layout = layout;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: _layout.map((ayahData) {
        return Positioned(
          left: ayahData['x'].toDouble() * MediaQuery.of(context).size.width,
          top: ayahData['y'].toDouble() * MediaQuery.of(context).size.height,
          width: ayahData['w'].toDouble() * MediaQuery.of(context).size.width,
          height: ayahData['h'].toDouble() * MediaQuery.of(context).size.height,
          child: Text(
            quran.getVerse(ayahData['surah'], ayahData['ayah']),
            style: TextStyle(
              fontFamily: 'QPCV1',
              color: primaryColors[getValue("quranPageolorsIndex")],
              fontSize: getValue("pageViewFontSize").toDouble(),
            ),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }
}
