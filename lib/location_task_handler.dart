import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class LocationTaskHandler extends TaskHandler {

  @override
  Future<void> onStart(
      DateTime timestamp,
      TaskStarter starter,
      ) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(
      DateTime timestamp,
      bool isTimeout,
      ) async {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/");
  }

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onReceiveData(Object data) {}
}