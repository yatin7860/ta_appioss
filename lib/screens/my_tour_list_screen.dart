

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'start_tour_screen.dart';
import 'tour_details_screen.dart';

class MyTourListScreen extends StatefulWidget {
  const MyTourListScreen({super.key});

  @override
  State<MyTourListScreen> createState() => _MyTourListScreenState();
}

class _MyTourListScreenState extends State<MyTourListScreen> {

  final TextEditingController searchController = TextEditingController();

  List tours = [];
  List filteredTours = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTours();
  }

  Future<void> loadTours() async {

    setState(() {
      loading = true;
    });

    final response = await ApiService.getMyTourList();

    if (response != null &&
        response["success"] == true) {

      setState(() {

        tours = response["tours"];

        filteredTours = tours;

        loading = false;

      });

    } else {

      setState(() {

        loading = false;

      });

    }
  }

  void searchTour(String value) {

    setState(() {

      filteredTours = tours.where((tour) {

        return tour["TOUR_ID"]
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase()) ||

            tour["NAME"]
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase());

      }).toList();

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("My Tour List"),

        backgroundColor: const Color(0xFF1E2F5B),

      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(

              controller: searchController,

              onChanged: searchTour,

              decoration: InputDecoration(

                hintText: "Search Tour",

                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(10),

                ),

              ),

            ),

            const SizedBox(height: 15),

            Expanded(

              child: loading

                  ? const Center(

                      child: CircularProgressIndicator(),

                    )

                  : filteredTours.isEmpty

                      ? const Center(

                          child: Text(
                            "No Tour Found",
                            style: TextStyle(fontSize: 18),
                          ),

                        )

                      : ListView.builder(

                          itemCount: filteredTours.length,

                          itemBuilder: (context, index) {

                            final tour = filteredTours[index];

                            return Card(

                              elevation: 3,

                              margin: const EdgeInsets.only(bottom: 15),

                              shape: RoundedRectangleBorder(

                                borderRadius: BorderRadius.circular(12),

                              ),

                              child: Padding(

                                padding: const EdgeInsets.all(15),

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    Text(

                                      "Tour ID : ${tour["TOUR_ID"]}",

                                      style: const TextStyle(

                                        fontSize: 18,

                                        fontWeight: FontWeight.bold,

                                      ),

                                    ),

                                    const SizedBox(height: 10),

                                    Text("Name : ${tour["NAME"]}"),

                                    Text("Visit Place : ${tour["VISIT_PLACE"]}"),

                                    Text("Purpose : ${tour["VISIT_PURPOSE"]}"),

                                    Text("Project : ${tour["PROJECT_ID"]}"),

                                    Text("From : ${tour["FROM_DATE"]}"),

                                    Text("To : ${tour["TO_DATE"]}"),

                                    const SizedBox(height: 10),

                                    Row(

                                      children: [

                                        const Text(

                                          "RI : ",

                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),

                                        ),

                                        Text(
                                          tour["RI_STATUS"] ?? "",
                                        ),

                                      ],

                                    ),

                                    Row(

                                      children: [

                                        const Text(

                                          "PI : ",

                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),

                                        ),

                                        Text(
                                          tour["PI_STATUS"] ?? "",
                                        ),

                                      ],

                                    ),

                                    Row(

                                      children: [

                                        const Text(

                                          "AO : ",

                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),

                                        ),

                                        Text(
                                          tour["AO_STATUS"] ?? "",
                                        ),

                                      ],

                                    ),

                                    const SizedBox(height: 15),

                                    SizedBox(

                                      width: double.infinity,

                                      child: ElevatedButton(

                                        style: ElevatedButton.styleFrom(

                                          backgroundColor: Colors.green,

                                        ),

                                        onPressed: () {

                                          Navigator.push(

                                            context,

                                            MaterialPageRoute(

                                              builder: (_) => TourDetailsScreen(

                                              tourId: tour["TOUR_ID"].toString(),

                                              ),

                                            ),

                                          );

                                        },

                                        child: const Text(

                                          "View Details",

                                        ),

                                      ),

                                    ),

                                  ],

                                ),

                              ),

                            );

                          },

                        ),

            ),

          ],

        ),

      ),

    );

  }

}
