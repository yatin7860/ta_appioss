import 'package:flutter/material.dart';

class EmployeeTourListScreen extends StatelessWidget {
  const EmployeeTourListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Tour List"),
      ),
      body: const Center(
        child: Text("Employee Tour List Screen"),
      ),
    );
  }
}