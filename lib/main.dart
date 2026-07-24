import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/splash_screen.dart';
import 'taskhandler/location_task_handler.dart';

Future<void> main() async {
  final Stopwatch stopwatch = Stopwatch()..start();

  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("1. Widgets Binding : ${stopwatch.elapsedMilliseconds} ms");

  await Hive.initFlutter();
  debugPrint("2. Hive Init : ${stopwatch.elapsedMilliseconds} ms");

  final sw = Stopwatch()..start();

  await Hive.openBox('settings');
  debugPrint("settings: ${sw.elapsedMilliseconds}");

  await Hive.openBox('tour_tracking');
  debugPrint("tour_tracking: ${sw.elapsedMilliseconds}");

  await Hive.openBox('offline_routes');
  debugPrint("offline_routes: ${sw.elapsedMilliseconds}");

  await Hive.openBox('location_cache');
  debugPrint("location_cache: ${sw.elapsedMilliseconds}");

  await Hive.openBox('tour_session');
  debugPrint("tour_session: ${sw.elapsedMilliseconds}");
  debugPrint("3. Hive Boxes Opened : ${stopwatch.elapsedMilliseconds} ms");

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

  debugPrint("4. ForegroundTask Init : ${stopwatch.elapsedMilliseconds} ms");

  runApp(const MyApp());

  debugPrint("5. runApp() : ${stopwatch.elapsedMilliseconds} ms");

  stopwatch.stop();
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
      home: const SplashScreen(),
    );
  }
}