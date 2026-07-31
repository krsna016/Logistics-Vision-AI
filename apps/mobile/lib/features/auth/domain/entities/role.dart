enum Role {
  operator('Operator', 1),
  supervisor('Supervisor', 2),
  manager('Warehouse Manager', 3),
  administrator('Administrator', 4);

  final String displayName;
  final int level;

  const Role(this.displayName, this.level);

  // Operator checks
  bool get canCaptureScans => level >= 1;
  bool get canSaveLayers => level >= 1;
  bool get canCorrectManually => level >= 1;

  // Supervisor checks
  bool get canApproveCorrections => level >= 2;
  bool get canCompleteTrucks => level >= 2;
  bool get canCompleteWagons => level >= 2;
  bool get canExportData => level >= 2;

  // Manager checks
  bool get canViewAnalytics => level >= 3;
  bool get canManageWagons => level >= 3;
  bool get canArchiveRecords => level >= 3;
  bool get canExportReports => level >= 3;
  bool get canRestoreBackups => level >= 3;

  // Admin checks
  bool get canManageUsers => level >= 4;
  bool get canManageSecurity => level >= 4;
  bool get canManageDevices => level >= 4;
}
