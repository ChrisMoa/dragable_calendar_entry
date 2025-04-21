import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDateRange(DateTime start, DateTime end) {
    final isSameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;

    if (isSameDay) {
      return '${DateFormat('MMM d, yyyy').format(start)} ${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';
    } else {
      return '${DateFormat('MMM d, h:mm a').format(start)} - ${DateFormat('MMM d, h:mm a').format(end)}';
    }
  }

  static DateTime roundToNearestHour(DateTime dateTime) {
    final minutes = dateTime.minute;
    if (minutes < 30) {
      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        0,
      );
    } else {
      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour + 1,
        0,
      );
    }
  }
}
