import 'package:hive_flutter/hive_flutter.dart';

import '../models/tour_session.dart';

class SessionService {

  static const String boxName = "tour_session";

  static const String activeSessionKey =
      "active_session";

  static const String tourSessionKey =
      "tour_session";

  static Box get _box =>
      Hive.box(boxName);

  // =====================================
  // OLD METHODS (USED IN PART 1-9)
  // =====================================

  static Future<void> saveActiveSession(
      String sessionId,
      ) async {

    await _box.put(

      activeSessionKey,

      sessionId,

    );

  }

  static String? getActiveSession() {

    return _box.get(
      activeSessionKey,
    );

  }

  // =====================================
  // NEW METHODS (PART 10)
  // =====================================

  static Future<void> saveSession(
      TourSession session,
      ) async {

    await _box.put(

      tourSessionKey,

      session.toJson(),

    );

  }

  static TourSession? getSession() {

    final data =
    _box.get(tourSessionKey);

    if (data == null) {

      return null;

    }

    return TourSession.fromJson(

      Map<String, dynamic>.from(
        data,
      ),

    );

  }

  static Future<void> clearSession() async {

    await _box.delete(
      activeSessionKey,
    );

    await _box.delete(
      tourSessionKey,
    );

  }

}