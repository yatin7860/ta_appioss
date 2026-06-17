class RouteSession {

  final String sessionId;

  final DateTime startTime;

  final DateTime? endTime;

  final double totalDistance;

  RouteSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.totalDistance,
  });

  Map<String, dynamic> toJson() {
    return {
      "sessionId": sessionId,
      "startTime": startTime.toIso8601String(),
      "endTime": endTime?.toIso8601String(),
      "totalDistance": totalDistance,
    };
  }

  factory RouteSession.fromJson(
      Map data,
      ) {
    return RouteSession(
      sessionId: data["sessionId"],
      startTime: DateTime.parse(
        data["startTime"],
      ),
      endTime: data["endTime"] == null
          ? null
          : DateTime.parse(
        data["endTime"],
      ),
      totalDistance:
      data["totalDistance"],
    );
  }
}