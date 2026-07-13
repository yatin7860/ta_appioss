import 'package:hive_flutter/hive_flutter.dart';

import '../models/route_session.dart';

class TourStateService {

  static const String boxName = "tour_session";

  static Box get _box => Hive.box(boxName);

  //==========================================
  // START TOUR
  //==========================================

  static Future<void> startTour({

    required String tourId,

    required String sessionId,

  }) async {

    final session = RouteSession(

      tourId: tourId,

      sessionId: sessionId,

      startTime: DateTime.now(),

      endTime: null,

      isRunning: true,

      isPaused: false,

      lastUploadedIndex: 0,

      totalPoints: 0,

    );

    await _box.put(
      "current",
      session.toJson(),
    );
  }

  //==========================================
  // CURRENT SESSION
  //==========================================

  static RouteSession? getCurrentSession() {

    final data = _box.get("current");

    if (data == null) {

      return null;

    }

    return RouteSession.fromJson(

      Map<String, dynamic>.from(data),

    );
  }

  //==========================================
  // IS RUNNING
  //==========================================

  static bool isRunning() {

    final session = getCurrentSession();

    if (session == null) {

      return false;

    }

    return session.isRunning;
  }

  //==========================================
  // IS PAUSED
  //==========================================

  static bool isPaused() {

    final session = getCurrentSession();

    if (session == null) {

      return false;

    }

    return session.isPaused;
  }

  //==========================================
  // PAUSE TOUR
  //==========================================

  static Future<void> pauseTour() async {

    final session = getCurrentSession();

    if (session == null) {

      return;

    }

    final updated = session.copyWith(

      isPaused: true,

    );

    await _box.put(

      "current",

      updated.toJson(),

    );
  }

  //==========================================
  // RESUME TOUR
  //==========================================

  static Future<void> resumeTour() async {

    final session = getCurrentSession();

    if (session == null) {

      return;

    }

    final updated = session.copyWith(

      isPaused: false,

    );

    await _box.put(

      "current",

      updated.toJson(),

    );
  }

  //==========================================
  // STOP TOUR
  //==========================================

  static Future<void> stopTour() async {

    final session = getCurrentSession();

    if (session == null) {

      return;

    }

    final updated = session.copyWith(

      endTime: DateTime.now(),

      isRunning: false,

    );

    await _box.put(

      "current",

      updated.toJson(),

    );
  }

  //==========================================
  // UPDATE LAST INDEX
  //==========================================

  static Future<void> updateLastIndex(

      int index,

      ) async {

    final session = getCurrentSession();

    if (session == null) {

      return;

    }

    final updated = session.copyWith(

      lastUploadedIndex: index,

    );

    await _box.put(

      "current",

      updated.toJson(),

    );
  }

  //==========================================
  // UPDATE TOTAL POINTS
  //==========================================

  static Future<void> updateTotalPoints(

      int total,

      ) async {

    final session = getCurrentSession();

    if (session == null) {

      return;

    }

    final updated = session.copyWith(

      totalPoints: total,

    );

    await _box.put(

      "current",

      updated.toJson(),

    );
  }

  //==========================================
  // CLEAR SESSION
  //==========================================

  static Future<void> clearSession() async {

    await _box.delete(

      "current",

    );
  }
}