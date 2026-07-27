enum TimeFilter {
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days'),
  thisMonth('This Month'),
  custom('Custom Range');

  final String displayName;
  const TimeFilter(this.displayName);
}
