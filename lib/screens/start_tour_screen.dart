import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../location_task_handler.dart';
import '../models/location_point.dart';
import '../services/tracking_storage_service.dart';
import 'package:uuid/uuid.dart';
import '../services/session_service.dart';
import '../services/tour_state_service.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class StartTourScreen extends StatefulWidget {

  final String tourId;

  const StartTourScreen({
    super.key,
    required this.tourId,
  });


  @override
  State<StartTourScreen> createState() =>
      _StartTourScreenState();
}

class _StartTourScreenState
    extends State<StartTourScreen>
    with TickerProviderStateMixin {
    
  // ================= VARIABLES =================

  LatLng? currentLocation;

  String? currentSessionId;

  LatLng? startPoint;

  List<LatLng> route = [];

  bool isStarted = false;

  bool isPaused = false;
  
  bool followUser = true;

  double totalDistance = 0;

  double markerRotation = 0;
  
  double mapRotation = 0;

  LatLng? previousPoint;
  
  // ================= ANIMATION =================

AnimationController? animationController;

Animation<LatLng>? locationAnimation;

  static const platform =
  MethodChannel('native/location');

  StreamSubscription<Position>?
  positionStream;

  final MapController mapController =
  MapController();

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    
    animationController = AnimationController(

      vsync: this,

      duration: const Duration(
      milliseconds: 800,
  ),
);

    loadInitialLocation();

    restorePreviousSession();
    
    restoreTourState();
  }

  @override
void dispose() {

  // DO NOT STOP TRACKING HERE
  animationController?.dispose();
  super.dispose();
}

  // ================= LOAD INITIAL LOCATION =================

  Future<void> loadInitialLocation() async {
  try {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      debugPrint("Location service disabled");

      const fallback = LatLng(30.7333, 76.7794);

      if (!mounted) return;

      setState(() {
        currentLocation = fallback;
        startPoint = fallback;
        route = [fallback];
      });

      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {

      debugPrint("Location permission denied");

      const fallback = LatLng(30.7333, 76.7794);

      if (!mounted) return;

      setState(() {
        currentLocation = fallback;
        startPoint = fallback;
        route = [fallback];
      });

      return;
    }

    Position position =
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).timeout(
      const Duration(seconds: 10),
    );

    final location = LatLng(
      position.latitude,
      position.longitude,
    );

    if (!mounted) return;

    setState(() {
      currentLocation = location;
      startPoint = location;
      route = [location];
    });

    debugPrint(
      "Location Loaded: ${position.latitude}, ${position.longitude}",
    );

  } catch (e) {
    debugPrint("INITIAL LOCATION ERROR: $e");

    const fallback = LatLng(
      30.7333,
      76.7794,
    );

    if (!mounted) return;

    setState(() {
      currentLocation = fallback;
      startPoint = fallback;
      route = [fallback];
    });
  }
}

  Future<void> restorePreviousSession() async {
    try {

      final sessionId =
      SessionService.getActiveSession();

      if (sessionId == null) {
        return;
      }

      final points =
      TrackingStorageService
          .getSessionPoints(
          sessionId);

      if (points.isEmpty) {
        return;
      }

      currentSessionId = sessionId;

      route = points.map((e) {
        return LatLng(
          e.latitude,
          e.longitude,
        );
      }).toList();

      currentLocation = route.last;

      startPoint = route.first;

      if (!mounted) return;

      setState(() {
        isStarted = true;
        isPaused = false;
      });

      debugPrint(
        "Recovered session: $sessionId",
      );

    } catch (e) {

      debugPrint(
        "RESTORE ERROR: $e",
      );
    }
  }
  Future<void> restoreTourState() async {

  final running =
      await TourStateService.isRunning();

  if (!running) {
    return;
  }

  if (!mounted) return;

  setState(() {

    isStarted = true;

    isPaused = false;
  });

  debugPrint(
    "Tour restored after reopen",
  );

  startTour();
}

// ================= START TOUR =================

