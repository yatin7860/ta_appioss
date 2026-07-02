import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';

class TourDetailsScreen extends StatefulWidget {
  final String tourId;

  const TourDetailsScreen({
    super.key,
    required this.tourId,
  });

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  bool loading = true;

Map<String, dynamic>? tour;
Map<String, dynamic>? profile;
List journeyList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }
Future<void> loadData() async {

  final tourResponse =
      await ApiService.getTourDetails(widget.tourId);

  final profileResponse =
      await ApiService.getProfile();

  if (tourResponse != null &&
      tourResponse["success"] == true &&
      tourResponse["data"] != null &&
      tourResponse["data"].isNotEmpty) {

    setState(() {

      journeyList = tourResponse["data"];

      tour = tourResponse["data"][0];

      profile = profileResponse;

      loading = false;

    });

  } else {

    setState(() {

      loading = false;

    });

  }
}

  String value(dynamic v) {
    if (v == null) return "-";

    if (v.toString().trim().isEmpty) {
      return "-";
    }

    return v.toString();
  }
  String get reportingEmail =>
    profile?["REPORTING_INCHARGE"] ?? "-";

String get vehicleEmail =>
    profile?["VI_INCHARGE_1"] ?? "-";

String get accountEmail =>
    profile?["AO_INCHARGE_1"] ?? "-";

String get directorEmail =>
    profile?["DIRECTOR_APPROVAL"] ?? "-";

String get userRole =>
    profile?["ROLE"] ?? "-";

