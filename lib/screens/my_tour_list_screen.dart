import 'package:flutter/material.dart';
import 'start_tour_screen.dart';

class MyTourListScreen extends StatefulWidget {
  const MyTourListScreen({super.key});

  @override
  State<MyTourListScreen> createState() => _MyTourListScreenState();
}

class _MyTourListScreenState extends State<MyTourListScreen> {

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start Tour"),
        backgroundColor: const Color(0xFF1E2F5B),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔍 SEARCH BAR
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Tour",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ▶ START TOUR BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // ✅ NAVIGATION FIX
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StartTourScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  "Start Tour",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}