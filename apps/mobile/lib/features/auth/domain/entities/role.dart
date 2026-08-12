enum Role {
  supervisor('Supervisor', 1),
  administrator('Administrator', 2);

  final String displayName;
  final int level;

  const Role(this.displayName, this.level);

  bool get canCaptureScans => true;
  bool get canSaveLayers => true;
  bool get canCorrectManually => true;
  bool get canApproveCorrections => true;
  bool get canCompleteTrucks => true;
  bool get canCompleteWagons => true;
  bool get canExportData => true;
  bool get canViewAnalytics => true;
  bool get canManageWagons => true;
  bool get canArchiveRecords => true;
  bool get canExportReports => true;
  bool get canRestoreBackups => true;
  bool get canManageUsers => this == Role.administrator;
  bool get canManageSecurity => this == Role.administrator;
  bool get canManageDevices => this == Role.administrator;
  bool get canModifyDigitalRegisters => this == Role.administrator;
}

Role parseRole(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'administrator':
    case 'admin':
      return Role.administrator;
    case 'supervisor':
    case 'manager':
    case 'operator':
    default:
      return Role.supervisor;
  }
}
