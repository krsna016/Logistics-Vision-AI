import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageStorageService {
  Future<String> get _storagePath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'smartload_images');
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<String> saveImage(File imageFile, String prefix) async {
    final basePath = await _storagePath;
    final safePrefix = prefix.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final fileName =
        '${safePrefix.isEmpty ? 'image' : safePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destination = p.join(basePath, fileName);

    await imageFile.copy(destination);
    // Returning relative path could be better, but absolute is fine for now as it's within AppDocs
    return destination;
  }

  Future<File?> getImage(String path) async {
    final file = await _storedFile(path);
    if (file == null) return null;
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<void> deleteImage(String path) async {
    final file = await _storedFile(path);
    if (file == null) return;
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File?> _storedFile(String path) async {
    final root = p.normalize(await _storagePath);
    final candidate = p.normalize(path);
    final isInsideStorage =
        candidate == root || candidate.startsWith('$root${p.separator}');
    if (!isInsideStorage) return null;
    return File(candidate);
  }
}
