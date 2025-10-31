import 'dart:convert';
import 'package:http/http.dart' as http;

class TafsirService {
  // Ibn Kathir id on quran.com API
  static const int _ibnKathirId = 169;
  static const String _base = 'https://api.quran.com/api/v4';

  Future<String?> getIbnKathir(int surah, int ayah) async {
    final verseKey = '$surah:$ayah';
    final uri = Uri.parse('$_base/verses/tafsirs?tafsir_id=$_ibnKathirId&verse_key=$verseKey');
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body);
    final list = body['tafsirs'] as List?;
    if (list == null || list.isEmpty) return null;
    final text = list.first['text']?.toString();
    if (text == null) return null;
    // بعض النصوص قد تحتوي HTML بسيط، نزيل العلامات الأساسية فقط
    final plain = text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return plain.isEmpty ? text : plain;
  }
}


