import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'screens/check_login.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

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
    ),

    iosNotificationOptions:
    const IOSNotificationOptions(),

    foregroundTaskOptions:
    ForegroundTaskOptions(

      eventAction:
      ForegroundTaskEventAction.repeat(5000),

      autoRunOnBoot: false,

      autoRunOnMyPackageReplaced: true,

      allowWakeLock: true,

      allowWifiLock: true,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

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