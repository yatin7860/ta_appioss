import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../location_task_handler.dart';

class StartTourScreen extends StatefulWidget {
  const StartTourScreen({super.key});

  @override
  State<StartTourScreen> createState() =>
      _StartTourScreenState();
}

class _StartTourScreenState
    extends State<StartTourScreen> {

  // ================= VARIABLES =================

  LatLng? currentLocation;

  LatLng? startPoint;

  List<LatLng> route = [];

  bool isStarted = false;

  bool isPaused = false;

  double totalDistance = 0;

  StreamSubscription<Position>?
  positionStream;

  final MapController mapController =
  MapController();

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    loadInitialLocation();
  }

  @override
  void dispose() {

    positionStream?.cancel();

    super.dispose();
  }

  // ================= LOAD INITIAL LOCATION =================

  Future<void> loadInitialLocation() async {

    try {

      bool serviceEnabled =
      await Geolocator
          .isLocationServiceEnabled();

      if (!serviceEnabled) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Please enable GPS",
            ),
          ),
        );

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {

        permission =
        await Geolocator
            .requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission
                  .deniedForever) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Location permission denied",
            ),
          ),
        );

        return;
      }

      Position position =
      await Geolocator
          .getCurrentPosition(
        desiredAccuracy:
        LocationAccuracy.high,
      );

      final LatLng location =
      LatLng(        
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {

        currentLocation = location;

        startPoint = location;

        route = [location];
      });

    } catch (e) {

      debugPrint(
        "INITIAL LOCATION ERROR: $e",
      );
    }
  }

  // ================= START TOUR =================

  Future<void> startTour() async {

    try {

      bool serviceEnabled =
      await Geolocator
          .isLocationServiceEnabled();

      if (!serviceEnabled) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Please enable location",
            ),
          ),
        );

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {

        permission =
        await Geolocator
            .requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission
                  .deniedForever) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
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

      // ================= START FOREGROUND SERVICE =================

      await FlutterForegroundTask
          .startService(

        notificationTitle:
        'Tour Tracking Active',

        notificationText:
        'Background tracking running',

        callback: startCallback,
      );

      // ================= RESET DATA =================

      startPoint = currentLocation;

      route = [currentLocation!];

      totalDistance = 0;

      // ================= CANCEL OLD STREAM =================

      await positionStream?.cancel();

      // ================= START LIVE LOCATION =================

      positionStream =
          Geolocator.getPositionStream(

            locationSettings:
            const LocationSettings(

              accuracy:
              LocationAccuracy.best,

              distanceFilter: 5,
            ),
          ).listen(

                (Position position) {

              try {

                final LatLng newPoint =
                LatLng(
                  position.latitude,
                  position.longitude,
                );

                if (!mounted) return;

                setState(() {

                  route.add(newPoint);

                  currentLocation =
                      newPoint;

                  // ================= DISTANCE =================

                  if (route.length > 1) {

                    totalDistance +=
                        Geolocator
                            .distanceBetween(

                          route[
                          route.length - 2]
                              .latitude,

                          route[
                          route.length - 2]
                              .longitude,

                          newPoint.latitude,

                          newPoint.longitude,
                        );
                  }
                });

                // ================= AUTO FOLLOW =================

                mapController.move(
                  newPoint,
                  mapController
                      .camera.zoom,
                );

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

    try {

      await positionStream?.cancel();

      // ================= STOP FOREGROUND SERVICE =================

      await FlutterForegroundTask
          .stopService();

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

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
        const Text("Start Tour"),

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

                    // ================= MAP TILE =================

                    TileLayer(

                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",

                      subdomains:
                      const [
                        'a',
                        'b',
                        'c',
                      ],
                    ),

                    // ================= ROUTE =================

                    if (route.length > 1)

                      PolylineLayer(

                        polylines: [

                          Polyline(

                            points:
                            route,

                            strokeWidth:
                            6,

                            color:
                            Colors.blue,
                          ),
                        ],
                      ),

                    // ================= CURRENT LOCATION =================

                    MarkerLayer(

                      markers: [

                        Marker(

                          point:
                          currentLocation!,

                          width: 30,

                          height: 30,

                          child: Container(

                            decoration:
                            BoxDecoration(

                              color:
                              Colors.blue,

                              shape:
                              BoxShape.circle,

                              border:
                              Border.all(

                                color:
                                Colors.white,

                                width: 3,
                              ),

                              boxShadow: [

                                BoxShadow(

                                  color:
                                  Colors.blue
                                      .withOpacity(
                                    0.5,
                                  ),

                                  blurRadius:
                                  10,

                                  spreadRadius:
                                  2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ================= MY LOCATION BUTTON =================

                Positioned(

                  right: 15,

                  bottom: 20,

                  child:
                  FloatingActionButton(

                    heroTag: "location",

                    backgroundColor:
                    Colors.white,

                    onPressed: () {

                      if (currentLocation !=
                          null) {

                        mapController.move(
                          currentLocation!,
                          16,
                        );
                      }
                    },

                    child: const Icon(
                      Icons.my_location,
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
                                .camera.zoom + 1,
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
                                .camera.zoom - 1,
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