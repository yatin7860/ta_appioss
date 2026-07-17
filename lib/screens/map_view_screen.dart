import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapViewScreen extends StatefulWidget {

  final String tourId;

  const MapViewScreen({
    super.key,
    required this.tourId,
  });

  @override
  State<MapViewScreen> createState() =>
      _MapViewScreenState();
}

class _MapViewScreenState
    extends State<MapViewScreen> {

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()

      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )

      ..loadRequest(
        Uri.parse(
          "http://192.168.1.65/prsc_ta/mapview/${widget.tourId}",
        ),
      );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Tour Map"),

        backgroundColor: const Color(0xff1E2F5B),

      ),

      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}