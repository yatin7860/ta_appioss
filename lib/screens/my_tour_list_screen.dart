

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

        offset: const Offset(0,4),

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

                SizedBox(height:20),

                Text(
                  "No Tours Available",
                  style: TextStyle(
                    fontSize:22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height:10),

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
                            return Container(

  margin: const EdgeInsets.only(bottom: 18),

  decoration: BoxDecoration(

    color: Colors.white,

    borderRadius: BorderRadius.circular(18),

    boxShadow: [

      BoxShadow(

        color: Colors.black12,

        blurRadius: 10,

        offset: const Offset(0,5),

      ),

    ],

  ),

  child: Card(

    elevation: 0,

    margin: EdgeInsets.zero,

    shape: RoundedRectangleBorder(

      borderRadius: BorderRadius.circular(18),

    ),


                              child: Padding(

                                padding: const EdgeInsets.all(15),

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    
  Container(

  padding: const EdgeInsets.all(16),

  decoration: BoxDecoration(

    gradient: const LinearGradient(

      colors: [

        Color(0xff1E2F5B),

        Color(0xff355CC9),

      ],

      begin: Alignment.topLeft,

      end: Alignment.bottomRight,

    ),

    borderRadius: BorderRadius.circular(15),

  ),

  child: Row(

    children: [

      CircleAvatar(

        radius: 22,

        backgroundColor: Colors.white,

        child: const Icon(

          Icons.flight_takeoff,

          color: Color(0xff1E2F5B),

        ),

      ),

      const SizedBox(width:15),

      Expanded(

        child: Column(

          crossAxisAlignment:

              CrossAxisAlignment.start,

          children: [

            const Text(

              "Tour ID",

              style: TextStyle(

                color: Colors.white70,

                fontSize: 13,

              ),

            ),

            Text(

              "#${tour["TOUR_ID"]}",

              style: const TextStyle(

                color: Colors.white,

                fontSize: 22,

                fontWeight: FontWeight.bold,

              ),

            ),

          ],

        ),

      ),

      buildStatusChip(

        tour["DIRECTOR_STATUS"],

      ),

    ],

  ),

),


  const SizedBox(height: 10),

  buildInfoTile(
  Icons.person,
  "Employee",
  tour["NAME"],
),

buildInfoTile(
  Icons.location_on,
  "Visit Place",
  tour["VISIT_PLACE"],
),

buildInfoTile(
  Icons.description,
  "Purpose",
  tour["VISIT_PURPOSE"],
),

buildInfoTile(
  Icons.account_tree,
  "Project",
  tour["PROJECT_ID"],
),

buildInfoTile(
  Icons.calendar_today,
  "From Date",
  tour["FROM_DATE"],
),

buildInfoTile(
  Icons.calendar_month,
  "To Date",
  tour["TO_DATE"],
),

  Wrap(

  spacing: 10,

  runSpacing: 10,

  children: [

    buildApprovalChip(
      "RI",
      tour["RI_STATUS"],
    ),

    buildApprovalChip(
      "PI",
      tour["PI_STATUS"],
    ),

    buildApprovalChip(
      "VI",
      tour["VI_STATUS"],
    ),

    buildApprovalChip(
      "AO",
      tour["AO_STATUS"],
    ),

    buildApprovalChip(
      "Director",
      tour["DIRECTOR_STATUS"],
    ),

  ],

),
const SizedBox(height: 15),

SizedBox(

  width: double.infinity,

  child: ElevatedButton.icon(

    icon: const Icon(

      Icons.remove_red_eye,

      color: Colors.white,

    ),

    style: ElevatedButton.styleFrom(

      backgroundColor: const Color(0xff1E2F5B),

      elevation: 3,

      padding: const EdgeInsets.symmetric(

        vertical: 15,

      ),

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(14),

      ),

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

    label: const Text(

      "View Details",

      style: TextStyle(

        color: Colors.white,

        fontWeight: FontWeight.bold,

        fontSize: 17,

      ),

    ),

  ),

),

]
 ),

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
Widget buildStatusChip(dynamic status) {

  String value =
      status?.toString() ?? "PENDING";

  Color color = Colors.orange;

  if (value == "APPROVE") {

    color = Colors.green;

  }

  if (value == "REJECT") {

    color = Colors.red;

  }

  return Container(

    padding: const EdgeInsets.symmetric(

      horizontal: 12,

      vertical: 6,

    ),

    decoration: BoxDecoration(

      color: color,

      borderRadius: BorderRadius.circular(20),

    ),

    child: Text(

      value,

      style: const TextStyle(

        color: Colors.white,

        fontWeight: FontWeight.bold,

      ),

    ),

  );

}
Widget buildInfoTile(

  IconData icon,

  String title,

  dynamic value,

) {

  return Padding(

    padding: const EdgeInsets.only(bottom: 12),

    child: Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        CircleAvatar(

          radius: 18,

          backgroundColor:
              const Color(0xff1E2F5B).withOpacity(.1),

          child: Icon(

            icon,

            size: 18,

            color: const Color(0xff1E2F5B),

          ),

        ),

        const SizedBox(width: 12),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                title,

                style: TextStyle(

                  color: Colors.grey[600],

                  fontSize: 12,

                ),

              ),

              const SizedBox(height: 2),

              Text(

                value == null || value.toString().isEmpty
                    ? "-"
                    : value.toString(),

                style: const TextStyle(

                  fontWeight: FontWeight.w600,

                  fontSize: 16,

                ),

              ),

            ],

          ),

        ),

      ],

    ),

  );

}
Widget buildApprovalChip(

  String title,

  dynamic status,

) {

  String value =
      status?.toString() ?? "PENDING";

  Color color = Colors.orange;

  IconData icon = Icons.schedule;

  if (value.toUpperCase() == "APPROVE") {

    color = Colors.green;

    icon = Icons.check_circle;

  } else if (value.toUpperCase() == "REJECT") {

    color = Colors.red;

    icon = Icons.cancel;

  } else if (value.toUpperCase() ==
      "ACTION NOT REQUIRED") {

    color = Colors.blue;

    icon = Icons.info;

  } else if (value.toUpperCase() ==
      "PENDING") {

    color = Colors.orange;

    icon = Icons.schedule;

  }

  return Container(

    padding: const EdgeInsets.symmetric(

      horizontal: 12,

      vertical: 8,

    ),

    decoration: BoxDecoration(

      color: color.withOpacity(0.12),

      borderRadius: BorderRadius.circular(30),

      border: Border.all(

        color: color,

      ),

    ),

    child: Row(

      mainAxisSize: MainAxisSize.min,

      children: [

        Icon(

          icon,

          size: 16,

          color: color,

        ),

        const SizedBox(width: 6),

        Text(

          "$title : $value",

          style: TextStyle(

            color: color,

            fontWeight: FontWeight.bold,

            fontSize: 13,

          ),

        ),

      ],

    ),

  );

}
}
