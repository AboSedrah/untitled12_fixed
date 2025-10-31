import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CacheService {
  static final CacheService _i = CacheService._internal();
  factory CacheService() => _i;
  CacheService._internal();

  final Map<String, dynamic> _memory = {};

  Future<String> _dirPath() async {
    final dir = await getApplicationSupportDirectory();
    final p = '${dir.path}/cache';
    final d = Directory(p);
    if (!d.existsSync()) d.createSync(recursive: true);
    return p;
  }

  Future<File> _fileFor(String key) async {
    final safe = base64Url.encode(utf8.encode(key));
    final dir = await _dirPath();
    return File('$dir/$safe.json');
  }

  Future<Map<String, dynamic>?> _readDisk(String key) async {
    final f = await _fileFor(key);
    if (!f.existsSync()) return null;
    try {
      final j = json.decode(await f.readAsString()) as Map<String, dynamic>;
      return j;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeDisk(String key, Map<String, dynamic> obj) async {
    final f = await _fileFor(key);
    await f.writeAsString(json.encode(obj), flush: true);
  }

  Future<T> getData<T>(
    String url, {
    required Duration ttl,
    required T Function(dynamic json) parser,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // memory
    final m = _memory[url];
    if (m is Map<String, dynamic>) {
      final ts = (m['ts'] as int?) ?? 0;
      if (now - ts < ttl.inMilliseconds && m.containsKey('data')) {
        return parser(m['data']);
      }
    }

    // disk
    final d = await _readDisk(url);
    if (d != null) {
      final ts = (d['ts'] as int?) ?? 0;
      if (now - ts < ttl.inMilliseconds && d.containsKey('data')) {
        _memory[url] = d;
        return parser(d['data']);
      }
    }

    // network
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final packed = {'ts': now, 'data': data};
      _memory[url] = packed;
      await _writeDisk(url, packed);
      return parser(data);
    }
    // fallback to stale cache
    if (d != null && d.containsKey('data')) {
      return parser(d['data']);
    }
    throw 'Network error: ${resp.statusCode}';
  }

  Future<void> clearCache() async {
    _memory.clear();
    final dir = Directory(await _dirPath());
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  Future<int> getCacheSize() async {
    final dir = Directory(await _dirPath());
    int total = 0;
    if (dir.existsSync()) {
      for (final f in dir.listSync(recursive: true)) {
        if (f is File) total += await f.length();
      }
    }
    return total;
  }
}


