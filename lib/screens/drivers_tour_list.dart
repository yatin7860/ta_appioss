import 'package:flutter/material.dart';

class DriversTourListScreen extends StatelessWidget {
  const DriversTourListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drivers Tour List"),
        backgroundColor: const Color(0xFF1E2F5B),
      ),
      body: const Center(
        child: Text(
          "Drivers Tour List",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}