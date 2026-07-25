enum ExportType {
  pdf,
  excel,
  csv,
  print,
  share,
}

abstract class ReportExporter {
  Future<bool> exportRegister(String registerId, ExportType type);
}

class MockReportExporter implements ReportExporter {
  @override
  Future<bool> exportRegister(String registerId, ExportType type) async {
    // Simulated export delay for UX verification
    await Future.delayed(const Duration(milliseconds: 1200));
    return true;
  }
}
