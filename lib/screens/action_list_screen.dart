import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'tour_details_screen.dart';
import '../widgets/tour_card.dart';
import '../widgets/action_card_widgets.dart';

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

  List<String> userRoles = [];

  @override
  void initState() {
    super.initState();

    loadActionList();
  }

  Future<void> loadActionList() async {
    setState(() {
      loading = true;
    });

    userRoles = await ApiService.getUserRoles();

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

                  itemBuilder: (context, index) {

  final tour = filteredTours[index];

  return TourCard(

    tour: tour,

    children: [

      OverallStatus(
        tour: tour,
      ),

      const SizedBox(height: 15),

      ConfirmationCard(
        tour: tour,
      ),

      const SizedBox(height: 15),

      if (ApiService.canCurrentRoleApprove(
        tour,
        userRoles,
      ))
        ActionButtonsSection(
        tour: tour,
                    userRoles: userRoles,
                    remarksController: remarksController,

                    onApprove: () {
                    approveTour(
                    tour,
                    "APPROVE",
                    );
                    },

                    onReject: () {
                    approveTour(
                    tour,
                    "REJECT",
                    );
                    },

                    onExecute: () {
                    updateExecution(
                    tour,
                    "EXECUTED",
                    );
                    },

                    onNotExecute: () {
                    updateExecution(
                    tour,
                    "NOT_EXECUTED",
                    );
                    },
                    ),

  ]
  );

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
