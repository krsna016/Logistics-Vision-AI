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

  /// Imports operational records and document files from a SmartLoad archive.
  /// Authentication accounts, secure credentials and app settings remain on
  /// this device. The current database is backed up before any changes.
  Future<ArchiveImportSummary> importArchive(File archiveFile) async {
    if (!await archiveFile.exists()) {
      throw StateError('The selected archive file was not found.');
    }

    final documents = await _documentsDirectory();
    // Keep the extraction workspace in app Documents. Android can reclaim or
    // remap cache/code_cache paths while a large picker operation is active,
    // which makes the extracted database disappear before SQLite can stage it.
    final tempDir = await Directory(p.join(
      documents.path,
      'smartload_import_${DateTime.now().microsecondsSinceEpoch}',
    )).create(recursive: true);
    try {
      final extracted = await _extractAndValidate(archiveFile, tempDir);
      // Await before entering finally. Returning the Future directly deletes
      // tempDir while SQLite is still trying to stage the extracted database.
      return await _importExtractedDirectory(extracted, documents);
    } finally {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    }
  }

  /// Imports an already extracted SmartLoad archive folder. The folder must
  /// contain MANIFEST.json, database/smartload_offline.sqlite and optionally
  /// a documents/ directory.
  Future<ArchiveImportSummary> importFolder(Directory folder) async {
    if (!await folder.exists()) {
      throw StateError('The selected archive folder was not found.');
    }
    final documents = await _documentsDirectory();
    final root = await _findArchiveRoot(folder);
    final extracted = await _validateExtractedDirectory(root);
    return _importExtractedDirectory(extracted, documents);
  }

  /// Returns the automatic safety snapshots created immediately before an
  /// archive import or a previous-backup restore, newest first.
  Future<List<LocalDatabaseBackup>> listLocalBackups() async {
    final documents = await _documentsDirectory();
    final backupDir = Directory(p.join(documents.path, 'backups'));
    if (!await backupDir.exists()) return const [];

    final backups = <LocalDatabaseBackup>[];
    await for (final entity in backupDir.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      final isSafetyBackup =
          (name.startsWith('pre_import_') || name.startsWith('pre_restore_')) &&
              name.endsWith('.sqlite');
      if (!isSafetyBackup) continue;
      final stat = await entity.stat();
      backups.add(LocalDatabaseBackup(
        file: entity,
        createdAt: stat.modified,
        sizeBytes: stat.size,
      ));
    }
    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  /// Restores operational data from an automatic local safety snapshot.
  /// A new snapshot of the current database is made before replacement, so
  /// the restore itself can also be reversed.
  Future<ArchiveImportSummary> restoreLocalBackup(
      LocalDatabaseBackup backup) async {
    final available = await listLocalBackups();
    final selectedPath = p.normalize(p.absolute(backup.file.path));
    LocalDatabaseBackup? selected;
    for (final candidate in available) {
      if (p.normalize(p.absolute(candidate.file.path)) == selectedPath) {
        selected = candidate;
        break;
      }
    }
    if (selected == null || !await selected.file.exists()) {
      throw StateError('The selected local backup is no longer available.');
    }

    final documents = await _documentsDirectory();
    final restoreDir = await Directory(p.join(
      documents.path,
      'smartload_restore_${DateTime.now().microsecondsSinceEpoch}',
    )).create(recursive: true);
    try {
      final databaseDir =
          await Directory(p.join(restoreDir.path, 'database')).create();
      await selected.file
          .copy(p.join(databaseDir.path, 'smartload_offline.sqlite'));
      return await _importExtractedDirectory(
        restoreDir,
        documents,
        backupPrefix: 'pre_restore',
      );
    } finally {
      if (await restoreDir.exists()) await restoreDir.delete(recursive: true);
    }
  }

  /// File pickers sometimes return a wrapper folder containing the extracted
  /// archive. Accept that common layout as well as the archive root itself.
  Future<Directory> _findArchiveRoot(Directory selected) async {
    final candidates = <Directory>[];
    var pending = <(Directory, int)>[(selected, 0)];
    while (pending.isNotEmpty) {
      final current = pending.removeAt(0);
      final directory = current.$1;
      final depth = current.$2;
      if (await File(p.join(directory.path, 'MANIFEST.json')).exists()) {
        candidates.add(directory);
        continue;
      }
      // Some file managers create ZIPs with one or more outer folders. Search
      // a small, bounded depth without following links so both the ZIP picker
      // and extracted-folder picker accept the same safe archive layouts.
      if (depth >= 4) continue;
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is Directory && p.basename(entity.path) != '__MACOSX') {
          pending.add((entity, depth + 1));
        }
      }
    }
    if (candidates.length == 1) return candidates.single;
    if (candidates.length > 1) {
      throw StateError(
          'This selection contains more than one SmartLoad archive. Choose only one backup.');
    }
    throw StateError(
        'Select the archive folder containing MANIFEST.json and database/.');
  }

  Future<ArchiveImportSummary> _importExtractedDirectory(
    Directory extracted,
    Directory documents, {
    String backupPrefix = 'pre_import',
  }) async {
    final importedDatabase =
        File(p.join(extracted.path, 'database', 'smartload_offline.sqlite'));
    if (!await importedDatabase.exists()) {
      throw StateError('This folder does not contain a SmartLoad database.');
    }
    if (await importedDatabase.length() == 0) {
      throw StateError('The imported SmartLoad database is empty.');
    }

    final currentDatabase =
        File(p.join(documents.path, 'smartload_offline.sqlite'));
    if (await currentDatabase.exists()) {
      await _database.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
      final backupDir = Directory(p.join(documents.path, 'backups'));
      await backupDir.create(recursive: true);
      final backupName =
          '${backupPrefix}_${DateTime.now().toUtc().toIso8601String().replaceAll(':', '-')}.sqlite';
      await currentDatabase.copy(p.join(backupDir.path, backupName));
    }

    // Android may expose the picker/cache extraction directory as readable
    // to Dart but not as a valid SQLite attach location. Stage the database
    // inside the app's writable documents directory first.
    final staging = File(p.join(documents.path,
        'smartload_import_staging_${DateTime.now().microsecondsSinceEpoch}.sqlite'));
    await importedDatabase.copy(staging.path);
    late List<String> availableTables;
    try {
      await _database.customStatement(
          "ATTACH DATABASE '${_sqlQuote(staging.path)}' AS imported_archive");
      try {
        await _validateImportedDatabase();
        availableTables = await _availableImportedTables();
        final importColumns = <String, List<String>>{};
        for (final table in availableTables) {
          importColumns[table] = await _compatibleColumns(table);
        }
        await _database.transaction(() async {
          // Older local builds could leave nullable parent references pointing
          // at records that had since been removed. Defer checking until the
          // optional references are repaired below; required relationships
          // are still validated before commit.
          await _database.customStatement('PRAGMA defer_foreign_keys = ON');
          for (final table in _operationalTables.reversed) {
            await _database.customStatement('DELETE FROM "$table"');
          }
          for (final table in availableTables) {
            final columns = importColumns[table]!;
            final columnSql = columns.map(_sqlIdentifier).join(', ');
            await _database.customStatement(
              'INSERT INTO ${_sqlIdentifier(table)} ($columnSql) '
              'SELECT $columnSql FROM imported_archive.${_sqlIdentifier(table)}',
            );
          }
          await _repairOptionalParentReferences();
          await _rebaseImportedFilePaths(documents.path);
          final brokenReferences =
              await _database.customSelect('PRAGMA foreign_key_check').get();
          if (brokenReferences.isNotEmpty) {
            throw StateError(
                'The archive contains records with missing parent data.');
          }
        });
      } finally {
        await _database.customStatement('DETACH DATABASE imported_archive');
      }
    } finally {
      if (await staging.exists()) await staging.delete();
    }

    var copiedFiles = 0;
    final importedDocuments = Directory(p.join(extracted.path, 'documents'));
    if (await importedDocuments.exists()) {
      await for (final entity
          in importedDocuments.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final relative = p.relative(entity.path, from: importedDocuments.path);
        final destination = File(p.join(documents.path, relative));
        await destination.parent.create(recursive: true);
        await entity.copy(destination.path);
        copiedFiles++;
      }
    }
    return ArchiveImportSummary(
      importedTables: availableTables.length,
      copiedFiles: copiedFiles,
    );
  }

  static const _operationalTables = <String>[
    'warehouses',
    'wagons',
    'trucks',
    'layers',
    'detections',
    'digital_registers',
    'loading_sessions',
    'audit_logs',
    'sync_queues',
    'dataset_images',
    'image_metadata',
    'image_quality',
    'annotations',
    'dataset_exports',
    'model_history',
    'report_exports',
  ];

  static const _requiredOperationalTables = <String>{
    'warehouses',
    'wagons',
    'trucks',
    'layers',
    'detections',
    'digital_registers',
    'loading_sessions',
    'audit_logs',
    'sync_queues',
  };

  static String _sqlQuote(String value) => value.replaceAll("'", "''");
  static String _sqlIdentifier(String value) =>
      '"${value.replaceAll('"', '""')}"';

  Future<void> _validateImportedDatabase() async {
    final integrity = await _database
        .customSelect('PRAGMA imported_archive.integrity_check')
        .get();
    if (integrity.length != 1 ||
        integrity.single.data.values.single.toString().toLowerCase() != 'ok') {
      throw StateError('The database inside this archive is damaged.');
    }
    final versionRows = await _database
        .customSelect('PRAGMA imported_archive.user_version')
        .get();
    final importedVersion =
        (versionRows.single.data.values.single as num?)?.toInt() ?? 0;
    if (importedVersion > _database.schemaVersion) {
      throw StateError(
          'This archive was created by a newer SmartLoad version. Update the app before importing it.');
    }
  }

  Future<List<String>> _availableImportedTables() async {
    final rows = await _database
        .customSelect(
          "SELECT name FROM imported_archive.sqlite_master WHERE type = 'table'",
        )
        .get();
    final existing = rows.map((row) => row.read<String>('name')).toSet();
    final missingRequired = _requiredOperationalTables.difference(existing);
    if (missingRequired.isNotEmpty) {
      throw StateError(
          'The archive database is incomplete (missing ${missingRequired.join(', ')}).');
    }
    return _operationalTables.where(existing.contains).toList();
  }

  Future<List<String>> _compatibleColumns(String table) async {
    final currentRows = await _database
        .customSelect('PRAGMA main.table_info(${_sqlIdentifier(table)})')
        .get();
    final importedRows = await _database
        .customSelect(
            'PRAGMA imported_archive.table_info(${_sqlIdentifier(table)})')
        .get();
    final importedNames =
        importedRows.map((row) => row.read<String>('name')).toSet();
    final shared = <String>[];
    final missingRequired = <String>[];
    for (final row in currentRows) {
      final name = row.read<String>('name');
      if (importedNames.contains(name)) {
        shared.add(name);
        continue;
      }
      final notNull = row.read<int>('notnull') == 1;
      final primaryKey = row.read<int>('pk') > 0;
      final hasDefault = row.data['dflt_value'] != null;
      if (notNull && !primaryKey && !hasDefault) missingRequired.add(name);
    }
    if (shared.isEmpty || missingRequired.isNotEmpty) {
      throw StateError('The archive uses an incompatible $table table format.');
    }
    return shared;
  }

  Future<void> _repairOptionalParentReferences() async {
    // These columns are explicitly nullable in the live schema. Clearing a
    // stale parent ID preserves the operational record and matches how the UI
    // represents an unassigned warehouse/wagon.
    await _database.customStatement('''
      UPDATE wagons
      SET warehouse_id = NULL
      WHERE warehouse_id IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM warehouses WHERE warehouses.id = wagons.warehouse_id
        )
    ''');
    await _database.customStatement('''
      UPDATE trucks
      SET wagon_id = NULL
      WHERE wagon_id IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM wagons WHERE wagons.id = trucks.wagon_id
        )
    ''');
    await _database.customStatement('''
      UPDATE loading_sessions
      SET warehouse_id = NULL
      WHERE warehouse_id IS NOT NULL
        AND NOT EXISTS (
          SELECT 1
          FROM warehouses
          WHERE warehouses.id = loading_sessions.warehouse_id
        )
    ''');
  }

  Future<void> _rebaseImportedFilePaths(String documentsPath) async {
    final root = _sqlQuote(documentsPath.replaceAll('\\', '/'));
    const pathColumns = <(String, String)>[
      ('layers', 'photo_path'),
      ('layers', 'cropped_photo_path'),
      ('dataset_images', 'original_path'),
      ('dataset_images', 'annotated_path'),
      ('dataset_images', 'thumbnail_path'),
      ('dataset_exports', 'export_path'),
      ('report_exports', 'file_path'),
    ];
    for (final (table, column) in pathColumns) {
      final tableSql = _sqlIdentifier(table);
      final columnSql = _sqlIdentifier(column);
      await _database.customStatement('''
        UPDATE $tableSql
        SET $columnSql = CASE
          WHEN instr(replace($columnSql, '\\', '/'), '/app_flutter/') > 0
            THEN '$root/' || substr(
              replace($columnSql, '\\', '/'),
              instr(replace($columnSql, '\\', '/'), '/app_flutter/')
                + length('/app_flutter/')
            )
          WHEN replace($columnSql, '\\', '/') LIKE 'documents/%'
            THEN '$root/' || substr(
              replace($columnSql, '\\', '/'),
              length('documents/') + 1
            )
          WHEN substr(replace($columnSql, '\\', '/'), 1, 1) <> '/'
            THEN '$root/' || replace($columnSql, '\\', '/')
          ELSE $columnSql
        END
        WHERE $columnSql IS NOT NULL AND $columnSql <> ''
      ''');
    }
  }

  Future<Directory> _extractAndValidate(
      File archiveFile, Directory target) async {
    // ZIP decompression is intentionally isolated from Flutter's UI thread.
    // Large photo archives otherwise make the entire app appear frozen.
    await Isolate.run(() => _extractArchiveSync(archiveFile.path, target.path));
    final root = await _findArchiveRoot(target);
    return _validateExtractedDirectory(root);
  }

  Future<Directory> _validateExtractedDirectory(Directory folder) async {
    final manifestFile = File(p.join(folder.path, 'MANIFEST.json'));
    final databaseFile =
        File(p.join(folder.path, 'database', 'smartload_offline.sqlite'));
    if (!await manifestFile.exists() || !await databaseFile.exists()) {
      throw StateError(
          'Select the extracted archive’s root folder containing MANIFEST.json and database/.');
    }
    final manifest = jsonDecode(await manifestFile.readAsString());
    if (manifest is! Map ||
        manifest['format'] != 'SmartLoad local audit archive') {
      throw StateError('The selected folder is not a SmartLoad audit archive.');
    }
    return folder;
  }
}

