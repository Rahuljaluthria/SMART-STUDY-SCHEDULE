import 'package:intl/intl.dart';

class IntlHelper {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat.jm().format(time);
  }
}
