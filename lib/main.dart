import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/check_login.dart';
import 'taskhandler/location_task_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================================
  // HIVE INITIALIZATION
  // ==========================================================

  await Hive.initFlutter();

  await Hive.openBox('settings');
  await Hive.openBox('tour_tracking');
  await Hive.openBox('offline_routes');
  await Hive.openBox('location_cache');
  await Hive.openBox('tour_session');

  // ==========================================================
  // FOREGROUND TASK
  // Android uses Foreground Service
  // iOS ignores Android options automatically
  // ==========================================================

  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'tour_tracking_channel',
      channelName: 'Tour Tracking',
      channelDescription: 'Tracking employee location',

      channelImportance: NotificationChannelImportance.HIGH,
      priority: NotificationPriority.HIGH,

      enableVibration: false,
      playSound: false,
      showWhen: true,
    ),

    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),

    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),

      autoRunOnBoot: Platform.isAndroid,
      autoRunOnMyPackageReplaced: Platform.isAndroid,

      allowWakeLock: Platform.isAndroid,
      allowWifiLock: Platform.isAndroid,
    ),
  );

  runApp(const MyApp());
}
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(
    LocationTaskHandler(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'PRSC TA',

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),

      home: CheckLogin(),
    );
  }
}