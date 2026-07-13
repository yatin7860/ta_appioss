class LocationPoint {

  final String tourId;

  final String sessionId;

  final double latitude;

  final double longitude;

  final String address;

  final bool pauseStatus;

  final int index;

  final double accuracy;

  final double speed;

  final DateTime timestamp;

  bool uploaded;

  LocationPoint({

    required this.tourId,

    required this.sessionId,

    required this.latitude,

    required this.longitude,

    required this.address,

    required this.pauseStatus,

    required this.index,

    required this.accuracy,

    required this.speed,

    required this.timestamp,

    this.uploaded = false,
  });

  Map<String, dynamic> toJson() {

    return {

      // API fields

      "tourId": tourId,

      "latitude": latitude,

      "longitude": longitude,

      "address": address,

      "pause_status": pauseStatus,

      "index": index,

      "timestamp": timestamp.millisecondsSinceEpoch,

      // Local only

      "sessionId": sessionId,

      "accuracy": accuracy,

      "speed": speed,

      "uploaded": uploaded,
    };
  }

  factory LocationPoint.fromJson(
      Map<dynamic, dynamic> json) {

    return LocationPoint(

      tourId: json["tourId"],

      sessionId: json["sessionId"] ?? "",

      latitude: (json["latitude"] as num).toDouble(),

      longitude: (json["longitude"] as num).toDouble(),

      address: json["address"] ?? "",

      pauseStatus: json["pause_status"] ?? false,

      index: json["index"] ?? 0,

      accuracy: (json["accuracy"] as num?)?.toDouble() ?? 0,

      speed: (json["speed"] as num?)?.toDouble() ?? 0,

      timestamp: json["timestamp"] is int
          ? DateTime.fromMillisecondsSinceEpoch(json["timestamp"])
          : DateTime.parse(json["timestamp"]),

      uploaded: json["uploaded"] ?? false,
    );
  }

  /// JSON sent to backend API
  Map<String, dynamic> toApiJson() {

    return {

      "tourId": tourId,

      "latitude": latitude,

      "longitude": longitude,

      "address": address,

      "pause_status": pauseStatus,

      "index": index,

      "timestamp": timestamp.millisecondsSinceEpoch,
    };
  }
}