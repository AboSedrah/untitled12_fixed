import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _i = AudioService._internal();
  factory AudioService() => _i;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _useSystemVolume = true;
  double _customVolume = 1.0; // 0..1

  Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> setVolumePolicy({required bool useSystemVolume, double? level}) async {
    _useSystemVolume = useSystemVolume;
    if (level != null) _customVolume = level.clamp(0.0, 1.0);
  }

  Future<void> playPreview({required String voiceId, String? localPath}) async {
    await stopPreview();
    if (!_useSystemVolume) {
      await _player.setVolume(_customVolume);
    } else {
      // دع النظام يحدد مستوى الصوت؛ لا نغيره هنا
    }

    if (localPath != null && File(localPath).existsSync()) {
      await _player.play(DeviceFileSource(localPath));
    } else {
      // تشغيل من الأصول: مرّر المسار دون بادئة "assets/" لأن AssetSource يضيفها تلقائيًا
      final asset = 'raw/$voiceId.ogg';
      await _player.play(AssetSource(asset));
    }
  }

  Future<void> stopPreview() async {
    await _player.stop();
  }
}


