

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'start_tour_screen.dart';

import '../widgets/tour_card.dart';

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

      backgroundColor: const Color(0xffF4F6FA),

      appBar: AppBar(

        elevation: 0,

        backgroundColor: const Color(0xFF1E2F5B),

        centerTitle: true,

        title: const Text(

          "My Tour List",

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
                    child: CircularProgressIndicator(),
                  )

                      : filteredTours.isEmpty

                      ? Center(

                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

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
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Create your first tour.",
                        ),

                      ],

                    ),

                  )

                      : ListView.builder(

                      itemCount: filteredTours.length,

                      itemBuilder: (context, index) {
                        final tour = filteredTours[index];
                        return TourCard(

                         tour: tour,

                         children: [

                         buildStartTourButton(tour),

  ], 

);
                      }
                  ),
                ),
              ]
          ),
      ),
    );
  }
  Widget buildStartTourButton(Map tour) {

  // Show only after RI approval

 if (tour["RI_STATUS"] != "APPROVE") {
  return const SizedBox.shrink();
}

if (tour["CONFIRMATION_STATUS_"] != "PENDING") {
  return const SizedBox.shrink();
}

  return SizedBox(

    width: double.infinity,

    child: ElevatedButton.icon(

      icon: const Icon(
        Icons.play_arrow,
        color: Colors.white,
      ),

      style: ElevatedButton.styleFrom(

        backgroundColor: const Color(0xff1E2F5B),

        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),

        shape: RoundedRectangleBorder(

          borderRadius:
              BorderRadius.circular(14),

        ),

      ),

      onPressed: () {

        Navigator.push(

          context,

          MaterialPageRoute(

           builder: (_) => StartTourScreen(
  tourId: tour["TOUR_ID"].toString(),
),

          ),

        );

      },

      label: const Text(

        "Start Tour",

        style: TextStyle(

          color: Colors.white,

          fontSize: 17,

          fontWeight: FontWeight.bold,

        ),

      ),

    ),

  );

}
}