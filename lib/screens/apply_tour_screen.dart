import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';
import 'login_screen.dart';
import 'my_tour_list_screen.dart';
import 'dart:convert';

class ApplyTourScreen extends StatefulWidget {

  const ApplyTourScreen({super.key});

  @override
  State<ApplyTourScreen> createState() =>
      _ApplyTourScreenState();
}

class _ApplyTourScreenState
    extends State<ApplyTourScreen> {

  // ================= USER =================

  String empId = "";

  String name = "";

  String email = "";

  String group = "";

  String contact = "";

  String designation = "";

  String riEmail = "";

  String viEmail = "";

  String piEmail = "";

  String aoEmail = "";

  String directorEmail = "";

  // ================= CONTROLLERS =================

  final fromController =
  TextEditingController();

  final toController =
  TextEditingController();

  final purposeController =
  TextEditingController();

  final sanctionController =
  TextEditingController();

  final placeController =
  TextEditingController();

  final remarksController =
  TextEditingController();

  final advanceController =
  TextEditingController();

  DateTime? startDate;

  DateTime? endDate;

  String journeyMode = "";

  String tourType = "";

  List<dynamic> projectSchemes = [];

  List<String> journeyModes = [];

  String? selectedProjectScheme;
  String? selectedJourneyMode;

  String? selectedVehicleType;

  List<String> vehicleTypes = [
    "Hatchback/Sedan",
    "SUV",
  ];

  final vehicleRemarksController =
  TextEditingController();
  final otherJourneyController =
  TextEditingController();

  bool showAdvance = false;
  bool isSubmitting = false;

  List<PlatformFile> files = [];
  List<Map<String, dynamic>> journeyList = [];

  // ================= INIT =================

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      print("APPLY TOUR LOG ID = ${prefs.getString('log_id')}");
    });

    loadUser();
    fetchDropdownData();
  }

  // ================= LOAD USER =================

  Future<void> loadUser() async {

    try {

      final data =
      await ApiService.getProfile();
      print("PROFILE DATA: $data");

      if (data != null) {

        setState(() {

          empId =
              data['EMP_ID']
                  ?.toString() ?? "";

          name =
              data['NAME']
                  ?.toString() ?? "";

          email =
              data['EMAIL']
                  ?.toString() ?? "";

          group =
              data['GROUP_NAME']
                  ?.toString() ?? "";

          contact =
              data['CONTACT']
                  ?.toString() ?? "";

          designation =
              data['DESIGNATION']
                  ?.toString() ?? "";

          riEmail =
              data["REPORTING_INCHARGE"]
                  ?.toString() ?? "";

          viEmail =
              data["VI_INCHARGE_1"]
                  ?.toString() ?? "";

          piEmail = data["PROJECT_INCHARGE"]?.toString() ?? "";

          aoEmail =
              data["AO_INCHARGE_1"]
                  ?.toString() ?? "";

          directorEmail =
              data["DIRECTOR_APPROVAL"]
                  ?.toString() ?? "";

          print("RI : $riEmail");

          print("VI : $viEmail");

          print("AO : $aoEmail");

          print("DIRECTOR : $directorEmail");
        });
      }

    } catch (e) {

      print(
        "LOAD USER ERROR: $e",
      );
    }
  }
///////
  Future<void> fetchDropdownData() async {

    try {

      final data =
      await ApiService
          .getTourDropdownData();

      print(data);

      if (data != null &&
          data["success"] == true) {

        final List<dynamic> schemes =
            data["project_schemes"] ?? [];

        final List<dynamic> journeys =
            data["journey_modes"] ?? [];

        setState(() {

          projectSchemes = schemes;

          journeyModes = journeys
              .map((e) =>
              e["JOURNEY_MODE"].toString())
              .toList();
        });

        print(projectSchemes);

        print(journeyModes);
      }

    } catch (e) {

      print(e);
    }
  }

  // ================= DATE PICKER =================

  Future<void> pickDate(
      bool isStart,
      ) async {

    DateTime? picked =
    await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2023),

      lastDate: DateTime(2100),
    );

    if (picked != null) {

      setState(() {

        if (isStart) {

          startDate = picked;

        } else {

          endDate = picked;
        }
      });
    }
  }

  // ================= DAYS =================
  String getDays() {

    if (startDate != null &&
        endDate != null) {

      int days =
          endDate!
              .difference(startDate!)
              .inDays + 1;

      return days.toString();
    }

    return "1";
  }

  // ================= FILE PICKER =================

  Future<void> pickFiles() async {

    FilePickerResult? result =
    await FilePicker.platform.pickFiles(

      allowMultiple: true,

      type: FileType.any,
    );

    if (result != null) {

      setState(() {

        files = result.files;
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> submitData() async {
    // Prevent multiple clicks
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    // ===== VALIDATION =====

    if (journeyList.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one journey."),
        ),
      );

      return;
    }

    print("=========== BEFORE SUBMIT ===========");
    print("Journey Count : ${journeyList.length}");
    print(journeyList);

    //
    if (purposeController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Purpose of Visit is Required"),
        ),
      );

      return;

    }
//
    if (sanctionController.text.isNotEmpty &&
        double.tryParse(sanctionController.text) == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Sanction Amount"),
        ),
      );

      return;

    }
