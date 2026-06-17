class LocationPoint {
  final String sessionId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed;
  final DateTime timestamp;

  LocationPoint({
    required this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      "sessionId": sessionId,
      "latitude": latitude,
      "longitude": longitude,
      "accuracy": accuracy,
      "speed": speed,
      "timestamp": timestamp.toIso8601String(),
    };
  }

  factory LocationPoint.fromJson(
      Map<dynamic, dynamic> json,
      ) {
    return LocationPoint(
      sessionId: json["sessionId"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      accuracy: json["accuracy"],
      speed: json["speed"],
      timestamp: DateTime.parse(
        json["timestamp"],
      ),
    );
  }
}