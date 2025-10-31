import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void nullValidator(String hiveFieldName, dynamic value) {
  if (!Hive.isBoxOpen("name")) return;
  final box = Hive.box("name");
  if (box.get(hiveFieldName) == null) {
    box.put(hiveFieldName, value);
  }
}

dynamic getValue(dynamic field, {dynamic defaultValue}) {
  if (!Hive.isBoxOpen("name")) return defaultValue;
  return Hive.box("name").get(field, defaultValue: defaultValue);
}

void updateValue(dynamic field, dynamic value) {
  if (!Hive.isBoxOpen("name")) return;
  Hive.box("name").put(field, value);
}

Future<void> initializeHive() async {
  var p = await getApplicationDocumentsDirectory();
  Hive.init(p.path);
  await Hive.openBox("name");
}
