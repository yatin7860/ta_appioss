import 'dart:async';

class RetryService {

  static int retryCount = 0;

  static Timer? retryTimer;

  static void reset() {

    retryCount = 0;

    retryTimer?.cancel();

  }

  static Duration nextDelay() {

    switch (retryCount) {

      case 0:
        return const Duration(seconds: 30);

      case 1:
        return const Duration(minutes: 1);

      case 2:
        return const Duration(minutes: 2);

      case 3:
        return const Duration(minutes: 5);

      default:
        return const Duration(minutes: 10);

    }

  }

}