Widget rowItem(
  String title,
  dynamic valueText,
) {

  return Padding(

    padding: const EdgeInsets.symmetric(vertical: 6),

    child: Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Icon(

          Icons.arrow_right,

          size: 18,

          color: Colors.blue,

        ),

        const SizedBox(width: 5),

        SizedBox(

          width: 150,

          child: Text(

            title,

            style: const TextStyle(

              fontWeight: FontWeight.bold,

            ),

          ),

        ),

        Expanded(

          child: Text(

            value(valueText),

          ),

        ),

      ],

    ),

  );

}
  Widget statusBadge(String? status) {

  Color bgColor = Colors.grey.shade300;
  Color textColor = Colors.black;

  String value = (status ?? "").trim().toUpperCase();

  if (value == "APPROVE") {

    bgColor = Colors.green.shade100;
    textColor = Colors.green.shade900;

  } else if (value == "PENDING") {

    bgColor = Colors.orange.shade100;
    textColor = Colors.orange.shade900;

  } else if (value == "REJECT") {

    bgColor = Colors.red.shade100;
    textColor = Colors.red.shade900;

  } else if (value == "ACTION NOT REQUIRED") {

    bgColor = Colors.blue.shade100;
    textColor = Colors.blue.shade900;

  }

  return Container(

    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),

    decoration: BoxDecoration(

      color: bgColor,

      borderRadius: BorderRadius.circular(20),

    ),

    child: Text(

      value.isEmpty ? "-" : value,

      style: TextStyle(

        color: textColor,

        fontWeight: FontWeight.bold,

      ),

    ),

  );
}
Widget statusRow(String title, String? status) {

  return Padding(

    padding: const EdgeInsets.symmetric(vertical: 6),

    child: Row(

      children: [

        SizedBox(

          width: 170,

          child: Text(

            title,

            style: const TextStyle(

              fontWeight: FontWeight.bold,

            ),

          ),

        ),

        Expanded(

          child: statusBadge(status),

        ),

      ],

    ),

  );

}

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tour List"),
        backgroundColor: const Color(0xff1E2F5B),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : tour == null
              ? const Center(
                  child: Text("No Data Found"),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {

                            if (tour == null) return;

                            await PdfService.printTour(

                              tour: tour!,

                              profile: profile,

                              journeyList: journeyList,

                            );

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            "PRINT",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      
///basic details 
            ExpansionTile(

  tilePadding: EdgeInsets.zero,

  collapsedBackgroundColor: const Color(0xFF1E2F5B),

  backgroundColor: const Color(0xFF1E2F5B),

  collapsedShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),

  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),

  iconColor: Colors.white,

  collapsedIconColor: Colors.white,

  title: const Row(

    children: [

      Icon(
        Icons.person,
        color: Colors.white,
      ),

      SizedBox(width: 10),

      Text(

        "Basic Details",

        style: TextStyle(

          color: Colors.white,

          fontSize: 18,

          fontWeight: FontWeight.bold,

        ),

      ),

    ],

  ),

  children: [

    Card(

      margin: const EdgeInsets.only(top: 10),

      elevation: 2,

      child: Padding(

        padding: const EdgeInsets.all(15),

        child: Column(

          children: [

           rowItem(
                                "Tour ID",
                                tour!["TOUR_ID"],
                              ),

                              rowItem(
                                "Tour Request",
                                tour!["DATE_TIME"],
                              ),

                              rowItem(
                                "Name",
                                tour!["NAME"],
                              ),

                              rowItem(
                                "Contact",
                                tour!["CONTACT"],
                              ),

                              rowItem(
                                "Email",
                                tour!["EMAIL"],
                              ),

                              rowItem(
                                "Designation",
                                tour!["DESIGNATION"],
                              ),

                              rowItem(
                                "Division",
                                tour!["DIVISION"],
                              ),

                              rowItem(
                                "Visit Purpose",
                                tour!["VISIT_PURPOSE"],
                              ),

                              rowItem(
                                "Tour Type",
                                tour!["TOUR_TYPE"],
                              ),

                              rowItem(
                                "Other Tour Type",
                                tour!["OTHER_TOUR_TYPE"],
                              ),

                              rowItem(
                                "Sanction",
                                tour!["SANCTION"],
                              ),

                              rowItem(
                                "Advance",
                                tour!["ADVANCE_AMOUNT"],
                              ),

                              rowItem(
                                "Project Scheme",
                                tour!["PROJECT_ID"],
                              ),

                              rowItem(
                                "From Date",
                                tour!["FROM_DATE"],
                              ),

                              rowItem(
                                "To Date",
                                tour!["TO_DATE"],
                              ),

                              rowItem(
                                "Days",
                                tour!["DAYS"],
                              ),

                              rowItem(
                                "Place to be visited",
                                tour!["VISIT_PLACE"],
                              ),

                              rowItem(
                                "Assigned Vehicle",
                                tour!["VEHICLE_NAME"],
                              ),

                              rowItem(
                                "Assigned Driver",
                                tour!["DRIVER_NAME"],
                              ),

                              rowItem(
                                "Grant for Advance",
                                tour!["ADVANCE_AMOUNT"],
                              ),

                              rowItem(
                                "Account will be submitted by",
                                tour!["SUBMIT_ACCOUNT"],
                              ),


          ],

        ),

      ),

    ),

  ],

),
                      //=====================================================