Future<void> startTour() async {
  try {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enable location"),
        ),
      );
      return;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission denied",
          ),
        ),
      );
      return;
    }

    if (currentLocation == null) {
      return;
    }


    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    await platform.invokeMethod(
      'startTracking',
    );

    // START FOREGROUND SERVICE


      await TourStateService.setRunning(true);

      if (Platform.isAndroid) {

      await FlutterForegroundTask.startService(

        notificationTitle:
        'Tour Tracking Active',

        notificationText:
        'Background tracking running',

        callback: startCallback,
      );
    }

    // RESET TOUR DATA

    currentSessionId ??=
    const Uuid().v4();

    debugPrint(
      "SESSION ID: $currentSessionId",
    );

    startPoint = currentLocation;

    route = [currentLocation!];

    totalDistance = 0;

    // CANCEL OLD STREAM

    await positionStream?.cancel();

    // START LIVE TRACKING

    positionStream =
        Geolocator.getPositionStream(
      locationSettings:
          const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen(
      (Position position) async {
        try {
    final LatLng newPoint = LatLng(

  position.latitude,

  position.longitude,
);

// ================= ROTATION =================

if (previousPoint != null) {

  final dx =
      newPoint.longitude -
      previousPoint!.longitude;

  final dy =
      newPoint.latitude -
      previousPoint!.latitude;

  markerRotation =
      math.atan2(dx, dy);
  mapRotation =
    markerRotation * 57.2958;
}

previousPoint = newPoint;

          // SAVE TO LOCAL STORAGE

          final point = LocationPoint(
            sessionId: currentSessionId!,
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            speed: position.speed,
            timestamp: DateTime.now(),
          );
          debugPrint(
            "Saving point for session: $currentSessionId",
          );

          await TrackingStorageService
              .savePoint(point);

          if (!mounted) return;

          setState(() {
            route.add(newPoint);

            currentLocation = newPoint;

            if (route.length > 1) {
              totalDistance +=
                  Geolocator.distanceBetween(
                route[route.length - 2]
                    .latitude,
                route[route.length - 2]
                    .longitude,
                newPoint.latitude,
                newPoint.longitude,
              );
            }
          });

 if (followUser) {

  mapController.move(
    newPoint,
    17,
  );
}
        } catch (e) {
          debugPrint(
            "TRACKING ERROR: $e",
          );
        }
      },
    );

    if (!mounted) return;

    setState(() {
      isStarted = true;
      isPaused = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Tour Started",
        ),
      ),
    );
  } catch (e) {
    debugPrint(
      "START TOUR ERROR: $e",
    );
  }
}

  // ================= PAUSE =================

  void pauseTour() {

    positionStream?.pause();

    setState(() {

      isPaused = true;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Tour Paused",
        ),
      ),
    );
  }

  // ================= RESUME =================

  void resumeTour() {

    positionStream?.resume();

    setState(() {

      isPaused = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Tour Resumed",
        ),
      ),
    );
  }

  // ================= STOP =================

  Future<void> stopTour() async {
  
  await TourStateService.setRunning(false);

    try {

      await positionStream?.cancel();
      await platform.invokeMethod(
        'stopTracking',
      );

      // ================= STOP FOREGROUND SERVICE =================

      await FlutterForegroundTask
          .stopService();
      await SessionService
          .clearSession();

      if (!mounted) return;

      setState(() {

        isStarted = false;

        isPaused = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(

            "Tour Stopped\n"
                "Distance: "
                "${(totalDistance / 1000).toStringAsFixed(2)} KM",
          ),
        ),
      );

    } catch (e) {

      debugPrint(
        "STOP TOUR ERROR: $e",
      );
    }
  }

//----ui----