//
    if (startDate == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Start Date is Required"),
        ),
      );

      return;

    }
//
    if (endDate == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("End Date is Required"),
        ),
      );

      return;

    }
//
    if (endDate!.isBefore(startDate!)) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "End Date must be after Start Date",
          ),
        ),
      );

      return;

    }
//
    if (fromController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter From Location",
          ),
        ),
      );

      return;

    }
//
    if (toController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter To Location",
          ),
        ),
      );

      return;

    }
//
    if (fromController.text.trim().toLowerCase() ==
        toController.text.trim().toLowerCase()) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "From and To cannot be same",
          ),
        ),
      );

      return;

    }
//
    if (selectedJourneyMode == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Select Journey Mode",
          ),
        ),
      );

      return;

    }
//

    if (tourType.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select Tour Type"),
        ),
      );

      return;

    }
//
    if (selectedProjectScheme == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select Project Scheme"),
        ),
      );

      return;

    }
//
    if (placeController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Place to be Visited is Required"),
        ),
      );

      return;

    }
//
    if (showAdvance) {

      if (advanceController.text.trim().isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Enter Advance Amount",
            ),
          ),
        );

        return;

      }

      if (double.tryParse(
          advanceController.text) ==
          null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid Advance Amount",
            ),
          ),
        );

        return;

      }

    }
//
    if (journeyList.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please add at least one journey.",
          ),
        ),
      );

      return;

    }
//
    if (selectedJourneyMode == "Taxi") {

      if (selectedVehicleType == null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Select Vehicle Type",
            ),
          ),
        );

        return;

      }

      if (vehicleRemarksController.text
          .trim()
          .isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Vehicle Remarks Required",
            ),
          ),
        );

        return;

      }

    }
//
    if (selectedJourneyMode == "Other") {

      if (otherJourneyController.text
          .trim()
          .isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Specify Other Journey Mode",
            ),
          ),
        );

        return;

      }

    }
//

    if (showAdvance) {

      if (advanceController.text.trim().isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter Advance Amount"),
          ),
        );

        return;
      }

      // Advance submission date validation
      if (endDate == null) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Select Advance Submission Date"),
          ),
        );

        return;
      }

    }
