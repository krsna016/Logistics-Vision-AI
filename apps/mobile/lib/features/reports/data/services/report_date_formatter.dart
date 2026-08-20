class ReportDateFormatter {
  static String formatDate(dynamic date) {
    if (date == null) return 'N/A';
    DateTime parsed;
    if (date is DateTime) {
      parsed = date;
    } else if (date is String) {
      final parsedDate = DateTime.tryParse(date);
      if (parsedDate == null) return date;
      parsed = parsedDate;
    } else {
      return date.toString();
    }
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(dynamic date) {
    if (date == null) return 'N/A';
    DateTime parsed;
    if (date is DateTime) {
      parsed = date;
    } else if (date is String) {
      final parsedDate = DateTime.tryParse(date);
      if (parsedDate == null) return date;
      parsed = parsedDate;
    } else {
      return date.toString();
    }
    final ymd =
        '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    final hms =
        '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}:${parsed.second.toString().padLeft(2, '0')}';
    return '$ymd $hms';
  }
}
