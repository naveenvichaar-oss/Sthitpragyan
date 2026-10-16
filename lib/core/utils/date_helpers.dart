import 'package:intl/intl.dart';

/// DateHelpers provides utility functions for date manipulations,
/// day key generation for Hive, and executive streak checks.
class DateHelpers {
  DateHelpers._();

  static final DateFormat _displayFormat = DateFormat('EEEE, MMMM d');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _storageKeyFormat = DateFormat('yyyy-MM-dd');

  /// Formats date for executive dashboard header (e.g. "Tuesday, October 17")
  static String formatExecutiveDate(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Formats short date for history chips (e.g. "Oct 17")
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Formats time (e.g. "9:30 PM")
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Produces a deterministic normalized storage key (e.g. "2026-10-17")
  static String toStorageKey(DateTime date) {
    return _storageKeyFormat.format(date);
  }

  /// Returns date stripped of hour, minute, second, millisecond
  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Determines if two dates fall on the exact same calendar day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns true if date [a] is yesterday relative to date [b]
  static bool isYesterday(DateTime candidate, DateTime today) {
    final normCandidate = normalize(candidate);
    final normToday = normalize(today);
    return normToday.difference(normCandidate).inDays == 1;
  }

  /// Returns a list of the last 7 calendar days ending today
  static List<DateTime> getLast7Days([DateTime? fromDate]) {
    final anchor = normalize(fromDate ?? DateTime.now());
    return List.generate(7, (index) {
      return anchor.subtract(Duration(days: 6 - index));
    });
  }
}
