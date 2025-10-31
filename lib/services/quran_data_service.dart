
import 'dart:convert';
import 'package:flutter/services.dart';

class QuranDataService {
  Future<List<dynamic>> getPageLayout(int page) async {
    final String response = await rootBundle.loadString('assets/mushaf_layout/page_$page.json');
    final data = await json.decode(response);
    return data;
  }
}
