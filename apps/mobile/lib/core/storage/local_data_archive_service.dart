import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

/// Creates a shareable, point-in-time archive of the app's local audit data.
///
/// Platform-secure secrets (login tokens and cached password hashes) are
/// intentionally excluded: they are stored outside the Documents directory.
class LocalDataArchiveService {
  LocalDataArchiveService(
    this._database, {
    Future<Directory> Function()? documentsDirectory,
  }) : _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory;

  final AppDatabase _database;
  final Future<Directory> Function() _documentsDirectory;

  Future<File> createArchive() async {
    final documents = await _documentsDirectory();
    final timestamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final archiveFile = File(
      p.join(documents.path, 'SmartLoad_local_audit_$timestamp.zip'),
    );

    final databaseFile =
        File(p.join(documents.path, 'smartload_offline.sqlite'));
    if (!await databaseFile.exists()) {
      throw StateError('Local database was not found.');
    }

    try {
      // Flush WAL changes before copying the database. Companion files are
      // included below too, in case SQLite cannot truncate an active reader.
      await _database.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');

      final files = <Map<String, String>>[
        {
          'source': databaseFile.path,
          'archivePath': 'database/${p.basename(databaseFile.path)}',
        },
      ];
      for (final suffix in ['-wal', '-shm']) {
        final companion = File('${databaseFile.path}$suffix');
        if (await companion.exists()) {
          files.add({
            'source': companion.path,
            'archivePath': 'database/${p.basename(companion.path)}',
          });
        }
      }

      await for (final entity
          in documents.list(recursive: true, followLinks: false)) {
        if (entity is! File || p.equals(entity.path, archiveFile.path)) {
          continue;
        }
        if (p.equals(entity.path, databaseFile.path) ||
            p.equals(entity.path, '${databaseFile.path}-wal') ||
            p.equals(entity.path, '${databaseFile.path}-shm')) {
          continue;
        }
        // Never recursively include earlier full-data archives. It wastes
        // storage and makes every new share progressively slower.
        if (p.basename(entity.path).startsWith('SmartLoad_local_audit_') &&
            entity.path.endsWith('.zip')) {
          continue;
        }
        final relativePath = p.relative(entity.path, from: documents.path);
        files.add({
          'source': entity.path,
          'archivePath': 'documents/$relativePath',
        });
      }

      // Compression and file reads are CPU intensive. Isolate.run keeps the
      // Flutter UI responsive, including the progress animation.
      await Isolate.run(
        () => _writeArchive(
          archivePath: archiveFile.path,
          files: files,
        ),
      );
      return archiveFile;
    } catch (_) {
      if (await archiveFile.exists()) await archiveFile.delete();
      rethrow;
    }
  }
}

Future<void> _writeArchive({
  required String archivePath,
  required List<Map<String, String>> files,
}) async {
  final encoder = ZipFileEncoder();
  final inventory = <Map<String, Object>>[];
  encoder.create(archivePath);
  try {
    for (final file in files) {
      final source = File(file['source']!);
      final destination = file['archivePath']!.replaceAll(p.separator, '/');
      await encoder.addFile(source, destination);
      inventory.add({'path': destination, 'sizeBytes': await source.length()});
    }
    encoder.addArchiveFile(ArchiveFile.string(
      'MANIFEST.json',
      jsonEncode({
        'format': 'SmartLoad local audit archive',
        'createdAtUtc': DateTime.now().toUtc().toIso8601String(),
        'database': 'database/smartload_offline.sqlite',
        'includes': [
          'SQLite operational data, audit logs, and sync queue',
          'saved images, backups, and locally generated reports/exports',
        ],
        'excludes': [
          'platform-secure login tokens and cached password hashes',
          'temporary processing/cache files',
          'previous full-data audit ZIP archives',
        ],
        'files': inventory,
      }),
    ));
    await encoder.close();
  } catch (_) {
    await encoder.close();
    rethrow;
  }
}
