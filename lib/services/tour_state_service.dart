import 'package:shared_preferences/shared_preferences.dart';

class TourStateService {

  static const String key =
      "tour_running";

  static Future<void> setRunning(
      bool value,
      ) async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      key,
      value,
    );
  }

  static Future<bool> isRunning() async {

    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(key) ?? false;
  }
}
