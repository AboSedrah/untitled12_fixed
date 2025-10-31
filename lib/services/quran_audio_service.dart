import'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'settings_service.dart';

class QuranAudioService {
  static const String _base = 'https://api.quran.com/api/v4';
  final int recitationId;
  QuranAudioService({this.recitationId = 7}); // 7 مثال: المنشاوي

  Future<String?> urlFor(int surah, int ayah, {BuildContext? context}) async {
    final int rid = context != null
        ? context.read<SettingsService>().quranReciterId
        : recitationId;
    final key = '$surah:$ayah';
    final uri = Uri.parse('$_base/verses/by_key/$key?audio=$rid');
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body);
    final files = (body['verse']?['audio']?['audio_files'] as List?) ?? const [];
    if (files.isEmpty) return null;
    return files.first['url']?.toString();
  }

  Future<String?> urlForSurah(int surah, {BuildContext? context}) async {
    final int rid = context != null
        ? context.read<SettingsService>().quranReciterId
        : recitationId;
    final uri = Uri.parse('$_base/chapter_recitations/$rid/$surah');
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body);
    final audio = body['audio_file'];
    if (audio == null) return null;
    return audio['audio_url']?.toString();
  }
}



