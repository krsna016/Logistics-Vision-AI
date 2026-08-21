import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../utils/field_normalizer.dart';
import 'database_encryption.dart';

/// Creates a shareable, point-in-time archive of the app's local audit data.
///
/// Platform-secure secrets (login tokens and cached password hashes) are
/// intentionally excluded: they are stored outside the Documents directory.
class LocalDataArchiveService {
  LocalDataArchiveService(
    this._database, {
    Future<Directory> Function()? documentsDirectory,
    Future<String?> Function()? databaseEncryptionKey,
  })  : _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory,
        _databaseEncryptionKey =
            databaseEncryptionKey ?? readDatabaseEncryptionKey;

  final AppDatabase _database;
  final Future<Directory> Function() _documentsDirectory;
  final Future<String?> Function() _databaseEncryptionKey;
  static const _kdfIterations = 600000;
  static const _maxArchiveBytes = 1024 * 1024 * 1024;
  static const _maxBackupSourceBytes = 900 * 1024 * 1024;
  static const _encryptionChunkBytes = 8 * 1024 * 1024;

  static void validateBackupPassword(String password) {
    if (password.isEmpty) {
      throw ArgumentError.value(
        password,
        'password',
        'Enter a backup password.',
      );
    }
  }

  Future<File> createArchive({required String password}) async {
    validateBackupPassword(password);
    final documents = await _documentsDirectory();
    final now = DateTime.now().toUtc();
    final timestamp = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}-'
        '${now.minute.toString().padLeft(2, '0')}-'
        '${now.second.toString().padLeft(2, '0')}_UTC';
    final archiveFile = File(
      p.join(documents.path, 'SmartLoad_Local_Backup_$timestamp.zip'),
    );
    final unencryptedArchive = File('${archiveFile.path}.temporary');

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
        final name = p.basename(entity.path);
        if ((name.startsWith('SmartLoad_local_audit_') ||
                name.startsWith('SmartLoad_Local_Backup_')) &&
            name.endsWith('.zip')) {
          continue;
        }
        final relativePath = p.relative(entity.path, from: documents.path);
        final normalizedRelative = relativePath.replaceAll(p.separator, '/');
        if (!_isBackedUpDocumentPath(normalizedRelative)) continue;
        files.add({
          'source': entity.path,
          'archivePath': 'documents/$normalizedRelative',
        });
      }

      // Compression and file reads are CPU intensive. Isolate.run keeps the
      // Flutter UI responsive, including the progress animation.
      if (files.length > 20000) {
        throw StateError('There are too many local files to back up safely.');
      }
      final filesWithIntegrity = <Map<String, String>>[];
      var totalSourceBytes = 0;
      for (final file in files) {
        final source = File(file['source']!);
        final sourceBytes = await source.length();
        final isDatabase =
            file['archivePath'] == 'database/smartload_offline.sqlite';
        if (sourceBytes > (isDatabase ? 768 : 256) * 1024 * 1024) {
          throw StateError('A local file is too large to back up safely.');
        }
        totalSourceBytes += sourceBytes;
        if (totalSourceBytes > _maxBackupSourceBytes) {
          throw StateError('Local data is too large to back up safely.');
        }
        filesWithIntegrity.add({
          ...file,
          'sha256': await _sha256File(source),
        });
      }

      final databaseEncryptionKey = await _databaseEncryptionKey();
      await Isolate.run(
        () => _writeArchive(
          archivePath: unencryptedArchive.path,
          files: filesWithIntegrity,
          databaseEncryptionKey: databaseEncryptionKey,
        ),
      );
      await _encryptArchive(unencryptedArchive, archiveFile, password);
      return archiveFile;
    } catch (_) {
      if (await archiveFile.exists()) await archiveFile.delete();
      rethrow;
    } finally {
      if (await unencryptedArchive.exists()) await unencryptedArchive.delete();
      final chunkDirectory = Directory('${archiveFile.path}.chunks');
      if (await chunkDirectory.exists()) {
        await chunkDirectory.delete(recursive: true);
      }
    }
  }

  /// Imports operational records and document files from a SmartLoad archive.
  /// Authentication accounts, secure credentials and app settings remain on
  /// this device. The current database is backed up before any changes.
  Future<ArchiveImportSummary> importArchive(
    File archiveFile, {
    String password = '',
  }) async {
    if (!await archiveFile.exists()) {
      throw StateError('The selected archive file was not found.');
    }
    if (await archiveFile.length() > _maxArchiveBytes) {
      throw StateError('The selected backup is too large to import safely.');
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
      final extracted = await _extractProtectedOrLegacyArchive(
        archiveFile,
        tempDir,
        password,
      );
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
    throw UnsupportedError(
      'Extracted-folder import is disabled because protected backups must stay encrypted. Select the SmartLoad ZIP backup instead.',
    );
  }

  Future<void> _encryptArchive(
    File unencryptedArchive,
    File encryptedArchive,
    String password,
  ) async {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final noncePrefix = List<int>.generate(8, (_) => random.nextInt(256));
    final key = await _deriveKey(password, salt);
    final algorithm = AesGcm.with256bits();
    final chunkDirectory = await Directory('${encryptedArchive.path}.chunks')
        .create(recursive: true);
    final chunkNames = <String>[];
    final input = await unencryptedArchive.open();
    try {
      var chunkIndex = 0;
      while (true) {
        final clear = await input.read(_encryptionChunkBytes);
        if (clear.isEmpty) break;
        final name = 'chunks/${chunkIndex.toString().padLeft(6, '0')}.bin';
        final box = await algorithm.encrypt(
          clear,
          secretKey: key,
          nonce: _chunkNonce(noncePrefix, chunkIndex),
          aad: utf8.encode('SmartLoad-backup-v2:$chunkIndex'),
        );
        await File(p.join(chunkDirectory.path, p.basename(name))).writeAsBytes(
          <int>[...box.cipherText, ...box.mac.bytes],
          flush: true,
        );
        chunkNames.add(name);
        chunkIndex++;
      }
    } finally {
      await input.close();
    }

    final metadata = jsonEncode({
      'format': 'SmartLoad encrypted local backup',
      'formatVersion': 2,
      'encryption': 'AES-256-GCM chunked',
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': _kdfIterations,
      'salt': base64Encode(salt),
      'noncePrefix': base64Encode(noncePrefix),
      'chunkSizeBytes': _encryptionChunkBytes,
      'plainSizeBytes': await unencryptedArchive.length(),
      'archiveSha256': await _sha256File(unencryptedArchive),
      'chunks': chunkNames,
    });
    final metadataBox = await algorithm.encrypt(
      const <int>[],
      secretKey: key,
      nonce: _chunkNonce(noncePrefix, 0xffffffff),
      aad: utf8.encode(metadata),
    );

    final encoder = ZipFileEncoder();
    encoder.create(encryptedArchive.path);
    try {
      encoder.addArchiveFile(ArchiveFile.string(
        'BACKUP_INFO.json',
        jsonEncode({
          'metadata': metadata,
          'metadataMac': base64Encode(metadataBox.mac.bytes),
        }),
      ));
      for (final name in chunkNames) {
        await encoder.addFile(
          File(p.join(chunkDirectory.path, p.basename(name))),
          name,
          ArchiveFile.STORE,
        );
      }
      await encoder.close();
    } catch (_) {
      await encoder.close();
      rethrow;
    } finally {
      if (await chunkDirectory.exists()) {
        await chunkDirectory.delete(recursive: true);
      }
    }
  }

  Future<Directory> _extractProtectedOrLegacyArchive(
    File archiveFile,
    Directory tempDir,
    String password,
  ) async {
    final outer = await Directory(p.join(tempDir.path, 'protected'))
        .create(recursive: true);
    await Isolate.run(
      () => _extractArchiveSync(archiveFile.path, outer.path),
    );
    final infoFile = File(p.join(outer.path, 'BACKUP_INFO.json'));
    final payloadFile = File(p.join(outer.path, 'backup_payload.bin'));
    if (!await infoFile.exists() && !await payloadFile.exists()) {
      // Backups created before password protection are still accepted. Their
      // own integrity manifest remains mandatory.
      final legacyRoot = await _findArchiveRoot(outer);
      return _validateExtractedDirectory(legacyRoot);
    }
    if (!await infoFile.exists()) {
      throw StateError('This protected backup is incomplete.');
    }
    if (await infoFile.length() > 2 * 1024 * 1024) {
      throw StateError('This protected backup is damaged.');
    }
    final info = jsonDecode(await infoFile.readAsString());
    if (info is Map && info['metadata'] is String) {
      return _decryptChunkedArchive(info, outer, tempDir, password);
    }
    if (!await payloadFile.exists()) {
      throw StateError('This protected backup is incomplete.');
    }
    if (info is! Map ||
        info['format'] != 'SmartLoad encrypted local backup' ||
        info['formatVersion'] != 1 ||
        info['encryption'] != 'AES-256-GCM' ||
        info['kdf'] != 'PBKDF2-HMAC-SHA256' ||
        info['iterations'] != _kdfIterations ||
        info['salt'] is! String ||
        info['nonce'] is! String ||
        info['payload'] != 'backup_payload.bin') {
      throw StateError('This protected backup uses an unsupported format.');
    }
    try {
      final salt = base64Decode(info['salt'] as String);
      final nonce = base64Decode(info['nonce'] as String);
      if (await payloadFile.length() > 256 * 1024 * 1024) {
        throw StateError(
            'This legacy backup is too large to decrypt safely. Create a new backup on the source device.');
      }
      final payload = await payloadFile.readAsBytes();
      if (salt.length != 16 || nonce.length != 12 || payload.length <= 16) {
        throw const FormatException();
      }
      final key = await _deriveKey(password, salt);
      final clearBytes = await AesGcm.with256bits().decrypt(
        SecretBox(
          payload.sublist(0, payload.length - 16),
          nonce: nonce,
          mac: Mac(payload.sublist(payload.length - 16)),
        ),
        secretKey: key,
      );
      final decrypted = File(p.join(tempDir.path, 'decrypted_backup.zip'));
      await decrypted.writeAsBytes(clearBytes, flush: true);
      final decryptedRoot = await Directory(
        p.join(tempDir.path, 'decrypted_contents'),
      ).create(recursive: true);
      return await _extractAndValidate(decrypted, decryptedRoot);
    } on SecretBoxAuthenticationError {
      throw StateError('Incorrect backup password or a damaged backup file.');
    } on FormatException {
      throw StateError('This protected backup is damaged.');
    } on TypeError {
      throw StateError('This protected backup is damaged.');
    }
  }

  Future<Directory> _decryptChunkedArchive(
    Map<dynamic, dynamic> outerInfo,
    Directory outer,
    Directory tempDir,
    String password,
  ) async {
    try {
      final metadataJson = outerInfo['metadata'];
      final metadataMacValue = outerInfo['metadataMac'];
      if (metadataJson is! String || metadataMacValue is! String) {
        throw const FormatException();
      }
      final metadata = jsonDecode(metadataJson);
      if (metadata is! Map ||
          metadata['format'] != 'SmartLoad encrypted local backup' ||
          metadata['formatVersion'] != 2 ||
          metadata['encryption'] != 'AES-256-GCM chunked' ||
          metadata['kdf'] != 'PBKDF2-HMAC-SHA256' ||
          metadata['iterations'] != _kdfIterations ||
          metadata['chunkSizeBytes'] != _encryptionChunkBytes ||
          metadata['salt'] is! String ||
          metadata['noncePrefix'] is! String ||
          metadata['plainSizeBytes'] is! num ||
          metadata['archiveSha256'] is! String ||
          metadata['chunks'] is! List) {
        throw const FormatException();
      }
      final salt = base64Decode(metadata['salt'] as String);
      final noncePrefix = base64Decode(metadata['noncePrefix'] as String);
      final plainSize = (metadata['plainSizeBytes'] as num).toInt();
      final chunks = (metadata['chunks'] as List).cast<String>();
      if (salt.length != 16 ||
          noncePrefix.length != 8 ||
          plainSize <= 0 ||
          plainSize > _maxArchiveBytes ||
          chunks.isEmpty ||
          chunks.length > 20000) {
        throw const FormatException();
      }
      for (var index = 0; index < chunks.length; index++) {
        if (chunks[index] != 'chunks/${index.toString().padLeft(6, '0')}.bin') {
          throw const FormatException();
        }
      }

      final actualOuterPaths = <String>{};
      await for (final entity
          in outer.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          actualOuterPaths.add(
            p
                .relative(entity.path, from: outer.path)
                .replaceAll(p.separator, '/'),
          );
        }
      }
      final expectedOuterPaths = <String>{'BACKUP_INFO.json', ...chunks};
      if (actualOuterPaths.length != expectedOuterPaths.length ||
          !actualOuterPaths.containsAll(expectedOuterPaths)) {
        throw const FormatException();
      }

      final key = await _deriveKey(password, salt);
      final algorithm = AesGcm.with256bits();
      await algorithm.decrypt(
        SecretBox(
          const <int>[],
          nonce: _chunkNonce(noncePrefix, 0xffffffff),
          mac: Mac(base64Decode(metadataMacValue)),
        ),
        secretKey: key,
        aad: utf8.encode(metadataJson),
      );

      final decrypted = File(p.join(tempDir.path, 'decrypted_backup.zip'));
      final output = await decrypted.open(mode: FileMode.write);
      var written = 0;
      try {
        for (var index = 0; index < chunks.length; index++) {
          final chunkFile = File(p.joinAll([
            outer.path,
            ...p.posix.split(chunks[index]),
          ]));
          final encryptedLength = await chunkFile.length();
          if (encryptedLength <= 16 ||
              encryptedLength > _encryptionChunkBytes + 16) {
            throw const FormatException();
          }
          final encrypted = await chunkFile.readAsBytes();
          final clear = await algorithm.decrypt(
            SecretBox(
              encrypted.sublist(0, encrypted.length - 16),
              nonce: _chunkNonce(noncePrefix, index),
              mac: Mac(encrypted.sublist(encrypted.length - 16)),
            ),
            secretKey: key,
            aad: utf8.encode('SmartLoad-backup-v2:$index'),
          );
          await output.writeFrom(clear);
          written += clear.length;
        }
      } finally {
        await output.close();
      }
      if (written != plainSize ||
          await _sha256File(decrypted) != metadata['archiveSha256']) {
        throw const FormatException();
      }
      final decryptedRoot = await Directory(
        p.join(tempDir.path, 'decrypted_contents'),
      ).create(recursive: true);
      return await _extractAndValidate(decrypted, decryptedRoot);
    } on SecretBoxAuthenticationError {
      throw StateError('Incorrect backup password or a damaged backup file.');
    } on FormatException {
      throw StateError('This protected backup is damaged.');
    } on TypeError {
      throw StateError('This protected backup is damaged.');
    }
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt) {
    return Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _kdfIterations,
      bits: 256,
    ).deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
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
    final importedDatabaseKey = await _importedDatabaseKey(extracted);

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
    // Protected archives can contain SQLite WAL/SHM companions. Attach the
    // complete set so SQLite sees the same committed state as on the source
    // device; copying only the main encrypted file can make a valid backup
    // appear corrupt or incomplete.
    final stagingCompanions = <File>[];
    for (final suffix in ['-wal', '-shm']) {
      final companion = File('${importedDatabase.path}$suffix');
      if (await companion.exists()) {
        final staged = File('${staging.path}$suffix');
        await companion.copy(staged.path);
        stagingCompanions.add(staged);
      }
    }
    final documentRollback = await Directory(p.join(
      extracted.path,
      '.smartload_document_rollback',
    )).create(recursive: true);
    final importedDocuments = await _prepareImportedDocuments(
      extracted,
      documents,
      documentRollback,
    );
    late List<String> availableTables;
    try {
      await _database.customStatement(
          "ATTACH DATABASE '${_sqlQuote(staging.path)}' AS imported_archive");
      try {
        if (importedDatabaseKey != null) {
          await _database.customStatement(
            "PRAGMA imported_archive.key = '${_sqlQuote(importedDatabaseKey)}'",
          );
        }
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
          await _normalizeImportedData();
          await _repairOptionalParentReferences();
          await _rebaseImportedFilePaths(documents.path);
          final brokenReferences =
              await _database.customSelect('PRAGMA foreign_key_check').get();
          if (brokenReferences.isNotEmpty) {
            throw StateError(
                'The archive contains records with missing parent data.');
          }
          await _replaceImportedDocuments(importedDocuments);
        });
      } finally {
        await _database.customStatement('DETACH DATABASE imported_archive');
      }
    } catch (_) {
      await _restoreImportedDocuments(importedDocuments);
      rethrow;
    } finally {
      if (await staging.exists()) await staging.delete();
      for (final companion in stagingCompanions) {
        if (await companion.exists()) await companion.delete();
      }
      if (await documentRollback.exists()) {
        await documentRollback.delete(recursive: true);
      }
    }
    return ArchiveImportSummary(
      importedTables: availableTables.length,
      copiedFiles: importedDocuments.length,
    );
  }

  Future<String?> _importedDatabaseKey(Directory extracted) async {
    final manifest = File(p.join(extracted.path, 'MANIFEST.json'));
    if (await manifest.exists()) {
      final decoded = jsonDecode(await manifest.readAsString());
      if (decoded is Map && decoded['databaseEncryptionKey'] is String) {
        return decoded['databaseEncryptionKey'] as String;
      }
      // Portable backups created before database encryption are plaintext.
      return null;
    }
    // Automatic safety snapshots never leave this device and use its key.
    return _databaseEncryptionKey();
  }

  Future<List<_ImportedDocument>> _prepareImportedDocuments(
    Directory extracted,
    Directory documents,
    Directory rollback,
  ) async {
    final sourceRoot = Directory(p.join(extracted.path, 'documents'));
    if (!await sourceRoot.exists()) return const [];
    final manifestFile = File(p.join(extracted.path, 'MANIFEST.json'));
    var isOriginalLegacyManifest = false;
    if (await manifestFile.exists()) {
      final decoded = jsonDecode(await manifestFile.readAsString());
      isOriginalLegacyManifest = decoded is Map &&
          decoded['format'] == 'SmartLoad local audit archive' &&
          decoded['formatVersion'] == null;
    }
    final result = <_ImportedDocument>[];
    await for (final entity in sourceRoot.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final relative = p
          .relative(entity.path, from: sourceRoot.path)
          .replaceAll(p.separator, '/');
      final allowed = isOriginalLegacyManifest
          ? _isAllowedLegacyImportedDocumentPath('documents/$relative')
          : _isBackedUpDocumentPath(relative);
      if (!allowed) {
        throw StateError('The backup contains an unsupported document path.');
      }
      final destination = File(p.joinAll([
        documents.path,
        ...p.posix.split(relative),
      ]));
      File? original;
      if (await destination.exists()) {
        original = File(p.joinAll([
          rollback.path,
          ...p.posix.split(relative),
        ]));
        await original.parent.create(recursive: true);
        await destination.copy(original.path);
      }
      result.add(_ImportedDocument(
        source: entity,
        destination: destination,
        original: original,
      ));
    }
    return result;
  }

  Future<void> _replaceImportedDocuments(
      List<_ImportedDocument> documents) async {
    for (final document in documents) {
      await document.destination.parent.create(recursive: true);
      final temporary = File(
          '${document.destination.path}.smartload-importing-${DateTime.now().microsecondsSinceEpoch}');
      try {
        await document.source.copy(temporary.path);
        if (await document.destination.exists()) {
          await document.destination.delete();
        }
        await temporary.rename(document.destination.path);
      } finally {
        if (await temporary.exists()) await temporary.delete();
      }
    }
  }

  Future<void> _restoreImportedDocuments(
      List<_ImportedDocument> documents) async {
    for (final document in documents.reversed) {
      if (await document.destination.exists()) {
        await document.destination.delete();
      }
      if (document.original case final original?) {
        await document.destination.parent.create(recursive: true);
        await original.copy(document.destination.path);
      }
    }
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

  Future<void> _normalizeImportedData() async {
    final wagons = await _database.select(_database.wagons).get();
    for (final w in wagons) {
      String jsonStr = w.itemManifestJson;
      try {
        final parsed = jsonDecode(w.itemManifestJson);
        if (parsed is List) {
          final List<Map<String, dynamic>> updatedItems = [];
          for (var item in parsed) {
            if (item is Map<String, dynamic>) {
              item['name'] =
                  FieldNormalizer.title(item['name']?.toString() ?? '');
              updatedItems.add(item);
            }
          }
          jsonStr = jsonEncode(updatedItems);
        }
      } catch (_) {}

      await _database.update(_database.wagons).replace(
            w.copyWith(
              wagonNumber: FieldNormalizer.code(w.wagonNumber),
              origin: Value(FieldNormalizer.title(w.origin ?? '')),
              destination: Value(FieldNormalizer.title(w.destination ?? '')),
              remarks: Value(FieldNormalizer.text(w.remarks)),
              itemManifestJson: jsonStr,
            ),
          );
    }

    final trucks = await _database.select(_database.trucks).get();
    for (final t in trucks) {
      await _database.update(_database.trucks).replace(
            t.copyWith(
              truckNumber: FieldNormalizer.code(t.truckNumber),
              vehicleNumber: FieldNormalizer.code(t.vehicleNumber),
              driverName: FieldNormalizer.title(t.driverName),
              company: FieldNormalizer.title(t.company),
              warehouse: Value(FieldNormalizer.title(t.warehouse ?? '')),
              notes: Value(FieldNormalizer.text(t.notes)),
            ),
          );
    }

    final layers = await _database.select(_database.layers).get();
    for (final l in layers) {
      String jsonStr = l.itemAllocationsJson;
      try {
        final parsed = jsonDecode(l.itemAllocationsJson);
        if (parsed is List) {
          final List<Map<String, dynamic>> updatedAllocations = [];
          for (var alloc in parsed) {
            if (alloc is Map<String, dynamic>) {
              alloc['itemName'] =
                  FieldNormalizer.title(alloc['itemName']?.toString() ?? '');
              updatedAllocations.add(alloc);
            }
          }
          jsonStr = jsonEncode(updatedAllocations);
        }
      } catch (_) {}

      await _database.update(_database.layers).replace(
            l.copyWith(
              itemName: Value(l.itemName != null
                  ? FieldNormalizer.title(l.itemName!)
                  : null),
              itemAllocationsJson: jsonStr,
              notes: Value(FieldNormalizer.text(l.notes)),
            ),
          );
    }
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
    if (await manifestFile.length() > 8 * 1024 * 1024) {
      throw StateError('The archive integrity manifest is too large.');
    }
    final manifest = jsonDecode(await manifestFile.readAsString());
    if (manifest is! Map) {
      throw StateError('The selected folder is not a SmartLoad backup.');
    }
    final isProtectedFormat =
        manifest['format'] == 'SmartLoad protected local backup' &&
            manifest['formatVersion'] == 3;
    final isLegacyFormat = manifest['format'] ==
            'SmartLoad local audit archive' &&
        (manifest['formatVersion'] == null || manifest['formatVersion'] == 2);
    if ((!isProtectedFormat && !isLegacyFormat) || manifest['files'] is! List) {
      throw StateError(
          'This archive is from an unsupported format. Create a new protected backup from the source device.');
    }
    final listedPaths = <String>{};
    final isOriginalLegacyManifest =
        isLegacyFormat && manifest['formatVersion'] == null;
    for (final entry in manifest['files'] as List) {
      if (entry is! Map || entry['path'] is! String) {
        throw StateError('The archive integrity manifest is invalid.');
      }
      final hasDigest = entry['sha256'] is String;
      // The first local-only release recorded file sizes but not hashes. Keep
      // this narrowly scoped compatibility path so those genuine SmartLoad
      // backups remain restorable; every newer archive still requires SHA-256.
      if (!hasDigest &&
          (!isOriginalLegacyManifest || entry['sizeBytes'] is! num)) {
        throw StateError('The archive integrity manifest is invalid.');
      }
      final relativePath = entry['path'] as String;
      final segments = p.posix.split(relativePath);
      if (relativePath.startsWith('/') ||
          relativePath.contains('\\') ||
          segments.any((segment) => segment == '..' || segment.isEmpty) ||
          !listedPaths.add(relativePath)) {
        throw StateError(
            'The archive integrity manifest contains an unsafe path.');
      }
      if (relativePath.startsWith('documents/') &&
          !(isOriginalLegacyManifest
              ? _isAllowedLegacyImportedDocumentPath(relativePath)
              : _isAllowedImportedDocumentPath(relativePath))) {
        throw StateError('The archive contains an unsupported document type '
            '(${p.basename(relativePath)}). SmartLoad cannot safely restore it.');
      }
      final file =
          File(p.joinAll([folder.path, ...p.posix.split(relativePath)]));
      if (!await file.exists()) {
        throw StateError('The archive integrity check failed.');
      }
      if (hasDigest && await _sha256File(file) != entry['sha256']) {
        throw StateError('The archive integrity check failed.');
      }
      if (!hasDigest &&
          await file.length() != (entry['sizeBytes'] as num).toInt()) {
        throw StateError('The archive integrity check failed.');
      }
    }
    if (!listedPaths.contains('database/smartload_offline.sqlite')) {
      throw StateError('The archive integrity manifest omits its database.');
    }

    final extractedPaths = <String>{'MANIFEST.json'};
    await for (final entity
        in folder.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      extractedPaths.add(
        p.relative(entity.path, from: folder.path).replaceAll(p.separator, '/'),
      );
    }
    final expectedPaths = <String>{'MANIFEST.json', ...listedPaths};
    if (extractedPaths.length != expectedPaths.length ||
        !extractedPaths.containsAll(expectedPaths)) {
      throw StateError(
          'The archive contains files that are not authenticated by its integrity manifest.');
    }
    return folder;
  }

  static bool _isBackedUpDocumentPath(String relativePath) {
    final normalized = relativePath.replaceAll('\\', '/');
    if (normalized.startsWith('smartload_images/') ||
        normalized.startsWith('activity_logs/')) {
      return true;
    }
    if (normalized.contains('/')) return false;
    final lower = normalized.toLowerCase();
    return normalized.startsWith('SmartLoad_') &&
        (lower.endsWith('.pdf') ||
            lower.endsWith('.xlsx') ||
            lower.endsWith('.csv') ||
            lower.endsWith('.zip'));
  }

  static bool _isAllowedImportedDocumentPath(String archivePath) {
    const prefix = 'documents/';
    if (!archivePath.startsWith(prefix)) return false;
    return _isBackedUpDocumentPath(archivePath.substring(prefix.length));
  }

  /// The first unprotected SmartLoad backups copied the whole Documents
  /// directory, so their generated reports did not always use a
  /// `SmartLoad_` prefix. Preserve those backups while still restricting
  /// restored files to non-executable operational documents and images.
  static bool _isAllowedLegacyImportedDocumentPath(String archivePath) {
    const prefix = 'documents/';
    if (!archivePath.startsWith(prefix)) return false;
    final relative = archivePath.substring(prefix.length).replaceAll('\\', '/');
    if (relative.isEmpty) return false;
    final lower = relative.toLowerCase();
    const extensions = <String>{
      '.bak',
      '.csv',
      '.db',
      '.docx',
      '.jpeg',
      '.jpg',
      '.json',
      '.log',
      '.pdf',
      '.png',
      '.sqlite',
      '.sqlite-shm',
      '.sqlite-wal',
      '.txt',
      '.webp',
      '.xlsx',
      '.zip',
    };
    // Legacy archives copied the Documents tree verbatim, including nested
    // report/export folders. The manifest/path checks above already reject
    // absolute paths, backslashes, empty segments, and `..` traversal.
    return extensions.any(lower.endsWith);
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

class _ImportedDocument {
  const _ImportedDocument({
    required this.source,
    required this.destination,
    required this.original,
  });

  final File source;
  final File destination;
  final File? original;
}

void _extractArchiveSync(String archivePath, String targetPath) {
  final input = InputFileStream(archivePath);
  try {
    final archive = ZipDecoder().decodeBuffer(input);
    var totalBytes = 0;
    var fileCount = 0;
    final names = <String>{};
    for (final entry in archive) {
      final name = entry.name.replaceAll('\\', '/');
      final segments = p.posix.split(name);
      if (name.isEmpty ||
          name.startsWith('/') ||
          segments.any((segment) => segment == '..' || segment.isEmpty)) {
        throw StateError('The archive contains an unsafe file path.');
      }
      if (!entry.isFile) continue;
      if (!names.add(name)) {
        throw StateError('The archive contains duplicate file paths.');
      }
      fileCount++;
      totalBytes += entry.size;
      final maxEntryBytes = name.endsWith('database/smartload_offline.sqlite')
          ? 768 * 1024 * 1024
          : 256 * 1024 * 1024;
      if (entry.size > maxEntryBytes ||
          fileCount > 20000 ||
          totalBytes > 1024 * 1024 * 1024) {
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
  required String? databaseEncryptionKey,
}) async {
  final encoder = ZipFileEncoder();
  final inventory = <Map<String, Object>>[];
  encoder.create(archivePath);
  try {
    for (final file in files) {
      final source = File(file['source']!);
      final destination = file['archivePath']!.replaceAll(p.separator, '/');
      await encoder.addFile(source, destination);
      inventory.add({
        'path': destination,
        'sizeBytes': await source.length(),
        'sha256': file['sha256']!,
      });
    }
    encoder.addArchiveFile(ArchiveFile.string(
      'MANIFEST.json',
      jsonEncode({
        'format': 'SmartLoad protected local backup',
        'formatVersion': 3,
        'createdAtUtc': DateTime.now().toUtc().toIso8601String(),
        'database': 'database/smartload_offline.sqlite',
        if (databaseEncryptionKey != null)
          'databaseEncryptionKey': databaseEncryptionKey,
        'includes': [
          'SQLite operational data and audit logs',
          'saved images, backups, and locally generated reports/exports',
        ],
        'excludes': [
          'platform-secure login tokens and cached password hashes',
          'temporary processing/cache files',
          'previous full-data backup ZIP archives',
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

Future<String> _sha256File(File file) async =>
    (await sha256.bind(file.openRead()).first).toString();

List<int> _chunkNonce(List<int> prefix, int index) => <int>[
      ...prefix,
      (index >> 24) & 0xff,
      (index >> 16) & 0xff,
      (index >> 8) & 0xff,
      index & 0xff,
    ];
