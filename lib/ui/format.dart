const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Oct 26", or "Oct 26, 2025" outside the current year (local time).
String formatShortDate(DateTime date, DateTime now) {
  final local = date.toLocal();
  final day = '${_months[local.month - 1]} ${local.day}';
  return local.year == now.toLocal().year ? day : '$day, ${local.year}';
}
