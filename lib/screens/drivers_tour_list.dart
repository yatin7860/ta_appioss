import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/tour_card.dart';

class DriversTourListScreen extends StatefulWidget {
  const DriversTourListScreen({super.key});

  @override
  State<DriversTourListScreen> createState() =>
      _DriversTourListScreenState();
}

class _DriversTourListScreenState
    extends State<DriversTourListScreen> {

  final TextEditingController searchController =
  TextEditingController();

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

    final response =
    await ApiService.getDriverTourList();

    if (response != null &&
        response["success"] == true) {

      setState(() {

        tours = response["tours"] ?? [];

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

        return

          tour["TOUR_ID"]
              .toString()
              .toLowerCase()
              .contains(value.toLowerCase())

              ||

              tour["NAME"]
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase())

              ||

              tour["DRIVER_NAME"]
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase());

      }).toList();

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF4F6FA),

      appBar: AppBar(

        elevation: 0,

        backgroundColor: const Color(0xFF1E2F5B),

        centerTitle: true,

        title: const Text(

          "Drivers Tour List",

          style: TextStyle(

            color: Colors.white,

            fontSize: 22,

            fontWeight: FontWeight.bold,

          ),

        ),

        actions: [

          IconButton(

            icon: const Icon(Icons.refresh),

            onPressed: loadTours,

          ),

        ],

      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Container(

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.circular(15),

                boxShadow: [

                  BoxShadow(

                    color: Colors.black12,

                    blurRadius: 10,

                    offset: const Offset(0, 4),

                  ),

                ],

              ),

              child: TextField(

                controller: searchController,

                onChanged: searchTour,

                decoration: InputDecoration(

                  hintText: "Search Tour",

                  prefixIcon: const Icon(

                    Icons.search,

                    color: Color(0xff1E2F5B),

                  ),

                  suffixIcon: searchController.text.isEmpty

                      ? null

                      : IconButton(

                    icon: const Icon(Icons.close),

                    onPressed: () {

                      searchController.clear();

                      searchTour("");

                    },

                  ),

                  border: InputBorder.none,

                  contentPadding:

                  const EdgeInsets.symmetric(

                    vertical: 18,

                  ),

                ),

              ),

            ),

            const SizedBox(height: 15),

            Expanded(

              child: loading

                  ? const Center(

                child:

                CircularProgressIndicator(),

              )

                  : filteredTours.isEmpty

                  ? const Center(

                child: Column(

                  mainAxisAlignment:

                  MainAxisAlignment.center,

                  children: [

                    Icon(

                      Icons.travel_explore,

                      size: 100,

                      color: Colors.grey,

                    ),

                    SizedBox(height: 20),

                    Text(

                      "No Tours Available",

                      style: TextStyle(

                        fontSize: 22,

                        fontWeight:

                        FontWeight.bold,

                      ),

                    ),

                    SizedBox(height: 10),

                    Text(

                      "No tours assigned to you.",

                    ),

                  ],

                ),

              )

                  : RefreshIndicator(

                onRefresh: loadTours,

                child: ListView.builder(

                  itemCount:

                  filteredTours.length,

                  itemBuilder:

                      (context, index) {

                    final tour =

                    filteredTours[index];

                    return TourCard(

                      tour: tour,

                      children: [

                        const SizedBox(height: 10),

                        Row(

                          children: [

                            const Icon(

                              Icons.person,

                              color: Colors.blue,

                            ),

                            const SizedBox(width: 8),

                            Expanded(

                              child: Text(

                                "Driver : ${tour["DRIVER_NAME"]}",

                              ),

                            ),

                          ],

                        ),

                        const SizedBox(height: 8),

                        Row(

                          children: [

                            const Icon(

                              Icons.local_taxi,

                              color: Colors.green,

                            ),

                            const SizedBox(width: 8),

                            Expanded(

                              child: Text(

                                "Vehicle : ${tour["VEHICLE_NAME"]}",

                              ),

                            ),

                          ],

                        ),

                      ],

                    );

                  },

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}