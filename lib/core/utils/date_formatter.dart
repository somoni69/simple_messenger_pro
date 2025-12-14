import 'package:intl/intl.dart';

class DateFormatter {
  static String formatMessageTime(DateTime date)  {
    final now = DateTime.now();
    final localDate = date.toLocal();

    if (now.year == localDate.year && 
        now.month == localDate.month &&
        now.day == localDate.day) {
          return DateFormat('HH:mm').format(localDate);
        } else {
          return DateFormat('d MMM HH:mm').format(localDate);
        }
  }
}