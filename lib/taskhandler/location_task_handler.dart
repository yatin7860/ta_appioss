import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

import '../models/location_point.dart';
import '../services/tracking_storage_service.dart';
import '../services/tour_state_service.dart';

class LocationTaskHandler extends TaskHandler {

  StreamSubscription<Position>? _positionStream;

  int index = 0;

  @override
  Future<void> onStart(
      DateTime timestamp,
      TaskStarter starter,
      ) async {

    final session =
    TourStateService.getCurrentSession();

    if (session == null) return;

    _positionStream =
        Geolocator.getPositionStream(

          locationSettings:

          const LocationSettings(

            accuracy:
            LocationAccuracy.best,

            distanceFilter: 10,

          ),

        ).listen(

              (Position position) async {

            if (!TourStateService.isRunning()) {

              return;

            }

            if (TourStateService.isPaused()) {

              return;

            }

            String address = "";

            try {

              final places =
              await placemarkFromCoordinates(

                position.latitude,

                position.longitude,

              );

              if (places.isNotEmpty) {

                final p = places.first;

                address =

                "${p.street}, ${p.locality}, ${p.administrativeArea}";
              }

            } catch (_) {}

            final point = LocationPoint(

              tourId: session.tourId,

              sessionId: session.sessionId,

              latitude: position.latitude,

              longitude: position.longitude,

              address: address,

              pauseStatus: false,

              index: index,

              accuracy: position.accuracy,

              speed: position.speed,

              timestamp: DateTime.now(),

            );

            await TrackingStorageService.savePoint(
              point,
            );

            index++;

          },

        );
  }

  @override
  void onRepeatEvent(
      DateTime timestamp) {}

  @override
  Future<void> onDestroy(

      DateTime timestamp,

      bool isTimeout,

      ) async {

    await _positionStream?.cancel();

  }

  @override
  void onNotificationPressed() {

    FlutterForegroundTask.launchApp("/");

  }

  @override
  void onNotificationButtonPressed(
      String id) {}

  @override
  void onReceiveData(Object data) {}
}