class LocalDatabaseBackup {
  const LocalDatabaseBackup({
    required this.file,
    required this.createdAt,
    required this.sizeBytes,
  });

  final File file;
  final DateTime createdAt;
  final int sizeBytes;
}

class ArchiveImportSummary {
  const ArchiveImportSummary({
    required this.importedTables,
    required this.copiedFiles,
  });

  final int importedTables;
  final int copiedFiles;
}

void _extractArchiveSync(String archivePath, String targetPath) {
  final input = InputFileStream(archivePath);
  try {
    final archive = ZipDecoder().decodeBuffer(input);
    var totalBytes = 0;
    var fileCount = 0;
    for (final entry in archive) {
      final name = entry.name.replaceAll('\\', '/');
      final segments = p.posix.split(name);
      if (name.isEmpty ||
          name.startsWith('/') ||
          segments.any((segment) => segment == '..')) {
        throw StateError('The archive contains an unsafe file path.');
      }
      if (!entry.isFile) continue;
      fileCount++;
      totalBytes += entry.size;
      if (fileCount > 100000 || totalBytes > 2 * 1024 * 1024 * 1024) {
        throw StateError('The archive is too large to import safely.');
      }
      final output = File(p.joinAll([targetPath, ...segments]));
      output.parent.createSync(recursive: true);
      final outputStream = OutputFileStream(output.path);
      try {
        entry.writeContent(outputStream);
      } finally {
        outputStream.close();
      }
    }
  } finally {
    input.close();
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
