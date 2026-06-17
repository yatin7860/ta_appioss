import 'package:hive_flutter/hive_flutter.dart';

class SessionService {
  static const String boxName = 'tour_session';

  static Future<void> saveActiveSession(
      String sessionId,
      ) async {
    final box = Hive.box(boxName);

    await box.put(
      'active_session',
      sessionId,
    );
  }

  static String? getActiveSession() {
    final box = Hive.box(boxName);

    return box.get(
      'active_session',
    );
  }

  static Future<void> clearSession() async {
    final box = Hive.box(boxName);

    await box.delete(
      'active_session',
    );
  }
}