import 'dart:typed_data';

import 'package:fazkorony/models/quran_ui/helpers/save_image.dart';
import 'package:share_plus/share_plus.dart';

void shareImage(Uint8List capturedImage) async {
  try {
    final tempImageFile = await saveImageToTempDirectory(capturedImage);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(tempImageFile.path)],
    ));
    await tempImageFile.delete();
  } catch (e) {

  }
}
