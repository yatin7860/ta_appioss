import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/tour_card.dart';

class EmployeeTourListScreen extends StatefulWidget {
  const EmployeeTourListScreen({super.key});

  @override
  State<EmployeeTourListScreen> createState() =>
      _EmployeeTourListScreenState();
}

class _EmployeeTourListScreenState
    extends State<EmployeeTourListScreen> {
      List tours = [];

List filteredTours = [];

bool loading = true;

final TextEditingController searchController =
    TextEditingController();
    @override
void initState() {
  super.initState();
  getEmployeeTours();
}
Future<void> getEmployeeTours() async {
  setState(() {
    loading = true;
  });

  var result =
  await ApiService.getEmployeeTourList();

  if (result != null &&
      result["success"] == true) {
    tours = result["tours"] ?? [];

    filteredTours = List.from(tours);
  }

  setState(() {
    loading = false;
  });
}
      void searchTour(String value){

        if(value.isEmpty){

          filteredTours=List.from(tours);

        }else{

          filteredTours=tours.where((tour){

            return tour["NAME"]
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase())

                ||

                tour["TOUR_ID"]
                    .toString()
                    .contains(value);

          }).toList();

        }

        setState(() {});

      }
      @override
      Widget build(BuildContext context){

        return Scaffold(

          appBar: AppBar(
            title: const Text("Employee Tour List"),
          ),

          body:

          loading

              ?

          const Center(
            child: CircularProgressIndicator(),
          )

              :

          Column(

            children: [

              Padding(

                padding: const EdgeInsets.all(12),

                child: TextField(

                  controller: searchController,

                  onChanged: searchTour,

                  decoration: const InputDecoration(

                    hintText: "Search Tour",

                    prefixIcon: Icon(Icons.search),

                  ),

                ),

              ),

              Expanded(

                child:

                ListView.builder(

                  itemCount: filteredTours.length,

                  itemBuilder: (context,index){

                    return TourCard(

                      tour: filteredTours[index],

                    );

                  },

                ),

              ),

            ],

          ),

        );

      }
}