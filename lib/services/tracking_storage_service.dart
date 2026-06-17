import 'package:hive_flutter/hive_flutter.dart';
import '../models/location_point.dart';

class TrackingStorageService {

  static const String boxName =
      "offline_routes";

  static Future<void> savePoint(
      LocationPoint point,
      ) async {

    final box =
    Hive.box(boxName);

    await box.add(
      point.toJson(),
    );
  }

  static List<LocationPoint>
  getSessionPoints(
      String sessionId,
      ) {

    final box =
    Hive.box(boxName);

    return box.values
        .map(
          (e) =>
          LocationPoint.fromJson(
            Map<String, dynamic>.from(e),
          ),
    )
        .where(
          (e) =>
      e.sessionId ==
          sessionId,
    )
        .toList();
  }

  static Future<void> clear() async {

    final box =
    Hive.box(boxName);

    await box.clear();
  }
}