import 'package:hive_flutter/hive_flutter.dart';

import '../models/location_point.dart';

class TrackingStorageService {

  static const String boxName = "offline_routes";

  static Box get _box => Hive.box(boxName);

  /// ===================================================
  /// SAVE ONE LOCATION
  /// ===================================================

  static Future<void> savePoint(
      LocationPoint point,
      ) async {

    await _box.add(
      point.toJson(),
    );
  }

  /// ===================================================
  /// GET ALL LOCATIONS
  /// ===================================================

  static List<LocationPoint> getAllPoints() {

    return _box.values

        .map(
          (e) => LocationPoint.fromJson(
        Map<String, dynamic>.from(e),
      ),
    )

        .toList();
  }

  /// ===================================================
  /// GET LOCATIONS OF ONE TOUR
  /// ===================================================

  static List<LocationPoint> getTourPoints(
      String tourId,
      ) {

    return getAllPoints()

        .where(
          (e) => e.tourId == tourId,
    )

        .toList();
  }

  /// ===================================================
  /// GET PENDING LOCATIONS
  /// ===================================================

  static List<LocationPoint> getPendingPoints() {

    return getAllPoints()

        .where(
          (e) => e.uploaded == false,
    )

        .toList();
  }

  /// ===================================================
  /// UPDATE ONE LOCATION
  /// ===================================================

  static Future<void> updatePoint(

      int hiveIndex,

      LocationPoint point,

      ) async {

    await _box.put(

      hiveIndex,

      point.toJson(),

    );
  }

  /// ===================================================
  /// MARK AS UPLOADED
  /// ===================================================

  static Future<void> markUploaded() async {

    for(int i=0;i<_box.length;i++){

      final point = LocationPoint.fromJson(

        Map<String,dynamic>.from(

          _box.getAt(i),

        ),

      );

      point.uploaded=true;

      await _box.putAt(

        i,

        point.toJson(),

      );

    }

  }

  /// ===================================================
  /// DELETE UPLOADED
  /// ===================================================

  static Future<void> removeUploaded() async {

    final List<int> indexes = [];

    for (int i = 0; i < _box.length; i++) {

      final point = LocationPoint.fromJson(

        Map<String, dynamic>.from(
          _box.getAt(i),
        ),

      );

      if (point.uploaded) {

        indexes.add(i);

      }
    }

    indexes.reversed.forEach(

          (index) {

        _box.deleteAt(index);

      },

    );
  }

  /// ===================================================
  /// MARK ONLY UPLOADED BATCH
  /// ===================================================

  static Future<void> markUploadedBatch(
      List<LocationPoint> uploadedPoints,
      ) async {

    for (int i = 0; i < _box.length; i++) {

      final point = LocationPoint.fromJson(
        Map<String, dynamic>.from(
          _box.getAt(i),
        ),
      );

      final exists = uploadedPoints.any(
            (e) =>
        e.tourId == point.tourId &&
            e.timestamp == point.timestamp,
      );

      if (exists) {

        point.uploaded = true;

        await _box.putAt(
          i,
          point.toJson(),
        );

      }

    }

  }

  /// ===================================================
  /// CLEAR EVERYTHING
  /// ===================================================

  static Future<void> clearAll() async {

    await _box.clear();

  }

}