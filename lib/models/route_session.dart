class RouteSession {

  /// Tour ID from backend
  final String tourId;

  /// Unique session id
  final String sessionId;

  /// Tour start time
  final DateTime startTime;

  /// Tour end time
  final DateTime? endTime;

  /// Current status
  final bool isRunning;

  /// Pause status
  final bool isPaused;

  /// Last uploaded location index
  final int lastUploadedIndex;

  /// Total locations stored
  final int totalPoints;

  RouteSession({
    required this.tourId,
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.isRunning,
    required this.isPaused,
    required this.lastUploadedIndex,
    required this.totalPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      "tourId": tourId,
      "sessionId": sessionId,
      "startTime": startTime.millisecondsSinceEpoch,
      "endTime": endTime?.millisecondsSinceEpoch,
      "isRunning": isRunning,
      "isPaused": isPaused,
      "lastUploadedIndex": lastUploadedIndex,
      "totalPoints": totalPoints,
    };
  }

  factory RouteSession.fromJson(
      Map<dynamic, dynamic> json) {

    return RouteSession(

      tourId: json["tourId"],

      sessionId: json["sessionId"],

      startTime:
      DateTime.fromMillisecondsSinceEpoch(
        json["startTime"],
      ),

      endTime: json["endTime"] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
        json["endTime"],
      ),

      isRunning: json["isRunning"] ?? false,

      isPaused: json["isPaused"] ?? false,

      lastUploadedIndex:
      json["lastUploadedIndex"] ?? 0,

      totalPoints:
      json["totalPoints"] ?? 0,
    );
  }

  RouteSession copyWith({

    DateTime? endTime,

    bool? isRunning,

    bool? isPaused,

    int? lastUploadedIndex,

    int? totalPoints,

  }) {

    return RouteSession(

      tourId: tourId,

      sessionId: sessionId,

      startTime: startTime,

      endTime: endTime ?? this.endTime,

      isRunning: isRunning ?? this.isRunning,

      isPaused: isPaused ?? this.isPaused,

      lastUploadedIndex:
      lastUploadedIndex ??
          this.lastUploadedIndex,

      totalPoints:
      totalPoints ??
          this.totalPoints,
    );
  }
}