//

    Map<String, dynamic> body = {

      "PUT_SELECTED_PROEJCT": selectedProjectScheme ?? "",

      "PUT_EMP_ID": empId,

      "PUT_NAME": name,

      "PUT_CONTACT": contact,

      "PUT_EMAIL": email,

      "PUT_DESIGNATION": designation,

      "PUT_DIVISION": group,

      "PUT_USER_TYPE": "USER",

      "PUT_RI_EMAIL": riEmail,

      "PUT_VI_EMAIL": viEmail,

      "PUT_PI_EMAIL": piEmail,

      "PUT_AO_EMAIL": aoEmail,

      "PUT_DIRECTOR_EMAIL": directorEmail,

      "PUT_VISIT_PURPOSE": purposeController.text,

      "PUT_TOUR_TYPE": tourType,

      "PUT_OTHER_TOUR_TYPE": "",

      "PUT_SANCTION": sanctionController.text,

      "PUT_OTHER_PROJECT": "",

      "PUT_ADVANCE":
      showAdvance
          ? advanceController.text
          : "0",

      "PUT_ADVANCE_DATE":
      endDate == null
          ? ""
          : endDate.toString().split(" ")[0],

      "PUT_FROM_DATE":
      startDate == null
          ? ""
          : startDate.toString().split(" ")[0],

      "PUT_TO_DATE":
      endDate == null
          ? ""
          : endDate.toString().split(" ")[0],

      "PUT_DAYS": getDays(),

      "PUT_VISIT_PLACE": placeController.text,

      // IMPORTANT
      "journey_details": journeyList,

    };

    print(body);

    print("========== BODY ==========");

    body.forEach((key,value){

      print("$key : $value");

    });

    print("==========================");

    final response = await ApiService.submitTour(body);

    print("SUBMIT RESPONSE : $response");

    if (!mounted) return;

    if (response != null &&
        response["success"] == true) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MyTourListScreen(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response?["message"] ??
                "Failed to submit tour",
          ),
        ),
      );

    }

  }
  ///add journey
  ///
  void addJourney() {

    if (startDate == null) {
      if (this.startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Select Tour Dates First",
            ),
          ),
        );
        return;
      }

      if (startDate!.isBefore(this.startDate!) ||
          startDate!.isAfter(endDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Journey Date must be between Tour Dates",
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select journey date")),
      );
      return;
    }

    if (fromController.text.trim().isEmpty ||
        toController.text.trim().isEmpty ||
        selectedJourneyMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all journey details")),
      );
      return;
    }
    //
    bool alreadyExists =
    journeyList.any((e) {

      return e["date"] ==
          startDate!
              .toString()
              .split(" ")[0] &&
          e["from"] ==
              fromController.text.trim() &&
          e["to"] ==
              toController.text.trim();

    });

    if (alreadyExists) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Journey Already Added",
          ),
        ),
      );

      return;

    }