// APPROVAL DETAILS
//=====================================================
ExpansionTile(

  tilePadding: EdgeInsets.zero,

  collapsedBackgroundColor: Colors.green,

  backgroundColor: Colors.green,

  collapsedShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),

  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),

  iconColor: Colors.white,

  collapsedIconColor: Colors.white,

  title: const Row(

    children: [

      Icon(
        Icons.approval,
        color: Colors.white,
      ),

      SizedBox(width: 10),

      Text(

        "Approval Details",

        style: TextStyle(

          color: Colors.white,

          fontWeight: FontWeight.bold,

          fontSize: 18,

        ),

      ),

    ],

  ),

  children: [

    Card(

      margin: const EdgeInsets.only(top: 10),

      child: Padding(

        padding: const EdgeInsets.all(15),

        child: Column(

          children: [

     rowItem(
  "Reporting Incharge",
  reportingEmail,
),

rowItem(
  "Role",
  "Reporting Incharge",
),

statusRow(
  "Status",
  tour!["RI_STATUS"],
),

rowItem(
  "Remarks",
  tour!["RI_REMARKS"],
),

        const Divider(),

        rowItem(
  "Project Incharge",
  profile?["PI_INCHARGE"] ?? "-",
),

rowItem(
  "Role",
  "Project Incharge",
),

statusRow(
  "Status",
  tour!["PI_STATUS"],
),

rowItem(
  "Remarks",
  tour!["PI_REMARKS"],
),
        const Divider(),

      rowItem(
  "Vehicle Incharge",
  vehicleEmail,
),

rowItem(
  "Role",
  "Vehicle Incharge",
),

        statusRow(
        "Vehicle Incharge Status",
        tour!["VI_STATUS"],
        ),

        rowItem(
          "Vehicle Incharge Remarks",
          tour!["VI_REMARKS"],
        ),

        rowItem(
          "Vehicle Name",
          tour!["VEHICLE_NAME"],
        ),

        rowItem(
          "Driver Name",
          tour!["DRIVER_NAME"],
        ),

        const Divider(),

       
        rowItem(
  "Account Office",
  accountEmail,
),

rowItem(
  "Role",
  "Accounts Office",
),

        statusRow(
          "Account Office Status",
          tour!["AO_STATUS"],
        ),

        rowItem(
          "Account Office Remarks",
          tour!["AO_REMARKS"],
        ),

        const Divider(),

       rowItem(
  "Director",
  directorEmail,
),

rowItem(
  "Role",
  "Director",
),

        statusRow(
        "Director Status",
          tour!["DIRECTOR_STATUS"],
        ),

        rowItem(
          "Director Remarks",
          tour!["DIRECTOR_REMARKS"],
        ),


          ],

        ),

      ),

    ),

  ],

),

//// journey details
//
ExpansionTile(

  tilePadding: EdgeInsets.zero,

  collapsedBackgroundColor: Colors.orange,

  backgroundColor: Colors.orange,

  collapsedShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),

  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),

  iconColor: Colors.white,

  collapsedIconColor: Colors.white,

  title: const Row(

    children: [

      Icon(
        Icons.route,
        color: Colors.white,
      ),

      SizedBox(width: 10),

      Text(
        "Journey Details",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

    ],

  ),

  children: [

    ListView.builder(

      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: journeyList.length,

      itemBuilder: (context, index) {

        final journey = journeyList[index];

        return Card(

          margin: const EdgeInsets.all(10),

          elevation: 2,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),

          child: Padding(

            padding: const EdgeInsets.all(15),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

               Container(

  width: double.infinity,

  padding: const EdgeInsets.all(12),

  decoration: BoxDecoration(

    color: Colors.blue.shade50,

    borderRadius: BorderRadius.circular(8),

  ),

  child: Text(

    "Journey ${index + 1}",

    style: const TextStyle(

      fontSize: 18,

      fontWeight: FontWeight.bold,

      color: Colors.blue,

    ),

  ),

), 

                const Divider(),

                rowItem(
                  "Journey Date",
                  journey["DATE_"],
                ),

                rowItem(
                  "From",
                  journey["FROM_"],
                ),

                rowItem(
                  "To",
                  journey["TO_"],
                ),

                rowItem(
                  "Mode of Journey",
                  journey["JOURNEY_MODE_"],
                ),

                rowItem(
                  "Vehicle Type",
                  journey["VEHICLE_TYPE_"],
                ),

                rowItem(
                  "Vehicle Remarks",
                  journey["VEHICLE_REMARKS_"],
                ),

                rowItem(
                  "Other Journey",
                  journey["OTHER_MODE_"],
                ),

                rowItem(
                  "Remarks",
                  journey["SPECIFIC_REASON_"],
                ),

                statusRow(
                  "Confirmation Status",
                  journey["CONFIRMATION_STATUS_"],
                ),

              ],

            ),

          ),

        );

      },

    ),

  ],

),
        ]
                  )
    )
    );
  }
}