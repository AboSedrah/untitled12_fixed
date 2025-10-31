import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class VoiceAssetsService {
  static final VoiceAssetsService _i = VoiceAssetsService._internal();
  factory VoiceAssetsService() => _i;
  VoiceAssetsService._internal();

  final Map<String, bool> _downloaded = {};

  Future<String> _voicesDirPath() async {
    final dir = await getApplicationSupportDirectory();
    final p = '${dir.path}/voices';
    final d = Directory(p);
    if (!d.existsSync()) d.createSync(recursive: true);
    return p;
  }

  Future<String> localPathFor(String voiceId) async {
    final base = await _voicesDirPath();
    return '$base/$voiceId.ogg';
  }

  Future<void> downloadVoice(String voiceId) async {
    // مبدئيًا: انسخ من الأصول إلى القرص كتنزيل محلي
    // في المستقبل: استبدلها بتحميل حقيقي من الشبكة
    final bytes = await File('assets/raw/$voiceId.ogg').readAsBytes().catchError((_, __) => Uint8List(0));
    if (bytes.isEmpty) return;
    final dest = await localPathFor(voiceId);
    final f = File(dest);
    await f.writeAsBytes(bytes, flush: true);
    _downloaded[voiceId] = true;
  }

  Future<void> deleteAllVoices() async {
    final base = await _voicesDirPath();
    final d = Directory(base);
    if (d.existsSync()) {
      await d.delete(recursive: true);
    }
    _downloaded.clear();
  }

  bool isDownloaded(String voiceId) => _downloaded[voiceId] == true;
}