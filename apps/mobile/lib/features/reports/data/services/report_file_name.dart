String buildReportFileName({
  required String reportName,
  String? subject,
  required String extension,
  DateTime? generatedAt,
}) {
  final time = (generatedAt ?? DateTime.now()).toLocal();
  final dateStamp = '${time.year.toString().padLeft(4, '0')}-'
      '${time.month.toString().padLeft(2, '0')}-'
      '${time.day.toString().padLeft(2, '0')}_'
      '${time.hour.toString().padLeft(2, '0')}-'
      '${time.minute.toString().padLeft(2, '0')}-'
      '${time.second.toString().padLeft(2, '0')}';
  final subjectPart = subject == null || subject.trim().isEmpty
      ? ''
      : '_${_safeFilePart(subject)}';
  return 'SmartLoad_${_safeFilePart(reportName)}${subjectPart}_$dateStamp.$extension';
}

String _safeFilePart(String value) {
  final normalized = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
  return normalized.replaceAll(RegExp(r'^_+|_+$'), '').isEmpty
      ? 'Report'
      : normalized.replaceAll(RegExp(r'^_+|_+$'), '');
}
