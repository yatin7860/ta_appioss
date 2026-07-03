import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'tour_details_screen.dart';

class ActionListScreen extends StatefulWidget {
  const ActionListScreen({super.key});

  @override
  State<ActionListScreen> createState() =>
      _ActionListScreenState();
}

class _ActionListScreenState
    extends State<ActionListScreen> {

  final TextEditingController searchController =
  TextEditingController();
  final TextEditingController remarksController =
    TextEditingController();

  List tours = [];

  List filteredTours = [];

  bool loading = true;

  String userRole = "";

  @override
  void initState() {
    super.initState();

    loadActionList();
  }

  Future<void> loadActionList() async {
    setState(() {
      loading = true;
    });

    userRole =
    await ApiService.getUserRole();

    final response =
    await ApiService.getActionList();

    if (response != null &&
        response["success"] == true) {
      tours = response["tours"];

      filteredTours = tours;
    }

    setState(() {
      loading = false;
    });
  }

  void searchAction(String value) {
    setState(() {
      filteredTours = tours.where((tour) {
        return

          tour["TOUR_ID"]
              .toString()
              .toLowerCase()
              .contains(
            value.toLowerCase(),
          )

              ||

              tour["NAME"]
                  .toString()
                  .toLowerCase()
                  .contains(
                value.toLowerCase(),
              );
      }).toList();
    });
  }

  Future<void> refreshData() async {
    await loadActionList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor:
      const Color(0xffF4F6FA),

      appBar: AppBar(

        backgroundColor:
        const Color(0xff1E2F5B),

        elevation: 0,

        centerTitle: true,

        title: const Text(

          "Action List",

          style: TextStyle(

            color: Colors.white,

            fontWeight: FontWeight.bold,

          ),

        ),

        actions: [

          IconButton(

            onPressed: refreshData,

            icon: const Icon(Icons.refresh),

          )

        ],

      ),

      body: RefreshIndicator(

        onRefresh: refreshData,

        child: Padding(

          padding:
          const EdgeInsets.all(16),

          child: Column(

            children: [

              buildSearch(),

              const SizedBox(height: 18),

              Expanded(

                child: loading

                    ? const Center(

                  child:
                  CircularProgressIndicator(),

                )

                    : filteredTours.isEmpty

                    ? buildEmpty()

                    : ListView.builder(

                  itemCount:
                  filteredTours.length,

                  itemBuilder:

                      (context, index) {
                    final tour =
                    filteredTours[index];

                    return buildActionCard(
                        tour);
                  },

                ),

              )

            ],

          ),

        ),

      ),

    );
  }

  Widget buildSearch() {
    return Container(

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(15),

        boxShadow: const [

          BoxShadow(

            color: Colors.black12,

            blurRadius: 8,

            offset: Offset(0, 4),

          )

        ],

      ),

      child: TextField(

        controller: searchController,

        onChanged: searchAction,

        decoration: InputDecoration(

          border: InputBorder.none,

          hintText:
          "Search Tour",

          prefixIcon:
          const Icon(Icons.search),

          suffixIcon:

          searchController.text.isEmpty

              ? null

              : IconButton(

            onPressed: () {
              searchController.clear();

              searchAction("");
            },

            icon: const Icon(Icons.close),

          ),

        ),

      ),

    );
  }

  Widget buildEmpty() {
    return const Center(

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(

            Icons.assignment,

            size: 90,

            color: Colors.grey,

          ),

          SizedBox(height: 15),

          Text(

            "No Action Available",

            style: TextStyle(

              fontSize: 18,

              fontWeight: FontWeight.bold,

            ),

          )

        ],

      ),

    );
  }

  Widget buildActionCard(Map tour) {
    return Container(

      margin: const EdgeInsets.only(bottom: 20),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: const [

          BoxShadow(

            color: Colors.black12,

            blurRadius: 10,

            offset: Offset(0, 5),

          ),

        ],

      ),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //---------------- HEADER ----------------//

            Row(

              children: [

                const CircleAvatar(

                  radius: 25,

                  backgroundColor: Color(0xff1E2F5B),

                  child: Icon(

                    Icons.person,

                    color: Colors.white,

                  ),

                ),

                const SizedBox(width: 12),

                Expanded(

                  child: Column(

                    crossAxisAlignment:

                    CrossAxisAlignment.start,

                    children: [

                    Text(
  tour["NAME"] == null ||
          tour["NAME"].toString().isEmpty
      ? "Employee"
      : tour["NAME"].toString(),
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

                      Text(

                        "Tour ID : ${tour["TOUR_ID"]}",

                        style: const TextStyle(

                          color: Colors.grey,

                        ),

                      ),

                    ],

                  ),

                ),

                buildOverallStatus(

                  tour,

                ),

              ],

            ),

            const SizedBox(height: 18),

            buildInfoTile(

              Icons.email,

              "Email",

              tour["EMAIL"] == null ||
tour["EMAIL"].toString().isEmpty
    ? "-"
    : tour["EMAIL"]

            ),

            buildInfoTile(

              Icons.calendar_month,

              "Tour Date",

              tour["FROM_DATE"],

            ),

            buildInfoTile(

              Icons.location_on,

              "Visit Place",

              tour["VISIT_PLACE"],

            ),

            buildInfoTile(

              Icons.work,

              "Purpose",

              tour["VISIT_PURPOSE"],

            ),

            buildInfoTile(

              Icons.currency_rupee,

              "Sanction",

              tour["SANCTION"],

            ),

            buildInfoTile(

              Icons.money,

              "Advance",

              tour["ADVANCE_AMOUNT"],

            ),

            const SizedBox(height: 15),

            const Divider(),

            const SizedBox(height: 10),

            const Text(

              "Approval Status",

              style: TextStyle(

                fontWeight: FontWeight.bold,

                fontSize: 17,

              ),

            ),

            const SizedBox(height: 12),

            Wrap(

              spacing: 8,

              runSpacing: 8,

              children: [

                buildStatusChip(

                  "RI",

                  tour["RI_STATUS"],

                ),

                buildStatusChip(

                  "PI",

                  tour["PI_STATUS"],

                ),

                buildStatusChip(

                  "VI",

                  tour["VI_STATUS"],

                ),

                buildStatusChip(

                  "AO",

                  tour["AO_STATUS"],

                ),

                buildStatusChip(

                  "DIR",

                  tour["DIRECTOR_STATUS"],

                ),

              ],

            ),

            const SizedBox(height: 18),

            buildConfirmationCard(tour),

            const SizedBox(height: 18),
            if (!ApiService.isFullyApproved(tour))
  buildApprovalSection(tour),

if (ApiService.isFullyApproved(tour))
  buildExecutionSection(tour),

const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,

              child: FilledButton.icon(

                

                style: FilledButton.styleFrom(

                  backgroundColor:

                  const Color(

                      0xff1E2F5B),

                  shape:

                  RoundedRectangleBorder(

                    borderRadius:

                    BorderRadius.circular(

                        12),

                  ),

                ),

                icon: const Icon(

                  Icons.visibility,

                  color: Colors.white,

                ),

                label: const Text(

                  "View Details",

                  style: TextStyle(

                    color: Colors.white,

                  ),

                ),

                onPressed: () {
                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>

                          TourDetailsScreen(

                            tourId: tour["TOUR_ID"]
                                .toString(),

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
  

Widget buildOverallStatus(Map tour) {

  String status = "IN PROCESS";
  Color color = Colors.orange;

  if (ApiService.isFullyApproved(tour)) {

    status = "APPROVED";
    color = Colors.green;

  } else if (

      tour["RI_STATUS"] == "REJECT" ||
      tour["PI_STATUS"] == "REJECT" ||
      tour["VI_STATUS"] == "REJECT" ||
      tour["AO_STATUS"] == "REJECT" ||
      tour["DIRECTOR_STATUS"] == "REJECT") {

    status = "REJECTED";
    color = Colors.red;

  }

  return Chip(

    backgroundColor: color,

    label: Text(

      status,

      style: const TextStyle(

        color: Colors.white,
        fontWeight: FontWeight.bold,

      ),

    ),

  );

}

  Widget buildConfirmationCard(Map tour) {
    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: tour["CONFIRMATION_STATUS_"]=="PENDING"

? Colors.orange.shade100

: Colors.green.shade100,

        borderRadius: BorderRadius.circular(12),

      ),

      child: Row(

        children: [

          Icon(

            tour["CONFIRMATION_STATUS_"]=="PENDING"

? Icons.pending_actions

: Icons.check_circle,

            color: Colors.blue,

          ),

          const SizedBox(width: 10),

          Expanded(

            child: Text(

              "Confirmation : ${tour["CONFIRMATION_STATUS_"]}",

              style: const TextStyle(

                fontWeight: FontWeight.bold,

              ),

            ),

          ),

        ],

      ),

    );
  }
Widget buildApprovalSection(Map tour) {

  if (!ApiService.canCurrentRoleApprove(
      tour,
      userRole,
  )) {

    return const SizedBox();

  }

  return Column(

    children: [

      TextField(

        controller: remarksController,

        decoration: InputDecoration(

          labelText: "Remarks",

          border: OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(10),

          ),

        ),

      ),

      const SizedBox(height:15),

      Row(

        children: [

          Expanded(

            child: ElevatedButton(

              style: ElevatedButton.styleFrom(

                backgroundColor: Colors.green,

              ),

              onPressed: () {

                approveTour(

                  tour,

                  "APPROVE",

                );

              },

              child: const Text(

                "Approve",

              ),

            ),

          ),

          const SizedBox(width:12),

          Expanded(

            child: ElevatedButton(

              style: ElevatedButton.styleFrom(

                backgroundColor: Colors.red,

              ),

              onPressed: () {

                approveTour(

                  tour,

                  "REJECT",

                );

              },

              child: const Text(

                "Reject",

              ),

            ),

          ),

        ],

      ),

    ],

  );

}
Widget buildExecutionSection(Map tour){

  if(

      !ApiService.isConfirmationPending(

          tour)

  ){

    return const SizedBox();

  }

  return Column(

    children: [

      TextField(

        controller:

        remarksController,

        decoration:

        const InputDecoration(

          labelText:

          "Execution Remarks",

        ),

      ),

      const SizedBox(height:15),

      Row(

        children: [

          Expanded(

            child:

            ElevatedButton(

              style:

              ElevatedButton.styleFrom(

                backgroundColor:

                Colors.green,

              ),

              onPressed: (){

                updateExecution(

                  tour,

                  "EXECUTED",

                );

              },

              child:

              const Text(

                "Execute All",

              ),

            ),

          ),

          const SizedBox(width:12),

          Expanded(

            child:

            ElevatedButton(

              style:

              ElevatedButton.styleFrom(

                backgroundColor:

                Colors.red,

              ),

              onPressed: (){

                updateExecution(

                  tour,

                  "NOT_EXECUTED",

                );

              },

              child:

              const Text(

                "Not Execute",

              ),

            ),

          ),

        ],

      ),

    ],

  );

}
  Widget buildInfoTile(IconData icon,

      String title,

      dynamic value,) {
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

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: TextStyle(

                    color: Colors.grey[600],

                    fontSize: 12,

                  ),

                ),

                const SizedBox(height: 3),

                Text(

                  value == null ||

                      value
                          .toString()
                          .isEmpty

                      ? "-"

                      : value.toString(),

                  style: const TextStyle(

                    fontWeight:
                    FontWeight.w600,

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

  Widget buildStatusChip(String title,

      dynamic status,) {
    Color color = Colors.orange;

    IconData icon = Icons.schedule;

    String value =
        status?.toString() ??
            "PENDING";

    switch (value.toUpperCase()) {
      case "APPROVE":
        color = Colors.green;

        icon = Icons.check_circle;

        break;

      case "REJECT":
        color = Colors.red;

        icon = Icons.cancel;

        break;

      case "ACTION NOT REQUIRED":
        color = Colors.blue;

        icon = Icons.info;

        break;
    }

    return Chip(

      avatar: Icon(

        icon,

        color: Colors.white,

        size: 18,

      ),

      backgroundColor: color,

      label: Text(

        "$title",

        style: const TextStyle(

          color: Colors.white,

          fontWeight: FontWeight.bold,

        ),

      ),

    );
  }
  Future approveTour(

Map tour,

String action,

) async {

  final result =

      await ApiService.approveTour(

    tourId:

    tour["TOUR_ID"].toString(),

    action: action,

    remarks:

    remarksController.text,

    email:

    await ApiService

        .getLoggedUserEmail(),

  );

  if(result!=null){

    remarksController.clear();

    loadActionList();

    ScaffoldMessenger.of(context)

        .showSnackBar(

      SnackBar(

        content:

        Text(result["message"]),

      ),

    );

  }

}
Future updateExecution(

Map tour,

String status,

) async{

  final result =

      await ApiService.confirmJourney(

    tourId:

    tour["TOUR_ID"].toString(),

    confirmationStatus:

    status,

    remarks:

    remarksController.text,

  );

  if(result!=null){

    remarksController.clear();

    loadActionList();

    ScaffoldMessenger.of(context)

        .showSnackBar(

      SnackBar(

        content:

        Text(result["message"]),

      ),

    );

  }

}
}
