import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/check_login.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // ================= HIVE INIT =================

  await Hive.initFlutter();

  await Hive.openBox('settings');

  await Hive.openBox('tour_tracking');

  await Hive.openBox('offline_routes');

  await Hive.openBox('location_cache');

  await Hive.openBox('tour_session');

  // ================= FOREGROUND TASK =================
  // ANDROID ONLY EXECUTION

  FlutterForegroundTask.init(

    androidNotificationOptions:
    AndroidNotificationOptions(

      channelId: 'tour_tracking_channel',

      channelName: 'Tour Tracking',

      channelDescription:
      'Background tracking notification',

      channelImportance:
      NotificationChannelImportance.HIGH,

      priority:
      NotificationPriority.HIGH,

      enableVibration: false,

      playSound: false,

      showWhen: true,
    ),

    // REQUIRED BY PLUGIN
    // SAFE FOR IOS
    iosNotificationOptions:
    const IOSNotificationOptions(

      showNotification: false,

      playSound: false,
    ),

    foregroundTaskOptions:
    ForegroundTaskOptions(

      eventAction:
      ForegroundTaskEventAction.repeat(5000),

      autoRunOnBoot:
      Platform.isAndroid,

      autoRunOnMyPackageReplaced:
      Platform.isAndroid,

      allowWakeLock:
      Platform.isAndroid,

      allowWifiLock:
      Platform.isAndroid,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'PRSC TA',

      theme: ThemeData(

        colorSchemeSeed: Colors.blue,

        useMaterial3: true,
      ),

      home: CheckLogin(),
    );
  }
}