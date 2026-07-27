class BackupArchive {
  final String id;
  final DateTime createdAt;
  final String version;
  final double sizeMB;
  final String createdBy;
  final bool isAutomatic;
  final bool isEncrypted;
  final BackupIntegrity status;

  const BackupArchive({
    required this.id,
    required this.createdAt,
    required this.version,
    required this.sizeMB,
    required this.createdBy,
    required this.isAutomatic,
    this.isEncrypted = true,
    this.status = BackupIntegrity.verified,
  });
}

enum BackupIntegrity {
  verified('Verified', true),
  pending('Verifying...', false),
  corrupted('Corrupted', false);

  final String label;
  final bool isValid;
  const BackupIntegrity(this.label, this.isValid);
}