@override
Widget build(BuildContext context) {

  return PopScope(

    canPop: false,

     onPopInvokedWithResult: (
    didPop,
    result,
)
{

  Navigator.pop(context);
},

    child: Scaffold(

      appBar: AppBar(

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back,
          ),

          onPressed: () {

            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Start Tour",
        ),

        centerTitle: true,

        backgroundColor:
            const Color(0xFF1E2F5B),
      ),

      body: Column(

        children: [

          // ================= MAP =================

          Expanded(

            child: currentLocation == null

                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )

                : Stack(

                    children: [

                      FlutterMap(

                        mapController:
                            mapController,

                        options: MapOptions(

                          initialCenter:
                              currentLocation!,

                          initialZoom: 15,

                          interactionOptions:
                              const InteractionOptions(

                            flags:
                                InteractiveFlag.all,
                          ),
                        ),

                        children: [

                          // ================= TILE =================

                          TileLayer(

                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",

                            userAgentPackageName:
                                "com.taappios.app",
                          ),

                          // ================= ROUTE =================
                          if (route.length > 1)

                            PolylineLayer(

                              polylines: [

                                Polyline(

                                  points: route,

                                  strokeWidth: 8,

                                  color: Colors.blueAccent,

                                  borderStrokeWidth: 2,

                                  borderColor: Colors.white,
                                ),
                              ],
                            ),

                          // ================= CURRENT LOCATION =================

                MarkerLayer(

  markers: [

    // ================= START MARKER =================

    if (route.isNotEmpty)

      Marker(

        point: route.first,

        width: 45,

        height: 45,

        child: const Icon(

          Icons.location_on,

          color: Colors.green,

          size: 40,
        ),
      ),

    // ================= END MARKER =================

    if (route.length > 1)

      Marker(

        point: route.last,

        width: 45,

        height: 45,

        child: const Icon(

          Icons.location_on,

          color: Colors.red,

          size: 40,
        ),
      ),

    // ================= MOVING CAR / ARROW =================

    Marker(

      point: currentLocation!,

      width: 60,

      height: 60,

      child: Transform.rotate(

        angle: markerRotation,

        child: Container(
        
        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(
          
            color: Colors.white,

            shape: BoxShape.circle,

            boxShadow: [

              BoxShadow(

                color: Colors.blue.withValues(
                  alpha: 0.2,
                ),

                blurRadius: 8,

                spreadRadius: 2,
              ),
            ],
          ),

          child: const Icon(

            Icons.directions_car,

            color: Colors.blueAccent,

            size: 28,
          ),
        ),
      ),
    ),
  ],
),
],
),

                      // ================= LOCATION BUTTON =================

                      Positioned(

                        right: 15,

                        bottom: 20,

                        child:
                            FloatingActionButton(

                          heroTag: "location",

                          backgroundColor:
                              Colors.white,

                        onPressed: () {

                        setState(() {

                        followUser = !followUser;
                    });

                    if (currentLocation != null) {

                     mapController.move(
                      currentLocation!,
                      17,
                    );
                   }
                  },
                              child: Icon(

                                followUser
                                    ? Icons.gps_fixed
                                    : Icons.gps_not_fixed,

                                color: Colors.black,
                              ),
                        ),
                      ),

                      // ================= ZOOM BUTTONS =================

                      Positioned(

                        left: 10,

                        top: 20,

                        child: Column(

                          children: [

                            _zoomButton(
                              Icons.add,
                              () {

                                mapController.move(

                                  mapController
                                      .camera.center,

                                  mapController
                                          .camera.zoom +
                                      1,
                                );
                              },
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            _zoomButton(
                              Icons.remove,
                              () {

                                mapController.move(

                                  mapController
                                      .camera.center,

                                  mapController
                                          .camera.zoom -
                                      1,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

          // ================= DISTANCE =================

          Padding(

            padding:
                const EdgeInsets.all(10),

            child: Text(

              "Total Distance : "
              "${(totalDistance / 1000).toStringAsFixed(2)} KM",

              style: const TextStyle(

                fontSize: 16,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // ================= BUTTONS =================

          Padding(

            padding:
                const EdgeInsets.all(12),

            child: Column(

              children: [

                Row(

                  children: [

                    Expanded(

                      child: _mainButton(

                        "Start",

                        Colors.green,

                        isStarted
                            ? null
                            : startTour,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(

                      child: _mainButton(

                        "Pause",

                        Colors.orange,

                        isStarted &&
                                !isPaused
                            ? pauseTour
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                Row(

                  children: [

                    Expanded(

                      child: _mainButton(

                        "Resume",

                        Colors.blue,

                        isPaused
                            ? resumeTour
                            : null,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(

                      child: _mainButton(

                        "Stop",

                        Colors.red,

                        isStarted
                            ? stopTour
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  // ================= MAIN BUTTON =================

  Widget _mainButton(
      String text,
      Color color,
      VoidCallback? onTap,
      ) {

    return SizedBox(

      height: 55,

      child: ElevatedButton(

        onPressed: onTap,

        style:
        ElevatedButton.styleFrom(

          backgroundColor:

          onTap == null
              ? Colors.grey.shade300
              : color,

          shape:
          RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(30),
          ),
        ),

        child: Text(

          text,

          style: TextStyle(

            color:
            onTap == null
                ? Colors.black45
                : Colors.white,

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ================= ZOOM BUTTON =================

  Widget _zoomButton(
      IconData icon,
      VoidCallback onTap,
      ) {

    return Container(

      width: 42,

      height: 42,

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(8),

        boxShadow: const [

          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
          ),
        ],
      ),

      child: IconButton(

        icon: Icon(
          icon,
          size: 20,
        ),

        onPressed: onTap,
      ),
    );
  }
}

// ================= FOREGROUND CALLBACK =================

@pragma('vm:entry-point')
void startCallback() {

  FlutterForegroundTask.setTaskHandler(
    LocationTaskHandler(),
  );
}
