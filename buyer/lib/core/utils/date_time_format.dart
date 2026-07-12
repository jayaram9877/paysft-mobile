/// Lightweight date/time formatting for meeting cards — no external deps.
class DateTimeFormat {
  const DateTimeFormat._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  /// e.g. "Mon, 12 Aug 2026".
  static String date(DateTime dt) {
    final wd = _weekdays[dt.weekday - 1];
    return '$wd, ${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  /// e.g. "3:30 PM".
  static String time(DateTime dt) {
    final h24 = dt.hour;
    final ampm = h24 < 12 ? 'AM' : 'PM';
    var h = h24 % 12;
    if (h == 0) h = 12;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }

  /// e.g. "Mon, 12 Aug 2026 · 3:30 PM".
  static String dateTime(DateTime dt) => '${date(dt)} · ${time(dt)}';

  /// Relative-ish label for upcoming visits, e.g. "Today", "Tomorrow" or the date.
  static String dayLabel(DateTime dt, DateTime now) {
    final d = DateTime(dt.year, dt.month, dt.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return date(dt);
  }
}
