import 'package:flutter/material.dart';

class ActionListScreen extends StatelessWidget {
  const ActionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Action List"),
      ),
      body: const Center(
        child: Text("Action List Screen"),
      ),
    );
  }
}