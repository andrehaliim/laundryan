import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PhotoStorage {
  static late Directory _dir;
  static final _picker = ImagePicker();

  static Future<void> init() async {
    final docs = await getApplicationDocumentsDirectory();
    _dir = Directory(p.join(docs.path, 'photos'));
    if (!await _dir.exists()) await _dir.create(recursive: true);
  }

  static File? file(String? name) =>
      name == null ? null : File(p.join(_dir.path, name));

  /// Takes a photo and saves it to the app folder. Returns the file name, or null if cancelled.
  static Future<String?> pick(ImageSource source) async {
    final x = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (x == null) return null;
    final name =
        '${DateTime.now().microsecondsSinceEpoch}${p.extension(x.path)}';
    await File(x.path).copy(p.join(_dir.path, name));
    return name;
  }

  static Future<void> delete(String? name) async {
    final f = file(name);
    if (f != null && await f.exists()) await f.delete();
  }
}
