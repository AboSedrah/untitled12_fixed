import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

/// Safe Hive helpers — avoid calling Hive.box(...) if the box hasn't been opened yet.
void nullValidator(String hiveFieldName, dynamic value) {
  if (!Hive.isBoxOpen("name")) return;
  final box = Hive.box("name");
  if (box.get(hiveFieldName) == null) {
    box.put(hiveFieldName, value);
  }
}

/// Synchronously get a value from the shared box. Returns [defaultValue]
/// if the box isn't open yet.
dynamic getValue(dynamic field, {dynamic defaultValue}) {
  if (!Hive.isBoxOpen("name")) return defaultValue;
  return Hive.box("name").get(field, defaultValue: defaultValue);
}

/// Update a value if the box is open; otherwise this is a no-op.
void updateValue(dynamic field, dynamic value) {
  if (!Hive.isBoxOpen("name")) return;
  Hive.box("name").put(field, value);
}

Future<void> initializeHive() async {
  var p = await getApplicationDocumentsDirectory();
  Hive.init(p.path);
  await Hive.openBox("name");
}
