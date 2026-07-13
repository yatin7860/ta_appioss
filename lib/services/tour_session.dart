class TourSession {

  final String tourId;

  final String sessionId;

  final bool isRunning;

  final bool isPaused;

  final DateTime startedAt;

  TourSession({
    required this.tourId,
    required this.sessionId,
    required this.isRunning,
    required this.isPaused,
    required this.startedAt,
  });

  Map<String, dynamic> toJson() {

    return {

      "tourId": tourId,

      "sessionId": sessionId,

      "isRunning": isRunning,

      "isPaused": isPaused,

      "startedAt": startedAt.toIso8601String(),

    };

  }

  factory TourSession.fromJson(
      Map<String, dynamic> json,
      ) {

    return TourSession(

      tourId: json["tourId"],

      sessionId: json["sessionId"],

      isRunning: json["isRunning"],

      isPaused: json["isPaused"],

      startedAt: DateTime.parse(
        json["startedAt"],
      ),

    );

  }

}