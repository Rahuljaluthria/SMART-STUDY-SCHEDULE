import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsHelper {
  static const String _scheduleKey = 'study_schedule';

  // Save schedule
  static Future<void> saveSchedule(Map<String, String> schedule) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_scheduleKey, jsonEncode(schedule));
  }

  // Load schedule
  static Future<Map<String, String>?> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    String? scheduleJson = prefs.getString(_scheduleKey);
    if (scheduleJson != null) {
      return Map<String, String>.from(jsonDecode(scheduleJson));
    }
    return null;
  }
}