//

    Map<String, dynamic> journey = {

      "date": startDate!.toString().split(" ")[0],

      "from": fromController.text.trim(),

      "to": toController.text.trim(),

      "journey_mode": selectedJourneyMode!,

      "taxi_type": selectedVehicleType ?? "",

      "taxi_remarks": vehicleRemarksController.text.trim(),

      "other_mode": otherJourneyController.text.trim(),

      "remarks": remarksController.text.trim(),

    };

    setState(() {

      journeyList.add(journey);

      print("============= JOURNEY ADDED =============");
      print(journey);
      print("TOTAL JOURNEYS : ${journeyList.length}");
      print(journeyList);
      print("========================================");

      fromController.clear();
      toController.clear();
      remarksController.clear();
      vehicleRemarksController.clear();
      otherJourneyController.clear();

      selectedJourneyMode = null;
      selectedVehicleType = null;
      startDate = null;

    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Journey Added Successfully"),
      ),
    );
  }
  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: AppDrawer(
        name: name,
        email: email,
      ),

      backgroundColor:
      const Color(0xFFF2F2F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFF162B63),
        elevation: 0,

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        title: const Text(
          "Apply Tour",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),

            onSelected: (value) async {
              if (value == "logout") {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              }
            },

            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(18),

        child: Column(

            children: [

              // ================= EMPLOYEE DETAILS =================

              sectionCard(

                title: "Employee Details",

                children: [

                  buildField(
                    "Employee Id",
                    empId,
                  ),

                  buildField(
                    "Email",
                    email,
                  ),

                  buildField(
                    "Group",
                    group,
                  ),

                  buildField(
                    "Name",
                    name,
                  ),

                  buildField(
                    "Contact",
                    contact,
                  ),

                  buildField(
                    "Designation",
                    designation,
                  ),
                ],
              ),

              // ================= TOUR DETAILS =================

              sectionCard(

                title: "Tour Details",

                children: [

                  // ================= PURPOSE =================

                  buildInput(
                    "Purpose of Visit",
                    purposeController,
                  ),

                  // ================= SANCTION =================

                  buildInput(
                    "Sanction",
                    sanctionController,
                  ),

                  // ================= DATE FROM =================

                  dateField(
                    "Date From",
                    startDate,
                        () => pickDate(true),
                  ),

                  if (startDate == null)

                    const Padding(

                      padding: EdgeInsets.only(
                        left: 4,
                        top: 2,
                        bottom: 12,
                      ),

                      child: Text(

                        "Start date is required",

                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  // ================= DATE TO =================

                  dateField(
                    "Date To",
                    endDate,
                        () => pickDate(false),
                  ),

                  if (endDate == null)

                    const Padding(

                      padding: EdgeInsets.only(
                        left: 4,
                        top: 2,
                        bottom: 12,
                      ),

                      child: Text(

                        "End date is required",

                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  // ================= AUTO DAYS =================

                  buildField(
                    "Days",
                    getDays(),
                  ),

                  // ================= TOUR TYPE =================

                  dropdownField(

                    "Tour Type",

                    [
                      "Field",
                      "Meeting",
                      "Office",
                      "Other",
                    ],

                        (val) {

                      setState(() {

                        tourType = val;
                      });
                    },
                  ),

                  if (tourType.isEmpty)

                    const Padding(

                      padding: EdgeInsets.only(
                        left: 4,
                        top: 2,
                        bottom: 12,
                      ),

                      child: Text(

                        "tour type is Required",

                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),



// ================= PROJECT SCHEME =================

                  const Text(
                    "Project Scheme",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedProjectScheme,
                    decoration: InputDecoration(
                      hintText: "Select Project Scheme",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    items: projectSchemes.map((item) {

                      return DropdownMenuItem<String>(

                        value: item["Id"].toString(),

                        child: Text(

                          item["Project_Name"],

                          overflow: TextOverflow.ellipsis,

                        ),

                      );

                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProjectScheme = value;
                      });
                    },
                  ),

                  if (selectedProjectScheme == null)
                    const Padding(
                      padding: EdgeInsets.only(left: 4, top: 4, bottom: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Project Scheme is Required",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 18),

                  // ================= PLACE =================

                  buildInput(
                    "Place to be Visited",
                    placeController,
                  ),
                ],
              ),



              // ================= JOURNEY DETAILS =================

              sectionCard(

                  title: "Journey Details",

                  children: [

                    dateField(
                      "Date",
                      startDate,
                          () => pickDate(true),
                    ),
                    if (startDate == null)

                      const Padding(

                        padding: EdgeInsets.only(
                          left: 4,
                          top: 2,
                          bottom: 12,
                        ),

                        child: Text(

                          "Journey date is required",

                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),


                    buildInput(
                      "From",
                      fromController,
                    ),
                    if (startDate == null)

                      const Padding(

                        padding: EdgeInsets.only(
                          left: 4,
                          top: 2,
                          bottom: 12,
                        ),

                        child: Text(

                          "Start date is required",

                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),


                    buildInput(
                      "To",
                      toController,
                    ),

// ================= MODE OF JOURNEY =================

                    const Text(
                      "Mode of Journey",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedJourneyMode,
                      decoration: InputDecoration(
                        hintText: "Select Mode of Journey",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      items: journeyModes.map((item) {
                        return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item)
                        );
                      }).toList(),
////////
                      onChanged: (value) {

                        setState(() {

                          selectedJourneyMode = value;

                          if (value != "Taxi") {

                            selectedVehicleType = null;
                            vehicleRemarksController.clear();

                          }

                          if (value != "Other") {

                            otherJourneyController.clear();

                          }

                        });

                      },
                    ),
                    if (selectedJourneyMode == null)
                      const Padding(
                        padding: EdgeInsets.only(left: 4, top: 4, bottom: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Mode of Journey is Required",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    if (selectedJourneyMode == "Taxi") ...[

                      const SizedBox(height: 15),

                      // Vehicle Type
                      const Text(
                        "Vehicle Type",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: selectedVehicleType,
                        decoration: InputDecoration(
                          hintText: "Select Vehicle Type",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: vehicleTypes.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedVehicleType = value;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      // Vehicle Remarks
                      buildInput(
                        "Vehicle Remarks",
                        vehicleRemarksController,
                      ),
                    ],
                    if (selectedJourneyMode == "Other") ...[

                      const SizedBox(height: 15),

                      buildInput(
                        "Please Specify Other Journey Mode",
                        otherJourneyController,
                      ),

                    ],

                    buildInput(
                      "Remarks",
                      remarksController,
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addJourney,
                        child: const Text("Add Journey"),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: journeyList.length,
                      itemBuilder: (context, index) {
                        final item = journeyList[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text("${item['from']} → ${item['to']}"),
                            subtitle: Text(
                              "Date : ${item['date']}\n"
                                  "Mode : ${item['journey_mode']}\n"
                                  "Remarks : ${item['remarks']}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  journeyList.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    // ================= ADVANCE =================

                    sectionCard(

                      title: "Advance",

                      children: [

                        Row(

                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                          children: [

                            const Text(

                              "Enable Advance",

                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),

                            Switch(

                              value: showAdvance,

                              onChanged: (val) {

                                setState(() {

                                  showAdvance = val;
                                });
                              },
                            ),
                          ],
                        ),

                        if (showAdvance) ...[

                          const SizedBox(
                            height: 15,
                          ),

                          buildInput(
                            "Grant for Advance",
                            advanceController,
                          ),

                          dateField(
                            "Amount should be submitted by",
                            endDate,
                                () => pickDate(false),
                          ),
                        ],
                      ],
                    ),

                    // ================= FILE =================

                    sectionCard(

                      title: "Upload File",

                      children: [

                        SizedBox(

                          width: double.infinity,

                          child: ElevatedButton(

                            onPressed: pickFiles,

                            style:
                            ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.blue,

                              minimumSize:
                              const Size(
                                double.infinity,
                                50,
                              ),

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                            ),

                            child: const Text(

                              "CHOOSE FILE",

                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        if (files.isNotEmpty)

                          Column(

                            children: files.map((f) {

                              return ListTile(

                                leading: const Icon(
                                  Icons.insert_drive_file,
                                ),

                                title: Text(f.name),
                              );
                            }).toList(),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ================= SUBMIT =================

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton(

                        onPressed: submitData,

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          const Color(0xFF162B63),

                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 16,
                          ),

                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),

                        child: const Text(

                          "Submit",

                          style: TextStyle(

                            color: Colors.white,

                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ]
              ),
            ]
        ),
      ),
    );

  }


  // ================= SECTION CARD =================

  Widget sectionCard({

    required String title,

    required List<Widget> children,

  }) {

    return Container(

      width: double.infinity,

      margin:
      const EdgeInsets.only(bottom: 20),

      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        border: Border.all(
          color: Colors.grey.shade400,
        ),

        borderRadius:
        BorderRadius.circular(10),
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style: const TextStyle(

              fontSize: 20,

              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          ...children,
        ],
      ),
    );
  }

  // ================= READONLY FIELD =================

  Widget buildField(
      String label,
      String value,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 18),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: const TextStyle(

              fontSize: 16,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          TextField(

            readOnly: true,

            decoration: InputDecoration(

              hintText: value,

              contentPadding:
              const EdgeInsets.symmetric(

                horizontal: 16,

                vertical: 18,
              ),

              enabledBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                  Colors.grey.shade300,
                ),
              ),

              focusedBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                  Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INPUT =================

  Widget buildInput(

      String label,

      TextEditingController controller,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 18),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: const TextStyle(

              fontSize: 16,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          TextField(

            controller: controller,

            decoration: InputDecoration(

              hintText: label,

              contentPadding:
              const EdgeInsets.symmetric(

                horizontal: 16,

                vertical: 18,
              ),

              enabledBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                  Colors.grey.shade300,
                ),
              ),

              focusedBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                  Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DROPDOWN =================

  Widget dropdownField(

      String label,

      List<String> items,

      Function(String) onChanged,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 18),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: const TextStyle(

              fontSize: 16,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          DropdownButtonFormField<String>(

            isExpanded: true,

            value: label == "Project Scheme"
                ? selectedProjectScheme
                : label == "Mode of Journey"
                ? selectedJourneyMode
                : null,

            decoration: InputDecoration(

              contentPadding:
              const EdgeInsets.symmetric(

                horizontal: 16,

                vertical: 5,
              ),

              enabledBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                  Colors.grey.shade300,
                ),
              ),

              focusedBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(10),

                borderSide: BorderSide(
                  color:
                  Colors.grey.shade400,
                ),
              ),
            ),

            hint: Text(
              "Select $label",
            ),

            items: items.map((e) {

              return DropdownMenuItem<String>(

                value: e,

                child: Text(

                  e,

                  overflow:
                  TextOverflow.ellipsis,
                ),
              );

            }).toList(),

            onChanged: (val) {

              if (val != null) {
                onChanged(val);
              }
            },
          ),
        ],
      ),
    );
  }

  // ================= DATE FIELD =================

  Widget dateField(

      String label,

      DateTime? date,

      VoidCallback onTap,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 18),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            label,

            style: const TextStyle(

              fontSize: 16,

              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          GestureDetector(

            onTap: onTap,

            child: AbsorbPointer(

              child: TextField(

                decoration: InputDecoration(

                  hintText: date == null

                      ? "Select Date"

                      : date
                      .toString()
                      .split(" ")[0],

                  contentPadding:
                  const EdgeInsets.symmetric(

                    horizontal: 16,

                    vertical: 18,
                  ),

                  enabledBorder:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(10),

                    borderSide: BorderSide(
                      color:
                      Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(10),

                    borderSide: BorderSide(
                      color:
                      Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

