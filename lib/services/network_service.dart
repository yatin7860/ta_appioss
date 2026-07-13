import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {

  static StreamSubscription<List<ConnectivityResult>>? subscription;

  static void startListening(
      Future<void> Function() onConnected,
      ) {

    subscription?.cancel();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((result) async {

      if (!result.contains(ConnectivityResult.none)) {

        await onConnected();

      }

    });

  }

  static Future<void> stopListening() async {

    await subscription?.cancel();

  }

}