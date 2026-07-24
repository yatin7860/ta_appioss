import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../services/location_sync_service.dart';
import '../services/network_service.dart';
import '../services/retry_service.dart';
import '../taskhandler/location_task_handler.dart';

import '../models/location_point.dart';
import '../services/tracking_storage_service.dart';
import 'package:uuid/uuid.dart';

import '../services/tour_state_service.dart';

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

class _StartTourScreenState extends State<StartTourScreen>
    with TickerProviderStateMixin,
        WidgetsBindingObserver {

  // ================= VARIABLES =================

  LatLng? currentLocation;

  String? currentSessionId;

  LatLng? startPoint;

  List<LatLng> route = [];


  bool isStarted = false;

  bool isPaused = false;

  bool syncing = false;


  int uploadedCount = 0;

  int pendingLocations = 0;

  bool followUser = true;

  double totalDistance = 0;

  double markerRotation = 0;

  double mapRotation = 0;

  LatLng? previousPoint;

  LatLng? lastSavedPoint;

  // ================= ANIMATION =================

  AnimationController? animationController;

  Animation<LatLng>? locationAnimation;


  StreamSubscription<Position>?
  positionStream;
  Timer? syncTimer;

  final MapController mapController =
  MapController();

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    animationController = AnimationController(

      vsync: this,

      duration: const Duration(
        milliseconds: 800,
      ),
    );

    initializeTour();
  }
  Future<void> initializeTour() async {

    debugPrint("Initializing Tour...");



    await loadInitialLocation();

    await restoreTourState();

    await restorePreviousSession();

    debugPrint("Initialization Complete");

  }

  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this);
    // Stop GPS Stream
    positionStream?.cancel();

    // Stop Sync Timer
    syncTimer?.cancel();

    RetryService.retryTimer?.cancel();

    // Stop Network Listener
    NetworkService.stopListening();
    debugPrint(
      "Resources Disposed",
    );

    // Dispose Animation
    animationController?.dispose();

    super.dispose();

  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) {

    debugPrint(
        "Lifecycle : $state");

    switch (state) {

      case AppLifecycleState.resumed:

        debugPrint("App Resumed");

        if (isStarted && !isPaused) {

          startUploadTimer();

          startNetworkListener();

          startLocationStream();

        }

        break;

      case AppLifecycleState.paused:

        debugPrint("App Paused");

        break;

      case AppLifecycleState.detached:

        debugPrint("App Detached");

        break;

      case AppLifecycleState.inactive:

        debugPrint("App Inactive");

        break;

      case AppLifecycleState.hidden:

        debugPrint("App Hidden");

        break;

    }

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

      final points =
      TrackingStorageService.getTourPoints(
        widget.tourId,
      );

      debugPrint(
        "Recovered ${points.length} locations",
      );

      if (points.isEmpty) {
        return;
      }

      currentSessionId =
          points.first.sessionId;

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
        "Recovered Session : $currentSessionId",
      );

      debugPrint(
        "Route Restored Successfully",
      );

    } catch (e) {

      debugPrint(
        "RESTORE ERROR : $e",
      );

    }

  }
  Future<void> restoreTourState() async {

    final session =
    await TourStateService.getCurrentSession();

    if (session == null) {
      debugPrint(
          "No Active Tour Found");
      return;
    }

    currentSessionId = session.sessionId;
    debugPrint(
        "Session Restored : ${session.sessionId}");

    if (!mounted) return;

    setState(() {

      isStarted = session.isRunning;

      isPaused = session.isPaused;

    });

    if (session.isRunning && !session.isPaused) {

      debugPrint("Restarting Active Tour");

      startUploadTimer();

      startNetworkListener();

      startLocationStream();
      debugPrint(
        "Tour Restored Successfully",
      );

      if (Platform.isAndroid) {

        await FlutterForegroundTask.startService(

          notificationTitle: "Tour Tracking Active",

          notificationText: "Background tracking running",

          callback: startCallback,

        );

      }

    }
  }
  //
  void startUploadTimer() {

    syncTimer?.cancel();

    syncTimer = Timer.periodic(

      const Duration(
        minutes: 2,
      ),

          (_) async {

        if (!mounted) return;

        setState(() {
          syncing = true;
        });

        await LocationSyncService.uploadLocations();

        if (!mounted) return;

        setState(() {
          syncing = false;

          pendingLocations =
              TrackingStorageService.pendingCount();
        });

      },

    );

    debugPrint(
      "Upload Timer Started",
    );

  }
  //
  void startNetworkListener() {

    // Prevent duplicate listeners
    NetworkService.stopListening();

    NetworkService.startListening(() async {

      debugPrint("Internet Connected");

      if (!mounted) return;

      setState(() {
        syncing = true;
      });

      await LocationSyncService.uploadLocations();

      if (!mounted) return;

      setState(() {
        syncing = false;

        pendingLocations =
            TrackingStorageService.pendingCount();
      });

    });

    debugPrint(
      "Network Listener Started",
    );

  }
  //

  void startLocationStream() {

    positionStream?.cancel();

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 5,
          ),
        ).listen(
              (Position position) async {

            try {

              // ================= SPEED FILTER =================

              if (position.speed > 45) {

                debugPrint(
                  "Ignored - Invalid Speed : ${position.speed}",
                );

                return;

              }

              // Ignore poor GPS accuracy
              if (position.accuracy > 30) {

                debugPrint(
                    "Ignored - Accuracy : ${position.accuracy}");

                return;

              }

              final LatLng newPoint = LatLng(

                position.latitude,

                position.longitude,

              );

              if (lastSavedPoint != null) {

                final distance =
                Geolocator.distanceBetween(

                  lastSavedPoint!.latitude,

                  lastSavedPoint!.longitude,

                  newPoint.latitude,

                  newPoint.longitude,

                );

                // Ignore duplicate points
                if (distance < 5) {

                  debugPrint(
                    "Duplicate Point Ignored",
                  );

                  return;

                }

                // Ignore unrealistic GPS jumps
                if (distance > 200) {

                  debugPrint(
                    "GPS Jump Ignored : $distance meters",
                  );

                  return;

                }

              }
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

              // ================= SAVE TO HIVE =================

              if (currentSessionId == null) {

                debugPrint("Session is null");

                return;

              }

              final point = LocationPoint(

                tourId: widget.tourId,

                sessionId: currentSessionId!,

                latitude: position.latitude,

                longitude: position.longitude,

                address: "",

                pauseStatus: isPaused,

                index: route.length,

                accuracy: position.accuracy,

                speed: position.speed,

                timestamp: DateTime.now(),

              );

              debugPrint(
                "Saving point for session : $currentSessionId",
              );

              await TrackingStorageService.savePoint(point);

              if (mounted) {

                setState(() {

                  pendingLocations =
                      TrackingStorageService.pendingCount();

                });

              }

// Update last saved point
              lastSavedPoint = newPoint;

              if (!mounted) return;

              setState(() {

                route.add(newPoint);

                currentLocation = newPoint;

                if (route.length > 1) {

                  totalDistance +=
                      Geolocator.distanceBetween(

                        route[route.length - 2].latitude,

                        route[route.length - 2].longitude,

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
                "TRACKING ERROR : $e",
              );

            }

          },

        );

    debugPrint(
      "GPS Tracking Started",
    );

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

      // START FOREGROUND SERVICE

      final sessionId = currentSessionId ?? const Uuid().v4();


      currentSessionId = sessionId;

      await TourStateService.startTour(

        tourId: widget.tourId,

        sessionId: sessionId,

      );

      if (Platform.isAndroid) {

        final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();

        if (notificationPermission != NotificationPermission.granted) {
          await FlutterForegroundTask.requestNotificationPermission();
        }

        if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
          await FlutterForegroundTask.requestIgnoreBatteryOptimization();
        }

        debugPrint("Before startService");

        await FlutterForegroundTask.startService(
          notificationTitle: "Tour Tracking Active",
          notificationText: "Background tracking running",
          callback: startCallback,
        );

        debugPrint("After startService");


      }

      // RESET TOUR DATA


      debugPrint(
        "SESSION ID: $currentSessionId",
      );

      startPoint = currentLocation;

      route = [currentLocation!];

      totalDistance = 0;

      // CANCEL OLD STREAM

      await positionStream?.cancel();

      startUploadTimer();
      startNetworkListener();
      // Start GPS tracking
      startLocationStream();
      debugPrint(
        "Live Tracking Started",
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
    } catch (e, stack) {
      debugPrint("START TOUR ERROR: $e");
      debugPrint(stack.toString());
    }

  }

  // ================= PAUSE =================

  Future<void> pauseTour() async {

    positionStream?.pause();

    await TourStateService.pauseTour();

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

  Future<void> resumeTour() async {

    positionStream?.resume();

    await TourStateService.resumeTour();

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

    await TourStateService.stopTour();

    currentSessionId = null;

    try {
      syncTimer?.cancel();
      RetryService.retryTimer?.cancel();
      await NetworkService.stopListening();

      if (mounted) {

        setState(() {
          syncing = true;
        });

      }

      while (TrackingStorageService
          .getPendingPoints()
          .isNotEmpty) {

        final success =
        await LocationSyncService.uploadLocations();

        if (!success) {

          debugPrint(
            "Upload failed. Remaining locations kept in Hive.",
          );

          break;

        }

      }
      debugPrint(
        "Pending Locations : ${TrackingStorageService.pendingCount()}",
      );

      if (mounted) {

        setState(() {
          syncing = false;
        });

      }
      await positionStream?.cancel();

      // ================= STOP FOREGROUND SERVICE =================

      if (Platform.isAndroid) {
        await FlutterForegroundTask.stopService();
      }


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

            // ================= SYNC INDICATOR =================

            if (syncing)

              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(10),

                color: Colors.green,

                child: const Row(

                  children: [

                    SizedBox(

                      width: 18,

                      height: 18,

                      child: CircularProgressIndicator(

                        strokeWidth: 2,

                        color: Colors.white,

                      ),

                    ),

                    SizedBox(width: 12),

                    Text(

                      "Uploading location data...",

                      style: TextStyle(

                        color: Colors.white,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ],

                ),

              ),
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
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [

                  Text(
                    "Total Distance : ${(totalDistance / 1000).toStringAsFixed(2)} KM",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Pending Locations : $pendingLocations",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    syncing
                        ? "⬆ Uploading Locations..."
                        : "✔ Sync Completed",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: syncing ? Colors.blue : Colors.green,
                    ),
                  ),

                ],
              ),
            ),



            // ================= BUTTONS =================

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [

                  // ================= START / PAUSE =================

                  Row(
                    children: [

                      Expanded(
                        child: _mainButton(
                          "Start",
                          Colors.green,
                          isStarted ? null : startTour,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _mainButton(
                          "Pause",
                          Colors.orange,
                          isStarted && !isPaused
                              ? pauseTour
                              : null,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 10),

                  // ================= RESUME / STOP =================

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

                      const SizedBox(width: 10),

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

                  const SizedBox(height: 15),

                  // ================= SYNC NOW BUTTON =================

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(

                      icon: const Icon(
                        Icons.sync,
                        color: Colors.white,
                      ),

                      label: Text(
                        "Sync Now ($pendingLocations)",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      onPressed: syncing
                          ? null
                          : () async {

                        if (!mounted) return;

                        setState(() {
                          syncing = true;
                        });

                        final success =
                        await LocationSyncService.uploadLocations();

                        if (!mounted) return;

                        setState(() {
                          syncing = false;
                          pendingLocations =
                              TrackingStorageService.pendingCount();
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? "Locations Synced Successfully"
                                  : "Sync Failed",
                            ),
                          ),
                        );
                      },

                    ),
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
