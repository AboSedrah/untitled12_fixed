import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class StatsExportService {
  Future<void> exportJson() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> dump = {};
    for (final k in prefs.getKeys()) {
      if (!k.startsWith('dhikr.')) continue;
      final v = prefs.get(k);
      dump[k] = v;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/dhikr_stats_export.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(dump));
    await Share.shareXFiles([XFile(file.path)], text: 'Dhikr stats export');
  }

  Future<void> importJson() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    final content = await File(path).readAsString();
    final Map<String, dynamic> data = json.decode(content) as Map<String, dynamic>;
    final prefs = await SharedPreferences.getInstance();
    for (final entry in data.entries) {
      final k = entry.key;
      if (!k.startsWith('dhikr.')) continue;
      final v = entry.value;
      if (v is int) {
        await prefs.setInt(k, v);
      } else if (v is double) await prefs.setDouble(k, v);
      else if (v is bool) await prefs.setBool(k, v);
      else if (v is String) await prefs.setString(k, v);
      else if (v is List) await prefs.setString(k, json.encode(v));
      else if (v is Map) await prefs.setString(k, json.encode(v));
    }
  }
}


